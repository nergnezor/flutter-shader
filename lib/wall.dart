import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Wall extends BodyComponent {
  final Offset _start;
  final Offset _end;

  Wall(this._start, this._end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(_start.toVector2(), _end.toVector2());
    final fixtureDef = FixtureDef(shape, friction: 0.3);
    final bodyDef = BodyDef(
      position: Vector2.zero(),
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

  List<Component> createBoundaries(Rect r) {
    return [
      Wall(r.topLeft, r.topRight),
      Wall(r.topRight, r.bottomRight),
      Wall(r.bottomLeft, r.bottomRight),
      Wall(r.topLeft, r.bottomLeft),
    ];
  }
