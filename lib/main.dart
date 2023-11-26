import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';

import 'player.dart';
import 'wall.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: Forge2DExample.new));
}

class Forge2DExample extends Forge2DGame
    with MultiTouchDragDetector, MouseMovementDetector {
  late final FragmentProgram program;
  late final FragmentShader shader;
  double time = 0;
  late List<Ball> balls;

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewport.add(FpsTextComponent());
    // camera.viewfinder.zoom = 1;
    balls = List.generate(3, (index) => Ball());
    world.addAll(balls);
    world.addAll(createBoundaries(camera.visibleWorldRect));
    program = await FragmentProgram.fromAsset('shaders/bg.frag');
    shader = program.fragmentShader();
  }

  @override
  void render(Canvas canvas) {
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas.drawRect(Offset.zero & size.toSize(), Paint()..shader = shader);
    super.render(canvas);
  }

  void onMouseMove(PointerHoverInfo info) {
    updateMousePosition(info.eventPosition.widget);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    updateMousePosition(info.eventPosition.widget, pointerId);
  }

  void updateMousePosition(Vector2 position, [int pointerId = 0]) {
    var localLocation = position - size / 2;
    localLocation /= camera.viewfinder.zoom;
    final direction = localLocation - balls[pointerId].position;
    final distance = direction.length;

    balls[pointerId].body.applyLinearImpulse(direction * pow(distance / 4, 2).toDouble());
  }
}
