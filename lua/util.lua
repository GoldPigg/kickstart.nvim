---@class Util
local M = {}

local ANSI_MAX_LEN = 20

--- Modified from 'lazy.core.util'.
---@param modname string
---@param fn fun(modname:string, modpath:string, type:'file' | 'link' | 'directory')
function M.deep_lsmod(modname, fn)
  ---@type LazyUtil
  local LazyUtil = require 'lazy.util'
  local root, match = LazyUtil.find_root(modname)
  if not root then
    return
  end

  if match:sub(-4) == '.lua' then
    fn(modname, match, 'file')
    if not vim.uv.fs_stat(root) then
      return
    end
  end

  local cur = modname
  local function fn1(path, name, type)
    if (type == 'file' or type == 'link') and name:sub(-4) == '.lua' then
      fn(cur .. '.' .. name:sub(1, -5), path, type)
    elseif type == 'directory' then
      local tmp = cur
      cur = cur .. '.' .. name
      fn(cur, path, type)
      LazyUtil.ls(path, fn1)
      cur = tmp
    end
  end
  LazyUtil.ls(root, fn1)
end

--- Get all submodules (include modname) in modname.
---@param modname string
---@return string[]
function M.get_submods(modname)
  local res = { modname }

  M.deep_lsmod(modname, function(name, _, type)
    if type == 'directory' then
      res[#res + 1] = name
    end
  end)

  return res
end

---@alias Style vim.api.keyset.highlight

---@param color string[]
---@return string
function M.format_color(color)
  local res = '#'
  for _, v in ipairs(color) do
    res = res .. string.format('%02X', v)
  end
  return res
end

---@param str string
---@return Style | nil
function M.parse_ansi(str)
  local args = vim.tbl_map(tonumber, vim.split(str, ';'))

  if #args == 1 then
    if args[1] == 0 then
      return {}
    end
  end

  if #args == 5 then
    local color = M.format_color { args[3], args[4], args[5] }
    if args[1] == 38 then
      return { fg = color }
    end
    if args[1] == 48 then
      return { bg = color }
    end
  end

  return nil
end

---@param str string
---@return string
---@return Style[]
function M.parse_ansi_string(str)
  local text, styles = '', {}
  local cur, cur_style = 0, {}
  local i = 1
  while i <= #str do
    local flag = false
    local j = i + 1
    if str:sub(i, i) == '\x1B' then
      while j <= #str and j - i < ANSI_MAX_LEN do
        if str:sub(j, j) == 'm' then
          flag = true
          break
        end
        j = j + 1
      end
    end

    if flag then
      local style = M.parse_ansi(str:sub(i + 2, j - 1))
      if style == {} then
        cur_style = {}
      elseif style then
        cur_style = vim.tbl_extend('force', cur_style, style)
      end
      i = j
    else
      cur = cur + 1
      styles[cur] = cur_style
      text = text .. str:sub(i, i)
    end

    i = i + 1
  end

  return text, styles
end

return M
