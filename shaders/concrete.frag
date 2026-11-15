#include <flutter/runtime_effect.glsl>

// Low-contrast poured concrete. No animation, uniforms, vignette or heavy
// noise. Local coordinates tie it to the scrolling wall without extra work.
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
  float mineral = noise(p * .006);
  float fine = noise(p * .14);
  float pores = smoothstep(.84, .95, noise(p * .24));
  float softShade = noise(p * .0018);

  // Roughly 90% flatter than the earlier mottled texture. Ink is allowed to
  // show the mineral surface through semi-transparent painted colours.
  float value = .725
    + (mineral - .5) * .041
    + (fine - .5) * .024
    + (softShade - .5) * .026
    - pores * .014;
  vec3 concrete = vec3(value * 1.012, value, value * .964);
  fragColor = vec4(concrete, 1.);
}
