import 'package:flutter/material.dart';


class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text('All Songs'),
        backgroundColor: Colors.blue[900],
      ),
      body: const Center(
        child: Text('All Songs Page', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}