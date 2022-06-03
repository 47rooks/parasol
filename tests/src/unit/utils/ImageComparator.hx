package unit.utils;

import lime.math.ARGB;
import openfl.display.BitmapData;

/**
 * PixelDiff structures contain the pixel x, y coordinates and the difference value.
 */
typedef PixelDiff = {
    /**
     * The x coordinate of the pixel.
     */
    x:Int,
    /**
     * The y coordinate of the pixel.
     */
    y:Int,
    /**
     * Reproduced from openfl.display.BitmapData.copy() function:
     *      If the pixel has different RGB values (ignoring the alpha value) in each bitmap,
     *        the difference pixel is 0xFFRRGGBB where RR/GG/BB are the individual difference
     *        values between red, green, and blue channels. Alpha channel differences are
     *        ignored in this case.
     *      If only the alpha channel value is different, the pixel value is 0xZZFFFFFF,
     *        where ZZ is the difference in the alpha value.
     */
    diff:ARGB,
}

/**
 * A ComparatorResult reports the result of comparison including supporting
 * information if any.
 */
enum ComparatorResult {
    /**
     * Bitmaps are identical.
     */
    IDENTICAL;
    /**
     * `actual` bitmap parameter is null
     */
    ACTUAL_NULL;
    /**
     * Bitmaps are not the same height.
     * 
     * @param refh is the height of the reference bitmap
     * @param acth is the height of the actual bitmap
     */
    DIFFERENT_HEIGHT(refh:Int, acth:Int);
    /**
     * Bitmaps are not the same width
     *     Widths are different,
     *         refw the width of the reference bitmap
     *         actw the width of the actual bitmap
     */
    DIFFERENT_WIDTH(refw:Int, actw:Int);
    /**
     * Some pixels are different, see PxielDiff for a description of the supporting data provided.
     */
    PIXELS_DIFFERENT(?data:Array<PixelDiff>);
    /**
     * Reference bitmap could not be loaded
     */
    REF_NOTLOADED;
    /**
     * Difference is unknown, see message provided
     */
    UNKNOWN(message:String);
    /**
     * Reference or actual bitmap cannot be read
     */
    UNREADABLE;
}

class ImageComparator {
    /**
     * Compare a bitmap with a reference bitmap loaded from a file
     * @param refPath reference bitmap file path
     * @param actual the actual bitmap to compare
     * @return ComparatorResult the result of the comparison
     */
    public static function equals(refPath:String, actual:BitmapData):ComparatorResult {

        var refBitmapData = BitmapData.fromFile(refPath);
        if (refBitmapData == null) {
            return ComparatorResult.REF_NOTLOADED;
        }
        var results = refBitmapData.compare(actual);

        if (Std.isOfType(results, Int)) {
            switch(cast(results, Int)) {
                case 0:    // refBitmap and actual point to the same entity
                           // or are actually distinct but identical
                    return ComparatorResult.IDENTICAL;
                case -1:   // actual is null
                    return ComparatorResult.ACTUAL_NULL;
                case -2:   // one of both bitmaps unreadable
                           // This should be impossible to hit because of the check above
                           // and the way the equals API works.
                    return ComparatorResult.UNREADABLE;
                case -3:   // different width images
                    return ComparatorResult.DIFFERENT_WIDTH(refBitmapData.width, actual.width);
                case -4:   // different height images
                    return ComparatorResult.DIFFERENT_HEIGHT(refBitmapData.height, actual.height);
            }
        } else if (Std.isOfType(results, BitmapData)) {
            var pd = new Array<PixelDiff>();
            var bmd:BitmapData = cast(results, BitmapData);

            for (i in 0...bmd.width) {
                for (j in 0...bmd.height) {
                    if (bmd.getPixel(i, j) != 0) {
                        pd.push({x:i, y:j, diff:bmd.getPixel(i, j)});
                    }
                }
            }
            return ComparatorResult.PIXELS_DIFFERENT(pd);
        }
        // This is an unexpected return type from BitmapData.compare. It should never
        // be hit but because the if cannot cover all possible types the Dynamic result
        // might take, we need this.
        return ComparatorResult.UNKNOWN("unknown reason for difference");
    }
}