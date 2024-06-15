import 'dart:async';
import 'package:flutter/material.dart';
import 'components/dead_piece.dart';
import 'components/piece.dart';
import 'components/square.dart';
import 'helper/helper_methods.dart';

class GameBoard extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  const GameBoard({super.key, required this.player1Name, required this.player2Name});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  late Timer whiteTimer;
  late Timer blackTimer;

  int whiteSecondsRemaining = 600; // 10 minutes initially
  int blackSecondsRemaining = 600; // 10 minutes initially

  @override
  void initState() {
    super.initState();
    _initializedBoard();
    _startTimers();
  }

  void _startTimers() {
    const oneSecond = Duration(seconds: 1);

    whiteTimer = Timer.periodic(oneSecond, (timer) {
      if (isWhiteTurn) {
        setState(() {
          if (whiteSecondsRemaining > 0) {
            whiteSecondsRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });

    blackTimer = Timer.periodic(oneSecond, (timer) {
      if (!isWhiteTurn) {
        setState(() {
          if (blackSecondsRemaining > 0) {
            blackSecondsRemaining--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _initializedBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8, (index) => null));
    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: false, imagePath: 'assets/pawn.png');
      newBoard[6][i] = ChessPiece(type: ChessPieceType.pawn, isWhite: true, imagePath: 'assets/pawn.png');
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'assets/rook.png');
    newBoard[0][7] = ChessPiece(type: ChessPieceType.rook, isWhite: false, imagePath: 'assets/rook.png');
    newBoard[7][0] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'assets/rook.png');
    newBoard[7][7] = ChessPiece(type: ChessPieceType.rook, isWhite: true, imagePath: 'assets/rook.png');

    // Place knights
    newBoard[0][1] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'assets/knight.png');
    newBoard[0][6] = ChessPiece(type: ChessPieceType.knight, isWhite: false, imagePath: 'assets/knight.png');
    newBoard[7][1] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'assets/knight.png');
    newBoard[7][6] = ChessPiece(type: ChessPieceType.knight, isWhite: true, imagePath: 'assets/knight.png');

    // Place bishops
    newBoard[0][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'assets/bishop.png');
    newBoard[0][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: false, imagePath: 'assets/bishop.png');
    newBoard[7][2] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'assets/bishop.png');
    newBoard[7][5] = ChessPiece(type: ChessPieceType.bishop, isWhite: true, imagePath: 'assets/bishop.png');

    // Place queens
    newBoard[0][3] = ChessPiece(type: ChessPieceType.queen, isWhite: false, imagePath: 'assets/queen.png');
    newBoard[7][3] = ChessPiece(type: ChessPieceType.queen, isWhite: true, imagePath: 'assets/queen.png');

    // Place kings
    newBoard[0][4] = ChessPiece(type: ChessPieceType.king, isWhite: false, imagePath: 'assets/king.png');
    newBoard[7][4] = ChessPiece(type: ChessPieceType.king, isWhite: true, imagePath: 'assets/king.png');

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
          validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
        }
      } else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
        validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
      } else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];
    if (piece == null) return [];

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Pawns can move forward if the square is not occupied
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // Pawns can move 2 squares forward if they are at their initial positions
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Pawns can capture diagonally
        if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPieceType.rook:
        // Horizontal and vertical directions
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.knight:
        // All eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (isInBoard(newRow, newCol)) {
            if (board[newRow][newCol] == null || board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
          }
        }
        break;

      case ChessPieceType.bishop:
        // Diagonal directions
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) break;
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPieceType.queen:
        // Combine rook and bishop moves
        candidateMoves.addAll(calculateRawValidMoves(row, col, ChessPiece(type: ChessPieceType.rook, isWhite: piece.isWhite, imagePath: '')));
        candidateMoves.addAll(calculateRawValidMoves(row, col, ChessPiece(type: ChessPieceType.bishop, isWhite: piece.isWhite, imagePath: '')));
        break;

      case ChessPieceType.king:
        // One square in any direction
        var kingMoves = [
          [-1, -1],
          [-1, 0],
          [-1, 1],
          [0, -1],
          [0, 1],
          [1, -1],
          [1, 0],
          [1, 1],
        ];
        for (var move in kingMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (isInBoard(newRow, newCol)) {
            if (board[newRow][newCol] == null || board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
          }
        }
        break;

      default:
        break;
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
    if (!checkSimulation) return candidateMoves;

    List<List<int>> realValidMoves = [];
    for (var move in candidateMoves) {
      List<List<ChessPiece?>> simulatedBoard = simulateMove(board, row, col, move[0], move[1]);

      if (!isKingInCheck(simulatedBoard, piece!.isWhite ? whiteKingPosition : blackKingPosition)) {
        realValidMoves.add(move);
      }
    }

    return realValidMoves;
  }

  List<List<ChessPiece?>> simulateMove(List<List<ChessPiece?>> board, int startRow, int startCol, int endRow, int endCol) {
    List<List<ChessPiece?>> simulatedBoard = [];
    for (var row in board) {
      List<ChessPiece?> newRow = [];
      for (var piece in row) {
        if (piece != null) {
          newRow.add(ChessPiece(type: piece.type, isWhite: piece.isWhite, imagePath: piece.imagePath));
        } else {
          newRow.add(null);
        }
      }
      simulatedBoard.add(newRow);
    }

    simulatedBoard[endRow][endCol] = simulatedBoard[startRow][startCol];
    simulatedBoard[startRow][startCol] = null;

    if (simulatedBoard[endRow][endCol]?.type == ChessPieceType.king) {
      if (simulatedBoard[endRow][endCol]!.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    return simulatedBoard;
  }

  bool isKingInCheck(List<List<ChessPiece?>> board, List<int> kingPosition) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite != board[kingPosition[0]][kingPosition[1]]!.isWhite) {
          List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);
          for (var move in candidateMoves) {
            if (move[0] == kingPosition[0] && move[1] == kingPosition[1]) {

              return true;
            }
          }
        }
      }
    }

    return false;
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  void movePiece(int newRow, int newCol) {
    setState(() {
      if (board[newRow][newCol] != null) {
        if (board[newRow][newCol]!.isWhite) {
          whitePiecesTaken.add(board[newRow][newCol]!);
        } else {
          blackPiecesTaken.add(board[newRow][newCol]!);
        }
      }

      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedCol] = null;

      if (selectedPiece?.type == ChessPieceType.king) {
        if (selectedPiece!.isWhite) {
          whiteKingPosition = [newRow, newCol];
        } else {
          blackKingPosition = [newRow, newCol];
        }
      }

      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];

      isWhiteTurn = !isWhiteTurn;
      checkStatus = isKingInCheck(board, isWhiteTurn ? whiteKingPosition : blackKingPosition);
    });
    if(isCheckMate(!isWhiteTurn)) {
   showDialog(context: context, builder: (context) => AlertDialog(
    title: Text("CHECK MATE!"),
    actions: [
      TextButton(onPressed: resetGame, child: Text("Play Again")),
    ],
   ),
   );
    }
  }

 bool isCheckMate(bool isWhiteKing) {
  if (!isKingInCheck(board, whiteKingPosition)) {
    return false;
  }
  for(int i=0;i<8;i++) {
    for (int j = 0 ;j <8 ; j++) {
      if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
        continue;
      }
      List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);
      if(pieceValidMoves.isNotEmpty) {
        return false;
      }
    }
  }


  return true;
 }
 
  @override
  void dispose() {
    whiteTimer.cancel();
    blackTimer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void resetGame() {
    Navigator.pop(context);
    _initializedBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    setState(() {
      
    });
  }
@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: Column(
children: [
Column(
children:[
Text(
widget.player1Name,
style:
TextStyle(
fontSize: 16.0,
fontWeight: FontWeight.bold,
),

  ),
  Text(
              formatTime(blackSecondsRemaining),
              style: TextStyle(
                fontSize: 30,
                color: isWhiteTurn ? Colors.green : Colors.black,
              ),
            ),
],
),

Expanded(
child: GridView.builder(
itemCount: whitePiecesTaken.length,
physics: const NeverScrollableScrollPhysics(),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
itemBuilder: (context, index) => DeadPiece(
imagePath: whitePiecesTaken[index].imagePath,
isWhite: true,
),
),
),
Text(
checkStatus ? "Check!" : ""
),
Expanded(
flex: 3,
child: GridView.builder(
itemCount: 8 * 8,
physics: const NeverScrollableScrollPhysics(),
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 8,
),
itemBuilder: (context, index) {
int row = index ~/ 8;
int col = index % 8;


        bool isSelected = selectedRow == row && selectedCol == col;
        bool isValidMove = false;
        for (var position in validMoves) {
          if (position[0] == row && position[1] == col) {
            isValidMove = true;
          }
        }
  
        return Square(
          isWhite: isWhite(index),
          piece: board[row][col],
          isSelected: isSelected,
          isValidMove: isValidMove,
          isInCheck: checkStatus,
          onTap: () => pieceSelected(row, col),
        );
      },
    ),
  ),
  Text(
    widget.player2Name,
    style: 
    TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
    
  ),
  
  Text(
              formatTime(whiteSecondsRemaining),
              style: TextStyle(
                fontSize: 30,
                color: isWhiteTurn ? Colors.green : Colors.black,
              ),
            ),
  Expanded(
    child: GridView.builder(
      itemCount: blackPiecesTaken.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
       itemBuilder: (context, index) => DeadPiece(
        imagePath: blackPiecesTaken[index].imagePath,
        isWhite: false,
       ),
  ),
  ),
  //  ElevatedButton(
  //           onPressed: () {
  //             // Implement reset functionality
  //             setState(() {
  //               _initializedBoard();
  //               whitePiecesTaken.clear();
  //               blackPiecesTaken.clear();
  //               whiteSecondsRemaining = 600;
  //               blackSecondsRemaining = 600;
  //               isWhiteTurn = true;
  //               checkStatus = false;
  //             });
  //           },
  //           child: Text('Reset Game'),
  //         ),
      
],
),
);
}
}


