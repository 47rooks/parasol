package parasol.macros;


#if macro
import haxe.ValueException;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;
using haxe.macro.ExprTools;
using haxe.macro.Tools;
using haxe.macro.TypeTools;

@SuppressWarnings("checkstyle:FieldDocComment")
/**
 * Derived from OpenFL's ShaderMacro class this class provides support to load fragment
 * shaders from a library file and integrate them with Haxeflixel shader code. The objective is
 * to reduce code duplication by allowing reuse of individual GLSL functions in multiple shaders.
 * 
 * This macro is applied to subclasses of ParasolShader.
 */
class ParasolShaderMacro
{
	static var GLSL_DIRECTORY = "parasol/shaders/glsl";
	
	/**
	 * Process the @:parasol* macros to load shader and shader library functions
	 * and store the code read in member variables.
	 * 
	 * @return Array<Field>
	 */
	public static function build():Array<Field>
	{
		var fields = Context.getBuildFields();

		var parasolFlixelFragmentHeader = "";
		var parasolFragmentBody = "";

		var parasolFragmentSource = null;
		var parasolFunctionsSource = "";
		var parasolFragmentShader:String = null;

		for (field in fields)
		{
			for (meta in field.meta)
			{
				switch (meta.name)
				{
					case "parasolFragmentShader", ":parasolFragmentShader":
						parasolFragmentShader = meta.params[0].getValue();

					case "parasolLibraryFunction", ":parasolLibraryFunction":
						var fnSource = getLibraryFunctionText(meta.params[0].getValue(), meta.params[1].getValue());
						parasolFunctionsSource = parasolFunctionsSource + "\n" + fnSource;

					case "glFragmentHeader", ":glFragmentHeader":
						parasolFlixelFragmentHeader = meta.params[0].getValue();

						default:
				}
			}
		}

		var pos = Context.currentPos();
		var localClass = Context.getLocalClass().get();
		var superClass = localClass.superClass != null ? localClass.superClass.t.get() : null;
		var parent = superClass;
		var parentFields;

		while (parent != null)
		{
			parentFields = [parent.constructor.get()].concat(parent.fields.get());

			for (field in parentFields)
			{
				for (meta in field.meta.get())
				{
					switch (meta.name)
					{
						case "glFragmentHeader", ":glFragmentHeader":
							/* Capture the regular Flixel fragment header so that all the definitions
							 * can be put into the shader with parasol functions.
							 */
							parasolFlixelFragmentHeader = meta.params[0].getValue() + "\n" + parasolFlixelFragmentHeader;
						default:
					}
				}
			}

			parent = parent.superClass != null ? parent.superClass.t.get() : null;
		}

		if (parasolFragmentShader != null) {
			parasolFragmentSource = getShaderText(parasolFragmentShader);
		}

		if (parasolFragmentShader != null)
		{
			var shaderDataFields = new Array<Field>();
			var uniqueFields = [];

			processFields(parasolFragmentSource, "uniform", shaderDataFields, pos);

			if (shaderDataFields.length > 0)
			{
				var fieldNames = new Map<String, Bool>();

				for (field in shaderDataFields)
				{
					parent = superClass;

					while (parent != null)
					{
						for (parentField in parent.fields.get())
						{
							if (parentField.name == field.name)
							{
								fieldNames.set(field.name, true);
							}
						}

						parent = parent.superClass != null ? parent.superClass.t.get() : null;
					}

					if (!fieldNames.exists(field.name))
					{
						uniqueFields.push(field);
					}

					fieldNames[field.name] = true;
				}
			}

			// #if !display
			for (field in fields)
			{
				switch (field.name)
				{
					case "new":
						var block = switch (field.kind)
						{
							case FFun(f):
								if (f.expr == null) null;

								switch (f.expr.expr)
								{
									case EBlock(e): e;
									default: null;
								}

							default: null;
						}

						if (parasolFragmentSource != null)
						{
							block.unshift(macro if (__parasolFragmentSource == null)
							{
								__parasolFragmentSource = $v{parasolFragmentSource};
							});
						}
	

						if (parasolFunctionsSource != null)
						{
							block.unshift(macro if (__parasolFunctionsSource == null)
							{
								__parasolFunctionsSource = $v{parasolFunctionsSource};
							});
						}
		
						if (parasolFlixelFragmentHeader != null)
						{
							block.unshift(macro if (__parasolFlixelFragmentHeader == null)
							{
								__parasolFlixelFragmentHeader = $v{parasolFlixelFragmentHeader};
							});
						}

						block.push(Context.parse("__isGenerated = true", pos));
						block.push(Context.parse("__initGL ()", pos));

					default:
				}
			}
			// #end

			fields = fields.concat(uniqueFields);
		}

		return fields;
	}

