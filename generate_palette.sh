#!/bin/bash

# Color Palette Generator
# Generates a color palette from a base color (equivalent to 500 shade)
# Based on the woot color structure from the CSS file

# Function to convert hex to RGB
hex_to_rgb() {
    local hex=$1
    # Remove # if present
    hex=${hex#"#"}
    
    # Convert to RGB
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    
    echo "$r $g $b"
}

# Function to convert RGB to hex
rgb_to_hex() {
    local r=$1
    local g=$2
    local b=$3
    
    printf "#%02x%02x%02x" $r $g $b
}

# Function to convert RGB to HSL
rgb_to_hsl() {
    local r=$1
    local g=$2
    local b=$3
    
    # Normalize RGB values to 0-1
    r=$(echo "scale=6; $r / 255" | bc -l)
    g=$(echo "scale=6; $g / 255" | bc -l)
    b=$(echo "scale=6; $b / 255" | bc -l)
    
    # Find min and max
    local max=$(echo "$r $g $b" | tr ' ' '\n' | sort -n | tail -1)
    local min=$(echo "$r $g $b" | tr ' ' '\n' | sort -n | head -1)
    
    # Calculate lightness
    local l=$(echo "scale=6; ($max + $min) / 2" | bc -l)
    
    # Calculate saturation and hue
    local delta=$(echo "scale=6; $max - $min" | bc -l)
    
    if [ "$(echo "$delta == 0" | bc -l)" -eq 1 ]; then
        local s=0
        local h=0
    else
        if [ "$(echo "$l < 0.5" | bc -l)" -eq 1 ]; then
            local s=$(echo "scale=6; $delta / ($max + $min)" | bc -l)
        else
            local s=$(echo "scale=6; $delta / (2 - $max - $min)" | bc -l)
        fi
        
        # Calculate hue
        if [ "$(echo "$max == $r" | bc -l)" -eq 1 ]; then
            local h=$(echo "scale=6; (($g - $b) / $delta) * 60" | bc -l)
        elif [ "$(echo "$max == $g" | bc -l)" -eq 1 ]; then
            local h=$(echo "scale=6; ((($b - $r) / $delta) + 2) * 60" | bc -l)
        else
            local h=$(echo "scale=6; ((($r - $g) / $delta) + 4) * 60" | bc -l)
        fi
        
        # Normalize hue to 0-360
        if [ "$(echo "$h < 0" | bc -l)" -eq 1 ]; then
            h=$(echo "scale=6; $h + 360" | bc -l)
        fi
    fi
    
    # Convert to percentages/degrees
    h=$(echo "scale=2; $h" | bc -l)
    s=$(echo "scale=4; $s * 100" | bc -l)
    l=$(echo "scale=4; $l * 100" | bc -l)
    
    echo "$h $s $l"
}

# Helper function for HSL to RGB conversion
hue2rgb() {
    local p=$1
    local q=$2
    local t=$3
    
    if [ "$(echo "$t < 0" | bc -l)" -eq 1 ]; then
        t=$(echo "scale=6; $t + 1" | bc -l)
    fi
    if [ "$(echo "$t > 1" | bc -l)" -eq 1 ]; then
        t=$(echo "scale=6; $t - 1" | bc -l)
    fi
    if [ "$(echo "$t < 0.166667" | bc -l)" -eq 1 ]; then
        echo "scale=6; $p + ($q - $p) * 6 * $t" | bc -l
    elif [ "$(echo "$t < 0.5" | bc -l)" -eq 1 ]; then
        echo "$q"
    elif [ "$(echo "$t < 0.666667" | bc -l)" -eq 1 ]; then
        echo "scale=6; $p + ($q - $p) * (0.666667 - $t) * 6" | bc -l
    else
        echo "$p"
    fi
}

# Function to convert HSL to RGB
hsl_to_rgb() {
    local h=$1
    local s=$2
    local l=$3
    
    # Normalize values
    h=$(echo "scale=6; $h / 360" | bc -l)
    s=$(echo "scale=6; $s / 100" | bc -l)
    l=$(echo "scale=6; $l / 100" | bc -l)
    
    if [ "$(echo "$s == 0" | bc -l)" -eq 1 ]; then
        # Achromatic (gray)
        local r=$(echo "scale=0; $l * 255" | bc -l)
        local g=$r
        local b=$r
    else
        if [ "$(echo "$l < 0.5" | bc -l)" -eq 1 ]; then
            local q=$(echo "scale=6; $l * (1 + $s)" | bc -l)
        else
            local q=$(echo "scale=6; $l + $s - $l * $s" | bc -l)
        fi
        
        local p=$(echo "scale=6; 2 * $l - $q" | bc -l)
        
        local r=$(hue2rgb $p $q $(echo "scale=6; $h + 0.333333" | bc -l))
        local g=$(hue2rgb $p $q $h)
        local b=$(hue2rgb $p $q $(echo "scale=6; $h - 0.333333" | bc -l))
        
        r=$(echo "scale=0; $r * 255" | bc -l)
        g=$(echo "scale=0; $g * 255" | bc -l)
        b=$(echo "scale=0; $b * 255" | bc -l)
    fi
    
    # Ensure values are integers and within range
    r=$(printf "%.0f" $r)
    g=$(printf "%.0f" $g)
    b=$(printf "%.0f" $b)
    
    # Clamp values to 0-255
    r=$((r < 0 ? 0 : r > 255 ? 255 : r))
    g=$((g < 0 ? 0 : g > 255 ? 255 : g))
    b=$((b < 0 ? 0 : b > 255 ? 255 : b))
    
    echo "$r $g $b"
}

# Global associative array to store generated colors
declare -A GENERATED_COLORS

# Function to generate palette and store colors
generate_palette_colors() {
    local base_color=$1
    local prefix=${2:-"custom"}
    
    # Convert base color to RGB then HSL
    local rgb=$(hex_to_rgb "$base_color")
    local hsl=$(rgb_to_hsl $rgb)
    
    read -r base_h base_s base_l <<< "$hsl"
    
    # Define lightness adjustments based on woot palette analysis
    declare -A shades=(
        ["25"]="95"
        ["50"]="85"
        ["75"]="75"
        ["100"]="65"
        ["200"]="55"
        ["300"]="45"
        ["400"]="35"
        ["500"]="$base_l"
        ["600"]="25"
        ["700"]="20"
        ["800"]="15"
        ["900"]="10"
    )
    
    # Generate each shade and store in global array
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        local target_l=${shades[$shade]}
        
        # For very light shades, reduce saturation
        local adjusted_s=$base_s
        if [ "$(echo "$target_l > 80" | bc -l)" -eq 1 ]; then
            adjusted_s=$(echo "scale=2; $base_s * 0.3" | bc -l)
        elif [ "$(echo "$target_l > 60" | bc -l)" -eq 1 ]; then
            adjusted_s=$(echo "scale=2; $base_s * 0.7" | bc -l)
        fi
        
        # Convert back to RGB
        local new_rgb=$(hsl_to_rgb "$base_h" "$adjusted_s" "$target_l")
        local new_hex=$(rgb_to_hex $new_rgb)
        
        # Store in global array
        GENERATED_COLORS["$shade"]="$new_hex"
    done
}

# Function to replace colors in a single file
replace_colors_in_file() {
    local file_path=$1
    local old_prefix=$2
    local new_prefix=$3  # This parameter is ignored in replacement mode
    local backup_suffix=${4:-".backup"}
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File '$file_path' not found."
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
    local temp_file=$(mktemp)
    
    # Extract existing color definitions
    grep -E "^\s*--${old_prefix}-[0-9]+:\s*#[0-9a-fA-F]{6};" "$file_path" > "$temp_file"
    
    if [ ! -s "$temp_file" ]; then
        echo "No color variables found with prefix '--${old_prefix}-' in the file."
        rm "$temp_file"
        return 1
    fi
    
    echo "Found color variables:"
    cat "$temp_file"
    echo ""
    
    # Process each line and perform replacements
    local replacements_made=0
    while IFS= read -r line; do
        # Extract shade number and old color using a simpler approach
        local shade_pattern="--${old_prefix}-([0-9]+):"
        local color_pattern="#[0-9a-fA-F]{6}"
        
        if [[ $line =~ $shade_pattern ]]; then
            local shade="${BASH_REMATCH[1]}"
            
            # Extract the color value
            if [[ $line =~ $color_pattern ]]; then
                local old_color="${BASH_REMATCH[0]}"
                local new_color="${GENERATED_COLORS[$shade]}"
                
                if [ -n "$new_color" ]; then
                    echo "Replacing: --${old_prefix}-${shade}: ${old_color} → --${old_prefix}-${shade}: ${new_color}"
                    
                    # Only replace the color value, keep the variable name the same
                    sed -i "s/${old_color}/${new_color}/g" "$file_path"
                    
                    ((replacements_made++))
                else
                    echo "Warning: No generated color found for shade $shade"
                fi
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
    diff -u "${file_path}${backup_suffix}" "$file_path" | head -20
    
    return 0
}

# Function to replace colors in all CSS files within a directory
replace_colors_in_directory() {
    local dir_path=$1
    local old_prefix=$2
    local new_prefix=$3  # This parameter is ignored in replacement mode
    local backup_suffix=${4:-".backup"}
    
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
    local css_files=()
    while IFS= read -r -d '' file; do
        css_files+=("$file")
    done < <(find "$dir_path" -type f \( -name "*.css" -o -name "*.scss" -o -name "*.sass" -o -name "*.less" \) -print0)
    
    if [ ${#css_files[@]} -eq 0 ]; then
        echo "No CSS files found in directory '$dir_path'"
        return 1
    fi
    
    echo "Found ${#css_files[@]} CSS/SCSS/SASS/LESS files:"
    printf '%s\n' "${css_files[@]}"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed with replacing colors in all these files? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi
    
    local total_files_processed=0
    local total_replacements=0
    local failed_files=()
    
    # Process each file
    for file in "${css_files[@]}"; do
        echo "=========================================="
        echo "Processing file: $file"
        echo "=========================================="
        
        # Check if file contains the target prefix
        if ! grep -q "^\s*--${old_prefix}-[0-9]" "$file"; then
            echo "Skipping '$file' - no variables with prefix '--${old_prefix}-' found"
            echo ""
            continue
        fi
        
        # Process the file
        if replace_colors_in_file "$file" "$old_prefix" "$new_prefix" "$backup_suffix"; then
            ((total_files_processed++))
            # Count replacements made in this file
            local file_replacements=$(grep -c "Replacing:" <<< "$(replace_colors_in_file "$file" "$old_prefix" "$new_prefix" "$backup_suffix" 2>&1)" || echo "0")
            ((total_replacements += file_replacements))
        else
            failed_files+=("$file")
        fi
        
        echo ""
    done
    
    # Summary
    echo "=========================================="
    echo "DIRECTORY PROCESSING COMPLETE"
    echo "=========================================="
    echo "Total CSS files found: ${#css_files[@]}"
    echo "Files successfully processed: $total_files_processed"
    echo "Files failed: ${#failed_files[@]}"
    
    if [ ${#failed_files[@]} -gt 0 ]; then
        echo "Failed files:"
        printf '  %s\n' "${failed_files[@]}"
    fi
    
    echo ""
    echo "All modified files have backup copies with '$backup_suffix' extension."
    echo "You can restore any file using: cp filename${backup_suffix} filename"
    
    return 0
}

# Function to generate palette (original functionality)
generate_palette() {
    local base_color=$1
    local prefix=${2:-"custom"}
    
    echo "Generating palette from base color: $base_color"
    echo "Using prefix: $prefix"
    echo ""
    
    # Generate colors first
    generate_palette_colors "$base_color" "$prefix"
    
    # Convert base color to RGB then HSL for display
    local rgb=$(hex_to_rgb "$base_color")
    local hsl=$(rgb_to_hsl $rgb)
    read -r base_h base_s base_l <<< "$hsl"
    
    echo "Base HSL: H=$base_h S=$base_s% L=$base_l%"
    echo ""
    
    echo "Generated CSS Variables:"
    echo "/* $prefix Color Palette - Generated from $base_color */"
    
    # Generate each shade
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        local new_hex="${GENERATED_COLORS[$shade]}"
        echo "    --$prefix-$shade: $new_hex;"
    done
    
    echo ""
    echo "Generated Tailwind-style classes:"
    echo "/* Add these to your CSS */"
    
    # Generate utility classes
    for shade in 25 50 75 100 200 300 400 500 600 700 800 900; do
        local new_hex="${GENERATED_COLORS[$shade]}"
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
}

# Check if bc is available
if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' calculator is required but not installed."
    echo "Please install it using:"
    echo "  Ubuntu/Debian: sudo apt-get install bc"
    echo "  macOS: brew install bc"
    echo "  CentOS/RHEL: sudo yum install bc"
    exit 1
fi

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 1
fi

base_color=$1
prefix=${2:-"custom"}

# Validate hex color format
if [[ ! $base_color =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
    echo "Error: Invalid hex color format. Please use format like #29a2a7 or 29a2a7"
    exit 1
fi

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
    
    # Then replace in file
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
    
    # Then replace in directory
    replace_hex_colors_in_directory "$dir_path"
else
    # Generate the palette only
    generate_palette "$base_color" "$prefix"
fi

# Function to replace specific hex colors throughout a file
replace_hex_colors_in_file() {
    local file_path=$1
    local backup_suffix=${2:-".backup"}
    
    if [ ! -f "$file_path" ]; then
        echo "Error: File '$file_path' not found."
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
    declare -A old_color_map=(
        ["#d1dfdf"]="50"
        ["#a4d8da"]="75"
        ["#80c8cb"]="100"
        ["#47ccd1"]="200"
        ["#2db3b7"]="300"
        ["#238b8e"]="400"
        ["#289fa3"]="500"
        ["#196366"]="600"
        ["#144f51"]="700"
        ["#0f3b3d"]="800"
        ["#12494d"]="850"
        ["#0a2728"]="900"
    )
    
    echo "Searching for these specific hex colors:"
    local replacements_made=0
    
    # Process each color mapping
    for old_hex in "${!old_color_map[@]}"; do
        local shade="${old_color_map[$old_hex]}"
        local new_hex="${GENERATED_COLORS[$shade]}"
        
        if [ -n "$new_hex" ]; then
            # Check if the old color exists in the file
            if grep -q "$old_hex" "$file_path"; then
                echo "Found $old_hex (shade $shade) → replacing with $new_hex"
                
                # Replace all instances of this hex color (case insensitive)
                # Use both lowercase and uppercase versions
                local old_hex_lower=$(echo "$old_hex" | tr '[:upper:]' '[:lower:]')
                local old_hex_upper=$(echo "$old_hex" | tr '[:lower:]' '[:upper:]')
                
                sed -i "s/$old_hex_lower/$new_hex/g" "$file_path"
                sed -i "s/$old_hex_upper/$new_hex/g" "$file_path"
                
                ((replacements_made++))
            else
                echo "Color $old_hex (shade $shade) not found in file"
            fi
        else
            echo "Warning: No generated color found for shade $shade"
        fi
    done
    
    echo ""
    echo "Replacement complete!"
    echo "Total hex colors replaced: $replacements_made"
    echo "Modified file: $file_path"
    echo "Backup available at: ${file_path}${backup_suffix}"
    
    # Show a diff of changes
    echo ""
    echo "Changes made (showing first 20 lines of diff):"
    diff -u "${file_path}${backup_suffix}" "$file_path" | head -20
    
    return 0
}

# Function to replace specific hex colors in all CSS files within a directory
replace_hex_colors_in_directory() {
    local dir_path=$1
    local backup_suffix=${2:-".backup"}
    
    if [ ! -d "$dir_path" ]; then
        echo "Error: Directory '$dir_path' not found."
        return 1
    fi
    
    echo "Processing directory: $dir_path"
    echo "Looking for CSS files recursively..."
    echo "Searching for specific hex colors and replacing with generated palette colors"
    echo ""
    
    # Find all CSS files in the directory and subdirectories
    local css_files=()
    while IFS= read -r -d '' file; do
        css_files+=("$file")
    done < <(find "$dir_path" -type f \( -name "*.css" -o -name "*.scss" -o -name "*.sass" -o -name "*.less" \) -print0)
    
    if [ ${#css_files[@]} -eq 0 ]; then
        echo "No CSS files found in directory '$dir_path'"
        return 1
    fi
    
    echo "Found ${#css_files[@]} CSS/SCSS/SASS/LESS files:"
    printf '%s\n' "${css_files[@]}"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to proceed with replacing hex colors in all these files? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled."
        return 0
    fi
    
    local total_files_processed=0
    local failed_files=()
    
    # Process each file
    for file in "${css_files[@]}"; do
        echo "=========================================="
        echo "Processing file: $file"
        echo "=========================================="
        
        # Process the file
        if replace_hex_colors_in_file "$file" "$backup_suffix"; then
            ((total_files_processed++))
        else
            failed_files+=("$file")
        fi
        
        echo ""
    done
    
    # Summary
    echo "=========================================="
    echo "DIRECTORY PROCESSING COMPLETE"
    echo "=========================================="
    echo "Total CSS files found: ${#css_files[@]}"
    echo "Files successfully processed: $total_files_processed"
    echo "Files failed: ${#failed_files[@]}"
    
    if [ ${#failed_files[@]} -gt 0 ]; then
        echo "Failed files:"
        printf '  %s\n' "${failed_files[@]}"
    fi
    
    echo ""
    echo "All modified files have backup copies with '$backup_suffix' extension."
    echo "You can restore any file using: cp filename${backup_suffix} filename"
    
    return 0
} 