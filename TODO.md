# TODOs

In no particular order the following things need to be examined and notes, helpers and possibly demos have to be produced:

## Simpler Shader Problems
   * using multiple images, so you have the base image and a texture
   * metaballs - need this for blobby fluids
   * basic glow shader
   * camera filters

## Harder Problems
   * using multiple buffers for multi-pass effects, needs:
     * multiple sampler2D uniforms I expect, or some other way to create another buffer
     * a way to redirect the fragment output to a specific buffer
   * how to share shader code between multiple FlxShaders - couple of options - no idea what will work
     * read glsl code from files in a macro at compile time
     * somehow create multiple shader pieces with the existing macro support
     * some general way to separate GLSL code from Haxe code would be great
       * hopefully would facilitate the above
       * would permit sharing of GLSL to non-HaxeFlixel and non-Haxe code bases if uniforms were standardised or adapters written
   * Construct GLSL code at runtime rather than via the @:glFragmentSource/@:glVertexSource macros
   * there is a problem with array uniforms - this requires work on openfl though
   