---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    options = {
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      disabled_filetypes = {
        statusline = { 'neo-tree', 'dashboard' },
        winbar = { 'neo-tree', 'dashboard' },
      },
      ignore_focus = { 'neo-tree' },
      globalstatus = true,
    },
    sections = {
      lualine_b = { 'project', 'branch' },
      lualine_c = { 'encoding', 'filesize' },
      lualine_x = { 'lsp_status', 'filetype' },
      lualine_y = { 'searchcount', 'progress' },
      lualine_z = { 'selectioncount', 'location' },
    },
    winbar = {
      lualine_c = {
        { 'filetype', icon_only = true, separator = { left = '', right = '' } },
        { 'filename', symbols = { modified = '●' } },
      },
    },
    inactive_winbar = { lualine_c = { 'filename' } },
    extensions = { 'toggleterm' },
  },
}
