local vue_language_server_path = vim.env.MASON .. '/packages/vue-language-server/@vue/language-server'
local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}
return {
  vtsls = {
    settings = {
      vtsls = {
        tsserver = {
          globalPlugins = {
            vue_plugin,
          },
        },
      },
    },
    on_attach = function(client)
      local existing_capabilities = client.server_capabilities
      if vim.bo.filetype == 'vue' then
        existing_capabilities.semanticTokensProvider.full = false
      else
        existing_capabilities.semanticTokensProvider.full = true
      end
    end,
    filetypes = tsserver_filetypes,
  },
}
