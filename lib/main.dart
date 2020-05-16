import 'package:flutter/material.dart';
import 'package:invisiblecardgame/card.dart' as GameCard;
import 'package:invisiblecardgame/swipe_move.dart';
import 'package:invisiblecardgame/widgets/swipe_detector_widget.dart';

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
  int _currentCardIndex = 0;
  List<GameCard.Card> _shuffledCards = GameCard.allCards;
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
      _currentCardIndex = 0;
      _isPairMode = isPairMode;
      _nextCardIsAssociatedCardOfCurrentCard = false;
      _isCardIsRevealed = false;
      _shuffledCards = getDeckFirstPart(GameCard.allCards, _isPairMode);
      _shuffledCards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[
            Text(widget.title),
            Text(_isPairMode ? '' : '.')
          ]),
        ),
        body: Center(
            child: GestureDetector(
                onDoubleTap: () => revealCard(),
                onVerticalDragDown: (DragDownDetails details) {
                  defineTypeOfNextCart(details.globalPosition);
                },
                child: Draggable(
                    child: Container(
                      child: getCurrentCard(),
                      width: MediaQuery.of(context).size.width * 0.8,
                    ),
                    feedback: Container(
                      child: Container(
                          child: getCurrentCardFeedback(),
                          width: MediaQuery.of(context).size.width * 0.8),
                    ),
                    childWhenDragging: Container(
                      child: Container(
                        child: getNextCard(),
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ),
                    onDragCompleted: () {},
                    onDragEnd: (drag) {
                      nextCurrentCard();
                    }))));
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
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return Image(
          image: _shuffledCards[_currentCardIndex]
              .getAssociatedCard()
              .getBackAssetImage());
    } else {
      return Image(image: _shuffledCards[_currentCardIndex].getAssetImage());
    }
  }

  Widget getCurrentCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      if (_isCardIsRevealed) {
        return Image(
            image: _shuffledCards[_currentCardIndex]
                .getAssociatedCard()
                .getAssetImage());
      } else {
        return Image(
            image: _shuffledCards[_currentCardIndex]
                .getAssociatedCard()
                .getBackAssetImage());
      }
    } else {
      return Image(image: _shuffledCards[_currentCardIndex].getAssetImage());
    }
  }

  Widget getNextCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return Image(
          image: _shuffledCards[_currentCardIndex]
              .getAssociatedCard()
              .getBackAssetImage());
    } else {
      generateNextCard();
      return Image(
          image: _shuffledCards[_currentCardIndex + 1].getAssetImage());
    }
  }

  void nextCurrentCard() {
    if (_nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    setState(() {
      _currentCardIndex++;
    });
  }

  void generateNextCard() {
    if (_currentCardIndex == GameCard.allCards.length - 1 ||
        _nextCardIsAssociatedCardOfCurrentCard) {
      return;
    }

    // if next card is called it means that the associated card is not the the predicted card.
    // So, we can add it randomly in the first part of the deck between currentIndex + 1 and end of the first part.
    GameCard.Card currentCard = _shuffledCards[_currentCardIndex];
    GameCard.Card associatedCard = currentCard.getAssociatedCard();

    List<GameCard.Card> nextShuffledDeck =
        _shuffledCards.getRange(0, _currentCardIndex + 1).toList();
    List<GameCard.Card> cardRemainToBeSeen = _shuffledCards
        .getRange(_currentCardIndex, _shuffledCards.length)
        .toList();

    cardRemainToBeSeen.add(associatedCard);
    cardRemainToBeSeen.shuffle();
    nextShuffledDeck.addAll(cardRemainToBeSeen);

    setState(() {
      _shuffledCards = nextShuffledDeck;
    });
  }

  void toggleMode() {
    setupStates(!_isPairMode);
  }

  List<GameCard.Card> getDeckFirstPart(List<GameCard.Card> cards, isPairMode) {
    if (isPairMode) {
      return cards.where((card) => card.value % 2 == 0).toList();
    } else {
      return cards.where((card) => card.value % 2 != 0).toList();
    }
  }

  List<GameCard.Card> getDeckSecondPart(List<GameCard.Card> cards, isPairMode) {
    return getDeckFirstPart(cards, !isPairMode);
  }
}
