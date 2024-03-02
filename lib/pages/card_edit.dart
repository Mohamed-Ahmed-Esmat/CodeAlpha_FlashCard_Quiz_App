import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
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
    Key? key,
    this.title,
    this.questions,
    this.answers,
    this.cardId,
  }) : super(key: key);

  @override
  _CardEditPageState createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  final User? user = AuthenticationService().currentUser;
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> questionControllers = [];
  List<TextEditingController> answerControllers = [];
  bool isLoading = false; // New variable to track loading state
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

    if (titleController.text.isNotEmpty &&
        questions.isNotEmpty &&
        answers.isNotEmpty &&
        questions[0].isNotEmpty &&
        answers[0].isNotEmpty) {
      if (widget.cardId == null) {
        await _firestoreService.addFlashyCard(
            titleController.text, questions, answers);
      } else {
        await _firestoreService.editFlashyCard(
            widget.cardId!, titleController.text, questions, answers);
      }

      Navigator.pop(context, 'refresh');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Please enter a title and at least one question and answer.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<void> pickAndUploadFile() async {
    setState(() {
      isLoading = true; // Set loading state to true when picking the file
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      Map<String, List<String>> fileData = await _readFile(filePath);

      if (fileData['questions']!.isNotEmpty &&
          fileData['answers']!.isNotEmpty) {
        questionControllers.clear();
        answerControllers.clear();

        for (var i = 0; i < fileData['questions']!.length; i++) {
          questionControllers
              .add(TextEditingController(text: fileData['questions']![i]));
          answerControllers
              .add(TextEditingController(text: fileData['answers']![i]));
        }

        setState(() {
          isLoading = false; // Set loading state to false after data is loaded
        });
      }
    } else {
      setState(() {
        isLoading = false; // Set loading state to false if no file is picked
      });
    }
  }

  Future<Map<String, List<String>>> _readFile(String filePath) async {
    List<String> questions = [];
    List<String> answers = [];

    if (filePath.endsWith('.xlsx')) {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      var rowCounter = 0;
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (rowCounter == 0) {
            rowCounter++;
            continue;
          }
          if (row.length >= 2) {
            // Read only the first two cells of each row
            var questionValue = row[0]?.value;
            var answerValue = row[1]?.value;

            if (questionValue != null && answerValue != null) {
              questions.add(questionValue.toString());
              answers.add(answerValue.toString());
            }
          }
          rowCounter++;
        }
      }
    }

    return {'questions': questions, 'answers': answers};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title == null ? 'Add Card' : 'Edit Card'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: pickAndUploadFile,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show circular indicator
            )
          : ListView(
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
                  thickness: 2.0,
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
                        SizedBox(height: 12.0),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
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
                          thickness: 1.0,
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
