import 'package:cloud_firestore/cloud_firestore.dart';

class FlashyCard {
  String cardId;
  String title;
  List<int> quizScores = [];
  List<String> questions;
  List<String> answers;

  FlashyCard(
      {required this.cardId,
      required this.title,
      required this.quizScores,
      required this.questions,
      required this.answers});

  factory FlashyCard.fromDocument(DocumentSnapshot doc) {
    return FlashyCard(
      cardId: doc.id,
      title: doc.data().toString().contains('title') ? doc.get('title') : '',
      questions: doc.data().toString().contains('questions')
          ? List<String>.from(doc.get('questions'))
          : [],
      answers: doc.data().toString().contains('answers')
          ? List<String>.from(doc.get('answers'))
          : [],
      quizScores: doc.data().toString().contains('quizScores')
          ? List<int>.from(doc.get('quizScores'))
          : [],
    );
  }
}
