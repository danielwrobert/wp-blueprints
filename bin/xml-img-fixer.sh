#!/bin/bash

# Fix WXR Image URLs Script
# Usage: ./xml-img-fixer.sh wp-blocks-demo.xml

if [ $# -eq 0 ]; then
    echo "Usage: $0 <input-xml-file>"
    echo "Example: $0 wp-blocks-demo.xml"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.xml}-fixed.xml"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

echo "Processing $INPUT_FILE..."
echo "Output will be saved to $OUTPUT_FILE"

# Copy input to output
cp "$INPUT_FILE" "$OUTPUT_FILE"

# Define all the replacements
declare -A replacements=(
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2010/08/manhattansummer.jpg"]="https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_8399-1024x682.jpg"]="https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_8399.jpg"]="https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_0767.jpg"]="https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_0747-1024x682.jpg"]="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_0747.jpg"]="https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/img_0513-1.jpg"]="https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/michelle_049-1024x768.jpg"]="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/michelle_049.jpg"]="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1600"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dscn3316-1024x768.jpg"]="https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dscn3316.jpg"]="https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2014/01/spectacles.gif"]="https://images.unsplash.com/photo-1509347528160-9a9e33742cdb?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2014/01/dsc20050315_145007_132.jpg"]="https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2013/09/dsc20050604_133440_34211.jpg"]="https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc09114-1024x768.jpg"]="https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc09114.jpg"]="https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2012/12/unicorn-wallpaper-1024x768.jpg"]="https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/100_5540-1024x768.jpg"]="https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/100_5478-1024x768.jpg"]="https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/cep00032-1024x819.jpg"]="https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20051220_160808_102-1024x682.jpg"]="https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/canola2.jpg"]="https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dcp_2082-1024x682.jpg"]="https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20051220_173257_119-1024x682.jpg"]="https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20051220_173257_119.jpg"]="https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/windmill-1024x768.jpg"]="https://images.unsplash.com/photo-1532628387584-f9d9a0e1aa0b?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/windmill.jpg"]="https://images.unsplash.com/photo-1532628387584-f9d9a0e1aa0b?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20050813_115856_52.jpg"]="https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc03149-1024x768.jpg"]="https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc03149.jpg"]="https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20050102_192118_51-1024x768.jpg"]="https://images.unsplash.com/photo-1509803874385-db7c23652552?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2025/12/random-badge.png"]="https://images.unsplash.com/photo-1614680376593-902f74cf0d41?w=200"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2025/12/pexels-photo-20072294.jpeg"]="https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2025/12/hobbits.png"]="https://images.unsplash.com/photo-1531219432768-9f540ce91ef3?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2025/12/captain-america-1.png"]="https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2025/12/captain-america.png"]="https://images.unsplash.com/photo-1608889825103-eb5ed706fc64?w=1024"
    ["https://wpsandbox.mystagingwebsite.com/wp-content/uploads/2008/06/dsc20050604_133440_342.jpg"]="https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800"
)

# Perform replacements
count=0
for old_url in "${!replacements[@]}"; do
    new_url="${replacements[$old_url]}"
    # Escape special characters for sed
    old_escaped=$(echo "$old_url" | sed 's/[\/&?]/\\&/g')
    new_escaped=$(echo "$new_url" | sed 's/[\/&]/\\&/g')
    
    sed -i.bak "s|$old_escaped|$new_escaped|g" "$OUTPUT_FILE"
    ((count++))
    echo "[$count/${#replacements[@]}] Replaced: $(basename "$old_url")"
done

# Clean up backup file
rm "${OUTPUT_FILE}.bak"

echo ""
echo "✅ Done! Fixed XML file saved as: $OUTPUT_FILE"
echo "Found and replaced ${#replacements[@]} image URLs"