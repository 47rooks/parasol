package examples.states;

import flixel.system.FlxAssets.FlxShader;
import parasol.shaders.GrayscaleShader;
import flixel.addons.ui.FlxUICheckBox;
import examples.states.ImagesState;

/**
 * The GrayscaleShaderState provides the demo driver for the GrayscaleShader.
 */
class GrayscaleShaderState extends ImagesState {
    var _controls:Controls;
    var _shader:FlxShader;

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new GrayscaleShader();

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 100, null, toggleShader);
        enableC.getLabel().size = 15;
        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
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
}