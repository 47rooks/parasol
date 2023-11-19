package examples.states;

import examples.states.ImagesState.Controls;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import parasol.shaders.SaturationShader;

/**
 * The SaturationShaderState provides the demo driver for the SaturationShader.
 */
 class SaturationShaderState extends ImagesState {
    var _controls:Controls;
    var _shader:FlxShader;
	var _saturation:Float = 1.0;

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new SaturationShader(CSS);

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 100, null, toggleShader);
        enableC.getLabel().size = 15;

        var saturationSlider = new FlxSlider(this, "_saturation", Controls.LINE_X, 100.0, 0.0, 64.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		saturationSlider.setTexts("Saturation", true, "0.0", "100.0", 15);

        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Saturation value
            saturationSlider,
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

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (_sprite.shader != null)
        {
            // These fields should only be set when the slider changes but the slider has no callback
            cast(_shader, SaturationShader).saturation = _saturation;
        }
    }

}