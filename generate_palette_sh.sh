#!/bin/sh

# Color Palette Generator - POSIX Shell Version
# Generates a color palette from a base color (equivalent to 500 shade)
# Based on the woot color structure from the CSS file

# Function to convert hex to RGB
hex_to_rgb() {
    hex=$1
    # Remove # if present
    hex=${hex#"#"}
    
    # Convert to RGB using printf and arithmetic
    # Extract each pair of hex digits
    r_hex=${hex%????}
    g_hex=${hex#??}
    g_hex=${g_hex%??}
    b_hex=${hex#????}
    
    # Convert to decimal
    r=$(printf "%d" "0x$r_hex")
    g=$(printf "%d" "0x$g_hex")
    b=$(printf "%d" "0x$b_hex")
    
    echo "$r $g $b"
}

# Function to convert RGB to hex
rgb_to_hex() {
    r=$1
    g=$2
    b=$3
    
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

# Function to convert RGB to HSL
rgb_to_hsl() {
    r=$1
    g=$2
    b=$3
    
    # Normalize RGB values to 0-1 (using integer arithmetic scaled by 1000000)
    r_norm=$((r * 1000000 / 255))
    g_norm=$((g * 1000000 / 255))
    b_norm=$((b * 1000000 / 255))
    
    # Find min and max
    max=$r_norm
    min=$r_norm
    
    if [ $g_norm -gt $max ]; then max=$g_norm; fi
    if [ $b_norm -gt $max ]; then max=$b_norm; fi
    if [ $g_norm -lt $min ]; then min=$g_norm; fi
    if [ $b_norm -lt $min ]; then min=$b_norm; fi
    
    # Calculate lightness (scaled by 1000000)
    l=$(((max + min) / 2))
    
    # Calculate saturation and hue
    delta=$((max - min))
    
    if [ $delta -eq 0 ]; then
        s=0
        h=0
    else
        if [ $l -lt 500000 ]; then
            s=$((delta * 1000000 / (max + min)))
        else
            s=$((delta * 1000000 / (2000000 - max - min)))
        fi
        
        # Calculate hue (scaled by 1000000)
        if [ $max -eq $r_norm ]; then
            h=$(((g_norm - b_norm) * 60000000 / delta))
        elif [ $max -eq $g_norm ]; then
            h=$((((b_norm - r_norm) * 60000000 / delta) + 120000000))
        else
            h=$((((r_norm - g_norm) * 60000000 / delta) + 240000000))
        fi
        
        # Normalize hue to 0-360
        while [ $h -lt 0 ]; do
            h=$((h + 360000000))
        done
        while [ $h -ge 360000000 ]; do
            h=$((h - 360000000))
        done
    fi
    
    # Convert to final values
    h_final=$((h / 1000000))
    s_final=$((s / 10000))
    l_final=$((l / 10000))
    
    echo "$h_final $s_final $l_final"
}

# Helper function for HSL to RGB conversion
hue2rgb() {
    p=$1
    q=$2
    t=$3
    
    # All values scaled by 1000000
    if [ $t -lt 0 ]; then
        t=$((t + 1000000))
    fi
    if [ $t -gt 1000000 ]; then
        t=$((t - 1000000))
    fi
    
    if [ $t -lt 166667 ]; then
        echo $((p + (q - p) * 6 * t / 1000000))
    elif [ $t -lt 500000 ]; then
        echo $q
    elif [ $t -lt 666667 ]; then
        echo $((p + (q - p) * (666667 - t) * 6 / 1000000))
    else
        echo $p
    fi
}

# Function to convert HSL to RGB
hsl_to_rgb() {
    h=$1
    s=$2
    l=$3
    
    # Normalize values (scale by 1000000 for precision)
    h_norm=$((h * 1000000 / 360))
    s_norm=$((s * 10000))
    l_norm=$((l * 10000))
    
    if [ $s_norm -eq 0 ]; then
        # Achromatic (gray)
        r=$((l_norm * 255 / 1000000))
        g=$r
        b=$r
    else
        if [ $l_norm -lt 500000 ]; then
            q=$((l_norm * (1000000 + s_norm) / 1000000))
        else
            q=$((l_norm + s_norm - l_norm * s_norm / 1000000))
        fi
        
        p=$((2 * l_norm - q))
        
        r=$(hue2rgb $p $q $((h_norm + 333333)))
        g=$(hue2rgb $p $q $h_norm)
        b=$(hue2rgb $p $q $((h_norm - 333333)))
        
        r=$((r * 255 / 1000000))
        g=$((g * 255 / 1000000))
        b=$((b * 255 / 1000000))
    fi
    
    # Clamp values to 0-255
    if [ $r -lt 0 ]; then r=0; fi
    if [ $r -gt 255 ]; then r=255; fi
    if [ $g -lt 0 ]; then g=0; fi
    if [ $g -gt 255 ]; then g=255; fi
    if [ $b -lt 0 ]; then b=0; fi
    if [ $b -gt 255 ]; then b=255; fi
    
    echo "$r $g $b"
}

# Global variables to store generated colors (using individual variables instead of associative array)
SHADE_25=""
SHADE_50=""
SHADE_75=""
SHADE_100=""
SHADE_200=""
SHADE_300=""
SHADE_400=""
SHADE_500=""
SHADE_600=""
SHADE_700=""
SHADE_800=""
SHADE_900=""

# Function to get color by shade
get_color_by_shade() {
    shade=$1
    case $shade in
        25) echo "$SHADE_25" ;;
        50) echo "$SHADE_50" ;;
        75) echo "$SHADE_75" ;;
        100) echo "$SHADE_100" ;;
        200) echo "$SHADE_200" ;;
        300) echo "$SHADE_300" ;;
        400) echo "$SHADE_400" ;;
        500) echo "$SHADE_500" ;;
        600) echo "$SHADE_600" ;;
        700) echo "$SHADE_700" ;;
        800) echo "$SHADE_800" ;;
        900) echo "$SHADE_900" ;;
        *) echo "" ;;
    esac
}

