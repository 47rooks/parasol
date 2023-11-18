package unit.parasol.shaders;

import unit.utils.Capture;
import unit.utils.GameHarness;
import utest.Test;

/**
 * A base class for tests requiring image capture support and a GameHarness instance.
 */
class ImageCapturingBaseTest extends Test {

    static final WINDOW_WIDTH = 600;
    static final WINDOW_HEIGHT = 400;
    static final REFERENCE_DIR = "tests/reference/";

    var _stage:openfl.display.Stage;
    var _gameHarness:GameHarness;
    
    public function new(stage:openfl.display.Stage) {
        super();
        _stage = stage;
    }

    function setup():Void {
        // Install the GameHarness sized for these tests
        _gameHarness = new GameHarness(WINDOW_WIDTH, WINDOW_HEIGHT);
        _stage.addChildAt(_gameHarness, 0);
        _gameHarness.dispatchEvent(
            new openfl.events.Event(openfl.events.Event.ADDED_TO_STAGE, false, false));
    }

    function teardown():Void {
        // Remove the GameHarness and destroy it
        _stage.removeChild(_gameHarness);
        _gameHarness = null;
        Capture.enabled = false;
    }

}