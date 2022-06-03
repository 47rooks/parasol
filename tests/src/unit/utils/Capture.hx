package unit.utils;

import openfl.geom.Point;
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.geom.Rectangle;

/**
 * Capture is a simplistic capture tool which captures the OpenFL Context3D front buffer
 * to a BitmapData static which may be read from anywhere else.
 * 
 * This is not thread safe. There is no control over overwrite by subsequent calls.
 * This is normally installed using the InstallCallout macro. The test that uses this
 * callout must copy the bitmap elsewhere if preserving it is required.
 * 
 * In order to capture the fully rendered image this must be called before
 * Context3D.present() is called, or the buffer will have been cleared and it will
 * only capture an empty buffer.
 * 
 * Capture is enabled and disabled by setting the enabled boolean.
 */
class Capture {

    /**
     * The width of the image to capture from the buffer. Set before setting enabled.
     */
    public static var captureWidth:Int;
    /**
     * The height of the image to capture from the buffer. Set before setting enabled.
     */
    public static var captureHeight:Int;
    /**
     * Enable capture by setting to true, disable by setting false.
     */
    public static var enabled:Bool = false;

    /**
     * The captured image BitmapData. 
     */
    public static var image:BitmapData;

    /**
     * Capture an image of the current buffer. Capturing is only performed if enabled and if the 
     * width and height are both greater than 0.
     * @param ctx The rendering context. Used to perform the actual capture.
     */
    public static function capture(ctx:Context3D) {
        if (enabled && captureWidth > 0 && captureHeight > 0) {
            image = new BitmapData(captureWidth, captureHeight);
            ctx.drawToBitmapData(image, new Rectangle(0, 0, captureWidth, captureHeight), new Point(0,0));
        }
    }
}
