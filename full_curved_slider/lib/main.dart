import 'package:flutter/material.dart';
import 'dart:ui';
import "dart:math";
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double score = 0;
  String level = "";
  List<double> percentDists = [];
  Map levels = {
    10: "Scrub",
    20: "Grub",
    30: "Gremlin",
    40: "Journeyman",
    50: "Nike Golf Sales Representative",
    60: "Nike Golf Floor Manager",
    70: "Putting Sage",
    80: "Golfball Sorcerer",
    90: "Lizard Man",
    100: "Wii Sports Announcer"
  };
  void setLevel() {
    for (int i in levels.keys) {
      if (score <= i) {
        level = levels[i];
        break;
      }
    }
  }
  void onActive() {
    setState(() {

    });
  }
  void onInactive() {
    setState(() {
    });
  }
  void onChange(List<double> percentages) {
    setState(() {
      percentDists = percentages;
    });
  }
  void onScore() {
    setState(() {
      ++score;
      setLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: Colors.lightGreen,
          body: Column (
              children: [
                GolfHeader(
                  header: "Let's play some SUBPAR GOLF!",
                  percentDists: percentDists,
                  level: level,
                  score: score
                ),
                CurvedSlider(
                  onActive: onActive,
                  onChanged: onChange,
                  onInactive: onInactive,
                  onScore: onScore,
                  thumbCount: 1,
                  ellipseHeight: 400,
                  ellipseWidth: 300,
                  widgetHeight: 450,
                )
              ]
          )
      ),
    );
  }
}
class GolfHeader extends StatelessWidget {
  final double score;
  final List<double> percentDists;
  final String level;
  final String header;
  const GolfHeader({Key key, this.score, this.percentDists, this.level, this.header}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String percents = "";
    for (double i in percentDists) {
      percents += i.toStringAsFixed(0) + "% ";
    }

    return Container(
        width: double.infinity,
        height: 230,
          child: Padding(
            padding: EdgeInsets.all(30),
              child: Column (
                children: [
                  Text (
                    header,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white
                    ),
                  ),
                  Text(
                    "Distance to goal: " + percents,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white

                    )
                  ),
                  Text(
                    "Score: " + score.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white
                      )
                  ),
                  Text(
                      "Level: " + level,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white

                      )
                  ),
                ]
            )
          )
    );
  }

}

class CurvedSlider extends StatefulWidget {
  final Function onChanged;
  final Function onActive;
  final Function onInactive;
  final Function onScore;
  final double radius;
  final double thumbCount;
  final double ellipseWidth;
  final double ellipseHeight;
  final double widgetHeight;

  const CurvedSlider({Key key, this.onChanged, this.onActive, this.onInactive, this.radius, this.thumbCount, this.ellipseWidth, this.ellipseHeight, this.widgetHeight, this.onScore}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CurvedSliderState(thumbCount, ellipseWidth, ellipseHeight, widgetHeight);
}

class _CurvedSliderState extends State<CurvedSlider> {
  List<List<double>> thumbPositions = [];
  List<double> holeCoordinates;
  double fingerX = 0;
  double fingerY = 0;
  double startTheta = .25;
  List<double> distancePercentages = [];

  _CurvedSliderState(double thumbCount, double ellipseWidth, double ellipseHeight, double widgetHeight) {
    for (int i = 0; i < thumbCount; ++i ) {
      thumbPositions.add(screenCoordinatesFromTheta(startTheta, ellipseWidth, ellipseHeight, widgetHeight));
      distancePercentages.add(startTheta * 100);
      //thumbPositions.add([ellipseWidth, widgetHeight]); //FIXME
    }
    holeCoordinates = screenCoordinatesFromTheta(1.5, ellipseWidth, ellipseHeight, widgetHeight);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.widgetHeight,
      color: Colors.lightGreen,
      //-----OVERRIDING THE LISTENER-----//
      child: Listener(
          onPointerDown: _fingerDown,
          onPointerMove: _fingerMove,
          onPointerUp: _fingerUp,

          child: CustomPaint (
            painter: SliderPainter(thumbPositions, widget.ellipseHeight, widget.ellipseWidth, fingerX, fingerY, holeCoordinates),
          )
      ),
    );
  }

  void _updateLocation(PointerEvent details) {
    fingerX = details.localPosition.dx;
    fingerY = details.localPosition.dy;
  }

  void updateDistance() {
    for (int i = 0; i < thumbPositions.length; ++i) {
      double thumbRadians = screenCoordinatesToTheta(thumbPositions[i], widget.widgetHeight);
      distancePercentages[i] = (thumbRadians/1.5) * 100;
    }
  }

