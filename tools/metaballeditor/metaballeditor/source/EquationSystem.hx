package;

import flixel.system.scaleModes.FixedScaleMode;
import polygonal.ds.ListSet;
import polygonal.ds.Set;

typedef Function =
{
	var fx:String;
	var formula:Formula;
}

typedef PiecewiseFunction =
{
	var fx:String;
	var formula:Formula;
	var domainVariable:String;
	var domainMinimum:Float;
	var domainMaximum:Float;
}

typedef ErrorData =
{
	var eqnNumber:Int;
	var eqnFieldNumber:Int;
	var errorPos:Int;
	var errorMsg:String;
}

/**
 * An EquationSystem is a system of equations subject to very specific
 * constraints. At present the constraints are hardcoded. They are:
 * 
 *    1. There is one output value. This may be defined through a single
 *       formula or as a piecewise function of several formulae,
 *    2. There are two independent input variables. This is driven by
 *       the current 2D graphics use case,
 *    3. There must be no cycles in the dependence of the equations.
 *    4. The falloff equations are represented separately from any, optional,
 *       coordinate transform equation.
 * 
 * Where functions are piecewise functions domains must be specified over
 * which each formula applies.
 */
class EquationSystem
{
	var _falloffFunctionsStr:Array<Array<String>>;
	var _falloffFunctions:Array<PiecewiseFunction>;
	var _xyTransformStr:Array<String>;
	var _xyTransform:Function;
	var _hasXYTransform:Bool;
	var _outputVariable:String;
	var _eqnParameters:Array<String>;
	var _domainVariables:Array<String>;
	var _inputVariables:Array<String>;

	public function new(falloffEqns:Array<Array<String>>, xyTransform:Array<String>)
	{
		_falloffFunctionsStr = falloffEqns;
		_xyTransformStr = xyTransform;
		_falloffFunctions = new Array<PiecewiseFunction>();

		// Process the equations to ensure we can create a
		// fully functional object.
		createFormulaFromInputs();
	}

	/**
	 * Convert the input string arrays of formulae to Formula objects. Collect up any error data
	 * so that it may be returned to the UI so that the user may correct the errors and resubmit it.
	 */
	private function createFormulaFromInputs():Void
	{
		var errors = new Array<ErrorData>();

		// Process the falloff equations
		for (i => ie in _falloffFunctionsStr)
		{
			// Assign initial values to each temporary variable
			var tFx:String = "";
			var tFormula:Null<Formula> = null;
			var tDomainVar:String = "";
			var tDomainMin:Float = Math.NaN;
			var tDomainMax:Float = Math.NaN;
			var formulaHasErrors:Bool = false;

			// Skip empty equations
			if (isArrayAllEmpty(ie))
			{
				continue;
			}
			for (j => s in ie)
			{
				switch (j)
				{
					case 0:
						// For now a simple single letter string will do
						if (s != null && s.length == 1)
						{
							tFx = s;
						}
						else
						{
							errors.push({
								eqnNumber: i,
								eqnFieldNumber: j,
								errorPos: -1,
								errorMsg: "fx variable must be a single alphabetical character"
							});
							formulaHasErrors = true;
						}
					case 1:
					// Skip - this is the boilerplate '=' character
					case 2:
						try
						{
							// Hopefully it pukes on empty strings
							tFormula = s;
						}
						catch (e:Dynamic)
						{
							errors.push({
								eqnNumber: i,
								eqnFieldNumber: j,
								errorPos: e.pos,
								errorMsg: 'formula error: ${e.msg}'
							});
							formulaHasErrors = true;
						}
					case 3:
						if (s != null)
						{
							if (s.length == 1)
							{
								tDomainVar = s;
							}
							else if (s.length == 0)
							{
								tDomainVar = null;
							}
						}
						else
						{
							tDomainVar = null;
							// errors.push({
							// 	eqnNumber: i,
							// 	eqnFieldNumber: j,
							// 	errorPos: -1,
							// 	errorMsg: "domain variable, if specified, must be a single alphabetical character"
							// });
							// formulaHasErrors = true;
						}
					case 4:
						tDomainMin = Std.parseFloat(s);
						if (tDomainVar != null && Math.isNaN(tDomainMin))
						{
							errors.push({
								eqnNumber: i,
								eqnFieldNumber: j,
								errorPos: -1,
								errorMsg: "domain minimum must be a real number"
							});
							formulaHasErrors = true;
						}
					case 5:
						tDomainMax = Std.parseFloat(s);
						if (tDomainVar != null && Math.isNaN(tDomainMax))
						{
							errors.push({
								eqnNumber: i,
								eqnFieldNumber: j,
								errorPos: -1,
								errorMsg: "domain maximum must be a real number"
							});
							formulaHasErrors = true;
						}
				}
			}
			if (!formulaHasErrors)
			{
				// Add equation to equations
				_falloffFunctions.push({
					fx: tFx,
					formula: tFormula,
					domainVariable: tDomainVar,
					domainMinimum: tDomainMin,
					domainMaximum: tDomainMax
				});
			}
		}

		// Process the xy transform if there is on
		if (_xyTransformStr.length > 0 && _xyTransformStr[0].length > 0 && _xyTransformStr[2].length > 0)
		{
			_xyTransform = {
				fx: _xyTransformStr[0],
				formula: _xyTransformStr[2]
			};
			// FIXME verify that the transform only refers to x and y
			// Create error if not
			_hasXYTransform = true;
		}

		// Handle any errors
		if (errors.length > 0)
		{
			_falloffFunctions = [];
			_xyTransform = null;
			throw new ESException("Error during formula creation", null, null, errors);
		}
	}

