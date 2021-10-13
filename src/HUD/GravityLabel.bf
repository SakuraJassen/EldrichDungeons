using BasicEngine.HUD;
using System;
using BasicEngine;

namespace EldrichDungeons.Hud
{
	class GravityLabel : Label
	{
		public float mGravity = 3f;
		public this(System.String str, float x, float y, int32 fontSize = 16) : base(str, 0, 0, fontSize)
		{
			SafeMemberSet!(mOffset, new Vector2D(x, y));
		}

		public override void Update(int dt)
		{
			base.Update(dt);
			mAngle -= mGravity;
			//mVel = Math.Max(mVel-mGravity, 0);
		}
	}
}
