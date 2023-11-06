package examples.states;

import examples.states.ImagesState;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxAssets;
import flixel.text.FlxText;
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
    var _blurOffset:Float = 0.0;

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _shader = new ShakeShader();

        // Create controls
        var button = new FlxUIButton(Controls.LINE_X, 50, "Start shake", buttonCbk);
		button.resize(200, 40);
		button.setLabelFormat(14, FlxColor.BLACK, FlxTextAlign.CENTER);
		add(button);

        _blur = new FlxUICheckBox(Controls.LINE_X, 100, null, null, "Use blur", 100);
        _blur.getLabel().size = 15;

        var intensitySlider = new FlxSlider(this, "_intensity", Controls.LINE_X, 150.0, 0.0, 1.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		intensitySlider.setTexts("Intensity", true, "0.0", "1.0", 15);

        var durationSlider = new FlxSlider(this, "_duration", Controls.LINE_X, 210.0, 0.0, 5.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		durationSlider.setTexts("Duration (seconds)", true, "0.0", "5.0", 15);

        var blurOffsetSlider = new FlxSlider(this, "_blurOffset", Controls.LINE_X, 270.0, 0.0, 20.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
		blurOffsetSlider.setTexts("Blur offset (pixels)", true, "0.0", "20.0", 15);

        _controls = new Controls(20, 100, 400, 400, [
            // Add button to start shake
            button,
            // Add blur while shaking
            _blur,
            // Intensity of shaking
            intensitySlider,
            // Duration of shake in seconds
            durationSlider,
            // Blur offset
            blurOffsetSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 330)
        ], _controlsCamera);

        add(_controls._controls);
    }

    function buttonCbk():Void {
        _sprite.shader = _shader;
        cast(_sprite.shader, ShakeShader).shake(_intensity, _duration, _blur.checked, _blurOffset);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        if (_sprite.shader != null) {
            cast(_sprite.shader, ShakeShader).update(elapsed);
        }
    }
}