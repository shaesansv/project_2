import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/screens/scanner_screen.dart';

void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Colors.green,
    duration: Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void login(String email, String password, BuildContext context) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");

  // Get all users
  DataSnapshot data = await dbRef.get();

  bool userFound = false;

  if (data.exists) {
    for (var child in data.children) {
      Map<dynamic, dynamic>? userData = child.value as Map<dynamic, dynamic>?;

      if (userData != null &&
          userData["email"] == email &&
          userData["password"] == password) {
        userFound = true;

        // Navigate to ScannerScreen on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScannerScreen()),
        );
        break;
      }
    }
  }

  if (!userFound) {
    showSnackBar(context, "Invalid email or password!", isError: true);
  }
}

void signUp(String email, String password, String username,
    BuildContext context) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");

  // Get current users from database
  DataSnapshot data = await dbRef.get();

  bool emailExists = false;

  if (data.exists) {
    for (var child in data.children) {
      Map<dynamic, dynamic>? userData = child.value as Map<dynamic, dynamic>?;

      if (userData != null && userData["email"] == email) {
        emailExists = true;
        break;
      }
    }
  }

  if (emailExists) {
    showSnackBar(context, "Email already exists!", isError: true);
  } else {
    String newUserKey = dbRef.push().key ?? "defaultKey";

    await dbRef.child(newUserKey).set({
      "email": email,
      "password": password,
      "username": username,
      "urls": []
    });

    showSnackBar(context, "User registered successfully!", isError: false);
  }
}
