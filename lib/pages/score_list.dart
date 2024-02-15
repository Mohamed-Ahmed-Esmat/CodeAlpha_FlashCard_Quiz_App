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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Confirm Delete',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to delete your previous scores?',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          // Call your function to delete the card here
                          _firestoreService.deleteScoreList(card.cardId);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
            if (quizScores.isEmpty) {
              return Center(
                child: Text(
                  'No scores available for ${card.title}\nTime to practice!!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: quizScores.length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: ListTile(
                      title: Text('Quiz ${index + 1}'),
                      trailing: Text('Score: ${quizScores[index]}'),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
