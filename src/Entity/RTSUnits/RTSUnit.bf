using System;
using SDL2;
using BasicEngine;
using BasicEngine.Entity;
using BasicEngine.HUD;
using EldrichDungeons.Hud;
using System.Collections;
using EldrichDungeons.Items;
using EldrichDungeons.Items.Consumable;
using EldrichDungeons.Particle;

namespace EldrichDungeons.Entity.RTSUnits
{
	class RTSUnit : Entity
	{
		public Vector2D mGridPos = new Vector2D(0, 0) ~ DeleteAndNullify!(_);

		public String mName = null ~ SafeDelete!(_);

		public static List<String> Names = new List<String>() { "Hans", "Gunther", "Bob", "Manfred", "88888888", "Wdik", "333" } ~ delete _;

		public int mMovementReach = 3;
		public int mAttackReach = 1;
		public int mSightRadius = 4;
		public bool mIsFlying = false;
		public bool mNeedLineOfSight = false;

		public bool mHasMoved = false;
		public bool mHasAttacked = false;
		public bool mClickable = true;

		private Image mDisabledImage = null;

		public Pathfinding mPathfinder = null ~ SafeDelete!(_);

		public StatsCollection mStats = new StatsCollection() ~ SafeDelete!(_);

		public Inventory mInventory = new Inventory(this) ~ SafeDelete!(_);

		public BasicAI mAI = null ~ SafeDelete!(_);

		public enum Force : uint8
		{
			None = 0b0000,
			Neutral = 0b0001,
			Friendly = 0b0010,
			Enemy = 0b0100,
		}

		public Force mForce = .None;

		public this()
		{
			SetGridPos(scope .(0, 0));
		}

		public override void Init()
		{
			base.Init();
			mName = new String(Names[gGameApp.mRand.Next(Names.Count)]);
			mInventory.AddItem(new LowPotion(null, ToGlobalString!("Low-Pot."), 0));
			mInventory.AddItem(new LowPotion(null, ToGlobalString!("Low-Pot."), 0));
			mInventory.AddItem(new HighPotion(null, ToGlobalString!("High-Pot."), 0));

			loadTextures();
			SetBoundingBoxFromImage(mImage);
		}

		private Result<void> loadTextures()
		{
			delete mImage;
			mImage = Try!(ResourceLoader.LoadTexture("images/RTSUnits/test.png"));
			mDisabledImage = Try!(ResourceLoader.LoadTexture("images/RTSUnits/testDisabled.png"));

			return .Ok;
		}

		public void SetGridPos(Vector2D gridPos)
		{
			SafeMemberSet!(mGridPos, new Vector2D(gridPos));
			mPos.mX = mGridPos.mX * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth) + mBoundingBox.w / 2;
			mPos.mY = mGridPos.mY * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight) + mBoundingBox.h / 2;
		}

		public void MoveToGridPos(Vector2D gridPos)
		{
			Vector2D screenPos = new Vector2D(0, 0);
			screenPos.mX = gridPos.mX * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileWidth) + mBoundingBox.w / 2;
			screenPos.mY = gridPos.mY * gEngineApp.mGameRules.GetRange(GameApp.GameRules.TileHeight) + mBoundingBox.h / 2;

			mPathfinder = new .(&mPos, screenPos);
			mPathfinder.mSetFinishPos = true;
		}

		public void SetForce(Force f)
		{
			this.mForce = f;
		}

		public void Attack(RTSUnit other)
		{
			float dmg = this.mStats.mStrength + (this.mStats.mAgility * 0.3f);
			float dmgMod = other.mStats.mStrength * 0.2f;
			float dodgeChance = other.mStats.mAgility * 0.2f + other.mStats.mLuck * 0.1f;
			dmg *= dmgMod;
			if (gGameApp.mRand.NextDouble() < dodgeChance / 100)
				dmg = 0;

			other.mStats.mCurrentHP -= (int)dmg;

			if (other.mStats.mCurrentHP <= 0)
				this.mStats.mTotalExperience += (int)(25 * other.mStats.mLevel);

			other.onAttack(this, dmg);
		}

		public void Heal(float healAmount)
		{
			mStats.mCurrentHP = Math.Min(mStats.mCurrentHP + healAmount, mStats.mMaxHP);

			onHeal(healAmount);
		}

		public override void Update(int dt)
		{
			base.Update(dt);
			if (mPathfinder != null)
			{
				if (!mPathfinder.Update())
					SafeDeleteNullify!(mPathfinder);
			}

			if (mStats.mTotalExperience >= mStats.mNextLevelExperience)
			{
				Log!(ToStackString!(mStats));
				mStats.LevelUp();

				CreateLabel(ToStackString!("Level Up!"), new Color(64, 255, 64));
				Log!("Level Up!");
				Log!(ToStackString!(mStats));
			}
		}

		public override void Draw(int dt)
		{
			Image img = mImage;
			base.Draw(dt);
			if (!mVisiable)
				return;

			if (mHasMoved == true && mHasAttacked == true)
				img = mDisabledImage;

			var rec = GetPosAdjustedBoundingBox();
			SDL2.SDL.SetTextureColorMod(img.mTexture, mColor.R, mColor.G, mColor.B);
			gEngineApp.Draw(img, rec.x, rec.y);
			SDL2.SDL.SetTextureColorMod(img.mTexture, 255, 255, 255);
		}

		public void CreateLabel(String str, Color c = null)
		{
			GravityLabel l = new GravityLabel(ToStackString!(str), this.mPos.mX, this.mPos.mY);
			if (c != null)
				SafeMemberSet!(l.mColor, c);
			else
				SafeMemberSet!(l.mColor, new Color(255, 64, 64));
			l.RenderImage();
			l.mMaxUpdates = 45;
			l.mVel = 1.5f;
			l.mAngle = 140 + 90;
			if (gGameApp.mRand.NextDouble() > 0.5)
				l.mAngle -= 0;
			gGameApp.AddEntity(l);
		}

///* Events
		protected internal virtual void onAttack(RTSUnit other, float dmg)
		{
			var label = ToStackString!(Math.Truncate(dmg));
			if (dmg == 0)
			{
				label = "Miss!";
			}
			CreateLabel(label, new Color(255, 64, 64));

			if (this.mStats.mCurrentHP <= 0)
			{
				this.mIsDeleting = true;

				var pabb = GetPosAdjustedBoundingBox();
				pabb.x += pabb.w / 2;
				pabb.y += pabb.h / 2;
				Soul par = new Soul(new Vector2D(pabb.x, pabb.y), new Size2D(12, 12), .FG4);
				par.[Friend]mAnimationOffSet = gGameApp.mRand.Next(30);
				gGameApp.AddParticle(par);

				if (let battleGS = gGameApp.mGameState as Battle)
					battleGS.mRTSSystem.RemoveFromGrid(this);
			}
		}

		protected virtual void onHeal(float healAmount)
		{
			CreateLabel(ToStackString!(Math.Truncate(healAmount)), new Color(64, 255, 64));
		}

		public override bool onClick()
		{
			return base.onClick();
		}
	}
}
