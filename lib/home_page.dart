import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chess4.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/names');
                },
                
                child: const Text('Start Game',
                style: TextStyle(
                  fontSize: 60.0,
                  color: Colors.green,
                ),
                ),
              ),
             const SizedBox(
                width: 200,
                height: 100,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/instructions');
                },
                child: const Text('rules',
                style: TextStyle(
                  fontSize: 60.0,
                  color: Colors.blue,
                ),
                ),
              ),
              SizedBox(
                height: 200,
              ),
              Text(
                "B.     I.      B.     O.",
                style: TextStyle(
                  fontSize: 50.0,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
