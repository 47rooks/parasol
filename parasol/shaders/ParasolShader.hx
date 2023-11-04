package parasol.shaders;


import flixel.system.FlxAssets.FlxShader;

#if !macro
@:autoBuild(parasol.macros.ParasolShaderMacro.build())
#end
class ParasolShader extends FlxShader {
	/**
     * This class provides a base class for shaders which are created
     * from GLSL text in a file. See parasol.macros.ParasolShaderMacro.hx
     * for details.
     * 
	 * Get or set the fragment source used when compiling with GLSL.
	 * This property is not available on the Flash target.
	 */
	public var parasolFragmentSource(get, set):String;
	public var parasolFunctionsSource(get, set):String;
	public var parasolFlixelFragmentHeader(get, set):String;

	@:noCompletion private var __parasolFunctionsSource:String;
	@:noCompletion private var __parasolFragmentSource:String;
	@:noCompletion private var __parasolFlixelFragmentHeader:String;

    /**
     * Creates a new Shader instance.
	 */
	public function new()
    {
        glFragmentSource = parasolFlixelFragmentHeader + parasolFunctionsSource + parasolFragmentSource;

        super();
    }

    @:noCompletion private function get_parasolFragmentSource():String
    {
        return __parasolFragmentSource;
    }

    @:noCompletion private function set_parasolFragmentSource(value:String):String
    {
        return __parasolFragmentSource = value;
    }

    @:noCompletion private function get_parasolFunctionsSource():String
    {
        return __parasolFunctionsSource;
    }
    
    @:noCompletion private function set_parasolFunctionsSource(value:String):String
    {
        return __parasolFunctionsSource = value;
    }

    @:noCompletion private function get_parasolFlixelFragmentHeader():String
    {
        return __parasolFlixelFragmentHeader;
    }

    @:noCompletion private function set_parasolFlixelFragmentHeader(value:String):String
    {
        return __parasolFlixelFragmentHeader = value;
    }
}
