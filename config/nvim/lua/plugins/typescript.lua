return {
  -- Ensure required external tooling is installed through mason.nvim
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, tool in ipairs({
        "typescript-language-server",
        "prettierd",
        "eslint_d",
        "biome",
      }) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },

  -- Configure formatting preferences for JS/TS-ecosystem files
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local function ensure_formatters(ft)
        if not opts.formatters_by_ft[ft] then
          opts.formatters_by_ft[ft] = vim.deepcopy({ "biome", "prettierd", "prettier" })
        end
      end
      for _, ft in ipairs({
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
      }) do
        ensure_formatters(ft)
      end
    end,
  },

  -- Wire eslint_d into nvim-lint so diagnostics stay in sync with local config
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      local js_like = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      }
      for _, ft in ipairs(js_like) do
        opts.linters_by_ft[ft] = { "biome", "eslint_d" }
      end

      opts.linters = opts.linters or {}
      local lint = require("lint")

      local uv = vim.uv or vim.loop

      local root_pattern = (function()
        local ok, lsp_util = pcall(require, "lspconfig.util")
        if ok and type(lsp_util.root_pattern) == "function" then
          return lsp_util.root_pattern
        end
        local function fallback(...)
          local patterns = { ... }
          return function(startpath)
            if not startpath or startpath == "" then
              return nil
            end
            local dirname = (vim.fs and vim.fs.dirname and vim.fs.dirname(startpath))
              or vim.fn.fnamemodify(startpath, ":h")
            if not dirname or dirname == "" then
              dirname = "."
            end
            if vim.fs and vim.fs.find and vim.fs.dirname then
              local found = vim.fs.find(patterns, { path = dirname, upward = true })
              if found and found[1] then
                return vim.fs.dirname(found[1])
              end
            else
              for _, pattern in ipairs(patterns) do
                local found = vim.fn.findfile(pattern, dirname .. ";")
                if found ~= "" then
                  return vim.fn.fnamemodify(found, ":p:h")
                end
              end
            end
            return nil
          end
        end
        return fallback
      end)()

      local joinpath = (vim.fs and vim.fs.joinpath) or function(...)
        return table.concat({ ... }, "/")
      end

      local function path_exists(path)
        return path and path ~= "" and uv and uv.fs_stat and uv.fs_stat(path) ~= nil
      end

      local eslint_config_candidates = {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.jsonc",
      }

      local function has_eslint_config(root)
        for _, name in ipairs(eslint_config_candidates) do
          if path_exists(joinpath(root, name)) then
            return true
          end
        end

        local package_path = joinpath(root, "package.json")
        if path_exists(package_path) and vim.fn.filereadable(package_path) == 1 then
          local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(package_path), "\n"))
          if ok and type(data) == "table" and data.eslintConfig ~= nil then
            return true
          end
        end

        return false
      end

      opts.linters.eslint_d = vim.tbl_deep_extend("force", opts.linters.eslint_d or {}, {
        prefer_local = "node_modules/.bin",
        condition = function(ctx)
          local root = root_pattern(
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.cjs",
            ".eslintrc.json",
            ".eslintrc.yaml",
            ".eslintrc.yml",
            ".eslintrc.jsonc",
            "package.json"
          )(ctx.filename)

          if not root then
            return false
          end

          if not has_eslint_config(root) then
            return false
          end

          if vim.fn.isdirectory(joinpath(root, "node_modules")) == 0 then
            return false
          end

          return true
        end,
      })

      opts.linters.biome = vim.tbl_deep_extend("force", opts.linters.biome or {}, {
        condition = function(ctx)
          return root_pattern("biome.json", "biome.jsonc", "biome.json5")(ctx.filename) ~= nil
        end,
      })
    end,
  },
}
