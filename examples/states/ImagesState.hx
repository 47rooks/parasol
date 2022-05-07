package examples.states;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxSlider;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.StrNameLabel;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxSprite;
import examples.states.DemoState;
import examples.states.MenuState;

typedef ImageData = { 
    var file: String; // the filename for the image
    var name: String;  // the name of the image
}

/**
 * ImageState is a FlxState providing a selection of images and sprite to which shader effects may be applied.
 */
class ImagesState extends DemoState {
    var _sprite:FlxSprite;
    var _shader:FlxShader;

    var _shaderOn:FlxUICheckBox;

    var _bloomBrightnessThreshold:Float = 0.5;
    var _prevBrightnessThreshold:Float = 0.5;
    var _bloomBrightnessSlider:FlxSlider;

    final images:Array<ImageData> = [
        {
            "file": "assets/images/pexels-pixabay-2150.png",
            "name": "Spiral galaxy"
        },
        {
            "file": "assets/images/pexels-pixabay-73873.png",
            "name": "Solar flare"
        }
    ];

    override public function new() {
        super();
    }

    override public function create() {
        super.create();

        _sprite = new FlxSprite(0, 0);
        _sprite.loadGraphic(images[0].file);   // spiral galaxy
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

    /**
     * Toggle the shader on and off, callback for enable checkbox.
     */
    function toggleShader():Void {
        if (_sprite.shader == null) {
            _sprite.shader = _shader;
        } else {
            _sprite.shader = null;
        }
    }
}

/**
 * Controls provide a sprite group which can contain a collection of controls which can control
 * the various aspects of the shader active in the demo.
 */
class Controls {
    public static final LINE_X = 50;
    public var _controls(default, null):FlxSpriteGroup;

    /**
     * Create a new Controls object.
     * @param xLoc the x position to place the group at.
     * @param yLoc the y position to place the group at.
     * @param xSize the width of the controls pane.
     * @param ySize the height of the controls pane.
     * @param uiElts an Array of FlxSprites to add to the control pane 
     */
    public function new(xLoc:Float, yLoc:Float, xSize:Int, ySize:Int, uiElts:Array<FlxSprite>) {

        _controls = new FlxSpriteGroup();

        // Put a semi-transparent background in
        var controlbg = new FlxSprite(10, 10);
        controlbg.makeGraphic(xSize, ySize, FlxColor.BLACK);
        controlbg.alpha = 0.3;
        _controls.add(controlbg);

        // Add controls
        _controls = new FlxSpriteGroup(xLoc, yLoc);
        for (ui in uiElts) {
            _controls.add(ui);
        }

        _controls.add(new FlxText(LINE_X, ySize - 40, "Hit <ESC> to return to the menu", MenuState.BASE_FONT_SIZE));
    }
}