  void _processFingerInput() {
    setState(() {
      int cIndex = collisionIndex();
      if (cIndex != null) {
        double theta = screenCoordinatesToTheta([fingerX, fingerY], widget.widgetHeight);
        double radius = getRadius(theta, widget.ellipseWidth, widget.ellipseHeight);
        thumbPositions[cIndex] = sliderCoordinatesToScreenCoordinates(radiusThetaToSliderCoordinates(radius, theta), widget.widgetHeight);
      }
      int goalIndex = checkGoal();
      if (goalIndex != null) {
        thumbPositions[cIndex] = screenCoordinatesFromTheta(startTheta, widget.ellipseWidth, widget.ellipseHeight, widget.widgetHeight);
        widget.onScore();
      }
      updateDistance();
    });

  }

  int checkGoal() {
    for (int i = 0; i < thumbPositions.length; ++i) {
      if (thumbPositions[i][0] - holeCoordinates[0] <= 10 && thumbPositions[i][1] - holeCoordinates[1] <= 10) {
        return i;
      }
    }
    return null;
  }

  int collisionIndex() {
    for (int i = 0; i < thumbPositions.length; ++i) {
      if (fingerX - thumbPositions[i][0] <= 100 && fingerY - thumbPositions[i][1] <= 100) {
        return i;
      }
    }
    return null;
  }

  void _fingerDown(PointerEvent details) {
    _updateLocation(details);
    _processFingerInput();
    if (widget.onActive != null) widget.onActive();
  }

  void _fingerMove(PointerEvent details) {
    _updateLocation(details);
    _processFingerInput();
    if (widget.onChanged != null) widget.onChanged(distancePercentages);
  }

  void _fingerUp(PointerUpEvent details) {
    if (widget.onInactive != null) widget.onInactive();
  }
}

List<double> radiusThetaToSliderCoordinates(double radius, double theta) {
  return [radius * cos(theta), radius * sin(theta)];
}
List<double> screenCoordinatesToSliderCoordinates(List<double> screenCoordinates, double height) {
  return [screenCoordinates[0], height - screenCoordinates[1]];
}
List<double> sliderCoordinatesToScreenCoordinates(List<double> sliderCoordinates, double height) {
  return [sliderCoordinates[0], height - sliderCoordinates[1]];
}
double getRadius(double theta, double width, double height) {
  return (width * height) / sqrt((pow(width, 2) * pow(sin(theta), 2)) + (pow(height, 2) * pow(cos(theta), 2)));
}
double coordinatesToRadians(List<double> coordinates) {
  return atan(coordinates[1]/coordinates[0]);
}
List<double> screenCoordinatesFromTheta(double theta, ellipseWidth, ellipseHeight, widgetHeight) {
  return sliderCoordinatesToScreenCoordinates(radiusThetaToSliderCoordinates(getRadius(theta, ellipseWidth, ellipseHeight), theta), widgetHeight);
}

double screenCoordinatesToTheta(List<double> coordinates, double widgetHeight) {
  return coordinatesToRadians(screenCoordinatesToSliderCoordinates([coordinates[0], coordinates[1]], widgetHeight));
}

//-----PAINTER WIDGET-----//
class SliderPainter extends CustomPainter {
  double ellipseWidth = 200;
  double ellipseHeight = 100;
  List<List<double>> thumbPositions;
  List<double> holeCoordinates;
  double radius = 20;
  double fingerX = 0;
  double fingerY = 0;

  @override
  void paint(Canvas canvas, Size size) {
    Paint golfGreen = Paint()
      ..color = Colors.lightGreen[200]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 200;

    Paint ball = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    Paint hole = Paint()
      ..color = Colors.brown[700]
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    // Method to convert degree to radians
    num degToRad(num deg) => deg * (pi / 180.0);

    Path path = Path();
    path.moveTo(- ellipseWidth, 0);
    Rect r = Rect.fromLTWH(- ellipseWidth, size.height - ellipseHeight, ellipseWidth * 2 , ellipseHeight *2);

    path.arcTo(r, degToRad(0), degToRad(-180), true);
    canvas.drawPath(path, golfGreen);

    canvas.drawOval(Rect.fromPoints(Offset(holeCoordinates[0], holeCoordinates[1] - 5), Offset(holeCoordinates[0] + 30, holeCoordinates[1] + 15)), hole);

    for (List<double> pos in thumbPositions) {
      canvas.drawCircle(Offset(pos[0], pos[1]), 10, ball);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  SliderPainter(List<List<double>> thumbPos, double ellipseH, double ellipseW, double fingerX, double fingerY, List<double> holeCoordinates) {
    thumbPositions = thumbPos;
    ellipseHeight = ellipseH;
    ellipseWidth = ellipseW;
    this.fingerX = fingerX;
    this.fingerY = fingerY;
    this.holeCoordinates = holeCoordinates;
  }

}


/*
TO DO:
Draw a pretty background
Create header
Document and tidy code

Extra points:
interpolating thumb position
support for multiple thumbs
different sizes and aspect ratios
something interesting


 */