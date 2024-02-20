import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication_services.dart';
import '../services/firestore_services.dart';

class CardEditPage extends StatefulWidget {
  final String? title;
  final String? cardId;
  final List<String>? questions;
  final List<String>? answers;

  const CardEditPage({
    super.key,
    this.title,
    this.questions,
    this.answers,
    this.cardId,
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

    if (widget.cardId == null) {
      // Save the new card to Firestore
      await _firestoreService.addFlashyCard(
          titleController.text, questions, answers);
    } else {
      // Edit the existing card in Firestore
      await _firestoreService.editFlashyCard(
          widget.cardId!, titleController.text, questions, answers);
    }

    // After saving or editing the card, navigate back to the previous page
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: questionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Question ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0), // Added SizedBox here
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    child: TextField(
                      controller: answerControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Answer ${index + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        questionControllers.removeAt(index);
                        answerControllers.removeAt(index);
                      });
                    },
                  ),
                  const Divider(
                    thickness: 1.0, // You can adjust thickness here
                  ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  questionControllers.add(TextEditingController());
                  answerControllers.add(TextEditingController());
                });
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
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
