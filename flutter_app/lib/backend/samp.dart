import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/scanner_screen.dart';

void login(String email, String password, BuildContext context) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");

  // Get all users
  DataSnapshot data = await dbRef.get();

  bool userFound = false;

  if (data.exists) {
    // Loop through each user to find a match
    for (var child in data.children) {
      Map<dynamic, dynamic>? userData = child.value as Map<dynamic, dynamic>?;

      if (userData != null &&
          userData["email"] == email &&
          userData["password"] == password) {
        userFound = true;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ScannerScreen()));
        print("Login successful! Welcome, ${userData["username"]}");
        break;
      }
    }
  }

  if (!userFound) {
    print("Invalid email or password!");
  }
}

void signUp(String email, String password, String username) async {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");

  // Get current users from database
  DataSnapshot data = await dbRef.get();

  bool emailExists = false;

  if (data.exists) {
    // Loop through the existing users
    for (var child in data.children) {
      Map<dynamic, dynamic>? userData = child.value as Map<dynamic, dynamic>?;

      if (userData != null && userData["email"] == email) {
        emailExists = true;
        break;
      }
    }
  }

  if (emailExists) {
    print("Email already exists!");
  } else {
    // Push new user to database
    String newUserKey = dbRef.push().key ?? "defaultKey";

    await dbRef.child(newUserKey).set({
      "email": email,
      "password": password,
      "username": username,
      "urls": []
    });

    print("User registered successfully!");
  }
}
