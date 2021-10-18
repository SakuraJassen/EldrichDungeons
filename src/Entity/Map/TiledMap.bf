using BasicEngine;
using BasicEngine.Entity;
using SDL2;
using EldrichDungeons.Entity.Tiles;
using System.Collections;
using System;
using EldrichDungeons.Entity.RTSUnits;

namespace EldrichDungeons.Entity.Map
{
	class TiledMap : Entity
	{
		// Map size in Tiles
		public Size2D mMapSize = new Size2D(16, 16) ~ DeleteAndNullify!(_);
		 // Tile size in Pixels
		public Size2D mTileSize = new Size2D(32, 48) ~ DeleteAndNullify!(_);

		//public List<Entity>[,] mEntityList = null ~ DeleteContainerAndItems!(_);
		public Tile[,] mTileList = null ~ DeleteContainerAndItems!(_);

		public TileSet mTileSet = new TileSet() ~ delete _;

		public uint8[,] mFogOfWar = null ~ SafeDelete!(_);
		private uint8 minimumAlpha = 64;
		private HashSet<v2d> lastUpdatedPos = new HashSet<v2d>() { } ~ SafeDelete!(_);

		private List<v2d> spawnPos = null ~ SafeDelete!(_);
		public List<v2d> SpawnPositions
		{
			get { return spawnPos; }
		}

		public ~this()
		{
			SafeDeleteNullify!(mImage);
		}

		public override void Init()
		{
			SafeMemberSet!(mColor, new Color(192, 128, 64));

			mTileSet.LoadTileSet("Tile");
			MapLoader loader = scope MapLoader();

			/*if (loader.LoadLevelData() case .Err(var err))
				Log!(err);*/
			switch (loader.LoadLevelData())
			{
			case .Ok(let pos):
				SafeMemberSet!(spawnPos, pos);
			case .Err(let err):
				Log!(err);
			}

			mMapSize.Set(loader.mMapSize);

			//DeleteContainerAndItems!(mEntityList);
			DeleteContainerAndItems!(mTileList);
			SafeDelete!(mFogOfWar);

			//mEntityList = new List<Entity>[(int)mMapSize.Height, (int)mMapSize.Width];
			mTileList = new Tile[(int)mMapSize.Height, (int)mMapSize.Width];
			mFogOfWar = new uint8[(int)mMapSize.Height, (int)mMapSize.Width];

			for (int i = 0; i < mTileList.Count; i++)
			{
				//SafeMemberSet!(mEntityList[i], new List<Entity>());
				mFogOfWar[i] = 0;
			}

			renderMap(loader);
		}

		private void drawTile(Image img, int32 x, int32 y, uint8 alpha)
		{
			int32 xAdjust = x * (int32)mTileSize.Width;
			int32 yAdjust = y * (int32)mTileSize.Height;
			SDL.Rect destRect = .((int32)xAdjust, (int32)yAdjust, img.mSurface.w, img.mSurface.h);
			SDL.SetTextureAlphaMod(img.mTexture, alpha);
			SDL.RenderFillRect(gEngineApp.mRenderer, &destRect);
			SDL.RenderCopy(gEngineApp.mRenderer, img.mTexture, null, &destRect);
			SDL.SetTextureAlphaMod(img.mTexture, 0xff);
		}


		private void drawTile(Image img, int32 x, int32 y)
		{
			int32 xAdjust = x * (int32)mTileSize.Width;
			int32 yAdjust = y * (int32)mTileSize.Height;
			SDL.Rect destRect = .((int32)xAdjust, (int32)yAdjust, img.mSurface.w, img.mSurface.h);
			SDL.RenderCopy(gEngineApp.mRenderer, img.mTexture, null, &destRect);
		}

		private void renderMap(MapLoader mapLoader)
		{
			if (mImage == null)
			{
				Size2D size = scope .(mMapSize.Width * mTileSize.Width, mMapSize.Height * mTileSize.Height);
				SafeMemberSet!(mImage, new Image());
				DrawUtils.CreateTexture(mImage, size, gEngineApp.mRenderer);
			}

			SDL.SetRenderTarget(gEngineApp.mRenderer, mImage.mTexture);
			SDL.SetRenderDrawColor(gEngineApp.mRenderer, 0, 0, 0, 255);

			SDL.RenderClear(gEngineApp.mRenderer);

			for (int32 x = 0; x < mMapSize.Width; x++)
			{
				for (int32 y = 0; y < mMapSize.Height; y++)
				{
					int tileId = mapLoader[y, x];
					if (tileId == 2 && y < mMapSize.Height - 1 && mapLoader[y + 1, x] == 0)
						tileId = 1;
					Tile tile = new Tile(mTileSet[tileId]);
					SafeMemberSet!(mTileList[y, x], tile);

					drawTile(tile.mTileImage, x, y, minimumAlpha);
				}
			}

			SDL.SetRenderTarget(gEngineApp.mRenderer, null);
		}

