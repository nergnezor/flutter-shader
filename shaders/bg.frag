#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

void mainImage(out vec4 O, vec2 I)
{
    vec2 percent = (I + iResolution.xy / 2.0) / iResolution.y;
    // Draw a sphere in the center of the screen.
    if (percent.x < 0.5)
    {
        O = vec4(1, 0, 0, 1);
        return;
    }
    vec3 col = 0.1 * (1 + sin(iTime / 10 + percent.y + vec3(4, 3, 2)));
    O = vec4(col, 1);
}
void main()
{
    mainImage(fragColor, FlutterFragCoord().xy);
}