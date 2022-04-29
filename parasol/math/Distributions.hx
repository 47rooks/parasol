package parasol.math;

/**
 * This class provides functions for generating and manipulating statistical distributions.
 */
class Distributions {
    /**
     * Evaluate the value of the Gaussian normal PDF for the specified mean and standard deviation at x.
     * Refer to:
     *     https://en.wikipedia.org/wiki/Normal_distribution
     *     https://www.itl.nist.gov/div898/handbook/eda/section3/eda3661.htm
     *
     * @param mean the mean of the distribution
     * @param stddev the standard deviation of the distribution. Must not be positive -
     * this restriction bypasses a mathematical complexity where sigma is 0.0, which in
     * any case is not a practical value for the current use cases.
     * @param x the point for which to calculate the value
     * @return Float the value of the Gaussian normal PDF
     */
    public static function evaluateNormalPDF(mean:Float, stddev:Float, x:Float):Float {
        if (stddev <= 0) {
            throw "stddev must be positive";
        }
        var a = (x - mean) / stddev;
        return 1 / (stddev * Math.sqrt(2 * Math.PI)) * Math.exp(-0.5 * a * a);
    }
}