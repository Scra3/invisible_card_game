import 'dart:async';
import 'package:flutter/material.dart';
import 'package:invisiblecardgame/card.dart' as GameCard;
import 'package:flip_card/flip_card.dart';
import 'package:invisiblecardgame/constants.dart';
import 'package:invisiblecardgame/deck_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:launch_review/launch_review.dart';

void main() => runApp(MyApp());

const double CARD_LEFT_RATIO = 0.4;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomePage(title: 'Deck'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AdmobInterstitial _interstitialAd;
  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey();
  bool _isLoadingAd = true;
  Timer _adTimer;

  List<GameCard.Card> _visibleCards;
  List<GameCard.Card> _invisibleCards;
  bool _isPairMode = true;
  bool _isStartedCardDisplayed = true;
  bool _isInvisibleCardRevealed = false;

  AnimationController _spinnerController;

  @override
  void initState() {
    super.initState();

    _spinnerController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _spinnerController.forward();

    setupStates(true);

    loadAd();
  }

  void loadAd() async {
    _interstitialAd = AdmobInterstitial(
      adUnitId: INTERSTITIAL_ID,
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) {
          _adTimer.cancel();
          setState(() {
            _isLoadingAd = false;
          });
        }
      },
    );

    _interstitialAd.load();

    _adTimer = Timer.periodic(Duration(milliseconds: 500), (Timer t) async {
      if (_isLoadingAd == true && await _interstitialAd.isLoaded) {
        _interstitialAd.show();
      }
    });
  }

  void setupStates(bool isPairMode) {
    DeckBuilder deckBuilder = DeckBuilder().forPairMode(isPairMode);
    setState(() {
      _isPairMode = isPairMode;
      _isStartedCardDisplayed = true;
      _isInvisibleCardRevealed = false;
      _invisibleCards = deckBuilder.getInvisibleCards();
      _visibleCards = deckBuilder.getVisibleCards();
      _visibleCards.shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Scaffold(
        key: _scaffoldState,
        appBar: AppBar(
          title: buildTitleWidget(),
        ),
        body: Center(
            child: Container(
          height: MediaQuery.of(context).size.height,
          width: cardWidth,
          child: _isLoadingAd
              ? buildLoadingWidget()
              : Stack(children: <Widget>[
                  ...generateDeckForElevationEffectWidget(cardWidth),
                  buildDeckWidget(cardWidth),
                  buildFlipCardWidget(cardWidth),
                  buildFirstCardToStartWidget(cardWidth),
                  buildActionButtonWidget(cardWidth, context),
                ]),
        )));
  }

  Widget buildLoadingWidget() {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_spinnerController),
      child: Image(
        image: AssetImage("images/splash_icon.png"),
      ),
    );
  }

  Widget buildTitleWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
        Widget>[
      Row(children: <Widget>[Text(widget.title), Text(_isPairMode ? '' : '.')]),
      IconButton(
        icon: Icon(Icons.help),
        onPressed: () {
          navigateToRulesWebsite();
        },
      ),
      RatingBar(
        initialRating: 3,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        unratedColor: Colors.amber.withAlpha(50),
        itemCount: 5,
        itemSize: 25.0,
        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {
          if (rating > 3) {
            LaunchReview.launch(androidAppId: APP_ID);
          }
        },
      )
    ]);
  }

  bool get isTrickEnded {
    return _isInvisibleCardRevealed || _isStartedCardDisplayed;
  }

  bool get isLastCard {
    return _visibleCards.length == 1;
  }

  Widget buildActionButtonWidget(double cardWidth, BuildContext context) {
    if (!isTrickEnded && !isLastCard) {
      return Container();
    }

    return Positioned(
        bottom: 5,
        width: cardWidth,
        child: RaisedButton(
            color: Theme.of(context).primaryColor,
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
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Text(
                        _isStartedCardDisplayed ? "Start" : "Retry",
                        style: TextStyle(fontSize: 20.0),
                      )),
                  Image(
                    image: AssetImage("images/app_icon.png"),
                    width: 25,
                  )
                ])));
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
            revealInvisibleCardIfTapedOnLeftSide(
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
                  setState(() {
                    _visibleCards = DeckBuilder.generatedNextVisibleCards(
                        _visibleCards, _invisibleCards);
                  });
                }
              }));
    }
  }

  List<Widget> generateDeckForElevationEffectWidget(double cardWidth) {
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

  void revealInvisibleCardIfTapedOnLeftSide(
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

  navigateToRulesWebsite() async {
    if (await canLaunch(RULES_URL)) {
      await launch(RULES_URL);
    } else {
      throw 'Could not launch $RULES_URL';
    }
  }
}
