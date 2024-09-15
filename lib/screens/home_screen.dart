import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green,
        actions: [
          // User email display
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  user.email ?? 'No Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          // Sign-out button
          IconButton(
            icon: Icon(Icons.logout, semanticLabel: "Sign out"),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to sign out: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              color: Colors.green,
              child: Column(
                children: [
                  Image.network('https://i.ibb.co/2txqMcF/logo.png',
                      width: 70), // Add your logo here
                  SizedBox(height: 5),
                  Text(
                    'Good Chef',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Welcome Text
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: Text(
            //     'Welcome to Recipe Hub!',
            //     style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            //   ),
            // ),

            // Dashboard Buttons
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              padding: EdgeInsets.all(16.0),
              children: [
                _buildDashboardButton(
                  context,
                  'Search Recipes',
                  Icons.search,
                  '/recipe_search',
                ),
                _buildDashboardButton(
                  context,
                  'Add Recipes',
                  Icons.add,
                  '/add_recipe',
                ),
                _buildDashboardButton(
                  context,
                  'Cookbook',
                  Icons.book,
                  '/cookbook',
                ),
                _buildDashboardButton(
                  context,
                  'Meal Planner',
                  Icons.calendar_today,
                  '/meal_planner',
                ),
                _buildDashboardButton(
                  context,
                  'BMI Calculator',
                  Icons.fitness_center,
                  '/bmi_calculator',
                ),
                _buildDashboardButton(
                  context,
                  'Nutri Goals',
                  Icons.sports_gymnastics,
                  '/personalised_goals',
                ),
                _buildDashboardButton(
                  context,
                  'Store Finder',
                  Icons.store,
                  '/store_finder',
                ),
                _buildDashboardButton(
                  context,
                  'Food Class',
                  Icons.video_call,
                  '/class',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(4.0),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
