import 'package:invisiblecardgame/card.dart';

class DeckBuilder {
  final List<Card> cards = allCards;
  bool _isPairMode;

  DeckBuilder forPairMode(isPairMode) {
    _isPairMode = isPairMode;
    return this;
  }

  List<Card> getVisibleCards() {
    return _isPairMode ? _getPairCards() : _getOddCards();
  }

  List<Card> getInvisibleCards() {
    return _isPairMode ? _getOddCards() : _getPairCards();
  }

  List<Card> _getPairCards() {
    List<Card> redKings = [Card(KING_VALUE, D_CARD), Card(KING_VALUE, H_CARD)];

    List<Card> generatedDeck = cards
        .where((card) => card.value % 2 == 0 && card.value != KING_VALUE)
        .toList();
    generatedDeck.addAll(redKings);

    return generatedDeck;
  }

  List<Card> _getOddCards() {
    List<Card> blackKings = [
      Card(KING_VALUE, S_CARD),
      Card(KING_VALUE, C_CARD)
    ];

    List<Card> generatedDeck = cards
        .where((card) => card.value % 2 != 0 && card.value != KING_VALUE)
        .toList();
    generatedDeck.addAll(blackKings);

    return generatedDeck;
  }

  static List<Card> generatedNextVisibleCards(
      List<Card> visibleCards, List<Card> invisibleCards) {
    List<Card> nextVisibleCards = [visibleCards[1]];

    List<Card> cardRemainToBeSeen =
        visibleCards.getRange(2, visibleCards.length).toList();
    Card associatedCard = invisibleCards.firstWhere(
        (card) =>
            card.getName() == visibleCards.first.getAssociatedCard().getName(),
        orElse: () => null);

    if (associatedCard != null) {
      cardRemainToBeSeen.add(associatedCard);
    }

    cardRemainToBeSeen.shuffle();
    nextVisibleCards.addAll(cardRemainToBeSeen);

    return nextVisibleCards;
  }
}
