package parasol.math;

import parasol.math.Distributions;

/**
 * Types of kernel
 */
enum KernelType {
    GAUSSIAN;   // The Gaussian or normal distribution.
}

/**
 * The KernelBuilder class provides a builder for kernels with a fluent chaining API.
 * For GAUSSIAN kernel these are the defaults:
 *      size - no default - must be specified
 *      clamp - false
 *      mean - 0.0
 *      sigma - 0.0
 *      range - 6
 *      normalize - true
 * 
 * Refer to the individual APIs for the details of specifying each parameter.
 * 
 * Example:
 *       var kernel = new KernelBuilder(KernelType.GAUSSIAN)
 *                       .size(5).stddev(2.0).normalize(false).emit();
 *
 *   will produce a kernel of 5 values from a normal distribution with mean of 0.0
 * and standard deviation of 2.0 not normalized.
 */
class KernelBuilder {
    public static final LEARN_OPENGL_KERNEL_SIGMA = 1.75724; // The default approximates Joey De Vries sigma value in the Learning OpenGL bloom filter.

    final _type:KernelType;
    var _size:Int;
    var _clamp:Bool = false;
    var _mean:Float = 0.0;
    var _sigma:Float = 1.0;
    var _sigmaRange:Float = 6;
    var _normalize:Bool = true;

    /**
     * Constructor
     * @param type the type of kernel to construct 
     */
    public function new(type:KernelType) {
        this._type = type;
    }

    /**
     * Set the kernel size.
     * @param k the kernel size, must be odd.
     * @return KernelBuilder
     */
    public function size(k:Int):KernelBuilder {
        if (k < 1 ) {
            throw "kernel size k must be at least one";
        }
        if (k % 2 == 0) {
            throw "kernel size k must be an odd number";
        }
        this._size = k;
        return this;
    }

    /**
     * Map the specified sigmaRange of the distribution onto the kernel size.
     * For example if clamp() is called and sigmaRange is 6 then 6 sigma range of the PDF is corresponds to
     * the k elements of the kernel.
     * If sigmaRange() is not called a default range of 6.0 sigma is used.
     * If not called independent mean and kernel size are used.
     * @return KernelBuilder
     */
    public function clamp():KernelBuilder {
        this._clamp = true;
        return this;
    }

    /**
     * Set the mean of the distribution.
     * @param mean the mean value. If not called the default is 0.0.
     * @return KernelBuilder
     */
    public function mean(mean:Float):KernelBuilder {
        this._mean = mean;
        return this;
    }

    /**
     * Set the standard deviation of the distribution.
     * @param sigma the standard deviation. If not called the default is 1.0.
     * @return KernelBuilder
     */
    public function stddev(sigma:Float):KernelBuilder {
        if (sigma <= 0.0) {
            throw "sigma must be positive";
        }

        _sigma = sigma;
        return this;
    }

    /**
     * Set the range of standard deviations to apply to map to the kernel size.
     * If clamp() is not also called this value is ignored.
     * @param sigmaRange the number of standard deviations to map. If not called the default 6.0.
     * @return KernelBuilder
     */
    public function range(sigmaRange:Float):KernelBuilder {
        if (sigmaRange <= 0.0) {
            throw "sigmaRange must be positive";
        }

        _sigmaRange = sigmaRange;
        return this;
    }

    /**
     * Return a normalized or raw kernel.
     * @param n if true normalize the array so that elements sum to 1.0, otherwise
     * return unnormalized values. If not called the default is true.
     * @return KernelBuilder
     */
    public function normalize(n:Bool = true):KernelBuilder {
        this._normalize = n;
        return this;
    }

    /**
     * Verify the kernel parameters are correct and emit the kernel.
     * @return Array<Float>
     */
    public function emit():Array<Float> {
        var rv:Array<Float>;
        switch (this._type) {
            case GAUSSIAN:
                return gaussianKernel(this._size, this._clamp, this._mean, this._sigma, this._sigmaRange, this._normalize);
        }
    }

    /**
     * Compute a Gaussian kernel for the specified properties.
     *
     * @param k the kernel size, must be odd.
     * @param clamp if true then sigmaRange must be specified, and sigmaRange of the distribution is mapped onto the kernel
     * size. For example if clamp is true and sigmaRange is 6 then 6 sigma range of the PDF is corresponds to the k pixels
     * of the kernel. If false, there sigma and k are independent and sigma must be provided.
     * @param sigma the sigma value of the distribution. Must be non-negative. Ignored if clamp is true.
     * @param sigmaRange the number of sigmas considered to cover the entire range of the Gaussian distribution.
     * Default is 6 which covers 99.7%. Ignored if clamp is false.
     * @param normalize if true normalize the array so that elements sum to 1.0.
     * @return Array<Float> the kernel values starting from pixel 0, the center and moving out pixel by pixel. The kernel
     * has (k+1)/2 values as the distribution is symmetric and thus only the center value and values from one side need be
     * returned.
     */
     private function gaussianKernel(k:Int, clamp:Bool, mean:Float, sigma:Float, sigmaRange:Float, normalize:Bool):Array<Float> {
        if (sigma <= 0.0) {
            throw "sigma must be positive";
        }
        if (sigmaRange <= 0.0) {
            throw "sigmaRange must be positive";
        }
        if (k < 1 ) {
            throw "kernel size k must be at least one";
        }
        if (k % 2 == 0) {
            throw "kernel size k must be an odd number";
        }

        var s:Float;
        if (clamp) {
            s = (k - 1) / sigmaRange;  // Make sure all stddevs map on kernel size
        } else {
            s = sigma;
        }
       
        var rv = new Array<Float>();
        rv.resize(k);  // Extend array to the size of the kernel
        var midpt = Math.floor((k + 1) / 2);
        for (x in 0...midpt) {
            // Use mean of 0.0 as the distribution is centered at the point we are blurring.
            var v = Distributions.evaluateNormalPDF(0, s, x);
            rv[midpt - 1 + x] = v;
            rv[midpt - 1 - x] = v;
        }
        if (normalize) {
            rv = normalizeKernel(rv);
        }
        return rv;
    }

    /**
     * Normalize a kernel (array of numbers) so the elements sum to 1.0.
     * The array is normalized in place.
     * @param k the array to normalize.
     * @return Array<Float> the array that was passed in, with all elements normalized.
     */
    static function normalizeKernel(k:Array<Float>):Array<Float> {
        var total = 0.0;
        for (i in 0...k.length) {
            total += k[i];
        }
        for (i in 0...k.length) {
            k[i] = k[i] / total;
        }
        return k;
    }
}