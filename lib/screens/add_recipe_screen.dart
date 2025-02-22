// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class AddRecipeScreen extends StatefulWidget {
//   @override
//   _AddRecipeScreenState createState() => _AddRecipeScreenState();
// }

// class _AddRecipeScreenState extends State<AddRecipeScreen> {
//   final User? user = FirebaseAuth.instance.currentUser;
//   final TextEditingController mealNameController = TextEditingController();
//   final TextEditingController readyInTimeController = TextEditingController();
//   final TextEditingController ingredientController = TextEditingController();
//   final TextEditingController cookingStepsController = TextEditingController();
//   final TextEditingController ingredientBenefitsController = TextEditingController();
//   final TextEditingController culinaryTrendsController = TextEditingController();
//   final TextEditingController recipeCultureController = TextEditingController();
//   final TextEditingController recipeDescriptionController = TextEditingController();

//   String? selectedMealTime;
//   String? selectedRecipeSeason;
//   List<String> ingredients = [];

//   final List<String> mealTimes = ['Breakfast', 'Lunch', 'Dinner','Any Time'];
//   final List<String> recipeSeasons = ['Spring', 'Summer', 'Autumn', 'Winter', 'Sunny', 'Rainy', 'Not Seasonal'];

//   void addIngredient() {
//     if (ingredientController.text.isNotEmpty) {
//       setState(() {
//         ingredients.add(ingredientController.text);
//         ingredientController.clear();
//       });
//     }
//   }

//   void removeIngredient(String ingredient) {
//     setState(() {
//       ingredients.remove(ingredient);
//     });
//   }

//   Future<void> saveRecipe() async {
//     if (mealNameController.text.isNotEmpty &&
//         selectedMealTime != null &&
//         ingredients.isNotEmpty &&
//         selectedRecipeSeason != null &&
//         cookingStepsController.text.isNotEmpty &&
//         ingredientBenefitsController.text.isNotEmpty &&
//         culinaryTrendsController.text.isNotEmpty &&
//         recipeCultureController.text.isNotEmpty &&
//         recipeDescriptionController.text.isNotEmpty) {
//       try {
//         await FirebaseFirestore.instance.collection('recipes').add({
//           'user': user?.email,
//           'mealName': mealNameController.text,
//           'mealTime': selectedMealTime,
//           'ingredients': ingredients,
//           'readyInTime': readyInTimeController.text,
//           'recipeSeason': selectedRecipeSeason,
//           'cookingSteps': cookingStepsController.text,
//           'ingredientBenefits': ingredientBenefitsController.text,
//           'culinaryTrends': culinaryTrendsController.text,
//           'recipeCulture': recipeCultureController.text,
//           'recipeDescription': recipeDescriptionController.text,
//           'share': true,
//           'rating': 0.1,
//           'rating_count': 0.1
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
//         setState(() {});
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add recipe.')));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.redAccent));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Recipe'),
//         backgroundColor: Colors.redAccent,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField('Meal Name', mealNameController),
//               SizedBox(height: 20),
//               Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
//               SizedBox(height: 10),
//               ...ingredients.map((ingredient) => ListTile(
//                     title: Text(ingredient, style: TextStyle(color: Colors.green[800])),
//                     leading: Icon(Icons.check_circle, color: Colors.green),
//                     trailing: IconButton(
//                       icon: Icon(Icons.remove_circle, color: Colors.red),
//                       onPressed: () => removeIngredient(ingredient),
//                     ),
//                   )),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildTextField('Add Ingredient', ingredientController),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.add_circle, color: Colors.green),
//                     onPressed: addIngredient,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               _buildDropdown('Meal Time', mealTimes, selectedMealTime, (value) {
//                 setState(() {
//                   selectedMealTime = value;
//                 });
//               }),
//               SizedBox(height: 16),
//               _buildTextField('Ready In Time (e.g., 30 minutes)', readyInTimeController),
//               SizedBox(height: 16),
//               _buildDropdown('Recipe Season', recipeSeasons, selectedRecipeSeason, (value) {
//                 setState(() {
//                   selectedRecipeSeason = value;
//                 });
//               }),
//               SizedBox(height: 16),
//               _buildTextField('Cooking Steps (Add each step line by line)', cookingStepsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Ingredient Benefits', ingredientBenefitsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Culinary Trends', culinaryTrendsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Recipe Food Culture', recipeCultureController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Recipe Description', recipeDescriptionController, maxLines: null),
//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: saveRecipe,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   ),
//                   child: Text('Save Recipe', style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {int? maxLines = 1}) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.redAccent),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.green),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
//     return DropdownButtonFormField<String>(
//       value: selectedValue,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.redAccent),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.green),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       items: items.map((String item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged:onChanged,
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'dart:io';

