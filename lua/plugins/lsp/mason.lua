---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'mason-org/mason-lspconfig.nvim',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Allows extra capabilities provided by blink.cmp
    'saghen/blink.cmp',
  },
  config = function()
    local Util = require 'util'
    local capabilities = require('blink.cmp').get_lsp_capabilities()

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

    local ensure_installed = vim.tbl_keys(servers or {})
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
      automatic_installation = false,
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for ts_ls)
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
