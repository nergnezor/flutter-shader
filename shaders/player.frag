#include <flutter/runtime_effect.glsl>

uniform float iTime;
uniform float radius;
uniform vec2 speed;
uniform float life;

out vec4 fragColor;

void fillLife(out vec4 fragColor, in vec2 fragCoord)
{
  vec4 color = vec4(0);
  float fillHeight = life;
  // Vary the fill height based on the time.
  // And also based on the x coordinate.
  fillHeight += 0.05 * sin(fragCoord.x * 4 + iTime * 4) * sin(iTime * 4);

  float y = (fragCoord.y + radius) / (2.0 * radius);
  if (y < fillHeight)
  {
    float r = 0.1 + 0.5 * life;
    color = vec4(r, r / 2, r, 0.3);
  }

  float fillHeight2 = life + 0.06 * sin(fragCoord.x * 3 + iTime * 3) * sin(iTime * 4);
  if (y < fillHeight2)
  {
    float b = 1.0;
    color *= vec4(b / 3, b, b, 1);
  }

  fragColor = color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  fillLife(fragColor, fragCoord);
  float center_distance = length(fragCoord) / radius;
  if (center_distance < 0.95)
    return;
  fragColor = vec4(0.8);
}
void main()
{
  mainImage(fragColor, FlutterFragCoord().xy);
}
