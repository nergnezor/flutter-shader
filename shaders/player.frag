#include <flutter/runtime_effect.glsl>

uniform float time;
uniform float radius;
uniform vec2 speed;
uniform float life;
out vec4 fragColor;

vec4 calculateColor(float center_distance, float radius, float time)
{
  float red = 100000*sin(time/8) ;
  float green = pow(center_distance, 3);
  float blue = 0.4 ;
  return vec4(red, green, blue, 0.8);
}

void main()
{
  float center_distance = length(FlutterFragCoord().xy)/radius;
  float velocity = length(speed);
    fragColor = calculateColor(center_distance, radius, time);
}