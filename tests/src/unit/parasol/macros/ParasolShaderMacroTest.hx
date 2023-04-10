package unit.parasol.macros;


#if macro
import parasol.macros.ParasolShaderMacro;
#end
import haxe.ValueException;
import utest.Assert;
import utest.Test;

using haxe.macro.ExprTools;

class ParasolShaderMacroTest extends Test {
    /**
     * Wrapper macro function so that test functions can invoke the macro context function.
     * @return ExprOf<String>
     */
     @:access(parasol.macros.ParasolShaderMacro.getGLSLDirectory)
     static macro function macroGetGLSLDirectory():ExprOf<String> {
        return macro $v{ParasolShaderMacro.getGLSLDirectory()};
    }

    @:access(parasol.macros.ParasolShaderMacro.countBrace)
    static macro function macroCountBrace(s:String, opening:Bool = true):ExprOf<Int> {
        return macro $v{ParasolShaderMacro.countBrace(s, opening)};
    }

    @:access(parasol.macros.ParasolShaderMacro.countBraces)
    static macro function macroCountBraces(s:String):ExprOf<{netCount:Int, foundOpeningBrace:Bool}> {
        return macro $v{ParasolShaderMacro.countBraces(s)};
    }

    @:access(parasol.macros.ParasolShaderMacro.removeComment)
    static macro function macroRemoveComment(orig_line:String, inMultilineComment:Bool = false):ExprOf<{line:String, inMultilineComment:Bool}> {
        return macro $v{ParasolShaderMacro.removeComment(orig_line, inMultilineComment)};
    }

    @:access(parasol.macros.ParasolShaderMacro.extractFunction)
    static macro function macroExtractFunction(fileContent:String, functionName:String):ExprOf<String> {
        try {
            return macro $v{ParasolShaderMacro.extractFunction(fileContent, functionName)};
        } catch (ve:ValueException) {
            return macro $v{ve.value};
        };
    }

    @:access(parasol.macros.ParasolShaderMacro.getLibraryFunctionText)
    static macro function macroGetLibraryFunctionText(libraryFileName:String, functionName:String):ExprOf<String> {
        try {
            return macro $v{ParasolShaderMacro.getLibraryFunctionText(libraryFileName, functionName)};
        } catch (ve:ValueException) {
            return macro $v{ve.value};
        };
    }

    /**
     * Given: the parasol library is installed
     * When: `ParasolShaderMacro.getGLSLDirectory()` is called
     * The: `parasol/shaders/glsl` is returned
     */
    function testGetGLSLDirectory() {
        var dir = ParasolShaderMacroTest.macroGetGLSLDirectory();
        Assert.equals("parasol/shaders/glsl", dir);
    }
    
