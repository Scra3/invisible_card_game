import 'package:flutter/material.dart';
import 'package:invisiblecardgame/card.dart' as GameCard;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Deck Card'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<GameCard.Card> _shuffledCards = GameCard.allCards;
  List<GameCard.Card> _associatedCards = GameCard.allCards;
  bool _isPairMode = true;
  bool _nextCardIsAssociatedCardOfCurrentCard = false;
  bool _isCardIsRevealed = false;

  @override
  void initState() {
    super.initState();
    setupStates(true);
  }

  void setupStates(bool isPairMode) {
    setState(() {
      _isPairMode = isPairMode;
      _nextCardIsAssociatedCardOfCurrentCard = false;
      _associatedCards = getAssociatedCards(GameCard.allCards, _isPairMode);
      _isCardIsRevealed = false;
      _shuffledCards = getDeck(GameCard.allCards, _isPairMode);
      _shuffledCards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[
            Text(widget.title),
            Text(_isPairMode ? '' : '.')
          ]),
        ),
        body: Center(
          child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(children: <Widget>[
                ...generateDeckCardsForElevationEffect(cardWidth),
                buildDeckWidget(cardWidth)
              ])),
        ));
  }

  Widget buildDeckWidget(double cardWith) {
    if (_shuffledCards.length == 1) {
      return Container(child: getCurrentCard(), width: cardWith);
    } else {
      return GestureDetector(
          onLongPress: () => toggleMode(),
          onDoubleTap: () => revealCard(),
          onVerticalDragDown: (DragDownDetails details) {
            defineTypeOfNextCart(details.globalPosition);
          },
          child: Draggable(
              child: Container(
                child: getCurrentCard(),
                width: cardWith,
              ),
              feedback: Container(
                child: getCurrentCardFeedback(),
                width: cardWith,
              ),
              childWhenDragging: Container(
                child: getNextCard(),
                width: cardWith,
              ),
              onDragEnd: (drag) {
                removeCurrentCard();
                generateNextCard();
              }));
    }
  }

  void removeCurrentCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    _shuffledCards.removeAt(0);
    setState(() {
      _shuffledCards = _shuffledCards;
    });
  }

  List<Widget> generateDeckCardsForElevationEffect(double cardWidth) {
    return [5.0, 10.0, 15.0, 20.0, 25.0]
        .reversed
        .map((top) => Positioned(
            top: top,
            child: Container(
              child: Image(image: AssetImage('images/cards/white_card.png')),
              width: cardWidth,
            )))
        .toList();
  }

  void defineTypeOfNextCart(Offset globalPosition) {
    if (globalPosition.dx < 250 || _nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    setState(() {
      _nextCardIsAssociatedCardOfCurrentCard = true;
    });
  }

  void revealCard() {
    setState(() {
      _isCardIsRevealed = true;
    });
  }

  Widget getCurrentCardFeedback() {
    return Image(image: _shuffledCards[0].getAssetImage());
  }

  Widget getCurrentCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      if (_isCardIsRevealed) {
        return Image(
            image: _shuffledCards[0].getAssociatedCard().getAssetImage());
      } else {
        return Image(
            image: _shuffledCards[0].getAssociatedCard().getBackAssetImage());
      }
    } else {
      return Image(image: _shuffledCards[0].getAssetImage());
    }
  }

  Widget getNextCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return Image(
          image: _shuffledCards[0].getAssociatedCard().getBackAssetImage());
    } else {
      return Image(image: _shuffledCards[1].getAssetImage());
    }
  }

  void generateNextCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    // if next card is called it means that the associated card is not the the predicted card.
    // So, we can add it randomly in the first part of the deck between currentIndex + 1 and end of the first part.
    List<GameCard.Card> newShuffledCards = [_shuffledCards.first];

    List<GameCard.Card> cardRemainToBeSeen =
        _shuffledCards.getRange(1, _shuffledCards.length).toList();
    GameCard.Card associatedCard = _associatedCards.firstWhere(
        (card) =>
            card.getName() ==
            _shuffledCards.first.getAssociatedCard().getName(),
        orElse: () => null);

    if (associatedCard != null) {
      cardRemainToBeSeen.add(associatedCard);
      _associatedCards.removeWhere(
        (card) =>
            card.getName() ==
            _shuffledCards.first.getAssociatedCard().getName(),
      );
    }
    cardRemainToBeSeen.shuffle();
    newShuffledCards.addAll(cardRemainToBeSeen);

    setState(() {
      _shuffledCards = newShuffledCards;
    });
  }

  void toggleMode() {
    setupStates(!_isPairMode);
  }

  List<GameCard.Card> getDeck(List<GameCard.Card> cards, isPairMode) {
    if (isPairMode) {
      return cards.where((card) => card.value % 2 == 0).toList();
    } else {
      return cards.where((card) => card.value % 2 != 0).toList();
    }
  }

  List<GameCard.Card> getAssociatedCards(
      List<GameCard.Card> cards, isPairMode) {
    return getDeck(cards, !isPairMode);
  }
}
