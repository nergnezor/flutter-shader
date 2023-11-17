#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float time;
out vec4 fragColor;

void main()
{
  vec2 center = resolution.xy / 2.0;
  float center_distance = distance(FlutterFragCoord().xy, center);
  const float RADIUS = 100 * (1 + sin(time*3)/8);
  float alpha = center_distance < RADIUS ? 1.0 : 0.0;
  fragColor = vec4(alpha);
}
