import 'package:flutter/material.dart';
import 'package:contact_management_app/models/contact.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool showFavoriteIcon;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onFavoriteToggle,
    this.showFavoriteIcon = false,
  });

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
    final List<Color> avatarColors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
    ];
    final colorIndex = contact.name.isNotEmpty ? contact.name.codeUnitAt(0) % avatarColors.length : 0;
    final avatarColor = avatarColors[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: avatarColor,
          child: Text(
            _getInitials(contact.name),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.email.isNotEmpty)
              Text(
                contact.email,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            Text(
              contact.phone,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        trailing: showFavoriteIcon 
          ? IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
                color: contact.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      ),
    );
  }
}
