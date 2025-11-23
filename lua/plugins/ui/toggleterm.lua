-- Patch to solve a bug in send_lines_to_terminal
local function patch()
  local toggleterm = require 'toggleterm'
  local api = vim.api
  local fn = vim.fn
  local lazy = require 'toggleterm.lazy'
  ---@module "toggleterm.utils"
  local utils = lazy.require 'toggleterm.utils'

  --- @param selection_type string
  --- @param trim_spaces boolean
  --- @param cmd_data table<string, any>
  --- @param go_back boolean? whether or not to return to original window
  local function send_lines_to_terminal(selection_type, trim_spaces, cmd_data, go_back)
    local id = tonumber(cmd_data.args) or 1
    trim_spaces = trim_spaces == nil or trim_spaces

    vim.validate {
      selection_type = { selection_type, 'string', true },
      trim_spaces = { trim_spaces, 'boolean', true },
      terminal_id = { id, 'number', true },
      go_back = { go_back, 'boolean', true },
    }

    local current_window = api.nvim_get_current_win() -- save current window

    local lines = {}
    -- Beginning of the selection: line number, column number
    local start_line, start_col
    if selection_type == 'single_line' then
      start_line, start_col = unpack(api.nvim_win_get_cursor(0))
      -- nvim_win_get_cursor uses 0-based indexing for columns, while we use 1-based indexing
      start_col = start_col + 1
      table.insert(lines, fn.getline(start_line))
    else
      local res = nil
      if string.match(selection_type, 'visual') then
        -- This calls vim.fn.getpos, which uses 1-based indexing for columns
        res = utils.get_line_selection 'visual'
      else
        -- This calls vim.fn.getpos, which uses 1-based indexing for columns
        res = utils.get_line_selection 'motion'
      end
      start_line, start_col = unpack(res.start_pos)
      -- char, line and block are used for motion/operatorfunc. 'block' is ignored
      if selection_type == 'visual_lines' or selection_type == 'line' then
        lines = res.selected_lines
      elseif selection_type == 'visual_selection' or selection_type == 'char' then
        lines = utils.get_visual_selection(res, true)
      end
    end

    -- nvim_win_set_cursor() uses 0-based indexing for columns, while we use 1-based indexing
    api.nvim_win_set_cursor(current_window, { start_line, start_col - 1 })

    if not lines or not next(lines) then
      return
    end

    if not trim_spaces then
      toggleterm.exec(table.concat(lines, '\n'), id, nil, nil, nil, nil, go_back)
    else
      for _, line in ipairs(lines) do
        local l = trim_spaces and line:gsub('^%s+', ''):gsub('%s+$', '') or line
        toggleterm.exec(l, id, nil, nil, nil, nil, go_back)
      end
    end
  end
  toggleterm.send_lines_to_terminal = send_lines_to_terminal
end

---@module 'lazy/types'
---@type LazyPluginSpec
return {
  'akinsho/toggleterm.nvim',
  config = function()
    local toggleterm = require 'toggleterm'

    patch()

    toggleterm.setup {
      open_mapping = [[<c-\>]],
      direction = 'float',
      float_opts = {
        border = 'curved',
        winblend = 20,
      },
    }

    local trim_spaces = true
    vim.keymap.set({ 'n', 'v' }, '<leader>Tp', function()
      local mode = vim.api.nvim_get_mode().mode
      local selection_type = 'single_line'
      if mode == 'v' or mode == '' or mode == 'V' then
        selection_type = 'visual_selection'
      end
      toggleterm.send_lines_to_terminal(selection_type, trim_spaces, { args = vim.v.count })
    end, { desc = '[T]erminal [P]aste' })

    vim.keymap.set('n', '<leader>Tn', '<Cmd>TermNew<CR>', { desc = '[T]erminal [N]ew' })
    vim.keymap.set('n', '<leader>Ts', '<Cmd>TermSelect<CR>', { desc = '[T]erminal [S]elect' })
  end,
}
