#include <flutter/runtime_effect.glsl>

uniform float iTime;
uniform float radius;
uniform vec2 speed;
uniform float life;

out vec4 fragColor;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  float fillHeight = life;

  float y = fragCoord.y / radius;
  if (y > fillHeight)
  {
    return;
  }
  fragColor = vec4(0.1 + 0.5 * life);
}
void main()
{
  mainImage(fragColor, FlutterFragCoord().xy);
}