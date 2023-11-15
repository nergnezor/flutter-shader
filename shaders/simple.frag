#version 460 core

#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
out vec4 fragColor;

vec3 flutterBlue = vec3(5, 83, 177) / 255;
vec3 flutterNavy = vec3(4, 43, 89) / 255;
vec3 flutterSky = vec3(2, 125, 253) / 255;

void main() {
  vec2 uv = FlutterFragCoord().xy / resolution.xy;
  vec2 center = vec2(0.5, 0.5);
  uv.x *= resolution.x / resolution.y;

  float center_dist = distance(uv, center);
  // float angle = atan(st.y, st.x);
  const float RADIUS = .1;
  // float r = RADIUS + 0.1 * sin(10.0 * angle + time * 2.0);
  // float alpha = smoothstep(r, r + 0.01, center_dist);
float alpha = center_dist < RADIUS ? 1.0 : 0.0;
  fragColor = vec4(alpha, alpha, alpha, 1.0);


}
