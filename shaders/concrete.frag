#include <flutter/runtime_effect.glsl>

// Fine, static cast-concrete grain: mineral inclusions, pores, and shallow
// clouds. No time uniforms or repaint loop.
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
  float cloud = noise(p * .0028);
  float grain = noise(p * .038);
  float sand = noise(p * .32);
  float tiny = hash21(floor(p * .94));
  float pits = smoothstep(.87, .975, noise(p * .17));
  float tone = .736
    + (cloud - .5) * .103
    + (grain - .5) * .081
    + (sand - .5) * .032
    + (tiny - .5) * .017
    - .025 * pits;
  vec3 concrete = vec3(tone * .994, tone * 1.002, tone * 1.007);
  fragColor = vec4(concrete, 1.);
}
