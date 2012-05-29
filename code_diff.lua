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
local function GetNoneEmptyLineArrayWithFileName(file_name)
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
local function GetSegmentsOfTwoVersionCodes(code_lines_a, code_lines_b)
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


local function GetNextGivenCountOfString(str, count)
    local index = 1
    local len = str:len()
    return function()
        if index > len then
            return string.rep(" ", count), true
        else
            local nindex = index + count
            local sub_str = str:sub(index, nindex - 1)
            sub_str = sub_str .. string.rep(" ", count - sub_str:len())
            index = nindex
            return sub_str, false
        end--if
    end--func
end--func


--part_lines_a: array, lines to show.
--part_lines_b: the same.
--is_same: is same or diffrent.
--return: void.
local function ShowEachSegment(part_lines_a, part_lines_b, is_same)
    local NUMBER_WIDTH = 4
    local TEXT_WIDTH = 60
    local INTERVAL_CHARACTER = ""
    if is_same then
        INTERVAL_CHARACTER = "-"
    else
        INTERVAL_CHARACTER = "+"
    end--if
    local interval_chrcts = string.rep(INTERVAL_CHARACTER, 4)

    for i = 1, math.huge do
        if i > #part_lines_a and i > #part_lines_b then
            break
        else
            local line_a = part_lines_a[i]
            local empty = {line = "", text = ""}
            line_a = line_a or empty
            local line_b = part_lines_b[i]
            line_b = line_b or empty
            local NumA = GetNextGivenCountOfString(tostring(line_a.line), NUMBER_WIDTH)
            local TextA = GetNextGivenCountOfString(line_a.text, TEXT_WIDTH)
            local NumB = GetNextGivenCountOfString(tostring(line_b.line), NUMBER_WIDTH)
            local TextB = GetNextGivenCountOfString(line_b.text, TEXT_WIDTH)
            while true do
                local num_a = NumA()
                local text_a_str, text_a_end = TextA()
                local num_b = NumB()
                local text_b_str, text_b_end = TextB()
                if text_a_end and text_b_end then
                    break
                end--if
                io.write(num_a, "| ", text_a_str, " | ", interval_chrcts, " | ", num_b, "| ", text_b_str, "\n")
            end--while
        end--if
    end--for
end--for


--code_lines_a: array, delete empty lines, "text" and "line" fields included.
--code_lines_b: the same.
--segments: table, each element has four fields, "a_low", "a_high", "b_low", "b_high", table has an other field, "is_first_same".
--return: void
--show comparing result on terminal.
local function ShowComparingResult(code_lines_a, code_lines_b, segments)
    for i, v in ipairs(segments) do
        local pla = table.pack(table.unpack(code_lines_a, v.a_low, v.a_high))
        local plb = table.pack(table.unpack(code_lines_b, v.b_low, v.b_high))
        local is_same = (i % 2 == 1) == segments.is_first_same
        ShowEachSegment(pla, plb, is_same)
        io.write("\n")
    end
end


--file_name_a: string.
--file_name_b: string.
--return: void.
local function ShowDifferenceOfTwoFiles(file_name_a, file_name_b)
    local lines_a = GetNoneEmptyLineArrayWithFileName(file_name_a)
    local lines_b = GetNoneEmptyLineArrayWithFileName(file_name_b)
    local segments = GetSegmentsOfTwoVersionCodes(lines_a, lines_b)
    ShowComparingResult(lines_a, lines_b, segments)
end--func


local function TerminalInterface()
    io.write("**************Code Diffrence**************\n", "Version 1.0\n", "Author: qswang, blog.csdn.net/wangqs1988\n")
    io.write("******************************************\n\n")
    while true do
        io.write("first file name:\n")
        local file_name_a = io.read("*line")
        io.write("second file name:\n")
        local file_name_b = io.read("*line")
        ShowDifferenceOfTwoFiles(file_name_a, file_name_b)
    end--while
end--func


TerminalInterface()
