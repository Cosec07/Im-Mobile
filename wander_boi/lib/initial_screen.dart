import 'package:flutter/material.dart';
import 'map_screen.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to the map screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          },
          child: Text('Start Exploring'),
        ),
      ),
    );
  }
}
