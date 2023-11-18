#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float time;
out vec4 fragColor;

const float RADIUS = 100;
void main()
{
  fragColor = vec4(0);
  vec2 center = resolution.xy / 2;
  float center_distance = distance(FlutterFragCoord().xy, center);
  float extra =  cos(time*10)/8;
  const float r = RADIUS * (1 + extra);
  if (center_distance > r) return;

  
  float alpha = pow(center_distance/RADIUS,2);
  fragColor = vec4(0.1+extra,alpha,0.4+pow(extra,4),1);
}
