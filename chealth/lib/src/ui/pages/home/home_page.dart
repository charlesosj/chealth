import 'package:chealth/src/ui/pages/home/home_controller.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = HomeController();

  @override
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.getData();
          },
          child:const Icon(Icons.refresh),),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}
