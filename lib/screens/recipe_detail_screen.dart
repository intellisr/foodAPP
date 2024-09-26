import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String documentId;
  const RecipeDetailScreen({Key? key, required this.documentId})
      : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? recipeData;
  double rating = 0;
  TextEditingController commentController = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
    _fetchUserData();
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.documentId)
          .get();
      setState(() {
        recipeData = snapshot.data() as Map<String, dynamic>?;
        rating = recipeData?['rating'] ?? 0.0;
      });
    } catch (e) {
      print('Error fetching recipe data: $e');
    }
  }

  Future<void> _submitRatingAndComment() async {
    if (commentController.text.isNotEmpty) {
      try {
        DocumentSnapshot recipeDoc = await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.documentId)
            .get();

        double currentRating = recipeDoc.get('rating') ?? 0.0;
        int ratingCount = recipeDoc.get('rating_count') ?? 0;

        double newAverageRating =
            ((currentRating * ratingCount) + rating) / (ratingCount + 1);

        await FirebaseFirestore.instance
            .collection('recipes')
            .doc(widget.documentId)
            .update({
          'rating': num.parse(newAverageRating.toStringAsFixed(1)),
          'rating_count': ratingCount + 1,
        });

        await FirebaseFirestore.instance.collection('rating').add({
          'recipe_id': widget.documentId,
          'rating': rating,
          'comment': commentController.text,
          'user': user!.email,
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Rating and comment added!')));

        commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add rating and comment: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter a comment.')));
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user?.email)
          .get();

      var userDetails = userSnapshot.data() as Map<String, dynamic>?;
      setState(() {
        isAdmin = userDetails?['role'] == 'admin';
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _deleteRecipe() async {
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe deleted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete recipe: $e')),
      );
    }
  }

  Future<void> _shareRecipe() async {
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.documentId)
          .update({
        'share': true,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Recipe Shared')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')));
    }
  }

  Future<void> _addFavourite() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fav')
          .where('rec_id', isEqualTo: widget.documentId)
          .where('user', isEqualTo: user?.email)
          .get();

      if (snapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('fav').add({
          'rec_id': widget.documentId,
          'user': user?.email,
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Added to favorite')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Already in favorites')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to favorite: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Recipe Details'),
          backgroundColor: Colors.redAccent,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
        color: Color.fromARGB(217, 249, 160, 160),
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: _buildDetailField('User', recipeData!['user'])),
                SizedBox(width: 16),
                Expanded(
                    child: _buildDetailField(
                        'Meal Name', recipeData!['mealName'])),
              ]),
              _buildIngredientList(recipeData!['ingredients']),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: _buildDetailField(
                        'Meal Time', recipeData!['mealTime'])),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDetailField(
                        'Ready In Time', recipeData!['readyInTime'])),
              ]),
              _buildDetailField('Recipe Season', recipeData!['recipeSeason']),
              _buildDetailField('Cooking Steps', recipeData!['cookingSteps']),
              _buildDetailField(
                  'Ingredient Benefits', recipeData!['ingredientBenefits']),
              _buildDetailField(
                  'Culinary Trends', recipeData!['culinaryTrends']),
              _buildDetailField(
                  'Recipe Food Culture', recipeData!['recipeCulture']),
              _buildDetailField(
                  'Recipe Description', recipeData!['recipeDescription']),
              if (recipeData!['user'] != user!.email) ...[
                SizedBox(height: 20),
                _buildRatingField(),
                SizedBox(height: 16),
                _buildCommentField(),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRatingAndComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Submit Rating & Comment',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
              SizedBox(height: 20),
              _buildRatingsSection(),
              SizedBox(height: 16),
              if (recipeData!['user'] == user!.email && recipeData!['share'] == false) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: _shareRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Share',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
              if (recipeData!['user'] != user!.email) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: _addFavourite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Add to favourite',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
              ],
              SizedBox(height: 16),
              if (recipeData!['user'] == user!.email || isAdmin) ...[
                Center(
                  child: ElevatedButton(
                    onPressed: _deleteRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Delete Recipe',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientList(List<dynamic> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ingredients
                  .map((ingredient) => Text(
                        '- $ingredient',
                        style: TextStyle(fontSize: 16),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Your Rating:', style: TextStyle(fontSize: 18)),
        SizedBox(width: 8),
        RatingStars(
          value: rating,
          onValueChanged: (value) {
            setState(() {
              rating = value;
            });
          },
          starSize: 30,
          starCount: 5,
          starOffColor: Colors.grey,
          starColor: const Color.fromARGB(255, 81, 255, 7),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Comment:', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        TextField(
          controller: commentController,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter your comment',
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildRatingsSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rating')
          .where('recipe_id', isEqualTo: widget.documentId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var ratings = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ratings & Comments:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Column(
              children: ratings.map((doc) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rating: ${doc['rating']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Comment: ${doc['comment']}', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('User: ${doc['user']}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}