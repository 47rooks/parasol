package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

/**
 * A metaball demonstration sprite.
 */
class Metaball extends FlxSprite
{
	var _stationary:Bool;

	/**
	 * Constructor
	 * @param xLoc the initial location x value of the metaball 
	 * @param yLoc the initial location y value of the metaball 
	 * @param bitmap the BitmapData containing the metaball image
	 * @param mbCamera the camera on which to render the metaball
	 * @param stationary true if the metaball should be stationary, false it if should be set in motion
	 */
	public function new(xLoc:Float, yLoc:Float, bitmap:BitmapData, mbCamera:FlxCamera, stationary:Bool = true)
	{
		super(0, 0);
		_stationary = stationary;
		this.cameras = [mbCamera];
		// blend = BlendMode.ADD;

		loadGraphic(bitmap, false, 256, 256);
		x = xLoc - width / 2;
		y = yLoc - height / 2;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!_stationary)
		{
			if (x + width / 2 < 0)
				velocity.x *= -1.0;
			if (x + width / 2 > FlxG.width)
				velocity.x *= -1.0;
			if (y + height / 2 < 0)
				velocity.y *= -1.0;
			if (y + height / 2 > FlxG.height)
				velocity.y *= -1.0;
		}
	}
}
