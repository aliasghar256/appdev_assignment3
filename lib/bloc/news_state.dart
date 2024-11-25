import 'package:equatable/equatable.dart';
import '../main.dart';

abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsArticleModel> articles;

  NewsLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

class NewsError extends NewsState {
  final String message;

  NewsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShowModalState extends NewsState {
  final NewsArticleModel article;
  final List<NewsArticleModel> articles; // Preserve the articles

  ShowModalState({required this.article, required this.articles});

  @override
  List<Object?> get props => [article, articles];
}