    /**
     * Given: A string containing no braces
     * When: `ParasolShaderMacro.countBrace` is called with opening true
     * Then: 0 is returned
     */
    function testCountBraceNoneOpening() {
        Assert.equals(0, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid main (void)", true));
    }

    /**
     * Given: A string containing no braces
     * When: `ParasolShaderMacro.countBrace` is called with opening false
     * Then: 0 is returned
     */
    function testCountBraceNoneEmptyNotOpening() {
        Assert.equals(0, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid main (void)", false));
    }

    /**
     * Given: A string containing 3 opening braces
     * When: `ParasolShaderMacro.countBrace` is called with opening true
     * Then: 3 is returned
     */
     function testCountBraceThreeOpOpening() {
        Assert.equals(3, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid { main { (void) { ", true));
    }

    /**
     * Given: A string containing 3 closing braces
     * When: `ParasolShaderMacro.countBrace` is called with opening false
     * Then: 3 is returned
     */
    function testCountBraceThreeClsNotOpening() {
        Assert.equals(3, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid } main } (void) } ", false));
    }

    /**
     * Given: A string containing 3 opening braces
     * When: `ParasolShaderMacro.countBrace` is called with opening false
     * Then: 0 is returned
     */
    function testCountBraceThreeOpNotOpening() {
        Assert.equals(0, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid { main { (void) { ", false));
    }

    /**
     * Given: A string containing 3 closing braces
     * When: `ParasolShaderMacro.countBrace` is called with opening true
     * Then: 0 is returned
     */
    function testCountBraceThreeClsOpening() {
        Assert.equals(0, ParasolShaderMacroTest.macroCountBrace("/* cmt */ \nvoid } main } (void) } ", true));
    }

    /**
     * Given: A string containing 2 opening and 3 closing braces
     * When: `ParasolShaderMacro.countBraces` is called
     * Then: `{netCount: -1, foundOpeningBrace:true}` is returned
     */
    function testCountBracesTwoOpenThreeClosing() {
        var rv = ParasolShaderMacroTest.macroCountBraces("/* cmt */ \nvoid } main { } (void) { } ");
        Assert.equals(-1, rv.netCount);
    }

    /**
     * Given: A string containing 0 opening and 3 closing braces
     * When: `ParasolShaderMacro.countBraces` is called
     * Then: `{netCount: -3, foundOpeningBrace:false}` is returned
     */
    function testCountBracesThreeClosing() {
        var rv = ParasolShaderMacroTest.macroCountBraces("/* cmt */ \nvoid } main } (void) } ");
        Assert.equals(-3, rv.netCount);
    }

    /**
     * Given: A line with one character `a`
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: 'a', inMultilineComment:false}` should be returned
     */
    function testRemoveCommentSingleAFalse() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('a', false);
        Assert.equals('a', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: A line with one character `z`
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=true`
     * Then: `{line: '', inMultilineComment:true}` should be returned
     */
    function testRemoveCommentSingleZTrue() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('z', true);
        Assert.equals('', rv.line);
        Assert.isTrue(rv.inMultilineComment);
    }

    /**
     * Given: A line with no comment markers
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: the whole of the line is returned, inMultilineComment:false}` should be returned
     */
    function testRemoveCommentLineNoCmtFalse() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this is the world ()', false);
        Assert.equals('hello this is the world ()', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: A line with no comment markers
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=true`
     * Then: `{line: '', inMultilineComment:true}` should be returned
     */
    function testRemoveCommentLineNoCmtTrue() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this is the world ()', true);
        Assert.equals('', rv.line);
        Assert.isTrue(rv.inMultilineComment);
    }

    /**
     * Given: A line with /* comment marker at one point in it
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: 'line up to the character before the comment marker', inMultilineComment:true}` should be returned
     */
    function testRemoveCommentLineOpenCmtFalse() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this is /* the world main()', false);
        Assert.equals('hello this is ', rv.line);
        Assert.isTrue(rv.inMultilineComment);
    }

    /**
     * Given: A line with end of multiline comment marker at one point in it
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=true`
     * Then: `{line: 'line after the end of comment marker', inMultilineComment:false}` should be returned
     */
    function testRemoveCommentLineCloseCmtTrue() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this is */ the world main()', true);
        Assert.equals(' the world main()', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: A line with a complete multiline comment in it
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: 'the text outside the comment markers', inMultilineComment:false}` should be returned
     */
    function testRemoveCommentLineWithEmbeddedCommentTrue() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this /* is the world */ main()', false);
        Assert.equals('hello this  main()', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: A line with an incorrect multiline comment marker / * in it.
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: 'all text returned', inMultilineComment:false}` should be returned
     */
    function testRemoveCommentInvalidCmtMarkerTrue() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this / * is the world main()', false);
        Assert.equals('hello this / * is the world main()', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: A line with an end of line comment marker in it.
     * When: `ParasolShaderMacro.removeComment` is called with `inMultilineComment=false`
     * Then: `{line: 'all text up until // returned', inMultilineComment:false}` should be returned
     */
    function testRemoveCommentEOLCmtMarkerFalse() {
        var rv = ParasolShaderMacroTest.macroRemoveComment('hello this // is the world main()', false);
        Assert.equals('hello this ', rv.line);
        Assert.isFalse(rv.inMultilineComment);
    }

    /**
     * Given: a string with a function in it
     * When: `ParasolShaderMacro.extractFunction` is called with the function name
     * Then: the function text is returned
     */
    function testExtractFunction() {
        var rv = ParasolShaderMacroTest.macroExtractFunction("
            // This is a main function
            void main(void)
            {
                int a = 0; // init. a
            }", "main");
        Assert.match(
            ~/\s+void main\(void\)(\r|\n)\s+\{(\r|\n)\s+int a = 0;\s+(\r|\n)\s+\}/i, rv);
    }

    /**
     * Given: a string with a function in it
     * When: `ParasolShaderMacro.extractFunction` is called with a different function name
     * Then: `ValueException` is thrown indicating the function is not found
     */
    function testExtractFunctionWrongName() {
        Assert.equals("Function foo was not found in file content provided.", ParasolShaderMacroTest.macroExtractFunction("
                // This is a main function
                void main(void)
                {
                    int a = 0; // init. a
                }", "foo"));
    }

    /**
     * Given: a string with a function in it with missing closing brace
     * When: `ParasolShaderMacro.extractFunction` is called with a the function name
     * Then: `ValueException` is thrown indicating the full function could not be found
     */
    function testExtractFunctionNoClosingBrace() {
        var rv = ParasolShaderMacroTest.macroExtractFunction("
                // This is a main function
                void foo(void)
                {
                    int a = 0; // init. a
                ", "foo");
        Assert.match(~/Did not get a full function \(braces=1,.*/, rv);
    }

    /**
     * Given: a string with a function in it with an extra closing brace
     * When: `ParasolShaderMacro.extractFunction` is called with a the function name
     * Then: `ValueException` is thrown indicating the full function could not be found
     */
    function testExtractFunctionExtraClosingBrace() {
        var rv = ParasolShaderMacroTest.macroExtractFunction("
                // This is a main function
                void foo(void)
                {
                    int a = 0; // init. a
                }}", "foo");
        Assert.match(~/Did not get a full function \(braces=-1,.*/, rv);
    }

    /**
     * Given: a string with a function in it with multiline and single line comments in it
     * When: `ParasolShaderMacro.extractFunction` is called with a the function name
     * Then: the function is returned
     */
    function testExtractFunctionMultipleComments() {
        var rv = ParasolShaderMacroTest.macroExtractFunction("
                // This is a main function
                void foo(void)
                {
                    /*
                     * This is a multi-line comment.
                     */
                    int a = 0; // init. a
                }", "foo");
        Assert.match(
            ~/\s+void foo\(void\)(\r|\n)\s+\{(\r|\n)\s+int a = 0;\s+(\r|\n)\s+\}/i, rv);
    }

    /**
     * Given: a library file with multiple functions and boilerplate comments
     * When: `ParasolShaderMacro.getLibraryFunctionText` is called for one of the functions
     * Then: the function text is returned
     */
    // function testGetLibraryFunctionText() {
    //     var rv = ParasolShaderMacroTest.macroGetLibraryFunctionText("testLib.", "testFunc");
    //     // Assert.match();
    // }

    /**
     * Given: a library file with multiple functions and boilerplate comments
     * When: `ParasolShaderMacro.getLibraryFunctionText` is called for function that does not exist in the file
     * Then: an exception is thrown indicating the function does not exist in that library
     */

    /**
     * Given: a library file
     * When: `ParasolShaderMacro.getLibraryFunctionText` for a non-existent library file
     * Then: an exception is thrown indicating the file does not exist
     */

    /**
     * Given: a file with a main shader function in it
     * When: `ParasolShaderMacro.getShaderText` is called
     * Then: the function text is returned
     */

    /**
     * Given: a file with no shader function in it
     * When: `ParasolShaderMacro.getShaderText` is called
     * Then: an exception is thrown indicating there is no function in the file
     */

    /**
     * Given: a non-existent file
     * When: `ParasolShaderMacro.getShaderText` for a non-existent file
     * Then: an exception is thrown indicating the file does not exist
     */
}


