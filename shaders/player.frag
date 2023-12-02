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
    if (y - fillHeight > -0.01)
      color = vec4(0.99);

    const vec4 blue1 = vec4(0.8, 0.2, 0.4, 0.3);
    color += blue1;
  }

  float fillHeight2 = life + 0.06 * sin(fragCoord.x * 3 + iTime * 3) * sin(iTime * 4);
  if (y < fillHeight2)
  {
    if (y - fillHeight2 > -0.01)
      color = vec4(0.8);
    const vec4 blue2 = vec4(0.3, 0.5, 0.5, 0.3);
    color = mix(color, blue2, life);
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
