using SDL2;
using BasicEngine.Entity;

namespace EldrichDungeons.Entity.Tiles
{
	class Tile : Entity
	{
		public this()
		{ }

		public this(Tile t)
		{
			this.mTileImage = t.mTileImage;
			this.mIsWall = t.mIsWall;
			this.mIsWater = t.mIsWater;
			this.mIsOccupied = t.mIsOccupied;
		}

		public Image mTileImage = null;
		public bool mIsWall = false;
		public bool mIsWater = false;
		public bool mIsOccupied = false;

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
