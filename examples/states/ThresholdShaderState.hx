package examples.states;

import flixel.system.FlxAssets.FlxShader;
import parasol.shaders.ThresholdShader;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import examples.states.ImagesState;

/**
 * The ThresholdShaderState provides the demo driver for the ThresholdShader.
 */
class ThresholdShaderState extends ImagesState {
    var _controls:Controls;
    var _shader:FlxShader;

    var _brightnessThreshold:Float = 0.5; // Initial threshold value
    var _prevThreshold:Float = 0.5;       // previous threshold value

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new ThresholdShader(0.8);

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 100, null, toggleShader);
        enableC.getLabel().size = 15;
        
        var brightnessSlider = new FlxSlider(this, "_brightnessThreshold", Controls.LINE_X, 100.0, 0.0, 1.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        brightnessSlider.setTexts("Brightness Threshold", true, "0.0", "1.0", 15);
        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Add a slider for the brightness threshold
            brightnessSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 200)
        ], _controlsCamera);

        add(_controls._controls);
    }

    /**
     * Toggle the shader on and off, callback for enable checkbox.
     */
     function toggleShader():Void {
        if (_sprite.shader == null) {
            _sprite.shader = _shader;
        } else {
            _sprite.shader = null;
        }
    }

    /**
     * If the threshold slider value changes propagate the change to the shader.
     * @param elapsed time since last update
     */
    override public function update(elapsed:Float) {
        super.update(elapsed);

        if (_prevThreshold != _brightnessThreshold) {
            cast(_shader, ThresholdShader).update(_brightnessThreshold);
            _prevThreshold = _brightnessThreshold;
        }
    }
}