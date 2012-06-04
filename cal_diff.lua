package.loaded.cal_diff = _ENV


--orgnl_array: array, code array with empty lines.
--return: array, delete empty lines, "text" and "line" fields included.
local function GetNoneEmptyArray(orgnl_array)
    local t = {}
    for i, v in ipairs(orgnl_array) do
        if not v:find"^ -$" then  --jump empty lines.
            local ti = #t + 1
            local store = {}
            store.text, store.line = v, i
            t[ti] = store
        end--if
    end--for

    return t
end--func


--code_text: string, original code text.
--return: array, separate codes to lines, including empty lines.
local function GetLineArrayWithText(code_text)
    local array = {}
    local begin, tend = 0, 0

    while true do
        begin, tend = code_text:find(".-[\n%z]", tend + 1)  --find line.
        if not begin then break end
        local t  = code_text:sub(begin, tend)
        array[#array+1] = t:gsub("[\n%z]", "")  --delete return and end.
    end--while

    return array
end--func


--file_name: stirng, text file name(path).
--return: array, delete empty lines, "text" and "line" fields included.
function GetNoneEmptyLineArrayWithFileName(file_name)
    local file = assert(io.open(file_name))
    local file_text = file:read"*all"
    local line_array = GetLineArrayWithText(file_text)
    local t = GetNoneEmptyArray(line_array)
    return t
end--func


--num_a: number, real number.
--num_b: the same.
--num_c: the same.
--return 1: number, max number.
--return 2: number, [123].
local function GetMaxNumber(num_a, num_b, num_c)
    if num_a >= num_b and num_a >= num_c then
        return num_a, 1
    elseif num_b >= num_c and num_b >= num_a then
        return num_b, 2
    else
        return num_c, 3
    end--if
end--func


--record_table: table, "dir" and "number" fields included.
--return: table, each element has four fields, "a_low", "a_high", "b_low", "b_high", table has an other field, "is_first_same".
local function GetSegmentsWithRecordTable(record_table)
    local segments = {}
    local line_n, column_n = #record_table, #record_table[0]
    
    local function Node()
        return record_table[line_n][column_n]
    end--func

    local function NewSegment()
        local t = {}
        t.a_high, t.b_high = line_n, column_n
        t.a_low, t.b_low = line_n, column_n
        segments[#segments+1] = t
    end--func

    local function OldSegment()
        local t = segments[#segments]
        t.a_low, t.b_low = line_n, column_n
    end--func

    local state = ""
    while Node().number ~= 0 do
        if Node().dir == "leftup" then
            if state == "same" then
                OldSegment()
            else
                NewSegment()
                local t = segments[#segments-1]
                if state == "diff" then
                    if line_n == t.a_low then
                        t.a_low = t.a_low + 1
                    elseif column_n == t.b_low then
                        t.b_low = t.b_low + 1
                    end--if
                end--if
                state = "same"
            end--if
            column_n, line_n = column_n - 1, line_n - 1
        else
            if state == "diff" then
                OldSegment()
            else
                NewSegment()
                state = "diff"
            end--if
            if Node().dir == "left" then
                column_n = column_n -1
            else
                line_n = line_n - 1
            end--if
        end--if
    end--while

    if line_n > 0 or column_n > 0 then
        local t = {}
        t.a_low, t.b_low = 1, 1
        t.a_high, t.b_high = line_n, column_n
        segments[#segments+1] = t
        segments.is_first_same = false
    else
        segments.is_first_same = true
    end--if

    local len = #segments
    for i = 1, len/2 do
        segments[i], segments[len+1-i] = segments[len+1-i], segments[i]
    end--for

    return segments
end--func


--code_lines_a: array, delete empty lines, "text" and "line" fields included.
--code_lines_b: the same.
--return: table, each element has four fields, "a_low", "a_high", "b_low", "b_high", table has an other field, "is_first_same".
function GetSegmentsOfTwoVersionCodes(code_lines_a, code_lines_b)
    local record = {}

    for i = 0, #code_lines_a do
        record[i] = {}
        for j = 0, #code_lines_b do
            record[i][j] = {}
            record[i][j].number = 0
        end--for
    end--for

    for ia, va in ipairs(code_lines_a) do
        for ib, vb in ipairs(code_lines_b) do
            local left_num = record[ia][ib-1].number
            local up_num = record[ia-1][ib].number
            local leftup_num = record[ia-1][ib-1].number

            if va.text == vb.text then leftup_num = leftup_num + 1 end--if

            local max, max_index = GetMaxNumber(left_num, up_num, leftup_num)
            record[ia][ib].number = max

            if max_index == 1 then
                record[ia][ib].dir = "left"
            elseif max_index == 2 then
                record[ia][ib].dir = "up"
            else
                record[ia][ib].dir = "leftup"
            end--if
        end--for
    end--for

    local segments = GetSegmentsWithRecordTable(record)
    return segments
end--func
