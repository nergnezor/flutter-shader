#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

void mainImage(out vec4 O, vec2 I)
{
    vec2 percent = (I + iResolution / 2) / iResolution;
    vec2 centerOffset = percent - vec2(0.5, 0.5);
    vec2 target = vec2(0, 14.5);
    float targetDistance = length(I - target);
    // Draw a sphere in the center of the screen.
    if (targetDistance < 4)
    {
        O = vec4(0.6);
        return;
    }
    vec3 col = 0.1 * (1 + sin(iTime / 10 + percent.y + vec3(4, 3, 2)));
    O = vec4(0.4);
}
void main()
{
    mainImage(fragColor, FlutterFragCoord().xy);
}