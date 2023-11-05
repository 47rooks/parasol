package examples.states;

import examples.states.ImagesState;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import parasol.shaders.ShakeShader;

/**
 * The ShakeShaderState provides the demo driver for the ShakeShader.
 */
class ShakeShaderState extends ImagesState {
    var _controls:Controls;
    var _shader:FlxShader;

    // Shake effect tunables
    var _blur:FlxUICheckBox;
    var _intensity:Float = 0.05;
    var _duration:Float = 0.5;

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new ShakeShader();

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 100, null, toggleShader);
        enableC.getLabel().size = 15;

        _blur = new FlxUICheckBox(Controls.LINE_X, 100, null, null, "Use blur", 100);
        _blur.getLabel().size = 15;

        var intensitySlider = new FlxSlider(this, "_intensity", Controls.LINE_X, 170.0, 0.00, 1.00, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		intensitySlider.setTexts("Intensity", true, "0.00", "1.00", 15);

        var durationSlider = new FlxSlider(this, "_duration", Controls.LINE_X, 230.0, 0.0, 5.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		durationSlider.setTexts("Duration (seconds)", true, "0.0", "5.0", 15);

        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Add blur while shaking
            _blur,
            // Intensity of shaking
            intensitySlider,
            // Duration of shake in seconds
            durationSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 310)
        ], _controlsCamera);

        add(_controls._controls);
    }

    /**
     * Toggle the shader on and off, callback for enable checkbox.
     */
     function toggleShader():Void {
        if (_sprite.shader == null) {
            _sprite.shader = _shader;
            cast(_sprite.shader, ShakeShader).shake(_intensity, _duration, _blur.checked);
        } else {
            _sprite.shader = null;
        }
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (_sprite.shader != null) {
            cast(_sprite.shader, ShakeShader).update(elapsed);
        }
    }
}