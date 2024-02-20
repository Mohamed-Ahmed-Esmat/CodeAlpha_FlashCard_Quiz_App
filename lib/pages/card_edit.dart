import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication_services.dart';
import '../services/firestore_services.dart';

class CardEditPage extends StatefulWidget {
  final String? title;
  final List<String>? questions;
  final List<String>? answers;

  const CardEditPage({
    super.key,
    this.title,
    this.questions,
    this.answers,
  });

  @override
  _CardEditPageState createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  final User? user = AuthenticationService().currentUser;
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> questionControllers = [];
  List<TextEditingController> answerControllers = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.title != null) {
      titleController.text = widget.title!;
    }
    if (widget.questions != null) {
      questionControllers = widget.questions!
          .map((question) => TextEditingController(text: question))
          .toList();
    }
    if (widget.answers != null) {
      answerControllers = widget.answers!
          .map((answer) => TextEditingController(text: answer))
          .toList();
    }
  }

  void saveCard() async {
    List<String> questions =
        questionControllers.map((controller) => controller.text).toList();
    List<String> answers =
        answerControllers.map((controller) => controller.text).toList();

    // Save the new card to Firestore
    await _firestoreService.addFlashyCard(
        titleController.text, questions, answers);

    // After saving the card, navigate back to the previous page
    Navigator.pop(context, 'refresh');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title == null ? 'Add Card' : 'Edit Card'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(
            thickness: 2.0, // Increased thickness
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: questionControllers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  TextField(
                    controller: questionControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Question ${index + 1}',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12.0), // Added SizedBox here
                  TextField(
                    controller: answerControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Answer ${index + 1}',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Divider(
                    thickness: 1.0, // You can adjust thickness here
                  ),
                ],
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                questionControllers.add(TextEditingController());
                answerControllers.add(TextEditingController());
              });
            },
            child: Text('Add Question and Answer'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveCard,
        child: Icon(Icons.save),
      ),
    );
  }
}
