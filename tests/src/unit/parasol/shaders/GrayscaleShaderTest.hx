package unit.parasol.shaders;

import flixel.FlxG;
import parasol.shaders.GrayscaleShader;
import flixel.FlxSprite;
import unit.utils.ImageComparator;
import openfl.events.Event;
import utest.Assert;
import unit.utils.Capture;
import unit.utils.GameHarness;
import unit.utils.StateHarness;
import utest.Test;

class GrayscaleShaderTest extends Test {

    static final WINDOW_WIDTH = 1920;
    static final WINDOW_HEIGHT = 1280;
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

        // Prime Capture utility
        Capture.captureHeight = WINDOW_HEIGHT;
        Capture.captureWidth = WINDOW_WIDTH;
        Capture.enabled = true;
    }

    function teardown():Void {
        // Remove the GameHarness and destroy it
        _stage.removeChild(_gameHarness);
        _gameHarness = null;
        Capture.enabled = false;
    }

    /**
     * Given an image
     * When a Grayscale shader is applied to it
     * Then the image will match the reference image pixel for pixel.
     */
    function testGrayscaleShader() {
        // Create shader and apply to a test image and install in the GameHarness
        var gs = new GrayscaleShader();
        var testSprite = new FlxSprite();
        testSprite.loadGraphic("assets/images/pexels-pixabay-2150.png");
        testSprite.shader = gs;
        var sh = new StateHarness(testSprite);
        FlxG.switchState(sh);

        // Need to run the game loop twice to be sure the image is rendered when capture runs
        // I don't actually know why which is not good. But I suspect the first is the initial
        // game loop and needs to setup stuff.
        _gameHarness.runGameLoop();
        _gameHarness.runGameLoop();

        // To compare with reference
        var results = ImageComparator.equals(REFERENCE_DIR + "grayscaleref.png", Capture.image);
        Assert.equals(ComparatorResult.IDENTICAL, results);
    }
}