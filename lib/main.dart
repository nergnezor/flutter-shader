import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'flipper.dart';

import 'ball.dart';
import 'boundaries.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: MouseJointExample.new));
}

class MouseJointExample extends Forge2DGame {
  MouseJointExample()
      : super(world: MouseJointWorld(), gravity: Vector2(0, 20));
}

class MouseJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame> {
  late final FragmentProgram program;
  late final FragmentShader shader;
  double time = 0;
  late Ball ball;
  List<Flipper> flippers = List.generate(2, (index) => Flipper(index));
  Flipper? activeFlipper;

  @override
  Future<void> onLoad() async {
    // ..setFloat(0, time)
    game.camera.viewfinder.visibleGameSize = Vector2.all(20);
    super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);

    final center = Vector2.zero();
    ball = Ball(center);
    add(ball);
    addAll(flippers);

    game.camera.viewport.add(FpsTextComponent());

    program = await FragmentProgram.fromAsset('shaders/bg.frag');
    shader = program.fragmentShader();
  }

  @override
  void onDragStart(DragStartEvent info) {
    super.onDragStart(info);

    // Choose flipper by side of the screen touched
    final left = info.localPosition.x < 0;
    final flipper = flippers[left ? 0 : 1];
    flipper.body.angularVelocity = left ? -10 : 10;
    activeFlipper = flipper;
    // Set a timer to stop the flipper
    Future.delayed(Duration(milliseconds: 100), () {
      flipper.body.angularVelocity = 0;
    });
  }

  void returnFlipper(Flipper flipper) {
    // Reset the flipper to its original position over time until the angle is 0
    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 10));
      if (flipper.body.angle.abs() < 0.01) {
        flipper.body.setTransform(flipper.body.position, 0);
        return false;
      }
      flipper.body
          .setTransform(flipper.body.position, flipper.body.angle * 0.6);
      return true;
    });
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {}

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    returnFlipper(activeFlipper!);
  }

  @override
  void render(Canvas canvas) {
    final scale = game.camera.viewfinder.scale.x;
    var rect = game.camera.visibleWorldRect;

    shader
      ..setFloat(0, rect.width)
      ..setFloat(1, rect.height)
      ..setFloat(2, time);

    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    if (ball.body.position.y > game.camera.visibleWorldRect.bottom) {
// Add some delay before resetting the ball
      Future.delayed(Duration(milliseconds: 1000), () {
        resetBall();
      });
    }
  }

  void resetBall() {
    ball.body.linearVelocity = Vector2.zero();
    ball.body.setTransform(Vector2(0,game.camera.visibleWorldRect.top * 0.8), 0);

    // Add random force to the ball
    Future.delayed(Duration(milliseconds: 1000), () {
      addRandomForce();
    });
  }

  void addRandomForce() {
    final force = Vector2(5 * (Random().nextDouble() - 0.5), 0);
    ball.body.applyLinearImpulse(force);
  }
}
