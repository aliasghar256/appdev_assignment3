abstract class NewsEvent {}

class NewsTilePressed extends NewsEvent {
  final News news;

  NewsTilePressed(this.news);
}