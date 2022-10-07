package;

import EquationSystem.ErrorData;
import haxe.Exception;

/**
 * EquationSystem exceptions are thrown as this type.
 * Refer to the definition of ErrorData to process this.
 */
class ESException extends Exception
{
	public var errorData(default, null):Null<Array<ErrorData>>;

	public function new(message:String, ?previous:Exception, ?native:Any, ?data:Array<ErrorData>)
	{
		super(message, previous, native);
		if (data != null)
		{
			errorData = data;
		}
	}
}
