import 'package:chess_game/game_board.dart';
import 'package:flutter/material.dart';

class PlayerName extends StatelessWidget {
  final TextEditingController _name1 = TextEditingController();
  final TextEditingController _name2 = TextEditingController();

  PlayerName({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 139, 150, 46),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,  // Center the column vertically
            children: [
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "1st Player Name",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  controller: _name1,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(height: 20),  // Add space between the text fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "2nd Player Name",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  controller: _name2,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(height: 100),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameBoard(
                        player1Name: _name1.text,
                        player2Name: _name2.text,
                      ),
                    ),
                  );
                },
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}