# Function to set color by shade
set_color_by_shade() {
    shade=$1
    color=$2
    case $shade in
        25) SHADE_25="$color" ;;
        50) SHADE_50="$color" ;;
        75) SHADE_75="$color" ;;
        100) SHADE_100="$color" ;;
        200) SHADE_200="$color" ;;
        300) SHADE_300="$color" ;;
        400) SHADE_400="$color" ;;
        500) SHADE_500="$color" ;;
        600) SHADE_600="$color" ;;
        700) SHADE_700="$color" ;;
        800) SHADE_800="$color" ;;
        900) SHADE_900="$color" ;;
    esac
}

# Function to get lightness by shade
get_lightness_by_shade() {
    shade=$1
    case $shade in
        25) echo "95" ;;
        50) echo "85" ;;
        75) echo "75" ;;
        100) echo "65" ;;
        200) echo "55" ;;
        300) echo "45" ;;
        400) echo "35" ;;
        500) echo "$1" ;;  # Will be replaced with base_l
        600) echo "25" ;;
        700) echo "20" ;;
        800) echo "15" ;;
        900) echo "10" ;;
        *) echo "50" ;;
    esac
}

# Function to generate palette and store colors
generate_palette_colors() {
    base_color=$1
    prefix=${2:-"custom"}
    
    # Convert base color to RGB then HSL
    rgb=$(hex_to_rgb "$base_color")
    hsl=$(rgb_to_hsl $rgb)
    
    # Parse HSL values
    base_h=$(echo $hsl | cut -d' ' -f1)
    base_s=$(echo $hsl | cut -d' ' -f2)
    base_l=$(echo $hsl | cut -d' ' -f3)
    
    # Generate each shade and store in global variables
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        if [ "$shade" = "500" ]; then
            target_l=$base_l
        else
            target_l=$(get_lightness_by_shade $shade)
        fi
        
        # For very light shades, reduce saturation
        adjusted_s=$base_s
        if [ $target_l -gt 80 ]; then
            adjusted_s=$((base_s * 30 / 100))
        elif [ $target_l -gt 60 ]; then
            adjusted_s=$((base_s * 70 / 100))
        fi
        
        # Convert back to RGB
        new_rgb=$(hsl_to_rgb "$base_h" "$adjusted_s" "$target_l")
        new_hex=$(rgb_to_hex $new_rgb)
        
        # Store in global variables
        set_color_by_shade "$shade" "$new_hex"
    done
}

