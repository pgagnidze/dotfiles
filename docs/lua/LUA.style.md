# Lua Style Guide

Style conventions for Lua code in this repository.

## Header

Every executable script starts with:

```lua
#!/usr/bin/env lua
```

## Comments

Avoid comments. Code should be self-explanatory through clear naming and structure.

If logic isn't obvious, refactor into a well-named function instead of adding a comment.

Use section headers to organize larger files:

```lua
-- patterns --

-- captures --

-- grammar --
```

Use `TODO` and `FIXME` tags when needed.

## Structure

Organize files in this order:

1. Shebang (for executables)
2. Local requires
3. Module table (if applicable)
4. Local aliases for performance
5. Constants
6. Helper functions
7. Public functions
8. Main logic or module return

```lua
#!/usr/bin/env lua

local utils = require("utils")

local module = {}

local insert, concat = table.insert, table.concat

local VERSION = "1.0.0"

local function helper()
end

function module.public_function()
end

return module
```

For executables, use a `main()` pattern:

```lua
#!/usr/bin/env lua

local function main()
    local args = parse_args(arg)
    do_work(args)
    os.exit(0)
end

main()
```

## Types

Primitives (value): `string`, `number`, `boolean`, `nil`

Complex (reference): `table`, `function`, `userdata`

```lua
local foo = { 1, 2 }
local bar = foo
bar[1] = 9
print(foo[1]) -- 9 (same reference)
```

## Formatting

Use 4 spaces. No tabs. LF line endings. No semicolons.

Space after `--`, commas, around operators, and inside braces:

```lua
-- good comment
local x = y * 9
local numbers = { 1, 2, 3 }
local player = { name = "Jack" }
```

No spaces inside parentheses. Blank lines between functions.

Indent tables to the start of the line:

```lua
-- good
local my_table = {
    "hello",
}
```

Avoid aligning variable declarations (produces noisy diffs).

## Variables

Always use `local`:

```lua
local superpower = get_superpower()
```

Scope determines name length:
- Large scope → descriptive names
- Small scope (under 10 lines) or iterators → single letters ok

Use `_` for ignored variables:

```lua
for _, item in ipairs(items) do
    process(item)
end
```

## Naming

| Type | Convention | Example |
|------|------------|---------|
| Variables, functions | `snake_case` | `user_name`, `get_config` |
| Classes | `PascalCase` | `MyClass`, `HttpClient` |
| Boolean functions | `is_`/`has_` prefix | `is_valid`, `has_items` |
| True constants | `UPPER_CASE` | `MAX_RETRIES` |

Never use `_UPPERCASE` (reserved by Lua).

## Strings

Use double quotes. Use single quotes when string contains double quotes:

```lua
local name = "LuaRocks"
local html = '<div class="container">'
```

Concatenation operator can omit spaces:

```lua
local message = "Hello, "..user.."! Day #"..day
```

## Tables

Populate fields at once. Use trailing commas:

```lua
local player = {
    name = "Jack",
    class = "Rogue",
}
```

Use plain `key` syntax when possible, `["key"]` for invalid identifiers:

```lua
local codes = { ["UTF-8"] = val1, ascii = val2 }
```

Note: `nil` values don't count in `#` length.

## Functions

Prefer function syntax over variable syntax:

```lua
-- good
local function yup(name) end

-- bad
local nope = function(name) end
```

Never name a parameter `arg` (conflicts with legacy Lua).

Return early for validation:

```lua
local function is_good_name(name)
    if #name < 3 or #name > 30 then return false end
    return true
end
```

Always use parentheses in function calls:

```lua
local bar = require("bar")
```

Exception: table arguments spanning multiple lines:

```lua
local instance = module.new {
    param = 42,
}
```

### Module Functions

Declare external to the table:

```lua
local module = {}

function module.hello()
    print("hello")
end
```

Declare metatable functions internal:

```lua
local version_mt = {
    __eq = function(a, b) return a.major == b.major end,
    __lt = function(a, b) return a.major < b.major end,
}
```

## Properties

Dot notation for known properties, brackets for dynamic access:

```lua
local is_jedi = luke.jedi
local value = config[key]
```

## Conditionals

False and nil are falsy. Use shortcuts:

```lua
-- good
if name then end
local name = input or "default"
local result = condition and value_if_true or value_if_false

-- bad
if name ~= nil then end
```

Note: `x and y or z` fails if `y` can be `nil` or `false`.

## Blocks

Single-line blocks for simple returns, breaks, and lambdas:

```lua
if not ok then return nil, "failed" end
if done then break end
use_callback(x, function(k) return k.last end)
```

## Type Checking

Use explicit conversion functions:

```lua
local total = tostring(score)
local val = tonumber(input)
```

Add type assertions for public APIs:

```lua
function load_manifest(repo_url, lua_version)
    assert(type(repo_url) == "string")
    assert(type(lua_version) == "string" or not lua_version)
end
```

## Error Handling

Return `nil` and error message for expected failures:

```lua
local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "cannot open: "..path
    end
    local content = file:read("*a")
    file:close()
    return content
end
```

Use `error()` or `assert()` for programming errors (API misuse):

```lua
local function process(config)
    assert(type(config) == "table", "config must be a table")
end
```

## Modules

Start with a local table. Return it at the end:

```lua
local module = {}

function module.say(greeting)
    print(greeting)
end

return module
```

For circular dependencies, register early:

```lua
local module = {}
package.loaded["myproject.mymodule"] = module

local other = require("myproject.other")
```

