using System;
namespace EldrichDungeons.Entity.RTSUnits
{
	class StatsCollection
	{
		//Experience
		public uint mLevel;
		public int mTotalExperience;
		public int mNextLevelExperience;
		public float mExperienceCurve;

		public float mCurrentHP;

		public float mMaxHP;
		public float mMaxHPGrowth;
		// Strength grants dmg reduction and Melee dmg
		public float mStrength;
		public float mStrengthGrowth;
		// Agility increases the chance to dodge a Attack and increases Ranged Attacks
		public float mAgility;
		public float mAgilityGrowth;
		// Luck also increases the chance to dodge and increases the chance to Critical strike and increases the chance
		// to proc secondary effects
		public float mLuck;
		public float mLuckGrowth;
		// Magic increases Magic DMG and Magic Def
		public float mMagic;
		public float mMagicGrowth;

		public this()
		{
			this.mMaxHP = 30;
			this.mCurrentHP = this.mMaxHP;
			this.mStrength = 5;
			this.mAgility = 2;
			this.mLuck = 2;
			this.mMagic = 2;

			this.mMaxHPGrowth = 1;
			this.mStrengthGrowth = 1;
			this.mAgilityGrowth = 1;
			this.mLuckGrowth = 1;
			this.mMagicGrowth = 1;

			this.mTotalExperience = 0;
			this.mExperienceCurve = 1.2f;

			mNextLevelExperience = (int)((mLevel * mLevel) * mExperienceCurve + 100);
		}

		public this(float maxHP, float str, float agi, float luck, float magic)
		{
			this.mMaxHP = maxHP;
			this.mCurrentHP = this.mMaxHP;
			this.mStrength = str;
			this.mAgility = agi;
			this.mLuck = luck;
			this.mMagic = magic;

			this.mTotalExperience = 0;
		}

		public void LevelUp()
		{
			mLevel++;
			mNextLevelExperience = (int)((mLevel * mLevel) * mExperienceCurve + 100);

			mMaxHP += gGameApp.mRand.Next((int32)Math.Min(mMaxHPGrowth - 1, 0), (int32)mMaxHPGrowth + 1);
			this.mCurrentHP = this.mMaxHP;

			mStrength += gGameApp.mRand.Next((int32)Math.Min(mStrengthGrowth - 1, 0), (int32)mStrengthGrowth + 1);
			mAgility += gGameApp.mRand.Next((int32)Math.Min(mAgilityGrowth - 1, 0), (int32)mAgilityGrowth + 1);
			mLuck += gGameApp.mRand.Next((int32)Math.Min(mLuckGrowth - 1, 0), (int32)mLuckGrowth + 1);
			mMagic += gGameApp.mRand.Next((int32)Math.Min(mMagicGrowth - 1, 0), (int32)mMagicGrowth + 1);
		}

		public void Roll(int maxMaxHP, int minMaxHP, int maxStr, int minStr, int maxAgi, int minAgi, int maxLuck, int minLuck, int maxMagic, int minMagic)
		{
			this.mMaxHP = gGameApp.mRand.Next(minMaxHP, maxMaxHP);
			this.mCurrentHP = this.mMaxHP;
			this.mStrength = gGameApp.mRand.Next(minStr, maxStr);
			this.mAgility = gGameApp.mRand.Next(minAgi, maxAgi);
			this.mLuck = gGameApp.mRand.Next(minLuck, maxLuck);
			this.mMagic = gGameApp.mRand.Next(minMagic, maxMagic);
		}

		public override void ToString(System.String strBuffer)
		{
			strBuffer.AppendF("Stats:\n");
			strBuffer.AppendF("{}/{} HP\n", mCurrentHP, mMaxHP);
			strBuffer.AppendF("{} LVL\n", mLevel);
			strBuffer.AppendF("{} STR\n", mStrength);
			strBuffer.AppendF("{} AGI\n", mAgility);
			strBuffer.AppendF("{} Luck\n", mLuck);
			strBuffer.AppendF("{} Magic", mMagic);
		}
	}
}
