import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: Forge2DExample.new));
}

class Forge2DExample extends Forge2DGame
    with MultiTouchDragDetector, MouseMovementDetector {
  late final FragmentProgram _program2;
  late final FragmentShader bgShader;
  double time = 0;
  late Ball ball;

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
    ball = Ball();
    world.add(ball);
    world.add(Ball());
    world.addAll(createBoundaries());
    _program2 = await FragmentProgram.fromAsset('shaders/bg.frag');
    bgShader = _program2.fragmentShader();
  }

  List<Component> createBoundaries() {
    final visibleRect = camera.visibleWorldRect;
    final topLeft = visibleRect.topLeft.toVector2();
    final topRight = visibleRect.topRight.toVector2();
    final bottomRight = visibleRect.bottomRight.toVector2();
    final bottomLeft = visibleRect.bottomLeft.toVector2();

    return [
      Wall(topLeft, topRight),
      Wall(topRight, bottomRight),
      Wall(bottomLeft, bottomRight),
      Wall(topLeft, bottomLeft),
    ];
  }

  @override
  void render(Canvas canvas) {
    bgShader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas.drawRect(Offset.zero & size.toSize(), Paint()..shader = bgShader);
    super.render(canvas);
  }

  void onMouseMove(PointerHoverInfo info) {
    updateMousePosition(info.eventPosition.widget);
  }

  void updateMousePosition(Vector2 position) {
    var localLocation = position - size / 2;
    localLocation /= camera.viewfinder.zoom;
    final direction = localLocation - ball.position;
    final distance = direction.length;
    // print('mouse: $localLocation, ball: ${ball.position}');
    if (distance > 5) {
      ball.body.applyLinearImpulse(direction * 500);
    }
  }

  // Get touch input
  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    updateMousePosition(info.eventPosition.widget);
  }
}

class Ball extends BodyComponent with TapCallbacks {
  Ball({Vector2? initialPosition})
      : super(
          fixtureDefs: [
            FixtureDef(
              CircleShape()..radius = 5,
              restitution: 0.8,
              friction: 0.4,
            ),
          ],
          bodyDef: BodyDef(
            angularDamping: 0.8,
            position: initialPosition ?? Vector2.zero(),
            type: BodyType.dynamic,
          ),
        );
  late final FragmentProgram _program;
  late final FragmentShader shader;
  double time = 0;
  double radius = 5;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  static const int padding = 2;

  @override
  void render(Canvas canvas) {
    shader
      ..setFloat(0, time)
      ..setFloat(1, radius)
      ..setFloat(2, speed.x)
      ..setFloat(3, speed.y);

    canvas
      ..drawCircle(
        Offset.zero,
        radius,
        Paint()..shader = shader,
      );
  }

  @override
  Future onLoad() async {
    super.onLoad();
    _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
  }
}

class Wall extends BodyComponent {
  final Vector2 _start;
  final Vector2 _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start, _end);
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
