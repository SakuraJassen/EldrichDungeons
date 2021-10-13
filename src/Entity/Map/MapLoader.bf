using System;
using System.IO;
using System.Collections;
using System.Reflection;
using BasicEngine;
namespace EldrichDungeons.Entity.Map
{
	class MapLoader
	{
		public Size2D mMapSize = new Size2D(0, 0) ~ DeleteAndNullify!(_);

		private uint8[,] mTileData = null ~ SafeDelete!(_);

		public uint8 this[int y, int x]
		{
			get
			{
				return mTileData[y, x];
			}

			set
			{
				mTileData[y, x] = value;
			}
		}

		public Result<void> LoadLevelData(String mapName)
		{
			StreamReader sr = scope StreamReader();
			using (sr.Open(scope $"maps/{mapName}"))
			{
				{
					var sizeValue = ReadNextLine(sr);
					mMapSize.Width = sizeValue[0];
					mMapSize.Height = sizeValue[1];
					delete sizeValue;

					mTileData = new uint8[(int)mMapSize.Height, (int)mMapSize.Width];
				}

				for (int32 y = 0; y < mMapSize.Height; y++)
				{
					var tileData = ReadNextLine(sr);
					if (tileData.Count != mMapSize.Width)
					{
						delete tileData;
						return .Err((.)"Mismatched Map size");
					}
					for (int32 x = 0; x < mMapSize.Width; x++)
					{
						mTileData[y, x] = (uint8)tileData[x];
					}
					delete tileData;
				}
			}

			return .Ok;
		}

		public Result<List<v2d>> LoadLevelData()
		{
			mMapSize.Width = 32;
			mMapSize.Height = 16;

			mTileData = new uint8[(int)mMapSize.Height, (int)mMapSize.Width];

			List<v2d> ret = new List<v2d>();

			for (int32 y = 0; y < mMapSize.Height; y++)
			{
				for (int32 x = 0; x < mMapSize.Width; x++)
				{
					mTileData[y, x] = 1;
				}
			}

			bool complet = false;
			v2d currentPos = .(gGameApp.mRand.Next((int32)mMapSize.Width), gGameApp.mRand.Next((int32)mMapSize.Height));
			ret.Add(currentPos);
			while (!complet)
			{
				//Log!(currentPos.x, currentPos.y);
				for (int x = -1; x < 2; x++)
				{
					int xAdj = (int)currentPos.x + x;
					if (xAdj < 0 || xAdj >= mMapSize.Width)
						continue;
					for (int y = -1; y < 2; y++)
					{
						var yAdj = (int)currentPos.y + y;
						if (yAdj < 0 || yAdj >= mMapSize.Height)
							continue;
						if (mTileData[yAdj, xAdj] == 1)
							mTileData[yAdj, xAdj] = 2;
					}
				}

				v2d oldPos = currentPos;

				mTileData[(int)currentPos.y, (int)currentPos.x] = 0;
				List<v2d> dirList = scope .() { v2d(-1, 0), v2d(1, 0), v2d(0, -1), v2d(0, 1) };
				repeat
				{
					if (dirList.Count == 0)
					{
						complet = true;
						break;
					}

					currentPos = oldPos;
					v2d dir = GetAndRemove!(dirList, gGameApp.mRand.Next(dirList.Count));
					currentPos.x += dir.x;
					currentPos.y += dir.y;

					if (currentPos.y < 1 || currentPos.y >= mMapSize.Height - 1 || currentPos.x < 1 || currentPos.x >= mMapSize.Width - 1)
					{
						currentPos = oldPos;
					}
				} while (mTileData[(int)currentPos.y, (int)currentPos.x] == 0)

				ret.Add(currentPos);
			}

			for (int32 y = 0; y < mMapSize.Height; y++)
			{
				for (int32 x = 0; x < mMapSize.Width; x++)
				{
					if (mTileData[y, x] == 1 || (y == 0 || x == 0 || y == mMapSize.Height - 1 || x == mMapSize.Width - 1))
						mTileData[y, x] = 2;
				}
			}

			return .Ok(ret);
		}

		public List<int> ReadNextLine(StreamReader sr)
		{
			String value = scope .("");
			sr.ReadLine(value);
			var split = value.Split!(',');
			var list = new List<int>();
			for (var val in split)
			{
				val.Trim();
				list.Add(int.Parse(val));
			}

			return list;
		}
	}
}
