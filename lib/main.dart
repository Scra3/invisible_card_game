import 'package:flutter/material.dart';
import 'package:invisiblecardgame/card.dart' as GameCard;
import 'package:flip_card/flip_card.dart';
import 'package:invisiblecardgame/deck_builder.dart';

void main() => runApp(MyApp());

const double CARD_LEFT_RATIO = 0.4;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(title: 'Deck of Cards'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<GameCard.Card> _visibleCards;
  List<GameCard.Card> _invisibleCards;
  bool _isPairMode = true;
  bool _isStartedCardDisplayed = true;
  bool _isInvisibleCardRevealed = false;
  bool _isTutorialDisplayed = false;

  @override
  void initState() {
    super.initState();
    setupStates(true);
  }

  void setupStates(bool isPairMode) {
    DeckBuilder deckBuilder = DeckBuilder().forPairMode(isPairMode);
    setState(() {
      _isPairMode = isPairMode;
      _isStartedCardDisplayed = true;
      _isInvisibleCardRevealed = false;
      _isTutorialDisplayed = false;
      _invisibleCards = deckBuilder.getInvisibleCards();
      _visibleCards = deckBuilder.getVisibleCards();
      _visibleCards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(children: <Widget>[
                  Text(widget.title),
                  Text(_isPairMode ? '' : '.')
                ]),
                IconButton(
                  icon: Icon(Icons.help),
                  tooltip: 'Increase volume by 10',
                  onPressed: () {
                    setState(() {
                      _isTutorialDisplayed = !_isTutorialDisplayed;
                    });
                  },
                ),
              ]),
        ),
        body: Center(
            child: Container(
          height: MediaQuery.of(context).size.height,
          width: cardWidth,
          child: Stack(children: <Widget>[
            ...generateDeckCardsForElevationEffectWidget(cardWidth),
            buildDeckWidget(cardWidth),
            buildFlipCardWidget(cardWidth),
            buildFirstCardToStartWidget(cardWidth),
            buildRestartStartButtonWidget(cardWidth),
          ]),
        )));
  }

  Widget buildRestartStartButtonWidget(double cardWidth) {
    return Positioned(
        bottom: 0,
        width: cardWidth,
        child: RaisedButton(
            color: Color(0XFF30475e),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)),
            onPressed: () {
              setState(() {
                if (_isStartedCardDisplayed) {
                  _isStartedCardDisplayed = false;
                } else {
                  setupStates(_isPairMode);
                }
              });
            },
            child: Text(
              _isStartedCardDisplayed ? "Start" : "Retry",
              style: TextStyle(fontSize: 20.0),
            )));
  }

  Widget buildFirstCardToStartWidget(double cardWidth) {
    if (!_isStartedCardDisplayed) {
      return Container();
    }

    return GestureDetector(
      onTap: () => toggleMode(),
      child:
          Image(image: _visibleCards[0].getBackAssetImage(), width: cardWidth),
    );
  }

  Widget buildFlipCardWidget(double cardWidth) {
    // it uses to disable draggable cards

    if (!_isInvisibleCardRevealed) {
      return Container();
    }

    return Positioned(
      width: cardWidth,
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Image(
            gaplessPlayback: true,
            image: _visibleCards[0].getAssociatedCard().getBackAssetImage()),
        back: Image(
          gaplessPlayback: true,
          image: _visibleCards[0].getAssociatedCard().getAssetImage(),
        ),
      ),
    );
  }

  Widget buildDeckWidget(double cardWith) {
    if (_visibleCards.length == 1) {
      return Container(child: getCurrentCardImageWidget(), width: cardWith);
    } else {
      return GestureDetector(
          onVerticalDragDown: (DragDownDetails details) {
            revealInvisibleCardIfTapsOnLeftSide(
                details.globalPosition, cardWith);
          },
          child: Draggable(
              child: Container(
                child: _isInvisibleCardRevealed
                    ? Container()
                    : getCurrentCardImageWidget(),
                width: cardWith,
              ),
              feedback: Container(
                child: getCurrentCardImageWidget(),
                width: cardWith,
              ),
              childWhenDragging: Container(
                child: getNextCardImageWidget(),
                width: cardWith,
              ),
              onDragEnd: (drag) {
                if (!_isInvisibleCardRevealed) {
                  generateNextCard();
                  removeCurrentCard();
                }
              }));
    }
  }

  void removeCurrentCard() {
    _visibleCards.removeAt(0);
  }

  List<Widget> generateDeckCardsForElevationEffectWidget(double cardWidth) {
    AssetImage cardImage = AssetImage('images/cards/white_card.png');

    if (_isInvisibleCardRevealed) {
      cardImage = _visibleCards[1].getAssetImage();
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

  void revealInvisibleCardIfTapsOnLeftSide(
      Offset globalPosition, double cardWith) {
    if (globalPosition.dx > cardWith * CARD_LEFT_RATIO) {
      return;
    }

    setState(() {
      _isInvisibleCardRevealed = true;
    });
  }

  Widget getCurrentCardImageWidget() {
    return Image(
        image: _visibleCards[0].getAssetImage(), gaplessPlayback: true);
  }

  Widget getNextCardImageWidget() {
    return Image(
        image: _visibleCards[1].getAssetImage(), gaplessPlayback: true);
  }

  void toggleMode() {
    setupStates(!_isPairMode);
  }

  void generateNextCard() {
    // if next card is called it means that the associated card is not the the predicted card.
    // So, we can add it randomly in the first part of the deck between currentIndex + 1 and end of the first part.
    List<GameCard.Card> newShuffledCards = [
      _visibleCards.first,
      _visibleCards[1]
    ];

    List<GameCard.Card> cardRemainToBeSeen =
        _visibleCards.getRange(2, _visibleCards.length).toList();
    GameCard.Card associatedCard = _invisibleCards.firstWhere(
        (card) =>
            card.getName() == _visibleCards.first.getAssociatedCard().getName(),
        orElse: () => null);

    if (associatedCard != null) {
      cardRemainToBeSeen.add(associatedCard);
      _invisibleCards.removeWhere(
        (card) =>
            card.getName() == _visibleCards.first.getAssociatedCard().getName(),
      );
    }
    cardRemainToBeSeen.shuffle();
    newShuffledCards.addAll(cardRemainToBeSeen);

    setState(() {
      _visibleCards = newShuffledCards;
    });
  }
}
