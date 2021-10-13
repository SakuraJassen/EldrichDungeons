using System.Collections;
using System;
using System.IO;
using EldrichDungeons.Items.Equipment;

namespace EldrichDungeons.Items
{
	static class ItemHandler
	{
		static List<Item> mItemDatabase;

		static void Init()
		{
			mItemDatabase.Add(new Item());
		}

		static void Dispose()
		{
			DeleteContainerAndItems!(mItemDatabase);
		}

		static Item CreateItemByType(uint32 itemType)
		{
			return mItemDatabase[mItemDatabase.FindIndex(scope (_) => _.ItemType == itemType)].Create();
		}

		static public Result<void> LoadItemData()
		{
			StreamReader sr = scope StreamReader();
			using (sr.Open(scope $"items/items"))
			{
				//var sizeValue = ReadNextLine(sr);
			}

			return .Ok;
		}

		static public List<int> ReadNextLine(StreamReader sr)
		{
			String value = scope .("");
			sr.ReadLine(value);
			var split = value.Split!(',');
			var list = new List<int>();
			for (var val in split)
			{
				val.Trim();
				list.Add(int.Parse(val));
			}

			return list;
		}
	}
}
