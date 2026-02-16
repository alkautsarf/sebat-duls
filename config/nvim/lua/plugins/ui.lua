-- ~/.config/nvim/lua/plugins/ui.lua
return {
  -- Disable LazyVim default colorscheme
  { "LazyVim/lazyvim/plugins/colorscheme", enabled = false },
  -- Night Owl colorscheme with transparency
  {
    "oxfist/night-owl.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("night-owl").setup({
        transparency = true,
      })
      vim.cmd.colorscheme("night-owl")
    end,
  },

  -- Transparency for floats, sidebars, and Oil
  {
    "xiyaowong/nvim-transparent",
    opts = {
      extra_groups = {
        "NormalFloat",
        "FloatBorder",
        "LazyNormal",
        "MasonNormal",
        "TelescopeNormal",
        "TelescopeBorder",
        "WhichKeyNormal",
        "OilNormal", -- ⬅ added
        "OilPreviewNormal", -- ⬅ in case preview window shows
      },
    },
  },
}
