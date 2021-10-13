using System;
using SDL2;
using EldrichDungeons.Entity.RTSUnits;

namespace EldrichDungeons.Items
{
	class Item
	{
		protected Image mImage = null;

		protected String mName ~ SafeDelete!(_);
		public String Name
		{
			get { return mName; }
		}

		protected uint32 mItemType;
		public uint32 ItemType
		{
			get { return mItemType; }
		}

		public this()
		{
		}

		public this(Image img, String name, uint32 type)
		{
			mImage = img;
			mName = name;
			mItemType = type;
		}

		public virtual Self Create()
		{
			Log!("Called base create");
			return new Self(mImage, mName, mItemType);
		}

//### Events
		///*
		// returns true if the Item should be consumed
		///*
		public virtual bool onUse(RTSUnit user)
		{
			return true;
		}

		public virtual bool onDiscard(RTSUnit user)
		{
			return true;
		}

		public virtual bool onObtained(RTSUnit user)
		{
			return true;
		}
	}
}
