import 'package:flutter/material.dart';
import 'package:contact_management_app/database/database_helper.dart';
import 'package:contact_management_app/models/contact.dart';
import 'package:contact_management_app/screens/add_edit_contact_screen.dart';
import 'package:contact_management_app/screens/contact_details_screen.dart';
import 'package:contact_management_app/screens/favorites_screen.dart';
import 'package:contact_management_app/screens/settings_screen.dart';
import 'package:contact_management_app/widgets/contact_card.dart';
import 'package:contact_management_app/widgets/custom_drawer.dart';

class ContactListScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final ThemeMode themeMode;

  const ContactListScreen({
    super.key,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _db.getAllContacts();
    setState(() {
      _contacts = contacts;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = _contacts;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredContacts = _contacts.where((c) {
        return c.name.toLowerCase().contains(query) ||
            c.phone.contains(query) ||
            c.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void _filterContacts(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterContacts('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Toggle search visibility if needed, but UI shows a persistent bar
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const CustomDrawer(currentRoute: 'contacts'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor,
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: _clearSearch,
                    )
                  : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          return ContactCard(
                            contact: contact,
                            onTap: () => _navigateToDetails(contact),
                            onFavoriteToggle: () async {
                              await _db.toggleFavorite(
                                contact.id!,
                                !contact.isFavorite,
                              );
                              await _loadContacts();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildEmptyState() {
    bool isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.contacts_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No results found' : 'No contacts yet',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try searching for something else.'
                : 'Add your first contact by tapping\nthe + button below.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditContactScreen(),
      ),
    );
    if (result == true) {
      _loadContacts();
    }
  }

  void _navigateToDetails(Contact contact) async {
    // Navigation to Details screen (to be implemented)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsScreen(contact: contact),
      ),
    );
    if (result == true) {
      _loadContacts();
    }
  }
}
