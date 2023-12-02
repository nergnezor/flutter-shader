// ignore-line
#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
out vec4 fragColor;

#define SPEED 5

void mainImage(out vec4 O, vec2 I)
{
    vec2 percent = (I + iResolution / 2) / iResolution;
    vec2 centerOffset = percent - vec2(0.5, 0.5);
    const float height = iResolution.y;
    // float yDistance = mod(iTime * 5, height);
    float yDistance = iTime * SPEED;

    const int numTargets = 5;
    const int radius = 4;
    float targetYInterval = iResolution.y / numTargets;
    for (int i = 0; i < numTargets; i++)
    {
        float targetY = i * targetYInterval;
        // targetY += radius;

        targetY += yDistance;
        targetY = mod(targetY, height);
        targetY -= height / 2;
        // targetY -= 10;
        float targetDistance = length(I - vec2(0, targetY));
        if (targetDistance < radius)
        {
            O = vec4(0.6);
            return;
        }
    }

    O = vec4(0.5);
}
void main()
{
    mainImage(fragColor, FlutterFragCoord().xy);
}