-- Data-driven parser tests generated from ../data/parser_vectors.md.
--
-- Run from the repository root:
--   busted --config-file=spec/busted.lua spec/

local context_lines = {}

-- Provide the small part of the Neovim API used by parser vectors.
-- Busted loads specs in its own environment, so publish the stub through _G.
local vim = _G.vim or {}
_G.vim = vim
vim.b = vim.b or {}
vim.bo = vim.bo or setmetatable({}, {
    __index = function()
        return {}
    end,
})

vim.islist = vim.islist or function(value)
    if type(value) ~= "table" then
        return false
    end

    local count = 0

    for key in pairs(value) do
        if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
            return false
        end

        count = count + 1
    end

    return count == #value
end

vim.list_contains = vim.list_contains or function(list, value)
    for i = 1, #list do
        if list[i] == value then
            return true
        end
    end

    return false
end

vim.api = vim.api or {}

vim.api.nvim_list_bufs = function()
    if #context_lines == 0 then
        return {}
    end

    return { 1 }
end

vim.api.nvim_buf_is_valid = function()
    return true
end

vim.api.nvim_buf_is_loaded = function()
    return true
end

vim.api.nvim_buf_get_lines = function()
    local lines = {}

    for i = 1, #context_lines do
        lines[i] = context_lines[i]
    end

    return lines
end

