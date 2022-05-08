package parasol.shaders;

import flixel.system.FlxAssets.FlxShader;

import parasol.math.KernelBuilder;

/**
 * BlurShader produces a blur shader using a Gaussian kernel.
 * 
 * See https://learnopengl.com/Advanced-Lighting/Bloom for the approach to blurring that is used here.
 *    Plus Jonathan Hopkins comment on this on how to produce kernels, which is mostly how the kernel computation is done here.
 */
class BlurShader extends FlxShader {
    
    var _kernel:Array<Float>;  // Gaussian kernel weights
    
    @:glFragmentSource('
        #pragma header

        uniform vec2 u_texelSize;
        uniform mat4 u_kernel;
        uniform int u_kernelSize;
        uniform bool u_horizontal;

        void main()
        {
            vec3 sum = vec3(0);
            vec2 st = openfl_TextureCoordv.xy;  // Note, already normalized

            // Do center texel first
            sum += flixel_texture2D(bitmap, vec2(st.x, st.y)).rgb * u_kernel[0][0];

            if (u_horizontal) {
                for (int i=1; i < 16; i++) {   // columns
                    if (i >= u_kernelSize) {
                        break;
                    }
                    sum += flixel_texture2D(bitmap, vec2(st.x - i * u_texelSize.x, st.y)).rgb * u_kernel[i/4][mod(i,4)];
                    sum += flixel_texture2D(bitmap, vec2(st.x + i * u_texelSize.x, st.y)).rgb * u_kernel[i/4][mod(i,4)];
                }
            } else {
                for (int i=1; i < 16; i++) {
                    if (i >= u_kernelSize) {
                        break;
                    }
                    sum += flixel_texture2D(bitmap, vec2(st.x, st.y - i * u_texelSize.y)).rgb * u_kernel[i/4][mod(i,4)];
                    sum += flixel_texture2D(bitmap, vec2(st.x, st.y + i * u_texelSize.y)).rgb * u_kernel[i/4][mod(i,4)];
                }   
            }             
            gl_FragColor = vec4(sum, 1.0);
        }
    ')
    /**
     * Create a new BlurShader.
     * @param width width of the area over which the shader is to be applied. Used to compute the texel size.
     * @param height height of the area over which the shader is to be applied. Used to compute the texel size.
     */
    override public function new(width:Float, height:Float) {
        super();
        this.u_texelSize.value = [1.0 / width, 1.0 / height];

        // FIXME make kernel a constructor parameter - provide a way to just use a default
        var kb = new KernelBuilder(KernelType.GAUSSIAN);
        _kernel = kb.size(9).stddev(KernelBuilder.LEARN_OPENGL_KERNEL_SIGMA).emit();
        _kernel = padToMat4(upperHalf(_kernel));
        this.u_kernel.value = _kernel;
        this.u_kernelSize.value = [_kernel.length];
        this.u_horizontal.value = [false];  // Setting to false so that loops changing this immediately do horizontal first
    }

    /**
     * Pad out a float array to fill a mat4. If the input array has fewer than 16 elements
     * the returned array is padded with 0.0's up to 16. If the input array has more than
     * 16 elements those greater than 16 are discarded.
     * @param a the input array to be expanded
     * @return Array<Float> a 16 element array padded with 0.0 elements if necessary
     */
    private function padToMat4(a: Array<Float>):Array<Float> {
        var rv:Array<Float> = [];
        for (i in 0...16) {
            if (i > a.length) {
                rv.push(0.0);
            } else {
                rv.push(a[i]);
            }
        }
        return rv;
    }

    /**
     * Return a copy of the kernel array containing the middle value and
     * all values to the end of the array.
     * @param k the kernel construct the upper half from.
     * @return Array<Float>
     */
    private function upperHalf(k:Array<Float>):Array<Float> {
        return k.slice(Math.floor((k.length + 1) / 2) - 1);
    }
}