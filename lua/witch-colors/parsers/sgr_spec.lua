-- Tests for the unified SGR parser (`witch-colors.parsers.sgr`).
--
-- These tests intentionally use explicit RGB literals instead of the parser's
-- private conversion helpers. All expectations are based on the documented
-- parser contract and the fixed default xterm palette used by the parser.

local sgr = require("witch-colors.parsers.sgr")
local assert = require("luassert")

local ESC = "\27"
local CSI_8 = string.char(0x9B)

-- Arbitrary match columns used by the helper. Every successful resolution
-- must preserve these values exactly.
local MATCH_START = 11
local MATCH_END = 37

--- Build a normal 7-bit SGR sequence from its parameter string.
--- @param parameters string
--- @return string
local function sequence(parameters)
	return ESC .. "[" .. parameters .. "m"
end

--- Format a packed RGB value for readable assertion messages.
--- @param value integer|nil
--- @return string
local function format_rgb(value)
	if value == nil then
		return "nil"
	end

	return string.format("#%06X", value)
end

--- Resolve a complete SGR sequence with fixed match columns.
--- @param value string
--- @return table|nil
local function resolve(value)
	return sgr.resolve({
		value = value,
		col_start = MATCH_START,
		col_end = MATCH_END,
	})
end

--- Assert that a complete SGR sequence resolves to the expected colors.
--- @param value string
--- @param expected_fg integer|nil
--- @param expected_bg integer|nil
--- @return table
local function assert_color(value, expected_fg, expected_bg)
	local result = resolve(value)

	assert.is_not_nil(result, ("expected %q to resolve to a color"):format(value))
	assert.are.same(
		MATCH_START,
		result.col_start,
		("%q changed col_start"):format(value)
	)
	assert.are.same(MATCH_END, result.col_end, ("%q changed col_end"):format(value))
	assert.are.same(
		expected_fg,
		result.fg,
		("%q foreground: expected %s, got %s"):format(
			value,
			format_rgb(expected_fg),
			format_rgb(result.fg)
		)
	)
	assert.are.same(
		expected_bg,
		result.bg,
		("%q background: expected %s, got %s"):format(
			value,
			format_rgb(expected_bg),
			format_rgb(result.bg)
		)
	)

	return result
end

--- Assert that a complete SGR sequence resolves to no color at all.
--- @param value string
local function assert_rejected(value)
	local result = resolve(value)

	assert.is_nil(
		result,
		("expected %q to be rejected, got fg=%s bg=%s"):format(
			value,
			format_rgb(result and result.fg),
			format_rgb(result and result.bg)
		)
	)
end

--- Assert that at least one parser pattern matches the entire input.
--- @param value string
--- @return boolean
local function matches_any_pattern(value)
	for _, pattern in ipairs(sgr.patterns) do
		local first, last = value:find(pattern)

		if first == 1 and last == #value then
			return true
		end
	end

	return false
end

-- ============================================================================
-- ANSI colors
-- ============================================================================

describe("SGR parser: ANSI colors", function()
	-- The parser uses the default xterm 16-color palette. Values are explicit
	-- here so a palette regression is visible without involving parser helpers.
	local normal = {
		{ name = "black", fg = 30, bg = 40, rgb = 0x000000 },
		{ name = "red", fg = 31, bg = 41, rgb = 0xCD0000 },
		{ name = "green", fg = 32, bg = 42, rgb = 0x00CD00 },
		{ name = "yellow", fg = 33, bg = 43, rgb = 0xCDCD00 },
		{ name = "blue", fg = 34, bg = 44, rgb = 0x0000EE },
		{ name = "magenta", fg = 35, bg = 45, rgb = 0xCD00CD },
		{ name = "cyan", fg = 36, bg = 46, rgb = 0x00CDCD },
		{ name = "white", fg = 37, bg = 47, rgb = 0xE5E5E5 },
	}

	local bright = {
		{ name = "bright black", fg = 90, bg = 100, rgb = 0x7F7F7F },
		{ name = "bright red", fg = 91, bg = 101, rgb = 0xFF0000 },
		{ name = "bright green", fg = 92, bg = 102, rgb = 0x00FF00 },
		{ name = "bright yellow", fg = 93, bg = 103, rgb = 0xFFFF00 },
		{ name = "bright blue", fg = 94, bg = 104, rgb = 0x5C5CFF },
		{ name = "bright magenta", fg = 95, bg = 105, rgb = 0xFF00FF },
		{ name = "bright cyan", fg = 96, bg = 106, rgb = 0x00FFFF },
		{ name = "bright white", fg = 97, bg = 107, rgb = 0xFFFFFF },
	}

	local function define_cases(label, cases)
		for _, case in ipairs(cases) do
			it(
				("%s foreground %d (%s) -> %s"):format(
					label,
					case.fg,
					case.name,
					format_rgb(case.rgb)
				),
				function()
					assert_color(sequence(tostring(case.fg)), case.rgb, nil)
				end
			)

			it(
				("%s background %d (%s) -> %s"):format(
					label,
					case.bg,
					case.name,
					format_rgb(case.rgb)
				),
				function()
					assert_color(sequence(tostring(case.bg)), nil, case.rgb)
				end
			)
		end
	end

	define_cases("normal", normal)
	define_cases("bright", bright)
end)

