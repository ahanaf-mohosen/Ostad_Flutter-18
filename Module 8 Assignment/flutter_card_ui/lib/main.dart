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
      title: 'Flutter Card UI',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          elevation: 0,
        ),
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
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Profile Card
            Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                        "assets/profile.jpg",
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "John Doe",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Flutter Developer",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Passionate about creating user-friendly and engaging digital experiences.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Divider(color: Colors.grey.shade300),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
                        Icon(Icons.email, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "john.doe@example.com",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: const [
                        Icon(Icons.phone, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "+123 456 7890",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Follow"),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Message"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child: Divider(
                    color: Colors.grey.shade400,
                  ),
                ),

                const Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Interests",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),

                Expanded(
                  child: Divider(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                Expanded(
                  child: interestCard(
                    image: "assets/travel.jpg",
                    title: "Travel",
                    description:
                    "Exploring new places around the world",
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: interestCard(
                    image: "assets/camera.jpg",
                    title: "Photography",
                    description:
                    "Capturing moments through the lens",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget interestCard({
    required String image,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius:
              BorderRadius.circular(8),
              child: Image.asset(
                image,
                height: 95,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                ),
                child: const Text("View More"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}