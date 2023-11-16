import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:simple_shader/ball.dart';

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
    // game.dispose();
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
  late final Ball ball;

  double time = 0;

  @override
  void update(double dt) {
    time += dt;
    ball.time = time;
    ball.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    ball.render(canvas);
    canvas.restore();
  }

  @override
  Future<void> onLoad() async {
    ball = Ball();
    await ball.onLoad();
  }
}
