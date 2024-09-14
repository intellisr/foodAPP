// import 'package:flutter/material.dart';

// class RecipeSearchScreen extends StatelessWidget {
//   final TextEditingController searchController = TextEditingController();

//   void searchRecipes() {
//     // Implement search functionality
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Search Recipes')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(controller: searchController, decoration: InputDecoration(labelText: 'Search by ingredient')),
//             ElevatedButton(onPressed: searchRecipes, child: Text('Search')),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class RecipeSearchScreen extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final List<double> ratings = [5.0, 4.3, 4.0, 1.0]; // Initial ratings for the 4 cards

  void searchRecipes() {
    // Implement search functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar with icon
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by ingredient',
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
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section with cards
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cards per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: 4, // Displaying 4 cards
                itemBuilder: (context, index) {
                  double rating = ratings[index];

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
            ),
          ],
        ),
      ),
    );
  }
}

