using System.Collections;
using BasicEngine;
using EldrichDungeons.Entity;
using System;
using BasicEngine.Collections;

namespace EldrichDungeons
{
	static
	{
		public static GameApp gGameApp;
	}

	class GameApp : BasicEngine.Engine
	{
		public Vector2D mScreenOffset = new Vector2D(0, 0) ~ SafeDeleteNullify!(_); 
		public BasicEngine.Noise.BasicNoise2D mNoiseGen = new BasicEngine.Noise.BasicNoise2D(Random.[Friend]sSeed, 1) ~ delete _;

		public static class GameRules
		{
			public static NamedIndex TileWidth = null;
			public static NamedIndex TileHeight = null;
		}

		public this()
		{
			gGameApp = this;
		}
	}
}
