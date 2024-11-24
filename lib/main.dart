import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // Import intl package for date formatting.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NewsPage(),
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchNews() async {
    const String baseUrl = 'https://newsapi.org/v2/top-headlines?country=us';
    const String apiKey = 'abb021fcd9124fe4a756d19365dc0136';
    final response = await http.get(Uri.parse('$baseUrl&apiKey=$apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to fetch news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 10),
            const Text('News App'),
          ],
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return NewsTile(article: article);
              },
            );
          }
          return const Center(child: Text('No News Found'));
        },
      ),
    );
  }
}

class NewsTile extends StatelessWidget {
  final Map<String, dynamic> article;

  const NewsTile({Key? key, required this.article}) : super(key: key);

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
        leading: article['urlToImage'] != null
            ? Image.network(article['urlToImage'], width: 100, fit: BoxFit.fill, height: double.infinity, )
            : const Icon(Icons.image, size: 50),
        title: Text(
          style: TextStyle(fontWeight: FontWeight.bold),
          article['title'] ?? 'No Title',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(article['author'] ?? 'Unknown Author'),
            const SizedBox(height: 5),
            Text(formatPublishedDate(article['publishedAt'] ?? 'No Date')),
          ],
        ),
        
        
      ),
    );
  }
}

class NewsTileModel {
  final String? author;
  final String? title;
  final String? publishedAt;
  final String? content;
  final String? imageUrl;
  final String? articleUrl;

  NewsTileModel({
    this.author,
    required this.title,
    this.publishedAt,
    this.content,
    this.imageUrl,
    this.articleUrl,
  });

  factory NewsTileModel.fromJson(Map<String, dynamic> json) {
    return NewsTileModel(
      author: json['author'],
      title: json['title'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      imageUrl: json['urlToImage'],
      articleUrl: json['url'],
    );
  }
}