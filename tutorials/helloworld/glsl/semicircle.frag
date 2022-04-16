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
 * semicircle() returns 1.0 in the shape of a semi-circular ring with sharp edge.
 * It does this by thresholding the distance() function value from a centre to the
 * current fragment's xy location and ensuring that st.x > that center.x, that is
 * that st is on the right hand side of the centre point. Thesholding is done with
 * the step() function.
 *
 * This is done twice, once for the inner circle which is subtracted from the
 * outer circle. The subtraction is achieved by reversing the distance value and the
 * threshold in the computation of c_inner.
 *
 * Parameters
 *   inner - the inner circle radius
 *   outer - the outer circle radius
 *   point - the current fragment's xy coordinate
 *   center - the center of the circle
 *
 * Returns
 *   0.0 if point is inside or outside the ring
 *   1.0 if point is on the ring itself
 */
float semicircle(float inner, float outer, vec2 point, vec2 centre) {
    float d = point.x > centre.x ? distance(point, centre) : 0.0;
    float c_outer = step(d, outer);
    float c_inner = step(inner, d);
    return  c_outer * c_inner;
}

/**
 * smoothsemicircle() returns 1.0 in the shape of a semi=circular ring with a fuzzy edge.
 * It does this by thresholding the distance() function value from a centre to the
 * current fragment's xy location and ensuring that st.x > that center.x, that is
 * that st is on the right hand side of the centre point. Thesholding is done with
 * the smoothstep() function.
 *
 * Fuzziness of the step is hardcoded to 0.1 but could also be a parameter.
 *
 * This is done twice, once for the inner circle which is subtracted from the
 * outer circle. The subtraction is achieved by reversing the distance value and the
 * threshold in the computation of c_inner.
 *
 * Parameters
 *   inner - the inner circle radius
 *   outer - the outer circle radius
 *   point - the current fragment's xy coordinate
 *   center - the center of the circle
 *
 * Returns
 *   1.0 if point is inside or outside the ring
 *   a value > 0.0 and <= 1.0 if point is on the ring itself
 */
float smoothsemicircle(float inner, float outer, vec2 point, vec2 centre) {
    float d = distance(point, centre);
    float c_outer = smoothstep(d, d + 0.1, outer);
    float c_inner = smoothstep(inner, inner - 0.1, d);
    return  smoothstep(0.5, 0.55, point.x) * (c_outer - c_inner);
}

/**
 * This example draws a ring centered in the screen. As usual, the coordinate space
 * is 0,0 in the bottom left to 1.0, 1.0 in the top right.
 */
void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    // Comment this line out and use the following one to change from hard to fuzzy edge.
    float pct = semicircle(0.25, 0.3, st, vec2(0.5, 0.5));
    // float pct = smoothsemicircle(0.25, 0.3, st, vec2(0.5, 0.5));
    gl_FragColor = vec4(vec3(pct), 1.0);
}