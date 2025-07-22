local M = {}

M.timer = 0

function M.setup()
	M.load_timer()
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			M.save_timer()
		end,
	})
end

local function get_timer_file()
	local project_root = vim.fn.getcwd()
	local timer_file = project_root .. "/.nvim/.nvim_timer_data.json"
	if vim.fn.filereadable(timer_file) == 0 then
		local data = { timer_count = 0 }
		vim.fn.writefile({ vim.json.encode(data) }, timer_file)
	end
	return timer_file
end

function M.save_timer()
	local timer_file = get_timer_file()
	local data = { timer_count = M.timer }
	vim.fn.writefile({ vim.json.encode(data) }, timer_file)
end

function M.load_timer()
	local timer_file = get_timer_file()
	if vim.fn.filereadable(timer_file) == 1 then
		local data = vim.json.decode(vim.fn.readfile(timer_file)[1])
		M.timer = data.timer_count or 0
	end
	return M.timer
end

return M