# Function to replace colors in a single file
replace_colors_in_file() {
    file_path=$1
    old_prefix=$2
    new_prefix=$3  # This parameter is ignored in replacement mode
    backup_suffix=${4:-".backup"}
    
    if [ ! -e "$file_path" ]; then
        echo "Error: Path '$file_path' not found."
        return 1
    fi
    
    if [ -d "$file_path" ]; then
        echo "Error: '$file_path' is a directory, not a file."
        echo ""
        echo "To process all CSS files in a directory, use the --replace-dir option instead:"
        echo "  $0 \"$base_color\" \"$prefix\" --replace-dir \"$file_path\" \"$old_prefix\""
        echo ""
        echo "This will recursively find and process all .css, .scss, .sass, and .less files"
        echo "in the directory and its subdirectories."
        return 1
    fi
    
    if [ ! -f "$file_path" ]; then
        echo "Error: '$file_path' is not a regular file."
        return 1
    fi
    
    echo "Replacing color values in file: $file_path"
    echo "Target prefix: $old_prefix (keeping variable names unchanged)"
    echo "New color palette generated from base color"
    echo ""
    
    # Create backup
    cp "$file_path" "${file_path}${backup_suffix}"
    echo "Backup created: ${file_path}${backup_suffix}"
    
    # Find existing color variables and their values
    echo "Finding existing color variables..."
    temp_file=$(mktemp)
    
    # Extract existing color definitions
    grep "^[[:space:]]*--${old_prefix}-[0-9][0-9]*:[[:space:]]*#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F];" "$file_path" > "$temp_file"
    
    if [ ! -s "$temp_file" ]; then
        echo "No color variables found with prefix '--${old_prefix}-' in the file."
        rm "$temp_file"
        return 1
    fi
    
    echo "Found color variables:"
    cat "$temp_file"
    echo ""
    
    # Process each line and perform replacements
    replacements_made=0
    while IFS= read -r line; do
        # Extract shade number and old color
        shade=$(echo "$line" | sed -n "s/^[[:space:]]*--${old_prefix}-\([0-9][0-9]*\):.*/\1/p")
        old_color=$(echo "$line" | sed -n 's/.*\(#[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]\).*/\1/p')
        
        if [ -n "$shade" ] && [ -n "$old_color" ]; then
            new_color=$(get_color_by_shade "$shade")
            
            if [ -n "$new_color" ]; then
                echo "Replacing: --${old_prefix}-${shade}: ${old_color} → --${old_prefix}-${shade}: ${new_color}"
                
                # Only replace the color value, keep the variable name the same
                sed -i "s/${old_color}/${new_color}/g" "$file_path"
                
                replacements_made=$((replacements_made + 1))
            else
                echo "Warning: No generated color found for shade $shade"
            fi
        fi
    done < "$temp_file"
    
    rm "$temp_file"
    
    echo ""
    echo "Replacement complete!"
    echo "Total color values replaced: $replacements_made"
    echo "Modified file: $file_path"
    echo "Backup available at: ${file_path}${backup_suffix}"
    
    # Show a diff of changes
    echo ""
    echo "Changes made (showing first 20 lines of diff):"
    if command -v diff >/dev/null 2>&1; then
        diff -u "${file_path}${backup_suffix}" "$file_path" | head -20
    else
        echo "diff command not available, skipping diff display"
    fi
    
    return 0
}

