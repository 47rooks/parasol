package unit.utils;

import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;

class ReferenceImageCreator {
    // FIXME create reference images based on a run and shader/filter application and collection of the 
    // reference image and dumping it to a file.

    final imgDir =  "tests\\reference\\";

    public function new() {}

    public function createImages() {
        var pixel = "00FF00FF";
        var imageString:String = "";

        for (i in 0...64) {
            imageString = imageString + pixel;
        }
        var bs = Bytes.ofHex(imageString);
        trace('bs=${bs}');
        var ba = ByteArray.fromBytes(bs);

        // Original green square base image
        var bmd = BitmapData.fromBytes(ba);
        writePNG(bmd, 8, 8, imgDir + "greenSquare.png");

        // Original green square base image with red pixel at (6, 4)
        ba[6*4] = 255;
        ba[6*4 + 1] = 0;
        bmd = BitmapData.fromBytes(ba);
        writePNG(bmd, 8, 8, imgDir + "greenSquareWithRedDot.png");

        // Original green square base image with transparent green pixel at (6, 4)
        ba[6*4] = 0;
        ba[6*4 + 1] = 255;
        ba[6*4 + 3] = 127;
        bmd = BitmapData.fromBytes(ba);
        writePNG(bmd, 8, 8, imgDir + "greenSquareWithAlphaPixel.png");
    }

    /**
     * Write the provided bitmap to a file as a PNG
     * @param bmd the BitmapData object to write out
     * @param width the width of the rect to write out
     * @param height the height of the rect to write out
     * @param filePath the file to write to
     */
    private function writePNG(bmd: BitmapData, width:Int, height:Int, filePath:String):Void {
        var tsba = new ByteArray();
        bmd.encode(new Rectangle(0, 0, width, height), new PNGEncoderOptions(), tsba);
        var tsb = Bytes.ofData(tsba);
        sys.io.File.saveBytes(filePath, tsb);
    }

    /**
     * Write the `Capture.image` to a file as a PNG.
     * Note this presumes that Capture is in use and has an image captured to write out.
     * 
     * @param rect the Rectangle portion to write out
     * @param filePath the file to write to
     */
    static public function writeCaptureToPNG(rect:Rectangle, filePath:String):Void {
        // To save a reference file
        // This is the currently functional way to save a bitmap to a png
        var tsba = new ByteArray();
        Capture.image.encode(rect, new PNGEncoderOptions(), tsba);
        trace('tsba size=${tsba.length}');
        var tsb = Bytes.ofData(tsba);
        sys.io.File.saveBytes(filePath, tsb);
    }
}