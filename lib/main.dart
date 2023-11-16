import 'dart:async';
import 'dart:ui';

import 'package:flame/game.dart';
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

class Shader extends Game {
  late final FragmentProgram _program;
  late final FragmentShader shader;

  double time = 0;

  void dispose() {
    shader.dispose();
  }

  @override
  Future<void>? onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/simple.frag');
    shader = _program.fragmentShader();
  }

  @override
  void render(Canvas canvas) {
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas
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
