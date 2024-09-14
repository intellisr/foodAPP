import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class RecipeDetailScreen extends StatefulWidget {
  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final String documentId = "P0J8GyFKdooUZsb0RLsA";
  final String user = "sathirx";
  Map<String, dynamic>? recipeData;
  double rating = 0;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRecipeData();
  }

  Future<void> _fetchRecipeData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('recipes').doc(documentId).get();
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
        await FirebaseFirestore.instance.collection('rating').doc(documentId).update({
          'recipe_id': documentId,
          'rating': rating,
          'comment': commentController.text,
          'user': user, // Hardcoded user
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rating and comment added!')));
        commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add rating and comment.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a comment.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recipeData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Recipe Details'),
          backgroundColor: Colors.green[800],
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Details'),
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        color: Colors.green[50], // Light green background
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailField('User', recipeData!['user']),
              _buildDetailField('Meal Name', recipeData!['mealName']),
              _buildDetailField('Meal Time', recipeData!['mealTime']),
              _buildDetailField('Ready In Time', recipeData!['readyInTime']),
              _buildDetailField('Recipe Season', recipeData!['recipeSeason']),
              _buildDetailField('Cooking Steps', recipeData!['cookingSteps']),
              _buildDetailField('Ingredient Benefits', recipeData!['ingredientBenefits']),
              _buildDetailField('Culinary Trends', recipeData!['culinaryTrends']),
              _buildDetailField('Recipe Food Culture', recipeData!['recipeCulture']),
              _buildDetailField('Recipe Description', recipeData!['recipeDescription']),
              _buildIngredientList(recipeData!['ingredients']),
              if (recipeData!['user'] != user) ...[
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
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Submit Rating & Comment', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(height: 4),
          Text(
            value is String ? value.replaceAll('\\n', '\n') : value.toString(),
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(List<dynamic> ingredients) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredients',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
          ),
          SizedBox(height: 4),
          ...ingredients.map((ingredient) => Text(
                ingredient,
                style: TextStyle(fontSize: 16, color: Colors.green[700]),
              )),
        ],
      ),
    );
  }

  Widget _buildRatingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        SizedBox(height: 4),
        RatingStars(
          value: rating,
          onValueChanged: (newRating) {
            setState(() {
              rating = newRating;
            });
          },
          starBuilder: (index, color) => Icon(
            Icons.star,
            color: color,
          ),
          starCount: 5,
          starSize: 30,
          valueLabelColor: Colors.black,
          valueLabelTextStyle: TextStyle(color: Colors.white),
          valueLabelRadius: 10,
          valueLabelPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          valueLabelMargin: const EdgeInsets.only(right: 8),
          starColor: Colors.yellow,
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
        ),
        SizedBox(height: 4),
        TextField(
          controller: commentController,
          maxLines: 3,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: 'Enter your comment here...',
          ),
        ),
      ],
    );
  }
}