---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = { github = {
      download_url_template = 'https://gh-proxy.org/https://github.com/%s/releases/download/%s/%s',
    } } },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Allows extra capabilities provided by blink.cmp
    'saghen/blink.cmp',
  },
  config = function()
    local Util = require 'util'

    local servers = {}

    -- Load lsp config in the fold 'lua/lsp'
    Util.deep_lsmod('lsp', function(name, path, type)
      if type == 'file' or type == 'link' then
        local mod, err = loadfile(path)
        if mod == nil then
          vim.print('When load ' .. name .. ' from ' .. path .. ' error\n' .. err)
        else
          servers = vim.tbl_extend('force', servers, mod())
        end
      end
    end)

    local ensure_installed = {}
    for server_name, server in pairs(servers) do
      local config = { server_name }
      if server.version then
        config.version = server.version
        config.auto_update = false
      end
      ensure_installed[#ensure_installed + 1] = config
    end
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
