using System.Collections;
using EldrichDungeons.Items;
using EldrichDungeons.Items.Equipment;
using EldrichDungeons.Items.Equipment.Armors;
using EldrichDungeons.Entity.RTSUnits;

namespace EldrichDungeons
{
	class Inventory
	{
		public RTSUnit mInventoryOwner;
		Equipment mEquipment = Equipment();
		public List<Item> mInventoryList = new List<Item>() ~ DeleteContainerAndItems!(_);

		int mInventorySize = 10;
		public int InventorySize
		{
			get { return mInventorySize; }
		}

		public this()
		{
		}

		public this(int size)
		{
			mInventorySize = size;
		}

		public this(RTSUnit owner)
		{
			mInventoryOwner = owner;
		}

		public Item this[int index]
		{
			get { return mInventoryList[index]; }
		}

		public bool Use(int InventorySlot)
		{
			Item item = mInventoryList[InventorySlot];
			bool ret = item.onUse(mInventoryOwner);
			return ret;
		}

		public void AddItem(Item i)
		{
			mInventoryList.Add(i);
		}
	}

	struct Equipment
	{
		Armor mHelmet;
		Armor mTorso;
		Armor mPants;
		Armor mShoes;
		Armor mGloves;
		Armor mCloak;

		public int TotalArmour
		{
			get
			{
				return mHelmet.mArmor + mTorso.mArmor + mPants.mArmor + mShoes.mArmor + mGloves.mArmor + mCloak.mArmor;
			}
		}

		Weapon mRightHand;
		Weapon mLeftHand;
	}
}
