import 'package:flutter/material.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
      ),
      body: Center(
        child: Text(
          'No saved jobs yet',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}