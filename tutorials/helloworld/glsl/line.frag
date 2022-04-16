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
 * Each of these returns a 0 or 1 and they are multiplied together. Only if all four checks pass is a 1.0 returned
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
float rect(vec2 st, vec2 start, vec2 end) {
    float run = end.x - start.x;
    float slope = (end.y - start.y) / run;

    float interp_y = start.y + (st.x - start.x) * slope;

    if (st.x > start.x && st.x < end.x && st.y > interp_y - 0.1 && st.y < interp_y + 0.1) {
        return 1.0;
    }
    return 0.0;
}

/**
 * smoothrect() returns a float value of 0.0 if st is outside the box defined by x, y and width and height. It
 * returns > 0.0 if st is inside the box.
 * It uses four step functions to check:
 *    if st.x (the x value of the st vec2) is greater than the left hand edge value, x
 *    if st.x is less that the right hand edge value, x + width
 *    if st.y (the y value of the st vec2) is greater than the bottom edge value, y
 *    if st.y is less than the top edge value, y + height
 *
 * Unlike step() this function will return a value between 0.0 and 1.0 when st lines in the region
 * between the edge and the edge + 0.1. This is what gives us the fuzzy edge. Each of these
 * returns are multiplied together. Only if all four checks pass is value > 0.0 returned otherwise
 * st is outside the box and a 0 is returned.
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
     * This is because we now wish to return 1.0 if st.x is on the
     * left of the right hand edge, and if st.y is below the top.
     */
    float r = smoothstep(st.x, st.x + 0.1, x + width);
    float t = smoothstep(st.y, st.y + 0.1, y + height);

    return l * b * r * t;
}


/**
 * rotate() returns a matrix which will rotate by the angle specified.
 *
 * Parameters
 *    _angle - the angle to rotate by
 *
 * Returns
 *    a matrix that will perform this rotation
 */
mat2 rotate2d(float _angle) {
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st -= vec2(0.5);
    st = rotate2d(-3.14159 /3.) * st;
    st += vec2(0.5);
    float pct = smoothrect(st, 0.2, 0.2, 0.7, 0.2);
    gl_FragColor = vec4(vec3(pct), 1.0);
}