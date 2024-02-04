import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  final FlashyCard card;

  const CardPage({Key? key, required this.card}) : super(key: key);

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
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
            const Text(
              'Questions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (String question in widget.card.questions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(question),
              ),
            const Text(
              '\nAnswers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (String answer in widget.card.answers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(answer),
              ),
          ],
        ),
      ),
    );
  }
}
