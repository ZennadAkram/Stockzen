import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageSearchPage extends StatefulWidget {
  @override
  _ImageSearchPageState createState() => _ImageSearchPageState();
}

class _ImageSearchPageState extends State<ImageSearchPage> {
  String query = '';
  List<String> imageResults = [];

  Future<void> searchImages(String query) async {
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/search/photos?query=$query&client_id=YOUR_API_KEY'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<String> urls = data['results']
          .map<String>((item) => item['urls']['small'])
          .toList();
      setState(() {
        imageResults = urls;
      });
    } else {
      throw Exception('Failed to load images');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search images...',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  query = text;
                });
              },
              onSubmitted: (text) {
                searchImages(text);
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: imageResults.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Handle image selection
                    print('Selected image URL: ${imageResults[index]}');
                  },
                  child: Image.network(imageResults[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
