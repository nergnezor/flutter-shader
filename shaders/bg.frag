// ignore-line
#include <flutter/runtime_effect.glsl>

uniform vec2 iResolution;
uniform float iTime;
uniform float radius;
uniform vec2 speed;
uniform float life;
out vec4 fragColor;
// Define global variables
vec2 cameraPosition = vec2(0.0, 0.0);  // Initial camera position
float horizontalLineThickness = 0.008; // Adjust the thickness of horizontal lines
float verticalLineThickness = 0.0015;  // Adjust the thickness of vertical lines
float horizontalLineFrequency = 3.0;   // Adjust the frequency of horizontal lines
float verticalLineFrequency = 2.0;     // Adjust the frequency of vertical lines
float distortionFactor = -3.5;         // Adjust the degree of distortion
float movementSpeed = 3.5;             // Adjust the speed of movement
float ellipseDegree = 0.36;            // Adjust the degree of elliptical shape
float brightnessFactor = 1.7;          // Adjust the brightness of the shader

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Translate the NDC so that the origin is at the center of the screen and scale x-axis.
    // vec2 centerDistance = (fragCoord - iResolution.xy * 0.5) / min(iResolution.y, iResolution.x);
    // centerDistance.x *= iResolution.x / iResolution.y * ellipseDegree; // to maintain aspect ratio and control elliptical shape.
    vec2 centerDistance = fragCoord / iResolution.y;
    // Offset the center to the top of the screen
    centerDistance.y += 0.2;
    movementSpeed = (sin(iTime * 0.9) * 1.0 + 2.0) * 0.0025 + 5.0;

    // Tunnel distortion from the center, reduced as it approaches the camera
    float distortion = (0.5 - length(centerDistance)) * sin(iTime + length(centerDistance) * distortionFactor) * 0.05;
    centerDistance += vec2(distortion, distortion / 0.5); // Only distort horizontally

    vec2 t = vec2(atan(centerDistance.x, centerDistance.y) / 3.1416, 1.0 / length(centerDistance));
    vec2 s = iTime * vec2(0.0, movementSpeed);
    vec2 z = vec2(3.0, 1.0);
    float m = t.y + 0.6;

    // Generate stripes
    vec2 texCoord = vec2(mod((t.x - cameraPosition.x) * z.x + s.x, 1.0), mod((t.y - cameraPosition.y) * z.y + s.y, 1.0));
    float horizontalLine = step(horizontalLineThickness, fract(texCoord.x * horizontalLineFrequency));
    float perspectiveFactor = 0.2 / (0.2 + t.y); // perspective factor
    float verticalLine = step(verticalLineThickness, fract(texCoord.y * verticalLineFrequency * perspectiveFactor));

    // Combine horizontal and vertical stripes
    vec3 stripeColor = vec3(horizontalLine * verticalLine);

    // Set the background color to #CFC67F, stripes color to #BDB474, and add distance fog with color #AD9B45
    vec3 backgroundColor = vec3(207.0 / 255.0, 100.0 / 255.0, 127.0 / 255.0) * brightnessFactor;
    vec3 stripeColorFinal = vec3(189.0 / 255.0, 180.0 / 255.0, 116.0 / 255.0) * brightnessFactor;
    vec3 fogColor = vec3(173.0 / 255.0, 155.0 / 255.0, 69.0 / 255.0) * brightnessFactor;

    // Calculate the distance from the center
    float distance = length(fragCoord - iResolution.xy * 0.5) / length(iResolution.xy * 0.5);

    // Apply the distance fog effect
    vec3 finalColor = mix(stripeColorFinal, fogColor, smoothstep(0.0, 1.0, distance));

    fragColor = vec4((finalColor * stripeColor + backgroundColor) / m, 1.0);
}

void main()
{
    mainImage(fragColor, FlutterFragCoord().xy);
}