Name requires after the last component:

```lua
local socket = require("socket")
local client = require("http.client")
```

Module rules:
- Do not set globals
- Requiring should cause no side effects
- Use factories for stateful objects

```lua
-- good: factory pattern
local messagepack = require("messagepack")
local mp = messagepack.new({ integer = "unsigned" })
```

## OOP

Use the idiomatic pattern with `Class:new(o)`:

```lua
local Player = {}

function Player:new(o)
    o = o or { name = "unknown", health = 100 }
    self.__index = self
    setmetatable(o, self)
    return o
end

function Player:take_damage(amount)
    self.health = self.health - amount
end
```

Use method notation (`:`) for method calls:

```lua
my_object:my_method()
```

Do not rely on `__gc` for non-memory resources. Add explicit `close` methods.

## Colors

Support `NO_COLOR` and `FORCE_COLOR` environment variables:

```lua
local function should_use_color()
    if os.getenv("FORCE_COLOR") then return true end
    if os.getenv("NO_COLOR") then return false end
    local term = os.getenv("TERM")
    if not term or term == "dumb" then return false end
    return true
end
```

## Performance

These patterns matter in hot paths. Don't micro-optimize rarely-called code.

### Localize Globals

Cache library functions at module top:

```lua
local insert, concat = table.insert, table.concat
local match, gsub = string.match, string.gsub
local floor, sin = math.floor, math.sin
```

Global lookups go through `_G` at runtime. Locals are resolved at load time.

### String Building

Never concatenate in loops. Use `table.concat`:

```lua
-- bad: O(n²)
local result = ""
for i = 1, #items do
    result = result .. items[i]
end

-- good: O(n)
local parts = {}
for i = 1, #items do
    parts[i] = items[i]
end
local result = concat(parts)
```

### Table Construction

Define all fields at construction. Move constants outside functions:

```lua
-- bad: creates table each call
function get_headers()
    return { ["Content-Type"] = "application/json" }
end

-- good: reuse constant
local BASE_HEADERS = { ["Content-Type"] = "application/json" }
```

### Avoid Table Creation in Loops

```lua
-- bad: garbage every iteration
for i = 1, N do
    local point = { x = i, y = i * 2 }
    process(point)
end

-- good: reuse table
local point = { x = 0, y = 0 }
for i = 1, N do
    point.x, point.y = i, i * 2
    process(point)
end
```

### Cache Table Access

```lua
-- bad: repeated lookup
for i = 1, #self.items do
    process(self.items[i])
end

-- good: cache reference
local items = self.items
for i = 1, #items do
    process(items[i])
end
```

### Numeric For Loops

Prefer numeric for over ipairs for arrays:

```lua
-- faster
for i = 1, #array do
    process(array[i])
end
```

Use ipairs when you need sparse array safety or cleaner code.

### LuaJIT Specific

Pre-size tables with `table.new`:

```lua
local new = require("table.new")
local t = new(1000, 0)  -- 1000 array slots, 0 hash slots
```

Use `goto` for continue pattern:

```lua
for i = 1, N do
    if skip_condition then goto continue end
    -- main logic
    ::continue::
end
```

Use FFI for numeric arrays in hot paths:

```lua
local ffi = require("ffi")
local cache = ffi.new("int32_t[1000]")
```

## Pattern Matching

### Use Lua Patterns For

Simple extractions and replacements:

```lua
local ext = filename:match("%.([^%.]+)$")
local safe = path:gsub("%.%.", "")
local token = header:match("^Bearer%s+(.+)$")
```

### Use LPeg For

Structured parsing, recursive grammars, RFC compliance:

```lua
local lpeg = require("lpeg")
local P, R, S, C, Ct = lpeg.P, lpeg.R, lpeg.S, lpeg.C, lpeg.Ct

local token = (R("az", "AZ", "09") + S"-._~")^1
local quoted = P'"' * C((1 - P'"')^0) * P'"'
local param = C(token) * P"=" * (quoted + C(token))
```

### Decision Matrix

| Scenario | Use |
|----------|-----|
| Extract file extension | Lua patterns |
| Sanitize filename | Lua patterns |
| Extract query param | Lua patterns |
| Parse HTTP request | LPeg |
| Parse multipart form | LPeg |
| Validate email (RFC) | LPeg |

## Testing

Use busted. Write tests in `spec/` mirroring source structure:

```lua
describe("utils", function()
    describe("parse_args", function()
        it("returns empty table for no arguments", function()
            assert.same({}, utils.parse_args({}))
        end)
    end)
end)
```

Test interfaces, not private methods.

## Static Checking

Use luacheck:

```bash
luacheck myproject/ bin/ spec/
```

Configuration in `.luacheckrc`:

```lua
std = "lua51+lua52+lua53+lua54"
ignore = { "212" }  -- unused argument
```

## Project Structure

```
project/
  bin/                    # Executables
  project/                # Main module directory
    init.lua              # Main module
    submodule.lua         # Submodules
  spec/                   # Tests (busted)
  README.md
  LICENSE
```

## References

- <https://github.com/luarocks/lua-style-guide>
- <https://github.com/Olivine-Labs/lua-style-guide>
- <http://lua-users.org/wiki/LuaStyleGuide>
- <https://www.lua.org/gems/sample.pdf> (Roberto's Performance Tips)
- <https://www.inf.puc-rio.br/~roberto/lpeg/>
- <https://no-color.org>
- <https://force-color.org>
