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

  @override
  void initState() {
    super.initState();
    // clone
    _shuffledCards = GameCard.allCards.map((card) => card).toList();
    _shuffledCards.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                child: buildImageWidget()),
            Positioned(
              right: 50,
              child: SwipeDetector(
                  onDoubleTap: () => displayFontOfBackCard(),
                  onSwipe: (move) {
                    if (move.move == Move.LEFT) {
                      nextCard();
                      displayFontOfBackCard();
                    } else if (move.move == Move.RIGHT) {
                      previousCard();
                      displayFontOfBackCard();
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
                  onDoubleTap: () => displayFontOfBackCard(),
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
        ));
  }

  Widget buildImageWidget() {
    if (_isDisplayBackCard) {
      return Image(
          image: _shuffledCards[_currentCardIndex].getBackAssetImage());
    } else {
      return Image(image: _shuffledCards[_currentCardIndex].getAssetImage());
    }
  }

  void displayBackAssociatedCard() {
    final GameCard.Card cardToSwitch = _shuffledCards[_currentCardIndex];
    final int associatedCardIndexFromDeck = _shuffledCards.indexWhere((card) =>
        card.getName() ==
        _shuffledCards[_currentCardIndex - 1].getAssociatedCard().getName());

    setState(() {
      _shuffledCards[_currentCardIndex] =
          _shuffledCards[associatedCardIndexFromDeck];
      _shuffledCards[associatedCardIndexFromDeck] = cardToSwitch;
      _isDisplayBackCard = true;
    });
  }

  void displayFontOfBackCard() {
    setState(() {
      _isDisplayBackCard = false;
    });
  }

  void nextCard() {
    if (_currentCardIndex == GameCard.allCards.length - 1) {
      return;
    }

    setState(() {
      _currentCardIndex++;
    });
  }

  void previousCard() {
    if (_currentCardIndex == 0) {
      return;
    }

    setState(() {
      _currentCardIndex--;
    });
  }
}