		private void updateFogOfWar(HashSet<v2d> visitedGrids)
		{
			if (mImage == null)
			{
				Size2D size = scope .(mMapSize.Width * mTileSize.Width, mMapSize.Height * mTileSize.Height);
				SafeMemberSet!(mImage, new Image());
				DrawUtils.CreateTexture(mImage, size, gEngineApp.mRenderer);
			}

			SDL.SetRenderTarget(gEngineApp.mRenderer, mImage.mTexture);
			SDL.SetRenderDrawColor(gEngineApp.mRenderer, 0, 0, 0, 255);

			for (var gridpos in lastUpdatedPos)
			{
				uint8 alpha = (uint8)Math.Remap(mFogOfWar[(int)gridpos.y, (int)gridpos.x], 0, 8, minimumAlpha, 255);
				drawTile(mTileList[(int)gridpos.y, (int)gridpos.x].mTileImage, (int32)gridpos.x, (int32)gridpos.y, alpha);
			}

			for (var gridpos in visitedGrids)
			{
				uint8 alpha = (uint8)Math.Remap(mFogOfWar[(int)gridpos.y, (int)gridpos.x], 0, 8, minimumAlpha, 255);
				drawTile(mTileList[(int)gridpos.y, (int)gridpos.x].mTileImage, (int32)gridpos.x, (int32)gridpos.y, alpha);
			}

			/*for (int32 x = 0; x < mMapSize.Width; x++)
			{
				for (int32 y = 0; y < mMapSize.Height; y++)
				{
					uint8 alpha = (uint8)Math.Remap(mFogOfWar[y, x], 0, 8, 64, 255);
					/*if (!mTileList[y, x].IsWalkable)
						alpha = 0x7f;*/
					drawTileToMap(mTileList[y, x].mTileImage, x, y, alpha);
				}
			}*/

			SDL.SetRenderTarget(gEngineApp.mRenderer, null);
		}

		private void updateFogOfWar()
		{
			if (mImage == null)
			{
				Size2D size = scope .(mMapSize.Width * mTileSize.Width, mMapSize.Height * mTileSize.Height);
				SafeMemberSet!(mImage, new Image());
				DrawUtils.CreateTexture(mImage, size, gEngineApp.mRenderer);
			}

			SDL.SetRenderTarget(gEngineApp.mRenderer, mImage.mTexture);
			SDL.SetRenderDrawColor(gEngineApp.mRenderer, 0, 0, 0, 255);

			for (int32 x = 0; x < mMapSize.Width; x++)
			{
				for (int32 y = 0; y < mMapSize.Height; y++)
				{
					uint8 alpha = (uint8)Math.Remap(mFogOfWar[y, x], 0, 8, minimumAlpha, 255);
					drawTile(mTileList[y, x].mTileImage, x, y, alpha);
					for (var entity in mTileList[y, x].mEntities)
						entity.mVisiable = mFogOfWar[y, x] > 0;
				}
			}

			SDL.SetRenderTarget(gEngineApp.mRenderer, null);
		}

		public void RemoveFromTile(RTSUnit e)
		{
			if (e == null)
				return;

			var tile = ref mTileList[(int)e.mGridPos.mY, (int)e.mGridPos.mX];
			tile.mEntities.Remove(e);
			tile.mIsOccupied = (tile.mEntities.Count != 0);
		}

		public void SetToTile(RTSUnit e, Vector2D gridPos)
		{
			if (e == null)
				return;

			var fromTile = ref mTileList[(int)e.mGridPos.mY, (int)e.mGridPos.mX];
			fromTile.mEntities.Remove(e);

			fromTile.mIsOccupied = (fromTile.mEntities.Count != 0);

			e.SetGridPos(gridPos);

			var toTile = mTileList[(int)e.mGridPos.mY, (int)e.mGridPos.mX];

			e.mVisiable = mFogOfWar[(int)e.mGridPos.mY, (int)e.mGridPos.mX] > 0;

			toTile.mEntities.Add(e);
			toTile.mIsOccupied = true;
		}

		public void UpdateFogOfWar(HashSet<v2d> visitedGrids)
		{
			updateFogOfWar(visitedGrids);

			for (var gridpos in lastUpdatedPos)
			{
				for (var entity in mTileList[(int)gridpos.y, (int)gridpos.x].mEntities)
					entity.mVisiable = mFogOfWar[(int)gridpos.y, (int)gridpos.x] > 0;
			}

			for (var gridpos in visitedGrids)
			{
				for (var entity in mTileList[(int)gridpos.y, (int)gridpos.x].mEntities)
					entity.mVisiable = mFogOfWar[(int)gridpos.y, (int)gridpos.x] > 0;
			}

			SafeMemberSet!(lastUpdatedPos, visitedGrids);
			/*
			for (int32 x = 0; x < mMapSize.Width; x++)
			{
				for (int32 y = 0; y < mMapSize.Height; y++)
				{
					for (var entity in mEntityList[y, x])
						entity.mVisiable = mFogOfWar[y, x] > 0;
				}
			}*/
		}

		public void UpdateFogOfWar()
		{
			updateFogOfWar();
		}

		public override void Draw(int dt)
		{
			gEngineApp.Draw(mImage, mPos.mX, mPos.mY);
		}

		public override void Update(int dt)
		{
		}
	}
}
