using BasicEngine.HUD;
using BasicEngine;
using System.Collections;
using EldrichDungeons.RTSSystem;
using System;

namespace EldrichDungeons.HUD.Elements
{
	class ContextMenu : Form
	{
		private RTSSystem mRTSSystem = null;
		private RTSSystem.OverlayState mCurrentOpenContextMenuStatus = .Close;
		public RTSSystem.OverlayState CurrentOpenContextMenuStatus
		{
			get
			{
				return mCurrentOpenContextMenuStatus;
			}
		}

		private HUDComponent mAlignPoint = new HUDComponent() { mCenter = false } ~ SafeDelete!(_);

		public this(RTSSystem sys)
		{
			mRTSSystem = sys;

			for (var i < RTSSystem.OverlayState.Count)
				mComponentContainers.Add(new ComponentContainer());

			Formater f = scope Formater();
			f.xOffset = 100;
			f.yOffset = 0;
			f.compWidth = 100;
			f.combHeight = 25;
			f.xPadding = 5;
			f.yPadding = 10;

			mAlignPoint.mVisiable = false;
			mAlignPoint.Init();

			//None Submenu
			var btn = new BasicEngine.HUD.Button(new .(0, 0), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "End Turn");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.StartEnemyTurn();
					mRTSSystem.ResetState();
					return true;
				});
			mComponentContainers[(int)RTSSystem.OverlayState.None].Add(btn);

			//Move Submenu
			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "Move");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.MoveToTile(mRTSSystem.mSelectedUnit, new .(mRTSSystem.mSelectedTile));
					mRTSSystem.mSelectedUnit.mHasMoved = true;
					mRTSSystem.CloseContextMenu();
					mRTSSystem.ResetState();
					return true;
				});
			mComponentContainers[(int)RTSSystem.OverlayState.Move].Add(btn);

			f.columnIndex++;

			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "End Turn");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.StartEnemyTurn();
					mRTSSystem.ResetState();
					return true;
				});
			btn.mOffset.mY = f.combHeight + f.yPadding;
			mComponentContainers[(int)RTSSystem.OverlayState.Move].Add(btn);

			f.columnIndex = 0;
			//Attack Submenu
			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "Attack");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					if (mRTSSystem.AttackTile(mRTSSystem.mSelectedUnit, mRTSSystem.mSelectedTile))
					{
						mRTSSystem.mSelectedUnit.mHasAttacked = true;
						mRTSSystem.mSelectedUnit.mHasMoved = true;
					}
					mRTSSystem.CloseContextMenu();
					mRTSSystem.ResetState();
					return true;
				});
			mComponentContainers[(int)RTSSystem.OverlayState.Attack].Add(btn);

			f.columnIndex++;

			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "End Turn");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.StartEnemyTurn();
					mRTSSystem.ResetState();
					return true;
				});
			btn.mOffset.mY = f.combHeight + f.yPadding;
			mComponentContainers[(int)RTSSystem.OverlayState.Attack].Add(btn);

			f.columnIndex = 0;
			//Self Submenu
			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "Attack..");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.CloseContextMenu();
					mRTSSystem.mOverlayType = .Attack;
					mRTSSystem.mSelectedUnit = mRTSSystem.mLastSelectedUnit;
					mRTSSystem.mLastSelectedUnit = null;
					return true;
				});
			btn.mOffset.mY = (f.combHeight + f.yPadding) * f.columnIndex;
			mComponentContainers[(int)RTSSystem.OverlayState.Self].Add(btn);

			f.columnIndex++;

			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "Item..");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.CloseContextMenu();
					mRTSSystem.mQuickInv.SetIventory(mRTSSystem.mSelectedUnit.mInventory);
					mRTSSystem.mQuickInv.ChangePage(0);
					mRTSSystem.mQuickInv.OpenAt(scope Vector2D(mRTSSystem.mSelectedTile.mX * mRTSSystem.mTileSize.Width, mRTSSystem.mSelectedTile.mY * mRTSSystem.mTileSize.Height));
					mRTSSystem.mStopUpdatingTile = true;
					//rtsSystem.ResetState();
					return true;
				});
			btn.mOffset.mY = (f.combHeight + f.yPadding) * f.columnIndex;
			mComponentContainers[(int)RTSSystem.OverlayState.Self].Add(btn);

			f.columnIndex++;

			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "End Turn");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.StartEnemyTurn();
					mRTSSystem.ResetState();
					return true;
				});
			btn.mOffset.mY = (f.combHeight + f.yPadding) * f.columnIndex;
			mComponentContainers[(int)RTSSystem.OverlayState.Self].Add(btn);

			f.columnIndex = 0;
			//Place Submenu
			btn = new BasicEngine.HUD.Button(f.GetNewPos(), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "Place");
			btn.mParent = mAlignPoint;
			btn.mClickEvents.Add(new () =>
				{
					mRTSSystem.SetToTile(mRTSSystem.[Friend]mParty[mRTSSystem.mPlacedUnits], scope .(mRTSSystem.mSelectedTile));
					mRTSSystem.[Friend]mParty[mRTSSystem.mPlacedUnits].mVisiable = true;
					mRTSSystem.mPlacedUnits++;
					if (mRTSSystem.mPlacedUnits >= mRTSSystem.[Friend]mParty.Count)
					{
						mRTSSystem.mPlacedUnits = -1;
						mRTSSystem.ResetState();
						mRTSSystem.ClearOverlay();
						mRTSSystem.mMap.[Friend]minimumAlpha = 64;
						mRTSSystem.mMap.UpdateFogOfWar();
						mRTSSystem.OnBattleBegin();
					}
					mRTSSystem.CloseContextMenu();
					return false;
				});
			mComponentContainers[(int)RTSSystem.OverlayState.Place].Add(btn);

			SetVisibility(false);
			AddToEntityList();
		}

		public void SelectButton(RTSSystem.OverlayState type, int index)
		{
			if (mComponentContainers[(int)type].Count <= index)
				return;

			bool preventDefault = mComponentContainers[(int)type][index].onClick();

			if (preventDefault == false)
			{
				mRTSSystem.ResetState(mRTSSystem.mMousePos);
			}
		}

		public void OpenAt(Vector2D pos, RTSSystem.OverlayState type)
		{
			List<bool> enableMenu = scope List<bool>();
			for (var i < mComponentContainers.Count)
				enableMenu.Add(false);

			if (type != .Close)
				enableMenu[(int)type] = true;
			else
				mRTSSystem.mStopUpdatingTile = false;

			Log!(pos.mX, pos.mY, type);

			mCurrentOpenContextMenuStatus = type;
			for (var i < mComponentContainers.Count)
			{
				mComponentContainers[i].SetVisibility(enableMenu[i]);
				mComponentContainers[i].SetEnabled(enableMenu[i]);
			}

			if (mRTSSystem.mSelectedTile != null)
			{
				pos.Set(mRTSSystem.mSelectedTile);
				pos.mY *= mRTSSystem.mTileSize.Height;
				pos.mX *= mRTSSystem.mTileSize.Width;
			}
			mAlignPoint.mOffset.mX = pos.mX;
			mAlignPoint.mOffset.mY = pos.mY;
			mAlignPoint.CalculatePos();
		}
	}
}
