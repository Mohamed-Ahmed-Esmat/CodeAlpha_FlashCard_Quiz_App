import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/card.dart';
import 'package:flash_card_quiz_app/widgets/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/authentication_services.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<CardListProvider>(context, listen: false).loadUserCards();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthenticationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }
          return Consumer<CardListProvider>(
            builder: (context, cardListProvider, child) {
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
                body: cardListProvider.cards.isEmpty
                    ? const Center(
                        child: Text(
                          'No cards available',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search',
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        cardListProvider.filterCards('');
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    cardListProvider.filterCards(value);
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: cardListProvider.filteredCards.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No matching cards found',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                      itemCount:
                                          cardListProvider.filteredCards.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          child: Card(
                                            elevation: 10,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    cardListProvider
                                                        .filteredCards[index]
                                                        .title,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                          context,
                                                          cardListProvider
                                                                  .filteredCards[
                                                              index]);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      confirmDelete(
                                                          context, index);
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
                                                  card: cardListProvider
                                                      .filteredCards[index],
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
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.add),
                ),
              );
            },
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

  void _showAddCardDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController questionsController = TextEditingController();
    TextEditingController answersController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: questionsController,
                decoration: const InputDecoration(
                    labelText: 'Questions (comma-separated)'),
              ),
              TextField(
                controller: answersController,
                decoration: const InputDecoration(
                    labelText: 'Answers (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CardListProvider>(context, listen: false)
                    .addNewCard(titleController.text, questionsController.text,
                        answersController.text);
                Navigator.pop(context);
              },
              child: const Text('Add'),
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
        TextEditingController(text: card.questions.join(','));
    TextEditingController answersController =
        TextEditingController(text: card.answers.join(','));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Card'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: questionsController,
                decoration: const InputDecoration(
                    labelText: 'Questions (comma-separated)'),
              ),
              TextField(
                controller: answersController,
                decoration: const InputDecoration(
                    labelText: 'Answers (comma-separated)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<CardListProvider>(context, listen: false).editCard(
                    card,
                    titleController.text,
                    questionsController.text,
                    answersController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this card?',
            style: TextStyle(
              color: Colors.red,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onPressed: () {
                Provider.of<CardListProvider>(context, listen: false)
                    .deleteCard(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
