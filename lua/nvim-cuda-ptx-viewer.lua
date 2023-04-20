
M = {}
function M.init()
end

local lineinfo = {}
local asm_buffer
local asm_file_name
local asm_window
local ptx_buffer
local ptx_window
local augroup = vim.api.nvim_create_augroup("CudaPTX", {})

local function create_ptx_buffer()
    ptx_buffer = vim.api.nvim_create_buf(false, false)
    vim.cmd "vsplit"
    vim.cmd(string.format("buffer %d", ptx_buffer))
    vim.cmd(string.format("e %s.ptx", asm_file_name))
    ptx_window = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(asm_window)
end

local function update_cursor()
    local cur_pos = M.find_nearest_line_number()
    if not cur_pos or not ptx_window then
        return
    end
    vim.api.nvim_win_set_cursor(ptx_window, { cur_pos, 1})
end

local function create_callbacks()
    vim.api.nvim_clear_autocmds { group = augroup, buffer = asm_buffer}
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        buffer = asm_buffer,
        callback = function()
            update_cursor()
        end,
        desc = "CudaPTX : update ptx cursor"
    })
end

function M.update()
    asm_buffer = vim.api.nvim_get_current_buf()
    asm_file_name = vim.fn.expand('%:r')
    asm_window = vim.api.nvim_get_current_win()
    lineinfo = {}
    local start = 0
    vim.fn.cursor(1, 1)
    while true do
        local l = vim.fn.search('## File', 'w')
        if l == start then
            break
        end

        if start == 0 then
            start = l
        end

        table.insert(lineinfo, l)
    end
    --print(vim.inspect(lineinfo))
    create_callbacks()
    create_ptx_buffer()
end

local function get_range(start_pos, end_pos, row)
    if math.abs(start_pos - end_pos) <= 1 then
        return start_pos
    end

    local mid_pos = math.floor((start_pos + end_pos)/2)
    local mid_val = lineinfo[mid_pos]
    --print('row : ' .. row .. ', start : ' .. start_pos .. ', end : ' .. end_pos .. ', mid : ' .. mid_pos .. ', mid val : ' .. mid_val )
    if not mid_val then
        return start_pos
    end

    if mid_val > row then
        return get_range(start_pos, mid_pos, row)
    end
    return get_range(mid_pos, end_pos, row)
end

function M.find_nearest_line_number()
    local cursor_pos = vim.fn.getcurpos()
    local row = cursor_pos[2]
    local lineinfo_size = #lineinfo
    local pos = get_range(0, lineinfo_size, row)
    --print(pos .. ', ' .. lineinfo[pos])
    local str = vim.fn.getline(lineinfo[pos])
    --print(string.sub('//## File ".nv_debug_ptx_txt", line 87609', 37 , 40))
    return tonumber(string.sub(str, 37 , string.len(str)))
end

return M
