package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * A LineShader draws a straight line across a graphic and fills in a solid opaque color below.
 * 
 * TODO: Add color selection, both background and foreground colors
 *       Add blending with existing graphic content
 *       Make fill optional
 *       Add line thickness control
 */
class LineShader extends FlxShader
{
	var _refWidth:Float;
	var _refHeight:Float;

	@:glFragmentSource('
        #pragma header

        uniform vec2 u_point1;
        uniform vec2 u_point2;

        void main() {
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

            // Compute slope
            float run = u_point2.x - u_point1.x;
            float slope = (u_point2.y - u_point1.y) / run;
            vec3 color = vec3(0);
            float y_interp = u_point1.y + (st.x - u_point1.x) * slope;

            // Compute whether I am above or below line and set color accordingly
            if (st.y > y_interp) {
                color = vec3(0.,0.,1.);
            }
            
            // Output the color
            gl_FragColor = vec4(color, 1.0);
        }
    ')
	/**
	 * A shader that draws a straight line between two points, filling below the line.
	 * @param x1 starting point x value
	 * @param y1 starting point y value
	 * @param x2 ending point x value
	 * @param y2 ending point y value
	 * @param refWidth the width of the sprite graphic on which the line is to be drawn
	 * @param refHeight the height of the sprite graphic on which the line is to be drawn
	 */
	public function new(x1:Float, y1:Float, x2:Float, y2:Float, refWidth:Float, refHeight:Float)
	{
		super();
		_refWidth = refWidth;
		_refHeight = refHeight;
		this.u_point1.value = [x1 / _refWidth, y1 / _refHeight];
		this.u_point2.value = [x2 / _refWidth, y2 / _refHeight];
	}

	/**
	 * Update the line start and end points, moving the line and shading.
	 * @param x1 starting point x value
	 * @param y1 starting point y value
	 * @param x2 ending point x value
	 * @param y2 ending point y value
	 */
	public function update(x1:Float, y1:Float, x2:Float, y2:Float):Void
	{
		this.u_point1.value = [x1 / _refWidth, y1 / _refHeight];
		this.u_point2.value = [x2 / _refWidth, y2 / _refHeight];
	}
}
