import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ball.dart';

class Flipper extends BodyComponent with ContactCallbacks {
  final int index;
  Flipper(
    this.index,
  ) {}

  late final Vector2 _position;
  static const FlipperMaxAngle = 52.0;
  static const FlipperLength = 7.1;
  static const RubberThickness = 0.4;
  final speed = 5.0;
  double scale = 1.0;

  void activate() {
    bool left = index == 0;
    body.angularVelocity = left ? -speed : speed;
  }

  void returnFlipper() {
    body.angularVelocity = body.angle > 0 ? -speed : speed;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final size = game.camera.visibleWorldRect.size;
    final y = size.height / 2 * 0.6;
    var x = size.width / 2 * 0.95;
    if (index == 0) {
      x *= -1;
    }
    _position = Vector2(x, y);
    // _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    // shader = _program.fragmentShader();
  }

  @override
  Body createBody() {
    final shape = EdgeShape();
    final flipperShape = getFlipperShape(index);
    shape.set(flipperShape[0], flipperShape[1]);
    // shape.radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.5,
      friction: 0.5,
    );

    final bodyDef = BodyDef(
      userData: this,
      // angularDamping: 0.8,
      position: _position,
      type: BodyType.kinematic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void renderEdge(Canvas canvas, Offset start, Offset end) {
    // shader
    // ..setFloat(0, time)
    // ..setFloat(1, radius);
    // ..setFloat(2, speed.x)
    // ..setFloat(3, speed.y);

    canvas
      ..drawLine(
        start,
        end,
        // Paint()..shader = shader,
        Paint()
          ..color = Color.fromARGB(255, 244, 241, 54)
          ..strokeWidth = RubberThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
  }

  @override
  void update(double dt) {
    super.update(dt);
// 60 x 0.8 = 48
    var maxAngle = degrees2Radians * FlipperMaxAngle;
    var minAngle = 0.0;
    if (index == 0) {
      minAngle = -maxAngle;
      maxAngle = 0;
    }
    if (body.angle > maxAngle || body.angle < minAngle) {
      body.setTransform(body.position, body.angle.clamp(minAngle, maxAngle));
      body.angularVelocity = 0;
    }
    // if (scale < 1) {
    //   setScale(1.001);
    // }
  }

  // @override
  // void beginContact(Object other, Contact contact) {
  //   if (other is Ball && other.isFirstBall) return;
  //   // Decrease the length of the flipper
  //   setScale(0.9);
  // }

  // void setScale(double s) {
  //   scale = scale * s;
  //   const maxScale = 1.0;
  //   const minScale = 0.1;
  //   if (scale > maxScale || scale < minScale) {
  //     scale = scale.clamp(0.1, 1.0);
  //     return;
  //   }

  //   final shape = body.fixtures.first.shape as EdgeShape;
  //   // final newLength = FlipperLength * scale;
  //   shape.set(shape.vertex1, shape.vertex2..scale(s));
  // }

  getFlipperShape(int index) {
    final isRight = index == 1;
    final length = FlipperLength;
    var angle = pi / 6; // 90 + 30 = 120 degrees
    var x = length * cos(angle);
    if (isRight) {
      x = -x;
    }
    final y = length * sin(angle);
    final Vector2 start = Vector2.zero();
    final Vector2 end = Vector2(x, y);
    return [start, end];
  }
}
