---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local util = require 'util'
    local db = require 'dashboard'

    local theme = 'hyper'
    local vertical_center = true
    local footer = {}
    local file_path = vim.fn.stdpath 'config' .. '/header.txt'

    ---@type Style[][]
    local styles = {}
    local header = {}
    for i, line in ipairs(vim.fn.readfile(file_path)) do
      if line ~= '' then
        header[i], styles[i] = util.parse_ansi_string(line)
      end
    end

    db.setup {
      theme = theme,
      config = {
        header = header,
        vertical_center = vertical_center,
        shortcut = {
          { desc = '󰊳 Update', group = '@property', action = 'Lazy update', key = 'u' },
          {
            icon = ' ',
            icon_hl = '@variable',
            desc = 'Files',
            group = 'Label',
            action = 'Telescope find_files',
            key = 'f',
          },
          {
            desc = ' Apps',
            group = 'DiagnosticHint',
            action = 'Telescope app',
            key = 'a',
          },
          {
            desc = ' dotfiles',
            group = 'Number',
            action = 'Telescope dotfiles',
            key = 'd',
          },
        },
        footer = footer,
        project = { limit = 2 },
        mru = { limit = 5 },
      },
    }

    vim.api.nvim_create_autocmd('User', {
      pattern = 'DashboardLoaded',
      callback = function()
        vim.api.nvim_set_hl(0, 'DashboardHeader', {})

        local ns = vim.api.nvim_create_namespace 'DashboardHeader'
        vim.api.nvim_win_set_hl_ns(db.winid, ns)

        local line_st = 0
        if vertical_center and theme == 'doom' then
          line_st = math.floor(vim.o.lines / 2) - math.ceil((vim.api.nvim_buf_line_count(db.bufnr) + math.ceil(#footer / 2) - 3) / 2) - 2
        end

        for i, line in ipairs(styles) do
          local col_st = math.floor((vim.o.columns - vim.api.nvim_strwidth(header[i])) / 2)
          for j, style in ipairs(line) do
            local fg, bg = style.fg or '', style.bg or ''
            local hl_name = fg:sub(2) .. bg:sub(2)
            local pos = { line_st + i - 1, col_st + j - 1 }
            vim.api.nvim_set_hl(ns, hl_name, style)
            vim.hl.range(db.bufnr, ns, hl_name, pos, pos, { inclusive = true })
          end
        end
      end,
    })
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
