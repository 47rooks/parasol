package unit.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
/**
 * InstallCallout renames a specified function and creates a new function of the same name
 * which first calls a callout function and then calls the original function.
 * 
 * Currently both the replaced function and the callout function are fixed.
 * 
 * This macro must be invoked as an initialization macro from the haxe build command line
 * to ensure that it is active before the target class is typed.
 * 
 * For a flixel project add this to project.xml:
 *     <haxeflag name="--macro" value="addMetadata('@:build(unit.macros.InstallCallout.build(\'present\', \'unit.utils.Capture.capture\'))',
 *               'openfl.display3D.Context3D')" if="tests"/>
 */
class InstallCallout {
    /**
     * Create the replacement function and rename the original.
     * @param targetFunctionName the name of the function to replace
     * @param callout the function to be called by the replacement target function before
     * then calling the renamed original function. This must be fully module and class
     * qualified so that this InstallCallout does not need to import it.
     * @return Array<Field>
     */
    public static function build(targetFunctionName:String, callout:String): Array<Field> {

        var fields = Context.getBuildFields();
        var newFunctionName:String;
        if (fields != null) {
            for (f in fields) {
                // Rename the target function
                if (f.name == targetFunctionName) {
                    f.name = targetFunctionName + "0";
                    newFunctionName = f.name;
                    break;
                }
            }
            if (newFunctionName != "") {
                // Create a new function of the same name as the target
                // function which calls the callout and then the renamed
                // original function.
                var nf = {
                    name: targetFunctionName,
                    access: [APublic],
                    kind: FFun({
                        params: [],
                        args: [],
                        expr: macro { $p{callout.split('.')}(this);
                                      this.$newFunctionName();
                                    },
                        ret: macro: Void
                    }),
                    pos: Context.currentPos()
                };
                fields.push(nf);
                return fields;
            }
        }
        return fields;
    }
}
#end