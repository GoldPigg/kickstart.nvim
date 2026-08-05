---@class Util
local M = {}

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

return M