// import 'dart:async';
// import 'package:chess_game/components/piece.dart';
// import 'package:flutter/material.dart';

// class GameBoard extends StatefulWidget {
//   final String player1Name;
//   final String player2Name;

//   const GameBoard({
//     Key? key,
//     required this.player1Name,
//     required this.player2Name,
//   }) : super(key: key);

//   @override
//   State<GameBoard> createState() => _GameBoardState();
// }

// class _GameBoardState extends State<GameBoard> {
//   late List<List<ChessPiece?>> board;

//   ChessPiece? selectedPiece;
//   int selectedRow = -1;
//   int selectedCol = -1;

//   List<List<int>> validMoves = [];

//   List<ChessPiece> whitePiecesTaken = [];
//   List<ChessPiece> blackPiecesTaken = [];
//   bool isWhiteTurn = true;
//   List<int> whiteKingPosition = [7, 4];
//   List<int> blackKingPosition = [0, 4];
//   bool checkStatus = false;
//   late Timer whiteTimer;
//   late Timer blackTimer;

//   int whiteSecondsRemaining = 600; // 10 minutes initially
//   int blackSecondsRemaining = 600; // 10 minutes initially

//   @override
//   void initState() {
//     super.initState();
//     _initializedBoard();
//     _startTimers();
//   }

