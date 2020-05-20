import 'package:test/test.dart';
import 'package:invisiblecardgame/deck_builder.dart';

void main() {
  group('with pair mode', () {
    DeckBuilder deck;

    setUp(() {
      deck = DeckBuilder().forPairMode(true);
    });

    test('gets visible card with pair value', () {
      expect(deck.getVisibleCards().first.value % 2, 0);
    });

    test('gets visible cards', () {
      expect(deck.getVisibleCards().length, 26);
    });

    test('gets invisible cards', () {
      expect(deck.getInvisibleCards().length, 26);
    });

    test('invisible cards and visibles cards does not have same cards', () {
      Set cards = new Set<String>();
      [...deck.getVisibleCards(), ...deck.getInvisibleCards()]
          .forEach((card) => cards.add(card.getName()));

      expect(cards.length, 52);
    });
  });


  group('with odd mode', () {
    DeckBuilder deck;

    setUp(() {
      deck = DeckBuilder().forPairMode(false);
    });

    test('gets visible card with odd value', () {
      expect(deck.getVisibleCards().first.value % 2 > 0, true);
    });

    test('gets visible cards', () {
      expect(deck.getVisibleCards().length, 26);
    });

    test('gets invisible cards', () {
      expect(deck.getInvisibleCards().length, 26);
    });

    test('invisible cards and visibles cards does not have same cards', () {
      Set cards = new Set<String>();
      [...deck.getVisibleCards(), ...deck.getInvisibleCards()]
          .forEach((card) => cards.add(card.getName()));

      expect(cards.length, 52);
    });
  });
}
