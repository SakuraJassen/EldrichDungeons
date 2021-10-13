using BasicEngine;
using System;

namespace EldrichDungeons
{
	class Program
	{
		public static void Main()
		{
			let gameApp = scope GameApp();
			SafeMemberSet!(gameApp.mTitle, new String("EldrichDungeons"));
			gameApp.Init();

			delete gameApp.mGameState;
			gameApp.mGameState = new Battle();

			gameApp.Run();
		}
	}
}
