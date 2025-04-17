import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AccountDetailsScreen extends StatefulWidget {
  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  File? _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _showFirebaseErrorPopup();
    });
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          userData = Map<String, dynamic>.from(userDoc.data() as Map);
          nameController.text = userData?["name"] ?? "";
          phoneController.text = userData?["phone"] ?? "";
          countryController.text = userData?["country"] ?? "";
          cityController.text = userData?["city"] ?? "";
          bioController.text = userData?["bio"] ?? "";
          dobController.text = userData?["DOB"] ?? "";
          profileImageUrl = userData?["profileImage"];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null || user == null) return;
    String filePath = 'profile_images/${user!.uid}.jpg';
    try {
      UploadTask uploadTask = FirebaseStorage.instance.ref(filePath).putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        profileImageUrl = downloadUrl;
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> _showFirebaseErrorPopup() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Firebase Issue"),
        content: Text("There is a problem fetching user data. Add data manually."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
      ),
    );
  }

  Future<void> saveUserData() async {
    if (user == null) return;
    await _uploadImage();
    Map<String, dynamic> updatedData = {
      "name": nameController.text,
      "phone": phoneController.text,
      "country": countryController.text,
      "city": cityController.text,
      "bio": bioController.text,
      "DOB": dobController.text,
      "profileImage": profileImageUrl,
    };
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).set(updatedData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text("Account Details", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green,
                  backgroundImage: _image != null ? FileImage(_image!) : (profileImageUrl != null ? NetworkImage(profileImageUrl!) : null),
                  child: _image == null && profileImageUrl == null ? Icon(Icons.person, size: 50, color: Colors.white) : null,
                ),
              ),
              SizedBox(height: 16),
              infoTextField("Name", nameController),
              infoTextField("Phone", phoneController),
              infoTextField("Country", countryController),
              infoTextField("City", cityController),
              infoTextField("Bio", bioController),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
                child: AbsorbPointer(
                  child: infoTextField("Date of Birth", dobController),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await saveUserData();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Data Saved Successfully")));
                  fetchUserData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Save", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget infoTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
