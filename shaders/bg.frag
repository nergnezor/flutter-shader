#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

void mainImage(out vec4 O, vec2 I)
{
    vec2 xPercent = (I + iResolution / 2) / iResolution;
    // Draw a sphere in the center of the screen.
    if (xPercent.x < 0.5)
    {
        O = vec4(0.6);
        return;
    }
    vec3 col = 0.1 * (1 + sin(iTime / 10 + xPercent.y + vec3(4, 3, 2)));
    O = vec4(0.4);
}
void main()
{
    mainImage(fragColor, FlutterFragCoord().xy);
}