import 'package:audioplayers/audioplayers.dart';
import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/score_list.dart';
import 'package:flutter/material.dart';

import '../services/firestore_services.dart';

class QuizPage extends StatefulWidget {
  final FlashyCard card;
  const QuizPage({Key? key, required this.card}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String correctAnswerAudio = 'assets/sounds/correct.mp3';
  String wrongAnswerAudio = 'assets/sounds/incorrect.mp3';
  int currentQuestionIndex = 0;
  int score = 0;
  int questionIndex = 0;
  List<String> shuffledOptions = [];
  List<String> shuffledOQuestions = [];
  bool quizFinished = false;
  String? selectedOption;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Shuffle the questions for the quiz
    shuffledOQuestions = List.from(widget.card.questions)..shuffle();
    print("Original List: ");
    print(widget.card.questions);
    print("Shuffled List: ");
    print(shuffledOQuestions);
    // Shuffle the options for the first question
    shuffleOptions();
    // Find the index of the current question in the original list
    questionIndex =
        widget.card.questions.indexOf(shuffledOQuestions[currentQuestionIndex]);
  }

  @override
  Widget build(BuildContext context) {
    questionIndex =
        widget.card.questions.indexOf(shuffledOQuestions[currentQuestionIndex]);
    print("Question Index out: ");
    print(questionIndex);
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Page'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_outlined),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScoreListPage(
                    card: widget.card,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                child: Text(shuffledOQuestions[currentQuestionIndex]),
              ),
              const SizedBox(height: 16),
              // Display shuffled multiple-choice options
              ...shuffledOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    color: selectedOption == option
                        ? (option == widget.card.answers[questionIndex]
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
                              shuffledOQuestions.length - 1) {
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
                  if (currentQuestionIndex < shuffledOQuestions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        if (!quizFinished) {
                          // Move to the next question
                          nextQuestionOrDisplayScore();
                        }
                      },
                      child: Icon(
                          Icons.arrow_forward), // Change 'Next' to an arrow
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (quizFinished)
                Text(
                  'Score: $score / ${shuffledOQuestions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkAnswer(String selectedOption) async {
    // Check if the selected option is correct
    if (selectedOption == widget.card.answers[questionIndex]) {
      score++;
      await _audioPlayer.play(AssetSource(correctAnswerAudio));

      // Increment the score for a correct answer
    }
    // If the selected option is incorrect
    else {
      await _audioPlayer.play(AssetSource(wrongAnswerAudio));
    }
  }

  void nextQuestionOrDisplayScore() {
    setState(() {
      if (currentQuestionIndex < shuffledOQuestions.length - 1) {
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
          content: Text('Your score is $score / ${shuffledOQuestions.length}'),
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
    questionIndex =
        widget.card.questions.indexOf(shuffledOQuestions[currentQuestionIndex]);
    // Get all incorrect answers
    List<String> incorrectAnswers = List.from(widget.card.answers);
    print("Question Index: ");
    print(questionIndex);
    String correctAnswer = widget.card.answers[questionIndex];

    // Remove the correct answer
    incorrectAnswers.remove(correctAnswer);

    // Shuffle the incorrect answers
    incorrectAnswers.shuffle();

    // Take three incorrect answers and add the correct answer
    shuffledOptions = incorrectAnswers.take(3).toList();
    shuffledOptions.add(correctAnswer);

    // Shuffle these four options
    shuffledOptions.shuffle();
    print("Correct Answer: ");
    print(correctAnswer);
    print("Shuffled Options: ");
    print(shuffledOptions);
  }
}
