import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'
//     show debugDefaultTargetPlatformOverride;

import 'package:r_tree/r_tree.dart';
import 'package:uuid/uuid.dart';

Uuid uuid;

void main() {
  // debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  uuid = Uuid();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Network Graph',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Graph();
  }
}

class Node {
  String id;
  bool selected = false;

  double x, y;

  Node() {
    this.id = uuid.v4();
  }
}

class Edge {
  String srcId;
  String dstId;
}

void circle({ double x, double y, double radius, Canvas canvas, Color fill = Colors.lime, Color stroke }) {
    var paint = Paint();
    paint.color = fill;
    paint.style = PaintingStyle.fill;

    // draw circle
    canvas.drawCircle(Offset(x, y), radius, paint);

    // draw stroke
    paint = Paint();
      paint.color = stroke;
      paint.strokeWidth = 4;
      paint.style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, y), radius, paint);
}

void line({ double x, double y, double x2, double y2, Canvas canvas, Color stroke = Colors.orangeAccent }) {
    var paint = Paint();
    paint.color = stroke;
    paint.strokeWidth = 2;

    canvas.drawLine(Offset(x, y), Offset(x2, y2), paint);
}

class Graph extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GraphState();
}

class GraphState extends State<Graph> {
  RTree<String> rtree;

  List<Node> nodesList = [
    (Node()
      ..x = 40
      ..y = 30),
    (Node()
      ..x = 120
      ..y = 120),
    (Node()
      ..x = 30
      ..y = 240),
    (Node()
      ..x = 340
      ..y = 30),
  ];

  Map<String, Node> nodes = Map<String, Node>();
  List<Edge> edges;

  @override
  void initState() {
    super.initState();

    rtree = RTree<String>();

    nodesList.forEach((node) {
      rtree.insert(RTreeDatum<String>(Rectangle(node.x-15, node.y-15, 60, 60), node.id));
      nodes[node.id] = node;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        var results =
          rtree.search(Rectangle(details.localPosition.dx, details.localPosition.dy, 10, 10));

        setState(() {
          results.forEach((result) {
            nodes[result.value].selected = !nodes[result.value].selected;
          });
        });
      },
      child: CustomPaint(
        painter: GraphCanvas(nodes: nodes.values),
      ),
    );
  }
  
}

class GraphCanvas extends CustomPainter {
  Iterable<Node> nodes;
  GraphCanvas({ this.nodes });

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < nodes.length; i++) {
      var firstNode = nodes.elementAt(i);

      if (nodes.length >= i + 2) {
        var secondNode = nodes.elementAt(i+1);

        line(
          x: firstNode.x,
          y: firstNode.y,
          x2: secondNode.x,
          y2: secondNode.y,
          canvas: canvas,
        );
      }
    }

    nodes.forEach((node) =>
      circle(x: node.x, y: node.y, radius: 30, canvas: canvas, stroke: node.selected ? Colors.red : Colors.transparent));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}