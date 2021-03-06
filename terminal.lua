#!/usr/bin/lua
package.loaded.terminal = _ENV

local cd = require"cal_diff"
local prt = require"print"

local cd_GtNnEmptLnArrWthFNm = cd.GetNoneEmptyLineArrayWithFileName
local cd_GtSgmntsOfTwVrsnCds = cd.GetSegmentsOfTwoVersionCodes
local prt_ShCmprRst = prt.ShowComparingResult
local io_wrt = io.write
local io_rd = io.read


--file_name_a: string.
--file_name_b: string.
--return: void.
local function ShowDifferenceOfTwoFiles(file_name_a, file_name_b)
    local lines_a = cd_GtNnEmptLnArrWthFNm(file_name_a)
    local lines_b = cd_GtNnEmptLnArrWthFNm(file_name_b)
    local segments = cd_GtSgmntsOfTwVrsnCds(lines_a, lines_b)
    prt_ShCmprRst(lines_a, lines_b, segments)
end--func


local function TerminalInterface()
        local file_name_a = arg[1]
        local file_name_b = arg[2]
        ShowDifferenceOfTwoFiles(file_name_a, file_name_b)
end--func


TerminalInterface()
