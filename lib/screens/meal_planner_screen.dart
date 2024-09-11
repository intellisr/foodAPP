import 'package:flutter/material.dart';

class MealPlannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meal Planner')),
      body: Center(child: Text('Plan your meals here.')),
    );
  }
}