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
  fillHeight += 0.05 * sin(fragCoord.x * 4 + iTime) * sin(iTime * 4);

  float y = (fragCoord.y + radius) / (2.0 * radius);
  if (y < fillHeight)
  {
    if (y - fillHeight > -0.01)
      color = vec4(0.8);

    const vec4 blue1 = vec4(0.6 - life, 0.5 * life, life, 0.5);
    color += blue1;
  }

  float fillHeight2 = life + 0.06 * sin(fragCoord.x * 3 + iTime * 3) * sin(iTime * 5);
  if (y < fillHeight2)
  {
    if (y - fillHeight2 > -0.01)
      color = vec4(0.8);
    const vec4 blue2 = vec4(0.8 - life, 0.5 + life / 2, 0.8 * life, 0.5);
    color = mix(color, blue2, 0.5);
  }

  fragColor = color;
}

bool drawEye(out vec4 fragColor, in vec2 fragCoord)
{
  const float eyeRadius = 0.1;
  const float eyeDistance = 0.3;
  const vec2 eyeCenter = vec2(-0.3, 0.3);
  vec2 eyeCoord = fragCoord - eyeCenter;
  float eyeDistanceFromCenter = length(eyeCoord);
  if (eyeDistanceFromCenter < eyeRadius)
  {
    fragColor = vec4(0.8);
    return true;
  }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  float center_distance = length(fragCoord) / radius;
  if (center_distance > 0.98)
  {
    fragColor = vec4(1);
    return;
  }
  fillLife(fragColor, fragCoord);
  // if (drawEye(fragColor, fragCoord))
  // return;
  // fragColor = vec4(0.3);
  const float eyeRadius = 0.5;
  const float eyeDistance = eyeRadius * 1.6;
  const float pupilRadius = 0.2;
  const float irisRadius = 0.3;
  for (int i = 0; i < 2; i++)
  {
    vec2 eyeCenter = vec2(-0.3 + i * eyeDistance, 0.3);

    vec2 eyeCoord = fragCoord - eyeCenter;
    float eyeDistanceFromCenter = length(eyeCoord);
    if (eyeDistanceFromCenter < eyeRadius)
    {
      if (eyeDistanceFromCenter > eyeRadius - 0.02)
      {
        fragColor *= 0.3;
        return;
      }
      if (eyeDistanceFromCenter < pupilRadius)
      {
        fragColor = vec4(0, 0, 0, 1);
        return;
      }
      if (eyeDistanceFromCenter < irisRadius)
      {
        fragColor = vec4(0, 0.7, 1, 1);
        return;
      }
      fragColor = vec4(1, 1, 1, 1);
      return;
    }
  }
}
void main()
{
  mainImage(fragColor, FlutterFragCoord().xy);
}
