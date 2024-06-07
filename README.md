# Budget Tracker

Basic budget tracker.

## Features

- **Add New Entries**: Easily record new expenses, including category, amount, and optional note.
- **Edit Entries**: Modify existing entries, including category, amount, note, and date.
- **Print Latest Transactions**: View the latest transactions with a specified limit.
- **Generate Budget Report**: Create a comprehensive markdown report with summary and costs per category.

## Getting Started

1. **Clone the Repository**: Clone this repository to your local machine.

```bash
git clone https://github.com/augustovillamediana/budget
```
2. Initialize the Database: Run the following command to initialize the SQLite database.
```bash
./script.sh initdb
```
3. Usage: Utilize the script to manage your budget effectively. Here are some examples:
```bash
# Add a new entry
./script.sh -new "Groceries" 50 "Purchased fruits and vegetables"

# Edit an existing entry
./script.sh -edit 1 "Entertainment" 20 "Movie night" "2024-06-01"

# Print latest transactions
./script.sh -t 10

# Generate budget report for the current month
./script.sh --md

# Generate budget report for a specific month (e.g., May 2024)
./script.sh --md 2024-05
```

## Notes
This script leverages SQLite for data storage, ensuring reliability and efficiency.
Feel free to customize and extend the script according to your requirements.

Created with dedication to financial management. 📊💼
