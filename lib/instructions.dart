import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructions'),
      ),
      body: const SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Text(
          "Chess laws or chess rules are laws that govern and direct how chess is played. These laws began to manifest into their current form in the Middle Ages and continued to gradually change slightly until they reached their current form at the beginning of the 19th century, while their origins and first rules are not known, today. Current International Chess Board: The FIDE sets the laws of chess, with some national chess federations making minor changes for their own purposes. There are various rules for speed chess, correspondence chess, web chess and variants of chess.\n\n"
          "Chess is a game played by two people on a chessboard with sixteen pieces for each player. These pieces move certain moves, and the goal of the game is death, which is threatening the king with an inevitable takeover. It is not required that the game end with death. Sometimes players surrender when they are certain of their loss. In addition to that, there are many... One of the ways the game ends in a draw.\n\n"
          "In addition to the basic movements of the pieces, the rules govern the equipment used, time control, ethical behavior of players, requirements for physically disabled players, recording moves using chess marks, as well as providing frameworks for solving unusual problems that may arise during the game.",
          style: TextStyle(
            fontSize: 22.0,
            color: Colors.black87,
            backgroundColor: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
