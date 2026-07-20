import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profile UI',
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: const Color(0xfffdf7fd),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 25),

            ProfileItem(
              icon: Icons.icecream,
              text: "Ice cream is very delicious right?",
            ),

            SizedBox(height: 45),

            ProfileItem(
              icon: Icons.code,
              text: "Programming is not boring if you love it",
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: const Color(0xffe7d9fb),
            child: Icon(
              icon,
              size: 70,
              color: const Color(0xff34126e),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}