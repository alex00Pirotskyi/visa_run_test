#include <flutter/runtime_effect.glsl>

// Cool grey concrete microstructure beneath the static architectural
// sunlight painter. No time uniform; the shader is never animated.
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
  float big = noise(p * .003);
  float fine = noise(p * .026);
  float tiny = noise(p * .20);
  float pores = smoothstep(.86, .97, noise(p * .17));
  float v = .733
    + (big - .5) * .055
    + (fine - .5) * .045
    + (tiny - .5) * .023
    - pores * .019;
  vec3 grey = vec3(v * .995, v * 1.002, v * 1.004);
  fragColor = vec4(grey, 1.);
}
