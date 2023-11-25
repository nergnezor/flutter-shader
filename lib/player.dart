import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Player extends  PositionComponent with CollisionCallbacks {
  late final FragmentProgram _program;
  late final FragmentShader shader;

  double time = 0;
  late double radius;
  Vector2 speed = Vector2.zero();
  Vector2 move = Vector2.zero();
  // PositionComponent pos = PositionComponent();
static const int padding = 10;
bool touching = false;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    print('Player collided with $other');
    touching = true;
    super.onCollision(intersectionPoints, other);
  }
  @override
  void onLoad() async{
        _program = await FragmentProgram.fromAsset('shaders/shader.frag');
    shader = _program.fragmentShader();
    radius = size.x / 2;

    add(CircleHitbox(radius: size.x / 2));
  }    

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (touching) {
      canvas.drawRect(
        Rect.fromCircle(center: Offset.zero, radius: radius+padding),
        Paint()..color = Color(0x88ff0000),
      );
      touching = false;
    }

    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time)
      ..setFloat(3, 0)
      ..setFloat(4, 0)
      ..setFloat(5, radius)
      ..setFloat(6, speed.x)
      ..setFloat(7, speed.y);

          canvas
      // ..translate(circle.x, circle.y)
      ..drawRect(
        Rect.fromCircle(center: Offset.zero, radius: radius+padding),
        // Vector2.all(100).toOffset() & Vector2.all(400).toSize(),
        Paint()..shader = shader,
      );

  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;

    var current_speed = Vector2.zero();
    if (move != Vector2.zero()) {
      current_speed = move / dt;
      move = Vector2.zero();
    }
    speed = speed * 0.98 + current_speed * 0.1;

    // radius = pow(4 + 1 * (1 + cos(time + pi)) / 2, 3).toDouble();
    // radius -= speed.length / 20;
    // radius = radius.clamp(20, 100);
    // Update position
    position += speed * dt;
    // print("speed: $speed");
    // pos.position += speed * dt * 3;
  }
}