// class AddRecipeScreen extends StatefulWidget {
//   @override
//   _AddRecipeScreenState createState() => _AddRecipeScreenState();
// }

// class _AddRecipeScreenState extends State<AddRecipeScreen> {
//   final User? user = FirebaseAuth.instance.currentUser;
//   final TextEditingController mealNameController = TextEditingController();
//   final TextEditingController readyInTimeController = TextEditingController();
//   final TextEditingController ingredientController = TextEditingController();
//   final TextEditingController cookingStepsController = TextEditingController();
//   final TextEditingController ingredientBenefitsController = TextEditingController();
//   final TextEditingController culinaryTrendsController = TextEditingController();
//   final TextEditingController recipeCultureController = TextEditingController();
//   final TextEditingController recipeDescriptionController = TextEditingController();

//   String? selectedMealTime;
//   String? selectedRecipeSeason;
//   List<String> ingredients = [];
//   File? _imageFile; // Store the selected image file
//   String? imageUrl; // Store the image URL from Firebase Storage

//   final List<String> mealTimes = ['Breakfast', 'Lunch', 'Dinner', 'Any Time'];
//   final List<String> recipeSeasons = ['Spring', 'Summer', 'Autumn', 'Winter', 'Sunny', 'Rainy', 'Not Seasonal'];

//   void addIngredient() {
//     if (ingredientController.text.isNotEmpty) {
//       setState(() {
//         ingredients.add(ingredientController.text);
//         ingredientController.clear();
//       });
//     }
//   }

//   void removeIngredient(String ingredient) {
//     setState(() {
//       ingredients.remove(ingredient);
//     });
//   }

//   // Function to pick an image from gallery
//   Future<void> pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//       });
//     }
//   }

//   // Function to upload the image to Firebase Storage and get the URL
//   Future<void> uploadImage() async {
//     if (_imageFile != null) {
//       try {
//         final ref = FirebaseStorage.instance.ref().child('recipe_images/${_imageFile!.path.split('/').last}');
//         await ref.putFile(_imageFile!);
//         imageUrl = await ref.getDownloadURL();
//       } catch (e) {
//         print('Image upload failed: $e');
//       }
//     }
//   }

