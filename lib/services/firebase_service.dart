import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication Methods
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Firestore Methods
  Future<void> addUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      throw Exception('Failed to add user data: $e');
    }
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).update(userData);
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Storage Methods
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  // Plant Data Methods
  Future<void> addPlantData(String userId, Map<String, dynamic> plantData) async {
    try {
      await _firestore.collection('users').doc(userId).collection('plants').add(plantData);
    } catch (e) {
      throw Exception('Failed to add plant data: $e');
    }
  }

  Future<QuerySnapshot> getUserPlants(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).collection('plants').get();
    } catch (e) {
      throw Exception('Failed to get user plants: $e');
    }
  }
} 