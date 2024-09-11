import 'package:flutter/material.dart';

class RecipeSearchScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();

  void searchRecipes() {
    // Implement search functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Recipes')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: searchController, decoration: InputDecoration(labelText: 'Search by ingredient')),
            ElevatedButton(onPressed: searchRecipes, child: Text('Search')),
          ],
        ),
      ),
    );
  }
}