# Color Palette Generator - POSIX Shell Version

This is a POSIX-compliant version of the color palette generator script that works with `/bin/sh` and other POSIX-compatible shells.

## Files

- `generate_palette.sh` - Original Bash version (requires bash)
- `generate_palette_sh.sh` - POSIX shell version (works with `/bin/sh`)

## Key Differences from Bash Version

### 1. Shell Compatibility
- **Bash version**: Uses `#!/bin/bash` and requires bash-specific features
- **POSIX version**: Uses `#!/bin/sh` and works with any POSIX-compliant shell

### 2. Associative Arrays
- **Bash version**: Uses associative arrays (`declare -A GENERATED_COLORS`)
- **POSIX version**: Uses individual global variables (`SHADE_25`, `SHADE_50`, etc.) with helper functions

### 3. Regular Expressions
- **Bash version**: Uses bash regex matching (`[[ $var =~ $pattern ]]`)
- **POSIX version**: Uses `case` statements for pattern matching

### 4. Arithmetic Operations
- **Bash version**: Uses `bc` for floating-point calculations
- **POSIX version**: Uses integer arithmetic scaled by factors (1000000) for precision

### 5. Array Handling
- **Bash version**: Uses bash arrays for file lists
- **POSIX version**: Uses temporary files and `while` loops for processing lists

### 6. String Manipulation
- **Bash version**: Uses bash parameter expansion with regex
- **POSIX version**: Uses POSIX parameter expansion and `sed` for pattern extraction

## Usage

Both versions have identical command-line interfaces:

```bash
# Generate palette only
./generate_palette_sh.sh '#29a2a7' woot
./generate_palette_sh.sh '3b82f6' blue

# Replace colors in single file
./generate_palette_sh.sh '#29a2a7' custom --replace application.css w

# Replace colors in directory
./generate_palette_sh.sh '#29a2a7' custom --replace-dir ./src w
```

## Compatibility

### POSIX Version Works With:
- `/bin/sh` (POSIX shell)
- `dash` (Debian Almquist Shell)
- `ash` (Almquist Shell)
- `bash` (when invoked as `sh`)
- `zsh` (when invoked as `sh`)
- Most Unix-like systems' default shells

### Dependencies
- Standard POSIX utilities: `sed`, `grep`, `find`, `cut`, `printf`
- `mktemp` for temporary files
- `diff` (optional, for showing changes)

### No Dependencies On:
- `bc` calculator (uses integer arithmetic instead)
- Bash-specific features
- GNU-specific extensions

## Performance Considerations

The POSIX version may be slightly slower than the bash version due to:
- Using integer arithmetic instead of `bc` for calculations
- More function calls for color storage/retrieval
- Additional `sed` calls for pattern extraction

However, the performance difference is negligible for typical use cases.

## Testing

Both versions produce identical output for the same input colors. The POSIX version has been tested with:
- Color palette generation
- Single file replacement
- Directory replacement
- Various shell environments

## Advantages of POSIX Version

1. **Better Portability**: Works on more systems without requiring bash
2. **Smaller Footprint**: No dependency on `bc` calculator
3. **Alpine Linux Compatible**: Works in minimal Docker containers
4. **Embedded Systems**: Suitable for systems with limited shell environments

## Advantages of Bash Version

1. **More Readable**: Associative arrays make code clearer
2. **Better Precision**: Uses `bc` for floating-point calculations
3. **Faster Execution**: Native bash features are generally faster
4. **More Maintainable**: Bash-specific features reduce code complexity

Choose the version that best fits your environment and requirements. 