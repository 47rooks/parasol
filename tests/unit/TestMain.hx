package tests.unit;

import tests.unit.parasol.math.KernelsTest;
import tests.unit.parasol.math.DistributionsTest;
import tests.unit.parasol.shaders.LineShaderTest;
import utest.Runner;
import utest.ui.Report;

class TestMain
{
	public static function main()
	{
		var runner = new Runner();
		runner.addCase(new DistributionsTest());
		runner.addCase(new KernelsTest());
		runner.addCase(new LineShaderTest());
		Report.create(runner);
		runner.run();
	}
}