-- ============================================================================
-- xterm 256 colors
-- ============================================================================

describe("SGR parser: xterm 256 colors", function()
	-- Every important boundary between the ANSI, cube, and grayscale ranges.
	local boundaries = {
		{ index = 0, rgb = 0x000000 },
		{ index = 15, rgb = 0xFFFFFF },
		{ index = 16, rgb = 0x000000 },
		{ index = 231, rgb = 0xFFFFFF },
		{ index = 232, rgb = 0x080808 },
		{ index = 255, rgb = 0xEEEEEE },
	}

	local function define_boundary_cases(label, format, target)
		for _, case in ipairs(boundaries) do
			local parameters = format:format(case.index)

			it(
				("%s: %s -> %s"):format(label, parameters, format_rgb(case.rgb)),
				function()
					if target == "fg" then
						assert_color(sequence(parameters), case.rgb, nil)
					else
						assert_color(sequence(parameters), nil, case.rgb)
					end
				end
			)
		end
	end

	define_boundary_cases("foreground semicolon boundary", "38;5;%d", "fg")
	define_boundary_cases("background semicolon boundary", "48;5;%d", "bg")
	define_boundary_cases("foreground colon boundary", "38:5:%d", "fg")
	define_boundary_cases("background colon boundary", "48:5:%d", "bg")

	local hybrid = {
		{ parameters = "38;5:0", fg = 0x000000 },
		{ parameters = "38;5:21", fg = 0x0000FF },
		{ parameters = "38;5:196", fg = 0xFF0000 },
		{ parameters = "38;5:255", fg = 0xEEEEEE },
		{ parameters = "48;5:0", bg = 0x000000 },
		{ parameters = "48;5:21", bg = 0x0000FF },
		{ parameters = "48;5:196", bg = 0xFF0000 },
		{ parameters = "48;5:255", bg = 0xEEEEEE },
	}

	for _, case in ipairs(hybrid) do
		it(
			("hybrid separator %s -> fg %s bg %s"):format(
				case.parameters,
				format_rgb(case.fg),
				format_rgb(case.bg)
			),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end

	-- The 6x6x6 color cube uses the channel levels 0, 95, 135, 175, 215, 255.
	local cube = {
		{ index = 17, rgb = 0x00005F },
		{ index = 21, rgb = 0x0000FF },
		{ index = 51, rgb = 0x00FFFF },
		{ index = 54, rgb = 0x5F0087 },
		{ index = 81, rgb = 0x5FD7FF },
		{ index = 125, rgb = 0xAF005F },
		{ index = 136, rgb = 0xAF8700 },
		{ index = 196, rgb = 0xFF0000 },
	}

	for _, case in ipairs(cube) do
		it(
			("color cube foreground index %d -> %s"):format(
				case.index,
				format_rgb(case.rgb)
			),
			function()
				assert_color(sequence(("38;5;%d"):format(case.index)), case.rgb, nil)
			end
		)
	end

	it("color cube background index 81 -> #5FD7FF", function()
		assert_color(sequence("48;5;81"), nil, 0x5FD7FF)
	end)

	it("color cube background index 196 -> #FF0000", function()
		assert_color(sequence("48;5;196"), nil, 0xFF0000)
	end)

	-- The grayscale ramp starts at 8 and increases by 10 for indices 232-255.
	local grayscale = {
		{ index = 233, rgb = 0x121212 },
		{ index = 240, rgb = 0x585858 },
		{ index = 255, rgb = 0xEEEEEE },
	}

	for _, case in ipairs(grayscale) do
		it(
			("grayscale foreground index %d -> %s"):format(
				case.index,
				format_rgb(case.rgb)
			),
			function()
				assert_color(sequence(("38;5;%d"):format(case.index)), case.rgb, nil)
			end
		)
	end

	it("grayscale background index 240 -> #585858", function()
		assert_color(sequence("48;5:240"), nil, 0x585858)
	end)
end)

-- ============================================================================
-- Truecolor: semicolon syntax
-- ============================================================================

describe("SGR parser: truecolor semicolon syntax", function()
	local foreground = {
		{ rgb = 0x000000, label = "0,0,0" },
		{ rgb = 0x010101, label = "1,1,1" },
		{ rgb = 0x7F7F7F, label = "127,127,127" },
		{ rgb = 0xFEFEFE, label = "254,254,254" },
		{ rgb = 0xFFFFFF, label = "255,255,255" },
		{ rgb = 0xFF0000, label = "255,0,0" },
		{ rgb = 0x00FF00, label = "0,255,0" },
		{ rgb = 0x0000FF, label = "0,0,255" },
		{ rgb = 0x010000, label = "1,0,0" },
		{ rgb = 0x000100, label = "0,1,0" },
		{ rgb = 0x000001, label = "0,0,1" },
		{ rgb = 0xFF8040, label = "255,128,64" },
		{ rgb = 0x7FFE01, label = "127,254,1" },
	}

	local background = {
		{ rgb = 0x000000, label = "0,0,0" },
		{ rgb = 0x010101, label = "1,1,1" },
		{ rgb = 0x7F7F7F, label = "127,127,127" },
		{ rgb = 0xFEFEFE, label = "254,254,254" },
		{ rgb = 0xFFFFFF, label = "255,255,255" },
		{ rgb = 0x010203, label = "1,2,3" },
		{ rgb = 0x4080FF, label = "64,128,255" },
	}

	for _, case in ipairs(foreground) do
		local parameters = ("38;2;%s"):format(case.label:gsub(",", ";"))

		it(
			("foreground %s -> %s"):format(case.label, format_rgb(case.rgb)),
			function()
				assert_color(sequence(parameters), case.rgb, nil)
			end
		)
	end

	for _, case in ipairs(background) do
		local parameters = ("48;2;%s"):format(case.label:gsub(",", ";"))

		it(
			("background %s -> %s"):format(case.label, format_rgb(case.rgb)),
			function()
				assert_color(sequence(parameters), nil, case.rgb)
			end
		)
	end
end)

-- ============================================================================
-- Truecolor: colon syntax and compatibility forms
-- ============================================================================

describe("SGR parser: truecolor colon syntax", function()
	local empty_csid = {
		{ parameters = "38:2::0:0:0", fg = 0x000000 },
		{ parameters = "38:2::255:255:255", fg = 0xFFFFFF },
		{ parameters = "38:2::255:128:64", fg = 0xFF8040 },
		{ parameters = "48:2::1:2:3", bg = 0x010203 },
		{ parameters = "48:2::64:128:255", bg = 0x4080FF },
	}

	for _, case in ipairs(empty_csid) do
		it(
			("empty color-space identifier %s -> fg %s bg %s"):format(
				case.parameters,
				format_rgb(case.fg),
				format_rgb(case.bg)
			),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end

	local numeric_csid = {
		{ parameters = "38:2:0:255:128:64", fg = 0xFF8040 },
		{ parameters = "38:2:1:255:128:64", fg = 0xFF8040 },
		{ parameters = "38:2:2:255:128:64", fg = 0xFF8040 },
		{ parameters = "38:2:99:255:128:64", fg = 0xFF8040 },
		{ parameters = "38:2:255:255:128:64", fg = 0xFF8040 },
		-- The color-space identifier is not restricted to the 0-255 channel
		-- range; it is parsed and then ignored for RGB conversion.
		{ parameters = "38:2:9999:255:128:64", fg = 0xFF8040 },
		{ parameters = "48:2:7:1:2:3", bg = 0x010203 },
	}

	for _, case in ipairs(numeric_csid) do
		it(
			("numeric color-space identifier %s -> fg %s bg %s"):format(
				case.parameters,
				format_rgb(case.fg),
				format_rgb(case.bg)
			),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end

	local hybrid = {
		{ parameters = "38;2::1:2:3", fg = 0x010203 },
		{ parameters = "38;2:1:255:128:64", fg = 0xFF8040 },
		{ parameters = "48;2::1:2:3", bg = 0x010203 },
		{ parameters = "48;2:7:64:128:255", bg = 0x4080FF },
	}

	for _, case in ipairs(hybrid) do
		it(
			("hybrid separator %s -> fg %s bg %s"):format(
				case.parameters,
				format_rgb(case.fg),
				format_rgb(case.bg)
			),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end

	-- ALLOW_LEGACY_COLON_RGB is enabled in the parser, so a three-field colon
	-- group is interpreted as R:G:B (with no color-space identifier).
	local legacy = {
		{ parameters = "38:2:255:128:64", fg = 0xFF8040 },
		{ parameters = "38:2:1:2:3", fg = 0x010203 },
		{ parameters = "48:2:1:2:3", bg = 0x010203 },
		{ parameters = "48:2:64:128:255", bg = 0x4080FF },
	}

	for _, case in ipairs(legacy) do
		it(
			("legacy colon shorthand %s -> fg %s bg %s"):format(
				case.parameters,
				format_rgb(case.fg),
				format_rgb(case.bg)
			),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end
end)

-- ============================================================================
-- Color-space and optional parameters
-- ============================================================================

describe("SGR parser: color-space and optional parameters", function()
	local valid = {
		{ parameters = "38:2:1:17:34:51", label = "numeric CSID" },
		{ parameters = "38:2:9999:17:34:51", label = "large numeric CSID" },
		{ parameters = "38:2::17:34:51:200", label = "reserved parameter" },
		{ parameters = "38:2::17:34:51:", label = "empty reserved parameter" },
		{ parameters = "38:2::17:34:51::100", label = "empty reserved + tolerance" },
		{ parameters = "38:2::17:34:51:200:100", label = "reserved + tolerance" },
		{ parameters = "38:2::17:34:51:::1", label = "tolerance color space CIELAB" },
		{ parameters = "38:2::17:34:51:200:100:0", label = "all optional, CIELUV" },
		{ parameters = "38:2::17:34:51:200:100:1", label = "all optional, CIELAB" },
		{ parameters = "38:2::17:34:51:200:100:", label = "empty tolerance color space" },
	}

	for _, case in ipairs(valid) do
		it(
			("ignored optional parameters preserve RGB: %s (%s)"):format(
				case.label,
				case.parameters
			),
			function()
				assert_color(sequence(case.parameters), 0x112233, nil)
			end
		)
	end

	it("optional tolerance is not restricted to 0-255", function()
		assert_color(sequence("38:2::1:2:3:9:9999:1"), 0x010203, nil)
	end)

	it("optional parameter values do not alter the background result", function()
		assert_color(sequence("48:2::17:34:51:200:100:1"), nil, 0x112233)
	end)

	local invalid_optional = {
		{ parameters = "38:2::17:34:51:x", label = "non-numeric reserved parameter" },
		{ parameters = "38:2::17:34:51:200:x", label = "non-numeric tolerance" },
		{ parameters = "38:2::17:34:51:200:100:2", label = "tolerance color space above 1" },
		{ parameters = "38:2::17:34:51:200:100:-1", label = "negative tolerance color space" },
		{ parameters = "38:2::17:34:51:200:100:255", label = "tolerance color space above range" },
	}

	for _, case in ipairs(invalid_optional) do
		it(
			("rejects %s (%s)"):format(case.label, case.parameters),
			function()
				assert_rejected(sequence(case.parameters))
			end
		)
	end

	local missing_fields = {
		{ parameters = "38:2::1:2", label = "missing blue channel" },
		{ parameters = "38:2:1:2", label = "missing blue channel with numeric CSID" },
		{ parameters = "38:2::1", label = "missing green and blue channels" },
		{ parameters = "38:2:1", label = "only a color-space identifier" },
		{ parameters = "38:2::", label = "empty CSID with no channels" },
		{ parameters = "38:2:", label = "empty CSID field only" },
		{ parameters = "38:2", label = "missing colon after mode" },
		{ parameters = "48:2::1:2", label = "background missing blue channel" },
	}

	for _, case in ipairs(missing_fields) do
		it(
			("rejects %s (%s)"):format(case.label, case.parameters),
			function()
				assert_rejected(sequence(case.parameters))
			end
		)
	end

	local extra_fields = {
		{ parameters = "38:2::1:2:3:1:2:3:4", label = "eighth field" },
		{ parameters = "38:2::1:2:3:1:2:3:4:5", label = "ninth field" },
		{ parameters = "48:2::1:2:3:1:2:3:4", label = "background eighth field" },
	}

	for _, case in ipairs(extra_fields) do
		it(
			("rejects excessive colon subparameters: %s (%s)"):format(
				case.label,
				case.parameters
			),
			function()
				assert_rejected(sequence(case.parameters))
			end
		)
	end

	it("rejects a non-numeric color-space identifier", function()
		assert_rejected(sequence("38:2:x:1:2:3"))
	end)
end)

-- ============================================================================
-- Invalid input and boundary validation
-- ============================================================================

describe("SGR parser: invalid input and boundary validation", function()
	local invalid = {
		{ parameters = "38;5;-1", label = "negative palette index" },
		{ parameters = "38;5;256", label = "palette index above 255" },
		{ parameters = "38;5;999", label = "large palette index" },
		{ parameters = "38;5;", label = "empty palette index" },
		{ parameters = "38;5;;", label = "empty palette index with extra separator" },
		{ parameters = "38;", label = "missing color mode" },
		{ parameters = "38", label = "missing color mode separator" },
		{ parameters = "38;3;1", label = "unsupported semicolon mode 3" },
		{ parameters = "38;4;1", label = "unsupported semicolon mode 4" },
		{ parameters = "38;1", label = "unsupported semicolon mode 1" },
		{ parameters = "38;0", label = "unsupported semicolon mode 0" },
		{ parameters = "38:3:1", label = "unsupported colon mode 3" },
		{ parameters = "38:4:1", label = "unsupported colon mode 4" },
		{ parameters = "38;2,1,2,3", label = "comma separators" },
		{ parameters = "38;2:1;2;3", label = "mixed semicolon and colon fields" },
		{ parameters = "38:2;1:2:3", label = "colon mode with semicolon fields" },
		{ parameters = "38;2;-1;2;3", label = "negative red channel" },
		{ parameters = "38;2;256;2;3", label = "red channel above 255" },
		{ parameters = "38;2;1;999;3", label = "green channel above 255" },
		{ parameters = "38;2;1;2;300", label = "blue channel above 255" },
		{ parameters = "38;2;;1;2", label = "empty red channel" },
		{ parameters = "38;2;1;;2", label = "empty green channel" },
		{ parameters = "38;2;1;2;", label = "empty blue channel" },
		{ parameters = "38;2;1;2", label = "missing blue channel" },
		{ parameters = "38;2;1", label = "missing green and blue channels" },
		{ parameters = "38;2", label = "missing all RGB channels" },
		{ parameters = "38;2;1;2;x", label = "non-numeric blue channel" },
		{ parameters = "38;2;1;x;2", label = "non-numeric green channel" },
		{ parameters = "38;2;x;1;2", label = "non-numeric red channel" },
		{ parameters = "38;2;+1;2;3", label = "signed red channel" },
		{ parameters = "38:5:256", label = "colon palette index above 255" },
		{ parameters = "38:5:-1", label = "negative colon palette index" },
		{ parameters = "38:5:", label = "empty colon palette index" },
		{ parameters = "38:5", label = "missing colon palette index" },
		{ parameters = "38:5:196:5", label = "extra colon palette subparameter" },
		{ parameters = "38:5:196:", label = "trailing empty colon palette subparameter" },
		{ parameters = "38:;1", label = "empty colon color mode" },
		{ parameters = "38::1", label = "empty colon before mode" },
		{ parameters = "38;5;196;", label = "trailing empty parameter resets foreground" },
	}

	for _, case in ipairs(invalid) do
		it(
			("rejects %s (%s)"):format(case.label, case.parameters),
			function()
				assert_rejected(sequence(case.parameters))
			end
		)
	end

	local trailing_junk = {
		{ value = sequence("31") .. "X", label = "character after terminator" },
		{ value = sequence("38;2;1;2;3") .. "X", label = "truecolor junk after terminator" },
		{ value = sequence("31") .. " ", label = "space after terminator" },
		{ value = sequence("31") .. "\n", label = "newline after terminator" },
		{ value = sequence("31x"), label = "non-numeric character before terminator" },
		{
			value = sequence("38;2;1;2;3:4"),
			label = "colon data after semicolon truecolor channels",
		},
		{
			value = sequence("38;5;196:4"),
			label = "colon data after a semicolon palette index",
		},
		{ value = sequence("38:2::1:2:3:z"), label = "non-numeric optional field" },
	}

	for _, case in ipairs(trailing_junk) do
		it(
			("rejects %s"):format(case.label),
			function()
				assert_rejected(case.value)
			end
		)
	end

	local invalid_preserving = {
		{
			parameters = "31;38;5;256",
			fg = 0xCD0000,
			bg = nil,
			label = "invalid palette index after ANSI foreground",
		},
		{
			parameters = "31;38;5;",
			fg = 0xCD0000,
			bg = nil,
			label = "missing palette index after ANSI foreground",
		},
		{
			parameters = "31;38;2;1;2",
			fg = 0xCD0000,
			bg = nil,
			label = "incomplete truecolor after ANSI foreground",
		},
		{
			parameters = "31;38;2;;1;2",
			fg = 0xCD0000,
			bg = nil,
			label = "empty truecolor channel after ANSI foreground",
		},
		{
			parameters = "31;38;2;256;1;2",
			fg = 0xCD0000,
			bg = nil,
			label = "out-of-range truecolor channel after ANSI foreground",
		},
		{
			parameters = "31;38:2::1:2",
			fg = 0xCD0000,
			bg = nil,
			label = "incomplete colon truecolor after ANSI foreground",
		},
		{
			parameters = "31;38:5:256",
			fg = 0xCD0000,
			bg = nil,
			label = "invalid colon palette after ANSI foreground",
		},
		{
			parameters = "31;38;3;1",
			fg = 0xCD0000,
			bg = nil,
			label = "unsupported mode after ANSI foreground",
		},
		{
			parameters = "44;48;5;999",
			fg = nil,
			bg = 0x0000EE,
			label = "invalid palette index after ANSI background",
		},
		{
			parameters = "44;48;2;1;2",
			fg = nil,
			bg = 0x0000EE,
			label = "incomplete truecolor after ANSI background",
		},
		{
			parameters = "31;38;5;196:4",
			fg = 0xCD0000,
			bg = nil,
			label = "malformed colon data after a palette index",
		},
		{
			parameters = "31;38;2;1;2;3:4",
			fg = 0xCD0000,
			bg = nil,
			label = "malformed colon data after truecolor channels",
		},
	}

	for _, case in ipairs(invalid_preserving) do
		it(
			("preserves valid colors when ignoring %s"):format(case.label),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end
end)

-- ============================================================================
-- SGR attributes and resets
-- ============================================================================

describe("SGR parser: SGR attributes and resets", function()
	local cases = {
		{ parameters = "0", fg = nil, bg = nil, label = "full reset alone" },
		{ parameters = "0;0", fg = nil, bg = nil, label = "multiple full resets" },
		{ parameters = "39", fg = nil, bg = nil, label = "foreground reset alone" },
		{ parameters = "49", fg = nil, bg = nil, label = "background reset alone" },
		{ parameters = "39;49", fg = nil, bg = nil, label = "foreground and background resets" },
		{ parameters = "31;0", fg = nil, bg = nil, label = "full reset after foreground" },
		{ parameters = "44;0", fg = nil, bg = nil, label = "full reset after background" },
		{ parameters = "31;44;0", fg = nil, bg = nil, label = "full reset after both colors" },
		{ parameters = "31;44;0;0", fg = nil, bg = nil, label = "repeated full reset after both colors" },
		{ parameters = "0;31", fg = 0xCD0000, bg = nil, label = "reset before foreground" },
		{ parameters = "0;44", fg = nil, bg = 0x0000EE, label = "reset before background" },
		{ parameters = "0;31;44", fg = 0xCD0000, bg = 0x0000EE, label = "reset before both colors" },
		{ parameters = "31;0;44", fg = nil, bg = 0x0000EE, label = "reset between colors" },
		{ parameters = "31;39", fg = nil, bg = nil, label = "foreground reset after foreground" },
		{ parameters = "44;49", fg = nil, bg = nil, label = "background reset after background" },
		{ parameters = "31;44;39", fg = nil, bg = 0x0000EE, label = "foreground reset keeps background" },
		{ parameters = "31;44;49", fg = 0xCD0000, bg = nil, label = "background reset keeps foreground" },
		{ parameters = "31;44;39;49", fg = nil, bg = nil, label = "both resets after both colors" },
		{ parameters = "31;39;44", fg = nil, bg = 0x0000EE, label = "foreground reset before background" },
		{ parameters = "44;49;31", fg = 0xCD0000, bg = nil, label = "background reset before foreground" },
		{ parameters = "0;31;0;44;0", fg = nil, bg = nil, label = "repeated resets around colors" },
		{ parameters = "31;;", fg = nil, bg = nil, label = "trailing empty parameters reset colors" },
		{ parameters = "31;;44", fg = nil, bg = 0x0000EE, label = "empty parameter resets before background" },
		{ parameters = ";31", fg = 0xCD0000, bg = nil, label = "leading empty parameter is a reset" },
		{ parameters = ";;31", fg = 0xCD0000, bg = nil, label = "multiple leading empty parameters" },
		{ parameters = "1;31;44", fg = 0xCD0000, bg = 0x0000EE, label = "bold mixed with colors" },
		{
			parameters = "1;2;3;4;5;7;8;9;31;44;53",
			fg = 0xCD0000,
			bg = 0x0000EE,
			label = "many unrelated attributes mixed with colors",
		},
		{ parameters = "1;4:3;31", fg = 0xCD0000, bg = nil, label = "colon attribute before foreground" },
		{ parameters = "1;4:3;44", fg = nil, bg = 0x0000EE, label = "colon attribute before background" },
		{ parameters = "4:3", fg = nil, bg = nil, label = "colon attribute alone" },
		{ parameters = "4:3;4:3", fg = nil, bg = nil, label = "multiple colon attributes" },
		{ parameters = "4:3;31;4:3", fg = 0xCD0000, bg = nil, label = "colon attribute around foreground" },
		{ parameters = "38;5;196;4:3", fg = 0xFF0000, bg = nil, label = "colon attribute after extended color" },
		{ parameters = "4:3;48;5:21", fg = nil, bg = 0x0000FF, label = "colon attribute before extended background" },
		{ parameters = "21;31", fg = 0xCD0000, bg = nil, label = "double underline before foreground" },
		{ parameters = "58;5;196", fg = nil, bg = nil, label = "underline color is not foreground" },
	}

	for _, case in ipairs(cases) do
		it(
			("%s (%s)"):format(case.label, case.parameters),
			function()
				local value = sequence(case.parameters)

				if case.fg == nil and case.bg == nil then
					assert_rejected(value)
				else
					assert_color(value, case.fg, case.bg)
				end
			end
		)
	end
end)

-- ============================================================================
-- Multiple color declarations
-- ============================================================================

describe("SGR parser: multiple color declarations", function()
	local cases = {
		{
			parameters = "31;48;2;255;128;64",
			fg = 0xCD0000,
			bg = 0xFF8040,
			label = "ANSI foreground with truecolor background",
		},
		{
			parameters = "38;5;196;48:5:21",
			fg = 0xFF0000,
			bg = 0x0000FF,
			label = "indexed foreground with colon indexed background",
		},
		{
			parameters = "38:2::255:128:64;49",
			fg = 0xFF8040,
			bg = nil,
			label = "truecolor foreground followed by background reset",
		},
		{
			parameters = "31;32;44",
			fg = 0x00CD00,
			bg = 0x0000EE,
			label = "last foreground wins",
		},
		{
			parameters = "41;44",
			fg = nil,
			bg = 0x0000EE,
			label = "last background wins",
		},
		{
			parameters = "31;44;32;41",
			fg = 0x00CD00,
			bg = 0xCD0000,
			label = "last foreground and background win independently",
		},
		{
			parameters = "38;5;196;38;5;21",
			fg = 0x0000FF,
			bg = nil,
			label = "last indexed foreground wins",
		},
		{
			parameters = "48;5;21;48;5;196",
			fg = nil,
			bg = 0xFF0000,
			label = "last indexed background wins",
		},
		{
			parameters = "31;38;5;256",
			fg = 0xCD0000,
			bg = nil,
			label = "invalid extended foreground preserves ANSI foreground",
		},
		{
			parameters = "44;48;5;999",
			fg = nil,
			bg = 0x0000EE,
			label = "invalid extended background preserves ANSI background",
		},
		{
			parameters = "31;44;48;2;1;2;3",
			fg = 0xCD0000,
			bg = 0x010203,
			label = "valid background replaces earlier background",
		},
		{
			parameters = "31;44;38;2;1;2;3",
			fg = 0x010203,
			bg = 0x0000EE,
			label = "valid foreground replaces earlier foreground",
		},
		{
			parameters = "31;44;38;2;1;2",
			fg = 0xCD0000,
			bg = 0x0000EE,
			label = "invalid foreground leaves foreground and background intact",
		},
	}

	for _, case in ipairs(cases) do
		it(
			("%s (%s)"):format(case.label, case.parameters),
			function()
				assert_color(sequence(case.parameters), case.fg, case.bg)
			end
		)
	end
end)

-- ============================================================================
-- Escape sequence representations
-- ============================================================================

describe("SGR parser: escape sequence representations", function()
	local introducers = {
		{ name = "actual ESC", prefix = ESC .. "[" },
		{ name = "actual 8-bit CSI", prefix = CSI_8 },
		{ name = "literal \\27[", prefix = "\\27[" },
		{ name = "literal \\033[", prefix = "\\033[" },
		{ name = "literal \\x1b[", prefix = "\\x1b[" },
		{ name = "literal \\x1B[", prefix = "\\x1B[" },
		{ name = "literal \\e[", prefix = "\\e[" },
		{ name = "literal \\u001b[", prefix = "\\u001b[" },
		{ name = "literal \\u001B[", prefix = "\\u001B[" },
		{ name = "literal \\x9b[", prefix = "\\x9b[" },
		{ name = "literal \\x9B[", prefix = "\\x9B[" },
		{ name = "literal \\u009b[", prefix = "\\u009b[" },
		{ name = "literal \\u009B[", prefix = "\\u009B[" },
	}

	for _, case in ipairs(introducers) do
		it(
			("resolves ANSI red using %s"):format(case.name),
			function()
				assert_color(case.prefix .. "31m", 0xCD0000, nil)
			end
		)
	end

	it("resolves truecolor using an actual 8-bit CSI", function()
		assert_color(CSI_8 .. "38;2;1;2;3m", 0x010203, nil)
	end)

	it("resolves truecolor using a literal \\x9b[ introducer", function()
		assert_color("\\x9b[38;2;1;2;3m", 0x010203, nil)
	end)

	local invalid_introducers = {
		{ value = "[31m", label = "missing introducer" },
		{ value = ESC .. "31m", label = "ESC without bracket" },
		{ value = ESC .. "x[31m", label = "ESC followed by a wrong byte" },
		{ value = "\\q[31m", label = "unknown literal escape" },
		{ value = "\\x2[31m", label = "wrong hex escape value" },
		{ value = "\\x1c[31m", label = "wrong hex escape suffix" },
		{ value = "\\x9c[31m", label = "wrong 8-bit hex escape value" },
		{ value = "\\u001c[31m", label = "wrong unicode escape suffix" },
		{ value = "\\u009c[31m", label = "wrong 8-bit unicode escape value" },
		{ value = "0x9b[31m", label = "0x prefix instead of a backslash" },
		{ value = CSI_8 .. "[31m", label = "8-bit CSI followed by an extra bracket" },
	}

	for _, case in ipairs(invalid_introducers) do
		it(
			("rejects %s"):format(case.label),
			function()
				assert_rejected(case.value)
			end
		)
	end

	local malformed_terminators = {
		{ value = ESC .. "[31", label = "missing terminator" },
		{ value = ESC .. "[31M", label = "uppercase terminator" },
		{ value = ESC .. "[31n", label = "wrong terminator" },
		{ value = ESC .. "[31mX", label = "junk after terminator" },
		{ value = "\\x1b[31", label = "literal introducer without terminator" },
		{ value = "\\x9b[31", label = "literal 8-bit introducer without terminator" },
		{ value = "\\u009b[31", label = "literal unicode 8-bit introducer without terminator" },
		{ value = ESC .. "[38;2;1;2;3", label = "truecolor missing terminator" },
		{ value = ESC .. "[", label = "introducer only" },
		{ value = ESC .. "[m", label = "empty parameter list is a reset, not a color" },
	}

	for _, case in ipairs(malformed_terminators) do
		it(
			("rejects %s"):format(case.label),
			function()
				assert_rejected(case.value)
			end
		)
	end
end)

describe("SGR parser: escape introducer patterns", function()
	-- These cases verify that the parser's public `patterns` table can actually
	-- find every documented introducer form before `resolve` is called.
	local introducers = {
		{ name = "actual ESC", prefix = ESC .. "[" },
		{ name = "actual 8-bit CSI", prefix = CSI_8 },
		{ name = "literal \\27[", prefix = "\\27[" },
		{ name = "literal \\033[", prefix = "\\033[" },
		{ name = "literal \\x1b[", prefix = "\\x1b[" },
		{ name = "literal \\x1B[", prefix = "\\x1B[" },
		{ name = "literal \\e[", prefix = "\\e[" },
		{ name = "literal \\u001b[", prefix = "\\u001b[" },
		{ name = "literal \\u001B[", prefix = "\\u001B[" },
		{ name = "literal \\x9b[", prefix = "\\x9b[" },
		{ name = "literal \\x9B[", prefix = "\\x9B[" },
		{ name = "literal \\u009b[", prefix = "\\u009b[" },
		{ name = "literal \\u009B[", prefix = "\\u009B[" },
	}

	for _, case in ipairs(introducers) do
		it(
			("patterns recognize %s"):format(case.name),
			function()
				local value = case.prefix .. "31m"

				assert.is_true(
					matches_any_pattern(value),
					("expected a parser pattern to match %q"):format(value)
				)
			end
		)
	end
end)

-- ============================================================================
-- Parser output contract
-- ============================================================================

describe("SGR parser: output contract", function()
	it("preserves col_start and col_end for a foreground color", function()
		local result = sgr.resolve({
			value = sequence("31"),
			col_start = 0,
			col_end = 5,
		})

		assert.is_not_nil(result)
		assert.are.same(0, result.col_start)
		assert.are.same(5, result.col_end)
		assert.are.same(0xCD0000, result.fg)
		assert.is_nil(result.bg)
	end)

	it("preserves col_start and col_end for a background color", function()
		local result = sgr.resolve({
			value = sequence("44"),
			col_start = 100,
			col_end = 104,
		})

		assert.is_not_nil(result)
		assert.are.same(100, result.col_start)
		assert.are.same(104, result.col_end)
		assert.is_nil(result.fg)
		assert.are.same(0x0000EE, result.bg)
	end)

	it("preserves col_start and col_end for both colors", function()
		local result = sgr.resolve({
			value = sequence("31;44"),
			col_start = 7,
			col_end = 12,
		})

		assert.is_not_nil(result)
		assert.are.same(7, result.col_start)
		assert.are.same(12, result.col_end)
		assert.are.same(0xCD0000, result.fg)
		assert.are.same(0x0000EE, result.bg)
	end)

	it("preserves zero-valued columns", function()
		local result = sgr.resolve({
			value = sequence("31"),
			col_start = 0,
			col_end = 0,
		})

		assert.is_not_nil(result)
		assert.are.same(0, result.col_start)
		assert.are.same(0, result.col_end)
	end)

	it("leaves a missing foreground as nil", function()
		local result = assert_color(sequence("44"), nil, 0x0000EE)

		assert.is_nil(result.fg)
	end)

	it("leaves a missing background as nil", function()
		local result = assert_color(sequence("31"), 0xCD0000, nil)

		assert.is_nil(result.bg)
	end)

	it("returns nil for an invalid sequence with no resolved colors", function()
		assert_rejected(sequence("38;5;256"))
	end)

	it("returns nil for a reset-only sequence", function()
		assert_rejected(sequence("0;39;49"))
	end)

	it("ignores extra fields on the match table", function()
		local result = sgr.resolve({
			value = sequence("31;44"),
			col_start = 3,
			col_end = 8,
			pattern = "unused",
			extra = true,
		})

		assert.is_not_nil(result)
		assert.are.same(3, result.col_start)
		assert.are.same(8, result.col_end)
		assert.are.same(0xCD0000, result.fg)
		assert.are.same(0x0000EE, result.bg)
	end)
end)
