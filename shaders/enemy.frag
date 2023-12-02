#include <flutter/runtime_effect.glsl>

uniform float time;
uniform float radius;
uniform vec2 speed;
uniform float life;
out vec4 fragColor;

vec4 calculateColor(float center_distance, float radius, float time)
{
  if (center_distance > 0.99)
  {
    return vec4(1);
  }
  return vec4(0.1 + 0.5 * life);
}

void main()
{
  float center_distance = length(FlutterFragCoord().xy) / radius;
  float velocity = length(speed);
  fragColor = calculateColor(center_distance, radius, time);
}