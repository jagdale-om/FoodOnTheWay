import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String _selectedCountry = 'United States';
  String? errorMessage;
  late VideoPlayerController _controller;

  final Map<String, String> countryFlags = {
    'United States': '🇺🇸',
    'Canada': '🇨🇦',
    'United Kingdom': '🇬🇧',
    'India': '🇮🇳',
    'Australia': '🇦🇺',
    'Germany': '🇩🇪',
    'France': '🇫🇷',
  };

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/BG2.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("About Food On The Way"),
          content: Text(
              "Food On The Way is a convenient food delivery app that brings delicious meals right to your doorstep. Browse menus, order food, and enjoy seamless delivery."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        //  Save login state in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;

          // Fetch user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

          if (userDoc.exists) {
            String storedCountry = userDoc['country'] ?? ""; // Country saved during signup

            if (storedCountry.isNotEmpty && storedCountry != _selectedCountry) {
              // ❌ Show warning if country does not match
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please select the correct country: $storedCountry")),
              );
              return;
            }

            // ✅ Save login state in SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool("isLoggedIn", true);

            // ✅ Navigate to HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("User not found in database. Please sign up first.")),
            );
          }
        }

      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${e.toString()}")),
      );
    }
  }






  // Google Sign-In Method
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // ✅ User exists → Log them in
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // ❌ User doesn't exist → Show warning & sign out
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No account found for this Google account. Please sign up first.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.7)),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Welcome!",
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[600],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline, color: Colors.white),
                          onPressed: _showAppInfo,
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: _selectedCountry,
                      dropdownColor: Colors.black, // Background of dropdown to match theme
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCountry = newValue!;
                        });
                      },
                      items: countryFlags.keys.map((String country) {
                        return DropdownMenuItem(
                          value: country,
                          child: Row(
                            children: [
                              Text(countryFlags[country] ?? '', style: TextStyle(fontSize: 15)), // Flag
                              SizedBox(width: 5),
                              Text(country, style: TextStyle(color: Colors.white, fontSize: 15)), // White country text
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  ],
                ),

                Spacer(),

                Text(
                  "Food On The Way",
                  style: GoogleFonts.monoton(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),

                SizedBox(height: 20),

                _buildTextField("Email", emailController),
                _buildTextField("Password", passwordController,
                    obscureText: true),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      child:
                      Text("Login", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800]),
                    ),
                    ElevatedButton.icon(
                      onPressed: signInWithGoogle,
                      icon: Image.asset("assets/google_icon.png", height: 24), // Google icon added
                      label: Text("Login with Google", style: TextStyle(color: Colors.black)), // Make text black for contrast
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 2,
                      ),
                    ),

                  ],
                ),

                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.roboto(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),



                Spacer(),

                Center(
                  child: Text(
                    '''© 2025 Food On The Way. All Rights Reserved.
             App Is Still In Development Phase.''',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: label == "Password" ? _obscurePassword : obscureText,
        style: TextStyle(color: Colors.white), // White text while typing
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(),
          suffixIcon: label == "Password"
              ? IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
  bool _obscurePassword = true;

}
