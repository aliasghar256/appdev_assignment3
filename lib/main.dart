import 'package:assignment3_24525/bloc/news_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Import intl package for date formatting.
import './bloc/news_bloc.dart';
import 'bloc/news_event.dart';
import 'bloc/news_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Providing the NewsBloc to the entire app
      create: (context) => NewsBloc()..add(FetchNews()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter News App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const NewsPage(), // Initial screen of the app
      ),
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('News App'),
                const Spacer(),
                Image.asset('assets/logo.png', height: 40),
              ],
            ),
            const Text(
              "The Best News App",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: BlocConsumer<NewsBloc, NewsState>(
        listener: (context, state) {
  if (state is ShowModalState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NewsModalBottomSheet(article: state.article);
      },
    ).whenComplete(() {
      // Trigger the ModalDismissed event when the modal is closed
      context.read<NewsBloc>().add(ModalDismissed());
    });
  }
},

        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NewsLoaded || state is ShowModalState) {
            final articles = (state is NewsLoaded)
                ? state.articles
                : (state as ShowModalState).articles;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return NewsTile(article: article);
              },
            );
          } else if (state is NewsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No News Available'));
        },
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  const NewsTile({Key? key, required this.article}) : super(key: key);

  final NewsArticleModel article;
  String formatPublishedDate(String? date) {
    if (date == null || date.isEmpty) {
      return 'No Date';
    }
    try {
      final DateTime parsedDate = DateTime.parse(date);
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      return formatter.format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: article.imageUrl != null
            ? Image.network(article.imageUrl!, width: 100, fit: BoxFit.fill, height: double.infinity, )
            : const Icon(Icons.image, size: 50),
        title: Text(
          style: TextStyle(fontWeight: FontWeight.bold),
          article.title ?? 'No Title',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(article.author ?? 'Unknown Author'),
            const SizedBox(height: 5),
            Text(formatPublishedDate(article.publishedAt ?? 'No Date')),
          ],
        ),
        onTap: (){
          context.read<NewsBloc>().add(ShowArticleDetails(article));
        },     
      ),
    );
  }
}

class NewsModalBottomSheet extends StatelessWidget {
  final NewsArticleModel article;

  const NewsModalBottomSheet({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Author and Published Date
            Row(
              children: [
                Text(
                  'By ${article.author ?? 'Unknown Author'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  'Published on ${article.publishedAt ?? 'No Date'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Article Image
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  article.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),

            // Article Description
            Text(
              article.description ?? 'No Description Available',
              style: const TextStyle(
                fontSize: 16,
                height: 1.5, // Improve readability
              ),
            ),
            const SizedBox(height: 20),

            // View Full Article Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (article.url != null) {
                    _launchUrl(context, article.url!);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Full Article',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url); // Convert the URL string to a Uri object

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Opens the URL in an external browser
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open URL: $url')),
    );
  }
}
}

class NewsArticleModel {
  final String? author;
  final String title;
  final String? description;
  final String? content;
  final String? publishedAt;
  final String? url;
  final String? imageUrl;

  NewsArticleModel({
    this.author,
    required this.title,
    this.description,
    this.content,
    this.publishedAt,
    this.url,
    this.imageUrl,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      content: json['content'],
      publishedAt: json['publishedAt'],
      url: json['url'],
      imageUrl: json['urlToImage'],
    );
  }
}