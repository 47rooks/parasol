package tests.unit.parasol.shaders;

import parasol.shaders.LineShader;
import utest.Assert;
import utest.Test;

class LineShaderTest extends Test
{
	function testCreate()
	{
		var ls = new LineShader(0.0, 0.2, 1.0, 0.35, 640, 480);
		Assert.notNull(ls);
	}
}
