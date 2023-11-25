import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Player extends BodyComponent with CollisionCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;

  double time = 0;
  double radius = 100;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  static const int padding = 20;
  bool touching = false;

  final CircleHitbox circleHitbox = CircleHitbox(
    position: Vector2.all(100),
    radius: 100,
  );

  static BodyDef bdef = BodyDef(
    linearDamping: 0.9,
    angularDamping: 0.9,
    type: BodyType.dynamic,
    position: Vector2.all(100),
  );

  Player(int i, Forge2DWorld w) {
    bodyDef?.position = Vector2.all(i.toDouble());
    body = Body(
      BodyDef(
        position: Vector2.all(i.toDouble()),
        linearVelocity: Vector2.zero(),
        type: BodyType.dynamic,
      ),
      w.physicsWorld,
    );

    // position = Vector2.all(i.toDouble());
    // size = Vector2.all(200);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      intersectionPoints.forEach((element) {
        // if (element.x == 0 || element.x == gameRef.size.x) {
        //   speed.x *= -1;
        // }
        // if (element.y == 0 || element.y == gameRef.size.y) {
        //   speed.y *= -1;
        // }
      });
      return;
    }
    touching = true;
    final direction = other.position - position;
    // Bounce in the opposite direction
    speed -= direction * 10;
    // super.onCollision(intersectionPoints, other);
  }

  @override
  Future onLoad() async {
    super.onLoad();
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
    // radius = size.x / 2;

    add(circleHitbox);
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

    if (move.length > 20) {
      speed = speed * 0.5 + move / dt * 0.2;
      move = Vector2.zero();
    } else {
      speed = speed * 0.95;
    }

    radius = pow(4 + 1 * (1 + cos(time + pi)) / 2, 3).toDouble();
    radius -= speed.length / 200;
    radius = radius.clamp(20, 100);
    circleHitbox.radius = radius;
    // Update position
    // position += speed * dt;
    // Add force to body
    body.applyForce(-speed);
    // position.clamp(Vector2.all(radius), gameRef.size - Vector2.all(radius));
  }
}
