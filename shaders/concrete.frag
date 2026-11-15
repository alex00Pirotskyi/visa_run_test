#include <flutter/runtime_effect.glsl>

// Static architectural concrete. One GPU draw, zero time-dependent uniforms.
// Subtle aggregate, pores and mineral variation; no animated noise.
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
  float mineral = noise(p * .028);
  float fine = noise(p * .18);
  float granular = hash21(floor(p * .97));
  float pores = smoothstep(.85, .98, noise(p * .21));
  float value = .741
      + (cloud - .5) * .08
      + (mineral - .5) * .06
      + (fine - .5) * .024
      + (granular - .5) * .017
      - pores * .026;
  fragColor = vec4(vec3(value * 1.012, value, value * .984), 1.);
}
