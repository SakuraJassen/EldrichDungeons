using SDL2;
using BasicEngine.Entity;
using System.Collections;

namespace EldrichDungeons.Entity.Tiles
{
	class Tile : Entity
	{
		public Image mTileImage = null;
		public uint8 mFogOfWar = 0;
		public bool mIsWall = false;
		public bool mIsWater = false;
		public bool mIsOccupied = false;

		public List<Entity> mEntities = new List<Entity>() ~ DeleteAndNullify!(_);

		public this()
			{ }

		public this(Tile t)
		{
			this.mTileImage = t.mTileImage;
			this.mIsWall = t.mIsWall;
			this.mIsWater = t.mIsWater;
			this.mIsOccupied = t.mIsOccupied;
		}

		public bool IsWalkable
		{
			get { return (!mIsWall && !mIsWater); }
		}

		public override void Draw(int dt)
		{
			base.Draw(dt);
			gGameApp.Draw(mTileImage, mPos.mX, mPos.mY);
		}
	}
}
