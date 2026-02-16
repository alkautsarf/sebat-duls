return {
  {
    "tomlion/vim-solidity",
    ft = "solidity",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if type(opts.ensure_installed) == "table" and not vim.tbl_contains(opts.ensure_installed, "solidity") then
        table.insert(opts.ensure_installed, "solidity")
      end
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local original = opts.formatters_by_ft.solidity or {}
      local formatters = {}
      for _, formatter in ipairs(original) do
        if formatter ~= "prettierd" then
          table.insert(formatters, formatter)
        end
      end
      table.insert(formatters, "forge_fmt")
      opts.formatters_by_ft.solidity = formatters
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      for _, tool in ipairs({ "nomicfoundation-solidity-language-server", "solhint" }) do
        if not vim.tbl_contains(opts.ensure_installed, tool) then
          table.insert(opts.ensure_installed, tool)
        end
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      local server_opts = opts.servers.solidity_ls_nomicfoundation or {}
      server_opts.settings = vim.tbl_deep_extend("force", server_opts.settings or {}, {
        solidity = {
          diagnostic = { enable = true },
        },
      })
      server_opts.capabilities = server_opts.capabilities or {}
      server_opts.capabilities.textDocument = server_opts.capabilities.textDocument or {}
      server_opts.capabilities.textDocument.diagnostic = server_opts.capabilities.textDocument.diagnostic or {
        dynamicRegistration = false,
      }

      opts.servers.solidity_ls_nomicfoundation = server_opts

      opts.setup = opts.setup or {}
      local existing = opts.setup.solidity_ls_nomicfoundation
      opts.setup.solidity_ls_nomicfoundation = function(server_name, final_opts)
        if existing then
          local override = existing(server_name, final_opts)
          if override ~= nil then
            return override
          end
        end
        final_opts.settings = vim.tbl_deep_extend("force", final_opts.settings or {}, server_opts.settings or {})
        final_opts.capabilities = final_opts.capabilities or {}
        final_opts.capabilities.textDocument = final_opts.capabilities.textDocument or {}
        final_opts.capabilities.textDocument.diagnostic = final_opts.capabilities.textDocument.diagnostic
          or server_opts.capabilities.textDocument.diagnostic
      end
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.solidity = { "solhint" }

      opts.linters = opts.linters or {}
      local solhint_config = vim.fn.expand('~/.config/nvim/solhint-default.json')
      local lint_parser = require("lint.parser")
      local function find_up(patterns, opts)
        if vim.fs and vim.fs.find then
          return vim.fs.find(patterns, opts)[1]
        end
        local search_path = opts and opts.path or vim.fn.getcwd()
        for _, pattern in ipairs(patterns) do
          local found = vim.fn.findfile(pattern, search_path .. ';')
          if found ~= '' then
            return found
          end
        end
      end
      local dirname = vim.fs and vim.fs.dirname or function(path)
        return vim.fn.fnamemodify(path, ':h')
      end

      local function has_project_config(filename)
        if not filename or filename == "" then
          return false
        end
        local targets = {
          '.solhintrc',
          '.solhintrc.json',
          '.solhintrc.js',
          '.solhintrc.cjs',
          '.solhint.json',
          'foundry.toml',
        }
        local dir = dirname(filename)
        return find_up(targets, { path = dir, upward = true }) ~= nil
      end
      local base_parser = lint_parser.from_pattern(
        '^[^:]+:(%d+):(%d+): (%w+) (.-) (%S+)$',
        { 'lnum', 'col', 'severity', 'message', 'code' },
        {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
        },
        { source = 'solhint' }
      )

      opts.linters.solhint = vim.tbl_deep_extend("force", opts.linters.solhint or {}, {
        stdin = true,
        args = { '--formatter', 'unix', '--config', solhint_config, 'stdin' },
        condition = function(ctx)
          return has_project_config(ctx.filename) or vim.fn.executable('solhint') == 1
        end,
        parser = function(output, bufnr)
          local diags = base_parser(output, bufnr)
          for _, diag in ipairs(diags) do
            diag.lnum = math.max(0, (diag.lnum or 1) - 1)
            if diag.col and diag.col > 0 then
              diag.col = math.max(0, diag.col - 1)
              diag.end_col = diag.end_col or (diag.col + 1)
            end
          end
          return diags
        end,
      })

      local lint = require("lint")
      vim.diagnostic.config({
        underline = true,
        virtual_text = { spacing = 2, prefix = '●' },
        update_in_insert = true,
        severity_sort = true,
      }, lint.get_namespace("solhint"))
    end,
  },
}
