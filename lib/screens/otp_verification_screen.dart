// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'login_screen.dart';
//
// class OTPVerificationScreen extends StatefulWidget {
//   @override
//   _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
// }
//
// class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   String verificationId = "";
//   String countryCode = "+91";
//
//   void sendOTP() async {
//     await _auth.verifyPhoneNumber(
//       phoneNumber: "$countryCode${phoneController.text.trim()}",
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         saveUserAndProceed();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification Failed: ${e.message}")));
//       },
//       codeSent: (String verId, int? resendToken) {
//         setState(() {
//           verificationId = verId;
//         });
//         showOTPDialog();
//       },
//       codeAutoRetrievalTimeout: (String verId) {
//         setState(() {
//           verificationId = verId;
//         });
//       },
//     );
//   }
//
//   void verifyOTP() async {
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: verificationId,
//         smsCode: otpController.text.trim(),
//       );
//       UserCredential userCredential = await _auth.signInWithCredential(credential);
//       if (userCredential.user != null) {
//         saveUserAndProceed();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Incorrect OTP. Try again.")));
//     }
//   }
//
//   Future<void> saveUserAndProceed() async {
//     User? user = _auth.currentUser;
//     if (user == null) return;
//
//     await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//       'phone': "$countryCode${phoneController.text.trim()}",
//       'createdAt': DateTime.now(),
//     });
//
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text("Account Created Successfully!")));
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }
//
//   void showOTPDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Enter OTP"),
//         content: TextField(
//           controller: otpController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(hintText: "Enter OTP"),
//         ),
//         actions: [
//           TextButton(onPressed: verifyOTP, child: Text("Verify")),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Food On The Way", style: GoogleFonts.poppins(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Hi! Welcome", style: GoogleFonts.poppins(fontSize: 22, color: Colors.blue)),
//             SizedBox(height: 20),
//             Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(15),
//                 boxShadow: [
//                   BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   DropdownButton<String>(
//                     value: countryCode,
//                     onChanged: (newValue) {
//                       setState(() => countryCode = newValue!);
//                     },
//                     items: ["+91", "+1", "+44", "+92"].map((code) {
//                       return DropdownMenuItem(
//                         value: code,
//                         child: Text(code),
//                       );
//                     }).toList(),
//                   ),
//                   TextField(
//                     controller: phoneController,
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(hintText: "Enter your mobile number"),
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: sendOTP,
//                     child: Text("Send OTP"),
//                     style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
//                   ),
//                   SizedBox(height: 10),
//                   Text("We will send you a one-time password (OTP)",
//                       style: GoogleFonts.poppins(color: Colors.grey)),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
