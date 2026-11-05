import 'package:flutter/material.dart';

void main() => runApp(const CalorieTrackerApp());

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16866A);
    return MaterialApp(
      title: 'Calorie Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF5F7F5)),
      ),
      home: const TrackerHomePage(),
    );
  }
}

class FoodEntry {
  FoodEntry({required this.name, required this.calories});
  final String name;
  final double calories;
}

class TrackerHomePage extends StatefulWidget {
  const TrackerHomePage({super.key});

  @override
  State<TrackerHomePage> createState() => _TrackerHomePageState();
}

class _TrackerHomePageState extends State<TrackerHomePage> {
  static const _goal = 2000;
  final List<FoodEntry> _foods = [];
  double get _total => _foods.fold<double>(0, (sum, item) => sum + item.calories);
  String _formatCalories(num value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);

  String get _today {
    final now = DateTime.now();
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Future<void> _addFood() async {
    final entry = await showDialog<FoodEntry>(
      context: context,
      builder: (_) => const AddFoodDialog(),
    );
    if (entry != null && mounted) setState(() => _foods.insert(0, entry));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_goal - _total).clamp(0.0, _goal.toDouble()).toDouble();
    final progress = (_total / _goal).clamp(0.0, 1.0).toDouble();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFE2F2EC), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFF16866A))),
          const SizedBox(width: 10),
          const Text('Calorie Tracker', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        ]),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_today, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            const SizedBox(height: 18),
            _buildHero(remaining, progress),
            const SizedBox(height: 24),
            const Text("Today's summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _summaryCard('Total calories', _total, 'consumed', Icons.local_fire_department_outlined, const Color(0xFFEAF5EF), const Color(0xFF16866A))),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Daily goal', _goal, 'target', Icons.flag_outlined, const Color(0xFFFFF2DF), const Color(0xFFCC8A22))),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('Remaining', remaining, 'to your goal', Icons.bolt_outlined, const Color(0xFFECEBFA), const Color(0xFF7163C5))),
            ]),
            const SizedBox(height: 26),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Food diary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('${_foods.length} ${_foods.length == 1 ? 'item' : 'items'}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ]),
            const SizedBox(height: 10),
            if (_foods.isEmpty)
              _emptyDiary()
            else
              ListView.builder(
                itemCount: _foods.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final food = _foods[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 9),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFEAF5EF), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.restaurant_outlined, color: Color(0xFF16866A))),
                      title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Food entry'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${_formatCalories(food.calories)} kcal', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        IconButton(tooltip: 'Delete ${food.name}', onPressed: () => setState(() => _foods.removeAt(index)), icon: Icon(Icons.delete_outline, color: Colors.grey.shade500)),
                      ]),
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _addFood, icon: const Icon(Icons.add), label: const Text('Add food'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), foregroundColor: const Color(0xFF16866A), side: const BorderSide(color: Color(0xFFB7D9CD)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addFood, icon: const Icon(Icons.add), label: const Text('Add food'), backgroundColor: const Color(0xFF16866A), foregroundColor: Colors.white),
    );
  }

  Widget _buildHero(double remaining, double progress) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF16866A), Color(0xFF25A17A)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Calories consumed', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(20)), child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1))),
          ]),
          const SizedBox(height: 8),
          Text(_formatCalories(_total), style: const TextStyle(color: Colors.white, fontSize: 42, height: 1.1, fontWeight: FontWeight.w800)),
          const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 22),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white.withValues(alpha: .25), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${(progress * 100).round()}% of daily goal', style: const TextStyle(color: Colors.white, fontSize: 12)), Text('${_formatCalories(remaining)} kcal left', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))]),
        ]),
      );

  Widget _summaryCard(String title, num value, String caption, IconData icon, Color tint, Color accent) => Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: accent, size: 18)),
          const SizedBox(height: 12),
          Text(_formatCalories(value), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ])),
      );

  Widget _emptyDiary() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Container(width: 52, height: 52, decoration: const BoxDecoration(color: Color(0xFFEAF5EF), shape: BoxShape.circle), child: const Icon(Icons.no_meals_outlined, color: Color(0xFF16866A))),
          const SizedBox(height: 12),
          const Text('Nothing on your plate yet', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Add your first food to start tracking today.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        ]),
      );
}

class AddFoodDialog extends StatefulWidget {
  const AddFoodDialog({super.key});

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add food'),
        content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Food name', hintText: 'e.g. Grilled chicken', prefixIcon: Icon(Icons.restaurant)),
              validator: (value) => value == null || value.trim().isEmpty ? 'Enter a food name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Calories', hintText: 'e.g. 250', suffixText: 'kcal', prefixIcon: Icon(Icons.local_fire_department_outlined)),
              validator: (value) {
                final calories = num.tryParse(value?.trim() ?? '');
                if (calories == null || calories <= 0 || !calories.isFinite) return 'Enter a number greater than 0';
                return null;
              },
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(context, FoodEntry(name: _nameController.text.trim(), calories: double.parse(_caloriesController.text.trim())));
            },
            child: const Text('Add food'),
          ),
        ],
      );
}
