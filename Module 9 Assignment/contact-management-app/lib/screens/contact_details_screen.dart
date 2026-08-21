import 'package:flutter/material.dart';
import 'package:contact_management_app/database/database_helper.dart';
import 'package:contact_management_app/models/contact.dart';
import 'package:contact_management_app/screens/add_edit_contact_screen.dart';
import 'package:contact_management_app/widgets/delete_confirmation_dialog.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;
  const ContactDetailsScreen({super.key, required this.contact});

  @override
  State<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> words = name.trim().split(RegExp(r'\s+'));
    if (words.length > 1 && words[1].isNotEmpty) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
        actions: [
          IconButton(
            icon: Icon(
              _contact.isFavorite ? Icons.star : Icons.star_border,
              color: _contact.isFavorite ? Colors.amber : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF5D5FEF).withOpacity(0.1),
                child: Text(
                  _getInitials(_contact.name),
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D5FEF),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _contact.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      _buildInfoTile(Icons.phone_outlined, _contact.phone, 'Mobile'),
                      const Divider(),
                      _buildInfoTile(Icons.email_outlined, _contact.email, 'Email'),
                      const Divider(),
                      _buildInfoTile(Icons.location_on_outlined, _contact.address, 'Address'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5D5FEF)),
      title: Text(value.isEmpty ? 'Not set' : value),
      subtitle: Text(label),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _toggleFavorite() async {
    final newStatus = !_contact.isFavorite;
    await _db.toggleFavorite(_contact.id!, newStatus);
    setState(() {
      _contact.isFavorite = newStatus;
    });
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditContactScreen(contact: _contact),
      ),
    );
    if (result == true) {
      Navigator.pop(context, true);
    }
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(contactName: _contact.name),
    );

    if (result == true) {
      await _db.deleteContact(_contact.id!);
      Navigator.pop(context, true);
    }
  }
}
