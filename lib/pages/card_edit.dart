import 'package:flutter/material.dart';

class CardEditPage extends StatefulWidget {
  final String? title;
  final List<String>? questions;
  final List<String>? answers;

  CardEditPage({this.title, this.questions, this.answers});

  @override
  _CardEditPageState createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> questionControllers = [];
  List<TextEditingController> answerControllers = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title == null ? 'Add Card' : 'Edit Card'),
      ),
      body: ListView(
        children: <Widget>[
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          ...List.generate(questionControllers.length, (index) {
            return TextField(
              controller: questionControllers[index],
              decoration: InputDecoration(labelText: 'Question ${index + 1}'),
            );
          }),
          ...List.generate(answerControllers.length, (index) {
            return TextField(
              controller: answerControllers[index],
              decoration: InputDecoration(labelText: 'Answer ${index + 1}'),
            );
          }),
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
        onPressed: () {
          // Handle save operation here
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
