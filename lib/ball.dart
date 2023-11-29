import 'dart:ui';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'boundaries.dart';
import 'flipper.dart';

class Ball extends BodyComponent with ContactCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;
  final double radius;
  final Vector2 _position;

  Ball(
    this._position, 
    this.radius,
  ) {}

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.3,
      friction: 0.4,
    );

    final bodyDef = BodyDef(
      userData: this,
      angularDamping: 0.8,
      position: _position,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    shader
      // ..setFloat(0, time)
      ..setFloat(1, radius);
    // ..setFloat(2, speed.x)
    // ..setFloat(3, speed.y);

    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()..shader = shader,
      );
  }

  @override
  @mustCallSuper
  void update(double dt) {
    super.update(dt);
  }

  static const explodeForce = 10000;
  @override
  void beginContact(Object other, Contact contact) {
// Calculate impulse (force) on the ball
    final speeds = [contact.bodyA.linearVelocity, contact.bodyB.linearVelocity];
    final masses = [contact.bodyA.mass, contact.bodyB.mass];
    final force = speeds[0] * masses[0] + speeds[1] * masses[1];
    print(force.length);
    if (other is Wall) {
      other.paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 1;
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
