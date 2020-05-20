// Import the test package and Counter class
import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
import 'package:invisiblecardgame/card.dart';

void main() {
  group('Associated card', () {
    Card card;
    Card associatedCard;

    setUp(() {
      card = Card(4, C_CARD);
      associatedCard = card.getAssociatedCard();
    });

    test('gets the card value', () {
      expect(associatedCard.value, 9);
    });

    test('gets the card color', () {
      expect(associatedCard.color, D_CARD);
    });
  });

  group('Get asset image', () {
    test('when it is a number', () {
      expect(Card(4, C_CARD).getAssetImage(), AssetImage('images/cards/4C.png'));
    });

    test('when it is a king', () {
      expect(Card(13, C_CARD).getAssetImage(), AssetImage('images/cards/KC.png'));
    });

    test('when it is a queen', () {
      expect(Card(12, C_CARD).getAssetImage(), AssetImage('images/cards/QC.png'));
    });

    test('when it is a valet', () {
      expect(Card(11, C_CARD).getAssetImage(), AssetImage('images/cards/JC.png'));
    });
  });
}
