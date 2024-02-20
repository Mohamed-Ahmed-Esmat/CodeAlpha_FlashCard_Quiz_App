import 'package:flutter/material.dart';

import '../classes/FlashyCard.dart';
import '../services/firestore_services.dart';

class CardListProvider extends ChangeNotifier {
  final FirestoreService firestoreService = FirestoreService();
  List<FlashyCard> cards = [];
  List<FlashyCard> filteredCards = [];
  bool isLoading = false; // Add this line

  CardListProvider() {
    loadUserCards();
  }

  void loadUserCards() async {
    isLoading = true; // Set isLoading to true at the start
    notifyListeners();
    List<FlashyCard> userCards = await firestoreService.getFlashyCardsUser();
    cards = userCards;
    filteredCards = List.from(cards);
    isLoading = false; // Set isLoading to false at the end
    notifyListeners();
  }

  void filterCards(String query) {
    filteredCards = cards
        .where((card) => card.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void addNewCard(String title, String questions, String answers) async {
    if (title.isNotEmpty && questions.isNotEmpty && answers.isNotEmpty) {
      List<String> questionList = questions.split(',');
      List<String> answerList = answers.split(',');

      // Validate that the number of answers corresponds to the number of questions
      if (questionList.length == answerList.length) {
        FlashyCard newCard = await firestoreService.addFlashyCard(
            title, questionList, answerList);
        cards.add(newCard);
        filteredCards.add(newCard);
        notifyListeners();
      } else {
        print(
            'Number of answers should correspond to the number of questions.');
      }
    } else {
      print('Please fill in all fields.');
    }
  }

  void editCard(
      FlashyCard card, String title, String questions, String answers) async {
    if (title.isNotEmpty && questions.isNotEmpty && answers.isNotEmpty) {
      List<String> questionList = questions.split(',');
      List<String> answerList = answers.split(',');

      // Validate that the number of answers corresponds to the number of questions
      if (questionList.length == answerList.length) {
        // Call the editFlashyCard method from FirestoreService
        await firestoreService.editFlashyCard(
            card.cardId, title, questionList, answerList);
        loadUserCards();
      } else {
        print(
            'Number of answers should correspond to the number of questions.');
      }
    } else {
      print('Please fill in all fields.');
    }
  }

  void deleteCard(int index) async {
    // Remove the card from the UI
    FlashyCard card = filteredCards[index];
    cards.remove(card);
    filteredCards.remove(card);

    // Call the deleteFlashyCard method
    await firestoreService.deleteFlashyCard(card.cardId);
    notifyListeners();
  }
}