	/**
	 * Ensure that all elements in a particular equation line are empty. This is required
	 * because if a user deletes a line the input can come down to this part of the system
	 * as 0 length but non-null strings. Note also that the '=' element is deliberately skipped.
	 * This really should be handled in the UI layer.
	 * 
	 * @param ary the array of strings for the equation
	 * @return Bool true if all elements are either null or empty
	 */
	private function isArrayAllEmpty(ary:Array<String>):Bool
	{
		var rc:Bool = true;
		for (i => e in ary)
		{
			if (e != null && e != "=")
			{
				if (e.length > 0)
				{
					return false;
				}
			}
		}
		return rc;
	}

	/**
	 * Evaluate the equation system for a given point. The range of values must be between
	 * -1.0 and +1.0 for both x and y. Evaluation proceeds in these steps:
	 * 
	 *   1. bind x and y to the falloff equations if they appear there,
	 *   2. bind x and y to the transform equation if there is one,
	 *   3. evaluate the transform equation if there is one,
	 *   4. based on the result of the transform equation select the correct falloff equation
	 *      and bind the result to it
	 *   5. evaluate the falloff equation and return the value.
	 */
	public function evaluate(x:Float, y:Float):Float
	{
		// bind x and y, to both xy transform and to the falloff functions
		//    Note, this hardcodes the input variable names for now

		for (eqn in _falloffFunctions)
		{
			if (eqn.formula.params().contains("x"))
			{
				eqn.formula.bind(x, "x");
			}
			if (eqn.formula.params().contains("y"))
			{
				eqn.formula.bind(x, "y");
			}
		}
		if (_hasXYTransform)
		{
			if (_xyTransform.formula.params().contains("x"))
			{
				_xyTransform.formula.bind(x, "x");
			}
			if (_xyTransform.formula.params().contains("y"))
			{
				_xyTransform.formula.bind(y, "y");
			}
		}

		// Evaluate the xy transform
		var xyT = 0.0;
		var result:Float = 0.0;
		if (_hasXYTransform)
		{
			xyT = _xyTransform.formula.result;

			// Find the correct piecewise equation to evaluate
			for (eqn in _falloffFunctions)
			{
				if (eqn.domainVariable != "" && xyT >= eqn.domainMinimum && xyT < eqn.domainMaximum)
				{
					// Bind the transform value to the domain variable
					eqn.formula.bind(xyT, eqn.domainVariable);
					result = eqn.formula.result;
					break;
				}
			}
		}
		else
		{
			result = _falloffFunctions[0].formula.result;
		}

		return result;
	}
}