//   void _startTimers() {
//     const oneSecond = Duration(seconds: 1);

//     whiteTimer = Timer.periodic(oneSecond, (timer) {
//       if (isWhiteTurn) {
//         setState(() {
//           if (whiteSecondsRemaining > 0) {
//             whiteSecondsRemaining--;
//           } else {
//             timer.cancel();
//           }
//         });
//       }
//     });

//     blackTimer = Timer.periodic(oneSecond, (timer) {
//       if (!isWhiteTurn) {
//         setState(() {
//           if (blackSecondsRemaining > 0) {
//             blackSecondsRemaining--;
//           } else {
//             timer.cancel();
//           }
//         });
//       }
//     });
//   }

//   void _initializedBoard() {
//     List<List<ChessPiece?>> newBoard =
//         List.generate(8, (index) => List.generate(8, (index) => null));

//     // Place pawns
//     for (int i = 0; i < 8; i++) {
//       newBoard[1][i] = ChessPiece(
//         type: ChessPieceType.pawn,
//         isWhite: false,
//         imagePath: 'assets/pawn.png',
//       );
//       newBoard[6][i] = ChessPiece(
//         type: ChessPieceType.pawn,
//         isWhite: true,
//         imagePath: 'assets/pawn.png',
//       );
//     }

//     // Place rooks
//     newBoard[0][0] = ChessPiece(
//       type: ChessPieceType.rook,
//       isWhite: false,
//       imagePath: 'assets/rook.png',
//     );
//     newBoard[0][7] = ChessPiece(
//       type: ChessPieceType.rook,
//       isWhite: false,
//       imagePath: 'assets/rook.png',
//     );
//     newBoard[7][0] = ChessPiece(
//       type: ChessPieceType.rook,
//       isWhite: true,
//       imagePath: 'assets/rook.png',
//     );
//     newBoard[7][7] = ChessPiece(
//       type: ChessPieceType.rook,
//       isWhite: true,
//       imagePath: 'assets/rook.png',
//     );

