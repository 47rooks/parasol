package examples.states;

import examples.states.DemoState;
import examples.states.MenuState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.StrNameLabel;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

typedef ImageData = { 
    var file: String; // the filename for the image
    var name: String;  // the name of the image
}

/**
 * ImageState is a FlxState providing a selection of images and sprite to which shader effects may be applied.
 */
class ImagesState extends DemoState {
    var _sprite:FlxSprite;

    var _bloomBrightnessThreshold:Float = 0.5;
    var _prevBrightnessThreshold:Float = 0.5;
    var _bloomBrightnessSlider:FlxSlider;

    var _controlsCamera:FlxCamera;

    final images:Array<ImageData> = [
        {
            "file": "assets/images/pexels-pixabay-2150.png",
            "name": "Spiral galaxy"
        },
        {
            "file": "assets/images/pexels-pixabay-73873.png",
            "name": "Solar flare"
        },
        {
            "file": "assets/images/GameTwo.png",
            "name": "Breakout"
        }
    ];

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        // Create a second camera for the controls so they will not be affected by filters.
        _controlsCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        _controlsCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(_controlsCamera, false);
        add(_controlsCamera);

        _sprite = new FlxSprite(0, 0);
        _sprite.loadGraphic(images[0].file);   // spiral galaxy
        // _sprite.cameras = [_controlsCamera];
        _sprite.cameras = [FlxG.camera];
        add(_sprite);
    }

    /**
     * Get the pulldown menu to select the image to apply the effect to.
     * @return FlxUIDropDownMenu
     */
    private function getImageChooser(xLoc:Float, yLoc:Float):FlxUIDropDownMenu {
        var imagePullDown = new FlxUIDropDownMenu(xLoc, yLoc, [for (img in images) new StrNameLabel(img.file, img.name)],
        (f) -> {
            _sprite.loadGraphic('${f}');
        },
        new FlxUIDropDownHeader(120, null, new FlxUIText(0, 0, 200, null, 12)));
        return imagePullDown;
    }
}

/**
 * Controls provide a sprite group which can contain a collection of controls which can control
 * the various aspects of the shader active in the demo.
 */
class Controls {
    public static final LINE_X = 50;
    public var _controls(default, null):FlxSpriteGroup;
    var _controlbg:FlxSprite;
    
    /**
     * Create a new Controls object.
     * @param xLoc the x position to place the group at.
     * @param yLoc the y position to place the group at.
     * @param xSize the width of the controls pane.
     * @param ySize the height of the controls pane.
     * @param uiElts an Array of FlxSprites to add to the control pane
     */
    public function new(xLoc:Float, yLoc:Float, xSize:Int, ySize:Int, uiElts:Array<FlxSprite>, camera:FlxCamera) {

        // Put a semi-transparent background in
        _controlbg = new FlxSprite(10, 10);
        _controlbg.makeGraphic(xSize, ySize, FlxColor.BLACK);
        _controlbg.alpha = 0.3;
        _controlbg.cameras = [camera];

        _controls = new FlxSpriteGroup(xLoc, yLoc);
        _controls.cameras = [camera];

        _controls.add(_controlbg);

        // Add controls
        for (ui in uiElts) {
            ui.cameras = [camera];
            _controls.add(ui);
        }

        var returnPrompt = new FlxText(LINE_X, ySize - 40, "Hit <ESC> to return to the menu", MenuState.BASE_FONT_SIZE);
        _controls.add(returnPrompt);
    }

    /**
     * Check if mouse overlaps the control area.
     * @return Bool true if mouse overlaps control area, false otherwise.
     */
    public function mouseOverlaps():Bool {
        
        return FlxG.mouse.overlaps(_controlbg);
    }
}