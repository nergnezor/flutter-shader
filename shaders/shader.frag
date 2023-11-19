#version 460 core
#include <flutter/runtime_effect.glsl>
precision mediump float;

uniform vec2 resolution;
uniform float time;
uniform vec2 position;
uniform float radius;
uniform vec2 speed;
out vec4 fragColor;

const float BORDER = 10.0;

vec4 calculateColor(float center_distance, float radius, float time)
{
  float red = pow(7 * sin(time) / 8, 2);
  float green = pow(center_distance / radius, 3);
  float blue = 0.4 + pow(red, 4);
  return vec4(red, green, blue, 0.8);
}

void main()
{
  // fragColor = vec4(0, 0, 0, 1);
  // return;
  // vec2 center = resolution.xy / 2;
  // vec2 center = vec2(radius);
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