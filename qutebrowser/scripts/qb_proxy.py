import asyncio
import json
import aiohttp
from aiohttp import web
import sys

TARGET_PORT = 2262
PROXY_PORT = 9222

async def handle_http(request):
    path = request.path.rstrip('/')
    url_path = path if path else '/'
    sys.stderr.write(f"HTTP {request.method} {url_path}\n")
    sys.stderr.flush()
    
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(f"http://127.0.0.1:{TARGET_PORT}{url_path}") as res:
                if path == '/json/version':
                    data = await res.json()
                    data['Browser'] = "Chrome/134.0.0.0"
                    ws_url = data['webSocketDebuggerUrl']
                    data['webSocketDebuggerUrl'] = ws_url.replace(str(TARGET_PORT), str(PROXY_PORT))
                    return web.json_response(data)
                elif path in ['/json', '/json/list']:
                    data = await res.json()
                    for item in data:
                        if 'webSocketDebuggerUrl' in item:
                            item['webSocketDebuggerUrl'] = item['webSocketDebuggerUrl'].replace(str(TARGET_PORT), str(PROXY_PORT))
                    return web.json_response(data)
                else:
                    body = await res.read()
                    return web.Response(body=body, content_type=res.content_type)
        except Exception as e:
            sys.stderr.write(f"HTTP Error: {e}\n")
            sys.stderr.flush()
            return web.Response(text=str(e), status=502)

async def handle_ws(request):
    sys.stderr.write(f"WS Connection: {request.path}\n")
    sys.stderr.flush()
    ws_client = web.WebSocketResponse(autoclose=False, autoping=False)
    await ws_client.prepare(request)
    
    target_url = f"ws://127.0.0.1:{TARGET_PORT}{request.path}"
    
    async with aiohttp.ClientSession() as session:
        async with session.ws_connect(target_url, autoclose=False, autoping=False) as ws_target:
            async def forward_to_target():
                try:
                    async for msg in ws_client:
                        if msg.type == aiohttp.WSMsgType.TEXT:
                            try:
                                data = json.loads(msg.data)
                                if data.get('method') == 'Target.createBrowserContext':
                                    sys.stderr.write("Mocking Target.createBrowserContext\n")
                                    sys.stderr.flush()
                                    await ws_client.send_str(json.dumps({
                                        "id": data['id'],
                                        "result": {"browserContextId": "fake-context-1"}
                                    }))
                                    continue
                                elif data.get('method') == 'Target.getBrowserContexts':
                                    await ws_client.send_str(json.dumps({
                                        "id": data['id'],
                                        "result": {"browserContextIds": ["fake-context-1"]}
                                    }))
                                    continue
                                elif data.get('method') == 'Target.setDiscoverTargets':
                                    sys.stderr.write("Mocking Target.setDiscoverTargets\n")
                                    sys.stderr.flush()
                                    await ws_client.send_str(json.dumps({
                                        "id": data['id'],
                                        "result": {}
                                    }))
                                    continue
                            except:
                                pass
                            await ws_target.send_str(msg.data)
                        elif msg.type == aiohttp.WSMsgType.BINARY:
                            await ws_target.send_bytes(msg.data)
                        elif msg.type == aiohttp.WSMsgType.CLOSE:
                            await ws_target.close()
                except Exception as e:
                    sys.stderr.write(f"Forward to target error: {e}\n")
                    sys.stderr.flush()

            async def forward_to_client():
                try:
                    async for msg in ws_target:
                        if msg.type == aiohttp.WSMsgType.TEXT:
                            if not ws_client.closed:
                                try:
                                    data = json.loads(msg.data)
                                    # Intercept Browser.getVersion response
                                    if data.get('result', {}).get('product', '').startswith('qutebrowser'):
                                        data['result']['product'] = "Chrome/134.0.0.0"
                                        await ws_client.send_str(json.dumps(data))
                                        continue
                                except:
                                    pass
                                await ws_client.send_str(msg.data)
                        elif msg.type == aiohttp.WSMsgType.BINARY:
                            if not ws_client.closed:
                                await ws_client.send_bytes(msg.data)
                        elif msg.type == aiohttp.WSMsgType.CLOSE:
                            if not ws_client.closed:
                                await ws_client.close()
                except Exception as e:
                    sys.stderr.write(f"Forward to client error: {e}\n")
                    sys.stderr.flush()

            await asyncio.gather(forward_to_target(), forward_to_client())
            
    return ws_client

async def main():
    app = web.Application()
    app.router.add_get('/devtools/browser/{id}', handle_ws)
    app.router.add_get('/devtools/page/{id}', handle_ws)
    app.router.add_get('/{tail:.*}', handle_http)
    
    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '127.0.0.1', PROXY_PORT)
    await site.start()
    sys.stderr.write(f"Proxy started on port {PROXY_PORT}\n")
    sys.stderr.flush()
    await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
