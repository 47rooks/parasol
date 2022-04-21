package;

import LetterShader.Letter;
import flixel.FlxSprite;
import flixel.math.FlxRandom;

class LetterSprite extends FlxSprite
{
	override public function new(x:Float, y:Float, width:Int, height:Int, letter:Letter)
	{
		super(x, y);
		makeGraphic(width, height, new FlxRandom().color());
		shader = new LetterShader(letter);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (shader != null)
		{
			cast(shader, LetterShader).update(-angle);
		}
	}
}
