import 'package:flash_card_quiz_app/classes/FlashyCard.dart';
import 'package:flash_card_quiz_app/pages/card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();

  // Sample list of cards
  List<FlashyCard> cards = [
    FlashyCard(
      title: 'Science Quiz',
      questions: [
        'What is the capital of France?',
        'What is the atomic number of oxygen?'
      ],
      answers: ['Paris', '8'],
    ),
    FlashyCard(
      title: 'Math Quiz',
      questions: ['2 + 2 equals?', 'Square root of 16?'],
      answers: ['4', '4'],
    ),
    // Add more cards as needed
  ];

  List<FlashyCard> filteredCards = [];

  @override
  void initState() {
    super.initState();
    // Initialize filteredCards with all cards initially
    filteredCards = List.from(cards);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 192, 255, 1.0),
      appBar: AppBar(
        title: const Text('Welcome Learner'),
        backgroundColor: Colors.blue,
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
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Delete the card
                                      setState(() {
                                        cards.remove(filteredCards[index]);
                                        filterCards('');
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            // Navigate to the CardPage when a card is clicked
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CardPage(card: filteredCards[index]),
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
    );
  }

  void filterCards(String query) {
    setState(() {
      // Filter cards based on the search query
      filteredCards = cards
          .where(
              (card) => card.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
