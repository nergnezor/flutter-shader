import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'boundaries.dart';
import 'flipper.dart';

class Ball extends BodyComponent with ContactCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;
  static const PinballDiameter = 2.7; // (cm) = 27mm
  static const EnemyBallDiameter = 6.0;
  late final double radius;
  final bool isFirstBall;
  static late final Ball first;
  int life = 100;
  double time = 0;
  Vector2 _position = Vector2(0, -20);
  Ball({this.isFirstBall = false}) {}

  void reset() {
    final oldBody = body;
    body = createBody();
    // world.remove(oldBody as BodyComponent);
    // Remove the old body from the world
    // world.remove(oldBody);
    // final shape = body.fixtures.first.shape as CircleShape;
    // shape.radius = radius;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final shaderName = isFirstBall ? 'player' : 'enemy';
    radius = isFirstBall ? PinballDiameter / 2 : EnemyBallDiameter / 2;

    _program = await FragmentProgram.fromAsset('shaders/$shaderName.frag');
    shader = _program.fragmentShader();

    _position.y = -game.camera.visibleWorldRect.height / 2 * 0.8;
    _position.x =
        isFirstBall ? -game.camera.visibleWorldRect.width / 2 * 0.8 : 0;

    if (isFirstBall) {
      first = this;
    }
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
      gravityOverride: isFirstBall ? null : Vector2(0, 1),
      position: _position,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    // print(sin(game.currentTime()));
    shader
      ..setFloat(0, time)
      ..setFloat(1, radius)
      ..setFloat(2, body.linearVelocity.x)
      ..setFloat(3, body.linearVelocity.y)
      ..setFloat(4, life / 100.0);

    canvas
      ..drawCircle(
        Offset.zero,
        max(radius, 1),
        Paint()..shader = shader,
      );
    // Draw a line on the ball to show its direction
    final lineStart = Offset(0, 0);
    final lineEnd = Offset(radius * max(life / 100, 0), 0);
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
    time += dt;
    if (body.position.y > game.camera.visibleWorldRect.height / 2) {
// Add some delay before resetting the ball
      Future.delayed(Duration(milliseconds: 1), () {
        if (isFirstBall) {
          life -= 10;
          // world.remove(lifeText);
          // world.add(lifeText);
          reset();
        } else {
          world.remove(this);
        }
      });
    }
    if (life <= 0) {
      // First spin the ball
      body.applyAngularImpulse(100);
      body.setActive(false);
      grow(dt * 10);
    }
  }

  static const explodeForce = 100;
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

    if (!isFirstBall && other is Ball && other.isFirstBall) {
      final lifeDrain = 10 * force.length / explodeForce;
      life -= lifeDrain.round();
      grow(lifeDrain / 100);
    }

    // Enemy - Flipper collision
    if (!isFirstBall && other is Flipper) {
      final lifeDrain = 10 * force.length / explodeForce;
      first.life -= max(lifeDrain.round(), 1);
      // life -= lifeDrain.round();
      // grow(lifeDrain / 100);
    }
    if (isFirstBall) {
      print(other);
    }
  }

  void grow(double amount) {
    final shape = body.fixtures.first.shape as CircleShape;
    final scale = 1 + amount;
    shape.radius = shape.radius * scale;
    const maxScale = 50;
    if (shape.radius > maxScale) {
      if (isFirstBall) {
        die();

        return;
      }
      world.remove(this);
    }
  }

  void die() {
    // Display a message
    final text = TextComponent(
      text: 'You died!',
      position: Vector2(0, 0),
      anchor: Anchor.center,
      textRenderer: TextPaint(
          style: TextStyle(
        color: Colors.red,
        fontSize: 4,
      )),
    );

    world.add(text);
    // Remove the text after 2 seconds
    life = 100;
    reset();
    Future.delayed(Duration(seconds: 2), () {
      world.remove(text);
    });
  }
}
