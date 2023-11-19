import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
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

class Shader extends FlameGame
    with MouseMovementDetector, MultiTouchDragDetector {
  late final FragmentProgram _program;
  late final FragmentProgram _program2;
  late final FragmentShader shader;
  late final FragmentShader bgShader;

  double time = 0;
  double radius = 100;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  PositionComponent pos = PositionComponent();

  // Get pointer input
  @override
  void onMouseMove(PointerHoverInfo info) {
    updateMousePosition(info.eventPosition.widget);
  }

  void updateMousePosition(Vector2 position) {
    move = position - pos.position;
    // time = 0;
    speed = Vector2.zero();
  }

  // Get touch input
  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    updateMousePosition(info.eventPosition.widget);
  }

  void dispose() {
    shader.dispose();
  }

  @override
  Future<void>? onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
    _program2 = await FragmentProgram.fromAsset('shaders/bg.frag');
    bgShader = _program2.fragmentShader();
    pos.position = Vector2.zero();
    add(pos);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Vector2 circle = pos.position;
    // -size / 2;
    // Clamp to screen and change speed direction if needed
    if (circle.x < 0 || circle.x > size.x) {
      speed.x *= -1;
    }
    if (circle.y < 0 || circle.y > size.y) {
      speed.y *= -1;
    }
    circle.x = circle.x.clamp(0, size.x);
    circle.y = circle.y.clamp(0, size.y);

    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time)
      ..setFloat(3, circle.x)
      ..setFloat(4, circle.y)
      ..setFloat(5, radius)
      ..setFloat(6, speed.x)
      ..setFloat(7, speed.y);

    bgShader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas.drawRect(Offset.zero & size.toSize(), Paint()..shader = bgShader);

    canvas
      // ..translate(circle.x, circle.y)
      ..drawRect(
        Rect.fromCircle(center: circle.toOffset(), radius: radius + 100),
        // Vector2.all(100).toOffset() & Vector2.all(400).toSize(),
        Paint()..shader = shader,
      );
    shader
      // ..setFloat(3, circle.x)
      // ..setFloat(4, circle.y)
      ..setFloat(5, radius * 0.5);

    canvas
      ..translate(circle.x + 2, circle.y)
      ..drawRect(
        Rect.fromCircle(center: circle.toOffset(), radius: radius / 2 + 100),
        Paint()..shader = shader,
      );
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    var current_speed = Vector2.zero();
    if (move != Vector2.zero()) {
      current_speed = move / dt;
      move = Vector2.zero();
    }
    speed = speed * 0.98 + current_speed * 0.1;

    radius = pow(4 + 1 * (1 + cos(time + pi)) / 2, 3).toDouble();
    radius -= speed.length / 20;
    radius = radius.clamp(20, 100);
    // Update position
    pos.position += speed * dt * 3;
  }
}
