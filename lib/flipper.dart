import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'ball.dart';

class Flipper extends BodyComponent with ContactCallbacks {
  final int index;
  Flipper(
    this.index,
  ) {}

  late final Vector2 _position;
  late final FragmentProgram _program;
  late final FragmentShader shader;

    void returnFlipper() {
    // Reset the flipper to its original position over time until the angle is 0
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      if (body.angle.abs() < 0.01) {
        body.setTransform(body.position, 0);
        return false;
      }
      body
          .setTransform(body.position, body.angle * 0.6);
      return true;
    });
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final size = game.camera.visibleWorldRect.size;
    final y = size.height/2*0.8;
    var x = size.width/2*0.9;
    if (index == 0) {
      x *= -1;
    }
    _position = Vector2(x, y);
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
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
      friction: 0.9,
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
          ..color = const Color.fromARGB(255, 136, 54, 244)
          ..strokeWidth = 0.4,
      );
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball) {}
  }
  
  getFlipperShape(int index) {
    final isRight = index == 1;
    final length = 8.0;
    var angle = pi/6; // 90 + 30 = 120 degrees
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