//     // Place knights
//     newBoard[0][1] = ChessPiece(
//       type: ChessPieceType.knight,
//       isWhite: false,
//       imagePath: 'assets/knight.png',
//     );
//     newBoard[0][6] = ChessPiece(
//       type: ChessPieceType.knight,
//       isWhite: false,
//       imagePath: 'assets/knight.png',
//     );
//     newBoard[7][1] = ChessPiece(
//       type: ChessPieceType.knight,
//       isWhite: true,
//       imagePath: 'assets/knight.png',
//     );
//     newBoard[7][6] = ChessPiece(
//       type: ChessPieceType.knight,
//       isWhite: true,
//       imagePath: 'assets/knight.png',
//     );

//     // Place bishops
//     newBoard[0][2] = ChessPiece(
//       type: ChessPieceType.bishop,
//       isWhite: false,
//       imagePath: 'assets/bishop.png',
//     );
//     newBoard[0][5] = ChessPiece(
//       type: ChessPieceType.bishop,
//       isWhite: false,
//       imagePath: 'assets/bishop.png',
//     );
//     newBoard[7][2] = ChessPiece(
//       type: ChessPieceType.bishop,
//       isWhite: true,
//       imagePath: 'assets/bishop.png',
//     );
//     newBoard[7][5] = ChessPiece(
//       type: ChessPieceType.bishop,
//       isWhite: true,
//       imagePath: 'assets/bishop.png',
//     );

//     // Place queens
//     newBoard[0][3] = ChessPiece(
//       type: ChessPieceType.queen,
//       isWhite: false,
//       imagePath: 'assets/queen.png',
//     );
//     newBoard[7][3] = ChessPiece(
//       type: ChessPieceType.queen,
//       isWhite: true,
//       imagePath: 'assets/queen.png',
//     );

//     // Place kings
//     newBoard[0][4] = ChessPiece(
//       type: ChessPieceType.king,
//       isWhite: false,
//       imagePath: 'assets/king.png',
//     );
//     newBoard[7][4] = ChessPiece(
//       type: ChessPieceType.king,
//       isWhite: true,
//       imagePath: 'assets/king.png',
//     );

//     board = newBoard;
//   }

