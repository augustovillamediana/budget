#!/bin/bash

DB_NAME="mybudget.db"
MD_FILE="budget.md"

# Function to initialize the database
initdb() {
    sqlite3 $DB_NAME <<EOF
CREATE TABLE IF NOT EXISTS budget (
    id INTEGER PRIMARY KEY,
    category TEXT NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    note TEXT
);
EOF
    echo "Database and table created successfully."
}

# Function to add a new entry to the budget table
add_entry() {
    category="$1"
    amount="$2"
    note="$3"
    date=$(date +%Y-%m-%d) # Current date

    sqlite3 $DB_NAME <<EOF
INSERT INTO budget (category, amount, date, note)
VALUES ('$category', $amount, '$date', '$note');
EOF
    echo "New entry added successfully."
}

# Function to edit an existing entry in the budget table
edit_entry() {
    id="$1"
    category="$2"
    amount="$3"
    note="$4"
    
    sqlite3 $DB_NAME <<EOF
UPDATE budget
SET category = '$category',
    amount = $amount,
    note = '$note'
WHERE id = $id;
EOF
    echo "Entry with ID $id updated successfully."
}

# Function to print the latest transactions
print_transactions() {
    limit="$1"
    sqlite3 $DB_NAME <<EOF
SELECT id, category, amount, date, note
FROM budget
ORDER BY date DESC, id DESC
LIMIT $limit;
EOF
}

# Function to generate the budget report
generate_md() {
    month="${1:-$(date +%Y-%m)}" # Use provided month or current month

    # Calculate totals and balance for the current month
    read -r total_positive total_negative balance < <(sqlite3 $DB_NAME <<EOF
SELECT
    COALESCE(SUM(CASE WHEN amount > 0 THEN amount ELSE 0 END), 0) AS total_positive,
    COALESCE(SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END), 0) AS total_negative,
    COALESCE(SUM(amount), 0) AS balance
FROM budget
WHERE strftime('%Y-%m', date) = '$month';
EOF
)

    # Calculate costs per category for the current and previous months
    current_month_data=$(sqlite3 -header -separator "|" $DB_NAME <<EOF
SELECT category, SUM(amount) AS total
FROM budget
WHERE strftime('%Y-%m', date) = '$month'
GROUP BY category;
EOF
)

    previous_month=$(date -d "$month-01 -1 month" +%Y-%m)
    previous_month_data=$(sqlite3 -header -separator "|" $DB_NAME <<EOF
SELECT category, SUM(amount) AS total
FROM budget
WHERE strftime('%Y-%m', date) = '$previous_month'
GROUP BY category;
EOF
)

    # Create the markdown file
    {
        echo "# Budget Report for $month"
        echo
        echo "## Summary"
        echo "| Total Positive | Total Negative | Balance |"
        echo "|----------------|----------------|---------|"
        echo "| $total_positive | $total_negative | $balance |"
        echo
        echo "## Costs per Category"
        echo "### Current Month ($month)"
        echo "$current_month_data"
        echo
        echo "### Previous Month ($previous_month)"
        echo "$previous_month_data"
    } > $MD_FILE

    echo "Budget report generated successfully in $MD_FILE"
}

# Check the command-line arguments
if [ "$1" == "initdb" ]; then
    initdb
elif [ "$1" == "-new" ]; then
    shift
    if [ $# -lt 3 ]; then
        echo "Usage: $0 -new \"Category\" Amount \"Note\""
        exit 1
    fi
    add_entry "$1" "$2" "$3"
elif [ "$1" == "-edit" ]; then
    shift
    if [ $# -lt 4 ]; then
        echo "Usage: $0 -edit ID \"Category\" Amount \"Note\""
        exit 1
    fi
    edit_entry "$1" "$2" "$3" "$4"
elif [ "$1" == "-t" ]; then
    shift
    if [ $# -lt 1 ]; then
        echo "Usage: $0 -t NumberOfTransactions"
        exit 1
    fi
    print_transactions "$1"
elif [ "$1" == "--md" ]; then
    shift
    generate_md "$1"
else
    echo "Usage: $0 initdb"
    echo "       $0 -new \"Category\" Amount \"Note\""
    echo "       $0 -edit ID \"Category\" Amount \"Note\""
    echo "       $0 -t NumberOfTransactions"
    echo "       $0 --md [Month]"
    echo "To initialize the database, run: $0 initdb"
    echo "To add a new entry, run: $0 -new \"Category\" Amount \"Note\""
    echo "To edit an entry, run: $0 -edit ID \"Category\" Amount \"Note\""
    echo "To print latest transactions, run: $0 -t NumberOfTransactions"
    echo "To generate a markdown report, run: $0 --md [Month]"
fi
