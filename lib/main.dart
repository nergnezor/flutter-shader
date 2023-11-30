import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/services.dart';
import 'flipper.dart';

import 'ball.dart';
import 'boundaries.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: MouseJointExample.new));
}

class MouseJointExample extends Forge2DGame {
  MouseJointExample()
      : super(world: MouseJointWorld(), gravity: Vector2(0, 80));
}

class MouseJointWorld extends Forge2DWorld
    with DragCallbacks, HasGameReference<Forge2DGame>, KeyboardHandler {
  late final FragmentProgram program;
  late final FragmentShader shader;
  double time = 0;
  double lastCreateBallTime = 0;
  late Ball ball;
  List<Flipper> flippers = List.generate(2, (index) => Flipper(index));
  List<Flipper> activeFlippers = [];
  PositionComponent camera = PositionComponent();

// Check keyboard input from KeyboardHandler
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keys) {
    // Check left/right arrow keys
    if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      flippers[0].activate();
      return true;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      flippers[1].activate();
      return true;
    }
    return false;
  }

  @override
  Future<void> onLoad() async {
    // ..setFloat(0, time)
    game.camera.viewfinder.visibleGameSize = Vector2.all(20);
    super.onLoad();
    final boundaries = createBoundaries(game);
    addAll(boundaries);

    ball = Ball(isFirstBall: true);
    add(ball);
    addAll(flippers);
    game.camera.viewport.add(FpsTextComponent());
    game.camera.viewport.add(ball.lifeText);

    program = await FragmentProgram.fromAsset('shaders/bg.frag');
    shader = program.fragmentShader();

    game.camera.follow(camera, verticalOnly: true, snap: false, maxSpeed: 300);
  }

  @override
  void onDragStart(DragStartEvent info) {
    super.onDragStart(info);

    // Choose flipper by side of the screen touched
    final left = info.localPosition.x < 0;
    final flipper = flippers[left ? 0 : 1];
    flipper.activate();
    activeFlippers.add(flipper);
  }

  @override
  void onDragUpdate(DragUpdateEvent info) {}

  @override
  void onDragEnd(DragEndEvent info) {
    super.onDragEnd(info);
    if (activeFlippers.length == 2) {
      final id = info.pointerId % 2;
      activeFlippers[id].returnFlipper();
      activeFlippers.removeAt(id);
      return;
    }
    activeFlippers.first!.returnFlipper();
    activeFlippers.clear();
  }

  @override
  void render(Canvas canvas) {
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

// Move the camera up if the ball is at the top of the screen
    const cameraSpeed = 2;
    final screenYOffset =
        -ball.body.position.y - game.camera.visibleWorldRect.height / 2;

    if (screenYOffset > 0) {
      camera.y -= screenYOffset * 2;
      camera.y = max(camera.y,
          ball.body.position.y + game.camera.visibleWorldRect.height / 2);
    } else if (camera.y < 0) {
      camera.y = 0;
    }

    if (time - lastCreateBallTime > 5.0) {
      lastCreateBallTime = time;
      add(Ball());
    }
  }
}
