import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipeScreen extends StatefulWidget {
  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
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

  final List<String> mealTimes = ['Breakfast', 'Lunch', 'Dinner','Any Time'];
  final List<String> recipeSeasons = ['Spring', 'Summer', 'Autumn', 'Winter', 'Sunny', 'Rainy', 'Not Seasonal'];

  void addIngredient() {
    if (ingredientController.text.isNotEmpty) {
      setState(() {
        ingredients.add(ingredientController.text);
        ingredientController.clear();
      });
    }
  }

  Future<void> saveRecipe() async {
    if (mealNameController.text.isNotEmpty &&
        selectedMealTime != null &&
        ingredients.isNotEmpty &&
        selectedRecipeSeason != null &&
        cookingStepsController.text.isNotEmpty &&
        ingredientBenefitsController.text.isNotEmpty &&
        culinaryTrendsController.text.isNotEmpty &&
        recipeCultureController.text.isNotEmpty &&
        recipeDescriptionController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('recipes').add({
          'user':user?.email,
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
          'share':false,
          'rating':0.1,
          'rating_count':0.1
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add recipe.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.'),backgroundColor: Colors.green,));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Meal Name', mealNameController),
              SizedBox(height: 20),
              Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              ...ingredients.map((ingredient) => ListTile(
                    title: Text(ingredient, style: TextStyle(color: Colors.green[800])),
                    leading: Icon(Icons.check_circle, color: Colors.green),
                  )),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Add Ingredient', ingredientController),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: Colors.green),
                    onPressed: addIngredient,
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDropdown('Meal Time', mealTimes, selectedMealTime, (value) {
                setState(() {
                  selectedMealTime = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Ready In Time (e.g., 30 minutes)', readyInTimeController),
              SizedBox(height: 16),
              _buildDropdown('Recipe Season', recipeSeasons, selectedRecipeSeason, (value) {
                setState(() {
                  selectedRecipeSeason = value;
                });
              }),
              SizedBox(height: 16),
              _buildTextField('Cooking Steps (Add each step line by line)', cookingStepsController, maxLines: null),
              SizedBox(height: 16),
              _buildTextField('Ingredient Benefits', ingredientBenefitsController, maxLines: null),
              SizedBox(height: 16),
              _buildTextField('Culinary Trends', culinaryTrendsController, maxLines: null),
              SizedBox(height: 16),
              _buildTextField('Recipe Food Culture', recipeCultureController, maxLines: null),
              SizedBox(height: 16),
              _buildTextField('Recipe Description', recipeDescriptionController, maxLines: null),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('Save Recipe', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int? maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.green[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}