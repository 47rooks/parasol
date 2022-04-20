package;

import LetterShader.Letter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class PlayState extends FlxState
{
	final SCREEN_CENTRE_X = FlxG.width / 2;
	final SCREEN_CENTRE_Y = FlxG.height / 2;
	final LETTER_WIDTH = 50;
	final LETTER_HEIGHT = 50;
	final NUM_LETTERS = 10;

	var _letters:Array<FlxSprite>;
	// References to each letter's spinning tween
	var _spinningTweens:Array<FlxTween> = null;

	override public function create()
	{
		super.create();

		// Display instructions
		showKeyHelp();

		// Create a collection of sprites each with one of the letters
		// of H E L L O W O R L D
		_letters = new Array();
		var r = new FlxRandom();
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
	 * Compute the x,y position of the sprite for a letter so as to centre it vertically
	 * and to centre the spelled out work horizontally.
	 * @param letterNum the number of the letter in the word, starting from 0 for the first letter
	 * @param numLetters the number of letters in the word
	 */
	private function computeLetterSpritePos(letterNum:Int, numLetters:Int):FlxPoint
	{
		var x = SCREEN_CENTRE_X - numLetters * LETTER_WIDTH / 2 + letterNum * LETTER_WIDTH;
		var y = SCREEN_CENTRE_Y - LETTER_HEIGHT / 2;
		return new FlxPoint(x, y);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Start or cancel tweens to spin the letters
		if (FlxG.keys.justReleased.S)
		{
			if (_spinningTweens == null)
			{
				// Starting spinning
				_spinningTweens = new Array<FlxTween>();
				for (l in _letters)
				{
					// 1 second per full rotation, repeating until stopped
					_spinningTweens.push(FlxTween.angle(l, l.angle, l.angle + 360, 1, {type: LOOPING}));
				}
			}
			else
			{
				// Cancel spinning and destroy tweens
				stopSpinning();
			}
		}

		// Reset all tweens
		if (FlxG.keys.justReleased.R)
		{
			// Reset all motion
			if (_spinningTweens != null)
			{
				stopSpinning();
			}
			// Rotate back to 0 angle
			for (l in _letters)
			{
				FlxTween.angle(l, l.angle, 0.0, 1);
			}
		}
	}

	/**
	 * Helper function to stop the tweens
	 */
	private function stopSpinning():Void
	{
		for (t in _spinningTweens)
		{
			t.cancel();
		}
		_spinningTweens = null;
	}

	/**
	 * Create and display the key mappings
	 */
	private function showKeyHelp():Void
	{
		final LINE_X = 20;
		final LINE_Y = FlxG.height - 50;
		final FONT_SIZE = 15;
		var posY = LINE_Y;

		add(new FlxText(LINE_X, posY, "Keys:", FONT_SIZE));
		posY += 20;
		add(new FlxText(LINE_X, posY, "S - start/stop spin letters, R - reset", FONT_SIZE));
	}
}
