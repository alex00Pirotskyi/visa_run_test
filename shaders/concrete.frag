#include <flutter/runtime_effect.glsl>

// Static pale concrete: tiny pores, quiet aggregate and fine mineral grain.
// No uniforms; one shader draw per wall render.
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
  float large = noise(p * .0035);
  float medium = noise(p * .028);
  float tiny = noise(p * .24);
  float sand = hash21(floor(p * .91));
  float pores = smoothstep(.88, .976, noise(p * .18));
  float value = .915
    + (large - .5) * .071
    + (medium - .5) * .043
    + (tiny - .5) * .023
    + (sand - .5) * .014
    - pores * .022;
  vec3 concrete = vec3(value * .998, value * .994, value * .989);
  fragColor = vec4(concrete, 1.);
}
