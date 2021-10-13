using BasicEngine;
using BasicEngine.GameStates;
using BasicEngine.LayeredList;
using BasicEngine.HUD;

using EldrichDungeons.Entity;
using EldrichDungeons.Entity.Map;
using EldrichDungeons.Entity.Tiles;
using System.Collections;
using BasicEngine.Entity;
using EldrichDungeons.RTSSystem;
using EldrichDungeons.Entity.RTSUnits;
using System;

namespace EldrichDungeons
{
	class Battle : GameState
	{
		public RTSSystem mRTSSystem = new RTSSystem() ~ SafeDelete!(_);

		public this()
		{
			InitGameRules();



			/*var unit = new RTSUnit();
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(8, 8));
			gEngineApp.AddEntity(unit);

			unit = new RTSUnit();
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(6, 8));
			gEngineApp.AddEntity(unit);

			/*unit = new RTSUnit() { mAttackReach = 2 };
			SafeMemberSet!(unit.mColor, new Color(0, 255, 0));
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(5, 8));
			gEngineApp.AddEntity(unit);*/

			unit = new RTSUnit();
			unit.SetForce(.Enemy);
			SafeMemberSet!(unit.mColor, new Color(255, 0, 0));
			SafeMemberSet!(unit.mAI, new BasicAI());
			mRTSSystem.SetToTile(unit, scope .(14, 8));
			gEngineApp.AddEntity(unit);

			unit = new RTSUnit();
			unit.SetForce(.Enemy);
			SafeMemberSet!(unit.mColor, new Color(255, 0, 0));
			SafeMemberSet!(unit.mAI, new BasicAI());
			mRTSSystem.SetToTile(unit, scope .(15, 8));
			gEngineApp.AddEntity(unit);*/

			List<RTSUnit> party = new List<RTSUnit>();
			var unit = new RTSUnit();
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(8, 8));
			party.Add(unit);
			gEngineApp.AddEntity(unit);

			unit = new RTSUnit();
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(6, 8));
			party.Add(unit);
			gEngineApp.AddEntity(unit);

			unit = new RTSUnit();
			unit.SetForce(.Friendly);
			mRTSSystem.SetToTile(unit, scope .(6, 8));
			party.Add(unit);
			gEngineApp.AddEntity(unit);

			mRTSSystem.Init(party);
		}

		public void UpdateSelectedTile()
		{
			mRTSSystem.UpdateSelectedTile();
		}

		public override void InitGameRules()
		{
			base.InitGameRules();

			GameApp.GameRules.TileWidth = gEngineApp.mGameRules.mNamedIndices.AddSized("TileWidth", .Byte);
			GameApp.GameRules.TileHeight = gEngineApp.mGameRules.mNamedIndices.AddSized("TileHeight", .Byte);

			gEngineApp.mGameRules.SetRange(GameApp.GameRules.TileWidth, (uint64)mRTSSystem.mTileSize.Width);
			gEngineApp.mGameRules.SetRange(GameApp.GameRules.TileHeight, (uint64)mRTSSystem.mTileSize.Height);
		}


		public override void Draw(int dt)
		{
			base.Draw(dt);

			if (gEngineApp.mGameRules.GetRangeAsBool(Engine.GameRules.DebugDisplayInfos))
			{
				let spacing = 28;
				DrawUtils.DrawString(gEngineApp.mRenderer, gEngineApp.mFont, 8, 4 + (spacing * 3), scope String()..AppendF("mousepos: {}, {}", mRTSSystem.mMousePos.mX, mRTSSystem.mMousePos.mY), .(32, 32, 32, 255));
				DrawUtils.DrawString(gEngineApp.mRenderer, gEngineApp.mFont, 8, 4 + (spacing * 4), scope String()..AppendF("CellPos: {}, {}", mRTSSystem.mSelectedTile?.mX, mRTSSystem.mSelectedTile?.mY), .(32, 32, 32, 255));
				DrawUtils.DrawString(gEngineApp.mRenderer, gEngineApp.mFont, 8, 4 + (spacing * 5), scope String()..AppendF("SelectedUnit: {}, {}", mRTSSystem.mSelectedUnit?.mPos.mX, mRTSSystem.mSelectedUnit?.mPos.mX), .(32, 32, 32, 255));
				DrawUtils.DrawString(gEngineApp.mRenderer, gEngineApp.mFont, 8, 4 + (spacing * 6), scope String()..AppendF("mStopUpdatingTile: {}", mRTSSystem.mStopUpdatingTile), .(32, 32, 32, 255));
			}
		}

		public override void Update(int dt)
		{
			base.Update(dt);
			mRTSSystem.Update(dt);
		}

		public override void MouseDown(SDL2.SDL.MouseButtonEvent evt)
		{
			base.MouseDown(evt);
			bool preventDefault = false;
			for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.HUD].mEntities)
			{
				if (let button = entity as BasicEngine.HUD.Button)
				{
					if (button.mEnabled && button.mVisiable)
					{
						if ((button.mBoundingBox.Contains((.)(evt.x - (entity.mPos.mX)), (.)(evt.y - (entity.mPos.mY)))))
						{
							preventDefault = button.onClick();

							if (preventDefault == false)
							{
								mRTSSystem.ResetState(mRTSSystem.mMousePos);
							}

							return;
						}
					}
				}
			}

			if (preventDefault == false)
				mRTSSystem.MouseDown(evt);
		}

		public override void MouseUp(SDL2.SDL.MouseButtonEvent evt)
		{
			base.MouseUp(evt);
		}

		private uint hoverDelay = 10;
		private List<HUDComponent> hoverActive = new List<HUDComponent>() ~ DeleteAndNullify!(_);
		public override void MouseMotion(SDL2.SDL.Event evt)
		{
			base.MouseMotion(evt);
			mRTSSystem.mMousePos.Set(evt.motion.x, evt.motion.y);

			if (--hoverDelay == 0)
			{
				for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.HUD].mEntities)
				{
					if (let ele = entity as BasicEngine.HUD.HUDComponent)
					{
						if (ele.mEnabled && ele.mVisiable && (ele.mBoundingBox.Contains((.)(mRTSSystem.mMousePos.mX - (entity.mPos.mX)), (.)(mRTSSystem.mMousePos.mY - (entity.mPos.mY)))))
						{
							ele.onHover();
							hoverActive.Add(ele);
						}
						else if (hoverActive.Contains(ele))
						{
							hoverActive.Remove(ele);
							ele.onHoverLeave();
						}
					}
				}
				hoverDelay = 2;
			}

			if (!mRTSSystem.mStopUpdatingTile)
				UpdateSelectedTile();
		}

		public override void HandleInput()
		{
			if (--mInputDelay > 0)
				return;
			if (gGameApp.IsKeyDown(.R))
			{
				mRTSSystem.mMap.Init();
				mInputDelay = 20;
			}
			if (gGameApp.IsKeyDown(.Escape))
			{
				mRTSSystem.CloseContextMenu();
				mRTSSystem.ClearOverlay();
				mRTSSystem.mSelectedUnit = null;
				mRTSSystem.mLastSelectedUnit = null;
				mInputDelay = 20;
			}
			if (gGameApp.IsKeyDown(.O))
			{
				let avrgFrameTime = scope String()..Truncate(gEngineApp.mFPSCounter.GetAvrgFrameTime(), 2);
				Log!(gEngineApp.mFPSCounter.FPS, avrgFrameTime);
				gEngineApp.mGameRules.SetRange(Engine.GameRules.DebugDisplayInfos, gEngineApp.mGameRules.GetRange(Engine.GameRules.DebugDisplayInfos));
			}
		}

	}
}