local function set_context(text)
    context_lines = {}

    if text == "" then
        return
    end

    for line in (text .. "\n"):gmatch("([^\n]*)\n") do
        context_lines[#context_lines + 1] = line
    end
end

-- Busted may run under a Lua build without luabitop. Converters only need a
-- few integer operations on positive numbers, so provide a small fallback.
if not _G.bit then
    local function band(a, b)
        local result = 0
        local power = 1

        while a > 0 and b > 0 do
            if a % 2 == 1 and b % 2 == 1 then
                result = result + power
            end

            a = math.floor(a / 2)
            b = math.floor(b / 2)
            power = power * 2
        end

        return result
    end

    local function bor(a, b)
        local result = 0
        local power = 1

        while a > 0 or b > 0 do
            if a % 2 == 1 or b % 2 == 1 then
                result = result + power
            end

            a = math.floor(a / 2)
            b = math.floor(b / 2)
            power = power * 2
        end

        return result
    end

    _G.bit = {
        band = band,
        bor = bor,
        rshift = function(a, n)
            return math.floor(a / 2 ^ n)
        end,
        lshift = function(a, n)
            return a * 2 ^ n
        end,
        tohex = function(value, digits)
            if digits < 0 then
                return string.format("%0" .. -digits .. "X", value)
            end

            return string.format("%0" .. digits .. "X", value)
        end,
    }
end

package.preload["bit"] = function()
    return _G.bit
end

local config = require("witch-colors.config")

local PARSER_ORDER = {
    "hex",
    "short_hex",
    "rgb",
    "hsl",
    "hsl_bare",
    "css_named",
    "sgr",
    "tailwind",
    "var_usage",
}

local PARSERS = {
    hex = config.current.parsers.hex,
    short_hex = config.current.parsers.short_hex,
    rgb = require("witch-colors.parsers.rgb"),
    hsl = require("witch-colors.parsers.hsl"),
    hsl_bare = require("witch-colors.parsers.hsl-bare"),
    css_named = require("witch-colors.parsers.css-named"),
    sgr = require("witch-colors.parsers.sgr"),
    tailwind = require("witch-colors.parsers.tailwind"),
    var_usage = require("witch-colors.parsers.var-usage"),
}

local ESC = string.char(27)

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function split_fields(line)
    local fields = {}
    local buffer = {}
    local escaped = false

    for i = 1, #line do
        local char = line:sub(i, i)

        if escaped then
            buffer[#buffer + 1] = char
            escaped = false
        elseif char == "\\" then
            buffer[#buffer + 1] = char
            escaped = true
        elseif char == "|" then
            fields[#fields + 1] = trim(table.concat(buffer))
            buffer = {}
        else
            buffer[#buffer + 1] = char
        end
    end

    if escaped then
        error("trailing escape in vector: " .. line)
    end

    fields[#fields + 1] = trim(table.concat(buffer))

    return fields
end

local function utf8_char(code)
    if code < 0x80 then
        return string.char(code)
    end

    if code < 0x800 then
        return string.char(
            0xC0 + math.floor(code / 0x40),
            0x80 + code % 0x40
        )
    end

    if code < 0x10000 then
        return string.char(
            0xE0 + math.floor(code / 0x1000),
            0x80 + math.floor(code / 0x40) % 0x40,
            0x80 + code % 0x40
        )
    end

    return string.char(
        0xF0 + math.floor(code / 0x40000),
        0x80 + math.floor(code / 0x1000) % 0x40,
        0x80 + math.floor(code / 0x40) % 0x40,
        0x80 + code % 0x40
    )
end

local SIMPLE_ESCAPES = {
    n = "\n",
    r = "\r",
    t = "\t",
    e = ESC,
    ["\\"] = "\\",
    ["|"] = "|",
}

local function decode(text)
    local output = {}
    local index = 1

    while index <= #text do
        local char = text:sub(index, index)

        if char ~= "\\" then
            output[#output + 1] = char
            index = index + 1
        else
            local next_char = text:sub(index + 1, index + 1)

            if next_char == "x" and text:sub(index + 2, index + 2) == "{" then
                local close = text:find("}", index + 3, true)
                assert(close, "unterminated hex escape in: " .. text)
                local code = tonumber(text:sub(index + 3, close - 1), 16)
                assert(code, "bad hex escape in: " .. text)
                output[#output + 1] = utf8_char(code)
                index = close + 1
            elseif next_char == "x" then
                local hex = text:sub(index + 2, index + 3)
                assert(#hex == 2, "bad hex escape in: " .. text)
                local code = tonumber(hex, 16)
                assert(code, "bad hex escape in: " .. text)
                output[#output + 1] = string.char(code)
                index = index + 4
            elseif next_char == "u" and text:sub(index + 2, index + 2) == "{" then
                local close = text:find("}", index + 3, true)
                assert(close, "unterminated unicode escape in: " .. text)
                local code = tonumber(text:sub(index + 3, close - 1), 16)
                assert(code, "bad unicode escape in: " .. text)
                output[#output + 1] = utf8_char(code)
                index = close + 1
            elseif next_char == "u" then
                local hex = text:sub(index + 2, index + 5)
                assert(#hex == 4, "bad unicode escape in: " .. text)
                local code = tonumber(hex, 16)
                assert(code, "bad unicode escape in: " .. text)
                output[#output + 1] = utf8_char(code)
                index = index + 6
            elseif SIMPLE_ESCAPES[next_char] then
                output[#output + 1] = SIMPLE_ESCAPES[next_char]
                index = index + 2
            else
                error("unknown escape \\" .. next_char .. " in: " .. text)
            end
        end
    end

    return table.concat(output)
end

local function parse_color_token(text)
    if text == "-" then
        return nil
    end

    if text == "NONE" then
        return "NONE"
    end

    if text:sub(1, 1) == "#" then
        return text
    end

    local digits = text:match("^0[xX](%x+)$")
    assert(digits, "bad color value in vector file: " .. text)

    return tonumber(digits, 16)
end

local ALLOWED_EXPECT_KEYS = {
    color = true,
    fg = true,
    bg = true,
    sp = true,
}

local function parse_expect(text)
    if text == "-" then
        return {}
    end

    -- Single-color parsers use a bare value; SGR keeps its fg/bg/sp labels.
    if not text:find("=", 1, true) then
        return { color = parse_color_token(text) }
    end

    local expect = {}

    for raw_key, raw_value in text:gmatch("([%a]+)%s*=%s*([^,]+)") do
        local key = trim(raw_key)
        local value = trim(raw_value)

        assert(ALLOWED_EXPECT_KEYS[key], "unknown expectation key: " .. key)
        expect[key] = parse_color_token(value)
    end

    assert(next(expect), "empty expectation in vector file: " .. text)

    return expect
end

local function parse_offset(text)
    if text == "-" then
        return nil
    end

    local value = tonumber(text)
    assert(value and value % 1 == 0, "bad offset in vector file: " .. text)

    return value
end

local function open_vectors()
    local source = debug.getinfo(1, "S").source
    local directory = ""

    if source:sub(1, 1) == "@" then
        source = source:sub(2)
        directory = source:match("^(.*[/\\])") or ""
    end

    local candidates = {
        "spec/data/parser_vectors.md",
        directory .. "../data/parser_vectors.md",
        "data/parser_vectors.md",
        "spec/data/parser_vectors.txt",
        directory .. "../data/parser_vectors.txt",
        "data/parser_vectors.txt",
    }

    for _, candidate in ipairs(candidates) do
        local file = io.open(candidate, "r")

        if file then
            local all_lines = {}
            local selected = {}
            local in_block = false
            local found_block = false

            for line in file:lines() do
                all_lines[#all_lines + 1] = line

                if line:find("<!-- VECTORS BEGIN -->", 1, true) then
                    in_block = true
                    found_block = true
                elseif line:find("<!-- VECTORS END -->", 1, true) then
                    break
                elseif in_block then
                    selected[#selected + 1] = line
                end
            end

            file:close()

            -- A plain testing.txt is still accepted as a compatibility path.
            if not found_block then
                selected = all_lines
            end

            return selected, candidate
        end
    end

    error("cannot open parser_vectors.md from " .. table.concat(candidates, ", "))
end

local function collect_matches(str, patterns)
    local matches = {}
    local count = 0
    local str_len = #str

    if str_len == 0 or not patterns then
        return matches, count
    end

    for i = 1, #patterns do
        local pattern = patterns[i]
        local init = 1

        while init <= str_len + 1 do
            local first, last = str:find(pattern, init)

            if not first then
                break
            end

            if last >= first then
                count = count + 1
                matches[count] = {
                    col_start = first - 1,
                    col_end = last,
                    value = str:sub(first, last),
                    pattern = pattern,
                }
                init = last + 1
            else
                init = first + 1
            end
        end
    end

    return matches, count
end

local function resolve_decorations(parser, input, row)
    local matches = collect_matches(input, parser.patterns)
    local decorations = {}

    for i = 1, #matches do
        local match = matches[i]
        local decoration

        if parser.resolve then
            decoration = parser.resolve(match, row)
        else
            decoration = {
                color = match.value,
                col_start = match.col_start,
                col_end = match.col_end,
            }
        end

        if decoration then
            decorations[#decorations + 1] = decoration
        end
    end

    return decorations
end

local function assert_color(expected, actual, label)
    assert.are.same(expected, actual, label)
end

local function assert_decoration(result, expect, start, finish, label)
    if expect.color ~= nil then
        assert_color(expect.color, result.color, label .. ": color")
        assert.is_nil(result.fg, label .. ": unexpected fg")
        assert.is_nil(result.bg, label .. ": unexpected bg")
        assert.is_nil(result.sp, label .. ": unexpected sp")
    else
        assert.is_nil(result.color, label .. ": unexpected color")
        assert_color(expect.fg, result.fg, label .. ": fg")
        assert_color(expect.bg, result.bg, label .. ": bg")
        assert_color(expect.sp, result.sp, label .. ": sp")
    end

    assert.are.same(start, result.col_start, label .. ": col_start")
    assert.are.same(finish, result.col_end, label .. ": col_end")
end

local vector_lines, path = open_vectors()
local group = "Parser vectors"
local seen = {}
local used = {}
local case_count = 0
local line_number = 0

for _, line in ipairs(vector_lines) do
    line_number = line_number + 1
    local text = trim(line)

    if text:sub(1, 3) == "```" then
        -- Markdown fence around the embedded vector block.
    elseif text ~= "" and text:sub(1, 1) == "#" then
        local heading = text:match("^##%s+(.+)$")

        if heading then
            group = trim(heading)
        end
    elseif text ~= "" then
        local location = path .. ":" .. line_number
        local fields = split_fields(text)
        assert.are.equal(8, #fields, "bad vector at " .. location .. ": " .. line)

        local parser_id = fields[1]
        local parser = PARSERS[parser_id]
        assert.is_truthy(parser, "unknown parser at " .. location .. ": " .. parser_id)

        local name = fields[2]
        local input = decode(fields[3])
        local context = fields[4] == "-" and "" or decode(fields[4])
        local expect = parse_expect(fields[5])
        local start = parse_offset(fields[6])
        local finish = parse_offset(fields[7])
        local note = fields[8] == "-" and "" or decode(fields[8])
        local key = parser_id .. "/" .. name

        assert.is_nil(seen[key], "duplicate vector at " .. location .. ": " .. key)
        seen[key] = true
        used[parser_id] = true
        case_count = case_count + 1

        if next(expect) then
            assert.is_truthy(start ~= nil, "missing start at " .. location)
            assert.is_truthy(finish ~= nil, "missing end at " .. location)
        else
            assert.is_nil(start, "unexpected start at " .. location)
            assert.is_nil(finish, "unexpected end at " .. location)
        end

        it(group .. ": " .. name, function()
            local label = key .. (note == "" and "" or " (" .. note .. ")")

            set_context(context)
            local decorations = resolve_decorations(parser, input, 0)

            if not next(expect) then
                assert.are.equal(0, #decorations, label .. ": expected no decoration")
                return
            end

            assert.are.equal(1, #decorations, label .. ": expected exactly one decoration")
            assert_decoration(decorations[1], expect, start, finish, label)
        end)
    end
end

it("vector file contains cases for every parser", function()
    assert.is_true(case_count > 0, "no vectors found in " .. path)

    for _, parser_id in ipairs(PARSER_ORDER) do
        assert.is_true(used[parser_id], "no vectors for parser: " .. parser_id)
    end
end)

for _, parser_id in ipairs(PARSER_ORDER) do
    it(parser_id .. " exposes patterns", function()
        local parser = PARSERS[parser_id]
        assert.is_true(type(parser.patterns) == "table", parser_id .. ": patterns must be a table")
        assert.is_true(#parser.patterns > 0, parser_id .. ": patterns must not be empty")
    end)
end
