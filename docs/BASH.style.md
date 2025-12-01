# Bash Style Guide

Style conventions for shell scripts in this repository.

## Header

Every script starts with:

```bash
#!/usr/bin/env bash

set -euo pipefail
```

- `set -e` exits on error
- `set -u` exits on undefined variable
- `set -o pipefail` catches pipe failures

## Comments

Avoid comments. Code should be self-explanatory through clear naming and structure.

If logic isn't obvious, refactor into a well-named function instead of adding a comment.

## Structure

Organize scripts in this order:

1. Shebang and set options
2. Global variables
3. `setup_colors` function
4. `log` function
5. `show_help` function
6. Other functions (logical sections)
7. `main` function
8. `main "$@"` call

```bash
#!/usr/bin/env bash

set -euo pipefail

VERSION="1.0.0"

setup_colors() { ... }
log() { ... }
show_help() { ... }
check_prerequisites() { ... }
do_work() { ... }

main() {
    setup_colors
    ...
    exit 0
}

main "$@"
```

**Important:** Always end `main()` with `exit 0`. Bash reads scripts sequentially from disk, so if the script changes during execution, Bash resumes at the current byte offset—potentially running unintended code. The `main` function pattern loads code into memory before execution, and `exit` prevents returning to the (possibly modified) script on disk.

Reference: https://arongriffis.com/2023-11-18-bash-main

## Colors

Support `NO_COLOR` and `FORCE_COLOR` environment variables per informal standards.

```bash
setup_colors() {
    if [[ -n "${FORCE_COLOR:-}" ]]; then
        USE_COLOR=true
    elif [[ -n "${NO_COLOR:-}" ]]; then
        USE_COLOR=false
    elif [[ -t 1 ]]; then
        USE_COLOR=true
    else
        USE_COLOR=false
    fi

    if [[ "$USE_COLOR" == true ]]; then
        red=$'\e[31m'
        green=$'\e[32m'
        yellow=$'\e[33m'
        blue=$'\e[34m'
        bold=$'\e[1m'
        reset=$'\e[0m'
    else
        red='' green='' yellow='' blue='' bold='' reset=''
    fi
}
```

Priority:
1. `FORCE_COLOR` set and non-empty: colors on
2. `NO_COLOR` set and non-empty: colors off
3. stdout is TTY: colors on
4. otherwise: colors off

References:
- https://no-color.org
- https://force-color.org

## Logging

Use a `log` function with lowercase levels:

```bash
log() {
    local level=$1
    shift
    local color
    case "$level" in
        info) color="$blue" ;;
        success) color="$green" ;;
        warn) color="$yellow" ;;
        error) color="$red" ;;
        *) color="" ;;
    esac
    if [[ "$level" == "error" ]]; then
        echo "${color}[${level}]${reset} $*" >&2
    else
        echo "${color}[${level}]${reset} $*"
    fi
}
```

Usage:

```bash
log info "Starting process"
log success "Done"
log warn "File already exists"
log error "Failed to connect"
```

Output:

```
[info] Starting process
[success] Done
[warn] File already exists
[error] Failed to connect
```

Errors go to stderr.

## Help Text

Use heredoc with bold title:

```bash
show_help() {
    cat <<EOF
${bold}Script Name${reset}

Brief description of what it does.

Usage: $(basename "$0") [options] <required-arg>

Arguments:
    required-arg    Description

Options:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

Examples:
    $(basename "$0") foo
    $(basename "$0") -v bar
EOF
}
```

## Variables

- Global constants: `UPPER_CASE`
- Local variables: `lower_case`
- Use `local` for function variables

```bash
VERSION="1.0.0"
OUTPUT_DIR="/tmp/output"

process_file() {
    local file=$1
    local result
    result=$(do_something "$file")
}
```

## Parameter Expansion

Prefer built-in parameter expansion over external tools like `sed`, `awk`, `tr`, `basename`, `dirname`.

### Default values

```bash
var="${var:-default}"
name="${1:-anonymous}"
```

### String manipulation

```bash
${var#pattern}      # Remove shortest match from start
${var##pattern}     # Remove longest match from start
${var%pattern}      # Remove shortest match from end
${var%%pattern}     # Remove longest match from end
${var/old/new}      # Replace first match
${var//old/new}     # Replace all matches
```

### Common replacements

```bash
filename="${path##*/}"      # Instead of: basename "$path"
dir="${path%/*}"            # Instead of: dirname "$path"
extension="${file##*.}"     # Get file extension
name="${file%.*}"           # Remove extension
user="${email%%@*}"         # Get username from email
domain="${email#*@}"        # Get domain from email
```

