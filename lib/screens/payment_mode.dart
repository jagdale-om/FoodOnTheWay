import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bill total: ₹000.01",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("RECOMMENDED"),
            _buildPaymentOption(
              context,
              "Google Pay UPI",
              Icons.payment,
              onTap: () => _showQRPopup(context),
            ),

            _buildSectionTitle("CARDS"),
            _buildPaymentOption(
              context,
              "Add credit or debit cards",
              Icons.credit_card,
              isAdd: true,
              onTap: () => _showComingSoon(context),
            ),

            _buildSectionTitle("PAY BY ANY UPI APP"),
            _buildPaymentOption(
              context,
              "Add new UPI ID",
              Icons.add,
              isAdd: true,
              onTap: () => _showComingSoon(context),
            ),

            _buildSectionTitle("WALLETS"),
            _buildPaymentOption(
              context,
              "Amazon Pay Balance (₹0.00)",
              Icons.account_balance_wallet,
              onTap: () => _showComingSoon(context),
            ),
            _buildPaymentOption(
              context,
              "Mobikwik (Link your wallet)",
              Icons.wallet,
              isLink: true,
              onTap: () => _showComingSoon(context),
            ),

            _buildSectionTitle("PAY LATER"),
            _buildPaymentOption(
              context,
              "Simpl (Blocked for now)",
              Icons.block,
              isDisabled: true,
              onTap: () => _showComingSoon(context),
            ),

            _buildSectionTitle("NETBANKING"),
            _buildPaymentOption(
              context,
              "Netbanking",
              Icons.account_balance,
              isAdd: true,
              onTap: () => _showComingSoon(context),
            ),

            _buildSectionTitle("CASH ON DELIVERY"),
            _buildPaymentOption(
              context,
              "Cash on delivery (Not available)",
              Icons.delivery_dining,
              isDisabled: true,
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon,
      {bool isAdd = false, bool isLink = false, bool isDisabled = false, VoidCallback? onTap}) {
    return Card(
      color: isDisabled ? Colors.green[900] : Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        trailing: isAdd
            ? Text("ADD", style: TextStyle(color: Colors.green[500]))
            : isLink
            ? Text("LINK", style: TextStyle(color: Colors.green[500]))
            : Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: isDisabled ? null : onTap,
      ),
    );
  }

  void _showQRPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Scan to Pay", style: TextStyle(color: Colors.white)),
          content: Image.asset("assets/qr_code.jpg"), // Replace with your QR image path
          actions: [
            TextButton(
              child: Text("Close", style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text("Coming Soon!", style: TextStyle(color: Colors.white)),
          content: Text(
            "This feature is not available yet.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text("OK", style: TextStyle(color: Colors.green)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
