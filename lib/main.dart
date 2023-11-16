import 'dart:async';
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

class Shader extends FlameGame with DragCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;
  late final Player player;

  double time = 0;
  Vector2 mouse = Vector2.zero();

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    mouse.setFrom(event.localPosition);
    print('onDragStart: ${event.localPosition}');
  }

  @override
  bool containsLocalPoint(Vector2 localPoint) {
    return true;
  }

  void dispose() {
    shader.dispose();
  }

  @override
  Future<void>? onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/simple.frag');
    shader = _program.fragmentShader();
    player = Player(Vector2.all(100), Vector2.all(300));
    add(player);
  }

  @override
  void render(Canvas canvas) {
    player.render(canvas);
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas
      ..translate(player.position.x, player.position.y)
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

class Player extends PositionComponent with DragCallbacks {
  Player(Vector2 position, Vector2 size)
      : super(position: position, size: size);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // super.onDragUpdate(event);
    position.add(event.delta);
    // update(dt);
    print('onDragUpdate: ${event.delta}');
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(position & size, Paint()..color = const Color(0xFF00FF00));
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  bool containsLocalPoint(Vector2 localPoint) {
    return true;
  }
}