# Function to replace colors in all CSS files within a directory
replace_colors_in_directory() {
    dir_path=$1
    old_prefix=$2
    new_prefix=$3  # This parameter is ignored in replacement mode
    backup_suffix=${4:-".backup"}
    
    if [ ! -d "$dir_path" ]; then
        echo "Error: Directory '$dir_path' not found."
        return 1
    fi
    
    echo "Processing directory: $dir_path"
    echo "Looking for CSS files recursively..."
    echo "Target prefix: $old_prefix (keeping variable names unchanged)"
    echo "New color palette generated from base color"
    echo ""
    
    # Find all CSS files in the directory and subdirectories
    temp_file_list=$(mktemp)
    find "$dir_path" -type f \( -name "*.css" -o -name "*.scss" -o -name "*.sass" -o -name "*.less" \) > "$temp_file_list"
    
    if [ ! -s "$temp_file_list" ]; then
        echo "No CSS files found in directory '$dir_path'"
        echo ""
        echo "The script looks for files with these extensions:"
        echo "  - .css (CSS files)"
        echo "  - .scss (Sass files)"
        echo "  - .sass (Sass files)"
        echo "  - .less (Less files)"
        echo ""
        echo "Make sure your directory contains files with these extensions."
        echo "You can check what files are in the directory with:"
        echo "  find \"$dir_path\" -type f -name \"*.css\" -o -name \"*.scss\" -o -name \"*.sass\" -o -name \"*.less\""
        rm "$temp_file_list"
        return 1
    fi
    
    css_files_count=$(wc -l < "$temp_file_list")
    echo "Found $css_files_count CSS/SCSS/SASS/LESS files:"
    cat "$temp_file_list"
    echo ""
    
    # Ask for confirmation
    printf "Do you want to proceed with replacing colors in all these files? (y/N): "
    read -r reply
    case $reply in
        [Yy]|[Yy][Ee][Ss])
            echo "Proceeding with replacement..."
            ;;
        *)
            echo "Operation cancelled."
            rm "$temp_file_list"
            return 0
            ;;
    esac
    
    total_files_processed=0
    failed_files_count=0
    
    # Process each file
    while IFS= read -r file; do
        echo "=========================================="
        echo "Processing file: $file"
        echo "=========================================="
        
        # Check if file contains the target prefix
        if ! grep -q "^[[:space:]]*--${old_prefix}-[0-9]" "$file"; then
            echo "Skipping '$file' - no variables with prefix '--${old_prefix}-' found"
            echo ""
            continue
        fi
        
        # Process the file
        if replace_colors_in_file "$file" "$old_prefix" "$new_prefix" "$backup_suffix"; then
            total_files_processed=$((total_files_processed + 1))
        else
            failed_files_count=$((failed_files_count + 1))
        fi
        
        echo ""
    done < "$temp_file_list"
    
    rm "$temp_file_list"
    
    # Summary
    echo "=========================================="
    echo "DIRECTORY PROCESSING COMPLETE"
    echo "=========================================="
    echo "Total CSS files found: $css_files_count"
    echo "Files successfully processed: $total_files_processed"
    echo "Files failed: $failed_files_count"
    
    echo ""
    echo "All modified files have backup copies with '$backup_suffix' extension."
    echo "You can restore any file using: cp filename${backup_suffix} filename"
    
    return 0
}

