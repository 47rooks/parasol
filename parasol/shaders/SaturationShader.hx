package parasol.shaders;

import parasol.shaders.ParasolShader;

enum SaturationAlgorithm {
    /**
     * Simple RGB to HSV conversion, modify S value, convert back.
     */
    HSV;
    /**
     * Implementation of CSS saturate filter algorithm.
     * Refer https://www.w3.org/TR/filter-effects-1/#elementdef-fecolormatrix
     * for details.
     */
    CSS;
}

/**
 * Saturate or desaturate a sprite.
 * 
 * Saturation is controlled by directly setting the saturation property.
 */
class SaturationShader extends ParasolShader {

    /**
     * Saturation value. This is applied as a multiplier to the saturation value of
     * each pixel. Values should be between 0.0 and perhaps as much as 10.0 Values less
     * than one will reduce saturation while values greater than will increase it.
     * Values less than zero will be clamped to 0.0.
     */
    public var saturation(get, set):Float;

    @:parasolLibraryFunction('shaderlib.fs', 'rgb_to_hsv')
    @:parasolLibraryFunction('shaderlib.fs', 'hsv_to_rgb')
    @:parasolLibraryFunction('shaderlib.fs', 'css_saturate')
    @:parasolFragmentShader('saturation.fs')
    public function new(algorithm:SaturationAlgorithm=CSS) {
        super();
        u_saturation.value = [1.0];
        switch (algorithm) {
            case CSS:
                u_algorithm.value = [true];
            case HSV:
                u_algorithm.value = [false];
        }
    }

    function get_saturation():Float {
		return u_saturation.value[0];
	}

	function set_saturation(value:Float):Float {
		u_saturation.value[0] = Math.max(value, 0.0);
        return value;
	}
}