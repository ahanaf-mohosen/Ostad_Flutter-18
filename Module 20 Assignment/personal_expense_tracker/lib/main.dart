import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

const _ink = Color(0xFF172B4D);
const _muted = Color(0xFF8290A5);
const _green = Color(0xFF188A68);
const _red = Color(0xFFE05B56);
const _canvas = Color(0xFFF5F7FA);
const _categories = [
  'Food & Drink',
  'Transport',
  'Shopping',
  'Bills',
  'Health',
  'Entertainment',
  'Salary',
  'Other',
];

class Transaction {
  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type;
  final DateTime date;

  Map<String, Object?> toMap() => {
    'title': title,
    'amount': amount,
    'category': category,
    'type': type,
    'date': date.toIso8601String(),
  };
  factory Transaction.fromMap(Map<String, Object?> map) => Transaction(
    id: map['id'] as int,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    category: map['category'] as String,
    type: map['type'] as String,
    date: DateTime.parse(map['date'] as String),
  );
}

class TransactionDatabase {
  TransactionDatabase._();
  static final instance = TransactionDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = p.join(await getDatabasesPath(), 'expense_tracker.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount REAL NOT NULL, category TEXT NOT NULL, type TEXT NOT NULL, date TEXT NOT NULL)',
        );
      },
    );
    _database = db;

    // Populate a new install once. Existing user transactions are left intact.
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM transactions'),
        ) ??
        0;
    if (count == 0) {
      final today = DateTime.now();
      final demoTransactions = [
        Transaction(
          title: 'Monthly salary',
          amount: 3200,
          category: 'Salary',
          type: 'Income',
          date: today.subtract(const Duration(days: 2)),
        ),
        Transaction(
          title: 'Grocery run',
          amount: 86.42,
          category: 'Food & Drink',
          type: 'Expense',
          date: today.subtract(const Duration(days: 1)),
        ),
        Transaction(
          title: 'Metro card top-up',
          amount: 25,
          category: 'Transport',
          type: 'Expense',
          date: today,
        ),
        Transaction(
          title: 'Weekend dinner',
          amount: 48.90,
          category: 'Food & Drink',
          type: 'Expense',
          date: today.subtract(const Duration(days: 3)),
        ),
        Transaction(
          title: 'Freelance design',
          amount: 450,
          category: 'Other',
          type: 'Income',
          date: today.subtract(const Duration(days: 4)),
        ),
      ];
      final batch = db.batch();
      for (final item in demoTransactions) {
        batch.insert('transactions', item.toMap());
      }
      await batch.commit(noResult: true);
    }
    return db;
  }

  Future<List<Transaction>> all() async {
    final rows = await (await database).query(
      'transactions',
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(Transaction.fromMap).toList();
  }

  Future<void> save(Transaction item) async {
    final db = await database;
    if (item.id == null) {
      await db.insert('transactions', item.toMap());
    } else {
      await db.update(
        'transactions',
        item.toMap(),
        where: 'id = ?',
        whereArgs: [item.id],
      );
    }
  }

  Future<void> delete(int id) async =>
      (await database).delete('transactions', where: 'id = ?', whereArgs: [id]);
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Expense Tracker',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: _green),
      appBarTheme: const AppBarTheme(
        backgroundColor: _canvas,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
      ),
    ),
    home: const DashboardScreen(),
  );
}

String _money(double n) => '\$${n.toStringAsFixed(2)}';
String _date(DateTime d) => '${_month(d.month)} ${d.day}, ${d.year}';
String _month(int m) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][m - 1];
IconData _categoryIcon(String category) => switch (category) {
  'Food & Drink' => Icons.restaurant_rounded,
  'Transport' => Icons.directions_car_rounded,
  'Shopping' => Icons.shopping_bag_rounded,
  'Bills' => Icons.receipt_long_rounded,
  'Health' => Icons.favorite_rounded,
  'Entertainment' => Icons.movie_rounded,
  'Salary' => Icons.account_balance_wallet_rounded,
  _ => Icons.sell_rounded,
};

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Transaction> _items = [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final rows = await TransactionDatabase.instance.all();
      if (mounted) {
        setState(() {
          _items = rows;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _income =>
      _items.where((t) => t.type == 'Income').fold(0.0, (v, t) => v + t.amount);
  double get _expense => _items
      .where((t) => t.type == 'Expense')
      .fold(0.0, (v, t) => v + t.amount);
  Future<void> _add() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
    );
    _refresh();
  }

  Future<void> _open(Transaction t) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TransactionDetailScreen(transaction: t, onChanged: _refresh),
      ),
    );
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final recent = _items.take(5).toList();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 22,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            Text(
              'Your money, in focus',
              style: TextStyle(
                fontSize: 12,
                color: _muted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'All transactions',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AllTransactionsScreen(items: _items, onChanged: _refresh),
                ),
              );
              _refresh();
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _ink.withValues(alpha: .12),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURRENT BALANCE',
                          style: TextStyle(
                            color: Color(0xFFB8C4D5),
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _money(_income - _expense),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.7,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _balanceMini(
                                'Income',
                                _income,
                                Icons.south_west_rounded,
                                const Color(0xFF71D8AE),
                              ),
                            ),
                            Container(
                              height: 42,
                              width: 1,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _balanceMini(
                                'Expenses',
                                _expense,
                                Icons.north_east_rounded,
                                const Color(0xFFFFA49E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          'Total income',
                          _income,
                          Icons.south_west_rounded,
                          _green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          'Total expense',
                          _expense,
                          Icons.north_east_rounded,
                          _red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AllTransactionsScreen(
                              items: _items,
                              onChanged: _refresh,
                            ),
                          ),
                        ),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recent.isEmpty)
                    _emptyState()
                  else
                    ...recent.map((t) => _transactionTile(t, () => _open(t))),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add transaction',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _balanceMini(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) => Row(
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFB8C4D5), fontSize: 11),
            ),
            const SizedBox(height: 3),
            Text(
              _money(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
  Widget _summaryCard(String title, double value, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEDF0F4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _money(value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _ink,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
          ],
        ),
      );
}

