import 'package:flutter_bloc/flutter_bloc.dart';
import 'news_event.dart';
import 'news_state.dart';


class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(NewsState());

  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {
    if (event is NewsEvent) {
      yield state.copyWith(
        news: event.news,
      );
    }
  }
} 