package unit.parasol.math;

import parasol.math.Distributions;
import utest.Assert;
import utest.Test;

class DistributionsTest extends Test {
    function testStandardNormal0() {
        var r = Distributions.evaluateNormalPDF(0, 1, 0);
        Assert.floatEquals(0.398942280401433, r);
    }

    function testNormal1() {
        var r = Distributions.evaluateNormalPDF(1, 1, 1);
        Assert.floatEquals(0.398942280401433, r);
    }
    
    function testNormalSigma0() {
        Assert.raises(() -> {Distributions.evaluateNormalPDF(0, 0, 0);}, "stddev must be positive");
    }

    function testNormal1_5() {
        var r = Distributions.evaluateNormalPDF(1, 1, 1.5);
        Assert.floatEquals(0.3520653267643, r);
    }
    
    function testNormalSigma12_5() {
        var r = Distributions.evaluateNormalPDF(1, 12.5, 1.5);
        Assert.floatEquals(0.0318898603363684, r);
    }

    function testNormalNeg3Sigma() {
        Assert.raises(() -> {Distributions.evaluateNormalPDF(1, -3, 0);}, "stddev must be positive");
    }

    function testNormaln1_1_0() {
        var r = Distributions.evaluateNormalPDF(-1, 1, 0);
        Assert.floatEquals(0.241970724519143, r);
    }

    function testNormaln2_1_0() {
        var r = Distributions.evaluateNormalPDF(-2, 1, 0);
        Assert.floatEquals(0.053990966513188, r);
    }

    function testNormal0_1_n4() {
        var r = Distributions.evaluateNormalPDF(0, 1, -4);
        Assert.floatEquals(0.000133830225765, r);
    }

    function testNormal0_1_n3() {
        var r = Distributions.evaluateNormalPDF(0, 1, -3);
        Assert.floatEquals(0.004431848411938, r);
    }

    function testNormal0_1_n2() {
        var r = Distributions.evaluateNormalPDF(0, 1, -2);
        Assert.floatEquals(0.053990966513188, r);
    }

    function testNormal0_1_n1() {
        var r = Distributions.evaluateNormalPDF(0, 1, -1);
        Assert.floatEquals(0.241970724519143, r);
    }

    function testNormal0_1_0() {
        var r = Distributions.evaluateNormalPDF(0, 1, 0);
        Assert.floatEquals(0.398942280401433, r);
    }

    function testNormal0_1_1() {
        var r = Distributions.evaluateNormalPDF(0, 1, 1);
        Assert.floatEquals(0.241970724519143, r);
    }

    function testNormal0_1_2() {
        var r = Distributions.evaluateNormalPDF(0, 1, 2);
        Assert.floatEquals(0.053990966513188, r);
    }

    function testNormal0_1_3() {
        var r = Distributions.evaluateNormalPDF(0, 1, 3);
        Assert.floatEquals(0.004431848411938, r);
    }

    function testNormal0_1_4() {
        var r = Distributions.evaluateNormalPDF(0, 1, 4);
        Assert.floatEquals(0.000133830225765, r);
    }
}