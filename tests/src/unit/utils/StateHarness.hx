package unit.utils;

import flixel.FlxSprite;
import flixel.FlxState;

/**
 * StateHarness is a test harness for a FlxState into which a test sprite may be
 * injected. It must then be switch into via the FlxG.switchState() call.
 */
class StateHarness extends FlxState {

    var _testSprite:FlxSprite;

    /**
     * Constructor
     * @param testSprite the sprite to display
     */
    public function new(testSprite:FlxSprite) {
        super();
        _testSprite = testSprite;
    }

    override public function create()
    {
        super.create();
        add(_testSprite);
    }
}