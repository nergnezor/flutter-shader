#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float time;
uniform vec2 position;
uniform float radius;
uniform vec2 speed;
out vec4 fragColor;

vec4 calculateColor(float center_distance, float radius, float time)
{
  float red = pow(7 * sin(time) / 8, 2);
  float green = pow(center_distance / radius, 3);
  float blue = 0.4 + pow(red, 4);
  return vec4(red, green, blue, 0.8);
}

void main()
{
  float center_distance = distance(FlutterFragCoord().xy, position);
  float velocity = length(speed);
  const float value = sqrt(velocity) / 4;

  if (center_distance > radius + value)
    return;
  // Draw border
  if (center_distance < radius)
  {
    fragColor = calculateColor(center_distance, radius, time);
    return;
  }
  fragColor = vec4(value / 2, value / 4, value / 8, 1);
}