import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_hub/screens/recipe_detail_screen.dart';

class MyProfileScreen extends StatefulWidget {
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  List<DocumentSnapshot> favoriteRecipes = [];
  List<DocumentSnapshot> myRecipes = [];
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    loadFavoriteRecipes();
    loadMyRecipes();
  }

  Future<void> loadFavoriteRecipes() async {
    try {
      QuerySnapshot favSnapshot = await FirebaseFirestore.instance
          .collection('fav')
          .where('user', isEqualTo: user!.email ?? 'No Email')
          .get();

      for (var doc in favSnapshot.docs) {
        DocumentSnapshot<Object?>? recipeDoc =
            await loadRecipeDetails(doc['rec_id']);
        if (recipeDoc != null) {
          favoriteRecipes.add(recipeDoc);
        }
      }

      setState(() {});
    } catch (e) {
      print('Error loading favorite recipes: $e');
    }
  }

  Future<void> loadMyRecipes() async {
    try {
      QuerySnapshot myRecipeSnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('user', isEqualTo: user!.email ?? 'No Email')
          .get();

      myRecipes = myRecipeSnapshot.docs;

      setState(() {});
    } catch (e) {
      print('Error loading my recipes: $e');
    }
  }

  Future<DocumentSnapshot?> loadRecipeDetails(String recipeId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .get();
    } catch (e) {
      print('Error loading recipe details: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Favorites with background color
              Container(
                color: Colors.redAccent
                    .withOpacity(0.2), // Light background color for better UX
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Favorites',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250, // Set height for the slider
                      child: favoriteRecipes.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              scrollDirection:
                                  Axis.horizontal, // Horizontal scrolling
                              itemCount: favoriteRecipes.length,
                              itemBuilder: (context, index) {
                                var recipeData = favoriteRecipes[index].data()
                                    as Map<String, dynamic>;
                                double rating = recipeData['rating'] ?? 0.0;
                                return Container(
                                  width:
                                      200, // Fixed width for each card in the slider
                                  margin: EdgeInsets.only(
                                      right: 10), // Margin between cards
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          RecipeDetailScreen(documentId:favoriteRecipes[index].id),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Display meal name
                                            Text(
                                                recipeData['mealName']
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Meal Time : ${recipeData['mealTime']}'),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Season : ${recipeData['recipeSeason']}'),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Time : ${recipeData['readyInTime']}'),
                                            Spacer(),
                                            // Rating bar with 5 stars
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children:
                                                  List.generate(5, (starIndex) {
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Section 2: My Recipes
              Text('My Recipes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              myRecipes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // Disable scrolling for grid view
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 cards per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: myRecipes.length, // Displaying recipe cards
                      itemBuilder: (context, index) {
                        var recipeData =
                            myRecipes[index].data() as Map<String, dynamic>;
                        double rating = recipeData['rating'] ?? 0.0;
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                      documentId: myRecipes[index].id),
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
                                  ],
                                ),
                              ),
                            ));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
