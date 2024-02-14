import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/quiz.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  final FlashyCard card;

  const CardPage({Key? key, required this.card}) : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  int currentQuestionIndex = 0;
  CardSide side = CardSide.FRONT;
  final FlipCardController flipCardController = FlipCardController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.title),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      card: widget.card,
                    ),
                  ),
                );
              },
              child: Text(
                'Ready? Let\'s test your knowledge',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
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
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Do nothing, since the FlipCard will handle the flipping
                },
                child: FlipCard(
                  controller: flipCardController,
                  direction: FlipDirection.HORIZONTAL,
                  front: Container(
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text(
                      'Tap to see the answer',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  back: Container(
                    color: Colors.green,
                    alignment: Alignment.center,
                    child: Text(
                      widget.card.answers[currentQuestionIndex],
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Move to the previous question
                    setState(() {
                      if (currentQuestionIndex > 0) {
                        currentQuestionIndex--;
                      }
                    });
                  },
                ),
                Text(
                  '${currentQuestionIndex + 1} / ${widget.card.questions.length}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    // Move to the next question
                    setState(() {
                      if (currentQuestionIndex <
                          widget.card.questions.length - 1) {
                        currentQuestionIndex++;
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
