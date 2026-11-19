# Parser test vectors

## hex parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| hex | long_black | `#000000` | - | `#000000` | 0 | 7 | string color is preserved |
| hex | long_white | `#FFFFFF` | - | `#FFFFFF` | 0 | 7 | uppercase |
| hex | long_lowercase | `#ff5733` | - | `#ff5733` | 0 | 7 | case preserved |
| hex | long_alpha | `#FF800080` | - | `#FF800080` | 0 | 9 | 8-digit string color |
| hex | prefix_offset | `color: #123456;` | - | `#123456` | 7 | 14 | word boundary offsets |
| hex | background_offset | `background:#00ff00` | - | `#00ff00` | 11 | 18 | no space after colon |
| hex | zero_x_black | `0x000000` | - | `0x0` | 0 | 8 | numeric color |
| hex | zero_x_upper | `0XFF5733` | - | `0xFF5733` | 0 | 8 | uppercase 0X prefix |
| hex | zero_x_padded | `x 0x123456 y` | - | `0x123456` | 2 | 10 | frontier offsets |
| hex | five_digits | `#12345` | - | - | - | - | too short |
| hex | seven_digits | `#1234567` | - | - | - | - | wrong length |
| hex | zero_x_five | `0x12345` | - | - | - | - | too short |
| hex | zero_x_eight | `0x12345678` | - | - | - | - | too long |
| hex | non_hex | `#GGGGGG` | - | - | - | - | non-hex digits |
| hex | short_form | `#FFF` | - | - | - | - | handled by short_hex |
| hex | short_alpha_form | `#F53A` | - | - | - | - | handled by short_hex |
| hex | long_mixed_case | `#AbCdEf` | - | `#AbCdEf` | 0 | 7 | case is preserved |
| hex | alpha_black | `#00000000` | - | `#00000000` | 0 | 9 | fully transparent string color |
| hex | zero_x_leading_zero | `0x00000f` | - | `0xF` | 0 | 8 | numeric value drops leading zeroes |
| hex | zero_x_mixed_case | `0XaBcDeF` | - | `0xABCDEF` | 0 | 8 | mixed-case digits |
| hex | nine_digits | `#123456789` | - | - | - | - | CSS hex cannot have nine digits |
| hex | zero_x_seven | `0x1234567` | - | - | - | - | numeric form rejects seven digits |
| hex | hash_trailing_hyphen | `#123456-def` | - | - | - | - | frontier rejects hyphen |

## short_hex parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| short_hex | white | `#FFF` | - | `#FFF` | 0 | 4 | default resolve keeps text |
| short_hex | rgb | `#F53` | - | `#F53` | 0 | 4 | 3-digit form |
| short_hex | rgba | `#f53a` | - | `#f53a` | 0 | 5 | 4-digit lowercase form |
| short_hex | transparent | `#0000` | - | `#0000` | 0 | 5 | alpha zero |
| short_hex | offset | `color: #abc;` | - | `#abc` | 7 | 11 | word boundary offsets |
| short_hex | two_digits | `#FF` | - | - | - | - | too short |
| short_hex | five_digits | `#FFFFF` | - | - | - | - | wrong length |
| short_hex | long_form | `#123456` | - | - | - | - | handled by hex |
| short_hex | non_hex | `#GGF` | - | - | - | - | non-hex digits |
| short_hex | trailing_hyphen | `#abc-def` | - | - | - | - | frontier rejects hyphen |
| short_hex | black | `#000` | - | `#000` | 0 | 4 | short black |
| short_hex | uppercase_rgba | `#ABCD` | - | `#ABCD` | 0 | 5 | uppercase alpha form |
| short_hex | mixed_case | `#aBcD` | - | `#aBcD` | 0 | 5 | case is preserved |
| short_hex | embedded | `x #abc y` | - | `#abc` | 2 | 6 | frontier offsets in text |
| short_hex | seven_digits | `#1234567` | - | - | - | - | invalid length |
| short_hex | zero_prefix | `#0000000` | - | - | - | - | invalid length |

## rgb parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| rgb | legacy_red | `rgb(255, 0, 0)` | - | `0xFF0000` | 0 | 14 | legacy commas |
| rgb | legacy_spaces | `rgb( 12 , 34 , 56 )` | - | `0x0C2238` | 0 | 19 | whitespace around commas |
| rgb | legacy_percent | `rgb(100%, 0%, 0%)` | - | `0xFF0000` | 0 | 17 | percentage channels |
| rgb | legacy_rgba | `rgba(255, 128, 0, 0.5)` | - | `0x180FF8000` | 0 | 22 | numeric legacy alpha |
| rgb | legacy_alpha_percent | `rgba(0, 255, 0, 20%)` | - | `0x13300FF00` | 0 | 20 | percentage legacy alpha |
| rgb | modern_red | `rgb(255 0 0)` | - | `0xFF0000` | 0 | 12 | modern spaces |
| rgb | modern_mixed | `rgb(100% 128 0)` | - | `0xFF8000` | 0 | 15 | mixed number and percentage |
| rgb | modern_decimal | `rgb(1.2 2.6 3)` | - | `0x010303` | 0 | 14 | rounded half-up |
| rgb | modern_alpha | `rgb(255 128 0 / .5)` | - | `0x180FF8000` | 0 | 19 | slash alpha |
| rgb | clamped | `rgb(-5 260 128)` | - | `0x00FF80` | 0 | 15 | clamped channels |
| rgb | uppercase | `RGB(1, 2, 3)` | - | `0x010203` | 0 | 12 | case-insensitive name |
| rgb | alpha_zero | `rgb(0 0 0 / 0)` | - | `0x100000000` | 0 | 14 | transparent black |
| rgb | alpha_one | `rgb(0 0 0 / 1)` | - | `0x000000` | 0 | 14 | opaque black |
| rgb | alpha_quarter | `rgba(10 20 30 / 25%)` | - | `0x1400A141E` | 0 | 20 | modern rgba percentage alpha |
| rgb | rounded_max | `rgb(255.4 0 0)` | - | `0xFF0000` | 0 | 14 | decimal channel rounds to 255 |
| rgb | half_channels | `rgb(0.5 0.5 0.5)` | - | `0x010101` | 0 | 16 | half values round up |
| rgb | padded_black | `rgb( 0 0 0 )` | - | `0x000000` | 0 | 12 | outer whitespace |
| rgb | modern_percentages | `rgb(0% 50% 100%)` | - | `0x0080FF` | 0 | 16 | all channels as percentages |
| rgb | uppercase_alpha | `RGB(1 2 3 / 50%)` | - | `0x180010203` | 0 | 16 | case-insensitive modern form |
| rgb | uppercase_rgba | `RGBA(1 2 3 / 25%)` | - | `0x140010203` | 0 | 17 | case-insensitive rgba |
| rgb | signed_channels | `rgb(+1 -2 300)` | - | `0x0100FF` | 0 | 14 | signed channels and clamping |
| rgb | alpha_clamped_high | `rgb(1 2 3 / 2)` | - | `0x010203` | 0 | 14 | alpha clamps to one |
| rgb | alpha_clamped_low | `rgb(1 2 3 / -1)` | - | `0x100010203` | 0 | 15 | alpha clamps to zero |
| rgb | padded_commas | `rgb( 1 , 2 , 3 )` | - | `0x010203` | 0 | 16 | legacy whitespace around commas |
| rgb | offset | `color: rgb(0 0 255);` | - | `0x0000FF` | 7 | 19 | match offsets |
| rgb | missing_channel | `rgb(255, 0)` | - | - | - | - | legacy needs three channels |
| rgb | mixed_legacy_repr | `rgb(255, 0%, 0)` | - | - | - | - | legacy channels must match |
| rgb | modern_missing_channel | `rgb(1 2)` | - | - | - | - | modern needs three channels |
| rgb | modern_bad_alpha | `rgb(1 2 / 0.5)` | - | - | - | - | missing blue channel |
| rgb | too_many | `rgb(1,2,3,4,5)` | - | - | - | - | too many arguments |
| rgb | scientific | `rgb(1e2 0 0)` | - | - | - | - | scientific notation unsupported |
| rgb | trailing_dot | `rgb(1. 2 3)` | - | - | - | - | trailing decimal unsupported |
| rgb | none_channel | `rgb(none 0 0)` | - | - | - | - | none unsupported |
| rgb | unbalanced | `rgb(1 2 3` | - | - | - | - | unbalanced parentheses |
| rgb | empty | `rgb()` | - | - | - | - | empty function |
| rgb | empty_alpha | `rgb(1 2 3 /)` | - | - | - | - | alpha value required |
| rgb | legacy_rgba_three_args | `rgba(1,2,3)` | - | `0x010203` | 0 | 11 | rgba alias accepts three channels |
| rgb | modern_four_channels | `rgb(1 2 3 4)` | - | - | - | - | alpha requires slash |
| rgb | trailing_comma | `rgb(1, 2, 3,)` | - | - | - | - | trailing comma unsupported |
| rgb | css_comment | `rgb(1 /*x*/ 2 3)` | - | - | - | - | CSS comments unsupported |
| rgb | calc | `rgb(calc(1 + 1) 2 3)` | - | - | - | - | calc() unsupported |
| rgb | nested_var | `rgb(var(--x) 2 3)` | - | - | - | - | var() unsupported |
| rgb | nested_rgb | `rgb(rgb(1 2 3) 2 3)` | - | - | - | - | nested functions unsupported |

## hsl parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| hsl | red | `hsl(0, 100%, 50%)` | - | `0xFF0000` | 0 | 17 | legacy commas |
| hsl | green | `hsl(120, 100%, 50%)` | - | `0x00FF00` | 0 | 19 | legacy commas |
| hsl | blue | `hsl(240, 100%, 50%)` | - | `0x0000FF` | 0 | 19 | legacy commas |
| hsl | orange | `hsl(30 100% 50%)` | - | `0xFF8000` | 0 | 16 | modern spaces |
| hsl | hsla_alpha | `hsla(0, 100%, 50%, 0.5)` | - | `0x180FF0000` | 0 | 23 | legacy alpha |
| hsl | modern_alpha_percent | `hsl(180 100% 50% / 50%)` | - | `0x18000FFFF` | 0 | 23 | slash alpha |
| hsl | turn_unit | `hsl(0.5turn 100% 50%)` | - | `0x00FFFF` | 0 | 21 | turn hue |
| hsl | grad_unit | `hsl(200grad 100% 50%)` | - | `0x00FFFF` | 0 | 21 | grad hue |
| hsl | rad_unit | `hsl(3.14159rad 100% 50%)` | - | `0x00FFFF` | 0 | 24 | radian hue |
| hsl | negative_hue | `hsl(-120 100% 50%)` | - | `0x0000FF` | 0 | 18 | hue wraps |
| hsl | hue_360 | `hsl(360 100% 50%)` | - | `0xFF0000` | 0 | 17 | 360 is red |
| hsl | clamped | `hsl(0 150% -10%)` | - | `0x000000` | 0 | 16 | saturation/lightness clamped |
| hsl | none | `hsl(none 0% 100%)` | - | `0xFFFFFF` | 0 | 17 | none in modern syntax |
| hsl | scientific | `hsl(1e2 0% 100%)` | - | `0xFFFFFF` | 0 | 16 | scientific hue |
| hsl | alpha_zero | `hsl(0 0% 50% / 0)` | - | `0x100808080` | 0 | 17 | transparent gray |
| hsl | alpha_one | `hsl(0 0% 50% / 1)` | - | `0x808080` | 0 | 17 | opaque gray |
| hsl | hue_720 | `hsl(720 100% 50%)` | - | `0xFF0000` | 0 | 17 | hue wraps twice |
| hsl | hue_negative_360 | `hsl(-360 100% 50%)` | - | `0xFF0000` | 0 | 18 | negative full turn |
| hsl | all_none | `hsl(none none none)` | - | `0x000000` | 0 | 19 | CSS none components |
| hsl | legacy_alpha_percent | `hsla(120, 50%, 50%, 100%)` | - | `0x40BF40` | 0 | 25 | fully opaque legacy alpha |
| hsl | alpha_clamped_high | `hsl(0 100% 50% / 2)` | - | `0xFF0000` | 0 | 19 | alpha clamps to one |
| hsl | alpha_clamped_low | `hsl(0 100% 50% / -1)` | - | `0x100FF0000` | 0 | 20 | alpha clamps to zero |
| hsl | alpha_none | `hsl(0 100% 50% / none)` | - | `0xFF0000` | 0 | 22 | none alpha means opaque |
| hsl | uppercase_function | `HSL(0, 100%, 50%)` | - | `0xFF0000` | 0 | 17 | case-insensitive function name |
| hsl | positive_hue | `hsl(+120 100% 50%)` | - | `0x00FF00` | 0 | 18 | explicit positive hue |
| hsl | padded_commas | `hsl( 0 , 100% , 50% )` | - | `0xFF0000` | 0 | 21 | legacy whitespace around commas |
| hsl | negative_turn | `hsl(-.5turn 100% 50%)` | - | `0x00FFFF` | 0 | 21 | negative turn hue |
| hsl | offset | `color: hsl(0 0% 0%);` | - | `0x000000` | 7 | 19 | match offsets |
| hsl | unbalanced | `hsl(0, 100%, 50%` | - | - | - | - | unbalanced parentheses |
| hsl | modern_alpha_no_slash | `hsl(0 100% 50% 0.5)` | - | - | - | - | alpha needs slash |
| hsl | mixed_separators | `hsl(0, 100%, 50% / 0.5)` | - | - | - | - | legacy/modern mix |
| hsl | legacy_none | `hsl(0, none, 50%)` | - | - | - | - | none unsupported in legacy |
| hsl | bad_unit | `hsl(0degx 100% 50%)` | - | - | - | - | unknown hue unit |
| hsl | missing_percent | `hsl(0 100 50%)` | - | - | - | - | percentage required |
| hsl | bad_alpha_separator | `hsl(0 100% 50%, 0.5)` | - | - | - | - | comma in modern syntax |
| hsl | bad_hue | `hsl(abc 100% 50%)` | - | - | - | - | non-numeric hue |
| hsl | empty_alpha_hsl | `hsl(0 100% 50% /)` | - | - | - | - | alpha value required |
| hsl | extra_alpha_token | `hsl(0 100% 50% / 50% 0)` | - | - | - | - | too many alpha tokens |
| hsl | mixed_legacy_alpha | `hsl(0,100%,50% / 0.5)` | - | - | - | - | legacy commas cannot mix with slash alpha |
| hsl | stray_percent | `hsl(0 100% 50)%` | - | - | - | - | malformed closing syntax |
| hsl | bad_alpha_value | `hsl(0 100% 50% / abc)` | - | - | - | - | non-numeric alpha |
| hsl | css_comment | `hsl(0 /*x*/ 100% 50%)` | - | - | - | - | CSS comments unsupported |
| hsl | calc | `hsl(calc(1 + 1) 100% 50%)` | - | - | - | - | calc() unsupported |
| hsl | nested_var | `hsl(var(--x) 100% 50%)` | - | - | - | - | var() unsupported |
| hsl | nested_hsl | `hsl(hsl(0 100% 50%) 100% 50%)` | - | - | - | - | nested functions unsupported |

## hsl_bare parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| hsl_bare | basic | `--primary: 240 100% 50%;` | - | `0x0000FF` | 11 | 23 | blue |
| hsl_bare | decimal | `--secondary: 0 84.2% 60.2%;` | - | `0xEF4444` | 13 | 26 | decimal channels |
| hsl_bare | negative | `--accent: -120 50% 40%;` | - | `0x333399` | 10 | 22 | negative hue |
| hsl_bare | numeric_alpha | `--transparent: 240 100% 50% / 0.5;` | - | `0x1800000FF` | 15 | 33 | numeric alpha |
| hsl_bare | percent_alpha | `--overlay: 240 100% 50% / 50%;` | - | `0x1800000FF` | 11 | 29 | percentage alpha |
| hsl_bare | deg | `--deg: 120deg 100% 50%;` | - | `0x00FF00` | 7 | 22 | deg hue |
| hsl_bare | grad | `--grad: 200grad 100% 50%;` | - | `0x00FFFF` | 8 | 24 | grad hue |
| hsl_bare | turn | `--turn: .5turn 100% 50%;` | - | `0x00FFFF` | 8 | 23 | turn hue |
| hsl_bare | rad | `--rad: 3.14159rad 100% 50%;` | - | `0x00FFFF` | 7 | 26 | radian hue |
| hsl_bare | no_terminator | `--x: 0 0% 100%` | - | `0xFFFFFF` | 5 | 14 | trailing semicolon optional |
| hsl_bare | trailing_space | `--x: 0 0% 0%   ;` | - | `0x000000` | 5 | 12 | trailing space excluded |
| hsl_bare | alpha_zero | `--alpha-zero: 0 0% 100% / 0;` | - | `0x100FFFFFF` | 14 | 27 | transparent white |
| hsl_bare | alpha_one | `--alpha-one: 0 0% 100% / 1;` | - | `0xFFFFFF` | 13 | 26 | opaque white |
| hsl_bare | hue_720 | `--hue-720: 720 100% 50%;` | - | `0xFF0000` | 11 | 23 | hue wraps twice |
| hsl_bare | uppercase_unit | `--upper: 120DEG 100% 50%;` | - | `0x00FF00` | 9 | 24 | case-insensitive hue unit |
| hsl_bare | clamped | `--clamped: 0 150% -10%;` | - | `0x000000` | 11 | 22 | channels clamped |
| hsl_bare | embedded_offset | `body { --x: 0 0% 100%; }` | - | `0xFFFFFF` | 12 | 21 | value-only highlight |
| hsl_bare | commas | `--x: 0, 100%, 50%;` | - | - | - | - | commas unsupported |
| hsl_bare | none | `--x: 240 100% 50% / none;` | - | - | - | - | none unsupported |
| hsl_bare | missing_percent | `--x: 0 100 50%;` | - | - | - | - | percentage required |
| hsl_bare | bad_hue | `--x: abc 100% 50%;` | - | - | - | - | non-numeric hue |
| hsl_bare | empty_value | `--x: ;` | - | - | - | - | empty value |
| hsl_bare | bad_alpha | `--x: 0 100% 50% / abc;` | - | - | - | - | non-numeric alpha |
| hsl_bare | scientific | `--x: 1e2 0% 100%;` | - | - | - | - | scientific notation unsupported |
| hsl_bare | alpha_without_slash | `--x: 0 100% 50% 0.5;` | - | - | - | - | alpha needs slash |
| hsl_bare | calc | `--x: calc(0 + 1) 100% 50%;` | - | - | - | - | calc() unsupported |
| hsl_bare | nested_var | `--x: var(--y) 100% 50%;` | - | - | - | - | var() unsupported |
| hsl_bare | css_comment | `--x: 0 /*x*/ 100% 50%;` | - | - | - | - | CSS comments unsupported |

## css_named parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| css_named | palette_lightsalmon | `lightsalmon` | - | `0xFFA07A` | 0 | 11 | CSS palette |
| css_named | palette_salmon | `salmon` | - | `0xFA8072` | 0 | 6 | CSS palette |
| css_named | palette_darksalmon | `darksalmon` | - | `0xE9967A` | 0 | 10 | CSS palette |
| css_named | palette_lightcoral | `lightcoral` | - | `0xF08080` | 0 | 10 | CSS palette |
| css_named | palette_indianred | `indianred` | - | `0xCD5C5C` | 0 | 9 | CSS palette |
| css_named | palette_crimson | `crimson` | - | `0xDC143C` | 0 | 7 | CSS palette |
| css_named | palette_firebrick | `firebrick` | - | `0xB22222` | 0 | 9 | CSS palette |
| css_named | palette_red | `red` | - | `0xFF0000` | 0 | 3 | CSS palette |
| css_named | palette_darkred | `darkred` | - | `0x8B0000` | 0 | 7 | CSS palette |
| css_named | palette_coral | `coral` | - | `0xFF7F50` | 0 | 5 | CSS palette |
| css_named | palette_tomato | `tomato` | - | `0xFF6347` | 0 | 6 | CSS palette |
| css_named | palette_orangered | `orangered` | - | `0xFF4500` | 0 | 9 | CSS palette |
| css_named | palette_gold | `gold` | - | `0xFFD700` | 0 | 4 | CSS palette |
| css_named | palette_orange | `orange` | - | `0xFFA500` | 0 | 6 | CSS palette |
| css_named | palette_darkorange | `darkorange` | - | `0xFF8C00` | 0 | 10 | CSS palette |
| css_named | palette_lightyellow | `lightyellow` | - | `0xFFFFE0` | 0 | 11 | CSS palette |
| css_named | palette_lemonchiffon | `lemonchiffon` | - | `0xFFFACD` | 0 | 12 | CSS palette |
| css_named | palette_lightgoldenrodyellow | `lightgoldenrodyellow` | - | `0xFAFAD2` | 0 | 20 | CSS palette |
| css_named | palette_papayawhip | `papayawhip` | - | `0xFFEFD5` | 0 | 10 | CSS palette |
| css_named | palette_moccasin | `moccasin` | - | `0xFFE4B5` | 0 | 8 | CSS palette |
| css_named | palette_peachpuff | `peachpuff` | - | `0xFFDAB9` | 0 | 9 | CSS palette |
| css_named | palette_palegoldenrod | `palegoldenrod` | - | `0xEEE8AA` | 0 | 13 | CSS palette |
| css_named | palette_khaki | `khaki` | - | `0xF0E68C` | 0 | 5 | CSS palette |
| css_named | palette_darkkhaki | `darkkhaki` | - | `0xBDB76B` | 0 | 9 | CSS palette |
| css_named | palette_yellow | `yellow` | - | `0xFFFF00` | 0 | 6 | CSS palette |
| css_named | palette_lawngreen | `lawngreen` | - | `0x7CFC00` | 0 | 9 | CSS palette |
| css_named | palette_chartreuse | `chartreuse` | - | `0x7FFF00` | 0 | 10 | CSS palette |
| css_named | palette_limegreen | `limegreen` | - | `0x32CD32` | 0 | 9 | CSS palette |
| css_named | palette_lime | `lime` | - | `0x00FF00` | 0 | 4 | CSS palette |
| css_named | palette_forestgreen | `forestgreen` | - | `0x228B22` | 0 | 11 | CSS palette |
| css_named | palette_green | `green` | - | `0x008000` | 0 | 5 | CSS palette |
| css_named | palette_darkgreen | `darkgreen` | - | `0x006400` | 0 | 9 | CSS palette |
| css_named | palette_greenyellow | `greenyellow` | - | `0xADFF2F` | 0 | 11 | CSS palette |
| css_named | palette_yellowgreen | `yellowgreen` | - | `0x9ACD32` | 0 | 11 | CSS palette |
| css_named | palette_springgreen | `springgreen` | - | `0x00FF7F` | 0 | 11 | CSS palette |
| css_named | palette_mediumspringgreen | `mediumspringgreen` | - | `0x00FA9A` | 0 | 17 | CSS palette |
| css_named | palette_lightgreen | `lightgreen` | - | `0x90EE90` | 0 | 10 | CSS palette |
| css_named | palette_palegreen | `palegreen` | - | `0x98FB98` | 0 | 9 | CSS palette |
| css_named | palette_darkseagreen | `darkseagreen` | - | `0x8FBC8F` | 0 | 12 | CSS palette |
| css_named | palette_mediumseagreen | `mediumseagreen` | - | `0x3CB371` | 0 | 14 | CSS palette |
| css_named | palette_seagreen | `seagreen` | - | `0x2E8B57` | 0 | 8 | CSS palette |
| css_named | palette_olive | `olive` | - | `0x808000` | 0 | 5 | CSS palette |
| css_named | palette_darkolivegreen | `darkolivegreen` | - | `0x556B2F` | 0 | 14 | CSS palette |
| css_named | palette_olivedrab | `olivedrab` | - | `0x6B8E23` | 0 | 9 | CSS palette |
| css_named | palette_lightcyan | `lightcyan` | - | `0xE0FFFF` | 0 | 9 | CSS palette |
| css_named | palette_cyan | `cyan` | - | `0x00FFFF` | 0 | 4 | CSS palette |
| css_named | palette_aqua | `aqua` | - | `0x00FFFF` | 0 | 4 | CSS palette |
| css_named | palette_aquamarine | `aquamarine` | - | `0x7FFFD4` | 0 | 10 | CSS palette |
| css_named | palette_mediumaquamarine | `mediumaquamarine` | - | `0x66CDAA` | 0 | 16 | CSS palette |
| css_named | palette_paleturquoise | `paleturquoise` | - | `0xAFEEEE` | 0 | 13 | CSS palette |
| css_named | palette_turquoise | `turquoise` | - | `0x40E0D0` | 0 | 9 | CSS palette |
| css_named | palette_mediumturquoise | `mediumturquoise` | - | `0x48D1CC` | 0 | 15 | CSS palette |
| css_named | palette_darkturquoise | `darkturquoise` | - | `0x00CED1` | 0 | 13 | CSS palette |
| css_named | palette_lightseagreen | `lightseagreen` | - | `0x20B2AA` | 0 | 13 | CSS palette |
| css_named | palette_cadetblue | `cadetblue` | - | `0x5F9EA0` | 0 | 9 | CSS palette |
| css_named | palette_darkcyan | `darkcyan` | - | `0x008B8B` | 0 | 8 | CSS palette |
| css_named | palette_teal | `teal` | - | `0x008080` | 0 | 4 | CSS palette |
| css_named | palette_powderblue | `powderblue` | - | `0xB0E0E6` | 0 | 10 | CSS palette |
| css_named | palette_lightblue | `lightblue` | - | `0xADD8E6` | 0 | 9 | CSS palette |
| css_named | palette_lightskyblue | `lightskyblue` | - | `0x87CEFA` | 0 | 12 | CSS palette |
| css_named | palette_skyblue | `skyblue` | - | `0x87CEEB` | 0 | 7 | CSS palette |
| css_named | palette_deepskyblue | `deepskyblue` | - | `0x00BFFF` | 0 | 11 | CSS palette |
| css_named | palette_lightsteelblue | `lightsteelblue` | - | `0xB0C4DE` | 0 | 14 | CSS palette |
| css_named | palette_dodgerblue | `dodgerblue` | - | `0x1E90FF` | 0 | 10 | CSS palette |
| css_named | palette_cornflowerblue | `cornflowerblue` | - | `0x6495ED` | 0 | 14 | CSS palette |
| css_named | palette_steelblue | `steelblue` | - | `0x4682B4` | 0 | 9 | CSS palette |
| css_named | palette_royalblue | `royalblue` | - | `0x4169E1` | 0 | 9 | CSS palette |
| css_named | palette_blue | `blue` | - | `0x0000FF` | 0 | 4 | CSS palette |
| css_named | palette_mediumblue | `mediumblue` | - | `0x0000CD` | 0 | 10 | CSS palette |
| css_named | palette_darkblue | `darkblue` | - | `0x00008B` | 0 | 8 | CSS palette |
| css_named | palette_navy | `navy` | - | `0x000080` | 0 | 4 | CSS palette |
| css_named | palette_midnightblue | `midnightblue` | - | `0x191970` | 0 | 12 | CSS palette |
| css_named | palette_mediumslateblue | `mediumslateblue` | - | `0x7B68EE` | 0 | 15 | CSS palette |
| css_named | palette_slateblue | `slateblue` | - | `0x6A5ACD` | 0 | 9 | CSS palette |
| css_named | palette_darkslateblue | `darkslateblue` | - | `0x483D8B` | 0 | 13 | CSS palette |
| css_named | palette_lavender | `lavender` | - | `0xE6E6FA` | 0 | 8 | CSS palette |
| css_named | palette_thistle | `thistle` | - | `0xD8BFD8` | 0 | 7 | CSS palette |
| css_named | palette_plum | `plum` | - | `0xDDA0DD` | 0 | 4 | CSS palette |
| css_named | palette_violet | `violet` | - | `0xEE82EE` | 0 | 6 | CSS palette |
| css_named | palette_orchid | `orchid` | - | `0xDA70D6` | 0 | 6 | CSS palette |
| css_named | palette_fuchsia | `fuchsia` | - | `0xFF00FF` | 0 | 7 | CSS palette |
| css_named | palette_magenta | `magenta` | - | `0xFF00FF` | 0 | 7 | CSS palette |
| css_named | palette_mediumorchid | `mediumorchid` | - | `0xBA55D3` | 0 | 12 | CSS palette |
| css_named | palette_rebeccapurple | `rebeccapurple` | - | `0x663399` | 0 | 13 | CSS palette |
| css_named | palette_mediumpurple | `mediumpurple` | - | `0x9370DB` | 0 | 12 | CSS palette |
| css_named | palette_blueviolet | `blueviolet` | - | `0x8A2BE2` | 0 | 10 | CSS palette |
| css_named | palette_darkviolet | `darkviolet` | - | `0x9400D3` | 0 | 10 | CSS palette |
| css_named | palette_darkorchid | `darkorchid` | - | `0x9932CC` | 0 | 10 | CSS palette |
| css_named | palette_darkmagenta | `darkmagenta` | - | `0x8B008B` | 0 | 11 | CSS palette |
| css_named | palette_purple | `purple` | - | `0x800080` | 0 | 6 | CSS palette |
| css_named | palette_indigo | `indigo` | - | `0x4B0082` | 0 | 6 | CSS palette |
| css_named | palette_pink | `pink` | - | `0xFFC0CB` | 0 | 4 | CSS palette |
| css_named | palette_lightpink | `lightpink` | - | `0xFFB6C1` | 0 | 9 | CSS palette |
| css_named | palette_hotpink | `hotpink` | - | `0xFF69B4` | 0 | 7 | CSS palette |
| css_named | palette_deeppink | `deeppink` | - | `0xFF1493` | 0 | 8 | CSS palette |
| css_named | palette_palevioletred | `palevioletred` | - | `0xDB7093` | 0 | 13 | CSS palette |
| css_named | palette_mediumvioletred | `mediumvioletred` | - | `0xC71585` | 0 | 15 | CSS palette |
| css_named | palette_white | `white` | - | `0xFFFFFF` | 0 | 5 | CSS palette |
| css_named | palette_snow | `snow` | - | `0xFFFAFA` | 0 | 4 | CSS palette |
| css_named | palette_honeydew | `honeydew` | - | `0xF0FFF0` | 0 | 8 | CSS palette |
| css_named | palette_mintcream | `mintcream` | - | `0xF5FFFA` | 0 | 9 | CSS palette |
| css_named | palette_azure | `azure` | - | `0xF0FFFF` | 0 | 5 | CSS palette |
| css_named | palette_aliceblue | `aliceblue` | - | `0xF0F8FF` | 0 | 9 | CSS palette |
| css_named | palette_ghostwhite | `ghostwhite` | - | `0xF8F8FF` | 0 | 10 | CSS palette |
| css_named | palette_whitesmoke | `whitesmoke` | - | `0xF5F5F5` | 0 | 10 | CSS palette |
| css_named | palette_seashell | `seashell` | - | `0xFFF5EE` | 0 | 8 | CSS palette |
| css_named | palette_beige | `beige` | - | `0xF5F5DC` | 0 | 5 | CSS palette |
| css_named | palette_oldlace | `oldlace` | - | `0xFDF5E6` | 0 | 7 | CSS palette |
| css_named | palette_floralwhite | `floralwhite` | - | `0xFFFAF0` | 0 | 11 | CSS palette |
| css_named | palette_ivory | `ivory` | - | `0xFFFFF0` | 0 | 5 | CSS palette |
| css_named | palette_antiquewhite | `antiquewhite` | - | `0xFAEBD7` | 0 | 12 | CSS palette |
| css_named | palette_linen | `linen` | - | `0xFAF0E6` | 0 | 5 | CSS palette |
| css_named | palette_lavenderblush | `lavenderblush` | - | `0xFFF0F5` | 0 | 13 | CSS palette |
| css_named | palette_mistyrose | `mistyrose` | - | `0xFFE4E1` | 0 | 9 | CSS palette |
| css_named | palette_gainsboro | `gainsboro` | - | `0xDCDCDC` | 0 | 9 | CSS palette |
| css_named | palette_lightgray | `lightgray` | - | `0xD3D3D3` | 0 | 9 | CSS palette |
| css_named | palette_lightgrey | `lightgrey` | - | `0xD3D3D3` | 0 | 9 | CSS palette |
| css_named | palette_silver | `silver` | - | `0xC0C0C0` | 0 | 6 | CSS palette |
| css_named | palette_darkgray | `darkgray` | - | `0xA9A9A9` | 0 | 8 | CSS palette |
| css_named | palette_darkgrey | `darkgrey` | - | `0xA9A9A9` | 0 | 8 | CSS palette |
| css_named | palette_gray | `gray` | - | `0x808080` | 0 | 4 | CSS palette |
| css_named | palette_grey | `grey` | - | `0x808080` | 0 | 4 | CSS palette |
| css_named | palette_dimgray | `dimgray` | - | `0x696969` | 0 | 7 | CSS palette |
| css_named | palette_dimgrey | `dimgrey` | - | `0x696969` | 0 | 7 | CSS palette |
| css_named | palette_lightslategray | `lightslategray` | - | `0x778899` | 0 | 14 | CSS palette |
| css_named | palette_lightslategrey | `lightslategrey` | - | `0x778899` | 0 | 14 | CSS palette |
| css_named | palette_slategray | `slategray` | - | `0x708090` | 0 | 9 | CSS palette |
| css_named | palette_slategrey | `slategrey` | - | `0x708090` | 0 | 9 | CSS palette |
| css_named | palette_darkslategray | `darkslategray` | - | `0x2F4F4F` | 0 | 13 | CSS palette |
| css_named | palette_darkslategrey | `darkslategrey` | - | `0x2F4F4F` | 0 | 13 | CSS palette |
| css_named | palette_black | `black` | - | `0x000000` | 0 | 5 | CSS palette |
| css_named | palette_cornsilk | `cornsilk` | - | `0xFFF8DC` | 0 | 8 | CSS palette |
| css_named | palette_blanchedalmond | `blanchedalmond` | - | `0xFFEBCD` | 0 | 14 | CSS palette |
| css_named | palette_bisque | `bisque` | - | `0xFFE4C4` | 0 | 6 | CSS palette |
| css_named | palette_navajowhite | `navajowhite` | - | `0xFFDEAD` | 0 | 11 | CSS palette |
| css_named | palette_wheat | `wheat` | - | `0xF5DEB3` | 0 | 5 | CSS palette |
| css_named | palette_burlywood | `burlywood` | - | `0xDEB887` | 0 | 9 | CSS palette |
| css_named | palette_tan | `tan` | - | `0xD2B48C` | 0 | 3 | CSS palette |
| css_named | palette_rosybrown | `rosybrown` | - | `0xBC8F8F` | 0 | 9 | CSS palette |
| css_named | palette_sandybrown | `sandybrown` | - | `0xF4A460` | 0 | 10 | CSS palette |
| css_named | palette_goldenrod | `goldenrod` | - | `0xDAA520` | 0 | 9 | CSS palette |
| css_named | palette_peru | `peru` | - | `0xCD853F` | 0 | 4 | CSS palette |
| css_named | palette_chocolate | `chocolate` | - | `0xD2691E` | 0 | 9 | CSS palette |
| css_named | palette_saddlebrown | `saddlebrown` | - | `0x8B4513` | 0 | 11 | CSS palette |
| css_named | palette_sienna | `sienna` | - | `0xA0522D` | 0 | 6 | CSS palette |
| css_named | palette_brown | `brown` | - | `0xA52A2A` | 0 | 5 | CSS palette |
| css_named | palette_maroon | `maroon` | - | `0x800000` | 0 | 6 | CSS palette |
| css_named | uppercase | `RED` | - | `0xFF0000` | 0 | 3 | case-insensitive |
| css_named | mixed_case | `RebeccaPurple` | - | `0x663399` | 0 | 13 | case-insensitive |
| css_named | grey_alias | `GREY` | - | `0x808080` | 0 | 4 | grey alias |
| css_named | gray_alias | `GRAY` | - | `0x808080` | 0 | 4 | gray alias |
| css_named | aqua_alias | `AQUA` | - | `0x00FFFF` | 0 | 4 | aqua alias |
| css_named | cyan_alias | `CYAN` | - | `0x00FFFF` | 0 | 4 | cyan alias |
| css_named | fuchsia_alias | `FUCHSIA` | - | `0xFF00FF` | 0 | 7 | fuchsia alias |
| css_named | magenta_alias | `MAGENTA` | - | `0xFF00FF` | 0 | 7 | magenta alias |
| css_named | offset | `color: red;` | - | `0xFF0000` | 7 | 10 | word boundary offsets |
| css_named | unknown | `notacolor` | - | - | - | - | not a CSS name |
| css_named | inside_identifier | `myred` | - | - | - | - | leading frontier |
| css_named | hyphenated | `red-zzz` | - | - | - | - | trailing hyphen |
| css_named | underscore | `red_zzz` | - | - | - | - | trailing underscore |

## sgr ANSI colors

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | ansi_fg_0 | `\e[30m` | - | `fg=0x000000` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_1 | `\e[31m` | - | `fg=0xCD0000` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_2 | `\e[32m` | - | `fg=0x00CD00` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_3 | `\e[33m` | - | `fg=0xCDCD00` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_4 | `\e[34m` | - | `fg=0x0000EE` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_5 | `\e[35m` | - | `fg=0xCD00CD` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_6 | `\e[36m` | - | `fg=0x00CDCD` | 0 | 5 | basic ANSI |
| sgr | ansi_fg_7 | `\e[37m` | - | `fg=0xE5E5E5` | 0 | 5 | basic ANSI |
| sgr | bright_fg_0 | `\e[90m` | - | `fg=0x7F7F7F` | 0 | 5 | aixterm bright |
| sgr | bright_fg_1 | `\e[91m` | - | `fg=0xFF0000` | 0 | 5 | aixterm bright |
| sgr | bright_fg_2 | `\e[92m` | - | `fg=0x00FF00` | 0 | 5 | aixterm bright |
| sgr | bright_fg_3 | `\e[93m` | - | `fg=0xFFFF00` | 0 | 5 | aixterm bright |
| sgr | bright_fg_4 | `\e[94m` | - | `fg=0x5C5CFF` | 0 | 5 | aixterm bright |
| sgr | bright_fg_5 | `\e[95m` | - | `fg=0xFF00FF` | 0 | 5 | aixterm bright |
| sgr | bright_fg_6 | `\e[96m` | - | `fg=0x00FFFF` | 0 | 5 | aixterm bright |
| sgr | bright_fg_7 | `\e[97m` | - | `fg=0xFFFFFF` | 0 | 5 | aixterm bright |
| sgr | ansi_bg_0 | `\e[40m` | - | `bg=0x000000` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_1 | `\e[41m` | - | `bg=0xCD0000` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_2 | `\e[42m` | - | `bg=0x00CD00` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_3 | `\e[43m` | - | `bg=0xCDCD00` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_4 | `\e[44m` | - | `bg=0x0000EE` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_5 | `\e[45m` | - | `bg=0xCD00CD` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_6 | `\e[46m` | - | `bg=0x00CDCD` | 0 | 5 | basic ANSI |
| sgr | ansi_bg_7 | `\e[47m` | - | `bg=0xE5E5E5` | 0 | 5 | basic ANSI |
| sgr | bright_bg_0 | `\e[100m` | - | `bg=0x7F7F7F` | 0 | 6 | aixterm bright |
| sgr | bright_bg_1 | `\e[101m` | - | `bg=0xFF0000` | 0 | 6 | aixterm bright |
| sgr | bright_bg_2 | `\e[102m` | - | `bg=0x00FF00` | 0 | 6 | aixterm bright |
| sgr | bright_bg_3 | `\e[103m` | - | `bg=0xFFFF00` | 0 | 6 | aixterm bright |
| sgr | bright_bg_4 | `\e[104m` | - | `bg=0x5C5CFF` | 0 | 6 | aixterm bright |
| sgr | bright_bg_5 | `\e[105m` | - | `bg=0xFF00FF` | 0 | 6 | aixterm bright |
| sgr | bright_bg_6 | `\e[106m` | - | `bg=0x00FFFF` | 0 | 6 | aixterm bright |
| sgr | bright_bg_7 | `\e[107m` | - | `bg=0xFFFFFF` | 0 | 6 | aixterm bright |

## sgr resets and ordering

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | empty | `\e[m` | - | - | - | - | empty SGR equals reset |
| sgr | reset | `\e[0m` | - | - | - | - | default rendition |
| sgr | reset_fg | `\e[39m` | - | - | - | - | foreground reset |
| sgr | reset_bg | `\e[49m` | - | - | - | - | background reset |
| sgr | reset_sp | `\e[59m` | - | - | - | - | underline reset |
| sgr | attributes_only | `\e[1;2;3;4m` | - | - | - | - | no color attributes |
| sgr | reset_after_fg | `\e[31;0m` | - | - | - | - | reset clears earlier colors |
| sgr | reset_fg_after_fg | `\e[31;39m` | - | - | - | - | foreground reset only |
| sgr | reset_bg_after_bg | `\e[44;49m` | - | - | - | - | background reset only |
| sgr | reset_sp_after_sp | `\e[58;5;196;59m` | - | - | - | - | underline reset only |
| sgr | bold_before_fg | `\e[1;31m` | - | `fg=0xCD0000` | 0 | 7 | attribute before color |
| sgr | bold_after_fg | `\e[31;1m` | - | `fg=0xCD0000` | 0 | 7 | attribute after color |
| sgr | blink_before_bg | `\e[6;44m` | - | `bg=0x0000EE` | 0 | 7 | attribute before background |
| sgr | all_targets | `\e[31;44;58;5;196m` | - | `fg=0xCD0000,bg=0x0000EE,sp=0xFF0000` | 0 | 17 | three color targets |
| sgr | attrs_between | `\e[31;1;2;44m` | - | `fg=0xCD0000,bg=0x0000EE` | 0 | 12 | attributes between colors |
| sgr | three_targets_reordered | `\e[58;5;21;44;31m` | - | `fg=0xCD0000,bg=0x0000EE,sp=0x0000FF` | 0 | 16 | reverse target order |
| sgr | fg_reset_keeps_bg | `\e[31;44;39m` | - | `bg=0x0000EE` | 0 | 11 | foreground reset only |
| sgr | bg_reset_keeps_fg | `\e[31;44;49m` | - | `fg=0xCD0000` | 0 | 11 | background reset only |
| sgr | sp_reset_keeps_fg_bg | `\e[31;44;58;5;196;59m` | - | `fg=0xCD0000,bg=0x0000EE` | 0 | 20 | underline reset only |
| sgr | two_indexed | `\e[38;5;196;48;5;21m` | - | `fg=0xFF0000,bg=0x0000FF` | 0 | 19 | indexed fg then bg |
| sgr | two_indexed_reversed | `\e[48;5;21;38;5;196m` | - | `fg=0xFF0000,bg=0x0000FF` | 0 | 19 | indexed bg then fg |

## sgr xterm indexed

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | index_fg_000 | `\e[38;5;0m` | - | `fg=0x000000` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_001 | `\e[38;5;1m` | - | `fg=0xCD0000` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_002 | `\e[38;5;2m` | - | `fg=0x00CD00` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_003 | `\e[38;5;3m` | - | `fg=0xCDCD00` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_004 | `\e[38;5;4m` | - | `fg=0x0000EE` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_005 | `\e[38;5;5m` | - | `fg=0xCD00CD` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_006 | `\e[38;5;6m` | - | `fg=0x00CDCD` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_007 | `\e[38;5;7m` | - | `fg=0xE5E5E5` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_008 | `\e[38;5;8m` | - | `fg=0x7F7F7F` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_009 | `\e[38;5;9m` | - | `fg=0xFF0000` | 0 | 9 | xterm 256 foreground palette |
| sgr | index_fg_010 | `\e[38;5;10m` | - | `fg=0x00FF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_011 | `\e[38;5;11m` | - | `fg=0xFFFF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_012 | `\e[38;5;12m` | - | `fg=0x5C5CFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_013 | `\e[38;5;13m` | - | `fg=0xFF00FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_014 | `\e[38;5;14m` | - | `fg=0x00FFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_015 | `\e[38;5;15m` | - | `fg=0xFFFFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_016 | `\e[38;5;16m` | - | `fg=0x000000` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_017 | `\e[38;5;17m` | - | `fg=0x00005F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_018 | `\e[38;5;18m` | - | `fg=0x000087` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_019 | `\e[38;5;19m` | - | `fg=0x0000AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_020 | `\e[38;5;20m` | - | `fg=0x0000D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_021 | `\e[38;5;21m` | - | `fg=0x0000FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_022 | `\e[38;5;22m` | - | `fg=0x005F00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_023 | `\e[38;5;23m` | - | `fg=0x005F5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_024 | `\e[38;5;24m` | - | `fg=0x005F87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_025 | `\e[38;5;25m` | - | `fg=0x005FAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_026 | `\e[38;5;26m` | - | `fg=0x005FD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_027 | `\e[38;5;27m` | - | `fg=0x005FFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_028 | `\e[38;5;28m` | - | `fg=0x008700` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_029 | `\e[38;5;29m` | - | `fg=0x00875F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_030 | `\e[38;5;30m` | - | `fg=0x008787` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_031 | `\e[38;5;31m` | - | `fg=0x0087AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_032 | `\e[38;5;32m` | - | `fg=0x0087D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_033 | `\e[38;5;33m` | - | `fg=0x0087FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_034 | `\e[38;5;34m` | - | `fg=0x00AF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_035 | `\e[38;5;35m` | - | `fg=0x00AF5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_036 | `\e[38;5;36m` | - | `fg=0x00AF87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_037 | `\e[38;5;37m` | - | `fg=0x00AFAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_038 | `\e[38;5;38m` | - | `fg=0x00AFD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_039 | `\e[38;5;39m` | - | `fg=0x00AFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_040 | `\e[38;5;40m` | - | `fg=0x00D700` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_041 | `\e[38;5;41m` | - | `fg=0x00D75F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_042 | `\e[38;5;42m` | - | `fg=0x00D787` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_043 | `\e[38;5;43m` | - | `fg=0x00D7AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_044 | `\e[38;5;44m` | - | `fg=0x00D7D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_045 | `\e[38;5;45m` | - | `fg=0x00D7FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_046 | `\e[38;5;46m` | - | `fg=0x00FF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_047 | `\e[38;5;47m` | - | `fg=0x00FF5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_048 | `\e[38;5;48m` | - | `fg=0x00FF87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_049 | `\e[38;5;49m` | - | `fg=0x00FFAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_050 | `\e[38;5;50m` | - | `fg=0x00FFD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_051 | `\e[38;5;51m` | - | `fg=0x00FFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_052 | `\e[38;5;52m` | - | `fg=0x5F0000` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_053 | `\e[38;5;53m` | - | `fg=0x5F005F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_054 | `\e[38;5;54m` | - | `fg=0x5F0087` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_055 | `\e[38;5;55m` | - | `fg=0x5F00AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_056 | `\e[38;5;56m` | - | `fg=0x5F00D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_057 | `\e[38;5;57m` | - | `fg=0x5F00FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_058 | `\e[38;5;58m` | - | `fg=0x5F5F00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_059 | `\e[38;5;59m` | - | `fg=0x5F5F5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_060 | `\e[38;5;60m` | - | `fg=0x5F5F87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_061 | `\e[38;5;61m` | - | `fg=0x5F5FAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_062 | `\e[38;5;62m` | - | `fg=0x5F5FD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_063 | `\e[38;5;63m` | - | `fg=0x5F5FFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_064 | `\e[38;5;64m` | - | `fg=0x5F8700` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_065 | `\e[38;5;65m` | - | `fg=0x5F875F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_066 | `\e[38;5;66m` | - | `fg=0x5F8787` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_067 | `\e[38;5;67m` | - | `fg=0x5F87AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_068 | `\e[38;5;68m` | - | `fg=0x5F87D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_069 | `\e[38;5;69m` | - | `fg=0x5F87FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_070 | `\e[38;5;70m` | - | `fg=0x5FAF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_071 | `\e[38;5;71m` | - | `fg=0x5FAF5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_072 | `\e[38;5;72m` | - | `fg=0x5FAF87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_073 | `\e[38;5;73m` | - | `fg=0x5FAFAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_074 | `\e[38;5;74m` | - | `fg=0x5FAFD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_075 | `\e[38;5;75m` | - | `fg=0x5FAFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_076 | `\e[38;5;76m` | - | `fg=0x5FD700` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_077 | `\e[38;5;77m` | - | `fg=0x5FD75F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_078 | `\e[38;5;78m` | - | `fg=0x5FD787` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_079 | `\e[38;5;79m` | - | `fg=0x5FD7AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_080 | `\e[38;5;80m` | - | `fg=0x5FD7D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_081 | `\e[38;5;81m` | - | `fg=0x5FD7FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_082 | `\e[38;5;82m` | - | `fg=0x5FFF00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_083 | `\e[38;5;83m` | - | `fg=0x5FFF5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_084 | `\e[38;5;84m` | - | `fg=0x5FFF87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_085 | `\e[38;5;85m` | - | `fg=0x5FFFAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_086 | `\e[38;5;86m` | - | `fg=0x5FFFD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_087 | `\e[38;5;87m` | - | `fg=0x5FFFFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_088 | `\e[38;5;88m` | - | `fg=0x870000` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_089 | `\e[38;5;89m` | - | `fg=0x87005F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_090 | `\e[38;5;90m` | - | `fg=0x870087` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_091 | `\e[38;5;91m` | - | `fg=0x8700AF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_092 | `\e[38;5;92m` | - | `fg=0x8700D7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_093 | `\e[38;5;93m` | - | `fg=0x8700FF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_094 | `\e[38;5;94m` | - | `fg=0x875F00` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_095 | `\e[38;5;95m` | - | `fg=0x875F5F` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_096 | `\e[38;5;96m` | - | `fg=0x875F87` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_097 | `\e[38;5;97m` | - | `fg=0x875FAF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_098 | `\e[38;5;98m` | - | `fg=0x875FD7` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_099 | `\e[38;5;99m` | - | `fg=0x875FFF` | 0 | 10 | xterm 256 foreground palette |
| sgr | index_fg_100 | `\e[38;5;100m` | - | `fg=0x878700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_101 | `\e[38;5;101m` | - | `fg=0x87875F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_102 | `\e[38;5;102m` | - | `fg=0x878787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_103 | `\e[38;5;103m` | - | `fg=0x8787AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_104 | `\e[38;5;104m` | - | `fg=0x8787D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_105 | `\e[38;5;105m` | - | `fg=0x8787FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_106 | `\e[38;5;106m` | - | `fg=0x87AF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_107 | `\e[38;5;107m` | - | `fg=0x87AF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_108 | `\e[38;5;108m` | - | `fg=0x87AF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_109 | `\e[38;5;109m` | - | `fg=0x87AFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_110 | `\e[38;5;110m` | - | `fg=0x87AFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_111 | `\e[38;5;111m` | - | `fg=0x87AFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_112 | `\e[38;5;112m` | - | `fg=0x87D700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_113 | `\e[38;5;113m` | - | `fg=0x87D75F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_114 | `\e[38;5;114m` | - | `fg=0x87D787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_115 | `\e[38;5;115m` | - | `fg=0x87D7AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_116 | `\e[38;5;116m` | - | `fg=0x87D7D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_117 | `\e[38;5;117m` | - | `fg=0x87D7FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_118 | `\e[38;5;118m` | - | `fg=0x87FF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_119 | `\e[38;5;119m` | - | `fg=0x87FF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_120 | `\e[38;5;120m` | - | `fg=0x87FF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_121 | `\e[38;5;121m` | - | `fg=0x87FFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_122 | `\e[38;5;122m` | - | `fg=0x87FFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_123 | `\e[38;5;123m` | - | `fg=0x87FFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_124 | `\e[38;5;124m` | - | `fg=0xAF0000` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_125 | `\e[38;5;125m` | - | `fg=0xAF005F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_126 | `\e[38;5;126m` | - | `fg=0xAF0087` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_127 | `\e[38;5;127m` | - | `fg=0xAF00AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_128 | `\e[38;5;128m` | - | `fg=0xAF00D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_129 | `\e[38;5;129m` | - | `fg=0xAF00FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_130 | `\e[38;5;130m` | - | `fg=0xAF5F00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_131 | `\e[38;5;131m` | - | `fg=0xAF5F5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_132 | `\e[38;5;132m` | - | `fg=0xAF5F87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_133 | `\e[38;5;133m` | - | `fg=0xAF5FAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_134 | `\e[38;5;134m` | - | `fg=0xAF5FD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_135 | `\e[38;5;135m` | - | `fg=0xAF5FFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_136 | `\e[38;5;136m` | - | `fg=0xAF8700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_137 | `\e[38;5;137m` | - | `fg=0xAF875F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_138 | `\e[38;5;138m` | - | `fg=0xAF8787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_139 | `\e[38;5;139m` | - | `fg=0xAF87AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_140 | `\e[38;5;140m` | - | `fg=0xAF87D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_141 | `\e[38;5;141m` | - | `fg=0xAF87FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_142 | `\e[38;5;142m` | - | `fg=0xAFAF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_143 | `\e[38;5;143m` | - | `fg=0xAFAF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_144 | `\e[38;5;144m` | - | `fg=0xAFAF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_145 | `\e[38;5;145m` | - | `fg=0xAFAFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_146 | `\e[38;5;146m` | - | `fg=0xAFAFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_147 | `\e[38;5;147m` | - | `fg=0xAFAFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_148 | `\e[38;5;148m` | - | `fg=0xAFD700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_149 | `\e[38;5;149m` | - | `fg=0xAFD75F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_150 | `\e[38;5;150m` | - | `fg=0xAFD787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_151 | `\e[38;5;151m` | - | `fg=0xAFD7AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_152 | `\e[38;5;152m` | - | `fg=0xAFD7D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_153 | `\e[38;5;153m` | - | `fg=0xAFD7FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_154 | `\e[38;5;154m` | - | `fg=0xAFFF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_155 | `\e[38;5;155m` | - | `fg=0xAFFF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_156 | `\e[38;5;156m` | - | `fg=0xAFFF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_157 | `\e[38;5;157m` | - | `fg=0xAFFFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_158 | `\e[38;5;158m` | - | `fg=0xAFFFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_159 | `\e[38;5;159m` | - | `fg=0xAFFFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_160 | `\e[38;5;160m` | - | `fg=0xD70000` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_161 | `\e[38;5;161m` | - | `fg=0xD7005F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_162 | `\e[38;5;162m` | - | `fg=0xD70087` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_163 | `\e[38;5;163m` | - | `fg=0xD700AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_164 | `\e[38;5;164m` | - | `fg=0xD700D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_165 | `\e[38;5;165m` | - | `fg=0xD700FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_166 | `\e[38;5;166m` | - | `fg=0xD75F00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_167 | `\e[38;5;167m` | - | `fg=0xD75F5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_168 | `\e[38;5;168m` | - | `fg=0xD75F87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_169 | `\e[38;5;169m` | - | `fg=0xD75FAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_170 | `\e[38;5;170m` | - | `fg=0xD75FD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_171 | `\e[38;5;171m` | - | `fg=0xD75FFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_172 | `\e[38;5;172m` | - | `fg=0xD78700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_173 | `\e[38;5;173m` | - | `fg=0xD7875F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_174 | `\e[38;5;174m` | - | `fg=0xD78787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_175 | `\e[38;5;175m` | - | `fg=0xD787AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_176 | `\e[38;5;176m` | - | `fg=0xD787D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_177 | `\e[38;5;177m` | - | `fg=0xD787FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_178 | `\e[38;5;178m` | - | `fg=0xD7AF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_179 | `\e[38;5;179m` | - | `fg=0xD7AF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_180 | `\e[38;5;180m` | - | `fg=0xD7AF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_181 | `\e[38;5;181m` | - | `fg=0xD7AFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_182 | `\e[38;5;182m` | - | `fg=0xD7AFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_183 | `\e[38;5;183m` | - | `fg=0xD7AFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_184 | `\e[38;5;184m` | - | `fg=0xD7D700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_185 | `\e[38;5;185m` | - | `fg=0xD7D75F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_186 | `\e[38;5;186m` | - | `fg=0xD7D787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_187 | `\e[38;5;187m` | - | `fg=0xD7D7AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_188 | `\e[38;5;188m` | - | `fg=0xD7D7D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_189 | `\e[38;5;189m` | - | `fg=0xD7D7FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_190 | `\e[38;5;190m` | - | `fg=0xD7FF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_191 | `\e[38;5;191m` | - | `fg=0xD7FF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_192 | `\e[38;5;192m` | - | `fg=0xD7FF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_193 | `\e[38;5;193m` | - | `fg=0xD7FFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_194 | `\e[38;5;194m` | - | `fg=0xD7FFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_195 | `\e[38;5;195m` | - | `fg=0xD7FFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_196 | `\e[38;5;196m` | - | `fg=0xFF0000` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_197 | `\e[38;5;197m` | - | `fg=0xFF005F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_198 | `\e[38;5;198m` | - | `fg=0xFF0087` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_199 | `\e[38;5;199m` | - | `fg=0xFF00AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_200 | `\e[38;5;200m` | - | `fg=0xFF00D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_201 | `\e[38;5;201m` | - | `fg=0xFF00FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_202 | `\e[38;5;202m` | - | `fg=0xFF5F00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_203 | `\e[38;5;203m` | - | `fg=0xFF5F5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_204 | `\e[38;5;204m` | - | `fg=0xFF5F87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_205 | `\e[38;5;205m` | - | `fg=0xFF5FAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_206 | `\e[38;5;206m` | - | `fg=0xFF5FD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_207 | `\e[38;5;207m` | - | `fg=0xFF5FFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_208 | `\e[38;5;208m` | - | `fg=0xFF8700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_209 | `\e[38;5;209m` | - | `fg=0xFF875F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_210 | `\e[38;5;210m` | - | `fg=0xFF8787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_211 | `\e[38;5;211m` | - | `fg=0xFF87AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_212 | `\e[38;5;212m` | - | `fg=0xFF87D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_213 | `\e[38;5;213m` | - | `fg=0xFF87FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_214 | `\e[38;5;214m` | - | `fg=0xFFAF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_215 | `\e[38;5;215m` | - | `fg=0xFFAF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_216 | `\e[38;5;216m` | - | `fg=0xFFAF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_217 | `\e[38;5;217m` | - | `fg=0xFFAFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_218 | `\e[38;5;218m` | - | `fg=0xFFAFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_219 | `\e[38;5;219m` | - | `fg=0xFFAFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_220 | `\e[38;5;220m` | - | `fg=0xFFD700` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_221 | `\e[38;5;221m` | - | `fg=0xFFD75F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_222 | `\e[38;5;222m` | - | `fg=0xFFD787` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_223 | `\e[38;5;223m` | - | `fg=0xFFD7AF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_224 | `\e[38;5;224m` | - | `fg=0xFFD7D7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_225 | `\e[38;5;225m` | - | `fg=0xFFD7FF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_226 | `\e[38;5;226m` | - | `fg=0xFFFF00` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_227 | `\e[38;5;227m` | - | `fg=0xFFFF5F` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_228 | `\e[38;5;228m` | - | `fg=0xFFFF87` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_229 | `\e[38;5;229m` | - | `fg=0xFFFFAF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_230 | `\e[38;5;230m` | - | `fg=0xFFFFD7` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_231 | `\e[38;5;231m` | - | `fg=0xFFFFFF` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_232 | `\e[38;5;232m` | - | `fg=0x080808` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_233 | `\e[38;5;233m` | - | `fg=0x121212` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_234 | `\e[38;5;234m` | - | `fg=0x1C1C1C` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_235 | `\e[38;5;235m` | - | `fg=0x262626` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_236 | `\e[38;5;236m` | - | `fg=0x303030` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_237 | `\e[38;5;237m` | - | `fg=0x3A3A3A` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_238 | `\e[38;5;238m` | - | `fg=0x444444` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_239 | `\e[38;5;239m` | - | `fg=0x4E4E4E` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_240 | `\e[38;5;240m` | - | `fg=0x585858` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_241 | `\e[38;5;241m` | - | `fg=0x626262` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_242 | `\e[38;5;242m` | - | `fg=0x6C6C6C` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_243 | `\e[38;5;243m` | - | `fg=0x767676` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_244 | `\e[38;5;244m` | - | `fg=0x808080` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_245 | `\e[38;5;245m` | - | `fg=0x8A8A8A` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_246 | `\e[38;5;246m` | - | `fg=0x949494` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_247 | `\e[38;5;247m` | - | `fg=0x9E9E9E` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_248 | `\e[38;5;248m` | - | `fg=0xA8A8A8` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_249 | `\e[38;5;249m` | - | `fg=0xB2B2B2` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_250 | `\e[38;5;250m` | - | `fg=0xBCBCBC` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_251 | `\e[38;5;251m` | - | `fg=0xC6C6C6` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_252 | `\e[38;5;252m` | - | `fg=0xD0D0D0` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_253 | `\e[38;5;253m` | - | `fg=0xDADADA` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_254 | `\e[38;5;254m` | - | `fg=0xE4E4E4` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_fg_255 | `\e[38;5;255m` | - | `fg=0xEEEEEE` | 0 | 11 | xterm 256 foreground palette |
| sgr | index_bg_000 | `\e[48;5;0m` | - | `bg=0x000000` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_001 | `\e[48;5;1m` | - | `bg=0xCD0000` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_002 | `\e[48;5;2m` | - | `bg=0x00CD00` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_003 | `\e[48;5;3m` | - | `bg=0xCDCD00` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_004 | `\e[48;5;4m` | - | `bg=0x0000EE` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_005 | `\e[48;5;5m` | - | `bg=0xCD00CD` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_006 | `\e[48;5;6m` | - | `bg=0x00CDCD` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_007 | `\e[48;5;7m` | - | `bg=0xE5E5E5` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_008 | `\e[48;5;8m` | - | `bg=0x7F7F7F` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_009 | `\e[48;5;9m` | - | `bg=0xFF0000` | 0 | 9 | xterm 256 background palette |
| sgr | index_bg_010 | `\e[48;5;10m` | - | `bg=0x00FF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_011 | `\e[48;5;11m` | - | `bg=0xFFFF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_012 | `\e[48;5;12m` | - | `bg=0x5C5CFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_013 | `\e[48;5;13m` | - | `bg=0xFF00FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_014 | `\e[48;5;14m` | - | `bg=0x00FFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_015 | `\e[48;5;15m` | - | `bg=0xFFFFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_016 | `\e[48;5;16m` | - | `bg=0x000000` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_017 | `\e[48;5;17m` | - | `bg=0x00005F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_018 | `\e[48;5;18m` | - | `bg=0x000087` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_019 | `\e[48;5;19m` | - | `bg=0x0000AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_020 | `\e[48;5;20m` | - | `bg=0x0000D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_021 | `\e[48;5;21m` | - | `bg=0x0000FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_022 | `\e[48;5;22m` | - | `bg=0x005F00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_023 | `\e[48;5;23m` | - | `bg=0x005F5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_024 | `\e[48;5;24m` | - | `bg=0x005F87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_025 | `\e[48;5;25m` | - | `bg=0x005FAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_026 | `\e[48;5;26m` | - | `bg=0x005FD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_027 | `\e[48;5;27m` | - | `bg=0x005FFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_028 | `\e[48;5;28m` | - | `bg=0x008700` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_029 | `\e[48;5;29m` | - | `bg=0x00875F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_030 | `\e[48;5;30m` | - | `bg=0x008787` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_031 | `\e[48;5;31m` | - | `bg=0x0087AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_032 | `\e[48;5;32m` | - | `bg=0x0087D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_033 | `\e[48;5;33m` | - | `bg=0x0087FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_034 | `\e[48;5;34m` | - | `bg=0x00AF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_035 | `\e[48;5;35m` | - | `bg=0x00AF5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_036 | `\e[48;5;36m` | - | `bg=0x00AF87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_037 | `\e[48;5;37m` | - | `bg=0x00AFAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_038 | `\e[48;5;38m` | - | `bg=0x00AFD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_039 | `\e[48;5;39m` | - | `bg=0x00AFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_040 | `\e[48;5;40m` | - | `bg=0x00D700` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_041 | `\e[48;5;41m` | - | `bg=0x00D75F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_042 | `\e[48;5;42m` | - | `bg=0x00D787` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_043 | `\e[48;5;43m` | - | `bg=0x00D7AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_044 | `\e[48;5;44m` | - | `bg=0x00D7D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_045 | `\e[48;5;45m` | - | `bg=0x00D7FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_046 | `\e[48;5;46m` | - | `bg=0x00FF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_047 | `\e[48;5;47m` | - | `bg=0x00FF5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_048 | `\e[48;5;48m` | - | `bg=0x00FF87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_049 | `\e[48;5;49m` | - | `bg=0x00FFAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_050 | `\e[48;5;50m` | - | `bg=0x00FFD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_051 | `\e[48;5;51m` | - | `bg=0x00FFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_052 | `\e[48;5;52m` | - | `bg=0x5F0000` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_053 | `\e[48;5;53m` | - | `bg=0x5F005F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_054 | `\e[48;5;54m` | - | `bg=0x5F0087` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_055 | `\e[48;5;55m` | - | `bg=0x5F00AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_056 | `\e[48;5;56m` | - | `bg=0x5F00D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_057 | `\e[48;5;57m` | - | `bg=0x5F00FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_058 | `\e[48;5;58m` | - | `bg=0x5F5F00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_059 | `\e[48;5;59m` | - | `bg=0x5F5F5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_060 | `\e[48;5;60m` | - | `bg=0x5F5F87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_061 | `\e[48;5;61m` | - | `bg=0x5F5FAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_062 | `\e[48;5;62m` | - | `bg=0x5F5FD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_063 | `\e[48;5;63m` | - | `bg=0x5F5FFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_064 | `\e[48;5;64m` | - | `bg=0x5F8700` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_065 | `\e[48;5;65m` | - | `bg=0x5F875F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_066 | `\e[48;5;66m` | - | `bg=0x5F8787` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_067 | `\e[48;5;67m` | - | `bg=0x5F87AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_068 | `\e[48;5;68m` | - | `bg=0x5F87D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_069 | `\e[48;5;69m` | - | `bg=0x5F87FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_070 | `\e[48;5;70m` | - | `bg=0x5FAF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_071 | `\e[48;5;71m` | - | `bg=0x5FAF5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_072 | `\e[48;5;72m` | - | `bg=0x5FAF87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_073 | `\e[48;5;73m` | - | `bg=0x5FAFAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_074 | `\e[48;5;74m` | - | `bg=0x5FAFD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_075 | `\e[48;5;75m` | - | `bg=0x5FAFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_076 | `\e[48;5;76m` | - | `bg=0x5FD700` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_077 | `\e[48;5;77m` | - | `bg=0x5FD75F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_078 | `\e[48;5;78m` | - | `bg=0x5FD787` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_079 | `\e[48;5;79m` | - | `bg=0x5FD7AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_080 | `\e[48;5;80m` | - | `bg=0x5FD7D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_081 | `\e[48;5;81m` | - | `bg=0x5FD7FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_082 | `\e[48;5;82m` | - | `bg=0x5FFF00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_083 | `\e[48;5;83m` | - | `bg=0x5FFF5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_084 | `\e[48;5;84m` | - | `bg=0x5FFF87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_085 | `\e[48;5;85m` | - | `bg=0x5FFFAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_086 | `\e[48;5;86m` | - | `bg=0x5FFFD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_087 | `\e[48;5;87m` | - | `bg=0x5FFFFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_088 | `\e[48;5;88m` | - | `bg=0x870000` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_089 | `\e[48;5;89m` | - | `bg=0x87005F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_090 | `\e[48;5;90m` | - | `bg=0x870087` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_091 | `\e[48;5;91m` | - | `bg=0x8700AF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_092 | `\e[48;5;92m` | - | `bg=0x8700D7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_093 | `\e[48;5;93m` | - | `bg=0x8700FF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_094 | `\e[48;5;94m` | - | `bg=0x875F00` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_095 | `\e[48;5;95m` | - | `bg=0x875F5F` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_096 | `\e[48;5;96m` | - | `bg=0x875F87` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_097 | `\e[48;5;97m` | - | `bg=0x875FAF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_098 | `\e[48;5;98m` | - | `bg=0x875FD7` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_099 | `\e[48;5;99m` | - | `bg=0x875FFF` | 0 | 10 | xterm 256 background palette |
| sgr | index_bg_100 | `\e[48;5;100m` | - | `bg=0x878700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_101 | `\e[48;5;101m` | - | `bg=0x87875F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_102 | `\e[48;5;102m` | - | `bg=0x878787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_103 | `\e[48;5;103m` | - | `bg=0x8787AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_104 | `\e[48;5;104m` | - | `bg=0x8787D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_105 | `\e[48;5;105m` | - | `bg=0x8787FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_106 | `\e[48;5;106m` | - | `bg=0x87AF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_107 | `\e[48;5;107m` | - | `bg=0x87AF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_108 | `\e[48;5;108m` | - | `bg=0x87AF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_109 | `\e[48;5;109m` | - | `bg=0x87AFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_110 | `\e[48;5;110m` | - | `bg=0x87AFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_111 | `\e[48;5;111m` | - | `bg=0x87AFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_112 | `\e[48;5;112m` | - | `bg=0x87D700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_113 | `\e[48;5;113m` | - | `bg=0x87D75F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_114 | `\e[48;5;114m` | - | `bg=0x87D787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_115 | `\e[48;5;115m` | - | `bg=0x87D7AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_116 | `\e[48;5;116m` | - | `bg=0x87D7D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_117 | `\e[48;5;117m` | - | `bg=0x87D7FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_118 | `\e[48;5;118m` | - | `bg=0x87FF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_119 | `\e[48;5;119m` | - | `bg=0x87FF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_120 | `\e[48;5;120m` | - | `bg=0x87FF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_121 | `\e[48;5;121m` | - | `bg=0x87FFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_122 | `\e[48;5;122m` | - | `bg=0x87FFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_123 | `\e[48;5;123m` | - | `bg=0x87FFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_124 | `\e[48;5;124m` | - | `bg=0xAF0000` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_125 | `\e[48;5;125m` | - | `bg=0xAF005F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_126 | `\e[48;5;126m` | - | `bg=0xAF0087` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_127 | `\e[48;5;127m` | - | `bg=0xAF00AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_128 | `\e[48;5;128m` | - | `bg=0xAF00D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_129 | `\e[48;5;129m` | - | `bg=0xAF00FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_130 | `\e[48;5;130m` | - | `bg=0xAF5F00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_131 | `\e[48;5;131m` | - | `bg=0xAF5F5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_132 | `\e[48;5;132m` | - | `bg=0xAF5F87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_133 | `\e[48;5;133m` | - | `bg=0xAF5FAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_134 | `\e[48;5;134m` | - | `bg=0xAF5FD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_135 | `\e[48;5;135m` | - | `bg=0xAF5FFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_136 | `\e[48;5;136m` | - | `bg=0xAF8700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_137 | `\e[48;5;137m` | - | `bg=0xAF875F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_138 | `\e[48;5;138m` | - | `bg=0xAF8787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_139 | `\e[48;5;139m` | - | `bg=0xAF87AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_140 | `\e[48;5;140m` | - | `bg=0xAF87D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_141 | `\e[48;5;141m` | - | `bg=0xAF87FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_142 | `\e[48;5;142m` | - | `bg=0xAFAF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_143 | `\e[48;5;143m` | - | `bg=0xAFAF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_144 | `\e[48;5;144m` | - | `bg=0xAFAF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_145 | `\e[48;5;145m` | - | `bg=0xAFAFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_146 | `\e[48;5;146m` | - | `bg=0xAFAFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_147 | `\e[48;5;147m` | - | `bg=0xAFAFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_148 | `\e[48;5;148m` | - | `bg=0xAFD700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_149 | `\e[48;5;149m` | - | `bg=0xAFD75F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_150 | `\e[48;5;150m` | - | `bg=0xAFD787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_151 | `\e[48;5;151m` | - | `bg=0xAFD7AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_152 | `\e[48;5;152m` | - | `bg=0xAFD7D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_153 | `\e[48;5;153m` | - | `bg=0xAFD7FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_154 | `\e[48;5;154m` | - | `bg=0xAFFF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_155 | `\e[48;5;155m` | - | `bg=0xAFFF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_156 | `\e[48;5;156m` | - | `bg=0xAFFF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_157 | `\e[48;5;157m` | - | `bg=0xAFFFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_158 | `\e[48;5;158m` | - | `bg=0xAFFFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_159 | `\e[48;5;159m` | - | `bg=0xAFFFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_160 | `\e[48;5;160m` | - | `bg=0xD70000` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_161 | `\e[48;5;161m` | - | `bg=0xD7005F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_162 | `\e[48;5;162m` | - | `bg=0xD70087` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_163 | `\e[48;5;163m` | - | `bg=0xD700AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_164 | `\e[48;5;164m` | - | `bg=0xD700D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_165 | `\e[48;5;165m` | - | `bg=0xD700FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_166 | `\e[48;5;166m` | - | `bg=0xD75F00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_167 | `\e[48;5;167m` | - | `bg=0xD75F5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_168 | `\e[48;5;168m` | - | `bg=0xD75F87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_169 | `\e[48;5;169m` | - | `bg=0xD75FAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_170 | `\e[48;5;170m` | - | `bg=0xD75FD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_171 | `\e[48;5;171m` | - | `bg=0xD75FFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_172 | `\e[48;5;172m` | - | `bg=0xD78700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_173 | `\e[48;5;173m` | - | `bg=0xD7875F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_174 | `\e[48;5;174m` | - | `bg=0xD78787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_175 | `\e[48;5;175m` | - | `bg=0xD787AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_176 | `\e[48;5;176m` | - | `bg=0xD787D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_177 | `\e[48;5;177m` | - | `bg=0xD787FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_178 | `\e[48;5;178m` | - | `bg=0xD7AF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_179 | `\e[48;5;179m` | - | `bg=0xD7AF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_180 | `\e[48;5;180m` | - | `bg=0xD7AF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_181 | `\e[48;5;181m` | - | `bg=0xD7AFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_182 | `\e[48;5;182m` | - | `bg=0xD7AFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_183 | `\e[48;5;183m` | - | `bg=0xD7AFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_184 | `\e[48;5;184m` | - | `bg=0xD7D700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_185 | `\e[48;5;185m` | - | `bg=0xD7D75F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_186 | `\e[48;5;186m` | - | `bg=0xD7D787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_187 | `\e[48;5;187m` | - | `bg=0xD7D7AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_188 | `\e[48;5;188m` | - | `bg=0xD7D7D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_189 | `\e[48;5;189m` | - | `bg=0xD7D7FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_190 | `\e[48;5;190m` | - | `bg=0xD7FF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_191 | `\e[48;5;191m` | - | `bg=0xD7FF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_192 | `\e[48;5;192m` | - | `bg=0xD7FF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_193 | `\e[48;5;193m` | - | `bg=0xD7FFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_194 | `\e[48;5;194m` | - | `bg=0xD7FFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_195 | `\e[48;5;195m` | - | `bg=0xD7FFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_196 | `\e[48;5;196m` | - | `bg=0xFF0000` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_197 | `\e[48;5;197m` | - | `bg=0xFF005F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_198 | `\e[48;5;198m` | - | `bg=0xFF0087` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_199 | `\e[48;5;199m` | - | `bg=0xFF00AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_200 | `\e[48;5;200m` | - | `bg=0xFF00D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_201 | `\e[48;5;201m` | - | `bg=0xFF00FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_202 | `\e[48;5;202m` | - | `bg=0xFF5F00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_203 | `\e[48;5;203m` | - | `bg=0xFF5F5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_204 | `\e[48;5;204m` | - | `bg=0xFF5F87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_205 | `\e[48;5;205m` | - | `bg=0xFF5FAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_206 | `\e[48;5;206m` | - | `bg=0xFF5FD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_207 | `\e[48;5;207m` | - | `bg=0xFF5FFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_208 | `\e[48;5;208m` | - | `bg=0xFF8700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_209 | `\e[48;5;209m` | - | `bg=0xFF875F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_210 | `\e[48;5;210m` | - | `bg=0xFF8787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_211 | `\e[48;5;211m` | - | `bg=0xFF87AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_212 | `\e[48;5;212m` | - | `bg=0xFF87D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_213 | `\e[48;5;213m` | - | `bg=0xFF87FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_214 | `\e[48;5;214m` | - | `bg=0xFFAF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_215 | `\e[48;5;215m` | - | `bg=0xFFAF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_216 | `\e[48;5;216m` | - | `bg=0xFFAF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_217 | `\e[48;5;217m` | - | `bg=0xFFAFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_218 | `\e[48;5;218m` | - | `bg=0xFFAFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_219 | `\e[48;5;219m` | - | `bg=0xFFAFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_220 | `\e[48;5;220m` | - | `bg=0xFFD700` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_221 | `\e[48;5;221m` | - | `bg=0xFFD75F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_222 | `\e[48;5;222m` | - | `bg=0xFFD787` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_223 | `\e[48;5;223m` | - | `bg=0xFFD7AF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_224 | `\e[48;5;224m` | - | `bg=0xFFD7D7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_225 | `\e[48;5;225m` | - | `bg=0xFFD7FF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_226 | `\e[48;5;226m` | - | `bg=0xFFFF00` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_227 | `\e[48;5;227m` | - | `bg=0xFFFF5F` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_228 | `\e[48;5;228m` | - | `bg=0xFFFF87` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_229 | `\e[48;5;229m` | - | `bg=0xFFFFAF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_230 | `\e[48;5;230m` | - | `bg=0xFFFFD7` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_231 | `\e[48;5;231m` | - | `bg=0xFFFFFF` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_232 | `\e[48;5;232m` | - | `bg=0x080808` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_233 | `\e[48;5;233m` | - | `bg=0x121212` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_234 | `\e[48;5;234m` | - | `bg=0x1C1C1C` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_235 | `\e[48;5;235m` | - | `bg=0x262626` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_236 | `\e[48;5;236m` | - | `bg=0x303030` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_237 | `\e[48;5;237m` | - | `bg=0x3A3A3A` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_238 | `\e[48;5;238m` | - | `bg=0x444444` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_239 | `\e[48;5;239m` | - | `bg=0x4E4E4E` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_240 | `\e[48;5;240m` | - | `bg=0x585858` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_241 | `\e[48;5;241m` | - | `bg=0x626262` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_242 | `\e[48;5;242m` | - | `bg=0x6C6C6C` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_243 | `\e[48;5;243m` | - | `bg=0x767676` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_244 | `\e[48;5;244m` | - | `bg=0x808080` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_245 | `\e[48;5;245m` | - | `bg=0x8A8A8A` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_246 | `\e[48;5;246m` | - | `bg=0x949494` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_247 | `\e[48;5;247m` | - | `bg=0x9E9E9E` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_248 | `\e[48;5;248m` | - | `bg=0xA8A8A8` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_249 | `\e[48;5;249m` | - | `bg=0xB2B2B2` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_250 | `\e[48;5;250m` | - | `bg=0xBCBCBC` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_251 | `\e[48;5;251m` | - | `bg=0xC6C6C6` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_252 | `\e[48;5;252m` | - | `bg=0xD0D0D0` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_253 | `\e[48;5;253m` | - | `bg=0xDADADA` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_254 | `\e[48;5;254m` | - | `bg=0xE4E4E4` | 0 | 11 | xterm 256 background palette |
| sgr | index_bg_255 | `\e[48;5;255m` | - | `bg=0xEEEEEE` | 0 | 11 | xterm 256 background palette |
| sgr | index_sp_000 | `\e[58;5;0m` | - | `sp=0x000000` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_001 | `\e[58;5;1m` | - | `sp=0xCD0000` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_002 | `\e[58;5;2m` | - | `sp=0x00CD00` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_003 | `\e[58;5;3m` | - | `sp=0xCDCD00` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_004 | `\e[58;5;4m` | - | `sp=0x0000EE` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_005 | `\e[58;5;5m` | - | `sp=0xCD00CD` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_006 | `\e[58;5;6m` | - | `sp=0x00CDCD` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_007 | `\e[58;5;7m` | - | `sp=0xE5E5E5` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_008 | `\e[58;5;8m` | - | `sp=0x7F7F7F` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_009 | `\e[58;5;9m` | - | `sp=0xFF0000` | 0 | 9 | xterm 256 underline palette |
| sgr | index_sp_010 | `\e[58;5;10m` | - | `sp=0x00FF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_011 | `\e[58;5;11m` | - | `sp=0xFFFF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_012 | `\e[58;5;12m` | - | `sp=0x5C5CFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_013 | `\e[58;5;13m` | - | `sp=0xFF00FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_014 | `\e[58;5;14m` | - | `sp=0x00FFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_015 | `\e[58;5;15m` | - | `sp=0xFFFFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_016 | `\e[58;5;16m` | - | `sp=0x000000` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_017 | `\e[58;5;17m` | - | `sp=0x00005F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_018 | `\e[58;5;18m` | - | `sp=0x000087` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_019 | `\e[58;5;19m` | - | `sp=0x0000AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_020 | `\e[58;5;20m` | - | `sp=0x0000D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_021 | `\e[58;5;21m` | - | `sp=0x0000FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_022 | `\e[58;5;22m` | - | `sp=0x005F00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_023 | `\e[58;5;23m` | - | `sp=0x005F5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_024 | `\e[58;5;24m` | - | `sp=0x005F87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_025 | `\e[58;5;25m` | - | `sp=0x005FAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_026 | `\e[58;5;26m` | - | `sp=0x005FD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_027 | `\e[58;5;27m` | - | `sp=0x005FFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_028 | `\e[58;5;28m` | - | `sp=0x008700` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_029 | `\e[58;5;29m` | - | `sp=0x00875F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_030 | `\e[58;5;30m` | - | `sp=0x008787` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_031 | `\e[58;5;31m` | - | `sp=0x0087AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_032 | `\e[58;5;32m` | - | `sp=0x0087D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_033 | `\e[58;5;33m` | - | `sp=0x0087FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_034 | `\e[58;5;34m` | - | `sp=0x00AF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_035 | `\e[58;5;35m` | - | `sp=0x00AF5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_036 | `\e[58;5;36m` | - | `sp=0x00AF87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_037 | `\e[58;5;37m` | - | `sp=0x00AFAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_038 | `\e[58;5;38m` | - | `sp=0x00AFD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_039 | `\e[58;5;39m` | - | `sp=0x00AFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_040 | `\e[58;5;40m` | - | `sp=0x00D700` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_041 | `\e[58;5;41m` | - | `sp=0x00D75F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_042 | `\e[58;5;42m` | - | `sp=0x00D787` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_043 | `\e[58;5;43m` | - | `sp=0x00D7AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_044 | `\e[58;5;44m` | - | `sp=0x00D7D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_045 | `\e[58;5;45m` | - | `sp=0x00D7FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_046 | `\e[58;5;46m` | - | `sp=0x00FF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_047 | `\e[58;5;47m` | - | `sp=0x00FF5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_048 | `\e[58;5;48m` | - | `sp=0x00FF87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_049 | `\e[58;5;49m` | - | `sp=0x00FFAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_050 | `\e[58;5;50m` | - | `sp=0x00FFD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_051 | `\e[58;5;51m` | - | `sp=0x00FFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_052 | `\e[58;5;52m` | - | `sp=0x5F0000` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_053 | `\e[58;5;53m` | - | `sp=0x5F005F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_054 | `\e[58;5;54m` | - | `sp=0x5F0087` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_055 | `\e[58;5;55m` | - | `sp=0x5F00AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_056 | `\e[58;5;56m` | - | `sp=0x5F00D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_057 | `\e[58;5;57m` | - | `sp=0x5F00FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_058 | `\e[58;5;58m` | - | `sp=0x5F5F00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_059 | `\e[58;5;59m` | - | `sp=0x5F5F5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_060 | `\e[58;5;60m` | - | `sp=0x5F5F87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_061 | `\e[58;5;61m` | - | `sp=0x5F5FAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_062 | `\e[58;5;62m` | - | `sp=0x5F5FD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_063 | `\e[58;5;63m` | - | `sp=0x5F5FFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_064 | `\e[58;5;64m` | - | `sp=0x5F8700` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_065 | `\e[58;5;65m` | - | `sp=0x5F875F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_066 | `\e[58;5;66m` | - | `sp=0x5F8787` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_067 | `\e[58;5;67m` | - | `sp=0x5F87AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_068 | `\e[58;5;68m` | - | `sp=0x5F87D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_069 | `\e[58;5;69m` | - | `sp=0x5F87FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_070 | `\e[58;5;70m` | - | `sp=0x5FAF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_071 | `\e[58;5;71m` | - | `sp=0x5FAF5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_072 | `\e[58;5;72m` | - | `sp=0x5FAF87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_073 | `\e[58;5;73m` | - | `sp=0x5FAFAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_074 | `\e[58;5;74m` | - | `sp=0x5FAFD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_075 | `\e[58;5;75m` | - | `sp=0x5FAFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_076 | `\e[58;5;76m` | - | `sp=0x5FD700` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_077 | `\e[58;5;77m` | - | `sp=0x5FD75F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_078 | `\e[58;5;78m` | - | `sp=0x5FD787` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_079 | `\e[58;5;79m` | - | `sp=0x5FD7AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_080 | `\e[58;5;80m` | - | `sp=0x5FD7D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_081 | `\e[58;5;81m` | - | `sp=0x5FD7FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_082 | `\e[58;5;82m` | - | `sp=0x5FFF00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_083 | `\e[58;5;83m` | - | `sp=0x5FFF5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_084 | `\e[58;5;84m` | - | `sp=0x5FFF87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_085 | `\e[58;5;85m` | - | `sp=0x5FFFAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_086 | `\e[58;5;86m` | - | `sp=0x5FFFD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_087 | `\e[58;5;87m` | - | `sp=0x5FFFFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_088 | `\e[58;5;88m` | - | `sp=0x870000` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_089 | `\e[58;5;89m` | - | `sp=0x87005F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_090 | `\e[58;5;90m` | - | `sp=0x870087` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_091 | `\e[58;5;91m` | - | `sp=0x8700AF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_092 | `\e[58;5;92m` | - | `sp=0x8700D7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_093 | `\e[58;5;93m` | - | `sp=0x8700FF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_094 | `\e[58;5;94m` | - | `sp=0x875F00` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_095 | `\e[58;5;95m` | - | `sp=0x875F5F` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_096 | `\e[58;5;96m` | - | `sp=0x875F87` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_097 | `\e[58;5;97m` | - | `sp=0x875FAF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_098 | `\e[58;5;98m` | - | `sp=0x875FD7` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_099 | `\e[58;5;99m` | - | `sp=0x875FFF` | 0 | 10 | xterm 256 underline palette |
| sgr | index_sp_100 | `\e[58;5;100m` | - | `sp=0x878700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_101 | `\e[58;5;101m` | - | `sp=0x87875F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_102 | `\e[58;5;102m` | - | `sp=0x878787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_103 | `\e[58;5;103m` | - | `sp=0x8787AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_104 | `\e[58;5;104m` | - | `sp=0x8787D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_105 | `\e[58;5;105m` | - | `sp=0x8787FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_106 | `\e[58;5;106m` | - | `sp=0x87AF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_107 | `\e[58;5;107m` | - | `sp=0x87AF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_108 | `\e[58;5;108m` | - | `sp=0x87AF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_109 | `\e[58;5;109m` | - | `sp=0x87AFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_110 | `\e[58;5;110m` | - | `sp=0x87AFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_111 | `\e[58;5;111m` | - | `sp=0x87AFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_112 | `\e[58;5;112m` | - | `sp=0x87D700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_113 | `\e[58;5;113m` | - | `sp=0x87D75F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_114 | `\e[58;5;114m` | - | `sp=0x87D787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_115 | `\e[58;5;115m` | - | `sp=0x87D7AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_116 | `\e[58;5;116m` | - | `sp=0x87D7D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_117 | `\e[58;5;117m` | - | `sp=0x87D7FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_118 | `\e[58;5;118m` | - | `sp=0x87FF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_119 | `\e[58;5;119m` | - | `sp=0x87FF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_120 | `\e[58;5;120m` | - | `sp=0x87FF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_121 | `\e[58;5;121m` | - | `sp=0x87FFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_122 | `\e[58;5;122m` | - | `sp=0x87FFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_123 | `\e[58;5;123m` | - | `sp=0x87FFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_124 | `\e[58;5;124m` | - | `sp=0xAF0000` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_125 | `\e[58;5;125m` | - | `sp=0xAF005F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_126 | `\e[58;5;126m` | - | `sp=0xAF0087` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_127 | `\e[58;5;127m` | - | `sp=0xAF00AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_128 | `\e[58;5;128m` | - | `sp=0xAF00D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_129 | `\e[58;5;129m` | - | `sp=0xAF00FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_130 | `\e[58;5;130m` | - | `sp=0xAF5F00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_131 | `\e[58;5;131m` | - | `sp=0xAF5F5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_132 | `\e[58;5;132m` | - | `sp=0xAF5F87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_133 | `\e[58;5;133m` | - | `sp=0xAF5FAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_134 | `\e[58;5;134m` | - | `sp=0xAF5FD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_135 | `\e[58;5;135m` | - | `sp=0xAF5FFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_136 | `\e[58;5;136m` | - | `sp=0xAF8700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_137 | `\e[58;5;137m` | - | `sp=0xAF875F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_138 | `\e[58;5;138m` | - | `sp=0xAF8787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_139 | `\e[58;5;139m` | - | `sp=0xAF87AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_140 | `\e[58;5;140m` | - | `sp=0xAF87D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_141 | `\e[58;5;141m` | - | `sp=0xAF87FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_142 | `\e[58;5;142m` | - | `sp=0xAFAF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_143 | `\e[58;5;143m` | - | `sp=0xAFAF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_144 | `\e[58;5;144m` | - | `sp=0xAFAF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_145 | `\e[58;5;145m` | - | `sp=0xAFAFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_146 | `\e[58;5;146m` | - | `sp=0xAFAFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_147 | `\e[58;5;147m` | - | `sp=0xAFAFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_148 | `\e[58;5;148m` | - | `sp=0xAFD700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_149 | `\e[58;5;149m` | - | `sp=0xAFD75F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_150 | `\e[58;5;150m` | - | `sp=0xAFD787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_151 | `\e[58;5;151m` | - | `sp=0xAFD7AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_152 | `\e[58;5;152m` | - | `sp=0xAFD7D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_153 | `\e[58;5;153m` | - | `sp=0xAFD7FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_154 | `\e[58;5;154m` | - | `sp=0xAFFF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_155 | `\e[58;5;155m` | - | `sp=0xAFFF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_156 | `\e[58;5;156m` | - | `sp=0xAFFF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_157 | `\e[58;5;157m` | - | `sp=0xAFFFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_158 | `\e[58;5;158m` | - | `sp=0xAFFFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_159 | `\e[58;5;159m` | - | `sp=0xAFFFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_160 | `\e[58;5;160m` | - | `sp=0xD70000` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_161 | `\e[58;5;161m` | - | `sp=0xD7005F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_162 | `\e[58;5;162m` | - | `sp=0xD70087` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_163 | `\e[58;5;163m` | - | `sp=0xD700AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_164 | `\e[58;5;164m` | - | `sp=0xD700D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_165 | `\e[58;5;165m` | - | `sp=0xD700FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_166 | `\e[58;5;166m` | - | `sp=0xD75F00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_167 | `\e[58;5;167m` | - | `sp=0xD75F5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_168 | `\e[58;5;168m` | - | `sp=0xD75F87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_169 | `\e[58;5;169m` | - | `sp=0xD75FAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_170 | `\e[58;5;170m` | - | `sp=0xD75FD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_171 | `\e[58;5;171m` | - | `sp=0xD75FFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_172 | `\e[58;5;172m` | - | `sp=0xD78700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_173 | `\e[58;5;173m` | - | `sp=0xD7875F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_174 | `\e[58;5;174m` | - | `sp=0xD78787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_175 | `\e[58;5;175m` | - | `sp=0xD787AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_176 | `\e[58;5;176m` | - | `sp=0xD787D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_177 | `\e[58;5;177m` | - | `sp=0xD787FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_178 | `\e[58;5;178m` | - | `sp=0xD7AF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_179 | `\e[58;5;179m` | - | `sp=0xD7AF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_180 | `\e[58;5;180m` | - | `sp=0xD7AF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_181 | `\e[58;5;181m` | - | `sp=0xD7AFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_182 | `\e[58;5;182m` | - | `sp=0xD7AFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_183 | `\e[58;5;183m` | - | `sp=0xD7AFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_184 | `\e[58;5;184m` | - | `sp=0xD7D700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_185 | `\e[58;5;185m` | - | `sp=0xD7D75F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_186 | `\e[58;5;186m` | - | `sp=0xD7D787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_187 | `\e[58;5;187m` | - | `sp=0xD7D7AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_188 | `\e[58;5;188m` | - | `sp=0xD7D7D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_189 | `\e[58;5;189m` | - | `sp=0xD7D7FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_190 | `\e[58;5;190m` | - | `sp=0xD7FF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_191 | `\e[58;5;191m` | - | `sp=0xD7FF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_192 | `\e[58;5;192m` | - | `sp=0xD7FF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_193 | `\e[58;5;193m` | - | `sp=0xD7FFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_194 | `\e[58;5;194m` | - | `sp=0xD7FFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_195 | `\e[58;5;195m` | - | `sp=0xD7FFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_196 | `\e[58;5;196m` | - | `sp=0xFF0000` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_197 | `\e[58;5;197m` | - | `sp=0xFF005F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_198 | `\e[58;5;198m` | - | `sp=0xFF0087` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_199 | `\e[58;5;199m` | - | `sp=0xFF00AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_200 | `\e[58;5;200m` | - | `sp=0xFF00D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_201 | `\e[58;5;201m` | - | `sp=0xFF00FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_202 | `\e[58;5;202m` | - | `sp=0xFF5F00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_203 | `\e[58;5;203m` | - | `sp=0xFF5F5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_204 | `\e[58;5;204m` | - | `sp=0xFF5F87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_205 | `\e[58;5;205m` | - | `sp=0xFF5FAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_206 | `\e[58;5;206m` | - | `sp=0xFF5FD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_207 | `\e[58;5;207m` | - | `sp=0xFF5FFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_208 | `\e[58;5;208m` | - | `sp=0xFF8700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_209 | `\e[58;5;209m` | - | `sp=0xFF875F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_210 | `\e[58;5;210m` | - | `sp=0xFF8787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_211 | `\e[58;5;211m` | - | `sp=0xFF87AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_212 | `\e[58;5;212m` | - | `sp=0xFF87D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_213 | `\e[58;5;213m` | - | `sp=0xFF87FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_214 | `\e[58;5;214m` | - | `sp=0xFFAF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_215 | `\e[58;5;215m` | - | `sp=0xFFAF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_216 | `\e[58;5;216m` | - | `sp=0xFFAF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_217 | `\e[58;5;217m` | - | `sp=0xFFAFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_218 | `\e[58;5;218m` | - | `sp=0xFFAFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_219 | `\e[58;5;219m` | - | `sp=0xFFAFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_220 | `\e[58;5;220m` | - | `sp=0xFFD700` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_221 | `\e[58;5;221m` | - | `sp=0xFFD75F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_222 | `\e[58;5;222m` | - | `sp=0xFFD787` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_223 | `\e[58;5;223m` | - | `sp=0xFFD7AF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_224 | `\e[58;5;224m` | - | `sp=0xFFD7D7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_225 | `\e[58;5;225m` | - | `sp=0xFFD7FF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_226 | `\e[58;5;226m` | - | `sp=0xFFFF00` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_227 | `\e[58;5;227m` | - | `sp=0xFFFF5F` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_228 | `\e[58;5;228m` | - | `sp=0xFFFF87` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_229 | `\e[58;5;229m` | - | `sp=0xFFFFAF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_230 | `\e[58;5;230m` | - | `sp=0xFFFFD7` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_231 | `\e[58;5;231m` | - | `sp=0xFFFFFF` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_232 | `\e[58;5;232m` | - | `sp=0x080808` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_233 | `\e[58;5;233m` | - | `sp=0x121212` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_234 | `\e[58;5;234m` | - | `sp=0x1C1C1C` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_235 | `\e[58;5;235m` | - | `sp=0x262626` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_236 | `\e[58;5;236m` | - | `sp=0x303030` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_237 | `\e[58;5;237m` | - | `sp=0x3A3A3A` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_238 | `\e[58;5;238m` | - | `sp=0x444444` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_239 | `\e[58;5;239m` | - | `sp=0x4E4E4E` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_240 | `\e[58;5;240m` | - | `sp=0x585858` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_241 | `\e[58;5;241m` | - | `sp=0x626262` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_242 | `\e[58;5;242m` | - | `sp=0x6C6C6C` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_243 | `\e[58;5;243m` | - | `sp=0x767676` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_244 | `\e[58;5;244m` | - | `sp=0x808080` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_245 | `\e[58;5;245m` | - | `sp=0x8A8A8A` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_246 | `\e[58;5;246m` | - | `sp=0x949494` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_247 | `\e[58;5;247m` | - | `sp=0x9E9E9E` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_248 | `\e[58;5;248m` | - | `sp=0xA8A8A8` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_249 | `\e[58;5;249m` | - | `sp=0xB2B2B2` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_250 | `\e[58;5;250m` | - | `sp=0xBCBCBC` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_251 | `\e[58;5;251m` | - | `sp=0xC6C6C6` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_252 | `\e[58;5;252m` | - | `sp=0xD0D0D0` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_253 | `\e[58;5;253m` | - | `sp=0xDADADA` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_254 | `\e[58;5;254m` | - | `sp=0xE4E4E4` | 0 | 11 | xterm 256 underline palette |
| sgr | index_sp_255 | `\e[58;5;255m` | - | `sp=0xEEEEEE` | 0 | 11 | xterm 256 underline palette |
| sgr | colon_index_fg_000 | `\e[38:5:0m` | - | `fg=0x000000` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_001 | `\e[38:5:1m` | - | `fg=0xCD0000` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_002 | `\e[38:5:2m` | - | `fg=0x00CD00` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_003 | `\e[38:5:3m` | - | `fg=0xCDCD00` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_004 | `\e[38:5:4m` | - | `fg=0x0000EE` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_005 | `\e[38:5:5m` | - | `fg=0xCD00CD` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_006 | `\e[38:5:6m` | - | `fg=0x00CDCD` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_007 | `\e[38:5:7m` | - | `fg=0xE5E5E5` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_008 | `\e[38:5:8m` | - | `fg=0x7F7F7F` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_009 | `\e[38:5:9m` | - | `fg=0xFF0000` | 0 | 9 | T.416 indexed foreground palette |
| sgr | colon_index_fg_010 | `\e[38:5:10m` | - | `fg=0x00FF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_011 | `\e[38:5:11m` | - | `fg=0xFFFF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_012 | `\e[38:5:12m` | - | `fg=0x5C5CFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_013 | `\e[38:5:13m` | - | `fg=0xFF00FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_014 | `\e[38:5:14m` | - | `fg=0x00FFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_015 | `\e[38:5:15m` | - | `fg=0xFFFFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_016 | `\e[38:5:16m` | - | `fg=0x000000` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_017 | `\e[38:5:17m` | - | `fg=0x00005F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_018 | `\e[38:5:18m` | - | `fg=0x000087` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_019 | `\e[38:5:19m` | - | `fg=0x0000AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_020 | `\e[38:5:20m` | - | `fg=0x0000D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_021 | `\e[38:5:21m` | - | `fg=0x0000FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_022 | `\e[38:5:22m` | - | `fg=0x005F00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_023 | `\e[38:5:23m` | - | `fg=0x005F5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_024 | `\e[38:5:24m` | - | `fg=0x005F87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_025 | `\e[38:5:25m` | - | `fg=0x005FAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_026 | `\e[38:5:26m` | - | `fg=0x005FD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_027 | `\e[38:5:27m` | - | `fg=0x005FFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_028 | `\e[38:5:28m` | - | `fg=0x008700` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_029 | `\e[38:5:29m` | - | `fg=0x00875F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_030 | `\e[38:5:30m` | - | `fg=0x008787` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_031 | `\e[38:5:31m` | - | `fg=0x0087AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_032 | `\e[38:5:32m` | - | `fg=0x0087D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_033 | `\e[38:5:33m` | - | `fg=0x0087FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_034 | `\e[38:5:34m` | - | `fg=0x00AF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_035 | `\e[38:5:35m` | - | `fg=0x00AF5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_036 | `\e[38:5:36m` | - | `fg=0x00AF87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_037 | `\e[38:5:37m` | - | `fg=0x00AFAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_038 | `\e[38:5:38m` | - | `fg=0x00AFD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_039 | `\e[38:5:39m` | - | `fg=0x00AFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_040 | `\e[38:5:40m` | - | `fg=0x00D700` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_041 | `\e[38:5:41m` | - | `fg=0x00D75F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_042 | `\e[38:5:42m` | - | `fg=0x00D787` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_043 | `\e[38:5:43m` | - | `fg=0x00D7AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_044 | `\e[38:5:44m` | - | `fg=0x00D7D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_045 | `\e[38:5:45m` | - | `fg=0x00D7FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_046 | `\e[38:5:46m` | - | `fg=0x00FF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_047 | `\e[38:5:47m` | - | `fg=0x00FF5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_048 | `\e[38:5:48m` | - | `fg=0x00FF87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_049 | `\e[38:5:49m` | - | `fg=0x00FFAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_050 | `\e[38:5:50m` | - | `fg=0x00FFD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_051 | `\e[38:5:51m` | - | `fg=0x00FFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_052 | `\e[38:5:52m` | - | `fg=0x5F0000` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_053 | `\e[38:5:53m` | - | `fg=0x5F005F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_054 | `\e[38:5:54m` | - | `fg=0x5F0087` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_055 | `\e[38:5:55m` | - | `fg=0x5F00AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_056 | `\e[38:5:56m` | - | `fg=0x5F00D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_057 | `\e[38:5:57m` | - | `fg=0x5F00FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_058 | `\e[38:5:58m` | - | `fg=0x5F5F00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_059 | `\e[38:5:59m` | - | `fg=0x5F5F5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_060 | `\e[38:5:60m` | - | `fg=0x5F5F87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_061 | `\e[38:5:61m` | - | `fg=0x5F5FAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_062 | `\e[38:5:62m` | - | `fg=0x5F5FD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_063 | `\e[38:5:63m` | - | `fg=0x5F5FFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_064 | `\e[38:5:64m` | - | `fg=0x5F8700` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_065 | `\e[38:5:65m` | - | `fg=0x5F875F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_066 | `\e[38:5:66m` | - | `fg=0x5F8787` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_067 | `\e[38:5:67m` | - | `fg=0x5F87AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_068 | `\e[38:5:68m` | - | `fg=0x5F87D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_069 | `\e[38:5:69m` | - | `fg=0x5F87FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_070 | `\e[38:5:70m` | - | `fg=0x5FAF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_071 | `\e[38:5:71m` | - | `fg=0x5FAF5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_072 | `\e[38:5:72m` | - | `fg=0x5FAF87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_073 | `\e[38:5:73m` | - | `fg=0x5FAFAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_074 | `\e[38:5:74m` | - | `fg=0x5FAFD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_075 | `\e[38:5:75m` | - | `fg=0x5FAFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_076 | `\e[38:5:76m` | - | `fg=0x5FD700` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_077 | `\e[38:5:77m` | - | `fg=0x5FD75F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_078 | `\e[38:5:78m` | - | `fg=0x5FD787` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_079 | `\e[38:5:79m` | - | `fg=0x5FD7AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_080 | `\e[38:5:80m` | - | `fg=0x5FD7D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_081 | `\e[38:5:81m` | - | `fg=0x5FD7FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_082 | `\e[38:5:82m` | - | `fg=0x5FFF00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_083 | `\e[38:5:83m` | - | `fg=0x5FFF5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_084 | `\e[38:5:84m` | - | `fg=0x5FFF87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_085 | `\e[38:5:85m` | - | `fg=0x5FFFAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_086 | `\e[38:5:86m` | - | `fg=0x5FFFD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_087 | `\e[38:5:87m` | - | `fg=0x5FFFFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_088 | `\e[38:5:88m` | - | `fg=0x870000` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_089 | `\e[38:5:89m` | - | `fg=0x87005F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_090 | `\e[38:5:90m` | - | `fg=0x870087` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_091 | `\e[38:5:91m` | - | `fg=0x8700AF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_092 | `\e[38:5:92m` | - | `fg=0x8700D7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_093 | `\e[38:5:93m` | - | `fg=0x8700FF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_094 | `\e[38:5:94m` | - | `fg=0x875F00` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_095 | `\e[38:5:95m` | - | `fg=0x875F5F` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_096 | `\e[38:5:96m` | - | `fg=0x875F87` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_097 | `\e[38:5:97m` | - | `fg=0x875FAF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_098 | `\e[38:5:98m` | - | `fg=0x875FD7` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_099 | `\e[38:5:99m` | - | `fg=0x875FFF` | 0 | 10 | T.416 indexed foreground palette |
| sgr | colon_index_fg_100 | `\e[38:5:100m` | - | `fg=0x878700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_101 | `\e[38:5:101m` | - | `fg=0x87875F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_102 | `\e[38:5:102m` | - | `fg=0x878787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_103 | `\e[38:5:103m` | - | `fg=0x8787AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_104 | `\e[38:5:104m` | - | `fg=0x8787D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_105 | `\e[38:5:105m` | - | `fg=0x8787FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_106 | `\e[38:5:106m` | - | `fg=0x87AF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_107 | `\e[38:5:107m` | - | `fg=0x87AF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_108 | `\e[38:5:108m` | - | `fg=0x87AF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_109 | `\e[38:5:109m` | - | `fg=0x87AFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_110 | `\e[38:5:110m` | - | `fg=0x87AFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_111 | `\e[38:5:111m` | - | `fg=0x87AFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_112 | `\e[38:5:112m` | - | `fg=0x87D700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_113 | `\e[38:5:113m` | - | `fg=0x87D75F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_114 | `\e[38:5:114m` | - | `fg=0x87D787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_115 | `\e[38:5:115m` | - | `fg=0x87D7AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_116 | `\e[38:5:116m` | - | `fg=0x87D7D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_117 | `\e[38:5:117m` | - | `fg=0x87D7FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_118 | `\e[38:5:118m` | - | `fg=0x87FF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_119 | `\e[38:5:119m` | - | `fg=0x87FF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_120 | `\e[38:5:120m` | - | `fg=0x87FF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_121 | `\e[38:5:121m` | - | `fg=0x87FFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_122 | `\e[38:5:122m` | - | `fg=0x87FFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_123 | `\e[38:5:123m` | - | `fg=0x87FFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_124 | `\e[38:5:124m` | - | `fg=0xAF0000` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_125 | `\e[38:5:125m` | - | `fg=0xAF005F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_126 | `\e[38:5:126m` | - | `fg=0xAF0087` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_127 | `\e[38:5:127m` | - | `fg=0xAF00AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_128 | `\e[38:5:128m` | - | `fg=0xAF00D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_129 | `\e[38:5:129m` | - | `fg=0xAF00FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_130 | `\e[38:5:130m` | - | `fg=0xAF5F00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_131 | `\e[38:5:131m` | - | `fg=0xAF5F5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_132 | `\e[38:5:132m` | - | `fg=0xAF5F87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_133 | `\e[38:5:133m` | - | `fg=0xAF5FAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_134 | `\e[38:5:134m` | - | `fg=0xAF5FD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_135 | `\e[38:5:135m` | - | `fg=0xAF5FFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_136 | `\e[38:5:136m` | - | `fg=0xAF8700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_137 | `\e[38:5:137m` | - | `fg=0xAF875F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_138 | `\e[38:5:138m` | - | `fg=0xAF8787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_139 | `\e[38:5:139m` | - | `fg=0xAF87AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_140 | `\e[38:5:140m` | - | `fg=0xAF87D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_141 | `\e[38:5:141m` | - | `fg=0xAF87FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_142 | `\e[38:5:142m` | - | `fg=0xAFAF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_143 | `\e[38:5:143m` | - | `fg=0xAFAF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_144 | `\e[38:5:144m` | - | `fg=0xAFAF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_145 | `\e[38:5:145m` | - | `fg=0xAFAFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_146 | `\e[38:5:146m` | - | `fg=0xAFAFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_147 | `\e[38:5:147m` | - | `fg=0xAFAFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_148 | `\e[38:5:148m` | - | `fg=0xAFD700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_149 | `\e[38:5:149m` | - | `fg=0xAFD75F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_150 | `\e[38:5:150m` | - | `fg=0xAFD787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_151 | `\e[38:5:151m` | - | `fg=0xAFD7AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_152 | `\e[38:5:152m` | - | `fg=0xAFD7D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_153 | `\e[38:5:153m` | - | `fg=0xAFD7FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_154 | `\e[38:5:154m` | - | `fg=0xAFFF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_155 | `\e[38:5:155m` | - | `fg=0xAFFF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_156 | `\e[38:5:156m` | - | `fg=0xAFFF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_157 | `\e[38:5:157m` | - | `fg=0xAFFFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_158 | `\e[38:5:158m` | - | `fg=0xAFFFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_159 | `\e[38:5:159m` | - | `fg=0xAFFFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_160 | `\e[38:5:160m` | - | `fg=0xD70000` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_161 | `\e[38:5:161m` | - | `fg=0xD7005F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_162 | `\e[38:5:162m` | - | `fg=0xD70087` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_163 | `\e[38:5:163m` | - | `fg=0xD700AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_164 | `\e[38:5:164m` | - | `fg=0xD700D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_165 | `\e[38:5:165m` | - | `fg=0xD700FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_166 | `\e[38:5:166m` | - | `fg=0xD75F00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_167 | `\e[38:5:167m` | - | `fg=0xD75F5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_168 | `\e[38:5:168m` | - | `fg=0xD75F87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_169 | `\e[38:5:169m` | - | `fg=0xD75FAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_170 | `\e[38:5:170m` | - | `fg=0xD75FD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_171 | `\e[38:5:171m` | - | `fg=0xD75FFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_172 | `\e[38:5:172m` | - | `fg=0xD78700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_173 | `\e[38:5:173m` | - | `fg=0xD7875F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_174 | `\e[38:5:174m` | - | `fg=0xD78787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_175 | `\e[38:5:175m` | - | `fg=0xD787AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_176 | `\e[38:5:176m` | - | `fg=0xD787D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_177 | `\e[38:5:177m` | - | `fg=0xD787FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_178 | `\e[38:5:178m` | - | `fg=0xD7AF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_179 | `\e[38:5:179m` | - | `fg=0xD7AF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_180 | `\e[38:5:180m` | - | `fg=0xD7AF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_181 | `\e[38:5:181m` | - | `fg=0xD7AFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_182 | `\e[38:5:182m` | - | `fg=0xD7AFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_183 | `\e[38:5:183m` | - | `fg=0xD7AFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_184 | `\e[38:5:184m` | - | `fg=0xD7D700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_185 | `\e[38:5:185m` | - | `fg=0xD7D75F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_186 | `\e[38:5:186m` | - | `fg=0xD7D787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_187 | `\e[38:5:187m` | - | `fg=0xD7D7AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_188 | `\e[38:5:188m` | - | `fg=0xD7D7D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_189 | `\e[38:5:189m` | - | `fg=0xD7D7FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_190 | `\e[38:5:190m` | - | `fg=0xD7FF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_191 | `\e[38:5:191m` | - | `fg=0xD7FF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_192 | `\e[38:5:192m` | - | `fg=0xD7FF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_193 | `\e[38:5:193m` | - | `fg=0xD7FFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_194 | `\e[38:5:194m` | - | `fg=0xD7FFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_195 | `\e[38:5:195m` | - | `fg=0xD7FFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_196 | `\e[38:5:196m` | - | `fg=0xFF0000` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_197 | `\e[38:5:197m` | - | `fg=0xFF005F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_198 | `\e[38:5:198m` | - | `fg=0xFF0087` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_199 | `\e[38:5:199m` | - | `fg=0xFF00AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_200 | `\e[38:5:200m` | - | `fg=0xFF00D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_201 | `\e[38:5:201m` | - | `fg=0xFF00FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_202 | `\e[38:5:202m` | - | `fg=0xFF5F00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_203 | `\e[38:5:203m` | - | `fg=0xFF5F5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_204 | `\e[38:5:204m` | - | `fg=0xFF5F87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_205 | `\e[38:5:205m` | - | `fg=0xFF5FAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_206 | `\e[38:5:206m` | - | `fg=0xFF5FD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_207 | `\e[38:5:207m` | - | `fg=0xFF5FFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_208 | `\e[38:5:208m` | - | `fg=0xFF8700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_209 | `\e[38:5:209m` | - | `fg=0xFF875F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_210 | `\e[38:5:210m` | - | `fg=0xFF8787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_211 | `\e[38:5:211m` | - | `fg=0xFF87AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_212 | `\e[38:5:212m` | - | `fg=0xFF87D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_213 | `\e[38:5:213m` | - | `fg=0xFF87FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_214 | `\e[38:5:214m` | - | `fg=0xFFAF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_215 | `\e[38:5:215m` | - | `fg=0xFFAF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_216 | `\e[38:5:216m` | - | `fg=0xFFAF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_217 | `\e[38:5:217m` | - | `fg=0xFFAFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_218 | `\e[38:5:218m` | - | `fg=0xFFAFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_219 | `\e[38:5:219m` | - | `fg=0xFFAFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_220 | `\e[38:5:220m` | - | `fg=0xFFD700` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_221 | `\e[38:5:221m` | - | `fg=0xFFD75F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_222 | `\e[38:5:222m` | - | `fg=0xFFD787` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_223 | `\e[38:5:223m` | - | `fg=0xFFD7AF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_224 | `\e[38:5:224m` | - | `fg=0xFFD7D7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_225 | `\e[38:5:225m` | - | `fg=0xFFD7FF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_226 | `\e[38:5:226m` | - | `fg=0xFFFF00` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_227 | `\e[38:5:227m` | - | `fg=0xFFFF5F` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_228 | `\e[38:5:228m` | - | `fg=0xFFFF87` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_229 | `\e[38:5:229m` | - | `fg=0xFFFFAF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_230 | `\e[38:5:230m` | - | `fg=0xFFFFD7` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_231 | `\e[38:5:231m` | - | `fg=0xFFFFFF` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_232 | `\e[38:5:232m` | - | `fg=0x080808` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_233 | `\e[38:5:233m` | - | `fg=0x121212` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_234 | `\e[38:5:234m` | - | `fg=0x1C1C1C` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_235 | `\e[38:5:235m` | - | `fg=0x262626` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_236 | `\e[38:5:236m` | - | `fg=0x303030` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_237 | `\e[38:5:237m` | - | `fg=0x3A3A3A` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_238 | `\e[38:5:238m` | - | `fg=0x444444` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_239 | `\e[38:5:239m` | - | `fg=0x4E4E4E` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_240 | `\e[38:5:240m` | - | `fg=0x585858` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_241 | `\e[38:5:241m` | - | `fg=0x626262` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_242 | `\e[38:5:242m` | - | `fg=0x6C6C6C` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_243 | `\e[38:5:243m` | - | `fg=0x767676` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_244 | `\e[38:5:244m` | - | `fg=0x808080` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_245 | `\e[38:5:245m` | - | `fg=0x8A8A8A` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_246 | `\e[38:5:246m` | - | `fg=0x949494` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_247 | `\e[38:5:247m` | - | `fg=0x9E9E9E` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_248 | `\e[38:5:248m` | - | `fg=0xA8A8A8` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_249 | `\e[38:5:249m` | - | `fg=0xB2B2B2` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_250 | `\e[38:5:250m` | - | `fg=0xBCBCBC` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_251 | `\e[38:5:251m` | - | `fg=0xC6C6C6` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_252 | `\e[38:5:252m` | - | `fg=0xD0D0D0` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_253 | `\e[38:5:253m` | - | `fg=0xDADADA` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_254 | `\e[38:5:254m` | - | `fg=0xE4E4E4` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_fg_255 | `\e[38:5:255m` | - | `fg=0xEEEEEE` | 0 | 11 | T.416 indexed foreground palette |
| sgr | colon_index_bg_000 | `\e[48:5:0m` | - | `bg=0x000000` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_001 | `\e[48:5:1m` | - | `bg=0xCD0000` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_002 | `\e[48:5:2m` | - | `bg=0x00CD00` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_003 | `\e[48:5:3m` | - | `bg=0xCDCD00` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_004 | `\e[48:5:4m` | - | `bg=0x0000EE` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_005 | `\e[48:5:5m` | - | `bg=0xCD00CD` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_006 | `\e[48:5:6m` | - | `bg=0x00CDCD` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_007 | `\e[48:5:7m` | - | `bg=0xE5E5E5` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_008 | `\e[48:5:8m` | - | `bg=0x7F7F7F` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_009 | `\e[48:5:9m` | - | `bg=0xFF0000` | 0 | 9 | T.416 indexed background palette |
| sgr | colon_index_bg_010 | `\e[48:5:10m` | - | `bg=0x00FF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_011 | `\e[48:5:11m` | - | `bg=0xFFFF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_012 | `\e[48:5:12m` | - | `bg=0x5C5CFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_013 | `\e[48:5:13m` | - | `bg=0xFF00FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_014 | `\e[48:5:14m` | - | `bg=0x00FFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_015 | `\e[48:5:15m` | - | `bg=0xFFFFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_016 | `\e[48:5:16m` | - | `bg=0x000000` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_017 | `\e[48:5:17m` | - | `bg=0x00005F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_018 | `\e[48:5:18m` | - | `bg=0x000087` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_019 | `\e[48:5:19m` | - | `bg=0x0000AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_020 | `\e[48:5:20m` | - | `bg=0x0000D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_021 | `\e[48:5:21m` | - | `bg=0x0000FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_022 | `\e[48:5:22m` | - | `bg=0x005F00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_023 | `\e[48:5:23m` | - | `bg=0x005F5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_024 | `\e[48:5:24m` | - | `bg=0x005F87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_025 | `\e[48:5:25m` | - | `bg=0x005FAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_026 | `\e[48:5:26m` | - | `bg=0x005FD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_027 | `\e[48:5:27m` | - | `bg=0x005FFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_028 | `\e[48:5:28m` | - | `bg=0x008700` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_029 | `\e[48:5:29m` | - | `bg=0x00875F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_030 | `\e[48:5:30m` | - | `bg=0x008787` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_031 | `\e[48:5:31m` | - | `bg=0x0087AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_032 | `\e[48:5:32m` | - | `bg=0x0087D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_033 | `\e[48:5:33m` | - | `bg=0x0087FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_034 | `\e[48:5:34m` | - | `bg=0x00AF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_035 | `\e[48:5:35m` | - | `bg=0x00AF5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_036 | `\e[48:5:36m` | - | `bg=0x00AF87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_037 | `\e[48:5:37m` | - | `bg=0x00AFAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_038 | `\e[48:5:38m` | - | `bg=0x00AFD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_039 | `\e[48:5:39m` | - | `bg=0x00AFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_040 | `\e[48:5:40m` | - | `bg=0x00D700` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_041 | `\e[48:5:41m` | - | `bg=0x00D75F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_042 | `\e[48:5:42m` | - | `bg=0x00D787` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_043 | `\e[48:5:43m` | - | `bg=0x00D7AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_044 | `\e[48:5:44m` | - | `bg=0x00D7D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_045 | `\e[48:5:45m` | - | `bg=0x00D7FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_046 | `\e[48:5:46m` | - | `bg=0x00FF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_047 | `\e[48:5:47m` | - | `bg=0x00FF5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_048 | `\e[48:5:48m` | - | `bg=0x00FF87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_049 | `\e[48:5:49m` | - | `bg=0x00FFAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_050 | `\e[48:5:50m` | - | `bg=0x00FFD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_051 | `\e[48:5:51m` | - | `bg=0x00FFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_052 | `\e[48:5:52m` | - | `bg=0x5F0000` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_053 | `\e[48:5:53m` | - | `bg=0x5F005F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_054 | `\e[48:5:54m` | - | `bg=0x5F0087` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_055 | `\e[48:5:55m` | - | `bg=0x5F00AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_056 | `\e[48:5:56m` | - | `bg=0x5F00D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_057 | `\e[48:5:57m` | - | `bg=0x5F00FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_058 | `\e[48:5:58m` | - | `bg=0x5F5F00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_059 | `\e[48:5:59m` | - | `bg=0x5F5F5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_060 | `\e[48:5:60m` | - | `bg=0x5F5F87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_061 | `\e[48:5:61m` | - | `bg=0x5F5FAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_062 | `\e[48:5:62m` | - | `bg=0x5F5FD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_063 | `\e[48:5:63m` | - | `bg=0x5F5FFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_064 | `\e[48:5:64m` | - | `bg=0x5F8700` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_065 | `\e[48:5:65m` | - | `bg=0x5F875F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_066 | `\e[48:5:66m` | - | `bg=0x5F8787` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_067 | `\e[48:5:67m` | - | `bg=0x5F87AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_068 | `\e[48:5:68m` | - | `bg=0x5F87D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_069 | `\e[48:5:69m` | - | `bg=0x5F87FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_070 | `\e[48:5:70m` | - | `bg=0x5FAF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_071 | `\e[48:5:71m` | - | `bg=0x5FAF5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_072 | `\e[48:5:72m` | - | `bg=0x5FAF87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_073 | `\e[48:5:73m` | - | `bg=0x5FAFAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_074 | `\e[48:5:74m` | - | `bg=0x5FAFD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_075 | `\e[48:5:75m` | - | `bg=0x5FAFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_076 | `\e[48:5:76m` | - | `bg=0x5FD700` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_077 | `\e[48:5:77m` | - | `bg=0x5FD75F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_078 | `\e[48:5:78m` | - | `bg=0x5FD787` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_079 | `\e[48:5:79m` | - | `bg=0x5FD7AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_080 | `\e[48:5:80m` | - | `bg=0x5FD7D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_081 | `\e[48:5:81m` | - | `bg=0x5FD7FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_082 | `\e[48:5:82m` | - | `bg=0x5FFF00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_083 | `\e[48:5:83m` | - | `bg=0x5FFF5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_084 | `\e[48:5:84m` | - | `bg=0x5FFF87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_085 | `\e[48:5:85m` | - | `bg=0x5FFFAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_086 | `\e[48:5:86m` | - | `bg=0x5FFFD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_087 | `\e[48:5:87m` | - | `bg=0x5FFFFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_088 | `\e[48:5:88m` | - | `bg=0x870000` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_089 | `\e[48:5:89m` | - | `bg=0x87005F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_090 | `\e[48:5:90m` | - | `bg=0x870087` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_091 | `\e[48:5:91m` | - | `bg=0x8700AF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_092 | `\e[48:5:92m` | - | `bg=0x8700D7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_093 | `\e[48:5:93m` | - | `bg=0x8700FF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_094 | `\e[48:5:94m` | - | `bg=0x875F00` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_095 | `\e[48:5:95m` | - | `bg=0x875F5F` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_096 | `\e[48:5:96m` | - | `bg=0x875F87` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_097 | `\e[48:5:97m` | - | `bg=0x875FAF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_098 | `\e[48:5:98m` | - | `bg=0x875FD7` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_099 | `\e[48:5:99m` | - | `bg=0x875FFF` | 0 | 10 | T.416 indexed background palette |
| sgr | colon_index_bg_100 | `\e[48:5:100m` | - | `bg=0x878700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_101 | `\e[48:5:101m` | - | `bg=0x87875F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_102 | `\e[48:5:102m` | - | `bg=0x878787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_103 | `\e[48:5:103m` | - | `bg=0x8787AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_104 | `\e[48:5:104m` | - | `bg=0x8787D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_105 | `\e[48:5:105m` | - | `bg=0x8787FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_106 | `\e[48:5:106m` | - | `bg=0x87AF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_107 | `\e[48:5:107m` | - | `bg=0x87AF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_108 | `\e[48:5:108m` | - | `bg=0x87AF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_109 | `\e[48:5:109m` | - | `bg=0x87AFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_110 | `\e[48:5:110m` | - | `bg=0x87AFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_111 | `\e[48:5:111m` | - | `bg=0x87AFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_112 | `\e[48:5:112m` | - | `bg=0x87D700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_113 | `\e[48:5:113m` | - | `bg=0x87D75F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_114 | `\e[48:5:114m` | - | `bg=0x87D787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_115 | `\e[48:5:115m` | - | `bg=0x87D7AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_116 | `\e[48:5:116m` | - | `bg=0x87D7D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_117 | `\e[48:5:117m` | - | `bg=0x87D7FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_118 | `\e[48:5:118m` | - | `bg=0x87FF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_119 | `\e[48:5:119m` | - | `bg=0x87FF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_120 | `\e[48:5:120m` | - | `bg=0x87FF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_121 | `\e[48:5:121m` | - | `bg=0x87FFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_122 | `\e[48:5:122m` | - | `bg=0x87FFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_123 | `\e[48:5:123m` | - | `bg=0x87FFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_124 | `\e[48:5:124m` | - | `bg=0xAF0000` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_125 | `\e[48:5:125m` | - | `bg=0xAF005F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_126 | `\e[48:5:126m` | - | `bg=0xAF0087` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_127 | `\e[48:5:127m` | - | `bg=0xAF00AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_128 | `\e[48:5:128m` | - | `bg=0xAF00D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_129 | `\e[48:5:129m` | - | `bg=0xAF00FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_130 | `\e[48:5:130m` | - | `bg=0xAF5F00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_131 | `\e[48:5:131m` | - | `bg=0xAF5F5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_132 | `\e[48:5:132m` | - | `bg=0xAF5F87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_133 | `\e[48:5:133m` | - | `bg=0xAF5FAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_134 | `\e[48:5:134m` | - | `bg=0xAF5FD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_135 | `\e[48:5:135m` | - | `bg=0xAF5FFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_136 | `\e[48:5:136m` | - | `bg=0xAF8700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_137 | `\e[48:5:137m` | - | `bg=0xAF875F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_138 | `\e[48:5:138m` | - | `bg=0xAF8787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_139 | `\e[48:5:139m` | - | `bg=0xAF87AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_140 | `\e[48:5:140m` | - | `bg=0xAF87D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_141 | `\e[48:5:141m` | - | `bg=0xAF87FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_142 | `\e[48:5:142m` | - | `bg=0xAFAF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_143 | `\e[48:5:143m` | - | `bg=0xAFAF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_144 | `\e[48:5:144m` | - | `bg=0xAFAF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_145 | `\e[48:5:145m` | - | `bg=0xAFAFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_146 | `\e[48:5:146m` | - | `bg=0xAFAFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_147 | `\e[48:5:147m` | - | `bg=0xAFAFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_148 | `\e[48:5:148m` | - | `bg=0xAFD700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_149 | `\e[48:5:149m` | - | `bg=0xAFD75F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_150 | `\e[48:5:150m` | - | `bg=0xAFD787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_151 | `\e[48:5:151m` | - | `bg=0xAFD7AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_152 | `\e[48:5:152m` | - | `bg=0xAFD7D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_153 | `\e[48:5:153m` | - | `bg=0xAFD7FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_154 | `\e[48:5:154m` | - | `bg=0xAFFF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_155 | `\e[48:5:155m` | - | `bg=0xAFFF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_156 | `\e[48:5:156m` | - | `bg=0xAFFF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_157 | `\e[48:5:157m` | - | `bg=0xAFFFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_158 | `\e[48:5:158m` | - | `bg=0xAFFFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_159 | `\e[48:5:159m` | - | `bg=0xAFFFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_160 | `\e[48:5:160m` | - | `bg=0xD70000` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_161 | `\e[48:5:161m` | - | `bg=0xD7005F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_162 | `\e[48:5:162m` | - | `bg=0xD70087` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_163 | `\e[48:5:163m` | - | `bg=0xD700AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_164 | `\e[48:5:164m` | - | `bg=0xD700D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_165 | `\e[48:5:165m` | - | `bg=0xD700FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_166 | `\e[48:5:166m` | - | `bg=0xD75F00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_167 | `\e[48:5:167m` | - | `bg=0xD75F5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_168 | `\e[48:5:168m` | - | `bg=0xD75F87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_169 | `\e[48:5:169m` | - | `bg=0xD75FAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_170 | `\e[48:5:170m` | - | `bg=0xD75FD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_171 | `\e[48:5:171m` | - | `bg=0xD75FFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_172 | `\e[48:5:172m` | - | `bg=0xD78700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_173 | `\e[48:5:173m` | - | `bg=0xD7875F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_174 | `\e[48:5:174m` | - | `bg=0xD78787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_175 | `\e[48:5:175m` | - | `bg=0xD787AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_176 | `\e[48:5:176m` | - | `bg=0xD787D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_177 | `\e[48:5:177m` | - | `bg=0xD787FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_178 | `\e[48:5:178m` | - | `bg=0xD7AF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_179 | `\e[48:5:179m` | - | `bg=0xD7AF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_180 | `\e[48:5:180m` | - | `bg=0xD7AF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_181 | `\e[48:5:181m` | - | `bg=0xD7AFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_182 | `\e[48:5:182m` | - | `bg=0xD7AFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_183 | `\e[48:5:183m` | - | `bg=0xD7AFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_184 | `\e[48:5:184m` | - | `bg=0xD7D700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_185 | `\e[48:5:185m` | - | `bg=0xD7D75F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_186 | `\e[48:5:186m` | - | `bg=0xD7D787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_187 | `\e[48:5:187m` | - | `bg=0xD7D7AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_188 | `\e[48:5:188m` | - | `bg=0xD7D7D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_189 | `\e[48:5:189m` | - | `bg=0xD7D7FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_190 | `\e[48:5:190m` | - | `bg=0xD7FF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_191 | `\e[48:5:191m` | - | `bg=0xD7FF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_192 | `\e[48:5:192m` | - | `bg=0xD7FF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_193 | `\e[48:5:193m` | - | `bg=0xD7FFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_194 | `\e[48:5:194m` | - | `bg=0xD7FFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_195 | `\e[48:5:195m` | - | `bg=0xD7FFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_196 | `\e[48:5:196m` | - | `bg=0xFF0000` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_197 | `\e[48:5:197m` | - | `bg=0xFF005F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_198 | `\e[48:5:198m` | - | `bg=0xFF0087` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_199 | `\e[48:5:199m` | - | `bg=0xFF00AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_200 | `\e[48:5:200m` | - | `bg=0xFF00D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_201 | `\e[48:5:201m` | - | `bg=0xFF00FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_202 | `\e[48:5:202m` | - | `bg=0xFF5F00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_203 | `\e[48:5:203m` | - | `bg=0xFF5F5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_204 | `\e[48:5:204m` | - | `bg=0xFF5F87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_205 | `\e[48:5:205m` | - | `bg=0xFF5FAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_206 | `\e[48:5:206m` | - | `bg=0xFF5FD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_207 | `\e[48:5:207m` | - | `bg=0xFF5FFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_208 | `\e[48:5:208m` | - | `bg=0xFF8700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_209 | `\e[48:5:209m` | - | `bg=0xFF875F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_210 | `\e[48:5:210m` | - | `bg=0xFF8787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_211 | `\e[48:5:211m` | - | `bg=0xFF87AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_212 | `\e[48:5:212m` | - | `bg=0xFF87D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_213 | `\e[48:5:213m` | - | `bg=0xFF87FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_214 | `\e[48:5:214m` | - | `bg=0xFFAF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_215 | `\e[48:5:215m` | - | `bg=0xFFAF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_216 | `\e[48:5:216m` | - | `bg=0xFFAF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_217 | `\e[48:5:217m` | - | `bg=0xFFAFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_218 | `\e[48:5:218m` | - | `bg=0xFFAFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_219 | `\e[48:5:219m` | - | `bg=0xFFAFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_220 | `\e[48:5:220m` | - | `bg=0xFFD700` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_221 | `\e[48:5:221m` | - | `bg=0xFFD75F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_222 | `\e[48:5:222m` | - | `bg=0xFFD787` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_223 | `\e[48:5:223m` | - | `bg=0xFFD7AF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_224 | `\e[48:5:224m` | - | `bg=0xFFD7D7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_225 | `\e[48:5:225m` | - | `bg=0xFFD7FF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_226 | `\e[48:5:226m` | - | `bg=0xFFFF00` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_227 | `\e[48:5:227m` | - | `bg=0xFFFF5F` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_228 | `\e[48:5:228m` | - | `bg=0xFFFF87` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_229 | `\e[48:5:229m` | - | `bg=0xFFFFAF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_230 | `\e[48:5:230m` | - | `bg=0xFFFFD7` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_231 | `\e[48:5:231m` | - | `bg=0xFFFFFF` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_232 | `\e[48:5:232m` | - | `bg=0x080808` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_233 | `\e[48:5:233m` | - | `bg=0x121212` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_234 | `\e[48:5:234m` | - | `bg=0x1C1C1C` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_235 | `\e[48:5:235m` | - | `bg=0x262626` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_236 | `\e[48:5:236m` | - | `bg=0x303030` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_237 | `\e[48:5:237m` | - | `bg=0x3A3A3A` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_238 | `\e[48:5:238m` | - | `bg=0x444444` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_239 | `\e[48:5:239m` | - | `bg=0x4E4E4E` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_240 | `\e[48:5:240m` | - | `bg=0x585858` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_241 | `\e[48:5:241m` | - | `bg=0x626262` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_242 | `\e[48:5:242m` | - | `bg=0x6C6C6C` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_243 | `\e[48:5:243m` | - | `bg=0x767676` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_244 | `\e[48:5:244m` | - | `bg=0x808080` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_245 | `\e[48:5:245m` | - | `bg=0x8A8A8A` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_246 | `\e[48:5:246m` | - | `bg=0x949494` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_247 | `\e[48:5:247m` | - | `bg=0x9E9E9E` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_248 | `\e[48:5:248m` | - | `bg=0xA8A8A8` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_249 | `\e[48:5:249m` | - | `bg=0xB2B2B2` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_250 | `\e[48:5:250m` | - | `bg=0xBCBCBC` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_251 | `\e[48:5:251m` | - | `bg=0xC6C6C6` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_252 | `\e[48:5:252m` | - | `bg=0xD0D0D0` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_253 | `\e[48:5:253m` | - | `bg=0xDADADA` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_254 | `\e[48:5:254m` | - | `bg=0xE4E4E4` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_bg_255 | `\e[48:5:255m` | - | `bg=0xEEEEEE` | 0 | 11 | T.416 indexed background palette |
| sgr | colon_index_sp_000 | `\e[58:5:0m` | - | `sp=0x000000` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_001 | `\e[58:5:1m` | - | `sp=0xCD0000` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_002 | `\e[58:5:2m` | - | `sp=0x00CD00` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_003 | `\e[58:5:3m` | - | `sp=0xCDCD00` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_004 | `\e[58:5:4m` | - | `sp=0x0000EE` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_005 | `\e[58:5:5m` | - | `sp=0xCD00CD` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_006 | `\e[58:5:6m` | - | `sp=0x00CDCD` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_007 | `\e[58:5:7m` | - | `sp=0xE5E5E5` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_008 | `\e[58:5:8m` | - | `sp=0x7F7F7F` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_009 | `\e[58:5:9m` | - | `sp=0xFF0000` | 0 | 9 | T.416 indexed underline palette |
| sgr | colon_index_sp_010 | `\e[58:5:10m` | - | `sp=0x00FF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_011 | `\e[58:5:11m` | - | `sp=0xFFFF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_012 | `\e[58:5:12m` | - | `sp=0x5C5CFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_013 | `\e[58:5:13m` | - | `sp=0xFF00FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_014 | `\e[58:5:14m` | - | `sp=0x00FFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_015 | `\e[58:5:15m` | - | `sp=0xFFFFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_016 | `\e[58:5:16m` | - | `sp=0x000000` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_017 | `\e[58:5:17m` | - | `sp=0x00005F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_018 | `\e[58:5:18m` | - | `sp=0x000087` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_019 | `\e[58:5:19m` | - | `sp=0x0000AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_020 | `\e[58:5:20m` | - | `sp=0x0000D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_021 | `\e[58:5:21m` | - | `sp=0x0000FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_022 | `\e[58:5:22m` | - | `sp=0x005F00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_023 | `\e[58:5:23m` | - | `sp=0x005F5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_024 | `\e[58:5:24m` | - | `sp=0x005F87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_025 | `\e[58:5:25m` | - | `sp=0x005FAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_026 | `\e[58:5:26m` | - | `sp=0x005FD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_027 | `\e[58:5:27m` | - | `sp=0x005FFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_028 | `\e[58:5:28m` | - | `sp=0x008700` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_029 | `\e[58:5:29m` | - | `sp=0x00875F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_030 | `\e[58:5:30m` | - | `sp=0x008787` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_031 | `\e[58:5:31m` | - | `sp=0x0087AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_032 | `\e[58:5:32m` | - | `sp=0x0087D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_033 | `\e[58:5:33m` | - | `sp=0x0087FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_034 | `\e[58:5:34m` | - | `sp=0x00AF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_035 | `\e[58:5:35m` | - | `sp=0x00AF5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_036 | `\e[58:5:36m` | - | `sp=0x00AF87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_037 | `\e[58:5:37m` | - | `sp=0x00AFAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_038 | `\e[58:5:38m` | - | `sp=0x00AFD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_039 | `\e[58:5:39m` | - | `sp=0x00AFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_040 | `\e[58:5:40m` | - | `sp=0x00D700` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_041 | `\e[58:5:41m` | - | `sp=0x00D75F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_042 | `\e[58:5:42m` | - | `sp=0x00D787` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_043 | `\e[58:5:43m` | - | `sp=0x00D7AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_044 | `\e[58:5:44m` | - | `sp=0x00D7D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_045 | `\e[58:5:45m` | - | `sp=0x00D7FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_046 | `\e[58:5:46m` | - | `sp=0x00FF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_047 | `\e[58:5:47m` | - | `sp=0x00FF5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_048 | `\e[58:5:48m` | - | `sp=0x00FF87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_049 | `\e[58:5:49m` | - | `sp=0x00FFAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_050 | `\e[58:5:50m` | - | `sp=0x00FFD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_051 | `\e[58:5:51m` | - | `sp=0x00FFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_052 | `\e[58:5:52m` | - | `sp=0x5F0000` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_053 | `\e[58:5:53m` | - | `sp=0x5F005F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_054 | `\e[58:5:54m` | - | `sp=0x5F0087` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_055 | `\e[58:5:55m` | - | `sp=0x5F00AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_056 | `\e[58:5:56m` | - | `sp=0x5F00D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_057 | `\e[58:5:57m` | - | `sp=0x5F00FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_058 | `\e[58:5:58m` | - | `sp=0x5F5F00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_059 | `\e[58:5:59m` | - | `sp=0x5F5F5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_060 | `\e[58:5:60m` | - | `sp=0x5F5F87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_061 | `\e[58:5:61m` | - | `sp=0x5F5FAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_062 | `\e[58:5:62m` | - | `sp=0x5F5FD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_063 | `\e[58:5:63m` | - | `sp=0x5F5FFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_064 | `\e[58:5:64m` | - | `sp=0x5F8700` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_065 | `\e[58:5:65m` | - | `sp=0x5F875F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_066 | `\e[58:5:66m` | - | `sp=0x5F8787` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_067 | `\e[58:5:67m` | - | `sp=0x5F87AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_068 | `\e[58:5:68m` | - | `sp=0x5F87D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_069 | `\e[58:5:69m` | - | `sp=0x5F87FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_070 | `\e[58:5:70m` | - | `sp=0x5FAF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_071 | `\e[58:5:71m` | - | `sp=0x5FAF5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_072 | `\e[58:5:72m` | - | `sp=0x5FAF87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_073 | `\e[58:5:73m` | - | `sp=0x5FAFAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_074 | `\e[58:5:74m` | - | `sp=0x5FAFD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_075 | `\e[58:5:75m` | - | `sp=0x5FAFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_076 | `\e[58:5:76m` | - | `sp=0x5FD700` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_077 | `\e[58:5:77m` | - | `sp=0x5FD75F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_078 | `\e[58:5:78m` | - | `sp=0x5FD787` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_079 | `\e[58:5:79m` | - | `sp=0x5FD7AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_080 | `\e[58:5:80m` | - | `sp=0x5FD7D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_081 | `\e[58:5:81m` | - | `sp=0x5FD7FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_082 | `\e[58:5:82m` | - | `sp=0x5FFF00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_083 | `\e[58:5:83m` | - | `sp=0x5FFF5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_084 | `\e[58:5:84m` | - | `sp=0x5FFF87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_085 | `\e[58:5:85m` | - | `sp=0x5FFFAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_086 | `\e[58:5:86m` | - | `sp=0x5FFFD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_087 | `\e[58:5:87m` | - | `sp=0x5FFFFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_088 | `\e[58:5:88m` | - | `sp=0x870000` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_089 | `\e[58:5:89m` | - | `sp=0x87005F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_090 | `\e[58:5:90m` | - | `sp=0x870087` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_091 | `\e[58:5:91m` | - | `sp=0x8700AF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_092 | `\e[58:5:92m` | - | `sp=0x8700D7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_093 | `\e[58:5:93m` | - | `sp=0x8700FF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_094 | `\e[58:5:94m` | - | `sp=0x875F00` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_095 | `\e[58:5:95m` | - | `sp=0x875F5F` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_096 | `\e[58:5:96m` | - | `sp=0x875F87` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_097 | `\e[58:5:97m` | - | `sp=0x875FAF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_098 | `\e[58:5:98m` | - | `sp=0x875FD7` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_099 | `\e[58:5:99m` | - | `sp=0x875FFF` | 0 | 10 | T.416 indexed underline palette |
| sgr | colon_index_sp_100 | `\e[58:5:100m` | - | `sp=0x878700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_101 | `\e[58:5:101m` | - | `sp=0x87875F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_102 | `\e[58:5:102m` | - | `sp=0x878787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_103 | `\e[58:5:103m` | - | `sp=0x8787AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_104 | `\e[58:5:104m` | - | `sp=0x8787D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_105 | `\e[58:5:105m` | - | `sp=0x8787FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_106 | `\e[58:5:106m` | - | `sp=0x87AF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_107 | `\e[58:5:107m` | - | `sp=0x87AF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_108 | `\e[58:5:108m` | - | `sp=0x87AF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_109 | `\e[58:5:109m` | - | `sp=0x87AFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_110 | `\e[58:5:110m` | - | `sp=0x87AFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_111 | `\e[58:5:111m` | - | `sp=0x87AFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_112 | `\e[58:5:112m` | - | `sp=0x87D700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_113 | `\e[58:5:113m` | - | `sp=0x87D75F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_114 | `\e[58:5:114m` | - | `sp=0x87D787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_115 | `\e[58:5:115m` | - | `sp=0x87D7AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_116 | `\e[58:5:116m` | - | `sp=0x87D7D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_117 | `\e[58:5:117m` | - | `sp=0x87D7FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_118 | `\e[58:5:118m` | - | `sp=0x87FF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_119 | `\e[58:5:119m` | - | `sp=0x87FF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_120 | `\e[58:5:120m` | - | `sp=0x87FF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_121 | `\e[58:5:121m` | - | `sp=0x87FFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_122 | `\e[58:5:122m` | - | `sp=0x87FFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_123 | `\e[58:5:123m` | - | `sp=0x87FFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_124 | `\e[58:5:124m` | - | `sp=0xAF0000` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_125 | `\e[58:5:125m` | - | `sp=0xAF005F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_126 | `\e[58:5:126m` | - | `sp=0xAF0087` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_127 | `\e[58:5:127m` | - | `sp=0xAF00AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_128 | `\e[58:5:128m` | - | `sp=0xAF00D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_129 | `\e[58:5:129m` | - | `sp=0xAF00FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_130 | `\e[58:5:130m` | - | `sp=0xAF5F00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_131 | `\e[58:5:131m` | - | `sp=0xAF5F5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_132 | `\e[58:5:132m` | - | `sp=0xAF5F87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_133 | `\e[58:5:133m` | - | `sp=0xAF5FAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_134 | `\e[58:5:134m` | - | `sp=0xAF5FD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_135 | `\e[58:5:135m` | - | `sp=0xAF5FFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_136 | `\e[58:5:136m` | - | `sp=0xAF8700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_137 | `\e[58:5:137m` | - | `sp=0xAF875F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_138 | `\e[58:5:138m` | - | `sp=0xAF8787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_139 | `\e[58:5:139m` | - | `sp=0xAF87AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_140 | `\e[58:5:140m` | - | `sp=0xAF87D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_141 | `\e[58:5:141m` | - | `sp=0xAF87FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_142 | `\e[58:5:142m` | - | `sp=0xAFAF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_143 | `\e[58:5:143m` | - | `sp=0xAFAF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_144 | `\e[58:5:144m` | - | `sp=0xAFAF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_145 | `\e[58:5:145m` | - | `sp=0xAFAFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_146 | `\e[58:5:146m` | - | `sp=0xAFAFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_147 | `\e[58:5:147m` | - | `sp=0xAFAFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_148 | `\e[58:5:148m` | - | `sp=0xAFD700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_149 | `\e[58:5:149m` | - | `sp=0xAFD75F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_150 | `\e[58:5:150m` | - | `sp=0xAFD787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_151 | `\e[58:5:151m` | - | `sp=0xAFD7AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_152 | `\e[58:5:152m` | - | `sp=0xAFD7D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_153 | `\e[58:5:153m` | - | `sp=0xAFD7FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_154 | `\e[58:5:154m` | - | `sp=0xAFFF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_155 | `\e[58:5:155m` | - | `sp=0xAFFF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_156 | `\e[58:5:156m` | - | `sp=0xAFFF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_157 | `\e[58:5:157m` | - | `sp=0xAFFFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_158 | `\e[58:5:158m` | - | `sp=0xAFFFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_159 | `\e[58:5:159m` | - | `sp=0xAFFFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_160 | `\e[58:5:160m` | - | `sp=0xD70000` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_161 | `\e[58:5:161m` | - | `sp=0xD7005F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_162 | `\e[58:5:162m` | - | `sp=0xD70087` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_163 | `\e[58:5:163m` | - | `sp=0xD700AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_164 | `\e[58:5:164m` | - | `sp=0xD700D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_165 | `\e[58:5:165m` | - | `sp=0xD700FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_166 | `\e[58:5:166m` | - | `sp=0xD75F00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_167 | `\e[58:5:167m` | - | `sp=0xD75F5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_168 | `\e[58:5:168m` | - | `sp=0xD75F87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_169 | `\e[58:5:169m` | - | `sp=0xD75FAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_170 | `\e[58:5:170m` | - | `sp=0xD75FD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_171 | `\e[58:5:171m` | - | `sp=0xD75FFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_172 | `\e[58:5:172m` | - | `sp=0xD78700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_173 | `\e[58:5:173m` | - | `sp=0xD7875F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_174 | `\e[58:5:174m` | - | `sp=0xD78787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_175 | `\e[58:5:175m` | - | `sp=0xD787AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_176 | `\e[58:5:176m` | - | `sp=0xD787D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_177 | `\e[58:5:177m` | - | `sp=0xD787FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_178 | `\e[58:5:178m` | - | `sp=0xD7AF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_179 | `\e[58:5:179m` | - | `sp=0xD7AF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_180 | `\e[58:5:180m` | - | `sp=0xD7AF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_181 | `\e[58:5:181m` | - | `sp=0xD7AFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_182 | `\e[58:5:182m` | - | `sp=0xD7AFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_183 | `\e[58:5:183m` | - | `sp=0xD7AFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_184 | `\e[58:5:184m` | - | `sp=0xD7D700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_185 | `\e[58:5:185m` | - | `sp=0xD7D75F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_186 | `\e[58:5:186m` | - | `sp=0xD7D787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_187 | `\e[58:5:187m` | - | `sp=0xD7D7AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_188 | `\e[58:5:188m` | - | `sp=0xD7D7D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_189 | `\e[58:5:189m` | - | `sp=0xD7D7FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_190 | `\e[58:5:190m` | - | `sp=0xD7FF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_191 | `\e[58:5:191m` | - | `sp=0xD7FF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_192 | `\e[58:5:192m` | - | `sp=0xD7FF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_193 | `\e[58:5:193m` | - | `sp=0xD7FFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_194 | `\e[58:5:194m` | - | `sp=0xD7FFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_195 | `\e[58:5:195m` | - | `sp=0xD7FFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_196 | `\e[58:5:196m` | - | `sp=0xFF0000` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_197 | `\e[58:5:197m` | - | `sp=0xFF005F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_198 | `\e[58:5:198m` | - | `sp=0xFF0087` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_199 | `\e[58:5:199m` | - | `sp=0xFF00AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_200 | `\e[58:5:200m` | - | `sp=0xFF00D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_201 | `\e[58:5:201m` | - | `sp=0xFF00FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_202 | `\e[58:5:202m` | - | `sp=0xFF5F00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_203 | `\e[58:5:203m` | - | `sp=0xFF5F5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_204 | `\e[58:5:204m` | - | `sp=0xFF5F87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_205 | `\e[58:5:205m` | - | `sp=0xFF5FAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_206 | `\e[58:5:206m` | - | `sp=0xFF5FD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_207 | `\e[58:5:207m` | - | `sp=0xFF5FFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_208 | `\e[58:5:208m` | - | `sp=0xFF8700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_209 | `\e[58:5:209m` | - | `sp=0xFF875F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_210 | `\e[58:5:210m` | - | `sp=0xFF8787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_211 | `\e[58:5:211m` | - | `sp=0xFF87AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_212 | `\e[58:5:212m` | - | `sp=0xFF87D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_213 | `\e[58:5:213m` | - | `sp=0xFF87FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_214 | `\e[58:5:214m` | - | `sp=0xFFAF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_215 | `\e[58:5:215m` | - | `sp=0xFFAF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_216 | `\e[58:5:216m` | - | `sp=0xFFAF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_217 | `\e[58:5:217m` | - | `sp=0xFFAFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_218 | `\e[58:5:218m` | - | `sp=0xFFAFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_219 | `\e[58:5:219m` | - | `sp=0xFFAFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_220 | `\e[58:5:220m` | - | `sp=0xFFD700` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_221 | `\e[58:5:221m` | - | `sp=0xFFD75F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_222 | `\e[58:5:222m` | - | `sp=0xFFD787` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_223 | `\e[58:5:223m` | - | `sp=0xFFD7AF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_224 | `\e[58:5:224m` | - | `sp=0xFFD7D7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_225 | `\e[58:5:225m` | - | `sp=0xFFD7FF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_226 | `\e[58:5:226m` | - | `sp=0xFFFF00` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_227 | `\e[58:5:227m` | - | `sp=0xFFFF5F` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_228 | `\e[58:5:228m` | - | `sp=0xFFFF87` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_229 | `\e[58:5:229m` | - | `sp=0xFFFFAF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_230 | `\e[58:5:230m` | - | `sp=0xFFFFD7` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_231 | `\e[58:5:231m` | - | `sp=0xFFFFFF` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_232 | `\e[58:5:232m` | - | `sp=0x080808` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_233 | `\e[58:5:233m` | - | `sp=0x121212` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_234 | `\e[58:5:234m` | - | `sp=0x1C1C1C` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_235 | `\e[58:5:235m` | - | `sp=0x262626` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_236 | `\e[58:5:236m` | - | `sp=0x303030` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_237 | `\e[58:5:237m` | - | `sp=0x3A3A3A` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_238 | `\e[58:5:238m` | - | `sp=0x444444` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_239 | `\e[58:5:239m` | - | `sp=0x4E4E4E` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_240 | `\e[58:5:240m` | - | `sp=0x585858` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_241 | `\e[58:5:241m` | - | `sp=0x626262` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_242 | `\e[58:5:242m` | - | `sp=0x6C6C6C` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_243 | `\e[58:5:243m` | - | `sp=0x767676` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_244 | `\e[58:5:244m` | - | `sp=0x808080` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_245 | `\e[58:5:245m` | - | `sp=0x8A8A8A` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_246 | `\e[58:5:246m` | - | `sp=0x949494` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_247 | `\e[58:5:247m` | - | `sp=0x9E9E9E` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_248 | `\e[58:5:248m` | - | `sp=0xA8A8A8` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_249 | `\e[58:5:249m` | - | `sp=0xB2B2B2` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_250 | `\e[58:5:250m` | - | `sp=0xBCBCBC` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_251 | `\e[58:5:251m` | - | `sp=0xC6C6C6` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_252 | `\e[58:5:252m` | - | `sp=0xD0D0D0` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_253 | `\e[58:5:253m` | - | `sp=0xDADADA` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_254 | `\e[58:5:254m` | - | `sp=0xE4E4E4` | 0 | 11 | T.416 indexed underline palette |
| sgr | colon_index_sp_255 | `\e[58:5:255m` | - | `sp=0xEEEEEE` | 0 | 11 | T.416 indexed underline palette |

## sgr xterm RGB

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | rgb_black | `\e[38;2;0;0;0m` | - | `fg=0x000000` | 0 | 13 | zero channels |
| sgr | rgb_white | `\e[38;2;255;255;255m` | - | `fg=0xFFFFFF` | 0 | 19 | maximum channels |
| sgr | rgb_red | `\e[38;2;255;0;0m` | - | `fg=0xFF0000` | 0 | 15 | red boundary |
| sgr | rgb_green | `\e[38;2;0;255;0m` | - | `fg=0x00FF00` | 0 | 15 | green boundary |
| sgr | rgb_blue | `\e[38;2;0;0;255m` | - | `fg=0x0000FF` | 0 | 15 | blue boundary |
| sgr | rgb_yellow | `\e[38;2;255;255;0m` | - | `fg=0xFFFF00` | 0 | 17 | red + green |
| sgr | rgb_magenta | `\e[38;2;255;0;255m` | - | `fg=0xFF00FF` | 0 | 17 | red + blue |
| sgr | rgb_cyan | `\e[38;2;0;255;255m` | - | `fg=0x00FFFF` | 0 | 17 | green + blue |
| sgr | rgb_arbitrary | `\e[38;2;1;2;3m` | - | `fg=0x010203` | 0 | 13 | channel order |
| sgr | rgb_mixed | `\e[38;2;128;64;192m` | - | `fg=0x8040C0` | 0 | 18 | mixed channels |
| sgr | rgb_attr_before | `\e[1;38;2;35;17;41m` | - | `fg=0x231129` | 0 | 18 | attribute before truecolor |
| sgr | rgb_attr_after | `\e[38;2;253;200;15;6m` | - | `fg=0xFDC80F` | 0 | 20 | attribute after truecolor |
| sgr | rgb_bg_black | `\e[48;2;0;0;0m` | - | `bg=0x000000` | 0 | 13 | background zero |
| sgr | rgb_bg_orange | `\e[48;2;255;165;0m` | - | `bg=0xFFA500` | 0 | 17 | background orange |
| sgr | rgb_bg_after_fg | `\e[31;48;2;6;197;164m` | - | `fg=0xCD0000,bg=0x06C5A4` | 0 | 20 | background after ANSI fg |
| sgr | rgb_sp_arbitrary | `\e[58;2;1;2;3m` | - | `sp=0x010203` | 0 | 13 | underline channel order |
| sgr | rgb_sp_mixed | `\e[58;2;81;155;120m` | - | `sp=0x519B78` | 0 | 18 | underline mixed |
| sgr | rgb_grid_0_0_0 | `\e[38;2;0;0;0m` | - | `fg=0x000000` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_0 | `\e[48;2;0;0;0m` | - | `bg=0x000000` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_0 | `\e[58;2;0;0;0m` | - | `sp=0x000000` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_0 | `\e[38:2::0:0:0m` | - | `fg=0x000000` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_0 | `\e[48:2::0:0:0m` | - | `bg=0x000000` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_0 | `\e[58:2::0:0:0m` | - | `sp=0x000000` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_0_1 | `\e[38;2;0;0;1m` | - | `fg=0x000001` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_1 | `\e[48;2;0;0;1m` | - | `bg=0x000001` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_1 | `\e[58;2;0;0;1m` | - | `sp=0x000001` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_1 | `\e[38:2::0:0:1m` | - | `fg=0x000001` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_1 | `\e[48:2::0:0:1m` | - | `bg=0x000001` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_1 | `\e[58:2::0:0:1m` | - | `sp=0x000001` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_0_127 | `\e[38;2;0;0;127m` | - | `fg=0x00007F` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_127 | `\e[48;2;0;0;127m` | - | `bg=0x00007F` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_127 | `\e[58;2;0;0;127m` | - | `sp=0x00007F` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_127 | `\e[38:2::0:0:127m` | - | `fg=0x00007F` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_127 | `\e[48:2::0:0:127m` | - | `bg=0x00007F` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_127 | `\e[58:2::0:0:127m` | - | `sp=0x00007F` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_0_128 | `\e[38;2;0;0;128m` | - | `fg=0x000080` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_128 | `\e[48;2;0;0;128m` | - | `bg=0x000080` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_128 | `\e[58;2;0;0;128m` | - | `sp=0x000080` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_128 | `\e[38:2::0:0:128m` | - | `fg=0x000080` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_128 | `\e[48:2::0:0:128m` | - | `bg=0x000080` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_128 | `\e[58:2::0:0:128m` | - | `sp=0x000080` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_0_254 | `\e[38;2;0;0;254m` | - | `fg=0x0000FE` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_254 | `\e[48;2;0;0;254m` | - | `bg=0x0000FE` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_254 | `\e[58;2;0;0;254m` | - | `sp=0x0000FE` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_254 | `\e[38:2::0:0:254m` | - | `fg=0x0000FE` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_254 | `\e[48:2::0:0:254m` | - | `bg=0x0000FE` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_254 | `\e[58:2::0:0:254m` | - | `sp=0x0000FE` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_0_255 | `\e[38;2;0;0;255m` | - | `fg=0x0000FF` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_0_255 | `\e[48;2;0;0;255m` | - | `bg=0x0000FF` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_0_255 | `\e[58;2;0;0;255m` | - | `sp=0x0000FF` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_0_255 | `\e[38:2::0:0:255m` | - | `fg=0x0000FF` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_0_255 | `\e[48:2::0:0:255m` | - | `bg=0x0000FF` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_0_255 | `\e[58:2::0:0:255m` | - | `sp=0x0000FF` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_0 | `\e[38;2;0;1;0m` | - | `fg=0x000100` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_0 | `\e[48;2;0;1;0m` | - | `bg=0x000100` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_0 | `\e[58;2;0;1;0m` | - | `sp=0x000100` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_0 | `\e[38:2::0:1:0m` | - | `fg=0x000100` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_0 | `\e[48:2::0:1:0m` | - | `bg=0x000100` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_0 | `\e[58:2::0:1:0m` | - | `sp=0x000100` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_1 | `\e[38;2;0;1;1m` | - | `fg=0x000101` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_1 | `\e[48;2;0;1;1m` | - | `bg=0x000101` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_1 | `\e[58;2;0;1;1m` | - | `sp=0x000101` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_1 | `\e[38:2::0:1:1m` | - | `fg=0x000101` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_1 | `\e[48:2::0:1:1m` | - | `bg=0x000101` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_1 | `\e[58:2::0:1:1m` | - | `sp=0x000101` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_127 | `\e[38;2;0;1;127m` | - | `fg=0x00017F` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_127 | `\e[48;2;0;1;127m` | - | `bg=0x00017F` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_127 | `\e[58;2;0;1;127m` | - | `sp=0x00017F` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_127 | `\e[38:2::0:1:127m` | - | `fg=0x00017F` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_127 | `\e[48:2::0:1:127m` | - | `bg=0x00017F` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_127 | `\e[58:2::0:1:127m` | - | `sp=0x00017F` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_128 | `\e[38;2;0;1;128m` | - | `fg=0x000180` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_128 | `\e[48;2;0;1;128m` | - | `bg=0x000180` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_128 | `\e[58;2;0;1;128m` | - | `sp=0x000180` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_128 | `\e[38:2::0:1:128m` | - | `fg=0x000180` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_128 | `\e[48:2::0:1:128m` | - | `bg=0x000180` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_128 | `\e[58:2::0:1:128m` | - | `sp=0x000180` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_254 | `\e[38;2;0;1;254m` | - | `fg=0x0001FE` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_254 | `\e[48;2;0;1;254m` | - | `bg=0x0001FE` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_254 | `\e[58;2;0;1;254m` | - | `sp=0x0001FE` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_254 | `\e[38:2::0:1:254m` | - | `fg=0x0001FE` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_254 | `\e[48:2::0:1:254m` | - | `bg=0x0001FE` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_254 | `\e[58:2::0:1:254m` | - | `sp=0x0001FE` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_1_255 | `\e[38;2;0;1;255m` | - | `fg=0x0001FF` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_1_255 | `\e[48;2;0;1;255m` | - | `bg=0x0001FF` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_1_255 | `\e[58;2;0;1;255m` | - | `sp=0x0001FF` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_1_255 | `\e[38:2::0:1:255m` | - | `fg=0x0001FF` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_1_255 | `\e[48:2::0:1:255m` | - | `bg=0x0001FF` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_1_255 | `\e[58:2::0:1:255m` | - | `sp=0x0001FF` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_0 | `\e[38;2;0;127;0m` | - | `fg=0x007F00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_0 | `\e[48;2;0;127;0m` | - | `bg=0x007F00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_0 | `\e[58;2;0;127;0m` | - | `sp=0x007F00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_0 | `\e[38:2::0:127:0m` | - | `fg=0x007F00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_0 | `\e[48:2::0:127:0m` | - | `bg=0x007F00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_0 | `\e[58:2::0:127:0m` | - | `sp=0x007F00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_1 | `\e[38;2;0;127;1m` | - | `fg=0x007F01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_1 | `\e[48;2;0;127;1m` | - | `bg=0x007F01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_1 | `\e[58;2;0;127;1m` | - | `sp=0x007F01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_1 | `\e[38:2::0:127:1m` | - | `fg=0x007F01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_1 | `\e[48:2::0:127:1m` | - | `bg=0x007F01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_1 | `\e[58:2::0:127:1m` | - | `sp=0x007F01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_127 | `\e[38;2;0;127;127m` | - | `fg=0x007F7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_127 | `\e[48;2;0;127;127m` | - | `bg=0x007F7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_127 | `\e[58;2;0;127;127m` | - | `sp=0x007F7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_127 | `\e[38:2::0:127:127m` | - | `fg=0x007F7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_127 | `\e[48:2::0:127:127m` | - | `bg=0x007F7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_127 | `\e[58:2::0:127:127m` | - | `sp=0x007F7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_128 | `\e[38;2;0;127;128m` | - | `fg=0x007F80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_128 | `\e[48;2;0;127;128m` | - | `bg=0x007F80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_128 | `\e[58;2;0;127;128m` | - | `sp=0x007F80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_128 | `\e[38:2::0:127:128m` | - | `fg=0x007F80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_128 | `\e[48:2::0:127:128m` | - | `bg=0x007F80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_128 | `\e[58:2::0:127:128m` | - | `sp=0x007F80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_254 | `\e[38;2;0;127;254m` | - | `fg=0x007FFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_254 | `\e[48;2;0;127;254m` | - | `bg=0x007FFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_254 | `\e[58;2;0;127;254m` | - | `sp=0x007FFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_254 | `\e[38:2::0:127:254m` | - | `fg=0x007FFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_254 | `\e[48:2::0:127:254m` | - | `bg=0x007FFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_254 | `\e[58:2::0:127:254m` | - | `sp=0x007FFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_127_255 | `\e[38;2;0;127;255m` | - | `fg=0x007FFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_127_255 | `\e[48;2;0;127;255m` | - | `bg=0x007FFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_127_255 | `\e[58;2;0;127;255m` | - | `sp=0x007FFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_127_255 | `\e[38:2::0:127:255m` | - | `fg=0x007FFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_127_255 | `\e[48:2::0:127:255m` | - | `bg=0x007FFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_127_255 | `\e[58:2::0:127:255m` | - | `sp=0x007FFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_0 | `\e[38;2;0;128;0m` | - | `fg=0x008000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_0 | `\e[48;2;0;128;0m` | - | `bg=0x008000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_0 | `\e[58;2;0;128;0m` | - | `sp=0x008000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_0 | `\e[38:2::0:128:0m` | - | `fg=0x008000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_0 | `\e[48:2::0:128:0m` | - | `bg=0x008000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_0 | `\e[58:2::0:128:0m` | - | `sp=0x008000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_1 | `\e[38;2;0;128;1m` | - | `fg=0x008001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_1 | `\e[48;2;0;128;1m` | - | `bg=0x008001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_1 | `\e[58;2;0;128;1m` | - | `sp=0x008001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_1 | `\e[38:2::0:128:1m` | - | `fg=0x008001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_1 | `\e[48:2::0:128:1m` | - | `bg=0x008001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_1 | `\e[58:2::0:128:1m` | - | `sp=0x008001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_127 | `\e[38;2;0;128;127m` | - | `fg=0x00807F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_127 | `\e[48;2;0;128;127m` | - | `bg=0x00807F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_127 | `\e[58;2;0;128;127m` | - | `sp=0x00807F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_127 | `\e[38:2::0:128:127m` | - | `fg=0x00807F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_127 | `\e[48:2::0:128:127m` | - | `bg=0x00807F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_127 | `\e[58:2::0:128:127m` | - | `sp=0x00807F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_128 | `\e[38;2;0;128;128m` | - | `fg=0x008080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_128 | `\e[48;2;0;128;128m` | - | `bg=0x008080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_128 | `\e[58;2;0;128;128m` | - | `sp=0x008080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_128 | `\e[38:2::0:128:128m` | - | `fg=0x008080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_128 | `\e[48:2::0:128:128m` | - | `bg=0x008080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_128 | `\e[58:2::0:128:128m` | - | `sp=0x008080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_254 | `\e[38;2;0;128;254m` | - | `fg=0x0080FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_254 | `\e[48;2;0;128;254m` | - | `bg=0x0080FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_254 | `\e[58;2;0;128;254m` | - | `sp=0x0080FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_254 | `\e[38:2::0:128:254m` | - | `fg=0x0080FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_254 | `\e[48:2::0:128:254m` | - | `bg=0x0080FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_254 | `\e[58:2::0:128:254m` | - | `sp=0x0080FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_128_255 | `\e[38;2;0;128;255m` | - | `fg=0x0080FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_128_255 | `\e[48;2;0;128;255m` | - | `bg=0x0080FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_128_255 | `\e[58;2;0;128;255m` | - | `sp=0x0080FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_128_255 | `\e[38:2::0:128:255m` | - | `fg=0x0080FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_128_255 | `\e[48:2::0:128:255m` | - | `bg=0x0080FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_128_255 | `\e[58:2::0:128:255m` | - | `sp=0x0080FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_0 | `\e[38;2;0;254;0m` | - | `fg=0x00FE00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_0 | `\e[48;2;0;254;0m` | - | `bg=0x00FE00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_0 | `\e[58;2;0;254;0m` | - | `sp=0x00FE00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_0 | `\e[38:2::0:254:0m` | - | `fg=0x00FE00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_0 | `\e[48:2::0:254:0m` | - | `bg=0x00FE00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_0 | `\e[58:2::0:254:0m` | - | `sp=0x00FE00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_1 | `\e[38;2;0;254;1m` | - | `fg=0x00FE01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_1 | `\e[48;2;0;254;1m` | - | `bg=0x00FE01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_1 | `\e[58;2;0;254;1m` | - | `sp=0x00FE01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_1 | `\e[38:2::0:254:1m` | - | `fg=0x00FE01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_1 | `\e[48:2::0:254:1m` | - | `bg=0x00FE01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_1 | `\e[58:2::0:254:1m` | - | `sp=0x00FE01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_127 | `\e[38;2;0;254;127m` | - | `fg=0x00FE7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_127 | `\e[48;2;0;254;127m` | - | `bg=0x00FE7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_127 | `\e[58;2;0;254;127m` | - | `sp=0x00FE7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_127 | `\e[38:2::0:254:127m` | - | `fg=0x00FE7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_127 | `\e[48:2::0:254:127m` | - | `bg=0x00FE7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_127 | `\e[58:2::0:254:127m` | - | `sp=0x00FE7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_128 | `\e[38;2;0;254;128m` | - | `fg=0x00FE80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_128 | `\e[48;2;0;254;128m` | - | `bg=0x00FE80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_128 | `\e[58;2;0;254;128m` | - | `sp=0x00FE80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_128 | `\e[38:2::0:254:128m` | - | `fg=0x00FE80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_128 | `\e[48:2::0:254:128m` | - | `bg=0x00FE80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_128 | `\e[58:2::0:254:128m` | - | `sp=0x00FE80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_254 | `\e[38;2;0;254;254m` | - | `fg=0x00FEFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_254 | `\e[48;2;0;254;254m` | - | `bg=0x00FEFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_254 | `\e[58;2;0;254;254m` | - | `sp=0x00FEFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_254 | `\e[38:2::0:254:254m` | - | `fg=0x00FEFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_254 | `\e[48:2::0:254:254m` | - | `bg=0x00FEFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_254 | `\e[58:2::0:254:254m` | - | `sp=0x00FEFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_254_255 | `\e[38;2;0;254;255m` | - | `fg=0x00FEFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_254_255 | `\e[48;2;0;254;255m` | - | `bg=0x00FEFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_254_255 | `\e[58;2;0;254;255m` | - | `sp=0x00FEFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_254_255 | `\e[38:2::0:254:255m` | - | `fg=0x00FEFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_254_255 | `\e[48:2::0:254:255m` | - | `bg=0x00FEFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_254_255 | `\e[58:2::0:254:255m` | - | `sp=0x00FEFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_0 | `\e[38;2;0;255;0m` | - | `fg=0x00FF00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_0 | `\e[48;2;0;255;0m` | - | `bg=0x00FF00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_0 | `\e[58;2;0;255;0m` | - | `sp=0x00FF00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_0 | `\e[38:2::0:255:0m` | - | `fg=0x00FF00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_0 | `\e[48:2::0:255:0m` | - | `bg=0x00FF00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_0 | `\e[58:2::0:255:0m` | - | `sp=0x00FF00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_1 | `\e[38;2;0;255;1m` | - | `fg=0x00FF01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_1 | `\e[48;2;0;255;1m` | - | `bg=0x00FF01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_1 | `\e[58;2;0;255;1m` | - | `sp=0x00FF01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_1 | `\e[38:2::0:255:1m` | - | `fg=0x00FF01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_1 | `\e[48:2::0:255:1m` | - | `bg=0x00FF01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_1 | `\e[58:2::0:255:1m` | - | `sp=0x00FF01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_127 | `\e[38;2;0;255;127m` | - | `fg=0x00FF7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_127 | `\e[48;2;0;255;127m` | - | `bg=0x00FF7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_127 | `\e[58;2;0;255;127m` | - | `sp=0x00FF7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_127 | `\e[38:2::0:255:127m` | - | `fg=0x00FF7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_127 | `\e[48:2::0:255:127m` | - | `bg=0x00FF7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_127 | `\e[58:2::0:255:127m` | - | `sp=0x00FF7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_128 | `\e[38;2;0;255;128m` | - | `fg=0x00FF80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_128 | `\e[48;2;0;255;128m` | - | `bg=0x00FF80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_128 | `\e[58;2;0;255;128m` | - | `sp=0x00FF80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_128 | `\e[38:2::0:255:128m` | - | `fg=0x00FF80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_128 | `\e[48:2::0:255:128m` | - | `bg=0x00FF80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_128 | `\e[58:2::0:255:128m` | - | `sp=0x00FF80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_254 | `\e[38;2;0;255;254m` | - | `fg=0x00FFFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_254 | `\e[48;2;0;255;254m` | - | `bg=0x00FFFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_254 | `\e[58;2;0;255;254m` | - | `sp=0x00FFFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_254 | `\e[38:2::0:255:254m` | - | `fg=0x00FFFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_254 | `\e[48:2::0:255:254m` | - | `bg=0x00FFFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_254 | `\e[58:2::0:255:254m` | - | `sp=0x00FFFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_0_255_255 | `\e[38;2;0;255;255m` | - | `fg=0x00FFFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_0_255_255 | `\e[48;2;0;255;255m` | - | `bg=0x00FFFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_0_255_255 | `\e[58;2;0;255;255m` | - | `sp=0x00FFFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_0_255_255 | `\e[38:2::0:255:255m` | - | `fg=0x00FFFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_0_255_255 | `\e[48:2::0:255:255m` | - | `bg=0x00FFFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_0_255_255 | `\e[58:2::0:255:255m` | - | `sp=0x00FFFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_0 | `\e[38;2;1;0;0m` | - | `fg=0x010000` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_0 | `\e[48;2;1;0;0m` | - | `bg=0x010000` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_0 | `\e[58;2;1;0;0m` | - | `sp=0x010000` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_0 | `\e[38:2::1:0:0m` | - | `fg=0x010000` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_0 | `\e[48:2::1:0:0m` | - | `bg=0x010000` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_0 | `\e[58:2::1:0:0m` | - | `sp=0x010000` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_1 | `\e[38;2;1;0;1m` | - | `fg=0x010001` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_1 | `\e[48;2;1;0;1m` | - | `bg=0x010001` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_1 | `\e[58;2;1;0;1m` | - | `sp=0x010001` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_1 | `\e[38:2::1:0:1m` | - | `fg=0x010001` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_1 | `\e[48:2::1:0:1m` | - | `bg=0x010001` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_1 | `\e[58:2::1:0:1m` | - | `sp=0x010001` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_127 | `\e[38;2;1;0;127m` | - | `fg=0x01007F` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_127 | `\e[48;2;1;0;127m` | - | `bg=0x01007F` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_127 | `\e[58;2;1;0;127m` | - | `sp=0x01007F` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_127 | `\e[38:2::1:0:127m` | - | `fg=0x01007F` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_127 | `\e[48:2::1:0:127m` | - | `bg=0x01007F` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_127 | `\e[58:2::1:0:127m` | - | `sp=0x01007F` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_128 | `\e[38;2;1;0;128m` | - | `fg=0x010080` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_128 | `\e[48;2;1;0;128m` | - | `bg=0x010080` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_128 | `\e[58;2;1;0;128m` | - | `sp=0x010080` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_128 | `\e[38:2::1:0:128m` | - | `fg=0x010080` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_128 | `\e[48:2::1:0:128m` | - | `bg=0x010080` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_128 | `\e[58:2::1:0:128m` | - | `sp=0x010080` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_254 | `\e[38;2;1;0;254m` | - | `fg=0x0100FE` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_254 | `\e[48;2;1;0;254m` | - | `bg=0x0100FE` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_254 | `\e[58;2;1;0;254m` | - | `sp=0x0100FE` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_254 | `\e[38:2::1:0:254m` | - | `fg=0x0100FE` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_254 | `\e[48:2::1:0:254m` | - | `bg=0x0100FE` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_254 | `\e[58:2::1:0:254m` | - | `sp=0x0100FE` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_0_255 | `\e[38;2;1;0;255m` | - | `fg=0x0100FF` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_0_255 | `\e[48;2;1;0;255m` | - | `bg=0x0100FF` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_0_255 | `\e[58;2;1;0;255m` | - | `sp=0x0100FF` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_0_255 | `\e[38:2::1:0:255m` | - | `fg=0x0100FF` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_0_255 | `\e[48:2::1:0:255m` | - | `bg=0x0100FF` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_0_255 | `\e[58:2::1:0:255m` | - | `sp=0x0100FF` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_0 | `\e[38;2;1;1;0m` | - | `fg=0x010100` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_0 | `\e[48;2;1;1;0m` | - | `bg=0x010100` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_0 | `\e[58;2;1;1;0m` | - | `sp=0x010100` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_0 | `\e[38:2::1:1:0m` | - | `fg=0x010100` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_0 | `\e[48:2::1:1:0m` | - | `bg=0x010100` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_0 | `\e[58:2::1:1:0m` | - | `sp=0x010100` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_1 | `\e[38;2;1;1;1m` | - | `fg=0x010101` | 0 | 13 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_1 | `\e[48;2;1;1;1m` | - | `bg=0x010101` | 0 | 13 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_1 | `\e[58;2;1;1;1m` | - | `sp=0x010101` | 0 | 13 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_1 | `\e[38:2::1:1:1m` | - | `fg=0x010101` | 0 | 14 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_1 | `\e[48:2::1:1:1m` | - | `bg=0x010101` | 0 | 14 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_1 | `\e[58:2::1:1:1m` | - | `sp=0x010101` | 0 | 14 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_127 | `\e[38;2;1;1;127m` | - | `fg=0x01017F` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_127 | `\e[48;2;1;1;127m` | - | `bg=0x01017F` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_127 | `\e[58;2;1;1;127m` | - | `sp=0x01017F` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_127 | `\e[38:2::1:1:127m` | - | `fg=0x01017F` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_127 | `\e[48:2::1:1:127m` | - | `bg=0x01017F` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_127 | `\e[58:2::1:1:127m` | - | `sp=0x01017F` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_128 | `\e[38;2;1;1;128m` | - | `fg=0x010180` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_128 | `\e[48;2;1;1;128m` | - | `bg=0x010180` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_128 | `\e[58;2;1;1;128m` | - | `sp=0x010180` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_128 | `\e[38:2::1:1:128m` | - | `fg=0x010180` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_128 | `\e[48:2::1:1:128m` | - | `bg=0x010180` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_128 | `\e[58:2::1:1:128m` | - | `sp=0x010180` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_254 | `\e[38;2;1;1;254m` | - | `fg=0x0101FE` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_254 | `\e[48;2;1;1;254m` | - | `bg=0x0101FE` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_254 | `\e[58;2;1;1;254m` | - | `sp=0x0101FE` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_254 | `\e[38:2::1:1:254m` | - | `fg=0x0101FE` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_254 | `\e[48:2::1:1:254m` | - | `bg=0x0101FE` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_254 | `\e[58:2::1:1:254m` | - | `sp=0x0101FE` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_1_255 | `\e[38;2;1;1;255m` | - | `fg=0x0101FF` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_1_255 | `\e[48;2;1;1;255m` | - | `bg=0x0101FF` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_1_255 | `\e[58;2;1;1;255m` | - | `sp=0x0101FF` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_1_255 | `\e[38:2::1:1:255m` | - | `fg=0x0101FF` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_1_255 | `\e[48:2::1:1:255m` | - | `bg=0x0101FF` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_1_255 | `\e[58:2::1:1:255m` | - | `sp=0x0101FF` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_0 | `\e[38;2;1;127;0m` | - | `fg=0x017F00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_0 | `\e[48;2;1;127;0m` | - | `bg=0x017F00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_0 | `\e[58;2;1;127;0m` | - | `sp=0x017F00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_0 | `\e[38:2::1:127:0m` | - | `fg=0x017F00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_0 | `\e[48:2::1:127:0m` | - | `bg=0x017F00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_0 | `\e[58:2::1:127:0m` | - | `sp=0x017F00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_1 | `\e[38;2;1;127;1m` | - | `fg=0x017F01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_1 | `\e[48;2;1;127;1m` | - | `bg=0x017F01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_1 | `\e[58;2;1;127;1m` | - | `sp=0x017F01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_1 | `\e[38:2::1:127:1m` | - | `fg=0x017F01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_1 | `\e[48:2::1:127:1m` | - | `bg=0x017F01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_1 | `\e[58:2::1:127:1m` | - | `sp=0x017F01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_127 | `\e[38;2;1;127;127m` | - | `fg=0x017F7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_127 | `\e[48;2;1;127;127m` | - | `bg=0x017F7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_127 | `\e[58;2;1;127;127m` | - | `sp=0x017F7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_127 | `\e[38:2::1:127:127m` | - | `fg=0x017F7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_127 | `\e[48:2::1:127:127m` | - | `bg=0x017F7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_127 | `\e[58:2::1:127:127m` | - | `sp=0x017F7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_128 | `\e[38;2;1;127;128m` | - | `fg=0x017F80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_128 | `\e[48;2;1;127;128m` | - | `bg=0x017F80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_128 | `\e[58;2;1;127;128m` | - | `sp=0x017F80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_128 | `\e[38:2::1:127:128m` | - | `fg=0x017F80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_128 | `\e[48:2::1:127:128m` | - | `bg=0x017F80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_128 | `\e[58:2::1:127:128m` | - | `sp=0x017F80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_254 | `\e[38;2;1;127;254m` | - | `fg=0x017FFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_254 | `\e[48;2;1;127;254m` | - | `bg=0x017FFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_254 | `\e[58;2;1;127;254m` | - | `sp=0x017FFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_254 | `\e[38:2::1:127:254m` | - | `fg=0x017FFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_254 | `\e[48:2::1:127:254m` | - | `bg=0x017FFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_254 | `\e[58:2::1:127:254m` | - | `sp=0x017FFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_127_255 | `\e[38;2;1;127;255m` | - | `fg=0x017FFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_127_255 | `\e[48;2;1;127;255m` | - | `bg=0x017FFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_127_255 | `\e[58;2;1;127;255m` | - | `sp=0x017FFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_127_255 | `\e[38:2::1:127:255m` | - | `fg=0x017FFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_127_255 | `\e[48:2::1:127:255m` | - | `bg=0x017FFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_127_255 | `\e[58:2::1:127:255m` | - | `sp=0x017FFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_0 | `\e[38;2;1;128;0m` | - | `fg=0x018000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_0 | `\e[48;2;1;128;0m` | - | `bg=0x018000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_0 | `\e[58;2;1;128;0m` | - | `sp=0x018000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_0 | `\e[38:2::1:128:0m` | - | `fg=0x018000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_0 | `\e[48:2::1:128:0m` | - | `bg=0x018000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_0 | `\e[58:2::1:128:0m` | - | `sp=0x018000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_1 | `\e[38;2;1;128;1m` | - | `fg=0x018001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_1 | `\e[48;2;1;128;1m` | - | `bg=0x018001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_1 | `\e[58;2;1;128;1m` | - | `sp=0x018001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_1 | `\e[38:2::1:128:1m` | - | `fg=0x018001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_1 | `\e[48:2::1:128:1m` | - | `bg=0x018001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_1 | `\e[58:2::1:128:1m` | - | `sp=0x018001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_127 | `\e[38;2;1;128;127m` | - | `fg=0x01807F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_127 | `\e[48;2;1;128;127m` | - | `bg=0x01807F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_127 | `\e[58;2;1;128;127m` | - | `sp=0x01807F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_127 | `\e[38:2::1:128:127m` | - | `fg=0x01807F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_127 | `\e[48:2::1:128:127m` | - | `bg=0x01807F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_127 | `\e[58:2::1:128:127m` | - | `sp=0x01807F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_128 | `\e[38;2;1;128;128m` | - | `fg=0x018080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_128 | `\e[48;2;1;128;128m` | - | `bg=0x018080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_128 | `\e[58;2;1;128;128m` | - | `sp=0x018080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_128 | `\e[38:2::1:128:128m` | - | `fg=0x018080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_128 | `\e[48:2::1:128:128m` | - | `bg=0x018080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_128 | `\e[58:2::1:128:128m` | - | `sp=0x018080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_254 | `\e[38;2;1;128;254m` | - | `fg=0x0180FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_254 | `\e[48;2;1;128;254m` | - | `bg=0x0180FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_254 | `\e[58;2;1;128;254m` | - | `sp=0x0180FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_254 | `\e[38:2::1:128:254m` | - | `fg=0x0180FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_254 | `\e[48:2::1:128:254m` | - | `bg=0x0180FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_254 | `\e[58:2::1:128:254m` | - | `sp=0x0180FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_128_255 | `\e[38;2;1;128;255m` | - | `fg=0x0180FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_128_255 | `\e[48;2;1;128;255m` | - | `bg=0x0180FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_128_255 | `\e[58;2;1;128;255m` | - | `sp=0x0180FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_128_255 | `\e[38:2::1:128:255m` | - | `fg=0x0180FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_128_255 | `\e[48:2::1:128:255m` | - | `bg=0x0180FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_128_255 | `\e[58:2::1:128:255m` | - | `sp=0x0180FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_0 | `\e[38;2;1;254;0m` | - | `fg=0x01FE00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_0 | `\e[48;2;1;254;0m` | - | `bg=0x01FE00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_0 | `\e[58;2;1;254;0m` | - | `sp=0x01FE00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_0 | `\e[38:2::1:254:0m` | - | `fg=0x01FE00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_0 | `\e[48:2::1:254:0m` | - | `bg=0x01FE00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_0 | `\e[58:2::1:254:0m` | - | `sp=0x01FE00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_1 | `\e[38;2;1;254;1m` | - | `fg=0x01FE01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_1 | `\e[48;2;1;254;1m` | - | `bg=0x01FE01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_1 | `\e[58;2;1;254;1m` | - | `sp=0x01FE01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_1 | `\e[38:2::1:254:1m` | - | `fg=0x01FE01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_1 | `\e[48:2::1:254:1m` | - | `bg=0x01FE01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_1 | `\e[58:2::1:254:1m` | - | `sp=0x01FE01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_127 | `\e[38;2;1;254;127m` | - | `fg=0x01FE7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_127 | `\e[48;2;1;254;127m` | - | `bg=0x01FE7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_127 | `\e[58;2;1;254;127m` | - | `sp=0x01FE7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_127 | `\e[38:2::1:254:127m` | - | `fg=0x01FE7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_127 | `\e[48:2::1:254:127m` | - | `bg=0x01FE7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_127 | `\e[58:2::1:254:127m` | - | `sp=0x01FE7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_128 | `\e[38;2;1;254;128m` | - | `fg=0x01FE80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_128 | `\e[48;2;1;254;128m` | - | `bg=0x01FE80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_128 | `\e[58;2;1;254;128m` | - | `sp=0x01FE80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_128 | `\e[38:2::1:254:128m` | - | `fg=0x01FE80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_128 | `\e[48:2::1:254:128m` | - | `bg=0x01FE80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_128 | `\e[58:2::1:254:128m` | - | `sp=0x01FE80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_254 | `\e[38;2;1;254;254m` | - | `fg=0x01FEFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_254 | `\e[48;2;1;254;254m` | - | `bg=0x01FEFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_254 | `\e[58;2;1;254;254m` | - | `sp=0x01FEFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_254 | `\e[38:2::1:254:254m` | - | `fg=0x01FEFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_254 | `\e[48:2::1:254:254m` | - | `bg=0x01FEFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_254 | `\e[58:2::1:254:254m` | - | `sp=0x01FEFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_254_255 | `\e[38;2;1;254;255m` | - | `fg=0x01FEFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_254_255 | `\e[48;2;1;254;255m` | - | `bg=0x01FEFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_254_255 | `\e[58;2;1;254;255m` | - | `sp=0x01FEFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_254_255 | `\e[38:2::1:254:255m` | - | `fg=0x01FEFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_254_255 | `\e[48:2::1:254:255m` | - | `bg=0x01FEFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_254_255 | `\e[58:2::1:254:255m` | - | `sp=0x01FEFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_0 | `\e[38;2;1;255;0m` | - | `fg=0x01FF00` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_0 | `\e[48;2;1;255;0m` | - | `bg=0x01FF00` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_0 | `\e[58;2;1;255;0m` | - | `sp=0x01FF00` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_0 | `\e[38:2::1:255:0m` | - | `fg=0x01FF00` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_0 | `\e[48:2::1:255:0m` | - | `bg=0x01FF00` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_0 | `\e[58:2::1:255:0m` | - | `sp=0x01FF00` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_1 | `\e[38;2;1;255;1m` | - | `fg=0x01FF01` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_1 | `\e[48;2;1;255;1m` | - | `bg=0x01FF01` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_1 | `\e[58;2;1;255;1m` | - | `sp=0x01FF01` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_1 | `\e[38:2::1:255:1m` | - | `fg=0x01FF01` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_1 | `\e[48:2::1:255:1m` | - | `bg=0x01FF01` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_1 | `\e[58:2::1:255:1m` | - | `sp=0x01FF01` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_127 | `\e[38;2;1;255;127m` | - | `fg=0x01FF7F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_127 | `\e[48;2;1;255;127m` | - | `bg=0x01FF7F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_127 | `\e[58;2;1;255;127m` | - | `sp=0x01FF7F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_127 | `\e[38:2::1:255:127m` | - | `fg=0x01FF7F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_127 | `\e[48:2::1:255:127m` | - | `bg=0x01FF7F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_127 | `\e[58:2::1:255:127m` | - | `sp=0x01FF7F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_128 | `\e[38;2;1;255;128m` | - | `fg=0x01FF80` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_128 | `\e[48;2;1;255;128m` | - | `bg=0x01FF80` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_128 | `\e[58;2;1;255;128m` | - | `sp=0x01FF80` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_128 | `\e[38:2::1:255:128m` | - | `fg=0x01FF80` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_128 | `\e[48:2::1:255:128m` | - | `bg=0x01FF80` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_128 | `\e[58:2::1:255:128m` | - | `sp=0x01FF80` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_254 | `\e[38;2;1;255;254m` | - | `fg=0x01FFFE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_254 | `\e[48;2;1;255;254m` | - | `bg=0x01FFFE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_254 | `\e[58;2;1;255;254m` | - | `sp=0x01FFFE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_254 | `\e[38:2::1:255:254m` | - | `fg=0x01FFFE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_254 | `\e[48:2::1:255:254m` | - | `bg=0x01FFFE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_254 | `\e[58:2::1:255:254m` | - | `sp=0x01FFFE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_1_255_255 | `\e[38;2;1;255;255m` | - | `fg=0x01FFFF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_1_255_255 | `\e[48;2;1;255;255m` | - | `bg=0x01FFFF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_1_255_255 | `\e[58;2;1;255;255m` | - | `sp=0x01FFFF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_1_255_255 | `\e[38:2::1:255:255m` | - | `fg=0x01FFFF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_1_255_255 | `\e[48:2::1:255:255m` | - | `bg=0x01FFFF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_1_255_255 | `\e[58:2::1:255:255m` | - | `sp=0x01FFFF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_0 | `\e[38;2;127;0;0m` | - | `fg=0x7F0000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_0 | `\e[48;2;127;0;0m` | - | `bg=0x7F0000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_0 | `\e[58;2;127;0;0m` | - | `sp=0x7F0000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_0 | `\e[38:2::127:0:0m` | - | `fg=0x7F0000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_0 | `\e[48:2::127:0:0m` | - | `bg=0x7F0000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_0 | `\e[58:2::127:0:0m` | - | `sp=0x7F0000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_1 | `\e[38;2;127;0;1m` | - | `fg=0x7F0001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_1 | `\e[48;2;127;0;1m` | - | `bg=0x7F0001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_1 | `\e[58;2;127;0;1m` | - | `sp=0x7F0001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_1 | `\e[38:2::127:0:1m` | - | `fg=0x7F0001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_1 | `\e[48:2::127:0:1m` | - | `bg=0x7F0001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_1 | `\e[58:2::127:0:1m` | - | `sp=0x7F0001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_127 | `\e[38;2;127;0;127m` | - | `fg=0x7F007F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_127 | `\e[48;2;127;0;127m` | - | `bg=0x7F007F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_127 | `\e[58;2;127;0;127m` | - | `sp=0x7F007F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_127 | `\e[38:2::127:0:127m` | - | `fg=0x7F007F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_127 | `\e[48:2::127:0:127m` | - | `bg=0x7F007F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_127 | `\e[58:2::127:0:127m` | - | `sp=0x7F007F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_128 | `\e[38;2;127;0;128m` | - | `fg=0x7F0080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_128 | `\e[48;2;127;0;128m` | - | `bg=0x7F0080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_128 | `\e[58;2;127;0;128m` | - | `sp=0x7F0080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_128 | `\e[38:2::127:0:128m` | - | `fg=0x7F0080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_128 | `\e[48:2::127:0:128m` | - | `bg=0x7F0080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_128 | `\e[58:2::127:0:128m` | - | `sp=0x7F0080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_254 | `\e[38;2;127;0;254m` | - | `fg=0x7F00FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_254 | `\e[48;2;127;0;254m` | - | `bg=0x7F00FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_254 | `\e[58;2;127;0;254m` | - | `sp=0x7F00FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_254 | `\e[38:2::127:0:254m` | - | `fg=0x7F00FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_254 | `\e[48:2::127:0:254m` | - | `bg=0x7F00FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_254 | `\e[58:2::127:0:254m` | - | `sp=0x7F00FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_0_255 | `\e[38;2;127;0;255m` | - | `fg=0x7F00FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_0_255 | `\e[48;2;127;0;255m` | - | `bg=0x7F00FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_0_255 | `\e[58;2;127;0;255m` | - | `sp=0x7F00FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_0_255 | `\e[38:2::127:0:255m` | - | `fg=0x7F00FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_0_255 | `\e[48:2::127:0:255m` | - | `bg=0x7F00FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_0_255 | `\e[58:2::127:0:255m` | - | `sp=0x7F00FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_0 | `\e[38;2;127;1;0m` | - | `fg=0x7F0100` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_0 | `\e[48;2;127;1;0m` | - | `bg=0x7F0100` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_0 | `\e[58;2;127;1;0m` | - | `sp=0x7F0100` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_0 | `\e[38:2::127:1:0m` | - | `fg=0x7F0100` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_0 | `\e[48:2::127:1:0m` | - | `bg=0x7F0100` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_0 | `\e[58:2::127:1:0m` | - | `sp=0x7F0100` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_1 | `\e[38;2;127;1;1m` | - | `fg=0x7F0101` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_1 | `\e[48;2;127;1;1m` | - | `bg=0x7F0101` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_1 | `\e[58;2;127;1;1m` | - | `sp=0x7F0101` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_1 | `\e[38:2::127:1:1m` | - | `fg=0x7F0101` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_1 | `\e[48:2::127:1:1m` | - | `bg=0x7F0101` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_1 | `\e[58:2::127:1:1m` | - | `sp=0x7F0101` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_127 | `\e[38;2;127;1;127m` | - | `fg=0x7F017F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_127 | `\e[48;2;127;1;127m` | - | `bg=0x7F017F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_127 | `\e[58;2;127;1;127m` | - | `sp=0x7F017F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_127 | `\e[38:2::127:1:127m` | - | `fg=0x7F017F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_127 | `\e[48:2::127:1:127m` | - | `bg=0x7F017F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_127 | `\e[58:2::127:1:127m` | - | `sp=0x7F017F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_128 | `\e[38;2;127;1;128m` | - | `fg=0x7F0180` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_128 | `\e[48;2;127;1;128m` | - | `bg=0x7F0180` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_128 | `\e[58;2;127;1;128m` | - | `sp=0x7F0180` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_128 | `\e[38:2::127:1:128m` | - | `fg=0x7F0180` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_128 | `\e[48:2::127:1:128m` | - | `bg=0x7F0180` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_128 | `\e[58:2::127:1:128m` | - | `sp=0x7F0180` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_254 | `\e[38;2;127;1;254m` | - | `fg=0x7F01FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_254 | `\e[48;2;127;1;254m` | - | `bg=0x7F01FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_254 | `\e[58;2;127;1;254m` | - | `sp=0x7F01FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_254 | `\e[38:2::127:1:254m` | - | `fg=0x7F01FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_254 | `\e[48:2::127:1:254m` | - | `bg=0x7F01FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_254 | `\e[58:2::127:1:254m` | - | `sp=0x7F01FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_1_255 | `\e[38;2;127;1;255m` | - | `fg=0x7F01FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_1_255 | `\e[48;2;127;1;255m` | - | `bg=0x7F01FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_1_255 | `\e[58;2;127;1;255m` | - | `sp=0x7F01FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_1_255 | `\e[38:2::127:1:255m` | - | `fg=0x7F01FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_1_255 | `\e[48:2::127:1:255m` | - | `bg=0x7F01FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_1_255 | `\e[58:2::127:1:255m` | - | `sp=0x7F01FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_0 | `\e[38;2;127;127;0m` | - | `fg=0x7F7F00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_0 | `\e[48;2;127;127;0m` | - | `bg=0x7F7F00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_0 | `\e[58;2;127;127;0m` | - | `sp=0x7F7F00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_0 | `\e[38:2::127:127:0m` | - | `fg=0x7F7F00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_0 | `\e[48:2::127:127:0m` | - | `bg=0x7F7F00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_0 | `\e[58:2::127:127:0m` | - | `sp=0x7F7F00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_1 | `\e[38;2;127;127;1m` | - | `fg=0x7F7F01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_1 | `\e[48;2;127;127;1m` | - | `bg=0x7F7F01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_1 | `\e[58;2;127;127;1m` | - | `sp=0x7F7F01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_1 | `\e[38:2::127:127:1m` | - | `fg=0x7F7F01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_1 | `\e[48:2::127:127:1m` | - | `bg=0x7F7F01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_1 | `\e[58:2::127:127:1m` | - | `sp=0x7F7F01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_127 | `\e[38;2;127;127;127m` | - | `fg=0x7F7F7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_127 | `\e[48;2;127;127;127m` | - | `bg=0x7F7F7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_127 | `\e[58;2;127;127;127m` | - | `sp=0x7F7F7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_127 | `\e[38:2::127:127:127m` | - | `fg=0x7F7F7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_127 | `\e[48:2::127:127:127m` | - | `bg=0x7F7F7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_127 | `\e[58:2::127:127:127m` | - | `sp=0x7F7F7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_128 | `\e[38;2;127;127;128m` | - | `fg=0x7F7F80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_128 | `\e[48;2;127;127;128m` | - | `bg=0x7F7F80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_128 | `\e[58;2;127;127;128m` | - | `sp=0x7F7F80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_128 | `\e[38:2::127:127:128m` | - | `fg=0x7F7F80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_128 | `\e[48:2::127:127:128m` | - | `bg=0x7F7F80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_128 | `\e[58:2::127:127:128m` | - | `sp=0x7F7F80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_254 | `\e[38;2;127;127;254m` | - | `fg=0x7F7FFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_254 | `\e[48;2;127;127;254m` | - | `bg=0x7F7FFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_254 | `\e[58;2;127;127;254m` | - | `sp=0x7F7FFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_254 | `\e[38:2::127:127:254m` | - | `fg=0x7F7FFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_254 | `\e[48:2::127:127:254m` | - | `bg=0x7F7FFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_254 | `\e[58:2::127:127:254m` | - | `sp=0x7F7FFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_127_255 | `\e[38;2;127;127;255m` | - | `fg=0x7F7FFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_127_255 | `\e[48;2;127;127;255m` | - | `bg=0x7F7FFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_127_255 | `\e[58;2;127;127;255m` | - | `sp=0x7F7FFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_127_255 | `\e[38:2::127:127:255m` | - | `fg=0x7F7FFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_127_255 | `\e[48:2::127:127:255m` | - | `bg=0x7F7FFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_127_255 | `\e[58:2::127:127:255m` | - | `sp=0x7F7FFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_0 | `\e[38;2;127;128;0m` | - | `fg=0x7F8000` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_0 | `\e[48;2;127;128;0m` | - | `bg=0x7F8000` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_0 | `\e[58;2;127;128;0m` | - | `sp=0x7F8000` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_0 | `\e[38:2::127:128:0m` | - | `fg=0x7F8000` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_0 | `\e[48:2::127:128:0m` | - | `bg=0x7F8000` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_0 | `\e[58:2::127:128:0m` | - | `sp=0x7F8000` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_1 | `\e[38;2;127;128;1m` | - | `fg=0x7F8001` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_1 | `\e[48;2;127;128;1m` | - | `bg=0x7F8001` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_1 | `\e[58;2;127;128;1m` | - | `sp=0x7F8001` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_1 | `\e[38:2::127:128:1m` | - | `fg=0x7F8001` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_1 | `\e[48:2::127:128:1m` | - | `bg=0x7F8001` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_1 | `\e[58:2::127:128:1m` | - | `sp=0x7F8001` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_127 | `\e[38;2;127;128;127m` | - | `fg=0x7F807F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_127 | `\e[48;2;127;128;127m` | - | `bg=0x7F807F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_127 | `\e[58;2;127;128;127m` | - | `sp=0x7F807F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_127 | `\e[38:2::127:128:127m` | - | `fg=0x7F807F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_127 | `\e[48:2::127:128:127m` | - | `bg=0x7F807F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_127 | `\e[58:2::127:128:127m` | - | `sp=0x7F807F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_128 | `\e[38;2;127;128;128m` | - | `fg=0x7F8080` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_128 | `\e[48;2;127;128;128m` | - | `bg=0x7F8080` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_128 | `\e[58;2;127;128;128m` | - | `sp=0x7F8080` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_128 | `\e[38:2::127:128:128m` | - | `fg=0x7F8080` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_128 | `\e[48:2::127:128:128m` | - | `bg=0x7F8080` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_128 | `\e[58:2::127:128:128m` | - | `sp=0x7F8080` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_254 | `\e[38;2;127;128;254m` | - | `fg=0x7F80FE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_254 | `\e[48;2;127;128;254m` | - | `bg=0x7F80FE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_254 | `\e[58;2;127;128;254m` | - | `sp=0x7F80FE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_254 | `\e[38:2::127:128:254m` | - | `fg=0x7F80FE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_254 | `\e[48:2::127:128:254m` | - | `bg=0x7F80FE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_254 | `\e[58:2::127:128:254m` | - | `sp=0x7F80FE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_128_255 | `\e[38;2;127;128;255m` | - | `fg=0x7F80FF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_128_255 | `\e[48;2;127;128;255m` | - | `bg=0x7F80FF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_128_255 | `\e[58;2;127;128;255m` | - | `sp=0x7F80FF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_128_255 | `\e[38:2::127:128:255m` | - | `fg=0x7F80FF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_128_255 | `\e[48:2::127:128:255m` | - | `bg=0x7F80FF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_128_255 | `\e[58:2::127:128:255m` | - | `sp=0x7F80FF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_0 | `\e[38;2;127;254;0m` | - | `fg=0x7FFE00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_0 | `\e[48;2;127;254;0m` | - | `bg=0x7FFE00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_0 | `\e[58;2;127;254;0m` | - | `sp=0x7FFE00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_0 | `\e[38:2::127:254:0m` | - | `fg=0x7FFE00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_0 | `\e[48:2::127:254:0m` | - | `bg=0x7FFE00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_0 | `\e[58:2::127:254:0m` | - | `sp=0x7FFE00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_1 | `\e[38;2;127;254;1m` | - | `fg=0x7FFE01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_1 | `\e[48;2;127;254;1m` | - | `bg=0x7FFE01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_1 | `\e[58;2;127;254;1m` | - | `sp=0x7FFE01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_1 | `\e[38:2::127:254:1m` | - | `fg=0x7FFE01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_1 | `\e[48:2::127:254:1m` | - | `bg=0x7FFE01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_1 | `\e[58:2::127:254:1m` | - | `sp=0x7FFE01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_127 | `\e[38;2;127;254;127m` | - | `fg=0x7FFE7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_127 | `\e[48;2;127;254;127m` | - | `bg=0x7FFE7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_127 | `\e[58;2;127;254;127m` | - | `sp=0x7FFE7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_127 | `\e[38:2::127:254:127m` | - | `fg=0x7FFE7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_127 | `\e[48:2::127:254:127m` | - | `bg=0x7FFE7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_127 | `\e[58:2::127:254:127m` | - | `sp=0x7FFE7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_128 | `\e[38;2;127;254;128m` | - | `fg=0x7FFE80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_128 | `\e[48;2;127;254;128m` | - | `bg=0x7FFE80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_128 | `\e[58;2;127;254;128m` | - | `sp=0x7FFE80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_128 | `\e[38:2::127:254:128m` | - | `fg=0x7FFE80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_128 | `\e[48:2::127:254:128m` | - | `bg=0x7FFE80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_128 | `\e[58:2::127:254:128m` | - | `sp=0x7FFE80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_254 | `\e[38;2;127;254;254m` | - | `fg=0x7FFEFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_254 | `\e[48;2;127;254;254m` | - | `bg=0x7FFEFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_254 | `\e[58;2;127;254;254m` | - | `sp=0x7FFEFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_254 | `\e[38:2::127:254:254m` | - | `fg=0x7FFEFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_254 | `\e[48:2::127:254:254m` | - | `bg=0x7FFEFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_254 | `\e[58:2::127:254:254m` | - | `sp=0x7FFEFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_254_255 | `\e[38;2;127;254;255m` | - | `fg=0x7FFEFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_254_255 | `\e[48;2;127;254;255m` | - | `bg=0x7FFEFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_254_255 | `\e[58;2;127;254;255m` | - | `sp=0x7FFEFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_254_255 | `\e[38:2::127:254:255m` | - | `fg=0x7FFEFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_254_255 | `\e[48:2::127:254:255m` | - | `bg=0x7FFEFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_254_255 | `\e[58:2::127:254:255m` | - | `sp=0x7FFEFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_0 | `\e[38;2;127;255;0m` | - | `fg=0x7FFF00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_0 | `\e[48;2;127;255;0m` | - | `bg=0x7FFF00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_0 | `\e[58;2;127;255;0m` | - | `sp=0x7FFF00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_0 | `\e[38:2::127:255:0m` | - | `fg=0x7FFF00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_0 | `\e[48:2::127:255:0m` | - | `bg=0x7FFF00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_0 | `\e[58:2::127:255:0m` | - | `sp=0x7FFF00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_1 | `\e[38;2;127;255;1m` | - | `fg=0x7FFF01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_1 | `\e[48;2;127;255;1m` | - | `bg=0x7FFF01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_1 | `\e[58;2;127;255;1m` | - | `sp=0x7FFF01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_1 | `\e[38:2::127:255:1m` | - | `fg=0x7FFF01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_1 | `\e[48:2::127:255:1m` | - | `bg=0x7FFF01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_1 | `\e[58:2::127:255:1m` | - | `sp=0x7FFF01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_127 | `\e[38;2;127;255;127m` | - | `fg=0x7FFF7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_127 | `\e[48;2;127;255;127m` | - | `bg=0x7FFF7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_127 | `\e[58;2;127;255;127m` | - | `sp=0x7FFF7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_127 | `\e[38:2::127:255:127m` | - | `fg=0x7FFF7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_127 | `\e[48:2::127:255:127m` | - | `bg=0x7FFF7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_127 | `\e[58:2::127:255:127m` | - | `sp=0x7FFF7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_128 | `\e[38;2;127;255;128m` | - | `fg=0x7FFF80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_128 | `\e[48;2;127;255;128m` | - | `bg=0x7FFF80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_128 | `\e[58;2;127;255;128m` | - | `sp=0x7FFF80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_128 | `\e[38:2::127:255:128m` | - | `fg=0x7FFF80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_128 | `\e[48:2::127:255:128m` | - | `bg=0x7FFF80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_128 | `\e[58:2::127:255:128m` | - | `sp=0x7FFF80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_254 | `\e[38;2;127;255;254m` | - | `fg=0x7FFFFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_254 | `\e[48;2;127;255;254m` | - | `bg=0x7FFFFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_254 | `\e[58;2;127;255;254m` | - | `sp=0x7FFFFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_254 | `\e[38:2::127:255:254m` | - | `fg=0x7FFFFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_254 | `\e[48:2::127:255:254m` | - | `bg=0x7FFFFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_254 | `\e[58:2::127:255:254m` | - | `sp=0x7FFFFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_127_255_255 | `\e[38;2;127;255;255m` | - | `fg=0x7FFFFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_127_255_255 | `\e[48;2;127;255;255m` | - | `bg=0x7FFFFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_127_255_255 | `\e[58;2;127;255;255m` | - | `sp=0x7FFFFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_127_255_255 | `\e[38:2::127:255:255m` | - | `fg=0x7FFFFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_127_255_255 | `\e[48:2::127:255:255m` | - | `bg=0x7FFFFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_127_255_255 | `\e[58:2::127:255:255m` | - | `sp=0x7FFFFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_0 | `\e[38;2;128;0;0m` | - | `fg=0x800000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_0 | `\e[48;2;128;0;0m` | - | `bg=0x800000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_0 | `\e[58;2;128;0;0m` | - | `sp=0x800000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_0 | `\e[38:2::128:0:0m` | - | `fg=0x800000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_0 | `\e[48:2::128:0:0m` | - | `bg=0x800000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_0 | `\e[58:2::128:0:0m` | - | `sp=0x800000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_1 | `\e[38;2;128;0;1m` | - | `fg=0x800001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_1 | `\e[48;2;128;0;1m` | - | `bg=0x800001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_1 | `\e[58;2;128;0;1m` | - | `sp=0x800001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_1 | `\e[38:2::128:0:1m` | - | `fg=0x800001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_1 | `\e[48:2::128:0:1m` | - | `bg=0x800001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_1 | `\e[58:2::128:0:1m` | - | `sp=0x800001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_127 | `\e[38;2;128;0;127m` | - | `fg=0x80007F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_127 | `\e[48;2;128;0;127m` | - | `bg=0x80007F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_127 | `\e[58;2;128;0;127m` | - | `sp=0x80007F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_127 | `\e[38:2::128:0:127m` | - | `fg=0x80007F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_127 | `\e[48:2::128:0:127m` | - | `bg=0x80007F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_127 | `\e[58:2::128:0:127m` | - | `sp=0x80007F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_128 | `\e[38;2;128;0;128m` | - | `fg=0x800080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_128 | `\e[48;2;128;0;128m` | - | `bg=0x800080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_128 | `\e[58;2;128;0;128m` | - | `sp=0x800080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_128 | `\e[38:2::128:0:128m` | - | `fg=0x800080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_128 | `\e[48:2::128:0:128m` | - | `bg=0x800080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_128 | `\e[58:2::128:0:128m` | - | `sp=0x800080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_254 | `\e[38;2;128;0;254m` | - | `fg=0x8000FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_254 | `\e[48;2;128;0;254m` | - | `bg=0x8000FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_254 | `\e[58;2;128;0;254m` | - | `sp=0x8000FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_254 | `\e[38:2::128:0:254m` | - | `fg=0x8000FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_254 | `\e[48:2::128:0:254m` | - | `bg=0x8000FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_254 | `\e[58:2::128:0:254m` | - | `sp=0x8000FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_0_255 | `\e[38;2;128;0;255m` | - | `fg=0x8000FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_0_255 | `\e[48;2;128;0;255m` | - | `bg=0x8000FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_0_255 | `\e[58;2;128;0;255m` | - | `sp=0x8000FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_0_255 | `\e[38:2::128:0:255m` | - | `fg=0x8000FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_0_255 | `\e[48:2::128:0:255m` | - | `bg=0x8000FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_0_255 | `\e[58:2::128:0:255m` | - | `sp=0x8000FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_0 | `\e[38;2;128;1;0m` | - | `fg=0x800100` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_0 | `\e[48;2;128;1;0m` | - | `bg=0x800100` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_0 | `\e[58;2;128;1;0m` | - | `sp=0x800100` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_0 | `\e[38:2::128:1:0m` | - | `fg=0x800100` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_0 | `\e[48:2::128:1:0m` | - | `bg=0x800100` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_0 | `\e[58:2::128:1:0m` | - | `sp=0x800100` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_1 | `\e[38;2;128;1;1m` | - | `fg=0x800101` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_1 | `\e[48;2;128;1;1m` | - | `bg=0x800101` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_1 | `\e[58;2;128;1;1m` | - | `sp=0x800101` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_1 | `\e[38:2::128:1:1m` | - | `fg=0x800101` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_1 | `\e[48:2::128:1:1m` | - | `bg=0x800101` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_1 | `\e[58:2::128:1:1m` | - | `sp=0x800101` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_127 | `\e[38;2;128;1;127m` | - | `fg=0x80017F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_127 | `\e[48;2;128;1;127m` | - | `bg=0x80017F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_127 | `\e[58;2;128;1;127m` | - | `sp=0x80017F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_127 | `\e[38:2::128:1:127m` | - | `fg=0x80017F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_127 | `\e[48:2::128:1:127m` | - | `bg=0x80017F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_127 | `\e[58:2::128:1:127m` | - | `sp=0x80017F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_128 | `\e[38;2;128;1;128m` | - | `fg=0x800180` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_128 | `\e[48;2;128;1;128m` | - | `bg=0x800180` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_128 | `\e[58;2;128;1;128m` | - | `sp=0x800180` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_128 | `\e[38:2::128:1:128m` | - | `fg=0x800180` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_128 | `\e[48:2::128:1:128m` | - | `bg=0x800180` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_128 | `\e[58:2::128:1:128m` | - | `sp=0x800180` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_254 | `\e[38;2;128;1;254m` | - | `fg=0x8001FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_254 | `\e[48;2;128;1;254m` | - | `bg=0x8001FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_254 | `\e[58;2;128;1;254m` | - | `sp=0x8001FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_254 | `\e[38:2::128:1:254m` | - | `fg=0x8001FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_254 | `\e[48:2::128:1:254m` | - | `bg=0x8001FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_254 | `\e[58:2::128:1:254m` | - | `sp=0x8001FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_1_255 | `\e[38;2;128;1;255m` | - | `fg=0x8001FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_1_255 | `\e[48;2;128;1;255m` | - | `bg=0x8001FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_1_255 | `\e[58;2;128;1;255m` | - | `sp=0x8001FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_1_255 | `\e[38:2::128:1:255m` | - | `fg=0x8001FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_1_255 | `\e[48:2::128:1:255m` | - | `bg=0x8001FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_1_255 | `\e[58:2::128:1:255m` | - | `sp=0x8001FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_0 | `\e[38;2;128;127;0m` | - | `fg=0x807F00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_0 | `\e[48;2;128;127;0m` | - | `bg=0x807F00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_0 | `\e[58;2;128;127;0m` | - | `sp=0x807F00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_0 | `\e[38:2::128:127:0m` | - | `fg=0x807F00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_0 | `\e[48:2::128:127:0m` | - | `bg=0x807F00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_0 | `\e[58:2::128:127:0m` | - | `sp=0x807F00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_1 | `\e[38;2;128;127;1m` | - | `fg=0x807F01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_1 | `\e[48;2;128;127;1m` | - | `bg=0x807F01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_1 | `\e[58;2;128;127;1m` | - | `sp=0x807F01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_1 | `\e[38:2::128:127:1m` | - | `fg=0x807F01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_1 | `\e[48:2::128:127:1m` | - | `bg=0x807F01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_1 | `\e[58:2::128:127:1m` | - | `sp=0x807F01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_127 | `\e[38;2;128;127;127m` | - | `fg=0x807F7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_127 | `\e[48;2;128;127;127m` | - | `bg=0x807F7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_127 | `\e[58;2;128;127;127m` | - | `sp=0x807F7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_127 | `\e[38:2::128:127:127m` | - | `fg=0x807F7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_127 | `\e[48:2::128:127:127m` | - | `bg=0x807F7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_127 | `\e[58:2::128:127:127m` | - | `sp=0x807F7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_128 | `\e[38;2;128;127;128m` | - | `fg=0x807F80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_128 | `\e[48;2;128;127;128m` | - | `bg=0x807F80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_128 | `\e[58;2;128;127;128m` | - | `sp=0x807F80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_128 | `\e[38:2::128:127:128m` | - | `fg=0x807F80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_128 | `\e[48:2::128:127:128m` | - | `bg=0x807F80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_128 | `\e[58:2::128:127:128m` | - | `sp=0x807F80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_254 | `\e[38;2;128;127;254m` | - | `fg=0x807FFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_254 | `\e[48;2;128;127;254m` | - | `bg=0x807FFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_254 | `\e[58;2;128;127;254m` | - | `sp=0x807FFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_254 | `\e[38:2::128:127:254m` | - | `fg=0x807FFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_254 | `\e[48:2::128:127:254m` | - | `bg=0x807FFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_254 | `\e[58:2::128:127:254m` | - | `sp=0x807FFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_127_255 | `\e[38;2;128;127;255m` | - | `fg=0x807FFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_127_255 | `\e[48;2;128;127;255m` | - | `bg=0x807FFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_127_255 | `\e[58;2;128;127;255m` | - | `sp=0x807FFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_127_255 | `\e[38:2::128:127:255m` | - | `fg=0x807FFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_127_255 | `\e[48:2::128:127:255m` | - | `bg=0x807FFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_127_255 | `\e[58:2::128:127:255m` | - | `sp=0x807FFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_0 | `\e[38;2;128;128;0m` | - | `fg=0x808000` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_0 | `\e[48;2;128;128;0m` | - | `bg=0x808000` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_0 | `\e[58;2;128;128;0m` | - | `sp=0x808000` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_0 | `\e[38:2::128:128:0m` | - | `fg=0x808000` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_0 | `\e[48:2::128:128:0m` | - | `bg=0x808000` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_0 | `\e[58:2::128:128:0m` | - | `sp=0x808000` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_1 | `\e[38;2;128;128;1m` | - | `fg=0x808001` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_1 | `\e[48;2;128;128;1m` | - | `bg=0x808001` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_1 | `\e[58;2;128;128;1m` | - | `sp=0x808001` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_1 | `\e[38:2::128:128:1m` | - | `fg=0x808001` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_1 | `\e[48:2::128:128:1m` | - | `bg=0x808001` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_1 | `\e[58:2::128:128:1m` | - | `sp=0x808001` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_127 | `\e[38;2;128;128;127m` | - | `fg=0x80807F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_127 | `\e[48;2;128;128;127m` | - | `bg=0x80807F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_127 | `\e[58;2;128;128;127m` | - | `sp=0x80807F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_127 | `\e[38:2::128:128:127m` | - | `fg=0x80807F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_127 | `\e[48:2::128:128:127m` | - | `bg=0x80807F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_127 | `\e[58:2::128:128:127m` | - | `sp=0x80807F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_128 | `\e[38;2;128;128;128m` | - | `fg=0x808080` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_128 | `\e[48;2;128;128;128m` | - | `bg=0x808080` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_128 | `\e[58;2;128;128;128m` | - | `sp=0x808080` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_128 | `\e[38:2::128:128:128m` | - | `fg=0x808080` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_128 | `\e[48:2::128:128:128m` | - | `bg=0x808080` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_128 | `\e[58:2::128:128:128m` | - | `sp=0x808080` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_254 | `\e[38;2;128;128;254m` | - | `fg=0x8080FE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_254 | `\e[48;2;128;128;254m` | - | `bg=0x8080FE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_254 | `\e[58;2;128;128;254m` | - | `sp=0x8080FE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_254 | `\e[38:2::128:128:254m` | - | `fg=0x8080FE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_254 | `\e[48:2::128:128:254m` | - | `bg=0x8080FE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_254 | `\e[58:2::128:128:254m` | - | `sp=0x8080FE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_128_255 | `\e[38;2;128;128;255m` | - | `fg=0x8080FF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_128_255 | `\e[48;2;128;128;255m` | - | `bg=0x8080FF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_128_255 | `\e[58;2;128;128;255m` | - | `sp=0x8080FF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_128_255 | `\e[38:2::128:128:255m` | - | `fg=0x8080FF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_128_255 | `\e[48:2::128:128:255m` | - | `bg=0x8080FF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_128_255 | `\e[58:2::128:128:255m` | - | `sp=0x8080FF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_0 | `\e[38;2;128;254;0m` | - | `fg=0x80FE00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_0 | `\e[48;2;128;254;0m` | - | `bg=0x80FE00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_0 | `\e[58;2;128;254;0m` | - | `sp=0x80FE00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_0 | `\e[38:2::128:254:0m` | - | `fg=0x80FE00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_0 | `\e[48:2::128:254:0m` | - | `bg=0x80FE00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_0 | `\e[58:2::128:254:0m` | - | `sp=0x80FE00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_1 | `\e[38;2;128;254;1m` | - | `fg=0x80FE01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_1 | `\e[48;2;128;254;1m` | - | `bg=0x80FE01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_1 | `\e[58;2;128;254;1m` | - | `sp=0x80FE01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_1 | `\e[38:2::128:254:1m` | - | `fg=0x80FE01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_1 | `\e[48:2::128:254:1m` | - | `bg=0x80FE01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_1 | `\e[58:2::128:254:1m` | - | `sp=0x80FE01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_127 | `\e[38;2;128;254;127m` | - | `fg=0x80FE7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_127 | `\e[48;2;128;254;127m` | - | `bg=0x80FE7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_127 | `\e[58;2;128;254;127m` | - | `sp=0x80FE7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_127 | `\e[38:2::128:254:127m` | - | `fg=0x80FE7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_127 | `\e[48:2::128:254:127m` | - | `bg=0x80FE7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_127 | `\e[58:2::128:254:127m` | - | `sp=0x80FE7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_128 | `\e[38;2;128;254;128m` | - | `fg=0x80FE80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_128 | `\e[48;2;128;254;128m` | - | `bg=0x80FE80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_128 | `\e[58;2;128;254;128m` | - | `sp=0x80FE80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_128 | `\e[38:2::128:254:128m` | - | `fg=0x80FE80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_128 | `\e[48:2::128:254:128m` | - | `bg=0x80FE80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_128 | `\e[58:2::128:254:128m` | - | `sp=0x80FE80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_254 | `\e[38;2;128;254;254m` | - | `fg=0x80FEFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_254 | `\e[48;2;128;254;254m` | - | `bg=0x80FEFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_254 | `\e[58;2;128;254;254m` | - | `sp=0x80FEFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_254 | `\e[38:2::128:254:254m` | - | `fg=0x80FEFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_254 | `\e[48:2::128:254:254m` | - | `bg=0x80FEFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_254 | `\e[58:2::128:254:254m` | - | `sp=0x80FEFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_254_255 | `\e[38;2;128;254;255m` | - | `fg=0x80FEFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_254_255 | `\e[48;2;128;254;255m` | - | `bg=0x80FEFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_254_255 | `\e[58;2;128;254;255m` | - | `sp=0x80FEFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_254_255 | `\e[38:2::128:254:255m` | - | `fg=0x80FEFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_254_255 | `\e[48:2::128:254:255m` | - | `bg=0x80FEFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_254_255 | `\e[58:2::128:254:255m` | - | `sp=0x80FEFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_0 | `\e[38;2;128;255;0m` | - | `fg=0x80FF00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_0 | `\e[48;2;128;255;0m` | - | `bg=0x80FF00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_0 | `\e[58;2;128;255;0m` | - | `sp=0x80FF00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_0 | `\e[38:2::128:255:0m` | - | `fg=0x80FF00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_0 | `\e[48:2::128:255:0m` | - | `bg=0x80FF00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_0 | `\e[58:2::128:255:0m` | - | `sp=0x80FF00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_1 | `\e[38;2;128;255;1m` | - | `fg=0x80FF01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_1 | `\e[48;2;128;255;1m` | - | `bg=0x80FF01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_1 | `\e[58;2;128;255;1m` | - | `sp=0x80FF01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_1 | `\e[38:2::128:255:1m` | - | `fg=0x80FF01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_1 | `\e[48:2::128:255:1m` | - | `bg=0x80FF01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_1 | `\e[58:2::128:255:1m` | - | `sp=0x80FF01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_127 | `\e[38;2;128;255;127m` | - | `fg=0x80FF7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_127 | `\e[48;2;128;255;127m` | - | `bg=0x80FF7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_127 | `\e[58;2;128;255;127m` | - | `sp=0x80FF7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_127 | `\e[38:2::128:255:127m` | - | `fg=0x80FF7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_127 | `\e[48:2::128:255:127m` | - | `bg=0x80FF7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_127 | `\e[58:2::128:255:127m` | - | `sp=0x80FF7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_128 | `\e[38;2;128;255;128m` | - | `fg=0x80FF80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_128 | `\e[48;2;128;255;128m` | - | `bg=0x80FF80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_128 | `\e[58;2;128;255;128m` | - | `sp=0x80FF80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_128 | `\e[38:2::128:255:128m` | - | `fg=0x80FF80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_128 | `\e[48:2::128:255:128m` | - | `bg=0x80FF80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_128 | `\e[58:2::128:255:128m` | - | `sp=0x80FF80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_254 | `\e[38;2;128;255;254m` | - | `fg=0x80FFFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_254 | `\e[48;2;128;255;254m` | - | `bg=0x80FFFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_254 | `\e[58;2;128;255;254m` | - | `sp=0x80FFFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_254 | `\e[38:2::128:255:254m` | - | `fg=0x80FFFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_254 | `\e[48:2::128:255:254m` | - | `bg=0x80FFFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_254 | `\e[58:2::128:255:254m` | - | `sp=0x80FFFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_128_255_255 | `\e[38;2;128;255;255m` | - | `fg=0x80FFFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_128_255_255 | `\e[48;2;128;255;255m` | - | `bg=0x80FFFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_128_255_255 | `\e[58;2;128;255;255m` | - | `sp=0x80FFFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_128_255_255 | `\e[38:2::128:255:255m` | - | `fg=0x80FFFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_128_255_255 | `\e[48:2::128:255:255m` | - | `bg=0x80FFFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_128_255_255 | `\e[58:2::128:255:255m` | - | `sp=0x80FFFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_0 | `\e[38;2;254;0;0m` | - | `fg=0xFE0000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_0 | `\e[48;2;254;0;0m` | - | `bg=0xFE0000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_0 | `\e[58;2;254;0;0m` | - | `sp=0xFE0000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_0 | `\e[38:2::254:0:0m` | - | `fg=0xFE0000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_0 | `\e[48:2::254:0:0m` | - | `bg=0xFE0000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_0 | `\e[58:2::254:0:0m` | - | `sp=0xFE0000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_1 | `\e[38;2;254;0;1m` | - | `fg=0xFE0001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_1 | `\e[48;2;254;0;1m` | - | `bg=0xFE0001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_1 | `\e[58;2;254;0;1m` | - | `sp=0xFE0001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_1 | `\e[38:2::254:0:1m` | - | `fg=0xFE0001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_1 | `\e[48:2::254:0:1m` | - | `bg=0xFE0001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_1 | `\e[58:2::254:0:1m` | - | `sp=0xFE0001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_127 | `\e[38;2;254;0;127m` | - | `fg=0xFE007F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_127 | `\e[48;2;254;0;127m` | - | `bg=0xFE007F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_127 | `\e[58;2;254;0;127m` | - | `sp=0xFE007F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_127 | `\e[38:2::254:0:127m` | - | `fg=0xFE007F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_127 | `\e[48:2::254:0:127m` | - | `bg=0xFE007F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_127 | `\e[58:2::254:0:127m` | - | `sp=0xFE007F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_128 | `\e[38;2;254;0;128m` | - | `fg=0xFE0080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_128 | `\e[48;2;254;0;128m` | - | `bg=0xFE0080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_128 | `\e[58;2;254;0;128m` | - | `sp=0xFE0080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_128 | `\e[38:2::254:0:128m` | - | `fg=0xFE0080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_128 | `\e[48:2::254:0:128m` | - | `bg=0xFE0080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_128 | `\e[58:2::254:0:128m` | - | `sp=0xFE0080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_254 | `\e[38;2;254;0;254m` | - | `fg=0xFE00FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_254 | `\e[48;2;254;0;254m` | - | `bg=0xFE00FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_254 | `\e[58;2;254;0;254m` | - | `sp=0xFE00FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_254 | `\e[38:2::254:0:254m` | - | `fg=0xFE00FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_254 | `\e[48:2::254:0:254m` | - | `bg=0xFE00FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_254 | `\e[58:2::254:0:254m` | - | `sp=0xFE00FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_0_255 | `\e[38;2;254;0;255m` | - | `fg=0xFE00FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_0_255 | `\e[48;2;254;0;255m` | - | `bg=0xFE00FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_0_255 | `\e[58;2;254;0;255m` | - | `sp=0xFE00FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_0_255 | `\e[38:2::254:0:255m` | - | `fg=0xFE00FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_0_255 | `\e[48:2::254:0:255m` | - | `bg=0xFE00FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_0_255 | `\e[58:2::254:0:255m` | - | `sp=0xFE00FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_0 | `\e[38;2;254;1;0m` | - | `fg=0xFE0100` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_0 | `\e[48;2;254;1;0m` | - | `bg=0xFE0100` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_0 | `\e[58;2;254;1;0m` | - | `sp=0xFE0100` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_0 | `\e[38:2::254:1:0m` | - | `fg=0xFE0100` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_0 | `\e[48:2::254:1:0m` | - | `bg=0xFE0100` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_0 | `\e[58:2::254:1:0m` | - | `sp=0xFE0100` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_1 | `\e[38;2;254;1;1m` | - | `fg=0xFE0101` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_1 | `\e[48;2;254;1;1m` | - | `bg=0xFE0101` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_1 | `\e[58;2;254;1;1m` | - | `sp=0xFE0101` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_1 | `\e[38:2::254:1:1m` | - | `fg=0xFE0101` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_1 | `\e[48:2::254:1:1m` | - | `bg=0xFE0101` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_1 | `\e[58:2::254:1:1m` | - | `sp=0xFE0101` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_127 | `\e[38;2;254;1;127m` | - | `fg=0xFE017F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_127 | `\e[48;2;254;1;127m` | - | `bg=0xFE017F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_127 | `\e[58;2;254;1;127m` | - | `sp=0xFE017F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_127 | `\e[38:2::254:1:127m` | - | `fg=0xFE017F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_127 | `\e[48:2::254:1:127m` | - | `bg=0xFE017F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_127 | `\e[58:2::254:1:127m` | - | `sp=0xFE017F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_128 | `\e[38;2;254;1;128m` | - | `fg=0xFE0180` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_128 | `\e[48;2;254;1;128m` | - | `bg=0xFE0180` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_128 | `\e[58;2;254;1;128m` | - | `sp=0xFE0180` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_128 | `\e[38:2::254:1:128m` | - | `fg=0xFE0180` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_128 | `\e[48:2::254:1:128m` | - | `bg=0xFE0180` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_128 | `\e[58:2::254:1:128m` | - | `sp=0xFE0180` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_254 | `\e[38;2;254;1;254m` | - | `fg=0xFE01FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_254 | `\e[48;2;254;1;254m` | - | `bg=0xFE01FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_254 | `\e[58;2;254;1;254m` | - | `sp=0xFE01FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_254 | `\e[38:2::254:1:254m` | - | `fg=0xFE01FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_254 | `\e[48:2::254:1:254m` | - | `bg=0xFE01FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_254 | `\e[58:2::254:1:254m` | - | `sp=0xFE01FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_1_255 | `\e[38;2;254;1;255m` | - | `fg=0xFE01FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_1_255 | `\e[48;2;254;1;255m` | - | `bg=0xFE01FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_1_255 | `\e[58;2;254;1;255m` | - | `sp=0xFE01FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_1_255 | `\e[38:2::254:1:255m` | - | `fg=0xFE01FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_1_255 | `\e[48:2::254:1:255m` | - | `bg=0xFE01FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_1_255 | `\e[58:2::254:1:255m` | - | `sp=0xFE01FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_0 | `\e[38;2;254;127;0m` | - | `fg=0xFE7F00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_0 | `\e[48;2;254;127;0m` | - | `bg=0xFE7F00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_0 | `\e[58;2;254;127;0m` | - | `sp=0xFE7F00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_0 | `\e[38:2::254:127:0m` | - | `fg=0xFE7F00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_0 | `\e[48:2::254:127:0m` | - | `bg=0xFE7F00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_0 | `\e[58:2::254:127:0m` | - | `sp=0xFE7F00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_1 | `\e[38;2;254;127;1m` | - | `fg=0xFE7F01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_1 | `\e[48;2;254;127;1m` | - | `bg=0xFE7F01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_1 | `\e[58;2;254;127;1m` | - | `sp=0xFE7F01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_1 | `\e[38:2::254:127:1m` | - | `fg=0xFE7F01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_1 | `\e[48:2::254:127:1m` | - | `bg=0xFE7F01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_1 | `\e[58:2::254:127:1m` | - | `sp=0xFE7F01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_127 | `\e[38;2;254;127;127m` | - | `fg=0xFE7F7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_127 | `\e[48;2;254;127;127m` | - | `bg=0xFE7F7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_127 | `\e[58;2;254;127;127m` | - | `sp=0xFE7F7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_127 | `\e[38:2::254:127:127m` | - | `fg=0xFE7F7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_127 | `\e[48:2::254:127:127m` | - | `bg=0xFE7F7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_127 | `\e[58:2::254:127:127m` | - | `sp=0xFE7F7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_128 | `\e[38;2;254;127;128m` | - | `fg=0xFE7F80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_128 | `\e[48;2;254;127;128m` | - | `bg=0xFE7F80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_128 | `\e[58;2;254;127;128m` | - | `sp=0xFE7F80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_128 | `\e[38:2::254:127:128m` | - | `fg=0xFE7F80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_128 | `\e[48:2::254:127:128m` | - | `bg=0xFE7F80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_128 | `\e[58:2::254:127:128m` | - | `sp=0xFE7F80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_254 | `\e[38;2;254;127;254m` | - | `fg=0xFE7FFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_254 | `\e[48;2;254;127;254m` | - | `bg=0xFE7FFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_254 | `\e[58;2;254;127;254m` | - | `sp=0xFE7FFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_254 | `\e[38:2::254:127:254m` | - | `fg=0xFE7FFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_254 | `\e[48:2::254:127:254m` | - | `bg=0xFE7FFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_254 | `\e[58:2::254:127:254m` | - | `sp=0xFE7FFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_127_255 | `\e[38;2;254;127;255m` | - | `fg=0xFE7FFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_127_255 | `\e[48;2;254;127;255m` | - | `bg=0xFE7FFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_127_255 | `\e[58;2;254;127;255m` | - | `sp=0xFE7FFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_127_255 | `\e[38:2::254:127:255m` | - | `fg=0xFE7FFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_127_255 | `\e[48:2::254:127:255m` | - | `bg=0xFE7FFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_127_255 | `\e[58:2::254:127:255m` | - | `sp=0xFE7FFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_0 | `\e[38;2;254;128;0m` | - | `fg=0xFE8000` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_0 | `\e[48;2;254;128;0m` | - | `bg=0xFE8000` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_0 | `\e[58;2;254;128;0m` | - | `sp=0xFE8000` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_0 | `\e[38:2::254:128:0m` | - | `fg=0xFE8000` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_0 | `\e[48:2::254:128:0m` | - | `bg=0xFE8000` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_0 | `\e[58:2::254:128:0m` | - | `sp=0xFE8000` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_1 | `\e[38;2;254;128;1m` | - | `fg=0xFE8001` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_1 | `\e[48;2;254;128;1m` | - | `bg=0xFE8001` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_1 | `\e[58;2;254;128;1m` | - | `sp=0xFE8001` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_1 | `\e[38:2::254:128:1m` | - | `fg=0xFE8001` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_1 | `\e[48:2::254:128:1m` | - | `bg=0xFE8001` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_1 | `\e[58:2::254:128:1m` | - | `sp=0xFE8001` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_127 | `\e[38;2;254;128;127m` | - | `fg=0xFE807F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_127 | `\e[48;2;254;128;127m` | - | `bg=0xFE807F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_127 | `\e[58;2;254;128;127m` | - | `sp=0xFE807F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_127 | `\e[38:2::254:128:127m` | - | `fg=0xFE807F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_127 | `\e[48:2::254:128:127m` | - | `bg=0xFE807F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_127 | `\e[58:2::254:128:127m` | - | `sp=0xFE807F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_128 | `\e[38;2;254;128;128m` | - | `fg=0xFE8080` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_128 | `\e[48;2;254;128;128m` | - | `bg=0xFE8080` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_128 | `\e[58;2;254;128;128m` | - | `sp=0xFE8080` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_128 | `\e[38:2::254:128:128m` | - | `fg=0xFE8080` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_128 | `\e[48:2::254:128:128m` | - | `bg=0xFE8080` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_128 | `\e[58:2::254:128:128m` | - | `sp=0xFE8080` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_254 | `\e[38;2;254;128;254m` | - | `fg=0xFE80FE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_254 | `\e[48;2;254;128;254m` | - | `bg=0xFE80FE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_254 | `\e[58;2;254;128;254m` | - | `sp=0xFE80FE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_254 | `\e[38:2::254:128:254m` | - | `fg=0xFE80FE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_254 | `\e[48:2::254:128:254m` | - | `bg=0xFE80FE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_254 | `\e[58:2::254:128:254m` | - | `sp=0xFE80FE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_128_255 | `\e[38;2;254;128;255m` | - | `fg=0xFE80FF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_128_255 | `\e[48;2;254;128;255m` | - | `bg=0xFE80FF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_128_255 | `\e[58;2;254;128;255m` | - | `sp=0xFE80FF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_128_255 | `\e[38:2::254:128:255m` | - | `fg=0xFE80FF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_128_255 | `\e[48:2::254:128:255m` | - | `bg=0xFE80FF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_128_255 | `\e[58:2::254:128:255m` | - | `sp=0xFE80FF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_0 | `\e[38;2;254;254;0m` | - | `fg=0xFEFE00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_0 | `\e[48;2;254;254;0m` | - | `bg=0xFEFE00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_0 | `\e[58;2;254;254;0m` | - | `sp=0xFEFE00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_0 | `\e[38:2::254:254:0m` | - | `fg=0xFEFE00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_0 | `\e[48:2::254:254:0m` | - | `bg=0xFEFE00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_0 | `\e[58:2::254:254:0m` | - | `sp=0xFEFE00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_1 | `\e[38;2;254;254;1m` | - | `fg=0xFEFE01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_1 | `\e[48;2;254;254;1m` | - | `bg=0xFEFE01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_1 | `\e[58;2;254;254;1m` | - | `sp=0xFEFE01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_1 | `\e[38:2::254:254:1m` | - | `fg=0xFEFE01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_1 | `\e[48:2::254:254:1m` | - | `bg=0xFEFE01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_1 | `\e[58:2::254:254:1m` | - | `sp=0xFEFE01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_127 | `\e[38;2;254;254;127m` | - | `fg=0xFEFE7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_127 | `\e[48;2;254;254;127m` | - | `bg=0xFEFE7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_127 | `\e[58;2;254;254;127m` | - | `sp=0xFEFE7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_127 | `\e[38:2::254:254:127m` | - | `fg=0xFEFE7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_127 | `\e[48:2::254:254:127m` | - | `bg=0xFEFE7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_127 | `\e[58:2::254:254:127m` | - | `sp=0xFEFE7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_128 | `\e[38;2;254;254;128m` | - | `fg=0xFEFE80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_128 | `\e[48;2;254;254;128m` | - | `bg=0xFEFE80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_128 | `\e[58;2;254;254;128m` | - | `sp=0xFEFE80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_128 | `\e[38:2::254:254:128m` | - | `fg=0xFEFE80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_128 | `\e[48:2::254:254:128m` | - | `bg=0xFEFE80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_128 | `\e[58:2::254:254:128m` | - | `sp=0xFEFE80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_254 | `\e[38;2;254;254;254m` | - | `fg=0xFEFEFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_254 | `\e[48;2;254;254;254m` | - | `bg=0xFEFEFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_254 | `\e[58;2;254;254;254m` | - | `sp=0xFEFEFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_254 | `\e[38:2::254:254:254m` | - | `fg=0xFEFEFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_254 | `\e[48:2::254:254:254m` | - | `bg=0xFEFEFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_254 | `\e[58:2::254:254:254m` | - | `sp=0xFEFEFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_254_255 | `\e[38;2;254;254;255m` | - | `fg=0xFEFEFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_254_255 | `\e[48;2;254;254;255m` | - | `bg=0xFEFEFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_254_255 | `\e[58;2;254;254;255m` | - | `sp=0xFEFEFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_254_255 | `\e[38:2::254:254:255m` | - | `fg=0xFEFEFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_254_255 | `\e[48:2::254:254:255m` | - | `bg=0xFEFEFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_254_255 | `\e[58:2::254:254:255m` | - | `sp=0xFEFEFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_0 | `\e[38;2;254;255;0m` | - | `fg=0xFEFF00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_0 | `\e[48;2;254;255;0m` | - | `bg=0xFEFF00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_0 | `\e[58;2;254;255;0m` | - | `sp=0xFEFF00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_0 | `\e[38:2::254:255:0m` | - | `fg=0xFEFF00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_0 | `\e[48:2::254:255:0m` | - | `bg=0xFEFF00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_0 | `\e[58:2::254:255:0m` | - | `sp=0xFEFF00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_1 | `\e[38;2;254;255;1m` | - | `fg=0xFEFF01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_1 | `\e[48;2;254;255;1m` | - | `bg=0xFEFF01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_1 | `\e[58;2;254;255;1m` | - | `sp=0xFEFF01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_1 | `\e[38:2::254:255:1m` | - | `fg=0xFEFF01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_1 | `\e[48:2::254:255:1m` | - | `bg=0xFEFF01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_1 | `\e[58:2::254:255:1m` | - | `sp=0xFEFF01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_127 | `\e[38;2;254;255;127m` | - | `fg=0xFEFF7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_127 | `\e[48;2;254;255;127m` | - | `bg=0xFEFF7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_127 | `\e[58;2;254;255;127m` | - | `sp=0xFEFF7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_127 | `\e[38:2::254:255:127m` | - | `fg=0xFEFF7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_127 | `\e[48:2::254:255:127m` | - | `bg=0xFEFF7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_127 | `\e[58:2::254:255:127m` | - | `sp=0xFEFF7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_128 | `\e[38;2;254;255;128m` | - | `fg=0xFEFF80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_128 | `\e[48;2;254;255;128m` | - | `bg=0xFEFF80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_128 | `\e[58;2;254;255;128m` | - | `sp=0xFEFF80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_128 | `\e[38:2::254:255:128m` | - | `fg=0xFEFF80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_128 | `\e[48:2::254:255:128m` | - | `bg=0xFEFF80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_128 | `\e[58:2::254:255:128m` | - | `sp=0xFEFF80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_254 | `\e[38;2;254;255;254m` | - | `fg=0xFEFFFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_254 | `\e[48;2;254;255;254m` | - | `bg=0xFEFFFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_254 | `\e[58;2;254;255;254m` | - | `sp=0xFEFFFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_254 | `\e[38:2::254:255:254m` | - | `fg=0xFEFFFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_254 | `\e[48:2::254:255:254m` | - | `bg=0xFEFFFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_254 | `\e[58:2::254:255:254m` | - | `sp=0xFEFFFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_254_255_255 | `\e[38;2;254;255;255m` | - | `fg=0xFEFFFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_254_255_255 | `\e[48;2;254;255;255m` | - | `bg=0xFEFFFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_254_255_255 | `\e[58;2;254;255;255m` | - | `sp=0xFEFFFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_254_255_255 | `\e[38:2::254:255:255m` | - | `fg=0xFEFFFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_254_255_255 | `\e[48:2::254:255:255m` | - | `bg=0xFEFFFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_254_255_255 | `\e[58:2::254:255:255m` | - | `sp=0xFEFFFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_0 | `\e[38;2;255;0;0m` | - | `fg=0xFF0000` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_0 | `\e[48;2;255;0;0m` | - | `bg=0xFF0000` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_0 | `\e[58;2;255;0;0m` | - | `sp=0xFF0000` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_0 | `\e[38:2::255:0:0m` | - | `fg=0xFF0000` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_0 | `\e[48:2::255:0:0m` | - | `bg=0xFF0000` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_0 | `\e[58:2::255:0:0m` | - | `sp=0xFF0000` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_1 | `\e[38;2;255;0;1m` | - | `fg=0xFF0001` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_1 | `\e[48;2;255;0;1m` | - | `bg=0xFF0001` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_1 | `\e[58;2;255;0;1m` | - | `sp=0xFF0001` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_1 | `\e[38:2::255:0:1m` | - | `fg=0xFF0001` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_1 | `\e[48:2::255:0:1m` | - | `bg=0xFF0001` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_1 | `\e[58:2::255:0:1m` | - | `sp=0xFF0001` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_127 | `\e[38;2;255;0;127m` | - | `fg=0xFF007F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_127 | `\e[48;2;255;0;127m` | - | `bg=0xFF007F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_127 | `\e[58;2;255;0;127m` | - | `sp=0xFF007F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_127 | `\e[38:2::255:0:127m` | - | `fg=0xFF007F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_127 | `\e[48:2::255:0:127m` | - | `bg=0xFF007F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_127 | `\e[58:2::255:0:127m` | - | `sp=0xFF007F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_128 | `\e[38;2;255;0;128m` | - | `fg=0xFF0080` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_128 | `\e[48;2;255;0;128m` | - | `bg=0xFF0080` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_128 | `\e[58;2;255;0;128m` | - | `sp=0xFF0080` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_128 | `\e[38:2::255:0:128m` | - | `fg=0xFF0080` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_128 | `\e[48:2::255:0:128m` | - | `bg=0xFF0080` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_128 | `\e[58:2::255:0:128m` | - | `sp=0xFF0080` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_254 | `\e[38;2;255;0;254m` | - | `fg=0xFF00FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_254 | `\e[48;2;255;0;254m` | - | `bg=0xFF00FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_254 | `\e[58;2;255;0;254m` | - | `sp=0xFF00FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_254 | `\e[38:2::255:0:254m` | - | `fg=0xFF00FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_254 | `\e[48:2::255:0:254m` | - | `bg=0xFF00FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_254 | `\e[58:2::255:0:254m` | - | `sp=0xFF00FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_0_255 | `\e[38;2;255;0;255m` | - | `fg=0xFF00FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_0_255 | `\e[48;2;255;0;255m` | - | `bg=0xFF00FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_0_255 | `\e[58;2;255;0;255m` | - | `sp=0xFF00FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_0_255 | `\e[38:2::255:0:255m` | - | `fg=0xFF00FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_0_255 | `\e[48:2::255:0:255m` | - | `bg=0xFF00FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_0_255 | `\e[58:2::255:0:255m` | - | `sp=0xFF00FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_0 | `\e[38;2;255;1;0m` | - | `fg=0xFF0100` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_0 | `\e[48;2;255;1;0m` | - | `bg=0xFF0100` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_0 | `\e[58;2;255;1;0m` | - | `sp=0xFF0100` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_0 | `\e[38:2::255:1:0m` | - | `fg=0xFF0100` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_0 | `\e[48:2::255:1:0m` | - | `bg=0xFF0100` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_0 | `\e[58:2::255:1:0m` | - | `sp=0xFF0100` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_1 | `\e[38;2;255;1;1m` | - | `fg=0xFF0101` | 0 | 15 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_1 | `\e[48;2;255;1;1m` | - | `bg=0xFF0101` | 0 | 15 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_1 | `\e[58;2;255;1;1m` | - | `sp=0xFF0101` | 0 | 15 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_1 | `\e[38:2::255:1:1m` | - | `fg=0xFF0101` | 0 | 16 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_1 | `\e[48:2::255:1:1m` | - | `bg=0xFF0101` | 0 | 16 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_1 | `\e[58:2::255:1:1m` | - | `sp=0xFF0101` | 0 | 16 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_127 | `\e[38;2;255;1;127m` | - | `fg=0xFF017F` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_127 | `\e[48;2;255;1;127m` | - | `bg=0xFF017F` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_127 | `\e[58;2;255;1;127m` | - | `sp=0xFF017F` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_127 | `\e[38:2::255:1:127m` | - | `fg=0xFF017F` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_127 | `\e[48:2::255:1:127m` | - | `bg=0xFF017F` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_127 | `\e[58:2::255:1:127m` | - | `sp=0xFF017F` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_128 | `\e[38;2;255;1;128m` | - | `fg=0xFF0180` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_128 | `\e[48;2;255;1;128m` | - | `bg=0xFF0180` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_128 | `\e[58;2;255;1;128m` | - | `sp=0xFF0180` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_128 | `\e[38:2::255:1:128m` | - | `fg=0xFF0180` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_128 | `\e[48:2::255:1:128m` | - | `bg=0xFF0180` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_128 | `\e[58:2::255:1:128m` | - | `sp=0xFF0180` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_254 | `\e[38;2;255;1;254m` | - | `fg=0xFF01FE` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_254 | `\e[48;2;255;1;254m` | - | `bg=0xFF01FE` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_254 | `\e[58;2;255;1;254m` | - | `sp=0xFF01FE` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_254 | `\e[38:2::255:1:254m` | - | `fg=0xFF01FE` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_254 | `\e[48:2::255:1:254m` | - | `bg=0xFF01FE` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_254 | `\e[58:2::255:1:254m` | - | `sp=0xFF01FE` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_1_255 | `\e[38;2;255;1;255m` | - | `fg=0xFF01FF` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_1_255 | `\e[48;2;255;1;255m` | - | `bg=0xFF01FF` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_1_255 | `\e[58;2;255;1;255m` | - | `sp=0xFF01FF` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_1_255 | `\e[38:2::255:1:255m` | - | `fg=0xFF01FF` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_1_255 | `\e[48:2::255:1:255m` | - | `bg=0xFF01FF` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_1_255 | `\e[58:2::255:1:255m` | - | `sp=0xFF01FF` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_0 | `\e[38;2;255;127;0m` | - | `fg=0xFF7F00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_0 | `\e[48;2;255;127;0m` | - | `bg=0xFF7F00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_0 | `\e[58;2;255;127;0m` | - | `sp=0xFF7F00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_0 | `\e[38:2::255:127:0m` | - | `fg=0xFF7F00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_0 | `\e[48:2::255:127:0m` | - | `bg=0xFF7F00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_0 | `\e[58:2::255:127:0m` | - | `sp=0xFF7F00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_1 | `\e[38;2;255;127;1m` | - | `fg=0xFF7F01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_1 | `\e[48;2;255;127;1m` | - | `bg=0xFF7F01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_1 | `\e[58;2;255;127;1m` | - | `sp=0xFF7F01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_1 | `\e[38:2::255:127:1m` | - | `fg=0xFF7F01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_1 | `\e[48:2::255:127:1m` | - | `bg=0xFF7F01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_1 | `\e[58:2::255:127:1m` | - | `sp=0xFF7F01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_127 | `\e[38;2;255;127;127m` | - | `fg=0xFF7F7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_127 | `\e[48;2;255;127;127m` | - | `bg=0xFF7F7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_127 | `\e[58;2;255;127;127m` | - | `sp=0xFF7F7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_127 | `\e[38:2::255:127:127m` | - | `fg=0xFF7F7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_127 | `\e[48:2::255:127:127m` | - | `bg=0xFF7F7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_127 | `\e[58:2::255:127:127m` | - | `sp=0xFF7F7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_128 | `\e[38;2;255;127;128m` | - | `fg=0xFF7F80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_128 | `\e[48;2;255;127;128m` | - | `bg=0xFF7F80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_128 | `\e[58;2;255;127;128m` | - | `sp=0xFF7F80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_128 | `\e[38:2::255:127:128m` | - | `fg=0xFF7F80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_128 | `\e[48:2::255:127:128m` | - | `bg=0xFF7F80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_128 | `\e[58:2::255:127:128m` | - | `sp=0xFF7F80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_254 | `\e[38;2;255;127;254m` | - | `fg=0xFF7FFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_254 | `\e[48;2;255;127;254m` | - | `bg=0xFF7FFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_254 | `\e[58;2;255;127;254m` | - | `sp=0xFF7FFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_254 | `\e[38:2::255:127:254m` | - | `fg=0xFF7FFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_254 | `\e[48:2::255:127:254m` | - | `bg=0xFF7FFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_254 | `\e[58:2::255:127:254m` | - | `sp=0xFF7FFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_127_255 | `\e[38;2;255;127;255m` | - | `fg=0xFF7FFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_127_255 | `\e[48;2;255;127;255m` | - | `bg=0xFF7FFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_127_255 | `\e[58;2;255;127;255m` | - | `sp=0xFF7FFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_127_255 | `\e[38:2::255:127:255m` | - | `fg=0xFF7FFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_127_255 | `\e[48:2::255:127:255m` | - | `bg=0xFF7FFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_127_255 | `\e[58:2::255:127:255m` | - | `sp=0xFF7FFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_0 | `\e[38;2;255;128;0m` | - | `fg=0xFF8000` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_0 | `\e[48;2;255;128;0m` | - | `bg=0xFF8000` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_0 | `\e[58;2;255;128;0m` | - | `sp=0xFF8000` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_0 | `\e[38:2::255:128:0m` | - | `fg=0xFF8000` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_0 | `\e[48:2::255:128:0m` | - | `bg=0xFF8000` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_0 | `\e[58:2::255:128:0m` | - | `sp=0xFF8000` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_1 | `\e[38;2;255;128;1m` | - | `fg=0xFF8001` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_1 | `\e[48;2;255;128;1m` | - | `bg=0xFF8001` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_1 | `\e[58;2;255;128;1m` | - | `sp=0xFF8001` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_1 | `\e[38:2::255:128:1m` | - | `fg=0xFF8001` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_1 | `\e[48:2::255:128:1m` | - | `bg=0xFF8001` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_1 | `\e[58:2::255:128:1m` | - | `sp=0xFF8001` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_127 | `\e[38;2;255;128;127m` | - | `fg=0xFF807F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_127 | `\e[48;2;255;128;127m` | - | `bg=0xFF807F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_127 | `\e[58;2;255;128;127m` | - | `sp=0xFF807F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_127 | `\e[38:2::255:128:127m` | - | `fg=0xFF807F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_127 | `\e[48:2::255:128:127m` | - | `bg=0xFF807F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_127 | `\e[58:2::255:128:127m` | - | `sp=0xFF807F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_128 | `\e[38;2;255;128;128m` | - | `fg=0xFF8080` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_128 | `\e[48;2;255;128;128m` | - | `bg=0xFF8080` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_128 | `\e[58;2;255;128;128m` | - | `sp=0xFF8080` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_128 | `\e[38:2::255:128:128m` | - | `fg=0xFF8080` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_128 | `\e[48:2::255:128:128m` | - | `bg=0xFF8080` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_128 | `\e[58:2::255:128:128m` | - | `sp=0xFF8080` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_254 | `\e[38;2;255;128;254m` | - | `fg=0xFF80FE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_254 | `\e[48;2;255;128;254m` | - | `bg=0xFF80FE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_254 | `\e[58;2;255;128;254m` | - | `sp=0xFF80FE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_254 | `\e[38:2::255:128:254m` | - | `fg=0xFF80FE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_254 | `\e[48:2::255:128:254m` | - | `bg=0xFF80FE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_254 | `\e[58:2::255:128:254m` | - | `sp=0xFF80FE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_128_255 | `\e[38;2;255;128;255m` | - | `fg=0xFF80FF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_128_255 | `\e[48;2;255;128;255m` | - | `bg=0xFF80FF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_128_255 | `\e[58;2;255;128;255m` | - | `sp=0xFF80FF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_128_255 | `\e[38:2::255:128:255m` | - | `fg=0xFF80FF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_128_255 | `\e[48:2::255:128:255m` | - | `bg=0xFF80FF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_128_255 | `\e[58:2::255:128:255m` | - | `sp=0xFF80FF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_0 | `\e[38;2;255;254;0m` | - | `fg=0xFFFE00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_0 | `\e[48;2;255;254;0m` | - | `bg=0xFFFE00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_0 | `\e[58;2;255;254;0m` | - | `sp=0xFFFE00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_0 | `\e[38:2::255:254:0m` | - | `fg=0xFFFE00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_0 | `\e[48:2::255:254:0m` | - | `bg=0xFFFE00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_0 | `\e[58:2::255:254:0m` | - | `sp=0xFFFE00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_1 | `\e[38;2;255;254;1m` | - | `fg=0xFFFE01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_1 | `\e[48;2;255;254;1m` | - | `bg=0xFFFE01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_1 | `\e[58;2;255;254;1m` | - | `sp=0xFFFE01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_1 | `\e[38:2::255:254:1m` | - | `fg=0xFFFE01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_1 | `\e[48:2::255:254:1m` | - | `bg=0xFFFE01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_1 | `\e[58:2::255:254:1m` | - | `sp=0xFFFE01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_127 | `\e[38;2;255;254;127m` | - | `fg=0xFFFE7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_127 | `\e[48;2;255;254;127m` | - | `bg=0xFFFE7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_127 | `\e[58;2;255;254;127m` | - | `sp=0xFFFE7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_127 | `\e[38:2::255:254:127m` | - | `fg=0xFFFE7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_127 | `\e[48:2::255:254:127m` | - | `bg=0xFFFE7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_127 | `\e[58:2::255:254:127m` | - | `sp=0xFFFE7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_128 | `\e[38;2;255;254;128m` | - | `fg=0xFFFE80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_128 | `\e[48;2;255;254;128m` | - | `bg=0xFFFE80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_128 | `\e[58;2;255;254;128m` | - | `sp=0xFFFE80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_128 | `\e[38:2::255:254:128m` | - | `fg=0xFFFE80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_128 | `\e[48:2::255:254:128m` | - | `bg=0xFFFE80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_128 | `\e[58:2::255:254:128m` | - | `sp=0xFFFE80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_254 | `\e[38;2;255;254;254m` | - | `fg=0xFFFEFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_254 | `\e[48;2;255;254;254m` | - | `bg=0xFFFEFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_254 | `\e[58;2;255;254;254m` | - | `sp=0xFFFEFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_254 | `\e[38:2::255:254:254m` | - | `fg=0xFFFEFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_254 | `\e[48:2::255:254:254m` | - | `bg=0xFFFEFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_254 | `\e[58:2::255:254:254m` | - | `sp=0xFFFEFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_254_255 | `\e[38;2;255;254;255m` | - | `fg=0xFFFEFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_254_255 | `\e[48;2;255;254;255m` | - | `bg=0xFFFEFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_254_255 | `\e[58;2;255;254;255m` | - | `sp=0xFFFEFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_254_255 | `\e[38:2::255:254:255m` | - | `fg=0xFFFEFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_254_255 | `\e[48:2::255:254:255m` | - | `bg=0xFFFEFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_254_255 | `\e[58:2::255:254:255m` | - | `sp=0xFFFEFF` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_0 | `\e[38;2;255;255;0m` | - | `fg=0xFFFF00` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_0 | `\e[48;2;255;255;0m` | - | `bg=0xFFFF00` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_0 | `\e[58;2;255;255;0m` | - | `sp=0xFFFF00` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_0 | `\e[38:2::255:255:0m` | - | `fg=0xFFFF00` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_0 | `\e[48:2::255:255:0m` | - | `bg=0xFFFF00` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_0 | `\e[58:2::255:255:0m` | - | `sp=0xFFFF00` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_1 | `\e[38;2;255;255;1m` | - | `fg=0xFFFF01` | 0 | 17 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_1 | `\e[48;2;255;255;1m` | - | `bg=0xFFFF01` | 0 | 17 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_1 | `\e[58;2;255;255;1m` | - | `sp=0xFFFF01` | 0 | 17 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_1 | `\e[38:2::255:255:1m` | - | `fg=0xFFFF01` | 0 | 18 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_1 | `\e[48:2::255:255:1m` | - | `bg=0xFFFF01` | 0 | 18 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_1 | `\e[58:2::255:255:1m` | - | `sp=0xFFFF01` | 0 | 18 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_127 | `\e[38;2;255;255;127m` | - | `fg=0xFFFF7F` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_127 | `\e[48;2;255;255;127m` | - | `bg=0xFFFF7F` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_127 | `\e[58;2;255;255;127m` | - | `sp=0xFFFF7F` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_127 | `\e[38:2::255:255:127m` | - | `fg=0xFFFF7F` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_127 | `\e[48:2::255:255:127m` | - | `bg=0xFFFF7F` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_127 | `\e[58:2::255:255:127m` | - | `sp=0xFFFF7F` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_128 | `\e[38;2;255;255;128m` | - | `fg=0xFFFF80` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_128 | `\e[48;2;255;255;128m` | - | `bg=0xFFFF80` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_128 | `\e[58;2;255;255;128m` | - | `sp=0xFFFF80` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_128 | `\e[38:2::255:255:128m` | - | `fg=0xFFFF80` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_128 | `\e[48:2::255:255:128m` | - | `bg=0xFFFF80` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_128 | `\e[58:2::255:255:128m` | - | `sp=0xFFFF80` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_254 | `\e[38;2;255;255;254m` | - | `fg=0xFFFFFE` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_254 | `\e[48;2;255;255;254m` | - | `bg=0xFFFFFE` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_254 | `\e[58;2;255;255;254m` | - | `sp=0xFFFFFE` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_254 | `\e[38:2::255:255:254m` | - | `fg=0xFFFFFE` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_254 | `\e[48:2::255:255:254m` | - | `bg=0xFFFFFE` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_254 | `\e[58:2::255:255:254m` | - | `sp=0xFFFFFE` | 0 | 20 | T.416 truecolor underline boundary grid |
| sgr | rgb_grid_255_255_255 | `\e[38;2;255;255;255m` | - | `fg=0xFFFFFF` | 0 | 19 | xterm truecolor foreground boundary grid |
| sgr | rgb_grid_bg_255_255_255 | `\e[48;2;255;255;255m` | - | `bg=0xFFFFFF` | 0 | 19 | xterm truecolor background boundary grid |
| sgr | rgb_grid_sp_255_255_255 | `\e[58;2;255;255;255m` | - | `sp=0xFFFFFF` | 0 | 19 | xterm truecolor underline boundary grid |
| sgr | iso_rgb_grid_255_255_255 | `\e[38:2::255:255:255m` | - | `fg=0xFFFFFF` | 0 | 20 | T.416 truecolor foreground boundary grid |
| sgr | iso_rgb_grid_bg_255_255_255 | `\e[48:2::255:255:255m` | - | `bg=0xFFFFFF` | 0 | 20 | T.416 truecolor background boundary grid |
| sgr | iso_rgb_grid_sp_255_255_255 | `\e[58:2::255:255:255m` | - | `sp=0xFFFFFF` | 0 | 20 | T.416 truecolor underline boundary grid |

## sgr ISO indexed and RGB

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | empty_csid | `\e[38:2::255:128:64m` | - | `fg=0xFF8040` | 0 | 19 | standard RGB form |
| sgr | csid_zero | `\e[38:2:0:255:128:64m` | - | `fg=0xFF8040` | 0 | 20 | explicit colour space 0 |
| sgr | csid_one | `\e[38:2:1:12:34:56m` | - | `fg=0x0C2238` | 0 | 18 | explicit colour space 1 |
| sgr | csid_large | `\e[38:2:9999:12:34:56m` | - | `fg=0x0C2238` | 0 | 21 | CSID is not channel-limited |
| sgr | csid_is_not_red | `\e[38:2:1:2:3m` | - | `fg=0x020300` | 0 | 13 | CSID=1, R=2, G=3, B default 0 |
| sgr | csid_is_not_red_2 | `\e[38:2:255:128:64m` | - | `fg=0x804000` | 0 | 18 | CSID slot is skipped |
| sgr | empty_channels | `\e[38:2::m` | - | `fg=0x000000` | 0 | 9 | empty channels default to 0 |
| sgr | one_channel | `\e[38:2::255m` | - | `fg=0xFF0000` | 0 | 12 | trailing G and B default to 0 |
| sgr | two_channels | `\e[38:2::255:128m` | - | `fg=0xFF8000` | 0 | 16 | trailing B defaults to 0 |
| sgr | empty_middle | `\e[38:2::255::64m` | - | `fg=0xFF0040` | 0 | 16 | empty G defaults to 0 |
| sgr | empty_red | `\e[38:2::::64m` | - | `fg=0x000040` | 0 | 13 | empty R and G default to 0 |
| sgr | mode_only | `\e[38:2m` | - | `fg=0x000000` | 0 | 7 | all elements default to 0 |
| sgr | csid_only | `\e[38:2:7m` | - | `fg=0x000000` | 0 | 9 | channels default to 0 |
| sgr | followed_by_bg | `\e[38:2::1:2:3;44m` | - | `fg=0x010203,bg=0x0000EE` | 0 | 17 | ISO color followed by ANSI bg |
| sgr | pe6 | `\e[38:2::1:2:3:0m` | - | `fg=0x010203` | 0 | 16 | PE6 has no meaning |
| sgr | pe7 | `\e[38:2::1:2:3:0:5m` | - | `fg=0x010203` | 0 | 18 | PE7 tolerance consumed |
| sgr | pe8_cieluv | `\e[38:2::1:2:3:0:0:0m` | - | `fg=0x010203` | 0 | 20 | PE8 CIELUV |
| sgr | pe8_cielab | `\e[38:2::1:2:3:0:0:1m` | - | `fg=0x010203` | 0 | 20 | PE8 CIELAB |
| sgr | bg_empty_csid | `\e[48:2::253:200:15m` | - | `bg=0xFDC80F` | 0 | 19 | background RGB |
| sgr | sp_empty_csid | `\e[58:2::81:155:120m` | - | `sp=0x519B78` | 0 | 19 | underline RGB |
| sgr | index_0 | `\e[38:5:0m` | - | `fg=0x000000` | 0 | 9 | first palette entry |
| sgr | index_255 | `\e[38:5:255m` | - | `fg=0xEEEEEE` | 0 | 11 | last palette entry |
| sgr | index_196 | `\e[38:5:196m` | - | `fg=0xFF0000` | 0 | 11 | cube red |
| sgr | index_empty | `\e[38:5:m` | - | `fg=0x000000` | 0 | 8 | empty element defaults to 0 |
| sgr | index_mode_only | `\e[38:5m` | - | `fg=0x000000` | 0 | 7 | omitted element defaults to 0 |
| sgr | index_followed_by_bg | `\e[38:5;44m` | - | `fg=0x000000,bg=0x0000EE` | 0 | 10 | semicolon starts new parameter |

## sgr ISO CMY and CMYK

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | cmy_zero | `\e[38:3::0:0:0m` | - | `fg=0xFFFFFF` | 0 | 14 | no ink |
| sgr | cmy_full | `\e[38:3::255:255:255m` | - | `fg=0x000000` | 0 | 20 | full ink |
| sgr | cmy_red | `\e[38:3::0:255:255m` | - | `fg=0xFF0000` | 0 | 18 | red |
| sgr | cmy_green | `\e[38:3::255:0:255m` | - | `fg=0x00FF00` | 0 | 18 | green |
| sgr | cmy_blue | `\e[38:3::255:255:0m` | - | `fg=0x0000FF` | 0 | 18 | blue |
| sgr | cmy_arbitrary | `\e[38:3::1:2:3m` | - | `fg=0xFEFDFC` | 0 | 14 | inverted components |
| sgr | cmy_defaults | `\e[38:3::m` | - | `fg=0xFFFFFF` | 0 | 9 | empty components default to 0 |
| sgr | cmy_mode_only | `\e[38:3m` | - | `fg=0xFFFFFF` | 0 | 7 | omitted components default to 0 |
| sgr | cmy_numeric_csid | `\e[38:3:7:0:255:255m` | - | `fg=0xFF0000` | 0 | 19 | numeric colour space |
| sgr | cmyk_zero | `\e[38:4::0:0:0:0m` | - | `fg=0xFFFFFF` | 0 | 16 | no ink |
| sgr | cmyk_black_by_k | `\e[38:4::0:0:0:255m` | - | `fg=0x000000` | 0 | 18 | full K |
| sgr | cmyk_black_by_cmy | `\e[38:4::255:255:255:0m` | - | `fg=0x000000` | 0 | 22 | full C, M and Y |
| sgr | cmyk_arbitrary | `\e[38:4::0:128:255:64m` | - | `fg=0xBF5F00` | 0 | 21 | mixed CMYK |
| sgr | cmyk_arbitrary_2 | `\e[38:4::255:0:0:128m` | - | `fg=0x007F7F` | 0 | 20 | mixed CMYK |
| sgr | cmyk_defaults | `\e[38:4::m` | - | `fg=0xFFFFFF` | 0 | 9 | empty components default to 0 |
| sgr | cmyk_mode_only | `\e[38:4m` | - | `fg=0xFFFFFF` | 0 | 7 | omitted components default to 0 |
| sgr | cmy_bg | `\e[48:3::0:255:255m` | - | `bg=0xFF0000` | 0 | 18 | CMY background |
| sgr | cmy_sp | `\e[58:3::0:255:255m` | - | `sp=0xFF0000` | 0 | 18 | CMY underline |
| sgr | cmyk_bg | `\e[48:4::0:128:255:64m` | - | `bg=0xBF5F00` | 0 | 21 | CMYK background |
| sgr | cmyk_sp | `\e[58:4::0:128:255:64m` | - | `sp=0xBF5F00` | 0 | 21 | CMYK underline |

## sgr ISO modes and compatibility

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | mode0 | `\e[38:0m` | - | - | - | - | implementation-defined, no RGB conversion |
| sgr | mode0_bg | `\e[48:0:1:2:3m` | - | - | - | - | mode 0 has no extra elements |
| sgr | mode1_fg | `\e[38:1m` | - | `fg=NONE` | 0 | 7 | transparent foreground |
| sgr | mode1_bg | `\e[48:1m` | - | `bg=NONE` | 0 | 7 | transparent background |
| sgr | mode1_sp | `\e[58:1m` | - | `sp=NONE` | 0 | 7 | transparent underline |
| sgr | mode0_extra_consumed | `\e[31;38:0:1:2:3;44m` | - | `fg=0xCD0000,bg=0x0000EE` | 0 | 19 | extra elements do not leak |
| sgr | mode1_extra_consumed | `\e[31;38:1:1:2:3;44m` | - | `fg=0xCD0000,bg=0x0000EE` | 0 | 19 | extra elements do not leak |
| sgr | mode1_followed_by_bg | `\e[38:1;44m` | - | `fg=NONE,bg=0x0000EE` | 0 | 10 | transparent fg with ANSI bg |
| sgr | compat_csid_0 | `\e[38;2:0:255:128:64m` | - | `fg=0xFF8040` | 0 | 20 | xterm/ISO mixed form |
| sgr | compat_csid_1_bg | `\e[48;2:1:12:34:56m` | - | `bg=0x0C2238` | 0 | 18 | xterm/ISO mixed form |
| sgr | compat_csid_0_sp | `\e[58;2:0:1:2:3m` | - | `sp=0x010203` | 0 | 15 | xterm/ISO mixed form |
| sgr | compat_followed_by_bg | `\e[38;2:0:255:128:64;44m` | - | `fg=0xFF8040,bg=0x0000EE` | 0 | 23 | following SGR remains available |

## sgr invalid and preserved colors

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | index_256 | `\e[38;5;256m` | - | - | - | - | index above 255 |
| sgr | colon_index_256 | `\e[38:5:256m` | - | - | - | - | index above 255 |
| sgr | red_256 | `\e[38;2;256;0;0m` | - | - | - | - | channel above 255 |
| sgr | green_256 | `\e[38;2;0;256;0m` | - | - | - | - | channel above 255 |
| sgr | blue_256 | `\e[38;2;0;0;256m` | - | - | - | - | channel above 255 |
| sgr | colon_red_256 | `\e[38:2::256:0:0m` | - | - | - | - | channel above 255 |
| sgr | colon_green_256 | `\e[38:2::0:256:0m` | - | - | - | - | channel above 255 |
| sgr | colon_blue_256 | `\e[38:2::0:0:256m` | - | - | - | - | channel above 255 |
| sgr | missing_blue | `\e[38;2;255;128m` | - | - | - | - | incomplete xterm RGB |
| sgr | empty_index | `\e[38;5;m` | - | - | - | - | empty xterm index |
| sgr | extra_index | `\e[38:5:1:2m` | - | - | - | - | too many ISO index fields |
| sgr | extra_rgb | `\e[38:2::1:2:3:0:0:1:2m` | - | - | - | - | too many ISO RGB fields |
| sgr | bad_pe8 | `\e[38:2::1:2:3:0:0:2m` | - | - | - | - | PE8 must be 0 or 1 |
| sgr | unknown_mode | `\e[38:9:1:2:3m` | - | - | - | - | unsupported ISO mode |
| sgr | non_digit | `\e[38;2;1;x;3m` | - | - | - | - | non-decimal parameter |
| sgr | trailing_colon | `\e[38:m` | - | - | - | - | mode missing |
| sgr | double_colon_mode | `\e[38::5:1m` | - | - | - | - | empty mode |
| sgr | arabic_digits | `\e[\xD9\xA3\xD9\xA1m` | - | - | - | - | only ASCII digits match |
| sgr | preserve_fg | `\e[31;38:2::256:0:0m` | - | `fg=0xCD0000` | 0 | 19 | bad RGB does not clear ANSI fg |
| sgr | preserve_bg | `\e[44;38;5;256m` | - | `bg=0x0000EE` | 0 | 14 | bad index does not clear ANSI bg |
| sgr | preserve_sp | `\e[58;5;21;58;5;256m` | - | `sp=0x0000FF` | 0 | 19 | bad underline does not clear sp |

## sgr introducers

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| sgr | introducer_literal_033 | `\\033[31m` | - | `fg=0xCD0000` | 0 | 8 | literal Lua-style ESC |
| sgr | introducer_literal_027 | `\\027[1;34m` | - | `fg=0x0000EE` | 0 | 10 | decimal-style ESC |
| sgr | introducer_literal_27 | `\\27[31m` | - | `fg=0xCD0000` | 0 | 7 | short decimal ESC |
| sgr | introducer_literal_x1b | `\\x1b[31m` | - | `fg=0xCD0000` | 0 | 8 | lowercase hex ESC |
| sgr | introducer_literal_x1B | `\\x1B[31m` | - | `fg=0xCD0000` | 0 | 8 | uppercase hex ESC |
| sgr | introducer_literal_e | `\\e[31m` | - | `fg=0xCD0000` | 0 | 6 | literal caret-style ESC |
| sgr | introducer_literal_E | `\\E[31m` | - | `fg=0xCD0000` | 0 | 6 | uppercase literal ESC |
| sgr | introducer_literal_u001b | `\\u001b[31m` | - | `fg=0xCD0000` | 0 | 10 | unicode escape |
| sgr | introducer_literal_u001B | `\\u001B[31m` | - | `fg=0xCD0000` | 0 | 10 | uppercase unicode escape |
| sgr | introducer_literal_u_braces | `\\u{1b}[31m` | - | `fg=0xCD0000` | 0 | 10 | braced unicode escape |
| sgr | introducer_literal_u_braces_upper | `\\u{1B}[31m` | - | `fg=0xCD0000` | 0 | 10 | uppercase braced unicode escape |
| sgr | introducer_literal_x_braces | `\\x{1b}[31m` | - | `fg=0xCD0000` | 0 | 10 | braced hex escape |
| sgr | introducer_literal_x_braces_upper | `\\x{1B}[31m` | - | `fg=0xCD0000` | 0 | 10 | uppercase braced hex escape |
| sgr | introducer_literal_caret | `^[[31m` | - | `fg=0xCD0000` | 0 | 6 | caret notation |
| sgr | introducer_literal_c1_9b | `\\x9b31m` | - | `fg=0xCD0000` | 0 | 7 | literal C1 CSI without bracket |
| sgr | introducer_literal_c1_9B | `\\x9B31m` | - | `fg=0xCD0000` | 0 | 7 | uppercase literal C1 CSI |
| sgr | introducer_literal_c1_u009b | `\\u009b31m` | - | `fg=0xCD0000` | 0 | 9 | unicode C1 CSI |
| sgr | introducer_literal_c1_u009B | `\\u009B31m` | - | `fg=0xCD0000` | 0 | 9 | uppercase unicode C1 CSI |
| sgr | introducer_literal_c1_u_braces | `\\u{9b}31m` | - | `fg=0xCD0000` | 0 | 9 | braced unicode C1 CSI |
| sgr | introducer_literal_c1_u_braces_upper | `\\u{9B}31m` | - | `fg=0xCD0000` | 0 | 9 | uppercase braced unicode C1 CSI |
| sgr | introducer_literal_c1_x_braces | `\\x{9b}31m` | - | `fg=0xCD0000` | 0 | 9 | braced hex C1 CSI |
| sgr | introducer_literal_c1_x_braces_upper | `\\x{9B}31m` | - | `fg=0xCD0000` | 0 | 9 | uppercase braced hex C1 CSI |
| sgr | introducer_utf8_csi | `\xC2\x9B31m` | - | `fg=0xCD0000` | 0 | 5 | UTF-8 encoded C1 CSI |
| sgr | introducer_offset | `before \e[31m after` | - | `fg=0xCD0000` | 7 | 12 | sequence inside a line |

## tailwind parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| tailwind | palette_black | `bg-black` | - | `0x000000` | 0 | 8 | bg utility |
| tailwind | palette_white | `bg-white` | - | `0xFFFFFF` | 0 | 8 | bg utility |
| tailwind | palette_slate_50 | `bg-slate-50` | - | `0xF8FAFC` | 0 | 11 | bg utility |
| tailwind | palette_slate_100 | `bg-slate-100` | - | `0xF1F5F9` | 0 | 12 | bg utility |
| tailwind | palette_slate_200 | `bg-slate-200` | - | `0xE2E8F0` | 0 | 12 | bg utility |
| tailwind | palette_slate_300 | `bg-slate-300` | - | `0xCBD5E1` | 0 | 12 | bg utility |
| tailwind | palette_slate_400 | `bg-slate-400` | - | `0x94A3B8` | 0 | 12 | bg utility |
| tailwind | palette_slate_500 | `bg-slate-500` | - | `0x64748B` | 0 | 12 | bg utility |
| tailwind | palette_slate_600 | `bg-slate-600` | - | `0x475569` | 0 | 12 | bg utility |
| tailwind | palette_slate_700 | `bg-slate-700` | - | `0x334155` | 0 | 12 | bg utility |
| tailwind | palette_slate_800 | `bg-slate-800` | - | `0x1E293B` | 0 | 12 | bg utility |
| tailwind | palette_slate_900 | `bg-slate-900` | - | `0x0F172A` | 0 | 12 | bg utility |
| tailwind | palette_gray_50 | `bg-gray-50` | - | `0xF9FAFB` | 0 | 10 | bg utility |
| tailwind | palette_gray_100 | `bg-gray-100` | - | `0xF3F4F6` | 0 | 11 | bg utility |
| tailwind | palette_gray_200 | `bg-gray-200` | - | `0xE5E7EB` | 0 | 11 | bg utility |
| tailwind | palette_gray_300 | `bg-gray-300` | - | `0xD1D5DB` | 0 | 11 | bg utility |
| tailwind | palette_gray_400 | `bg-gray-400` | - | `0x9CA3AF` | 0 | 11 | bg utility |
| tailwind | palette_gray_500 | `bg-gray-500` | - | `0x6B7280` | 0 | 11 | bg utility |
| tailwind | palette_gray_600 | `bg-gray-600` | - | `0x4B5563` | 0 | 11 | bg utility |
| tailwind | palette_gray_700 | `bg-gray-700` | - | `0x374151` | 0 | 11 | bg utility |
| tailwind | palette_gray_800 | `bg-gray-800` | - | `0x1F2937` | 0 | 11 | bg utility |
| tailwind | palette_gray_900 | `bg-gray-900` | - | `0x111827` | 0 | 11 | bg utility |
| tailwind | palette_zinc_50 | `bg-zinc-50` | - | `0xFAFAFA` | 0 | 10 | bg utility |
| tailwind | palette_zinc_100 | `bg-zinc-100` | - | `0xF4F4F5` | 0 | 11 | bg utility |
| tailwind | palette_zinc_200 | `bg-zinc-200` | - | `0xE4E4E7` | 0 | 11 | bg utility |
| tailwind | palette_zinc_300 | `bg-zinc-300` | - | `0xD4D4D8` | 0 | 11 | bg utility |
| tailwind | palette_zinc_400 | `bg-zinc-400` | - | `0xA1A1AA` | 0 | 11 | bg utility |
| tailwind | palette_zinc_500 | `bg-zinc-500` | - | `0x71717A` | 0 | 11 | bg utility |
| tailwind | palette_zinc_600 | `bg-zinc-600` | - | `0x52525B` | 0 | 11 | bg utility |
| tailwind | palette_zinc_700 | `bg-zinc-700` | - | `0x3F3F46` | 0 | 11 | bg utility |
| tailwind | palette_zinc_800 | `bg-zinc-800` | - | `0x27272A` | 0 | 11 | bg utility |
| tailwind | palette_zinc_900 | `bg-zinc-900` | - | `0x18181B` | 0 | 11 | bg utility |
| tailwind | palette_neutral_50 | `bg-neutral-50` | - | `0xFAFAFA` | 0 | 13 | bg utility |
| tailwind | palette_neutral_100 | `bg-neutral-100` | - | `0xF5F5F5` | 0 | 14 | bg utility |
| tailwind | palette_neutral_200 | `bg-neutral-200` | - | `0xE5E5E5` | 0 | 14 | bg utility |
| tailwind | palette_neutral_300 | `bg-neutral-300` | - | `0xD4D4D4` | 0 | 14 | bg utility |
| tailwind | palette_neutral_400 | `bg-neutral-400` | - | `0xA3A3A3` | 0 | 14 | bg utility |
| tailwind | palette_neutral_500 | `bg-neutral-500` | - | `0x737373` | 0 | 14 | bg utility |
| tailwind | palette_neutral_600 | `bg-neutral-600` | - | `0x525252` | 0 | 14 | bg utility |
| tailwind | palette_neutral_700 | `bg-neutral-700` | - | `0x404040` | 0 | 14 | bg utility |
| tailwind | palette_neutral_800 | `bg-neutral-800` | - | `0x262626` | 0 | 14 | bg utility |
| tailwind | palette_neutral_900 | `bg-neutral-900` | - | `0x171717` | 0 | 14 | bg utility |
| tailwind | palette_stone_50 | `bg-stone-50` | - | `0xFAFAF9` | 0 | 11 | bg utility |
| tailwind | palette_stone_100 | `bg-stone-100` | - | `0xF5F5F4` | 0 | 12 | bg utility |
| tailwind | palette_stone_200 | `bg-stone-200` | - | `0xE7E5E4` | 0 | 12 | bg utility |
| tailwind | palette_stone_300 | `bg-stone-300` | - | `0xD6D3D1` | 0 | 12 | bg utility |
| tailwind | palette_stone_400 | `bg-stone-400` | - | `0xA8A29E` | 0 | 12 | bg utility |
| tailwind | palette_stone_500 | `bg-stone-500` | - | `0x78716C` | 0 | 12 | bg utility |
| tailwind | palette_stone_600 | `bg-stone-600` | - | `0x57534E` | 0 | 12 | bg utility |
| tailwind | palette_stone_700 | `bg-stone-700` | - | `0x44403C` | 0 | 12 | bg utility |
| tailwind | palette_stone_800 | `bg-stone-800` | - | `0x292524` | 0 | 12 | bg utility |
| tailwind | palette_stone_900 | `bg-stone-900` | - | `0x1C1917` | 0 | 12 | bg utility |
| tailwind | palette_red_50 | `bg-red-50` | - | `0xFEF2F2` | 0 | 9 | bg utility |
| tailwind | palette_red_100 | `bg-red-100` | - | `0xFEE2E2` | 0 | 10 | bg utility |
| tailwind | palette_red_200 | `bg-red-200` | - | `0xFECACA` | 0 | 10 | bg utility |
| tailwind | palette_red_300 | `bg-red-300` | - | `0xFCA5A5` | 0 | 10 | bg utility |
| tailwind | palette_red_400 | `bg-red-400` | - | `0xF87171` | 0 | 10 | bg utility |
| tailwind | palette_red_500 | `bg-red-500` | - | `0xEF4444` | 0 | 10 | bg utility |
| tailwind | palette_red_600 | `bg-red-600` | - | `0xDC2626` | 0 | 10 | bg utility |
| tailwind | palette_red_700 | `bg-red-700` | - | `0xB91C1C` | 0 | 10 | bg utility |
| tailwind | palette_red_800 | `bg-red-800` | - | `0x991B1B` | 0 | 10 | bg utility |
| tailwind | palette_red_900 | `bg-red-900` | - | `0x7F1D1D` | 0 | 10 | bg utility |
| tailwind | palette_orange_50 | `bg-orange-50` | - | `0xFFF7ED` | 0 | 12 | bg utility |
| tailwind | palette_orange_100 | `bg-orange-100` | - | `0xFFEDD5` | 0 | 13 | bg utility |
| tailwind | palette_orange_200 | `bg-orange-200` | - | `0xFED7AA` | 0 | 13 | bg utility |
| tailwind | palette_orange_300 | `bg-orange-300` | - | `0xFDBA74` | 0 | 13 | bg utility |
| tailwind | palette_orange_400 | `bg-orange-400` | - | `0xFB923C` | 0 | 13 | bg utility |
| tailwind | palette_orange_500 | `bg-orange-500` | - | `0xF97316` | 0 | 13 | bg utility |
| tailwind | palette_orange_600 | `bg-orange-600` | - | `0xEA580C` | 0 | 13 | bg utility |
| tailwind | palette_orange_700 | `bg-orange-700` | - | `0xC2410C` | 0 | 13 | bg utility |
| tailwind | palette_orange_800 | `bg-orange-800` | - | `0x9A3412` | 0 | 13 | bg utility |
| tailwind | palette_orange_900 | `bg-orange-900` | - | `0x7C2D12` | 0 | 13 | bg utility |
| tailwind | palette_amber_50 | `bg-amber-50` | - | `0xFFFBEB` | 0 | 11 | bg utility |
| tailwind | palette_amber_100 | `bg-amber-100` | - | `0xFEF3C7` | 0 | 12 | bg utility |
| tailwind | palette_amber_200 | `bg-amber-200` | - | `0xFDE68A` | 0 | 12 | bg utility |
| tailwind | palette_amber_300 | `bg-amber-300` | - | `0xFCD34D` | 0 | 12 | bg utility |
| tailwind | palette_amber_400 | `bg-amber-400` | - | `0xFBBF24` | 0 | 12 | bg utility |
| tailwind | palette_amber_500 | `bg-amber-500` | - | `0xF59E0B` | 0 | 12 | bg utility |
| tailwind | palette_amber_600 | `bg-amber-600` | - | `0xD97706` | 0 | 12 | bg utility |
| tailwind | palette_amber_700 | `bg-amber-700` | - | `0xB45309` | 0 | 12 | bg utility |
| tailwind | palette_amber_800 | `bg-amber-800` | - | `0x92400E` | 0 | 12 | bg utility |
| tailwind | palette_amber_900 | `bg-amber-900` | - | `0x78350F` | 0 | 12 | bg utility |
| tailwind | palette_yellow_50 | `bg-yellow-50` | - | `0xFEFCE8` | 0 | 12 | bg utility |
| tailwind | palette_yellow_100 | `bg-yellow-100` | - | `0xFEF9C3` | 0 | 13 | bg utility |
| tailwind | palette_yellow_200 | `bg-yellow-200` | - | `0xFEF08A` | 0 | 13 | bg utility |
| tailwind | palette_yellow_300 | `bg-yellow-300` | - | `0xFDE047` | 0 | 13 | bg utility |
| tailwind | palette_yellow_400 | `bg-yellow-400` | - | `0xFACC15` | 0 | 13 | bg utility |
| tailwind | palette_yellow_500 | `bg-yellow-500` | - | `0xEAB308` | 0 | 13 | bg utility |
| tailwind | palette_yellow_600 | `bg-yellow-600` | - | `0xCA8A04` | 0 | 13 | bg utility |
| tailwind | palette_yellow_700 | `bg-yellow-700` | - | `0xA16207` | 0 | 13 | bg utility |
| tailwind | palette_yellow_800 | `bg-yellow-800` | - | `0x854D0E` | 0 | 13 | bg utility |
| tailwind | palette_yellow_900 | `bg-yellow-900` | - | `0x713F12` | 0 | 13 | bg utility |
| tailwind | palette_lime_50 | `bg-lime-50` | - | `0xF7FEE7` | 0 | 10 | bg utility |
| tailwind | palette_lime_100 | `bg-lime-100` | - | `0xECFCCB` | 0 | 11 | bg utility |
| tailwind | palette_lime_200 | `bg-lime-200` | - | `0xD9F99D` | 0 | 11 | bg utility |
| tailwind | palette_lime_300 | `bg-lime-300` | - | `0xBEF264` | 0 | 11 | bg utility |
| tailwind | palette_lime_400 | `bg-lime-400` | - | `0xA3E635` | 0 | 11 | bg utility |
| tailwind | palette_lime_500 | `bg-lime-500` | - | `0x84CC16` | 0 | 11 | bg utility |
| tailwind | palette_lime_600 | `bg-lime-600` | - | `0x65A30D` | 0 | 11 | bg utility |
| tailwind | palette_lime_700 | `bg-lime-700` | - | `0x4D7C0F` | 0 | 11 | bg utility |
| tailwind | palette_lime_800 | `bg-lime-800` | - | `0x3F6212` | 0 | 11 | bg utility |
| tailwind | palette_lime_900 | `bg-lime-900` | - | `0x365314` | 0 | 11 | bg utility |
| tailwind | palette_green_50 | `bg-green-50` | - | `0xF0FDF4` | 0 | 11 | bg utility |
| tailwind | palette_green_100 | `bg-green-100` | - | `0xDCFCE7` | 0 | 12 | bg utility |
| tailwind | palette_green_200 | `bg-green-200` | - | `0xBBF7D0` | 0 | 12 | bg utility |
| tailwind | palette_green_300 | `bg-green-300` | - | `0x86EFAC` | 0 | 12 | bg utility |
| tailwind | palette_green_400 | `bg-green-400` | - | `0x4ADE80` | 0 | 12 | bg utility |
| tailwind | palette_green_500 | `bg-green-500` | - | `0x22C55E` | 0 | 12 | bg utility |
| tailwind | palette_green_600 | `bg-green-600` | - | `0x16A34A` | 0 | 12 | bg utility |
| tailwind | palette_green_700 | `bg-green-700` | - | `0x15803D` | 0 | 12 | bg utility |
| tailwind | palette_green_800 | `bg-green-800` | - | `0x166534` | 0 | 12 | bg utility |
| tailwind | palette_green_900 | `bg-green-900` | - | `0x14532D` | 0 | 12 | bg utility |
| tailwind | palette_emerald_50 | `bg-emerald-50` | - | `0xECFDF5` | 0 | 13 | bg utility |
| tailwind | palette_emerald_100 | `bg-emerald-100` | - | `0xD1FAE5` | 0 | 14 | bg utility |
| tailwind | palette_emerald_200 | `bg-emerald-200` | - | `0xA7F3D0` | 0 | 14 | bg utility |
| tailwind | palette_emerald_300 | `bg-emerald-300` | - | `0x6EE7B7` | 0 | 14 | bg utility |
| tailwind | palette_emerald_400 | `bg-emerald-400` | - | `0x34D399` | 0 | 14 | bg utility |
| tailwind | palette_emerald_500 | `bg-emerald-500` | - | `0x10B981` | 0 | 14 | bg utility |
| tailwind | palette_emerald_600 | `bg-emerald-600` | - | `0x059669` | 0 | 14 | bg utility |
| tailwind | palette_emerald_700 | `bg-emerald-700` | - | `0x047857` | 0 | 14 | bg utility |
| tailwind | palette_emerald_800 | `bg-emerald-800` | - | `0x065F46` | 0 | 14 | bg utility |
| tailwind | palette_emerald_900 | `bg-emerald-900` | - | `0x064E3B` | 0 | 14 | bg utility |
| tailwind | palette_teal_50 | `bg-teal-50` | - | `0xF0FDFA` | 0 | 10 | bg utility |
| tailwind | palette_teal_100 | `bg-teal-100` | - | `0xCCFBF1` | 0 | 11 | bg utility |
| tailwind | palette_teal_200 | `bg-teal-200` | - | `0x99F6E4` | 0 | 11 | bg utility |
| tailwind | palette_teal_300 | `bg-teal-300` | - | `0x5EEAD4` | 0 | 11 | bg utility |
| tailwind | palette_teal_400 | `bg-teal-400` | - | `0x2DD4BF` | 0 | 11 | bg utility |
| tailwind | palette_teal_500 | `bg-teal-500` | - | `0x14B8A6` | 0 | 11 | bg utility |
| tailwind | palette_teal_600 | `bg-teal-600` | - | `0x0D9488` | 0 | 11 | bg utility |
| tailwind | palette_teal_700 | `bg-teal-700` | - | `0x0F766E` | 0 | 11 | bg utility |
| tailwind | palette_teal_800 | `bg-teal-800` | - | `0x115E59` | 0 | 11 | bg utility |
| tailwind | palette_teal_900 | `bg-teal-900` | - | `0x134E4A` | 0 | 11 | bg utility |
| tailwind | palette_cyan_50 | `bg-cyan-50` | - | `0xECFEFF` | 0 | 10 | bg utility |
| tailwind | palette_cyan_100 | `bg-cyan-100` | - | `0xCFFAFE` | 0 | 11 | bg utility |
| tailwind | palette_cyan_200 | `bg-cyan-200` | - | `0xA5F3FC` | 0 | 11 | bg utility |
| tailwind | palette_cyan_300 | `bg-cyan-300` | - | `0x67E8F9` | 0 | 11 | bg utility |
| tailwind | palette_cyan_400 | `bg-cyan-400` | - | `0x22D3EE` | 0 | 11 | bg utility |
| tailwind | palette_cyan_500 | `bg-cyan-500` | - | `0x06B6D4` | 0 | 11 | bg utility |
| tailwind | palette_cyan_600 | `bg-cyan-600` | - | `0x0891B2` | 0 | 11 | bg utility |
| tailwind | palette_cyan_700 | `bg-cyan-700` | - | `0x0E7490` | 0 | 11 | bg utility |
| tailwind | palette_cyan_800 | `bg-cyan-800` | - | `0x155E75` | 0 | 11 | bg utility |
| tailwind | palette_cyan_900 | `bg-cyan-900` | - | `0x164E63` | 0 | 11 | bg utility |
| tailwind | palette_sky_50 | `bg-sky-50` | - | `0xF0F9FF` | 0 | 9 | bg utility |
| tailwind | palette_sky_100 | `bg-sky-100` | - | `0xE0F2FE` | 0 | 10 | bg utility |
| tailwind | palette_sky_200 | `bg-sky-200` | - | `0xBAE6FD` | 0 | 10 | bg utility |
| tailwind | palette_sky_300 | `bg-sky-300` | - | `0x7DD3FC` | 0 | 10 | bg utility |
| tailwind | palette_sky_400 | `bg-sky-400` | - | `0x38BDF8` | 0 | 10 | bg utility |
| tailwind | palette_sky_500 | `bg-sky-500` | - | `0x0EA5E9` | 0 | 10 | bg utility |
| tailwind | palette_sky_600 | `bg-sky-600` | - | `0x0284C7` | 0 | 10 | bg utility |
| tailwind | palette_sky_700 | `bg-sky-700` | - | `0x0369A1` | 0 | 10 | bg utility |
| tailwind | palette_sky_800 | `bg-sky-800` | - | `0x075985` | 0 | 10 | bg utility |
| tailwind | palette_sky_900 | `bg-sky-900` | - | `0x0C4A6E` | 0 | 10 | bg utility |
| tailwind | palette_blue_50 | `bg-blue-50` | - | `0xEFF6FF` | 0 | 10 | bg utility |
| tailwind | palette_blue_100 | `bg-blue-100` | - | `0xDBEAFE` | 0 | 11 | bg utility |
| tailwind | palette_blue_200 | `bg-blue-200` | - | `0xBFDBFE` | 0 | 11 | bg utility |
| tailwind | palette_blue_300 | `bg-blue-300` | - | `0x93C5FD` | 0 | 11 | bg utility |
| tailwind | palette_blue_400 | `bg-blue-400` | - | `0x60A5FA` | 0 | 11 | bg utility |
| tailwind | palette_blue_500 | `bg-blue-500` | - | `0x3B82F6` | 0 | 11 | bg utility |
| tailwind | palette_blue_600 | `bg-blue-600` | - | `0x2563EB` | 0 | 11 | bg utility |
| tailwind | palette_blue_700 | `bg-blue-700` | - | `0x1D4ED8` | 0 | 11 | bg utility |
| tailwind | palette_blue_800 | `bg-blue-800` | - | `0x1E40AF` | 0 | 11 | bg utility |
| tailwind | palette_blue_900 | `bg-blue-900` | - | `0x1E3A8A` | 0 | 11 | bg utility |
| tailwind | palette_indigo_50 | `bg-indigo-50` | - | `0xEEF2FF` | 0 | 12 | bg utility |
| tailwind | palette_indigo_100 | `bg-indigo-100` | - | `0xE0E7FF` | 0 | 13 | bg utility |
| tailwind | palette_indigo_200 | `bg-indigo-200` | - | `0xC7D2FE` | 0 | 13 | bg utility |
| tailwind | palette_indigo_300 | `bg-indigo-300` | - | `0xA5B4FC` | 0 | 13 | bg utility |
| tailwind | palette_indigo_400 | `bg-indigo-400` | - | `0x818CF8` | 0 | 13 | bg utility |
| tailwind | palette_indigo_500 | `bg-indigo-500` | - | `0x6366F1` | 0 | 13 | bg utility |
| tailwind | palette_indigo_600 | `bg-indigo-600` | - | `0x4F46E5` | 0 | 13 | bg utility |
| tailwind | palette_indigo_700 | `bg-indigo-700` | - | `0x4338CA` | 0 | 13 | bg utility |
| tailwind | palette_indigo_800 | `bg-indigo-800` | - | `0x3730A3` | 0 | 13 | bg utility |
| tailwind | palette_indigo_900 | `bg-indigo-900` | - | `0x312E81` | 0 | 13 | bg utility |
| tailwind | palette_violet_50 | `bg-violet-50` | - | `0xF5F3FF` | 0 | 12 | bg utility |
| tailwind | palette_violet_100 | `bg-violet-100` | - | `0xEDE9FE` | 0 | 13 | bg utility |
| tailwind | palette_violet_200 | `bg-violet-200` | - | `0xDDD6FE` | 0 | 13 | bg utility |
| tailwind | palette_violet_300 | `bg-violet-300` | - | `0xC4B5FD` | 0 | 13 | bg utility |
| tailwind | palette_violet_400 | `bg-violet-400` | - | `0xA78BFA` | 0 | 13 | bg utility |
| tailwind | palette_violet_500 | `bg-violet-500` | - | `0x8B5CF6` | 0 | 13 | bg utility |
| tailwind | palette_violet_600 | `bg-violet-600` | - | `0x7C3AED` | 0 | 13 | bg utility |
| tailwind | palette_violet_700 | `bg-violet-700` | - | `0x6D28D9` | 0 | 13 | bg utility |
| tailwind | palette_violet_800 | `bg-violet-800` | - | `0x5B21B6` | 0 | 13 | bg utility |
| tailwind | palette_violet_900 | `bg-violet-900` | - | `0x4C1D95` | 0 | 13 | bg utility |
| tailwind | palette_purple_50 | `bg-purple-50` | - | `0xFAF5FF` | 0 | 12 | bg utility |
| tailwind | palette_purple_100 | `bg-purple-100` | - | `0xF3E8FF` | 0 | 13 | bg utility |
| tailwind | palette_purple_200 | `bg-purple-200` | - | `0xE9D5FF` | 0 | 13 | bg utility |
| tailwind | palette_purple_300 | `bg-purple-300` | - | `0xD8B4FE` | 0 | 13 | bg utility |
| tailwind | palette_purple_400 | `bg-purple-400` | - | `0xC084FC` | 0 | 13 | bg utility |
| tailwind | palette_purple_500 | `bg-purple-500` | - | `0xA855F7` | 0 | 13 | bg utility |
| tailwind | palette_purple_600 | `bg-purple-600` | - | `0x9333EA` | 0 | 13 | bg utility |
| tailwind | palette_purple_700 | `bg-purple-700` | - | `0x7E22CE` | 0 | 13 | bg utility |
| tailwind | palette_purple_800 | `bg-purple-800` | - | `0x6B21A8` | 0 | 13 | bg utility |
| tailwind | palette_purple_900 | `bg-purple-900` | - | `0x581C87` | 0 | 13 | bg utility |
| tailwind | palette_fuchsia_50 | `bg-fuchsia-50` | - | `0xFDF4FF` | 0 | 13 | bg utility |
| tailwind | palette_fuchsia_100 | `bg-fuchsia-100` | - | `0xFAE8FF` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_200 | `bg-fuchsia-200` | - | `0xF5D0FE` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_300 | `bg-fuchsia-300` | - | `0xF0ABFC` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_400 | `bg-fuchsia-400` | - | `0xE879F9` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_500 | `bg-fuchsia-500` | - | `0xD946EF` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_600 | `bg-fuchsia-600` | - | `0xC026D3` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_700 | `bg-fuchsia-700` | - | `0xA21CAF` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_800 | `bg-fuchsia-800` | - | `0x86198F` | 0 | 14 | bg utility |
| tailwind | palette_fuchsia_900 | `bg-fuchsia-900` | - | `0x701A75` | 0 | 14 | bg utility |
| tailwind | palette_pink_50 | `bg-pink-50` | - | `0xFDF2F8` | 0 | 10 | bg utility |
| tailwind | palette_pink_100 | `bg-pink-100` | - | `0xFCE7F3` | 0 | 11 | bg utility |
| tailwind | palette_pink_200 | `bg-pink-200` | - | `0xFBCFE8` | 0 | 11 | bg utility |
| tailwind | palette_pink_300 | `bg-pink-300` | - | `0xF9A8D4` | 0 | 11 | bg utility |
| tailwind | palette_pink_400 | `bg-pink-400` | - | `0xF472B6` | 0 | 11 | bg utility |
| tailwind | palette_pink_500 | `bg-pink-500` | - | `0xEC4899` | 0 | 11 | bg utility |
| tailwind | palette_pink_600 | `bg-pink-600` | - | `0xDB2777` | 0 | 11 | bg utility |
| tailwind | palette_pink_700 | `bg-pink-700` | - | `0xBE185D` | 0 | 11 | bg utility |
| tailwind | palette_pink_800 | `bg-pink-800` | - | `0x9D174D` | 0 | 11 | bg utility |
| tailwind | palette_pink_900 | `bg-pink-900` | - | `0x831843` | 0 | 11 | bg utility |
| tailwind | palette_rose_50 | `bg-rose-50` | - | `0xFFF1F2` | 0 | 10 | bg utility |
| tailwind | palette_rose_100 | `bg-rose-100` | - | `0xFFE4E6` | 0 | 11 | bg utility |
| tailwind | palette_rose_200 | `bg-rose-200` | - | `0xFECDD3` | 0 | 11 | bg utility |
| tailwind | palette_rose_300 | `bg-rose-300` | - | `0xFDA4AF` | 0 | 11 | bg utility |
| tailwind | palette_rose_400 | `bg-rose-400` | - | `0xFB7185` | 0 | 11 | bg utility |
| tailwind | palette_rose_500 | `bg-rose-500` | - | `0xF43F5E` | 0 | 11 | bg utility |
| tailwind | palette_rose_600 | `bg-rose-600` | - | `0xE11D48` | 0 | 11 | bg utility |
| tailwind | palette_rose_700 | `bg-rose-700` | - | `0xBE123C` | 0 | 11 | bg utility |
| tailwind | palette_rose_800 | `bg-rose-800` | - | `0x9F1239` | 0 | 11 | bg utility |
| tailwind | palette_rose_900 | `bg-rose-900` | - | `0x881337` | 0 | 11 | bg utility |
| tailwind | prefix_ring_offset | `ring-offset-slate-500` | - | `0x64748B` | 0 | 21 | supported prefix |
| tailwind | prefix_placeholder | `placeholder-slate-500` | - | `0x64748B` | 0 | 21 | supported prefix |
| tailwind | prefix_decoration | `decoration-slate-500` | - | `0x64748B` | 0 | 20 | supported prefix |
| tailwind | prefix_divide | `divide-slate-500` | - | `0x64748B` | 0 | 16 | supported prefix |
| tailwind | prefix_outline | `outline-slate-500` | - | `0x64748B` | 0 | 17 | supported prefix |
| tailwind | prefix_accent | `accent-slate-500` | - | `0x64748B` | 0 | 16 | supported prefix |
| tailwind | prefix_caret | `caret-slate-500` | - | `0x64748B` | 0 | 15 | supported prefix |
| tailwind | prefix_shadow | `shadow-slate-500` | - | `0x64748B` | 0 | 16 | supported prefix |
| tailwind | prefix_stroke | `stroke-slate-500` | - | `0x64748B` | 0 | 16 | supported prefix |
| tailwind | prefix_border | `border-slate-500` | - | `0x64748B` | 0 | 16 | supported prefix |
| tailwind | prefix_ring | `ring-slate-500` | - | `0x64748B` | 0 | 14 | supported prefix |
| tailwind | prefix_fill | `fill-slate-500` | - | `0x64748B` | 0 | 14 | supported prefix |
| tailwind | prefix_from | `from-slate-500` | - | `0x64748B` | 0 | 14 | supported prefix |
| tailwind | prefix_via | `via-slate-500` | - | `0x64748B` | 0 | 13 | supported prefix |
| tailwind | prefix_to | `to-slate-500` | - | `0x64748B` | 0 | 12 | supported prefix |
| tailwind | prefix_bg | `bg-slate-500` | - | `0x64748B` | 0 | 12 | supported prefix |
| tailwind | prefix_text | `text-slate-500` | - | `0x64748B` | 0 | 14 | supported prefix |
| tailwind | offset | `class='bg-blue-500'` | - | `0x3B82F6` | 7 | 18 | match offsets |
| tailwind | unknown_color | `bg-notacolor` | - | - | - | - | not in palette |
| tailwind | unknown_shade | `bg-red-1000` | - | - | - | - | invalid shade |
| tailwind | unknown_prefix | `foo-red-500` | - | - | - | - | unknown prefix |
| tailwind | bare_color | `red-500` | - | - | - | - | prefix required |
| tailwind | trailing_suffix | `bg-red-500-extra` | - | - | - | - | frontier rejects suffix |
| tailwind | missing_color | `bg-` | - | - | - | - | missing color name |

## var_usage parser

| parser | name | input | context | expect | start | end | note |
| --- | --- | --- | --- | --- | --- | --- | --- |
| var_usage | hex | `color: var(--brand);` | `:root { --brand: #123456; }` | `0x123456` | 7 | 19 | long hex |
| var_usage | short_hex | `color: var(--brand);` | `:root { --brand: #F53; }` | `0xFF5533` | 7 | 19 | short hex |
| var_usage | hex_alpha | `color: var(--brand);` | `:root { --brand: #FF800080; }` | `0x180FF8000` | 7 | 19 | 8-digit hex |
| var_usage | named | `color: var(--brand);` | `:root { --brand: rebeccapurple; }` | `0x663399` | 7 | 19 | CSS named color |
| var_usage | rgb_legacy | `color: var(--brand);` | `:root { --brand: rgb(255, 0, 0); }` | `0xFF0000` | 7 | 19 | legacy rgb |
| var_usage | rgb_modern | `color: var(--brand);` | `:root { --brand: rgb(255 128 0 / .5); }` | `0x180FF8000` | 7 | 19 | modern rgba |
| var_usage | hsl | `color: var(--brand);` | `:root { --brand: hsl(240 100% 50%); }` | `0x0000FF` | 7 | 19 | hsl |
| var_usage | hsla | `color: var(--brand);` | `:root { --brand: hsla(0, 100%, 50%, 0.5); }` | `0x180FF0000` | 7 | 19 | hsla |
| var_usage | multiline | `color: var(--brand);` | `:root {\n  --brand:\n    #654321;\n}` | `0x654321` | 7 | 19 | multiline declaration |
| var_usage | comment_removed | `color: var(--brand);` | `:root { /* old: #000000 */ --brand: #ABCDEF; }` | `0xABCDEF` | 7 | 19 | comments removed |
| var_usage | skip_invalid | `color: var(--brand);` | `:root { --brand: nope; --brand: #123456; }` | `0x123456` | 7 | 19 | first valid declaration wins |
| var_usage | offset | `border: 1px solid var(--brand);` | `:root { --brand: #010203; }` | `0x010203` | 18 | 30 | match offsets |
| var_usage | missing_declaration | `color: var(--brand);` | `:root { --other: #123456; }` | - | - | - | declaration not found |
| var_usage | invalid_declaration | `color: var(--brand);` | `:root { --brand: nope; }` | - | - | - | declaration is not a color |
| var_usage | no_context | `color: var(--brand);` | - | - | - | - | no loaded declaration |
| var_usage | whitespace | `color: var( --brand );` | `:root { --brand: #123456; }` | `0x123456` | 7 | 21 | whitespace inside var() |
| var_usage | uppercase_name | `color: var(--Brand);` | `:root { --Brand: #123456; }` | `0x123456` | 7 | 19 | case-sensitive custom property name |
| var_usage | hyphen_name | `color: var(--brand-color);` | `:root { --brand-color: #123456; }` | `0x123456` | 7 | 25 | hyphenated property name |
| var_usage | digit_name | `color: var(--brand2);` | `:root { --brand2: #123456; }` | `0x123456` | 7 | 20 | digit in property name |
| var_usage | transparent_hex | `color: var(--brand);` | `:root { --brand: #00000000; }` | `0x100000000` | 7 | 19 | 8-digit transparent hex |
| var_usage | uppercase_named | `color: var(--brand);` | `:root { --brand: REBECCAPURPLE; }` | `0x663399` | 7 | 19 | case-insensitive named color |
| var_usage | spaced_declaration | `color: var(--brand);` | `:root {\n  --brand :   #654321  ;\n}` | `0x654321` | 7 | 19 | spaces around declaration colon |
| var_usage | fallback_unsupported | `color: var(--brand, red);` | `:root { --brand: #123456; }` | - | - | - | fallback values are not supported |
| var_usage | uppercase_function | `color: VAR(--brand);` | `:root { --brand: #123456; }` | - | - | - | var() name is case-sensitive |
| var_usage | nested_var | `color: var(--brand);` | `:root { --brand: var(--other); --other: #123456; }` | - | - | - | nested var() unsupported |
| var_usage | calc_declaration | `color: var(--brand);` | `:root { --brand: calc(1 + 1); }` | - | - | - | calc() unsupported |
| var_usage | relative_color | `color: var(--brand);` | `:root { --brand: rgb(from #123456 r g b); }` | - | - | - | relative color syntax unsupported |

## Machine-readable vectors

<!-- VECTORS BEGIN -->

```text
# Parser test vectors for witch-colors.
#
# Consumed by spec/parsers/parser_vectors_spec.lua.
#
# Format:
#   parser | name | input | context | expect | start | end | note
#
# - `##` lines are group headings; `#` lines are comments.
# - `parser` is an id from lua/witch-colors/config.lua or parsers/.
# - `input` is the full line passed to the parser. Escapes: \e, \xHH,
#   \n, \r, \t, \\ and \|.
# - `context` supplies declaration text for var_usage; `-` means empty.
# - `expect` is `-`, `VALUE`, or `fg=VALUE,bg=VALUE,sp=VALUE`.
#   VALUE may be 0xRRGGBB, 0x1AARRGGBB, #RRGGBB (string), NONE, or `-`.
# - `start`/`end` are 0-based byte offsets; `-` when no decoration is expected.
# - `note` explains why the vector exists.
#
# Semicolon-separated SGR forms are xterm compatibility vectors.
# Colon-separated SGR forms follow ITU-T T.416 13.1.8.

## hex parser
hex | long_black | #000000 | - | #000000 | 0 | 7 | string color is preserved
hex | long_white | #FFFFFF | - | #FFFFFF | 0 | 7 | uppercase
hex | long_lowercase | #ff5733 | - | #ff5733 | 0 | 7 | case preserved
hex | long_alpha | #FF800080 | - | #FF800080 | 0 | 9 | 8-digit string color
hex | prefix_offset | color: #123456; | - | #123456 | 7 | 14 | word boundary offsets
hex | background_offset | background:#00ff00 | - | #00ff00 | 11 | 18 | no space after colon
hex | zero_x_black | 0x000000 | - | 0x0 | 0 | 8 | numeric color
hex | zero_x_upper | 0XFF5733 | - | 0xFF5733 | 0 | 8 | uppercase 0X prefix
hex | zero_x_padded | x 0x123456 y | - | 0x123456 | 2 | 10 | frontier offsets
hex | five_digits | #12345 | - | - | - | - | too short
hex | seven_digits | #1234567 | - | - | - | - | wrong length
hex | zero_x_five | 0x12345 | - | - | - | - | too short
hex | zero_x_eight | 0x12345678 | - | - | - | - | too long
hex | non_hex | #GGGGGG | - | - | - | - | non-hex digits
hex | short_form | #FFF | - | - | - | - | handled by short_hex
hex | short_alpha_form | #F53A | - | - | - | - | handled by short_hex
hex | long_mixed_case | #AbCdEf | - | #AbCdEf | 0 | 7 | case is preserved
hex | alpha_black | #00000000 | - | #00000000 | 0 | 9 | fully transparent string color
hex | zero_x_leading_zero | 0x00000f | - | 0xF | 0 | 8 | numeric value drops leading zeroes
hex | zero_x_mixed_case | 0XaBcDeF | - | 0xABCDEF | 0 | 8 | mixed-case digits
hex | nine_digits | #123456789 | - | - | - | - | CSS hex cannot have nine digits
hex | zero_x_seven | 0x1234567 | - | - | - | - | numeric form rejects seven digits
hex | hash_trailing_hyphen | #123456-def | - | - | - | - | frontier rejects hyphen

## short_hex parser
short_hex | white | #FFF | - | #FFF | 0 | 4 | default resolve keeps text
short_hex | rgb | #F53 | - | #F53 | 0 | 4 | 3-digit form
short_hex | rgba | #f53a | - | #f53a | 0 | 5 | 4-digit lowercase form
short_hex | transparent | #0000 | - | #0000 | 0 | 5 | alpha zero
short_hex | offset | color: #abc; | - | #abc | 7 | 11 | word boundary offsets
short_hex | two_digits | #FF | - | - | - | - | too short
short_hex | five_digits | #FFFFF | - | - | - | - | wrong length
short_hex | long_form | #123456 | - | - | - | - | handled by hex
short_hex | non_hex | #GGF | - | - | - | - | non-hex digits
short_hex | trailing_hyphen | #abc-def | - | - | - | - | frontier rejects hyphen
short_hex | black | #000 | - | #000 | 0 | 4 | short black
short_hex | uppercase_rgba | #ABCD | - | #ABCD | 0 | 5 | uppercase alpha form
short_hex | mixed_case | #aBcD | - | #aBcD | 0 | 5 | case is preserved
short_hex | embedded | x #abc y | - | #abc | 2 | 6 | frontier offsets in text
short_hex | seven_digits | #1234567 | - | - | - | - | invalid length
short_hex | zero_prefix | #0000000 | - | - | - | - | invalid length

## rgb parser
rgb | legacy_red | rgb(255, 0, 0) | - | 0xFF0000 | 0 | 14 | legacy commas
rgb | legacy_spaces | rgb( 12 , 34 , 56 ) | - | 0x0C2238 | 0 | 19 | whitespace around commas
rgb | legacy_percent | rgb(100%, 0%, 0%) | - | 0xFF0000 | 0 | 17 | percentage channels
rgb | legacy_rgba | rgba(255, 128, 0, 0.5) | - | 0x180FF8000 | 0 | 22 | numeric legacy alpha
rgb | legacy_alpha_percent | rgba(0, 255, 0, 20%) | - | 0x13300FF00 | 0 | 20 | percentage legacy alpha
rgb | modern_red | rgb(255 0 0) | - | 0xFF0000 | 0 | 12 | modern spaces
rgb | modern_mixed | rgb(100% 128 0) | - | 0xFF8000 | 0 | 15 | mixed number and percentage
rgb | modern_decimal | rgb(1.2 2.6 3) | - | 0x010303 | 0 | 14 | rounded half-up
rgb | modern_alpha | rgb(255 128 0 / .5) | - | 0x180FF8000 | 0 | 19 | slash alpha
rgb | clamped | rgb(-5 260 128) | - | 0x00FF80 | 0 | 15 | clamped channels
rgb | uppercase | RGB(1, 2, 3) | - | 0x010203 | 0 | 12 | case-insensitive name
rgb | alpha_zero | rgb(0 0 0 / 0) | - | 0x100000000 | 0 | 14 | transparent black
rgb | alpha_one | rgb(0 0 0 / 1) | - | 0x000000 | 0 | 14 | opaque black
rgb | alpha_quarter | rgba(10 20 30 / 25%) | - | 0x1400A141E | 0 | 20 | modern rgba percentage alpha
rgb | rounded_max | rgb(255.4 0 0) | - | 0xFF0000 | 0 | 14 | decimal channel rounds to 255
rgb | half_channels | rgb(0.5 0.5 0.5) | - | 0x010101 | 0 | 16 | half values round up
rgb | padded_black | rgb( 0 0 0 ) | - | 0x000000 | 0 | 12 | outer whitespace
rgb | modern_percentages | rgb(0% 50% 100%) | - | 0x0080FF | 0 | 16 | all channels as percentages
rgb | uppercase_alpha | RGB(1 2 3 / 50%) | - | 0x180010203 | 0 | 16 | case-insensitive modern form
rgb | uppercase_rgba | RGBA(1 2 3 / 25%) | - | 0x140010203 | 0 | 17 | case-insensitive rgba
rgb | signed_channels | rgb(+1 -2 300) | - | 0x0100FF | 0 | 14 | signed channels and clamping
rgb | alpha_clamped_high | rgb(1 2 3 / 2) | - | 0x010203 | 0 | 14 | alpha clamps to one
rgb | alpha_clamped_low | rgb(1 2 3 / -1) | - | 0x100010203 | 0 | 15 | alpha clamps to zero
rgb | padded_commas | rgb( 1 , 2 , 3 ) | - | 0x010203 | 0 | 16 | legacy whitespace around commas
rgb | offset | color: rgb(0 0 255); | - | 0x0000FF | 7 | 19 | match offsets
rgb | missing_channel | rgb(255, 0) | - | - | - | - | legacy needs three channels
rgb | mixed_legacy_repr | rgb(255, 0%, 0) | - | - | - | - | legacy channels must match
rgb | modern_missing_channel | rgb(1 2) | - | - | - | - | modern needs three channels
rgb | modern_bad_alpha | rgb(1 2 / 0.5) | - | - | - | - | missing blue channel
rgb | too_many | rgb(1,2,3,4,5) | - | - | - | - | too many arguments
rgb | scientific | rgb(1e2 0 0) | - | - | - | - | scientific notation unsupported
rgb | trailing_dot | rgb(1. 2 3) | - | - | - | - | trailing decimal unsupported
rgb | none_channel | rgb(none 0 0) | - | - | - | - | none unsupported
rgb | unbalanced | rgb(1 2 3 | - | - | - | - | unbalanced parentheses
rgb | empty | rgb() | - | - | - | - | empty function
rgb | empty_alpha | rgb(1 2 3 /) | - | - | - | - | alpha value required
rgb | legacy_rgba_three_args | rgba(1,2,3) | - | 0x010203 | 0 | 11 | rgba alias accepts three channels
rgb | modern_four_channels | rgb(1 2 3 4) | - | - | - | - | alpha requires slash
rgb | trailing_comma | rgb(1, 2, 3,) | - | - | - | - | trailing comma unsupported
rgb | css_comment | rgb(1 /*x*/ 2 3) | - | - | - | - | CSS comments unsupported
rgb | calc | rgb(calc(1 + 1) 2 3) | - | - | - | - | calc() unsupported
rgb | nested_var | rgb(var(--x) 2 3) | - | - | - | - | var() unsupported
rgb | nested_rgb | rgb(rgb(1 2 3) 2 3) | - | - | - | - | nested functions unsupported

## hsl parser
hsl | red | hsl(0, 100%, 50%) | - | 0xFF0000 | 0 | 17 | legacy commas
hsl | green | hsl(120, 100%, 50%) | - | 0x00FF00 | 0 | 19 | legacy commas
hsl | blue | hsl(240, 100%, 50%) | - | 0x0000FF | 0 | 19 | legacy commas
hsl | orange | hsl(30 100% 50%) | - | 0xFF8000 | 0 | 16 | modern spaces
hsl | hsla_alpha | hsla(0, 100%, 50%, 0.5) | - | 0x180FF0000 | 0 | 23 | legacy alpha
hsl | modern_alpha_percent | hsl(180 100% 50% / 50%) | - | 0x18000FFFF | 0 | 23 | slash alpha
hsl | turn_unit | hsl(0.5turn 100% 50%) | - | 0x00FFFF | 0 | 21 | turn hue
hsl | grad_unit | hsl(200grad 100% 50%) | - | 0x00FFFF | 0 | 21 | grad hue
hsl | rad_unit | hsl(3.14159rad 100% 50%) | - | 0x00FFFF | 0 | 24 | radian hue
hsl | negative_hue | hsl(-120 100% 50%) | - | 0x0000FF | 0 | 18 | hue wraps
hsl | hue_360 | hsl(360 100% 50%) | - | 0xFF0000 | 0 | 17 | 360 is red
hsl | clamped | hsl(0 150% -10%) | - | 0x000000 | 0 | 16 | saturation/lightness clamped
hsl | none | hsl(none 0% 100%) | - | 0xFFFFFF | 0 | 17 | none in modern syntax
hsl | scientific | hsl(1e2 0% 100%) | - | 0xFFFFFF | 0 | 16 | scientific hue
hsl | alpha_zero | hsl(0 0% 50% / 0) | - | 0x100808080 | 0 | 17 | transparent gray
hsl | alpha_one | hsl(0 0% 50% / 1) | - | 0x808080 | 0 | 17 | opaque gray
hsl | hue_720 | hsl(720 100% 50%) | - | 0xFF0000 | 0 | 17 | hue wraps twice
hsl | hue_negative_360 | hsl(-360 100% 50%) | - | 0xFF0000 | 0 | 18 | negative full turn
hsl | all_none | hsl(none none none) | - | 0x000000 | 0 | 19 | CSS none components
hsl | legacy_alpha_percent | hsla(120, 50%, 50%, 100%) | - | 0x40BF40 | 0 | 25 | fully opaque legacy alpha
hsl | alpha_clamped_high | hsl(0 100% 50% / 2) | - | 0xFF0000 | 0 | 19 | alpha clamps to one
hsl | alpha_clamped_low | hsl(0 100% 50% / -1) | - | 0x100FF0000 | 0 | 20 | alpha clamps to zero
hsl | alpha_none | hsl(0 100% 50% / none) | - | 0xFF0000 | 0 | 22 | none alpha means opaque
hsl | uppercase_function | HSL(0, 100%, 50%) | - | 0xFF0000 | 0 | 17 | case-insensitive function name
hsl | positive_hue | hsl(+120 100% 50%) | - | 0x00FF00 | 0 | 18 | explicit positive hue
hsl | padded_commas | hsl( 0 , 100% , 50% ) | - | 0xFF0000 | 0 | 21 | legacy whitespace around commas
hsl | negative_turn | hsl(-.5turn 100% 50%) | - | 0x00FFFF | 0 | 21 | negative turn hue
hsl | offset | color: hsl(0 0% 0%); | - | 0x000000 | 7 | 19 | match offsets
hsl | unbalanced | hsl(0, 100%, 50% | - | - | - | - | unbalanced parentheses
hsl | modern_alpha_no_slash | hsl(0 100% 50% 0.5) | - | - | - | - | alpha needs slash
hsl | mixed_separators | hsl(0, 100%, 50% / 0.5) | - | - | - | - | legacy/modern mix
hsl | legacy_none | hsl(0, none, 50%) | - | - | - | - | none unsupported in legacy
hsl | bad_unit | hsl(0degx 100% 50%) | - | - | - | - | unknown hue unit
hsl | missing_percent | hsl(0 100 50%) | - | - | - | - | percentage required
hsl | bad_alpha_separator | hsl(0 100% 50%, 0.5) | - | - | - | - | comma in modern syntax
hsl | bad_hue | hsl(abc 100% 50%) | - | - | - | - | non-numeric hue
hsl | empty_alpha_hsl | hsl(0 100% 50% /) | - | - | - | - | alpha value required
hsl | extra_alpha_token | hsl(0 100% 50% / 50% 0) | - | - | - | - | too many alpha tokens
hsl | mixed_legacy_alpha | hsl(0,100%,50% / 0.5) | - | - | - | - | legacy commas cannot mix with slash alpha
hsl | stray_percent | hsl(0 100% 50)% | - | - | - | - | malformed closing syntax
hsl | bad_alpha_value | hsl(0 100% 50% / abc) | - | - | - | - | non-numeric alpha
hsl | css_comment | hsl(0 /*x*/ 100% 50%) | - | - | - | - | CSS comments unsupported
hsl | calc | hsl(calc(1 + 1) 100% 50%) | - | - | - | - | calc() unsupported
hsl | nested_var | hsl(var(--x) 100% 50%) | - | - | - | - | var() unsupported
hsl | nested_hsl | hsl(hsl(0 100% 50%) 100% 50%) | - | - | - | - | nested functions unsupported

## hsl_bare parser
hsl_bare | basic | --primary: 240 100% 50%; | - | 0x0000FF | 11 | 23 | blue
hsl_bare | decimal | --secondary: 0 84.2% 60.2%; | - | 0xEF4444 | 13 | 26 | decimal channels
hsl_bare | negative | --accent: -120 50% 40%; | - | 0x333399 | 10 | 22 | negative hue
hsl_bare | numeric_alpha | --transparent: 240 100% 50% / 0.5; | - | 0x1800000FF | 15 | 33 | numeric alpha
hsl_bare | percent_alpha | --overlay: 240 100% 50% / 50%; | - | 0x1800000FF | 11 | 29 | percentage alpha
hsl_bare | deg | --deg: 120deg 100% 50%; | - | 0x00FF00 | 7 | 22 | deg hue
hsl_bare | grad | --grad: 200grad 100% 50%; | - | 0x00FFFF | 8 | 24 | grad hue
hsl_bare | turn | --turn: .5turn 100% 50%; | - | 0x00FFFF | 8 | 23 | turn hue
hsl_bare | rad | --rad: 3.14159rad 100% 50%; | - | 0x00FFFF | 7 | 26 | radian hue
hsl_bare | no_terminator | --x: 0 0% 100% | - | 0xFFFFFF | 5 | 14 | trailing semicolon optional
hsl_bare | trailing_space | --x: 0 0% 0%   ; | - | 0x000000 | 5 | 12 | trailing space excluded
hsl_bare | alpha_zero | --alpha-zero: 0 0% 100% / 0; | - | 0x100FFFFFF | 14 | 27 | transparent white
hsl_bare | alpha_one | --alpha-one: 0 0% 100% / 1; | - | 0xFFFFFF | 13 | 26 | opaque white
hsl_bare | hue_720 | --hue-720: 720 100% 50%; | - | 0xFF0000 | 11 | 23 | hue wraps twice
hsl_bare | uppercase_unit | --upper: 120DEG 100% 50%; | - | 0x00FF00 | 9 | 24 | case-insensitive hue unit
hsl_bare | clamped | --clamped: 0 150% -10%; | - | 0x000000 | 11 | 22 | channels clamped
hsl_bare | embedded_offset | body { --x: 0 0% 100%; } | - | 0xFFFFFF | 12 | 21 | value-only highlight
hsl_bare | commas | --x: 0, 100%, 50%; | - | - | - | - | commas unsupported
hsl_bare | none | --x: 240 100% 50% / none; | - | - | - | - | none unsupported
hsl_bare | missing_percent | --x: 0 100 50%; | - | - | - | - | percentage required
hsl_bare | bad_hue | --x: abc 100% 50%; | - | - | - | - | non-numeric hue
hsl_bare | empty_value | --x: ; | - | - | - | - | empty value
hsl_bare | bad_alpha | --x: 0 100% 50% / abc; | - | - | - | - | non-numeric alpha
hsl_bare | scientific | --x: 1e2 0% 100%; | - | - | - | - | scientific notation unsupported
hsl_bare | alpha_without_slash | --x: 0 100% 50% 0.5; | - | - | - | - | alpha needs slash
hsl_bare | calc | --x: calc(0 + 1) 100% 50%; | - | - | - | - | calc() unsupported
hsl_bare | nested_var | --x: var(--y) 100% 50%; | - | - | - | - | var() unsupported
hsl_bare | css_comment | --x: 0 /*x*/ 100% 50%; | - | - | - | - | CSS comments unsupported

## css_named parser
css_named | palette_lightsalmon | lightsalmon | - | 0xFFA07A | 0 | 11 | CSS palette
css_named | palette_salmon | salmon | - | 0xFA8072 | 0 | 6 | CSS palette
css_named | palette_darksalmon | darksalmon | - | 0xE9967A | 0 | 10 | CSS palette
css_named | palette_lightcoral | lightcoral | - | 0xF08080 | 0 | 10 | CSS palette
css_named | palette_indianred | indianred | - | 0xCD5C5C | 0 | 9 | CSS palette
css_named | palette_crimson | crimson | - | 0xDC143C | 0 | 7 | CSS palette
css_named | palette_firebrick | firebrick | - | 0xB22222 | 0 | 9 | CSS palette
css_named | palette_red | red | - | 0xFF0000 | 0 | 3 | CSS palette
css_named | palette_darkred | darkred | - | 0x8B0000 | 0 | 7 | CSS palette
css_named | palette_coral | coral | - | 0xFF7F50 | 0 | 5 | CSS palette
css_named | palette_tomato | tomato | - | 0xFF6347 | 0 | 6 | CSS palette
css_named | palette_orangered | orangered | - | 0xFF4500 | 0 | 9 | CSS palette
css_named | palette_gold | gold | - | 0xFFD700 | 0 | 4 | CSS palette
css_named | palette_orange | orange | - | 0xFFA500 | 0 | 6 | CSS palette
css_named | palette_darkorange | darkorange | - | 0xFF8C00 | 0 | 10 | CSS palette
css_named | palette_lightyellow | lightyellow | - | 0xFFFFE0 | 0 | 11 | CSS palette
css_named | palette_lemonchiffon | lemonchiffon | - | 0xFFFACD | 0 | 12 | CSS palette
css_named | palette_lightgoldenrodyellow | lightgoldenrodyellow | - | 0xFAFAD2 | 0 | 20 | CSS palette
css_named | palette_papayawhip | papayawhip | - | 0xFFEFD5 | 0 | 10 | CSS palette
css_named | palette_moccasin | moccasin | - | 0xFFE4B5 | 0 | 8 | CSS palette
css_named | palette_peachpuff | peachpuff | - | 0xFFDAB9 | 0 | 9 | CSS palette
css_named | palette_palegoldenrod | palegoldenrod | - | 0xEEE8AA | 0 | 13 | CSS palette
css_named | palette_khaki | khaki | - | 0xF0E68C | 0 | 5 | CSS palette
css_named | palette_darkkhaki | darkkhaki | - | 0xBDB76B | 0 | 9 | CSS palette
css_named | palette_yellow | yellow | - | 0xFFFF00 | 0 | 6 | CSS palette
css_named | palette_lawngreen | lawngreen | - | 0x7CFC00 | 0 | 9 | CSS palette
css_named | palette_chartreuse | chartreuse | - | 0x7FFF00 | 0 | 10 | CSS palette
css_named | palette_limegreen | limegreen | - | 0x32CD32 | 0 | 9 | CSS palette
css_named | palette_lime | lime | - | 0x00FF00 | 0 | 4 | CSS palette
css_named | palette_forestgreen | forestgreen | - | 0x228B22 | 0 | 11 | CSS palette
css_named | palette_green | green | - | 0x008000 | 0 | 5 | CSS palette
css_named | palette_darkgreen | darkgreen | - | 0x006400 | 0 | 9 | CSS palette
css_named | palette_greenyellow | greenyellow | - | 0xADFF2F | 0 | 11 | CSS palette
css_named | palette_yellowgreen | yellowgreen | - | 0x9ACD32 | 0 | 11 | CSS palette
css_named | palette_springgreen | springgreen | - | 0x00FF7F | 0 | 11 | CSS palette
css_named | palette_mediumspringgreen | mediumspringgreen | - | 0x00FA9A | 0 | 17 | CSS palette
css_named | palette_lightgreen | lightgreen | - | 0x90EE90 | 0 | 10 | CSS palette
css_named | palette_palegreen | palegreen | - | 0x98FB98 | 0 | 9 | CSS palette
css_named | palette_darkseagreen | darkseagreen | - | 0x8FBC8F | 0 | 12 | CSS palette
css_named | palette_mediumseagreen | mediumseagreen | - | 0x3CB371 | 0 | 14 | CSS palette
css_named | palette_seagreen | seagreen | - | 0x2E8B57 | 0 | 8 | CSS palette
css_named | palette_olive | olive | - | 0x808000 | 0 | 5 | CSS palette
css_named | palette_darkolivegreen | darkolivegreen | - | 0x556B2F | 0 | 14 | CSS palette
css_named | palette_olivedrab | olivedrab | - | 0x6B8E23 | 0 | 9 | CSS palette
css_named | palette_lightcyan | lightcyan | - | 0xE0FFFF | 0 | 9 | CSS palette
css_named | palette_cyan | cyan | - | 0x00FFFF | 0 | 4 | CSS palette
css_named | palette_aqua | aqua | - | 0x00FFFF | 0 | 4 | CSS palette
css_named | palette_aquamarine | aquamarine | - | 0x7FFFD4 | 0 | 10 | CSS palette
css_named | palette_mediumaquamarine | mediumaquamarine | - | 0x66CDAA | 0 | 16 | CSS palette
css_named | palette_paleturquoise | paleturquoise | - | 0xAFEEEE | 0 | 13 | CSS palette
css_named | palette_turquoise | turquoise | - | 0x40E0D0 | 0 | 9 | CSS palette
css_named | palette_mediumturquoise | mediumturquoise | - | 0x48D1CC | 0 | 15 | CSS palette
css_named | palette_darkturquoise | darkturquoise | - | 0x00CED1 | 0 | 13 | CSS palette
css_named | palette_lightseagreen | lightseagreen | - | 0x20B2AA | 0 | 13 | CSS palette
css_named | palette_cadetblue | cadetblue | - | 0x5F9EA0 | 0 | 9 | CSS palette
css_named | palette_darkcyan | darkcyan | - | 0x008B8B | 0 | 8 | CSS palette
css_named | palette_teal | teal | - | 0x008080 | 0 | 4 | CSS palette
css_named | palette_powderblue | powderblue | - | 0xB0E0E6 | 0 | 10 | CSS palette
css_named | palette_lightblue | lightblue | - | 0xADD8E6 | 0 | 9 | CSS palette
css_named | palette_lightskyblue | lightskyblue | - | 0x87CEFA | 0 | 12 | CSS palette
css_named | palette_skyblue | skyblue | - | 0x87CEEB | 0 | 7 | CSS palette
css_named | palette_deepskyblue | deepskyblue | - | 0x00BFFF | 0 | 11 | CSS palette
css_named | palette_lightsteelblue | lightsteelblue | - | 0xB0C4DE | 0 | 14 | CSS palette
css_named | palette_dodgerblue | dodgerblue | - | 0x1E90FF | 0 | 10 | CSS palette
css_named | palette_cornflowerblue | cornflowerblue | - | 0x6495ED | 0 | 14 | CSS palette
css_named | palette_steelblue | steelblue | - | 0x4682B4 | 0 | 9 | CSS palette
css_named | palette_royalblue | royalblue | - | 0x4169E1 | 0 | 9 | CSS palette
css_named | palette_blue | blue | - | 0x0000FF | 0 | 4 | CSS palette
css_named | palette_mediumblue | mediumblue | - | 0x0000CD | 0 | 10 | CSS palette
css_named | palette_darkblue | darkblue | - | 0x00008B | 0 | 8 | CSS palette
css_named | palette_navy | navy | - | 0x000080 | 0 | 4 | CSS palette
css_named | palette_midnightblue | midnightblue | - | 0x191970 | 0 | 12 | CSS palette
css_named | palette_mediumslateblue | mediumslateblue | - | 0x7B68EE | 0 | 15 | CSS palette
css_named | palette_slateblue | slateblue | - | 0x6A5ACD | 0 | 9 | CSS palette
css_named | palette_darkslateblue | darkslateblue | - | 0x483D8B | 0 | 13 | CSS palette
css_named | palette_lavender | lavender | - | 0xE6E6FA | 0 | 8 | CSS palette
css_named | palette_thistle | thistle | - | 0xD8BFD8 | 0 | 7 | CSS palette
css_named | palette_plum | plum | - | 0xDDA0DD | 0 | 4 | CSS palette
css_named | palette_violet | violet | - | 0xEE82EE | 0 | 6 | CSS palette
css_named | palette_orchid | orchid | - | 0xDA70D6 | 0 | 6 | CSS palette
css_named | palette_fuchsia | fuchsia | - | 0xFF00FF | 0 | 7 | CSS palette
css_named | palette_magenta | magenta | - | 0xFF00FF | 0 | 7 | CSS palette
css_named | palette_mediumorchid | mediumorchid | - | 0xBA55D3 | 0 | 12 | CSS palette
css_named | palette_rebeccapurple | rebeccapurple | - | 0x663399 | 0 | 13 | CSS palette
css_named | palette_mediumpurple | mediumpurple | - | 0x9370DB | 0 | 12 | CSS palette
css_named | palette_blueviolet | blueviolet | - | 0x8A2BE2 | 0 | 10 | CSS palette
css_named | palette_darkviolet | darkviolet | - | 0x9400D3 | 0 | 10 | CSS palette
css_named | palette_darkorchid | darkorchid | - | 0x9932CC | 0 | 10 | CSS palette
css_named | palette_darkmagenta | darkmagenta | - | 0x8B008B | 0 | 11 | CSS palette
css_named | palette_purple | purple | - | 0x800080 | 0 | 6 | CSS palette
css_named | palette_indigo | indigo | - | 0x4B0082 | 0 | 6 | CSS palette
css_named | palette_pink | pink | - | 0xFFC0CB | 0 | 4 | CSS palette
css_named | palette_lightpink | lightpink | - | 0xFFB6C1 | 0 | 9 | CSS palette
css_named | palette_hotpink | hotpink | - | 0xFF69B4 | 0 | 7 | CSS palette
css_named | palette_deeppink | deeppink | - | 0xFF1493 | 0 | 8 | CSS palette
css_named | palette_palevioletred | palevioletred | - | 0xDB7093 | 0 | 13 | CSS palette
css_named | palette_mediumvioletred | mediumvioletred | - | 0xC71585 | 0 | 15 | CSS palette
css_named | palette_white | white | - | 0xFFFFFF | 0 | 5 | CSS palette
css_named | palette_snow | snow | - | 0xFFFAFA | 0 | 4 | CSS palette
css_named | palette_honeydew | honeydew | - | 0xF0FFF0 | 0 | 8 | CSS palette
css_named | palette_mintcream | mintcream | - | 0xF5FFFA | 0 | 9 | CSS palette
css_named | palette_azure | azure | - | 0xF0FFFF | 0 | 5 | CSS palette
css_named | palette_aliceblue | aliceblue | - | 0xF0F8FF | 0 | 9 | CSS palette
css_named | palette_ghostwhite | ghostwhite | - | 0xF8F8FF | 0 | 10 | CSS palette
css_named | palette_whitesmoke | whitesmoke | - | 0xF5F5F5 | 0 | 10 | CSS palette
css_named | palette_seashell | seashell | - | 0xFFF5EE | 0 | 8 | CSS palette
css_named | palette_beige | beige | - | 0xF5F5DC | 0 | 5 | CSS palette
css_named | palette_oldlace | oldlace | - | 0xFDF5E6 | 0 | 7 | CSS palette
css_named | palette_floralwhite | floralwhite | - | 0xFFFAF0 | 0 | 11 | CSS palette
css_named | palette_ivory | ivory | - | 0xFFFFF0 | 0 | 5 | CSS palette
css_named | palette_antiquewhite | antiquewhite | - | 0xFAEBD7 | 0 | 12 | CSS palette
css_named | palette_linen | linen | - | 0xFAF0E6 | 0 | 5 | CSS palette
css_named | palette_lavenderblush | lavenderblush | - | 0xFFF0F5 | 0 | 13 | CSS palette
css_named | palette_mistyrose | mistyrose | - | 0xFFE4E1 | 0 | 9 | CSS palette
css_named | palette_gainsboro | gainsboro | - | 0xDCDCDC | 0 | 9 | CSS palette
css_named | palette_lightgray | lightgray | - | 0xD3D3D3 | 0 | 9 | CSS palette
css_named | palette_lightgrey | lightgrey | - | 0xD3D3D3 | 0 | 9 | CSS palette
css_named | palette_silver | silver | - | 0xC0C0C0 | 0 | 6 | CSS palette
css_named | palette_darkgray | darkgray | - | 0xA9A9A9 | 0 | 8 | CSS palette
css_named | palette_darkgrey | darkgrey | - | 0xA9A9A9 | 0 | 8 | CSS palette
css_named | palette_gray | gray | - | 0x808080 | 0 | 4 | CSS palette
css_named | palette_grey | grey | - | 0x808080 | 0 | 4 | CSS palette
css_named | palette_dimgray | dimgray | - | 0x696969 | 0 | 7 | CSS palette
css_named | palette_dimgrey | dimgrey | - | 0x696969 | 0 | 7 | CSS palette
css_named | palette_lightslategray | lightslategray | - | 0x778899 | 0 | 14 | CSS palette
css_named | palette_lightslategrey | lightslategrey | - | 0x778899 | 0 | 14 | CSS palette
css_named | palette_slategray | slategray | - | 0x708090 | 0 | 9 | CSS palette
css_named | palette_slategrey | slategrey | - | 0x708090 | 0 | 9 | CSS palette
css_named | palette_darkslategray | darkslategray | - | 0x2F4F4F | 0 | 13 | CSS palette
css_named | palette_darkslategrey | darkslategrey | - | 0x2F4F4F | 0 | 13 | CSS palette
css_named | palette_black | black | - | 0x000000 | 0 | 5 | CSS palette
css_named | palette_cornsilk | cornsilk | - | 0xFFF8DC | 0 | 8 | CSS palette
css_named | palette_blanchedalmond | blanchedalmond | - | 0xFFEBCD | 0 | 14 | CSS palette
css_named | palette_bisque | bisque | - | 0xFFE4C4 | 0 | 6 | CSS palette
css_named | palette_navajowhite | navajowhite | - | 0xFFDEAD | 0 | 11 | CSS palette
css_named | palette_wheat | wheat | - | 0xF5DEB3 | 0 | 5 | CSS palette
css_named | palette_burlywood | burlywood | - | 0xDEB887 | 0 | 9 | CSS palette
css_named | palette_tan | tan | - | 0xD2B48C | 0 | 3 | CSS palette
css_named | palette_rosybrown | rosybrown | - | 0xBC8F8F | 0 | 9 | CSS palette
css_named | palette_sandybrown | sandybrown | - | 0xF4A460 | 0 | 10 | CSS palette
css_named | palette_goldenrod | goldenrod | - | 0xDAA520 | 0 | 9 | CSS palette
css_named | palette_peru | peru | - | 0xCD853F | 0 | 4 | CSS palette
css_named | palette_chocolate | chocolate | - | 0xD2691E | 0 | 9 | CSS palette
css_named | palette_saddlebrown | saddlebrown | - | 0x8B4513 | 0 | 11 | CSS palette
css_named | palette_sienna | sienna | - | 0xA0522D | 0 | 6 | CSS palette
css_named | palette_brown | brown | - | 0xA52A2A | 0 | 5 | CSS palette
css_named | palette_maroon | maroon | - | 0x800000 | 0 | 6 | CSS palette
css_named | uppercase | RED | - | 0xFF0000 | 0 | 3 | case-insensitive
css_named | mixed_case | RebeccaPurple | - | 0x663399 | 0 | 13 | case-insensitive
css_named | grey_alias | GREY | - | 0x808080 | 0 | 4 | grey alias
css_named | gray_alias | GRAY | - | 0x808080 | 0 | 4 | gray alias
css_named | aqua_alias | AQUA | - | 0x00FFFF | 0 | 4 | aqua alias
css_named | cyan_alias | CYAN | - | 0x00FFFF | 0 | 4 | cyan alias
css_named | fuchsia_alias | FUCHSIA | - | 0xFF00FF | 0 | 7 | fuchsia alias
css_named | magenta_alias | MAGENTA | - | 0xFF00FF | 0 | 7 | magenta alias
css_named | offset | color: red; | - | 0xFF0000 | 7 | 10 | word boundary offsets
css_named | unknown | notacolor | - | - | - | - | not a CSS name
css_named | inside_identifier | myred | - | - | - | - | leading frontier
css_named | hyphenated | red-zzz | - | - | - | - | trailing hyphen
css_named | underscore | red_zzz | - | - | - | - | trailing underscore

## sgr ANSI colors
sgr | ansi_fg_0 | \e[30m | - | fg=0x000000 | 0 | 5 | basic ANSI
sgr | ansi_fg_1 | \e[31m | - | fg=0xCD0000 | 0 | 5 | basic ANSI
sgr | ansi_fg_2 | \e[32m | - | fg=0x00CD00 | 0 | 5 | basic ANSI
sgr | ansi_fg_3 | \e[33m | - | fg=0xCDCD00 | 0 | 5 | basic ANSI
sgr | ansi_fg_4 | \e[34m | - | fg=0x0000EE | 0 | 5 | basic ANSI
sgr | ansi_fg_5 | \e[35m | - | fg=0xCD00CD | 0 | 5 | basic ANSI
sgr | ansi_fg_6 | \e[36m | - | fg=0x00CDCD | 0 | 5 | basic ANSI
sgr | ansi_fg_7 | \e[37m | - | fg=0xE5E5E5 | 0 | 5 | basic ANSI
sgr | bright_fg_0 | \e[90m | - | fg=0x7F7F7F | 0 | 5 | aixterm bright
sgr | bright_fg_1 | \e[91m | - | fg=0xFF0000 | 0 | 5 | aixterm bright
sgr | bright_fg_2 | \e[92m | - | fg=0x00FF00 | 0 | 5 | aixterm bright
sgr | bright_fg_3 | \e[93m | - | fg=0xFFFF00 | 0 | 5 | aixterm bright
sgr | bright_fg_4 | \e[94m | - | fg=0x5C5CFF | 0 | 5 | aixterm bright
sgr | bright_fg_5 | \e[95m | - | fg=0xFF00FF | 0 | 5 | aixterm bright
sgr | bright_fg_6 | \e[96m | - | fg=0x00FFFF | 0 | 5 | aixterm bright
sgr | bright_fg_7 | \e[97m | - | fg=0xFFFFFF | 0 | 5 | aixterm bright
sgr | ansi_bg_0 | \e[40m | - | bg=0x000000 | 0 | 5 | basic ANSI
sgr | ansi_bg_1 | \e[41m | - | bg=0xCD0000 | 0 | 5 | basic ANSI
sgr | ansi_bg_2 | \e[42m | - | bg=0x00CD00 | 0 | 5 | basic ANSI
sgr | ansi_bg_3 | \e[43m | - | bg=0xCDCD00 | 0 | 5 | basic ANSI
sgr | ansi_bg_4 | \e[44m | - | bg=0x0000EE | 0 | 5 | basic ANSI
sgr | ansi_bg_5 | \e[45m | - | bg=0xCD00CD | 0 | 5 | basic ANSI
sgr | ansi_bg_6 | \e[46m | - | bg=0x00CDCD | 0 | 5 | basic ANSI
sgr | ansi_bg_7 | \e[47m | - | bg=0xE5E5E5 | 0 | 5 | basic ANSI
sgr | bright_bg_0 | \e[100m | - | bg=0x7F7F7F | 0 | 6 | aixterm bright
sgr | bright_bg_1 | \e[101m | - | bg=0xFF0000 | 0 | 6 | aixterm bright
sgr | bright_bg_2 | \e[102m | - | bg=0x00FF00 | 0 | 6 | aixterm bright
sgr | bright_bg_3 | \e[103m | - | bg=0xFFFF00 | 0 | 6 | aixterm bright
sgr | bright_bg_4 | \e[104m | - | bg=0x5C5CFF | 0 | 6 | aixterm bright
sgr | bright_bg_5 | \e[105m | - | bg=0xFF00FF | 0 | 6 | aixterm bright
sgr | bright_bg_6 | \e[106m | - | bg=0x00FFFF | 0 | 6 | aixterm bright
sgr | bright_bg_7 | \e[107m | - | bg=0xFFFFFF | 0 | 6 | aixterm bright

## sgr resets and ordering
sgr | empty | \e[m | - | - | - | - | empty SGR equals reset
sgr | reset | \e[0m | - | - | - | - | default rendition
sgr | reset_fg | \e[39m | - | - | - | - | foreground reset
sgr | reset_bg | \e[49m | - | - | - | - | background reset
sgr | reset_sp | \e[59m | - | - | - | - | underline reset
sgr | attributes_only | \e[1;2;3;4m | - | - | - | - | no color attributes
sgr | reset_after_fg | \e[31;0m | - | - | - | - | reset clears earlier colors
sgr | reset_fg_after_fg | \e[31;39m | - | - | - | - | foreground reset only
sgr | reset_bg_after_bg | \e[44;49m | - | - | - | - | background reset only
sgr | reset_sp_after_sp | \e[58;5;196;59m | - | - | - | - | underline reset only
sgr | bold_before_fg | \e[1;31m | - | fg=0xCD0000 | 0 | 7 | attribute before color
sgr | bold_after_fg | \e[31;1m | - | fg=0xCD0000 | 0 | 7 | attribute after color
sgr | blink_before_bg | \e[6;44m | - | bg=0x0000EE | 0 | 7 | attribute before background
sgr | all_targets | \e[31;44;58;5;196m | - | fg=0xCD0000,bg=0x0000EE,sp=0xFF0000 | 0 | 17 | three color targets
sgr | attrs_between | \e[31;1;2;44m | - | fg=0xCD0000,bg=0x0000EE | 0 | 12 | attributes between colors
sgr | three_targets_reordered | \e[58;5;21;44;31m | - | fg=0xCD0000,bg=0x0000EE,sp=0x0000FF | 0 | 16 | reverse target order
sgr | fg_reset_keeps_bg | \e[31;44;39m | - | bg=0x0000EE | 0 | 11 | foreground reset only
sgr | bg_reset_keeps_fg | \e[31;44;49m | - | fg=0xCD0000 | 0 | 11 | background reset only
sgr | sp_reset_keeps_fg_bg | \e[31;44;58;5;196;59m | - | fg=0xCD0000,bg=0x0000EE | 0 | 20 | underline reset only
sgr | two_indexed | \e[38;5;196;48;5;21m | - | fg=0xFF0000,bg=0x0000FF | 0 | 19 | indexed fg then bg
sgr | two_indexed_reversed | \e[48;5;21;38;5;196m | - | fg=0xFF0000,bg=0x0000FF | 0 | 19 | indexed bg then fg

## sgr xterm indexed
sgr | index_fg_000 | \e[38;5;0m | - | fg=0x000000 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_001 | \e[38;5;1m | - | fg=0xCD0000 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_002 | \e[38;5;2m | - | fg=0x00CD00 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_003 | \e[38;5;3m | - | fg=0xCDCD00 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_004 | \e[38;5;4m | - | fg=0x0000EE | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_005 | \e[38;5;5m | - | fg=0xCD00CD | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_006 | \e[38;5;6m | - | fg=0x00CDCD | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_007 | \e[38;5;7m | - | fg=0xE5E5E5 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_008 | \e[38;5;8m | - | fg=0x7F7F7F | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_009 | \e[38;5;9m | - | fg=0xFF0000 | 0 | 9 | xterm 256 foreground palette
sgr | index_fg_010 | \e[38;5;10m | - | fg=0x00FF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_011 | \e[38;5;11m | - | fg=0xFFFF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_012 | \e[38;5;12m | - | fg=0x5C5CFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_013 | \e[38;5;13m | - | fg=0xFF00FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_014 | \e[38;5;14m | - | fg=0x00FFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_015 | \e[38;5;15m | - | fg=0xFFFFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_016 | \e[38;5;16m | - | fg=0x000000 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_017 | \e[38;5;17m | - | fg=0x00005F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_018 | \e[38;5;18m | - | fg=0x000087 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_019 | \e[38;5;19m | - | fg=0x0000AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_020 | \e[38;5;20m | - | fg=0x0000D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_021 | \e[38;5;21m | - | fg=0x0000FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_022 | \e[38;5;22m | - | fg=0x005F00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_023 | \e[38;5;23m | - | fg=0x005F5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_024 | \e[38;5;24m | - | fg=0x005F87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_025 | \e[38;5;25m | - | fg=0x005FAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_026 | \e[38;5;26m | - | fg=0x005FD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_027 | \e[38;5;27m | - | fg=0x005FFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_028 | \e[38;5;28m | - | fg=0x008700 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_029 | \e[38;5;29m | - | fg=0x00875F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_030 | \e[38;5;30m | - | fg=0x008787 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_031 | \e[38;5;31m | - | fg=0x0087AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_032 | \e[38;5;32m | - | fg=0x0087D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_033 | \e[38;5;33m | - | fg=0x0087FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_034 | \e[38;5;34m | - | fg=0x00AF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_035 | \e[38;5;35m | - | fg=0x00AF5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_036 | \e[38;5;36m | - | fg=0x00AF87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_037 | \e[38;5;37m | - | fg=0x00AFAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_038 | \e[38;5;38m | - | fg=0x00AFD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_039 | \e[38;5;39m | - | fg=0x00AFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_040 | \e[38;5;40m | - | fg=0x00D700 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_041 | \e[38;5;41m | - | fg=0x00D75F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_042 | \e[38;5;42m | - | fg=0x00D787 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_043 | \e[38;5;43m | - | fg=0x00D7AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_044 | \e[38;5;44m | - | fg=0x00D7D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_045 | \e[38;5;45m | - | fg=0x00D7FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_046 | \e[38;5;46m | - | fg=0x00FF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_047 | \e[38;5;47m | - | fg=0x00FF5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_048 | \e[38;5;48m | - | fg=0x00FF87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_049 | \e[38;5;49m | - | fg=0x00FFAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_050 | \e[38;5;50m | - | fg=0x00FFD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_051 | \e[38;5;51m | - | fg=0x00FFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_052 | \e[38;5;52m | - | fg=0x5F0000 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_053 | \e[38;5;53m | - | fg=0x5F005F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_054 | \e[38;5;54m | - | fg=0x5F0087 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_055 | \e[38;5;55m | - | fg=0x5F00AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_056 | \e[38;5;56m | - | fg=0x5F00D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_057 | \e[38;5;57m | - | fg=0x5F00FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_058 | \e[38;5;58m | - | fg=0x5F5F00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_059 | \e[38;5;59m | - | fg=0x5F5F5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_060 | \e[38;5;60m | - | fg=0x5F5F87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_061 | \e[38;5;61m | - | fg=0x5F5FAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_062 | \e[38;5;62m | - | fg=0x5F5FD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_063 | \e[38;5;63m | - | fg=0x5F5FFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_064 | \e[38;5;64m | - | fg=0x5F8700 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_065 | \e[38;5;65m | - | fg=0x5F875F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_066 | \e[38;5;66m | - | fg=0x5F8787 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_067 | \e[38;5;67m | - | fg=0x5F87AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_068 | \e[38;5;68m | - | fg=0x5F87D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_069 | \e[38;5;69m | - | fg=0x5F87FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_070 | \e[38;5;70m | - | fg=0x5FAF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_071 | \e[38;5;71m | - | fg=0x5FAF5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_072 | \e[38;5;72m | - | fg=0x5FAF87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_073 | \e[38;5;73m | - | fg=0x5FAFAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_074 | \e[38;5;74m | - | fg=0x5FAFD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_075 | \e[38;5;75m | - | fg=0x5FAFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_076 | \e[38;5;76m | - | fg=0x5FD700 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_077 | \e[38;5;77m | - | fg=0x5FD75F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_078 | \e[38;5;78m | - | fg=0x5FD787 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_079 | \e[38;5;79m | - | fg=0x5FD7AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_080 | \e[38;5;80m | - | fg=0x5FD7D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_081 | \e[38;5;81m | - | fg=0x5FD7FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_082 | \e[38;5;82m | - | fg=0x5FFF00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_083 | \e[38;5;83m | - | fg=0x5FFF5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_084 | \e[38;5;84m | - | fg=0x5FFF87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_085 | \e[38;5;85m | - | fg=0x5FFFAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_086 | \e[38;5;86m | - | fg=0x5FFFD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_087 | \e[38;5;87m | - | fg=0x5FFFFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_088 | \e[38;5;88m | - | fg=0x870000 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_089 | \e[38;5;89m | - | fg=0x87005F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_090 | \e[38;5;90m | - | fg=0x870087 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_091 | \e[38;5;91m | - | fg=0x8700AF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_092 | \e[38;5;92m | - | fg=0x8700D7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_093 | \e[38;5;93m | - | fg=0x8700FF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_094 | \e[38;5;94m | - | fg=0x875F00 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_095 | \e[38;5;95m | - | fg=0x875F5F | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_096 | \e[38;5;96m | - | fg=0x875F87 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_097 | \e[38;5;97m | - | fg=0x875FAF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_098 | \e[38;5;98m | - | fg=0x875FD7 | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_099 | \e[38;5;99m | - | fg=0x875FFF | 0 | 10 | xterm 256 foreground palette
sgr | index_fg_100 | \e[38;5;100m | - | fg=0x878700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_101 | \e[38;5;101m | - | fg=0x87875F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_102 | \e[38;5;102m | - | fg=0x878787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_103 | \e[38;5;103m | - | fg=0x8787AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_104 | \e[38;5;104m | - | fg=0x8787D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_105 | \e[38;5;105m | - | fg=0x8787FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_106 | \e[38;5;106m | - | fg=0x87AF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_107 | \e[38;5;107m | - | fg=0x87AF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_108 | \e[38;5;108m | - | fg=0x87AF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_109 | \e[38;5;109m | - | fg=0x87AFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_110 | \e[38;5;110m | - | fg=0x87AFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_111 | \e[38;5;111m | - | fg=0x87AFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_112 | \e[38;5;112m | - | fg=0x87D700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_113 | \e[38;5;113m | - | fg=0x87D75F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_114 | \e[38;5;114m | - | fg=0x87D787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_115 | \e[38;5;115m | - | fg=0x87D7AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_116 | \e[38;5;116m | - | fg=0x87D7D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_117 | \e[38;5;117m | - | fg=0x87D7FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_118 | \e[38;5;118m | - | fg=0x87FF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_119 | \e[38;5;119m | - | fg=0x87FF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_120 | \e[38;5;120m | - | fg=0x87FF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_121 | \e[38;5;121m | - | fg=0x87FFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_122 | \e[38;5;122m | - | fg=0x87FFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_123 | \e[38;5;123m | - | fg=0x87FFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_124 | \e[38;5;124m | - | fg=0xAF0000 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_125 | \e[38;5;125m | - | fg=0xAF005F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_126 | \e[38;5;126m | - | fg=0xAF0087 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_127 | \e[38;5;127m | - | fg=0xAF00AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_128 | \e[38;5;128m | - | fg=0xAF00D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_129 | \e[38;5;129m | - | fg=0xAF00FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_130 | \e[38;5;130m | - | fg=0xAF5F00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_131 | \e[38;5;131m | - | fg=0xAF5F5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_132 | \e[38;5;132m | - | fg=0xAF5F87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_133 | \e[38;5;133m | - | fg=0xAF5FAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_134 | \e[38;5;134m | - | fg=0xAF5FD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_135 | \e[38;5;135m | - | fg=0xAF5FFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_136 | \e[38;5;136m | - | fg=0xAF8700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_137 | \e[38;5;137m | - | fg=0xAF875F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_138 | \e[38;5;138m | - | fg=0xAF8787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_139 | \e[38;5;139m | - | fg=0xAF87AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_140 | \e[38;5;140m | - | fg=0xAF87D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_141 | \e[38;5;141m | - | fg=0xAF87FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_142 | \e[38;5;142m | - | fg=0xAFAF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_143 | \e[38;5;143m | - | fg=0xAFAF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_144 | \e[38;5;144m | - | fg=0xAFAF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_145 | \e[38;5;145m | - | fg=0xAFAFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_146 | \e[38;5;146m | - | fg=0xAFAFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_147 | \e[38;5;147m | - | fg=0xAFAFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_148 | \e[38;5;148m | - | fg=0xAFD700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_149 | \e[38;5;149m | - | fg=0xAFD75F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_150 | \e[38;5;150m | - | fg=0xAFD787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_151 | \e[38;5;151m | - | fg=0xAFD7AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_152 | \e[38;5;152m | - | fg=0xAFD7D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_153 | \e[38;5;153m | - | fg=0xAFD7FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_154 | \e[38;5;154m | - | fg=0xAFFF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_155 | \e[38;5;155m | - | fg=0xAFFF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_156 | \e[38;5;156m | - | fg=0xAFFF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_157 | \e[38;5;157m | - | fg=0xAFFFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_158 | \e[38;5;158m | - | fg=0xAFFFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_159 | \e[38;5;159m | - | fg=0xAFFFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_160 | \e[38;5;160m | - | fg=0xD70000 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_161 | \e[38;5;161m | - | fg=0xD7005F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_162 | \e[38;5;162m | - | fg=0xD70087 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_163 | \e[38;5;163m | - | fg=0xD700AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_164 | \e[38;5;164m | - | fg=0xD700D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_165 | \e[38;5;165m | - | fg=0xD700FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_166 | \e[38;5;166m | - | fg=0xD75F00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_167 | \e[38;5;167m | - | fg=0xD75F5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_168 | \e[38;5;168m | - | fg=0xD75F87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_169 | \e[38;5;169m | - | fg=0xD75FAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_170 | \e[38;5;170m | - | fg=0xD75FD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_171 | \e[38;5;171m | - | fg=0xD75FFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_172 | \e[38;5;172m | - | fg=0xD78700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_173 | \e[38;5;173m | - | fg=0xD7875F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_174 | \e[38;5;174m | - | fg=0xD78787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_175 | \e[38;5;175m | - | fg=0xD787AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_176 | \e[38;5;176m | - | fg=0xD787D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_177 | \e[38;5;177m | - | fg=0xD787FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_178 | \e[38;5;178m | - | fg=0xD7AF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_179 | \e[38;5;179m | - | fg=0xD7AF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_180 | \e[38;5;180m | - | fg=0xD7AF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_181 | \e[38;5;181m | - | fg=0xD7AFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_182 | \e[38;5;182m | - | fg=0xD7AFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_183 | \e[38;5;183m | - | fg=0xD7AFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_184 | \e[38;5;184m | - | fg=0xD7D700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_185 | \e[38;5;185m | - | fg=0xD7D75F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_186 | \e[38;5;186m | - | fg=0xD7D787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_187 | \e[38;5;187m | - | fg=0xD7D7AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_188 | \e[38;5;188m | - | fg=0xD7D7D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_189 | \e[38;5;189m | - | fg=0xD7D7FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_190 | \e[38;5;190m | - | fg=0xD7FF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_191 | \e[38;5;191m | - | fg=0xD7FF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_192 | \e[38;5;192m | - | fg=0xD7FF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_193 | \e[38;5;193m | - | fg=0xD7FFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_194 | \e[38;5;194m | - | fg=0xD7FFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_195 | \e[38;5;195m | - | fg=0xD7FFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_196 | \e[38;5;196m | - | fg=0xFF0000 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_197 | \e[38;5;197m | - | fg=0xFF005F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_198 | \e[38;5;198m | - | fg=0xFF0087 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_199 | \e[38;5;199m | - | fg=0xFF00AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_200 | \e[38;5;200m | - | fg=0xFF00D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_201 | \e[38;5;201m | - | fg=0xFF00FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_202 | \e[38;5;202m | - | fg=0xFF5F00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_203 | \e[38;5;203m | - | fg=0xFF5F5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_204 | \e[38;5;204m | - | fg=0xFF5F87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_205 | \e[38;5;205m | - | fg=0xFF5FAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_206 | \e[38;5;206m | - | fg=0xFF5FD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_207 | \e[38;5;207m | - | fg=0xFF5FFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_208 | \e[38;5;208m | - | fg=0xFF8700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_209 | \e[38;5;209m | - | fg=0xFF875F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_210 | \e[38;5;210m | - | fg=0xFF8787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_211 | \e[38;5;211m | - | fg=0xFF87AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_212 | \e[38;5;212m | - | fg=0xFF87D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_213 | \e[38;5;213m | - | fg=0xFF87FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_214 | \e[38;5;214m | - | fg=0xFFAF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_215 | \e[38;5;215m | - | fg=0xFFAF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_216 | \e[38;5;216m | - | fg=0xFFAF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_217 | \e[38;5;217m | - | fg=0xFFAFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_218 | \e[38;5;218m | - | fg=0xFFAFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_219 | \e[38;5;219m | - | fg=0xFFAFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_220 | \e[38;5;220m | - | fg=0xFFD700 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_221 | \e[38;5;221m | - | fg=0xFFD75F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_222 | \e[38;5;222m | - | fg=0xFFD787 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_223 | \e[38;5;223m | - | fg=0xFFD7AF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_224 | \e[38;5;224m | - | fg=0xFFD7D7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_225 | \e[38;5;225m | - | fg=0xFFD7FF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_226 | \e[38;5;226m | - | fg=0xFFFF00 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_227 | \e[38;5;227m | - | fg=0xFFFF5F | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_228 | \e[38;5;228m | - | fg=0xFFFF87 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_229 | \e[38;5;229m | - | fg=0xFFFFAF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_230 | \e[38;5;230m | - | fg=0xFFFFD7 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_231 | \e[38;5;231m | - | fg=0xFFFFFF | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_232 | \e[38;5;232m | - | fg=0x080808 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_233 | \e[38;5;233m | - | fg=0x121212 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_234 | \e[38;5;234m | - | fg=0x1C1C1C | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_235 | \e[38;5;235m | - | fg=0x262626 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_236 | \e[38;5;236m | - | fg=0x303030 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_237 | \e[38;5;237m | - | fg=0x3A3A3A | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_238 | \e[38;5;238m | - | fg=0x444444 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_239 | \e[38;5;239m | - | fg=0x4E4E4E | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_240 | \e[38;5;240m | - | fg=0x585858 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_241 | \e[38;5;241m | - | fg=0x626262 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_242 | \e[38;5;242m | - | fg=0x6C6C6C | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_243 | \e[38;5;243m | - | fg=0x767676 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_244 | \e[38;5;244m | - | fg=0x808080 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_245 | \e[38;5;245m | - | fg=0x8A8A8A | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_246 | \e[38;5;246m | - | fg=0x949494 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_247 | \e[38;5;247m | - | fg=0x9E9E9E | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_248 | \e[38;5;248m | - | fg=0xA8A8A8 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_249 | \e[38;5;249m | - | fg=0xB2B2B2 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_250 | \e[38;5;250m | - | fg=0xBCBCBC | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_251 | \e[38;5;251m | - | fg=0xC6C6C6 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_252 | \e[38;5;252m | - | fg=0xD0D0D0 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_253 | \e[38;5;253m | - | fg=0xDADADA | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_254 | \e[38;5;254m | - | fg=0xE4E4E4 | 0 | 11 | xterm 256 foreground palette
sgr | index_fg_255 | \e[38;5;255m | - | fg=0xEEEEEE | 0 | 11 | xterm 256 foreground palette
sgr | index_bg_000 | \e[48;5;0m | - | bg=0x000000 | 0 | 9 | xterm 256 background palette
sgr | index_bg_001 | \e[48;5;1m | - | bg=0xCD0000 | 0 | 9 | xterm 256 background palette
sgr | index_bg_002 | \e[48;5;2m | - | bg=0x00CD00 | 0 | 9 | xterm 256 background palette
sgr | index_bg_003 | \e[48;5;3m | - | bg=0xCDCD00 | 0 | 9 | xterm 256 background palette
sgr | index_bg_004 | \e[48;5;4m | - | bg=0x0000EE | 0 | 9 | xterm 256 background palette
sgr | index_bg_005 | \e[48;5;5m | - | bg=0xCD00CD | 0 | 9 | xterm 256 background palette
sgr | index_bg_006 | \e[48;5;6m | - | bg=0x00CDCD | 0 | 9 | xterm 256 background palette
sgr | index_bg_007 | \e[48;5;7m | - | bg=0xE5E5E5 | 0 | 9 | xterm 256 background palette
sgr | index_bg_008 | \e[48;5;8m | - | bg=0x7F7F7F | 0 | 9 | xterm 256 background palette
sgr | index_bg_009 | \e[48;5;9m | - | bg=0xFF0000 | 0 | 9 | xterm 256 background palette
sgr | index_bg_010 | \e[48;5;10m | - | bg=0x00FF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_011 | \e[48;5;11m | - | bg=0xFFFF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_012 | \e[48;5;12m | - | bg=0x5C5CFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_013 | \e[48;5;13m | - | bg=0xFF00FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_014 | \e[48;5;14m | - | bg=0x00FFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_015 | \e[48;5;15m | - | bg=0xFFFFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_016 | \e[48;5;16m | - | bg=0x000000 | 0 | 10 | xterm 256 background palette
sgr | index_bg_017 | \e[48;5;17m | - | bg=0x00005F | 0 | 10 | xterm 256 background palette
sgr | index_bg_018 | \e[48;5;18m | - | bg=0x000087 | 0 | 10 | xterm 256 background palette
sgr | index_bg_019 | \e[48;5;19m | - | bg=0x0000AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_020 | \e[48;5;20m | - | bg=0x0000D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_021 | \e[48;5;21m | - | bg=0x0000FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_022 | \e[48;5;22m | - | bg=0x005F00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_023 | \e[48;5;23m | - | bg=0x005F5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_024 | \e[48;5;24m | - | bg=0x005F87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_025 | \e[48;5;25m | - | bg=0x005FAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_026 | \e[48;5;26m | - | bg=0x005FD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_027 | \e[48;5;27m | - | bg=0x005FFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_028 | \e[48;5;28m | - | bg=0x008700 | 0 | 10 | xterm 256 background palette
sgr | index_bg_029 | \e[48;5;29m | - | bg=0x00875F | 0 | 10 | xterm 256 background palette
sgr | index_bg_030 | \e[48;5;30m | - | bg=0x008787 | 0 | 10 | xterm 256 background palette
sgr | index_bg_031 | \e[48;5;31m | - | bg=0x0087AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_032 | \e[48;5;32m | - | bg=0x0087D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_033 | \e[48;5;33m | - | bg=0x0087FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_034 | \e[48;5;34m | - | bg=0x00AF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_035 | \e[48;5;35m | - | bg=0x00AF5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_036 | \e[48;5;36m | - | bg=0x00AF87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_037 | \e[48;5;37m | - | bg=0x00AFAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_038 | \e[48;5;38m | - | bg=0x00AFD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_039 | \e[48;5;39m | - | bg=0x00AFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_040 | \e[48;5;40m | - | bg=0x00D700 | 0 | 10 | xterm 256 background palette
sgr | index_bg_041 | \e[48;5;41m | - | bg=0x00D75F | 0 | 10 | xterm 256 background palette
sgr | index_bg_042 | \e[48;5;42m | - | bg=0x00D787 | 0 | 10 | xterm 256 background palette
sgr | index_bg_043 | \e[48;5;43m | - | bg=0x00D7AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_044 | \e[48;5;44m | - | bg=0x00D7D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_045 | \e[48;5;45m | - | bg=0x00D7FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_046 | \e[48;5;46m | - | bg=0x00FF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_047 | \e[48;5;47m | - | bg=0x00FF5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_048 | \e[48;5;48m | - | bg=0x00FF87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_049 | \e[48;5;49m | - | bg=0x00FFAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_050 | \e[48;5;50m | - | bg=0x00FFD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_051 | \e[48;5;51m | - | bg=0x00FFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_052 | \e[48;5;52m | - | bg=0x5F0000 | 0 | 10 | xterm 256 background palette
sgr | index_bg_053 | \e[48;5;53m | - | bg=0x5F005F | 0 | 10 | xterm 256 background palette
sgr | index_bg_054 | \e[48;5;54m | - | bg=0x5F0087 | 0 | 10 | xterm 256 background palette
sgr | index_bg_055 | \e[48;5;55m | - | bg=0x5F00AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_056 | \e[48;5;56m | - | bg=0x5F00D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_057 | \e[48;5;57m | - | bg=0x5F00FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_058 | \e[48;5;58m | - | bg=0x5F5F00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_059 | \e[48;5;59m | - | bg=0x5F5F5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_060 | \e[48;5;60m | - | bg=0x5F5F87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_061 | \e[48;5;61m | - | bg=0x5F5FAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_062 | \e[48;5;62m | - | bg=0x5F5FD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_063 | \e[48;5;63m | - | bg=0x5F5FFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_064 | \e[48;5;64m | - | bg=0x5F8700 | 0 | 10 | xterm 256 background palette
sgr | index_bg_065 | \e[48;5;65m | - | bg=0x5F875F | 0 | 10 | xterm 256 background palette
sgr | index_bg_066 | \e[48;5;66m | - | bg=0x5F8787 | 0 | 10 | xterm 256 background palette
sgr | index_bg_067 | \e[48;5;67m | - | bg=0x5F87AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_068 | \e[48;5;68m | - | bg=0x5F87D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_069 | \e[48;5;69m | - | bg=0x5F87FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_070 | \e[48;5;70m | - | bg=0x5FAF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_071 | \e[48;5;71m | - | bg=0x5FAF5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_072 | \e[48;5;72m | - | bg=0x5FAF87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_073 | \e[48;5;73m | - | bg=0x5FAFAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_074 | \e[48;5;74m | - | bg=0x5FAFD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_075 | \e[48;5;75m | - | bg=0x5FAFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_076 | \e[48;5;76m | - | bg=0x5FD700 | 0 | 10 | xterm 256 background palette
sgr | index_bg_077 | \e[48;5;77m | - | bg=0x5FD75F | 0 | 10 | xterm 256 background palette
sgr | index_bg_078 | \e[48;5;78m | - | bg=0x5FD787 | 0 | 10 | xterm 256 background palette
sgr | index_bg_079 | \e[48;5;79m | - | bg=0x5FD7AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_080 | \e[48;5;80m | - | bg=0x5FD7D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_081 | \e[48;5;81m | - | bg=0x5FD7FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_082 | \e[48;5;82m | - | bg=0x5FFF00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_083 | \e[48;5;83m | - | bg=0x5FFF5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_084 | \e[48;5;84m | - | bg=0x5FFF87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_085 | \e[48;5;85m | - | bg=0x5FFFAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_086 | \e[48;5;86m | - | bg=0x5FFFD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_087 | \e[48;5;87m | - | bg=0x5FFFFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_088 | \e[48;5;88m | - | bg=0x870000 | 0 | 10 | xterm 256 background palette
sgr | index_bg_089 | \e[48;5;89m | - | bg=0x87005F | 0 | 10 | xterm 256 background palette
sgr | index_bg_090 | \e[48;5;90m | - | bg=0x870087 | 0 | 10 | xterm 256 background palette
sgr | index_bg_091 | \e[48;5;91m | - | bg=0x8700AF | 0 | 10 | xterm 256 background palette
sgr | index_bg_092 | \e[48;5;92m | - | bg=0x8700D7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_093 | \e[48;5;93m | - | bg=0x8700FF | 0 | 10 | xterm 256 background palette
sgr | index_bg_094 | \e[48;5;94m | - | bg=0x875F00 | 0 | 10 | xterm 256 background palette
sgr | index_bg_095 | \e[48;5;95m | - | bg=0x875F5F | 0 | 10 | xterm 256 background palette
sgr | index_bg_096 | \e[48;5;96m | - | bg=0x875F87 | 0 | 10 | xterm 256 background palette
sgr | index_bg_097 | \e[48;5;97m | - | bg=0x875FAF | 0 | 10 | xterm 256 background palette
sgr | index_bg_098 | \e[48;5;98m | - | bg=0x875FD7 | 0 | 10 | xterm 256 background palette
sgr | index_bg_099 | \e[48;5;99m | - | bg=0x875FFF | 0 | 10 | xterm 256 background palette
sgr | index_bg_100 | \e[48;5;100m | - | bg=0x878700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_101 | \e[48;5;101m | - | bg=0x87875F | 0 | 11 | xterm 256 background palette
sgr | index_bg_102 | \e[48;5;102m | - | bg=0x878787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_103 | \e[48;5;103m | - | bg=0x8787AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_104 | \e[48;5;104m | - | bg=0x8787D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_105 | \e[48;5;105m | - | bg=0x8787FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_106 | \e[48;5;106m | - | bg=0x87AF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_107 | \e[48;5;107m | - | bg=0x87AF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_108 | \e[48;5;108m | - | bg=0x87AF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_109 | \e[48;5;109m | - | bg=0x87AFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_110 | \e[48;5;110m | - | bg=0x87AFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_111 | \e[48;5;111m | - | bg=0x87AFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_112 | \e[48;5;112m | - | bg=0x87D700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_113 | \e[48;5;113m | - | bg=0x87D75F | 0 | 11 | xterm 256 background palette
sgr | index_bg_114 | \e[48;5;114m | - | bg=0x87D787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_115 | \e[48;5;115m | - | bg=0x87D7AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_116 | \e[48;5;116m | - | bg=0x87D7D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_117 | \e[48;5;117m | - | bg=0x87D7FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_118 | \e[48;5;118m | - | bg=0x87FF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_119 | \e[48;5;119m | - | bg=0x87FF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_120 | \e[48;5;120m | - | bg=0x87FF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_121 | \e[48;5;121m | - | bg=0x87FFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_122 | \e[48;5;122m | - | bg=0x87FFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_123 | \e[48;5;123m | - | bg=0x87FFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_124 | \e[48;5;124m | - | bg=0xAF0000 | 0 | 11 | xterm 256 background palette
sgr | index_bg_125 | \e[48;5;125m | - | bg=0xAF005F | 0 | 11 | xterm 256 background palette
sgr | index_bg_126 | \e[48;5;126m | - | bg=0xAF0087 | 0 | 11 | xterm 256 background palette
sgr | index_bg_127 | \e[48;5;127m | - | bg=0xAF00AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_128 | \e[48;5;128m | - | bg=0xAF00D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_129 | \e[48;5;129m | - | bg=0xAF00FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_130 | \e[48;5;130m | - | bg=0xAF5F00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_131 | \e[48;5;131m | - | bg=0xAF5F5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_132 | \e[48;5;132m | - | bg=0xAF5F87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_133 | \e[48;5;133m | - | bg=0xAF5FAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_134 | \e[48;5;134m | - | bg=0xAF5FD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_135 | \e[48;5;135m | - | bg=0xAF5FFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_136 | \e[48;5;136m | - | bg=0xAF8700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_137 | \e[48;5;137m | - | bg=0xAF875F | 0 | 11 | xterm 256 background palette
sgr | index_bg_138 | \e[48;5;138m | - | bg=0xAF8787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_139 | \e[48;5;139m | - | bg=0xAF87AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_140 | \e[48;5;140m | - | bg=0xAF87D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_141 | \e[48;5;141m | - | bg=0xAF87FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_142 | \e[48;5;142m | - | bg=0xAFAF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_143 | \e[48;5;143m | - | bg=0xAFAF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_144 | \e[48;5;144m | - | bg=0xAFAF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_145 | \e[48;5;145m | - | bg=0xAFAFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_146 | \e[48;5;146m | - | bg=0xAFAFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_147 | \e[48;5;147m | - | bg=0xAFAFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_148 | \e[48;5;148m | - | bg=0xAFD700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_149 | \e[48;5;149m | - | bg=0xAFD75F | 0 | 11 | xterm 256 background palette
sgr | index_bg_150 | \e[48;5;150m | - | bg=0xAFD787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_151 | \e[48;5;151m | - | bg=0xAFD7AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_152 | \e[48;5;152m | - | bg=0xAFD7D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_153 | \e[48;5;153m | - | bg=0xAFD7FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_154 | \e[48;5;154m | - | bg=0xAFFF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_155 | \e[48;5;155m | - | bg=0xAFFF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_156 | \e[48;5;156m | - | bg=0xAFFF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_157 | \e[48;5;157m | - | bg=0xAFFFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_158 | \e[48;5;158m | - | bg=0xAFFFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_159 | \e[48;5;159m | - | bg=0xAFFFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_160 | \e[48;5;160m | - | bg=0xD70000 | 0 | 11 | xterm 256 background palette
sgr | index_bg_161 | \e[48;5;161m | - | bg=0xD7005F | 0 | 11 | xterm 256 background palette
sgr | index_bg_162 | \e[48;5;162m | - | bg=0xD70087 | 0 | 11 | xterm 256 background palette
sgr | index_bg_163 | \e[48;5;163m | - | bg=0xD700AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_164 | \e[48;5;164m | - | bg=0xD700D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_165 | \e[48;5;165m | - | bg=0xD700FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_166 | \e[48;5;166m | - | bg=0xD75F00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_167 | \e[48;5;167m | - | bg=0xD75F5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_168 | \e[48;5;168m | - | bg=0xD75F87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_169 | \e[48;5;169m | - | bg=0xD75FAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_170 | \e[48;5;170m | - | bg=0xD75FD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_171 | \e[48;5;171m | - | bg=0xD75FFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_172 | \e[48;5;172m | - | bg=0xD78700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_173 | \e[48;5;173m | - | bg=0xD7875F | 0 | 11 | xterm 256 background palette
sgr | index_bg_174 | \e[48;5;174m | - | bg=0xD78787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_175 | \e[48;5;175m | - | bg=0xD787AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_176 | \e[48;5;176m | - | bg=0xD787D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_177 | \e[48;5;177m | - | bg=0xD787FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_178 | \e[48;5;178m | - | bg=0xD7AF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_179 | \e[48;5;179m | - | bg=0xD7AF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_180 | \e[48;5;180m | - | bg=0xD7AF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_181 | \e[48;5;181m | - | bg=0xD7AFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_182 | \e[48;5;182m | - | bg=0xD7AFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_183 | \e[48;5;183m | - | bg=0xD7AFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_184 | \e[48;5;184m | - | bg=0xD7D700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_185 | \e[48;5;185m | - | bg=0xD7D75F | 0 | 11 | xterm 256 background palette
sgr | index_bg_186 | \e[48;5;186m | - | bg=0xD7D787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_187 | \e[48;5;187m | - | bg=0xD7D7AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_188 | \e[48;5;188m | - | bg=0xD7D7D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_189 | \e[48;5;189m | - | bg=0xD7D7FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_190 | \e[48;5;190m | - | bg=0xD7FF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_191 | \e[48;5;191m | - | bg=0xD7FF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_192 | \e[48;5;192m | - | bg=0xD7FF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_193 | \e[48;5;193m | - | bg=0xD7FFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_194 | \e[48;5;194m | - | bg=0xD7FFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_195 | \e[48;5;195m | - | bg=0xD7FFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_196 | \e[48;5;196m | - | bg=0xFF0000 | 0 | 11 | xterm 256 background palette
sgr | index_bg_197 | \e[48;5;197m | - | bg=0xFF005F | 0 | 11 | xterm 256 background palette
sgr | index_bg_198 | \e[48;5;198m | - | bg=0xFF0087 | 0 | 11 | xterm 256 background palette
sgr | index_bg_199 | \e[48;5;199m | - | bg=0xFF00AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_200 | \e[48;5;200m | - | bg=0xFF00D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_201 | \e[48;5;201m | - | bg=0xFF00FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_202 | \e[48;5;202m | - | bg=0xFF5F00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_203 | \e[48;5;203m | - | bg=0xFF5F5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_204 | \e[48;5;204m | - | bg=0xFF5F87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_205 | \e[48;5;205m | - | bg=0xFF5FAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_206 | \e[48;5;206m | - | bg=0xFF5FD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_207 | \e[48;5;207m | - | bg=0xFF5FFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_208 | \e[48;5;208m | - | bg=0xFF8700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_209 | \e[48;5;209m | - | bg=0xFF875F | 0 | 11 | xterm 256 background palette
sgr | index_bg_210 | \e[48;5;210m | - | bg=0xFF8787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_211 | \e[48;5;211m | - | bg=0xFF87AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_212 | \e[48;5;212m | - | bg=0xFF87D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_213 | \e[48;5;213m | - | bg=0xFF87FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_214 | \e[48;5;214m | - | bg=0xFFAF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_215 | \e[48;5;215m | - | bg=0xFFAF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_216 | \e[48;5;216m | - | bg=0xFFAF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_217 | \e[48;5;217m | - | bg=0xFFAFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_218 | \e[48;5;218m | - | bg=0xFFAFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_219 | \e[48;5;219m | - | bg=0xFFAFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_220 | \e[48;5;220m | - | bg=0xFFD700 | 0 | 11 | xterm 256 background palette
sgr | index_bg_221 | \e[48;5;221m | - | bg=0xFFD75F | 0 | 11 | xterm 256 background palette
sgr | index_bg_222 | \e[48;5;222m | - | bg=0xFFD787 | 0 | 11 | xterm 256 background palette
sgr | index_bg_223 | \e[48;5;223m | - | bg=0xFFD7AF | 0 | 11 | xterm 256 background palette
sgr | index_bg_224 | \e[48;5;224m | - | bg=0xFFD7D7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_225 | \e[48;5;225m | - | bg=0xFFD7FF | 0 | 11 | xterm 256 background palette
sgr | index_bg_226 | \e[48;5;226m | - | bg=0xFFFF00 | 0 | 11 | xterm 256 background palette
sgr | index_bg_227 | \e[48;5;227m | - | bg=0xFFFF5F | 0 | 11 | xterm 256 background palette
sgr | index_bg_228 | \e[48;5;228m | - | bg=0xFFFF87 | 0 | 11 | xterm 256 background palette
sgr | index_bg_229 | \e[48;5;229m | - | bg=0xFFFFAF | 0 | 11 | xterm 256 background palette
sgr | index_bg_230 | \e[48;5;230m | - | bg=0xFFFFD7 | 0 | 11 | xterm 256 background palette
sgr | index_bg_231 | \e[48;5;231m | - | bg=0xFFFFFF | 0 | 11 | xterm 256 background palette
sgr | index_bg_232 | \e[48;5;232m | - | bg=0x080808 | 0 | 11 | xterm 256 background palette
sgr | index_bg_233 | \e[48;5;233m | - | bg=0x121212 | 0 | 11 | xterm 256 background palette
sgr | index_bg_234 | \e[48;5;234m | - | bg=0x1C1C1C | 0 | 11 | xterm 256 background palette
sgr | index_bg_235 | \e[48;5;235m | - | bg=0x262626 | 0 | 11 | xterm 256 background palette
sgr | index_bg_236 | \e[48;5;236m | - | bg=0x303030 | 0 | 11 | xterm 256 background palette
sgr | index_bg_237 | \e[48;5;237m | - | bg=0x3A3A3A | 0 | 11 | xterm 256 background palette
sgr | index_bg_238 | \e[48;5;238m | - | bg=0x444444 | 0 | 11 | xterm 256 background palette
sgr | index_bg_239 | \e[48;5;239m | - | bg=0x4E4E4E | 0 | 11 | xterm 256 background palette
sgr | index_bg_240 | \e[48;5;240m | - | bg=0x585858 | 0 | 11 | xterm 256 background palette
sgr | index_bg_241 | \e[48;5;241m | - | bg=0x626262 | 0 | 11 | xterm 256 background palette
sgr | index_bg_242 | \e[48;5;242m | - | bg=0x6C6C6C | 0 | 11 | xterm 256 background palette
sgr | index_bg_243 | \e[48;5;243m | - | bg=0x767676 | 0 | 11 | xterm 256 background palette
sgr | index_bg_244 | \e[48;5;244m | - | bg=0x808080 | 0 | 11 | xterm 256 background palette
sgr | index_bg_245 | \e[48;5;245m | - | bg=0x8A8A8A | 0 | 11 | xterm 256 background palette
sgr | index_bg_246 | \e[48;5;246m | - | bg=0x949494 | 0 | 11 | xterm 256 background palette
sgr | index_bg_247 | \e[48;5;247m | - | bg=0x9E9E9E | 0 | 11 | xterm 256 background palette
sgr | index_bg_248 | \e[48;5;248m | - | bg=0xA8A8A8 | 0 | 11 | xterm 256 background palette
sgr | index_bg_249 | \e[48;5;249m | - | bg=0xB2B2B2 | 0 | 11 | xterm 256 background palette
sgr | index_bg_250 | \e[48;5;250m | - | bg=0xBCBCBC | 0 | 11 | xterm 256 background palette
sgr | index_bg_251 | \e[48;5;251m | - | bg=0xC6C6C6 | 0 | 11 | xterm 256 background palette
sgr | index_bg_252 | \e[48;5;252m | - | bg=0xD0D0D0 | 0 | 11 | xterm 256 background palette
sgr | index_bg_253 | \e[48;5;253m | - | bg=0xDADADA | 0 | 11 | xterm 256 background palette
sgr | index_bg_254 | \e[48;5;254m | - | bg=0xE4E4E4 | 0 | 11 | xterm 256 background palette
sgr | index_bg_255 | \e[48;5;255m | - | bg=0xEEEEEE | 0 | 11 | xterm 256 background palette
sgr | index_sp_000 | \e[58;5;0m | - | sp=0x000000 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_001 | \e[58;5;1m | - | sp=0xCD0000 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_002 | \e[58;5;2m | - | sp=0x00CD00 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_003 | \e[58;5;3m | - | sp=0xCDCD00 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_004 | \e[58;5;4m | - | sp=0x0000EE | 0 | 9 | xterm 256 underline palette
sgr | index_sp_005 | \e[58;5;5m | - | sp=0xCD00CD | 0 | 9 | xterm 256 underline palette
sgr | index_sp_006 | \e[58;5;6m | - | sp=0x00CDCD | 0 | 9 | xterm 256 underline palette
sgr | index_sp_007 | \e[58;5;7m | - | sp=0xE5E5E5 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_008 | \e[58;5;8m | - | sp=0x7F7F7F | 0 | 9 | xterm 256 underline palette
sgr | index_sp_009 | \e[58;5;9m | - | sp=0xFF0000 | 0 | 9 | xterm 256 underline palette
sgr | index_sp_010 | \e[58;5;10m | - | sp=0x00FF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_011 | \e[58;5;11m | - | sp=0xFFFF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_012 | \e[58;5;12m | - | sp=0x5C5CFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_013 | \e[58;5;13m | - | sp=0xFF00FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_014 | \e[58;5;14m | - | sp=0x00FFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_015 | \e[58;5;15m | - | sp=0xFFFFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_016 | \e[58;5;16m | - | sp=0x000000 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_017 | \e[58;5;17m | - | sp=0x00005F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_018 | \e[58;5;18m | - | sp=0x000087 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_019 | \e[58;5;19m | - | sp=0x0000AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_020 | \e[58;5;20m | - | sp=0x0000D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_021 | \e[58;5;21m | - | sp=0x0000FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_022 | \e[58;5;22m | - | sp=0x005F00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_023 | \e[58;5;23m | - | sp=0x005F5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_024 | \e[58;5;24m | - | sp=0x005F87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_025 | \e[58;5;25m | - | sp=0x005FAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_026 | \e[58;5;26m | - | sp=0x005FD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_027 | \e[58;5;27m | - | sp=0x005FFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_028 | \e[58;5;28m | - | sp=0x008700 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_029 | \e[58;5;29m | - | sp=0x00875F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_030 | \e[58;5;30m | - | sp=0x008787 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_031 | \e[58;5;31m | - | sp=0x0087AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_032 | \e[58;5;32m | - | sp=0x0087D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_033 | \e[58;5;33m | - | sp=0x0087FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_034 | \e[58;5;34m | - | sp=0x00AF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_035 | \e[58;5;35m | - | sp=0x00AF5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_036 | \e[58;5;36m | - | sp=0x00AF87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_037 | \e[58;5;37m | - | sp=0x00AFAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_038 | \e[58;5;38m | - | sp=0x00AFD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_039 | \e[58;5;39m | - | sp=0x00AFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_040 | \e[58;5;40m | - | sp=0x00D700 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_041 | \e[58;5;41m | - | sp=0x00D75F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_042 | \e[58;5;42m | - | sp=0x00D787 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_043 | \e[58;5;43m | - | sp=0x00D7AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_044 | \e[58;5;44m | - | sp=0x00D7D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_045 | \e[58;5;45m | - | sp=0x00D7FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_046 | \e[58;5;46m | - | sp=0x00FF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_047 | \e[58;5;47m | - | sp=0x00FF5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_048 | \e[58;5;48m | - | sp=0x00FF87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_049 | \e[58;5;49m | - | sp=0x00FFAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_050 | \e[58;5;50m | - | sp=0x00FFD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_051 | \e[58;5;51m | - | sp=0x00FFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_052 | \e[58;5;52m | - | sp=0x5F0000 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_053 | \e[58;5;53m | - | sp=0x5F005F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_054 | \e[58;5;54m | - | sp=0x5F0087 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_055 | \e[58;5;55m | - | sp=0x5F00AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_056 | \e[58;5;56m | - | sp=0x5F00D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_057 | \e[58;5;57m | - | sp=0x5F00FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_058 | \e[58;5;58m | - | sp=0x5F5F00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_059 | \e[58;5;59m | - | sp=0x5F5F5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_060 | \e[58;5;60m | - | sp=0x5F5F87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_061 | \e[58;5;61m | - | sp=0x5F5FAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_062 | \e[58;5;62m | - | sp=0x5F5FD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_063 | \e[58;5;63m | - | sp=0x5F5FFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_064 | \e[58;5;64m | - | sp=0x5F8700 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_065 | \e[58;5;65m | - | sp=0x5F875F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_066 | \e[58;5;66m | - | sp=0x5F8787 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_067 | \e[58;5;67m | - | sp=0x5F87AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_068 | \e[58;5;68m | - | sp=0x5F87D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_069 | \e[58;5;69m | - | sp=0x5F87FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_070 | \e[58;5;70m | - | sp=0x5FAF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_071 | \e[58;5;71m | - | sp=0x5FAF5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_072 | \e[58;5;72m | - | sp=0x5FAF87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_073 | \e[58;5;73m | - | sp=0x5FAFAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_074 | \e[58;5;74m | - | sp=0x5FAFD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_075 | \e[58;5;75m | - | sp=0x5FAFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_076 | \e[58;5;76m | - | sp=0x5FD700 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_077 | \e[58;5;77m | - | sp=0x5FD75F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_078 | \e[58;5;78m | - | sp=0x5FD787 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_079 | \e[58;5;79m | - | sp=0x5FD7AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_080 | \e[58;5;80m | - | sp=0x5FD7D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_081 | \e[58;5;81m | - | sp=0x5FD7FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_082 | \e[58;5;82m | - | sp=0x5FFF00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_083 | \e[58;5;83m | - | sp=0x5FFF5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_084 | \e[58;5;84m | - | sp=0x5FFF87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_085 | \e[58;5;85m | - | sp=0x5FFFAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_086 | \e[58;5;86m | - | sp=0x5FFFD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_087 | \e[58;5;87m | - | sp=0x5FFFFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_088 | \e[58;5;88m | - | sp=0x870000 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_089 | \e[58;5;89m | - | sp=0x87005F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_090 | \e[58;5;90m | - | sp=0x870087 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_091 | \e[58;5;91m | - | sp=0x8700AF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_092 | \e[58;5;92m | - | sp=0x8700D7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_093 | \e[58;5;93m | - | sp=0x8700FF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_094 | \e[58;5;94m | - | sp=0x875F00 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_095 | \e[58;5;95m | - | sp=0x875F5F | 0 | 10 | xterm 256 underline palette
sgr | index_sp_096 | \e[58;5;96m | - | sp=0x875F87 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_097 | \e[58;5;97m | - | sp=0x875FAF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_098 | \e[58;5;98m | - | sp=0x875FD7 | 0 | 10 | xterm 256 underline palette
sgr | index_sp_099 | \e[58;5;99m | - | sp=0x875FFF | 0 | 10 | xterm 256 underline palette
sgr | index_sp_100 | \e[58;5;100m | - | sp=0x878700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_101 | \e[58;5;101m | - | sp=0x87875F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_102 | \e[58;5;102m | - | sp=0x878787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_103 | \e[58;5;103m | - | sp=0x8787AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_104 | \e[58;5;104m | - | sp=0x8787D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_105 | \e[58;5;105m | - | sp=0x8787FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_106 | \e[58;5;106m | - | sp=0x87AF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_107 | \e[58;5;107m | - | sp=0x87AF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_108 | \e[58;5;108m | - | sp=0x87AF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_109 | \e[58;5;109m | - | sp=0x87AFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_110 | \e[58;5;110m | - | sp=0x87AFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_111 | \e[58;5;111m | - | sp=0x87AFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_112 | \e[58;5;112m | - | sp=0x87D700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_113 | \e[58;5;113m | - | sp=0x87D75F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_114 | \e[58;5;114m | - | sp=0x87D787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_115 | \e[58;5;115m | - | sp=0x87D7AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_116 | \e[58;5;116m | - | sp=0x87D7D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_117 | \e[58;5;117m | - | sp=0x87D7FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_118 | \e[58;5;118m | - | sp=0x87FF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_119 | \e[58;5;119m | - | sp=0x87FF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_120 | \e[58;5;120m | - | sp=0x87FF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_121 | \e[58;5;121m | - | sp=0x87FFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_122 | \e[58;5;122m | - | sp=0x87FFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_123 | \e[58;5;123m | - | sp=0x87FFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_124 | \e[58;5;124m | - | sp=0xAF0000 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_125 | \e[58;5;125m | - | sp=0xAF005F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_126 | \e[58;5;126m | - | sp=0xAF0087 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_127 | \e[58;5;127m | - | sp=0xAF00AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_128 | \e[58;5;128m | - | sp=0xAF00D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_129 | \e[58;5;129m | - | sp=0xAF00FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_130 | \e[58;5;130m | - | sp=0xAF5F00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_131 | \e[58;5;131m | - | sp=0xAF5F5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_132 | \e[58;5;132m | - | sp=0xAF5F87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_133 | \e[58;5;133m | - | sp=0xAF5FAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_134 | \e[58;5;134m | - | sp=0xAF5FD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_135 | \e[58;5;135m | - | sp=0xAF5FFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_136 | \e[58;5;136m | - | sp=0xAF8700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_137 | \e[58;5;137m | - | sp=0xAF875F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_138 | \e[58;5;138m | - | sp=0xAF8787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_139 | \e[58;5;139m | - | sp=0xAF87AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_140 | \e[58;5;140m | - | sp=0xAF87D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_141 | \e[58;5;141m | - | sp=0xAF87FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_142 | \e[58;5;142m | - | sp=0xAFAF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_143 | \e[58;5;143m | - | sp=0xAFAF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_144 | \e[58;5;144m | - | sp=0xAFAF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_145 | \e[58;5;145m | - | sp=0xAFAFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_146 | \e[58;5;146m | - | sp=0xAFAFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_147 | \e[58;5;147m | - | sp=0xAFAFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_148 | \e[58;5;148m | - | sp=0xAFD700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_149 | \e[58;5;149m | - | sp=0xAFD75F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_150 | \e[58;5;150m | - | sp=0xAFD787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_151 | \e[58;5;151m | - | sp=0xAFD7AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_152 | \e[58;5;152m | - | sp=0xAFD7D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_153 | \e[58;5;153m | - | sp=0xAFD7FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_154 | \e[58;5;154m | - | sp=0xAFFF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_155 | \e[58;5;155m | - | sp=0xAFFF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_156 | \e[58;5;156m | - | sp=0xAFFF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_157 | \e[58;5;157m | - | sp=0xAFFFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_158 | \e[58;5;158m | - | sp=0xAFFFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_159 | \e[58;5;159m | - | sp=0xAFFFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_160 | \e[58;5;160m | - | sp=0xD70000 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_161 | \e[58;5;161m | - | sp=0xD7005F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_162 | \e[58;5;162m | - | sp=0xD70087 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_163 | \e[58;5;163m | - | sp=0xD700AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_164 | \e[58;5;164m | - | sp=0xD700D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_165 | \e[58;5;165m | - | sp=0xD700FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_166 | \e[58;5;166m | - | sp=0xD75F00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_167 | \e[58;5;167m | - | sp=0xD75F5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_168 | \e[58;5;168m | - | sp=0xD75F87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_169 | \e[58;5;169m | - | sp=0xD75FAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_170 | \e[58;5;170m | - | sp=0xD75FD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_171 | \e[58;5;171m | - | sp=0xD75FFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_172 | \e[58;5;172m | - | sp=0xD78700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_173 | \e[58;5;173m | - | sp=0xD7875F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_174 | \e[58;5;174m | - | sp=0xD78787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_175 | \e[58;5;175m | - | sp=0xD787AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_176 | \e[58;5;176m | - | sp=0xD787D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_177 | \e[58;5;177m | - | sp=0xD787FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_178 | \e[58;5;178m | - | sp=0xD7AF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_179 | \e[58;5;179m | - | sp=0xD7AF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_180 | \e[58;5;180m | - | sp=0xD7AF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_181 | \e[58;5;181m | - | sp=0xD7AFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_182 | \e[58;5;182m | - | sp=0xD7AFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_183 | \e[58;5;183m | - | sp=0xD7AFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_184 | \e[58;5;184m | - | sp=0xD7D700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_185 | \e[58;5;185m | - | sp=0xD7D75F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_186 | \e[58;5;186m | - | sp=0xD7D787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_187 | \e[58;5;187m | - | sp=0xD7D7AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_188 | \e[58;5;188m | - | sp=0xD7D7D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_189 | \e[58;5;189m | - | sp=0xD7D7FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_190 | \e[58;5;190m | - | sp=0xD7FF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_191 | \e[58;5;191m | - | sp=0xD7FF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_192 | \e[58;5;192m | - | sp=0xD7FF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_193 | \e[58;5;193m | - | sp=0xD7FFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_194 | \e[58;5;194m | - | sp=0xD7FFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_195 | \e[58;5;195m | - | sp=0xD7FFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_196 | \e[58;5;196m | - | sp=0xFF0000 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_197 | \e[58;5;197m | - | sp=0xFF005F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_198 | \e[58;5;198m | - | sp=0xFF0087 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_199 | \e[58;5;199m | - | sp=0xFF00AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_200 | \e[58;5;200m | - | sp=0xFF00D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_201 | \e[58;5;201m | - | sp=0xFF00FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_202 | \e[58;5;202m | - | sp=0xFF5F00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_203 | \e[58;5;203m | - | sp=0xFF5F5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_204 | \e[58;5;204m | - | sp=0xFF5F87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_205 | \e[58;5;205m | - | sp=0xFF5FAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_206 | \e[58;5;206m | - | sp=0xFF5FD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_207 | \e[58;5;207m | - | sp=0xFF5FFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_208 | \e[58;5;208m | - | sp=0xFF8700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_209 | \e[58;5;209m | - | sp=0xFF875F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_210 | \e[58;5;210m | - | sp=0xFF8787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_211 | \e[58;5;211m | - | sp=0xFF87AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_212 | \e[58;5;212m | - | sp=0xFF87D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_213 | \e[58;5;213m | - | sp=0xFF87FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_214 | \e[58;5;214m | - | sp=0xFFAF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_215 | \e[58;5;215m | - | sp=0xFFAF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_216 | \e[58;5;216m | - | sp=0xFFAF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_217 | \e[58;5;217m | - | sp=0xFFAFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_218 | \e[58;5;218m | - | sp=0xFFAFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_219 | \e[58;5;219m | - | sp=0xFFAFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_220 | \e[58;5;220m | - | sp=0xFFD700 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_221 | \e[58;5;221m | - | sp=0xFFD75F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_222 | \e[58;5;222m | - | sp=0xFFD787 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_223 | \e[58;5;223m | - | sp=0xFFD7AF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_224 | \e[58;5;224m | - | sp=0xFFD7D7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_225 | \e[58;5;225m | - | sp=0xFFD7FF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_226 | \e[58;5;226m | - | sp=0xFFFF00 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_227 | \e[58;5;227m | - | sp=0xFFFF5F | 0 | 11 | xterm 256 underline palette
sgr | index_sp_228 | \e[58;5;228m | - | sp=0xFFFF87 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_229 | \e[58;5;229m | - | sp=0xFFFFAF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_230 | \e[58;5;230m | - | sp=0xFFFFD7 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_231 | \e[58;5;231m | - | sp=0xFFFFFF | 0 | 11 | xterm 256 underline palette
sgr | index_sp_232 | \e[58;5;232m | - | sp=0x080808 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_233 | \e[58;5;233m | - | sp=0x121212 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_234 | \e[58;5;234m | - | sp=0x1C1C1C | 0 | 11 | xterm 256 underline palette
sgr | index_sp_235 | \e[58;5;235m | - | sp=0x262626 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_236 | \e[58;5;236m | - | sp=0x303030 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_237 | \e[58;5;237m | - | sp=0x3A3A3A | 0 | 11 | xterm 256 underline palette
sgr | index_sp_238 | \e[58;5;238m | - | sp=0x444444 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_239 | \e[58;5;239m | - | sp=0x4E4E4E | 0 | 11 | xterm 256 underline palette
sgr | index_sp_240 | \e[58;5;240m | - | sp=0x585858 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_241 | \e[58;5;241m | - | sp=0x626262 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_242 | \e[58;5;242m | - | sp=0x6C6C6C | 0 | 11 | xterm 256 underline palette
sgr | index_sp_243 | \e[58;5;243m | - | sp=0x767676 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_244 | \e[58;5;244m | - | sp=0x808080 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_245 | \e[58;5;245m | - | sp=0x8A8A8A | 0 | 11 | xterm 256 underline palette
sgr | index_sp_246 | \e[58;5;246m | - | sp=0x949494 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_247 | \e[58;5;247m | - | sp=0x9E9E9E | 0 | 11 | xterm 256 underline palette
sgr | index_sp_248 | \e[58;5;248m | - | sp=0xA8A8A8 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_249 | \e[58;5;249m | - | sp=0xB2B2B2 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_250 | \e[58;5;250m | - | sp=0xBCBCBC | 0 | 11 | xterm 256 underline palette
sgr | index_sp_251 | \e[58;5;251m | - | sp=0xC6C6C6 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_252 | \e[58;5;252m | - | sp=0xD0D0D0 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_253 | \e[58;5;253m | - | sp=0xDADADA | 0 | 11 | xterm 256 underline palette
sgr | index_sp_254 | \e[58;5;254m | - | sp=0xE4E4E4 | 0 | 11 | xterm 256 underline palette
sgr | index_sp_255 | \e[58;5;255m | - | sp=0xEEEEEE | 0 | 11 | xterm 256 underline palette
sgr | colon_index_fg_000 | \e[38:5:0m | - | fg=0x000000 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_001 | \e[38:5:1m | - | fg=0xCD0000 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_002 | \e[38:5:2m | - | fg=0x00CD00 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_003 | \e[38:5:3m | - | fg=0xCDCD00 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_004 | \e[38:5:4m | - | fg=0x0000EE | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_005 | \e[38:5:5m | - | fg=0xCD00CD | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_006 | \e[38:5:6m | - | fg=0x00CDCD | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_007 | \e[38:5:7m | - | fg=0xE5E5E5 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_008 | \e[38:5:8m | - | fg=0x7F7F7F | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_009 | \e[38:5:9m | - | fg=0xFF0000 | 0 | 9 | T.416 indexed foreground palette
sgr | colon_index_fg_010 | \e[38:5:10m | - | fg=0x00FF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_011 | \e[38:5:11m | - | fg=0xFFFF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_012 | \e[38:5:12m | - | fg=0x5C5CFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_013 | \e[38:5:13m | - | fg=0xFF00FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_014 | \e[38:5:14m | - | fg=0x00FFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_015 | \e[38:5:15m | - | fg=0xFFFFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_016 | \e[38:5:16m | - | fg=0x000000 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_017 | \e[38:5:17m | - | fg=0x00005F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_018 | \e[38:5:18m | - | fg=0x000087 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_019 | \e[38:5:19m | - | fg=0x0000AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_020 | \e[38:5:20m | - | fg=0x0000D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_021 | \e[38:5:21m | - | fg=0x0000FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_022 | \e[38:5:22m | - | fg=0x005F00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_023 | \e[38:5:23m | - | fg=0x005F5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_024 | \e[38:5:24m | - | fg=0x005F87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_025 | \e[38:5:25m | - | fg=0x005FAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_026 | \e[38:5:26m | - | fg=0x005FD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_027 | \e[38:5:27m | - | fg=0x005FFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_028 | \e[38:5:28m | - | fg=0x008700 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_029 | \e[38:5:29m | - | fg=0x00875F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_030 | \e[38:5:30m | - | fg=0x008787 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_031 | \e[38:5:31m | - | fg=0x0087AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_032 | \e[38:5:32m | - | fg=0x0087D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_033 | \e[38:5:33m | - | fg=0x0087FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_034 | \e[38:5:34m | - | fg=0x00AF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_035 | \e[38:5:35m | - | fg=0x00AF5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_036 | \e[38:5:36m | - | fg=0x00AF87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_037 | \e[38:5:37m | - | fg=0x00AFAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_038 | \e[38:5:38m | - | fg=0x00AFD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_039 | \e[38:5:39m | - | fg=0x00AFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_040 | \e[38:5:40m | - | fg=0x00D700 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_041 | \e[38:5:41m | - | fg=0x00D75F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_042 | \e[38:5:42m | - | fg=0x00D787 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_043 | \e[38:5:43m | - | fg=0x00D7AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_044 | \e[38:5:44m | - | fg=0x00D7D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_045 | \e[38:5:45m | - | fg=0x00D7FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_046 | \e[38:5:46m | - | fg=0x00FF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_047 | \e[38:5:47m | - | fg=0x00FF5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_048 | \e[38:5:48m | - | fg=0x00FF87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_049 | \e[38:5:49m | - | fg=0x00FFAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_050 | \e[38:5:50m | - | fg=0x00FFD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_051 | \e[38:5:51m | - | fg=0x00FFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_052 | \e[38:5:52m | - | fg=0x5F0000 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_053 | \e[38:5:53m | - | fg=0x5F005F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_054 | \e[38:5:54m | - | fg=0x5F0087 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_055 | \e[38:5:55m | - | fg=0x5F00AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_056 | \e[38:5:56m | - | fg=0x5F00D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_057 | \e[38:5:57m | - | fg=0x5F00FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_058 | \e[38:5:58m | - | fg=0x5F5F00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_059 | \e[38:5:59m | - | fg=0x5F5F5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_060 | \e[38:5:60m | - | fg=0x5F5F87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_061 | \e[38:5:61m | - | fg=0x5F5FAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_062 | \e[38:5:62m | - | fg=0x5F5FD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_063 | \e[38:5:63m | - | fg=0x5F5FFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_064 | \e[38:5:64m | - | fg=0x5F8700 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_065 | \e[38:5:65m | - | fg=0x5F875F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_066 | \e[38:5:66m | - | fg=0x5F8787 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_067 | \e[38:5:67m | - | fg=0x5F87AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_068 | \e[38:5:68m | - | fg=0x5F87D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_069 | \e[38:5:69m | - | fg=0x5F87FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_070 | \e[38:5:70m | - | fg=0x5FAF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_071 | \e[38:5:71m | - | fg=0x5FAF5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_072 | \e[38:5:72m | - | fg=0x5FAF87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_073 | \e[38:5:73m | - | fg=0x5FAFAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_074 | \e[38:5:74m | - | fg=0x5FAFD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_075 | \e[38:5:75m | - | fg=0x5FAFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_076 | \e[38:5:76m | - | fg=0x5FD700 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_077 | \e[38:5:77m | - | fg=0x5FD75F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_078 | \e[38:5:78m | - | fg=0x5FD787 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_079 | \e[38:5:79m | - | fg=0x5FD7AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_080 | \e[38:5:80m | - | fg=0x5FD7D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_081 | \e[38:5:81m | - | fg=0x5FD7FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_082 | \e[38:5:82m | - | fg=0x5FFF00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_083 | \e[38:5:83m | - | fg=0x5FFF5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_084 | \e[38:5:84m | - | fg=0x5FFF87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_085 | \e[38:5:85m | - | fg=0x5FFFAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_086 | \e[38:5:86m | - | fg=0x5FFFD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_087 | \e[38:5:87m | - | fg=0x5FFFFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_088 | \e[38:5:88m | - | fg=0x870000 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_089 | \e[38:5:89m | - | fg=0x87005F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_090 | \e[38:5:90m | - | fg=0x870087 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_091 | \e[38:5:91m | - | fg=0x8700AF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_092 | \e[38:5:92m | - | fg=0x8700D7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_093 | \e[38:5:93m | - | fg=0x8700FF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_094 | \e[38:5:94m | - | fg=0x875F00 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_095 | \e[38:5:95m | - | fg=0x875F5F | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_096 | \e[38:5:96m | - | fg=0x875F87 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_097 | \e[38:5:97m | - | fg=0x875FAF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_098 | \e[38:5:98m | - | fg=0x875FD7 | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_099 | \e[38:5:99m | - | fg=0x875FFF | 0 | 10 | T.416 indexed foreground palette
sgr | colon_index_fg_100 | \e[38:5:100m | - | fg=0x878700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_101 | \e[38:5:101m | - | fg=0x87875F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_102 | \e[38:5:102m | - | fg=0x878787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_103 | \e[38:5:103m | - | fg=0x8787AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_104 | \e[38:5:104m | - | fg=0x8787D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_105 | \e[38:5:105m | - | fg=0x8787FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_106 | \e[38:5:106m | - | fg=0x87AF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_107 | \e[38:5:107m | - | fg=0x87AF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_108 | \e[38:5:108m | - | fg=0x87AF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_109 | \e[38:5:109m | - | fg=0x87AFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_110 | \e[38:5:110m | - | fg=0x87AFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_111 | \e[38:5:111m | - | fg=0x87AFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_112 | \e[38:5:112m | - | fg=0x87D700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_113 | \e[38:5:113m | - | fg=0x87D75F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_114 | \e[38:5:114m | - | fg=0x87D787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_115 | \e[38:5:115m | - | fg=0x87D7AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_116 | \e[38:5:116m | - | fg=0x87D7D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_117 | \e[38:5:117m | - | fg=0x87D7FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_118 | \e[38:5:118m | - | fg=0x87FF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_119 | \e[38:5:119m | - | fg=0x87FF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_120 | \e[38:5:120m | - | fg=0x87FF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_121 | \e[38:5:121m | - | fg=0x87FFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_122 | \e[38:5:122m | - | fg=0x87FFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_123 | \e[38:5:123m | - | fg=0x87FFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_124 | \e[38:5:124m | - | fg=0xAF0000 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_125 | \e[38:5:125m | - | fg=0xAF005F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_126 | \e[38:5:126m | - | fg=0xAF0087 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_127 | \e[38:5:127m | - | fg=0xAF00AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_128 | \e[38:5:128m | - | fg=0xAF00D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_129 | \e[38:5:129m | - | fg=0xAF00FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_130 | \e[38:5:130m | - | fg=0xAF5F00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_131 | \e[38:5:131m | - | fg=0xAF5F5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_132 | \e[38:5:132m | - | fg=0xAF5F87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_133 | \e[38:5:133m | - | fg=0xAF5FAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_134 | \e[38:5:134m | - | fg=0xAF5FD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_135 | \e[38:5:135m | - | fg=0xAF5FFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_136 | \e[38:5:136m | - | fg=0xAF8700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_137 | \e[38:5:137m | - | fg=0xAF875F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_138 | \e[38:5:138m | - | fg=0xAF8787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_139 | \e[38:5:139m | - | fg=0xAF87AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_140 | \e[38:5:140m | - | fg=0xAF87D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_141 | \e[38:5:141m | - | fg=0xAF87FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_142 | \e[38:5:142m | - | fg=0xAFAF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_143 | \e[38:5:143m | - | fg=0xAFAF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_144 | \e[38:5:144m | - | fg=0xAFAF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_145 | \e[38:5:145m | - | fg=0xAFAFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_146 | \e[38:5:146m | - | fg=0xAFAFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_147 | \e[38:5:147m | - | fg=0xAFAFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_148 | \e[38:5:148m | - | fg=0xAFD700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_149 | \e[38:5:149m | - | fg=0xAFD75F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_150 | \e[38:5:150m | - | fg=0xAFD787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_151 | \e[38:5:151m | - | fg=0xAFD7AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_152 | \e[38:5:152m | - | fg=0xAFD7D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_153 | \e[38:5:153m | - | fg=0xAFD7FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_154 | \e[38:5:154m | - | fg=0xAFFF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_155 | \e[38:5:155m | - | fg=0xAFFF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_156 | \e[38:5:156m | - | fg=0xAFFF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_157 | \e[38:5:157m | - | fg=0xAFFFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_158 | \e[38:5:158m | - | fg=0xAFFFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_159 | \e[38:5:159m | - | fg=0xAFFFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_160 | \e[38:5:160m | - | fg=0xD70000 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_161 | \e[38:5:161m | - | fg=0xD7005F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_162 | \e[38:5:162m | - | fg=0xD70087 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_163 | \e[38:5:163m | - | fg=0xD700AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_164 | \e[38:5:164m | - | fg=0xD700D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_165 | \e[38:5:165m | - | fg=0xD700FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_166 | \e[38:5:166m | - | fg=0xD75F00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_167 | \e[38:5:167m | - | fg=0xD75F5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_168 | \e[38:5:168m | - | fg=0xD75F87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_169 | \e[38:5:169m | - | fg=0xD75FAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_170 | \e[38:5:170m | - | fg=0xD75FD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_171 | \e[38:5:171m | - | fg=0xD75FFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_172 | \e[38:5:172m | - | fg=0xD78700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_173 | \e[38:5:173m | - | fg=0xD7875F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_174 | \e[38:5:174m | - | fg=0xD78787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_175 | \e[38:5:175m | - | fg=0xD787AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_176 | \e[38:5:176m | - | fg=0xD787D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_177 | \e[38:5:177m | - | fg=0xD787FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_178 | \e[38:5:178m | - | fg=0xD7AF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_179 | \e[38:5:179m | - | fg=0xD7AF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_180 | \e[38:5:180m | - | fg=0xD7AF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_181 | \e[38:5:181m | - | fg=0xD7AFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_182 | \e[38:5:182m | - | fg=0xD7AFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_183 | \e[38:5:183m | - | fg=0xD7AFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_184 | \e[38:5:184m | - | fg=0xD7D700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_185 | \e[38:5:185m | - | fg=0xD7D75F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_186 | \e[38:5:186m | - | fg=0xD7D787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_187 | \e[38:5:187m | - | fg=0xD7D7AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_188 | \e[38:5:188m | - | fg=0xD7D7D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_189 | \e[38:5:189m | - | fg=0xD7D7FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_190 | \e[38:5:190m | - | fg=0xD7FF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_191 | \e[38:5:191m | - | fg=0xD7FF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_192 | \e[38:5:192m | - | fg=0xD7FF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_193 | \e[38:5:193m | - | fg=0xD7FFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_194 | \e[38:5:194m | - | fg=0xD7FFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_195 | \e[38:5:195m | - | fg=0xD7FFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_196 | \e[38:5:196m | - | fg=0xFF0000 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_197 | \e[38:5:197m | - | fg=0xFF005F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_198 | \e[38:5:198m | - | fg=0xFF0087 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_199 | \e[38:5:199m | - | fg=0xFF00AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_200 | \e[38:5:200m | - | fg=0xFF00D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_201 | \e[38:5:201m | - | fg=0xFF00FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_202 | \e[38:5:202m | - | fg=0xFF5F00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_203 | \e[38:5:203m | - | fg=0xFF5F5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_204 | \e[38:5:204m | - | fg=0xFF5F87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_205 | \e[38:5:205m | - | fg=0xFF5FAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_206 | \e[38:5:206m | - | fg=0xFF5FD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_207 | \e[38:5:207m | - | fg=0xFF5FFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_208 | \e[38:5:208m | - | fg=0xFF8700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_209 | \e[38:5:209m | - | fg=0xFF875F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_210 | \e[38:5:210m | - | fg=0xFF8787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_211 | \e[38:5:211m | - | fg=0xFF87AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_212 | \e[38:5:212m | - | fg=0xFF87D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_213 | \e[38:5:213m | - | fg=0xFF87FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_214 | \e[38:5:214m | - | fg=0xFFAF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_215 | \e[38:5:215m | - | fg=0xFFAF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_216 | \e[38:5:216m | - | fg=0xFFAF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_217 | \e[38:5:217m | - | fg=0xFFAFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_218 | \e[38:5:218m | - | fg=0xFFAFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_219 | \e[38:5:219m | - | fg=0xFFAFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_220 | \e[38:5:220m | - | fg=0xFFD700 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_221 | \e[38:5:221m | - | fg=0xFFD75F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_222 | \e[38:5:222m | - | fg=0xFFD787 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_223 | \e[38:5:223m | - | fg=0xFFD7AF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_224 | \e[38:5:224m | - | fg=0xFFD7D7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_225 | \e[38:5:225m | - | fg=0xFFD7FF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_226 | \e[38:5:226m | - | fg=0xFFFF00 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_227 | \e[38:5:227m | - | fg=0xFFFF5F | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_228 | \e[38:5:228m | - | fg=0xFFFF87 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_229 | \e[38:5:229m | - | fg=0xFFFFAF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_230 | \e[38:5:230m | - | fg=0xFFFFD7 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_231 | \e[38:5:231m | - | fg=0xFFFFFF | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_232 | \e[38:5:232m | - | fg=0x080808 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_233 | \e[38:5:233m | - | fg=0x121212 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_234 | \e[38:5:234m | - | fg=0x1C1C1C | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_235 | \e[38:5:235m | - | fg=0x262626 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_236 | \e[38:5:236m | - | fg=0x303030 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_237 | \e[38:5:237m | - | fg=0x3A3A3A | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_238 | \e[38:5:238m | - | fg=0x444444 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_239 | \e[38:5:239m | - | fg=0x4E4E4E | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_240 | \e[38:5:240m | - | fg=0x585858 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_241 | \e[38:5:241m | - | fg=0x626262 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_242 | \e[38:5:242m | - | fg=0x6C6C6C | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_243 | \e[38:5:243m | - | fg=0x767676 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_244 | \e[38:5:244m | - | fg=0x808080 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_245 | \e[38:5:245m | - | fg=0x8A8A8A | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_246 | \e[38:5:246m | - | fg=0x949494 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_247 | \e[38:5:247m | - | fg=0x9E9E9E | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_248 | \e[38:5:248m | - | fg=0xA8A8A8 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_249 | \e[38:5:249m | - | fg=0xB2B2B2 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_250 | \e[38:5:250m | - | fg=0xBCBCBC | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_251 | \e[38:5:251m | - | fg=0xC6C6C6 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_252 | \e[38:5:252m | - | fg=0xD0D0D0 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_253 | \e[38:5:253m | - | fg=0xDADADA | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_254 | \e[38:5:254m | - | fg=0xE4E4E4 | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_fg_255 | \e[38:5:255m | - | fg=0xEEEEEE | 0 | 11 | T.416 indexed foreground palette
sgr | colon_index_bg_000 | \e[48:5:0m | - | bg=0x000000 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_001 | \e[48:5:1m | - | bg=0xCD0000 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_002 | \e[48:5:2m | - | bg=0x00CD00 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_003 | \e[48:5:3m | - | bg=0xCDCD00 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_004 | \e[48:5:4m | - | bg=0x0000EE | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_005 | \e[48:5:5m | - | bg=0xCD00CD | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_006 | \e[48:5:6m | - | bg=0x00CDCD | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_007 | \e[48:5:7m | - | bg=0xE5E5E5 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_008 | \e[48:5:8m | - | bg=0x7F7F7F | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_009 | \e[48:5:9m | - | bg=0xFF0000 | 0 | 9 | T.416 indexed background palette
sgr | colon_index_bg_010 | \e[48:5:10m | - | bg=0x00FF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_011 | \e[48:5:11m | - | bg=0xFFFF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_012 | \e[48:5:12m | - | bg=0x5C5CFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_013 | \e[48:5:13m | - | bg=0xFF00FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_014 | \e[48:5:14m | - | bg=0x00FFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_015 | \e[48:5:15m | - | bg=0xFFFFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_016 | \e[48:5:16m | - | bg=0x000000 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_017 | \e[48:5:17m | - | bg=0x00005F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_018 | \e[48:5:18m | - | bg=0x000087 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_019 | \e[48:5:19m | - | bg=0x0000AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_020 | \e[48:5:20m | - | bg=0x0000D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_021 | \e[48:5:21m | - | bg=0x0000FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_022 | \e[48:5:22m | - | bg=0x005F00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_023 | \e[48:5:23m | - | bg=0x005F5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_024 | \e[48:5:24m | - | bg=0x005F87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_025 | \e[48:5:25m | - | bg=0x005FAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_026 | \e[48:5:26m | - | bg=0x005FD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_027 | \e[48:5:27m | - | bg=0x005FFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_028 | \e[48:5:28m | - | bg=0x008700 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_029 | \e[48:5:29m | - | bg=0x00875F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_030 | \e[48:5:30m | - | bg=0x008787 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_031 | \e[48:5:31m | - | bg=0x0087AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_032 | \e[48:5:32m | - | bg=0x0087D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_033 | \e[48:5:33m | - | bg=0x0087FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_034 | \e[48:5:34m | - | bg=0x00AF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_035 | \e[48:5:35m | - | bg=0x00AF5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_036 | \e[48:5:36m | - | bg=0x00AF87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_037 | \e[48:5:37m | - | bg=0x00AFAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_038 | \e[48:5:38m | - | bg=0x00AFD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_039 | \e[48:5:39m | - | bg=0x00AFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_040 | \e[48:5:40m | - | bg=0x00D700 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_041 | \e[48:5:41m | - | bg=0x00D75F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_042 | \e[48:5:42m | - | bg=0x00D787 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_043 | \e[48:5:43m | - | bg=0x00D7AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_044 | \e[48:5:44m | - | bg=0x00D7D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_045 | \e[48:5:45m | - | bg=0x00D7FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_046 | \e[48:5:46m | - | bg=0x00FF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_047 | \e[48:5:47m | - | bg=0x00FF5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_048 | \e[48:5:48m | - | bg=0x00FF87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_049 | \e[48:5:49m | - | bg=0x00FFAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_050 | \e[48:5:50m | - | bg=0x00FFD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_051 | \e[48:5:51m | - | bg=0x00FFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_052 | \e[48:5:52m | - | bg=0x5F0000 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_053 | \e[48:5:53m | - | bg=0x5F005F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_054 | \e[48:5:54m | - | bg=0x5F0087 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_055 | \e[48:5:55m | - | bg=0x5F00AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_056 | \e[48:5:56m | - | bg=0x5F00D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_057 | \e[48:5:57m | - | bg=0x5F00FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_058 | \e[48:5:58m | - | bg=0x5F5F00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_059 | \e[48:5:59m | - | bg=0x5F5F5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_060 | \e[48:5:60m | - | bg=0x5F5F87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_061 | \e[48:5:61m | - | bg=0x5F5FAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_062 | \e[48:5:62m | - | bg=0x5F5FD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_063 | \e[48:5:63m | - | bg=0x5F5FFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_064 | \e[48:5:64m | - | bg=0x5F8700 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_065 | \e[48:5:65m | - | bg=0x5F875F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_066 | \e[48:5:66m | - | bg=0x5F8787 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_067 | \e[48:5:67m | - | bg=0x5F87AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_068 | \e[48:5:68m | - | bg=0x5F87D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_069 | \e[48:5:69m | - | bg=0x5F87FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_070 | \e[48:5:70m | - | bg=0x5FAF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_071 | \e[48:5:71m | - | bg=0x5FAF5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_072 | \e[48:5:72m | - | bg=0x5FAF87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_073 | \e[48:5:73m | - | bg=0x5FAFAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_074 | \e[48:5:74m | - | bg=0x5FAFD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_075 | \e[48:5:75m | - | bg=0x5FAFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_076 | \e[48:5:76m | - | bg=0x5FD700 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_077 | \e[48:5:77m | - | bg=0x5FD75F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_078 | \e[48:5:78m | - | bg=0x5FD787 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_079 | \e[48:5:79m | - | bg=0x5FD7AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_080 | \e[48:5:80m | - | bg=0x5FD7D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_081 | \e[48:5:81m | - | bg=0x5FD7FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_082 | \e[48:5:82m | - | bg=0x5FFF00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_083 | \e[48:5:83m | - | bg=0x5FFF5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_084 | \e[48:5:84m | - | bg=0x5FFF87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_085 | \e[48:5:85m | - | bg=0x5FFFAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_086 | \e[48:5:86m | - | bg=0x5FFFD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_087 | \e[48:5:87m | - | bg=0x5FFFFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_088 | \e[48:5:88m | - | bg=0x870000 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_089 | \e[48:5:89m | - | bg=0x87005F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_090 | \e[48:5:90m | - | bg=0x870087 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_091 | \e[48:5:91m | - | bg=0x8700AF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_092 | \e[48:5:92m | - | bg=0x8700D7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_093 | \e[48:5:93m | - | bg=0x8700FF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_094 | \e[48:5:94m | - | bg=0x875F00 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_095 | \e[48:5:95m | - | bg=0x875F5F | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_096 | \e[48:5:96m | - | bg=0x875F87 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_097 | \e[48:5:97m | - | bg=0x875FAF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_098 | \e[48:5:98m | - | bg=0x875FD7 | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_099 | \e[48:5:99m | - | bg=0x875FFF | 0 | 10 | T.416 indexed background palette
sgr | colon_index_bg_100 | \e[48:5:100m | - | bg=0x878700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_101 | \e[48:5:101m | - | bg=0x87875F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_102 | \e[48:5:102m | - | bg=0x878787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_103 | \e[48:5:103m | - | bg=0x8787AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_104 | \e[48:5:104m | - | bg=0x8787D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_105 | \e[48:5:105m | - | bg=0x8787FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_106 | \e[48:5:106m | - | bg=0x87AF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_107 | \e[48:5:107m | - | bg=0x87AF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_108 | \e[48:5:108m | - | bg=0x87AF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_109 | \e[48:5:109m | - | bg=0x87AFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_110 | \e[48:5:110m | - | bg=0x87AFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_111 | \e[48:5:111m | - | bg=0x87AFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_112 | \e[48:5:112m | - | bg=0x87D700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_113 | \e[48:5:113m | - | bg=0x87D75F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_114 | \e[48:5:114m | - | bg=0x87D787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_115 | \e[48:5:115m | - | bg=0x87D7AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_116 | \e[48:5:116m | - | bg=0x87D7D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_117 | \e[48:5:117m | - | bg=0x87D7FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_118 | \e[48:5:118m | - | bg=0x87FF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_119 | \e[48:5:119m | - | bg=0x87FF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_120 | \e[48:5:120m | - | bg=0x87FF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_121 | \e[48:5:121m | - | bg=0x87FFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_122 | \e[48:5:122m | - | bg=0x87FFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_123 | \e[48:5:123m | - | bg=0x87FFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_124 | \e[48:5:124m | - | bg=0xAF0000 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_125 | \e[48:5:125m | - | bg=0xAF005F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_126 | \e[48:5:126m | - | bg=0xAF0087 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_127 | \e[48:5:127m | - | bg=0xAF00AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_128 | \e[48:5:128m | - | bg=0xAF00D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_129 | \e[48:5:129m | - | bg=0xAF00FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_130 | \e[48:5:130m | - | bg=0xAF5F00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_131 | \e[48:5:131m | - | bg=0xAF5F5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_132 | \e[48:5:132m | - | bg=0xAF5F87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_133 | \e[48:5:133m | - | bg=0xAF5FAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_134 | \e[48:5:134m | - | bg=0xAF5FD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_135 | \e[48:5:135m | - | bg=0xAF5FFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_136 | \e[48:5:136m | - | bg=0xAF8700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_137 | \e[48:5:137m | - | bg=0xAF875F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_138 | \e[48:5:138m | - | bg=0xAF8787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_139 | \e[48:5:139m | - | bg=0xAF87AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_140 | \e[48:5:140m | - | bg=0xAF87D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_141 | \e[48:5:141m | - | bg=0xAF87FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_142 | \e[48:5:142m | - | bg=0xAFAF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_143 | \e[48:5:143m | - | bg=0xAFAF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_144 | \e[48:5:144m | - | bg=0xAFAF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_145 | \e[48:5:145m | - | bg=0xAFAFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_146 | \e[48:5:146m | - | bg=0xAFAFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_147 | \e[48:5:147m | - | bg=0xAFAFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_148 | \e[48:5:148m | - | bg=0xAFD700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_149 | \e[48:5:149m | - | bg=0xAFD75F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_150 | \e[48:5:150m | - | bg=0xAFD787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_151 | \e[48:5:151m | - | bg=0xAFD7AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_152 | \e[48:5:152m | - | bg=0xAFD7D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_153 | \e[48:5:153m | - | bg=0xAFD7FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_154 | \e[48:5:154m | - | bg=0xAFFF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_155 | \e[48:5:155m | - | bg=0xAFFF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_156 | \e[48:5:156m | - | bg=0xAFFF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_157 | \e[48:5:157m | - | bg=0xAFFFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_158 | \e[48:5:158m | - | bg=0xAFFFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_159 | \e[48:5:159m | - | bg=0xAFFFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_160 | \e[48:5:160m | - | bg=0xD70000 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_161 | \e[48:5:161m | - | bg=0xD7005F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_162 | \e[48:5:162m | - | bg=0xD70087 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_163 | \e[48:5:163m | - | bg=0xD700AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_164 | \e[48:5:164m | - | bg=0xD700D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_165 | \e[48:5:165m | - | bg=0xD700FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_166 | \e[48:5:166m | - | bg=0xD75F00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_167 | \e[48:5:167m | - | bg=0xD75F5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_168 | \e[48:5:168m | - | bg=0xD75F87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_169 | \e[48:5:169m | - | bg=0xD75FAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_170 | \e[48:5:170m | - | bg=0xD75FD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_171 | \e[48:5:171m | - | bg=0xD75FFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_172 | \e[48:5:172m | - | bg=0xD78700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_173 | \e[48:5:173m | - | bg=0xD7875F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_174 | \e[48:5:174m | - | bg=0xD78787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_175 | \e[48:5:175m | - | bg=0xD787AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_176 | \e[48:5:176m | - | bg=0xD787D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_177 | \e[48:5:177m | - | bg=0xD787FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_178 | \e[48:5:178m | - | bg=0xD7AF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_179 | \e[48:5:179m | - | bg=0xD7AF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_180 | \e[48:5:180m | - | bg=0xD7AF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_181 | \e[48:5:181m | - | bg=0xD7AFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_182 | \e[48:5:182m | - | bg=0xD7AFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_183 | \e[48:5:183m | - | bg=0xD7AFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_184 | \e[48:5:184m | - | bg=0xD7D700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_185 | \e[48:5:185m | - | bg=0xD7D75F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_186 | \e[48:5:186m | - | bg=0xD7D787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_187 | \e[48:5:187m | - | bg=0xD7D7AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_188 | \e[48:5:188m | - | bg=0xD7D7D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_189 | \e[48:5:189m | - | bg=0xD7D7FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_190 | \e[48:5:190m | - | bg=0xD7FF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_191 | \e[48:5:191m | - | bg=0xD7FF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_192 | \e[48:5:192m | - | bg=0xD7FF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_193 | \e[48:5:193m | - | bg=0xD7FFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_194 | \e[48:5:194m | - | bg=0xD7FFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_195 | \e[48:5:195m | - | bg=0xD7FFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_196 | \e[48:5:196m | - | bg=0xFF0000 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_197 | \e[48:5:197m | - | bg=0xFF005F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_198 | \e[48:5:198m | - | bg=0xFF0087 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_199 | \e[48:5:199m | - | bg=0xFF00AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_200 | \e[48:5:200m | - | bg=0xFF00D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_201 | \e[48:5:201m | - | bg=0xFF00FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_202 | \e[48:5:202m | - | bg=0xFF5F00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_203 | \e[48:5:203m | - | bg=0xFF5F5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_204 | \e[48:5:204m | - | bg=0xFF5F87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_205 | \e[48:5:205m | - | bg=0xFF5FAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_206 | \e[48:5:206m | - | bg=0xFF5FD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_207 | \e[48:5:207m | - | bg=0xFF5FFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_208 | \e[48:5:208m | - | bg=0xFF8700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_209 | \e[48:5:209m | - | bg=0xFF875F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_210 | \e[48:5:210m | - | bg=0xFF8787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_211 | \e[48:5:211m | - | bg=0xFF87AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_212 | \e[48:5:212m | - | bg=0xFF87D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_213 | \e[48:5:213m | - | bg=0xFF87FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_214 | \e[48:5:214m | - | bg=0xFFAF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_215 | \e[48:5:215m | - | bg=0xFFAF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_216 | \e[48:5:216m | - | bg=0xFFAF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_217 | \e[48:5:217m | - | bg=0xFFAFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_218 | \e[48:5:218m | - | bg=0xFFAFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_219 | \e[48:5:219m | - | bg=0xFFAFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_220 | \e[48:5:220m | - | bg=0xFFD700 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_221 | \e[48:5:221m | - | bg=0xFFD75F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_222 | \e[48:5:222m | - | bg=0xFFD787 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_223 | \e[48:5:223m | - | bg=0xFFD7AF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_224 | \e[48:5:224m | - | bg=0xFFD7D7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_225 | \e[48:5:225m | - | bg=0xFFD7FF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_226 | \e[48:5:226m | - | bg=0xFFFF00 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_227 | \e[48:5:227m | - | bg=0xFFFF5F | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_228 | \e[48:5:228m | - | bg=0xFFFF87 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_229 | \e[48:5:229m | - | bg=0xFFFFAF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_230 | \e[48:5:230m | - | bg=0xFFFFD7 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_231 | \e[48:5:231m | - | bg=0xFFFFFF | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_232 | \e[48:5:232m | - | bg=0x080808 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_233 | \e[48:5:233m | - | bg=0x121212 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_234 | \e[48:5:234m | - | bg=0x1C1C1C | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_235 | \e[48:5:235m | - | bg=0x262626 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_236 | \e[48:5:236m | - | bg=0x303030 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_237 | \e[48:5:237m | - | bg=0x3A3A3A | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_238 | \e[48:5:238m | - | bg=0x444444 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_239 | \e[48:5:239m | - | bg=0x4E4E4E | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_240 | \e[48:5:240m | - | bg=0x585858 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_241 | \e[48:5:241m | - | bg=0x626262 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_242 | \e[48:5:242m | - | bg=0x6C6C6C | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_243 | \e[48:5:243m | - | bg=0x767676 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_244 | \e[48:5:244m | - | bg=0x808080 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_245 | \e[48:5:245m | - | bg=0x8A8A8A | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_246 | \e[48:5:246m | - | bg=0x949494 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_247 | \e[48:5:247m | - | bg=0x9E9E9E | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_248 | \e[48:5:248m | - | bg=0xA8A8A8 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_249 | \e[48:5:249m | - | bg=0xB2B2B2 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_250 | \e[48:5:250m | - | bg=0xBCBCBC | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_251 | \e[48:5:251m | - | bg=0xC6C6C6 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_252 | \e[48:5:252m | - | bg=0xD0D0D0 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_253 | \e[48:5:253m | - | bg=0xDADADA | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_254 | \e[48:5:254m | - | bg=0xE4E4E4 | 0 | 11 | T.416 indexed background palette
sgr | colon_index_bg_255 | \e[48:5:255m | - | bg=0xEEEEEE | 0 | 11 | T.416 indexed background palette
sgr | colon_index_sp_000 | \e[58:5:0m | - | sp=0x000000 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_001 | \e[58:5:1m | - | sp=0xCD0000 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_002 | \e[58:5:2m | - | sp=0x00CD00 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_003 | \e[58:5:3m | - | sp=0xCDCD00 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_004 | \e[58:5:4m | - | sp=0x0000EE | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_005 | \e[58:5:5m | - | sp=0xCD00CD | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_006 | \e[58:5:6m | - | sp=0x00CDCD | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_007 | \e[58:5:7m | - | sp=0xE5E5E5 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_008 | \e[58:5:8m | - | sp=0x7F7F7F | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_009 | \e[58:5:9m | - | sp=0xFF0000 | 0 | 9 | T.416 indexed underline palette
sgr | colon_index_sp_010 | \e[58:5:10m | - | sp=0x00FF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_011 | \e[58:5:11m | - | sp=0xFFFF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_012 | \e[58:5:12m | - | sp=0x5C5CFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_013 | \e[58:5:13m | - | sp=0xFF00FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_014 | \e[58:5:14m | - | sp=0x00FFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_015 | \e[58:5:15m | - | sp=0xFFFFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_016 | \e[58:5:16m | - | sp=0x000000 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_017 | \e[58:5:17m | - | sp=0x00005F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_018 | \e[58:5:18m | - | sp=0x000087 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_019 | \e[58:5:19m | - | sp=0x0000AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_020 | \e[58:5:20m | - | sp=0x0000D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_021 | \e[58:5:21m | - | sp=0x0000FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_022 | \e[58:5:22m | - | sp=0x005F00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_023 | \e[58:5:23m | - | sp=0x005F5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_024 | \e[58:5:24m | - | sp=0x005F87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_025 | \e[58:5:25m | - | sp=0x005FAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_026 | \e[58:5:26m | - | sp=0x005FD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_027 | \e[58:5:27m | - | sp=0x005FFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_028 | \e[58:5:28m | - | sp=0x008700 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_029 | \e[58:5:29m | - | sp=0x00875F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_030 | \e[58:5:30m | - | sp=0x008787 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_031 | \e[58:5:31m | - | sp=0x0087AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_032 | \e[58:5:32m | - | sp=0x0087D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_033 | \e[58:5:33m | - | sp=0x0087FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_034 | \e[58:5:34m | - | sp=0x00AF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_035 | \e[58:5:35m | - | sp=0x00AF5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_036 | \e[58:5:36m | - | sp=0x00AF87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_037 | \e[58:5:37m | - | sp=0x00AFAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_038 | \e[58:5:38m | - | sp=0x00AFD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_039 | \e[58:5:39m | - | sp=0x00AFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_040 | \e[58:5:40m | - | sp=0x00D700 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_041 | \e[58:5:41m | - | sp=0x00D75F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_042 | \e[58:5:42m | - | sp=0x00D787 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_043 | \e[58:5:43m | - | sp=0x00D7AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_044 | \e[58:5:44m | - | sp=0x00D7D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_045 | \e[58:5:45m | - | sp=0x00D7FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_046 | \e[58:5:46m | - | sp=0x00FF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_047 | \e[58:5:47m | - | sp=0x00FF5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_048 | \e[58:5:48m | - | sp=0x00FF87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_049 | \e[58:5:49m | - | sp=0x00FFAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_050 | \e[58:5:50m | - | sp=0x00FFD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_051 | \e[58:5:51m | - | sp=0x00FFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_052 | \e[58:5:52m | - | sp=0x5F0000 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_053 | \e[58:5:53m | - | sp=0x5F005F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_054 | \e[58:5:54m | - | sp=0x5F0087 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_055 | \e[58:5:55m | - | sp=0x5F00AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_056 | \e[58:5:56m | - | sp=0x5F00D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_057 | \e[58:5:57m | - | sp=0x5F00FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_058 | \e[58:5:58m | - | sp=0x5F5F00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_059 | \e[58:5:59m | - | sp=0x5F5F5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_060 | \e[58:5:60m | - | sp=0x5F5F87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_061 | \e[58:5:61m | - | sp=0x5F5FAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_062 | \e[58:5:62m | - | sp=0x5F5FD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_063 | \e[58:5:63m | - | sp=0x5F5FFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_064 | \e[58:5:64m | - | sp=0x5F8700 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_065 | \e[58:5:65m | - | sp=0x5F875F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_066 | \e[58:5:66m | - | sp=0x5F8787 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_067 | \e[58:5:67m | - | sp=0x5F87AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_068 | \e[58:5:68m | - | sp=0x5F87D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_069 | \e[58:5:69m | - | sp=0x5F87FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_070 | \e[58:5:70m | - | sp=0x5FAF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_071 | \e[58:5:71m | - | sp=0x5FAF5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_072 | \e[58:5:72m | - | sp=0x5FAF87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_073 | \e[58:5:73m | - | sp=0x5FAFAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_074 | \e[58:5:74m | - | sp=0x5FAFD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_075 | \e[58:5:75m | - | sp=0x5FAFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_076 | \e[58:5:76m | - | sp=0x5FD700 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_077 | \e[58:5:77m | - | sp=0x5FD75F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_078 | \e[58:5:78m | - | sp=0x5FD787 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_079 | \e[58:5:79m | - | sp=0x5FD7AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_080 | \e[58:5:80m | - | sp=0x5FD7D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_081 | \e[58:5:81m | - | sp=0x5FD7FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_082 | \e[58:5:82m | - | sp=0x5FFF00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_083 | \e[58:5:83m | - | sp=0x5FFF5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_084 | \e[58:5:84m | - | sp=0x5FFF87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_085 | \e[58:5:85m | - | sp=0x5FFFAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_086 | \e[58:5:86m | - | sp=0x5FFFD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_087 | \e[58:5:87m | - | sp=0x5FFFFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_088 | \e[58:5:88m | - | sp=0x870000 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_089 | \e[58:5:89m | - | sp=0x87005F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_090 | \e[58:5:90m | - | sp=0x870087 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_091 | \e[58:5:91m | - | sp=0x8700AF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_092 | \e[58:5:92m | - | sp=0x8700D7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_093 | \e[58:5:93m | - | sp=0x8700FF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_094 | \e[58:5:94m | - | sp=0x875F00 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_095 | \e[58:5:95m | - | sp=0x875F5F | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_096 | \e[58:5:96m | - | sp=0x875F87 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_097 | \e[58:5:97m | - | sp=0x875FAF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_098 | \e[58:5:98m | - | sp=0x875FD7 | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_099 | \e[58:5:99m | - | sp=0x875FFF | 0 | 10 | T.416 indexed underline palette
sgr | colon_index_sp_100 | \e[58:5:100m | - | sp=0x878700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_101 | \e[58:5:101m | - | sp=0x87875F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_102 | \e[58:5:102m | - | sp=0x878787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_103 | \e[58:5:103m | - | sp=0x8787AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_104 | \e[58:5:104m | - | sp=0x8787D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_105 | \e[58:5:105m | - | sp=0x8787FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_106 | \e[58:5:106m | - | sp=0x87AF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_107 | \e[58:5:107m | - | sp=0x87AF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_108 | \e[58:5:108m | - | sp=0x87AF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_109 | \e[58:5:109m | - | sp=0x87AFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_110 | \e[58:5:110m | - | sp=0x87AFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_111 | \e[58:5:111m | - | sp=0x87AFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_112 | \e[58:5:112m | - | sp=0x87D700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_113 | \e[58:5:113m | - | sp=0x87D75F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_114 | \e[58:5:114m | - | sp=0x87D787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_115 | \e[58:5:115m | - | sp=0x87D7AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_116 | \e[58:5:116m | - | sp=0x87D7D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_117 | \e[58:5:117m | - | sp=0x87D7FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_118 | \e[58:5:118m | - | sp=0x87FF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_119 | \e[58:5:119m | - | sp=0x87FF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_120 | \e[58:5:120m | - | sp=0x87FF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_121 | \e[58:5:121m | - | sp=0x87FFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_122 | \e[58:5:122m | - | sp=0x87FFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_123 | \e[58:5:123m | - | sp=0x87FFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_124 | \e[58:5:124m | - | sp=0xAF0000 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_125 | \e[58:5:125m | - | sp=0xAF005F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_126 | \e[58:5:126m | - | sp=0xAF0087 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_127 | \e[58:5:127m | - | sp=0xAF00AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_128 | \e[58:5:128m | - | sp=0xAF00D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_129 | \e[58:5:129m | - | sp=0xAF00FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_130 | \e[58:5:130m | - | sp=0xAF5F00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_131 | \e[58:5:131m | - | sp=0xAF5F5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_132 | \e[58:5:132m | - | sp=0xAF5F87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_133 | \e[58:5:133m | - | sp=0xAF5FAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_134 | \e[58:5:134m | - | sp=0xAF5FD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_135 | \e[58:5:135m | - | sp=0xAF5FFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_136 | \e[58:5:136m | - | sp=0xAF8700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_137 | \e[58:5:137m | - | sp=0xAF875F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_138 | \e[58:5:138m | - | sp=0xAF8787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_139 | \e[58:5:139m | - | sp=0xAF87AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_140 | \e[58:5:140m | - | sp=0xAF87D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_141 | \e[58:5:141m | - | sp=0xAF87FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_142 | \e[58:5:142m | - | sp=0xAFAF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_143 | \e[58:5:143m | - | sp=0xAFAF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_144 | \e[58:5:144m | - | sp=0xAFAF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_145 | \e[58:5:145m | - | sp=0xAFAFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_146 | \e[58:5:146m | - | sp=0xAFAFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_147 | \e[58:5:147m | - | sp=0xAFAFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_148 | \e[58:5:148m | - | sp=0xAFD700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_149 | \e[58:5:149m | - | sp=0xAFD75F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_150 | \e[58:5:150m | - | sp=0xAFD787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_151 | \e[58:5:151m | - | sp=0xAFD7AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_152 | \e[58:5:152m | - | sp=0xAFD7D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_153 | \e[58:5:153m | - | sp=0xAFD7FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_154 | \e[58:5:154m | - | sp=0xAFFF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_155 | \e[58:5:155m | - | sp=0xAFFF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_156 | \e[58:5:156m | - | sp=0xAFFF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_157 | \e[58:5:157m | - | sp=0xAFFFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_158 | \e[58:5:158m | - | sp=0xAFFFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_159 | \e[58:5:159m | - | sp=0xAFFFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_160 | \e[58:5:160m | - | sp=0xD70000 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_161 | \e[58:5:161m | - | sp=0xD7005F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_162 | \e[58:5:162m | - | sp=0xD70087 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_163 | \e[58:5:163m | - | sp=0xD700AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_164 | \e[58:5:164m | - | sp=0xD700D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_165 | \e[58:5:165m | - | sp=0xD700FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_166 | \e[58:5:166m | - | sp=0xD75F00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_167 | \e[58:5:167m | - | sp=0xD75F5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_168 | \e[58:5:168m | - | sp=0xD75F87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_169 | \e[58:5:169m | - | sp=0xD75FAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_170 | \e[58:5:170m | - | sp=0xD75FD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_171 | \e[58:5:171m | - | sp=0xD75FFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_172 | \e[58:5:172m | - | sp=0xD78700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_173 | \e[58:5:173m | - | sp=0xD7875F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_174 | \e[58:5:174m | - | sp=0xD78787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_175 | \e[58:5:175m | - | sp=0xD787AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_176 | \e[58:5:176m | - | sp=0xD787D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_177 | \e[58:5:177m | - | sp=0xD787FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_178 | \e[58:5:178m | - | sp=0xD7AF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_179 | \e[58:5:179m | - | sp=0xD7AF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_180 | \e[58:5:180m | - | sp=0xD7AF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_181 | \e[58:5:181m | - | sp=0xD7AFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_182 | \e[58:5:182m | - | sp=0xD7AFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_183 | \e[58:5:183m | - | sp=0xD7AFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_184 | \e[58:5:184m | - | sp=0xD7D700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_185 | \e[58:5:185m | - | sp=0xD7D75F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_186 | \e[58:5:186m | - | sp=0xD7D787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_187 | \e[58:5:187m | - | sp=0xD7D7AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_188 | \e[58:5:188m | - | sp=0xD7D7D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_189 | \e[58:5:189m | - | sp=0xD7D7FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_190 | \e[58:5:190m | - | sp=0xD7FF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_191 | \e[58:5:191m | - | sp=0xD7FF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_192 | \e[58:5:192m | - | sp=0xD7FF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_193 | \e[58:5:193m | - | sp=0xD7FFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_194 | \e[58:5:194m | - | sp=0xD7FFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_195 | \e[58:5:195m | - | sp=0xD7FFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_196 | \e[58:5:196m | - | sp=0xFF0000 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_197 | \e[58:5:197m | - | sp=0xFF005F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_198 | \e[58:5:198m | - | sp=0xFF0087 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_199 | \e[58:5:199m | - | sp=0xFF00AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_200 | \e[58:5:200m | - | sp=0xFF00D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_201 | \e[58:5:201m | - | sp=0xFF00FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_202 | \e[58:5:202m | - | sp=0xFF5F00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_203 | \e[58:5:203m | - | sp=0xFF5F5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_204 | \e[58:5:204m | - | sp=0xFF5F87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_205 | \e[58:5:205m | - | sp=0xFF5FAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_206 | \e[58:5:206m | - | sp=0xFF5FD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_207 | \e[58:5:207m | - | sp=0xFF5FFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_208 | \e[58:5:208m | - | sp=0xFF8700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_209 | \e[58:5:209m | - | sp=0xFF875F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_210 | \e[58:5:210m | - | sp=0xFF8787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_211 | \e[58:5:211m | - | sp=0xFF87AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_212 | \e[58:5:212m | - | sp=0xFF87D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_213 | \e[58:5:213m | - | sp=0xFF87FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_214 | \e[58:5:214m | - | sp=0xFFAF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_215 | \e[58:5:215m | - | sp=0xFFAF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_216 | \e[58:5:216m | - | sp=0xFFAF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_217 | \e[58:5:217m | - | sp=0xFFAFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_218 | \e[58:5:218m | - | sp=0xFFAFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_219 | \e[58:5:219m | - | sp=0xFFAFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_220 | \e[58:5:220m | - | sp=0xFFD700 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_221 | \e[58:5:221m | - | sp=0xFFD75F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_222 | \e[58:5:222m | - | sp=0xFFD787 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_223 | \e[58:5:223m | - | sp=0xFFD7AF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_224 | \e[58:5:224m | - | sp=0xFFD7D7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_225 | \e[58:5:225m | - | sp=0xFFD7FF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_226 | \e[58:5:226m | - | sp=0xFFFF00 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_227 | \e[58:5:227m | - | sp=0xFFFF5F | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_228 | \e[58:5:228m | - | sp=0xFFFF87 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_229 | \e[58:5:229m | - | sp=0xFFFFAF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_230 | \e[58:5:230m | - | sp=0xFFFFD7 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_231 | \e[58:5:231m | - | sp=0xFFFFFF | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_232 | \e[58:5:232m | - | sp=0x080808 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_233 | \e[58:5:233m | - | sp=0x121212 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_234 | \e[58:5:234m | - | sp=0x1C1C1C | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_235 | \e[58:5:235m | - | sp=0x262626 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_236 | \e[58:5:236m | - | sp=0x303030 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_237 | \e[58:5:237m | - | sp=0x3A3A3A | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_238 | \e[58:5:238m | - | sp=0x444444 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_239 | \e[58:5:239m | - | sp=0x4E4E4E | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_240 | \e[58:5:240m | - | sp=0x585858 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_241 | \e[58:5:241m | - | sp=0x626262 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_242 | \e[58:5:242m | - | sp=0x6C6C6C | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_243 | \e[58:5:243m | - | sp=0x767676 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_244 | \e[58:5:244m | - | sp=0x808080 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_245 | \e[58:5:245m | - | sp=0x8A8A8A | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_246 | \e[58:5:246m | - | sp=0x949494 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_247 | \e[58:5:247m | - | sp=0x9E9E9E | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_248 | \e[58:5:248m | - | sp=0xA8A8A8 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_249 | \e[58:5:249m | - | sp=0xB2B2B2 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_250 | \e[58:5:250m | - | sp=0xBCBCBC | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_251 | \e[58:5:251m | - | sp=0xC6C6C6 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_252 | \e[58:5:252m | - | sp=0xD0D0D0 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_253 | \e[58:5:253m | - | sp=0xDADADA | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_254 | \e[58:5:254m | - | sp=0xE4E4E4 | 0 | 11 | T.416 indexed underline palette
sgr | colon_index_sp_255 | \e[58:5:255m | - | sp=0xEEEEEE | 0 | 11 | T.416 indexed underline palette

## sgr xterm RGB
sgr | rgb_black | \e[38;2;0;0;0m | - | fg=0x000000 | 0 | 13 | zero channels
sgr | rgb_white | \e[38;2;255;255;255m | - | fg=0xFFFFFF | 0 | 19 | maximum channels
sgr | rgb_red | \e[38;2;255;0;0m | - | fg=0xFF0000 | 0 | 15 | red boundary
sgr | rgb_green | \e[38;2;0;255;0m | - | fg=0x00FF00 | 0 | 15 | green boundary
sgr | rgb_blue | \e[38;2;0;0;255m | - | fg=0x0000FF | 0 | 15 | blue boundary
sgr | rgb_yellow | \e[38;2;255;255;0m | - | fg=0xFFFF00 | 0 | 17 | red + green
sgr | rgb_magenta | \e[38;2;255;0;255m | - | fg=0xFF00FF | 0 | 17 | red + blue
sgr | rgb_cyan | \e[38;2;0;255;255m | - | fg=0x00FFFF | 0 | 17 | green + blue
sgr | rgb_arbitrary | \e[38;2;1;2;3m | - | fg=0x010203 | 0 | 13 | channel order
sgr | rgb_mixed | \e[38;2;128;64;192m | - | fg=0x8040C0 | 0 | 18 | mixed channels
sgr | rgb_attr_before | \e[1;38;2;35;17;41m | - | fg=0x231129 | 0 | 18 | attribute before truecolor
sgr | rgb_attr_after | \e[38;2;253;200;15;6m | - | fg=0xFDC80F | 0 | 20 | attribute after truecolor
sgr | rgb_bg_black | \e[48;2;0;0;0m | - | bg=0x000000 | 0 | 13 | background zero
sgr | rgb_bg_orange | \e[48;2;255;165;0m | - | bg=0xFFA500 | 0 | 17 | background orange
sgr | rgb_bg_after_fg | \e[31;48;2;6;197;164m | - | fg=0xCD0000,bg=0x06C5A4 | 0 | 20 | background after ANSI fg
sgr | rgb_sp_arbitrary | \e[58;2;1;2;3m | - | sp=0x010203 | 0 | 13 | underline channel order
sgr | rgb_sp_mixed | \e[58;2;81;155;120m | - | sp=0x519B78 | 0 | 18 | underline mixed
sgr | rgb_grid_0_0_0 | \e[38;2;0;0;0m | - | fg=0x000000 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_0 | \e[48;2;0;0;0m | - | bg=0x000000 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_0 | \e[58;2;0;0;0m | - | sp=0x000000 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_0 | \e[38:2::0:0:0m | - | fg=0x000000 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_0 | \e[48:2::0:0:0m | - | bg=0x000000 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_0 | \e[58:2::0:0:0m | - | sp=0x000000 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_0_1 | \e[38;2;0;0;1m | - | fg=0x000001 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_1 | \e[48;2;0;0;1m | - | bg=0x000001 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_1 | \e[58;2;0;0;1m | - | sp=0x000001 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_1 | \e[38:2::0:0:1m | - | fg=0x000001 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_1 | \e[48:2::0:0:1m | - | bg=0x000001 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_1 | \e[58:2::0:0:1m | - | sp=0x000001 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_0_127 | \e[38;2;0;0;127m | - | fg=0x00007F | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_127 | \e[48;2;0;0;127m | - | bg=0x00007F | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_127 | \e[58;2;0;0;127m | - | sp=0x00007F | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_127 | \e[38:2::0:0:127m | - | fg=0x00007F | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_127 | \e[48:2::0:0:127m | - | bg=0x00007F | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_127 | \e[58:2::0:0:127m | - | sp=0x00007F | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_0_128 | \e[38;2;0;0;128m | - | fg=0x000080 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_128 | \e[48;2;0;0;128m | - | bg=0x000080 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_128 | \e[58;2;0;0;128m | - | sp=0x000080 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_128 | \e[38:2::0:0:128m | - | fg=0x000080 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_128 | \e[48:2::0:0:128m | - | bg=0x000080 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_128 | \e[58:2::0:0:128m | - | sp=0x000080 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_0_254 | \e[38;2;0;0;254m | - | fg=0x0000FE | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_254 | \e[48;2;0;0;254m | - | bg=0x0000FE | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_254 | \e[58;2;0;0;254m | - | sp=0x0000FE | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_254 | \e[38:2::0:0:254m | - | fg=0x0000FE | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_254 | \e[48:2::0:0:254m | - | bg=0x0000FE | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_254 | \e[58:2::0:0:254m | - | sp=0x0000FE | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_0_255 | \e[38;2;0;0;255m | - | fg=0x0000FF | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_0_255 | \e[48;2;0;0;255m | - | bg=0x0000FF | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_0_255 | \e[58;2;0;0;255m | - | sp=0x0000FF | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_0_255 | \e[38:2::0:0:255m | - | fg=0x0000FF | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_0_255 | \e[48:2::0:0:255m | - | bg=0x0000FF | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_0_255 | \e[58:2::0:0:255m | - | sp=0x0000FF | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_0 | \e[38;2;0;1;0m | - | fg=0x000100 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_0 | \e[48;2;0;1;0m | - | bg=0x000100 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_0 | \e[58;2;0;1;0m | - | sp=0x000100 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_0 | \e[38:2::0:1:0m | - | fg=0x000100 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_0 | \e[48:2::0:1:0m | - | bg=0x000100 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_0 | \e[58:2::0:1:0m | - | sp=0x000100 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_1 | \e[38;2;0;1;1m | - | fg=0x000101 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_1 | \e[48;2;0;1;1m | - | bg=0x000101 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_1 | \e[58;2;0;1;1m | - | sp=0x000101 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_1 | \e[38:2::0:1:1m | - | fg=0x000101 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_1 | \e[48:2::0:1:1m | - | bg=0x000101 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_1 | \e[58:2::0:1:1m | - | sp=0x000101 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_127 | \e[38;2;0;1;127m | - | fg=0x00017F | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_127 | \e[48;2;0;1;127m | - | bg=0x00017F | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_127 | \e[58;2;0;1;127m | - | sp=0x00017F | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_127 | \e[38:2::0:1:127m | - | fg=0x00017F | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_127 | \e[48:2::0:1:127m | - | bg=0x00017F | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_127 | \e[58:2::0:1:127m | - | sp=0x00017F | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_128 | \e[38;2;0;1;128m | - | fg=0x000180 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_128 | \e[48;2;0;1;128m | - | bg=0x000180 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_128 | \e[58;2;0;1;128m | - | sp=0x000180 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_128 | \e[38:2::0:1:128m | - | fg=0x000180 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_128 | \e[48:2::0:1:128m | - | bg=0x000180 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_128 | \e[58:2::0:1:128m | - | sp=0x000180 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_254 | \e[38;2;0;1;254m | - | fg=0x0001FE | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_254 | \e[48;2;0;1;254m | - | bg=0x0001FE | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_254 | \e[58;2;0;1;254m | - | sp=0x0001FE | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_254 | \e[38:2::0:1:254m | - | fg=0x0001FE | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_254 | \e[48:2::0:1:254m | - | bg=0x0001FE | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_254 | \e[58:2::0:1:254m | - | sp=0x0001FE | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_1_255 | \e[38;2;0;1;255m | - | fg=0x0001FF | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_1_255 | \e[48;2;0;1;255m | - | bg=0x0001FF | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_1_255 | \e[58;2;0;1;255m | - | sp=0x0001FF | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_1_255 | \e[38:2::0:1:255m | - | fg=0x0001FF | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_1_255 | \e[48:2::0:1:255m | - | bg=0x0001FF | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_1_255 | \e[58:2::0:1:255m | - | sp=0x0001FF | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_0 | \e[38;2;0;127;0m | - | fg=0x007F00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_0 | \e[48;2;0;127;0m | - | bg=0x007F00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_0 | \e[58;2;0;127;0m | - | sp=0x007F00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_0 | \e[38:2::0:127:0m | - | fg=0x007F00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_0 | \e[48:2::0:127:0m | - | bg=0x007F00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_0 | \e[58:2::0:127:0m | - | sp=0x007F00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_1 | \e[38;2;0;127;1m | - | fg=0x007F01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_1 | \e[48;2;0;127;1m | - | bg=0x007F01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_1 | \e[58;2;0;127;1m | - | sp=0x007F01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_1 | \e[38:2::0:127:1m | - | fg=0x007F01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_1 | \e[48:2::0:127:1m | - | bg=0x007F01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_1 | \e[58:2::0:127:1m | - | sp=0x007F01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_127 | \e[38;2;0;127;127m | - | fg=0x007F7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_127 | \e[48;2;0;127;127m | - | bg=0x007F7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_127 | \e[58;2;0;127;127m | - | sp=0x007F7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_127 | \e[38:2::0:127:127m | - | fg=0x007F7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_127 | \e[48:2::0:127:127m | - | bg=0x007F7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_127 | \e[58:2::0:127:127m | - | sp=0x007F7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_128 | \e[38;2;0;127;128m | - | fg=0x007F80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_128 | \e[48;2;0;127;128m | - | bg=0x007F80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_128 | \e[58;2;0;127;128m | - | sp=0x007F80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_128 | \e[38:2::0:127:128m | - | fg=0x007F80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_128 | \e[48:2::0:127:128m | - | bg=0x007F80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_128 | \e[58:2::0:127:128m | - | sp=0x007F80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_254 | \e[38;2;0;127;254m | - | fg=0x007FFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_254 | \e[48;2;0;127;254m | - | bg=0x007FFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_254 | \e[58;2;0;127;254m | - | sp=0x007FFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_254 | \e[38:2::0:127:254m | - | fg=0x007FFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_254 | \e[48:2::0:127:254m | - | bg=0x007FFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_254 | \e[58:2::0:127:254m | - | sp=0x007FFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_127_255 | \e[38;2;0;127;255m | - | fg=0x007FFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_127_255 | \e[48;2;0;127;255m | - | bg=0x007FFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_127_255 | \e[58;2;0;127;255m | - | sp=0x007FFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_127_255 | \e[38:2::0:127:255m | - | fg=0x007FFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_127_255 | \e[48:2::0:127:255m | - | bg=0x007FFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_127_255 | \e[58:2::0:127:255m | - | sp=0x007FFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_0 | \e[38;2;0;128;0m | - | fg=0x008000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_0 | \e[48;2;0;128;0m | - | bg=0x008000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_0 | \e[58;2;0;128;0m | - | sp=0x008000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_0 | \e[38:2::0:128:0m | - | fg=0x008000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_0 | \e[48:2::0:128:0m | - | bg=0x008000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_0 | \e[58:2::0:128:0m | - | sp=0x008000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_1 | \e[38;2;0;128;1m | - | fg=0x008001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_1 | \e[48;2;0;128;1m | - | bg=0x008001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_1 | \e[58;2;0;128;1m | - | sp=0x008001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_1 | \e[38:2::0:128:1m | - | fg=0x008001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_1 | \e[48:2::0:128:1m | - | bg=0x008001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_1 | \e[58:2::0:128:1m | - | sp=0x008001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_127 | \e[38;2;0;128;127m | - | fg=0x00807F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_127 | \e[48;2;0;128;127m | - | bg=0x00807F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_127 | \e[58;2;0;128;127m | - | sp=0x00807F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_127 | \e[38:2::0:128:127m | - | fg=0x00807F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_127 | \e[48:2::0:128:127m | - | bg=0x00807F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_127 | \e[58:2::0:128:127m | - | sp=0x00807F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_128 | \e[38;2;0;128;128m | - | fg=0x008080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_128 | \e[48;2;0;128;128m | - | bg=0x008080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_128 | \e[58;2;0;128;128m | - | sp=0x008080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_128 | \e[38:2::0:128:128m | - | fg=0x008080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_128 | \e[48:2::0:128:128m | - | bg=0x008080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_128 | \e[58:2::0:128:128m | - | sp=0x008080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_254 | \e[38;2;0;128;254m | - | fg=0x0080FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_254 | \e[48;2;0;128;254m | - | bg=0x0080FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_254 | \e[58;2;0;128;254m | - | sp=0x0080FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_254 | \e[38:2::0:128:254m | - | fg=0x0080FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_254 | \e[48:2::0:128:254m | - | bg=0x0080FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_254 | \e[58:2::0:128:254m | - | sp=0x0080FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_128_255 | \e[38;2;0;128;255m | - | fg=0x0080FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_128_255 | \e[48;2;0;128;255m | - | bg=0x0080FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_128_255 | \e[58;2;0;128;255m | - | sp=0x0080FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_128_255 | \e[38:2::0:128:255m | - | fg=0x0080FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_128_255 | \e[48:2::0:128:255m | - | bg=0x0080FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_128_255 | \e[58:2::0:128:255m | - | sp=0x0080FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_0 | \e[38;2;0;254;0m | - | fg=0x00FE00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_0 | \e[48;2;0;254;0m | - | bg=0x00FE00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_0 | \e[58;2;0;254;0m | - | sp=0x00FE00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_0 | \e[38:2::0:254:0m | - | fg=0x00FE00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_0 | \e[48:2::0:254:0m | - | bg=0x00FE00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_0 | \e[58:2::0:254:0m | - | sp=0x00FE00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_1 | \e[38;2;0;254;1m | - | fg=0x00FE01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_1 | \e[48;2;0;254;1m | - | bg=0x00FE01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_1 | \e[58;2;0;254;1m | - | sp=0x00FE01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_1 | \e[38:2::0:254:1m | - | fg=0x00FE01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_1 | \e[48:2::0:254:1m | - | bg=0x00FE01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_1 | \e[58:2::0:254:1m | - | sp=0x00FE01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_127 | \e[38;2;0;254;127m | - | fg=0x00FE7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_127 | \e[48;2;0;254;127m | - | bg=0x00FE7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_127 | \e[58;2;0;254;127m | - | sp=0x00FE7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_127 | \e[38:2::0:254:127m | - | fg=0x00FE7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_127 | \e[48:2::0:254:127m | - | bg=0x00FE7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_127 | \e[58:2::0:254:127m | - | sp=0x00FE7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_128 | \e[38;2;0;254;128m | - | fg=0x00FE80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_128 | \e[48;2;0;254;128m | - | bg=0x00FE80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_128 | \e[58;2;0;254;128m | - | sp=0x00FE80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_128 | \e[38:2::0:254:128m | - | fg=0x00FE80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_128 | \e[48:2::0:254:128m | - | bg=0x00FE80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_128 | \e[58:2::0:254:128m | - | sp=0x00FE80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_254 | \e[38;2;0;254;254m | - | fg=0x00FEFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_254 | \e[48;2;0;254;254m | - | bg=0x00FEFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_254 | \e[58;2;0;254;254m | - | sp=0x00FEFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_254 | \e[38:2::0:254:254m | - | fg=0x00FEFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_254 | \e[48:2::0:254:254m | - | bg=0x00FEFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_254 | \e[58:2::0:254:254m | - | sp=0x00FEFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_254_255 | \e[38;2;0;254;255m | - | fg=0x00FEFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_254_255 | \e[48;2;0;254;255m | - | bg=0x00FEFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_254_255 | \e[58;2;0;254;255m | - | sp=0x00FEFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_254_255 | \e[38:2::0:254:255m | - | fg=0x00FEFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_254_255 | \e[48:2::0:254:255m | - | bg=0x00FEFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_254_255 | \e[58:2::0:254:255m | - | sp=0x00FEFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_0 | \e[38;2;0;255;0m | - | fg=0x00FF00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_0 | \e[48;2;0;255;0m | - | bg=0x00FF00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_0 | \e[58;2;0;255;0m | - | sp=0x00FF00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_0 | \e[38:2::0:255:0m | - | fg=0x00FF00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_0 | \e[48:2::0:255:0m | - | bg=0x00FF00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_0 | \e[58:2::0:255:0m | - | sp=0x00FF00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_1 | \e[38;2;0;255;1m | - | fg=0x00FF01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_1 | \e[48;2;0;255;1m | - | bg=0x00FF01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_1 | \e[58;2;0;255;1m | - | sp=0x00FF01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_1 | \e[38:2::0:255:1m | - | fg=0x00FF01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_1 | \e[48:2::0:255:1m | - | bg=0x00FF01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_1 | \e[58:2::0:255:1m | - | sp=0x00FF01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_127 | \e[38;2;0;255;127m | - | fg=0x00FF7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_127 | \e[48;2;0;255;127m | - | bg=0x00FF7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_127 | \e[58;2;0;255;127m | - | sp=0x00FF7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_127 | \e[38:2::0:255:127m | - | fg=0x00FF7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_127 | \e[48:2::0:255:127m | - | bg=0x00FF7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_127 | \e[58:2::0:255:127m | - | sp=0x00FF7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_128 | \e[38;2;0;255;128m | - | fg=0x00FF80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_128 | \e[48;2;0;255;128m | - | bg=0x00FF80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_128 | \e[58;2;0;255;128m | - | sp=0x00FF80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_128 | \e[38:2::0:255:128m | - | fg=0x00FF80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_128 | \e[48:2::0:255:128m | - | bg=0x00FF80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_128 | \e[58:2::0:255:128m | - | sp=0x00FF80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_254 | \e[38;2;0;255;254m | - | fg=0x00FFFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_254 | \e[48;2;0;255;254m | - | bg=0x00FFFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_254 | \e[58;2;0;255;254m | - | sp=0x00FFFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_254 | \e[38:2::0:255:254m | - | fg=0x00FFFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_254 | \e[48:2::0:255:254m | - | bg=0x00FFFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_254 | \e[58:2::0:255:254m | - | sp=0x00FFFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_0_255_255 | \e[38;2;0;255;255m | - | fg=0x00FFFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_0_255_255 | \e[48;2;0;255;255m | - | bg=0x00FFFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_0_255_255 | \e[58;2;0;255;255m | - | sp=0x00FFFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_0_255_255 | \e[38:2::0:255:255m | - | fg=0x00FFFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_0_255_255 | \e[48:2::0:255:255m | - | bg=0x00FFFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_0_255_255 | \e[58:2::0:255:255m | - | sp=0x00FFFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_0 | \e[38;2;1;0;0m | - | fg=0x010000 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_0 | \e[48;2;1;0;0m | - | bg=0x010000 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_0 | \e[58;2;1;0;0m | - | sp=0x010000 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_0 | \e[38:2::1:0:0m | - | fg=0x010000 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_0 | \e[48:2::1:0:0m | - | bg=0x010000 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_0 | \e[58:2::1:0:0m | - | sp=0x010000 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_1 | \e[38;2;1;0;1m | - | fg=0x010001 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_1 | \e[48;2;1;0;1m | - | bg=0x010001 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_1 | \e[58;2;1;0;1m | - | sp=0x010001 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_1 | \e[38:2::1:0:1m | - | fg=0x010001 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_1 | \e[48:2::1:0:1m | - | bg=0x010001 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_1 | \e[58:2::1:0:1m | - | sp=0x010001 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_127 | \e[38;2;1;0;127m | - | fg=0x01007F | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_127 | \e[48;2;1;0;127m | - | bg=0x01007F | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_127 | \e[58;2;1;0;127m | - | sp=0x01007F | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_127 | \e[38:2::1:0:127m | - | fg=0x01007F | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_127 | \e[48:2::1:0:127m | - | bg=0x01007F | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_127 | \e[58:2::1:0:127m | - | sp=0x01007F | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_128 | \e[38;2;1;0;128m | - | fg=0x010080 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_128 | \e[48;2;1;0;128m | - | bg=0x010080 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_128 | \e[58;2;1;0;128m | - | sp=0x010080 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_128 | \e[38:2::1:0:128m | - | fg=0x010080 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_128 | \e[48:2::1:0:128m | - | bg=0x010080 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_128 | \e[58:2::1:0:128m | - | sp=0x010080 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_254 | \e[38;2;1;0;254m | - | fg=0x0100FE | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_254 | \e[48;2;1;0;254m | - | bg=0x0100FE | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_254 | \e[58;2;1;0;254m | - | sp=0x0100FE | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_254 | \e[38:2::1:0:254m | - | fg=0x0100FE | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_254 | \e[48:2::1:0:254m | - | bg=0x0100FE | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_254 | \e[58:2::1:0:254m | - | sp=0x0100FE | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_0_255 | \e[38;2;1;0;255m | - | fg=0x0100FF | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_0_255 | \e[48;2;1;0;255m | - | bg=0x0100FF | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_0_255 | \e[58;2;1;0;255m | - | sp=0x0100FF | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_0_255 | \e[38:2::1:0:255m | - | fg=0x0100FF | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_0_255 | \e[48:2::1:0:255m | - | bg=0x0100FF | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_0_255 | \e[58:2::1:0:255m | - | sp=0x0100FF | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_0 | \e[38;2;1;1;0m | - | fg=0x010100 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_0 | \e[48;2;1;1;0m | - | bg=0x010100 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_0 | \e[58;2;1;1;0m | - | sp=0x010100 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_0 | \e[38:2::1:1:0m | - | fg=0x010100 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_0 | \e[48:2::1:1:0m | - | bg=0x010100 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_0 | \e[58:2::1:1:0m | - | sp=0x010100 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_1 | \e[38;2;1;1;1m | - | fg=0x010101 | 0 | 13 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_1 | \e[48;2;1;1;1m | - | bg=0x010101 | 0 | 13 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_1 | \e[58;2;1;1;1m | - | sp=0x010101 | 0 | 13 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_1 | \e[38:2::1:1:1m | - | fg=0x010101 | 0 | 14 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_1 | \e[48:2::1:1:1m | - | bg=0x010101 | 0 | 14 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_1 | \e[58:2::1:1:1m | - | sp=0x010101 | 0 | 14 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_127 | \e[38;2;1;1;127m | - | fg=0x01017F | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_127 | \e[48;2;1;1;127m | - | bg=0x01017F | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_127 | \e[58;2;1;1;127m | - | sp=0x01017F | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_127 | \e[38:2::1:1:127m | - | fg=0x01017F | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_127 | \e[48:2::1:1:127m | - | bg=0x01017F | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_127 | \e[58:2::1:1:127m | - | sp=0x01017F | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_128 | \e[38;2;1;1;128m | - | fg=0x010180 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_128 | \e[48;2;1;1;128m | - | bg=0x010180 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_128 | \e[58;2;1;1;128m | - | sp=0x010180 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_128 | \e[38:2::1:1:128m | - | fg=0x010180 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_128 | \e[48:2::1:1:128m | - | bg=0x010180 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_128 | \e[58:2::1:1:128m | - | sp=0x010180 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_254 | \e[38;2;1;1;254m | - | fg=0x0101FE | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_254 | \e[48;2;1;1;254m | - | bg=0x0101FE | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_254 | \e[58;2;1;1;254m | - | sp=0x0101FE | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_254 | \e[38:2::1:1:254m | - | fg=0x0101FE | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_254 | \e[48:2::1:1:254m | - | bg=0x0101FE | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_254 | \e[58:2::1:1:254m | - | sp=0x0101FE | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_1_255 | \e[38;2;1;1;255m | - | fg=0x0101FF | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_1_255 | \e[48;2;1;1;255m | - | bg=0x0101FF | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_1_255 | \e[58;2;1;1;255m | - | sp=0x0101FF | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_1_255 | \e[38:2::1:1:255m | - | fg=0x0101FF | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_1_255 | \e[48:2::1:1:255m | - | bg=0x0101FF | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_1_255 | \e[58:2::1:1:255m | - | sp=0x0101FF | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_0 | \e[38;2;1;127;0m | - | fg=0x017F00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_0 | \e[48;2;1;127;0m | - | bg=0x017F00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_0 | \e[58;2;1;127;0m | - | sp=0x017F00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_0 | \e[38:2::1:127:0m | - | fg=0x017F00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_0 | \e[48:2::1:127:0m | - | bg=0x017F00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_0 | \e[58:2::1:127:0m | - | sp=0x017F00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_1 | \e[38;2;1;127;1m | - | fg=0x017F01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_1 | \e[48;2;1;127;1m | - | bg=0x017F01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_1 | \e[58;2;1;127;1m | - | sp=0x017F01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_1 | \e[38:2::1:127:1m | - | fg=0x017F01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_1 | \e[48:2::1:127:1m | - | bg=0x017F01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_1 | \e[58:2::1:127:1m | - | sp=0x017F01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_127 | \e[38;2;1;127;127m | - | fg=0x017F7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_127 | \e[48;2;1;127;127m | - | bg=0x017F7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_127 | \e[58;2;1;127;127m | - | sp=0x017F7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_127 | \e[38:2::1:127:127m | - | fg=0x017F7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_127 | \e[48:2::1:127:127m | - | bg=0x017F7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_127 | \e[58:2::1:127:127m | - | sp=0x017F7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_128 | \e[38;2;1;127;128m | - | fg=0x017F80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_128 | \e[48;2;1;127;128m | - | bg=0x017F80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_128 | \e[58;2;1;127;128m | - | sp=0x017F80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_128 | \e[38:2::1:127:128m | - | fg=0x017F80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_128 | \e[48:2::1:127:128m | - | bg=0x017F80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_128 | \e[58:2::1:127:128m | - | sp=0x017F80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_254 | \e[38;2;1;127;254m | - | fg=0x017FFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_254 | \e[48;2;1;127;254m | - | bg=0x017FFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_254 | \e[58;2;1;127;254m | - | sp=0x017FFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_254 | \e[38:2::1:127:254m | - | fg=0x017FFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_254 | \e[48:2::1:127:254m | - | bg=0x017FFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_254 | \e[58:2::1:127:254m | - | sp=0x017FFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_127_255 | \e[38;2;1;127;255m | - | fg=0x017FFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_127_255 | \e[48;2;1;127;255m | - | bg=0x017FFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_127_255 | \e[58;2;1;127;255m | - | sp=0x017FFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_127_255 | \e[38:2::1:127:255m | - | fg=0x017FFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_127_255 | \e[48:2::1:127:255m | - | bg=0x017FFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_127_255 | \e[58:2::1:127:255m | - | sp=0x017FFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_0 | \e[38;2;1;128;0m | - | fg=0x018000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_0 | \e[48;2;1;128;0m | - | bg=0x018000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_0 | \e[58;2;1;128;0m | - | sp=0x018000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_0 | \e[38:2::1:128:0m | - | fg=0x018000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_0 | \e[48:2::1:128:0m | - | bg=0x018000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_0 | \e[58:2::1:128:0m | - | sp=0x018000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_1 | \e[38;2;1;128;1m | - | fg=0x018001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_1 | \e[48;2;1;128;1m | - | bg=0x018001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_1 | \e[58;2;1;128;1m | - | sp=0x018001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_1 | \e[38:2::1:128:1m | - | fg=0x018001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_1 | \e[48:2::1:128:1m | - | bg=0x018001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_1 | \e[58:2::1:128:1m | - | sp=0x018001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_127 | \e[38;2;1;128;127m | - | fg=0x01807F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_127 | \e[48;2;1;128;127m | - | bg=0x01807F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_127 | \e[58;2;1;128;127m | - | sp=0x01807F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_127 | \e[38:2::1:128:127m | - | fg=0x01807F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_127 | \e[48:2::1:128:127m | - | bg=0x01807F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_127 | \e[58:2::1:128:127m | - | sp=0x01807F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_128 | \e[38;2;1;128;128m | - | fg=0x018080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_128 | \e[48;2;1;128;128m | - | bg=0x018080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_128 | \e[58;2;1;128;128m | - | sp=0x018080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_128 | \e[38:2::1:128:128m | - | fg=0x018080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_128 | \e[48:2::1:128:128m | - | bg=0x018080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_128 | \e[58:2::1:128:128m | - | sp=0x018080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_254 | \e[38;2;1;128;254m | - | fg=0x0180FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_254 | \e[48;2;1;128;254m | - | bg=0x0180FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_254 | \e[58;2;1;128;254m | - | sp=0x0180FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_254 | \e[38:2::1:128:254m | - | fg=0x0180FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_254 | \e[48:2::1:128:254m | - | bg=0x0180FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_254 | \e[58:2::1:128:254m | - | sp=0x0180FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_128_255 | \e[38;2;1;128;255m | - | fg=0x0180FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_128_255 | \e[48;2;1;128;255m | - | bg=0x0180FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_128_255 | \e[58;2;1;128;255m | - | sp=0x0180FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_128_255 | \e[38:2::1:128:255m | - | fg=0x0180FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_128_255 | \e[48:2::1:128:255m | - | bg=0x0180FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_128_255 | \e[58:2::1:128:255m | - | sp=0x0180FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_0 | \e[38;2;1;254;0m | - | fg=0x01FE00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_0 | \e[48;2;1;254;0m | - | bg=0x01FE00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_0 | \e[58;2;1;254;0m | - | sp=0x01FE00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_0 | \e[38:2::1:254:0m | - | fg=0x01FE00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_0 | \e[48:2::1:254:0m | - | bg=0x01FE00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_0 | \e[58:2::1:254:0m | - | sp=0x01FE00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_1 | \e[38;2;1;254;1m | - | fg=0x01FE01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_1 | \e[48;2;1;254;1m | - | bg=0x01FE01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_1 | \e[58;2;1;254;1m | - | sp=0x01FE01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_1 | \e[38:2::1:254:1m | - | fg=0x01FE01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_1 | \e[48:2::1:254:1m | - | bg=0x01FE01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_1 | \e[58:2::1:254:1m | - | sp=0x01FE01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_127 | \e[38;2;1;254;127m | - | fg=0x01FE7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_127 | \e[48;2;1;254;127m | - | bg=0x01FE7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_127 | \e[58;2;1;254;127m | - | sp=0x01FE7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_127 | \e[38:2::1:254:127m | - | fg=0x01FE7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_127 | \e[48:2::1:254:127m | - | bg=0x01FE7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_127 | \e[58:2::1:254:127m | - | sp=0x01FE7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_128 | \e[38;2;1;254;128m | - | fg=0x01FE80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_128 | \e[48;2;1;254;128m | - | bg=0x01FE80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_128 | \e[58;2;1;254;128m | - | sp=0x01FE80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_128 | \e[38:2::1:254:128m | - | fg=0x01FE80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_128 | \e[48:2::1:254:128m | - | bg=0x01FE80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_128 | \e[58:2::1:254:128m | - | sp=0x01FE80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_254 | \e[38;2;1;254;254m | - | fg=0x01FEFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_254 | \e[48;2;1;254;254m | - | bg=0x01FEFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_254 | \e[58;2;1;254;254m | - | sp=0x01FEFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_254 | \e[38:2::1:254:254m | - | fg=0x01FEFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_254 | \e[48:2::1:254:254m | - | bg=0x01FEFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_254 | \e[58:2::1:254:254m | - | sp=0x01FEFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_254_255 | \e[38;2;1;254;255m | - | fg=0x01FEFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_254_255 | \e[48;2;1;254;255m | - | bg=0x01FEFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_254_255 | \e[58;2;1;254;255m | - | sp=0x01FEFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_254_255 | \e[38:2::1:254:255m | - | fg=0x01FEFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_254_255 | \e[48:2::1:254:255m | - | bg=0x01FEFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_254_255 | \e[58:2::1:254:255m | - | sp=0x01FEFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_0 | \e[38;2;1;255;0m | - | fg=0x01FF00 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_0 | \e[48;2;1;255;0m | - | bg=0x01FF00 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_0 | \e[58;2;1;255;0m | - | sp=0x01FF00 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_0 | \e[38:2::1:255:0m | - | fg=0x01FF00 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_0 | \e[48:2::1:255:0m | - | bg=0x01FF00 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_0 | \e[58:2::1:255:0m | - | sp=0x01FF00 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_1 | \e[38;2;1;255;1m | - | fg=0x01FF01 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_1 | \e[48;2;1;255;1m | - | bg=0x01FF01 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_1 | \e[58;2;1;255;1m | - | sp=0x01FF01 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_1 | \e[38:2::1:255:1m | - | fg=0x01FF01 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_1 | \e[48:2::1:255:1m | - | bg=0x01FF01 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_1 | \e[58:2::1:255:1m | - | sp=0x01FF01 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_127 | \e[38;2;1;255;127m | - | fg=0x01FF7F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_127 | \e[48;2;1;255;127m | - | bg=0x01FF7F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_127 | \e[58;2;1;255;127m | - | sp=0x01FF7F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_127 | \e[38:2::1:255:127m | - | fg=0x01FF7F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_127 | \e[48:2::1:255:127m | - | bg=0x01FF7F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_127 | \e[58:2::1:255:127m | - | sp=0x01FF7F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_128 | \e[38;2;1;255;128m | - | fg=0x01FF80 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_128 | \e[48;2;1;255;128m | - | bg=0x01FF80 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_128 | \e[58;2;1;255;128m | - | sp=0x01FF80 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_128 | \e[38:2::1:255:128m | - | fg=0x01FF80 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_128 | \e[48:2::1:255:128m | - | bg=0x01FF80 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_128 | \e[58:2::1:255:128m | - | sp=0x01FF80 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_254 | \e[38;2;1;255;254m | - | fg=0x01FFFE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_254 | \e[48;2;1;255;254m | - | bg=0x01FFFE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_254 | \e[58;2;1;255;254m | - | sp=0x01FFFE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_254 | \e[38:2::1:255:254m | - | fg=0x01FFFE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_254 | \e[48:2::1:255:254m | - | bg=0x01FFFE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_254 | \e[58:2::1:255:254m | - | sp=0x01FFFE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_1_255_255 | \e[38;2;1;255;255m | - | fg=0x01FFFF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_1_255_255 | \e[48;2;1;255;255m | - | bg=0x01FFFF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_1_255_255 | \e[58;2;1;255;255m | - | sp=0x01FFFF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_1_255_255 | \e[38:2::1:255:255m | - | fg=0x01FFFF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_1_255_255 | \e[48:2::1:255:255m | - | bg=0x01FFFF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_1_255_255 | \e[58:2::1:255:255m | - | sp=0x01FFFF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_0 | \e[38;2;127;0;0m | - | fg=0x7F0000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_0 | \e[48;2;127;0;0m | - | bg=0x7F0000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_0 | \e[58;2;127;0;0m | - | sp=0x7F0000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_0 | \e[38:2::127:0:0m | - | fg=0x7F0000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_0 | \e[48:2::127:0:0m | - | bg=0x7F0000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_0 | \e[58:2::127:0:0m | - | sp=0x7F0000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_1 | \e[38;2;127;0;1m | - | fg=0x7F0001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_1 | \e[48;2;127;0;1m | - | bg=0x7F0001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_1 | \e[58;2;127;0;1m | - | sp=0x7F0001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_1 | \e[38:2::127:0:1m | - | fg=0x7F0001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_1 | \e[48:2::127:0:1m | - | bg=0x7F0001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_1 | \e[58:2::127:0:1m | - | sp=0x7F0001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_127 | \e[38;2;127;0;127m | - | fg=0x7F007F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_127 | \e[48;2;127;0;127m | - | bg=0x7F007F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_127 | \e[58;2;127;0;127m | - | sp=0x7F007F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_127 | \e[38:2::127:0:127m | - | fg=0x7F007F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_127 | \e[48:2::127:0:127m | - | bg=0x7F007F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_127 | \e[58:2::127:0:127m | - | sp=0x7F007F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_128 | \e[38;2;127;0;128m | - | fg=0x7F0080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_128 | \e[48;2;127;0;128m | - | bg=0x7F0080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_128 | \e[58;2;127;0;128m | - | sp=0x7F0080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_128 | \e[38:2::127:0:128m | - | fg=0x7F0080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_128 | \e[48:2::127:0:128m | - | bg=0x7F0080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_128 | \e[58:2::127:0:128m | - | sp=0x7F0080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_254 | \e[38;2;127;0;254m | - | fg=0x7F00FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_254 | \e[48;2;127;0;254m | - | bg=0x7F00FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_254 | \e[58;2;127;0;254m | - | sp=0x7F00FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_254 | \e[38:2::127:0:254m | - | fg=0x7F00FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_254 | \e[48:2::127:0:254m | - | bg=0x7F00FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_254 | \e[58:2::127:0:254m | - | sp=0x7F00FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_0_255 | \e[38;2;127;0;255m | - | fg=0x7F00FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_0_255 | \e[48;2;127;0;255m | - | bg=0x7F00FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_0_255 | \e[58;2;127;0;255m | - | sp=0x7F00FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_0_255 | \e[38:2::127:0:255m | - | fg=0x7F00FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_0_255 | \e[48:2::127:0:255m | - | bg=0x7F00FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_0_255 | \e[58:2::127:0:255m | - | sp=0x7F00FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_0 | \e[38;2;127;1;0m | - | fg=0x7F0100 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_0 | \e[48;2;127;1;0m | - | bg=0x7F0100 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_0 | \e[58;2;127;1;0m | - | sp=0x7F0100 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_0 | \e[38:2::127:1:0m | - | fg=0x7F0100 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_0 | \e[48:2::127:1:0m | - | bg=0x7F0100 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_0 | \e[58:2::127:1:0m | - | sp=0x7F0100 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_1 | \e[38;2;127;1;1m | - | fg=0x7F0101 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_1 | \e[48;2;127;1;1m | - | bg=0x7F0101 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_1 | \e[58;2;127;1;1m | - | sp=0x7F0101 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_1 | \e[38:2::127:1:1m | - | fg=0x7F0101 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_1 | \e[48:2::127:1:1m | - | bg=0x7F0101 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_1 | \e[58:2::127:1:1m | - | sp=0x7F0101 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_127 | \e[38;2;127;1;127m | - | fg=0x7F017F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_127 | \e[48;2;127;1;127m | - | bg=0x7F017F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_127 | \e[58;2;127;1;127m | - | sp=0x7F017F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_127 | \e[38:2::127:1:127m | - | fg=0x7F017F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_127 | \e[48:2::127:1:127m | - | bg=0x7F017F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_127 | \e[58:2::127:1:127m | - | sp=0x7F017F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_128 | \e[38;2;127;1;128m | - | fg=0x7F0180 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_128 | \e[48;2;127;1;128m | - | bg=0x7F0180 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_128 | \e[58;2;127;1;128m | - | sp=0x7F0180 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_128 | \e[38:2::127:1:128m | - | fg=0x7F0180 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_128 | \e[48:2::127:1:128m | - | bg=0x7F0180 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_128 | \e[58:2::127:1:128m | - | sp=0x7F0180 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_254 | \e[38;2;127;1;254m | - | fg=0x7F01FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_254 | \e[48;2;127;1;254m | - | bg=0x7F01FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_254 | \e[58;2;127;1;254m | - | sp=0x7F01FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_254 | \e[38:2::127:1:254m | - | fg=0x7F01FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_254 | \e[48:2::127:1:254m | - | bg=0x7F01FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_254 | \e[58:2::127:1:254m | - | sp=0x7F01FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_1_255 | \e[38;2;127;1;255m | - | fg=0x7F01FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_1_255 | \e[48;2;127;1;255m | - | bg=0x7F01FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_1_255 | \e[58;2;127;1;255m | - | sp=0x7F01FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_1_255 | \e[38:2::127:1:255m | - | fg=0x7F01FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_1_255 | \e[48:2::127:1:255m | - | bg=0x7F01FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_1_255 | \e[58:2::127:1:255m | - | sp=0x7F01FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_0 | \e[38;2;127;127;0m | - | fg=0x7F7F00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_0 | \e[48;2;127;127;0m | - | bg=0x7F7F00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_0 | \e[58;2;127;127;0m | - | sp=0x7F7F00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_0 | \e[38:2::127:127:0m | - | fg=0x7F7F00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_0 | \e[48:2::127:127:0m | - | bg=0x7F7F00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_0 | \e[58:2::127:127:0m | - | sp=0x7F7F00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_1 | \e[38;2;127;127;1m | - | fg=0x7F7F01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_1 | \e[48;2;127;127;1m | - | bg=0x7F7F01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_1 | \e[58;2;127;127;1m | - | sp=0x7F7F01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_1 | \e[38:2::127:127:1m | - | fg=0x7F7F01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_1 | \e[48:2::127:127:1m | - | bg=0x7F7F01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_1 | \e[58:2::127:127:1m | - | sp=0x7F7F01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_127 | \e[38;2;127;127;127m | - | fg=0x7F7F7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_127 | \e[48;2;127;127;127m | - | bg=0x7F7F7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_127 | \e[58;2;127;127;127m | - | sp=0x7F7F7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_127 | \e[38:2::127:127:127m | - | fg=0x7F7F7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_127 | \e[48:2::127:127:127m | - | bg=0x7F7F7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_127 | \e[58:2::127:127:127m | - | sp=0x7F7F7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_128 | \e[38;2;127;127;128m | - | fg=0x7F7F80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_128 | \e[48;2;127;127;128m | - | bg=0x7F7F80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_128 | \e[58;2;127;127;128m | - | sp=0x7F7F80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_128 | \e[38:2::127:127:128m | - | fg=0x7F7F80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_128 | \e[48:2::127:127:128m | - | bg=0x7F7F80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_128 | \e[58:2::127:127:128m | - | sp=0x7F7F80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_254 | \e[38;2;127;127;254m | - | fg=0x7F7FFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_254 | \e[48;2;127;127;254m | - | bg=0x7F7FFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_254 | \e[58;2;127;127;254m | - | sp=0x7F7FFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_254 | \e[38:2::127:127:254m | - | fg=0x7F7FFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_254 | \e[48:2::127:127:254m | - | bg=0x7F7FFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_254 | \e[58:2::127:127:254m | - | sp=0x7F7FFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_127_255 | \e[38;2;127;127;255m | - | fg=0x7F7FFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_127_255 | \e[48;2;127;127;255m | - | bg=0x7F7FFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_127_255 | \e[58;2;127;127;255m | - | sp=0x7F7FFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_127_255 | \e[38:2::127:127:255m | - | fg=0x7F7FFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_127_255 | \e[48:2::127:127:255m | - | bg=0x7F7FFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_127_255 | \e[58:2::127:127:255m | - | sp=0x7F7FFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_0 | \e[38;2;127;128;0m | - | fg=0x7F8000 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_0 | \e[48;2;127;128;0m | - | bg=0x7F8000 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_0 | \e[58;2;127;128;0m | - | sp=0x7F8000 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_0 | \e[38:2::127:128:0m | - | fg=0x7F8000 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_0 | \e[48:2::127:128:0m | - | bg=0x7F8000 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_0 | \e[58:2::127:128:0m | - | sp=0x7F8000 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_1 | \e[38;2;127;128;1m | - | fg=0x7F8001 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_1 | \e[48;2;127;128;1m | - | bg=0x7F8001 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_1 | \e[58;2;127;128;1m | - | sp=0x7F8001 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_1 | \e[38:2::127:128:1m | - | fg=0x7F8001 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_1 | \e[48:2::127:128:1m | - | bg=0x7F8001 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_1 | \e[58:2::127:128:1m | - | sp=0x7F8001 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_127 | \e[38;2;127;128;127m | - | fg=0x7F807F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_127 | \e[48;2;127;128;127m | - | bg=0x7F807F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_127 | \e[58;2;127;128;127m | - | sp=0x7F807F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_127 | \e[38:2::127:128:127m | - | fg=0x7F807F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_127 | \e[48:2::127:128:127m | - | bg=0x7F807F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_127 | \e[58:2::127:128:127m | - | sp=0x7F807F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_128 | \e[38;2;127;128;128m | - | fg=0x7F8080 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_128 | \e[48;2;127;128;128m | - | bg=0x7F8080 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_128 | \e[58;2;127;128;128m | - | sp=0x7F8080 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_128 | \e[38:2::127:128:128m | - | fg=0x7F8080 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_128 | \e[48:2::127:128:128m | - | bg=0x7F8080 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_128 | \e[58:2::127:128:128m | - | sp=0x7F8080 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_254 | \e[38;2;127;128;254m | - | fg=0x7F80FE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_254 | \e[48;2;127;128;254m | - | bg=0x7F80FE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_254 | \e[58;2;127;128;254m | - | sp=0x7F80FE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_254 | \e[38:2::127:128:254m | - | fg=0x7F80FE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_254 | \e[48:2::127:128:254m | - | bg=0x7F80FE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_254 | \e[58:2::127:128:254m | - | sp=0x7F80FE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_128_255 | \e[38;2;127;128;255m | - | fg=0x7F80FF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_128_255 | \e[48;2;127;128;255m | - | bg=0x7F80FF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_128_255 | \e[58;2;127;128;255m | - | sp=0x7F80FF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_128_255 | \e[38:2::127:128:255m | - | fg=0x7F80FF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_128_255 | \e[48:2::127:128:255m | - | bg=0x7F80FF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_128_255 | \e[58:2::127:128:255m | - | sp=0x7F80FF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_0 | \e[38;2;127;254;0m | - | fg=0x7FFE00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_0 | \e[48;2;127;254;0m | - | bg=0x7FFE00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_0 | \e[58;2;127;254;0m | - | sp=0x7FFE00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_0 | \e[38:2::127:254:0m | - | fg=0x7FFE00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_0 | \e[48:2::127:254:0m | - | bg=0x7FFE00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_0 | \e[58:2::127:254:0m | - | sp=0x7FFE00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_1 | \e[38;2;127;254;1m | - | fg=0x7FFE01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_1 | \e[48;2;127;254;1m | - | bg=0x7FFE01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_1 | \e[58;2;127;254;1m | - | sp=0x7FFE01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_1 | \e[38:2::127:254:1m | - | fg=0x7FFE01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_1 | \e[48:2::127:254:1m | - | bg=0x7FFE01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_1 | \e[58:2::127:254:1m | - | sp=0x7FFE01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_127 | \e[38;2;127;254;127m | - | fg=0x7FFE7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_127 | \e[48;2;127;254;127m | - | bg=0x7FFE7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_127 | \e[58;2;127;254;127m | - | sp=0x7FFE7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_127 | \e[38:2::127:254:127m | - | fg=0x7FFE7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_127 | \e[48:2::127:254:127m | - | bg=0x7FFE7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_127 | \e[58:2::127:254:127m | - | sp=0x7FFE7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_128 | \e[38;2;127;254;128m | - | fg=0x7FFE80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_128 | \e[48;2;127;254;128m | - | bg=0x7FFE80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_128 | \e[58;2;127;254;128m | - | sp=0x7FFE80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_128 | \e[38:2::127:254:128m | - | fg=0x7FFE80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_128 | \e[48:2::127:254:128m | - | bg=0x7FFE80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_128 | \e[58:2::127:254:128m | - | sp=0x7FFE80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_254 | \e[38;2;127;254;254m | - | fg=0x7FFEFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_254 | \e[48;2;127;254;254m | - | bg=0x7FFEFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_254 | \e[58;2;127;254;254m | - | sp=0x7FFEFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_254 | \e[38:2::127:254:254m | - | fg=0x7FFEFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_254 | \e[48:2::127:254:254m | - | bg=0x7FFEFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_254 | \e[58:2::127:254:254m | - | sp=0x7FFEFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_254_255 | \e[38;2;127;254;255m | - | fg=0x7FFEFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_254_255 | \e[48;2;127;254;255m | - | bg=0x7FFEFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_254_255 | \e[58;2;127;254;255m | - | sp=0x7FFEFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_254_255 | \e[38:2::127:254:255m | - | fg=0x7FFEFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_254_255 | \e[48:2::127:254:255m | - | bg=0x7FFEFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_254_255 | \e[58:2::127:254:255m | - | sp=0x7FFEFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_0 | \e[38;2;127;255;0m | - | fg=0x7FFF00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_0 | \e[48;2;127;255;0m | - | bg=0x7FFF00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_0 | \e[58;2;127;255;0m | - | sp=0x7FFF00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_0 | \e[38:2::127:255:0m | - | fg=0x7FFF00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_0 | \e[48:2::127:255:0m | - | bg=0x7FFF00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_0 | \e[58:2::127:255:0m | - | sp=0x7FFF00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_1 | \e[38;2;127;255;1m | - | fg=0x7FFF01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_1 | \e[48;2;127;255;1m | - | bg=0x7FFF01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_1 | \e[58;2;127;255;1m | - | sp=0x7FFF01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_1 | \e[38:2::127:255:1m | - | fg=0x7FFF01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_1 | \e[48:2::127:255:1m | - | bg=0x7FFF01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_1 | \e[58:2::127:255:1m | - | sp=0x7FFF01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_127 | \e[38;2;127;255;127m | - | fg=0x7FFF7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_127 | \e[48;2;127;255;127m | - | bg=0x7FFF7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_127 | \e[58;2;127;255;127m | - | sp=0x7FFF7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_127 | \e[38:2::127:255:127m | - | fg=0x7FFF7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_127 | \e[48:2::127:255:127m | - | bg=0x7FFF7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_127 | \e[58:2::127:255:127m | - | sp=0x7FFF7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_128 | \e[38;2;127;255;128m | - | fg=0x7FFF80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_128 | \e[48;2;127;255;128m | - | bg=0x7FFF80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_128 | \e[58;2;127;255;128m | - | sp=0x7FFF80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_128 | \e[38:2::127:255:128m | - | fg=0x7FFF80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_128 | \e[48:2::127:255:128m | - | bg=0x7FFF80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_128 | \e[58:2::127:255:128m | - | sp=0x7FFF80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_254 | \e[38;2;127;255;254m | - | fg=0x7FFFFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_254 | \e[48;2;127;255;254m | - | bg=0x7FFFFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_254 | \e[58;2;127;255;254m | - | sp=0x7FFFFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_254 | \e[38:2::127:255:254m | - | fg=0x7FFFFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_254 | \e[48:2::127:255:254m | - | bg=0x7FFFFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_254 | \e[58:2::127:255:254m | - | sp=0x7FFFFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_127_255_255 | \e[38;2;127;255;255m | - | fg=0x7FFFFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_127_255_255 | \e[48;2;127;255;255m | - | bg=0x7FFFFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_127_255_255 | \e[58;2;127;255;255m | - | sp=0x7FFFFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_127_255_255 | \e[38:2::127:255:255m | - | fg=0x7FFFFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_127_255_255 | \e[48:2::127:255:255m | - | bg=0x7FFFFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_127_255_255 | \e[58:2::127:255:255m | - | sp=0x7FFFFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_0 | \e[38;2;128;0;0m | - | fg=0x800000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_0 | \e[48;2;128;0;0m | - | bg=0x800000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_0 | \e[58;2;128;0;0m | - | sp=0x800000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_0 | \e[38:2::128:0:0m | - | fg=0x800000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_0 | \e[48:2::128:0:0m | - | bg=0x800000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_0 | \e[58:2::128:0:0m | - | sp=0x800000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_1 | \e[38;2;128;0;1m | - | fg=0x800001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_1 | \e[48;2;128;0;1m | - | bg=0x800001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_1 | \e[58;2;128;0;1m | - | sp=0x800001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_1 | \e[38:2::128:0:1m | - | fg=0x800001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_1 | \e[48:2::128:0:1m | - | bg=0x800001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_1 | \e[58:2::128:0:1m | - | sp=0x800001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_127 | \e[38;2;128;0;127m | - | fg=0x80007F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_127 | \e[48;2;128;0;127m | - | bg=0x80007F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_127 | \e[58;2;128;0;127m | - | sp=0x80007F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_127 | \e[38:2::128:0:127m | - | fg=0x80007F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_127 | \e[48:2::128:0:127m | - | bg=0x80007F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_127 | \e[58:2::128:0:127m | - | sp=0x80007F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_128 | \e[38;2;128;0;128m | - | fg=0x800080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_128 | \e[48;2;128;0;128m | - | bg=0x800080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_128 | \e[58;2;128;0;128m | - | sp=0x800080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_128 | \e[38:2::128:0:128m | - | fg=0x800080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_128 | \e[48:2::128:0:128m | - | bg=0x800080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_128 | \e[58:2::128:0:128m | - | sp=0x800080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_254 | \e[38;2;128;0;254m | - | fg=0x8000FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_254 | \e[48;2;128;0;254m | - | bg=0x8000FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_254 | \e[58;2;128;0;254m | - | sp=0x8000FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_254 | \e[38:2::128:0:254m | - | fg=0x8000FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_254 | \e[48:2::128:0:254m | - | bg=0x8000FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_254 | \e[58:2::128:0:254m | - | sp=0x8000FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_0_255 | \e[38;2;128;0;255m | - | fg=0x8000FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_0_255 | \e[48;2;128;0;255m | - | bg=0x8000FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_0_255 | \e[58;2;128;0;255m | - | sp=0x8000FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_0_255 | \e[38:2::128:0:255m | - | fg=0x8000FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_0_255 | \e[48:2::128:0:255m | - | bg=0x8000FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_0_255 | \e[58:2::128:0:255m | - | sp=0x8000FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_0 | \e[38;2;128;1;0m | - | fg=0x800100 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_0 | \e[48;2;128;1;0m | - | bg=0x800100 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_0 | \e[58;2;128;1;0m | - | sp=0x800100 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_0 | \e[38:2::128:1:0m | - | fg=0x800100 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_0 | \e[48:2::128:1:0m | - | bg=0x800100 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_0 | \e[58:2::128:1:0m | - | sp=0x800100 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_1 | \e[38;2;128;1;1m | - | fg=0x800101 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_1 | \e[48;2;128;1;1m | - | bg=0x800101 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_1 | \e[58;2;128;1;1m | - | sp=0x800101 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_1 | \e[38:2::128:1:1m | - | fg=0x800101 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_1 | \e[48:2::128:1:1m | - | bg=0x800101 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_1 | \e[58:2::128:1:1m | - | sp=0x800101 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_127 | \e[38;2;128;1;127m | - | fg=0x80017F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_127 | \e[48;2;128;1;127m | - | bg=0x80017F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_127 | \e[58;2;128;1;127m | - | sp=0x80017F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_127 | \e[38:2::128:1:127m | - | fg=0x80017F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_127 | \e[48:2::128:1:127m | - | bg=0x80017F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_127 | \e[58:2::128:1:127m | - | sp=0x80017F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_128 | \e[38;2;128;1;128m | - | fg=0x800180 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_128 | \e[48;2;128;1;128m | - | bg=0x800180 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_128 | \e[58;2;128;1;128m | - | sp=0x800180 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_128 | \e[38:2::128:1:128m | - | fg=0x800180 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_128 | \e[48:2::128:1:128m | - | bg=0x800180 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_128 | \e[58:2::128:1:128m | - | sp=0x800180 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_254 | \e[38;2;128;1;254m | - | fg=0x8001FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_254 | \e[48;2;128;1;254m | - | bg=0x8001FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_254 | \e[58;2;128;1;254m | - | sp=0x8001FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_254 | \e[38:2::128:1:254m | - | fg=0x8001FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_254 | \e[48:2::128:1:254m | - | bg=0x8001FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_254 | \e[58:2::128:1:254m | - | sp=0x8001FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_1_255 | \e[38;2;128;1;255m | - | fg=0x8001FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_1_255 | \e[48;2;128;1;255m | - | bg=0x8001FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_1_255 | \e[58;2;128;1;255m | - | sp=0x8001FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_1_255 | \e[38:2::128:1:255m | - | fg=0x8001FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_1_255 | \e[48:2::128:1:255m | - | bg=0x8001FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_1_255 | \e[58:2::128:1:255m | - | sp=0x8001FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_0 | \e[38;2;128;127;0m | - | fg=0x807F00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_0 | \e[48;2;128;127;0m | - | bg=0x807F00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_0 | \e[58;2;128;127;0m | - | sp=0x807F00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_0 | \e[38:2::128:127:0m | - | fg=0x807F00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_0 | \e[48:2::128:127:0m | - | bg=0x807F00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_0 | \e[58:2::128:127:0m | - | sp=0x807F00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_1 | \e[38;2;128;127;1m | - | fg=0x807F01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_1 | \e[48;2;128;127;1m | - | bg=0x807F01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_1 | \e[58;2;128;127;1m | - | sp=0x807F01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_1 | \e[38:2::128:127:1m | - | fg=0x807F01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_1 | \e[48:2::128:127:1m | - | bg=0x807F01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_1 | \e[58:2::128:127:1m | - | sp=0x807F01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_127 | \e[38;2;128;127;127m | - | fg=0x807F7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_127 | \e[48;2;128;127;127m | - | bg=0x807F7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_127 | \e[58;2;128;127;127m | - | sp=0x807F7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_127 | \e[38:2::128:127:127m | - | fg=0x807F7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_127 | \e[48:2::128:127:127m | - | bg=0x807F7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_127 | \e[58:2::128:127:127m | - | sp=0x807F7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_128 | \e[38;2;128;127;128m | - | fg=0x807F80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_128 | \e[48;2;128;127;128m | - | bg=0x807F80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_128 | \e[58;2;128;127;128m | - | sp=0x807F80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_128 | \e[38:2::128:127:128m | - | fg=0x807F80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_128 | \e[48:2::128:127:128m | - | bg=0x807F80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_128 | \e[58:2::128:127:128m | - | sp=0x807F80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_254 | \e[38;2;128;127;254m | - | fg=0x807FFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_254 | \e[48;2;128;127;254m | - | bg=0x807FFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_254 | \e[58;2;128;127;254m | - | sp=0x807FFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_254 | \e[38:2::128:127:254m | - | fg=0x807FFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_254 | \e[48:2::128:127:254m | - | bg=0x807FFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_254 | \e[58:2::128:127:254m | - | sp=0x807FFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_127_255 | \e[38;2;128;127;255m | - | fg=0x807FFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_127_255 | \e[48;2;128;127;255m | - | bg=0x807FFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_127_255 | \e[58;2;128;127;255m | - | sp=0x807FFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_127_255 | \e[38:2::128:127:255m | - | fg=0x807FFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_127_255 | \e[48:2::128:127:255m | - | bg=0x807FFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_127_255 | \e[58:2::128:127:255m | - | sp=0x807FFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_0 | \e[38;2;128;128;0m | - | fg=0x808000 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_0 | \e[48;2;128;128;0m | - | bg=0x808000 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_0 | \e[58;2;128;128;0m | - | sp=0x808000 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_0 | \e[38:2::128:128:0m | - | fg=0x808000 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_0 | \e[48:2::128:128:0m | - | bg=0x808000 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_0 | \e[58:2::128:128:0m | - | sp=0x808000 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_1 | \e[38;2;128;128;1m | - | fg=0x808001 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_1 | \e[48;2;128;128;1m | - | bg=0x808001 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_1 | \e[58;2;128;128;1m | - | sp=0x808001 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_1 | \e[38:2::128:128:1m | - | fg=0x808001 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_1 | \e[48:2::128:128:1m | - | bg=0x808001 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_1 | \e[58:2::128:128:1m | - | sp=0x808001 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_127 | \e[38;2;128;128;127m | - | fg=0x80807F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_127 | \e[48;2;128;128;127m | - | bg=0x80807F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_127 | \e[58;2;128;128;127m | - | sp=0x80807F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_127 | \e[38:2::128:128:127m | - | fg=0x80807F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_127 | \e[48:2::128:128:127m | - | bg=0x80807F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_127 | \e[58:2::128:128:127m | - | sp=0x80807F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_128 | \e[38;2;128;128;128m | - | fg=0x808080 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_128 | \e[48;2;128;128;128m | - | bg=0x808080 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_128 | \e[58;2;128;128;128m | - | sp=0x808080 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_128 | \e[38:2::128:128:128m | - | fg=0x808080 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_128 | \e[48:2::128:128:128m | - | bg=0x808080 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_128 | \e[58:2::128:128:128m | - | sp=0x808080 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_254 | \e[38;2;128;128;254m | - | fg=0x8080FE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_254 | \e[48;2;128;128;254m | - | bg=0x8080FE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_254 | \e[58;2;128;128;254m | - | sp=0x8080FE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_254 | \e[38:2::128:128:254m | - | fg=0x8080FE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_254 | \e[48:2::128:128:254m | - | bg=0x8080FE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_254 | \e[58:2::128:128:254m | - | sp=0x8080FE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_128_255 | \e[38;2;128;128;255m | - | fg=0x8080FF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_128_255 | \e[48;2;128;128;255m | - | bg=0x8080FF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_128_255 | \e[58;2;128;128;255m | - | sp=0x8080FF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_128_255 | \e[38:2::128:128:255m | - | fg=0x8080FF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_128_255 | \e[48:2::128:128:255m | - | bg=0x8080FF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_128_255 | \e[58:2::128:128:255m | - | sp=0x8080FF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_0 | \e[38;2;128;254;0m | - | fg=0x80FE00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_0 | \e[48;2;128;254;0m | - | bg=0x80FE00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_0 | \e[58;2;128;254;0m | - | sp=0x80FE00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_0 | \e[38:2::128:254:0m | - | fg=0x80FE00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_0 | \e[48:2::128:254:0m | - | bg=0x80FE00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_0 | \e[58:2::128:254:0m | - | sp=0x80FE00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_1 | \e[38;2;128;254;1m | - | fg=0x80FE01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_1 | \e[48;2;128;254;1m | - | bg=0x80FE01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_1 | \e[58;2;128;254;1m | - | sp=0x80FE01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_1 | \e[38:2::128:254:1m | - | fg=0x80FE01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_1 | \e[48:2::128:254:1m | - | bg=0x80FE01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_1 | \e[58:2::128:254:1m | - | sp=0x80FE01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_127 | \e[38;2;128;254;127m | - | fg=0x80FE7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_127 | \e[48;2;128;254;127m | - | bg=0x80FE7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_127 | \e[58;2;128;254;127m | - | sp=0x80FE7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_127 | \e[38:2::128:254:127m | - | fg=0x80FE7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_127 | \e[48:2::128:254:127m | - | bg=0x80FE7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_127 | \e[58:2::128:254:127m | - | sp=0x80FE7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_128 | \e[38;2;128;254;128m | - | fg=0x80FE80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_128 | \e[48;2;128;254;128m | - | bg=0x80FE80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_128 | \e[58;2;128;254;128m | - | sp=0x80FE80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_128 | \e[38:2::128:254:128m | - | fg=0x80FE80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_128 | \e[48:2::128:254:128m | - | bg=0x80FE80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_128 | \e[58:2::128:254:128m | - | sp=0x80FE80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_254 | \e[38;2;128;254;254m | - | fg=0x80FEFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_254 | \e[48;2;128;254;254m | - | bg=0x80FEFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_254 | \e[58;2;128;254;254m | - | sp=0x80FEFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_254 | \e[38:2::128:254:254m | - | fg=0x80FEFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_254 | \e[48:2::128:254:254m | - | bg=0x80FEFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_254 | \e[58:2::128:254:254m | - | sp=0x80FEFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_254_255 | \e[38;2;128;254;255m | - | fg=0x80FEFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_254_255 | \e[48;2;128;254;255m | - | bg=0x80FEFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_254_255 | \e[58;2;128;254;255m | - | sp=0x80FEFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_254_255 | \e[38:2::128:254:255m | - | fg=0x80FEFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_254_255 | \e[48:2::128:254:255m | - | bg=0x80FEFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_254_255 | \e[58:2::128:254:255m | - | sp=0x80FEFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_0 | \e[38;2;128;255;0m | - | fg=0x80FF00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_0 | \e[48;2;128;255;0m | - | bg=0x80FF00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_0 | \e[58;2;128;255;0m | - | sp=0x80FF00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_0 | \e[38:2::128:255:0m | - | fg=0x80FF00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_0 | \e[48:2::128:255:0m | - | bg=0x80FF00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_0 | \e[58:2::128:255:0m | - | sp=0x80FF00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_1 | \e[38;2;128;255;1m | - | fg=0x80FF01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_1 | \e[48;2;128;255;1m | - | bg=0x80FF01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_1 | \e[58;2;128;255;1m | - | sp=0x80FF01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_1 | \e[38:2::128:255:1m | - | fg=0x80FF01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_1 | \e[48:2::128:255:1m | - | bg=0x80FF01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_1 | \e[58:2::128:255:1m | - | sp=0x80FF01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_127 | \e[38;2;128;255;127m | - | fg=0x80FF7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_127 | \e[48;2;128;255;127m | - | bg=0x80FF7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_127 | \e[58;2;128;255;127m | - | sp=0x80FF7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_127 | \e[38:2::128:255:127m | - | fg=0x80FF7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_127 | \e[48:2::128:255:127m | - | bg=0x80FF7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_127 | \e[58:2::128:255:127m | - | sp=0x80FF7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_128 | \e[38;2;128;255;128m | - | fg=0x80FF80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_128 | \e[48;2;128;255;128m | - | bg=0x80FF80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_128 | \e[58;2;128;255;128m | - | sp=0x80FF80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_128 | \e[38:2::128:255:128m | - | fg=0x80FF80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_128 | \e[48:2::128:255:128m | - | bg=0x80FF80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_128 | \e[58:2::128:255:128m | - | sp=0x80FF80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_254 | \e[38;2;128;255;254m | - | fg=0x80FFFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_254 | \e[48;2;128;255;254m | - | bg=0x80FFFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_254 | \e[58;2;128;255;254m | - | sp=0x80FFFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_254 | \e[38:2::128:255:254m | - | fg=0x80FFFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_254 | \e[48:2::128:255:254m | - | bg=0x80FFFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_254 | \e[58:2::128:255:254m | - | sp=0x80FFFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_128_255_255 | \e[38;2;128;255;255m | - | fg=0x80FFFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_128_255_255 | \e[48;2;128;255;255m | - | bg=0x80FFFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_128_255_255 | \e[58;2;128;255;255m | - | sp=0x80FFFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_128_255_255 | \e[38:2::128:255:255m | - | fg=0x80FFFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_128_255_255 | \e[48:2::128:255:255m | - | bg=0x80FFFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_128_255_255 | \e[58:2::128:255:255m | - | sp=0x80FFFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_0 | \e[38;2;254;0;0m | - | fg=0xFE0000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_0 | \e[48;2;254;0;0m | - | bg=0xFE0000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_0 | \e[58;2;254;0;0m | - | sp=0xFE0000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_0 | \e[38:2::254:0:0m | - | fg=0xFE0000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_0 | \e[48:2::254:0:0m | - | bg=0xFE0000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_0 | \e[58:2::254:0:0m | - | sp=0xFE0000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_1 | \e[38;2;254;0;1m | - | fg=0xFE0001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_1 | \e[48;2;254;0;1m | - | bg=0xFE0001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_1 | \e[58;2;254;0;1m | - | sp=0xFE0001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_1 | \e[38:2::254:0:1m | - | fg=0xFE0001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_1 | \e[48:2::254:0:1m | - | bg=0xFE0001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_1 | \e[58:2::254:0:1m | - | sp=0xFE0001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_127 | \e[38;2;254;0;127m | - | fg=0xFE007F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_127 | \e[48;2;254;0;127m | - | bg=0xFE007F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_127 | \e[58;2;254;0;127m | - | sp=0xFE007F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_127 | \e[38:2::254:0:127m | - | fg=0xFE007F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_127 | \e[48:2::254:0:127m | - | bg=0xFE007F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_127 | \e[58:2::254:0:127m | - | sp=0xFE007F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_128 | \e[38;2;254;0;128m | - | fg=0xFE0080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_128 | \e[48;2;254;0;128m | - | bg=0xFE0080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_128 | \e[58;2;254;0;128m | - | sp=0xFE0080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_128 | \e[38:2::254:0:128m | - | fg=0xFE0080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_128 | \e[48:2::254:0:128m | - | bg=0xFE0080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_128 | \e[58:2::254:0:128m | - | sp=0xFE0080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_254 | \e[38;2;254;0;254m | - | fg=0xFE00FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_254 | \e[48;2;254;0;254m | - | bg=0xFE00FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_254 | \e[58;2;254;0;254m | - | sp=0xFE00FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_254 | \e[38:2::254:0:254m | - | fg=0xFE00FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_254 | \e[48:2::254:0:254m | - | bg=0xFE00FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_254 | \e[58:2::254:0:254m | - | sp=0xFE00FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_0_255 | \e[38;2;254;0;255m | - | fg=0xFE00FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_0_255 | \e[48;2;254;0;255m | - | bg=0xFE00FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_0_255 | \e[58;2;254;0;255m | - | sp=0xFE00FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_0_255 | \e[38:2::254:0:255m | - | fg=0xFE00FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_0_255 | \e[48:2::254:0:255m | - | bg=0xFE00FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_0_255 | \e[58:2::254:0:255m | - | sp=0xFE00FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_0 | \e[38;2;254;1;0m | - | fg=0xFE0100 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_0 | \e[48;2;254;1;0m | - | bg=0xFE0100 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_0 | \e[58;2;254;1;0m | - | sp=0xFE0100 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_0 | \e[38:2::254:1:0m | - | fg=0xFE0100 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_0 | \e[48:2::254:1:0m | - | bg=0xFE0100 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_0 | \e[58:2::254:1:0m | - | sp=0xFE0100 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_1 | \e[38;2;254;1;1m | - | fg=0xFE0101 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_1 | \e[48;2;254;1;1m | - | bg=0xFE0101 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_1 | \e[58;2;254;1;1m | - | sp=0xFE0101 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_1 | \e[38:2::254:1:1m | - | fg=0xFE0101 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_1 | \e[48:2::254:1:1m | - | bg=0xFE0101 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_1 | \e[58:2::254:1:1m | - | sp=0xFE0101 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_127 | \e[38;2;254;1;127m | - | fg=0xFE017F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_127 | \e[48;2;254;1;127m | - | bg=0xFE017F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_127 | \e[58;2;254;1;127m | - | sp=0xFE017F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_127 | \e[38:2::254:1:127m | - | fg=0xFE017F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_127 | \e[48:2::254:1:127m | - | bg=0xFE017F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_127 | \e[58:2::254:1:127m | - | sp=0xFE017F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_128 | \e[38;2;254;1;128m | - | fg=0xFE0180 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_128 | \e[48;2;254;1;128m | - | bg=0xFE0180 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_128 | \e[58;2;254;1;128m | - | sp=0xFE0180 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_128 | \e[38:2::254:1:128m | - | fg=0xFE0180 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_128 | \e[48:2::254:1:128m | - | bg=0xFE0180 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_128 | \e[58:2::254:1:128m | - | sp=0xFE0180 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_254 | \e[38;2;254;1;254m | - | fg=0xFE01FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_254 | \e[48;2;254;1;254m | - | bg=0xFE01FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_254 | \e[58;2;254;1;254m | - | sp=0xFE01FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_254 | \e[38:2::254:1:254m | - | fg=0xFE01FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_254 | \e[48:2::254:1:254m | - | bg=0xFE01FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_254 | \e[58:2::254:1:254m | - | sp=0xFE01FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_1_255 | \e[38;2;254;1;255m | - | fg=0xFE01FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_1_255 | \e[48;2;254;1;255m | - | bg=0xFE01FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_1_255 | \e[58;2;254;1;255m | - | sp=0xFE01FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_1_255 | \e[38:2::254:1:255m | - | fg=0xFE01FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_1_255 | \e[48:2::254:1:255m | - | bg=0xFE01FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_1_255 | \e[58:2::254:1:255m | - | sp=0xFE01FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_0 | \e[38;2;254;127;0m | - | fg=0xFE7F00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_0 | \e[48;2;254;127;0m | - | bg=0xFE7F00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_0 | \e[58;2;254;127;0m | - | sp=0xFE7F00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_0 | \e[38:2::254:127:0m | - | fg=0xFE7F00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_0 | \e[48:2::254:127:0m | - | bg=0xFE7F00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_0 | \e[58:2::254:127:0m | - | sp=0xFE7F00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_1 | \e[38;2;254;127;1m | - | fg=0xFE7F01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_1 | \e[48;2;254;127;1m | - | bg=0xFE7F01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_1 | \e[58;2;254;127;1m | - | sp=0xFE7F01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_1 | \e[38:2::254:127:1m | - | fg=0xFE7F01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_1 | \e[48:2::254:127:1m | - | bg=0xFE7F01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_1 | \e[58:2::254:127:1m | - | sp=0xFE7F01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_127 | \e[38;2;254;127;127m | - | fg=0xFE7F7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_127 | \e[48;2;254;127;127m | - | bg=0xFE7F7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_127 | \e[58;2;254;127;127m | - | sp=0xFE7F7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_127 | \e[38:2::254:127:127m | - | fg=0xFE7F7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_127 | \e[48:2::254:127:127m | - | bg=0xFE7F7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_127 | \e[58:2::254:127:127m | - | sp=0xFE7F7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_128 | \e[38;2;254;127;128m | - | fg=0xFE7F80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_128 | \e[48;2;254;127;128m | - | bg=0xFE7F80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_128 | \e[58;2;254;127;128m | - | sp=0xFE7F80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_128 | \e[38:2::254:127:128m | - | fg=0xFE7F80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_128 | \e[48:2::254:127:128m | - | bg=0xFE7F80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_128 | \e[58:2::254:127:128m | - | sp=0xFE7F80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_254 | \e[38;2;254;127;254m | - | fg=0xFE7FFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_254 | \e[48;2;254;127;254m | - | bg=0xFE7FFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_254 | \e[58;2;254;127;254m | - | sp=0xFE7FFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_254 | \e[38:2::254:127:254m | - | fg=0xFE7FFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_254 | \e[48:2::254:127:254m | - | bg=0xFE7FFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_254 | \e[58:2::254:127:254m | - | sp=0xFE7FFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_127_255 | \e[38;2;254;127;255m | - | fg=0xFE7FFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_127_255 | \e[48;2;254;127;255m | - | bg=0xFE7FFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_127_255 | \e[58;2;254;127;255m | - | sp=0xFE7FFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_127_255 | \e[38:2::254:127:255m | - | fg=0xFE7FFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_127_255 | \e[48:2::254:127:255m | - | bg=0xFE7FFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_127_255 | \e[58:2::254:127:255m | - | sp=0xFE7FFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_0 | \e[38;2;254;128;0m | - | fg=0xFE8000 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_0 | \e[48;2;254;128;0m | - | bg=0xFE8000 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_0 | \e[58;2;254;128;0m | - | sp=0xFE8000 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_0 | \e[38:2::254:128:0m | - | fg=0xFE8000 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_0 | \e[48:2::254:128:0m | - | bg=0xFE8000 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_0 | \e[58:2::254:128:0m | - | sp=0xFE8000 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_1 | \e[38;2;254;128;1m | - | fg=0xFE8001 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_1 | \e[48;2;254;128;1m | - | bg=0xFE8001 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_1 | \e[58;2;254;128;1m | - | sp=0xFE8001 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_1 | \e[38:2::254:128:1m | - | fg=0xFE8001 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_1 | \e[48:2::254:128:1m | - | bg=0xFE8001 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_1 | \e[58:2::254:128:1m | - | sp=0xFE8001 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_127 | \e[38;2;254;128;127m | - | fg=0xFE807F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_127 | \e[48;2;254;128;127m | - | bg=0xFE807F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_127 | \e[58;2;254;128;127m | - | sp=0xFE807F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_127 | \e[38:2::254:128:127m | - | fg=0xFE807F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_127 | \e[48:2::254:128:127m | - | bg=0xFE807F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_127 | \e[58:2::254:128:127m | - | sp=0xFE807F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_128 | \e[38;2;254;128;128m | - | fg=0xFE8080 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_128 | \e[48;2;254;128;128m | - | bg=0xFE8080 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_128 | \e[58;2;254;128;128m | - | sp=0xFE8080 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_128 | \e[38:2::254:128:128m | - | fg=0xFE8080 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_128 | \e[48:2::254:128:128m | - | bg=0xFE8080 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_128 | \e[58:2::254:128:128m | - | sp=0xFE8080 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_254 | \e[38;2;254;128;254m | - | fg=0xFE80FE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_254 | \e[48;2;254;128;254m | - | bg=0xFE80FE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_254 | \e[58;2;254;128;254m | - | sp=0xFE80FE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_254 | \e[38:2::254:128:254m | - | fg=0xFE80FE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_254 | \e[48:2::254:128:254m | - | bg=0xFE80FE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_254 | \e[58:2::254:128:254m | - | sp=0xFE80FE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_128_255 | \e[38;2;254;128;255m | - | fg=0xFE80FF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_128_255 | \e[48;2;254;128;255m | - | bg=0xFE80FF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_128_255 | \e[58;2;254;128;255m | - | sp=0xFE80FF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_128_255 | \e[38:2::254:128:255m | - | fg=0xFE80FF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_128_255 | \e[48:2::254:128:255m | - | bg=0xFE80FF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_128_255 | \e[58:2::254:128:255m | - | sp=0xFE80FF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_0 | \e[38;2;254;254;0m | - | fg=0xFEFE00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_0 | \e[48;2;254;254;0m | - | bg=0xFEFE00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_0 | \e[58;2;254;254;0m | - | sp=0xFEFE00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_0 | \e[38:2::254:254:0m | - | fg=0xFEFE00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_0 | \e[48:2::254:254:0m | - | bg=0xFEFE00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_0 | \e[58:2::254:254:0m | - | sp=0xFEFE00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_1 | \e[38;2;254;254;1m | - | fg=0xFEFE01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_1 | \e[48;2;254;254;1m | - | bg=0xFEFE01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_1 | \e[58;2;254;254;1m | - | sp=0xFEFE01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_1 | \e[38:2::254:254:1m | - | fg=0xFEFE01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_1 | \e[48:2::254:254:1m | - | bg=0xFEFE01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_1 | \e[58:2::254:254:1m | - | sp=0xFEFE01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_127 | \e[38;2;254;254;127m | - | fg=0xFEFE7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_127 | \e[48;2;254;254;127m | - | bg=0xFEFE7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_127 | \e[58;2;254;254;127m | - | sp=0xFEFE7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_127 | \e[38:2::254:254:127m | - | fg=0xFEFE7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_127 | \e[48:2::254:254:127m | - | bg=0xFEFE7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_127 | \e[58:2::254:254:127m | - | sp=0xFEFE7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_128 | \e[38;2;254;254;128m | - | fg=0xFEFE80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_128 | \e[48;2;254;254;128m | - | bg=0xFEFE80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_128 | \e[58;2;254;254;128m | - | sp=0xFEFE80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_128 | \e[38:2::254:254:128m | - | fg=0xFEFE80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_128 | \e[48:2::254:254:128m | - | bg=0xFEFE80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_128 | \e[58:2::254:254:128m | - | sp=0xFEFE80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_254 | \e[38;2;254;254;254m | - | fg=0xFEFEFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_254 | \e[48;2;254;254;254m | - | bg=0xFEFEFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_254 | \e[58;2;254;254;254m | - | sp=0xFEFEFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_254 | \e[38:2::254:254:254m | - | fg=0xFEFEFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_254 | \e[48:2::254:254:254m | - | bg=0xFEFEFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_254 | \e[58:2::254:254:254m | - | sp=0xFEFEFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_254_255 | \e[38;2;254;254;255m | - | fg=0xFEFEFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_254_255 | \e[48;2;254;254;255m | - | bg=0xFEFEFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_254_255 | \e[58;2;254;254;255m | - | sp=0xFEFEFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_254_255 | \e[38:2::254:254:255m | - | fg=0xFEFEFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_254_255 | \e[48:2::254:254:255m | - | bg=0xFEFEFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_254_255 | \e[58:2::254:254:255m | - | sp=0xFEFEFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_0 | \e[38;2;254;255;0m | - | fg=0xFEFF00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_0 | \e[48;2;254;255;0m | - | bg=0xFEFF00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_0 | \e[58;2;254;255;0m | - | sp=0xFEFF00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_0 | \e[38:2::254:255:0m | - | fg=0xFEFF00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_0 | \e[48:2::254:255:0m | - | bg=0xFEFF00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_0 | \e[58:2::254:255:0m | - | sp=0xFEFF00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_1 | \e[38;2;254;255;1m | - | fg=0xFEFF01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_1 | \e[48;2;254;255;1m | - | bg=0xFEFF01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_1 | \e[58;2;254;255;1m | - | sp=0xFEFF01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_1 | \e[38:2::254:255:1m | - | fg=0xFEFF01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_1 | \e[48:2::254:255:1m | - | bg=0xFEFF01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_1 | \e[58:2::254:255:1m | - | sp=0xFEFF01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_127 | \e[38;2;254;255;127m | - | fg=0xFEFF7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_127 | \e[48;2;254;255;127m | - | bg=0xFEFF7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_127 | \e[58;2;254;255;127m | - | sp=0xFEFF7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_127 | \e[38:2::254:255:127m | - | fg=0xFEFF7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_127 | \e[48:2::254:255:127m | - | bg=0xFEFF7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_127 | \e[58:2::254:255:127m | - | sp=0xFEFF7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_128 | \e[38;2;254;255;128m | - | fg=0xFEFF80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_128 | \e[48;2;254;255;128m | - | bg=0xFEFF80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_128 | \e[58;2;254;255;128m | - | sp=0xFEFF80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_128 | \e[38:2::254:255:128m | - | fg=0xFEFF80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_128 | \e[48:2::254:255:128m | - | bg=0xFEFF80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_128 | \e[58:2::254:255:128m | - | sp=0xFEFF80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_254 | \e[38;2;254;255;254m | - | fg=0xFEFFFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_254 | \e[48;2;254;255;254m | - | bg=0xFEFFFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_254 | \e[58;2;254;255;254m | - | sp=0xFEFFFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_254 | \e[38:2::254:255:254m | - | fg=0xFEFFFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_254 | \e[48:2::254:255:254m | - | bg=0xFEFFFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_254 | \e[58:2::254:255:254m | - | sp=0xFEFFFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_254_255_255 | \e[38;2;254;255;255m | - | fg=0xFEFFFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_254_255_255 | \e[48;2;254;255;255m | - | bg=0xFEFFFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_254_255_255 | \e[58;2;254;255;255m | - | sp=0xFEFFFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_254_255_255 | \e[38:2::254:255:255m | - | fg=0xFEFFFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_254_255_255 | \e[48:2::254:255:255m | - | bg=0xFEFFFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_254_255_255 | \e[58:2::254:255:255m | - | sp=0xFEFFFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_0 | \e[38;2;255;0;0m | - | fg=0xFF0000 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_0 | \e[48;2;255;0;0m | - | bg=0xFF0000 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_0 | \e[58;2;255;0;0m | - | sp=0xFF0000 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_0 | \e[38:2::255:0:0m | - | fg=0xFF0000 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_0 | \e[48:2::255:0:0m | - | bg=0xFF0000 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_0 | \e[58:2::255:0:0m | - | sp=0xFF0000 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_1 | \e[38;2;255;0;1m | - | fg=0xFF0001 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_1 | \e[48;2;255;0;1m | - | bg=0xFF0001 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_1 | \e[58;2;255;0;1m | - | sp=0xFF0001 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_1 | \e[38:2::255:0:1m | - | fg=0xFF0001 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_1 | \e[48:2::255:0:1m | - | bg=0xFF0001 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_1 | \e[58:2::255:0:1m | - | sp=0xFF0001 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_127 | \e[38;2;255;0;127m | - | fg=0xFF007F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_127 | \e[48;2;255;0;127m | - | bg=0xFF007F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_127 | \e[58;2;255;0;127m | - | sp=0xFF007F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_127 | \e[38:2::255:0:127m | - | fg=0xFF007F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_127 | \e[48:2::255:0:127m | - | bg=0xFF007F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_127 | \e[58:2::255:0:127m | - | sp=0xFF007F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_128 | \e[38;2;255;0;128m | - | fg=0xFF0080 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_128 | \e[48;2;255;0;128m | - | bg=0xFF0080 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_128 | \e[58;2;255;0;128m | - | sp=0xFF0080 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_128 | \e[38:2::255:0:128m | - | fg=0xFF0080 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_128 | \e[48:2::255:0:128m | - | bg=0xFF0080 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_128 | \e[58:2::255:0:128m | - | sp=0xFF0080 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_254 | \e[38;2;255;0;254m | - | fg=0xFF00FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_254 | \e[48;2;255;0;254m | - | bg=0xFF00FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_254 | \e[58;2;255;0;254m | - | sp=0xFF00FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_254 | \e[38:2::255:0:254m | - | fg=0xFF00FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_254 | \e[48:2::255:0:254m | - | bg=0xFF00FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_254 | \e[58:2::255:0:254m | - | sp=0xFF00FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_0_255 | \e[38;2;255;0;255m | - | fg=0xFF00FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_0_255 | \e[48;2;255;0;255m | - | bg=0xFF00FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_0_255 | \e[58;2;255;0;255m | - | sp=0xFF00FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_0_255 | \e[38:2::255:0:255m | - | fg=0xFF00FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_0_255 | \e[48:2::255:0:255m | - | bg=0xFF00FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_0_255 | \e[58:2::255:0:255m | - | sp=0xFF00FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_0 | \e[38;2;255;1;0m | - | fg=0xFF0100 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_0 | \e[48;2;255;1;0m | - | bg=0xFF0100 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_0 | \e[58;2;255;1;0m | - | sp=0xFF0100 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_0 | \e[38:2::255:1:0m | - | fg=0xFF0100 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_0 | \e[48:2::255:1:0m | - | bg=0xFF0100 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_0 | \e[58:2::255:1:0m | - | sp=0xFF0100 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_1 | \e[38;2;255;1;1m | - | fg=0xFF0101 | 0 | 15 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_1 | \e[48;2;255;1;1m | - | bg=0xFF0101 | 0 | 15 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_1 | \e[58;2;255;1;1m | - | sp=0xFF0101 | 0 | 15 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_1 | \e[38:2::255:1:1m | - | fg=0xFF0101 | 0 | 16 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_1 | \e[48:2::255:1:1m | - | bg=0xFF0101 | 0 | 16 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_1 | \e[58:2::255:1:1m | - | sp=0xFF0101 | 0 | 16 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_127 | \e[38;2;255;1;127m | - | fg=0xFF017F | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_127 | \e[48;2;255;1;127m | - | bg=0xFF017F | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_127 | \e[58;2;255;1;127m | - | sp=0xFF017F | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_127 | \e[38:2::255:1:127m | - | fg=0xFF017F | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_127 | \e[48:2::255:1:127m | - | bg=0xFF017F | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_127 | \e[58:2::255:1:127m | - | sp=0xFF017F | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_128 | \e[38;2;255;1;128m | - | fg=0xFF0180 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_128 | \e[48;2;255;1;128m | - | bg=0xFF0180 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_128 | \e[58;2;255;1;128m | - | sp=0xFF0180 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_128 | \e[38:2::255:1:128m | - | fg=0xFF0180 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_128 | \e[48:2::255:1:128m | - | bg=0xFF0180 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_128 | \e[58:2::255:1:128m | - | sp=0xFF0180 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_254 | \e[38;2;255;1;254m | - | fg=0xFF01FE | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_254 | \e[48;2;255;1;254m | - | bg=0xFF01FE | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_254 | \e[58;2;255;1;254m | - | sp=0xFF01FE | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_254 | \e[38:2::255:1:254m | - | fg=0xFF01FE | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_254 | \e[48:2::255:1:254m | - | bg=0xFF01FE | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_254 | \e[58:2::255:1:254m | - | sp=0xFF01FE | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_1_255 | \e[38;2;255;1;255m | - | fg=0xFF01FF | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_1_255 | \e[48;2;255;1;255m | - | bg=0xFF01FF | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_1_255 | \e[58;2;255;1;255m | - | sp=0xFF01FF | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_1_255 | \e[38:2::255:1:255m | - | fg=0xFF01FF | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_1_255 | \e[48:2::255:1:255m | - | bg=0xFF01FF | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_1_255 | \e[58:2::255:1:255m | - | sp=0xFF01FF | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_0 | \e[38;2;255;127;0m | - | fg=0xFF7F00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_0 | \e[48;2;255;127;0m | - | bg=0xFF7F00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_0 | \e[58;2;255;127;0m | - | sp=0xFF7F00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_0 | \e[38:2::255:127:0m | - | fg=0xFF7F00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_0 | \e[48:2::255:127:0m | - | bg=0xFF7F00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_0 | \e[58:2::255:127:0m | - | sp=0xFF7F00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_1 | \e[38;2;255;127;1m | - | fg=0xFF7F01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_1 | \e[48;2;255;127;1m | - | bg=0xFF7F01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_1 | \e[58;2;255;127;1m | - | sp=0xFF7F01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_1 | \e[38:2::255:127:1m | - | fg=0xFF7F01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_1 | \e[48:2::255:127:1m | - | bg=0xFF7F01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_1 | \e[58:2::255:127:1m | - | sp=0xFF7F01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_127 | \e[38;2;255;127;127m | - | fg=0xFF7F7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_127 | \e[48;2;255;127;127m | - | bg=0xFF7F7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_127 | \e[58;2;255;127;127m | - | sp=0xFF7F7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_127 | \e[38:2::255:127:127m | - | fg=0xFF7F7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_127 | \e[48:2::255:127:127m | - | bg=0xFF7F7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_127 | \e[58:2::255:127:127m | - | sp=0xFF7F7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_128 | \e[38;2;255;127;128m | - | fg=0xFF7F80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_128 | \e[48;2;255;127;128m | - | bg=0xFF7F80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_128 | \e[58;2;255;127;128m | - | sp=0xFF7F80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_128 | \e[38:2::255:127:128m | - | fg=0xFF7F80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_128 | \e[48:2::255:127:128m | - | bg=0xFF7F80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_128 | \e[58:2::255:127:128m | - | sp=0xFF7F80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_254 | \e[38;2;255;127;254m | - | fg=0xFF7FFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_254 | \e[48;2;255;127;254m | - | bg=0xFF7FFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_254 | \e[58;2;255;127;254m | - | sp=0xFF7FFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_254 | \e[38:2::255:127:254m | - | fg=0xFF7FFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_254 | \e[48:2::255:127:254m | - | bg=0xFF7FFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_254 | \e[58:2::255:127:254m | - | sp=0xFF7FFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_127_255 | \e[38;2;255;127;255m | - | fg=0xFF7FFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_127_255 | \e[48;2;255;127;255m | - | bg=0xFF7FFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_127_255 | \e[58;2;255;127;255m | - | sp=0xFF7FFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_127_255 | \e[38:2::255:127:255m | - | fg=0xFF7FFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_127_255 | \e[48:2::255:127:255m | - | bg=0xFF7FFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_127_255 | \e[58:2::255:127:255m | - | sp=0xFF7FFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_0 | \e[38;2;255;128;0m | - | fg=0xFF8000 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_0 | \e[48;2;255;128;0m | - | bg=0xFF8000 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_0 | \e[58;2;255;128;0m | - | sp=0xFF8000 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_0 | \e[38:2::255:128:0m | - | fg=0xFF8000 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_0 | \e[48:2::255:128:0m | - | bg=0xFF8000 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_0 | \e[58:2::255:128:0m | - | sp=0xFF8000 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_1 | \e[38;2;255;128;1m | - | fg=0xFF8001 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_1 | \e[48;2;255;128;1m | - | bg=0xFF8001 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_1 | \e[58;2;255;128;1m | - | sp=0xFF8001 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_1 | \e[38:2::255:128:1m | - | fg=0xFF8001 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_1 | \e[48:2::255:128:1m | - | bg=0xFF8001 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_1 | \e[58:2::255:128:1m | - | sp=0xFF8001 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_127 | \e[38;2;255;128;127m | - | fg=0xFF807F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_127 | \e[48;2;255;128;127m | - | bg=0xFF807F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_127 | \e[58;2;255;128;127m | - | sp=0xFF807F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_127 | \e[38:2::255:128:127m | - | fg=0xFF807F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_127 | \e[48:2::255:128:127m | - | bg=0xFF807F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_127 | \e[58:2::255:128:127m | - | sp=0xFF807F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_128 | \e[38;2;255;128;128m | - | fg=0xFF8080 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_128 | \e[48;2;255;128;128m | - | bg=0xFF8080 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_128 | \e[58;2;255;128;128m | - | sp=0xFF8080 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_128 | \e[38:2::255:128:128m | - | fg=0xFF8080 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_128 | \e[48:2::255:128:128m | - | bg=0xFF8080 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_128 | \e[58:2::255:128:128m | - | sp=0xFF8080 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_254 | \e[38;2;255;128;254m | - | fg=0xFF80FE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_254 | \e[48;2;255;128;254m | - | bg=0xFF80FE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_254 | \e[58;2;255;128;254m | - | sp=0xFF80FE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_254 | \e[38:2::255:128:254m | - | fg=0xFF80FE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_254 | \e[48:2::255:128:254m | - | bg=0xFF80FE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_254 | \e[58:2::255:128:254m | - | sp=0xFF80FE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_128_255 | \e[38;2;255;128;255m | - | fg=0xFF80FF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_128_255 | \e[48;2;255;128;255m | - | bg=0xFF80FF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_128_255 | \e[58;2;255;128;255m | - | sp=0xFF80FF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_128_255 | \e[38:2::255:128:255m | - | fg=0xFF80FF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_128_255 | \e[48:2::255:128:255m | - | bg=0xFF80FF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_128_255 | \e[58:2::255:128:255m | - | sp=0xFF80FF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_0 | \e[38;2;255;254;0m | - | fg=0xFFFE00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_0 | \e[48;2;255;254;0m | - | bg=0xFFFE00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_0 | \e[58;2;255;254;0m | - | sp=0xFFFE00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_0 | \e[38:2::255:254:0m | - | fg=0xFFFE00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_0 | \e[48:2::255:254:0m | - | bg=0xFFFE00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_0 | \e[58:2::255:254:0m | - | sp=0xFFFE00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_1 | \e[38;2;255;254;1m | - | fg=0xFFFE01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_1 | \e[48;2;255;254;1m | - | bg=0xFFFE01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_1 | \e[58;2;255;254;1m | - | sp=0xFFFE01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_1 | \e[38:2::255:254:1m | - | fg=0xFFFE01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_1 | \e[48:2::255:254:1m | - | bg=0xFFFE01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_1 | \e[58:2::255:254:1m | - | sp=0xFFFE01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_127 | \e[38;2;255;254;127m | - | fg=0xFFFE7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_127 | \e[48;2;255;254;127m | - | bg=0xFFFE7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_127 | \e[58;2;255;254;127m | - | sp=0xFFFE7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_127 | \e[38:2::255:254:127m | - | fg=0xFFFE7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_127 | \e[48:2::255:254:127m | - | bg=0xFFFE7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_127 | \e[58:2::255:254:127m | - | sp=0xFFFE7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_128 | \e[38;2;255;254;128m | - | fg=0xFFFE80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_128 | \e[48;2;255;254;128m | - | bg=0xFFFE80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_128 | \e[58;2;255;254;128m | - | sp=0xFFFE80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_128 | \e[38:2::255:254:128m | - | fg=0xFFFE80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_128 | \e[48:2::255:254:128m | - | bg=0xFFFE80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_128 | \e[58:2::255:254:128m | - | sp=0xFFFE80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_254 | \e[38;2;255;254;254m | - | fg=0xFFFEFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_254 | \e[48;2;255;254;254m | - | bg=0xFFFEFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_254 | \e[58;2;255;254;254m | - | sp=0xFFFEFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_254 | \e[38:2::255:254:254m | - | fg=0xFFFEFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_254 | \e[48:2::255:254:254m | - | bg=0xFFFEFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_254 | \e[58:2::255:254:254m | - | sp=0xFFFEFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_254_255 | \e[38;2;255;254;255m | - | fg=0xFFFEFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_254_255 | \e[48;2;255;254;255m | - | bg=0xFFFEFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_254_255 | \e[58;2;255;254;255m | - | sp=0xFFFEFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_254_255 | \e[38:2::255:254:255m | - | fg=0xFFFEFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_254_255 | \e[48:2::255:254:255m | - | bg=0xFFFEFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_254_255 | \e[58:2::255:254:255m | - | sp=0xFFFEFF | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_0 | \e[38;2;255;255;0m | - | fg=0xFFFF00 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_0 | \e[48;2;255;255;0m | - | bg=0xFFFF00 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_0 | \e[58;2;255;255;0m | - | sp=0xFFFF00 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_0 | \e[38:2::255:255:0m | - | fg=0xFFFF00 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_0 | \e[48:2::255:255:0m | - | bg=0xFFFF00 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_0 | \e[58:2::255:255:0m | - | sp=0xFFFF00 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_1 | \e[38;2;255;255;1m | - | fg=0xFFFF01 | 0 | 17 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_1 | \e[48;2;255;255;1m | - | bg=0xFFFF01 | 0 | 17 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_1 | \e[58;2;255;255;1m | - | sp=0xFFFF01 | 0 | 17 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_1 | \e[38:2::255:255:1m | - | fg=0xFFFF01 | 0 | 18 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_1 | \e[48:2::255:255:1m | - | bg=0xFFFF01 | 0 | 18 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_1 | \e[58:2::255:255:1m | - | sp=0xFFFF01 | 0 | 18 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_127 | \e[38;2;255;255;127m | - | fg=0xFFFF7F | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_127 | \e[48;2;255;255;127m | - | bg=0xFFFF7F | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_127 | \e[58;2;255;255;127m | - | sp=0xFFFF7F | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_127 | \e[38:2::255:255:127m | - | fg=0xFFFF7F | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_127 | \e[48:2::255:255:127m | - | bg=0xFFFF7F | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_127 | \e[58:2::255:255:127m | - | sp=0xFFFF7F | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_128 | \e[38;2;255;255;128m | - | fg=0xFFFF80 | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_128 | \e[48;2;255;255;128m | - | bg=0xFFFF80 | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_128 | \e[58;2;255;255;128m | - | sp=0xFFFF80 | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_128 | \e[38:2::255:255:128m | - | fg=0xFFFF80 | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_128 | \e[48:2::255:255:128m | - | bg=0xFFFF80 | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_128 | \e[58:2::255:255:128m | - | sp=0xFFFF80 | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_254 | \e[38;2;255;255;254m | - | fg=0xFFFFFE | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_254 | \e[48;2;255;255;254m | - | bg=0xFFFFFE | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_254 | \e[58;2;255;255;254m | - | sp=0xFFFFFE | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_254 | \e[38:2::255:255:254m | - | fg=0xFFFFFE | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_254 | \e[48:2::255:255:254m | - | bg=0xFFFFFE | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_254 | \e[58:2::255:255:254m | - | sp=0xFFFFFE | 0 | 20 | T.416 truecolor underline boundary grid
sgr | rgb_grid_255_255_255 | \e[38;2;255;255;255m | - | fg=0xFFFFFF | 0 | 19 | xterm truecolor foreground boundary grid
sgr | rgb_grid_bg_255_255_255 | \e[48;2;255;255;255m | - | bg=0xFFFFFF | 0 | 19 | xterm truecolor background boundary grid
sgr | rgb_grid_sp_255_255_255 | \e[58;2;255;255;255m | - | sp=0xFFFFFF | 0 | 19 | xterm truecolor underline boundary grid
sgr | iso_rgb_grid_255_255_255 | \e[38:2::255:255:255m | - | fg=0xFFFFFF | 0 | 20 | T.416 truecolor foreground boundary grid
sgr | iso_rgb_grid_bg_255_255_255 | \e[48:2::255:255:255m | - | bg=0xFFFFFF | 0 | 20 | T.416 truecolor background boundary grid
sgr | iso_rgb_grid_sp_255_255_255 | \e[58:2::255:255:255m | - | sp=0xFFFFFF | 0 | 20 | T.416 truecolor underline boundary grid

## sgr ISO indexed and RGB
sgr | empty_csid | \e[38:2::255:128:64m | - | fg=0xFF8040 | 0 | 19 | standard RGB form
sgr | csid_zero | \e[38:2:0:255:128:64m | - | fg=0xFF8040 | 0 | 20 | explicit colour space 0
sgr | csid_one | \e[38:2:1:12:34:56m | - | fg=0x0C2238 | 0 | 18 | explicit colour space 1
sgr | csid_large | \e[38:2:9999:12:34:56m | - | fg=0x0C2238 | 0 | 21 | CSID is not channel-limited
sgr | csid_is_not_red | \e[38:2:1:2:3m | - | fg=0x020300 | 0 | 13 | CSID=1, R=2, G=3, B default 0
sgr | csid_is_not_red_2 | \e[38:2:255:128:64m | - | fg=0x804000 | 0 | 18 | CSID slot is skipped
sgr | empty_channels | \e[38:2::m | - | fg=0x000000 | 0 | 9 | empty channels default to 0
sgr | one_channel | \e[38:2::255m | - | fg=0xFF0000 | 0 | 12 | trailing G and B default to 0
sgr | two_channels | \e[38:2::255:128m | - | fg=0xFF8000 | 0 | 16 | trailing B defaults to 0
sgr | empty_middle | \e[38:2::255::64m | - | fg=0xFF0040 | 0 | 16 | empty G defaults to 0
sgr | empty_red | \e[38:2::::64m | - | fg=0x000040 | 0 | 13 | empty R and G default to 0
sgr | mode_only | \e[38:2m | - | fg=0x000000 | 0 | 7 | all elements default to 0
sgr | csid_only | \e[38:2:7m | - | fg=0x000000 | 0 | 9 | channels default to 0
sgr | followed_by_bg | \e[38:2::1:2:3;44m | - | fg=0x010203,bg=0x0000EE | 0 | 17 | ISO color followed by ANSI bg
sgr | pe6 | \e[38:2::1:2:3:0m | - | fg=0x010203 | 0 | 16 | PE6 has no meaning
sgr | pe7 | \e[38:2::1:2:3:0:5m | - | fg=0x010203 | 0 | 18 | PE7 tolerance consumed
sgr | pe8_cieluv | \e[38:2::1:2:3:0:0:0m | - | fg=0x010203 | 0 | 20 | PE8 CIELUV
sgr | pe8_cielab | \e[38:2::1:2:3:0:0:1m | - | fg=0x010203 | 0 | 20 | PE8 CIELAB
sgr | bg_empty_csid | \e[48:2::253:200:15m | - | bg=0xFDC80F | 0 | 19 | background RGB
sgr | sp_empty_csid | \e[58:2::81:155:120m | - | sp=0x519B78 | 0 | 19 | underline RGB
sgr | index_0 | \e[38:5:0m | - | fg=0x000000 | 0 | 9 | first palette entry
sgr | index_255 | \e[38:5:255m | - | fg=0xEEEEEE | 0 | 11 | last palette entry
sgr | index_196 | \e[38:5:196m | - | fg=0xFF0000 | 0 | 11 | cube red
sgr | index_empty | \e[38:5:m | - | fg=0x000000 | 0 | 8 | empty element defaults to 0
sgr | index_mode_only | \e[38:5m | - | fg=0x000000 | 0 | 7 | omitted element defaults to 0
sgr | index_followed_by_bg | \e[38:5;44m | - | fg=0x000000,bg=0x0000EE | 0 | 10 | semicolon starts new parameter

## sgr ISO CMY and CMYK
sgr | cmy_zero | \e[38:3::0:0:0m | - | fg=0xFFFFFF | 0 | 14 | no ink
sgr | cmy_full | \e[38:3::255:255:255m | - | fg=0x000000 | 0 | 20 | full ink
sgr | cmy_red | \e[38:3::0:255:255m | - | fg=0xFF0000 | 0 | 18 | red
sgr | cmy_green | \e[38:3::255:0:255m | - | fg=0x00FF00 | 0 | 18 | green
sgr | cmy_blue | \e[38:3::255:255:0m | - | fg=0x0000FF | 0 | 18 | blue
sgr | cmy_arbitrary | \e[38:3::1:2:3m | - | fg=0xFEFDFC | 0 | 14 | inverted components
sgr | cmy_defaults | \e[38:3::m | - | fg=0xFFFFFF | 0 | 9 | empty components default to 0
sgr | cmy_mode_only | \e[38:3m | - | fg=0xFFFFFF | 0 | 7 | omitted components default to 0
sgr | cmy_numeric_csid | \e[38:3:7:0:255:255m | - | fg=0xFF0000 | 0 | 19 | numeric colour space
sgr | cmyk_zero | \e[38:4::0:0:0:0m | - | fg=0xFFFFFF | 0 | 16 | no ink
sgr | cmyk_black_by_k | \e[38:4::0:0:0:255m | - | fg=0x000000 | 0 | 18 | full K
sgr | cmyk_black_by_cmy | \e[38:4::255:255:255:0m | - | fg=0x000000 | 0 | 22 | full C, M and Y
sgr | cmyk_arbitrary | \e[38:4::0:128:255:64m | - | fg=0xBF5F00 | 0 | 21 | mixed CMYK
sgr | cmyk_arbitrary_2 | \e[38:4::255:0:0:128m | - | fg=0x007F7F | 0 | 20 | mixed CMYK
sgr | cmyk_defaults | \e[38:4::m | - | fg=0xFFFFFF | 0 | 9 | empty components default to 0
sgr | cmyk_mode_only | \e[38:4m | - | fg=0xFFFFFF | 0 | 7 | omitted components default to 0
sgr | cmy_bg | \e[48:3::0:255:255m | - | bg=0xFF0000 | 0 | 18 | CMY background
sgr | cmy_sp | \e[58:3::0:255:255m | - | sp=0xFF0000 | 0 | 18 | CMY underline
sgr | cmyk_bg | \e[48:4::0:128:255:64m | - | bg=0xBF5F00 | 0 | 21 | CMYK background
sgr | cmyk_sp | \e[58:4::0:128:255:64m | - | sp=0xBF5F00 | 0 | 21 | CMYK underline

## sgr ISO modes and compatibility
sgr | mode0 | \e[38:0m | - | - | - | - | implementation-defined, no RGB conversion
sgr | mode0_bg | \e[48:0:1:2:3m | - | - | - | - | mode 0 has no extra elements
sgr | mode1_fg | \e[38:1m | - | fg=NONE | 0 | 7 | transparent foreground
sgr | mode1_bg | \e[48:1m | - | bg=NONE | 0 | 7 | transparent background
sgr | mode1_sp | \e[58:1m | - | sp=NONE | 0 | 7 | transparent underline
sgr | mode0_extra_consumed | \e[31;38:0:1:2:3;44m | - | fg=0xCD0000,bg=0x0000EE | 0 | 19 | extra elements do not leak
sgr | mode1_extra_consumed | \e[31;38:1:1:2:3;44m | - | fg=0xCD0000,bg=0x0000EE | 0 | 19 | extra elements do not leak
sgr | mode1_followed_by_bg | \e[38:1;44m | - | fg=NONE,bg=0x0000EE | 0 | 10 | transparent fg with ANSI bg
sgr | compat_csid_0 | \e[38;2:0:255:128:64m | - | fg=0xFF8040 | 0 | 20 | xterm/ISO mixed form
sgr | compat_csid_1_bg | \e[48;2:1:12:34:56m | - | bg=0x0C2238 | 0 | 18 | xterm/ISO mixed form
sgr | compat_csid_0_sp | \e[58;2:0:1:2:3m | - | sp=0x010203 | 0 | 15 | xterm/ISO mixed form
sgr | compat_followed_by_bg | \e[38;2:0:255:128:64;44m | - | fg=0xFF8040,bg=0x0000EE | 0 | 23 | following SGR remains available

## sgr invalid and preserved colors
sgr | index_256 | \e[38;5;256m | - | - | - | - | index above 255
sgr | colon_index_256 | \e[38:5:256m | - | - | - | - | index above 255
sgr | red_256 | \e[38;2;256;0;0m | - | - | - | - | channel above 255
sgr | green_256 | \e[38;2;0;256;0m | - | - | - | - | channel above 255
sgr | blue_256 | \e[38;2;0;0;256m | - | - | - | - | channel above 255
sgr | colon_red_256 | \e[38:2::256:0:0m | - | - | - | - | channel above 255
sgr | colon_green_256 | \e[38:2::0:256:0m | - | - | - | - | channel above 255
sgr | colon_blue_256 | \e[38:2::0:0:256m | - | - | - | - | channel above 255
sgr | missing_blue | \e[38;2;255;128m | - | - | - | - | incomplete xterm RGB
sgr | empty_index | \e[38;5;m | - | - | - | - | empty xterm index
sgr | extra_index | \e[38:5:1:2m | - | - | - | - | too many ISO index fields
sgr | extra_rgb | \e[38:2::1:2:3:0:0:1:2m | - | - | - | - | too many ISO RGB fields
sgr | bad_pe8 | \e[38:2::1:2:3:0:0:2m | - | - | - | - | PE8 must be 0 or 1
sgr | unknown_mode | \e[38:9:1:2:3m | - | - | - | - | unsupported ISO mode
sgr | non_digit | \e[38;2;1;x;3m | - | - | - | - | non-decimal parameter
sgr | trailing_colon | \e[38:m | - | - | - | - | mode missing
sgr | double_colon_mode | \e[38::5:1m | - | - | - | - | empty mode
sgr | arabic_digits | \e[\xD9\xA3\xD9\xA1m | - | - | - | - | only ASCII digits match
sgr | preserve_fg | \e[31;38:2::256:0:0m | - | fg=0xCD0000 | 0 | 19 | bad RGB does not clear ANSI fg
sgr | preserve_bg | \e[44;38;5;256m | - | bg=0x0000EE | 0 | 14 | bad index does not clear ANSI bg
sgr | preserve_sp | \e[58;5;21;58;5;256m | - | sp=0x0000FF | 0 | 19 | bad underline does not clear sp

## sgr introducers
sgr | introducer_literal_033 | \\033[31m | - | fg=0xCD0000 | 0 | 8 | literal Lua-style ESC
sgr | introducer_literal_027 | \\027[1;34m | - | fg=0x0000EE | 0 | 10 | decimal-style ESC
sgr | introducer_literal_27 | \\27[31m | - | fg=0xCD0000 | 0 | 7 | short decimal ESC
sgr | introducer_literal_x1b | \\x1b[31m | - | fg=0xCD0000 | 0 | 8 | lowercase hex ESC
sgr | introducer_literal_x1B | \\x1B[31m | - | fg=0xCD0000 | 0 | 8 | uppercase hex ESC
sgr | introducer_literal_e | \\e[31m | - | fg=0xCD0000 | 0 | 6 | literal caret-style ESC
sgr | introducer_literal_E | \\E[31m | - | fg=0xCD0000 | 0 | 6 | uppercase literal ESC
sgr | introducer_literal_u001b | \\u001b[31m | - | fg=0xCD0000 | 0 | 10 | unicode escape
sgr | introducer_literal_u001B | \\u001B[31m | - | fg=0xCD0000 | 0 | 10 | uppercase unicode escape
sgr | introducer_literal_u_braces | \\u{1b}[31m | - | fg=0xCD0000 | 0 | 10 | braced unicode escape
sgr | introducer_literal_u_braces_upper | \\u{1B}[31m | - | fg=0xCD0000 | 0 | 10 | uppercase braced unicode escape
sgr | introducer_literal_x_braces | \\x{1b}[31m | - | fg=0xCD0000 | 0 | 10 | braced hex escape
sgr | introducer_literal_x_braces_upper | \\x{1B}[31m | - | fg=0xCD0000 | 0 | 10 | uppercase braced hex escape
sgr | introducer_literal_caret | ^[[31m | - | fg=0xCD0000 | 0 | 6 | caret notation
sgr | introducer_literal_c1_9b | \\x9b31m | - | fg=0xCD0000 | 0 | 7 | literal C1 CSI without bracket
sgr | introducer_literal_c1_9B | \\x9B31m | - | fg=0xCD0000 | 0 | 7 | uppercase literal C1 CSI
sgr | introducer_literal_c1_u009b | \\u009b31m | - | fg=0xCD0000 | 0 | 9 | unicode C1 CSI
sgr | introducer_literal_c1_u009B | \\u009B31m | - | fg=0xCD0000 | 0 | 9 | uppercase unicode C1 CSI
sgr | introducer_literal_c1_u_braces | \\u{9b}31m | - | fg=0xCD0000 | 0 | 9 | braced unicode C1 CSI
sgr | introducer_literal_c1_u_braces_upper | \\u{9B}31m | - | fg=0xCD0000 | 0 | 9 | uppercase braced unicode C1 CSI
sgr | introducer_literal_c1_x_braces | \\x{9b}31m | - | fg=0xCD0000 | 0 | 9 | braced hex C1 CSI
sgr | introducer_literal_c1_x_braces_upper | \\x{9B}31m | - | fg=0xCD0000 | 0 | 9 | uppercase braced hex C1 CSI
sgr | introducer_utf8_csi | \xC2\x9B31m | - | fg=0xCD0000 | 0 | 5 | UTF-8 encoded C1 CSI
sgr | introducer_offset | before \e[31m after | - | fg=0xCD0000 | 7 | 12 | sequence inside a line

## tailwind parser
tailwind | palette_black | bg-black | - | 0x000000 | 0 | 8 | bg utility
tailwind | palette_white | bg-white | - | 0xFFFFFF | 0 | 8 | bg utility
tailwind | palette_slate_50 | bg-slate-50 | - | 0xF8FAFC | 0 | 11 | bg utility
tailwind | palette_slate_100 | bg-slate-100 | - | 0xF1F5F9 | 0 | 12 | bg utility
tailwind | palette_slate_200 | bg-slate-200 | - | 0xE2E8F0 | 0 | 12 | bg utility
tailwind | palette_slate_300 | bg-slate-300 | - | 0xCBD5E1 | 0 | 12 | bg utility
tailwind | palette_slate_400 | bg-slate-400 | - | 0x94A3B8 | 0 | 12 | bg utility
tailwind | palette_slate_500 | bg-slate-500 | - | 0x64748B | 0 | 12 | bg utility
tailwind | palette_slate_600 | bg-slate-600 | - | 0x475569 | 0 | 12 | bg utility
tailwind | palette_slate_700 | bg-slate-700 | - | 0x334155 | 0 | 12 | bg utility
tailwind | palette_slate_800 | bg-slate-800 | - | 0x1E293B | 0 | 12 | bg utility
tailwind | palette_slate_900 | bg-slate-900 | - | 0x0F172A | 0 | 12 | bg utility
tailwind | palette_gray_50 | bg-gray-50 | - | 0xF9FAFB | 0 | 10 | bg utility
tailwind | palette_gray_100 | bg-gray-100 | - | 0xF3F4F6 | 0 | 11 | bg utility
tailwind | palette_gray_200 | bg-gray-200 | - | 0xE5E7EB | 0 | 11 | bg utility
tailwind | palette_gray_300 | bg-gray-300 | - | 0xD1D5DB | 0 | 11 | bg utility
tailwind | palette_gray_400 | bg-gray-400 | - | 0x9CA3AF | 0 | 11 | bg utility
tailwind | palette_gray_500 | bg-gray-500 | - | 0x6B7280 | 0 | 11 | bg utility
tailwind | palette_gray_600 | bg-gray-600 | - | 0x4B5563 | 0 | 11 | bg utility
tailwind | palette_gray_700 | bg-gray-700 | - | 0x374151 | 0 | 11 | bg utility
tailwind | palette_gray_800 | bg-gray-800 | - | 0x1F2937 | 0 | 11 | bg utility
tailwind | palette_gray_900 | bg-gray-900 | - | 0x111827 | 0 | 11 | bg utility
tailwind | palette_zinc_50 | bg-zinc-50 | - | 0xFAFAFA | 0 | 10 | bg utility
tailwind | palette_zinc_100 | bg-zinc-100 | - | 0xF4F4F5 | 0 | 11 | bg utility
tailwind | palette_zinc_200 | bg-zinc-200 | - | 0xE4E4E7 | 0 | 11 | bg utility
tailwind | palette_zinc_300 | bg-zinc-300 | - | 0xD4D4D8 | 0 | 11 | bg utility
tailwind | palette_zinc_400 | bg-zinc-400 | - | 0xA1A1AA | 0 | 11 | bg utility
tailwind | palette_zinc_500 | bg-zinc-500 | - | 0x71717A | 0 | 11 | bg utility
tailwind | palette_zinc_600 | bg-zinc-600 | - | 0x52525B | 0 | 11 | bg utility
tailwind | palette_zinc_700 | bg-zinc-700 | - | 0x3F3F46 | 0 | 11 | bg utility
tailwind | palette_zinc_800 | bg-zinc-800 | - | 0x27272A | 0 | 11 | bg utility
tailwind | palette_zinc_900 | bg-zinc-900 | - | 0x18181B | 0 | 11 | bg utility
tailwind | palette_neutral_50 | bg-neutral-50 | - | 0xFAFAFA | 0 | 13 | bg utility
tailwind | palette_neutral_100 | bg-neutral-100 | - | 0xF5F5F5 | 0 | 14 | bg utility
tailwind | palette_neutral_200 | bg-neutral-200 | - | 0xE5E5E5 | 0 | 14 | bg utility
tailwind | palette_neutral_300 | bg-neutral-300 | - | 0xD4D4D4 | 0 | 14 | bg utility
tailwind | palette_neutral_400 | bg-neutral-400 | - | 0xA3A3A3 | 0 | 14 | bg utility
tailwind | palette_neutral_500 | bg-neutral-500 | - | 0x737373 | 0 | 14 | bg utility
tailwind | palette_neutral_600 | bg-neutral-600 | - | 0x525252 | 0 | 14 | bg utility
tailwind | palette_neutral_700 | bg-neutral-700 | - | 0x404040 | 0 | 14 | bg utility
tailwind | palette_neutral_800 | bg-neutral-800 | - | 0x262626 | 0 | 14 | bg utility
tailwind | palette_neutral_900 | bg-neutral-900 | - | 0x171717 | 0 | 14 | bg utility
tailwind | palette_stone_50 | bg-stone-50 | - | 0xFAFAF9 | 0 | 11 | bg utility
tailwind | palette_stone_100 | bg-stone-100 | - | 0xF5F5F4 | 0 | 12 | bg utility
tailwind | palette_stone_200 | bg-stone-200 | - | 0xE7E5E4 | 0 | 12 | bg utility
tailwind | palette_stone_300 | bg-stone-300 | - | 0xD6D3D1 | 0 | 12 | bg utility
tailwind | palette_stone_400 | bg-stone-400 | - | 0xA8A29E | 0 | 12 | bg utility
tailwind | palette_stone_500 | bg-stone-500 | - | 0x78716C | 0 | 12 | bg utility
tailwind | palette_stone_600 | bg-stone-600 | - | 0x57534E | 0 | 12 | bg utility
tailwind | palette_stone_700 | bg-stone-700 | - | 0x44403C | 0 | 12 | bg utility
tailwind | palette_stone_800 | bg-stone-800 | - | 0x292524 | 0 | 12 | bg utility
tailwind | palette_stone_900 | bg-stone-900 | - | 0x1C1917 | 0 | 12 | bg utility
tailwind | palette_red_50 | bg-red-50 | - | 0xFEF2F2 | 0 | 9 | bg utility
tailwind | palette_red_100 | bg-red-100 | - | 0xFEE2E2 | 0 | 10 | bg utility
tailwind | palette_red_200 | bg-red-200 | - | 0xFECACA | 0 | 10 | bg utility
tailwind | palette_red_300 | bg-red-300 | - | 0xFCA5A5 | 0 | 10 | bg utility
tailwind | palette_red_400 | bg-red-400 | - | 0xF87171 | 0 | 10 | bg utility
tailwind | palette_red_500 | bg-red-500 | - | 0xEF4444 | 0 | 10 | bg utility
tailwind | palette_red_600 | bg-red-600 | - | 0xDC2626 | 0 | 10 | bg utility
tailwind | palette_red_700 | bg-red-700 | - | 0xB91C1C | 0 | 10 | bg utility
tailwind | palette_red_800 | bg-red-800 | - | 0x991B1B | 0 | 10 | bg utility
tailwind | palette_red_900 | bg-red-900 | - | 0x7F1D1D | 0 | 10 | bg utility
tailwind | palette_orange_50 | bg-orange-50 | - | 0xFFF7ED | 0 | 12 | bg utility
tailwind | palette_orange_100 | bg-orange-100 | - | 0xFFEDD5 | 0 | 13 | bg utility
tailwind | palette_orange_200 | bg-orange-200 | - | 0xFED7AA | 0 | 13 | bg utility
tailwind | palette_orange_300 | bg-orange-300 | - | 0xFDBA74 | 0 | 13 | bg utility
tailwind | palette_orange_400 | bg-orange-400 | - | 0xFB923C | 0 | 13 | bg utility
tailwind | palette_orange_500 | bg-orange-500 | - | 0xF97316 | 0 | 13 | bg utility
tailwind | palette_orange_600 | bg-orange-600 | - | 0xEA580C | 0 | 13 | bg utility
tailwind | palette_orange_700 | bg-orange-700 | - | 0xC2410C | 0 | 13 | bg utility
tailwind | palette_orange_800 | bg-orange-800 | - | 0x9A3412 | 0 | 13 | bg utility
tailwind | palette_orange_900 | bg-orange-900 | - | 0x7C2D12 | 0 | 13 | bg utility
tailwind | palette_amber_50 | bg-amber-50 | - | 0xFFFBEB | 0 | 11 | bg utility
tailwind | palette_amber_100 | bg-amber-100 | - | 0xFEF3C7 | 0 | 12 | bg utility
tailwind | palette_amber_200 | bg-amber-200 | - | 0xFDE68A | 0 | 12 | bg utility
tailwind | palette_amber_300 | bg-amber-300 | - | 0xFCD34D | 0 | 12 | bg utility
tailwind | palette_amber_400 | bg-amber-400 | - | 0xFBBF24 | 0 | 12 | bg utility
tailwind | palette_amber_500 | bg-amber-500 | - | 0xF59E0B | 0 | 12 | bg utility
tailwind | palette_amber_600 | bg-amber-600 | - | 0xD97706 | 0 | 12 | bg utility
tailwind | palette_amber_700 | bg-amber-700 | - | 0xB45309 | 0 | 12 | bg utility
tailwind | palette_amber_800 | bg-amber-800 | - | 0x92400E | 0 | 12 | bg utility
tailwind | palette_amber_900 | bg-amber-900 | - | 0x78350F | 0 | 12 | bg utility
tailwind | palette_yellow_50 | bg-yellow-50 | - | 0xFEFCE8 | 0 | 12 | bg utility
tailwind | palette_yellow_100 | bg-yellow-100 | - | 0xFEF9C3 | 0 | 13 | bg utility
tailwind | palette_yellow_200 | bg-yellow-200 | - | 0xFEF08A | 0 | 13 | bg utility
tailwind | palette_yellow_300 | bg-yellow-300 | - | 0xFDE047 | 0 | 13 | bg utility
tailwind | palette_yellow_400 | bg-yellow-400 | - | 0xFACC15 | 0 | 13 | bg utility
tailwind | palette_yellow_500 | bg-yellow-500 | - | 0xEAB308 | 0 | 13 | bg utility
tailwind | palette_yellow_600 | bg-yellow-600 | - | 0xCA8A04 | 0 | 13 | bg utility
tailwind | palette_yellow_700 | bg-yellow-700 | - | 0xA16207 | 0 | 13 | bg utility
tailwind | palette_yellow_800 | bg-yellow-800 | - | 0x854D0E | 0 | 13 | bg utility
tailwind | palette_yellow_900 | bg-yellow-900 | - | 0x713F12 | 0 | 13 | bg utility
tailwind | palette_lime_50 | bg-lime-50 | - | 0xF7FEE7 | 0 | 10 | bg utility
tailwind | palette_lime_100 | bg-lime-100 | - | 0xECFCCB | 0 | 11 | bg utility
tailwind | palette_lime_200 | bg-lime-200 | - | 0xD9F99D | 0 | 11 | bg utility
tailwind | palette_lime_300 | bg-lime-300 | - | 0xBEF264 | 0 | 11 | bg utility
tailwind | palette_lime_400 | bg-lime-400 | - | 0xA3E635 | 0 | 11 | bg utility
tailwind | palette_lime_500 | bg-lime-500 | - | 0x84CC16 | 0 | 11 | bg utility
tailwind | palette_lime_600 | bg-lime-600 | - | 0x65A30D | 0 | 11 | bg utility
tailwind | palette_lime_700 | bg-lime-700 | - | 0x4D7C0F | 0 | 11 | bg utility
tailwind | palette_lime_800 | bg-lime-800 | - | 0x3F6212 | 0 | 11 | bg utility
tailwind | palette_lime_900 | bg-lime-900 | - | 0x365314 | 0 | 11 | bg utility
tailwind | palette_green_50 | bg-green-50 | - | 0xF0FDF4 | 0 | 11 | bg utility
tailwind | palette_green_100 | bg-green-100 | - | 0xDCFCE7 | 0 | 12 | bg utility
tailwind | palette_green_200 | bg-green-200 | - | 0xBBF7D0 | 0 | 12 | bg utility
tailwind | palette_green_300 | bg-green-300 | - | 0x86EFAC | 0 | 12 | bg utility
tailwind | palette_green_400 | bg-green-400 | - | 0x4ADE80 | 0 | 12 | bg utility
tailwind | palette_green_500 | bg-green-500 | - | 0x22C55E | 0 | 12 | bg utility
tailwind | palette_green_600 | bg-green-600 | - | 0x16A34A | 0 | 12 | bg utility
tailwind | palette_green_700 | bg-green-700 | - | 0x15803D | 0 | 12 | bg utility
tailwind | palette_green_800 | bg-green-800 | - | 0x166534 | 0 | 12 | bg utility
tailwind | palette_green_900 | bg-green-900 | - | 0x14532D | 0 | 12 | bg utility
tailwind | palette_emerald_50 | bg-emerald-50 | - | 0xECFDF5 | 0 | 13 | bg utility
tailwind | palette_emerald_100 | bg-emerald-100 | - | 0xD1FAE5 | 0 | 14 | bg utility
tailwind | palette_emerald_200 | bg-emerald-200 | - | 0xA7F3D0 | 0 | 14 | bg utility
tailwind | palette_emerald_300 | bg-emerald-300 | - | 0x6EE7B7 | 0 | 14 | bg utility
tailwind | palette_emerald_400 | bg-emerald-400 | - | 0x34D399 | 0 | 14 | bg utility
tailwind | palette_emerald_500 | bg-emerald-500 | - | 0x10B981 | 0 | 14 | bg utility
tailwind | palette_emerald_600 | bg-emerald-600 | - | 0x059669 | 0 | 14 | bg utility
tailwind | palette_emerald_700 | bg-emerald-700 | - | 0x047857 | 0 | 14 | bg utility
tailwind | palette_emerald_800 | bg-emerald-800 | - | 0x065F46 | 0 | 14 | bg utility
tailwind | palette_emerald_900 | bg-emerald-900 | - | 0x064E3B | 0 | 14 | bg utility
tailwind | palette_teal_50 | bg-teal-50 | - | 0xF0FDFA | 0 | 10 | bg utility
tailwind | palette_teal_100 | bg-teal-100 | - | 0xCCFBF1 | 0 | 11 | bg utility
tailwind | palette_teal_200 | bg-teal-200 | - | 0x99F6E4 | 0 | 11 | bg utility
tailwind | palette_teal_300 | bg-teal-300 | - | 0x5EEAD4 | 0 | 11 | bg utility
tailwind | palette_teal_400 | bg-teal-400 | - | 0x2DD4BF | 0 | 11 | bg utility
tailwind | palette_teal_500 | bg-teal-500 | - | 0x14B8A6 | 0 | 11 | bg utility
tailwind | palette_teal_600 | bg-teal-600 | - | 0x0D9488 | 0 | 11 | bg utility
tailwind | palette_teal_700 | bg-teal-700 | - | 0x0F766E | 0 | 11 | bg utility
tailwind | palette_teal_800 | bg-teal-800 | - | 0x115E59 | 0 | 11 | bg utility
tailwind | palette_teal_900 | bg-teal-900 | - | 0x134E4A | 0 | 11 | bg utility
tailwind | palette_cyan_50 | bg-cyan-50 | - | 0xECFEFF | 0 | 10 | bg utility
tailwind | palette_cyan_100 | bg-cyan-100 | - | 0xCFFAFE | 0 | 11 | bg utility
tailwind | palette_cyan_200 | bg-cyan-200 | - | 0xA5F3FC | 0 | 11 | bg utility
tailwind | palette_cyan_300 | bg-cyan-300 | - | 0x67E8F9 | 0 | 11 | bg utility
tailwind | palette_cyan_400 | bg-cyan-400 | - | 0x22D3EE | 0 | 11 | bg utility
tailwind | palette_cyan_500 | bg-cyan-500 | - | 0x06B6D4 | 0 | 11 | bg utility
tailwind | palette_cyan_600 | bg-cyan-600 | - | 0x0891B2 | 0 | 11 | bg utility
tailwind | palette_cyan_700 | bg-cyan-700 | - | 0x0E7490 | 0 | 11 | bg utility
tailwind | palette_cyan_800 | bg-cyan-800 | - | 0x155E75 | 0 | 11 | bg utility
tailwind | palette_cyan_900 | bg-cyan-900 | - | 0x164E63 | 0 | 11 | bg utility
tailwind | palette_sky_50 | bg-sky-50 | - | 0xF0F9FF | 0 | 9 | bg utility
tailwind | palette_sky_100 | bg-sky-100 | - | 0xE0F2FE | 0 | 10 | bg utility
tailwind | palette_sky_200 | bg-sky-200 | - | 0xBAE6FD | 0 | 10 | bg utility
tailwind | palette_sky_300 | bg-sky-300 | - | 0x7DD3FC | 0 | 10 | bg utility
tailwind | palette_sky_400 | bg-sky-400 | - | 0x38BDF8 | 0 | 10 | bg utility
tailwind | palette_sky_500 | bg-sky-500 | - | 0x0EA5E9 | 0 | 10 | bg utility
tailwind | palette_sky_600 | bg-sky-600 | - | 0x0284C7 | 0 | 10 | bg utility
tailwind | palette_sky_700 | bg-sky-700 | - | 0x0369A1 | 0 | 10 | bg utility
tailwind | palette_sky_800 | bg-sky-800 | - | 0x075985 | 0 | 10 | bg utility
tailwind | palette_sky_900 | bg-sky-900 | - | 0x0C4A6E | 0 | 10 | bg utility
tailwind | palette_blue_50 | bg-blue-50 | - | 0xEFF6FF | 0 | 10 | bg utility
tailwind | palette_blue_100 | bg-blue-100 | - | 0xDBEAFE | 0 | 11 | bg utility
tailwind | palette_blue_200 | bg-blue-200 | - | 0xBFDBFE | 0 | 11 | bg utility
tailwind | palette_blue_300 | bg-blue-300 | - | 0x93C5FD | 0 | 11 | bg utility
tailwind | palette_blue_400 | bg-blue-400 | - | 0x60A5FA | 0 | 11 | bg utility
tailwind | palette_blue_500 | bg-blue-500 | - | 0x3B82F6 | 0 | 11 | bg utility
tailwind | palette_blue_600 | bg-blue-600 | - | 0x2563EB | 0 | 11 | bg utility
tailwind | palette_blue_700 | bg-blue-700 | - | 0x1D4ED8 | 0 | 11 | bg utility
tailwind | palette_blue_800 | bg-blue-800 | - | 0x1E40AF | 0 | 11 | bg utility
tailwind | palette_blue_900 | bg-blue-900 | - | 0x1E3A8A | 0 | 11 | bg utility
tailwind | palette_indigo_50 | bg-indigo-50 | - | 0xEEF2FF | 0 | 12 | bg utility
tailwind | palette_indigo_100 | bg-indigo-100 | - | 0xE0E7FF | 0 | 13 | bg utility
tailwind | palette_indigo_200 | bg-indigo-200 | - | 0xC7D2FE | 0 | 13 | bg utility
tailwind | palette_indigo_300 | bg-indigo-300 | - | 0xA5B4FC | 0 | 13 | bg utility
tailwind | palette_indigo_400 | bg-indigo-400 | - | 0x818CF8 | 0 | 13 | bg utility
tailwind | palette_indigo_500 | bg-indigo-500 | - | 0x6366F1 | 0 | 13 | bg utility
tailwind | palette_indigo_600 | bg-indigo-600 | - | 0x4F46E5 | 0 | 13 | bg utility
tailwind | palette_indigo_700 | bg-indigo-700 | - | 0x4338CA | 0 | 13 | bg utility
tailwind | palette_indigo_800 | bg-indigo-800 | - | 0x3730A3 | 0 | 13 | bg utility
tailwind | palette_indigo_900 | bg-indigo-900 | - | 0x312E81 | 0 | 13 | bg utility
tailwind | palette_violet_50 | bg-violet-50 | - | 0xF5F3FF | 0 | 12 | bg utility
tailwind | palette_violet_100 | bg-violet-100 | - | 0xEDE9FE | 0 | 13 | bg utility
tailwind | palette_violet_200 | bg-violet-200 | - | 0xDDD6FE | 0 | 13 | bg utility
tailwind | palette_violet_300 | bg-violet-300 | - | 0xC4B5FD | 0 | 13 | bg utility
tailwind | palette_violet_400 | bg-violet-400 | - | 0xA78BFA | 0 | 13 | bg utility
tailwind | palette_violet_500 | bg-violet-500 | - | 0x8B5CF6 | 0 | 13 | bg utility
tailwind | palette_violet_600 | bg-violet-600 | - | 0x7C3AED | 0 | 13 | bg utility
tailwind | palette_violet_700 | bg-violet-700 | - | 0x6D28D9 | 0 | 13 | bg utility
tailwind | palette_violet_800 | bg-violet-800 | - | 0x5B21B6 | 0 | 13 | bg utility
tailwind | palette_violet_900 | bg-violet-900 | - | 0x4C1D95 | 0 | 13 | bg utility
tailwind | palette_purple_50 | bg-purple-50 | - | 0xFAF5FF | 0 | 12 | bg utility
tailwind | palette_purple_100 | bg-purple-100 | - | 0xF3E8FF | 0 | 13 | bg utility
tailwind | palette_purple_200 | bg-purple-200 | - | 0xE9D5FF | 0 | 13 | bg utility
tailwind | palette_purple_300 | bg-purple-300 | - | 0xD8B4FE | 0 | 13 | bg utility
tailwind | palette_purple_400 | bg-purple-400 | - | 0xC084FC | 0 | 13 | bg utility
tailwind | palette_purple_500 | bg-purple-500 | - | 0xA855F7 | 0 | 13 | bg utility
tailwind | palette_purple_600 | bg-purple-600 | - | 0x9333EA | 0 | 13 | bg utility
tailwind | palette_purple_700 | bg-purple-700 | - | 0x7E22CE | 0 | 13 | bg utility
tailwind | palette_purple_800 | bg-purple-800 | - | 0x6B21A8 | 0 | 13 | bg utility
tailwind | palette_purple_900 | bg-purple-900 | - | 0x581C87 | 0 | 13 | bg utility
tailwind | palette_fuchsia_50 | bg-fuchsia-50 | - | 0xFDF4FF | 0 | 13 | bg utility
tailwind | palette_fuchsia_100 | bg-fuchsia-100 | - | 0xFAE8FF | 0 | 14 | bg utility
tailwind | palette_fuchsia_200 | bg-fuchsia-200 | - | 0xF5D0FE | 0 | 14 | bg utility
tailwind | palette_fuchsia_300 | bg-fuchsia-300 | - | 0xF0ABFC | 0 | 14 | bg utility
tailwind | palette_fuchsia_400 | bg-fuchsia-400 | - | 0xE879F9 | 0 | 14 | bg utility
tailwind | palette_fuchsia_500 | bg-fuchsia-500 | - | 0xD946EF | 0 | 14 | bg utility
tailwind | palette_fuchsia_600 | bg-fuchsia-600 | - | 0xC026D3 | 0 | 14 | bg utility
tailwind | palette_fuchsia_700 | bg-fuchsia-700 | - | 0xA21CAF | 0 | 14 | bg utility
tailwind | palette_fuchsia_800 | bg-fuchsia-800 | - | 0x86198F | 0 | 14 | bg utility
tailwind | palette_fuchsia_900 | bg-fuchsia-900 | - | 0x701A75 | 0 | 14 | bg utility
tailwind | palette_pink_50 | bg-pink-50 | - | 0xFDF2F8 | 0 | 10 | bg utility
tailwind | palette_pink_100 | bg-pink-100 | - | 0xFCE7F3 | 0 | 11 | bg utility
tailwind | palette_pink_200 | bg-pink-200 | - | 0xFBCFE8 | 0 | 11 | bg utility
tailwind | palette_pink_300 | bg-pink-300 | - | 0xF9A8D4 | 0 | 11 | bg utility
tailwind | palette_pink_400 | bg-pink-400 | - | 0xF472B6 | 0 | 11 | bg utility
tailwind | palette_pink_500 | bg-pink-500 | - | 0xEC4899 | 0 | 11 | bg utility
tailwind | palette_pink_600 | bg-pink-600 | - | 0xDB2777 | 0 | 11 | bg utility
tailwind | palette_pink_700 | bg-pink-700 | - | 0xBE185D | 0 | 11 | bg utility
tailwind | palette_pink_800 | bg-pink-800 | - | 0x9D174D | 0 | 11 | bg utility
tailwind | palette_pink_900 | bg-pink-900 | - | 0x831843 | 0 | 11 | bg utility
tailwind | palette_rose_50 | bg-rose-50 | - | 0xFFF1F2 | 0 | 10 | bg utility
tailwind | palette_rose_100 | bg-rose-100 | - | 0xFFE4E6 | 0 | 11 | bg utility
tailwind | palette_rose_200 | bg-rose-200 | - | 0xFECDD3 | 0 | 11 | bg utility
tailwind | palette_rose_300 | bg-rose-300 | - | 0xFDA4AF | 0 | 11 | bg utility
tailwind | palette_rose_400 | bg-rose-400 | - | 0xFB7185 | 0 | 11 | bg utility
tailwind | palette_rose_500 | bg-rose-500 | - | 0xF43F5E | 0 | 11 | bg utility
tailwind | palette_rose_600 | bg-rose-600 | - | 0xE11D48 | 0 | 11 | bg utility
tailwind | palette_rose_700 | bg-rose-700 | - | 0xBE123C | 0 | 11 | bg utility
tailwind | palette_rose_800 | bg-rose-800 | - | 0x9F1239 | 0 | 11 | bg utility
tailwind | palette_rose_900 | bg-rose-900 | - | 0x881337 | 0 | 11 | bg utility
tailwind | prefix_ring_offset | ring-offset-slate-500 | - | 0x64748B | 0 | 21 | supported prefix
tailwind | prefix_placeholder | placeholder-slate-500 | - | 0x64748B | 0 | 21 | supported prefix
tailwind | prefix_decoration | decoration-slate-500 | - | 0x64748B | 0 | 20 | supported prefix
tailwind | prefix_divide | divide-slate-500 | - | 0x64748B | 0 | 16 | supported prefix
tailwind | prefix_outline | outline-slate-500 | - | 0x64748B | 0 | 17 | supported prefix
tailwind | prefix_accent | accent-slate-500 | - | 0x64748B | 0 | 16 | supported prefix
tailwind | prefix_caret | caret-slate-500 | - | 0x64748B | 0 | 15 | supported prefix
tailwind | prefix_shadow | shadow-slate-500 | - | 0x64748B | 0 | 16 | supported prefix
tailwind | prefix_stroke | stroke-slate-500 | - | 0x64748B | 0 | 16 | supported prefix
tailwind | prefix_border | border-slate-500 | - | 0x64748B | 0 | 16 | supported prefix
tailwind | prefix_ring | ring-slate-500 | - | 0x64748B | 0 | 14 | supported prefix
tailwind | prefix_fill | fill-slate-500 | - | 0x64748B | 0 | 14 | supported prefix
tailwind | prefix_from | from-slate-500 | - | 0x64748B | 0 | 14 | supported prefix
tailwind | prefix_via | via-slate-500 | - | 0x64748B | 0 | 13 | supported prefix
tailwind | prefix_to | to-slate-500 | - | 0x64748B | 0 | 12 | supported prefix
tailwind | prefix_bg | bg-slate-500 | - | 0x64748B | 0 | 12 | supported prefix
tailwind | prefix_text | text-slate-500 | - | 0x64748B | 0 | 14 | supported prefix
tailwind | offset | class='bg-blue-500' | - | 0x3B82F6 | 7 | 18 | match offsets
tailwind | unknown_color | bg-notacolor | - | - | - | - | not in palette
tailwind | unknown_shade | bg-red-1000 | - | - | - | - | invalid shade
tailwind | unknown_prefix | foo-red-500 | - | - | - | - | unknown prefix
tailwind | bare_color | red-500 | - | - | - | - | prefix required
tailwind | trailing_suffix | bg-red-500-extra | - | - | - | - | frontier rejects suffix
tailwind | missing_color | bg- | - | - | - | - | missing color name

## var_usage parser
var_usage | hex | color: var(--brand); | :root { --brand: #123456; } | 0x123456 | 7 | 19 | long hex
var_usage | short_hex | color: var(--brand); | :root { --brand: #F53; } | 0xFF5533 | 7 | 19 | short hex
var_usage | hex_alpha | color: var(--brand); | :root { --brand: #FF800080; } | 0x180FF8000 | 7 | 19 | 8-digit hex
var_usage | named | color: var(--brand); | :root { --brand: rebeccapurple; } | 0x663399 | 7 | 19 | CSS named color
var_usage | rgb_legacy | color: var(--brand); | :root { --brand: rgb(255, 0, 0); } | 0xFF0000 | 7 | 19 | legacy rgb
var_usage | rgb_modern | color: var(--brand); | :root { --brand: rgb(255 128 0 / .5); } | 0x180FF8000 | 7 | 19 | modern rgba
var_usage | hsl | color: var(--brand); | :root { --brand: hsl(240 100% 50%); } | 0x0000FF | 7 | 19 | hsl
var_usage | hsla | color: var(--brand); | :root { --brand: hsla(0, 100%, 50%, 0.5); } | 0x180FF0000 | 7 | 19 | hsla
var_usage | multiline | color: var(--brand); | :root {\n  --brand:\n    #654321;\n} | 0x654321 | 7 | 19 | multiline declaration
var_usage | comment_removed | color: var(--brand); | :root { /* old: #000000 */ --brand: #ABCDEF; } | 0xABCDEF | 7 | 19 | comments removed
var_usage | skip_invalid | color: var(--brand); | :root { --brand: nope; --brand: #123456; } | 0x123456 | 7 | 19 | first valid declaration wins
var_usage | offset | border: 1px solid var(--brand); | :root { --brand: #010203; } | 0x010203 | 18 | 30 | match offsets
var_usage | missing_declaration | color: var(--brand); | :root { --other: #123456; } | - | - | - | declaration not found
var_usage | invalid_declaration | color: var(--brand); | :root { --brand: nope; } | - | - | - | declaration is not a color
var_usage | no_context | color: var(--brand); | - | - | - | - | no loaded declaration
var_usage | whitespace | color: var( --brand ); | :root { --brand: #123456; } | 0x123456 | 7 | 21 | whitespace inside var()
var_usage | uppercase_name | color: var(--Brand); | :root { --Brand: #123456; } | 0x123456 | 7 | 19 | case-sensitive custom property name
var_usage | hyphen_name | color: var(--brand-color); | :root { --brand-color: #123456; } | 0x123456 | 7 | 25 | hyphenated property name
var_usage | digit_name | color: var(--brand2); | :root { --brand2: #123456; } | 0x123456 | 7 | 20 | digit in property name
var_usage | transparent_hex | color: var(--brand); | :root { --brand: #00000000; } | 0x100000000 | 7 | 19 | 8-digit transparent hex
var_usage | uppercase_named | color: var(--brand); | :root { --brand: REBECCAPURPLE; } | 0x663399 | 7 | 19 | case-insensitive named color
var_usage | spaced_declaration | color: var(--brand); | :root {\n  --brand :   #654321  ;\n} | 0x654321 | 7 | 19 | spaces around declaration colon
var_usage | fallback_unsupported | color: var(--brand, red); | :root { --brand: #123456; } | - | - | - | fallback values are not supported
var_usage | uppercase_function | color: VAR(--brand); | :root { --brand: #123456; } | - | - | - | var() name is case-sensitive
var_usage | nested_var | color: var(--brand); | :root { --brand: var(--other); --other: #123456; } | - | - | - | nested var() unsupported
var_usage | calc_declaration | color: var(--brand); | :root { --brand: calc(1 + 1); } | - | - | - | calc() unsupported
var_usage | relative_color | color: var(--brand); | :root { --brand: rgb(from #123456 r g b); } | - | - | - | relative color syntax unsupported
```

<!-- VECTORS END -->
