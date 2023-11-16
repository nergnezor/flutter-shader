#version 460 core

#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 resolution;
uniform float iTime;
uniform vec2 mouse;
out vec4 fragColor;

// vec3 flutterBlue = vec3(5, 83, 177) / 255;
// vec3 flutterNavy = vec3(4, 43, 89) / 255;
// vec3 flutterSky = vec3(2, 125, 253) / 255;
/* This animation is the material of my first youtube tutorial about creative 
   coding, which is a video in which I try to introduce programmers to GLSL 
   and to the wonderful world of shaders, while also trying to share my recent 
   passion for this community.
                                       Video URL: https://youtu.be/f4s1h2YETNY
*/

//https://iquilezles.org/articles/palettes/
vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}

//https://www.shadertoy.com/view/mtyGWy
// void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
//     vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
//     vec2 uv0 = uv;
//     vec3 finalColor = vec3(0.0);
    
//     for (float i = 0.0; i < 4.0; i++) {
//         uv = fract(uv * 1.5) - 0.5;

//         float d = length(uv) * exp(-length(uv0));

//         vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

//         d = sin(d*8. + iTime)/8.;
//         d = abs(d);

//         d = pow(0.01 / d, 1.2);

//         finalColor += col * d;
//     }
        
//     fragColor = vec4(finalColor, 1.0);
// }
void main() {
  vec2 uv = FlutterFragCoord().xy / resolution.xy;
//   vec2 center = vec2(0.5, 0.5);
//   uv.x *= resolution.x / resolution.y;

//   float center_dist = distance(uv, center);
//   // float angle = atan(st.y, st.x);
//   const float RADIUS = .12 + 0.02*sin(time/1000000 );
//   // float r = RADIUS + 0.1 * sin(10.0 * angle + time * 2.0);
//   // float alpha = smoothstep(r, r + 0.01, center_dist);
// float alpha = center_dist < RADIUS ? 1.0 : 0.0;
//   fragColor = vec4(alpha, sin(time/10000000), alpha, 1.0);
vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0);
    
    for (float i = 0.0; i < 4.0; i++) {
        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = palette(length(uv0) + i*.4 + iTime*.4);

        d = sin(d*8. + iTime/100)/8.;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }
        
    fragColor = vec4(finalColor, 1.0);

}

