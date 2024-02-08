import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../classes/FlashyCard.dart';
import 'authentication_services.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationService _authenticationService = AuthenticationService();
  String get currentUserId => _authenticationService.currentUser!.uid;

  Future<void> addFlashyCard(
      String title, List<String> questions, List<String> answers) async {
    try {
      final CollectionReference flashycardCollection =
          FirebaseFirestore.instance.collection('flashycard');
      final DocumentReference docRef = await flashycardCollection.add({
        'questions': questions,
        'answers': answers,
        'title': title,
      });

      // Get the ID of the newly added document and update the user's followed_courses
      await _firestore.collection('users').doc(currentUserId).update({
        'followed_courses': FieldValue.arrayUnion([docRef.id])
      });
    } catch (e) {
      print('Error adding new flashycard: $e');
    }
  }

  Future<List<String>> getUserFollowing() async {
    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUserId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null && userData['followed_courses'] is List) {
          final List<dynamic> userFollowing = userData['followed_courses'];
          return userFollowing.map((item) => item.toString()).toList();
        }
      }
      return []; // Return an empty list if user data doesn't exist or no following courses
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user following data: $e');
      }
      return []; // Handle the error and return an empty list
    }
  }

  Future<List<FlashyCard>> getFlashyCardsUser() async {
    try {
      final userFollowing = await getUserFollowing();

      final querySnapshot = await _firestore
          .collection('flashycard')
          .where(FieldPath.documentId, whereIn: userFollowing)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final questions = data['questions'] as List<String>?; // Add null-check
        final answers = data['answers'] as List<String>?; // Add null-check
        final title = data['title'] as String?; // Add null-check

        if (questions == null) {
          print('card questions is null for document ID: ${doc.id}');
        }
        if (answers == null) {
          print('card answers is null for document ID: ${doc.id}');
        }
        if (title == null) {
          print('card title is null for document ID: ${doc.id}');
        }

        return FlashyCard(
          questions: questions ?? [], // Provide a default value if null
          title: title ?? '', // Provide a default value if null
          cardId: doc.id,
          answers: answers ?? [], // Provide a default value if null
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user following data: $e');
      }
      return []; // Handle the error and return an empty list
    }
  }
}
