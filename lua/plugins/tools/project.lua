---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'ahmedkhalf/project.nvim',
  config = function()
    require('project_nvim').setup {}
  end,
}
