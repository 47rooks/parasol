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
 * rect() returns a float value of 0.0 if st is outside the box defined by x, y and width and height. It
 * returns 1.0 if st is inside the box.
 * It uses four step functions to check:
 *    if st.x (the x value of the st vec2) is greater than the left hand edge value, x
 *    if st.x is less that the right hand edge value, x + width
 *    if st.y (the y value of the st vec2) is greater than the bottom edge value, y
 *    if st.y is less than the top edge value, y + height
 *
 * Each of these returns a 0.0 or 1.0 and they are multiplied together. Only if all four checks pass is a 1.0 returned
 * otherwise st is outside the box and a 0 is returned.
 *
 * Parameters
 *   st - the current fragment's location
 *   start - the top left corner of the rectangle
 *   end - the bottom right corner of the rectangle
 *
 * Returns
 *   0.0 if st is outside the rectangle
 *   1.0 if it is inside
 */
float rect(vec2 st, float x, float y, float width, float height) {
    // bottom and left
    float l = step(x, st.x);
    float b = step(y, st.y);

    /* top and right
     * Note that here the limit and the coordinate are reversed.
     * This is because we now wish to return 1.0 if st.x is on the
     * left side of the right hand edge, and if st.y is below the top.
     */
    float r = step(st.x, x + width);
    float t = step(st.y, y + height);

    return l * b * r * t;
}

/** The main program
 *  If this is not present GLSL will think there is no program. Just like C there must always be a main().
 */
void main() {
    /* gl_FragCoord is the fragment coordinate. Here we swizzle out the x and y value and divide them
     * by the resolution of the area we are drawing in (u_resolution) again swizzling out the xy portion
     * of the vector. u_resolution and gl_FragCoord are vec4's but we are only working in 2D here, so we
     * just take out the xy coordinates. This coordinate is relative to the containing window.
     *
     * st contains the xy coordinate of our pixel as a relative value between 0.0 and 1.0.
     */
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    /* Here we setup some colors, black and white. */
    vec3 color = vec3(0.); 
    vec3 white = vec3(1., 1., 1.);

    /* Now we call rect passing in:
     *   st, our coordinate
     *   0.4, 0.3 - the top and left (x and y) coordinates of our box
     *   0.2, 0.2 - the width and height of our box, here a square 0.2 on a side.
     *
     * pct has a value of 1.0 if st is inside the box, 0.0 otherwise.
     */
    float pct = rect(st, 0.4, 0.3, 0.2, 0.2);

    /* Set the color as white if pct is 1.0 or to 0.0 (black) otherwise. */
    color += white * pct;

    /* gl_FragColor is the GLSL variable for the output color from this shader. It is
     * the color for our pixel.
     */
    gl_FragColor = vec4(color, 1.0);
}