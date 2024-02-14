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
        'quizScores': [0],
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
        quizScores: [0],
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
}
