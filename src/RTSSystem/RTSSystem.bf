using System.Collections;
using BasicEngine;
using BasicEngine.Entity;
using BasicEngine.LayeredList;
using EldrichDungeons.Entity.RTSUnits;
using EldrichDungeons.Entity.Map;
using EldrichDungeons.Entity.Tiles;
using SDL2;
using BasicEngine.HUD;
using System;
using System.Collections;
using System.Collections;
using System;
using EldrichDungeons.HUD.Elements;
using System.Collections;

namespace EldrichDungeons.RTSSystem
{
	class RTSSystem
	{
		// Map size in Tiles
		public Size2D mMapSize = new Size2D(16, 16) ~ DeleteAndNullify!(_);
		// Tile size in Pixels
		public Size2D mTileSize = new Size2D(32, 48) ~ DeleteAndNullify!(_);

		public bool mStopUpdatingTile = false;
		public int mPlacedUnits = 0;
		public Vector2D mSelectedTile = null ~ SafeDelete!(_);
		public RTSUnit mSelectedUnit = null ~ _ = null;
		public RTSUnit mLastSelectedUnit = null ~ _ = null;

		public enum OverlayState : uint8
		{
			None = 0,
			Move = 1,
			Attack = 2,
			Magic = 3,//unused
			Enemy = 4,
			Close = 5,
			Self = 6,
			Item = 7,
			Place = 8,
			Count
		}

		public OverlayState mOverlayType = .Move;
		public List<Entity> mOverlay = new List<Entity>() ~ DeleteAndNullify!(_);
		public OverlayTile mSelectedTileOverlay = null ~ _ = null;

		public TiledMap mMap = new TiledMap();

		/*public List<Entity>[,] mEntityList
		{
			get { return mMap.mEntityList; }
		}*/
		private List<RTSUnit> mParty = new List<RTSUnit>() ~ SafeDelete!(_);

		public int mTurnCounter = 1;
		public int mEnemyTurnCooldown = 0;
		public bool mEnemyTurn = false;

		public ContextMenu mContextMenu = new ContextMenu(this) ~ SafeDelete!(_);
		private StatPicker statPicker = new StatPicker() ~ SafeDelete!(_);
		public QuickInventory mQuickInv = new QuickInventory(5, null) ~ SafeDelete!(_);

		public Vector2D mMousePos = new Vector2D(0, 0) ~ SafeDelete!(_);

