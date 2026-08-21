import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String currentRoute;
  const CustomDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20),
            color: const Color(0xFF5D5FEF),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.people_alt, color: Color(0xFF5D5FEF), size: 30),
                ),
                SizedBox(height: 15),
                Text(
                  'My Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your friends easily',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'My Contacts',
                    route: 'contacts',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.star_border,
                    title: 'Favorites',
                    route: 'favorites',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_add_alt,
                    title: 'Add Contact',
                    route: 'add',
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'About App',
                    route: 'about',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    route: 'settings',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    route: 'logout',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    bool isSelected = currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF5D5FEF).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF5D5FEF) : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF5D5FEF) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isSelected) {
            if (route == 'contacts') {
              Navigator.pushReplacementNamed(context, '/');
            } else if (route == 'favorites') {
              Navigator.pushNamed(context, '/favorites');
            } else if (route == 'settings') {
              Navigator.pushNamed(context, '/settings');
            } else if (route == 'add') {
              // We don't have a named route for add yet, but we can add it or just push
              Navigator.pushNamed(context, '/add');
            }
          }
        },
      ),
    );
  }
}
