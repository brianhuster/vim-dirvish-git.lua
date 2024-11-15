require('dirvish_git._vim')
local utils = require('dirvish_git.utils')
local bool = utils.bool

local M = {}
M.config = {}

M.cache = {}

local isnvim = bool(vim.fn.has('nvim'))

Count = 0

---@class dict

---@type string
local sep = bool(vim.fn.exists('+shellslash')) and not bool(vim.o.shellslash) and '\\' or '/'

---@param current_dir string
local function get_git_root(current_dir)
	local root = utils.system(('git -C %s rev-parse --show-toplevel'):format(current_dir))
	return root and vim.trim(root) or nil
end

---@param dir string
local function is_git_repo(dir)
	return bool(vim.fn.isdirectory(dir .. sep .. '.git'))
end

---@param us string
---@param them string
local function translate_git_status(us, them)
	if us == '?' and them == '?' then
		return 'untracked'
	elseif us == ' ' and them == 'M' then
		return 'modified'
	elseif us:match('[MAC]') then
		return 'staged'
	elseif us == 'R' then
		return 'renamed'
	elseif us == 'U' or them == 'U' or (us == 'A' and them == 'A') or (us == 'D' and them == 'D') then
		return 'unmerged'
	elseif us == '!' then
		return 'ignored'
	else
		return 'unknown'
	end
end

---@param path string
local function get_git_status(path)
	local current_dir = vim.fn.expand('%')
	if not vim.b.git_root then
		vim.b.git_root = get_git_root(current_dir)
	else
		local git_root = vim.b.git_root
		if not is_git_repo(git_root) then
			vim.b.git_root = get_git_root(current_dir)
		end
	end
	local git_root = vim.b.git_root
	if not git_root then
		return
	end
	local base_path = path:sub(#git_root + 2)

	local callback = function(job, stdout)
		local status_msg = stdout[1]
		local data = { status_msg:match('(.)(.)%s(.*)') }
		if #data > 0 then
			local us, them = data[1], data[2]
			local status = translate_git_status(us, them)
			if M.config.git_icons then
				M.cache[path] = M.config.git_icons[status]
				if vim.bo.filetype == 'dirvish' then
					vim.fn['dirvish#apply_icons']()
				end
			end
		else
			M.cache[path] = nil
		end
	end
	if not bool(vim.fn.isdirectory(path)) then
		utils.async_system(('git status --porcelain --ignored=no %s'):format(base_path), callback)
	else
		path = path .. sep
		utils.async_system(('git status --porcelain --ignored --renames %s'):format(base_path), callback)
	end
end

---@param file string
function M.add_icon(file)
	local git_icon = M.cache[file]
	if not git_icon then
		return file:sub(-1) == sep and M.config.git_icons.directory or M.config.git_icons.file
	end
	return git_icon
end

function M.init()
	Count = 0
	local current_dir = vim.fn.expand('%')
	local files = vim.fn.glob(current_dir .. '*', true, true)
	for i = 1, #files do
		local file = files[i]
		get_git_status(file)
	end
end

--- Set up the plugin
---@param opts table|dict: The options to set up the plugin. Being a table if you use Nvim, and a dictionary if you use Vim.
function M.setup(opts)
	local git_icons = {
		modified = '🖋️',
		staged = '✅',
		untracked = '❓',
		renamed = '🔄',
		unmerged = '❌',
		ignored = '🙈',
		file = '📄',
		directory = '📂',
	}
	if not isnvim then
		git_icons = vim.dict(git_icons)
	end
	local default_opts = {
		git_icons = git_icons,
	}
	if isnvim then
		M.config = vim.tbl_deep_extend('force', default_opts, opts or {})
	else
		M.config = vim.dict_deep_extend('force', vim.dict(default_opts), opts or vim.dict())
	end
	vim.fn['dirvish#add_icon_fn'](require('dirvish_git').add_icon)
end

return M
