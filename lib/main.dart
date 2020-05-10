import 'dart:io';

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
  bool _isDisplayBackCard = false;
  List<GameCard.Card> _shuffledCards = GameCard.allCards;
  bool _isRedMode = true;
  bool _cardIsChanging = true;

  @override
  void initState() {
    super.initState();
    // clone
    _shuffledCards = GameCard.allCards.map((card) => card).toList();
    _shuffledCards.shuffle();
    _shuffledCards = sortCards(_shuffledCards, _isRedMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: <Widget>[
            Text(widget.title),
            Text(_isRedMode ? '.' : '')
          ]),
        ),
        body: Center(
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
                          onDoubleTap: () => displayFrontOfBackCard(),
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
                          onDoubleTap: () => displayFrontOfBackCard(),
                          onSwipe: (move) {
                            if (move.move == Move.LEFT) {
                              nextCard();
                              displayBackAssociatedCard();
                            }
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            color: Colors.transparent,
                          )),
                    )
                  ],
                ))));
  }

  Widget buildImageWidget() {
    if (_isDisplayBackCard) {
      return Image(
          image: _shuffledCards[_currentCardIndex].getBackAssetImage());
    } else if (_currentCardIndex == 0 ||
        _currentCardIndex == GameCard.allCards.length - 1) {
      return Stack(
        children: <Widget>[
          Image(image: AssetImage('images/cards/yellow_back.png')),
          Positioned(
              top: 200,
              left: 100,
              child: Text('End of deck',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)))
        ],
      );
    } else {
      return AnimatedOpacity(
          opacity: _cardIsChanging ? 0 : 1,
          duration: Duration(milliseconds: 500),
          child:
              Image(image: _shuffledCards[_currentCardIndex].getAssetImage()));
    }
  }

  void displayBackAssociatedCard() {
    final index = _currentCardIndex - 1 <= 0 ? 0 : _currentCardIndex - 1;
    final GameCard.Card cardToSwitch = _shuffledCards[_currentCardIndex];
    final int associatedCardIndexFromDeck = _shuffledCards.indexWhere((card) =>
        card.getName() == _shuffledCards[index].getAssociatedCard().getName());

    setState(() {
      _shuffledCards[_currentCardIndex] =
          _shuffledCards[associatedCardIndexFromDeck];
      _shuffledCards[associatedCardIndexFromDeck] = cardToSwitch;
      _isDisplayBackCard = true;
    });
  }

  void displayFrontOfBackCard() {
    setState(() {
      _isDisplayBackCard = false;
    });
  }

  void nextCard() {
    if (_currentCardIndex == GameCard.allCards.length - 1 ||
        _isDisplayBackCard) {
      return;
    }

    setState(() {
      _cardIsChanging = true;
      _currentCardIndex++;
      _cardIsChanging = false;
    });
  }

  void previousCard() {
    if (_currentCardIndex == 0 || _isDisplayBackCard) {
      return;
    }

    setState(() {
      _cardIsChanging = true;
      _currentCardIndex--;
      _cardIsChanging = false;
    });
  }

  void toggleMode() {
    setState(() {
      _isRedMode = !_isRedMode;
      _shuffledCards = sortCards(_shuffledCards, _isRedMode);
      _currentCardIndex = 0;
    });
  }

  List<GameCard.Card> sortCards(List<GameCard.Card> cards, isRedMode) {
    List<GameCard.Card> sAndHCards = cards
        .where((card) =>
            card.color == GameCard.D_CARD || card.color == GameCard.S_CARD)
        .toList();

    List<GameCard.Card> hAndSCards = cards
        .where((card) =>
            card.color != GameCard.D_CARD && card.color != GameCard.S_CARD)
        .toList();

    if (isRedMode) {
      return new List.from(sAndHCards)..addAll(hAndSCards);
    } else {
      return new List.from(hAndSCards)..addAll(sAndHCards);
    }
  }
}
