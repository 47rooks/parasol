package examples.states;

import examples.states.ImagesState;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import parasol.shaders.PixelationShader;

 /**
  * The PixelationShaderState provides the demo driver for the PixelationShader.
  */
class PixelationShaderState extends ImagesState {
    var _controls:Controls;
    var _shader:FlxShader;
    var _pixelSizeX:Float;
    var _pixelSizeY:Float;

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new PixelationShader(_sprite.width, _sprite.height, 100.0, 100.0);

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Effect", 100, null, toggleShader);
        enableC.getLabel().size = 15;

        var boxSizeXSlider = new FlxSlider(this, "_pixelSizeX", Controls.LINE_X, 100.0, 1.0, 200.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        boxSizeXSlider.setTexts("Box Size X", true, "1.0", "200.0", 15);

        var boxSizeYSlider = new FlxSlider(this, "_pixelSizeY", Controls.LINE_X, 170.0, 1.0, 200.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        boxSizeYSlider.setTexts("Box Size Y", true, "1.0", "200.0", 15);

        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Add slider for the pixel box width
            boxSizeXSlider,
            // Add slider for the pixel box height
            boxSizeYSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 250)
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
     * Update the pixelation sizes as required.
     * 
     * @param elapsed time since last update
     */
     override public function update(elapsed:Float) {
        super.update(elapsed);

        if (_sprite.shader != null) {
            cast(_shader, PixelationShader).pixelWidth = _pixelSizeX;
            cast(_shader, PixelationShader).pixelHeight = _pixelSizeY;
        }
    }
}