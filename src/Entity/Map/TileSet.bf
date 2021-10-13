using System.Collections;
using SDL2;
using System;
using BasicEngine;
using EldrichDungeons.Entity.Tiles;
namespace EldrichDungeons.Entity.Map
{
	class TileSet
	{
		private List<Tile> mTileList = new List<Tile>() ~ DeleteContainerAndItems!(_);
		static public List<String> TileNames = new List<String>() {"Floor", "WallHorizont", "WallVertical", "WallTop"} ~ DeleteAndNullify!(_);
		public String mTileSetName ~ SafeDeleteNullify!(_);

		public int TileCount
		{
			get { return mTileList.Count; }
		}

		public Tile this[int id]
		{
		    get
		    {
		        return mTileList[id];
		    }

			set
			{
				mTileList[id] = value;
			}
		}

		public Result<void> LoadTileSet(String folderName)
		{
			for(var tileName in TileNames)
			{
				Tile tile = new Tile();
				SafeMemberSet!(tile.mTileImage, Try!(ResourceLoader.LoadTexture(StackStringFormat!("images/{}/{}.png", folderName, tileName))));

				if(tileName.StartsWith("Wall"))
					tile.mIsWall = true;

				mTileList.Add(tile);
			}
			SafeMemberSet!(mTileSetName, new String(folderName));

			return .Ok;
		}

		static public Result<int> GetIdByName(String tileName)
		{
			for(var i = 0; i < TileNames.Count; i++)
			{
				if(tileName == TileNames[i])
					return .Ok(i);
			}
			return .Err((.)"Couldn't find tile");
		}
	}
}
