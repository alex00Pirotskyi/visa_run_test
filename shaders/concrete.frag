#include <flutter/runtime_effect.glsl>

// Static cast-concrete mineral grain. Two smooth octaves and one shared
// grain/pore sample: 9 hash evaluations per fragment, down from 17.
// No time, no animated effects, no extra full-screen pass.
out vec4 fragColor;

float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  return mix(
    mix(hash21(i), hash21(i + vec2(1., 0.)), f.x),
    mix(hash21(i + vec2(0., 1.)), hash21(i + vec2(1., 1.)), f.x),
    f.y
  );
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  float cloud = noise(p * .004);
  float mineral = noise(p * .029);
  float grain = hash21(floor(p * .95));
  float pores = smoothstep(.965, .996, grain);
  float value = .741
      + (cloud - .5) * .081
      + (mineral - .5) * .063
      + (grain - .5) * .026
      - pores * .033;
  fragColor = vec4(vec3(value * 1.012, value, value * .984), 1.);
}
