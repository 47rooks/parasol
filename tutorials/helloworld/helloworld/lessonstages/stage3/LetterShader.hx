package;

import flixel.system.FlxAssets.FlxShader;

enum Letter
{
	H;
	E;
	L;
	O;
	W;
	R;
	D;
}

class LetterShader extends FlxShader
{
	@:glFragmentSource("
        #pragma header

        /* Useful constants */
        #define PI 3.14159265359
        #define BLUR 0.1

        uniform int u_letter;
        uniform float u_angle;

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
            float l = smoothstep(x, x + BLUR, st.x);
            float b = smoothstep(y, y + BLUR, st.y);

            /* top and right
            * Note that here the limit and the coordinate are reversed.
            * This is because we now wish to return > 0.0 if st.x is on the
            * left of the right hand edge, and if st.y is below the top.
            */
            float r = smoothstep(st.x, st.x + BLUR, x + width);
            float t = smoothstep(st.y, st.y + BLUR, y + height);

            return l * b * r * t;
        }

        /**
         * smoothcircle() returns 1.0 in the shape of a circular ring with a fuzzy edge.
         * It does this by thresholding the distance() function value from a centre to the
         * current fragment's xy location. Thesholding is done with the smoothstep() function.
         * Fuzziness of the step is hardcoded to 0.1 but could also be a parameter.
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
         *   0.0 if point is on the ring itself
         */
        float smoothcircle(float inner, float outer, vec2 point, vec2 centre) {
            float d = distance(point, centre);
            float c_outer = smoothstep(d, d + BLUR, outer);
            float c_inner = smoothstep(inner, inner - BLUR, d);
            return  c_outer - c_inner;
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
            float c_outer = smoothstep(d, d + BLUR, outer);
            float c_inner = smoothstep(inner, inner - BLUR, d);
            return  smoothstep(centre.x, centre.x + BLUR, point.x) * (c_outer - c_inner);
        }

        /**
         * Rotate the coordinate space by the specified angle.
         *
         * Parameters
         *   angle - the angle to rotate by in radians.
         *
         * Returns
         *   the rotation matrix
         */
        mat2 rotate2d(float angle) {
            return mat2(cos(angle),-sin(angle),
                        sin(angle),cos(angle));
        }

        /**
         * Draw an H
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float H(vec2 st) {
            // The left upright, the horizontal and the right upright
            float pct = smoothrect(st, 0.25, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.35, 0.4, 0.3, 0.2);
            pct += smoothrect(st, 0.55, 0.2, 0.2, 0.6);
            return pct;
        }

        /**
         * Draw an E
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float E(vec2 st) {
            // The vertical back, then the three horizontal lines
            float pct = smoothrect(st, 0.25, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.35, 0.2, 0.3, 0.2);
            pct += smoothrect(st, 0.35, 0.4, 0.3, 0.2);
            pct += smoothrect(st, 0.35, 0.6, 0.3, 0.2);
            return pct;
        }

        /**
         * Draw an L
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float L(vec2 st) {
            // The vertical then the horizontal
            float pct = smoothrect(st, 0.25, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.35, 0.2, 0.3, 0.2);
            return pct;
        }

        /**
         * Draw an O
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float O(vec2 st) {
            float pct = smoothcircle(0.25, 0.32, st, vec2(0.5, 0.5));
            return pct;
        }

        /**
         * Draw a W
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float W(vec2 st) {
            float pct = smoothrect(st, 0.2, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.4, 0.2, 0.2, 0.4);
            pct += smoothrect(st, 0.6, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.3, 0.2, 0.2, 0.2);
            pct += smoothrect(st, 0.5, 0.2, 0.2, 0.2);
            return pct;
        }

        /**
         * Draw an R
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float R(vec2 st) {
            // The upright, the horizontal top and the semicircle
            float pct = smoothrect(st, 0.35, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.45, 0.6, 0.2, 0.2);
            pct += smoothsemicircle(0.12, 0.2, st, vec2(0.55, 0.6));

            // Now create the sloping leg. This is done by rotating the axes by -PI/3 radians
            // and then drawing the rectangle.
            // To do the rotation we translate the origin (0, 0) to the center and then rotate it
            // and translate it back. We then use that coordinate to feed into the smoothrect()
            // function to draw the leg as though it we just a horizontal rect centered on 0,0.
            vec2 st2 = st - vec2(0.5);
            st2 = rotate2d(-PI /3.) * st2;
            st2 = st2 + vec2(0.5);
            st2.y -= 0.43;
            st2.x -= 0.64;
            float pct1 = smoothrect(st2, -0.2, 0.0, 0.4, 0.2);

            // Now combine the leg with the rest of the R.
            pct += pct1;

            return pct;
        }

        /**
         * Draw an D
         *
         * Parameters
         *   st - this fragment shader's x,y coordinate
         */
        float D(vec2 st) {
            float pct = smoothrect(st, 0.25, 0.2, 0.2, 0.6);
            pct += smoothrect(st, 0.35, 0.6, 0.2, 0.2);
            pct += smoothsemicircle(0.2, 0.3, st, vec2(0.45, 0.5));
            pct += smoothrect(st, 0.35, 0.2, 0.2, 0.2);
            return pct;
        }

        void main() {
            vec2 st = openfl_TextureCoordv.xy;

            st.y = 1.0-st.y;
            st = st - vec2(0.5);
            st = rotate2d(u_angle) * st;
            st = st + vec2(0.5);

            // Obtain the bitmap pixel color at our this location
            vec4 c = flixel_texture2D(bitmap, st);

            /**
             * Here we use the u_time uni-form to change the letter
             * we display. u_time is the time in seconds since the shader
             * began running.
             * 
             * We add the letter color value to the bitmap color red channel.
             * This will blend rather than overwrite the color of the background.
             * We also modify the alpha value to 50% of the value passed in.
             */
            // int letter = int(mod(u_time, 10.));
            if (u_letter == 0) {
                    c.r += H(st);
            } else if (u_letter == 1) {
                    c.r += E(st);
            } else if (u_letter == 2) {
                    c.r += L(st);
            } else if (u_letter == 3) {
                    c.r += O(st);
            } else if (u_letter == 4) {
                    c.r += W(st);
            } else if (u_letter == 5) {
                    c.r += R(st);
            } else if (u_letter == 6) {
                    c.r += D(st);
            }
            gl_FragColor = vec4(vec3(c), c.a * 0.5);
        }
    ")
	public function new(letter:Letter)
	{
		super();

        this.u_angle.value = [0.0];

		switch (letter)
		{
			case H:
				this.u_letter.value = [0];
			case E:
				this.u_letter.value = [1];
			case L:
				this.u_letter.value = [2];
			case O:
				this.u_letter.value = [3];
			case W:
				this.u_letter.value = [4];
			case R:
				this.u_letter.value = [5];
			case D:
				this.u_letter.value = [6];
		}
	}

  	/**
	 * Update shader variables as needed
	 * @param angle the angle of the sprite, in degrees
	 */
	public function update(angle:Float)
    {
        // Convert angle from degrees to radians
        // Take the negative of the angle to compensate for the y-axis flip
        this.u_angle.value = [-angle * Math.PI / 180];
    }
}
