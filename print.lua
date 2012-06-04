package.loaded.print = _ENV


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
function ShowComparingResult(code_lines_a, code_lines_b, segments)
    for i, v in ipairs(segments) do
        local pla = table.pack(table.unpack(code_lines_a, v.a_low, v.a_high))
        local plb = table.pack(table.unpack(code_lines_b, v.b_low, v.b_high))
        local is_same = (i % 2 == 1) == segments.is_first_same
        ShowEachSegment(pla, plb, is_same)
        io.write("\n")
    end
end
