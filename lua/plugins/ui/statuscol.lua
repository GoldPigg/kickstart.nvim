---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'luukvbaal/statuscol.nvim',
  event = 'FileType',
  config = function()
    local builtin = require 'statuscol.builtin'
    local ft_ignore = { 'help', 'vim', 'alpha', 'dashboard', 'neo-tree', 'lazy' }
    require('statuscol').setup {
      relculright = true,
      ft_ignore = ft_ignore,
      bt_ignore = { 'nofile' },
      segments = {
        {
          sign = { namespace = { 'diagnostic' }, maxwidth = 1, auto = true },
          click = 'v:lua.ScSa',
        },
        {
          sign = { namespace = { 'gitsigns' }, maxwidth = 1, auto = true },
          click = 'v:lua.ScSa',
        },
        {
          sign = { name = { 'Dap.*' }, maxwidth = 1, auto = true },
          click = 'v:lua.ScSa',
        },
        { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
        { text = { builtin.foldfunc, ' ' }, click = 'v:lua.ScFa' },
      },
    }
    vim.api.nvim_create_autocmd({ 'FileType', 'BufEnter' }, {
      callback = function()
        local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
        if vim.tbl_contains(ft_ignore, filetype) then
          vim.cmd 'setlocal foldcolumn=0'
        end
      end,
    })
  end,
}
