import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: const ShaderPage(),
    ),
  );
}

class ShaderPage extends StatefulWidget {
  const ShaderPage({super.key});

  @override
  State<ShaderPage> createState() => _ShaderPageState();
}

class _ShaderPageState extends State<ShaderPage> {
  final game = Shader();

  @override
  void dispose() {
    game.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shader'),
      ),
      body: GameWidget(game: game),
    );
  }
}

class Shader extends Game with MouseMovementDetector, MultiTouchDragDetector {
  late final FragmentProgram _program;
  late final FragmentShader shader;

  double time = 0;
  Vector2 mouse = Vector2.zero();
  double radius = 100;
  Vector2 speed = Vector2.zero();

  // Get pointer input
  @override
  void onMouseMove(PointerHoverInfo info) {
    mouse = info.eventPosition.widget;
  }

  // Get touch input
  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    mouse = info.eventPosition.widget;
  }

  void dispose() {
    shader.dispose();
  }

  @override
  Future<void>? onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
  }

  @override
  void render(Canvas canvas) {
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time)
      ..setFloat(3, radius);
    Vector2 circle = mouse - size / 2;
    // Limit position to always show full sphere
    circle.x = circle.x.clamp(-size.x / 2 + radius, size.x / 2 - radius);
    circle.y = circle.y.clamp(-size.y / 2 + radius, size.y / 2 - radius);

    canvas
      ..translate(circle.x, circle.y)
      ..drawRect(
        Offset.zero & size.toSize(),
        Paint()..shader = shader,
      );
  }

  @override
  void update(double dt) {
    time += dt;
  }
}