//   void pieceSelected(int row, int col) {
//     setState(() {
//       if (selectedPiece == null && board[row][col] != null) {
//         if (board[row][col]!.isWhite == isWhiteTurn) {
//           selectedPiece = board[row][col];
//           selectedRow = row;
//           selectedCol = col;
//           validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece!, true);
//         }
//       } else if (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) {
//         selectedPiece = board[row][col];
//         selectedRow = row;
//         selectedCol = col;
//         validMoves = calculateRealValidMoves(selectedRow, selectedCol, selectedPiece!, true);
//       } else if (selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)) {
//         movePiece(row, col);
//       }
//     });
//   }

//   List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
//     List<List<int>> candidateMoves = [];
//     if (piece == null) return [];

//     int direction = piece.isWhite ? -1 : 1;

//     switch (piece.type) {
//       case ChessPieceType.pawn:
//         // Pawns can move forward if the square is not occupied
//         if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
//           candidateMoves.add([row + direction, col]);
//         }
//         // Pawns can move 2 squares forward if they are at their initial positions
//         if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
//           if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
//             candidateMoves.add([row + 2 * direction, col]);
//           }
//         }
//         // Pawns can capture diagonally
//         if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.isWhite != piece.isWhite) {
//           candidateMoves.add([row + direction, col - 1]);
//         }
//         if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.isWhite != piece.isWhite) {
//           candidateMoves.add([row + direction, col + 1]);
//         }
//         break;

//       case ChessPieceType.rook:
//         // Horizontal and vertical directions
//         var directions = [
//           [-1, 0],
//           [1, 0],
//           [0, -1],
//           [0, 1],
//         ];
//         for (var direction in directions) {
//           for (int i = 1; i < 8; i++) {
//             int newRow = row + direction[0] * i;
//             int newCol = col + direction[1] * i;
//             if (!isInBoard(newRow, newCol)) break;
//             if (board[newRow][newCol] == null) {
//               candidateMoves.add([newRow, newCol]);
//             } else {
//               if (board[newRow][newCol]!.isWhite != piece.isWhite) {
//                 candidateMoves.add([newRow, newCol]);
//               }
//               break;
//             }
//           }
//         }
//         break;

//       case ChessPieceType.knight:
//         var knightMoves = [
//           [row - 2, col - 1],
//           [row - 2, col + 1],
//           [row + 2, col - 1],
//           [row + 2, col + 1],
//           [row - 1, col - 2],
//           [row - 1, col + 2],
//           [row + 1, col - 2],
//           [row + 1, col + 2],
//         ];

//         for (var move in knightMoves) {
//           int newRow = move[0];
//           int newCol = move[1];
//           if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null || board[newRow][newCol]!.isWhite != piece.isWhite)) {
//             candidateMoves.add([newRow, newCol]);
//           }
//         }
//         break;

//       case ChessPieceType.bishop:
//         // Diagonal directions
//         var directions = [
//           [-1, -1],
//           [-1, 1],
//           [1, -1],
//           [1, 1],
//         ];
//         for (var direction in directions) {
//           for (int i = 1; i < 8; i++) {
//             int newRow = row + direction[0] * i;
//             int newCol = col + direction[1] * i;
//             if (!isInBoard(newRow, newCol)) break;
//             if (board[newRow][newCol] == null) {
//               candidateMoves.add([newRow, newCol]);
//             } else {
//               if (board[newRow][newCol]!.isWhite != piece.isWhite) {
//                 candidateMoves.add([newRow, newCol]);
//               }
//               break;
//             }
//           }
//         }
//         break;

