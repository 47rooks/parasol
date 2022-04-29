package tests.unit.parasol.math;

import parasol.math.KernelBuilder;
import utest.Assert;
import utest.Test;

class KernelsTest extends Test {
    function testDefaultKernelSize9() {
        final expected = [0.000133830624614742, 0.00443186162003127, 0.0539909665131881, 0.241970724519143,
                          0.398942280401433,
                          0.241971445656601, 0.0539911274207044, 0.00443186162003127, 0.000133830624614742];
        var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                            .size(9).normalize(false).emit();
        assertKernel(expected, kernel);
    }

    /**
     * Test generation of the LearnOpenGL kernel - very close to the one in the
     * Bloom shader chapter in Learn Open GL.
     * Refer https://learnopengl.com/Advanced-Lighting/Bloom
     * Actual values [0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162]
     */
    function testLearnOpenGLKernel() {
        final expected = [0.0170186281053661, 0.0528663849966521, 0.118792870301754, 0.193088688600116,
                          0.227027771050871,
                          0.193088688600116, 0.118792870301754, 0.0528663849966521, 0.0170186281053661];

        var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(9).stddev(KernelBuilder.LEARN_OPENGL_KERNEL_SIGMA).normalize(false).emit();
        assertKernel(expected, kernel);
    }

    function testClamp7() {
        final expected = [0.00443184841193801, 0.0539909665131881, 0.241970724519143,
                          0.398942280401433,
                          0.241970724519143, 0.0539909665131881, 0.00443184841193801];

        var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(7).clamp().normalize(false).emit();
        assertKernel(expected, kernel);
    }

    function testClamp5() {
        final expected = [0.00664777261790701, 0.194276393498838,
                          0.598413420602149,
                          0.194276393498838, 0.00664777261790701];

        var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(5).clamp().normalize(false).emit();
        assertKernel(expected, kernel);
    }

    function testClamp4_5SigmaRange() {
        final expected = [0.0357071083151259, 0.238361226497662,
                          0.448810065451612,
                          0.238361226497662, 0.0357071083151259];

        var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(5).clamp().mean(1.0).stddev(1.0).range(4.5).normalize(false).emit();
        assertKernel(expected, kernel);
    }

    function testClamp0SigmaRange() {
        var kb = new KernelBuilder(KernelType.GAUSSIAN);
        Assert.raises(() -> {kb.size(5).clamp().mean(1.0).stddev(1.0).range(0.0).normalize(false).emit();});
    }

    function testNegativeSigmaRange() {
        var kb = new KernelBuilder(KernelType.GAUSSIAN);
        Assert.raises(() -> {kb.size(5).clamp().mean(1.0).stddev(1.0).range(-2.9).normalize(false).emit();}, "sigmaRange must be positive");
    }

    function testZeroStddev() {
        var kb = new KernelBuilder(KernelType.GAUSSIAN);
        Assert.raises(() -> {kb.size(7).stddev(0.0).normalize(false).emit();}, "sigma must be positive");
    }

    function testNormalizedDefault() {
        final expected = [0.0544886845496429, 0.244201342003233,
                          0.402619946894247,
                          0.244201342003233, 0.0544886845496429];

        var kernel = new KernelBuilder(KernelType.GAUSSIAN).size(5).emit();
        assertKernel(expected, kernel);
    }

    function testClampAndNormalize() {
        final expected = [0.0239774066611576, 0.0978427891123454, 0.227491300442007,
                          0.30137700756898,
                          0.227491300442007, 0.0978427891123454, 0.0239774066611576];

                          var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(7).clamp().range(4.5).emit();
        assertKernel(expected, kernel);
    }

    function testLargeKernel() {
        final expected = [0.00292138341559476, 0.00437031484895158, 0.006358770584403, 0.00899849441886468,
            0.0123851939264989, 0.0165795231321248, 0.0215862659443153, 0.0273350124459989,
            0.0336664475923431, 0.0403284540865239, 0.0469853125683838, 0.0532413342537254,
            0.0586775544607166, 0.0628972046154989, 0.06557328601699,
            0.0664903800669055,
            0.06557328601699, 0.0628972046154989, 0.0586775544607166, 0.0532413342537254,
            0.0469853125683838, 0.0403284540865239, 0.0336664475923431, 0.0273350124459989,
            0.0215862659443153, 0.0165795231321248, 0.0123851939264989, 0.00899849441886468,
            0.006358770584403, 0.00437031484895158, 0.00292138341559476];

            var kernel = new KernelBuilder(KernelType.GAUSSIAN)
                        .size(31).stddev(6.0).normalize(false).emit();
        assertKernel(expected, kernel);
    }

    /**
     * Check that kernel matches the expected kernel.
     * @param expected the expected kernel
     * @param kernel the kernel to check
     */
    private function assertKernel(expected:Array<Float>, kernel:Array<Float>) {
        Assert.equals(expected.length, kernel.length,
            'kernel length ${kernel.length} not equal to expected length ${expected.length}');
        for (i => e in kernel) {
            Assert.floatEquals(expected[i], e);
        }
    }
}