// PARASOL-EXCLUDE-START
precision highp float;

varying vec2 openfl_TextureCoordv;
uniform vec2 openfl_TextureSize;
uniform sampler2D bitmap;
// PARASOL-EXCLUDE-END

/* Forward declarations */
vec3 grayscale(sampler2D image0, vec2 st);
vec2 pixelate(vec2 st, vec2 resolution, vec2 pixelSize);

/* Uniforms */
uniform vec2 u_pixelSize;
