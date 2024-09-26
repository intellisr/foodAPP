import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  void login(BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong password provided for that user.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // Change to red theme
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0), // Increase horizontal padding for a more spacious layout
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, // Left-align content for better readability
          children: [
            // Logo and Title Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent, // Red background for header
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Soft shadow for a modern card-like appearance
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    'https://firebasestorage.googleapis.com/v0/b/foodapp-c2836.appspot.com/o/GOOD%20CHEF.png?alt=media&token=e4cf71cd-85dc-4772-83c4-6affac094c64',
                    width: 150, // Made the logo bigger for better visibility
                  ),
                ],
              ),
            ),

            SizedBox(height: 40), // Increase spacing for a cleaner layout

            // Email Field
            Text(
              'Email Address',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),

            SizedBox(height: 20),

            // Password Field
            Text(
              'Password',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              obscureText: true,
            ),

            SizedBox(height: 40), // Add extra space to separate the form and login button

            // Login Button
            ElevatedButton(
              onPressed: () => login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 5,
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.black.withOpacity(0.2), // Add shadow for a modern button look
              ),
              child: Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Sign Up Link
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to sign up screen
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Don\'t have an account? Sign Up',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}