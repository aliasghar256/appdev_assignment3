import 'package:equatable/equatable.dart';
import '../main.dart'; // Add this line to import NewsArticleModel

abstract class NewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNews extends NewsEvent {}

class ShowArticleDetails extends NewsEvent {
  final NewsArticleModel article;

  ShowArticleDetails(this.article);

  @override
  List<Object?> get props => [article];
}
class ModalDismissed extends NewsEvent {
  @override
  List<Object?> get props => [];
}
