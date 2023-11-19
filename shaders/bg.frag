#include <flutter/runtime_effect.glsl>
uniform vec2 resolution;
uniform float time;
uniform float radius;
uniform vec2 speed;
out vec4 fragColor;

void main()
{
    if (FlutterFragCoord().x < 100.0)
        fragColor = vec4(1, 0, 0, 1);
    else
        fragColor = vec4(0.2, 0.4, 0.7, 1);
}