# Function to generate palette (original functionality)
generate_palette() {
    base_color=$1
    prefix=${2:-"custom"}
    
    echo "Generating palette from base color: $base_color"
    echo "Using prefix: $prefix"
    echo ""
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Convert base color to RGB then HSL for display
    rgb=$(hex_to_rgb "$base_color")
    hsl=$(rgb_to_hsl $rgb)
    base_h=$(echo $hsl | cut -d' ' -f1)
    base_s=$(echo $hsl | cut -d' ' -f2)
    base_l=$(echo $hsl | cut -d' ' -f3)
    
    echo "Base HSL: H=$base_h S=$base_s% L=$base_l%"
    echo ""
    
    echo "Generated CSS Variables:"
    echo "/* $prefix Color Palette - Generated from $base_color */"
    
    # Generate each shade
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        new_hex=$(get_color_by_shade "$shade")
        echo "    --$prefix-$shade: $new_hex;"
    done
    
    echo ""
    echo "Generated Tailwind-style classes:"
    echo "/* Add these to your CSS */"
    
    # Generate utility classes
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        new_hex=$(get_color_by_shade "$shade")
        echo ".bg-$prefix-$shade { background-color: $new_hex; }"
        echo ".text-$prefix-$shade { color: $new_hex; }"
        echo ".border-$prefix-$shade { border-color: $new_hex; }"
    done
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <base_color> [prefix] [--replace file_path old_prefix] [--replace-dir dir_path old_prefix] [--replace-hex-colors file_path] [--replace-hex-colors-dir dir_path]"
    echo ""
    echo "Arguments:"
    echo "  base_color  Base color in hex format (e.g., #29a2a7 or 29a2a7)"
    echo "  prefix      Optional prefix for CSS variables (default: 'custom')"
    echo ""
    echo "Options:"
    echo "  --replace file_path old_prefix"
    echo "              Replace existing color VALUES in the specified file"
    echo "              file_path: Path to the CSS file to modify"
    echo "              old_prefix: Existing prefix to find (e.g., 'w' for --w-500)"
    echo "              Note: Variable names stay the same, only color values change"
    echo ""
    echo "  --replace-dir dir_path old_prefix"
    echo "              Replace existing color VALUES in ALL CSS files within directory"
    echo "              dir_path: Path to directory containing CSS files (searches recursively)"
    echo "              old_prefix: Existing prefix to find (e.g., 'w' for --w-500)"
    echo "              Supports: .css, .scss, .sass, .less files"
    echo "              Note: Variable names stay the same, only color values change"
    echo ""
    echo "  --replace-hex-colors file_path"
    echo "              Replace specific hex color values throughout the file"
    echo "              file_path: Path to the CSS file to modify"
    echo "              Replaces these exact hex colors with generated palette:"
    echo "              #d1dfdf, #a4d8da, #80c8cb, #47ccd1, #2db3b7, #238b8e,"
    echo "              #289fa3, #196366, #144f51, #0f3b3d, #12494d, #0a2728"
    echo ""
    echo "  --replace-hex-colors-dir dir_path"
    echo "              Replace specific hex color values in ALL CSS files within directory"
    echo "              dir_path: Path to directory containing CSS files (searches recursively)"
    echo "              Supports: .css, .scss, .sass, .less files"
    echo "              Replaces the same specific hex colors as --replace-hex-colors"
    echo ""
    echo "Examples:"
    echo "  # Generate palette only"
    echo "  $0 '#29a2a7' woot"
    echo "  $0 '3b82f6' blue"
    echo ""
    echo "  # Generate palette and replace color values in single file"
    echo "  $0 '#29a2a7' custom --replace application.css w"
    echo "  $0 '#3b82f6' custom --replace styles.css theme"
    echo ""
    echo "  # Generate palette and replace color values in all CSS files in directory"
    echo "  $0 '#29a2a7' custom --replace-dir ./src w"
    echo "  $0 '#3b82f6' custom --replace-dir ./styles theme"
    echo "  $0 '#10b981' custom --replace-dir . woot"
    echo ""
    echo "  # Generate palette and replace specific hex colors in single file"
    echo "  $0 '#29a2a7' custom --replace-hex-colors application.css"
    echo "  $0 '#3b82f6' custom --replace-hex-colors styles.css"
    echo ""
    echo "  # Generate palette and replace specific hex colors in all CSS files in directory"
    echo "  $0 '#29a2a7' custom --replace-hex-colors-dir ./src"
    echo "  $0 '#3b82f6' custom --replace-hex-colors-dir ."
    echo ""
    echo "This script generates a complete color palette based on the woot color"
    echo "structure found in the CSS file, using your base color as the 500 shade."
    echo ""
    echo "When using --replace or --replace-dir, the script will:"
    echo "1. Generate a new color palette from your base color"
    echo "2. Find all CSS variables with the old prefix (e.g., --w-500, --w-600)"
    echo "3. Replace ONLY the color values, keeping variable names unchanged"
    echo "4. Create backups of all modified files (.backup extension)"
    echo "5. Show a summary of all changes made"
    echo ""
    echo "When using --replace-hex-colors or --replace-hex-colors-dir, the script will:"
    echo "1. Generate a new color palette from your base color"
    echo "2. Find all instances of specific hex colors throughout the file(s)"
    echo "3. Replace those hex colors with corresponding colors from the new palette"
    echo "4. Create backups of all modified files (.backup extension)"
    echo "5. Show a summary of all changes made"
    echo ""
    echo "Note: This is a POSIX-compliant shell script that works with /bin/sh"
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

base_color=$1
prefix=${2:-"custom"}

# Validate hex color format
case $base_color in
    \#[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])
        # Valid hex with #
        ;;
    [0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])
        # Valid hex without #
        ;;
    *)
        echo "Error: Invalid hex color format. Please use format like #29a2a7 or 29a2a7"
        exit 1
        ;;
