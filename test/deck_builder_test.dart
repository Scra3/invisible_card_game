import 'package:invisiblecardgame/card.dart';
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

  group('generate next deck', () {
    DeckBuilder deck;
    List<Card> visibleCards;
    List<Card> invisibleCards;

    setUp(() {
      deck = DeckBuilder().forPairMode(true);
      visibleCards = deck.getVisibleCards();
      invisibleCards = deck.getInvisibleCards();
    });

    test('generates the next current card', () {
      Card nextCurrentCard = visibleCards[1];

      List<Card> generatedNextCards =
          DeckBuilder.generatedNextVisibleCards(visibleCards, invisibleCards);

      expect(generatedNextCards.first, nextCurrentCard);
    });

    test('adds to the deck the associated card to the removed card', () {
      Card expectedAssociatedCard = visibleCards.first.getAssociatedCard();

      Card card = visibleCards.firstWhere(
          (card) => card.getName() == expectedAssociatedCard.getName(),
          orElse: () => null);
      expect(card, null);

      List<Card> generatedNextVisibleCards =
          DeckBuilder.generatedNextVisibleCards(visibleCards, invisibleCards);

      card = generatedNextVisibleCards.firstWhere(
          (card) => card.getName() == expectedAssociatedCard.getName(),
          orElse: () => null);

      expect(card.getName(), expectedAssociatedCard.getName());
      expect(generatedNextVisibleCards.length, 26);
    });

    test(
        'does not add to the deck the associated card to the removed card if the card is already an associated card',
        () {
      visibleCards.first = visibleCards.first.getAssociatedCard();
      Card expectedAssociatedCard = visibleCards.first.getAssociatedCard();

      Card card = visibleCards.firstWhere(
          (card) => card.getName() == expectedAssociatedCard.getName(),
          orElse: () => null);
      expect(card, null);

      List<Card> generatedNextVisibleCards =
          DeckBuilder.generatedNextVisibleCards(visibleCards, invisibleCards);

      card = generatedNextVisibleCards.firstWhere(
          (card) => card.getName() == expectedAssociatedCard.getName(),
          orElse: () => null);

      expect(card, null);
      expect(generatedNextVisibleCards.length, 25);
    });
  });
}