	private static function processFields(source:String, storageType:String, fields:Array<Field>, pos:Position):Void
	{
		if (source == null) return;

		var lastMatch = 0, position, regex, field:Field, name, type;

		if (storageType == "uniform")
		{
			regex = ~/uniform ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}
		else
		{
			regex = ~/attribute ([A-Za-z0-9]+) ([A-Za-z0-9_]+)/;
		}

		var fieldAccess;

		while (regex.matchSub(source, lastMatch))
		{
			type = regex.matched(1);
			name = regex.matched(2);

			if (StringTools.startsWith(name, "gl_") || StringTools.startsWith(name, "openfl_"))
			{
				continue;
			}

			fieldAccess = APrivate;

			if (StringTools.startsWith(type, "sampler"))
			{
				field = {
					name: name,
					meta: [],
					access: [fieldAccess],
					kind: FVar(macro:openfl.display.ShaderInput<openfl.display.BitmapData>),
					pos: pos
				};
			}
			else
			{
				var parameterType:openfl.display.ShaderParameterType = switch (type)
				{
					case "bool": BOOL;
					case "double", "float": FLOAT;
					case "int", "uint": INT;
					case "bvec2": BOOL2;
					case "bvec3": BOOL3;
					case "bvec4": BOOL4;
					case "ivec2", "uvec2": INT2;
					case "ivec3", "uvec3": INT3;
					case "ivec4", "uvec4": INT4;
					case "vec2", "dvec2": FLOAT2;
					case "vec3", "dvec3": FLOAT3;
					case "vec4", "dvec4": FLOAT4;
					case "mat2", "mat2x2": MATRIX2X2;
					case "mat2x3": MATRIX2X3;
					case "mat2x4": MATRIX2X4;
					case "mat3x2": MATRIX3X2;
					case "mat3", "mat3x3": MATRIX3X3;
					case "mat3x4": MATRIX3X4;
					case "mat4x2": MATRIX4X2;
					case "mat4x3": MATRIX4X3;
					case "mat4", "mat4x4": MATRIX4X4;
					default: null;
				}

				switch (parameterType)
				{
					case BOOL, BOOL2, BOOL3, BOOL4:
						field = {
							name: name,
							meta: [{name: ":keep", pos: pos}],
							access: [fieldAccess],
							kind: FVar(macro:openfl.display.ShaderParameter<Bool>),
							pos: pos
						};

					case INT, INT2, INT3, INT4:
						field = {
							name: name,
							meta: [{name: ":keep", pos: pos}],
							access: [fieldAccess],
							kind: FVar(macro:openfl.display.ShaderParameter<Int>),
							pos: pos
						};

					default:
						field = {
							name: name,
							meta: [{name: ":keep", pos: pos}],
							access: [fieldAccess],
							kind: FVar(macro:openfl.display.ShaderParameter<Float>),
							pos: pos
						};
				}
			}

			field.meta = [{name: ":keep", pos: pos}];
	
			fields.push(field);

			position = regex.matchedPos();
			lastMatch = position.pos + position.len;
		}
	}

	/* ----- Shader library loading and parsing code ----- */

	/**
	 * Count occurrences of a character in the string `s`.
	 * @param s 
	 * @param opening search for opening brace `{`, `}` otherwise. 
	 * @return Int the number of that brace found
	 */
	static function countBrace(s:String, opening:Bool = true):Int {
		var rv:Int = 0;
		var char = opening ? '{' : '}';
		for (i in 0...s.length) {
			if (s.charAt(i) == char)
				rv++;
		}
		return rv;
	}
	
	/**
	 * Count the net number of opening and closing braces in a string. An opening
	 * brace adds 1 to the count and a closing brace subtracts 1.
	 * @param l the string to search
	 * @return {netCount:Int, foundOpeningBrace:Bool}, the number of braces found, and
	 * a boolean, true if an opening brace was found, false otherwise.
	 */
	private static function countBraces(l:String):{netCount:Int, foundOpeningBrace:Bool} {
		var foundBrace = false;
		var braces = countBrace(l, true);
		if (braces > 0) {
			foundBrace = true;
		}
		braces -= countBrace(l, false);
		return {netCount: braces, foundOpeningBrace: foundBrace};
	}

