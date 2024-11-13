// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'screens/login_screen.dart'; // Import your login screen
// import 'screens/home_screen.dart'; // Import your home screen
// import 'screens/recipe_search_screen.dart'; // Import your recipe search screen
// import 'screens/meal_planner_screen.dart'; // Import your meal planner screen
// import 'screens/bmi_calculator_screen.dart'; // Import your BMI calculator screen
// import 'screens/cookbook_screen.dart'; // Import your BMI calculator screen
// import 'screens/store_finder_screen.dart'; // Import your store finder screen
// import 'screens/signup_screen.dart';
// import 'screens/add_recipe_screen.dart';
// import 'screens/recipe_detail_screen.dart';
// import 'screens/personalised_goals_screen.dart';
// import 'screens/video_screen.dart';
// import 'screens/my_profile_screen.dart';
// import 'screens/shopping_list_screen.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Recipe Hub',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       initialRoute: '/', // Set the initial route
//       routes: {
//         '/': (context) => LoginScreen(), // Set the login screen as the home
//         '/signup': (context) => SignupScreen(), // Set the login screen as the home
//         '/home': (context) => HomeScreen(), // Define the home screen route
//         '/recipe_search': (context) =>  RecipeSearchScreen(), // Define recipe search route
//         '/meal_planner': (context) =>  MealPlannerScreen(), // Define meal planner route
//         '/bmi_calculator': (context) =>  BMICalculatorScreen(), // Define BMI calculator route
//         '/my_profile': (context) =>  MyProfileScreen(), // Define profile route
//         '/cookbook': (context) =>  CookBookScreen(), // Define cookbook route
//         '/store_finder': (context) => StoreFinderScreen(), // Define store finder route
//         '/add_recipe': (context) => AddRecipeScreen(), // Define Add Recipe route
//         '/recipe_details': (context) => RecipeDetailScreen(documentId:'temp'), // Define Recipe Detail route
//         '/personalised_goals': (context) => PersonalGoalScreen(), // Define Personal Goal route
//         '/shopping_list': (context) => ShoppingListScreen(), // Define Personal Goal route
//         '/class': (context) => VideoScreen(),
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_search_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/cookbook_screen.dart';
import 'screens/store_finder_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/add_recipe_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/personalised_goals_screen.dart';
import 'screens/video_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/RandomRecipeScreen.dart'; // Import the new random recipe screen

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
        '/': (context) => AuthCheckScreen(), // Auth check screen as home
        '/signup': (context) => SignupScreen(),
        '/home': (context) => HomeScreen(),
        '/recipe_search': (context) => RecipeSearchScreen(),
        '/meal_planner': (context) => MealPlannerScreen(),
        '/bmi_calculator': (context) => BMICalculatorScreen(),
        '/my_profile': (context) => MyProfileScreen(),
        '/cookbook': (context) => CookBookScreen(),
        '/store_finder': (context) => StoreFinderScreen(),
        '/add_recipe': (context) => AddRecipeScreen(),
        '/recipe_details': (context) => RecipeDetailScreen(documentId: 'temp'),
        '/personalised_goals': (context) => PersonalGoalScreen(),
        '/shopping_list': (context) => ShoppingListScreen(),
        '/class': (context) => VideoScreen(),
        '/random_recipes': (context) => RandomRecipeScreen(), // Define random recipe route
      },
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with actual authentication check
    bool isLoggedIn = false; // Placeholder; integrate with auth provider

    if (isLoggedIn) {
      return HomeScreen();
    } else {
      return RandomRecipeScreen(); // Show random recipes screen if not logged in
    }
  }
}
