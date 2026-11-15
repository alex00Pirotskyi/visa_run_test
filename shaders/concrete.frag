#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
out vec4 fragColor;

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash21(i), hash21(i + vec2(1.,0.)),f.x),
             mix(hash21(i + vec2(0.,1.)),hash21(i + vec2(1.,1.)),f.x),f.y);
}
void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 uv = p / max(uSize, vec2(1.));
  float coarse = noise(p * .0045);
  float medium = noise(p * .027);
  float grain = noise(p * .31);
  float pores = smoothstep(.79, .95, noise(p * .17));
  float veins = smoothstep(.43, .55, noise(vec2(p.x * .009, p.y * .002) + medium * .43));
  float edge = length((uv - .5) * vec2(1.12, .92));
  float light = .71 + .13 * coarse + .07 * medium + .038 * grain
      - .075 * pores - .023 * veins - .14 * smoothstep(.22, .85, edge);
  vec3 concrete = vec3(light * .99, light * .985, light * .956);
  fragColor = vec4(concrete, 1.);
}
