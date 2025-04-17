import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reservationsData = prefs.getString('reservations');

    if (reservationsData != null && reservationsData.isNotEmpty) {
      List<dynamic> decodedList = jsonDecode(reservationsData);
      setState(() {
        reservations = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }

    print("Loaded reservations: $reservations"); // Debugging
  }

  Future<void> _clearReservations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('reservations');
    setState(() {
      reservations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Reservation History",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _clearReservations();
            },
          ),
        ],
      ),
      body: reservations.isEmpty
          ? Center(child: Text(
        "No Reservation Yet",
        style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
      )
      )
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(reservation["restaurant"]),
              subtitle: Text("Seats Reserved: ${reservation["seats"]}"),
              trailing: Text(reservation["timestamp"]),
            ),
          );
        },
      ),
    );
  }
}
