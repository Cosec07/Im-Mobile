import 'package:flutter/material.dart';
import 'map_screen.dart';



class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore your City'),
      ),
      body : Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => MapScreen()),
            );
          },
          child: const Text('Start Exploring'),
        ),
      ),
    );
  }
}