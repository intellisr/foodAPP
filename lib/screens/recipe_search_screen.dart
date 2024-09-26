import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_hub/screens/recipe_detail_screen.dart';

class RecipeSearchScreen extends StatefulWidget {
  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> recipes = []; // To store retrieved recipes
  final List<double> ratings = []; // Initial ratings (mocked)

  // Function to search for recipes by name and ingredients
  Future<void> searchRecipes() async {
    String query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return; // Do nothing if search is empty
    }

    // Get Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Search by meal name
    QuerySnapshot nameQuerySnapshot = await firestore
        .collection('recipes')
        .where('share', isEqualTo: true) // Only fetch shared recipes
        .where('mealName', isGreaterThanOrEqualTo: query)
        .where('mealName', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    // Search for recipes where ingredients contain the query as a substring (case insensitive)
    QuerySnapshot ingredientsQuerySnapshot = await firestore
        .collection('recipes')
        .where('share', isEqualTo: true)
        .get(); // Get all shared recipes

    // Filter manually in code based on lookalike ingredients
    List<DocumentSnapshot> matchedRecipes =
        ingredientsQuerySnapshot.docs.where((doc) {
      List<String> ingredients = List<String>.from(doc['ingredients']);
      return ingredients
          .any((ingredient) => ingredient.toLowerCase().contains(query));
    }).toList();

    // Combine results (removing duplicates)
    List<DocumentSnapshot> allResults = [
      ...nameQuerySnapshot.docs,
      ...matchedRecipes,
    ].toSet().toList(); // Using Set to remove duplicates

    setState(() {
      recipes = allResults; // Update the list of recipes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar with icon
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or ingredient',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search button
            ElevatedButton.icon(
              onPressed: searchRecipes,
              icon: Icon(Icons.search),
              label: Text('Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Displaying recipe cards
            Expanded(
              child: recipes.isEmpty
                  ? Center(child: Text('No recipes found.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        var recipeData =
                            recipes[index].data() as Map<String, dynamic>;
                        double rating = recipeData['rating'] ?? 0.0;

                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      documentId: recipes[index].id),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display meal name
                                    Text(recipeData['mealName'].toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Meal Time : ${recipeData['mealTime']}'),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Season : ${recipeData['recipeSeason']}'),
                                    const SizedBox(height: 8),
                                    Text('Time : ${recipeData['readyInTime']}'),
                                    Spacer(),
                                    // Rating bar with 5 stars
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < rating.floor()
                                              ? Icons.star
                                              : (starIndex < rating
                                                  ? Icons.star_half
                                                  : Icons.star_border),
                                          color: starIndex < rating
                                              ? Colors.amber
                                              : Colors.grey,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 4),
                                    Center(
                                      child: Text(
                                        'Rating: $rating',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
