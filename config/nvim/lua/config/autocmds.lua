-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function set_diag_highlights()
  local palette = {
    DiagnosticUnderlineError = '#ff5f87',
    DiagnosticUnderlineWarn = '#ffd75f',
    DiagnosticUnderlineInfo = '#5fd7ff',
    DiagnosticUnderlineHint = '#afffd7',
  }
  for group, color in pairs(palette) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
    if not ok then
      hl = {}
    end
    hl.undercurl = true
    hl.underline = true
    hl.sp = color
    hl.fg = hl.fg or color
    vim.api.nvim_set_hl(0, group, hl)
  end
end

set_diag_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = set_diag_highlights,
})

vim.diagnostic.config({
  underline = true,
  update_in_insert = true,
  severity_sort = true,
  virtual_text = { spacing = 2, prefix = '●' },
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    pcall(vim.diagnostic.config, {
      underline = true,
      update_in_insert = true,
      severity_sort = true,
      virtual_text = { spacing = 2, prefix = '●' },
    }, args.buf)
  end,
})

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup('solidity_indent', { clear = true })

autocmd('FileType', {
  group = augroup,
  pattern = 'solidity',
  callback = function(event)
    local buf = event.buf
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    vim.schedule(function()
      if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
        return
      end

      pcall(vim.cmd, 'silent! runtime indent/solidity.vim')

      local ok, bo = pcall(function()
        return vim.bo[buf]
      end)
      if not ok then
        return
      end

      bo.autoindent = true
      bo.smartindent = false
      bo.cindent = false
      bo.expandtab = true
      bo.shiftwidth = 2
      bo.tabstop = 2
      bo.softtabstop = 2

      pcall(vim.api.nvim_buf_set_option, buf, 'indentexpr', 'GetSolidityIndent()')
      pcall(vim.api.nvim_buf_set_option, buf, 'indentkeys', [[0{,0},0),0],0\,,!^F,o,O,e]])
    end)
  end,
})


