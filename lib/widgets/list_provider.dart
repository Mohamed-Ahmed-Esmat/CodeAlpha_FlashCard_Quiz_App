import 'package:flutter/material.dart';

import '../classes/FlashyCard.dart';
import '../services/firestore_services.dart';

class CardListProvider extends ChangeNotifier {
  final FirestoreService firestoreService = FirestoreService();
  List<FlashyCard> cards = [];
  List<FlashyCard> filteredCards = [];

  void loadUserCards() async {
    List<FlashyCard> userCards = await firestoreService.getFlashyCardsUser();
    cards = userCards;
    filteredCards = List.from(cards);
    notifyListeners();
  }

  void filterCards(String query) {
    filteredCards = cards
        .where((card) => card.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }
}
