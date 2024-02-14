import 'package:flutter/material.dart';

import '../classes/FlashyCard.dart';

class CardListNotifier extends ValueNotifier<List<FlashyCard>> {
  CardListNotifier() : super([]);

  void update(List<FlashyCard> newCards) {
    value = newCards;
  }
}
