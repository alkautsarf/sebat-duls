return {
  "okuuva/auto-save.nvim",
  event = "BufReadPost",
  opts = {
    debounce_delay = 3000,
    condition = function(buf)
      local bo = vim.bo[buf]
      if bo.buftype ~= "" or bo.modifiable == false then
        return false
      end
      if bo.filetype == "" and vim.api.nvim_buf_get_name(buf) == "" then
        return false
      end
      return true
    end,
  },
}
