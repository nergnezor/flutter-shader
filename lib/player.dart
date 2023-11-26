import 'dart:math';
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';

class Ball extends BodyComponent {
  Ball({Vector2? initialPosition})
      : super(
          fixtureDefs: [
            FixtureDef(
              CircleShape()..radius = 5,
              restitution: 0.8,
              friction: 0.4,
            ),
          ],
          bodyDef: BodyDef(
            angularDamping: 0.8,
            position: initialPosition ?? Vector2.zero(),
            type: BodyType.dynamic,
          ),
        );
  late final FragmentProgram _program;
  late final FragmentShader shader;
  double time = 0;
  // double radius = 5;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  static const int padding = 2;

  @override
  void render(Canvas canvas) {
    final radius = fixtureDefs!.first.shape.radius;
    shader
      ..setFloat(0, time)
      ..setFloat(1, radius)
      ..setFloat(2, speed.x)
      ..setFloat(3, speed.y);

    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()..shader = shader,
      );
  }

  @override
  Future onLoad() async {
    super.onLoad();
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    fixtureDefs!.first.shape.radius = pow(2 + 0.5 * (1 + cos(time + pi)) / 2, 3).toDouble();
    // fixtureDefs.
    // radius -= speed.length / 200;
    // radius = radius.clamp(20, 100);
  }
}
