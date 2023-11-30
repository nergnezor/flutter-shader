import 'dart:math';
import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'boundaries.dart';
import 'flipper.dart';

class Ball extends BodyComponent with ContactCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;
  static const PinballDiameter = 2.7; // (cm) = 27mm
  final double radius = PinballDiameter / 2;
  final bool isFirstBall;

  Ball({this.isFirstBall = false}) {}

  void resetBall() {
    body.linearVelocity = Vector2.zero();
    body.setTransform(
        Vector2(30 * (Random().nextDouble() - 0.5),
            game.camera.visibleWorldRect.top * 1.1),
        0);

    // Add random force to the ball
    Future.delayed(Duration(milliseconds: 1000), () {});
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final shaderName = isFirstBall ? 'player' : 'enemy';
    _program = await FragmentProgram.fromAsset('shaders/$shaderName.frag');
    shader = _program.fragmentShader();
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.1,
      friction: 0.2,
    );

    final bodyDef = BodyDef(
      userData: this,
      gravityOverride: isFirstBall ? null : Vector2(0, 10),
      position: Vector2(0, game.camera.visibleWorldRect.top * 0.8),
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
      ..setFloat(3, body.linearVelocity.y);

    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()..shader = shader,
      );

    // Draw a line on the ball to show its direction
    final lineLength = radius * 2;
    final lineStart = Offset(0, 0);
    final lineEnd = Offset(radius, 0);
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
    if (body.position.y > game.camera.visibleWorldRect.bottom) {
// Add some delay before resetting the ball
      Future.delayed(Duration(milliseconds: 1), () {
        if (isFirstBall) {
          resetBall();
        } else {
          world.remove(this);
        }
      });
    }
  }

  static const explodeForce = 10000;
  @override
  void beginContact(Object other, Contact contact) {
// Calculate impulse (force) on the ball
    final speeds = [contact.bodyA.linearVelocity, contact.bodyB.linearVelocity];
    final masses = [contact.bodyA.mass, contact.bodyB.mass];
    final force = speeds[0] * masses[0] + speeds[1] * masses[1];
    if (other is Wall) {
      other.paint.color = Colors.red;
    }

    if (other is Ball) {
      if (force.length > explodeForce) {
        // Explode the ball
        Future.delayed(Duration(milliseconds: 1), () {
          world.remove(this);
        });
      }
    }
  }
}
