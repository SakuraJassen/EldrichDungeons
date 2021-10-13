using System;
using System.Collections;
using BasicEngine.Console;

namespace EldrichDungeons.Console
{
	class SmoothPoint : Command
	{
		public this() : base("smooth", 1, "Smooths the noiseGen") {

		}

		public override bool Run(List<String> args)
		{
			switch(int.Parse(args[1]))
			{
			case .Ok(let bias):
				gGameApp.mNoiseGen.[Friend]smoothPoints((float)bias/100);
			case .Err: gGameApp.mNoiseGen.[Friend]smoothPoints(0.5f);
			}
			
			
			return true;
		}

		public override Command Create()
		{
			return new Self();
		}
	}
}
