using SDL2;
using System;
namespace EldrichDungeons.Items.Consumable
{
	class LowPotion : Item
	{
		public int HealthRestore = 10;

		public this(Image img, String name, uint32 id) : base(img, name, id)
		{
		}

		public override bool onUse(EldrichDungeons.Entity.RTSUnits.RTSUnit user)
		{
			user.Heal(HealthRestore);
			return true;
		}

		public override Item Create()
		{
			return new LowPotion(mImage, mName, mItemType);
		}
	}
}
