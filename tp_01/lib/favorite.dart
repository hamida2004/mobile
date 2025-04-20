import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;

  FavoritesScreen({required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.blue[900],
      ),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final song = favorites.toList()[index];
          return ListTile(
            title: Text(song),
            // You can add more details or actions here
          );
        },
      ),
    );
  }
}