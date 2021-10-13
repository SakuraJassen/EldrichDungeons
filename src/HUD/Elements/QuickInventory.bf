using BasicEngine.HUD;
using System;
using BasicEngine;
using EldrichDungeons.RTSSystem;
namespace EldrichDungeons.HUD.Elements
{
	class QuickInventory : Form
	{
		public int mPage = 0;
		public int mMaxPage = 0;
		public int mPageSize = 5;

		private HUDComponent mBackground = new HUDComponent() { mCenter = true };

		private Inventory mCurrentInventory = null;

		public this(int pageSize, Inventory inv)
		{
			mPageSize = pageSize;

			SafeMemberSet!(mBackground.mColor, new Color(64, 64, 64));
			SafeMemberSet!(mBackground.mSize, new Size2D(100, 25 * (mPageSize + 1)));
			mBackground.mSize.mY += 25;
			mBackground.mOffset.Set(mPos);
			mBackground.Init();

			gEngineApp.AddEntity(mBackground);

			if (inv != null)
				SetIventory(inv);

			ChangePage(-1);
		}

		public void SetIventory(Inventory inv)
		{
			mMaxPage = (int)Math.Ceiling((float)inv.mInventoryList.Count / (float)mPageSize);

			ClearAndDeleteItems!(mComponentContainers);

			for (var i <= mMaxPage)
				mComponentContainers.Add(new ComponentContainer());

			Formater f = scope Formater();

			int currentItemIndex = 0;

			for (var page < mMaxPage)
			{
				f = scope Formater();
				f.xOffset = 25;
				f.yOffset = 15;
				f.xPadding = 5;
				f.yPadding = 5;
				f.compWidth = 50 - (f.xPadding);
				f.combHeight = 25;
				{
					var backBtn = new BasicEngine.HUD.Button(new .(0, 0), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "<-");
					backBtn.mParent = mBackground;
					backBtn.mEnabled = (page > 0);
					backBtn.mClickEvents.Add(new () =>
						{
							ChangePage(page - 1);
							return true;
						});
					mComponentContainers[page].Add(backBtn);
				}
				f.xOffset += f.compWidth + f.xPadding;
				{
					var nextBtn = new BasicEngine.HUD.Button(new .(0, 0), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), "->");
					nextBtn.mParent = mBackground;
					nextBtn.mEnabled = (page < mMaxPage - 1);
					nextBtn.mClickEvents.Add(new () =>
						{
							ChangePage(page + 1);
							return true;
						});
					mComponentContainers[page].Add(nextBtn);
				}

				f.xOffset = 50;
				f.yOffset = 50 + f.yPadding;
				f.compWidth = 100;
				for (var cnt = 0; cnt < mPageSize && currentItemIndex < inv.mInventoryList.Count; cnt++)
				{
					var btn = new BasicEngine.HUD.Button(new .(0, 0), new .(f.compWidth, f.combHeight), new .(f.xOffset, f.yOffset), inv.mInventoryList[currentItemIndex].Name);
					btn.mParent = mBackground;
					btn.mClickEvents.Add(new () =>
						{
							if (inv.Use(currentItemIndex))
							{
								delete GetAndRemove!(inv.mInventoryList, currentItemIndex);
								Close();
								inv.mInventoryOwner.mHasAttacked = true;
							}
							return false;
						});
					mComponentContainers[page].Add(btn);
					currentItemIndex++;
					f.yOffset += 25 + f.yPadding;
				}
			}

			AddToEntityList();
			SetVisibility(false);
		}

		public void Close()
		{
			ChangePage(-1);
		}

		public void ChangePage(int page)
		{
			if (page == -1)
				mBackground.mVisiable = false;
			else
				mBackground.mVisiable = true;

			mPage = page;

			for (var i < mComponentContainers.Count)
			{
				mComponentContainers[i].SetVisibility(i == page);
				//mComponentContainers[i].SetEnabled(i == page);
			}
		}

		public void OpenAt(Vector2D pos)
		{
			Log!(pos.mX, pos.mY);
			ChangePage(0);
			mBackground.mOffset.mX = pos.mX;
			mBackground.mOffset.mY = pos.mY;
			mBackground.CalculatePos();
		}
	}
}
