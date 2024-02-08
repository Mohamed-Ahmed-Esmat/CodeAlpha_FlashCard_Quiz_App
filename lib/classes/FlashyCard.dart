class FlashyCard {
  String cardId;
  String title;
  List<int> quizScores = [0];
  List<String> questions;
  List<String> answers;

  FlashyCard(
      {required this.cardId,
      required this.title,
      required this.questions,
      required this.answers});
}
