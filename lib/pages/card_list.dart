import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/card.dart';
import 'package:flash_card_quiz_app/widgets/list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/authentication_services.dart';
import 'card_edit.dart';
import 'login.dart';

class CardsList extends StatefulWidget {
  const CardsList({Key? key}) : super(key: key);

  @override
  State<CardsList> createState() => _CardsListState();
}

class _CardsListState extends State<CardsList> {
  final TextEditingController _searchController = TextEditingController();
  final User? user = AuthenticationService().currentUser;

  @override
  void initState() {
    super.initState();
    Provider.of<CardListProvider>(context, listen: false).loadUserCards();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthenticationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
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
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
                body: cardListProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : cardListProvider.cards.isEmpty
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
                                          itemCount: cardListProvider
                                              .filteredCards.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              child: Card(
                                                elevation: 10,
                                                color: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        cardListProvider
                                                            .filteredCards[
                                                                index]
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
                                                    builder: (context) =>
                                                        CardPage(
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

  void _showAddCardDialog(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardEditPage()),
    );

    // If the result is 'refresh', refresh the page
    if (result == 'refresh') {
      Provider.of<CardListProvider>(context, listen: false).loadUserCards();
    }
  }

  void _showEditCardDialog(BuildContext context, FlashyCard card) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardEditPage(
          cardId: card.cardId,
          title: card.title,
          questions: card.questions,
          answers: card.answers,
        ),
      ),
    );

    // If the result is 'refresh', refresh the page
    if (result == 'refresh') {
      Provider.of<CardListProvider>(context, listen: false).loadUserCards();
    }
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