Widget _emptyState() => Container(
  padding: const EdgeInsets.symmetric(vertical: 32),
  child: const Column(
    children: [
      Icon(
        Icons.account_balance_wallet_outlined,
        size: 42,
        color: Color(0xFFAFBAC8),
      ),
      SizedBox(height: 12),
      Text(
        'Nothing to track yet',
        style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
      ),
      SizedBox(height: 4),
      Text(
        'Add your first transaction to get started.',
        style: TextStyle(color: _muted, fontSize: 13),
      ),
    ],
  ),
);

Widget _transactionTile(Transaction t, VoidCallback onTap) {
  final income = t.type == 'Income';
  final color = income ? _green : _red;
  return Card(
    color: Colors.white,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 9),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(17),
      side: const BorderSide(color: Color(0xFFEDF0F4)),
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(_categoryIcon(t.category), color: color, size: 20),
      ),
      title: Text(
        t.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: _ink,
          fontSize: 14,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${t.category}  ·  ${_date(t.date)}',
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${income ? '+' : '−'}${_money(t.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(t.type, style: const TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    ),
  );
}

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({
    super.key,
    required this.items,
    required this.onChanged,
  });
  final List<Transaction> items;
  final VoidCallback onChanged;
  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  late List<Transaction> _items = widget.items;
  Future<void> _refresh() async {
    final rows = await TransactionDatabase.instance.all();
    if (mounted) setState(() => _items = rows);
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'All transactions',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: _items.isEmpty
        ? _emptyState()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return _transactionTile(item, () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionDetailScreen(
                      transaction: item,
                      onChanged: _refresh,
                    ),
                  ),
                );
                _refresh();
              });
            },
          ),
  );
}

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    required this.onChanged,
  });
  final Transaction transaction;
  final VoidCallback onChanged;
  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('“${transaction.title}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await TransactionDatabase.instance.delete(transaction.id!);
      onChanged();
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = transaction.type == 'Income';
    final color = income ? _green : _red;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => _delete(context),
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: _red),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      _categoryIcon(transaction.category),
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${income ? '+' : '−'}${_money(transaction.amount)}',
                    style: TextStyle(
                      color: color,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(transaction.type, style: const TextStyle(color: _muted)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _detailRow('Category', transaction.category),
            _detailRow('Date', _date(transaction.date)),
            _detailRow('Type', transaction.type),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TransactionFormScreen(transaction: transaction),
                  ),
                );
                if (context.mounted) {
                  onChanged();
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit transaction'),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    margin: const EdgeInsets.only(bottom: 9),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: _muted)),
        Text(
          value,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});
  final Transaction? transaction;
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.transaction?.title ?? '',
  );
  late final _amount = TextEditingController(
    text: widget.transaction == null
        ? ''
        : widget.transaction!.amount.toString(),
  );
  late String? _category = widget.transaction?.category;
  late String _type = widget.transaction?.type ?? 'Expense';
  late DateTime _selectedDate = widget.transaction?.date ?? DateTime.now();
  bool _saving = false;
  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value != null) setState(() => _selectedDate = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    setState(() => _saving = true);
    try {
      await TransactionDatabase.instance.save(
        Transaction(
          id: widget.transaction?.id,
          title: _title.text.trim(),
          amount: double.parse(_amount.text.trim()),
          category: _category!,
          type: _type,
          date: _selectedDate,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save transaction. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.transaction == null ? 'New transaction' : 'Edit transaction',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Text('Add the details below', style: TextStyle(color: _muted)),
          const SizedBox(height: 22),
          const _FieldLabel('Title'),
          TextFormField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Groceries'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Amount'),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixText: '\$ ',
            ),
            validator: (v) {
              final value = double.tryParse(v?.trim() ?? '');
              return value == null || !value.isFinite || value <= 0
                  ? 'Enter a valid amount greater than zero'
                  : null;
            },
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Category'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(hintText: 'Choose a category'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v),
            validator: (v) => v == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Transaction type'),
          _typeSelector(),
          const SizedBox(height: 18),
          const _FieldLabel('Date'),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: _muted,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _date(_selectedDate),
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.transaction == null
                        ? 'Save transaction'
                        : 'Save changes',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _typeSelector() => Row(
    children: ['Expense', 'Income'].map((type) {
      final selected = type == _type;
      final color = type == 'Income' ? _green : _red;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: type == 'Expense' ? 10 : 0),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _type = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: .1) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? color : const Color(0xFFE8EDF3),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == 'Income'
                        ? Icons.south_west_rounded
                        : Icons.north_east_rounded,
                    size: 17,
                    color: selected ? color : _muted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type,
                    style: TextStyle(
                      color: selected ? color : _muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
