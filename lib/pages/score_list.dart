import 'package:flutter/material.dart';

import '../classes/FlashyCard.dart';
import '../services/firestore_services.dart';

class ScoreListPage extends StatelessWidget {
  final FlashyCard card;
  final FirestoreService _firestoreService = FirestoreService();

  ScoreListPage({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scores for ${card.title}'),
      ),
      body: FutureBuilder<List<int>>(
        future: _firestoreService.getQuizScores(card.cardId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final quizScores = snapshot.data!;
            return ListView.builder(
              itemCount: quizScores.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Quiz ${index + 1}'),
                  trailing: Text('Score: ${quizScores[index]}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}