//       case ChessPieceType.queen:
//         // Queen moves like both a rook and a bishop
//         // Horizontal and vertical directions (rook moves)
//         var rookDirections = [
//           [-1, 0],
//           [1, 0],
//           [0, -1],
//           [0, 1],
//         ];
//         for (var direction in rookDirections) {
//           for (int i = 1; i < 8; i++) {
//             int newRow = row + direction[0] * i;
//             int newCol = col + direction[1] * i;
//             if (!isInBoard(newRow, newCol)) break;
//             if (board[newRow][newCol] == null) {
//               candidateMoves.add([newRow, newCol]);
//             } else {
//               if (board[newRow][newCol]!.isWhite != piece.isWhite) {
//                 candidateMoves.add([newRow, newCol]);
//               }
//               break;
//             }
//           }
//         }

//         // Diagonal directions (bishop moves)
//         var bishopDirections = [
//           [-1, -1],
//           [-1, 1],
//           [1, -1],
//           [1, 1],
//         ];
//         for (var direction in bishopDirections) {
//           for (int i = 1; i < 8; i++) {
//             int newRow = row + direction[0] * i;
//             int newCol = col + direction[1] * i;
//             if (!isInBoard(newRow, newCol)) break;
//             if (board[newRow][newCol] == null) {
//               candidateMoves.add([newRow, newCol]);
//             } else {
//               if (board[newRow][newCol]!.isWhite != piece.isWhite) {
//                 candidateMoves.add([newRow, newCol]);
//               }
//               break;
//             }
//           }
//         }
//         break;

//       case ChessPieceType.king:
//         // King moves in all 8 directions
//         var kingMoves = [
//           [row - 1, col - 1],
//           [row - 1, col],
//           [row - 1, col + 1],
//           [row, col - 1],
//           [row, col + 1],
//           [row + 1, col - 1],
//           [row + 1, col],
//           [row + 1, col + 1],
//         ];

//         for (var move in kingMoves) {
//           int newRow = move[0];
//           int newCol = move[1];
//           if (isInBoard(newRow, newCol) && (board[newRow][newCol] == null || board[newRow][newCol]!.isWhite != piece.isWhite)) {
//             candidateMoves.add([newRow, newCol]);
//           }
//         }

//         // Implementing castling
//         if (piece.isWhite && row == 7 && col == 4) {
//           // White King side castling
//           if (canCastle(row, col + 3)) {
//             candidateMoves.add([row, col + 2]);
//           }
//           // White Queen side castling
//           if (canCastle(row, col - 4)) {
//             candidateMoves.add([row, col - 2]);
//           }
//         } else if (!piece.isWhite && row == 0 && col == 4) {
//           // Black King side castling
//           if (canCastle(row, col + 3)) {
//             candidateMoves.add([row, col + 2]);
//           }
//           // Black Queen side castling
//           if (canCastle(row, col - 4)) {
//             candidateMoves.add([row, col - 2]);
//           }
//         }
//         break;
//     }

//     return candidateMoves;
//   }

//   List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece piece, bool considerCheck) {
//     List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

//     if (considerCheck) {
//       List<List<int>> validMoves = [];
//       for (var move in candidateMoves) {
//         int newRow = move[0];
//         int newCol = move[1];
//         ChessPiece? temp = board[newRow][newCol];
//         board[newRow][newCol] = piece;
//         board[row][col] = null;

//         if (!isInCheck(piece.isWhite)) {
//           validMoves.add([newRow, newCol]);
//         }

//         board[row][col] = piece;
//         board[newRow][newCol] = temp;
//       }
//       return validMoves;
//     }

//     return candidateMoves;
//   }

//   bool isInCheck(bool isWhite) {
//     List<List<int>> opponentMoves = [];
//     List<int> kingPosition = isWhite ? whiteKingPosition : blackKingPosition;

//     for (int row = 0; row < 8; row++) {
//       for (int col = 0; col < 8; col++) {
//         if (board[row][col] != null && board[row][col]!.isWhite != isWhite) {
//           List<List<int>> moves = calculateRawValidMoves(row, col, board[row][col]);
//           opponentMoves.addAll(moves);
//         }
//       }
//     }

//     return opponentMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1]);
//   }

