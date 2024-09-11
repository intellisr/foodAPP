import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipe Details')),
      body: Center(child: Text('Details for recipe $recipeId')),
    );
  }
}