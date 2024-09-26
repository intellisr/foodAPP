import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignupScreen({super.key});

  void signup(BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Show success message and navigate to login screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully signed up!')),
      );
      await Future.delayed(Duration(seconds: 2)); // Delay for visibility
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The password provided is too weak.")),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("The email is already in use.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.redAccent, // Red theme like login page
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and Title Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
                    width: 150, // Keep the logo consistent
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

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

            SizedBox(height: 40),

            // Sign Up Button
            ElevatedButton(
              onPressed: () => signup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 5,
                padding: EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            // Link to Login
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text(
                  'Already have an account? Login',
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