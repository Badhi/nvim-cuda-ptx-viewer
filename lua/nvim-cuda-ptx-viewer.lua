
M = {}
function M.init()
end

local lineinfo = {}

function M.update()
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

function M.find_nearest()
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
