import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitflow/meal_home.dart';
import 'package:fitflow/selection_screen.dart';
import 'package:fitflow/sign_in.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    String userName = user?.displayName ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("FitFlow"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Good Morning 🔥",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Popular Workouts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              /// **✅ Corrected Horizontal List for Workouts**
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    WorkoutCard(
                      title: "Lower Body Training",
                      imagePath: "assets/images/lower_body.jpg",
                      calories: "500 Kcal",
                      duration: "50 Min",
                    ),
                    WorkoutCard(
                      title: "Upper Body Training",
                      imagePath: "assets/images/upper_body.jpg",
                      calories: "400 Kcal",
                      duration: "40 Min",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Today’s Plan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              /// **✅ Corrected Plan Cards**
              const PlanCard(
                title: "Push Up",
                subtitle: "100 Push ups a day",
                progress: 0.45,
                level: "Intermediate",
              ),
              const PlanCard(
                title: "Sit Up",
                subtitle: "20 Sit ups a day",
                progress: 0.75,
                level: "Beginner",
              ),
              const PlanCard(
                title: "Knee Push Up",
                subtitle: "15 Knee push ups a day",
                progress: 0.30,
                level: "Beginner",
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      /// **✅ Updated Bottom Navigation Bar**
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  /// **🚀 Logout Confirmation Dialog**
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// ✅ **Workout Card Widget**
class WorkoutCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String calories;
  final String duration;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.calories,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white),
                const SizedBox(width: 5),
                Text(calories, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 20),
                const Icon(Icons.access_time, color: Colors.white),
                const SizedBox(width: 5),
                Text(duration, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Plan Card Widget**
class PlanCard extends StatelessWidget {
  final String title, subtitle, level;
  final double progress;

  const PlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    level,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, color: Colors.lightGreen),
          ],
        ),
      ),
    );
  }
}

/// ✅ **Bottom Navigation Bar**
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.lightGreen,
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostureScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealHomeScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.rocket), label: "Exercises"),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Meal Planning",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
