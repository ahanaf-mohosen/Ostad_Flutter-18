import 'dart:io';

extension ExpenseAmountFormatting on num {
	String formatExpenseAmount() {
		return '৳${toStringAsFixed(2)}';
	}
}

abstract class Expense {
	Expense(this.title, this.amount);

	final String title;
	final double amount;

	String get category;

	String getDisplayText() {
		return '$title - ${amount.formatExpenseAmount()} - $category';
	}
}

class FoodExpense extends Expense {
	FoodExpense(String title, double amount) : super(title, amount);

	@override
	String get category => 'Food';

	@override
	String getDisplayText() {
		return '${super.getDisplayText()}';
	}
}

class TransportExpense extends Expense {
	TransportExpense(String title, double amount) : super(title, amount);

	@override
	String get category => 'Transport';

	@override
	String getDisplayText() {
		return '${super.getDisplayText()}';
	}
}

class EntertainmentExpense extends Expense {
	EntertainmentExpense(String title, double amount) : super(title, amount);

	@override
	String get category => 'Entertainment';

	@override
	String getDisplayText() {
		return '${super.getDisplayText()}';
	}
}

class GenericExpense extends Expense {
	GenericExpense(this.customCategory, String title, double amount)
			: super(title, amount);

	final String customCategory;

	@override
	String get category => customCategory;
}

class ExpenseTracker {
	final List<Expense> _expenses = <Expense>[];

	void start() {
		while (true) {
			_showMenu();
			stdout.write('Choose Option: ');
			final String choice = stdin.readLineSync()?.trim() ?? '';
			print('');

			switch (choice) {
				case '1':
					_addExpense();
					break;
				case '2':
					_viewAllExpenses();
					break;
				case '3':
					_showTotalExpenses();
					break;
				case '4':
					print('Thank you for using Expense Tracker!');
					return;
				default:
					print('Invalid option. Please choose between 1 and 4.');
			}

			print('');
		}
	}

	void _showMenu() {
		print('===== Expense Tracker =====');
		print('1. Add Expense');
		print('2. View All Expenses');
		print('3. Show Total Expenses');
		print('4. Exit');
		print('');
	}

	void _addExpense() {
		stdout.write('Enter Expense Title: ');
		final String title = _readRequiredValue();

		stdout.write('Enter Expense Amount: ');
		final double amount = _readValidAmount();

		stdout.write('Enter Category: ');
		final String category = _readRequiredValue();

		final Expense expense = _createExpense(title, amount, category);
		_expenses.add(expense);

		print('Expense Added Successfully!');
	}

	void _viewAllExpenses() {
		print('===== All Expenses =====');

		if (_expenses.isEmpty) {
			print('No expenses added yet.');
			return;
		}

		for (int index = 0; index < _expenses.length; index++) {
			print('${index + 1}. ${_expenses[index].getDisplayText()}');
		}
	}

	void _showTotalExpenses() {
		double total = 0;

		for (final Expense expense in _expenses) {
			total += expense.amount;
		}

		print('Total Expenses: ${total.formatExpenseAmount()}');
	}

	String _readRequiredValue() {
		while (true) {
			final String value = stdin.readLineSync()?.trim() ?? '';

			if (value.isNotEmpty) {
				return value;
			}

			stdout.write('Value cannot be empty. Enter again: ');
		}
	}

	double _readValidAmount() {
		while (true) {
			final String input = stdin.readLineSync()?.trim() ?? '';
			final double? amount = double.tryParse(input);

			if (amount != null && amount > 0) {
				return amount;
			}

			stdout.write('Invalid amount. Enter a positive number: ');
		}
	}

	Expense _createExpense(String title, double amount, String category) {
		final String normalizedCategory = category.toLowerCase();

		switch (normalizedCategory) {
			case 'food':
				return FoodExpense(title, amount);
			case 'transport':
				return TransportExpense(title, amount);
			case 'entertainment':
				return EntertainmentExpense(title, amount);
			default:
				final String formattedCategory = _toTitleCase(category);
				return GenericExpense(formattedCategory, title, amount);
		}
	}

	String _toTitleCase(String value) {
		final List<String> words = value.trim().split(RegExp(r'\s+'));
		final List<String> formattedWords = <String>[];

		for (final String word in words) {
			if (word.isEmpty) {
				continue;
			}

			final String firstLetter = word[0].toUpperCase();
			final String remainingLetters =
					word.length > 1 ? word.substring(1).toLowerCase() : '';
			formattedWords.add('$firstLetter$remainingLetters');
		}

		return formattedWords.join(' ');
	}
}

void main() {
	final ExpenseTracker tracker = ExpenseTracker();
	tracker.start();
}
