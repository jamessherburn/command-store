#!/bin/bash

input_file="$HOME/daily-notes.txt"  # Path to the .txt file
output_file="$HOME/daily-notes.html"  # Path to the output HTML file

# Temporary files to store categorized entries
todo_file=$(mktemp)
done_file=$(mktemp)
merged_file=$(mktemp)
doing_file=$(mktemp)
general_notes_file=$(mktemp)

# Read the input file and parse the entries
while IFS= read -r line; do
    if [[ $line =~ \[([0-9]{2} [A-Za-z]+ [0-9]{4})\] ]]; then
        current_date="${BASH_REMATCH[1]}"
    elif [[ $line =~ \[(ToDo|Done|Merged|Doing)\] ]]; then
        current_tag="${BASH_REMATCH[1]}"
        task="${line#*\] }"  # Extract the task/message from the line
        # Add target="_blank" to any links and make them bold and black
        task=$(echo "$task" | sed 's|http[s]*://[a-zA-Z0-9./?=_-]*|<a href="&" target="_blank" style="color: black; font-weight: bold;">&</a>|g')
        case $current_tag in
            ToDo) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li><br>" >> "$todo_file" ;;
            Done) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li><br>" >> "$done_file" ;;
            Merged) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li><br>" >> "$merged_file" ;;
            Doing) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li><br>" >> "$doing_file" ;;
        esac
    elif [[ -n $line ]]; then
        # If no tag and line is not empty, consider it as a general note
        echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$line</li><br>" >> "$general_notes_file"
    fi
done < "$input_file"

# Start building the HTML content
html_content="<html>
<head>
    <title>Daily Notes</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: 'Times New Roman', serif;
            background-color: white;
        }
        .container {
            text-align: left;
            width: 60%;
        }
        h2 {
            margin: 20px 0;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 10px 0;
        }
        a {
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
    <script>
        function filterEntries() {
            const days = parseInt(prompt('Enter the number of days of history you want to see:', '0'));
            const today = new Date();
            const entries = document.querySelectorAll('li[data-date]');
            entries.forEach(entry => {
                const entryDate = new Date(entry.getAttribute('data-date'));
                const diffDays = Math.floor((today - entryDate) / (1000 * 60 * 60 * 24));
                if (diffDays > days) {
                    entry.style.display = 'none';
                }
            });
        }
        window.onload = filterEntries;
    </script>
</head>
<body>
    <div class=\"container\">"

# Append categorized entries to the HTML content
append_entries() {
    local tag="$1"
    local file="$2"
    if [[ -s $file ]]; then
        html_content+="<h2>$tag</h2><ul>"
        html_content+="$(cat "$file")"
        html_content+="</ul>"
    fi
}

append_entries "ToDo" "$todo_file"
append_entries "Done" "$done_file"
append_entries "Merged" "$merged_file"
append_entries "Doing" "$doing_file"
append_entries "General Notes" "$general_notes_file"

# Close the HTML content
html_content+="
    </div>
</body>
</html>"

# Write the HTML content to the output file
echo "$html_content" > "$output_file"

# Clean up temporary files
rm "$todo_file" "$done_file" "$merged_file" "$doing_file" "$general_notes_file"

echo "HTML file '$output_file' has been generated."






