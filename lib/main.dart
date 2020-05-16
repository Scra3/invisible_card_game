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
  bool _isCardFound = false;
  bool _isCardFoundDisplayed = false;
  List<GameCard.Card> _shuffledCards = GameCard.allCards;
  List<GameCard.Card> _associatedCards = GameCard.allCards;
  bool _isPairMode = true;
  bool _cardIsChanging = true;

  @override
  void initState() {
    super.initState();
    setupStates(true);
  }

  void setupStates(bool isPairMode) {
    setState(() {
      _currentCardIndex = 0;
      _isCardFound = false;
      _isCardFoundDisplayed = false;
      _isPairMode = isPairMode;
      _cardIsChanging = true;

      _shuffledCards = getDeckFirstPart(GameCard.allCards, _isPairMode);
      _shuffledCards.shuffle();
      _associatedCards = getDeckSecondPart(GameCard.allCards, _isPairMode);
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
        body: Stack(children: <Widget>[
          Center(
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.3,
                  child: Stack(
                    children: <Widget>[
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: buildImageWidget()),
                      Positioned(
                        right: 50,
                        child: SwipeDetector(
                            onDoubleTap: () => displayFoundCard(),
                            onLongPress: () => toggleMode(),
                            onSwipe: (move) {
                              if (move.move == Move.LEFT) {
                                nextCard();
                              } else if (move.move == Move.RIGHT) {
                                previousCard();
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: Colors.transparent,
                            )),
                      ),
                      Positioned(
                        right: 0,
                        width: 50,
                        child: SwipeDetector(
                            onLongPress: () => toggleMode(),
                            onDoubleTap: () => displayFoundCard(),
                            onSwipe: (move) {
                              if (move.move == Move.LEFT) {
                                displayAssociatedBackCard();
                              }
                            },
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              color: Colors.transparent,
                            )),
                      ),
                    ],
                  ))),
          RaisedButton(
            onPressed: () => setupStates(_isPairMode),
            textColor: Colors.white,
            child: const Text('Shuffle', style: TextStyle(fontSize: 20)),
          ),
        ]));
  }

  Widget buildImageWidget() {
    if (_isCardFound && !_isCardFoundDisplayed) {
      return Image(
          image: _shuffledCards[_currentCardIndex].getBackAssetImage());
    } else {
      return Image(image: _shuffledCards[_currentCardIndex].getAssetImage());
    }
  }

  void displayAssociatedBackCard() {
    final String associatedCardName =
        _shuffledCards[_currentCardIndex].getAssociatedCard().getName();
    final GameCard.Card associatedCard = _associatedCards
        .firstWhere((card) => card.getName() == associatedCardName);

    setState(() {
      _shuffledCards[_currentCardIndex] = associatedCard;
      _isCardFound = true;
    });
  }

  void displayFoundCard() {
    setState(() {
      _isCardFoundDisplayed = true;
    });
  }

  void nextCard() {
    if (_currentCardIndex == GameCard.allCards.length - 1 || _isCardFound) {
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
      _cardIsChanging = true;
      _shuffledCards = nextShuffledDeck;
      _currentCardIndex++;
      _cardIsChanging = false;
    });
  }

  void previousCard() {
    if (_currentCardIndex == 0 || _isCardFound) {
      return;
    }

    setState(() {
      _cardIsChanging = true;
      _currentCardIndex--;
      _cardIsChanging = false;
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
