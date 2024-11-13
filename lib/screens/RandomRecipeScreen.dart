import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_hub/screens/recipe_detail_screen.dart';
import 'package:recipe_hub/screens/login_screen.dart';

class RandomRecipeScreen extends StatefulWidget {
  @override
  _RandomRecipeScreenState createState() => _RandomRecipeScreenState();
}

class _RandomRecipeScreenState extends State<RandomRecipeScreen> {
  List<DocumentSnapshot> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRandomRecipes();
  }

  Future<void> fetchRandomRecipes() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch 10 random shared recipes
    QuerySnapshot querySnapshot = await firestore
        .collection('recipes')
        .where('share', isEqualTo: true)
        .limit(10)
        .get();

    setState(() {
      recipes = querySnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/foodapp-c2836.appspot.com/o/GOOD%20CHEF.png?alt=media&token=e4cf71cd-85dc-4772-83c4-6affac094c64',
          height: 100, // Adjust height as needed
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.login, color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Color.fromARGB(217, 255, 193, 193),
        child: recipes.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  var recipeData = recipes[index].data() as Map<String, dynamic>;
                  double rating = recipeData['rating'] ?? 0.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            documentId: recipes[index].id,
                          ),
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
                            if (recipeData['recipePicture'] != null)
                              Center(
                                child: Image.network(
                                  recipeData['recipePicture'],
                                  height: 85,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Text(
                              recipeData['mealName'].toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text('Meal Time : ${recipeData['mealTime']}'),
                            const SizedBox(height: 6),
                            Text('Season : ${recipeData['recipeSeason']}'),
                            const SizedBox(height: 6),
                            Text('Time : ${recipeData['readyInTime']}'),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
