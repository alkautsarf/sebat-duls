return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}

      local function ensure(opts_table, overrides)
        opts_table = opts_table or {}
        for key, value in pairs(overrides) do
          if type(value) == "table" and type(opts_table[key]) == "table" then
            opts_table[key] = vim.tbl_deep_extend("force", opts_table[key], value)
          else
            opts_table[key] = value
          end
        end
        return opts_table
      end

      opts.picker.sources.files = ensure(opts.picker.sources.files, {
        hidden = true,
        ignored = true,
      })

      opts.picker.sources.grep = ensure(opts.picker.sources.grep, {
        hidden = true,
        ignored = true,
      })

      opts.picker.sources.grep_word = ensure(opts.picker.sources.grep_word, {
        hidden = true,
        ignored = true,
      })

      opts.picker.sources.grep_buffers = ensure(opts.picker.sources.grep_buffers, {
        hidden = true,
        ignored = true,
      })

      return opts
    end,
  },
}
