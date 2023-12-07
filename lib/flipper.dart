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

  late Vector2 _position;
  static const FlipperMaxAngle = 52.0 * degrees2Radians;
  static const FlipperLength = 6.1;
  static const FlipperAngle = pi / 6; // 90 + 30 = 120 degrees
  static const RubberThickness = 0.4;
  final speed = 10.0;
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
    final y = (size.height / 2 - FlipperLength * sin(FlipperAngle)) * 0.95;
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
    canvas
      ..drawLine(
        start,
        end,
        // Paint()..shader = shader,
        Paint()
          ..color = Color.fromARGB(60, 0, 0, 0)
          ..strokeWidth = RubberThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

    canvas.drawArc(
      Rect.fromCenter(
        center: start,
        width: FlipperLength * 2,
        height: FlipperLength * 2,
      ),
      -body.angle - FlipperMaxAngle * -0.5 + index * pi + index * -0.12,
      pi / 4 * -1,
      false,
      Paint()
        ..color = Color.fromARGB(20, 0, 0, 0)
        ..strokeWidth = 0.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
// 60 x 0.8 = 48
    var maxAngle = FlipperMaxAngle;
    var minAngle = 0.0;
    if (index == 0) {
      minAngle = -maxAngle;
      maxAngle = 0;
    }
    if (body.angle > maxAngle || body.angle < minAngle) {
      body.setTransform(body.position, body.angle.clamp(minAngle, maxAngle));
      body.angularVelocity = 0;
    }
  }

  getFlipperShape(int index) {
    final isRight = index == 1;
    final length = FlipperLength;
    var x = length * cos(FlipperAngle);
    if (isRight) {
      x = -x;
    }
    final y = length * sin(FlipperAngle);
    final Vector2 start = Vector2.zero();
    final Vector2 end = Vector2(x, y);
    return [start, end];
  }

  reset() {
    world.destroyBody(body);
    onLoad();
  }
}
