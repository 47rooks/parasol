package;

import LetterShader.Letter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	// Some key constants to center and align the text properly
	final SCREEN_CENTRE_X = FlxG.width / 2;
	final SCREEN_CENTRE_Y = FlxG.height / 2;
	final LETTER_WIDTH = 50;
	final LETTER_HEIGHT = 50;
	final NUM_LETTERS = 10;

	// Array of sprites - one per letter
	var _letters:Array<FlxSprite>;

	override public function create():Void
	{
		super.create();

		// Create a collection of sprites each with one of the letters
		// of H E L L O W O R L D and add them to the PlayState.
		_letters = new Array();
		for (i => letter in [
			Letter.H, Letter.E, Letter.L, Letter.L, Letter.O, Letter.W, Letter.O, Letter.R, Letter.L, Letter.D
		])
		{
			var pos = computeLetterSpritePos(i, NUM_LETTERS);
			var l = new LetterSprite(pos.x, pos.y, LETTER_WIDTH, LETTER_HEIGHT, letter);
			_letters.push(l);
			add(l);
		}
	}

	/**
	 * Compute the x,y position of the sprite for a letter so as to centre it vertically on the
	 * vertical centerline of the game window, and to centre the spelled out word horizontally.
	 * 
	 * @param letterNum the number of the letter in the word, starting from 0 for the first letter
	 * @param numLetters the number of letters in the word
	 */
	private function computeLetterSpritePos(letterNum:Int, numLetters:Int):FlxPoint
	{
		var x = SCREEN_CENTRE_X - numLetters * LETTER_WIDTH / 2 + letterNum * LETTER_WIDTH;
		var y = SCREEN_CENTRE_Y - LETTER_HEIGHT / 2;
		return new FlxPoint(x, y);
	}
}
