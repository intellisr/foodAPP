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
  bool isSameUser =  false;

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

    // Fetch user data to check if the user is an admin
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user?.email) // Assuming the user's ID is stored in the document
          .get();

      var userDetails=userSnapshot.data() as Map<String, dynamic>?;
      var adminIs=userDetails?['role'] == 'admin';
      var sameUser=user?.email == recipeData?['rating'];    
      setState(() {
        isAdmin = adminIs; // Check if user is admin
        isSameUser = sameUser;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Delete recipe function
  Future<void> _deleteRecipe() async {
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe deleted successfully!')),
      );
      Navigator.pop(context); // Go back to the previous screen after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete recipe: $e')),
      );
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
        color: Colors.green[50],
        padding: EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Other details like user, mealName, etc.
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
              _buildRatingsSection(), // Add this widget for ratings
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
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
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
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
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
          valueLabelPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          valueLabelMargin: const EdgeInsets.only(right: 8),
          starColor: Colors.green,
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
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[800]),
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

  // This method fetches and displays the ratings
  Widget _buildRatingsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rating')
          .where('recipe_id', isEqualTo: widget.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ratings & Comments',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800]),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true, // Allow ListView inside ScrollView
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var ratingData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          'User: ${ratingData['user']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rating: ${ratingData['rating']} stars'),
                            SizedBox(height: 4),
                            Text(ratingData['comment'] ?? 'No comment'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Text('No ratings yet.');
        }
      },
    );
  }
}
