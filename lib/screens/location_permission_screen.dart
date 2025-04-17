// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'screens/home_screen.dart'; // Replace with your next screen import
//
// class LocationPermissionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white.withOpacity(0.9), // White Theme
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           width: 350,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Location Pin Icon
//               const Icon(Icons.location_pin, size: 60, color: Colors.red),
//               const SizedBox(height: 10),
//
//               // Message
//               const Text(
//                 "Enable Location Access",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
//               ),
//               const SizedBox(height: 10),
//
//               const Text(
//                 "Allow location access for a better experience.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.black54),
//               ),
//               const SizedBox(height: 20),
//
//               // Enable Location Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     bool granted = await _requestLocationPermission();
//                     if (granted) {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => NextScreen()), // Load Next Screen
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                   ),
//                   child: const Text("Enable Location", style: TextStyle(fontSize: 18)),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//
//               // Skip Option
//               TextButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => NextScreen()), // Load Next Screen
//                   );
//                 },
//                 child: const Text("Skip", style: TextStyle(color: Colors.red, fontSize: 16)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Function to Request Location Permission
//   Future<bool> _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.deniedForever) {
//         return false; // Permission Denied Permanently
//       }
//     }
//     return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
//   }
// }
