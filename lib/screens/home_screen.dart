import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'account_details_screen.dart';
import 'orders_screen.dart';
import 'payment_mode.dart';
import 'about_us_screen.dart';
import 'reservation_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("isLoggedIn", false);

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController locationController = TextEditingController(text: "WAKAD, Pune");
  TextEditingController cityController = TextEditingController();
  List<bool> _expandedList = List.generate(10, (index) => false);
  List<Map<String, dynamic>> filteredRestaurants = [];
  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> restaurants = [
    {"name": "Amul Restaurant", "image": "assets/restaurant1.jpeg", "rating": "4.2", "distance": "1.9 km", "seats": "10", "openTime": "10:00 AM", "closeTime": "10:00 PM"},
    {"name": "Jai Mata Di", "image": "assets/restaurant2.jpeg", "rating": "3.9", "distance": "1 km", "seats": "5", "openTime": "9:00 AM", "closeTime": "9:00 PM"},
    {"name": "Indoori Fast Food", "image": "assets/restaurant3.jpeg", "rating": "4.5", "distance": "2.5 km", "seats": "15", "openTime": "11:00 AM", "closeTime": "11:30 PM"},
    {"name": "Mahi Dhaba", "image": "assets/restaurant4.jpeg", "rating": "4.0", "distance": "3 km", "seats": "8", "openTime": "8:00 AM", "closeTime": "10:00 PM"},
    {"name": "Delhi Swad", "image": "assets/restaurant5.jpeg", "rating": "4.1", "distance": "2 km", "seats": "12", "openTime": "10:00 AM", "closeTime": "10:00 PM"},
    {"name": "Paustik Aahar", "image": "assets/restaurant6.jpeg", "rating": "3.8", "distance": "1.5 km", "seats": "7", "openTime": "7:00 AM", "closeTime": "9:30 PM"},
    {"name": "Thorat Misal", "image": "assets/restaurant7.jpeg", "rating": "4.3", "distance": "2.2 km", "seats": "6", "openTime": "9:00 AM", "closeTime": "10:00 PM"},
    {"name": "Bebe De Rasoi", "image": "assets/restaurant8.jpeg", "rating": "4.6", "distance": "3.5 km", "seats": "20", "openTime": "11:00 AM", "closeTime": "12:00 AM"},
    {"name": "Jhingat Misal", "image": "assets/restaurant9.jpeg", "rating": "4.0", "distance": "2.8 km", "seats": "9", "openTime": "8:30 AM", "closeTime": "9:00 PM"},
    {"name": "Desi Dhaba", "image": "assets/restaurant10.jpeg", "rating": "4.4", "distance": "3.2 km", "seats": "11", "openTime": "10:00 AM", "closeTime": "11:00 PM"},
  ];

  @override
  void initState() {
    super.initState();
    filteredRestaurants = List.from(restaurants);
  }

  void _searchRestaurants(String query) {
    setState(() {
      filteredRestaurants = restaurants
          .where((restaurant) => restaurant["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (filteredRestaurants.isEmpty) {
        filteredRestaurants = [{"name": "Restaurant not yet added. Will be available in a future update.", "image": "", "rating": "", "distance": "", "seats": "", "openTime": "", "closeTime": ""}];
      }
    });

  }

  Future<void> _getCurrentLocation() async {
    // Check & request location permission
    PermissionStatus permission = await Permission.location.request();

    if (permission.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission is required!")),
      );
      return;
    } else if (permission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enable location permission from settings.")),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocode to get address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      String address = "${place.locality}, ${place.country}";

      setState(() {
        cityController.text = address;
      });
    }
  }



  Future<void> _showReservationDialog(BuildContext context, Map<String, dynamic> restaurant, int index) async {
    TextEditingController seatController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reserve Seats"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Available Seats: ${restaurant["seats"]}"),
              TextField(
                controller: seatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Enter number of seats"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Reserve"),
              onPressed: () async {
                int? seatsToReserve = int.tryParse(seatController.text);
                int availableSeats = int.parse(restaurant["seats"].toString());

                if (seatsToReserve == null || seatsToReserve <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid number of seats.")),
                  );
                  return;
                }

                if (seatsToReserve > availableSeats) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Not enough available seats.")),
                  );
                  return;
                }

                // Update the available seats
                setState(() {
                  restaurant["seats"] = (availableSeats - seatsToReserve).toString();
                });

                // Save reservation to history
                await _saveReservation(restaurant["name"], seatsToReserve);

                Navigator.pop(context); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _saveReservation(String restaurantName, int seats) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? reservationsData = prefs.getString('reservations');

    List<Map<String, dynamic>> reservationsList = [];

    if (reservationsData != null) {
      List<dynamic> decodedList = jsonDecode(reservationsData);
      reservationsList = decodedList.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    // Add new reservation
    reservationsList.add({
      "restaurant": restaurantName,
      "seats": seats,
      "timestamp": DateTime.now().toString(),
    });

    // Save updated list
    await prefs.setString('reservations', jsonEncode(reservationsList));

    print("Reservation saved: $restaurantName - $seats seats"); // Debugging
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Food On The Way",
          style: GoogleFonts.monoton(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.yellow,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 30),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildUserOptions(),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: "Enter your address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.my_location, color: Colors.green),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search restaurants...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchRestaurants,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.asset(
                            restaurant["image"]!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(restaurant["name"]!),
                          subtitle: Text("Rating: ${restaurant["rating"]} | Distance: ${restaurant["distance"]}"),
                          trailing: Icon(
                            _expandedList[index] ? Icons.expand_less : Icons.expand_more,
                          ),
                          onTap: () {
                            setState(() {
                              _expandedList[index] = !_expandedList[index];
                            });
                          },
                        ),
                        if (_expandedList[index])
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Available Seats: ${restaurant["seats"]}", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("Opening Time: ${restaurant["openTime"]}"),
                                Text("Closing Time: ${restaurant["closeTime"]}"),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () {
                                    print("Reserve button tapped for ${restaurants[index]["name"]}"); // Debugging
                                    _showReservationDialog(context,restaurant, index);
                                  },
                                  child: Text("Reserve a Seat"),
                                ),



                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          if (index == 1) { // 1 is the index for Reservation Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReservationScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Reservations"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),

    );
  }

  Widget _buildUserOptions() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Account Details"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text("Your Orders"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Payment Settings"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentScreen()));
            },
          ), ListTile(
            leading: Icon(Icons.info),
            title: Text("About Us"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AppInformationScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text("Log Out"),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Confirm Log Out"),
                  content: Text("Are you sure you want to log out?"),
                  actions: [
                    TextButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text("Log Out"),
                      onPressed: () => _logout(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
