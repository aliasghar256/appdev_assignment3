import 'package:flutter_bloc/flutter_bloc.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(const NewsState());

  @override
  Stream<NewsState> mapEventToState(NewsEvent event) async* {
    if (event is NewsEvent) {
      yield state.copyWith(
        news: event.news,
      );
    }
  }
} 