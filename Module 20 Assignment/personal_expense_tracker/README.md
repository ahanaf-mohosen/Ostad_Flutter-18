# Expense Tracker

A Flutter app for tracking income and expenses with local SQLite storage. Add, edit, view, and delete transactions, and see your totals update on the dashboard.

## Screenshots

Screenshots were captured from the Android emulator.

| Dashboard | All transactions | Transaction details |
| --- | --- | --- |
| <img src="screenshots/dashboard.png" width="220" alt="Expense Tracker dashboard"> | <img src="screenshots/all_transactions.png" width="220" alt="All transactions list"> | <img src="screenshots/transaction_details.png" width="220" alt="Transaction details"> |

| Add transaction | Edit transaction |
| --- | --- |
| <img src="screenshots/add_transaction.png" width="220" alt="Add transaction form"> | <img src="screenshots/edit_transaction.png" width="220" alt="Edit transaction form with saved values"> |

## Run the app

```sh
flutter pub get
flutter run
```

Transactions are stored on device in `expense_tracker.db`. A small set of demo transactions is inserted on first launch when the database is empty.
