# Color Palette Generator

A bash script that generates complete color palettes from a single base color, following the same structure as the woot colors found in the Chatwoot CSS file. **Now with automatic color replacement functionality!**

## Features

- **HSL-based color generation**: Uses HSL color space for more natural color variations
- **Intelligent saturation adjustment**: Automatically reduces saturation for lighter shades
- **Multiple output formats**: Generates both CSS custom properties and utility classes
- **Flexible naming**: Customizable prefix for generated color variables
- **Woot-compatible structure**: Follows the exact shade structure (25, 50, 75, 100, 200, 300, 400, 500, 600, 700, 800, 900)
- **🆕 Automatic color replacement**: Find and replace existing color variables in CSS files
- **🆕 Safe backup creation**: Automatically creates backups before making changes
- **🆕 Visual diff output**: Shows exactly what changes were made

## Requirements

- Bash shell
- `bc` calculator (for floating-point arithmetic)
- `grep`, `sed` (standard Unix tools)

### Installing bc

```bash
# Ubuntu/Debian
sudo apt-get install bc

# macOS
brew install bc

# CentOS/RHEL
sudo yum install bc
```

## Usage

### Basic Palette Generation

```bash
./generate_palette.sh <base_color> [prefix]
```

### Color Replacement in Files

```bash
./generate_palette.sh <base_color> <new_prefix> --replace <file_path> <old_prefix>
```

### Arguments

- `base_color`: Base color in hex format (e.g., `#29a2a7` or `29a2a7`) - this becomes your 500 shade
- `prefix`: Prefix for CSS variables (default: `custom`)
- `--replace`: Enable replacement mode
- `file_path`: Path to the CSS file to modify
- `old_prefix`: Existing prefix to replace (e.g., `w` for `--w-500`)

### Examples

```bash
# Generate a palette only
./generate_palette.sh '#29a2a7' woot
./generate_palette.sh '3b82f6' blue
./generate_palette.sh '#ef4444'

# Generate palette and replace colors in file
./generate_palette.sh '#29a2a7' woot-new --replace application.css w
./generate_palette.sh '#3b82f6' blue-theme --replace styles.css old-blue
./generate_palette.sh '#10b981' green --replace main.css custom

# Chain replacements to try different color schemes
./generate_palette.sh '#ef4444' red-theme --replace application.css blue-theme
```

## Output

### 1. Palette Generation Mode

The script generates two types of output:

#### CSS Custom Properties

```css
/* blue Color Palette - Generated from #3b82f6 */
--blue-25: #eff1f6;
--blue-50: #ced6e3;
--blue-75: #97b5e8;
--blue-100: #6d98df;
--blue-200: #2473f5;
--blue-300: #0a5adb;
--blue-400: #0846ab;
--blue-500: #3b82f6;
--blue-600: #06327a;
--blue-700: #042862;
--blue-800: #031e49;
--blue-900: #021431;
```

#### Utility Classes

```css
/* Add these to your CSS */
.bg-blue-25 { background-color: #eff1f6; }
.text-blue-25 { color: #eff1f6; }
.border-blue-25 { border-color: #eff1f6; }
/* ... and so on for all shades */
```

### 2. Replacement Mode

When using `--replace`, the script will:

1. **Create a backup**: `filename.css.backup`
2. **Find existing variables**: Search for `--old-prefix-[number]` patterns
3. **Replace systematically**: Update both variable names and color values
4. **Show progress**: Display each replacement as it happens
5. **Provide summary**: Show total replacements and diff preview

#### Example Replacement Output

```bash
Replacing colors in file: application.css
Old prefix: w
New prefix: blue-theme

Backup created: application.css.backup
Finding existing color variables...
Found color variables:
    --w-50: #dbf0f0;
    --w-500: #29a2a7;
    --w-900: #0c3236;

Replacing: --w-50: #dbf0f0 → --blue-theme-50: #ced6e3
Replacing: --w-500: #29a2a7 → --blue-theme-500: #3b82f6
Replacing: --w-900: #0c3236 → --blue-theme-900: #021431

Replacement complete!
Total replacements made: 11
Modified file: application.css
Backup available at: application.css.backup
```

## How It Works

The script analyzes your base color (which becomes the 500 shade) and:

1. **Converts to HSL**: Extracts hue, saturation, and lightness values
2. **Generates lighter shades (25-400)**: 
   - Increases lightness progressively
   - Reduces saturation for very light shades to avoid oversaturation
3. **Generates darker shades (600-900)**:
   - Decreases lightness progressively
   - Maintains saturation for rich, deep colors
4. **Converts back to hex**: Provides ready-to-use hex color codes
5. **🆕 Replaces in files**: Uses `grep` and `sed` to find and replace existing color variables

## Color Shade Structure

Based on the woot color analysis from the CSS file:

| Shade | Lightness | Usage |
|-------|-----------|-------|
| 25    | ~95%      | Very light backgrounds |
| 50    | ~85%      | Light backgrounds |
| 75    | ~75%      | Medium-light accents |
| 100   | ~65%      | Light accents |
| 200   | ~55%      | Medium accents |
| 300   | ~45%      | Medium-dark accents |
| 400   | ~35%      | Dark accents |
| 500   | Base      | Primary color (your input) |
| 600   | ~25%      | Dark elements |
| 700   | ~20%      | Darker elements |
| 800   | ~15%      | Very dark elements |
| 900   | ~10%      | Darkest elements |

## Replacement Safety Features

- **Automatic backups**: Original file is always preserved as `.backup`
- **Pattern matching**: Only replaces exact CSS variable patterns
- **Validation**: Checks file existence and variable patterns before proceeding
- **Progress reporting**: Shows each replacement as it happens
- **Diff preview**: Shows what changed after completion

## Use Cases

### 1. Theme Development
```bash
# Start with existing woot colors, try different base colors
./generate_palette.sh '#8b5cf6' purple --replace application.css w
./generate_palette.sh '#f59e0b' amber --replace application.css purple
```

### 2. Brand Color Migration
```bash
# Replace old brand colors with new ones
./generate_palette.sh '#new-brand-color' brand-v2 --replace styles.css brand-v1
```

### 3. A/B Testing Colors
```bash
# Quickly test different color schemes
./generate_palette.sh '#variant-a' test-a --replace application.css current
# Test, then revert or try another
./generate_palette.sh '#variant-b' test-b --replace application.css test-a
```

## Integration with Existing CSS

You can easily integrate the generated colors into your existing CSS by:

1. Adding the CSS custom properties to your `:root` selector
2. Using the utility classes directly in your HTML
3. Referencing the custom properties in your existing CSS: `color: var(--blue-500)`
4. **🆕 Using replacement mode** to automatically update existing color schemes

## Example Workflow

```bash
# 1. Generate and test a new color scheme
./generate_palette.sh '#10b981' emerald --replace application.css w

# 2. If you like it, you're done! If not, try another:
./generate_palette.sh '#f59e0b' amber --replace application.css emerald

# 3. Restore original if needed:
cp application.css.backup application.css
```

## Troubleshooting

- **No variables found**: Check that your CSS file contains variables with the expected prefix pattern (`--prefix-number`)
- **Permission errors**: Ensure you have write access to the target CSS file
- **Backup conflicts**: The script will overwrite existing `.backup` files
- **Pattern mismatches**: The script looks for exact patterns like `--w-500: #color;`

This maintains visual consistency while allowing you to create new color schemes based on different base colors, and now you can automatically apply them to your existing CSS files! 