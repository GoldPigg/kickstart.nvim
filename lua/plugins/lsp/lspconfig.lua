---@param event vim.api.keyset.create_autocmd.callback_args
function SetDocumentHighlight(event)
  -- The following two autocommands are used to highlight references of the
  --    See `:help CursorHold` for information about when this is executed
  local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    buffer = event.buf,
    group = highlight_augroup,
    callback = vim.lsp.buf.document_highlight,
  })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    buffer = event.buf,
    group = highlight_augroup,
    callback = vim.lsp.buf.clear_references,
  })

  vim.api.nvim_create_autocmd('LspDetach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
    callback = function(event2)
      vim.lsp.buf.clear_references()
      vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
    end,
  })
end

---@param event vim.api.keyset.create_autocmd.callback_args
---@param opts table<string, boolean | nil>
function SetKeymap(event, opts)
  local map = function(keys, func, desc, mode)
    if opts[keys] ~= false then
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
  end

  -- Rename the variable under your cursor.
  map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

  -- Execute a code action, usually your cursor needs to be on top of an error
  map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

  -- Find references for the word under your cursor.
  map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types without an actual implementation.
  map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

  -- Jump to the definition of the word under your cursor.
  map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

  -- WARN: This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header.
  map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  -- Fuzzy find all the symbols in your current document.
  map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')

  -- Fuzzy find all the symbols in your current workspace.
  --  Similar to document symbols, except searches over your entire project.
  map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')

  -- Jump to the type of the word under your cursor.
  map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

  -- Show diagnostics of the line under your cursor.
  map('gsd', function()
    local _, win = vim.diagnostic.open_float { scope = 'l' }
    if win == nil then
      print 'Here is no diagnostic.'
      return nil
    end
    vim.api.nvim_set_current_win(win)
  end, '[S]how [D]iagnostics')

  -- The following code creates a keymap to toggle inlay hints in your
  -- code, if the language server you are using supports them
  map('<leader>th', function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
  end, '[T]oggle Inlay [H]ints')
end

---@param event vim.api.keyset.create_autocmd.callback_args
function LspAttach(event)
  -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
  ---@param client vim.lsp.Client
  ---@param method vim.lsp.protocol.Method
  ---@param bufnr? integer some lsp support methods only in specific files
  ---@return boolean
  local function client_supports_method(client, method, bufnr)
    if vim.fn.has 'nvim-0.11' == 1 then
      return client:supports_method(method, bufnr)
    else
      return client.supports_method(method, { bufnr = bufnr })
    end
  end

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
    SetDocumentHighlight(event)
  end

  SetKeymap(event, { ['<leader>th'] = client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) })
end

function SetDiagnostic()
  -- Diagnostic Config
  -- See :help vim.diagnostic.Opts
  local signs = vim.g.have_nerd_font
      and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚',
          [vim.diagnostic.severity.WARN] = '󰀪',
          [vim.diagnostic.severity.INFO] = '󰋽',
          [vim.diagnostic.severity.HINT] = '󰌶',
        },
      }
    or {}
  vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = signs,
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      prefix = function(diagnostic, i, total)
        print(diagnostic.severity, i, total)
        return string.format('[%s%d/%d]', signs.text[diagnostic.severity], i, total)
      end,
      format = function(diagnostic)
        local diagnostic_message = {
          [vim.diagnostic.severity.ERROR] = diagnostic.message,
          [vim.diagnostic.severity.WARN] = diagnostic.message,
          [vim.diagnostic.severity.INFO] = diagnostic.message,
          [vim.diagnostic.severity.HINT] = diagnostic.message,
        }
        return diagnostic_message[diagnostic.severity]
      end,
    },
  }
end

-- LSP Plugins
---@module 'lazy/types'
---@type LazyPluginSpec
return {
  -- Main LSP Configuration
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    --  This function gets run when an LSP attaches to a particular buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = LspAttach,
    })

    SetDiagnostic()
  end,
}