### Case conversion (bash 4+)

```bash
lower="${var,,}"            # Instead of: tr '[:upper:]' '[:lower:]'
upper="${var^^}"            # Instead of: tr '[:lower:]' '[:upper:]'
capitalize="${var^}"        # Capitalize first letter
```

### Length

```bash
length="${#var}"            # Instead of: expr length "$var"
```

## Command Checking

```bash
if ! command -v git &>/dev/null; then
    log error "git is not installed"
    exit 1
fi
```

Use `command` to bypass shell aliases and functions:

```bash
command ls                  # Runs actual ls, not alias
command -v git              # Check if command exists (not alias)
```

## Argument Parsing

Simple case statement:

```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h | --help)
            show_help
            exit 0
            ;;
        -v | --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done
```

## Exit Codes

- `exit 0` - success
- `exit 1` - general error
- `exit 2` - usage/syntax error (convention)

```bash
if [[ -z "$1" ]]; then
    show_help
    exit 2
fi
```

## Error Handling

- Use `set -e` for automatic exit on error
- Check critical commands explicitly when needed
- Use `|| true` to ignore expected failures

```bash
mkdir -p "$DIR"
cp "$SRC" "$DST"

if ! curl -fsSL "$URL" -o "$FILE"; then
    log error "Download failed"
    exit 1
fi

rm -f "$TEMP_FILE" || true
```

### Strategic set +e in loops

When processing multiple items where individual failures shouldn't stop the whole script:

```bash
set -eo pipefail

for item in "$@"; do
    set +e
    process_item "$item"
    result=$?
    set -e

    if [[ $result -ne 0 ]]; then
        log warn "Failed to process $item, continuing..."
    fi
done
```

## Common Pitfalls

### Double brackets vs single brackets

Use `[[` instead of `[` for conditionals:

```bash
[[ $file == *.txt ]]        # Pattern matching works
[ "$file" = *.txt ]         # Literal comparison, always false

[[ $var == 1 && $other == 2 ]]   # Logical operators built-in
[ "$var" = 1 ] && [ "$other" = 2 ]  # Requires shell operators

[[ $input =~ ^[0-9]+$ ]]    # Regex support
```

Double brackets handle spaces without quoting (though quoting is still recommended), support pattern matching and regex, and have built-in logical operators.

### Arithmetic increment with set -e

Using `((count++))` with `set -e` causes script to exit when count is 0:

```bash
count=0
((count++))
```

This exits because `((count++))` returns 1 (failure) when incrementing from 0, since the expression evaluates to 0 (falsy) before incrementing.

Use this instead:

```bash
count=$((count + 1))
```

## Platform Detection

When behavior differs between Linux and MacOS:

```bash
if [[ "$(uname -s)" == "Linux" ]]; then
    TIMEOUT="timeout -v 300"
else
    if command -v gtimeout &>/dev/null; then
        TIMEOUT="gtimeout -v 300"
    else
        log warn "gtimeout not available, install with: brew install coreutils"
        TIMEOUT=""
    fi
fi
```

## Output

Prefer `printf` over `echo` for portability:

```bash
printf "%s\n" "$message"
printf "Name: %s, Count: %d\n" "$name" "$count"
```

`echo` behavior varies across systems (handling of `-e`, `-n`, backslashes). `printf` is consistent.

## Debugging

Print commands before executing for transparency:

```bash
run() {
    printf "+ %s\n" "$*" >&2
    "$@"
}

run mkdir -p "$DIR"
run curl -fsSL "$URL" -o "$FILE"
```

Output shows each command prefixed with `+`, matching `set -x` format but with more control.

## Cleanup

Use trap for temporary files:

```bash
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT
```

## Formatting

Use shfmt with 4-space indentation:

```bash
shfmt -w -i 4 -ci script.sh
```

## Linting

Run shellcheck:

```bash
shellcheck script.sh
```

Configuration in `.shellcheckrc`:

```
external-sources=true
disable=SC2016,SC1090,SC2155
```

## Makefile

```makefile
lint:
    shellcheck bin/*

format:
    shfmt -w -i 4 -ci bin/*
```

## References

- https://github.com/dylanaraps/pure-bash-bible
- https://github.com/termstandard/colors
- https://nochlin.com/blog/6-techniques-i-use-to-create-a-great-user-experience-for-shell-scripts
