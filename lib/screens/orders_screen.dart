import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Orders",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No orders found",
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600]),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    String status = order['status'] ?? 'Pending'; // Example: "Preparing", "Delivered"
    Color statusColor = _getStatusColor(status);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, color: Colors.green, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order['itemName'],
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            _buildInfoRow(Icons.confirmation_number, "Quantity", "${order['quantity']}"),
            _buildInfoRow(Icons.attach_money, "Total Price", "₹${order['totalPrice']}"),
            _buildInfoRow(Icons.timer, "Estimated Time", "${order['estimatedTime']} mins"),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text("$label: ", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(value, style: GoogleFonts.poppins(color: Colors.grey[700])),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'preparing':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
