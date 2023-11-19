// PARASOL-EXCLUDE-START
precision highp float;

varying vec2 openfl_TextureCoordv;
uniform vec2 openfl_TextureSize;
uniform sampler2D bitmap;
// PARASOL-EXCLUDE-END

/* Forward declarations */
vec3 rgb_to_hsv(vec3 rgb);
vec3 hsv_to_rgb(vec3 hsv);
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord);
vec4 css_saturate(vec4 color, float saturation);

/* Uniforms */
uniform float u_saturation;
uniform bool u_algorithm; // True for the CSS based algorithm, false for the HSV saturation based.

/*
 * Modify saturation according to the value of the uniform.
 */
void main(void) {

    vec4 c = flixel_texture2D(bitmap, openfl_TextureCoordv);
    if (u_algorithm) {
        gl_FragColor = css_saturate(c, u_saturation);
    } else {
        vec3 hsv = rgb_to_hsv(c.rgb);
        hsv.z = clamp(hsv.z * u_saturation, 0.0, 1.0);
        vec3 color = hsv_to_rgb(hsv);
        gl_FragColor = vec4(color, 1.0);
    }
}
