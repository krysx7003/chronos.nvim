local M = {}
M.timer_count = 0
M.uv_timer = nil
M.current_time = "00:00"
M.should_save = true

function M.setup()
	M.load_timer()
	M.start_timer()

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			M.stop_timer()
		end,
	})
end

function M.update_timer()
	local hours = M.timer_count / 60
	local minutes = M.timer_count % 60
	M.current_time = string.format("%02d:%02d", hours, minutes)
	M.timer_count = M.timer_count + 1
end

function M.get_timer_file()
	local nvim_dir = vim.fn.getcwd() .. "/.nvim"
	local timer_file = nvim_dir .. "/.nvim_timer_data.json"

	if vim.fn.isdirectory(nvim_dir) == 0 then
		vim.fn.system({ "mkdir", ".nvim" })
	end

	if vim.fn.filereadable(timer_file) == 0 then
		local data = { timer_count = 0 }
		vim.fn.writefile({ vim.json.encode(data) }, timer_file)
	end
	return timer_file
end

function M.save_timer()
	local timer_file = M.get_timer_file()
	local data = { timer_count = M.timer }
	if M.should_save then
		vim.fn.writefile({ vim.json.encode(data) }, timer_file)
	end
end

function M.load_timer()
	local timer_file = M.get_timer_file()
	if vim.fn.filereadable(timer_file) == 1 then
		local data = vim.json.decode(vim.fn.readfile(timer_file)[1])
		M.timer_count = data.timer_count or 0
	end
end

function M.start_timer()
	if not M.uv_timer then
		M.uv_timer = vim.uv.new_timer()
		M.uv_timer:start(
			0,
			60000,
			vim.schedule_wrap(function()
				M.update_timer()
				require("lualine").refresh()
			end)
		)
		vim.schedule(function()
			print(string.format("Timer started at: %s | Count: %d", os.date("%H:%M:%S"), M.timer_count))
			io.flush()
		end)
	end
end

function M.stop_timer()
	M.save_timer()
	if M.uv_timer and not M.uv_timer:is_closing() then
		M.uv_timer:stop()
		M.uv_timer:close()
		M.uv_timer = nil
	end

	vim.schedule(function()
		print(string.format("Timer stopped at: %s | Count: %d", os.date("%H:%M:%S"), M.timer_count))
		io.flush()
	end)
end

function M.no_save()
	M.should_save = false
end

return M
