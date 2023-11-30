#include <flutter/runtime_effect.glsl>

uniform vec2 resolution;
uniform float time;
out vec4 fragColor;

const float PI = 3.1415926535897932384626433832795;

void draw_tunnel(float center_distance, float time, out vec4 color)
{
    color = vec4(0);
    float center_distance_interval = 0.1;
    bool is_in_interval = mod(pow(center_distance, 0.1 * (1 + 1 + sin(time / 2))), center_distance_interval) < center_distance_interval / 2.0;
    if (is_in_interval)
    {
        float r = 20 * pow(center_distance, 3);
        color = vec4(r, 0, r / 3, 1.0);
        // color = vec4(center_distance, 0, 0, center_distance);
    }
}

void main()
{
    // float center_distance_percentage = length(FlutterFragCoord().xy) / length(resolution);
    // draw_tunnel(center_distance_percentage, time, fragColor);
}
