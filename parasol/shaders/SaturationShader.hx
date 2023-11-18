package parasol.shaders;

import parasol.shaders.ParasolShader;

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
    @:parasolFragmentShader('saturation.fs')
    public function new() {
        super();
        u_saturation.value = [1.0];
    }

    function get_saturation():Float {
		return u_saturation.value[0];
	}

	function set_saturation(value:Float):Float {
		u_saturation.value[0] = Math.max(value, 0.0);
        return value;
	}
}