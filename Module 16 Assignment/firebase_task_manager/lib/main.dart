import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final notificationService = NotificationService();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool _loading = true;
  String? _firebaseError;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeFirebase());
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      if (!mounted) return;
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(notificationService.initialize().catchError((_) {}));
      });
    } catch (error) {
      if (mounted) setState(() => _firebaseError = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TaskFlow',
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF635BFF)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    ),
    home: _firebaseError != null
        ? FirebaseSetupScreen(error: _firebaseError!)
        : _loading
        ? const LoadingScreen()
        : const AuthGate(),
  );
}

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({required this.error, super.key});
  final String error;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF6F7FB),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Color(0xFF635BFF),
              ),
              const SizedBox(height: 20),
              const Text(
                'Connect your Firebase project',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add your platform configuration, then run `flutterfire configure` and launch again.',
              ),
              const SizedBox(height: 14),
              SelectableText(
                error,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const LoadingScreen();
      }
      return snapshot.data == null
          ? const LoginScreen()
          : const TaskHomeScreen();
    },
  );
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  Future<void> email(
    String email,
    String password, {
    required bool create,
  }) async {
    if (create) {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } else {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    }
  }

  Future<void> google() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return;
    final tokens = await account.authentication;
    await _auth.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signup = false, _busy = false, _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      _message(e.message ?? 'Authentication failed');
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E8FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: Color(0xFF635BFF),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _signup ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _signup
                      ? 'Start planning your day, one task at a time.'
                      : 'Sign in to pick up where you left off.',
                  style: const TextStyle(color: Color(0xFF77798A)),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Email address'),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      const _FieldLabel('Password'),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText: 'At least 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Use at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _busy
                              ? null
                              : () {
                                  if (_form.currentState!.validate()) {
                                    _run(
                                      () => AuthService().email(
                                        _email.text,
                                        _password.text,
                                        create: _signup,
                                      ),
                                    );
                                  }
                                },
                          child: _busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_signup ? 'Create account' : 'Sign in'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _run(AuthService().google),
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: const Text('Continue with Google'),
                  ),
                ),
                const SizedBox(height: 22),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _signup = !_signup),
                    child: Text(
                      _signup
                          ? 'Already have an account? Sign in'
                          : 'New here? Create an account',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.completed,
    required this.createdAt,
  });
  final String id, title, description, priority;
  final DateTime dueDate, createdAt;
  final bool completed;

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TaskItem(
      id: doc.id,
      title: data?['title'] as String? ?? '',
      description: data?['description'] as String? ?? '',
      dueDate: (data?['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: data?['priority'] as String? ?? 'Medium',
      completed: data?['completed'] as bool? ?? false,
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() => {
    'title': title,
    'description': description,
    'dueDate': Timestamp.fromDate(dueDate),
    'priority': priority,
    'completed': completed,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class TaskRepository {
  final String uid;
  TaskRepository(this.uid);
  CollectionReference<Map<String, dynamic>> get _tasks => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .collection('tasks');

  Stream<List<TaskItem>> watch() => _tasks
      .orderBy('dueDate')
      .snapshots()
      .map((s) => s.docs.map(TaskItem.fromDoc).toList());

  Future<void> save(TaskItem task) async {
    if (task.id.isEmpty) {
      final created = TaskItem(
        id: '',
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        priority: task.priority,
        completed: task.completed,
        createdAt: DateTime.now(),
      );
      await _tasks.add(created.toMap());
    } else {
      await _tasks.doc(task.id).update(task.toMap()..remove('createdAt'));
    }
  }

  Future<void> delete(String id) => _tasks.doc(id).delete();
  Future<void> toggle(TaskItem task) =>
      _tasks.doc(task.id).update({'completed': !task.completed});
}

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({super.key});
  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  String _filter = 'All';
  String _query = '';
  late final TaskRepository _repository = TaskRepository(
    FirebaseAuth.instance.currentUser?.uid ?? '',
  );

  @override
  void initState() {
    super.initState();
    notificationService.onTaskOpened = _openTask;
    notificationService.initializeForUser();
  }

  @override
  void dispose() {
    if (notificationService.onTaskOpened == _openTask) {
      notificationService.onTaskOpened = null;
    }
    super.dispose();
  }

  void _openTask(String? id) {
    if (!mounted) return;
    if (id == null) return;
    _repository.watch().first.then((tasks) {
      final matches = tasks.where((task) => task.id == id);
      if (matches.isNotEmpty && mounted) {
        showDialog<void>(
          context: context,
          builder: (_) => _TaskDetailsDialog(task: matches.first),
        );
      }
    });
  }

  Future<void> _edit([TaskItem? task]) async {
    final result = await showDialog<TaskItem>(
      context: context,
      builder: (_) => TaskEditorDialog(task: task),
    );
    if (result != null) await _repository.save(result);
  }

  Future<void> _delete(TaskItem task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await _repository.delete(task.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoadingScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: FirebaseAuth.instance.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New task'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TaskItem>>(
          stream: _repository.watch(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load tasks. Check your Firestore rules and connection.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snapshot.data!;
            final tasks = all
                .where(
                  (t) =>
                      (_filter == 'All' ||
                          (_filter == 'Pending'
                              ? !t.completed
                              : t.completed)) &&
                      ('${t.title} ${t.description}'.toLowerCase().contains(
                        _query.toLowerCase(),
                      )),
                )
                .toList();
            final pending = all.where((t) => !t.completed).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
              children: [
                Text(
                  'Good ${_greeting()}, ${user.displayName?.split(' ').first ?? 'there'} 👋',
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pending == 0
                      ? 'You’re all caught up.'
                      : 'You have $pending task${pending == 1 ? '' : 's'} to focus on today.',
                  style: const TextStyle(color: Color(0xFF77798A)),
                ),
                const SizedBox(height: 22),
                _SummaryCard(
                  total: all.length,
                  pending: pending,
                  completed: all.length - pending,
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Search tasks',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: ['All', 'Pending', 'Completed']
                      .map(
                        (label) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: _filter == label,
                            onSelected: (_) => setState(() => _filter = label),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filter == 'All' ? 'Your tasks' : '$_filter tasks',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${tasks.length} items',
                      style: const TextStyle(
                        color: Color(0xFF888A99),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (tasks.isEmpty)
                  _EmptyTasks(onAdd: () => _edit())
                else
                  ...tasks.map(
                    (task) => _TaskCard(
                      task: task,
                      onToggle: () => _repository.toggle(task),
                      onEdit: () => _edit(task),
                      onDelete: () => _delete(task),
                      onOpen: () => showDialog<void>(
                        context: context,
                        builder: (_) => _TaskDetailsDialog(task: task),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    return hour < 12
        ? 'morning'
        : hour < 17
        ? 'afternoon'
        : 'evening';
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.pending,
    required this.completed,
  });
  final int total, pending, completed;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF635BFF), Color(0xFF817AFF)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your progress', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(
          '$completed of $total completed',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 7,
            backgroundColor: Colors.white24,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$pending left to do',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    ),
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onOpen,
  });
  final TaskItem task;
  final VoidCallback onToggle, onEdit, onDelete, onOpen;
  @override
  Widget build(BuildContext context) {
    final tint = task.priority == 'High'
        ? const Color(0xFFFFE7E5)
        : task.priority == 'Low'
        ? const Color(0xFFE7F6EF)
        : const Color(0xFFFFF2D8);
    final ink = task.priority == 'High'
        ? const Color(0xFFDE594E)
        : task.priority == 'Low'
        ? const Color(0xFF2F9C68)
        : const Color(0xFFC98717);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 13, 6, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.completed,
                onChanged: (_) => onToggle(),
                activeColor: const Color(0xFF635BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed
                            ? Colors.black45
                            : const Color(0xFF252637),
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF858797),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _Pill(label: task.priority, color: tint, ink: ink),
                        _Pill(
                          label: _dateLabel(task.dueDate),
                          color: const Color(0xFFF0F0F6),
                          ink: const Color(0xFF717384),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, required this.ink});
  final String label;
  final Color color, ink;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      label,
      style: TextStyle(color: ink, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 42),
    child: Column(
      children: [
        const Icon(Icons.task_alt_rounded, size: 42, color: Color(0xFFA8A9B7)),
        const SizedBox(height: 12),
        const Text(
          'Nothing on your list yet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        const Text(
          'Add a task to get your day moving.',
          style: TextStyle(color: Color(0xFF858797)),
        ),
        TextButton(onPressed: onAdd, child: const Text('Create a task')),
      ],
    ),
  );
}

class _TaskDetailsDialog extends StatelessWidget {
  const _TaskDetailsDialog({required this.task});
  final TaskItem task;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(task.title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description.isNotEmpty) Text(task.description),
        const SizedBox(height: 14),
        Text('Due ${_dateLabel(task.dueDate)} · ${task.priority} priority'),
        const SizedBox(height: 5),
        Text(
          task.completed ? 'Completed' : 'Pending',
          style: const TextStyle(color: Color(0xFF77798A)),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  );
}

class TaskEditorDialog extends StatefulWidget {
  const TaskEditorDialog({this.task, super.key});
  final TaskItem? task;
  @override
  State<TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<TaskEditorDialog> {
  late final _title = TextEditingController(text: widget.task?.title ?? '');
  late final _description = TextEditingController(
    text: widget.task?.description ?? '',
  );
  late DateTime _due =
      widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  late String _priority = widget.task?.priority ?? 'Medium';
  String? _titleError;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.task == null ? 'New task' : 'Edit task'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Title'),
          TextField(
            controller: _title,
            autofocus: true,
            onChanged: (_) {
              if (_titleError != null) {
                setState(() => _titleError = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Description'),
          TextField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Add a few details'),
          ),
          const SizedBox(height: 14),
          const _FieldLabel('Priority'),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            items: [
              'Low',
              'Medium',
              'High',
            ].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _due,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null && mounted) setState(() => _due = picked);
            },
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text('Due ${_dateLabel(_due)}'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final title = _title.text.trim();
          if (title.isEmpty) {
            setState(() => _titleError = 'Please enter a task title');
            return;
          }
          Navigator.pop(
            context,
            TaskItem(
              id: widget.task?.id ?? '',
              title: title,
              description: _description.text.trim(),
              dueDate: _due,
              priority: _priority,
              completed: widget.task?.completed ?? false,
              createdAt: widget.task?.createdAt ?? DateTime.now(),
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    ),
  );
}

String _dateLabel(DateTime date) => '${_month(date.month)} ${date.day}';
String _month(int month) => const [
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
][month - 1];

class NotificationService {
  final _local = FlutterLocalNotificationsPlugin();
  void Function(String?)? _taskOpened;
  String? _queuedTaskId;

  void Function(String?)? get onTaskOpened => _taskOpened;

  set onTaskOpened(void Function(String?)? callback) {
    _taskOpened = callback;
    if (_queuedTaskId != null) {
      final id = _queuedTaskId;
      _queuedTaskId = null;
      callback?.call(id);
    }
  }

  void _openTask(String? id) {
    if (_taskOpened == null) {
      _queuedTaskId = id;
    } else {
      _taskOpened!(id);
    }
  }

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) =>
          _handlePayload(response.payload),
    );
    const channel = AndroidNotificationChannel(
      'task_updates',
      'Task updates',
      description: 'Updates about your tasks',
      importance: Importance.high,
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen(_showForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _openTask(message.data['taskId'] as String?),
    );
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openTask(initial.data['taskId'] as String?),
      );
    }
    final launch = await _local.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (launch?.didNotificationLaunchApp == true && payload != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _handlePayload(payload),
      );
    }
  }

  Future<void> initializeForUser() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      final user = FirebaseAuth.instance.currentUser;
      if (token != null && user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((value) {
        final current = FirebaseAuth.instance.currentUser;
        if (current != null) {
          FirebaseFirestore.instance.collection('users').doc(current.uid).set({
            'fcmToken': value,
          }, SetOptions(merge: true));
        }
      });
    } catch (_) {}
  }

  Future<void> _showForeground(RemoteMessage message) async {
    final title =
        message.notification?.title ??
        message.data['title'] as String? ??
        'Task update';
    final body =
        message.notification?.body ??
        message.data['body'] as String? ??
        'You have a task update.';
    await _local.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_updates',
          'Task updates',
          channelDescription: 'Updates about your tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode({'taskId': message.data['taskId']}),
    );
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      _openTask(null);
      return;
    }
    String? id;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        id = decoded['taskId'] as String?;
      } else if (decoded is String) {
        id = decoded;
      }
    } catch (_) {
      id = payload;
    }
    _openTask(id);
  }
}
