import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Shader Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Simple Shader Demo'),
  //     ),
  //     body: ShaderBuilder(
  //       assetKey: 'shaders/simple.frag',
  //       (context, shader, child) => CustomPaint(
  //         size: MediaQuery.of(context).size,
  //         painter: ShaderPainter(
  //           shader: shader,
  //         ),
  //       ),
  //       child: const Center(
  //         child: CircularProgressIndicator(),
  //       ),
  //     ),
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  // Start timer when the widget is first built
  late Timer timer;
  double time = 0;

  @override
  Widget build(BuildContext context) {
    const refreshRate = 60;
    const delay = 1000 ~/ refreshRate;
    timer = Timer.periodic(const Duration(milliseconds: delay), (timer) {
      time += delay / 1000.0;
      setState(() {});
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Shader Demo'),
      ),
      body: ShaderBuilder(
        assetKey: 'shaders/simple.frag',
        (context, shader, child) => CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ShaderPainter(shader, time),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class ShaderPainter extends CustomPainter {
  ShaderPainter(this.shader, this.time);
  ui.FragmentShader shader;
  double time;

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    // final time = DateTime.now().millisecondsSinceEpoch / 1000;
    // print(sin(time));
    shader.setFloat(2, time);

    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ShaderPainter) {
      return oldDelegate.shader != shader || oldDelegate.time != time;
    }
    return false;
  }
}
