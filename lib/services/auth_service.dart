import 'dart:async';

import 'package:carelog/database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Signs in with Google and returns the authenticated User.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );

        return userCredential.user;
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
    return null;
  }

  /// Synchronizes local data to Firestore for the current signed-in user.
  Future<void> synchronizeData() async {
    // TODO: Implement data synchronization logic here
    final user = _auth.currentUser;
    if (user == null) {
      print('User not signed in. Cannot synchronize data.');
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final localProducts = await DatabaseHelper.instance.getProducts();
    final localRoutines = await DatabaseHelper.instance.getRoutines();

    // Upload local products to Firestore
    if (localProducts.isNotEmpty) {
      final batch = firestore.batch();
      for (final product in localProducts) {
        final docRef = firestore
            .collection('users')
            .doc(user.uid)
            .collection('products')
            .doc(product.id);
        batch.set(docRef, {
          'name': product.name,
          'brand': product.brand,
          'type': product.type,
          'benefit': product.benefit,
          'purchaseDate': Timestamp.fromDate(product.purchaseDate),
          'price': product.price,
          'openingDate': Timestamp.fromDate(product.openingDate),
          'expiryPeriod': product.expiryPeriod,
          'expiryDate': Timestamp.fromDate(product.expiryDate),
          'imagePath': product.imagePath,
          'notes': product.notes,
        });
      }
      await batch.commit();
      print('Uploaded ${localProducts.length} products to Firestore.');
    }

    // TODO: Implement uploading routines and clearing local database
    if (localRoutines.isNotEmpty) {
      print('Synchronizing ${localRoutines.length} routines...');
      // You'll need to implement the logic to upload routines,
      // including handling the product IDs stored as a JSON string.
    }
  }
}
