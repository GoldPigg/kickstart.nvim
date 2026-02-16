---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local util = require 'util'
    local db = require 'dashboard'

    local theme = 'doom'
    local vertical_center = true
    local footer = { '☄  And in that light, I find deliverance.' }
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
        center = {
          {
            icon = '󰒲 ',
            desc = 'Manage Plugins       ',
            key = 'l',
            key_format = ' %s',
            action = 'Lazy',
          },
          {
            icon = ' ',
            desc = 'Manage LSP',
            key = 'm',
            key_format = ' %s',
            action = 'Mason',
          },
          {
            icon = '󰈞 ',
            desc = 'Recent Files',
            key = 'f',
            key_hl = 'Number',
            key_format = ' %s',
            action = 'Telescope oldfiles',
          },
          {
            icon = ' ',
            desc = 'Recent Projects',
            key = 'p',
            key_format = ' %s',
            action = 'Telescope projects',
          },
        },
        footer = footer,
      },
    }

    vim.api.nvim_create_autocmd('User', {
      pattern = 'DashboardLoaded',
      callback = function()
        vim.api.nvim_set_hl(0, 'DashboardHeader', {})
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#A034CA', bold = true, standout = true })

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
