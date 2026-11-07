#version 310 es
precision highp float;
precision highp int;

out vec4 out_color;

layout(binding = 0) uniform highp sampler2D framebuffer_tex;

layout(location = 0) flat in vec4 fragment_color;
layout(location = 1) in vec2 tex_coord;

void main() {
  vec4 color = fragment_color;

  // correct color
  color *= 2.;

  // correct texture coordinates
  vec2 texture_coords = vec2(tex_coord.x, (1.0f - tex_coord.y) - (1. - (448.0 / 512.0)) / 2.);

  // sample framebuffer texture
  out_color = color * texture(framebuffer_tex, texture_coords);
}
