using BasicEngine.HUD;
using BasicEngine;
using System;
using System.Collections;
using EldrichDungeons.Entity.RTSUnits;

namespace EldrichDungeons.HUD.Elements
{
	class StatPicker : Form
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
			formater.xMargin = 20;
			formater.xOffset = 25;
			formater.yOffset = 10;
			formater.columnIndex = 0;

			mPos.Set(0, 740 - 20 * 5);

			mOffSetPos.Set(210, mPos.mY);

			var bg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Background
			SafeMemberSet!(bg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(bg.mSize, new Size2D(160, formater.combHeight * 6));
			bg.mSize.mY += formater.combHeight;//padding
			bg.mOffset.Set(mPos);
			bg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(bg);

			var namebg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Level background
			namebg.mParent = bg;
			SafeMemberSet!(namebg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(namebg.mSize, new Size2D(bg.mSize.mX / 12 * 7, formater.combHeight / 2));
			namebg.mSize.mY += formater.combHeight;//padding

			namebg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(namebg);

			var lvlbg = new BasicEngine.HUD.HUDComponent() { mCenter = false };// Name background
			lvlbg.mParent = bg;
			SafeMemberSet!(lvlbg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(lvlbg.mSize, new Size2D(bg.mSize.mX - namebg.mSize.Width, formater.combHeight / 2));
			lvlbg.mSize.mY += formater.combHeight;//padding
			lvlbg.mOffset.mX = namebg.mSize.Width;
			lvlbg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(lvlbg);

			var valuebg = new BasicEngine.HUD.HUDComponent() { mCenter = false };
			valuebg.mParent = bg;
			SafeMemberSet!(valuebg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(valuebg.mSize, new Size2D(bg.mSize.mX / 2, formater.combHeight * 6));
			valuebg.mSize.mY += formater.combHeight;//padding
			valuebg.mSize.mY -= namebg.mSize.mY;
			valuebg.mOffset.mY = namebg.mSize.mY;
			valuebg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(valuebg);

			var labelbg = new BasicEngine.HUD.HUDComponent() { mCenter = false };
			labelbg.mParent = bg;
			SafeMemberSet!(labelbg.mColor, new Color(64, 64, 64));
			SafeMemberSet!(labelbg.mSize, new Size2D(bg.mSize.mX / 2, formater.combHeight * 6));
			labelbg.mSize.mY += formater.combHeight;//padding
			labelbg.mSize.mY -= namebg.mSize.mY;
			labelbg.mOffset.mY = namebg.mSize.mY;
			labelbg.mOffset.mX = valuebg.mSize.mX;
			labelbg.Init();
			mComponentContainers[(int)ListNames.PanelsExt].Add(labelbg);


			List<String> texts = scope List<String>()
				{
					"HP", "STR", "AGI", "LUCK", "MAGIC"
				};

			var nameLabel = new BasicEngine.HUD.Label("name") { mVel = 0, mMaxUpdates = 0 };
			nameLabel.mParent = namebg;
			nameLabel.mOffset.mX = (namebg.mSize.Width / 2);
			nameLabel.mOffset.mY = (namebg.mSize.Height / 2);

			mComponentContainers[(int)ListNames.Labels].Add(nameLabel);

			var lvlLabel = new BasicEngine.HUD.Label("lvl") { mVel = 0, mMaxUpdates = 0 };
			lvlLabel.mParent = lvlbg;
			SafeMemberSet!(lvlLabel.mOffset, formater.GetNewPos());
			lvlLabel.mOffset.mX = (lvlbg.mSize.Width / 2);
			lvlLabel.mOffset.mY = (lvlbg.mSize.Height / 2);

			mComponentContainers[(int)ListNames.Labels].Add(lvlLabel);

			formater.rowIndex = 0;
			formater.columnIndex = 0;
			formater.xMargin = (int)(valuebg.mSize.Width / 2);// Indent everything after HP
			for (int i < texts.Count)
			{
				var val = new BasicEngine.HUD.Label("0") { mVel = 0, mMaxUpdates = 0 };
				SafeMemberSet!(val.mOffset, formater.GetNewPos());
				Log!(val.mOffset.mX, val.mOffset.mY);
				val.mOffset.mX = (valuebg.mSize.Width / 2);
				val.mParent = valuebg;
				mComponentContainers[(int)ListNames.Labels].Add(val);

				var l = new BasicEngine.HUD.Label(texts[i]) { mVel = 0, mMaxUpdates = 0 };
				SafeMemberSet!(l.mOffset, formater.GetNewPos());
				l.mOffset.mX = (valuebg.mSize.Width / 2);
				Log!(l.mOffset.mX, l.mOffset.mY);
				l.mParent = labelbg;
				mComponentContainers[(int)ListNames.Labels].Add(l);

				formater.columnIndex++;
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
			AddToEntityList();
		}

		public override void Move(float x, float y)
		{
			mComponentContainers[(int)ListNames.PanelsExt][0].mOffset.mX += x;
			mComponentContainers[(int)ListNames.PanelsExt][0].mOffset.mY += y;
			mComponentContainers[(int)ListNames.PanelsExt][0].CalculatePos();
		}

		public void UpdateStatDisplay(RTSUnit unit)
		{
			if (unit == null)
			{
				SetVisibility(false);
				return;
			}

			SetVisibility(true);
			mComponentContainers[(int)ListNames.PanelsExt][0].mVisiable = false;

			((Label)mComponentContainers[(int)ListNames.Labels][0]).SetString(GlobalStringFormat!("{}", unit.mName));
			if (unit.mName.Length > 7)
			{
				int32 fontsize = Math.Max((int32)(16 - (unit.mName.Length - 8) * 2), 1);
				((Label)mComponentContainers[(int)ListNames.Labels][0]).SetFont("zorque.ttf", fontsize);
				((Label)mComponentContainers[(int)ListNames.Labels][0]).RenderImage();
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
