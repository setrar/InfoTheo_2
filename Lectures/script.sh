#!/bin/bash

file="lecture05.ipynb"

# Backup the original file
cp "$file" "${file}.bak"

# Process the file using awk
awk '
BEGIN {
    in_math = 0;  # Track if inside a math block
    math_content = "";  # Buffer for math block content
}
{
    # Detect opening or closing "$\n"
    if ($0 ~ /^\s*"\$\s*\\n",?$/) {
        in_math = !in_math;  # Toggle math mode
        if (!in_math) {
            # End math block: output combined line
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", math_content);  # Trim spaces
            print "    \"$" math_content " $\\n\",";
            math_content = "";  # Reset buffer
        }
    }
    # Inside a math block: accumulate content
    else if (in_math) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "");  # Trim spaces
        math_content = math_content $0;  # Append content to buffer
    }
    # Outside a math block: print lines as-is
    else {
        print $0;
    }
}
END {
    # Ensure any open math block is closed
    if (in_math) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", math_content);  # Trim spaces
        print "    \"$" math_content " $\\n\",";
    }
}
' "$file" > tmp.json && mv tmp.json "$file"

echo "Notebook fixed and saved to $file. Backup created at ${file}.bak."
