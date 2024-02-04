import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
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
                child: ElevatedButton(
                  onPressed: () {
                    // Check the answer and update the score
                    checkAnswer(option);
                    // Move to the next question or display the score
                    nextQuestionOrDisplayScore();
                  },
                  child: Text(option),
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
                      // Move to the next question
                      nextQuestionOrDisplayScore();
                    },
                    child: Text('Next'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentQuestionIndex == widget.card.questions.length - 1)
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
      }
    });
  }

  void shuffleOptions() {
    // Combine correct answer and other incorrect answers
    List<String> allOptions = List.from(widget.card.answers);
    allOptions.shuffle();
    shuffledOptions = allOptions.take(4).toList();
  }
}
