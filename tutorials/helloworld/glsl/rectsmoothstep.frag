/**
 * For GL for Embedded Systems set the float precision. This is required
 * for glsl-canvas to function.
 */
#ifdef GL_ES
precision mediump float;
#endif

/* The resolution of the panel in x, y pixels. */
uniform vec2 u_resolution;

/**
 * smoothrect() returns a float value of 0.0 if st is outside the box defined by x, y and width and height. It
 * returns > 0.0 and <= 1.0 if st is inside the box.
 * It uses four step functions to check:
 *    if st.x (the x value of the st vec2) is greater than the left hand edge value, x
 *    if st.x is less that the right hand edge value, x + width
 *    if st.y (the y value of the st vec2) is greater than the bottom edge value, y
 *    if st.y is less than the top edge value, y + height
 *
 * Unlike step() this function will return a value between 0.0 and 1.0 when st lines in the region
 * between the edge and the edge + 0.1. This is what gives us the fuzzy edge. Each of these
 * returns are multiplied together. Only if all four checks pass is value > 0.0 returned otherwise
 * st is outside the box and a 0.0 is returned.
 *
 * Parameters
 *   st - the current fragment's location
 *   start - the top left corner of the rectangle
 *   end - the bottom right corner of the rectangle
 *
 * Returns
 *   0.0 if st is outside the rectangle
 *   > 0.0 if it is inside
 */
float smoothrect(vec2 st, float x, float y, float width, float height) {
    // bottom and left
    float l = smoothstep(x, x + 0.1, st.x);
    float b = smoothstep(y, y + 0.1, st.y);

    /* top and right
     * Note that here the limit and the coordinate are reversed.
     * This is because we now wish to return > 0.0 if st.x is on the
     * left of the right hand edge, and if st.y is below the top.
     */
    float r = smoothstep(st.x, st.x + 0.1, x + width);
    float t = smoothstep(st.y, st.y + 0.1, y + height);

    return l * b * r * t;
}

/** The main program
 *  If this is not present GLSL will think there is no program. Just like C there must always be a main().
 */
void main() {
    /* gl_FragCoord is the fragment coordinate. Here we swizzle out the x and y value and divide them
     * by the resolution of the area we are drawing in (u_resolution) again swizzling out the xy portion
     * of the vector. u_resolution and gl_FragCoord is a vec4 but we are only working in 2D here, so we
     * just take out the xy coordinates. This coordinate is relative to the containing window.
     *
     * st contains the xy coordinate of our pixel as a relative value between 0.0 and 1.0.
     */
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    /* Here we setup some colors, black and white. */
    vec3 color = vec3(0.); 
    vec3 white = vec3(1., 1., 1.);

    /* Now we call rect three times to create the two vertical bars and the horizontal of the letter H
     *
     * pct has a value of 1.0 if st is inside the H, a value > 0.0 and < 1.0 on the fuzzy edge, and 0.0 otherwise.
     * Note that unlike the case of the rectangles themselves here we add the values together because we want
     * a value > 0.0 in any of the regions not just where they overlap.
     */
    float pct = smoothrect(st, 0.3, 0.2, 0.2, 0.6);
    pct += smoothrect(st, 0.4, 0.4, 0.3, 0.2);
    pct += smoothrect(st, 0.6, 0.2, 0.2, 0.6);

    /* Set the color as white if pct is > 0.0 or to 0.0 (black) otherwise. */
    color += white * pct;

    /* gl_FragColor is the GLSL variable for the output color from this shader. It is
     * the color for our pixel.
     */
    gl_FragColor = vec4(color, 1.0);
}