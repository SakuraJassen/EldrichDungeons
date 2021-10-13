using BasicEngine.Particle;
using BasicEngine;
using SDL2;
using System;

namespace EldrichDungeons.Particle
{
	class Soul : Particle
	{
		int mSizeMod = 0;
		int mAnimationOffSet = 0;

		public this(BasicEngine.Vector2D pos, BasicEngine.Size2D size, BasicEngine.LayeredList.LayeredList.LayerNames layer, Color color = null) : base(pos, size, layer)
		{
			if (color == null)
			{
				int offSetBase = 24;
				uint8 colorOffset = (.)gEngineApp.mRand.Next(0, offSetBase);
				uint8 baseColor = 64 + colorOffset;
				SafeMemberSet!(mColor, new Color(baseColor, baseColor + 64, baseColor + 64));
			} else
			{
				SafeMemberSet!(mColor, color);
			}
			mDrawAngle = 270;
			mVel = 0.5f;
			mMaxUpdates = 240;
			RenderImage(true);
		}

		public override void Update(int dt)
		{
			base.Update(dt);

			if (mSizeMod > -4 && mUpdateCnt < 20 && mUpdateCnt % 10 == 0)
			{
				var newPos = new Vector2D(mPos);
				newPos.mY += mSize.mY / 2;
				Soul par = new Soul(newPos, new Size2D(8, 8), .FG4);
				SafeMemberSet!(par.mColor, new Color(mColor));
				par.mSizeMod = mSizeMod - 2;
				par.mMaxUpdates = mMaxUpdates - mUpdateCnt;
				par.mAnimationOffSet = mAnimationOffSet;
				par.RenderImage();
				gGameApp.AddParticleFront(par);
			}

			int range = 30;
			float sin = Math.Sin((float)((mUpdateCnt + mAnimationOffSet) / 20));
			mAngle = Math.Remap(sin, -1, 1, 270 - range, 270 + range);
		}


		public override void Draw(int dt)
		{
			SDL.SetTextureAlphaMod(mImage.mTexture, 192);

			FadeOut(30, 2, 192, 0);

			SDL.Rect srcRect = .(0, 0, mImage.mSurface.w, mImage.mSurface.h);
			SDL.Rect destRect = .((int32)mPos.mX, (int32)mPos.mY, mImage.mSurface.w + (.)mSizeMod, mImage.mSurface.h + (.)mSizeMod);
			SDL.RenderCopyEx(gEngineApp.mRenderer, mImage.mTexture, &srcRect, &destRect, mDrawAngle, null, .None);

			SDL.SetTextureAlphaMod(mImage.mTexture, 255);

			//gEngineApp.Draw(mImage, mPos.mX, mPos.mY, mAngle+mDrawAngleOffset);
		}
	}
}
