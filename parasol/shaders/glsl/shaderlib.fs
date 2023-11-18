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

/*
 * rgb_to_hsv returns a vec3 containing HSV values for the provided RGB vec3.
 *
 * Parameters
 *
 * rgb - the input RGB value as a vec3 with each value between 0.0 - 1.0
 *
 * Returns
 *
 * vec3 - HSV value corresponding to the input RGB value.
 *
 * Credits/References
 *    https://math.stackexchange.com/questions/556341/rgb-to-hsv-color-conversion-algorithm
 *    https://www.geeksforgeeks.org/program-change-rgb-color-model-hsv-color-model/
 */
vec3 rgb_to_hsv(vec3 rgb)
{
    // Compute cmax and cmin and the range or difference
    float cmax = max(rgb.r, max(rgb.g, rgb.b));
    float cmin = min(rgb.r, min(rgb.g, rgb.b));
    float diff = cmax - cmin;
    float h = -1.0;
    float s = -1.0;

    // Compute HSV
    if (cmax == cmin) {
        h = 0.0;
    } else {
        if (cmax == rgb.r) {
            h = mod(60.0 * (rgb.g - rgb.b) / diff, 360.0);
        } else if (cmax == rgb.g) {
            h = mod(60.0 * (rgb.b - rgb.r) / diff + 120.0, 360.0);
        } else {
            // max is b
            h = mod(60.0 * (rgb.r - rgb.g) / diff + 240.0, 360.0);
        }
    }

    // Compute s
    if (cmax == 0.0) {
        s = 0.0;
    } else {
        s = (diff / cmax);
    }
    
    // Compute v
    float v = cmax;
    
    return vec3(h, s, v);
}

/*
 * hsv_to_rgb returns a vec3 containing RGB values for the provided HSV vec3.
 *
 * Parameters
 *
 * hsv - the input HSV value as a vec3
 *
 * Returns
 *
 * vec3 - RGB value corresponding to the input HSV value.
 *
 * Credits/References
 *    This implementation comes from https://cs.stackexchange.com/questions/64549/convert-hsv-to-rgb-colors
 *    which has a very clear and detailed explanation of the mathematics involved.
 */
vec3 hsv_to_rgb(vec3 hsv)
{
    // Note all swizzling of HSV done with xyz to avoid confusion caused by using rgb
    // in the HSV context.

    float r=0.0, g=0.0, b=0.0;
    // Process input S and V
    float cmax = hsv.z;
    float diff = hsv.y * hsv.z;
    float cmin = cmax - diff;

    // Compute h-prime to determine which RGB formulae to use
    float h_prime = 0.0;
    if (hsv.x >= 300.0) {
        h_prime = (hsv.x - 360.0) / 60.0;
    } else {
        h_prime = hsv.x / 60.0;
    }

    if (h_prime >= -1.0 && h_prime < 1.0) {
        if (h_prime < 0.0) {
            r = cmax;
            g = cmin;
            b = g - h_prime * diff;
        } else {
            r = cmax;
            b = cmin;
            g = b + h_prime * diff;
        }
    } else if (h_prime >= 1.0 && h_prime < 3.0) {
        if (h_prime - 2.0 < 0.0) {
            g = cmax;
            b = cmin;
            r = b - (h_prime - 2.0) * diff;
        } else {
            r = cmin;
            g = cmax;
            b = r + (h_prime - 2.0) * diff;
        }
    } else if (h_prime >= 3.0 && h_prime < 5.0) {
        if (h_prime - 4.0 < 0.0) {
            r = cmin;
            b = cmax;
            g = r - (h_prime - 4.0) * diff;
        } else {
            g = cmin;
            b = cmax;
            r = g + (h_prime - 4.0) * diff;
        }
    }
    return vec3(r, g, b);
}