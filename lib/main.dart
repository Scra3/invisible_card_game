import 'package:flutter/material.dart';
import 'package:invisiblecardgame/card.dart' as GameCard;
import 'package:flip_card/flip_card.dart';

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
  bool _isStartedCardDisplayed = true;
  bool _isFlipCardDisplayed = false;
  bool _nextCardIsAssociatedCardOfCurrentCard = false;

  @override
  void initState() {
    super.initState();
    setupStates(true);
  }

  void setupStates(bool isPairMode) {
    setState(() {
      _isPairMode = isPairMode;
      _nextCardIsAssociatedCardOfCurrentCard = false;
      _isStartedCardDisplayed = true;
      _associatedCards = getAssociatedCards(GameCard.allCards, _isPairMode);
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
          width: cardWidth,
          child: Stack(children: <Widget>[
            ...generateDeckCardsForElevationEffect(cardWidth),
            buildDeckWidget(cardWidth),
            displayFlipCard(cardWidth),
            displayFirstCardToStart(cardWidth)
          ]),
        )));
  }

  Widget displayFirstCardToStart(double cardWidth) {
    if (!_isStartedCardDisplayed) {
      return Container();
    }

    return GestureDetector(
        onLongPress: () => toggleMode(),
        child: Stack(children: <Widget>[
          Image(image: _shuffledCards[0].getBackAssetImage(), width: cardWidth),
          Positioned(
              top: 197,
              width: cardWidth,
              child: Center(
                  child: Container(
                      width: cardWidth / 2,
                      child: RaisedButton(
                        color: Color(0XFFeb4559),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0)),
                        onPressed: () {
                          setState(() {
                            _isStartedCardDisplayed = false;
                          });
                        },
                        child: Text(
                          "Start",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ))))
        ]));
  }

  Widget displayFlipCard(double cardWidth) {
    // it uses to disable draggable cards

    if (!_isFlipCardDisplayed) {
      return Container(
        width: cardWidth,
      );
    }

    return Positioned(
      width: cardWidth,
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Image(
            gaplessPlayback: true,
            image: _shuffledCards[0].getAssociatedCard().getBackAssetImage()),
        back: Image(
          gaplessPlayback: true,
          image: _shuffledCards[0].getAssociatedCard().getAssetImage(),
        ),
      ),
    );
  }

  Widget buildDeckWidget(double cardWith) {
    if (_shuffledCards.length == 1) {
      return Container(child: getCurrentCard(), width: cardWith);
    } else {
      return GestureDetector(
          onVerticalDragDown: (DragDownDetails details) {
            defineTypeOfNextCart(details.globalPosition, cardWith);
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
                generateNextCard();
                removeCurrentCard();
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
    AssetImage cardImage = AssetImage('images/cards/white_card.png');

    if (_isFlipCardDisplayed) {
      cardImage = _shuffledCards[1].getAssetImage();
    }

    return [5.0, 10.0, 15.0, 20.0, 25.0]
        .reversed
        .map((top) => Positioned(
            top: top,
            child: Container(
              child: Image(image: cardImage, gaplessPlayback: true),
              width: cardWidth,
            )))
        .toList();
  }

  void defineTypeOfNextCart(Offset globalPosition, double cardWith) {
    if (globalPosition.dx < cardWith - cardWith * 0.20) {
      return;
    }

    displayOverlay();

    setState(() {
      _nextCardIsAssociatedCardOfCurrentCard = true;
    });
  }

  Widget getCurrentCardFeedback() {
    return Image(
        image: _shuffledCards[0].getAssetImage(), gaplessPlayback: true);
  }

  void displayOverlay() {
    setState(() {
      _isFlipCardDisplayed = true;
    });
  }

  Widget getCurrentCard() {
    return Image(
        image: _shuffledCards[0].getAssetImage(), gaplessPlayback: true);
  }

  Widget getNextCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return Image(
          image: _shuffledCards[0].getAssociatedCard().getBackAssetImage(),
          gaplessPlayback: true);
    } else {
      return Image(
          image: _shuffledCards[1].getAssetImage(), gaplessPlayback: true);
    }
  }

  void generateNextCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    // if next card is called it means that the associated card is not the the predicted card.
    // So, we can add it randomly in the first part of the deck between currentIndex + 1 and end of the first part.
    List<GameCard.Card> newShuffledCards = [
      _shuffledCards.first,
      _shuffledCards[1]
    ];

    List<GameCard.Card> cardRemainToBeSeen =
        _shuffledCards.getRange(2, _shuffledCards.length).toList();
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
    final int kingValue = 13;
    if (isPairMode) {
      List<GameCard.Card> redKings = [
        GameCard.Card(kingValue, GameCard.D_CARD),
        GameCard.Card(kingValue, GameCard.H_CARD)
      ];

      List<GameCard.Card> generatedDeck = cards
          .where((card) => card.value % 2 == 0 && card.value != kingValue)
          .toList();
      generatedDeck.addAll(redKings);

      return generatedDeck;
    } else {
      List<GameCard.Card> blackKings = [
        GameCard.Card(kingValue, GameCard.S_CARD),
        GameCard.Card(kingValue, GameCard.C_CARD)
      ];

      List<GameCard.Card> generatedDeck = cards
          .where((card) => card.value % 2 != 0 && card.value != kingValue)
          .toList();
      generatedDeck.addAll(blackKings);
      return generatedDeck;
    }
  }

  List<GameCard.Card> getAssociatedCards(
      List<GameCard.Card> cards, isPairMode) {
    return getDeck(cards, !isPairMode);
  }
}