//   Future<void> saveRecipe() async {
//     if (mealNameController.text.isNotEmpty &&
//         selectedMealTime != null &&
//         ingredients.isNotEmpty &&
//         selectedRecipeSeason != null &&
//         cookingStepsController.text.isNotEmpty &&
//         ingredientBenefitsController.text.isNotEmpty &&
//         culinaryTrendsController.text.isNotEmpty &&
//         recipeCultureController.text.isNotEmpty &&
//         recipeDescriptionController.text.isNotEmpty) {
//       await uploadImage(); // Upload image before saving recipe
//       try {
//         await FirebaseFirestore.instance.collection('recipes').add({
//           'user': user?.email,
//           'mealName': mealNameController.text,
//           'mealTime': selectedMealTime,
//           'ingredients': ingredients,
//           'readyInTime': readyInTimeController.text,
//           'recipeSeason': selectedRecipeSeason,
//           'cookingSteps': cookingStepsController.text,
//           'ingredientBenefits': ingredientBenefitsController.text,
//           'culinaryTrends': culinaryTrendsController.text,
//           'recipeCulture': recipeCultureController.text,
//           'recipeDescription': recipeDescriptionController.text,
//           'recipePicture': imageUrl, // Save image URL
//           'share': true,
//           'rating': 0.1,
//           'rating_count': 0.1,
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
//         setState(() {});
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add recipe.')));
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.redAccent));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Recipe'),
//         backgroundColor: Colors.redAccent,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField('Meal Name', mealNameController),
//               SizedBox(height: 20),
//               Text('Ingredients:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
//               SizedBox(height: 10),
//               ...ingredients.map((ingredient) => ListTile(
//                     title: Text(ingredient, style: TextStyle(color: Colors.green[800])),
//                     leading: Icon(Icons.check_circle, color: Colors.green),
//                     trailing: IconButton(
//                       icon: Icon(Icons.remove_circle, color: Colors.red),
//                       onPressed: () => removeIngredient(ingredient),
//                     ),
//                   )),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildTextField('Add Ingredient', ingredientController),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.add_circle, color: Colors.green),
//                     onPressed: addIngredient,
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               _buildDropdown('Meal Time', mealTimes, selectedMealTime, (value) {
//                 setState(() {
//                   selectedMealTime = value;
//                 });
//               }),
//               SizedBox(height: 16),
//               _buildTextField('Ready In Time (e.g., 30 minutes)', readyInTimeController),
//               SizedBox(height: 16),
//               _buildDropdown('Recipe Season', recipeSeasons, selectedRecipeSeason, (value) {
//                 setState(() {
//                   selectedRecipeSeason = value;
//                 });
//               }),
//               SizedBox(height: 16),
//               _buildTextField('Cooking Steps (Add each step line by line)', cookingStepsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Ingredient Benefits', ingredientBenefitsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Culinary Trends', culinaryTrendsController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Recipe Food Culture', recipeCultureController, maxLines: null),
//               SizedBox(height: 16),
//               _buildTextField('Recipe Description', recipeDescriptionController, maxLines: null),
//               SizedBox(height: 16),
//               // Image picker section
//               Row(
//                 children: [
//                   ElevatedButton(
//                     onPressed: pickImage,
//                     child: Text('Pick Recipe Picture'),
//                   ),
//                   if (_imageFile != null)
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0),
//                       child: Text('Image selected'),
//                     ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: saveRecipe,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.redAccent,
//                     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   ),
//                   child: Text('Save Recipe', style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, {int? maxLines = 1}) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.redAccent),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.green),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
//     return DropdownButtonFormField<String>(
//       value: selectedValue,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(color: Colors.redAccent),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.green),
//           borderRadius: BorderRadius.circular(10),
//         ),
//       ),
//       items: items.map((String item) {
//         return DropdownMenuItem<String>(
//           value: item,
//           child: Text(item),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  File? _imageFile; // Store the selected image file
  String? imageUrl; // Store the image URL from Firebase Storage

  final List<String> mealTimes = ['Breakfast', 'Lunch', 'Dinner', 'Any Time'];
  final List<String> recipeSeasons = ['Spring-はる', 'Summer-なつ', 'Autumn-あき', 'Winter-ふゆ', 'Sunny', 'Rainy', 'Not Seasonal'];

  void addIngredient() {
    if (ingredientController.text.isNotEmpty) {
      setState(() {
        ingredients.add(ingredientController.text);
        ingredientController.clear();
      });
    }
  }

  void removeIngredient(String ingredient) {
    setState(() {
      ingredients.remove(ingredient);
    });
  }

  // Function to pick an image from gallery
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to upload the image to Firebase Storage and get the URL
  Future<void> uploadImage() async {
    if (_imageFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('recipe_images/${_imageFile!.path.split('/').last}');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        print('Image upload failed: $e');
      }
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
      await uploadImage(); // Upload image before saving recipe
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
          'recipePicture': imageUrl, // Save image URL
          'share': true,
          'rating': 0.1,
          'rating_count': 0.1,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add recipe.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields.'), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Recipe'),
        backgroundColor: Colors.redAccent,
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
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => removeIngredient(ingredient),
                    ),
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
              SizedBox(height: 16),
              // Image picker section
              Row(
                children: [
                  ElevatedButton(
                    onPressed: pickImage,
                    child: Text('Pick Recipe Picture'),
                  ),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text('Image selected'),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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
        labelStyle: TextStyle(color: Colors.redAccent),
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
        labelStyle: TextStyle(color: Colors.redAccent),
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
