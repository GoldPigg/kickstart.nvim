---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  config = function()
    local db = require 'dashboard'

    local theme = 'doom'
    local vertical_center = true
    local footer = { '☄  And in that light, I find deliverance.' }
    local file_path = vim.fn.stdpath 'config' .. '/header.txt'

    ---@diagnostic disable-next-line: duplicate-set-field
    require('dashboard.utils').center_align = function(tbl)
      local function fill_sizes(lines)
        local fills = {}
        for _, line in pairs(lines) do
          local width = tbl.width
          if width == nil then
            width = vim.api.nvim_strwidth(line)
          end
          table.insert(fills, math.floor((vim.o.columns - width) / 2))
        end
        return fills
      end

      local centered_lines = {}
      local fills = fill_sizes(tbl)

      for i = 1, #tbl do
        local fill_line = (' '):rep(fills[i]) .. tbl[i]
        table.insert(centered_lines, fill_line)
      end

      return centered_lines
    end

    local header = vim.tbl_extend('keep', { width = 28 }, vim.fn.readfile(file_path))

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
        vim.api.nvim_open_term(0, {})
      end,
      once = true,
    })
  end,
  dependencies = { { 'nvim-tree/nvim-web-devicons' } },
}
