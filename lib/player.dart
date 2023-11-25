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
  static const int padding = 20;
  bool touching = false;

  late final CircleHitbox circleHitbox;

  Player(int i) {
    position = Vector2.all(i.toDouble());
    size = Vector2.all(200);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      speed *= -1;
      // if (speed.length < 10) {
      //   // Pull towards the center
      //   speed += (Vector2.zero() - position) * 1;
      // }
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

    add(circleHitbox = CircleHitbox(
      position: Vector2.all(radius),
      radius: radius,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (touching) {
      touching = false;
    }

    shader
      ..setFloat(0, time)
      ..setFloat(1, radius)
      ..setFloat(2, speed.x)
      ..setFloat(3, speed.y);

    canvas
      ..drawRect(
        Rect.fromCircle(center: Offset.zero, radius: radius + padding),
        Paint()..shader = shader,
      );
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    if (move != Vector2.zero()) {
      speed = speed * 0.5 + move / dt * 0.5;
      move = Vector2.zero();
    } else {
      speed = speed * 0.95;
    }

    radius = pow(4 + 1 * (1 + cos(time + pi)) / 2, 3).toDouble();
    radius -= speed.length / 200;
    radius = radius.clamp(20, 100);
    circleHitbox.radius = radius;
    // Update position
    position += speed * dt;
  }
}
