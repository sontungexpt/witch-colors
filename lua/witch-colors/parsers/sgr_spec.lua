-- Standalone regression suite for the unified SGR parser.
--
-- Usage:
--   texlua /mnt/data/test_sgr.lua /mnt/data/sgr.lua
--
-- No external test framework or production-code modifications are required.

local parser_path = arg and arg[1] or "sgr.lua"
local chunk, load_error = loadfile(parser_path)
assert(chunk, "cannot load parser: " .. tostring(load_error))

local ok, parser = pcall(chunk)
assert(ok, "parser initialization failed: " .. tostring(parser))
assert(type(parser) == "table", "parser module must return a table")

local passed = 0
local failed = 0
local total = 0
local failures = {}

local function test(name, callback)
    total = total + 1
    local success, err = pcall(callback)
    if success then
        passed = passed + 1
    else
        failed = failed + 1
        failures[#failures + 1] = { name = name, error = tostring(err) }
        io.stderr:write("FAIL: ", name, "\n      ", tostring(err), "\n")
    end
end

local function eq(actual, expected, label)
    if actual ~= expected then
        error((label or "value") .. ": expected " .. tostring(expected)
            .. ", got " .. tostring(actual), 2)
    end
end

local function truthy(value, label)
    if not value then
        error((label or "value") .. ": expected truthy value", 2)
    end
end

local function falsy(value, label)
    if value then
        error((label or "value") .. ": expected falsy value", 2)
    end
end

local function count_keys(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

-- Emulate the host's pattern matching contract. The parser's resolve() gets
-- the matched byte slice and the exact Lua pattern that found it.
local function find_and_resolve(subject, row)
    local found

    for _, pattern in ipairs(parser.patterns) do
        local first, last = string.find(subject, pattern)
        if first then
            if found then
                error("multiple SGR patterns matched the same subject")
            end
            found = {
                value = string.sub(subject, first, last),
                pattern = pattern,
                col_start = first - 1,
                col_end = last,
            }
        end
    end

    if not found then
        return nil, nil
    end

    return parser.resolve(found, row or 0), found
end

local ESC = string.char(0x1B)
local DEFAULT_INTRODUCER = ESC .. "["

local function sequence(params, introducer)
    return (introducer or DEFAULT_INTRODUCER) .. params .. "m"
end

local function parse(params, introducer, prefix, suffix, row)
    local subject = (prefix or "") .. sequence(params, introducer) .. (suffix or "")
    return find_and_resolve(subject, row)
end

local function expect(params, fg, bg, sp, opts)
    opts = opts or {}
    local result, match = parse(params, opts.introducer, opts.prefix, opts.suffix, opts.row)

    if fg == nil and bg == nil and sp == nil then
        eq(result, nil, "result for SGR " .. tostring(params))
        return
    end

    truthy(result, "result for SGR " .. tostring(params))
    eq(result.fg, fg, "fg for SGR " .. tostring(params))
    eq(result.bg, bg, "bg for SGR " .. tostring(params))
    eq(result.sp, sp, "sp for SGR " .. tostring(params))

    if match then
        eq(result.col_start, match.col_start, "col_start")
        eq(result.col_end, match.col_end, "col_end")
    end

    for key in pairs(result) do
        if key ~= "fg" and key ~= "bg" and key ~= "sp"
            and key ~= "col_start" and key ~= "col_end" then
            error("unexpected result field: " .. tostring(key))
        end
    end
end

local function expect_result_nil(params, opts)
    local result = parse(params, opts and opts.introducer, opts and opts.prefix,
        opts and opts.suffix, opts and opts.row)
    eq(result, nil, "result for SGR " .. tostring(params))
end

-- ---------------------------------------------------------------------------
-- Public parser contract
-- ---------------------------------------------------------------------------

test("module returns a parser table", function()
    eq(type(parser), "table")
end)

test("parser exposes exactly patterns and resolve", function()
    eq(type(parser.patterns), "table")
    eq(type(parser.resolve), "function")
    eq(count_keys(parser), 2)
    truthy(parser.patterns ~= nil)
    truthy(parser.resolve ~= nil)
    falsy(parser.set_palette, "set_palette must not be exported")
    falsy(parser.parse, "parse must not be exported")
end)

test("parser has 24 configured introducers with raw C1 disabled", function()
    eq(#parser.patterns, 24)
end)

test("patterns are unique", function()
    local seen = {}
    for _, pattern in ipairs(parser.patterns) do
        falsy(seen[pattern], "duplicate pattern: " .. pattern)
        seen[pattern] = true
    end
end)

test("patterns are strings", function()
    for i, pattern in ipairs(parser.patterns) do
        eq(type(pattern), "string", "pattern " .. i)
    end
end)

test("unknown pattern is rejected by resolve", function()
    local value = ESC .. "[31m"
    local result = parser.resolve({
        value = value,
        pattern = "not-a-registered-pattern",
        col_start = 0,
        col_end = #value,
    }, 0)
    eq(result, nil)
end)

test("row argument is accepted and does not affect color resolution", function()
    local result = parse("31", nil, nil, nil, 123)
    truthy(result)
    eq(result.fg, 0xCD0000)
end)

-- ---------------------------------------------------------------------------
-- ANSI and aixterm colors
-- ---------------------------------------------------------------------------

local ansi = {
    0x000000, 0xCD0000, 0x00CD00, 0xCDCD00,
    0x0000EE, 0xCD00CD, 0x00CDCD, 0xE5E5E5,
    0x7F7F7F, 0xFF0000, 0x00FF00, 0xFFFF00,
    0x5C5CFF, 0xFF00FF, 0x00FFFF, 0xFFFFFF,
}

for i = 0, 7 do
    local index = i
    test("ANSI foreground " .. (30 + index), function()
        expect(tostring(30 + index), ansi[index + 1], nil, nil)
    end)
    test("ANSI background " .. (40 + index), function()
        expect(tostring(40 + index), nil, ansi[index + 1], nil)
    end)
end

for i = 0, 7 do
    local index = i
    test("aixterm bright foreground " .. (90 + index), function()
        expect(tostring(90 + index), ansi[index + 9], nil, nil)
    end)
    test("aixterm bright background " .. (100 + index), function()
        expect(tostring(100 + index), nil, ansi[index + 9], nil)
    end)
end

test("ANSI foreground and background coexist", function()
    expect("31;44", 0xCD0000, 0x0000EE, nil)
end)

test("last ANSI declaration wins per target", function()
    expect("31;32;44;45", 0x00CD00, 0xCD00CD, nil)
end)

-- ---------------------------------------------------------------------------
-- xterm 256-color palette
-- ---------------------------------------------------------------------------

local indexed_cases = {
    { 0, 0x000000 },
    { 1, 0xCD0000 },
    { 7, 0xE5E5E5 },
    { 8, 0x7F7F7F },
    { 15, 0xFFFFFF },
    { 16, 0x000000 },
    { 17, 0x00005F },
    { 21, 0x0000FF },
    { 46, 0x00FF00 },
    { 196, 0xFF0000 },
    { 202, 0xFF5F00 },
    { 231, 0xFFFFFF },
    { 232, 0x080808 },
    { 244, 0x808080 },
    { 255, 0xEEEEEE },
}

for _, item in ipairs(indexed_cases) do
    local index, expected = item[1], item[2]
    test("xterm indexed foreground " .. index, function()
        expect("38;5;" .. index, expected, nil, nil)
    end)
    test("xterm indexed background " .. index, function()
        expect("48;5;" .. index, nil, expected, nil)
    end)
end

test("colon indexed foreground", function()
    expect("38:5:196", 0xFF0000, nil, nil)
end)

test("colon indexed background", function()
    expect("48:5:21", nil, 0x0000FF, nil)
end)

test("mixed indexed foreground compatibility form", function()
    expect("38;5:196", 0xFF0000, nil, nil)
end)

test("mixed indexed background compatibility form", function()
    expect("48;5:21", nil, 0x0000FF, nil)
end)

-- ---------------------------------------------------------------------------
-- Truecolor forms and channel ordering
-- ---------------------------------------------------------------------------

test("semicolon RGB foreground", function()
    expect("38;2;255;128;64", 0xFF8040, nil, nil)
end)

test("semicolon RGB background", function()
    expect("48;2;255;128;64", nil, 0xFF8040, nil)
end)

test("colon RGB with empty CSID", function()
    expect("38:2::255:128:64", 0xFF8040, nil, nil)
end)

test("colon RGB with numeric CSID zero", function()
    expect("38:2:0:255:128:64", 0xFF8040, nil, nil)
end)

test("colon RGB with numeric CSID nonzero", function()
    expect("48:2:1:12:34:56", nil, 0x0C2238, nil)
end)

test("colon RGB accepts numeric CSID outside channel range", function()
    expect("38:2:9999:12:34:56", 0x0C2238, nil, nil)
end)

test("legacy colon RGB shorthand is enabled", function()
    expect("38:2:255:128:64", 0xFF8040, nil, nil)
end)

test("mixed separator RGB compatibility form", function()
    expect("38;2:0:255:128:64", 0xFF8040, nil, nil)
end)

test("RGB red channel boundary", function()
    expect("38;2;255;0;0", 0xFF0000, nil, nil)
end)

test("RGB green channel boundary", function()
    expect("38;2;0;255;0", 0x00FF00, nil, nil)
end)

test("RGB blue channel boundary", function()
    expect("38;2;0;0;255", 0x0000FF, nil, nil)
end)

test("RGB zero channels", function()
    expect("38;2;0;0;0", 0x000000, nil, nil)
end)

test("RGB maximum channels", function()
    expect("38;2;255;255;255", 0xFFFFFF, nil, nil)
end)

test("RGB arbitrary channel order is preserved", function()
    expect("38;2;1;2;3", 0x010203, nil, nil)
end)

test("colon RGB background", function()
    expect("48:2::1:2:3", nil, 0x010203, nil)
end)

test("mixed RGB syntax leaves following SGR attributes available", function()
    expect("38;2:0:255:128:64;44", 0xFF8040, 0x0000EE, nil)
end)

test("semicolon RGB leaves following SGR attributes available", function()
    expect("38;2;255;128;64;44", 0xFF8040, 0x0000EE, nil)
end)

-- ---------------------------------------------------------------------------
-- Underline color (SGR 58 / 59)
-- ---------------------------------------------------------------------------

test("semicolon indexed underline color", function()
    expect("58;5;196", nil, nil, 0xFF0000)
end)

test("colon indexed underline color", function()
    expect("58:5:21", nil, nil, 0x0000FF)
end)

test("semicolon RGB underline color", function()
    expect("58;2;1;2;3", nil, nil, 0x010203)
end)

test("colon RGB underline color", function()
    expect("58:2::1:2:3", nil, nil, 0x010203)
end)

test("underline and foreground/background coexist", function()
    expect("31;48;5;21;58;2;1;2;3", 0xCD0000, 0x0000FF, 0x010203)
end)

test("underline reset 59 preserves foreground and background", function()
    expect("31;44;58;5;196;59", 0xCD0000, 0x0000EE, nil)
end)

test("underline color declaration does not leak its fields", function()
    expect("58;5;196;44", nil, 0x0000EE, 0xFF0000)
end)

-- ---------------------------------------------------------------------------
-- Transparent / implementation-defined color modes
-- ---------------------------------------------------------------------------

test("transparent foreground maps to NONE", function()
    expect("38:1", "NONE", nil, nil)
end)

test("transparent background maps to NONE", function()
    expect("48:1", nil, "NONE", nil)
end)

test("transparent underline color maps to NONE", function()
    expect("58:1", nil, nil, "NONE")
end)

test("transparent foreground replaces prior explicit color", function()
    expect("31;38:1", "NONE", nil, nil)
end)

test("transparent mode can be followed by another SGR parameter", function()
    expect("38:1;44", "NONE", 0x0000EE, nil)
end)

test("foreground reset clears transparent foreground", function()
    expect("38:1;39", nil, nil, nil)
end)

test("implementation-defined foreground mode is ignored", function()
    expect_result_nil("38:0")
end)

test("implementation-defined mode preserves earlier foreground", function()
    expect("31;38:0;44", 0xCD0000, 0x0000EE, nil)
end)

test("transparent mode with extra fields is rejected", function()
    expect_result_nil("38:1:2")
end)

-- ---------------------------------------------------------------------------
-- SGR resets and empty parameters
-- ---------------------------------------------------------------------------

test("full reset clears all three color targets", function()
    expect("31;44;58;5;196;0", nil, nil, nil)
end)

test("foreground reset 39", function()
    expect("31;39;44", nil, 0x0000EE, nil)
end)

test("background reset 49", function()
    expect("31;44;49", 0xCD0000, nil, nil)
end)

test("underline reset 59", function()
    expect("58;5;196;59", nil, nil, nil)
end)

test("empty parameter at start behaves as reset", function()
    expect(";31", 0xCD0000, nil, nil)
end)

test("empty parameter between values behaves as reset", function()
    expect("31;;44", nil, 0x0000EE, nil)
end)

test("trailing empty parameter resets every target", function()
    expect("31;44;58;5;196;", nil, nil, nil)
end)

test("empty SGR parameter list has no color result", function()
    expect_result_nil("")
end)

test("multiple resets are harmless", function()
    expect("0;0;39;49;59", nil, nil, nil)
end)

-- ---------------------------------------------------------------------------
-- Attribute ignoring and ordering
-- ---------------------------------------------------------------------------

test("common SGR attributes are ignored", function()
    expect("1;2;3;4;5;7;8;9;31", 0xCD0000, nil, nil)
end)

test("reverse video is not applied by this color-only parser", function()
    expect("31;44;7", 0xCD0000, 0x0000EE, nil)
end)

test("colon subparameters of unrelated attributes are ignored", function()
    expect("4:3;31;44", 0xCD0000, 0x0000EE, nil)
end)

test("last valid foreground wins", function()
    expect("31;38;5;196;32", 0x00CD00, nil, nil)
end)

test("last valid background wins", function()
    expect("44;48:5:21;45", nil, 0xCD00CD, nil)
end)

test("foreground and background declarations are independent", function()
    expect("31;48;2;1;2;3;38:5:21", 0x0000FF, 0x010203, nil)
end)

test("invalid later foreground does not replace valid foreground", function()
    expect("31;38;5;256", 0xCD0000, nil, nil)
end)

test("invalid later background does not replace valid background", function()
    expect("44;48:5:256", nil, 0x0000EE, nil)
end)

-- ---------------------------------------------------------------------------
-- Optional ISO RGB fields (PE6 / PE7 / PE8)
-- ---------------------------------------------------------------------------

test("RGB with PE6", function()
    expect("38:2::255:128:64:0", 0xFF8040, nil, nil)
end)

test("RGB with PE6 and PE7", function()
    expect("38:2::255:128:64:0:100", 0xFF8040, nil, nil)
end)

test("RGB with PE6, PE7 and CIELUV PE8", function()
    expect("38:2::255:128:64:0:100:0", 0xFF8040, nil, nil)
end)

test("RGB with PE6, PE7 and CIELAB PE8", function()
    expect("38:2::255:128:64:0:100:1", 0xFF8040, nil, nil)
end)

test("RGB with omitted PE6 and PE7 but PE8 present as empty", function()
    expect("38:2::255:128:64:::", 0xFF8040, nil, nil)
end)

test("RGB with invalid PE8 value is rejected", function()
    expect_result_nil("38:2::255:128:64:0:100:2")
end)

test("RGB with empty PE8 is accepted", function()
    expect("38:2::255:128:64:0:100:", 0xFF8040, nil, nil)
end)

test("RGB with extra unsupported PE is rejected", function()
    expect_result_nil("38:2::255:128:64:0:100:1:2")
end)

test("RGB PE fields are consumed before following SGR parameters", function()
    expect("38:2::255:128:64:0:100:1;44", 0xFF8040, 0x0000EE, nil)
end)

-- ---------------------------------------------------------------------------
-- Invalid and out-of-range values
-- ---------------------------------------------------------------------------

local invalid_cases = {
    { "38;5;256", "indexed value above 255" },
    { "38:5:256", "colon indexed value above 255" },
    { "38;2;256;0;0", "red above 255" },
    { "38;2;0;256;0", "green above 255" },
    { "38;2;0;0;256", "blue above 255" },
    { "38:2::256:0:0", "colon red above 255" },
    { "38:2::0:256:0", "colon green above 255" },
    { "38:2::0:0:256", "colon blue above 255" },
    { "38:2::", "missing RGB channels" },
    { "38:2::255:128", "missing blue channel" },
    { "38:2::255::64", "empty green channel" },
    { "38:5:", "empty indexed value" },
    { "38;5;", "empty semicolon indexed value" },
    { "38;2;255;128", "missing semicolon blue channel" },
    { "38:5:1:2", "extra indexed field" },
    { "38:2::1:2:3:0:0:1:2", "extra RGB field" },
}

for _, item in ipairs(invalid_cases) do
    local params, label = item[1], item[2]
    test("invalid input: " .. label, function()
        expect_result_nil(params)
    end)
end

test("invalid color declaration preserves earlier foreground", function()
    expect("31;38:2::256:0:0", 0xCD0000, nil, nil)
end)

test("invalid color declaration preserves earlier underline color", function()
    expect("58;5;21;58;5;256", nil, nil, 0x0000FF)
end)

test("malformed parameter syntax does not match source pattern", function()
    local result = find_and_resolve(ESC .. "[38;2;1;x;3m")
    eq(result, nil)
end)

test("invalid non-ASCII numeric syntax does not match source pattern", function()
    local result = find_and_resolve(ESC .. "[٣١m")
    eq(result, nil)
end)

-- ---------------------------------------------------------------------------
-- Unsupported ISO modes are consumed but not converted by default
-- ---------------------------------------------------------------------------

test("CMY mode is ignored but does not swallow following SGR", function()
    expect("31;38:3::0:255:255;44", 0xCD0000, 0x0000EE, nil)
end)

test("CMYK mode is ignored but does not swallow following SGR", function()
    expect("31;38:4::0:255:255:0;44", 0xCD0000, 0x0000EE, nil)
end)

test("unknown colon color mode is consumed without creating RGB", function()
    expect("31;38:9:1:2:3;44", 0xCD0000, 0x0000EE, nil)
end)

-- ---------------------------------------------------------------------------
-- Introducer coverage
-- ---------------------------------------------------------------------------

local introducers = {
    { "ESC [", ESC .. "[" },
    { "UTF-8 C1 CSI", string.char(0xC2, 0x9B) },
    { "literal \\033[", "\\033[" },
    { "literal \\027[", "\\027[" },
    { "literal \\27[", "\\27[" },
    { "literal \\x1b[", "\\x1b[" },
    { "literal \\x1B[", "\\x1B[" },
    { "literal \\e[", "\\e[" },
    { "literal \\E[", "\\E[" },
    { "literal \\u001b[", "\\u001b[" },
    { "literal \\u001B[", "\\u001B[" },
    { "literal \\u{1b}[", "\\u{1b}[" },
    { "literal \\u{1B}[", "\\u{1B}[" },
    { "literal \\x{1b}[", "\\x{1b}[" },
    { "literal \\x{1B}[", "\\x{1B}[" },
    { "literal ^[[", "^[[" },
    { "literal \\x9b", "\\x9b" },
    { "literal \\x9B", "\\x9B" },
    { "literal \\u009b", "\\u009b" },
    { "literal \\u009B", "\\u009B" },
    { "literal \\u{9b}", "\\u{9b}" },
    { "literal \\u{9B}", "\\u{9B}" },
    { "literal \\x{9b}", "\\x{9b}" },
    { "literal \\x{9B}", "\\x{9B}" },
}

for _, item in ipairs(introducers) do
    local label, introducer = item[1], item[2]
    test("introducer matches and resolves: " .. label, function()
        local result, match = parse("31", introducer)
        truthy(match, "pattern match")
        truthy(result, "resolved decoration")
        eq(result.fg, 0xCD0000)
        eq(result.col_start, 0)
        eq(result.col_end, #introducer + #"31m")
    end)
end

test("raw C1 byte is not recognized by default", function()
    local raw_c1 = string.char(0x9B) .. "31m"
    local result, match = find_and_resolve(raw_c1)
    eq(match, nil)
    eq(result, nil)
end)

test("introducer patterns reject unsupported trailing characters", function()
    local result, match = find_and_resolve(ESC .. "[31xm")
    eq(match, nil)
    eq(result, nil)
end)

-- ---------------------------------------------------------------------------
-- Match offsets and result shape
-- ---------------------------------------------------------------------------

test("match byte offsets are preserved with ASCII prefix and suffix", function()
    local result, match = parse("31", nil, "abc", "xyz")
    truthy(result)
    eq(result.col_start, 3)
    eq(result.col_end, 3 + #sequence("31"))
    eq(result.col_start, match.col_start)
    eq(result.col_end, match.col_end)
end)

test("match byte offsets are preserved with multibyte UTF-8 prefix", function()
    local result = parse("31", nil, "é", "")
    truthy(result)
    eq(result.col_start, 2)
    eq(result.col_end, 2 + #sequence("31"))
end)

test("result contains only decoration contract fields", function()
    local result = parse("31;44;58;5;21")
    local allowed = {
        col_start = true,
        col_end = true,
        fg = true,
        bg = true,
        sp = true,
    }
    truthy(result)
    for key in pairs(result) do
        truthy(allowed[key], "unexpected output key " .. tostring(key))
    end
    eq(count_keys(result), 5)
end)

test("result leaves absent decoration fields nil", function()
    local result = parse("31")
    truthy(result)
    eq(result.bg, nil)
    eq(result.sp, nil)
end)

test("no color or reset-only sequence returns nil", function()
    expect_result_nil("0")
    expect_result_nil("39")
    expect_result_nil("49")
    expect_result_nil("59")
    expect_result_nil("1;2;3;4")
end)

-- ---------------------------------------------------------------------------
-- Summary
-- ---------------------------------------------------------------------------

io.write(string.format("\nSGR parser tests: %d total, %d passed, %d failed\n",
    total, passed, failed))

if failed > 0 then
    io.stderr:write("\nFailures:\n")
    for i, failure in ipairs(failures) do
        io.stderr:write(string.format("%d. %s\n   %s\n", i, failure.name, failure.error))
    end
    os.exit(1)
end

os.exit(0)
