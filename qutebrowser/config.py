import os
import subprocess

config.load_autoconfig(False)

c.fonts.default_family = "Ioskeley Mono"
c.fonts.default_size = "17pt"
c.fonts.web.family.standard = "Ioskeley Mono"
c.fonts.web.family.fixed = "Ioskeley Mono"
c.fonts.web.family.serif = "Ioskeley Mono"
c.fonts.web.family.sans_serif = "Ioskeley Mono"

c.tabs.position = "left"
c.tabs.width = "15%"
c.tabs.show = "switching"
c.tabs.favicons.show = "always"
c.tabs.title.format = "{index}: {audio}{current_title}"
c.statusbar.show = "in-mode"
c.window.hide_decoration = True
c.scrolling.smooth = True

c.qt.args = ['remote-debugging-port=2262']
c.content.headers.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36'

c.content.blocking.method = 'both'
c.content.blocking.adblock.lists = [
    "https://easylist.to/easylist/easylist.txt",
    "https://easylist.to/easylist/easyprivacy.txt",
    "https://secure.fanboy.co.nz/fanboy-annoyance.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/annoyances.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/unbreak.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/resource-abuse.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/privacy.txt",
    "https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/filters-2026.txt"
]
c.content.blocking.whitelist = ["*://*.youtube.com/*"]

c.content.javascript.enabled = True
c.content.cookies.accept = 'all'

bg_dark = "#010c18"
fg_light = "#d6deeb"
accent_cyan = "#82aaff"
accent_green = "#addb67"
accent_red = "#ef5350"
selection_bg = "#5f7e97"

c.colors.webpage.darkmode.enabled = False
c.colors.webpage.preferred_color_scheme = "dark"

c.colors.completion.fg = fg_light
c.colors.completion.odd.bg = bg_dark
c.colors.completion.even.bg = bg_dark
c.colors.completion.category.fg = accent_cyan
c.colors.completion.category.bg = bg_dark
c.colors.completion.category.border.top = bg_dark
c.colors.completion.category.border.bottom = bg_dark
c.colors.completion.item.selected.fg = "#ffffff"
c.colors.completion.item.selected.bg = selection_bg
c.colors.completion.match.fg = accent_green

c.colors.statusbar.normal.fg = fg_light
c.colors.statusbar.normal.bg = bg_dark
c.colors.statusbar.insert.bg = accent_green
c.colors.statusbar.url.success.https.fg = accent_green

c.colors.tabs.bar.bg = bg_dark
c.colors.tabs.odd.fg = fg_light
c.colors.tabs.odd.bg = bg_dark
c.colors.tabs.even.fg = fg_light
c.colors.tabs.even.bg = bg_dark
c.colors.tabs.selected.odd.fg = "#ffffff"
c.colors.tabs.selected.odd.bg = selection_bg
c.colors.tabs.selected.even.fg = "#ffffff"
c.colors.tabs.selected.even.bg = selection_bg

c.colors.hints.fg = "#000000"
c.colors.hints.bg = accent_cyan
c.colors.hints.match.fg = "#ffffff"

config.bind('T', 'config-cycle tabs.show always switching')
config.bind('B', 'cmd-set-text -s :tab-select')
config.bind('J', 'tab-next')
config.bind('K', 'tab-prev')
config.bind('H', 'back')
config.bind('L', 'forward')
config.bind('<Ctrl-j>', 'tab-move +')
config.bind('<Ctrl-k>', 'tab-move -')
config.bind('<Ctrl-r>', 'config-source')
config.bind('<Meta-r>', 'config-source')
config.bind('<Mod1-Tab>', 'tab-focus last')

c.editor.command = ["ghostty", "-e", "nvim", "{file}"]
c.url.searchengines = {
    "DEFAULT": "https://google.com/search?q={}",
    "g": "https://google.com/search?q={}",
    "y": "https://youtube.com/results?search_query={}",
    "gh": "https://github.com/search?q={}",
    "r": "https://reddit.com/r/{}"
}
c.completion.open_categories = ["searchengines", "quickmarks", "bookmarks", "history", "filesystem"]

# elsummariz00r
c.aliases['summarize'] = 'spawn --userscript summarize'
c.aliases['resummarize'] = 'spawn --userscript resummarize'
c.aliases['discuss'] = 'spawn --userscript discuss'
c.auto_save.session = True
c.session.lazy_restore = True

c.content.user_stylesheets = [os.path.expanduser("~/.qutebrowser/force-font.css")]

proxy_path = os.path.expanduser("~/.config/qutebrowser/scripts/qb_proxy.py")
if os.path.exists(proxy_path):
    subprocess.Popen(["/opt/homebrew/opt/python@3.14/bin/python3.14", proxy_path],
                     stdout=subprocess.DEVNULL,
                     stderr=subprocess.DEVNULL,
                     preexec_fn=os.setpgrp)
