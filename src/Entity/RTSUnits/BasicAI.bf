using EldrichDungeons.RTSSystem;
using EldrichDungeons.Entity.Map;
using BasicEngine;
using BasicEngine.LayeredList;
namespace EldrichDungeons.Entity.RTSUnits
{
	class BasicAI
	{
		public this()
		{
		}

		public enum AIState : uint8
		{
			None = 0b0000,
			Move = 0b0001,
			Attack = 0b0010,
			Magic = 0b0011,
		}

		public AIState mAIState = .None;
		public int mPauseTime = 0;
		public void LogicStep(RTSUnit me, RTSSystem rtsSystem)
		{
			if (--mPauseTime > 0 || (me.mPathfinder != null && !me.mPathfinder.Elapsed))
				return;

			if (!me.mHasMoved)
			{
				moveLogic(me, rtsSystem);
				mAIState = .Move;
			}
			else if (!me.mHasAttacked)
			{
				attackLogic(me, rtsSystem);
				mAIState = .Attack;
			}
		}

		private void moveLogic(RTSUnit me, RTSSystem rtsSystem)
		{
			Log!("move!");

			int mapHeight = (int)rtsSystem.mMapSize.Height;
			int mapWidth = (int)rtsSystem.mMapSize.Width;

			int reach = me.mMovementReach;

			var overlayArray = scope int[mapHeight, mapWidth];

			int GridPosX = (int)me.mGridPos.mX;
			int GridPosY = (int)me.mGridPos.mY;

			overlayArray[GridPosY, GridPosX] = reach;

			for (var i < reach * 2)
			{
				rtsSystem.FloodFill(ref overlayArray, .Move);
			}

			Vector2D targetCell = scope Vector2D(-1, -1);
			RTSUnit targetUnit = null;
			float minDist = float.MaxValue;
			for (int x < mapWidth)
			{
				for (int y < mapHeight)
				{
					if (overlayArray[y, x] > 0)
					{
						/*
						int count = countNeighbors(rtsSystem.mMap, me, x, y);
						if(maxCount < count)
						{
							maxCount = count;
							targetCell.Set(x, y);
						}
						*/
						//Vector2D targetPos = scope .(x * mapWidth + (me.mBoundingBox.w / 2), y * mapHeight + (me.mBoundingBox.h / 2));
						Vector2D targetPos = scope .(x, y);
						for (var entity in gGameApp.mEntityList.mLayers[(int)LayeredList.LayerNames.MainLayer].mEntities)
						{
							if (let rtsunit = entity as RTSUnit && rtsunit.mForce != .Enemy)
							{
								float dist = targetPos.Distance(rtsunit.mGridPos);
								if (dist < minDist && dist < me.mGridPos.Distance(rtsunit.mGridPos))
								{
									minDist = dist;
									targetCell.Set(x, y);
									targetUnit = rtsunit;
								}
							}
						}
					}
				}
			}

			if (targetCell != scope .(-1, -1))
			{
				rtsSystem.MoveToTile(me, new .(targetCell));
			}
			me.mHasMoved = true;
		}

		private void attackLogic(RTSUnit me, RTSSystem rtsSystem)
		{
			Log!("attack!");
			int mapHeight = (int)rtsSystem.mMapSize.Height;
			int mapWidth = (int)rtsSystem.mMapSize.Width;

			int reach = me.mAttackReach + 1;

			var overlayArray = scope int[mapHeight, mapWidth];

			int GridPosX = (int)me.mGridPos.mX;
			int GridPosY = (int)me.mGridPos.mY;

			overlayArray[GridPosY, GridPosX] = reach;

			for (var i < reach * 2)
			{
				rtsSystem.FloodFill(ref overlayArray, .Attack);
			}

			Vector2D targetCell = scope Vector2D(-1, -1);
			RTSUnit targetEnemy = null;

			float lowestHP = float.MaxValue;

			for (int x < mapWidth)
			{
				for (int y < mapHeight)
				{
					if (overlayArray[y, x] > 0)
					{
						var unitsOnTile = rtsSystem.GetUnitsOnTile(scope Vector2D(x, y));
						if (unitsOnTile.Count > 0)
						{
							if (let rtsunit = unitsOnTile[0] as RTSUnit
								&& !rtsunit.mIsDeleting
								&& rtsunit.mStats.mCurrentHP < lowestHP
								&& rtsunit != me
								&& rtsunit.mForce != .Enemy)
							{
								lowestHP = rtsunit.mStats.mCurrentHP;
								targetCell.Set(x, y);
								targetEnemy = rtsunit;
							}
						}
					}
				}
			}

			if (targetEnemy != null)
			{
				rtsSystem.AttackTile(me, targetCell);
			}

			me.mHasAttacked = true;
		}

		private int countNeighbors(TiledMap map, RTSUnit me, int x, int y)
		{
			int count = 0;
			for (int xOffset = -1; xOffset <= 1; xOffset++)
			{
				int xAdjust = xOffset + x;
				var entityList = map.mTileList[y, xAdjust].mEntities;
				if (!entityList.Contains(me))
					count += entityList.Count;
			}

			for (int yOffset = -1; yOffset <= 1; yOffset++)
			{
				int yAdjust = yOffset + y;
				var entityList = map.mTileList[yAdjust, x].mEntities;
				if (!entityList.Contains(me))
					count += entityList.Count;
			}

			return count;
		}
	}
}
