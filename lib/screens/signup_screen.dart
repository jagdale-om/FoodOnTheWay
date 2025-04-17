import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController reEnterPasswordController = TextEditingController();
  bool agreeTerms = false;
  bool agreePrivacy = false;
  bool agreeUpdates = false;
  String? errorMessage;
  bool isChecked = false; // Checkbox for terms & conditions
  bool _isLoading = false;
  String? passwordError;
  String? confirmPasswordError;
  String _verificationId = "";


  bool _validatePassword(String password) {
    String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(password);
  }





  void _onPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = "Password cannot be empty";
      } else if (!_validatePassword(value)) {
        passwordError = "Password must contain a special character, a number, and a letter.";
      } else {
        passwordError = null; // No error if valid
      }
    });
  }

  Future<void> saveUserDetails(User user, String name, String phone, String country, String city, String address) async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'phone': phone,
      'country': country,
      'city': city,
      'address': address,
    });
  }



  void _onConfirmPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        confirmPasswordError = "Confirm Password cannot be empty";
      } else if (value != passwordController.text) {
        confirmPasswordError = "Passwords do not match";
      } else {
        confirmPasswordError = null;
      }
    });
  }


  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final today = DateTime.now();
      final age = today.year - pickedDate.year - ((today.month > pickedDate.month ||
          (today.month == pickedDate.month && today.day >= pickedDate.day)) ? 0 : 1);

      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);

        if (age < 18) {
          errorMessage = "You must be at least 18 years old!";
        } else {
          errorMessage = null; // Remove error if user is 18+
        }
      });
    }
  }


  bool _validateFields() {
    if (firstNameController.text.trim().isEmpty) {
      _showError("Please enter your First Name.");
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showError("Please enter your Last Name.");
      return false;
    }
    if (dobController.text.trim().isEmpty) {
      _showError("Please enter your Date of Birth.");
      return false;
    }
    if (countryController.text.trim().isEmpty) {
      _showError("Please enter your Country.");
      return false;
    }
    if (contactNumberController.text.trim().isEmpty || contactNumberController.text.length < 10) {
      _showError("Please enter a valid Phone Number.");
      return false;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.contains("@")) {
      _showError("Please enter a valid Email.");
      return false;
    }
    if (passwordController.text.trim().isEmpty || passwordController.text.length < 10) {
      _showError("Password must be at least 10 characters.");
      return false;
    }
    if (reEnterPasswordController.text.trim().isEmpty || passwordController.text != reEnterPasswordController.text) {
      _showError("Passwords do not match.");
      return false;
    }
    if (!agreeTerms) {
      _showError("You must agree to the Terms & Conditions.");
      return false;
    }
    if (!agreePrivacy) {
      _showError("You must agree to the Privacy Policy.");
      return false;
    }
    if (!agreeUpdates) {
      _showError("You must agree to receive updates.");
      return false;
    }
    return true; // ✅ If everything is correct
  }


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
    );
  }

  Future<void> _onSignUpPressed() async {
    if (!_validateFields()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sign Up Successful! Please log in."), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } catch (e) {
      _showError(e.toString());
    }

    setState(() => _isLoading = false);
  }





  void _resetFields() {
    setState(() {
      firstNameController.clear();
      lastNameController.clear();
      contactNumberController.clear();
      emailController.clear();
      dobController.clear();
      countryController.clear();
      passwordController.clear();
      reEnterPasswordController.clear();
      agreeTerms = false;
      agreePrivacy = false;
      agreeUpdates = false;
      errorMessage = null;
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage("images/background.jpg"),
    fit: BoxFit.cover,
    ),
    ),
    child: Stack(
    children: [
    // Adding a semi-transparent overlay
    Container(
    width: double.infinity,
    height: double.infinity,
    color: Colors.black.withOpacity(0.6), // Low opacity effect
    ),
    // Sign Up Content
    SingleChildScrollView(
    child: Padding(
    padding: EdgeInsets.only(
    left: 16,
    right: 16,
    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Food On The Way",
                    style: GoogleFonts.monoton(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "First Name", controller: firstNameController)),
                    SizedBox(width: 10),
                    Expanded(child: CustomTextField(label: "Last Name", controller: lastNameController)),
                  ],
                ),
                CustomTextField(label: "Contact Number", controller: contactNumberController),
                CustomTextField(label: "Email", controller: emailController),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: dobController,
                      readOnly: true,
                      style: TextStyle(color: Colors.white), // Typed text in white
                      decoration: InputDecoration(
                        labelText: "Date of Birth",
                        labelStyle: TextStyle(color: Colors.white), // Label in white
                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today, color: Colors.white), // Calendar icon in white
                          onPressed: _selectDate,
                        ),
                      ),
                    ),
                    if (errorMessage != null) // Show warning if errorMessage is set
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
                CustomTextField(label: "Country", controller: countryController),


                CustomTextField(
                  label: "Password",
                  controller: passwordController,
                  obscureText: true,
                  onChanged: _onPasswordChanged,
                  errorText: passwordError, // Shows real-time suggestion
                ),

                CustomTextField(
                  label: "Re-enter Password",
                  controller: reEnterPasswordController,
                  obscureText: true,
                  onChanged: _onConfirmPasswordChanged,
                  errorText: confirmPasswordError,
                ),

                // Checkboxes
                buildCheckbox("Yes! I'm a Foodiee.", agreeTerms, (val) => setState(() => agreeTerms = val)),
                buildCheckbox("I agree to the Privacy Policy and Terms And Condition", agreePrivacy, (val) => setState(() => agreePrivacy = val)),
                buildCheckbox("I want to receive updates and offers", agreeUpdates, (val) => setState(() => agreeUpdates = val)),

                // Error Message
                if (errorMessage != null)
                  Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),

                SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _onSignUpPressed,
                      child: Text("Sign Up", style: TextStyle(fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                    ),

                    ElevatedButton(
                      onPressed: _resetFields, // Call reset function when pressed
                      child: Text("Clear", style: TextStyle(fontSize: 15, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                    ),

                  ],
                ),

                SizedBox(height: 50), // Extra spacing
              ],
            ),
          ),
        ),
    ],
      ),
        ),
    );
  }

  // Custom Checkbox Widget
  Widget buildCheckbox(String text, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          checkColor: Colors.black, // Checkmark color (black for contrast)
          activeColor: Colors.white, // Checkbox fill color when checked
          side: BorderSide(color: Colors.white), // White border for checkbox
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.white), // Make text white
          ),
        ),
      ],
    );
  }
}


class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? errorText;
  final IconData? suffixIcon;

  CustomTextField({required this.label, required this.controller, this.obscureText = false,this.onChanged,this.errorText, this.suffixIcon});

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? errorText;
  bool isPasswordVisible = false; // Track password visibility

  void _validateEmail(String value) {
    if (widget.label == "Email" && !value.endsWith("@gmail.com")) {
      setState(() {
        errorText = "Enter a valid Gmail ID (example@gmail.com)";
      });
    } else {
      setState(() {
        errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText && !isPasswordVisible, // Toggle visibility
        onChanged: widget.label == "Email" ? _validateEmail : null,
        style: TextStyle(color: Colors.white), // Make user input white
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.white), // Make field name white
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Make border white
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // White border when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.yellow, width: 2.0), // Highlight when focused
          ),
          errorText: errorText,
          suffixIcon: widget.label.contains("Password") // Show eye icon only for passwords
              ? IconButton(
            icon: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white, // Make eye icon white
            ),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          )
              : (widget.suffixIcon != null ? Icon(widget.suffixIcon, color: Colors.white) : null),
        ),
      ),
    );
  }

}


