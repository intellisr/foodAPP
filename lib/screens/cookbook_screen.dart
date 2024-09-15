import 'package:flutter/material.dart';

class CookBookScreen extends StatelessWidget {
  final List<double> favoriteRatings = [5.0, 4.7, 4.5, 4.0]; // Ratings for Favorite cards
  final List<double> myRecipeRatings = [5.0, 4.8, 4.5, 4.3, 4.0, 3.5]; // Ratings for My Recipes cards

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cook Book'),
        backgroundColor: Colors.greenAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Favorites with background color
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.2), // Background color for this section
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Favorites', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250, // Set height for the slider
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, // Horizontal scrolling
                        itemCount: favoriteRatings.length,
                        itemBuilder: (context, index) {
                          double rating = favoriteRatings[index];
                          return Container(
                            width: 200, // Fixed width for each card in the slider
                            margin: EdgeInsets.only(right: 10), // Margin between cards
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
                                    // Row 1: A single variable
                                    Text('Variable 1: Value', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    // Row 2: Two variables in columns
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Var 2A: Value'),
                                        Text('Var 2B: Value'),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Row 3: Two more variables in columns
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Var 3A: Value'),
                                        Text('Var 3B: Value'),
                                      ],
                                    ),
                                    Spacer(),
                                    // Rating bar with 5 stars
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < rating.floor()
                                              ? Icons.star
                                              : (starIndex < rating ? Icons.star_half : Icons.star_border),
                                          color: starIndex < rating ? Colors.amber : Colors.grey,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 4),
                                    // Display rating value below stars
                                    Center(
                                      child: Text(
                                        'Rating: $rating',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Section 2: My Recipes
              Text('My Recipes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Disable scrolling for grid view
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: myRecipeRatings.length, // Displaying 6 cards
                itemBuilder: (context, index) {
                  double rating = myRecipeRatings[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: A single variable
                          Text('Variable 1: Value', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Row 2: Two variables in columns
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Var 2A: Value'),
                              Text('Var 2B: Value'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 3: Two more variables in columns
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Var 3A: Value'),
                              Text('Var 3B: Value'),
                            ],
                          ),
                          Spacer(),
                          // Rating bar with 5 stars
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < rating.floor()
                                    ? Icons.star
                                    : (starIndex < rating ? Icons.star_half : Icons.star_border),
                                color: starIndex < rating ? Colors.amber : Colors.grey,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          // Display rating value below stars
                          Center(
                            child: Text(
                              'Rating: $rating',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
