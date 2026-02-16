local function remove_value(list, value)
  if not list then
    return
  end
  local filtered = {}
  for _, item in ipairs(list) do
    if item ~= value then
      table.insert(filtered, item)
    end
  end
  return filtered
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.formatters_by_ft then
        return
      end
      opts.formatters_by_ft.markdown = remove_value(opts.formatters_by_ft.markdown, "markdownlint-cli2")
      opts.formatters_by_ft["markdown.mdx"] = remove_value(opts.formatters_by_ft["markdown.mdx"], "markdownlint-cli2")
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      if not opts.sources then
        return
      end
      local filtered = {}
      for _, source in ipairs(opts.sources) do
        if source.name ~= "markdownlint_cli2" then
          table.insert(filtered, source)
        end
      end
      opts.sources = filtered
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      if not opts.linters_by_ft then
        return
      end
      opts.linters_by_ft.markdown = nil
      opts.linters_by_ft["markdown.mdx"] = nil
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if not opts.ensure_installed then
        return
      end
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "markdownlint-cli2"
      end, opts.ensure_installed)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        markdownlint = false,
      },
    },
  },
}
