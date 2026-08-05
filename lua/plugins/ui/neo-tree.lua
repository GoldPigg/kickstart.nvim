return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    event_handlers = {
      {
        event = 'file_opened',
        handler = function()
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local filetype = vim.api.nvim_get_option_value('filetype', {
              buf = buf,
            })
            if filetype == 'dashboard' then
              vim.api.nvim_win_close(win, true)
              ---@diagnostic disable-next-line:  missing-fields
              require('neo-tree.events').unsubscribe { event = 'file_opened', id = 'close_dashboard' }
              break
            end
          end
        end,
        id = 'close_dashboard',
      },
    },
    filesystem = {
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
