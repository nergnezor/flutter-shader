import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends PositionComponent with CollisionCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;

  double time = 0;
  late double radius;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  static const int padding = 10;
  bool touching = false;

  Player(int i) {
    position = Vector2.all(i.toDouble());
    size = Vector2.all(200);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      speed *= -1;
      if (speed.length < 10) {
        // Pull towards the center
        speed += (Vector2.zero() - position) * 1;
      }
      return;
    }
    touching = true;
    final direction = other.position - position;
    // Bounce in the opposite direction
    speed -= direction * 10;
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
    radius = size.x / 2;

    add(CircleHitbox(radius: size.x / 2, isSolid: true));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (touching) {
      // canvas.drawRect(
      //   Rect.fromCircle(center: Offset.zero, radius: radius + padding),
      //   Paint()..color = Color(0x88ff0000),
      // );
      touching = false;
    }

    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time)
      ..setFloat(3, 0)
      ..setFloat(4, 0)
      ..setFloat(5, radius)
      ..setFloat(6, speed.x)
      ..setFloat(7, speed.y);

    canvas
      // ..translate(circle.x, circle.y)
      ..drawRect(
        Rect.fromCircle(center: Offset.zero, radius: radius + padding),
        // Vector2.all(100).toOffset() & Vector2.all(400).toSize(),
        Paint()..shader = shader,
      );
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    if (move != Vector2.zero()) {
      speed = move / dt;
      move = Vector2.zero();
    } else {
      speed = speed * 0.95;
    }

    radius = pow(4 + 1 * (1 + cos(time + pi)) / 2, 3).toDouble();
    radius -= speed.length / 200;
    radius = radius.clamp(20, 100);
    // Update position
    position += speed * dt;
  }
}