//  bool canCastle(int row, int col) {
//   if (isInBoard(row, col) && board[row][col] != null && board[row][col]!.type == ChessPieceType.rook) {
//     if (board[row][col]!.isWhite == isWhiteTurn && !board[row][col]!.hasMoved) {
//       return true;
//     }
//   }
//   return false;
// }

// void movePiece(int newRow, int newCol) {
//   if (board[newRow][newCol] != null) {
//     if (board[newRow][newCol]!.isWhite) {
//       whitePiecesTaken.add(board[newRow][newCol]!);
//     } else {
//       blackPiecesTaken.add(board[newRow][newCol]!);
//     }
//   }

//   board[newRow][newCol] = selectedPiece;
//   board[selectedRow][selectedCol] = null;
//   selectedPiece!.hasMoved = true;

//   if (selectedPiece!.type == ChessPieceType.king) {
//     if (selectedPiece!.isWhite) {
//       whiteKingPosition = [newRow, newCol];
//     } else {
//       blackKingPosition = [newRow, newCol];
//     }
//   }

//   if (isInCheck(selectedPiece!.isWhite)) {
//     board[selectedRow][selectedCol] = selectedPiece;
//     board[newRow][newCol] = null;
//     if (board[newRow][newCol] != null) {
//       if (board[newRow][newCol]!.isWhite) {
//         whitePiecesTaken.removeLast();
//       } else {
//         blackPiecesTaken.removeLast();
//       }
//     }
//     selectedPiece!.hasMoved = false;
//     return;
//   }

//   setState(() {
//     selectedPiece = null;
//     selectedRow = -1;
//     selectedCol = -1;
//     validMoves = [];
//     isWhiteTurn = !isWhiteTurn;
//     checkStatus = isInCheck(!isWhiteTurn);
//   });
// }

// bool isInBoard(int row, int col) {
//   return row >= 0 && row < 8 && col >= 0 && col < 8;
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Column(
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(vertical: 16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               Text(
//                 '${widget.player1Name} Time: ${whiteSecondsRemaining ~/ 60}:${(whiteSecondsRemaining % 60).toString().padLeft(2, '0')}',
//                 style: TextStyle(fontSize: 18.0),
//               ),
//               Text(
//                 '${widget.player2Name} Time: ${blackSecondsRemaining ~/ 60}:${(blackSecondsRemaining % 60).toString().padLeft(2, '0')}',
//                 style: TextStyle(fontSize: 18.0),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: GridView.builder(
//             itemCount: 64,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 8,
//             ),
//             itemBuilder: (context, index) {
//               int row = index ~/ 8;
//               int col = index % 8;
//               bool isWhiteSquare = (row + col) % 2 == 1;
//               Color squareColor = isWhiteSquare ? Colors.grey[300]! : Colors.brown[700]!;
//               ChessPiece? piece = board[row][col];

//               return GestureDetector(
//                 onTap: () {
//                   pieceSelected(row, col);
//                 },
//                 child: Container(
//                   color: squareColor,
//                   child: piece != null
//                       ? Image.asset(
//                           piece.imagePath,
//                           fit: BoxFit.contain,
//                         )
//                       : null,
//                 ),
//               );
//             },
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             checkStatus ? '${isWhiteTurn ? widget.player1Name : widget.player2Name} is in check!' : '',
//             style: TextStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.red,
//             ),
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.only(bottom: 16.0),
//           child: ElevatedButton(
//             onPressed: () {
//               // Implement reset functionality
//               setState(() {
//                 _initializedBoard();
//                 whitePiecesTaken.clear();
//                 blackPiecesTaken.clear();
//                 whiteSecondsRemaining = 600;
//                 blackSecondsRemaining = 600;
//                 isWhiteTurn = true;
//                 checkStatus = false;
//               });
//             },
//             child: Text('Reset Game'),
//           ),
//         ),
//       ],
//     ),
//   );
// }

// @override
// void dispose() {
//   whiteTimer.cancel();
//   blackTimer.cancel();
//   super.dispose();
// }
// }