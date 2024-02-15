import 'package:cloud_firestore/cloud_firestore.dart';

import '../classes/FlashyCard.dart';
import 'authentication_services.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationService _authenticationService = AuthenticationService();
  String get currentUserId => _authenticationService.currentUser!.uid;

  Future<FlashyCard> addFlashyCard(
      String title, List<String> questions, List<String> answers) async {
    try {
      final CollectionReference flashycardCollection =
          FirebaseFirestore.instance.collection('flashycard');
      final DocumentReference docRef = await flashycardCollection.add({
        'questions': questions,
        'quizScores': [],
        'answers': answers,
        'title': title,
      });

      // Get the ID of the newly added document and update the user's cards
      await _firestore.collection('user').doc(currentUserId).update({
        'cards': FieldValue.arrayUnion([docRef.id])
      });

      // Return the newly created FlashyCard
      return FlashyCard(
        cardId: docRef.id,
        title: title,
        questions: questions,
        answers: answers,
        quizScores: [],
      );
    } catch (e) {
      print('Error adding new flashycard: $e');
      throw e;
    }
  }

  Future<List<FlashyCard>> getFlashyCardsUser() async {
    final userDoc =
        await _firestore.collection('user').doc(currentUserId).get();
    final List<dynamic> cardIds = userDoc['cards'] ?? [];
    final List<FlashyCard> cards = [];

    for (final cardId in cardIds) {
      final cardDoc =
          await _firestore.collection('flashycard').doc(cardId).get();
      cards.add(FlashyCard.fromDocument(cardDoc));
    }

    return cards;
  }

  Future<void> editFlashyCard(String cardId, String title,
      List<String> questions, List<String> answers) async {
    final cardDoc = _firestore.collection('flashycard').doc(cardId);

    await cardDoc.update({
      'title': title,
      'questions': questions,
      'answers': answers,
    });
  }

  Future<void> deleteFlashyCard(String cardId) async {
    final cardDoc = _firestore.collection('flashycard').doc(cardId);

    await cardDoc.delete();

    await _firestore.collection('user').doc(currentUserId).update({
      'cards': FieldValue.arrayRemove([cardId])
    });
  }

  Future<void> addQuizScore(String cardId, int score) async {
    try {
      // Get the document reference
      final DocumentReference cardDoc =
          _firestore.collection('flashycard').doc(cardId);

      // Get the current document
      final DocumentSnapshot currentDoc = await cardDoc.get();

      // Get the quizScores list
      List<int> quizScores = List<int>.from(currentDoc['quizScores']);
      print("Quiz Scores 1: \n");
      print(quizScores);
      // Add the new score to the list
      quizScores.add(score);
      // Update the quizScores list in Firestore
      await cardDoc.update({
        'quizScores': quizScores,
      });
    } catch (e) {
      print('Error adding quiz score: $e');
      throw e;
    }
  }

  Future<List<int>> getQuizScores(String cardId) async {
    try {
      // Get the document reference
      final DocumentReference cardDoc =
          _firestore.collection('flashycard').doc(cardId);

      // Get the current document
      final DocumentSnapshot currentDoc = await cardDoc.get();

      // Get the quizScores list
      List<int> quizScores = List<int>.from(currentDoc['quizScores']);
      print("Quiz Scores 2: \n");
      print(quizScores);
      return quizScores;
    } catch (e) {
      print('Error getting quiz scores: $e');
      throw e;
    }
  }

  Future<void> deleteScoreList(String cardId) async {
    try {
      // Get a reference to the document
      DocumentReference cardRef =
          FirebaseFirestore.instance.collection('flashycard').doc(cardId);

      // Update the document to set 'quizScores' to an empty list
      await cardRef.update({
        'quizScores': [],
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
