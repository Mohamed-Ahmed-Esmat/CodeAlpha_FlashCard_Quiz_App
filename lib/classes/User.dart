import 'FlashyCard.dart';

class Users {
  final String? uid;
  final String? email;
  final String? username;
  List<FlashyCard>? cards;
  Users({
    this.uid,
    this.email,
    this.username,
    this.cards,
  });
}
