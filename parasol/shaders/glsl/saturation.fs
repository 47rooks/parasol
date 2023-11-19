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

/* Uniforms */
uniform float u_saturation;

/*
 * Modify saturation according to the value of the uniform.
 */
void main(void) {

    mat4 sat_mat = mat4(vec4(0.213+0.787 * u_saturation, 0.213 - 0.213 * u_saturation, 0.213 - 0.213 * u_saturation, 0.0),
                        vec4(0.715 - 0.715 * u_saturation, 0.715 + 0.285 * u_saturation, 0.715 - 0.715 * u_saturation, 0.0),
                        vec4(0.072 - 0.072 * u_saturation, 0.072 - 0.072 * u_saturation, 0.072 + 0.928 * u_saturation, 0.0),
                      vec4(0.0, 0.0, 0.0, 1.0)
    );
    // vec3 hsv = rgb_to_hsv(flixel_texture2D(bitmap, openfl_TextureCoordv).rgb);
    // hsv.z = clamp(hsv.z * u_saturation, 0.0, 1.0);
    // vec3 color = hsv_to_rgb(hsv);
    vec4 c = flixel_texture2D(bitmap, openfl_TextureCoordv);
    gl_FragColor = sat_mat * c;
    // gl_FragColor = vec4(color, 1.0);
}
