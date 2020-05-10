import 'package:flutter/cupertino.dart';

enum Move { UP, DOWN, LEFT, RIGHT, IDLE }

class SwipeMove {
  final Move move;

  final double x;

  final double y;

  SwipeMove({@required this.move, @required this.x, @required this.y});

  factory SwipeMove.empty() {
    return SwipeMove(move: Move.IDLE, x: 0, y: 0);
  }

  @override
  String toString() {
    return "SwipeMove{move: $move, x: $x, column: $y}";
  }
}
