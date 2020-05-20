import 'dart:collection';

import 'package:flutter/cupertino.dart';

const C_CARD = 'C';
const D_CARD = 'D';
const S_CARD = 'S';
const H_CARD = 'H';

const KING_VALUE = 13;
const QUEEN_VALUE = 12;
const VALET_VALUE = 11;
const AS_VALUE = 1;

class Card {
  int value;
  String color;

  Card(this.value, this.color);

  Card getAssociatedCard() {
    const goalValue = 13;

    final cardValue = goalValue - value;
    final associatedColor = getAssociatedColor();

    // is King ?
    if (cardValue == 0) {
      return Card(13, associatedColor);
    } else {
      return Card(cardValue, associatedColor);
    }
  }

  AssetImage getBackAssetImage() {
    return AssetImage('images/cards/gray_back.png');
  }

  AssetImage getAssetImage() {
    String name;
    if (value == KING_VALUE) {
      name = buildName('K', color);
    } else if (value == QUEEN_VALUE) {
      name = buildName('Q', color);
    } else if (value == VALET_VALUE) {
      name = buildName('J', color);
    } else if (value == AS_VALUE) {
      name = buildName('A', color);
    } else {
      name = buildName(value.toString(), color);
    }
    return AssetImage('images/cards/$name.png');
  }

  String getName() {
    return buildName(value.toString(), color);
  }

  String buildName(String value, String color) {
    return '$value$color';
  }

  String getAssociatedColor() {
    switch (color) {
      case C_CARD:
        {
          return D_CARD;
        }
      case D_CARD:
        {
          return C_CARD;
        }
      case S_CARD:
        {
          return H_CARD;
        }
      case H_CARD:
        {
          return S_CARD;
        }
      default:
        {
          return null;
        }
    }
  }
}

List<Card> allCards = [
  // TRÈFLE
  Card(1, C_CARD),
  Card(2, C_CARD),
  Card(3, C_CARD),
  Card(4, C_CARD),
  Card(5, C_CARD),
  Card(6, C_CARD),
  Card(7, C_CARD),
  Card(8, C_CARD),
  Card(9, C_CARD),
  Card(10, C_CARD),
  Card(11, C_CARD),
  Card(12, C_CARD),
  Card(13, C_CARD),
  // CARREAUX
  Card(1, D_CARD),
  Card(2, D_CARD),
  Card(3, D_CARD),
  Card(4, D_CARD),
  Card(5, D_CARD),
  Card(6, D_CARD),
  Card(7, D_CARD),
  Card(8, D_CARD),
  Card(9, D_CARD),
  Card(10, D_CARD),
  Card(11, D_CARD),
  Card(12, D_CARD),
  Card(13, D_CARD),
  // COEUR
  Card(1, H_CARD),
  Card(2, H_CARD),
  Card(3, H_CARD),
  Card(4, H_CARD),
  Card(5, H_CARD),
  Card(6, H_CARD),
  Card(7, H_CARD),
  Card(8, H_CARD),
  Card(9, H_CARD),
  Card(10, H_CARD),
  Card(11, H_CARD),
  Card(12, H_CARD),
  Card(13, H_CARD),
  // PIC
  Card(1, S_CARD),
  Card(2, S_CARD),
  Card(3, S_CARD),
  Card(4, S_CARD),
  Card(5, S_CARD),
  Card(6, S_CARD),
  Card(7, S_CARD),
  Card(8, S_CARD),
  Card(9, S_CARD),
  Card(10, S_CARD),
  Card(11, S_CARD),
  Card(12, S_CARD),
  Card(13, S_CARD),
];
