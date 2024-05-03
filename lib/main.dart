import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEWS App', style: TextStyle(fontSize: 24.0)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(),
          ),
          ElevatedButtonContainer(
            buttonText: 'Apple Headquarters',
            category: 'Apple',
          ),
          ElevatedButtonContainer(
            buttonText: 'Tesla',
            category: 'political',
          ),
          ElevatedButtonContainer(
            buttonText: 'US Business',
            category: 'technical',
          ),
          Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}

class ElevatedButtonContainer extends StatelessWidget {
  final String buttonText;
  final String category;

  const ElevatedButtonContainer({
    required this.buttonText,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewsListScreen(category: category, title: buttonText)),
            );
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}

class NewsListScreen extends StatefulWidget {
  final String category;
  final String title;

  const NewsListScreen({Key? key, required this.category, required this.title}) : super(key: key);

  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late List<Map<String, dynamic>> newsArticles;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNewsArticles();
  }

  Future<void> fetchNewsArticles() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching starts
    });

    late String apiUrl;
    if (widget.category == 'Apple') {
      apiUrl = 'https://newsapi.org/v2/everything?q=apple&from=2024-05-02&to=2024-05-02&sortBy=popularity&apiKey=364399bba8b64b7d9a7fc18dd69fde89';
    } else if (widget.category == 'political') {
      apiUrl = 'https://newsapi.org/v2/everything?q=tesla&from=2024-04-03&sortBy=publishedAt&apiKey=364399bba8b64b7d9a7fc18dd69fde89';
    } else if (widget.category == 'technical') {
      apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=364399bba8b64b7d9a7fc18dd69fde89';
    }

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> articles = responseData['articles'];
      setState(() {
        newsArticles = articles.cast<Map<String, dynamic>>();
        isLoading = false; // Set loading to false when data is fetched
      });
    } else {
      setState(() {
        isLoading = false; // Set loading to false in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} News'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Display loading indicator
          : ListView.builder(
              itemCount: newsArticles.length,
              itemBuilder: (context, index) {
                final article = newsArticles[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewsDetailsScreen(article: article)),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'],
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text(article['description'] ?? ''),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NewsDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const NewsDetailsScreen({Key? key, required this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article['title'],
              style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              article['description'] ?? '',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Author: ${article['author'] ?? 'Unknown'}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Published At: ${article['publishedAt']}',
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
