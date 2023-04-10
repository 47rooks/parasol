package examples.states;

import examples.states.ImagesState;
import flixel.FlxG;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import parasol.filters.MultiShaderFilter;
import parasol.shaders.GrayscaleShader;
import parasol.shaders.PixelationShader;

using flixel.util.FlxSpriteUtil;

/**
 * MultiShaderState controls the MultiShaderFilter example. This demonstrates how you can combine
 * two regular shaders into a single filter. In this example we use a grayscale and a pixelation
 * shader.
 */
class MultiShaderState extends ImagesState {
    var _filter:MultiShaderFilter;
    var _shaders:Array<FlxShader>;
    var _pixelation:PixelationShader;
    var _grayscale:GrayscaleShader;

    var _pixelSize:Float = 1.0;
    
    var _controls:Controls;

    override public function create() {
        super.create();

        final LINE_X = 50;

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Filter", 100, null, toggleFilter);
        enableC.getLabel().size = 15;
        
        var pixelationSlider = new FlxSlider(this, "_pixelSize", Controls.LINE_X, 100.0, 1.0, 200.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        pixelationSlider.setTexts("Pixelation: pixel size", true, "1.0", "200.0", 15);

            _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Add a slider to control the pixelation size
            pixelationSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 250)
        ], _controlsCamera);

        // Add controls to state
        add(_controls._controls);

        // Set up shaders and create the multi-shader filter
        _shaders = new Array<FlxShader>();
        _grayscale = new GrayscaleShader();
        _shaders.push(_grayscale);
        _pixelation = new PixelationShader(_sprite.width, _sprite.height);
        _shaders.push(_pixelation);
        // Add filter to camera
        _filter = new MultiShaderFilter(_shaders);
        _controlsCamera.filtersEnabled = false;
        FlxG.camera.setFilters([_filter]);
        FlxG.camera.filtersEnabled = false;
    }

    /**
     * Update the brightness and number of passes in the filter.
     * @param elapsed 
     */
    override public function update(elapsed:Float) {
        super.update(elapsed);

        _pixelation.pixelWidth = _pixelSize;
        _pixelation.pixelHeight = _pixelSize;
    }

    /**
     * Toggle the shader on and off, callback for enable checkbox.
     */
    private function toggleFilter() {
        FlxG.camera.filtersEnabled = !FlxG.camera.filtersEnabled;
    }
}