	/**
	 * Remove comment text from the line
	 * @param orig_line the line to process
	 * @param inMultilineComment true if at the beginning of this line the parsing is in a multi-line comment, false otherwise
	 * @return a structure containing the line stripped of comments and a boolean indicating if at the end of this line the parsing is in a multi-line comment
	 */
	private static function removeComment(orig_line:String, inMultilineComment:Bool = false):{line:String, inMultilineComment:Bool} {
		var rl = "";
		var imlc = inMultilineComment;
		var i = 0;
		if (orig_line.length == 1) {
			// handle a single character line as a special case
			if (!imlc) {
				rl += orig_line;
			}
		} else {
			while (i < (orig_line.length - 1)) {
				var fc = orig_line.charAt(i);
				var sc = orig_line.charAt(i+1);
				if (!imlc && fc == '/' && sc == '/') {
					// comment to end of line - discard
					break;
				} else if (!imlc && fc == '/' && sc == '*') {
					// start of multi-line comment
					imlc = true;
					i++;
				} else if (imlc && fc == '*' && sc == '/') {
					// end of multi-line comment
					imlc = false;
					i++;
				} else if (!imlc) {
					// program text - include it
					rl += fc;
					if (i == orig_line.length - 2) {
						// If this is the end of the line include the last character
					    rl += sc;
					}
				}
				i++;
			}
		}
		return {line: rl, inMultilineComment: imlc};
	}

	/**
	 * Extrace the source text of the named function from the file content string.
	 * @param fileContent the content of the library file
	 * @param functionName the function to extract. Function names are assumed to be unique in
	 * the file, which also means there must not be forward declarations in the file either.
	 * @return String the text of the function
	 */
	private static function extractFunction(fileContent:String, functionName:String):String {
		var func = [];
		var foundFn = false;
		var foundFirstBrace = false;
		var braces = 0;
		var inMultilineComment = false;
		for (i => raw_l in fileContent.split('\n')) {
			var rv = removeComment(raw_l, inMultilineComment);
			var l = rv.line;
			inMultilineComment = rv.inMultilineComment;
			if (l.trim().length == 0) {
				continue;
			}
			if (!foundFn && l.indexOf(functionName) != -1) {
				foundFn = true;
				func.push(l);
				var rv = countBraces(l);
				braces += rv.netCount;
				foundFirstBrace = rv.foundOpeningBrace;
			} else if (foundFn && !foundFirstBrace) {
				func.push(l);
				var rv = countBraces(l);
				braces += rv.netCount;
				foundFirstBrace = rv.foundOpeningBrace;
			} else if (foundFn && foundFirstBrace) {
				func.push(l);
				var rv = countBraces(l);
				braces += rv.netCount;
				if (braces == 0) {
					break;
				}
			}
		}
		if (braces != 0) {
			throw new ValueException('Did not get a full function (braces=${braces},\nfunction=${func.join("\n")})');
		}
		if (!foundFn) {
			throw new ValueException('Function ${functionName} was not found in file content provided.');
		}
		return func.join('\n');
	}

	/**
	 * Get a function from a library.
	 * @param libraryFileName library file containinng the function
	 * @param functionName the function to be extracted
	 * @return String the function text
	 */
	private static function getLibraryFunctionText(libraryFileName:String, functionName:String):String {
        var glslPath:String = Path.join([GLSL_DIRECTORY, libraryFileName]);

		// If file exists then extract the function from it
        if (FileSystem.exists(glslPath)) {
            // get the file content of the template 
            var fileContent:String = File.getContent(glslPath);
			var functionText = extractFunction(fileContent, functionName);
            return functionText;
        }
		throw new ValueException('glsl library file `${libraryFileName}` not found.');
	}
	
	/**
	 * Get primary shader (including `main` function) for a shader.
	 * @param glslFileName the shader filename, assumed to be in the `parasol\shader\glsl` directory.
	 * FIXME This is a problem for users loading shaders from their own projects. Strictly this
	 *       should be a full pathname to the file in the user case, but for parasol it has to be
	 *       relative to the `parasol` root directory.
	 * @return String the shader source text
	 */
	private static function getShaderText(glslFileName:String):String {
        var glslPath:String = glslFileName;
		if (Path.directory(glslPath) == "") {
			glslPath = Path.join([GLSL_DIRECTORY, glslPath]);
		}

		// If the file exists read the shader code and strip the IDE boilerplate
        if (FileSystem.exists(glslPath)) {
            // get the file content of the template 
            var fileContent:String = File.getContent(glslPath);
            var regex_exclude = ~/\/\/ PARASOL-EXCLUDE-START(.|\r|\n)*PARASOL-EXCLUDE-END(\r|\n)/;
			fileContent = regex_exclude.replace(fileContent, "");
			
            return fileContent;
        }
		throw new ValueException('Shader file `${glslFileName}` not found.');
	}
}
#end
