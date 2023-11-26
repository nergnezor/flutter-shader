import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'balls.dart';
import 'boundaries.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: MouseJointExample.new));
}

class MouseJointExample extends Forge2DGame {
  MouseJointExample()
      : super(gravity: Vector2(0, 10.0), world: MouseJointWorld());
}

class MouseJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame> {
  late final FragmentProgram program;
  late final FragmentShader shader;
  double time = 0;
  late List<Ball> balls;
  late Ball ball;
  late Body groundBody;
  MouseJoint? mouseJoint;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);

    final center = Vector2.zero();
    groundBody = createBody(BodyDef());
    ball = Ball(center, radius: 5);
    add(ball);
    add(Ball(center + Vector2(0, -10), radius: 5));

    game.camera.viewport.add(FpsTextComponent());

    program = await FragmentProgram.fromAsset('shaders/bg.frag');
    shader = program.fragmentShader();
  }

  @override
  void onDragStart(DragStartEvent info) {
    super.onDragStart(info);
    final mouseJointDef = MouseJointDef()
      ..maxForce = 3000 * ball.body.mass * 10
      ..dampingRatio = 0.1
      ..frequencyHz = 5
      ..target.setFrom(ball.body.position)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = ball.body;

    if (mouseJoint == null) {
      mouseJoint = MouseJoint(mouseJointDef);
      createJoint(mouseJoint!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {
    mouseJoint?.setTarget(info.localPosition);
  }

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    destroyJoint(mouseJoint!);
    mouseJoint = null;
  }

  @override
  void render(Canvas canvas) {
    final scale = game.camera.viewfinder.scale.x;
    var rect = game.camera.visibleWorldRect;
    rect = Rect.fromLTWH(
      rect.left * scale + 180,
      rect.top * scale,
      rect.width * scale,
      rect.height * scale,
    );
    shader
      ..setFloat(0, 40)
      ..setFloat(1, 40)
      ..setFloat(2, time);

    canvas.drawRect(rect, Paint()..shader = shader);
    // super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }
}
