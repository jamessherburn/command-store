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
            ToDo) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li>" >> "$todo_file" ;;
            Done) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li>" >> "$done_file" ;;
            Merged) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li>" >> "$merged_file" ;;
            Doing) echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$task</li>" >> "$doing_file" ;;
        esac
    elif [[ -n $line ]]; then
        # If no tag and line is not empty, consider it as a general note
        echo "<li data-date=\"$current_date\"><strong>[$current_date]</strong><br>$line</li>" >> "$general_notes_file"
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
            margin: 10px 0; /* Reduced margin for headers */
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 10px 0; /* Add margin between list items */
            display: none; /* Initially hide all entries */
        }
        a {
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .controls {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 10px; /* Space between controls */
        }
        .control-group {
            display: flex;
            align-items: center;
        }
        .control-group label {
            margin-right: 10px;
            min-width: 100px; /* Ensures labels are aligned */
        }
    </style>
    <script>
        function parseDate(dateString) {
            const [day, month, year] = dateString.split(' ');
            const months = {
                'January': 0, 'February': 1, 'March': 2, 'April': 3,
                'May': 4, 'June': 5, 'July': 6, 'August': 7,
                'September': 8, 'October': 9, 'November': 10, 'December': 11
            };
            return new Date(year, months[month], day);
        }

        function filterEntries(filterFunction) {
            const sections = document.querySelectorAll('.section');
            sections.forEach(section => {
                const entries = section.querySelectorAll('li[data-date]');
                let hasVisibleEntries = false;
                entries.forEach(entry => {
                    if (filterFunction(entry)) {
                        entry.style.display = 'block';
                        hasVisibleEntries = true;
                    } else {
                        entry.style.display = 'none';
                    }
                });
                section.style.display = hasVisibleEntries ? 'block' : 'none';
            });
        }

        function filterByDate() {
            const selectedDate = new Date(document.getElementById('date-picker').value);
            filterEntries(entry => {
                const entryDate = parseDate(entry.getAttribute('data-date'));
                return entryDate.toDateString() === selectedDate.toDateString();
            });
        }

        function filterByDays() {
            const days = parseInt(document.getElementById('days-input').value) || 0;
            const today = new Date();
            filterEntries(entry => {
                const entryDate = parseDate(entry.getAttribute('data-date'));
                const diffDays = Math.floor((today - entryDate) / (1000 * 60 * 60 * 24));
                return diffDays <= days;
            });
        }

        window.onload = function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('date-picker').value = today;
            filterByDate();
        }
    </script>
</head>
<body>
    <div class=\"container\">
        <div class=\"controls\">
            <div class=\"control-group\">
                <label for=\"date-picker\">Specific Date:</label>
                <input type=\"date\" id=\"date-picker\" onchange=\"filterByDate()\">
            </div>
            <div class=\"control-group\">
                <label for=\"days-input\">Last X Days:</label>
                <input type=\"text\" id=\"days-input\" placeholder=\"Enter number of days\" oninput=\"filterByDays()\">
            </div>
        </div>
"

# Append categorized entries to the HTML content
append_entries() {
    local tag="$1"
    local file="$2"
    if [[ -s $file ]]; then
        html_content+="<div class=\"section\"><h2>$tag</h2><ul>"
        html_content+="$(cat "$file")"
        html_content+="</ul></div>"
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


