using SDL2;
using System;
namespace EldrichDungeons.Items.Consumable
{
	class HighPotion : Item
	{
		public int HealthRestore = 25;

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
			return new HighPotion(mImage, mName, mItemType);
		}
	}
}
