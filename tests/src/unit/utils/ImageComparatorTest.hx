package unit.utils;

import openfl.Assets;
import unit.utils.ImageComparator.ComparatorResult;
import utest.Assert;
import openfl.display.BitmapData;
import utest.Test;

/**
 * Tests for the ImageComparator cases of interest.
 * Note that readonly objects are not tested for.
 */
class ImageComparatorTest extends Test {

    /**
     * Given a BitmapData object
     * When compared with an identical but distinct BitmapData object
     * Then true is returned
     */
    function testCompareIdentical() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        Assert.equals(ComparatorResult.IDENTICAL, ImageComparator.equals("tests/data/green.png", bmd));
    }

    /**
     * Given a reference image
     * When comparing to a null
     * Then false is returned and error information is output to stderr.
     */
    function testCompareToNull() {
        Assert.equals(ComparatorResult.ACTUAL_NULL,
                      ImageComparator.equals("tests/data/green.png", null));
    }

    /**
     * Given a BitmapData
     * When compare it with a reference which cannot be loaded (non-existent path)
     * Then false is returned and error information is output to stderr.
     */
    function testCompareToNonexistentRef() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        Assert.equals(ComparatorResult.REF_NOTLOADED,
                      ImageComparator.equals("tests/data/doesnotexist", bmd));
    }

    @Ignored("Not implemented yet")
    function compareSelfNotReadable() {}
    
    @Ignored("Not implemented yet")
    function compareOtherNotReadable() {}

    /**
     * Given images of different width
     * When ImageComparator.equals is called
     * Then false is returned and error information is output to stderr.
     */
    function testDifferentWidth() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        Assert.same(ComparatorResult.DIFFERENT_WIDTH(16, 8),
                      ImageComparator.equals("tests/data/16w8h.png", bmd));
    }

    /**
     * Given images of different height
     * When ImageComparator.equals is called
     * Then false is returned and error information is output to stderr.
     */
     function testDifferentHeight() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        var result = ImageComparator.equals("tests/data/8w16h.png", bmd);
        Assert.same(ComparatorResult.DIFFERENT_HEIGHT(16, 8), result);
    }

    /**
     * Given images of different width and height
     * When ImageComparator.equals is called
     * Then false is returned and error information is output to stderr.
     */
    function testDifferentWidthAndHeight() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        Assert.same(ComparatorResult.DIFFERENT_WIDTH(12, 8),
                      ImageComparator.equals("tests/data/12x12red.png", bmd));
    }

    /**
     * Given a pair images different only in one pixel color
     * When ImageComparator.equals is called
     * Then false is returned and error information is output to stderr.
     */
    function testPixelColorDifferent() {
        var bmd = Assets.getBitmapData("tests/data/green.png");
        var result = ImageComparator.equals("tests/data/redDotOnGreen.png", bmd);
        switch(result) {
            case PIXELS_DIFFERENT(data):
                Assert.equals(1, data.length);
                Assert.equals(6, data[0].x);
                Assert.equals(3, data[0].y);
                Assert.equals(4999953, data[0].diff);
            default:
                Assert.fail('unexpected result=${result}');
        }
    }

    /**
     * Given a pair of images different only in the alpha of a pixel
     * When ImageComparator.equals is called
     * Then false is returned and error information is output to stderr.
     */
     @Ignored("alpha testing images are not ready")
    function testPixelAlphaDifferent() {
        var bmd = BitmapData.fromFile("tests/data/green.png");
        var result = ImageComparator.equals("tests/data/greenWithTransparent.png", bmd);
        switch(result) {
            case PIXELS_DIFFERENT(data):
                Assert.equals(1, data.length);
                Assert.equals(6, data[0].x);
                Assert.equals(4, data[0].y);
                Assert.equals(65793, data[0].diff);
                trace('result data = ${StringTools.hex(data[0].diff, 8)}');
                trace('bmd pixel=${StringTools.hex(bmd.getPixel32(6,4))}');
            default:
                Assert.fail('unexpected result=${result}');
        }
    }
}