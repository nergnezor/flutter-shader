import 'package:flame/components.dart';
import 'dart:async';
import 'dart:ui';

class Ball extends Component {
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  Vector2 size = Vector2.all(100);
  double time = 0;
  static Vector2 gravity = Vector2(0, 9.8);
  late final FragmentProgram _program;
  late final FragmentShader shader;
  @override
  void update(double dt) {
    super.update(dt);
    velocity += gravity * dt;
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    shader
      ..setFloat(0, size.x)
      ..setFloat(1, size.y)
      ..setFloat(2, time);

    canvas
      ..translate(200, 0)
      ..drawRect(
        Offset.zero & size.toSize(),
        Paint()..shader = shader,
      );
  }

  void dispose() {
    shader.dispose();
  }

  @override
  Future<void>? onLoad() async {
    _program = await FragmentProgram.fromAsset('shaders/simple.frag');
    shader = _program.fragmentShader();
  }
}
