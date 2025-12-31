#!/bin/bash

# Flexible WXR Image URLs Script
# Usage: ./xml-img-fixer.sh <input-xml-file> [source-domain]
# Example: ./xml-img-fixer.sh wp-blocks-demo.xml wpsandbox.mystagingwebsite.com

if [ $# -eq 0 ]; then
    echo "Usage: $0 <input-xml-file> [source-domain]"
    echo "Example: $0 wp-blocks-demo.xml wpsandbox.mystagingwebsite.com"
    echo ""
    echo "If source-domain is not provided, it will be auto-detected from the XML file."
    exit 1
fi

INPUT_FILE="$1"
SOURCE_DOMAIN="${2:-}"
OUTPUT_FILE="${INPUT_FILE%.xml}-fixed.xml"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

echo "Processing $INPUT_FILE..."

# If no source domain provided, auto-detect from XML
if [ -z "$SOURCE_DOMAIN" ]; then
    # Extract the first image URL to determine the source domain
    FIRST_URL=$(grep -oE 'https?://[^"<]+\.(jpg|jpeg|png|gif)' "$INPUT_FILE" | head -1)
    if [ -z "$FIRST_URL" ]; then
        echo "Error: No image URLs found in the XML file!"
        exit 1
    fi
    # Extract domain from URL (everything before /wp-content or similar)
    SOURCE_DOMAIN=$(echo "$FIRST_URL" | sed -E 's|https?://([^/]+)/.*|\1|')
    echo "Auto-detected source domain: $SOURCE_DOMAIN"
else
    echo "Using specified source domain: $SOURCE_DOMAIN"
fi

echo "Output will be saved to $OUTPUT_FILE"

# Copy input to output
cp "$INPUT_FILE" "$OUTPUT_FILE"

# Extract all unique image URLs from the source domain
TEMP_URLS=$(mktemp)
grep -oE "https?://${SOURCE_DOMAIN}[^\"<]+(jpg|jpeg|png|gif)" "$OUTPUT_FILE" | sort -u > "$TEMP_URLS"

TOTAL_URLS=$(wc -l < "$TEMP_URLS")

if [ "$TOTAL_URLS" -eq 0 ]; then
    echo "Warning: No image URLs found from domain '$SOURCE_DOMAIN' in the XML file."
    echo "Checked for patterns like: https://$SOURCE_DOMAIN/..."
    rm -f "$TEMP_URLS"
    exit 1
fi

echo "Found $TOTAL_URLS unique image URLs to replace"
echo ""

# Create a sed script file with all replacements
SED_SCRIPT=$(mktemp)

# Array of Unsplash photo IDs for variety
PHOTO_IDS=(
    "1477959858617-67f85cf4f1df"
    "1544551763-46a013bb70d5"
    "1505142468610-359e7d316be0"
    "1507525428034-b723cf961d3e"
    "1495616811223-4d98c6e9c869"
    "1506905925346-21bda4d32df4"
    "1506973035872-a4ec16b8e8d9"
    "1583511655857-d19b40a7a54e"
    "1469474968028-56623f02e42e"
    "1464822759023-fed622ff2c3b"
    "1472214103451-9374bd1c798e"
    "1523348837708-15d4a09cfac2"
    "1500382017468-9049fed747ef"
    "1501594907352-04cda38ebc29"
    "1470071459604-3b5ec3a7fe05"
    "1532628387584-f9d9a0e1aa0b"
    "1506905925346-21bda4d32df4"
    "1559827260-dc66d52bef19"
    "1509803874385-db7c23652552"
    "1614680376593-902f74cf0d41"
    "1558618666-fcd25c85cd64"
    "1531219432768-9f540ce91ef3"
    "1608889825103-eb5ed706fc64"
    "1441974231531-c6227db76b6e"
)

# Counter for cycling through photos
PHOTO_INDEX=0
REPLACEMENTS_MADE=0

# Process each URL
while IFS= read -r old_url; do
    if [ -z "$old_url" ]; then
        continue
    fi
    
    # Select a photo ID from the array (cycle through them)
    PHOTO_ID="${PHOTO_IDS[$((PHOTO_INDEX % ${#PHOTO_IDS[@]}))]}"
    PHOTO_INDEX=$((PHOTO_INDEX + 1))
    
    # Determine width based on URL (try to extract from filename or default to 1024)
    WIDTH="1024"
    if [[ "$old_url" =~ -1024x ]]; then
        WIDTH="1024"
    elif [[ "$old_url" =~ -800x ]]; then
        WIDTH="800"
    elif [[ "$old_url" =~ -600x ]]; then
        WIDTH="600"
    fi
    
    new_url="https://images.unsplash.com/photo-$PHOTO_ID?w=$WIDTH"
    
    # Escape for sed (only need to escape | since that's the delimiter)
    old_escaped=$(printf '%s\n' "$old_url" | sed -e 's/|/\\|/g')
    new_escaped=$(printf '%s\n' "$new_url" | sed -e 's/|/\\|/g')
    
    echo "s|$old_escaped|$new_escaped|g" >> "$SED_SCRIPT"
    REPLACEMENTS_MADE=$((REPLACEMENTS_MADE + 1))
    
    echo "[${REPLACEMENTS_MADE}/${TOTAL_URLS}] $(basename "$old_url")"
done < "$TEMP_URLS"

echo ""

# Apply sed script to file
sed -i.bak -f "$SED_SCRIPT" "$OUTPUT_FILE"

# Clean up
rm -f "$SED_SCRIPT" "${OUTPUT_FILE}.bak" "$TEMP_URLS"

echo "✅ Done! Fixed XML file saved as: $OUTPUT_FILE"
echo "Found and replaced $REPLACEMENTS_MADE image URLs from $SOURCE_DOMAIN"