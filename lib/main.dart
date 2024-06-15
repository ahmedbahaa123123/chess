import 'package:chess_game/instructions.dart';
import 'package:chess_game/players_names.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/game_board.dart';
import 'package:chess_game/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/gameboard': (context) => GameBoard(player1Name: 'Player1', player2Name: 'Player2',), // Provide a default value or change it as needed
        '/home': (context) => const HomePage(),
        '/instructions': (context) => const InstructionsPage(),
        '/names': (context) => PlayerName(),
      },
    );
  }
}


