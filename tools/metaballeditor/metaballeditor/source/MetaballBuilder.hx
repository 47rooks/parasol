package;

import lime.math.ARGB;
import openfl.display.BitmapData;

/**
 * The MetaballBuilder provides a way to generate a metaball from an input EquationSystem and size.
 */
class MetaballBuilder
{
	// Final metaball size
	var _width:Int;
	var _height:Int;

	var _equations:EquationSystem;

	var _halfWidth:Float;
	var _halfHeight:Float;

	/**
	 * Constructor
	 * @param width width of final bitmap in pixels
	 * @param height height of final bitmap in pixels
	 */
	public function new(es:EquationSystem, width:Int, height:Int)
	{
		_equations = es;
		_width = width;
		_height = height;

		_halfWidth = _width / 2;
		_halfHeight = _height / 2;
	}

	/**
	 * Generate a BitmapData metaball of the specified size by mapping the size onto the
	 * range -0.1-> 0.1 in both axes.
	 * 
	 * Note this can be a lengthy operation.
	 * 
	 * @return BitmapData the metaball as a BitmapData object
	 */
	public function generate():BitmapData
	{
		var bmd = new BitmapData(_width, _height);

		// Iterate over the dimensions of the metaball and evaluate the equation system for each point.
		// Set the color to white and the alpha value to the result of the equation evaluation.
		for (i in 0..._width)
		{
			var rx = (i - _halfWidth) / _halfWidth;
			for (j in 0..._height)
			{
				var ry = (j - _halfHeight) / _halfHeight;
				var rawAlpha = _equations.evaluate(rx, ry);
				var alpha = Math.min(255, Math.max(0, rawAlpha * 256 + 0.5));
				var color:ARGB = (Math.round(alpha) << 24) + (255 << 16) + (255 << 8) + 255;
				bmd.setPixel32(i, j, color);
			}
		}

		return bmd;
	}
}
