using BasicEngine.HUD;
using BasicEngine;
using System;
using System.Collections;
using EldrichDungeons.Entity.RTSUnits;

namespace EldrichDungeons.HUD.Elements
{
	class StatPickerd : Form
	{
		public bool mOffsetted = false;
		private Vector2D mOffSetPos = new Vector2D(0, 0) ~ SafeDelete!(_);

		enum ListNames : int
		{
			PanelsExt = 0,
			PanelsSmall = 1,
			Labels = 2
		}

		public this()
		{
			mComponentContainers.Add(new ComponentContainer());// Panel extended list
			mComponentContainers.Add(new ComponentContainer());// Panel small list
			mComponentContainers.Add(new ComponentContainer());// Stats list

			Formater formater = scope Formater();
			formater.compWidth = 54;
			formater.combHeight = 20;
			formater.xPadding = 15;
			formater.yPadding = 0;
			formater.xOffset = 0;
			formater.yOffset = 0;
			formater.columnIndex = 0;

			mPos.Set(10, 740 - 20 * 5);

			mOffSetPos.Set(210, mPos.mY);

			var bg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Background
			SafeMemberSet!(bg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(bg.mSize, new Size2D(160, formater.combHeight * 6));
			bg.mSize.mY += formater.combHeight;//padding
			{
				var pos = formater.GetNewPos();
				bg.mPos.Set(pos);
				delete pos;
			}
			bg.mPos.mX -= 10;
			bg.mPos.mY -= 10;
			bg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(bg);

			var middleLine = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Middle line
			SafeMemberSet!(middleLine.mColor, new Color(64, 64, 64));
			SafeMemberSet!(middleLine.mSize, new Size2D(bg.mSize.mX / 2, formater.combHeight * 6));
			middleLine.mSize.mY += formater.combHeight;//padding
			{
				var pos = formater.GetNewPos();
				middleLine.mPos.Set(pos);
				delete pos;
			}
			middleLine.mPos.mX -= 10;
			middleLine.mPos.mY -= 10;
			middleLine.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(middleLine);

			var namebg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Name background
			SafeMemberSet!(namebg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(namebg.mSize, new Size2D(bg.mSize.mX, formater.combHeight / 2));
			namebg.mSize.mY += formater.combHeight;//padding
			{
				var pos = formater.GetNewPos();
				namebg.mPos.Set(pos);
				delete pos;
			}
			namebg.mPos.mX -= 10;
			namebg.mPos.mY -= 10;
			namebg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(namebg);

			var lvlbg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Level background
			SafeMemberSet!(lvlbg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(lvlbg.mSize, new Size2D(bg.mSize.mX / 12 * 7, formater.combHeight / 2));
			lvlbg.mSize.mY += formater.combHeight;//padding
			{
				var pos = formater.GetNewPos();
				lvlbg.mPos.Set(pos);
				delete pos;
			}
			lvlbg.mPos.mX -= 10;
			lvlbg.mPos.mY -= 10;
			lvlbg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(lvlbg);

			List<String> texts = scope List<String>()
				{
					"HP", "STR", "AGI", "LUCK", "MAGIC"
				};
			{
				var pos = formater.GetNewPos();
				var nameLabel = new BasicEngine.HUD.Label("name", pos.mX, pos.mY) { mVel = 0, mMaxUpdates = 0 };
				mComponentContainers[(int)ListNames.Labels].Add(nameLabel);
				delete pos;
			}
			{
				var pos = formater.GetNewPos();
				pos.mX = lvlbg.mPos.mX + lvlbg.mSize.mX + 10;
				var lvlLabel = new BasicEngine.HUD.Label("lvl", pos.mX, pos.mY) { mVel = 0, mMaxUpdates = 0 };
				mComponentContainers[(int)ListNames.Labels].Add(lvlLabel);
				delete pos;
			}
			formater.rowIndex = 0;
			formater.columnIndex++;
			for (int i < texts.Count)
			{
				if (i > 0)
					formater.xMargin = 40;// Indent everything after HP

				var pos = formater.GetNewPos();
				var val = new BasicEngine.HUD.Label("0", pos.mX, pos.mY) { mVel = 0, mMaxUpdates = 0 };
				mComponentContainers[(int)ListNames.Labels].Add(val);

				formater.xMargin = 15;

				formater.rowIndex++;
				delete pos;

				pos = formater.GetNewPos();
				var l = new BasicEngine.HUD.Label(texts[i], lvlbg.mPos.mX + lvlbg.mSize.mX + 5, pos.mY) { mVel = 0, mMaxUpdates = 0 };
				mComponentContainers[(int)ListNames.Labels].Add(l);

				formater.rowIndex--;

				formater.columnIndex++;
				delete pos;
			}

			var boxPos = scope Vector2D(mComponentContainers[(int)ListNames.Labels][0].mPos);
			boxPos.mX = 0;
			boxPos.mY -= 10;// offset panel up for padding
			/*
			bg.mPos.Set(boxPos);
			middleLine.mPos.Set(boxPos);
			namebg.mPos.Set(boxPos);
			lvlbg.mPos.Set(boxPos);
			mOffSetPos.Set(boxPos);*/

			SetVisibility(false);
			Move(mPos);
			AddToEntityList();
		}

		public void UpdateStatDisplay(RTSUnit unit)
		{
			if (unit == null)
			{
				SetVisibility(false);
				return;
			}

			SetVisibility(true);

			((Label)mComponentContainers[(int)ListNames.Labels][0]).SetString(GlobalStringFormat!("{}", unit.mName));
			if (unit.mName.Length > 8)
			{
				int32 fontsize = Math.Max((int32)(16 - (unit.mName.Length - 8) * 2), 1);
				((Label)mComponentContainers[(int)ListNames.Labels][0]).SetFont("zorque.ttf", fontsize);
			}
			else
			{
				((Label)mComponentContainers[(int)ListNames.Labels][0]).SetFont("zorque.ttf", 16);
			}
			((Label)mComponentContainers[(int)ListNames.Labels][1]).SetString(GlobalStringFormat!("{:00} LVL", unit.mStats.mLevel + 1));
			((Label)mComponentContainers[(int)ListNames.Labels][2]).SetString(GlobalStringFormat!("{:00}/{:00}", unit.mStats.mCurrentHP, unit.mStats.mMaxHP));
			//((Label)mComponentContainers[1][4]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mLevel + 1));
			((Label)mComponentContainers[(int)ListNames.Labels][4]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mStrength));
			((Label)mComponentContainers[(int)ListNames.Labels][6]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mAgility));
			((Label)mComponentContainers[(int)ListNames.Labels][8]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mLuck));
			((Label)mComponentContainers[(int)ListNames.Labels][10]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mMagic));

			/*((Label)mComponentContainers[1][0]).SetString(GlobalStringFormat!("{:00}/{:00}", unit.mStats.mCurrentHP, unit.mStats.mMaxHP));
			((Label)mComponentContainers[1][2]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mLevel + 1));
			((Label)mComponentContainers[1][4]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mStrength));
			((Label)mComponentContainers[1][6]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mAgility));
			((Label)mComponentContainers[1][8]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mLuck));
			((Label)mComponentContainers[1][10]).SetString(GlobalStringFormat!("{:00}", unit.mStats.mMagic));*/

			/*float maxWidth = 0;
			for (int i = 1; i <= 11; i+=2)
			{
				if(mStatBox[i].mSize.mX > maxWidth)
				{
					maxWidth = mStatBox[i].mSize.mX;
					Log!(i);
				}
			}
			Log!(maxWidth);
			mStatBox[0].mSize.mX = maxWidth+20;
			mStatBox[0].Init();*/
		}
	}
}
