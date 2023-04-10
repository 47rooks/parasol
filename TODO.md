# TODOs

In no particular order the following things need to be examined and notes, helpers and possibly demos have to be produced:

## Simpler Shader Problems
   * create test images for BloomFilter
     * bunch of squares or different colors
     * a 2D scene - mostly fairly dark and a few highlights
   * using multiple images, so you have the base image and a texture
   * metaballs - need this for blobby fluids
   * automated testing for shaders and filters
     * use BitmapData.compare and reference images
     * construct reference images

## Harder Problems
   * FIXME Fix the fixes in the pixelation branch - this is an initial shader GLSL library function extractor
   * how to share shader code between multiple FlxShaders - couple of options - no idea what will work
     * read glsl code from files in a macro at compile time
     * somehow create multiple shader pieces with the existing macro support
     * some general way to separate GLSL code from Haxe code would be great
       * hopefully would facilitate the above
       * would permit sharing of GLSL to non-HaxeFlixel and non-Haxe code bases if uniforms were standardised or adapters written
   * Construct GLSL code at runtime rather than via the @:glFragmentSource/@:glVertexSource macros
   * there is a problem with array uniforms - this requires work on openfl though
   