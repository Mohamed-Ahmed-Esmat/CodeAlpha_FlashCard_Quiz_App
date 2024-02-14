import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/card.dart';
import 'package:flutter/material.dart';

import '../services/authentication_services.dart';
import '../services/firestore_services.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  final User? user = AuthenticationService().currentUser;
  final FirestoreService firestoreService = FirestoreService();
  List<FlashyCard> cards = [];

  List<FlashyCard> filteredCards = [];

  @override
  void initState() {
    super.initState();
    _loadUserCards();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthenticationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginPage();
          }
          return Scaffold(
            backgroundColor: const Color.fromRGBO(0, 192, 255, 1.0),
            appBar: AppBar(
              title: Text('Welcome ${user.displayName!}'),
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () async {
                    await AuthenticationService().signOut();
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              filterCards('');
                            },
                          ),
                        ),
                        onChanged: (value) {
                          filterCards(value);
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredCards.isEmpty
                      ? const Center(
                          child: Text(
                            'Card don\'t exist',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: filteredCards.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: Card(
                                  elevation: 10,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          filteredCards[index].title,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            _showEditCardDialog(
                                                context, filteredCards[index]);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _deleteCard(filteredCards[index]);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CardPage(
                                        card: filteredCards[index],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showAddCardDialog(context);
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  void filterCards(String query) {
    setState(() {
      filteredCards = cards
          .where(
              (card) => card.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _loadUserCards() async {
    List<FlashyCard> userCards = await firestoreService.getFlashyCardsUser();

    setState(() {
      cards = userCards;
      filteredCards = List.from(cards);
    });
  }

  void _showAddCardDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController questionsController = TextEditingController();
    TextEditingController answersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: questionsController,
                decoration:
                    InputDecoration(labelText: 'Questions (comma-separated)'),
              ),
              TextField(
                controller: answersController,
                decoration:
                    InputDecoration(labelText: 'Answers (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewCard(titleController.text, questionsController.text,
                    answersController.text);
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addNewCard(String title, String questions, String answers) async {
    if (title.isNotEmpty && questions.isNotEmpty && answers.isNotEmpty) {
      List<String> questionList = questions.split(',');
      List<String> answerList = answers.split(',');

      // Validate that the number of answers corresponds to the number of questions
      if (questionList.length == answerList.length) {
        await firestoreService.addFlashyCard(title, answerList, questionList);
        _loadUserCards();
      } else {
        _showErrorDialog(
            'Number of answers should correspond to the number of questions.');
      }
    } else {
      _showErrorDialog('Please fill in all fields.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCardDialog(BuildContext context, FlashyCard card) {
    TextEditingController titleController =
        TextEditingController(text: card.title);
    TextEditingController questionsController =
        TextEditingController(text: card.questions.join(', '));
    TextEditingController answersController =
        TextEditingController(text: card.answers.join(', '));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: questionsController,
                decoration:
                    InputDecoration(labelText: 'Questions (comma-separated)'),
              ),
              TextField(
                controller: answersController,
                decoration:
                    InputDecoration(labelText: 'Answers (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _editCard(card, titleController.text, questionsController.text,
                    answersController.text);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editCard(
      FlashyCard card, String title, String questions, String answers) async {
    if (title.isNotEmpty && questions.isNotEmpty && answers.isNotEmpty) {
      List<String> questionList = questions.split(',');
      List<String> answerList = answers.split(',');

      // Validate that the number of answers corresponds to the number of questions
      if (questionList.length == answerList.length) {
        // Call the editFlashyCard method from FirestoreService
        await firestoreService.editFlashyCard(
            card.cardId, title, questionList, answerList);
        _loadUserCards();
      } else {
        _showErrorDialog(
            'Number of answers should correspond to the number of questions.');
      }
    } else {
      _showErrorDialog('Please fill in all fields.');
    }
  }

  void _deleteCard(FlashyCard card) async {
    // Call the deleteFlashyCard method
    await firestoreService.deleteFlashyCard(card.cardId);

    // Reload the cards
    _loadUserCards();
  }
}
