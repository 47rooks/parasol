/*
 * This file is a library of GLSL functions.
 * These functions will be pulled into shaders during compilation via
 * macro processing of @:parasolFunctionsSource metadata statements.
 * It is required currently that these shaders not refer to any uniforms
 * directly. It is expected these will be provide by the calling function
 * as parameters.
 *
 * The code fragments up to HEADER ENDS is here only to permit IDEs to resolve
 * definitions and are not expected to be included in the final shader.
 */

precision highp float;
vec4 flixel_texture2D(sampler2D bitmap, vec2 coord);

/* ------------------ HEADER ENDS ------------------ */

/*
 * grayscale returns a luma value for a given texel in the specified texture
 * at the specified position.
 *
 * Parameters
 *
 * image0 - the sampler from which to sample the texel
 * st     - the fragment location
 *
 * Returns
 *
 * vec3 - the grayscale luma value as an RGB value with all channels equal.
 */
vec3 grayscale(sampler2D image0, vec2 st)
{
    vec4 color = flixel_texture2D(image0, st);
    return vec3(dot(color.rgb, vec3(0.2126, 0.7152, 0.0722)));
}

/*
 * pixelate returns the coordinate to pull the texel value from given a
 * coordinate, texture resolution and required pixelation size. All coordinates
 * lying within the same pixelation pixel (pixelSize) will return the same coordinate.
 *
 * Parameters
 *
 * st         - the coordinate of the fragment to be pixelated
 * resolution - the resolution of the texture being pixelated
 * pixelSize  - the width (x) and height (y) of the pixel to be rendered
 *
 * Returns
 *
 * vec2 - the coordinate from which to get the color value for the fragment st.
 */
vec2 pixelate(vec2 st, vec2 resolution, vec2 pixelSize)
{
    vec2 pix = pixelSize / resolution;
    vec2 pixelatedCoord = pix * floor(st / pix);
    return pixelatedCoord;
}