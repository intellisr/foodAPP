import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to Recipe Hub!'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recipe_search');
              },
              child: const Text('Search Recipes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/favorites');
              },
              child: const Text('Favorites'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/meal_planner');
              },
              child: const Text('Meal Planner'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bmi_calculator');
              },
              child: const Text('BMI Calculator'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/store_finder');
              },
              child: const Text('Store Finder'),
            ),
          ],
        ),
      ),
    );
  }
}