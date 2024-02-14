import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flutter/material.dart';

import '../services/firestore_services.dart';

class QuizPage extends StatefulWidget {
  final FlashyCard card;
  const QuizPage({Key? key, required this.card}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  List<String> shuffledOptions = [];
  bool quizFinished = false;
  String? selectedOption;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Shuffle the questions for the quiz
    widget.card.questions.shuffle();
    // Shuffle the options for the first question
    shuffleOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Multiple Choice Quiz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Question:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(widget.card.questions[currentQuestionIndex]),
            ),
            const SizedBox(height: 16),
            // Display shuffled multiple-choice options
            ...shuffledOptions.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Card(
                  color: selectedOption == option
                      ? (option == widget.card.answers[currentQuestionIndex]
                          ? Colors.green
                          : Colors.red)
                      : Colors.blue,
                  child: ListTile(
                    title: Text(
                      option,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () async {
                      if (!quizFinished && selectedOption == null) {
                        // Set the selected option
                        setState(() {
                          selectedOption = option;
                        });
                        // Check the answer and update the score
                        checkAnswer(option);
                        // If it's the last question, display the score
                        if (currentQuestionIndex ==
                            widget.card.questions.length - 1) {
                          // Store the score in the quizScores list of the FlashyCard class
                          widget.card.quizScores.add(score);
                          showScoreDialog();
                          await _firestoreService.addQuizScore(
                              widget.card.cardId, score);

                          // Mark the quiz as finished
                          quizFinished = true;
                          // Display the score immediately after the final question
                        }
                      }
                    },
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (currentQuestionIndex < widget.card.questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      if (!quizFinished) {
                        // Move to the next question
                        nextQuestionOrDisplayScore();
                      }
                    },
                    child:
                        Icon(Icons.arrow_forward), // Change 'Next' to an arrow
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (quizFinished)
              Text(
                'Score: $score / ${widget.card.questions.length}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  void checkAnswer(String selectedOption) {
    // Check if the selected option is correct
    if (selectedOption == widget.card.answers[currentQuestionIndex]) {
      setState(() {
        // Increment the score for a correct answer
        score++;
      });
    }
  }

  void nextQuestionOrDisplayScore() {
    setState(() {
      if (currentQuestionIndex < widget.card.questions.length - 1) {
        // Move to the next question
        currentQuestionIndex++;
        // Shuffle the options for the new question
        shuffleOptions();
        // Reset the selected option
        selectedOption = null;
      } else {
        // Store the score in the quizScores list of the FlashyCard class
        widget.card.quizScores.add(score);
        // Update the quizScores list in Firestore
        // Mark the quiz as finished
        quizFinished = true;
        // Display the score immediately after the final question
      }
    });
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Finished'),
          content:
              Text('Your score is $score / ${widget.card.questions.length}'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void shuffleOptions() {
    // Combine correct answer and other incorrect answers
    List<String> allOptions = List.from(widget.card.answers);
    allOptions.shuffle();
    shuffledOptions = allOptions.take(4).toList();
  }
}
