using System;
using System.Collections;
using BasicEngine.Console;

namespace EldrichDungeons.Console
{
	class Reseed : Command
	{
		public this() : base("reseed", 1, "reseeds the noiseGen") {

		}

		public override bool Run(List<String> args)
		{
			switch(int.Parse(args[1]))
			{
			case .Ok(let seed):
				gGameApp.mNoiseGen.Reseed(seed);
			case .Err: gGameApp.mNoiseGen.Reseed(gGameApp.mNoiseGen.[Friend]mSeed);
			}

			return true;
		}

		public override Command Create()
		{
			return new Self();
		}
	}
}
