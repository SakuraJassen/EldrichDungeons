using BasicEngine;
using BasicEngine.GameStates;
using BasicEngine.Entity;
using BasicEngine.Console;
using EldrichDungeons.Entity;
using EldrichDungeons.Entity.TileEntity;
using SDL2;
using System;
using System.Collections;
using BasicEngine.Collections;

namespace EldrichDungeons
{
	class Simulating : GameState
	{
		public this()
		{		
			var bg = new TiledBackground();
			bg.mLayer = .BG1;
			gEngineApp.AddEntity(bg);

			InitGameRules();

			gGameApp.mCmd = new CommandHandler();
			gGameApp.mCmd.RegisterCommand(new EldrichDungeons.Console.Fill());
			gGameApp.mCmd.RegisterCommand(new EldrichDungeons.Console.AddCreature());
			gGameApp.mCmd.RegisterCommand(new EldrichDungeons.Console.Reseed());
			gGameApp.mCmd.RegisterCommand(new EldrichDungeons.Console.SmoothPoint());
			gGameApp.mCmd.RegisterVariable(new String("?tree"), new String()..AppendF("{}", (uint)TileEntity.TileType.Tree));
			gGameApp.mCmd.RegisterVariable(new String("?fire"), new String()..AppendF("{}", (uint)TileEntity.TileType.Fire));
			gGameApp.mCmd.RegisterVariable(new String("?width"), new String()..AppendF("{}", gGameApp.mGridSize.Width-1));
			gGameApp.mCmd.RegisterVariable(new String("?height"), new String()..AppendF("{}", gGameApp.mGridSize.Height-1));
			
			gGameApp.mCmd.RunCommand(ToStackString!("set CanGrow 1\n\r"));
			for(int i < 5)
			{
				gGameApp.mCmd.RunCommand("add", ToStackString!(250+gGameApp.mRand.Next(50)), ToStackString!(250+gGameApp.mRand.Next(50)));
			}
		}

		public override void InitGameRules()
		{
			base.InitGameRules();

			GameApp.GameRules.CanGrow = gEngineApp.mGameRules.mNamedIndices.AddSized("CanGrow", 1);
			GameApp.GameRules.CanIgnite = gEngineApp.mGameRules.mNamedIndices.AddSized("CanIgnite", 1);
			GameApp.GameRules.FireParticleCount = gEngineApp.mGameRules.mNamedIndices.AddSized("FireParticleCount", .Byte);

			gEngineApp.mGameRules.SetRange(GameApp.GameRules.FireParticleCount, 2);
		}

		public override void MouseDown(SDL2.SDL.MouseButtonEvent evt)
		{
			base.MouseDown(evt);
		}

		public override void MouseUp(SDL2.SDL.MouseButtonEvent evt)
		{
			base.MouseUp(evt);
			/*if(evt.button & SDL2.SDL.BUTTON_LMASK == 1) {
				Vector2D gridPos = scope .((int)(evt.x/gGameApp.mGridSize.mX), (int)(evt.y/gGameApp.mGridSize.mY));
				gGameApp.AddAt(gridPos, new Tree());
				System.Diagnostics.Debug.WriteLine("Released left");
			}*/
		}

		private TileEntity.TileType fill = .None;
		public override void HandleInput()
		{
			base.HandleInput();

			int32 x = 0;
			int32 y = 0;
			if ((SDL.GetMouseState(&x, &y) & SDL.BUTTON_RMASK) > 0) {
				Vector2D gridPos = scope .((int)(x/gGameApp.mTileSize.mX), (int)(y/gGameApp.mTileSize.mY));
				gGameApp.SaveAddTileEntity(gridPos, new Fire());

				if(fill == .None) {
					fill = .Fire;
				}
			} else if (SDL.GetMouseState(&x, &y) & SDL.BUTTON(SDL.BUTTON_LMASK) > 0) {
				Vector2D gridPos = scope .((int)(x/gGameApp.mTileSize.mX), (int)(y/gGameApp.mTileSize.mY));
				if(fill == .None) {
					var id = gGameApp.mTileList[(int)gridPos.mY, (int)gridPos.mX]?.ID;
					if(id == null)
						fill = .Tree;
					else
						fill = .Fire;
				}
				else
				{
					switch(fill)
					{
					case .Tree:
						gGameApp.SaveAddTileEntity(gridPos, new Tree());
					case .Fire:
						gGameApp.SaveAddTileEntity(gridPos, new Fire());
					default:
					}
				}

			} else if (fill != .None) {
				fill = .None;
			}
		}

		public override void Update(int dt)
		{
			base.Update(dt);
			{
				var x = gGameApp.mRand.Next((int32)gGameApp.mGridSize.Width);
				var y = gGameApp.mRand.Next((int32)gGameApp.mGridSize.Height);
				
				if(gGameApp.mGameRules.GetRangeAsBool(GameApp.GameRules.CanIgnite) && gGameApp.mRand.Next(100) < 1) {
					if(gGameApp.mTileList[y,x] is Tree)
						gGameApp.AddTileEntity(scope .(x,y), new Fire());
				} else if(gGameApp.mGameRules.GetRangeAsBool(GameApp.GameRules.CanGrow) && gGameApp.mRand.Next(100) < 60) {
					if(gGameApp.mTileList[y,x] == null)
						gGameApp.SaveAddTileEntity(scope .(x,y), new Tree());
				}
			}
		}

		/*public override void Draw(int dt)
		{
			base.Draw(dt);
			System.String str = scope .();
			var font = scope Font();
			font.Load("zorque.ttf", 10);
			SDL2.SDL.SetRenderDrawColor(gGameApp.mRenderer, 0,0,0,0);
			SDL2.SDL.RenderClear(gGameApp.mRenderer);
			for(int x < Noise.BasicNoise.cArrayWidth)
			{
				for(int y < Noise.BasicNoise.cArrayHeight)
				{
					str.Clear();
					str.Truncate(gGameApp.mNoiseGen[x,y,0], 4);
					BasicEngine.Painter.DrawString(gGameApp.mRenderer, font, x*36+10, y*36+10, str, .(64, 255, 192, 255));
				}
			}
			gGameApp.mNoiseGen.[Friend]smoothPoints();
			gGameApp.mPause = true;

		}*/
	}
}