esac

# Check for replace options
if [ "$3" = "--replace" ]; then
    if [ $# -lt 5 ]; then
        echo "Error: --replace option requires file_path and old_prefix arguments"
        echo ""
        show_usage
        exit 1
    fi
    
    file_path=$4
    old_prefix=$5
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Then replace in file (prefix parameter is ignored in replacement mode)
    replace_colors_in_file "$file_path" "$old_prefix" "$prefix"
elif [ "$3" = "--replace-dir" ]; then
    if [ $# -lt 5 ]; then
        echo "Error: --replace-dir option requires dir_path and old_prefix arguments"
        echo ""
        show_usage
        exit 1
    fi
    
    dir_path=$4
    old_prefix=$5
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Then replace in directory (prefix parameter is ignored in replacement mode)
    replace_colors_in_directory "$dir_path" "$old_prefix" "$prefix"
elif [ "$3" = "--replace-hex-colors" ]; then
    if [ $# -lt 4 ]; then
        echo "Error: --replace-hex-colors option requires file_path argument"
        echo ""
        show_usage
        exit 1
    fi
    
    file_path=$4
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Then replace in file (prefix parameter is ignored in replacement mode)
    replace_hex_colors_in_file "$file_path"
elif [ "$3" = "--replace-hex-colors-dir" ]; then
    if [ $# -lt 4 ]; then
        echo "Error: --replace-hex-colors-dir option requires dir_path argument"
        echo ""
        show_usage
        exit 1
    fi
    
    dir_path=$4
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Then replace in directory (prefix parameter is ignored in replacement mode)
    replace_hex_colors_in_directory "$dir_path"
else
    # Generate the palette only
    generate_palette "$base_color" "$prefix"
fi

# Function to replace specific hex colors throughout a file
replace_hex_colors_in_file() {
    file_path=$1
    backup_suffix=${2:-".backup"}
    
    if [ ! -e "$file_path" ]; then
        echo "Error: Path '$file_path' not found."
        return 1
    fi
    
    if [ -d "$file_path" ]; then
        echo "Error: '$file_path' is a directory, not a file."
        echo ""
        echo "To process all CSS files in a directory, use the --replace-hex-colors-dir option instead:"
        echo "  $0 \"$base_color\" \"$prefix\" --replace-hex-colors-dir \"$file_path\""
        echo ""
        echo "This will recursively find and process all .css, .scss, .sass, and .less files"
        echo "in the directory and its subdirectories."
        return 1
    fi
    
    if [ ! -f "$file_path" ]; then
        echo "Error: '$file_path' is not a regular file."
        return 1
    fi
    
    echo "Replacing specific hex color values in file: $file_path"
    echo "Searching for exact hex color matches and replacing with generated palette colors"
    echo ""
    
    # Create backup
    cp "$file_path" "${file_path}${backup_suffix}"
    echo "Backup created: ${file_path}${backup_suffix}"
    
    # Define the specific hex colors to replace with their corresponding shades
    # Based on the provided color palette
    old_colors="
    #d1dfdf:50
    #a4d8da:75
    #80c8cb:100
    #47ccd1:200
    #2db3b7:300
    #238b8e:400
    #289fa3:500
    #196366:600
    #144f51:700
    #0f3b3d:800
    #12494d:850
    #0a2728:900
    "
    
    echo "Searching for these specific hex colors:"
    replacements_made=0
    
    # Process each color mapping
    # Use a different approach to avoid subshell issues
    temp_colors_file=$(mktemp)
    echo "$old_colors" > "$temp_colors_file"
    
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue
        
        # Extract hex color and shade
        old_hex=$(echo "$line" | cut -d':' -f1 | tr -d ' ')
        shade=$(echo "$line" | cut -d':' -f2 | tr -d ' ')
        
        if [ -n "$old_hex" ] && [ -n "$shade" ]; then
            # Get the new color for this shade
            new_hex=$(get_color_by_shade "$shade")
            
            if [ -n "$new_hex" ]; then
                # Check if the old color exists in the file
                if grep -q "$old_hex" "$file_path"; then
                    echo "Found $old_hex (shade $shade) → replacing with $new_hex"
                    
                    # Replace all instances of this hex color (case insensitive)
                    # Use both lowercase and uppercase versions
                    old_hex_lower=$(echo "$old_hex" | tr '[:upper:]' '[:lower:]')
                    old_hex_upper=$(echo "$old_hex" | tr '[:lower:]' '[:upper:]')
                    
                    sed -i "s/$old_hex_lower/$new_hex/g" "$file_path"
                    sed -i "s/$old_hex_upper/$new_hex/g" "$file_path"
                    
                    replacements_made=$((replacements_made + 1))
                else
                    echo "Color $old_hex (shade $shade) not found in file"
                fi
            else
                echo "Warning: No generated color found for shade $shade"
            fi
        fi
    done < "$temp_colors_file"
    
    rm "$temp_colors_file"
    
    echo ""
    echo "Replacement complete!"
    echo "Total hex colors replaced: $replacements_made"
    echo "Modified file: $file_path"
    echo "Backup available at: ${file_path}${backup_suffix}"
    
    # Show a diff of changes
    echo ""
    echo "Changes made (showing first 20 lines of diff):"
    if command -v diff >/dev/null 2>&1; then
        diff -u "${file_path}${backup_suffix}" "$file_path" | head -20
    else
        echo "diff command not available, skipping diff display"
    fi
    
    return 0
}

# Function to replace specific hex colors in all CSS files within a directory
replace_hex_colors_in_directory() {
    dir_path=$1
    backup_suffix=${2:-".backup"}
    
    if [ ! -d "$dir_path" ]; then
        echo "Error: Directory '$dir_path' not found."
        return 1
    fi
    
    echo "Processing directory: $dir_path"
    echo "Looking for CSS files recursively..."
    echo "Searching for specific hex colors and replacing with generated palette colors"
    echo ""
    
    # Find all CSS files in the directory and subdirectories
    temp_file_list=$(mktemp)
    find "$dir_path" -type f \( -name "*.css" -o -name "*.scss" -o -name "*.sass" -o -name "*.less" \) > "$temp_file_list"
    
    if [ ! -s "$temp_file_list" ]; then
        echo "No CSS files found in directory '$dir_path'"
        echo ""
        echo "The script looks for files with these extensions:"
        echo "  - .css (CSS files)"
        echo "  - .scss (Sass files)"
        echo "  - .sass (Sass files)"
        echo "  - .less (Less files)"
        echo ""
        echo "Make sure your directory contains files with these extensions."
        echo "You can check what files are in the directory with:"
        echo "  find \"$dir_path\" -type f -name \"*.css\" -o -name \"*.scss\" -o -name \"*.sass\" -o -name \"*.less\""
        rm "$temp_file_list"
        return 1
    fi
    
    css_files_count=$(wc -l < "$temp_file_list")
    echo "Found $css_files_count CSS/SCSS/SASS/LESS files:"
    cat "$temp_file_list"
    echo ""
    
    # Ask for confirmation
    printf "Do you want to proceed with replacing hex colors in all these files? (y/N): "
    read -r reply
    case $reply in
        [Yy]|[Yy][Ee][Ss])
            echo "Proceeding with replacement..."
            ;;
        *)
            echo "Operation cancelled."
            rm "$temp_file_list"
            return 0
            ;;
    esac
    
    total_files_processed=0
    failed_files_count=0
    
    # Process each file
    while IFS= read -r file; do
        echo "=========================================="
        echo "Processing file: $file"
        echo "=========================================="
        
        # Process the file
        if replace_hex_colors_in_file "$file" "$backup_suffix"; then
            total_files_processed=$((total_files_processed + 1))
        else
            failed_files_count=$((failed_files_count + 1))
        fi
        
        echo ""
    done < "$temp_file_list"
    
    rm "$temp_file_list"
    
    # Summary
    echo "=========================================="
    echo "DIRECTORY PROCESSING COMPLETE"
    echo "=========================================="
    echo "Total CSS files found: $css_files_count"
    echo "Files successfully processed: $total_files_processed"
    echo "Files failed: $failed_files_count"
    
    echo ""
    echo "All modified files have backup copies with '$backup_suffix' extension."
    echo "You can restore any file using: cp filename${backup_suffix} filename"
    
    return 0
} 