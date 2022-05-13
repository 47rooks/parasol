package examples.states;

import parasol.filters.BloomFilter;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxSlider;
import flixel.FlxG;
import flixel.util.FlxColor;
import examples.states.ImagesState;

using flixel.util.FlxSpriteUtil;

/**
 * BloomFilterState controls the BloomFilter example. It sets up controls to modify the brightness threshold
 * and the number of blur passes. Very high values will introduce noticeble lag.
 */
class BloomFilterState extends ImagesState {
    var _filter:BloomFilter;

    var _controls:Controls;

    static final INITIAL_BRIGHTNESS_THRESHOLD = 0.5;
    var _brightnessThreshold:Float = INITIAL_BRIGHTNESS_THRESHOLD;

    static final INITIAL_BLUR_PASSES = 2;
    static final MAX_BLUR_PASSES = 100;
    var _blurPasses:Int = INITIAL_BLUR_PASSES;

    override public function create() {
        super.create();

        final LINE_X = 50;

        // Create controls
        var enableC = new FlxUICheckBox(Controls.LINE_X, 50, null, null, "Enable Filter", 100, null, toggleFilter);
        enableC.getLabel().size = 15;
        
        var brightnessSlider = new FlxSlider(this, "_brightnessThreshold", Controls.LINE_X, 100.0, 0.0, 1.0, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        brightnessSlider.setTexts("Brightness Threshold", true, "0.0", "1.0", 15);

        var passesSlider = new FlxSlider(this, "_blurPasses", Controls.LINE_X, 170.0, 0, 100, 300, 15, 3, FlxColor.WHITE, FlxColor.WHITE);
        passesSlider.setTexts("Blur Passes", true, "0", "100", 15);

        _controls = new Controls(20, 100, 400, 400, [
            // Add a checkbox to turn the shader on and off
            enableC,
            // Add a slider for the brightness threshold
            brightnessSlider,
            // Add a slider for the number of blur passes
            passesSlider,
            // Add a pulldown to choose the image
            getImageChooser(Controls.LINE_X, 250)
        ], _controlsCamera);

        // Add controls to state
        add(_controls._controls);

        // Add filter to camera
        _filter = new BloomFilter(_sprite.width, _sprite.height, INITIAL_BRIGHTNESS_THRESHOLD, INITIAL_BLUR_PASSES);
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

        _blurPasses = correctBlurPasses();

        // Update the brightness threshold if it has changed
        _filter.update(_brightnessThreshold, _blurPasses);
    }

    /**
     * Toggle the shader on and off, callback for enable checkbox.
     */
    private function toggleFilter() {
        FlxG.camera.filtersEnabled = !FlxG.camera.filtersEnabled;
    }

	/**
	 * Make sure that blur passes is an even number between 0 and final INITIAL_BLUR_PASSES inclusive.
	 * @return Int the corrected value
	 */
	function correctBlurPasses():Int {
        _blurPasses = Math.floor(_blurPasses);
        if (_blurPasses < 0) return 0;
        if (_blurPasses > MAX_BLUR_PASSES) return MAX_BLUR_PASSES;
        if (_blurPasses % 2 != 0) return _blurPasses + 1;
        return _blurPasses;
    }
}