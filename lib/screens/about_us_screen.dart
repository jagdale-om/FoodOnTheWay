import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppInformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Details", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Food On The Way!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Food On The Way is a convenient and user-friendly app designed to help you find and reserve seats at your favorite restaurants with ease. Whether you're planning a casual dine-in or a special occasion, our app ensures you get the best dining experience without any hassle.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Key Features:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("\u2022 Browse and search for restaurants near you."),
            Text("\u2022 Check restaurant details, including opening and closing times."),
            Text("\u2022 View available seats and reserve them in advance."),
            Text("\u2022 Track your reservations and orders easily."),
            Text("\u2022 Manage your account details and preferences."),
            SizedBox(height: 20),
            Text(
              "Our Mission:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "We aim to make dining effortless and enjoyable for everyone by providing a seamless reservation and ordering experience. Our goal is to bridge the gap between customers and restaurants, ensuring convenience at every step.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