		public void Init(List<RTSUnit> party)
		{
			SafeMemberSet!(mParty, party);

			mMap.mLayer = .BG2;
			mMap.mTileSize.Set(mTileSize);
			mMap.mMapSize.Set(mMapSize);
			mMap.Init();

			mMapSize.Set(mMap.mMapSize);

			gEngineApp.AddEntity(mMap);

			OverlayTile t = new OverlayTile();
			t.mLayer = .FG4;
			t.mTileImage = ResourceLoader.LoadTexture("images/Overlay/SelectedCell.png");
			t.mCycleAlpha = false;
			if (mSelectedTile != null)
			{
				t.mPos.mX = mSelectedTile.mX * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth);
				t.mPos.mY = mSelectedTile.mY * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight);
			}
			mSelectedTileOverlay = t;
			gGameApp.AddEntity(t);
		}

		public void Update(int dt)
		{
			if (mEnemyTurn)
			{
				ClearOverlay();
				SafeDeleteNullify!(mSelectedTile);
				mSelectedUnit = null;
				mSelectedTileOverlay.mVisiable = false;

				if (--mEnemyTurnCooldown > 0)
					return;

				for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.MainLayer].mEntities)
				{
					if (let rtsunit = entity as EldrichDungeons.Entity.RTSUnits.RTSUnit)
					{
						if (rtsunit.mForce == .Enemy && (!rtsunit.mHasMoved || !rtsunit.mHasAttacked))
						{
							rtsunit.mAI.LogicStep(rtsunit, this);
							Log!(rtsunit.mAI.mAIState);
							mEnemyTurnCooldown = 30;
							return;
						}
					}
				}
				EndRound();
			}
			else if (mPlacedUnits >= 0)
			{
				if (!mStopUpdatingTile)
				{
					UpdateSelectedTile();
				}
				mParty[mPlacedUnits].SetGridPos(mSelectedTile);

				mParty[mPlacedUnits].mVisiable = true;

				// Update map with new Alpha Value;
				// The computational power required is negotiable but this function only has to run once
				ClearOverlay();
				mMap.[Friend]minimumAlpha = 255;
				mMap.UpdateFogOfWar();

				var overlayArray = getFloodFilledArray(5, mMap.SpawnPositions[0], .Place, true);

				for (var i < mPlacedUnits)
				{
					mParty[i].mVisiable = true;
					overlayArray[(int)mParty[i].mGridPos.mY, (int)mParty[i].mGridPos.mX] = 0;
				}

				for (int x < (int)mMapSize.Width)
				{
					for (int y < (int)mMapSize.Height)
					{
						if (overlayArray[y, x] > 0)
						{
							OverlayTile t = new OverlayTile();
							t.mLayer = .FG3;
							t.mTileImage = getOverlayTextureByType(.Place);
							t.SetBoundingBoxFromImage(t.mTileImage);
							t.mBoundingBox = SDL.Rect(0, 0, t.mTileImage.mSurface.w, t.mTileImage.mSurface.h);
							t.mPos.mX = x * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth);
							t.mPos.mY = y * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight);
							mOverlay.Add(t);
							gGameApp.AddEntity(t);
						}
					}
				}

				delete overlayArray;
			}
			else
			{
				if (!mStopUpdatingTile)
					UpdateSelectedTile();

				UpdateFogOfWar();

				if (mSelectedUnit != mLastSelectedUnit)
				{
					UpdateOverlay();
					statPicker.UpdateStatDisplay(mSelectedUnit);
				}
				if (mSelectedTile != null)
				{
					mSelectedTileOverlay.mVisiable = true;

					float xOffset = 190;
					if (mSelectedTile.mX < 6 && mSelectedTile.mY > 11)
					{
						if (statPicker.mOffsetted == false)
						{
							statPicker.mOffsetted = true;
							statPicker.Move(xOffset, 0);
							Log!("move right");
						}
					}
					else
					{
						if (statPicker.mOffsetted == true)
						{
							statPicker.mOffsetted = false;
							statPicker.Move(-xOffset, 0);
							Log!("move left");
						}
					}
				}
			}
		}

		public void SetToTile(RTSUnit e, Vector2D gridPos)
		{
			mMap.SetToTile(e, gridPos);//setting flags
		}

		public void MoveToTile(RTSUnit e, Vector2D targetGridPos)
		{
			mMap.RemoveFromTile(e);

			var path = GetNodesToGridPos(targetGridPos, e.mGridPos, e.mMovementReach + 1).Get();
			if (path.Count > 1)
				SafeDelete!(path.PopFront());

			int pathLength = path.Count;
			for (var i < pathLength)// Convert the gridPos to screen Cords
			{
				path[i].mX = path[i].mX * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth) + (uint64)e.mBoundingBox.w / 2;
				path[i].mY = path[i].mY * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight) + (uint64)e.mBoundingBox.h / 2;
			}

			SafeMemberSet!(e.mPathfinder, new Pathfinding(&e.mPos, path, pathLength * 10));

			mMap.SetToTile(e, targetGridPos);//setting flags
			SafeDelete!(targetGridPos);
			SafeDelete!(path);

			e.mPathfinder.Update();
		}

		public Result<List<Vector2D>> GetNodesToGridPos(Vector2D targetPos, Vector2D startPos, int reach)
		{
			var overlayArray = scope int[(int)mMapSize.Height, (int)mMapSize.Width];

			overlayArray[(int)startPos.mY, (int)startPos.mX] = reach;

			for (var i < reach * 2)
			{
				FloodFill(ref overlayArray, mOverlayType);
			}

			int currentGridPosX = (int)targetPos.mX;
			int currentGridPosY = (int)targetPos.mY;

			int currentNumber = overlayArray[currentGridPosY, currentGridPosX];

			List<Vector2D> path = new List<Vector2D>() { new Vector2D(targetPos) };
			bool foundPath = false;
			int stuckCounter = 0;
			while (!foundPath)
			{
				foundPath =
					(currentGridPosX == (int)startPos.mX) && (currentGridPosY == (int)startPos.mY)
					&& (currentNumber == reach);

				if (stuckCounter > 10)
					return .Err((void)"stuck!");

				for (var x = -1; x < 2; x++)
				{
					for (var y = -1; y < 2; y++)
					{
						if (overlayArray[currentGridPosY + y, currentGridPosX + x] == currentNumber + 1)
						{
							currentGridPosX = currentGridPosX + x;
							currentGridPosY = currentGridPosY + y;

							path.Insert(0, new Vector2D(currentGridPosX, currentGridPosY));

							currentNumber++;
							stuckCounter = 0;
						}
						else
							stuckCounter++;
					}
				}
			}
			return .Ok(path);
		}

		public bool AttackTile(RTSUnit e, Vector2D targetGridPos, bool attackAnimation = true)
		{
			var entityList = mMap.mTileList[(int)targetGridPos.mY, (int)targetGridPos.mX].mEntities;

			if (entityList.Count < 1)
			{
				Log!("Nothing to attack!");
				return false;
			}

			for (int i < entityList.Count)
			{
				if (let rtsunit = entityList[i] as EldrichDungeons.Entity.RTSUnits.RTSUnit)
				{
					if (rtsunit.mForce == e.mForce)
					{
						Log!("Can't attack a allied unit!");
						return false;
					}
					e.Attack(rtsunit);

					if (attackAnimation)
					{
						Vector2D enemyPos = new Vector2D(rtsunit.mGridPos);
						enemyPos.mX = enemyPos.mX * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth) + (uint64)e.mBoundingBox.w / 2;
						enemyPos.mY = enemyPos.mY * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight) + (uint64)e.mBoundingBox.h / 2;

						enemyPos.mX = Math.Lerp(enemyPos.mX, e.mPos.mX, 0.5f);
						enemyPos.mY = Math.Lerp(enemyPos.mY, e.mPos.mY, 0.5f);
						List<(Vector2D, Vector2D)> path = new .() { (enemyPos, new Vector2D(2)), (new Vector2D(e.mPos), new Vector2D(20)) };

						SafeMemberSet!(e.mPathfinder, new Pathfinding(&e.mPos, path));
					}
				}
			}

			return true;
		}

		public void StartEnemyTurn()
		{
			CloseContextMenu();
			mStopUpdatingTile = false;
			mEnemyTurn = true;
		}

		public void EndRound()
		{
			CloseContextMenu();
			mTurnCounter++;
			mEnemyTurn = false;

			for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.MainLayer].mEntities)
			{
				if (let rtsunit = entity as EldrichDungeons.Entity.RTSUnits.RTSUnit)
				{
					rtsunit.mHasMoved = false;
					rtsunit.mHasAttacked = false;
				}
			}
		}

		public void CloseContextMenu()
		{
			this.OpenContextMenuAt(scope Vector2D(0, 0), .Close);
			mQuickInv.Close();
		}

		public void OpenContextMenuAt(Vector2D pos, OverlayState type)
		{
			mContextMenu.OpenAt(pos, type);
		}

		public void ResetState(Vector2D selectedTile = null)
		{
			mSelectedUnit = null;
			mOverlayType = .Close;
			mStopUpdatingTile = false;
			UpdateSelectedTile();

			if (selectedTile != null)
				UpdateSelectedTile(selectedTile);

			ClearOverlay();
		}

		public void UpdateSelectedTile(Vector2D pos)
		{
			SafeMemberSet!(mSelectedTile, new Vector2D((int)(pos.mX / mTileSize.Width), (int)(pos.mY / mTileSize.Height)));

			mSelectedTileOverlay.mPos.mX = mSelectedTile.mX * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth);
			mSelectedTileOverlay.mPos.mY = mSelectedTile.mY * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight);
		}

		public void UpdateSelectedTile()
		{
			UpdateSelectedTile(mMousePos);
		}

		public void MouseDown(SDL2.SDL.MouseButtonEvent evt)
		{
			if (mEnemyTurn)//If it is the enemies turn prevent clicks from doing something
				return;

			bool found = false;
			if (mPlacedUnits >= 0)
			{
				mOverlayType = .Place;
			}
			else
			{
				for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.MainLayer].mEntities)
				{
					if (let rtsunit = entity as EldrichDungeons.Entity.RTSUnits.RTSUnit)
					{
						if (rtsunit.mVisiable && rtsunit.mClickable && (rtsunit.mBoundingBox.Contains((.)(evt.x - entity.mPos.mX), (.)(evt.y - entity.mPos.mY))))
						{
							if ((mOverlayType == .Attack && rtsunit.mForce != .Friendly) || mPlacedUnits >= 0)
								break;

							found = true;

							rtsunit.onClick();
							Log!(ToStackString!(rtsunit.mStats));
							mLastSelectedUnit = null;
							ClearOverlay();
							CloseContextMenu();
							if ((rtsunit.mHasMoved && rtsunit.mHasAttacked))
							{
								mSelectedUnit = rtsunit;
								mOverlayType = .None;
							}
							else
							{
								if (rtsunit.mForce == .Friendly && mSelectedUnit == rtsunit && !mSelectedUnit.mHasAttacked)
								{
									mOverlayType = .Self;
									UpdateSelectedTile();
									OpenContextMenuAt(scope Vector2D(evt.x, evt.y), mOverlayType);
									mStopUpdatingTile = true;
								}
								else
								{
									mSelectedUnit = rtsunit;
									if (rtsunit.mForce == .Friendly)
									{
										mOverlayType = .Move;
										if (rtsunit.mHasMoved)
											mOverlayType = .Attack;
									}
									else
									{
										mOverlayType = .Enemy;
									}
								}
							}

							Log!("unit found", ToStackString!(mOverlayType));
						}
					}
				}
			}

			for (let overlay in mOverlay)
			{
				if (mOverlayType == .Enemy)
					break;

				if (let overlayTile = overlay as EldrichDungeons.Entity.Tiles.OverlayTile)
				{
					if ((overlayTile.mBoundingBox.Contains((.)(evt.x - overlay.mPos.mX), (.)(evt.y - overlay.mPos.mY))))
					{
						found = true;

						overlayTile.onClick();

						if (!mStopUpdatingTile)
						{
							mStopUpdatingTile = true;
							UpdateSelectedTile();
						}

						var pos = new Vector2D(((int)overlayTile.mPos.mX / mTileSize.Width), (int)(overlayTile.mPos.mY / mTileSize.Height));
						if (mContextMenu.CurrentOpenContextMenuStatus == mOverlayType && mSelectedTile == pos)
							mContextMenu.SelectButton(mOverlayType, 0);
						else
							UpdateSelectedTile();

						SafeMemberSet!(mSelectedTile, pos);
						OpenContextMenuAt(scope Vector2D(evt.x, evt.y), mOverlayType);
						Log!("overlay found");
					}
				}
			}

			if (!found)
			{
				mStopUpdatingTile = false;
				if (mContextMenu.CurrentOpenContextMenuStatus == .Close && mQuickInv.mPage == -1)
					OpenContextMenuAt(scope Vector2D(evt.x, evt.y), .None);
				else
					CloseContextMenu();

				mSelectedUnit = null;
				Log!("Not found!");
			}
		}

		public void RemoveFromGrid(RTSUnit rtsUnit)
		{
			for (int x < (int)mMapSize.Width)
			{
				for (int y < (int)mMapSize.Height)
				{
					for (var ent in mMap.mTileList[y, x].mEntities)
					{
						if (ent.mIsDeleting || ent == rtsUnit)
							@ent.Remove();
					}
				}
			}
		}

		public OverlayTile AddOverlayTile(Vector2D gridpos)
		{
			OverlayTile t = new OverlayTile();
			t.mLayer = .FG3;
			t.mTileImage = getOverlayTextureByType();
			t.SetBoundingBoxFromImage(t.mTileImage);
			t.mBoundingBox = SDL.Rect(0, 0, t.mTileImage.mSurface.w, t.mTileImage.mSurface.h);
			t.mPos.mX = gridpos.mX * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth);
			t.mPos.mY = gridpos.mY * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight);
			mOverlay.Add(t);
			gGameApp.AddEntity(t);
			return t;
		}

		public void ClearOverlay()
		{
			for (var overlay in mOverlay)
			{
				overlay.mIsDeleting = true;
				@overlay.Remove();
			}
		}

		public void UpdateFogOfWar()
		{
			SafeMemberSet!(mMap.mFogOfWar, new uint8[(int)mMapSize.Height, (int)mMapSize.Width]);

			HashSet<v2d> visitedGrids = new .();

			for (let entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.MainLayer].mEntities)
			{
				if (let rtsunit = entity as EldrichDungeons.Entity.RTSUnits.RTSUnit && rtsunit.mForce == .Friendly)
				{
					int reach = rtsunit.mSightRadius;

					var overlayArray = scope int[(int)mMapSize.Height, (int)mMapSize.Width];

					int GridPosX = (int)rtsunit.mGridPos.mX;
					int GridPosY = (int)rtsunit.mGridPos.mY;

					overlayArray[GridPosY, GridPosX] = reach;

					visitedGrids.Add(.(GridPosX, GridPosY));

					for (var i < reach * 2)
					{
						FloodFillSight(ref overlayArray, ref visitedGrids);
					}

					for (var gridpos in visitedGrids)
					{
						var tileValue = overlayArray[(int)gridpos.y, (int)gridpos.x];
						var fowValue = mMap.mFogOfWar[(int)gridpos.y, (int)gridpos.x];
						if (tileValue > fowValue)
							mMap.mFogOfWar[(int)gridpos.y, (int)gridpos.x] = (uint8)Math.Min(tileValue, 255);
					}
				}
			}

			mMap.UpdateFogOfWar(visitedGrids);
		}

		public void UpdateOverlay()
		{
			if (mSelectedUnit == null || mOverlayType == .None)
			{
				ClearOverlay();
				return;
			}
			if (mSelectedUnit == mLastSelectedUnit)
				return;

			int reach = getReachByType(mSelectedUnit) + 1;
			bool ignoreUnitCollistion = mOverlayType == .Attack;

			var overlayArray = getFloodFilledArray(reach, .((int)mSelectedUnit.mGridPos.mX, (int)mSelectedUnit.mGridPos.mY), mOverlayType, ignoreUnitCollistion);

			overlayArray[(int)mSelectedUnit.mGridPos.mY, (int)mSelectedUnit.mGridPos.mX] = 0;

			for (int x < (int)mMapSize.Width)
			{
				for (int y < (int)mMapSize.Height)
				{
					if (overlayArray[y, x] > 0)
					{
						OverlayTile t = new OverlayTile();
						t.mLayer = .FG3;
						t.mTileImage = getOverlayTextureByType(mOverlayType);
						t.SetBoundingBoxFromImage(t.mTileImage);
						t.mBoundingBox = SDL.Rect(0, 0, t.mTileImage.mSurface.w, t.mTileImage.mSurface.h);
						t.mPos.mX = x * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth);
						t.mPos.mY = y * (int)gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight);
						mOverlay.Add(t);
						gGameApp.AddEntity(t);
					}
				}
			}
			mLastSelectedUnit = mSelectedUnit;

			delete overlayArray;
		}

		private int[,] getFloodFilledArray(int reach, v2d pos, OverlayState type, bool ignoreUnits = false)
		{
			var overlayArray = new int[(int)mMapSize.Height, (int)mMapSize.Width];

			int GridPosX = (int)pos.x;
			int GridPosY = (int)pos.y;

			overlayArray[GridPosY, GridPosX] = reach;

			for (var i < reach * 2)
			{
				FloodFill(ref overlayArray, type, ignoreUnits);
			}

			return overlayArray;
		}

		public void FloodFillSight(ref int[,] overlayArray, ref HashSet<v2d> visisitedNodes)
		{
			var overlayBuffer = scope int[(int)mMapSize.Height, (int)mMapSize.Width];

			for (var index < overlayArray.Count)
			{
				overlayBuffer[index] = overlayArray[index];
			}

			for (int x < (int)mMapSize.Width)
			{
				for (int y < (int)mMapSize.Height)
				{
					if (overlayArray[y, x] > 1)
					{
						int setValue = overlayArray[y, x] - 1;
						for (int xOffset = -1; xOffset < 2; xOffset++)
						{
							int xAdjust = xOffset + x;
							if (xAdjust >= (int)mMapSize.Width || xAdjust < 0)
								break;
							if (overlayArray[y, xAdjust] <= 0)
							{
								if ((mMap.mTileList[y, xAdjust]).IsWalkable)
									overlayBuffer[y, xAdjust] = setValue;
								else
									overlayBuffer[y, xAdjust] = 1;

								visisitedNodes.Add(v2d(xAdjust, y));
							}
						}

						for (int yOffset = -1; yOffset < 2; yOffset++)
						{
							int yAdjust = yOffset + y;
							if (yAdjust >= (int)mMapSize.Height || yAdjust < 0)
								break;
							if (overlayArray[yAdjust, x] <= 0)
							{
								if ((mMap.mTileList[yAdjust, x]).IsWalkable)
									overlayBuffer[yAdjust, x] = setValue;
								else
									overlayBuffer[yAdjust, x] = 1;

								visisitedNodes.Add(v2d(x, yAdjust));
							}
						}
					}
				}
			}

			for (var index < overlayBuffer.Count)
			{
				overlayArray[index] = overlayBuffer[index];
			}
		}

		public void FloodFill(ref int[,] overlayArray, OverlayState type, bool ignoreUnits = false)
		{
			var overlayBuffer = scope int[(int)mMapSize.Height, (int)mMapSize.Width];

			for (var index < overlayArray.Count)
			{
				overlayBuffer[index] = overlayArray[index];
			}

			for (int x < (int)mMapSize.Width)
			{
				for (int y < (int)mMapSize.Height)
				{
					if (overlayArray[y, x] > 0)
					{
						int setValue = overlayArray[y, x] - 1;

						for (int xOffset = -1; xOffset < 2; xOffset++)
						{
							int xAdjust = xOffset + x;
							if (xAdjust >= (int)mMapSize.Width || xAdjust < 0)
								break;
							if (overlayArray[y, xAdjust] <= 0 && (mMap.mTileList[y, xAdjust]).IsWalkable &&
								(mMap.mTileList[y, xAdjust].mEntities.Count < 1 || ignoreUnits))
								overlayBuffer[y, xAdjust] = setValue;
						}

						for (int yOffset = -1; yOffset < 2; yOffset++)
						{
							int yAdjust = yOffset + y;
							if (yAdjust >= (int)mMapSize.Height || yAdjust < 0)
								break;
							if (overlayArray[yAdjust, x] <= 0 && (mMap.mTileList[yAdjust, x]).IsWalkable &&
								(mMap.mTileList[yAdjust, x].mEntities.Count < 1 || ignoreUnits))
								overlayBuffer[yAdjust, x] = setValue;
						}
					}
				}
			}

			for (var index < overlayBuffer.Count)
			{
				overlayArray[index] = overlayBuffer[index];
			}
		}

		private int getReachByType(RTSUnit unit)
		{
			int ret = 0;
			switch (mOverlayType)
			{
			case .None:
				ret = 0;
			case .Move:
				ret = unit.mMovementReach;
			case .Attack:
				ret = unit.mAttackReach;
			case .Magic:
			case .Enemy:
				ret = unit.mMovementReach;
			case .Close:
			case .Item:
			case .Self:
			case .Place:
			case .Count:
			}
			return ret;
		}

		private Image getOverlayTextureByType()
		{
			return getOverlayTextureByType(mOverlayType);
		}

		private Image getOverlayTextureByType(OverlayState type)
		{
			Image ret = ResourceLoader.LoadTexture("images/Overlay/overlay.png");
			switch (type)
			{
			case .None:
				ret = ResourceLoader.LoadTexture("images/Overlay/overlay.png");
			case .Move:
			case .Attack:
				ret = ResourceLoader.LoadTexture("images/Overlay/overlayAttack.png");
			case .Magic:
			case .Enemy:
				ret = ResourceLoader.LoadTexture("images/Overlay/overlayAttack.png");
			case .Close:
			case .Item:
			case .Self:
			case .Place:
			case .Count:
			}
			return ret;
		}


		public ref List<Entity> GetUnitsOnTile(Vector2D pos)
		{
			return ref mMap.mTileList[(int)pos.mY, (int)pos.mX].mEntities;
		}

//###Events
		public void OnBattleBegin()
		{
			int enemyCount = gGameApp.mRand.Next(3) + 2;
			Log!("Enemy count", enemyCount);
			for (var i < enemyCount)
			{
				v2d spawnPos = .(0, 0);
				int debugCNT = 0;
				Tile t = null;
				repeat
				{
					int spawnIndex = gGameApp.mRand.Next(1, mMap.SpawnPositions.Count);
					spawnPos = GetAndRemove!(mMap.SpawnPositions, spawnIndex);
					t = mMap.mTileList[(int)spawnPos.y, (int)spawnPos.x];
					Log!(debugCNT++);
					Log!("spawnpos", spawnPos.x, spawnPos.y);
				}
				while (t.mEntities.Count > 1)

				var unit = new RTSUnit();
				unit.SetForce(.Enemy);
				SafeMemberSet!(unit.mColor, new Color(255, 0, 0));
				SafeMemberSet!(unit.mAI, new BasicAI());
				SetToTile(unit, scope .(spawnPos.x, spawnPos.y));
				gEngineApp.AddEntity(unit);
			}
		}

		public void OnTurnBegin()
		{
		}
	}
}
