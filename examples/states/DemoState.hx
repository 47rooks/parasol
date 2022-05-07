package examples.states;

import flixel.FlxG;
import flixel.FlxState;
import examples.states.MenuState;

/**
 * DemoState provides a highlevel state class providing functions needed by all demo states.
 */
class DemoState extends FlxState {

    override public function update(elapsed:Float) {
        super.update(elapsed);

        // Return to the MenuState
        if (FlxG.keys.justReleased.ESCAPE) {
            FlxG.switchState(new MenuState());
        }
    }
}