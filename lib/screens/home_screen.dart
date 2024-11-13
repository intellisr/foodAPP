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
        backgroundColor: Colors.redAccent,
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
            icon: Icon(Icons.logout, semanticLabel: "Sign out", color: Colors.white,),
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
              padding: EdgeInsets.all(5),
              color: Colors.redAccent,
              child: Column(
                children: [
                  Image.network('https://firebasestorage.googleapis.com/v0/b/foodapp-c2836.appspot.com/o/GOOD%20CHEF.png?alt=media&token=e4cf71cd-85dc-4772-83c4-6affac094c64',
                      width: 150), // Add your logo here
                  Text(
                    'HOME',
                    style: TextStyle(
                      fontSize: 20,
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
                  'My Profile',
                  Icons.face,
                  '/my_profile',
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
                  'Shopping List',
                  Icons.list,
                  '/shopping_list',
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
              colors: [ const Color.fromARGB(141, 255, 136, 0),Colors.red,const Color.fromARGB(141, 255, 136, 0)],
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
