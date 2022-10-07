package;

import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
	var _testSprite:FlxSprite;
	var _oldTVShader:OldTVShader;

	var _cummTime:Float;

	override public function create()
	{
		super.create();

		_cummTime = 0.0;

		_testSprite = new FlxSprite();
		_testSprite.loadGraphic(AssetPaths.pexels_pixabay_73873__png);

		_oldTVShader = new OldTVShader(_testSprite.width, _testSprite.height);
		_testSprite.shader = _oldTVShader;
		add(_testSprite);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		_cummTime += elapsed;
		_oldTVShader.update(_cummTime);
	}
}
