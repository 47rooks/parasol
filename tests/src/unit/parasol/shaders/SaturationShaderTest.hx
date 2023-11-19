package unit.parasol.shaders;

import flixel.FlxG;
import flixel.FlxSprite;
import parasol.shaders.SaturationShader;
import unit.utils.Capture;
import unit.utils.ImageComparator;
import unit.utils.StateHarness;
import utest.Assert;

class SaturationShaderTest extends ImageCapturingBaseTest {
 
    public function new(stage:openfl.display.Stage) {
        super(stage);
    }

    /**
     * Given an image
     * When a Saturation HSV shader is applied to it
     * Then the image will match the reference image pixel without any increase in saturation.
     */
     function testSaturationShaderHSVNoSat() {
        // Create shader and apply to a test image and install in the GameHarness
        var gs = new SaturationShader(HSV);
        var testSprite = new FlxSprite();
        testSprite.loadGraphic("assets/images/galaxy557x400.png");
        testSprite.shader = gs;

        var sh = new StateHarness(testSprite);
        FlxG.switchState(sh);

        // Need to run the game loop twice to be sure the image is rendered when capture runs
        // I don't actually know why which is not good. But I suspect the first is the initial
        // game loop and needs to setup stuff.
        _gameHarness.runGameLoop();
        
        Capture.prepare(Std.int(_gameHarness.width), Std.int(_gameHarness.height), true);
        _gameHarness.runGameLoop();
        Capture.wait();

        // To compare with reference
        var results = ImageComparator.equals(ImageCapturingBaseTest.REFERENCE_DIR + "galaxy557x751Sat1X.png", Capture.image);
        Assert.equals(ComparatorResult.IDENTICAL, results);
    }
    
   /**
    * Given an image
    * When a Saturation HSV shader is applied to it with 2 times saturation
    * Then the image will match the reference image pixel for pixel.
    */
   function testSaturationShaderHSVX2() {
       // Create shader and apply to a test image and install in the GameHarness
       var gs = new SaturationShader(HSV);
       var testSprite = new FlxSprite();
       testSprite.loadGraphic("assets/images/galaxy557x400.png");
       testSprite.shader = gs;

       var sh = new StateHarness(testSprite);
       FlxG.switchState(sh);
       
       // Increase saturation
       gs.saturation = 2.0;

       // Need to run the game loop twice to be sure the image is rendered when capture runs
       // I don't actually know why which is not good. But I suspect the first is the initial
       // game loop and needs to setup stuff.
       _gameHarness.runGameLoop();
       
       Capture.prepare(Std.int(_gameHarness.width), Std.int(_gameHarness.height), true);
       _gameHarness.runGameLoop();
       Capture.wait();

       // To compare with reference
       var results = ImageComparator.equals(ImageCapturingBaseTest.REFERENCE_DIR + "galaxy557x751Sat2X.png", Capture.image);
       Assert.equals(ComparatorResult.IDENTICAL, results);
    }

    /**
     * Given an image
     * When a Saturation CSS shader is applied to it
     * Then the image will match the reference image pixel without any increase in saturation.
     */
    function testSaturationShaderCSSNoSat() {
        // Create shader and apply to a test image and install in the GameHarness
        var gs = new SaturationShader(CSS);
        var testSprite = new FlxSprite();
        testSprite.loadGraphic("assets/images/galaxy557x400.png");
        testSprite.shader = gs;

        var sh = new StateHarness(testSprite);
        FlxG.switchState(sh);

        // Need to run the game loop twice to be sure the image is rendered when capture runs
        // I don't actually know why which is not good. But I suspect the first is the initial
        // game loop and needs to setup stuff.
        _gameHarness.runGameLoop();
        
        Capture.prepare(Std.int(_gameHarness.width), Std.int(_gameHarness.height), true);
        _gameHarness.runGameLoop();
        Capture.wait();

        // To compare with reference
        var results = ImageComparator.equals(ImageCapturingBaseTest.REFERENCE_DIR + "galaxy557x751Sat1X.png", Capture.image);
        Assert.equals(ComparatorResult.IDENTICAL, results);
    }
    
   /**
    * Given an image
    * When a Saturation CSS shader is applied to it with 2 times saturation
    * Then the image will match the reference image pixel for pixel.
    */
   function testSaturationShaderCSSXPt4() {
       // Create shader and apply to a test image and install in the GameHarness
       var gs = new SaturationShader(CSS);
       var testSprite = new FlxSprite();
       testSprite.loadGraphic("assets/images/galaxy557x400.png");
       testSprite.shader = gs;

       var sh = new StateHarness(testSprite);
       FlxG.switchState(sh);
       
       // Increase saturation
       gs.saturation = 0.4;

       // Need to run the game loop twice to be sure the image is rendered when capture runs
       // I don't actually know why which is not good. But I suspect the first is the initial
       // game loop and needs to setup stuff.
       _gameHarness.runGameLoop();
       
       Capture.prepare(Std.int(_gameHarness.width), Std.int(_gameHarness.height), true);
       _gameHarness.runGameLoop();
       Capture.wait();

       // To compare with reference
       var results = ImageComparator.equals(ImageCapturingBaseTest.REFERENCE_DIR + "galaxy557x751SatCSSX4.png", Capture.image);
       Assert.equals(ComparatorResult.IDENTICAL, results);
   }
}