import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CookBookScreen extends StatefulWidget {
  @override
  _CookBookScreenState createState() => _CookBookScreenState();
}

class _CookBookScreenState extends State<CookBookScreen> {
  List<DocumentSnapshot> myRecipes = [];
  final User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController mealNameController = TextEditingController();
  final TextEditingController readyInTimeController = TextEditingController();
  final TextEditingController ingredientController = TextEditingController();
  final TextEditingController cookingStepsController = TextEditingController();
  final TextEditingController ingredientBenefitsController = TextEditingController();
  final TextEditingController culinaryTrendsController = TextEditingController();
  final TextEditingController recipeCultureController = TextEditingController();
  final TextEditingController recipeDescriptionController = TextEditingController();

  String? selectedMealTime;
  String? selectedRecipeSeason;
  List<String> ingredients = [];
  bool isEditing = false; // Track whether we're adding or editing
  String? editingRecipeId; // Store the recipe ID for editing

  @override
  void initState() {
    super.initState();
    loadMyRecipes();
  }

  Future<void> loadMyRecipes() async {
    try {
      QuerySnapshot myRecipeSnapshot = await FirebaseFirestore.instance
          .collection('recipes')
          .where('user', isEqualTo: user!.email ?? 'No Email')
          .where('share', isEqualTo: false) // Only fetch private recipes
          .get();

      myRecipes = myRecipeSnapshot.docs;
      setState(() {});
    } catch (e) {
      print('Error loading my recipes: $e');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading my recipes: $e')));
    }
  }

  Future<void> saveRecipe() async {
    if (mealNameController.text.isNotEmpty && ingredients.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('recipes').add({
          'user': user?.email,
          'mealName': mealNameController.text,
          'mealTime': selectedMealTime,
          'ingredients': ingredients,
          'readyInTime': readyInTimeController.text,
          'recipeSeason': selectedRecipeSeason,
          'cookingSteps': cookingStepsController.text,
          'ingredientBenefits': ingredientBenefitsController.text,
          'culinaryTrends': culinaryTrendsController.text,
          'recipeCulture': recipeCultureController.text,
          'recipeDescription': recipeDescriptionController.text,
          'share': false,
          'rating': 0.1,
          'rating_count': 0.1
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
        clearFields();
        loadMyRecipes(); // Refresh the list after adding
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add recipe.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in the name and ingredients.'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> updateRecipe() async {
    if (mealNameController.text.isNotEmpty && ingredients.isNotEmpty && editingRecipeId != null) {
      try {
        await FirebaseFirestore.instance.collection('recipes').doc(editingRecipeId).update({
          'mealName': mealNameController.text,
          'mealTime': selectedMealTime,
          'ingredients': ingredients,
          'readyInTime': readyInTimeController.text,
          'recipeSeason': selectedRecipeSeason,
          'cookingSteps': cookingStepsController.text,
          'ingredientBenefits': ingredientBenefitsController.text,
          'culinaryTrends': culinaryTrendsController.text,
          'recipeCulture': recipeCultureController.text,
          'recipeDescription': recipeDescriptionController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe updated successfully!')));
        clearFields();
        loadMyRecipes(); // Refresh the list after updating
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update recipe.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in the name and ingredients.'), backgroundColor: Colors.redAccent));
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await FirebaseFirestore.instance.collection('recipes').doc(recipeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe deleted successfully!')));
      loadMyRecipes(); // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete recipe.')));
    }
  }

  void clearFields() {
    mealNameController.clear();
    readyInTimeController.clear();
    ingredientController.clear();
    cookingStepsController.clear();
    ingredientBenefitsController.clear();
    culinaryTrendsController.clear();
    recipeCultureController.clear();
    recipeDescriptionController.clear();
    selectedMealTime = null;
    selectedRecipeSeason = null;
    ingredients.clear();
    isEditing = false; // Reset to "add mode"
    editingRecipeId = null; // Clear editing recipe ID
  }

  void loadRecipeToEdit(DocumentSnapshot recipeDoc) {
    var data = recipeDoc.data() as Map<String, dynamic>;
    
    mealNameController.text = data['mealName'];
    readyInTimeController.text = data['readyInTime'] ?? '';
    selectedMealTime = data['mealTime'];
    selectedRecipeSeason = data['recipeSeason'];
    ingredients = List<String>.from(data['ingredients'] ?? []);
    
    cookingStepsController.text = data['cookingSteps'] ?? '';
    ingredientBenefitsController.text = data['ingredientBenefits'] ?? '';
    culinaryTrendsController.text = data['culinaryTrends'] ?? '';
    recipeCultureController.text = data['recipeCulture'] ?? '';
    recipeDescriptionController.text = data['recipeDescription'] ?? '';
    
    isEditing = true; // Switch to editing mode
    editingRecipeId = recipeDoc.id; // Store the recipe ID for editing
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cook Book'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add/Edit Recipe Section
              _buildTextField('Meal Name', mealNameController),
              SizedBox(height: 20),
              _buildIngredientField(),
              SizedBox(height: 20),
              _buildDropdown('Meal Time', ['Breakfast', 'Lunch', 'Dinner', 'Any Time'], selectedMealTime, (value) {
                setState(() { selectedMealTime = value; });
              }),
              SizedBox(height: 20),
              _buildTextField('Ready In Time (e.g., 30 minutes)', readyInTimeController),
              SizedBox(height: 20),
              _buildDropdown('Recipe Season', ['Spring', 'Summer', 'Autumn', 'Winter', 'Sunny', 'Rainy', 'Not Seasonal'], selectedRecipeSeason, (value) {
                setState(() { selectedRecipeSeason = value; });
              }),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: isEditing ? updateRecipe : saveRecipe, // Toggle between add and update
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(isEditing ? 'Update Recipe' : 'Add Recipe', style: TextStyle(fontSize: 18)),
                ),
              ),
              
              SizedBox(height: 40),

              // My Recipes Section
              Text('My Recipes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              myRecipes.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: myRecipes.length,
                      itemBuilder: (context, index) {
                        var recipeData = myRecipes[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(recipeData['mealName']),
                            subtitle:
                                Text('${recipeData['mealTime']} - ${recipeData['readyInTime']}'),
                            trailing:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => loadRecipeToEdit(myRecipes[index]),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteRecipe(myRecipes[index].id),
                                  ),
                                ]),
                            onTap: () => loadRecipeToEdit(myRecipes[index]),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        TextField(controller: controller),
      ],
    );
  }

  Widget _buildIngredientField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients', style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ingredientController,
                decoration: InputDecoration(hintText: 'Enter ingredient'),
              ),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (ingredientController.text.isNotEmpty) {
                  setState(() {
                    ingredients.add(ingredientController.text);
                    ingredientController.clear();
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ingredients
              .map((ingredient) => Chip(
                    label: Text(ingredient),
                    onDeleted: () {
                      setState(() {
                        ingredients.remove(ingredient);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> options, String? selectedValue, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: options.map((option) {
            return DropdownMenuItem(value: option, child: Text(option));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}