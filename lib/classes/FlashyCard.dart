class FlashyCard {
  String title;
  List<int> quizScores = [0];
  List<String> questions;
  List<String> answers;

  FlashyCard(
      {required this.title, required this.questions, required this.answers});
}
