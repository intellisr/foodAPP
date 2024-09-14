import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart'; // Import your login screen
import 'screens/home_screen.dart'; // Import your home screen
import 'screens/recipe_search_screen.dart'; // Import your recipe search screen
import 'screens/favorites_screen.dart'; // Import your favorites screen
import 'screens/meal_planner_screen.dart'; // Import your meal planner screen
import 'screens/bmi_calculator_screen.dart'; // Import your BMI calculator screen
import 'screens/cookbook_screen.dart'; // Import your BMI calculator screen
import 'screens/store_finder_screen.dart'; // Import your store finder screen
import 'screens/signup_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => LoginScreen(), // Set the login screen as the home
        '/signup': (context) => SignupScreen(), // Set the login screen as the home
        '/home': (context) => HomeScreen(), // Define the home screen route
        '/recipe_search': (context) =>  RecipeSearchScreen(), // Define recipe search route
        '/favorites': (context) =>  FavoritesScreen(), // Define favorites route
        '/meal_planner': (context) =>  MealPlannerScreen(), // Define meal planner route
        '/bmi_calculator': (context) =>  BMICalculatorScreen(), // Define BMI calculator route
        '/cookbook': (context) =>  CookBookScreen(), // Define cookbook route
        '/store_finder': (context) => StoreFinderScreen(), // Define store finder route
        '/add_recipe': (context) => AddRecipeScreen(), // Define store finder route
        '/recipe_details': (context) => RecipeDetailScreen(), // Define store finder route
      },
    );
  }
}