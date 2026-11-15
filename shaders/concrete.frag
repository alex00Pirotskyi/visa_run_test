#include <flutter/runtime_effect.glsl>

// "Kindle concrete": matte warm-gray wall, not a cinematic architectural
// scene. One smooth mineral octave + subtle pixel grain, with rare pores.
// Five hash evaluations per pixel (previously nine), and NO time uniforms.
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
  float mineral = noise(p * .005);
  float grain = hash21(floor(p * .92));
  float pore = step(.992, grain);

  float tone = .783
      + (mineral - .5) * .025
      + (grain - .5) * .018
      - pore * .012;
  vec3 concrete = vec3(tone * 1.011, tone * .997, tone * .982);
  fragColor = vec4(concrete, 1.);
}
