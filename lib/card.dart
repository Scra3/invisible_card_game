import 'package:flutter/cupertino.dart';

const C_CARD = 'C';
const D_CARD = 'D';
const S_CARD = 'S';
const H_CARD = 'H';

class Card {
  int _value;
  String _color;

  Card(this._value, this._color);

  Card getAssociatedCard() {
    const goal_value = 13;

    final cardValue = goal_value - _value;
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
    if (_value == 13) {
      name = buildName('K', _color);
    } else if (_value == 12) {
      name = buildName('Q', _color);
    } else if (_value == 11) {
      name = buildName('J', _color);
    } else if (_value == 1) {
      name = buildName('A', _color);
    }  else {
      name = buildName(_value.toString(), _color);
    }
    return AssetImage('images/cards/$name.png');
  }

  String getName() {
    return buildName(_value.toString(), _color);
  }

  String buildName(String value, String color) {
    return '$value$color';
  }

  String getAssociatedColor() {
    switch (_color) {
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