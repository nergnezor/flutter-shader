#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float time;
uniform float radius;
out vec4 fragColor;

void main()
{
  fragColor = vec4(0);
  vec2 center = resolution.xy / 2;
  float center_distance = distance(FlutterFragCoord().xy, center);
  if (center_distance > radius) return;

  float red =  pow(7*sin(time)/8,2);
  float green = pow(center_distance/radius,3);
  float blue = 0.4+pow(red,4);
  fragColor = vec4(red,green,blue,1);
}
