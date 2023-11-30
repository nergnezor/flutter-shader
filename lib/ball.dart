import 'dart:math';
import 'dart:ui';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'boundaries.dart';

class Ball extends BodyComponent with ContactCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;
  static const PinballDiameter = 2.7; // (cm) = 27mm
  static const EnemyBallDiameter = 8.0;
  late final double radius;
  final bool isFirstBall;
  double life = 1.0;

  Ball({this.isFirstBall = false}) {}

  void resetBall() {
    body.linearVelocity = Vector2.zero();
    body.setTransform(
        Vector2(30 * (Random().nextDouble() - 0.5),
            game.camera.visibleWorldRect.top * 1.0),
        0);

    // Add random force to the ball
    Future.delayed(Duration(milliseconds: 1000), () {});
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final shaderName = isFirstBall ? 'player' : 'enemy';
    radius = isFirstBall ? PinballDiameter / 2 : EnemyBallDiameter / 2;

    _program = await FragmentProgram.fromAsset('shaders/$shaderName.frag');
    shader = _program.fragmentShader();
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: isFirstBall ? 0.1 : 0.0,
      friction: 0.2,
      density: 1,
    );

    final bodyDef = BodyDef(
      userData: this,
      gravityOverride: isFirstBall ? Vector2(0, -1) : Vector2(0, 1),
      position: Vector2(0, game.camera.visibleWorldRect.top * 1.2),
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    shader
      ..setFloat(0, game.currentTime())
      ..setFloat(1, radius)
      ..setFloat(2, body.linearVelocity.x)
      ..setFloat(3, body.linearVelocity.y)
      ..setFloat(4, life);

    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()..shader = shader,
      );

    // Draw a line on the ball to show its direction
    final lineStart = Offset(0, 0);
    final lineEnd = Offset(radius*max(life,0), 0);
    canvas.drawLine(
        lineStart,
        lineEnd,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 0.1);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
    if (body.position.y > game.camera.visibleWorldRect.height / 2) {
// Add some delay before resetting the ball
      Future.delayed(Duration(milliseconds: 1), () {
        if (isFirstBall) {
          resetBall();
        } else {
          world.remove(this);
        }
      });
    }
    if (life < 0) {
      body.setActive(false);
      grow(dt*10);
    }
  }

  static const explodeForce = 1000;
  @override
  void beginContact(Object other, Contact contact) {
// Calculate impulse (force) on the ball
    final speeds = [contact.bodyA.linearVelocity, contact.bodyB.linearVelocity];
    final masses = [contact.bodyA.mass, contact.bodyB.mass];
    final force = speeds[0] * masses[0] + speeds[1] * masses[1];
    if (other is Wall) {
      other.paint.color = Colors.red;
      return;
    }

    if (!isFirstBall && other is Ball) {
      final lifeDrain = force.length / explodeForce;
      life -= lifeDrain;
      grow(lifeDrain);
      if (life < 0) {
        // First spin the ball
        body.applyAngularImpulse(100);
      }
    }
  }

  void grow(double amount) {
    final shape = body.fixtures.first.shape as CircleShape;
    final scale = 1 + amount;
    shape.radius = shape.radius * scale;
    const maxScale = 50;
    if (shape.radius > maxScale) {
      world.remove(this);
    }
  }
}
