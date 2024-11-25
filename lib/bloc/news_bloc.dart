import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(NewsInitial()) {
    on<FetchNews>(_onFetchNews);
    on<ShowArticleDetails>(_onShowArticleDetails);
    on<ModalDismissed>(_onModalDismissed);
  }

  Future<void> _onFetchNews(FetchNews event, Emitter<NewsState> emit) async {
    emit(NewsLoading());
    try {
      const String baseUrl = 'https://newsapi.org/v2/top-headlines?country=us';
      const String apiKey = 'abb021fcd9124fe4a756d19365dc0136';
      final response = await http.get(Uri.parse('$baseUrl&apiKey=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List<dynamic>)
            .map((json) => NewsArticleModel.fromJson(json))
            .toList();
        emit(NewsLoaded(articles));
      } else {
        emit(NewsError('Failed to fetch news: ${response.statusCode}'));
      }
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

 void _onShowArticleDetails(
    ShowArticleDetails event, Emitter<NewsState> emit) {
  final currentState = state;
  if (currentState is NewsLoaded) {
    emit(ShowModalState(article: event.article, articles: currentState.articles));
  }
}

void _onModalDismissed(ModalDismissed event, Emitter<NewsState> emit) {
  final currentState = state;
  if (currentState is ShowModalState) {
    emit(NewsLoaded(currentState.articles)); // Revert back to NewsLoaded state
  }
}

}
