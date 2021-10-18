using System;
using SDL2;
using BasicEngine.Entity;

namespace EldrichDungeons.Entity.Tiles
{
	class OverlayTile : Entity
	{
		public float mMinAlpha = 102.5f + 25f;
		public bool mCycleAlpha = true;

		public Image mTileImage
		{
			get { return mImage; }
			set { mImage = value; }
		}

		public override void Update(int dt)
		{
			base.Update(dt);
			if (mCycleAlpha)
				mAlpha = (float)((52.5 * Math.Cos(2 * 3.14 * 1 * ((float)(gGameApp.mUpdateCnt) / 100))) + mMinAlpha) / 255;
		}

		public override void Draw(int dt)
		{
			if (!mVisiable)
				return;

			SDL.SetTextureAlphaMod(mTileImage.mTexture, (.)(mAlpha * 254) & 0xFF);
			gGameApp.Draw(mTileImage, mPos.mX, mPos.mY);
			SDL.SetTextureAlphaMod(mTileImage.mTexture, 255);
		}
	}
}
