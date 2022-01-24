Function_Load_In = true
local Function_Version = "0113"
textout(Check_UI("野外打怪 - "..Function_Version,"Mobs Farm - "..Function_Version))

local BOT_Frame = CreateFrame("frame")
awm.RunMacroText("/console scriptErrors 1")

local frame=CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
local function frame_Initial()
	frame:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",edgeFile="Interface/ChatFrame/ChatFrameBackground",tile=true,edgeSize=1,tileSize=5,})
	frame:SetSize(4096,2160)
	frame:SetPoint("CENTER")
	frame:Show()
	frame:SetMovable(false)
	frame:SetBackdropColor(0,0,0,0)
	frame:SetBackdropBorderColor(0,0,0,0)

	local Notice = frame:CreateFontString(nil,"OVERLAY","ArtifactAppearanceSetHighlightFont")
	Notice:SetPoint("CENTER",0,30)
	Notice:SetText(Check_UI("无","Null"))
	Notice:Show()

	return Notice
end
local Notice = frame_Initial()
local Note_Head = "" -- Notice 的头部
local function Note_Set(text)
    Notice:SetText("|CFF00FF00"..date([[%H:%M:%S]]).." |CFFDBDB70["..Note_Head.."] |CFFFFFFFF"..text)
end


_,Class = awm.UnitClass("player")
local Faction = UnitFactionGroup("player")
local Realm = GetRealmName() -- 服务器名称
Level = awm.UnitLevel("player")
local _,Race = UnitRace("player")
------------------------------------------------------------------------
local Run_Time = GetTime()

Easy_Data.Sever_Map_Calculated = false
Continent_Move = false

local teleport = {x = 0, y = 0, z = 0, timer = false, time = 0}
local Destroy_Time = 0 -- 自动摧毁

local Grind = {Step = 1, Move = 1}
local Target_Info = {
    Mob = nil,
	GUID = nil,
	objx = nil,
	objy = nil,
	objz = nil,
	Item = nil,
}

local Sell = {
	Step = 1,
	Bag = 0,
	Timer = false,
	Time = 0,
	Slot = 1,
	Item_Name = "",
	Lack_Money = false,
	Repair_Money = 0,
	Interact_Step = false,
}

local Mail_Info = {
	Timer = false,
	Time = 0,
}

local Scan_Time = 0 -- 扫描间隔时间

local Loot_Timer = false
local Loot_Time = 0

local Gather_Timer = false -- 采集计时
local Gather_Time = GetTime() -- 开始采集时间

local Skin_Timer = false
local Skin_Time = 0

local Black_List = {} -- 采集黑名单
local Monster_Has_Killed = {}
local Combat_Target = nil -- 需要击杀的干扰目标
local Recheck_Target = false -- 重新检查目标的pointer
local Combating = false -- 正在战斗
local Stop_Yet = false -- 停止采集

local Has_Call_Pet = false -- 召唤宠物

local Interact_Step = false
local Eat_Time = 0 -- 吃喝 制造食物 间隔计时
local Start_Restore = false -- 是否正在回血

local Learn_Step = 1 -- 学技能步骤
local Learn_Time = 0
local Has_Mail = false -- 邮寄过了

local Combat_In_Range = false
local Scan_Combat = false -- 巡逻反击

local Execute_File = ""

local Has_Fly = false
local Fly_Z = 0 -- 飞行高度保持
local Fly_Scan = 0 -- 飞行高度扫描

local Combat = {
    Multi_Target = false,
	Vanish = 0, -- 盗贼消失计时
	Time = 0,
	Hunter_Trap = 0, -- 猎人陷阱计时
	Face_Time = GetTime(),
	Forst = false,
	Combat_In_Range = false,

	Fixed_Target = false,
	Fixed_Time = 0,
}

local Dead = {
    Repop = GetTime(),
	Shift = false,
	Shift_Step = 1,
	Safe = {},
}

local Food_Full_List = {
    21215,
    21023,
    20031,
    19301,
    20516,
    19996,
    21236,
    23172,
    21240,
    21254,
    19995,
    21235,
    19696,
    19994,
    8932,
    20452,
    13893,
    18255,
    13810,
    18254,
    8952,
    13724,
    13935,
    8953,
    8948,
    8950,
    8076,
    11415,
    13933,
    13934,
    21033,
    21031,
    23160,
    16171,
    12763,
    11444,
    19225,
    22324,
    13755,
    13931,
    13928,
    3927,
    6887,
    4599,
    13932,
    13929,
    4608,
    13930,
    4602,
    13927,
    16766,
    21552,
    4601,
    19306,
    9681,
    21030,
    16168,
    8075,
    17408,
    18635,
    12218,
    16971,
    18045,
    12216,
    21217,
    17222,
    12215,
    4457,
    13546,
    12210,
    8364,
    3771,
    13851,
    3729,
    12213,
    4594,
    12214,
    4539,
    1707,
    18632,
    12212,
    4544,
    19224,
    4607,
    17407,
    16169,
    1487,
    6038,
    8543,
    12211,
    6807,
    20074,
    3728,
    1119,
    5527,
    4593,
    3770,
    7228,
    12209,
    3665,
    4538,
    3664,
    3663,
    3726,
    4606,
    5480,
    1017,
    3727,
    3666,
    422,
    19305,
    4542,
    1114,
    16170,
    5479,
    21072,
    1082,
    5526,
    5478,
    2685,
    12238,
    5525,
    4592,
    5095,
    2683,
    2684,
    2687,
    6890,
    4537,
    2287,
    4541,
    3220,
    414,
    17119,
    2682,
    4605,
    5477,
    724,
    733,
    1113,
    5066,
    3662,
    19304,
    5476,
    16167,
    6316,
    17406,
    18633,
    3448,
    1326,
    17198,
    5474,
    17199,
    2888,
    2680,
    6888,
    2681,
    17197,
    12224,
    5472,
    11109,
    7808,
    7806,
    7807,
    6299,
    6290,
    787,
    5349,
    19223,
    2679,
    7097,
    16166,
    17344,
    4536,
    2070,
    11584,
    961,
    4604,
    117,
    4540,
    4656,
    5057,
    33053,
    34062,
    34780,
    32722,
    27663,
    22019,
    29394,
    29448,
    29449,
    29450,
    29451,
    29452,
    29453,
    30355,
    30357,
    30358,
    30359,
    30361,
    32685,
    32686,
    33048,
    33052,
    33872,
    38428,
    22895,
    24008,
    24009,
    24539,
    27651,
    27655,
    27657,
    27658,
    27659,
    27660,
    27661,
    27662,
    27664,
    27665,
    27666,
    27667,
    27854,
    27855,
    27856,
    27857,
    27858,
    27859,
    28486,
    29393,
    29412,
    30155,
    30458,
    30610,
    31672,
    31673,
    32721,
    33867,
    38427,
    24338,
    28501,
    29292,
}

local Drink_Full_List = {
    33053,
    34062,
    34780,
    20031,
    32722,
    22018,
    27860,
    29395,
    29401,
    30457,
    32453,
    32668,
    33042,
    34411,
    38431,
    28399,
    29454,
    30703,
    33825,
    38430,
    8079,
    18300,
    32455,
    8766,
    8078,
    1645,
    8077,
    19300,
    4791,
    1708,
    10841,
    3772,
    1205,
    9451,
    2136,
    1179,
    2288,
    17404,
    5350,
    159,
}

local Health_Full_List = {
    33934,
	31676,
	929,
	18253,
	2456,
	22829,
	17349,
	28100,
	33092,
	22829,
	22836,
	18839,
	31839,
	31853,
	4596,
	1710,
	858,
	13446,
	118,
	32763,
	22850,
	3928,
	9144,
	12190,
	20002,
	34440,
	31838,
	31852,
	32947,
}

local Mana_Full_List = {
    32948,
	22832,
	33935,
	20002,
	31677,
	3385,
	17351,
	13444,
	3827,
	32762,
	22850,
	9144,
	31840,
	31855,
	31841,
	33093,
	32902,
	12190,
	22836,
	6149,
	34440,
	17352,
	18253,
	2455,
	13443,
	28101,
	18841,
	31854,
	2456,
}

local Arrow_Full_List = {
    28056,
	28053,
	11285,
	3030,
	2515,
	2512,
}

local Bullet_Full_List = {
    28061,
	28060,
	11284,
	3033,
	2519,
	2516,
}

local Poison_Full_List = {
    6947,
	6949,
	6950,
	8926,
	8927,
	8928,
	21927,
}

local Auto_Purchase = {
    Lack_Money = false,
	Hunter_Ammo = false, -- 猎人子弹
	Hunter_PetFood = false,
	Rogue_Poison = false, -- 盗贼毒药
	Rogue_FlashPowder = false, -- 盗贼闪光粉
	Food = false,
	One_Time_Supply = false,
}

local function Grind_Config()

	Merchant_Name = "" -- 商人名字
	Merchant_Coord = {mapid = 0, x = 0, y = 0, z = 0}
	Mail_Coord = {mapid = 0, x = 0, y = 0, z = 0}

	Mobs_ID = {} -- 怪物ID
	Mobs_Coord = {}
	Mobs_MapID = 0
	Black_Spot = {}

	Ammo_Vendor_Name = "" -- 弹药商
	Ammo_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}

	Food_Vendor_Name = "" -- 吃喝购买
	Food_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}
	Food_Name = ""
	Drink_Name = ""

	Pet_Food_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}
	Pet_Food_Vendor_Name = ""
end
Grind_Config()

function Event_Reset()
    Grind.Step = 1
	Target_Info.Item = nil
    Target_Info.GUID = nil
    Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
	Dead.Shift = false
	Dead.Shift_Step = 1
	Dead.Safe = {}
end

function CheckDeadOrNot() -- 判断角色是否死亡
    if awm.UnitIsDeadOrGhost("player") and not CheckBuff("player",rs["假死"]) then
	    if not awm.UnitIsGhost("player") then
		    if not awm.GetCorpsePosition() then
			    return
			end
		    Dead.Repop = GetTime()
			Event_Reset()
			RepopMe()
			return true
		end
		if awm.UnitIsGhost("player") then
			return true
		end
	end
	return false
end
function Death_Run() -- 角色死亡，用寻路call跑尸体
   if GetTime() - Dead.Repop <= 8 then
	    Note_Set(Check_UI("等待跑尸复活时间 = ","Time waitting for going to Retrieve Corpse = ")..math.floor(8 - GetTime() + Dead.Repop))
	    return
	elseif GetTime() - Dead.Repop > 600 then
	    Note_Set(Check_UI("跑尸超过十分钟, 自动天使复活 = ","Dead time over 10 minutes, go to find Spirit Healer = ")..math.floor(GetTime() - Dead.Repop))
		
		awm.ClearTarget()
		awm.TargetUnit(Check_Client("灵魂医者","Spirit Healer"))
		if not awm.ObjectExists("target") then
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
			end
		    awm.Stuck()
		else			
			local distance = awm.GetDistanceBetweenObjects("player","target")
			local x,y,z = awm.ObjectPosition("target")
			if distance > 2 then
			    Run(x,y,z)
				Interact_Step = false
			else
			    AcceptXPLoss()
			    if Gossip_Show then
					if not Interact_Step then
						Interact_Step = true
						C_Timer.After(1, function() Interact_Step = false SelectGossipOption(1) end)
					end
					return
				else
					if not Interact_Step then
						Interact_Step = true
						C_Timer.After(1, function() Interact_Step = false awm.InteractUnit("target") end)
					end
					return	
				end
			end
			return
		end
	    return
	end

	Event_Reset()

	local deathx,deathy,deathz = awm.GetCorpsePosition()
	local Px,Py,Pz = awm.ObjectPosition("player")
	local DeathDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,deathx,deathy,deathz)
	if DeathDistance == nil then
	    return
	end
	if Coprse_In_Range then
	    awm.RetrieveCorpse()
	end
	
	if Dead.Shift then
		if Dead.Shift_Step == 6 then
		    local DeathDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Dead.Safe.x,Dead.Safe.y,Dead.Safe.z)
			if DeathDistance >= 2 then
			    Note_Set(Check_UI("安全地点剩余距离 = ","Safe Point Corpse Distance = ")..math.floor(DeathDistance))
				Run(Dead.Safe.x,Dead.Safe.y,Dead.Safe.z)
				return
			else
			    Note_Set(Check_UI("复活尸体","Retrieve Corpse"))
			    if GetUnitSpeed("player") > 0 then
					Try_Stop()
				end
				awm.RetrieveCorpse()
			end
			return
		elseif Dead.Shift_Step == 5 then
			if DeathDistance >= 2 then
			    Note_Set(Check_UI("安全地点剩余距离 = ","Safe Point Corpse Distance = ")..math.floor(DeathDistance))
				Run(deathx,deathy,deathz)
				return
			else
			    Note_Set(Check_UI("复活尸体","Retrieve Corpse"))
			    if GetUnitSpeed("player") > 0 then
					Try_Stop()
				end
				awm.RetrieveCorpse()
			end
			return
		elseif Dead.Shift_Step == 1 then
		    Dead.Safe.x,Dead.Safe.y,Dead.Safe.z = deathx + 10, deathy + 10, deathz
		elseif Dead.Shift_Step == 2 then
		    Dead.Safe.x,Dead.Safe.y,Dead.Safe.z = deathx - 10, deathy + 10, deathz
		elseif Dead.Shift_Step == 3 then
		    Dead.Safe.x,Dead.Safe.y,Dead.Safe.z = deathx - 10, deathy - 10, deathz
		elseif Dead.Shift_Step == 4 then
		    Dead.Safe.x,Dead.Safe.y,Dead.Safe.z = deathx + 10, deathy - 10, deathz
		end

		Note_Set(Check_UI("更换安全地点复活","Find safe point to retrieve"))
		local total = awm.GetObjectCount()
		Dead.Safe.x,Dead.Safe.y,Dead.Safe.z = awm.FindClosestPointOnMesh(select(8, GetInstanceInfo()),Dead.Safe.x,Dead.Safe.y,Dead.Safe.z)
		for i = 1,total do
			local ThisUnit = awm.GetObjectWithIndex(i)
			if awm.IsGuid(ThisUnit) then
				local name = awm.UnitFullName(ThisUnit)
				local x,y,z = awm.ObjectPosition(ThisUnit)
				local distance = awm.GetDistanceBetweenPositions(x,y,z,Dead.Safe.x,Dead.Safe.y,Dead.Safe.z)
				local Level_Gap = awm.UnitLevel("player") - awm.UnitLevel(ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and Level_Gap <= 6 and not awm.UnitAffectingCombat(ThisUnit) and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("pet") and distance <= 8 then
					Dead.Shift_Step = Dead.Shift_Step + 1
					return
				end
			end
		end
		Dead.Shift_Step = 6
		return
	elseif DeathDistance > 30 then
	    Note_Set(Check_UI("剩余距离 = ","Corpse Distance = ")..math.floor(DeathDistance))
		Run(deathx,deathy,deathz)
		return
	elseif DeathDistance <= 30 then
	    Note_Set(Check_UI("复活尸体","Retrieve Corpse"))
		if not Dead.Shift then
			local total = awm.GetObjectCount()
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				if awm.IsGuid(ThisUnit) then
					local name = awm.UnitFullName(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local Level_Gap = awm.UnitLevel("player") - awm.UnitLevel(ThisUnit)
					if awm.ObjectIsUnit(ThisUnit) and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and Level_Gap <= 6 and not awm.UnitAffectingCombat(ThisUnit) and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("pet") and distance <= 8 then
						Dead.Shift = true
						textout(Check_UI("附近8码有敌人, 不宜复活","Enemies in 8 yard distance, change retrieve place"))
						return
					end
				end
			end
		end

	    if GetUnitSpeed("player") > 0 then
			Try_Stop()
		end
		awm.RetrieveCorpse()
	end
end

function NeedHeal()-- 判断血蓝吃喝
    if not awm.UnitAffectingCombat("player") then
		local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	    local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100

		if Cur_Health < 99 and not CheckBuff("player",rs["进食"]) then
			Note_Set(Check_UI("使用回血...","Restore health..."))
			if IsMounted() then
				Dismount()
			end
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
			    local Mage_Food = EatCount()
				if Mage_Food and GetTime() - Eat_Time > 1.5 and select(5,GetItemInfo(Mage_Food)) <= UnitLevel("player") then
				    Eat_Time = GetTime()
					awm.UseItemByName(Mage_Food)
					textout(Check_UI("使用回血物品 = ","Eat Food = ")..Mage_Food)
					return false
				end

			    for i = 1,#Food_Full_List do
					local Food_Level = select(5,GetItemInfo(Food_Full_List[i]))
					if Food_Level and GetItemCount(Food_Full_List[i]) > 0 and UnitLevel("player") >= Food_Level and GetTime() - Eat_Time > 1.5 then
						Eat_Time = GetTime()
						awm.UseItemByName(Food_Full_List[i])
						textout(Check_UI("使用回血物品 = ","Eat Food = ")..select(1,GetItemInfo(Food_Full_List[i])))
						return false
					end
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(5,function() Stop_Moving = false end)
			end
			return false
		end
		if Cur_Power < 99 and not CheckBuff("player",rs["喝水"]) and Class ~= "WARRIOR" and Class ~= "ROGUE" then
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			if IsMounted() then
				Dismount()
			end
			Start_Restore = true
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
				local Mage_Drink = DrinkCount()
				if Mage_Drink and GetTime() - Eat_Time > 1.5 and select(5,GetItemInfo(Mage_Drink)) <= UnitLevel("player") then
				    Eat_Time = GetTime()
					awm.UseItemByName(Mage_Drink)
					textout(Check_UI("使用回蓝物品 = ","Drink = ")..Mage_Drink)
					return false
				end

			    for i = 1,#Drink_Full_List do
					local Food_Level = select(5,GetItemInfo(Drink_Full_List[i]))
					if Food_Level and GetItemCount(Drink_Full_List[i]) > 0 and UnitLevel("player") >= Food_Level and GetTime() - Eat_Time > 1.5 then
						Eat_Time = GetTime()
						awm.UseItemByName(Drink_Full_List[i])
						textout(Check_UI("使用回蓝物品 = ","Drink = ")..select(1,GetItemInfo(Drink_Full_List[i])))
						return false
					end
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(5,function() Stop_Moving = false end)
			end
			return false
		end
		if CheckBuff("player",rs["喝水"]) and (Cur_Health < 99 or (Cur_Power < 99 and Class ~= "WARRIOR" and Class ~= "ROGUE")) then
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			return false
		end
		if CheckBuff("player",rs["进食"]) and (Cur_Health < 99 or (Cur_Power < 99 and Class ~= "WARRIOR" and Class ~= "ROGUE")) then
			Note_Set(Check_UI("回血中...","Restore health..."))
			return false
		end
    end
	return true
end

function Buff_Check()
    local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100

	if (Cur_Power <= 20 and Class ~= "ROGUE" and Class ~= "WARRIOR") or (CheckBuff("player",rs["喝水"]) and Cur_Power < 100) or (CheckBuff("player",rs["进食"]) and Cur_Health < 100) then
	     NeedHeal()
		 return
	end

    if Class == "MAGE" and not awm.UnitAffectingCombat("player") and not IsMounted() then
		if not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and Easy_Data.Combat["法师冰甲术"] then
			if DoesSpellExist(rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) then
				awm.CastSpellByName(rs["冰甲术"],"player")
				return false
			end
			if DoesSpellExist(rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
				awm.TargetUnit("player")
				awm.CastSpellByName(rs["霜甲术"],"player")
				return false
			end
		end

		if DoesSpellExist(rs["法师魔甲术"]) and not CheckBuff("player",rs["法师魔甲术"]) and Easy_Data.Combat["法师魔甲术"] then
			awm.CastSpellByName(rs["法师魔甲术"],"player")
			return
		end	

		if DoesSpellExist(rs["熔岩护甲"]) and not CheckBuff("player",rs["熔岩护甲"]) and Easy_Data.Combat["法师熔岩护甲"] then
			awm.CastSpellByName(rs["熔岩护甲"],"player")
			return
		end	

		if DoesSpellExist(rs["奥术智慧"]) and not CheckBuff("player",rs["奥术智慧"]) then
			awm.CastSpellByName(rs["奥术智慧"],"player")
			return false
		end
		if not MakingDrinkOrEat() then
			return false
		end
	end
	if Class == "PRIEST" and not IsMounted() then
		if not CheckBuff("player",rs["暗影形态"]) and DoesSpellExist(rs["暗影形态"]) then
			awm.CastSpellByName(rs["暗影形态"],"player")
			return false
		end
		if DoesSpellExist(rs["真言术：韧"]) and (not CheckBuff("player",rs["真言术：韧"])) then
			awm.CastSpellByName(rs["真言术：韧"],"player")
			return false
		end
	end
	if Class == "WARLOCK" and not IsMounted() then
		if not CheckBuff("player",rs["邪甲术"]) and Spell_Castable(rs["邪甲术"]) and Easy_Data.Combat["术士邪甲术"] then
			awm.CastSpellByName(rs["邪甲术"],"player")
			return
		end

		if not CheckBuff("player",rs["恶魔皮肤"]) and Spell_Castable(rs["恶魔皮肤"]) and Easy_Data.Combat["术士恶魔皮肤"] then
			awm.CastSpellByName(rs["恶魔皮肤"],"player")
			return
		end

		if not CheckBuff("player",rs["术士魔甲术"]) and Spell_Castable(rs["术士魔甲术"]) and Easy_Data.Combat["术士魔甲术"] then
			awm.CastSpellByName(rs["术士魔甲术"],"player")
			return
		end

		if not PetHasActionBar() and GetItemCount(rs["灵魂碎片"]) > 0 and Spell_Castable(rs["召唤恶魔卫士"]) and Easy_Data.Combat["术士召唤恶魔卫士"] then
		    if not Interact_Step then
			    Interact_Step = true
				C_Timer.After(20,function() if Interact_Step then Interact_Step = false end end)
		        awm.CastSpellByName(rs["召唤恶魔卫士"])
			end
			Note_Set(rs["召唤恶魔卫士"])
			return false
		end

		if not PetHasActionBar() and GetItemCount(rs["灵魂碎片"]) > 0 and Spell_Castable(rs["召唤魅魔"]) and Easy_Data.Combat["术士召唤魅魔"] then
		    if not Interact_Step then
			    Interact_Step = true
				C_Timer.After(20,function() if Interact_Step then Interact_Step = false end end)
		        awm.CastSpellByName(rs["召唤魅魔"])
			end
			Note_Set(rs["召唤魅魔"])
			return false
		end

		if not PetHasActionBar() and GetItemCount(rs["灵魂碎片"]) > 0 and Spell_Castable(rs["召唤地狱猎犬"]) and Easy_Data.Combat["术士召唤地狱猎犬"] then
		    if not Interact_Step then
			    Interact_Step = true
				C_Timer.After(20,function() if Interact_Step then Interact_Step = false end end)
		        awm.CastSpellByName(rs["召唤地狱猎犬"])
			end
			Note_Set(rs["召唤地狱猎犬"])
			return false
		end

		if not PetHasActionBar() and GetItemCount(rs["灵魂碎片"]) > 0 and Spell_Castable(rs["召唤虚空行者"]) and Easy_Data.Combat["术士召唤虚空行者"] then
		    if not Interact_Step then
			    Interact_Step = true
				C_Timer.After(20,function() if Interact_Step then Interact_Step = false end end)
		        awm.CastSpellByName(rs["召唤虚空行者"])
			end
			Note_Set(rs["召唤虚空行者"])
			return false
		end

		if not PetHasActionBar() and Spell_Castable(rs["召唤小鬼"]) and Easy_Data.Combat["术士召唤小鬼"] then
			if not Interact_Step then
			    Interact_Step = true
				C_Timer.After(20,function() if Interact_Step then Interact_Step = false end end)
		        awm.CastSpellByName(rs["召唤小鬼"])
			end
			Note_Set(rs["召唤小鬼"])
			return false
		end
	end
	if Class == "HUNTER" and not IsMounted() then
	    if Easy_Data["需要召唤宠物"] then
			if not PetHasActionBar() and not IsMounted() then
				if not Pet_Dead and not Has_Call_Pet and Level > 11 then
					Note_Set(Check_UI("尝试召唤宠物...","Try to call pet"))
					Has_Call_Pet = true
					if DoesSpellExist(rs["召唤宠物"]) and not CastingBarFrame:IsVisible() then
						awm.CastSpellByName(rs["召唤宠物"])
					end
					C_Timer.After(5,function() Has_Call_Pet = false end)
					return false
				elseif Pet_Dead and Level > 11 then
					Note_Set(Check_UI("复活宠物中...","Try to revive pet"))
					if not Stop_Moving and GetUnitSpeed("player") > 0 then
						Stop_Moving = true
						Try_Stop()
						C_Timer.After(5,function() Stop_Moving = false end)
					end
					if DoesSpellExist(rs["复活宠物"]) and not CastingBarFrame:IsVisible() then
						awm.CastSpellByName(rs["复活宠物"])
					end
					return false
				end
			elseif awm.UnitIsDead("pet") and not IsMounted() and Level > 11 then
				Note_Set(Check_UI("宠物死亡, 复活宠物中...","Pet Dead... Try to revive pet"))
				if not Stop_Moving and GetUnitSpeed("player") > 0 then
					Stop_Moving = true
					Try_Stop()
					C_Timer.After(5,function() Stop_Moving = false end)
				end
				if DoesSpellExist(rs["复活宠物"]) and not CastingBarFrame:IsVisible() then
					awm.CastSpellByName(rs["复活宠物"])
				end
				return false
			elseif PetHasActionBar() and not awm.UnitIsDead("pet") and awm.UnitHealth("pet")/awm.UnitHealthMax("pet") < 0.5 and not IsMounted() and not awm.UnitAffectingCombat("player") then
				Note_Set(Check_UI("治疗宠物中...","Healing pet..."))
				if not Stop_Moving and GetUnitSpeed("player") > 0 then
					Stop_Moving = true
					Try_Stop()
					C_Timer.After(5,function() Stop_Moving = false end)
				end
				if DoesSpellExist(rs["治疗宠物"]) and not CastingBarFrame:IsVisible() and not CheckBuff("pet",rs["治疗宠物"]) then
					awm.CastSpellByName(rs["治疗宠物"],"pet")
					return false
				end
				return false
			end
			if PetHasActionBar() and not IsMounted() and not awm.UnitAffectingCombat("player") and not awm.UnitIsDead("pet") and Easy_Data["宠物食物"] and GetItemCount(Easy_Data["宠物食物"]) > 0 then
				local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
				if happiness < 3 then
					Note_Set(Check_UI("喂养宠物...","Feeding my pet..."))
					if not Has_Call_Pet then
						if not awm.SpellIsTargeting() then
							awm.RunMacroText("/stand")
							awm.CastSpellByName(rs["喂养宠物"])
						else
							awm.UseItemByName(Easy_Data["宠物食物"])
							Has_Call_Pet = true
							C_Timer.After(15,function() Has_Call_Pet = false end)
						end
					else
						if awm.SpellIsTargeting() then
							awm.SpellStopTargeting()
						end
					end
					return false
				end
			end
		end

		if PetHasActionBar() then
		    awm.PetPassiveMode()
		end

		if DoesSpellExist(rs["雄鹰守护"]) and not CheckBuff("player",rs["雄鹰守护"]) then
		     awm.TargetUnit("player")
			 awm.CastSpellByName(rs["雄鹰守护"])
			 return false
		end

		if DoesSpellExist(rs["强击光环"]) and not CheckBuff("player",rs["强击光环"]) then
		     awm.TargetUnit("player")
			 awm.CastSpellByName(rs["强击光环"])
			 return false
		end
	end

	if Class == "DRUID" and not IsMounted() then
		if not CheckBuff("player",rs["野性印记"]) and DoesSpellExist(rs["野性印记"]) then
			awm.CastSpellByName(rs["野性印记"],"player")
			return false
		end
		if not CheckBuff("player",rs["荆棘术"]) and DoesSpellExist(rs["荆棘术"]) then
			awm.CastSpellByName(rs["荆棘术"],"player")
			return false
		end
	end

	if Class == "ROGUE" and not IsMounted() then
	    local Poison = nil
		if GetItemCount(Check_Client("速效药膏","Instant Poison")) > 0 then
		    Poison = Check_Client("速效药膏","Instant Poison")
		end
		if GetItemCount(Check_Client("速效药膏 II","Instant Poison II")) > 0 then
		    Poison = Check_Client("速效药膏 II","Instant Poison II")
		end
		if GetItemCount(Check_Client("速效药膏 III","Instant Poison III")) > 0 then
		    Poison = Check_Client("速效药膏 III","Instant Poison III")
		end
		if GetItemCount(Check_Client("速效药膏 IV","Instant Poison IV")) > 0 then
		    Poison = Check_Client("速效药膏 IV","Instant Poison IV")
		end
		if GetItemCount(Check_Client("速效药膏 V","Instant Poison V")) > 0 then
		    Poison = Check_Client("速效药膏 V","Instant Poison V")
		end
		if GetItemCount(Check_Client("速效药膏 VI","Instant Poison VI")) > 0 then
		    Poison = Check_Client("速效药膏 VI","Instant Poison VI")
		end
		if GetItemCount(Check_Client("速效药膏 VII","Instant Poison VII")) > 0 then
		    Poison = Check_Client("速效药膏 VII","Instant Poison VII")
		end

		if Poison ~= nil and Easy_Data.Combat["盗贼毒药"] then
			local MainHand_Enchant,_,_,_,Offhand_Enchant = GetWeaponEnchantInfo()

			if not MainHand_Enchant then
			    Note_Set(Check_UI("上毒 - ","Posion - ").." - "..Poison)
			    if not awm.SpellIsTargeting() then
				    awm.UseItemByName(Poison)
					return
				end

			    if not Interact_Step and not CastingBarFrame:IsVisible() then
					Interact_Step = true
					C_Timer.After(5,function() if Interact_Step then Interact_Step = false end end)
					C_Timer.After(3,function() if awm.SpellIsTargeting() then awm.SpellStopTargeting() end end)
					awm.UseInventoryItem(16)
				end
				return
			elseif not Offhand_Enchant then
			    Note_Set(Check_UI("上毒 - ","Posion - ").." - "..Poison)
			    if not awm.SpellIsTargeting() then
				    awm.UseItemByName(Poison)
					return
				end

			    if not Interact_Step and not CastingBarFrame:IsVisible() then
					Interact_Step = true
					C_Timer.After(5,function() if Interact_Step then Interact_Step = false end end)
					C_Timer.After(3,function() if awm.SpellIsTargeting() then awm.SpellStopTargeting() end end)
					awm.UseInventoryItem(17)
				end
				return
			end
		end
	end

	if Class == "PALADIN" and not IsMounted() then
		if DoesSpellExist(rs["虔诚光环"]) and not CheckBuff("player",rs["虔诚光环"]) and Easy_Data.Combat["骑士虔诚光环"] then
			awm.CastSpellByName(rs["虔诚光环"],"player")
			return false
		end

		if DoesSpellExist(rs["冰霜抗性光环"]) and not CheckBuff("player",rs["冰霜抗性光环"]) and Easy_Data.Combat["骑士冰霜抗性光环"] then
			awm.CastSpellByName(rs["冰霜抗性光环"],"player")
			return false
		end

		if DoesSpellExist(rs["专注光环"]) and not CheckBuff("player",rs["专注光环"]) and Easy_Data.Combat["骑士专注光环"] then
			awm.CastSpellByName(rs["专注光环"],"player")
			return false
		end

		if DoesSpellExist(rs["暗影抗性光环"]) and not CheckBuff("player",rs["暗影抗性光环"]) and Easy_Data.Combat["骑士暗影抗性光环"] then
			awm.CastSpellByName(rs["暗影抗性光环"],"player")
			return false
		end

		if DoesSpellExist(rs["惩戒光环"]) and not CheckBuff("player",rs["惩戒光环"]) and Easy_Data.Combat["骑士惩戒光环"] then
			awm.CastSpellByName(rs["惩戒光环"],"player")
			return false
		end

		if DoesSpellExist(rs["火焰抗性光环"]) and not CheckBuff("player",rs["火焰抗性光环"]) and Easy_Data.Combat["骑士火焰抗性光环"] then
			awm.CastSpellByName(rs["火焰抗性光环"],"player")
			return false
		end
	end

	if Class == "SHAMAN" and not IsMounted() then
		local MainHand_Enchant,_,_,_,Offhand_Enchant = GetWeaponEnchantInfo()

		if not MainHand_Enchant and (Easy_Data.Combat["萨满石化武器"] or Easy_Data.Combat["萨满火舌武器"] or Easy_Data.Combat["萨满冰封武器"] or Easy_Data.Combat["萨满风怒武器"]) then
			Note_Set(Check_UI("武器增强 - ","Weapon Enhancement - "))
			if Spell_Castable(rs["石化武器"]) and Easy_Data.Combat["萨满石化武器"] then
			    awm.CastSpellByName(rs["石化武器"])
			end

			if Spell_Castable(rs["火舌武器"]) and Easy_Data.Combat["萨满火舌武器"] then
			    awm.CastSpellByName(rs["火舌武器"])
			end

			if Spell_Castable(rs["冰封武器"]) and Easy_Data.Combat["萨满冰封武器"] then
			    awm.CastSpellByName(rs["冰封武器"])
			end

			if Spell_Castable(rs["风怒武器"]) and Easy_Data.Combat["萨满风怒武器"] then
			    awm.CastSpellByName(rs["风怒武器"])
			end
			return
		end
	end
	return true
end
function CheckUse()
    if Class == "MAGE" then
		if GetItemCount(rs["法力红宝石"]) == 0 and DoesSpellExist(rs["制造魔法红宝石"]) then
		   if not CastingBarFrame:IsVisible() then
			   awm.CastSpellByName(rs["制造魔法红宝石"])
		   end
		   return false
		end
		if GetItemCount(rs["法力黄水晶"]) == 0 and DoesSpellExist(rs["制造魔法黄水晶"]) then
		   if not CastingBarFrame:IsVisible() then
			   awm.CastSpellByName(rs["制造魔法黄水晶"])
		   end
		   return false
		end
		if GetItemCount(rs["法力翡翠"]) == 0 and DoesSpellExist(rs["制造魔法翡翠"]) then
		   if not CastingBarFrame:IsVisible() then
			   awm.CastSpellByName(rs["制造魔法翡翠"])
		   end
		   return false
		end
		if GetItemCount(rs["法力玛瑙"]) == 0 and DoesSpellExist(rs["制造魔法玛瑙"]) then
		   if not CastingBarFrame:IsVisible() then
			   awm.CastSpellByName(rs["制造魔法玛瑙"])
		   end
		   return false
		end

		if GetItemCount(rs["法力刚玉"]) == 0 and DoesSpellExist(rs["制造魔法玉石"]) then
		   if not CastingBarFrame:IsVisible() then
			   awm.CastSpellByName(rs["制造魔法玉石"])
		   end
		   return false
		end
	end
	return true
end
function CheckProtection()
	if not CheckBuff("player",rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) and not IsMounted() then
		awm.CastSpellByName(rs["寒冰护体"],"player")
		return
	end
	if not CheckBuff("player",rs["法力护盾"]) and Spell_Castable(rs["法力护盾"]) and not IsMounted() then
		awm.CastSpellByName(rs["法力护盾"],"player")
		return
	end
	if not CheckBuff("player",rs["真言术：盾"]) and Spell_Castable(rs["真言术：盾"]) and not IsMounted() then
		awm.CastSpellByName(rs["真言术：盾"],"player")
		return
	end
	if not CheckBuff("player",rs["闪电之盾"]) and Spell_Castable(rs["闪电之盾"]) and not IsMounted() then
		awm.CastSpellByName(rs["闪电之盾"],"player")
		return
	end
end
function UseItem()
    if Class == "MAGE" then
	    if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力刚玉"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(22044) then
			awm.UseItemByName(rs["法力刚玉"])
		end

		if awm.UnitPower("player") < 2000 and GetItemCount(rs["法力红宝石"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(8008) then
			awm.UseItemByName(rs["法力红宝石"])
		end
		if awm.UnitPower("player") < 2000 and GetItemCount(rs["法力黄水晶"]) > 0 and not CastingBarFrame:IsVisible()  and CheckCooldown(8007) then
			awm.UseItemByName(rs["法力黄水晶"])
		end
		if awm.UnitPower("player") < 2000 and GetItemCount(rs["法力翡翠"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5513) then
			awm.UseItemByName(rs["法力翡翠"])
		end
		if awm.UnitPower("player") < 2000 and GetItemCount(rs["法力玛瑙"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5514) then
			awm.UseItemByName(rs["法力玛瑙"])
		end
	end

	local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100
	if Easy_Data["使用药水"] and Cur_Health < Easy_Data["回血药水百分比"] and not CastingBarFrame:IsVisible() then
	    local Use_Level = 0
		local Use_Potion = nil
	    for i = 1,#Health_Full_List do
		    if not CheckCooldown(Health_Full_List[i]) then
			    local Item_Level = select(5,GetItemInfo(Health_Full_List[i]))
				if Item_Level and Item_Level <= UnitLevel("player") and Item_Level > Use_Level then
					Use_Level = Item_Level
					Use_Potion = Health_Full_List[i]
				end
			end
		end

		if Use_Potion then
		    awm.UseItemByName(Use_Potion)
		end
	end

	if Easy_Data["使用药水"] and Cur_Power < Easy_Data["回蓝药水百分比"] and not CastingBarFrame:IsVisible() then
	    local Use_Level = 0
		local Use_Potion = nil
	    for i = 1,#Mana_Full_List do
		    if CheckCooldown(Mana_Full_List[i]) then
			    local Item_Level = select(5,GetItemInfo(Mana_Full_List[i]))
				if Item_Level and Item_Level <= UnitLevel("player") and Item_Level > Use_Level then
					Use_Level = Item_Level
					Use_Potion = Mana_Full_List[i]
				end
			end
		end

		if Use_Potion then
		    awm.UseItemByName(Use_Potion)
		end
	end
end

function Check_BagFree() --背包空格和耐久
    if Easy_Data["需要修理"] and not Sell.Lack_Money then
		for i = 1,18 do
		    local current,max = GetInventoryItemDurability(i)
			if current ~= nil and max ~= nil then
			    local durability = current/max
				if not tonumber(Easy_Data["修理耐久度"]) then
				    Easy_Data["修理耐久度"] = 0.1
				end

			    if durability <= tonumber(Easy_Data["修理耐久度"]) then
				    if Sell.Step == 1 then
					   Sell.Step = 2
				    end
				    return false
				end
			end
			if GetInventoryItemBroken("player",i) then
			   if Sell.Step == 1 then
				   Sell.Step = 2
			   end
			   return false
			end
		end
	elseif Sell.Lack_Money then
	    if GetMoney() >= Sell.Repair_Money then
		    Sell.Lack_Money = false
		end
	end
	if Easy_Data["需要卖物"] then
		if CalculateTotalNumberOfFreeBagSlots() <= Easy_Data["卖物格数"] then
			if Sell.Step == 1 then
				Sell.Step = 2
			end
			return false 
		end
	end
	return true 
end	
function Sell_JunkRun(x,y,z)
    local Px,Py,Pz = awm.ObjectPosition("player")
	local SellDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if SellDistance > 2 then 
	    Note_Set(Check_UI(Merchant_Name.." ,坐标 = "..x..","..y..","..z, Merchant_Name..", Coord = "..x..","..y..","..z))
		Run(x,y,z)
		Sell.Interact_Step = false
	elseif SellDistance <= 2 then
	    Note_Set(Check_UI("卖物步骤 = ","Vendor Step = ")..Sell.Step)
		if type(Merchant_Name) == "string" then
		    awm.TargetUnit(Merchant_Name)
		elseif type(Merchant_Name) == "number" then
		    local total = awm.GetObjectCount()
			local Far_Distance = 100
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local id = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) 
				    and not awm.UnitIsDead(ThisUnit) 
					and not awm.UnitAffectingCombat(ThisUnit) 
					and id == Merchant_Name 
					and distance < Far_Distance then
					    awm.TargetUnit(ThisUnit)
				end
			end		    
		end

		if MerchantFrame:IsVisible() then
		    if GetRepairAllCost() > GetMoney() and not Sell.Lack_Money then
			    Sell.Lack_Money = true
				Sell.Repair_Money = GetRepairAllCost()
			end
			if not Sell.Interact_Step then
				Sell.Interact_Step = true
				C_Timer.After(0.1, function()
				    if Sell.Interact_Step then
						Sell.Interact_Step = false
					end
				end)
				if MerchantFrame:IsVisible() then
					Auto_Sell()
				end
			end
			if Sell.Step == 2 then
				Sell.Step = 3
				RepairAllItems()
				local random_Time = math.random(10,15) + math.random()
				C_Timer.After(random_Time, function() Sell.Step = 4 end)
			end
			if Sell.Step == 4 then
				Sell.Step = 5
				RepairAllItems()
				local random_Time = math.random(15,20) + math.random()
				C_Timer.After(random_Time, function() Sell.Step = 6 end)
			end
			if Sell.Step == 6 then
				Sell.Step = 1
				CloseMerchant()
				awm.ClearTarget()
				textout(Check_UI("卖物完毕","Vendor process done"))
			end
			return
		elseif Gossip_Show then
			if not Sell.Interact_Step then
				Sell.Interact_Step = true
				local title1,gossip1,title2,gossip2,title3,gossip3,title4,gossip4,title5,gossip5 = GetGossipOptions()
				if gossip1 == "vendor" then
					SelectGossipOption(1)
				elseif gossip2 == "vendor" then
					SelectGossipOption(2)
				elseif gossip3 == "vendor" then
					SelectGossipOption(3)
				elseif gossip4 == "vendor" then
					SelectGossipOption(4)
				elseif gossip5 == "vendor" then
					SelectGossipOption(5)
				end
				C_Timer.After(1, function() Sell.Interact_Step = false end)
			end
		else
		    if awm.GetDistanceBetweenObjects("player","target") <= 4.5 then
				if not Sell.Interact_Step then
					Sell.Interact_Step = true
					C_Timer.After(1, function() 
						if Sell.Interact_Step then
							Sell.Interact_Step = false
						end
						awm.InteractUnit("target")
					end)
				end
			end
			return					
		end
	end
end

function ValidItem(item) -- 不售卖的装备列表
	local ItemList = string.split(Easy_Data["保留物品"],",")


    local Item_Id = tonumber(select(2,GetItemInfo(item)):match("item:(%d+):"))

	local Food_Count = 0
	for i = 1,#Food_Full_List do
	    Food_Count = Food_Count + GetItemCount(Food_Full_List[i])
	end
	for i = 1,#Food_Full_List do
	    if Item_Id and Item_Id == Food_Full_List[i] and Food_Count <= (Easy_Data["食物保留数量"] * 3) then
		    return true
		end
	end

	local Drink_Count = 0
	for i = 1,#Drink_Full_List do
	    Drink_Count = Drink_Count + GetItemCount(Drink_Full_List[i])
	end
	for i = 1,#Drink_Full_List do
	    if Item_Id and Item_Id == Drink_Full_List[i] and Drink_Count <= (Easy_Data["饮料保留数量"] * 3) then
		    return true
		end
	end

	local Health_Potion_Count = 0
	for i = 1,#Health_Full_List do
	    Health_Potion_Count = Health_Potion_Count + GetItemCount(Health_Full_List[i])
	end
	for i = 1,#Health_Full_List do
	    if Item_Id and Item_Id == Health_Full_List[i] and Health_Potion_Count <= Easy_Data["回血药水保留数量"] then
		    return true
		end
	end

	local Mana_Potion_Count = 0
	for i = 1,#Mana_Full_List do
	    Mana_Potion_Count = Mana_Potion_Count + GetItemCount(Mana_Full_List[i])
	end
	for i = 1,#Mana_Full_List do
	    if Item_Id and Item_Id == Mana_Full_List[i] and Mana_Potion_Count <= Easy_Data["回蓝药水保留数量"] then
		    return true
		end
	end

	if Class == "ROGUE" then
		if string.find(item,Check_Client("速效药膏","Instant Poison")) or (Item_Id and Item_Id == 8925) or (Item_Id and Item_Id == 8924) then
			return true
		end

		if item == rs["闪光粉"] then
			return true
		end
	end

	if Class == "HUNTER" 
	    and (item == Check_Client("锯齿箭","Jagged Arrow") 
		or item == Check_Client("锐锋箭","Razor Arrow") 
		or item == Check_Client("锋利的箭","Sharp Arrow") 
		or item == Check_Client("劣质箭","Rough Arrow") 
		or item == Check_Client("精准弹丸","Accurate Slugs") 
		or item == Check_Client("实心子弹","Solid Shot") 
		or item == Check_Client("重弹丸","Heavy Shot") 
		or item == Check_Client("轻弹丸","Light Shot")) then
	        return true
	end
	if Class == "HUNTER" and item == Easy_Data["宠物食物"] then
	    return true
	end

	if item == rs["空气图腾"] or item == rs["水之图腾"] or item == rs["火焰图腾"] or item == rs["大地图腾"] then
	    return true
	end

	if item == Check_Client("矿工锄","Mining Pick") or item == Check_Client("剥皮小刀","Skinning Knife") or item == Check_Client("潜行者工具","Thieves' Tools") or item == Check_Client("气阀微粒提取器","Zapthrottle Mote Extractor") then
	    return true
	end

    if #ItemList > 0 then
		for i = 0, #ItemList, 1 do
			if item and item ~= "" and ItemList[i] and ItemList[i] ~= "" then
				if ItemList[i] == item then
					return true
				elseif Easy_Data["模糊字售卖"] and (string.find(item, ItemList[i]) or string.find(ItemList[i], item)) then
				    return true
				end
			end
		end
	elseif #ItemList == 0 then
	    if item == Easy_Data["保留物品"] then
		    return true
		end
	end
    return false
end
function Valid_Quality(q) -- 装备品质比较
    if q == 0 and Easy_Data["灰色"] then
	    return true
	elseif q == 1 and Easy_Data["白色"] then
	    return true
	elseif q == 2 and Easy_Data["绿色"] then
	    return true
	elseif q == 3 and Easy_Data["蓝色"] then
	    return true
	elseif q == 4 and Easy_Data["紫色"] then
	    return true
	end
	return false
end
function Auto_Sell() -- 自动卖装备
	if Sell.Timer then
	    local time = GetTime() - Sell.Time
	    if time > 0.05 then
		   Sell.Timer = false
		end
		return
	end
	if Sell.Bag >= 5 then
		Sell.Bag = 0
		return
	end
	if GetBagName(Sell.Bag) == nil then
		Sell.Bag = Sell.Bag + 1
		Sell.Slot = 1
		return
	end
	if Sell.Slot > GetContainerNumSlots(Sell.Bag) then
	    Sell.Slot = 1
		Sell.Bag = Sell.Bag + 1
		Sell.Timer = false
		if GetBagName(Sell.Bag) == nil then
		    Sell.Bag = Sell.Bag + 1
			Sell.Slot = 1
			return
		end
		if Sell.Bag >= 5 then
			Sell.Bag = 0
		end
		textout(Check_UI("尝试出售第"..Sell.Bag.."包中的全部物品","Sell The"..Sell.Bag.." Bag's Items"))
		return
	else
	    local link = GetContainerItemLink(Sell.Bag, Sell.Slot)
		if link == nil then
		    Sell.Slot = Sell.Slot + 1
			return
		else
		    local item = select(1, GetItemInfo(link))
			local quality = select(3, GetItemInfo(link))
			if item == nil then
				return
			end
			if ValidItem(item) then
			    Sell.Slot = Sell.Slot + 1
				return
			end
			if MerchantFrame:IsVisible() and Valid_Quality(quality) then
				textout(Check_UI("第"..Sell.Bag.."包, 第"..Sell.Slot.."格, 出售 - "..item,"The"..Sell.Bag.."Bag, The"..Sell.Slot.."Slot, Sold - "..item))
				if not Sell.Timer then
					Sell.Time = GetTime()
					Sell.Timer = true
				end
				awm.UseContainerItem(Sell.Bag, Sell.Slot)
				Sell.Item_Name = item
				Sell.Slot = Sell.Slot + 1
				return
			elseif not Valid_Quality(quality) then
				Sell.Slot = Sell.Slot + 1
				return
			end
		end
	end
end

function Valid_Destroy(item) -- 自动摧毁
	local DestroyList = string.split(Easy_Data["摧毁物品"],",")

	local Food_Count = EatCount()
	local Drink_Count = DrinkCount()

	if item == Food_Count and GetItemCount(Food_Count) >= 40 then
	    return true
	end

	if item == Drink_Count and GetItemCount(Drink_Count) >= 40 then
	    return true
	end


    if #DestroyList > 0 then
		for i = 0, #DestroyList, 1 do
			if DestroyList[i] == item then
				return true
			end
		end
	elseif #DestroyList == 0 then
	    if item == Easy_Data["摧毁物品"] then
		    return true
		end
	end
    return false
end
function Valid_Destroy_Quality(q) -- 装备品质比较
    if q == 0 and Easy_Data["摧毁灰色"] then
	    return true
	elseif q == 1 and Easy_Data["摧毁白色"] then
	    return true
	elseif q == 2 and Easy_Data["摧毁绿色"] then
	    return true
	elseif q == 3 and Easy_Data["摧毁蓝色"] then
	    return true
	elseif q == 4 and Easy_Data["摧毁紫色"] then
	    return true
	end
	return false
end
function Auto_Destroy() -- 自动摧毁
    local bag = 0
    local slot = 0
    for bag = 0, 4 do
	    local FreeSlot = GetContainerFreeSlots(bag)
        for slot = 1, GetContainerNumSlots(bag) do
		    local pass = false
		    if #FreeSlot > 0 then
                for i = 0, #FreeSlot, 1 do
                    if slot == FreeSlot[i] then
						pass =true
					end
				end
			end
			if not pass then
			    local link = GetContainerItemLink(bag, slot)
                local item = select(1, GetItemInfo(link))
				local quality = select(3, GetItemInfo(link))
				local type = select(12, GetItemInfo(link))
				if item and not ValidItem(item) then -- 去除保留物品
					if (item and Valid_Destroy(item)) or (item and Valid_Destroy_Quality(quality)) then
					    textout(Check_UI("摧毁 = "..item,"Destroy = "..item))
						awm.PickupContainerItem(bag, slot)
						awm.DeleteCursorItem()
					end
				end
			end
        end
    end
end

function ValidMail(item)
    local MailList = string.split(Easy_Data["邮寄物品"],",")
	local Black_MailList = string.split(Easy_Data["邮寄过滤物品"],",")

	if #Black_MailList > 0 then
		for i = 0, #Black_MailList, 1 do
			if item and item ~= "" and Black_MailList[i] and Black_MailList[i] ~= "" then
				if Black_MailList[i] == item then
					return false
				end
			end
		end
	elseif #Black_MailList == 0 then
	    if item == Easy_Data["邮寄过滤物品"] then
		    return false
		end
	end

    if #MailList > 0 then
		for i = 0, #MailList, 1 do
			if item and item ~= "" and MailList[i] and MailList[i] ~= "" then
				if MailList[i] == item then
					return true
				elseif Easy_Data["模糊字邮寄"] and (string.find(item, MailList[i]) or string.find(MailList[i], item)) then
				    return true
				end
			end
		end
	elseif #MailList == 0 then
	    if item == Easy_Data["邮寄物品"] then
		    return true
		end
	end

	return false
end
function Mail(x,y,z)
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Mail_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if Mail_Distance >= 3 then
	    Note_Set(Check_UI("距离剩余 - "..math.floor(Mail_Distance),"Distance Left - "..math.floor(Mail_Distance)))
		Run(x,y,z)
		Mail_Info.Interact_Step = false
	else
	    if GetUnitSpeed("player") > 0 then
		    Try_Stop()
			return
		end
	    if not MailFrame:IsVisible() then
		    Note_Set(Check_UI("打开邮箱...","Open Mailbox..."))
			Mail_Box = Mail_Object()
			if not Mail_Info.Interact_Step and Mail_Box[1] ~= nil then
			    awm.InteractUnit(Mail_Box[1])
				Mail_Info.Interact_Step = true
				C_Timer.After(1, function()
				    if Mail_Info.Interact_Step then 
				        Mail_Info.Interact_Step = false
					end
				end)
			end
			return
		else
		    if not Mail_Info.Timer then
			    Mail_Info.Time = GetTime()
				Mail_Info.Timer = true
			end
			if Mail_Info.Timer then
			    local time = GetTime() - Mail_Info.Time
				if time >= 25 then
				     Mail_Info.Timer = false
					 CloseMail()
					 return
				end
			end
		    if not SendMailFrame:IsVisible() then
			    MailFrameTab2:Click()
			else
				Note_Set(Check_UI("邮寄物品...","Mailing items..."))
				if not Mail_Info.Interact_Step then
					Mail_Info.Interact_Step = true
					C_Timer.After(1, function()
						if Mail_Info.Interact_Step then 
							Mail_Info.Interact_Step = false
						end
					end)
				else
				    return
				end
				-- 邮寄金币
				local gold = math.floor(GetMoney()/10000)
				local silver = math.floor((GetMoney()/10000 - gold) * 100)
				local copper = math.floor((GetMoney()/10000 - gold - (silver/100)) * 10000)
				local Mail_gold = gold - Easy_Data["保留金币"]
				if Mail_gold > 0 and Easy_Data["邮寄金币"] then
				    SendMailMoneyGold:SetText(Mail_gold)
					SendMailMoneySilver:SetText(silver)
					SendMailMoneyCopper:SetText(copper)
					SendMailSendMoneyButton:Click()
					SendMailNameEditBox:SetText(Easy_Data["邮寄角色"])
					SendMailSubjectEditBox:SetText(Easy_Data["邮寄角色"])
					SendMailMailButton:Click()
					return
				end

				local bag = 0
				local slot = 0

				for bag = 0, 4 do
					local FreeSlot = GetContainerFreeSlots(bag)
					for slot = 1, GetContainerNumSlots(bag) do
					    if GetSendMailItem(12) ~= nil and SendMailFrame:IsVisible() and SendMailFrame:IsVisible() then
							SendMailSendMoneyButton:Click()
							SendMailNameEditBox:SetText(Easy_Data["邮寄角色"])
							SendMailMailButton:Click()
							return
						end

						local pass = false
						if #FreeSlot > 0 then
							for i = 0, #FreeSlot, 1 do
								if slot == FreeSlot[i] then
									pass =true
								end
							end
						end
						if not pass then
							local link = GetContainerItemLink(bag, slot)
							local item = select(1, GetItemInfo(link))
							if item and ValidMail(item) then
							    if SendMailFrame:IsVisible() then
									awm.UseContainerItem(bag, slot)
								end
							end
						end
					end
				end

				if GetSendMailItem(1) ~= nil then
				    SendMailSendMoneyButton:Click()
					SendMailNameEditBox:SetText(Easy_Data["邮寄角色"])
					SendMailMailButton:Click()
					return
				elseif SendMailFrame:IsVisible() and SendMailFrame:IsVisible() and GetSendMailItem(1) == nil then
				    Has_Mail = true
					textout(Check_UI("邮寄完毕","Mail logic end"))
					return
				end
			end
		end
	end
end
function Mail_Object() 
	local Mail_Box = {}
	local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.UnitFullName(ThisUnit)
		local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		if awm.ObjectIsGameObject(ThisUnit) and distance < 40 then
			if guid == "邮箱" or guid == "Mailbox" then
				Mail_Box[#Mail_Box + 1] = ThisUnit
			end
		end
	end
	return Mail_Box
end

function Hunter_Ammo_Type() -- 子弹或者箭矢
    local Range_Weapon = GetInventoryItemLink("player",GetInventorySlotInfo("RANGEDSLOT"))
	local Weapon_Class = select(13,GetItemInfo(Range_Weapon))
	local Ammo_type = ""
	if Weapon_Class == nil then
	    return nil
	elseif Weapon_Class == 18 or Weapon_Class == 2 then
		Ammo_type = "Array"
		return Ammo_type
	elseif Weapon_Class == 3 then
		Ammo_type = "Bullet"
		return Ammo_type
	else 
	    return nil
	end
end
function Hunter_Ammo_Name() -- 要买的自动箭矢名字
    local Ammo_Current = GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT"))
    local Ammo_Count = 0
	local Ammo_type = Hunter_Ammo_Type()

	local Ammo_Level = 0
	local Ammo_Name = nil
	local Ammo_Money = 0

	for i = 1,GetMerchantNumItems() do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if Ammo_type == nil then
			return nil
		elseif Ammo_type == "Array" then
		    for arr = 1,#Arrow_Full_List do
			    local Item_Level = select(5,GetItemInfo(Arrow_Full_List[arr]))
				local Item_Name = select(1,GetItemInfo(Arrow_Full_List[arr]))
				if Item_Level and Item_Name == id and Level >= Item_Level and Ammo_Level < Item_Level then
				    Ammo_Level = Item_Level
					Ammo_Name = Item_Name
					Ammo_Money = money
				end
			end
		elseif Ammo_type == "Bullet" then
		    for arr = 1,#Bullet_Full_List do
			    local Item_Level = select(5,GetItemInfo(Bullet_Full_List[arr]))
				local Item_Name = select(1,GetItemInfo(Bullet_Full_List[arr]))
				if Item_Level and Item_Name == id and Level >= Item_Level and Ammo_Level < Item_Level then
				    Ammo_Level = Item_Level
					Ammo_Name = Item_Name
					Ammo_Money = money
				end
			end
		end
	end

	if Ammo_Money > GetMoney() then
	    if Ammo_type == "Array" then
		    return select(1,GetItemInfo(2512))
		elseif Ammo_type == "Bullet" then
		    return select(1,GetItemInfo(2516))
		end
	end

	return Ammo_Name
end
function Hunter_Ammo_Count() -- 弹药统计
    local Ammo_Current = GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT"))
    local Ammo_Count = 0
	local Range_Weapon = GetInventoryItemLink("player",GetInventorySlotInfo("RANGEDSLOT"))
	local Weapon_Class = select(13,GetItemInfo(Range_Weapon))
	local Ammo_type = Hunter_Ammo_Type()
	if Ammo_type == nil then
	    return nil
	elseif Ammo_type == "Array" then
		for arr = 1,#Arrow_Full_List do
			local Item_Level = select(5,GetItemInfo(Arrow_Full_List[arr]))
			local Item_Name = select(1,GetItemInfo(Arrow_Full_List[arr]))
			if Item_Level and Level >= Item_Level then
				Ammo_Count = Ammo_Count + GetItemCount(Item_Name)
				if GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT")) <= 2 and GetItemCount(Item_Name) > 0 then
				    EquipItemByName(Item_Name)
				end
			end
		end
	elseif Ammo_type == "Bullet" then
		for arr = 1,#Bullet_Full_List do
			local Item_Level = select(5,GetItemInfo(Bullet_Full_List[arr]))
			local Item_Name = select(1,GetItemInfo(Bullet_Full_List[arr]))
			if Item_Level and Level >= Item_Level then
				Ammo_Count = Ammo_Count + GetItemCount(Item_Name)
				if GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT")) <= 2 and GetItemCount(Item_Name) > 0 then
				    EquipItemByName(Item_Name)
				end
			end
		end
	end
	return Ammo_Count
end
function BuyBullets()
    local Num = GetMerchantNumItems()
	local Ammo = Hunter_Ammo_Name()
	if Ammo == nil then
	    Auto_Purchase.Hunter_Ammo = false
		return
	end
	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == Ammo then
		    if GetMoney() >= money then
				BuyMerchantItem(i,200)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 200只","Buy Bullets At Store Slot "..i.." For 200"))
			else
			    Auto_Purchase.Hunter_Ammo = false
				Auto_Purchase.Lack_Money = true
			    textout(Check_UI("没有足够钱财购买子弹","Not enough money to buy bullets"))
				return
			end
		end
	end
end
function BulletRun(x,y,z)
	local Name = Ammo_Vendor_Name
    local Px,Py,Pz = awm.ObjectPosition("player")
	local SellDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if SellDistance > 4 then 
	    Note_Set(Check_UI("前往卖物购买子弹 枪械商 = "..Name,"Go buy bullets, Vendor name - "..Name))
		Run(x,y,z)
		Interact_Step = false
	elseif SellDistance <= 4 then
	    Note_Set(Check_UI("正在购买子弹","Bullets buying"))
		if type(Name) == "string" then
		    awm.TargetUnit(Name)
		elseif type(Name) == "number" then
		    local total = awm.GetObjectCount()
			local Far_Distance = 100
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local id = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) 
				    and not awm.UnitIsDead(ThisUnit) 
					and not awm.UnitAffectingCombat(ThisUnit) 
					and id == Name 
					and distance < Far_Distance then
					    awm.TargetUnit(ThisUnit)
				end
			end		    
		end
		if Merchant_Show and MerchantFrame:IsVisible() then
			RepairAllItems()
			Auto_Sell()
			if Hunter_Ammo_Count() < Easy_Data["子弹最大数量"] and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(2,function() Interact_Step = false end)
				BuyBullets()
			elseif Hunter_Ammo_Count() >= Easy_Data["子弹最大数量"] then
			    CloseMerchant()
				awm.ClearTarget()
				Auto_Purchase.Hunter_Ammo = false
				textout(Check_UI("买完子弹了, 又要重新开始工作了","Process of bullets buy done!"))
			end
			return
		elseif Gossip_Show then
			if not Interact_Step then
				Interact_Step = true
				local title1,gossip1,title2,gossip2,title3,gossip3,title4,gossip4,title5,gossip5 = GetGossipOptions()
				if gossip1 == "vendor" then
					SelectGossipOption(1)
				elseif gossip2 == "vendor" then
					SelectGossipOption(2)
				elseif gossip3 == "vendor" then
					SelectGossipOption(3)
				elseif gossip4 == "vendor" then
					SelectGossipOption(4)
				elseif gossip5 == "vendor" then
					SelectGossipOption(5)
				end
				C_Timer.After(1, function() Interact_Step = false end)
			end
		else
		    if awm.GetDistanceBetweenObjects("player","target") > 4.5 then
			    return
			end
		    if not Interact_Step then
				Interact_Step = true
				C_Timer.After(1, function() Interact_Step = false awm.InteractUnit("target") end)
			end
			return	
		end
	end
end

function Buy_Food_Drinks(Table)
    local Num = GetMerchantNumItems()

	local Food_Level = 0
	local Food_Name = nil

	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		for arr = 1,#Table do
		    local Item_Level = select(5,GetItemInfo(Table[arr]))
			local Item_Name = select(1,GetItemInfo(Table[arr]))
			if Item_Level and Item_Name and Item_Level and Item_Level <= Level and Item_Name == id and Food_Level < Item_Level then
			    Food_Level = Item_Level
				Food_Name = Item_Name
				print(Food_Name)
			end
		end
	end

	if Food_Name == nil then
	    Auto_Purchase.Lack_Money = true
		Auto_Purchase.Food = false
		return
	end

	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == Food_Name then
		    if GetMoney() >= money * 5 then
				BuyMerchantItem(i,5)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 5个","Buy Foods At Store Slot "..i.." For 5"))
			else
			    Auto_Purchase.Lack_Money = true
			    textout(Check_UI("没有足够钱财购买食物和饮料","Not enough money to buy Drink and Food"))
				return
			end
		end
	end
end
function Food_Drink_Run(x,y,z)
	local Name = Food_Vendor_Name
    local Px,Py,Pz = awm.ObjectPosition("player")
	local SellDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if SellDistance > 2 then 
	    Note_Set(Check_UI("购买食物和饮料 = "..Name,"Go buy Food and Drink, Vendor name - "..Name))
		Run(x,y,z)
		Interact_Step = false
	elseif SellDistance <= 2 then
	    Note_Set(Check_UI("正在购买食物和饮料","Foods and Drinks buying"))
		if type(Name) == "string" then
		    awm.TargetUnit(Name)
		elseif type(Name) == "number" then
		    local total = awm.GetObjectCount()
			local Far_Distance = 100
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local id = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) 
				    and not awm.UnitIsDead(ThisUnit) 
					and not awm.UnitAffectingCombat(ThisUnit) 
					and id == Name 
					and distance < Far_Distance then
					    awm.TargetUnit(ThisUnit)
				end
			end		    
		end
		if Merchant_Show and MerchantFrame:IsVisible() then
			RepairAllItems()
			Auto_Sell()
			local Food_Count = 0
			for i = 1,#Food_Full_List do
				Food_Count = Food_Count + GetItemCount(Food_Full_List[i])
			end
			
			local Drink_Count = 0
			for i = 1,#Drink_Full_List do
				Drink_Count = Drink_Count + GetItemCount(Drink_Full_List[i])
			end
			if (Food_Count < Easy_Data["食物保留数量"] or (Drink_Count < Easy_Data["饮料保留数量"]) and Class ~= "ROGUE" and Class ~= "WARRIOR") and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(2,function() Interact_Step = false end)
				if Food_Count < Easy_Data["食物保留数量"] then
					Buy_Food_Drinks(Food_Full_List)
				elseif Drink_Count < Easy_Data["饮料保留数量"] and Class ~= "ROGUE" and Class ~= "WARRIOR" then
				    Buy_Food_Drinks(Drink_Full_List)
				end
			elseif Food_Count >= Easy_Data["食物保留数量"] and (Drink_Count >= Easy_Data["饮料保留数量"] or Class == "ROGUE" or Class == "WARRIOR") then
			    CloseMerchant()
				awm.ClearTarget()
				textout(Check_UI("我买完了哦, 又要重新开始工作了","Process of Food buy done!"))
			end
			return
		elseif Gossip_Show then
			if not Interact_Step then
				Interact_Step = true
				local title1,gossip1,title2,gossip2,title3,gossip3,title4,gossip4,title5,gossip5 = GetGossipOptions()
				if gossip1 == "vendor" then
					SelectGossipOption(1)
				elseif gossip2 == "vendor" then
					SelectGossipOption(2)
				elseif gossip3 == "vendor" then
					SelectGossipOption(3)
				elseif gossip4 == "vendor" then
					SelectGossipOption(4)
				elseif gossip5 == "vendor" then
					SelectGossipOption(5)
				end
				C_Timer.After(1, function() Interact_Step = false end)
			end
		else
		    if awm.GetDistanceBetweenObjects("player","target") > 4.5 then
			    return
			end
		    if not Interact_Step then
				Interact_Step = true
				C_Timer.After(1, function() Interact_Step = false awm.InteractUnit("target") end)
			end
			return	
		end
	end
end

function Buy_Pet_Food(name)
    local Num = GetMerchantNumItems()
	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == name then
		    if GetMoney() >= money * 5 then
				BuyMerchantItem(i,5)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 5个","Buy Pet Food At Store Slot "..i.." For 5"))
			else
			    Has_Bought_Food_Drink = true
			    textout(Check_UI("没有足够钱财购买宠物食物","Not enough money to buy Pet Food"))
				return
			end
		end
	end
end
function Pet_Food_Run(x,y,z)
	local Name = Pet_Food_Vendor_Name
    local Px,Py,Pz = awm.ObjectPosition("player")
	local SellDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if SellDistance > 2 then 
	    Note_Set(Check_UI("购买宠物食物 = "..Name,"Go buy Pet Food, Vendor name - "..Name))
		Run(x,y,z)
		Interact_Step = false
	elseif SellDistance <= 2 then
	    Note_Set(Check_UI("正在购买宠物食物","Pet Food buying"))
		if type(Name) == "string" then
		    awm.TargetUnit(Name)
		elseif type(Name) == "number" then
		    local total = awm.GetObjectCount()
			local Far_Distance = 100
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local id = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) 
				    and not awm.UnitIsDead(ThisUnit) 
					and not awm.UnitAffectingCombat(ThisUnit) 
					and id == Name 
					and distance < Far_Distance then
					    awm.TargetUnit(ThisUnit)
				end
			end		    
		end
		if Merchant_Show and MerchantFrame:IsVisible() then
			RepairAllItems()
			Auto_Sell()
			local Food_Count = GetItemCount(Easy_Data["宠物食物"])
			if Food_Count < Easy_Data["宠物食物数量"] and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(2,function() Interact_Step = false end)
				if Food_Count < Easy_Data["宠物食物数量"] then
					Buy_Pet_Food(Easy_Data["宠物食物"])
				end
			elseif Food_Count >= Easy_Data["宠物食物数量"] then
			    CloseMerchant()
				awm.ClearTarget()
				textout(Check_UI("我买完了哦, 又要重新开始工作了","Process of bullets buy done!"))
			end
			return
		elseif Gossip_Show then
			if not Interact_Step then
				Interact_Step = true
				local title1,gossip1,title2,gossip2,title3,gossip3,title4,gossip4,title5,gossip5 = GetGossipOptions()
				if gossip1 == "vendor" then
					SelectGossipOption(1)
				elseif gossip2 == "vendor" then
					SelectGossipOption(2)
				elseif gossip3 == "vendor" then
					SelectGossipOption(3)
				elseif gossip4 == "vendor" then
					SelectGossipOption(4)
				elseif gossip5 == "vendor" then
					SelectGossipOption(5)
				end
				C_Timer.After(1, function() Interact_Step = false end)
			end
		else
		    if awm.GetDistanceBetweenObjects("player","target") > 4.5 then
			    return
			end
		    if not Interact_Step then
				Interact_Step = true
				C_Timer.After(1, function() Interact_Step = false awm.InteractUnit("target") end)
			end
			return	
		end
	end
end


function Combat_Scan()
    local Monster = {}
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.ObjectId(ThisUnit)
		local target = awm.UnitTarget(ThisUnit)
		if awm.UnitAffectingCombat(ThisUnit) and target and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and (target == UnitGUID("player") or target == UnitGUID("pet")) then
		    Monster[#Monster + 1] = ThisUnit
		end
	end
	return Monster
end

function CombatSystem(target)
    awm.Print_Spell = true

    local Px,Py,Pz = awm.ObjectPosition("player")
    local Combat_Monster = {}
	local Target_On_Me = {}
    local total = awm.GetObjectCount()
	local Is_Dungeon = IsInInstance()
	local Player_GUID = awm.UnitGUID("player")
	local Pet_GUID = awm.UnitGUID("Pet")

	local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100

	local Special_Buff = false -- 术士恐惧 

	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.ObjectId(ThisUnit)
		local U_target = awm.UnitTarget(ThisUnit)
		if awm.UnitAffectingCombat(ThisUnit) and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and (Is_Dungeon or (U_target and U_target == Player_GUID) or (PetHasActionBar() and U_target and U_target == Pet_GUID)) then
		    Combat_Monster[#Combat_Monster + 1] = {}
			Combat_Monster[#Combat_Monster].Unit = ThisUnit
			Combat_Monster[#Combat_Monster].Distance = awm.GetDistanceBetweenObjects("player",ThisUnit)

			if U_target == Player_GUID then
			    Target_On_Me[#Target_On_Me + 1] = ThisUnit
			end

			if U_target and U_target == Player_GUID and Class == "PRIEST" and Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "healer" and Is_Dungeon and (UnitInParty("player") or IsInRaid("player")) then
			    if Spell_Castable(rs["真言术：盾"]) and not CheckBuff("player",rs["真言术：盾"]) then
					awm.CastSpellByName(rs["真言术：盾"],"player")
				end

			    if Combat_Monster[#Combat_Monster].Distance < 6 and Cur_Health <= 30 and Spell_Castable(rs["心灵尖啸"]) then
				    awm.CastSpellByName(rs["心灵尖啸"])
				end

				if not CheckBuff("player",rs["渐隐术"]) and Spell_Castable(rs["渐隐术"]) then
				    awm.CastSpellByName(rs["渐隐术"])
				end
			end

			if awm.UnitCastingInfo(ThisUnit) then -- 怪物正在放技能
			    if Class == "ROGUE" then
				    if Spell_Castable(rs["脚踢"]) and Combat_Monster[#Combat_Monster].Distance < 5 then
					    awm.CastSpellByName(rs["脚踢"],ThisUnit)
					end
				end

				if Class == "MAGE" then
				    local x,y,z = awm.ObjectPosition(ThisUnit)
				    local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
				    if Spell_Castable(rs["法术反制"]) and Combat_Monster[#Combat_Monster].Distance < 30 and not In_Sight and hit == 0 then
					    awm.CastSpellByName(rs["法术反制"],ThisUnit)
					end
				end

				if Class == "WARRIOR" then
					if Spell_Castable(rs["拳击"]) and Combat_Monster[#Combat_Monster].Distance < 5 then
					    awm.CastSpellByName(rs["拳击"],ThisUnit)
					end

					if Spell_Castable(rs["盾击"]) and Combat_Monster[#Combat_Monster].Distance < 5 then
					    awm.CastSpellByName(rs["盾击"],ThisUnit)
					end
				end
			end

			if Class == "WARRIOR" then
				if Easy_Data.Combat["战士防御姿态"] and Spell_Castable(rs["嘲讽"]) and U_target ~= Player_GUID and Combat_Monster[#Combat_Monster].Distance < 5 then
					awm.CastSpellByName(rs["嘲讽"],Combat_Monster[#Combat_Monster].Unit)
				end
			end

			if Class == "DRUID" then
				if (Easy_Data.Combat["小德熊形态"] or Easy_Data.Combat["小德巨熊形态"]) and Spell_Castable(rs["低吼"]) and U_target ~= Player_GUID and Combat_Monster[#Combat_Monster].Distance < 5 then
					awm.CastSpellByName(rs["低吼"],Combat_Monster[#Combat_Monster].Unit)
				end
			end

			if Class == "PALADIN" then
				if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "tank" and Spell_Castable(rs["正义防御"]) and U_target ~= Player_GUID and awm.ObjectIsPlayer(U_target) and awm.GetDistanceBetweenObjects("player",U_target) < 20 then
					awm.CastSpellByName(rs["正义防御"],U_target)
				end
			end

			if Class == "WARLOCK" and CheckDebuffByName(ThisUnit,rs["恐惧"]) then
			    Special_Buff = true
			end

			if #Combat_Monster >= 2 then
			    if Class == "ROGUE" then
				    if Spell_Castable(rs["佯攻"]) and Combat_Monster[#Combat_Monster].Distance < 5 and Easy_Data.Combat["盗贼佯攻"] then
					    awm.CastSpellByName(rs["佯攻"],ThisUnit)
					end
				end
				if Class == "HUNTER" then
				    if Spell_Castable(rs["逃脱"]) and Combat_Monster[#Combat_Monster].Distance < 5 and Easy_Data.Combat["猎人逃脱"] then
					    awm.CastSpellByName(rs["逃脱"],ThisUnit)
					end
				end
			end
		end
	end
	if #Combat_Monster > 0 then
        table.sort(Combat_Monster, function(a, b)
			if a.Distance < b.Distance then
				return true
			elseif a.Distance == b.Distance then
				return false
			end
			return false
		end)
	end
  
    if (not target and #Combat_Monster > 0) or (not awm.ObjectExists(target) and #Combat_Monster > 0) then
	
	    target = Combat_Monster[1].Unit

		if Class == "HUNTER" then
		    for i = 1,#Combat_Monster do
			    if CheckDebuffByName(Combat_Monster[i].Unit,rs["猎人印记"]) then
				    target = Combat_Monster[i].Unit
				end
			end
		elseif IsInRaid("player") or UnitInParty("player") then
		    if UnitIsGroupLeader("player") then
			    local Far_Distance = 100
			    for i = 1,#Combat_Monster do
					local U_target = awm.UnitTarget(Combat_Monster[i].Unit)
					local guid = awm.ObjectId(Combat_Monster[i].Unit)
					if U_target and U_target ~= Player_GUID then
					    target = Combat_Monster[i].Unit
						break
					end
				end
			else
			    local Tar_List = {}
			    for i = 1,#Combat_Monster do
					local Tar_ID = awm.ObjectId(Combat_Monster[i].Unit)
					for id = 1,#Kill_First do
						if Tar_ID and Tar_ID == Kill_First[id] then
						    Tar_List[#Tar_List + 1] = {}
							Tar_List[#Tar_List].ID = Tar_ID
							Tar_List[#Tar_List].Unit = Combat_Monster[i].Unit
						end
					end
				end

				local Find_Target = false
				for id = 1,#Kill_First do
				    for i = 1,#Tar_List do
					    if Tar_List[i].ID == Kill_First[id] then
						    target = Tar_List[i].Unit
							Find_Target = true
							break
						end
					end

					if Find_Target then
					    break
					end
				end
			end
		end
	end

	if Combat.Fixed_Target then
	    target = Combat.Fixed_Target

		local Change_time = 1

		if (Class == "ROGUE" or Class == "WARRIOR" or Class == "DRUID") and not UnitIsGroupLeader("player") then
		    Change_time = 10
		end

		if GetTime() - Combat.Fixed_Time > Change_time or not awm.ObjectExists(Combat.Fixed_Target) or awm.UnitIsDead(Combat.Fixed_Target) then
		    Combat.Fixed_Target = nil
			return
		end
	else
	    Combat.Fixed_Time = GetTime()
		Combat.Fixed_Target = target
	end

	if not target then
	    return
	end

	if awm.SpellIsTargeting() and Class == "ROGUE" then
	    awm.SpellStopTargeting()
	end

	awm.TargetUnit(target)

	local x,y,z = awm.ObjectPosition(target)
	if not x or not y or not z then
	    Combat.Fixed_Target = nil
	    return
	end

	local distance = awm.GetDistanceBetweenObjects("player",target)
	
	local Tar_Health = (awm.UnitHealth("target")/awm.UnitHealthMax("target")) * 100
	local Tar_Power = (awm.UnitPower("target")/awm.UnitPowerMax("target")) * 100

	if UnitFullName("target") then
		Note_Set(UnitFullName("target").." = "..math.floor(awm.UnitHealth("target")).." | "..math.floor(awm.UnitPower("target")))
	end

	if awm.IsAoEPending() then
	    if Class == "ROGUE" then
		    awm.SpellStopTargeting()
			awm.SpellStopCasting()
		end
	    awm.ClickPosition(x,y,z)
		return
	end

	if IsMounted() and distance <= 40 then
	    Dismount()
	end
	if Mount_useble <= GetTime() then
		Mount_useble = GetTime() + 5
	end
	if CastingBarFrame:IsVisible() then
	    return
	end

    local flags = bit.bor(0x10, 0x100, 0x1)
    local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
	if hit == 1 or In_Sight then
	    Run(x,y,z)
		return
	end

	if GetTime() - Combat.Face_Time > 1 and distance < 35 and Tar_Health < 100 and awm.UnitAffectingCombat("player") and awm.UnitAffectingCombat("target") then
	    Combat.Face_Time = GetTime()
		awm.FaceTarget("target")
		return
	end

	if distance <= 4 and awm.ObjectExists(target) and not Combat.Forst then
	    local obj_face = awm.UnitFacing("player")
		local need_face = awm.GetAnglesBetweenObjects("player","target")

		awm.InteractUnit(target)
		if GetUnitSpeed("player") > 0 and math.abs(obj_face - need_face) < 0.4 then
			Try_Stop()
		elseif math.abs(obj_face - need_face) > 0.4 then
		    awm.FaceDirection(need_face)
		end
	end

	if distance >= 29 and not Combat.Combat_In_Range then
	    Run(x,y,z)
		return
    elseif distance < 29 and not Combat.Combat_In_Range then
	    Combat.Combat_In_Range = true
		Try_Stop()
		C_Timer.After(10,function()
		    if Combat.Combat_In_Range then
				Combat.Combat_In_Range = false 
			end	
		end)
	end

	--------------------------------种族天赋------------------------------
	if awm.UnitAffectingCombat("player") and Cur_Health <= 90 and distance <= 40 then
	    if Race == "Orc" and Spell_Castable(rs["血性狂怒"]) then
		    awm.CastSpellByName(rs["血性狂怒"])
		end
	end

	UseItem()

	--------------------------------法师------------------------------
	if Class == "MAGE" then
	    if Spell_Castable(rs["唤醒"]) and not CheckBuff("player",rs["唤醒"]) and Cur_Power <= 20 then
			awm.CastSpellByName(rs["唤醒"],"player")
			return
		end	

		if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) and Easy_Data.Combat["法师寒冰护体"] then
		    awm.CastSpellByName(rs["寒冰护体"],"player")
			return
		end

		if Spell_Castable(rs["法力护盾"]) and not CheckBuff("player",rs["法力护盾"]) and Easy_Data.Combat["法师法力护盾"] then
		    awm.CastSpellByName(rs["法力护盾"],"player")
			return
		end

		if Spell_Castable(rs["冰冷血脉"]) and not CheckBuff("player",rs["冰冷血脉"]) and distance <= 35 then
		    awm.CastSpellByName(rs["冰冷血脉"],"player")
			return
		end

		if not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and Easy_Data.Combat["法师冰甲术"] then
		    if Spell_Castable(rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) then
				awm.CastSpellByName(rs["冰甲术"],"player")
				return
			end
			if Spell_Castable(rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
				awm.CastSpellByName(rs["霜甲术"],"player")
				return
			end		
		end

		if Spell_Castable(rs["法师魔甲术"]) and not CheckBuff("player",rs["法师魔甲术"]) and Easy_Data.Combat["法师魔甲术"] then
			awm.CastSpellByName(rs["法师魔甲术"],"player")
			return
		end	

		if Spell_Castable(rs["熔岩护甲"]) and not CheckBuff("player",rs["熔岩护甲"]) and Easy_Data.Combat["法师熔岩护甲"] then
			awm.CastSpellByName(rs["熔岩护甲"],"player")
			return
		end	

		if Spell_Castable(rs["魔法抑制"]) and not CheckBuff("player",rs["魔法抑制"]) and Easy_Data.Combat["法师魔法抑制"] then
			awm.CastSpellByName(rs["魔法抑制"],"player")
			return
		end	

		if Spell_Castable(rs["魔法增效"]) and not CheckBuff("player",rs["魔法增效"]) and Easy_Data.Combat["法师魔法增效"] then
			awm.CastSpellByName(rs["魔法增效"],"player")
			return
		end	

		if Spell_Castable(rs["气定神闲"]) and not CheckBuff("player",rs["气定神闲"]) then
			awm.CastSpellByName(rs["气定神闲"],"player")
			return
		end	

		if Spell_Castable(rs["燃烧"]) and not CheckBuff("player",rs["燃烧"]) then
			awm.CastSpellByName(rs["燃烧"],"player")
			return
		end	

		if Spell_Castable(rs["奥术强化"]) and not CheckBuff("player",rs["奥术强化"]) then
			awm.CastSpellByName(rs["奥术强化"],"player")
			return
		end	

		if Spell_Castable(rs["烈焰风暴"]) and #Combat_Monster >= 2 and Easy_Data.Combat["法师烈焰风暴"] and GetTime() - Combat.Time >= 10 and distance < 29 then
		    Combat.Time = GetTime()
			awm.CastSpellByName(rs["烈焰风暴"])
			return
		end	

		if Spell_Castable(rs["活动炸弹"]) and distance <= 29 and not CheckDebuffByName("target",rs["活动炸弹"]) and Easy_Data.Combat["法师活动炸弹"] then
		    awm.CastSpellByName(rs["活动炸弹"])
			return
		end


		if distance < 10 and Spell_Castable(rs["冰霜新星"]) then
		    awm.CastSpellByName(rs["冰霜新星"])
			Combat.Forst = true
			C_Timer.After(1.25,function() Combat.Forst = false Try_Stop() end)
			return
		end
		if Combat.Forst then
		    awm.MoveBackwardStart()
			return
		end

		if distance > 35 then
		    Run(x,y,z)
			return
		end

		if Spell_Castable(rs["暴风雪"]) and #Combat_Monster >= 2 and Easy_Data.Combat["法师暴风雪"] and distance < 35 then
			awm.CastSpellByName(rs["暴风雪"])
			return
		end	

		if not PetHasActionBar() and distance <= 30 and Spell_Castable(rs["召唤水元素"]) and Easy_Data.Combat["法师召唤水元素"] then
		    awm.CastSpellByName(rs["召唤水元素"])
			return
		elseif PetHasActionBar() and not UnitIsDead("pet") and (not awm.UnitTarget("pet") or awm.UnitTarget("pet") and awm.UnitTarget("pet") ~= awm.UnitTarget("player")) then
		    awm.PetAttack("target")
		end

		local starttime, duration, enabled, _ = GetSpellCooldown(rs["召唤水元素"])
		local Water_Pet_Cooldown = 0

		if starttime then
		    Water_Pet_Cooldown = starttime + duration
		end
		if not PetHasActionBar() and distance <= 30 and GetTime() > Water_Pet_Cooldown and Spell_Castable(rs["急速冷却"]) then
		    awm.CastSpellByName(rs["急速冷却"])
			return
		end

		if PetHasActionBar() and Spell_Castable(rs["冰冻术"]) and distance <= 30 then
		    awm.CastSpellByName(rs["冰冻术"])
			return
		end

		if Spell_Castable(rs["火焰冲击"]) and distance <= 19 then
			awm.CastSpellByName(rs["火焰冲击"])
			return
		end

		if distance <= 35 and Spell_Castable(rs["冰枪术"]) and (CheckDebuffByName("target",rs["冰霜新星"]) or CheckDebuffByName("target",rs["冰冻术"])) and Easy_Data.Combat["法师冰枪术"] then
		    awm.CastSpellByName(rs["冰枪术"])
			return
		end

		if Spell_Castable(rs["冰锥术"]) and distance <= 8 and Easy_Data.Combat["法师冰锥术"] then
			awm.CastSpellByName(rs["冰锥术"])
			return
		end

		if Spell_Castable(rs["炎爆术"]) and Easy_Data.Combat["法师炎爆术"] and distance <= 30 then
			awm.CastSpellByName(rs["炎爆术"])
			return
		end

		if Spell_Castable(rs["龙息术"]) and Easy_Data.Combat["法师龙息术"] and distance <= 8 then
			awm.CastSpellByName(rs["龙息术"])
			return
		end

		if Spell_Castable(rs["冲击波"]) and Easy_Data.Combat["法师冲击波"] and distance <= 8 then
			awm.CastSpellByName(rs["冲击波"])
			return
		end

		if Spell_Castable(rs["寒冰箭"]) and distance <= 34 and Easy_Data.Combat["法师寒冰箭"] then
			awm.CastSpellByName(rs["寒冰箭"])
			return
		end

		if Spell_Castable(rs["灼烧"]) and distance <= 29 and Easy_Data.Combat["法师灼烧"] then
			awm.CastSpellByName(rs["灼烧"])
			return
		end

		if Spell_Castable(rs["奥术飞弹"]) and distance <= 29 and Easy_Data.Combat["法师奥术飞弹"] then
			awm.CastSpellByName(rs["奥术飞弹"])
			return
		end

		if Spell_Castable(rs["火球术"]) and distance <= 34 and Easy_Data.Combat["法师火球术"] then
			awm.CastSpellByName(rs["火球术"])
			return
		end
	end
	--------------------------------术士------------------------------
	if Class == "WARLOCK" then
		
		if not CheckBuff("player",rs["邪甲术"]) and Spell_Castable(rs["邪甲术"]) and Easy_Data.Combat["术士邪甲术"] then
			awm.CastSpellByName(rs["邪甲术"],"player")
			return
		end

		if not CheckBuff("player",rs["恶魔皮肤"]) and Spell_Castable(rs["恶魔皮肤"]) and Easy_Data.Combat["术士恶魔皮肤"] then
			awm.CastSpellByName(rs["恶魔皮肤"],"player")
			return
		end

		if not CheckBuff("player",rs["术士魔甲术"]) and Spell_Castable(rs["术士魔甲术"]) and Easy_Data.Combat["术士魔甲术"] then
			awm.CastSpellByName(rs["术士魔甲术"],"player")
			return
		end

		if distance > 37 then
			Run(x,y,z)
			return
		end

		if GetItemCount(rs["灵魂碎片"]) <= 10 then
			if UnitHealth("target") <= 620 and UnitLevel("player") >= 67 and distance <= 30 and Spell_Castable(rs["吸取灵魂"]) then
				awm.CastSpellByName(rs["吸取灵魂"])
				return
			elseif UnitHealth("target") <= 455 and UnitLevel("player") >= 52 and distance <= 30 and Spell_Castable(rs["吸取灵魂"]) then
				awm.CastSpellByName(rs["吸取灵魂"])
				return
			elseif UnitHealth("target") <= 290 and UnitLevel("player") >= 38 and distance <= 30 and Spell_Castable(rs["吸取灵魂"]) then
				awm.CastSpellByName(rs["吸取灵魂"])
				return
			elseif UnitHealth("target") <= 155 and UnitLevel("player") >= 24 and distance <= 30 and Spell_Castable(rs["吸取灵魂"]) then
				awm.CastSpellByName(rs["吸取灵魂"])
				return
			end
		end

		if CheckBuff("player",rs["暗影冥思"]) and Spell_Castable(rs["暗影箭"]) and distance <= 35 then
		    awm.CastSpellByName(rs["暗影箭"])
			return
		end

		if PetHasActionBar() and not UnitIsDead("pet") and UnitPower("pet") > 700 and Cur_Power <= Easy_Data.Combat["术士生命分流蓝量"] + 2 and Spell_Castable(rs["黑暗契约"]) then
			awm.CastSpellByName(rs["黑暗契约"])
			return
		end

		if Cur_Power <= Easy_Data.Combat["术士生命分流蓝量"] and Cur_Health >= Easy_Data.Combat["术士生命分流血量"] and Spell_Castable(rs["生命分流"]) and Easy_Data.Combat["术士生命分流"] then
			awm.CastSpellByName(rs["生命分流"])
			return
		end

		if PetHasActionBar() and not UnitIsDead("pet") and not awm.UnitTarget("pet") then
		    awm.PetAttack("target")
		elseif PetHasActionBar() and not UnitIsDead("pet") and awm.UnitTarget("pet") and awm.UnitTarget("pet") ~= awm.UnitTarget("player") then
		    awm.PetAttack("target")
		end

		if PetHasActionBar() and not UnitIsDead("pet") and (awm.UnitHealth("pet")/awm.UnitHealthMax("pet")) * 100 <= Easy_Data.Combat["术士生命通道血量"] and Spell_Castable(rs["生命通道"]) and Easy_Data.Combat["术士生命通道"] then
		    awm.CastSpellByName(rs["生命通道"])
			return
		end


		if not Special_Buff and Spell_Castable(rs["恐惧"]) and distance <= 23 and Easy_Data.Combat["术士恐惧"] then
		    awm.CastSpellByName(rs["恐惧"])
			return
		end

		if not CheckDebuffByName("target",rs["恐惧"]) and Spell_Castable(rs["死亡缠绕"]) and distance <= 35 and Easy_Data.Combat["术士死亡缠绕"] then
		    awm.CastSpellByName(rs["死亡缠绕"])
			return
		end

		if Spell_Castable(rs["灵魂之火"]) and distance <= 29 and Easy_Data.Combat["术士灵魂之火"] and GetItemCount(rs["灵魂碎片"]) > 0 then
			awm.CastSpellByName(rs["灵魂之火"])
			return
		end

		if Spell_Castable(rs["暗影之怒"]) and distance <= 19 and Easy_Data.Combat["术士暗影之怒"] then
			awm.CastSpellByName(rs["暗影之怒"])
			return
		end

		if Spell_Castable(rs["地狱烈焰"]) and distance <= 8 and Easy_Data.Combat["术士地狱烈焰"] then
			awm.CastSpellByName(rs["地狱烈焰"])
			return
		end

		if not CheckBuff("player",rs["灵魂链接"]) and Spell_Castable(rs["灵魂链接"]) and Easy_Data.Combat["术士灵魂链接"] then
			awm.CastSpellByName(rs["灵魂链接"])
			return
		end

		awm.FaceCombat("target")

		if Spell_Castable(rs["痛苦诅咒"]) and awm.IsSpellInRange(rs["痛苦诅咒"],"target") == 1 and not CheckDebuffByName("target",rs["痛苦诅咒"]) and Easy_Data.Combat["术士痛苦诅咒"] then
			awm.CastSpellByName(rs["痛苦诅咒"],"target")
			return
		end

		if Spell_Castable(rs["生命虹吸"]) and awm.IsSpellInRange(rs["生命虹吸"],"target") == 1 and not CheckDebuffByName("target",rs["生命虹吸"]) and Easy_Data.Combat["术士生命虹吸"] then
			awm.CastSpellByName(rs["生命虹吸"])
			return
		end

		if Spell_Castable(rs["吸取生命"]) and awm.IsSpellInRange(rs["吸取生命"],"target") == 1 and Cur_Health <= Easy_Data.Combat["术士吸取生命血量"] and Easy_Data.Combat["术士吸取生命"] then
			awm.CastSpellByName(rs["吸取生命"])
			return
		end

		if Spell_Castable(rs["诅咒增幅"]) then
		    awm.CastSpellByName(rs["诅咒增幅"])
			return
		end

		if Spell_Castable(rs["火焰之雨"]) and distance <= 29 and Easy_Data.Combat["术士火焰之雨"] then
			awm.CastSpellByName(rs["火焰之雨"])
			return
		end

		for i = 1,#Combat_Monster do
		    local ThisUnit = Combat_Monster[i].Unit
			local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)

			if Spell_Castable(rs["厄运诅咒"]) and distance <= 30 and #Combat_Monster >= 2 and not CheckDebuffByName(ThisUnit,rs["厄运诅咒"]) and Easy_Data.Combat["术士厄运诅咒"] then
				awm.CastSpellByName(rs["厄运诅咒"],ThisUnit)
				return
			end

			if Spell_Castable(rs["腐蚀之种"]) and distance <= 30 and not CheckDebuffByName(ThisUnit,rs["腐蚀之种"]) and Easy_Data.Combat["术士腐蚀之种"] then
				awm.CastSpellByName(rs["腐蚀之种"],ThisUnit)
				return
			end
			
			if Spell_Castable(rs["痛苦诅咒"]) and awm.IsSpellInRange(rs["痛苦诅咒"],ThisUnit) == 1 and not CheckDebuffByName(ThisUnit,rs["痛苦诅咒"]) and Easy_Data.Combat["术士痛苦诅咒"] then
				awm.CastSpellByName(rs["痛苦诅咒"],ThisUnit)
				return
			end

			if Spell_Castable(rs["痛苦无常"]) and awm.IsSpellInRange(rs["痛苦无常"],ThisUnit) == 1 and not CheckDebuffByName(ThisUnit,rs["痛苦无常"]) and Easy_Data.Combat["术士痛苦无常"] then
				awm.CastSpellByName(rs["痛苦无常"],ThisUnit)
				return
			end


			if Spell_Castable(rs["烧尽"]) and awm.IsSpellInRange(rs["烧尽"],ThisUnit) == 1 and CheckDebuffByName(ThisUnit,rs["献祭"]) and Easy_Data.Combat["术士烧尽"] then
				awm.CastSpellByName(rs["烧尽"],ThisUnit)
				return
			end

			if Spell_Castable(rs["术士燃烧"]) and awm.IsSpellInRange(rs["术士燃烧"],ThisUnit) == 1 and CheckDebuffByName(ThisUnit,rs["献祭"]) and Easy_Data.Combat["术士燃烧"] then
				awm.CastSpellByName(rs["术士燃烧"],ThisUnit)
				return
			end

			if Spell_Castable(rs["献祭"]) and awm.IsSpellInRange(rs["献祭"],ThisUnit) == 1 and not CheckDebuffByName(ThisUnit,rs["献祭"]) and Easy_Data.Combat["术士献祭"] then
				awm.CastSpellByName(rs["献祭"],ThisUnit)
				return
			end
			if Spell_Castable(rs["腐蚀术"]) and awm.IsSpellInRange(rs["腐蚀术"],ThisUnit) == 1 and not CheckDebuffByName(ThisUnit,rs["腐蚀术"]) and Easy_Data.Combat["术士腐蚀术"] then
				awm.CastSpellByName(rs["腐蚀术"],ThisUnit)
				return
			end
		end

		if Spell_Castable(rs["灼热之痛"]) and distance <= 29 and Easy_Data.Combat["术士灼热之痛"] then
			awm.CastSpellByName(rs["灼热之痛"])
			return
		end

		if Spell_Castable(rs["暗影箭"]) and distance <= 35 then
			awm.CastSpellByName(rs["暗影箭"])
			return
		end
	end
	--------------------------------战士------------------------------
	if Class == "WARRIOR" then
		if distance <= 25 and distance > 8 and Spell_Castable(rs["冲锋"]) and not UnitAffectingCombat("player") then
		    awm.CastSpellByName(rs["冲锋"],"target")
			return
		end

		if distance >= 9 and distance <= 24 and Spell_Castable(rs["拦截"]) then
		    awm.CastSpellByName(rs["拦截"],"target")
			return
		end
		if distance >= 4.9 then
			Run(x,y,z)
			return
		end
	    
		if GetTime() - Combat.Time > 7 then
		    Combat.Time = GetTime()
		    if Easy_Data.Combat["战士战斗姿态"] then
			    awm.CastSpellByName(rs["战斗姿态"])
			end
			if Easy_Data.Combat["战士防御姿态"] then
			    awm.CastSpellByName(rs["防御姿态"])
			end
			if Easy_Data.Combat["战士狂暴姿态"] then
			    awm.CastSpellByName(rs["狂暴姿态"])
			end

			if GetUnitSpeed("player") > 0 then
				if distance <= 2 then
					Try_Stop()
				end
				awm.InteractUnit("target")
			end
			return
		end

		if not CheckBuff("player",rs["战斗怒吼"]) and Spell_Castable(rs["战斗怒吼"]) and Easy_Data.Combat["战士战斗怒吼"] then
		    awm.CastSpellByName(rs["战斗怒吼"])
			return
		end
		if not CheckDebuffByName("target",rs["挫志怒吼"]) and Spell_Castable(rs["挫志怒吼"]) and Easy_Data.Combat["战士挫志怒吼"] then
		    awm.CastSpellByName(rs["挫志怒吼"])
			return
		end

		if not CheckBuff("player",rs["命令怒吼"]) and Spell_Castable(rs["命令怒吼"]) and Easy_Data.Combat["战士命令怒吼"] then
		    awm.CastSpellByName(rs["命令怒吼"])
			return
		end

		if not CheckDebuffByName("target",rs["刺耳怒吼"]) and Spell_Castable(rs["刺耳怒吼"]) and Easy_Data.Combat["战士刺耳怒吼"] then
		    awm.CastSpellByName(rs["刺耳怒吼"])
			return
		end

		if not CheckBuff("player",rs["死亡之愿"]) and Spell_Castable(rs["死亡之愿"]) and Easy_Data.Combat["战士死亡之愿"] then
		    awm.CastSpellByName(rs["死亡之愿"])
			return
		end

		if not CheckBuff("player",rs["鲁莽"]) and Spell_Castable(rs["鲁莽"]) then
		    awm.CastSpellByName(rs["鲁莽"])
			return
		end

		if not CheckBuff("player",rs["狂暴之怒"]) and Spell_Castable(rs["狂暴之怒"]) then
		    awm.CastSpellByName(rs["狂暴之怒"])
			return
		end

		if not CheckBuff("player",rs["血性狂暴"]) and Spell_Castable(rs["血性狂暴"]) then
		    awm.CastSpellByName(rs["血性狂暴"])
			return
		end
		if not CheckBuff("player",rs["嗜血"]) and Spell_Castable(rs["嗜血"]) and Easy_Data.Combat["战士嗜血"] then
		    awm.CastSpellByName(rs["嗜血"])
			return
		end

		if not CheckBuff("player",rs["暴怒"]) and Spell_Castable(rs["暴怒"]) and Easy_Data.Combat["战士暴怒"] then
		    awm.CastSpellByName(rs["暴怒"])
			return
		end

		if not CheckBuff("player",rs["破釜沉舟"]) and Spell_Castable(rs["破釜沉舟"]) and Easy_Data.Combat["战士破釜沉舟"] and Cur_Health <= 30 then
		    awm.CastSpellByName(rs["破釜沉舟"])
			return
		end

		if Spell_Castable(rs["反击风暴"]) and Cur_Health <= 40 then
			awm.CastSpellByName(rs["反击风暴"])
			return
		end

		if Spell_Castable(rs["盾墙"]) and Cur_Health <= 40 then
			awm.CastSpellByName(rs["盾墙"])
			return
		end

		if Spell_Castable(rs["破胆怒吼"]) and Cur_Health <= 20 and (Is_Dungeon or awm.ObjectIsPlayer("target")) then
			awm.CastSpellByName(rs["破胆怒吼"])
			return
		end

		if Spell_Castable(rs["横扫攻击"]) and Easy_Data.Combat["战士横扫攻击"] and #Combat_Monster >= 2 then
			awm.CastSpellByName(rs["横扫攻击"])
			return
		end

		if not CheckBuff("player",rs["盾牌格挡"]) and Spell_Castable(rs["盾牌格挡"]) and (#Target_On_Me >= 2 or Cur_Health <= 50) then
		    awm.CastSpellByName(rs["盾牌格挡"])
			return
		end

		if Spell_Castable(rs["压制"]) then
			awm.CastSpellByName(rs["压制"])
			return
		end

		if Spell_Castable(rs["缴械"]) then
			awm.CastSpellByName(rs["缴械"])
			return
		end

		local starttime, duration, enabled, _ = GetSpellCooldown(rs["雷霆一击"])
		local Cool_Down = 0

		if starttime then
		    Cool_Down = starttime + duration
		end

		if Cool_Down < GetTime() and Easy_Data.Combat["战士雷霆一击"] and #Combat_Monster >= 2 then
		    if Spell_Castable(rs["雷霆一击"]) then
		        awm.CastSpellByName(rs["雷霆一击"])
			end
			return
		end

		if Spell_Castable(rs["复仇"]) then
			awm.CastSpellByName(rs["复仇"])
			return
		end

		if Spell_Castable(rs["斩杀"]) and Tar_Health <= 19 then
		    awm.CastSpellByName(rs["斩杀"])
			return
		end

		if Spell_Castable(rs["顺劈斩"]) and Easy_Data.Combat["战士顺劈斩"] and #Combat_Monster >= 2 then
			awm.CastSpellByName(rs["顺劈斩"])
			return
		end

		if Spell_Castable(rs["震荡猛击"]) then
			awm.CastSpellByName(rs["震荡猛击"])
			return
		end

		if Spell_Castable(rs["盾牌猛击"]) then
			awm.CastSpellByName(rs["盾牌猛击"])
			return
		end

		if Spell_Castable(rs["毁灭打击"]) and not CheckDebuffByName("target",rs["破甲攻击"]) then
		    awm.CastSpellByName(rs["毁灭打击"])
			return
		end

		if Spell_Castable(rs["惩戒痛击"]) and Easy_Data.Combat["战士惩戒痛击"] then
		    awm.CastSpellByName(rs["惩戒痛击"])
			return
		end

		if Spell_Castable(rs["致死打击"]) and Easy_Data.Combat["战士致死打击"] and not CheckDebuffByName("target",rs["致死打击"]) then
			awm.CastSpellByName(rs["致死打击"])
			return
		end

		if Spell_Castable(rs["撕裂"]) and not CheckDebuffByName("target",rs["撕裂"]) then
			awm.CastSpellByName(rs["撕裂"])
			return
		end 

		if Spell_Castable(rs["旋风斩"]) and Easy_Data.Combat["战士旋风斩"] and #Combat_Monster >= 2 then
			awm.CastSpellByName(rs["旋风斩"])
			return
		end

		if Spell_Castable(rs["英勇打击"]) and Easy_Data.Combat["战士英勇打击"] then
			awm.CastSpellByName(rs["英勇打击"])
			return
		end
		if Spell_Castable(rs["猛击"]) and Easy_Data.Combat["战士猛击"] then
			awm.CastSpellByName(rs["猛击"])
			return
		end
	end
	--------------------------------萨满------------------------------
	if Class == "SHAMAN" then
	    local TuTeng = 
		{
			rs["石肤图腾"],
			rs["地缚图腾"],
			rs["石爪图腾"],
			rs["大地之力图腾"],
			rs["灼热图腾"],
			rs["战栗图腾"],
			rs["火焰新星图腾"],
			rs["治疗之泉图腾"],
			rs["抗寒图腾"],
			rs["法力之泉图腾"],
			rs["熔岩图腾"],
			rs["火舌图腾"],
			rs["抗火图腾"],
			rs["根基图腾"],
			rs["自然抗性图腾"],
			rs["风怒图腾"],
			rs["净化图腾"],
			rs["法力之潮图腾"],
			rs["天怒图腾"],
			rs["空气之怒图腾"],
			rs["土元素图腾"],
			rs["风墙图腾"],
			rs["火元素图腾"],
			rs["清毒图腾"],
			rs["祛病图腾"],
			rs["风之优雅图腾"],
		}

		local TuTeng_Exist = {}

		for i = 1,awm.GetObjectCount() do
		    local ThisUnit = awm.GetObjectWithIndex(i)
		    local name = awm.UnitFullName(ThisUnit)
			local Creator = awm.UnitCreatedBy(ThisUnit)
			local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
			if awm.ObjectExists(ThisUnit) and Creator and Creator == Player_GUID and name and string.find(name,Check_Client("图腾","Totem")) and distance < 20 then
			    TuTeng_Exist[#TuTeng_Exist + 1] = name 
			end
		end

		if #TuTeng_Exist > 0 then
		    for i = 1,#TuTeng do
			    local Exist = false
				for t = 1,#TuTeng_Exist do
				    if string.find(TuTeng_Exist[t],TuTeng[i]) then
					    Exist = true
						break
					end
				end

			    if Spell_Castable(TuTeng[i]) and Easy_Data.Combat["萨满"..TuTeng[i]] and not Exist and (not Easy_Data.Combat["增强萨满"] or (Easy_Data.Combat["增强萨满"] and distance < 8)) then
			        awm.CastSpellByName(TuTeng[i])
				    return
			    end
			end
		else
		    for i = 1,#TuTeng do
			    if Spell_Castable(TuTeng[i]) and Easy_Data.Combat["萨满"..TuTeng[i]] and (not Easy_Data.Combat["增强萨满"] or (Easy_Data.Combat["增强萨满"] and distance < 8)) then
			        awm.CastSpellByName(TuTeng[i])
				    return
			    end
			end
		end

	    if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "healer" and Is_Dungeon and (UnitInParty("player") or IsInRaid("player")) then	
		    local leader = nil
			local leader_name = nil
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) and UnitIsGroupLeader("party"..i) then
						leader = "party"..i
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) and UnitIsGroupLeader("raid"..i) then
						leader = "raid"..i
					end
				end
			end

			if leader then
			    leader_name = awm.UnitGUID(leader)
			end

			local Status = {}
			local Lowest_Health = 100
			local Lowest_Health_Party = nil
			local Lian = true -- 治疗链
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("party"..i)
						Status[i].Guid = awm.UnitGUID("party"..i)
						Status[i].Cur_Health = (awm.UnitHealth("party"..i)/awm.UnitHealthMax("party"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("party"..i)/awm.UnitPowerMax("party"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","party"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["萨满治疗链血量"] and Status[i].Distance <= 18 then
						    Lian = false
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("party"..i,1)
						if name and dispelType == "Poison" and Spell_Castable(rs["消毒术"]) and Easy_Data.Combat["萨满消毒术"] then
							awm.CastSpellByName(rs["消毒术"],"party"..i)
						end

						if name and dispelType == "Disease" and Spell_Castable(rs["祛病术"]) and Easy_Data.Combat["萨满祛病术"] then
							awm.CastSpellByName(rs["祛病术"],"party"..i)
						end
					end
				end

				if Lian and Easy_Data.Combat["萨满治疗链"] then
				    awm.CastSpellByName(rs["治疗链"],Status[Lowest_Health_Party].Guid)
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if Spell_Castable(rs["大地之盾"]) and health <= 30 and not CheckBuff(Member_target,rs["大地之盾"]) and Easy_Data.Combat["萨满大地之盾"] then
					    awm.CastSpellByName(rs["大地之盾"],Member_target)
					end

					if health <= Easy_Data.Combat["萨满次级治疗波血量"] and Spell_Castable(rs["次级治疗波"]) and Easy_Data.Combat["萨满次级治疗波"] then
					    awm.CastSpellByName(rs["次级治疗波"],Member_target)
					end

					if health <= Easy_Data.Combat["萨满治疗波血量"] and Spell_Castable(rs["治疗波"]) and Easy_Data.Combat["萨满治疗波"] then
					    awm.CastSpellByName(rs["治疗波"],Member_target)
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("raid"..i)
						Status[i].Guid = awm.UnitGUID("raid"..i)
						Status[i].Cur_Health = (awm.UnitHealth("raid"..i)/awm.UnitHealthMax("raid"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("raid"..i)/awm.UnitPowerMax("raid"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","raid"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["萨满治疗链血量"] and Status[i].Distance <= 18 then
						    Lian = false
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("raid"..i,1)
						if name and dispelType == "Poison" and Spell_Castable(rs["消毒术"]) and Easy_Data.Combat["萨满消毒术"] then
							awm.CastSpellByName(rs["消毒术"],"raid"..i)
						end

						if name and dispelType == "Disease" and Spell_Castable(rs["祛病术"]) and Easy_Data.Combat["萨满祛病术"] then
							awm.CastSpellByName(rs["祛病术"],"raid"..i)
						end
					end
				end


				if Lian and Easy_Data.Combat["萨满治疗链"] then
				    awm.CastSpellByName(rs["治疗链"],Status[Lowest_Health_Party].Guid)
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if Spell_Castable(rs["大地之盾"]) and health <= 30 and not CheckBuff(Member_target,rs["大地之盾"]) and Easy_Data.Combat["萨满大地之盾"] then
					    awm.CastSpellByName(rs["大地之盾"],Member_target)
					end

					if health <= Easy_Data.Combat["萨满次级治疗波血量"] and Spell_Castable(rs["次级治疗波"]) and Easy_Data.Combat["萨满次级治疗波"] then
					    awm.CastSpellByName(rs["次级治疗波"],Member_target)
					end

					if health <= Easy_Data.Combat["萨满治疗波血量"] and Spell_Castable(rs["治疗波"]) and Easy_Data.Combat["萨满治疗波"] then
					    awm.CastSpellByName(rs["治疗波"],Member_target)
					end
				end
			end
		else
			if not CheckBuff("player",rs["闪电之盾"]) and Spell_Castable(rs["闪电之盾"]) and Easy_Data.Combat["萨满闪电之盾"] then
				awm.CastSpellByName(rs["闪电之盾"],"player")
			end

			if not CheckBuff("player",rs["大地之盾"]) and Spell_Castable(rs["大地之盾"]) and Easy_Data.Combat["萨满大地之盾"] then
				awm.CastSpellByName(rs["大地之盾"],"player")
			end

			if not CheckBuff("player",rs["水之护盾"]) and Spell_Castable(rs["水之护盾"]) and Easy_Data.Combat["萨满水之护盾"] then
				awm.CastSpellByName(rs["水之护盾"],"player")
			end

			if Cur_Health <= Easy_Data.Combat["萨满治疗波血量"] and Spell_Castable(rs["治疗波"]) and Easy_Data.Combat["萨满治疗波"] then
				awm.CastSpellByName(rs["治疗波"],"player")
				return
			end

			if Easy_Data.Combat["增强萨满"] and distance > 5 then
			    Run(x,y,z)
				return
			elseif distance > 34 then
			    Run(x,y,z)
				return
			end

			if GetUnitSpeed("player") > 0 then
				if distance <= 2 and GetTime() - Combat.Time > 1 then
				    Combat.Time = GetTime()
					Try_Stop()
				end
				awm.InteractUnit("target")
			end

			awm.FaceCombat(target)

			if Spell_Castable(rs["萨满之怒"]) and (Cur_Power < 50 or Cur_Health < 50) and Easy_Data.Combat["萨满萨满之怒"] then
				awm.CastSpellByName(rs["萨满之怒"])
			end

			if Spell_Castable(rs["嗜血"]) and Easy_Data.Combat["萨满嗜血"] then
				awm.CastSpellByName(rs["嗜血"])
			end

			if Spell_Castable(rs["风暴打击"]) and Easy_Data.Combat["萨满风暴打击"] then
				awm.CastSpellByName(rs["风暴打击"])
			end
			
			if Spell_Castable(rs["烈焰震击"]) and awm.IsSpellInRange(rs["烈焰震击"],"target") == 1 and not CheckDebuffByName("target",rs["烈焰震击"]) and Easy_Data.Combat["萨满烈焰震击"] then
				awm.CastSpellByName(rs["烈焰震击"])
			end
			if Spell_Castable(rs["地震术"]) and awm.IsSpellInRange(rs["地震术"],"target") == 1 and Easy_Data.Combat["萨满地震术"] then
				awm.CastSpellByName(rs["地震术"])
			end
			if Spell_Castable(rs["冰霜震击"]) and awm.IsSpellInRange(rs["冰霜震击"],"target") == 1 and Easy_Data.Combat["萨满冰霜震击"] then
				awm.CastSpellByName(rs["冰霜震击"])
			end

			if Spell_Castable(rs["闪电链"]) and awm.IsSpellInRange(rs["闪电链"],"target") == 1 and Easy_Data.Combat["萨满闪电链"] and #Combat_Monster >= 2 then
				awm.CastSpellByName(rs["闪电链"])
			end

			if Spell_Castable(rs["闪电箭"]) and awm.IsSpellInRange(rs["闪电箭"],"target") == 1 and Easy_Data.Combat["萨满闪电箭"] then
				awm.CastSpellByName(rs["闪电箭"])
			end
		end
	end
	--------------------------------盗贼------------------------------
	if Class == "ROGUE" then
		if distance > 4.9 then
		    Run(x,y,z)
			if not awm.UnitAffectingCombat("player") and not CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["潜行"]) and distance < 10 then
				awm.CastSpellByName(rs["潜行"])
			end


			if Spell_Castable(rs["暗影步"]) and distance <= 24 and CheckBuff("player",rs["潜行"]) then
			    awm.CastSpellByName(rs["暗影步"])
			end
			return
		end	

		if not UnitAffectingCombat("player") and GetTime() - Combat.Vanish < Easy_Data.Combat["盗贼消失时间"] then
		    NeedHeal()
			return
		end

		if CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["预谋"]) then
			awm.CastSpellByName(rs["预谋"])
			return
		end

		if CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["偷袭"]) then
			awm.CastSpellByName(rs["偷袭"])
			return
		end

		if Cur_Health < Easy_Data.Combat["盗贼闪避血量"] and not CheckBuff("player",rs["闪避"]) and Spell_Castable(rs["闪避"]) then
		    awm.CastSpellByName(rs["闪避"])
			return
		end

		if Cur_Health <= Easy_Data.Combat["盗贼消失血量"] and Spell_Castable(rs["消失"]) and GetItemCount(rs["闪光粉"]) > 0 then
		    awm.CastSpellByName(rs["消失"])
			Combat.Vanish = GetTime()
			return
		end

		if Spell_Castable(rs["剑刃乱舞"]) and #Combat_Monster >= 2 then
			awm.CastSpellByName(rs["剑刃乱舞"])
			return
		end

		if not Spell_Castable(rs["闪避"]) and Cur_Health < Easy_Data.Combat["盗贼闪避血量"] and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["闪避"]) then
		    awm.CastSpellByName(rs["伺机待发"])
			return
		end

		if Spell_Castable(rs["破甲"]) and not CheckDebuffByName("target",rs["破甲"]) and GetComboPoints("player", "target") >= Easy_Data.Combat["盗贼终结点数"] and Easy_Data.Combat["盗贼破甲"] then
			awm.CastSpellByName(rs["破甲"])
			return
		end

		if not CheckBuff("player",rs["冲动"]) and Spell_Castable(rs["冲动"]) then
			awm.CastSpellByName(rs["冲动"])
			return
		end

		if not CheckBuff("player",rs["切割"]) and Spell_Castable(rs["切割"]) and GetComboPoints("player", "target") >= Easy_Data.Combat["盗贼终结点数"] and Easy_Data.Combat["盗贼切割"] then
			awm.CastSpellByName(rs["切割"])
			return
		end

		if not CheckDebuffByName("target",rs["割裂"]) and Spell_Castable(rs["割裂"]) and GetComboPoints("player", "target") >= Easy_Data.Combat["盗贼终结点数"] and Easy_Data.Combat["盗贼割裂"] then
			awm.CastSpellByName(rs["割裂"])
			return
		end

		if not CheckDebuffByName("target",rs["出血"]) and Spell_Castable(rs["出血"]) then
			awm.CastSpellByName(rs["出血"])
			return
		end

		if Spell_Castable(rs["肾击"]) and GetComboPoints("player", "target") >= Easy_Data.Combat["盗贼终结点数"] and Easy_Data.Combat["盗贼肾击"] then
			awm.CastSpellByName(rs["肾击"])
			return
		end

		if Spell_Castable(rs["刺骨"]) and GetComboPoints("player", "target") >= Easy_Data.Combat["盗贼终结点数"] and Easy_Data.Combat["盗贼刺骨"] then
			awm.CastSpellByName(rs["刺骨"])
			return
		end

		if Spell_Castable(rs["鬼魅攻击"]) then
			awm.CastSpellByName(rs["鬼魅攻击"])
			return
		end
		if GetUnitSpeed("player") > 0 then
			if distance <= 2 and GetTime() - Combat.Time > 1 then
			    Combat.Time = GetTime()
				Try_Stop()
			end
			awm.InteractUnit("target")
		end
		if Spell_Castable(rs["影袭"]) then
			awm.CastSpellByName(rs["影袭"])
			return
		end
	end
	--------------------------------牧师------------------------------
	if Class == "PRIEST" then
	    if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "healer" and Is_Dungeon and (UnitInParty("player") or IsInRaid("player")) then
			local leader = nil
			local leader_name = nil
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) and UnitIsGroupLeader("party"..i) then
						leader = "party"..i
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) and UnitIsGroupLeader("raid"..i) then
						leader = "raid"..i
					end
				end
			end

			if leader then
			    leader_name = awm.UnitGUID(leader)
			end

			local Status = {}
			local Lowest_Health = 100
			local Lowest_Health_Party = nil
			local Daoyan = true -- 治疗祷言
			local Circle = true -- 治疗之环
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("party"..i)
						Status[i].Guid = awm.UnitGUID("party"..i)
						Status[i].Cur_Health = (awm.UnitHealth("party"..i)/awm.UnitHealthMax("party"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("party"..i)/awm.UnitPowerMax("party"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","party"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["牧师治疗之环血量"] and Status[i].Distance <= 18 then
						    Circle = false
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["牧师治疗祷言血量"] and Status[i].Distance <= 36 then
						    Daoyan = false
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("party"..i,1)
						if name and dispelType == "Magic" and Spell_Castable(rs["驱散魔法"]) and Easy_Data.Combat["牧师驱散魔法"] then
							awm.CastSpellByName(rs["驱散魔法"],"party"..i)
						end

						if name and dispelType == "Disease" and Spell_Castable(rs["驱除疾病"]) and Easy_Data.Combat["牧师驱除疾病"] then
							awm.CastSpellByName(rs["驱除疾病"],"party"..i)
						end
					end
				end

				if Circle and Easy_Data.Combat["牧师治疗之环"] then
				    awm.CastSpellByName(rs["治疗之环"])
				elseif Daoyan and Easy_Data.Combat["牧师治疗祷言"] then
				    awm.CastSpellByName(rs["治疗祷言"])
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if Spell_Castable(rs["真言术：盾"]) and health <= 30 and not CheckBuff(Member_target,rs["真言术：盾"]) then
					    awm.CastSpellByName(rs["真言术：盾"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师恢复血量"] and not CheckBuff(Member_target,rs["恢复"]) and Spell_Castable(rs["恢复"]) and Easy_Data.Combat["牧师恢复"] then
					    awm.CastSpellByName(rs["恢复"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师强效治疗术血量"] and Spell_Castable(rs["强效治疗术"]) and Easy_Data.Combat["牧师强效治疗术"] then
					    awm.CastSpellByName(rs["强效治疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师治疗术血量"] and Spell_Castable(rs["治疗术"]) and Easy_Data.Combat["牧师治疗术"] then
					    awm.CastSpellByName(rs["治疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师快速治疗血量"] and Spell_Castable(rs["快速治疗"]) and Easy_Data.Combat["牧师快速治疗"] then
					    awm.CastSpellByName(rs["快速治疗"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师次级治疗术血量"] and Spell_Castable(rs["次级治疗术"]) and Easy_Data.Combat["牧师次级治疗术"] then
					    awm.CastSpellByName(rs["次级治疗术"],Member_target)
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("raid"..i)
						Status[i].Guid = awm.UnitGUID("raid"..i)
						Status[i].Cur_Health = (awm.UnitHealth("raid"..i)/awm.UnitHealthMax("raid"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("raid"..i)/awm.UnitPowerMax("raid"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","raid"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["牧师治疗之环血量"] and Status[i].Distance <= 18 then
						    Circle = false
						end

						if Status[i].Cur_Health >= Easy_Data.Combat["牧师治疗祷言血量"] and Status[i].Distance <= 36 then
						    Daoyan = false
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("party"..i,1)
						if name and dispelType == "Magic" and Spell_Castable(rs["驱散魔法"]) and Easy_Data.Combat["牧师驱散魔法"] then
							awm.CastSpellByName(rs["驱散魔法"],"party"..i)
						end

						if name and dispelType == "Disease" and Spell_Castable(rs["驱除疾病"]) and Easy_Data.Combat["牧师驱除疾病"] then
							awm.CastSpellByName(rs["驱除疾病"],"party"..i)
						end
					end
				end


				if Circle and Easy_Data.Combat["牧师治疗之环"] then
				    awm.CastSpellByName(rs["治疗之环"])
				elseif Daoyan and Easy_Data.Combat["牧师治疗祷言"] then
				    awm.CastSpellByName(rs["治疗祷言"])
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if Spell_Castable(rs["真言术：盾"]) and health <= 30 and not CheckBuff(Member_target,rs["真言术：盾"]) then
					    awm.CastSpellByName(rs["真言术：盾"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师恢复血量"] and not CheckBuff(Member_target,rs["恢复"]) and Spell_Castable(rs["恢复"]) and Easy_Data.Combat["牧师恢复"] then
					    awm.CastSpellByName(rs["恢复"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师强效治疗术血量"] and Spell_Castable(rs["强效治疗术"]) and Easy_Data.Combat["牧师强效治疗术"] then
					    awm.CastSpellByName(rs["强效治疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师治疗术血量"] and Spell_Castable(rs["治疗术"]) and Easy_Data.Combat["牧师治疗术"] then
					    awm.CastSpellByName(rs["治疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师快速治疗血量"] and Spell_Castable(rs["快速治疗"]) and Easy_Data.Combat["牧师快速治疗"] then
					    awm.CastSpellByName(rs["快速治疗"],Member_target)
					end

					if health <= Easy_Data.Combat["牧师次级治疗术血量"] and Spell_Castable(rs["次级治疗术"]) and Easy_Data.Combat["牧师次级治疗术"] then
					    awm.CastSpellByName(rs["次级治疗术"],Member_target)
					end
				end
			end
		else
		    if distance >= 36 then
				Run(x,y,z)
				return
			end
			if Spell_Castable(rs["暗影恶魔"]) then
				awm.CastSpellByName(rs["暗影恶魔"])
			end

			if PetHasActionBar() and not UnitIsDead("pet") and not awm.UnitTarget("pet") then
				awm.PetAttack("target")
			elseif PetHasActionBar() and not UnitIsDead("pet") and awm.UnitTarget("pet") and awm.UnitTarget("pet") ~= awm.UnitTarget("player") then
				awm.PetAttack("target")
			end

			if Cur_Health < 50 and not CheckBuff("player",rs["恢复"]) and Spell_Castable(rs["恢复"]) then
				awm.CastSpellByName(rs["恢复"],"player")
			end
			if not CheckBuff("player",rs["暗影形态"]) and Spell_Castable(rs["暗影形态"]) then
				awm.CastSpellByName(rs["暗影形态"])
				return
			end
			if not CheckBuff("player",rs["心灵之火"]) and Spell_Castable(rs["心灵之火"]) then
				awm.CastSpellByName(rs["心灵之火"],"player")
				return
			end
			if not CheckBuff("player",rs["真言术：盾"]) and Spell_Castable(rs["真言术：盾"]) then
				awm.CastSpellByName(rs["真言术：盾"],"player")
				return
			end
			if Spell_Castable(rs["神圣新星"]) and #Combat_Monster >= 2 and distance < 8 then
				awm.CastSpellByName(rs["神圣新星"])
				return
			end

			if Spell_Castable(rs["暗言术：痛"]) and awm.IsSpellInRange(rs["暗言术：痛"],"target") == 1 and (not CheckDebuffByName("target",rs["暗言术：痛"])) then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["暗言术：痛"])
			end

			if Spell_Castable(rs["吸血鬼的拥抱"]) and awm.IsSpellInRange(rs["吸血鬼的拥抱"],"target") == 1 and (not CheckDebuffByName("target",rs["吸血鬼的拥抱"])) then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["吸血鬼的拥抱"])
			end

			if Spell_Castable(rs["吸血鬼之触"]) and awm.IsSpellInRange(rs["吸血鬼之触"],"target") == 1 and (not CheckDebuffByName("target",rs["吸血鬼之触"])) then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["吸血鬼之触"])
			end

			if Spell_Castable(rs["心灵震爆"]) and awm.IsSpellInRange(rs["心灵震爆"],"target") == 1 then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["心灵震爆"])
			end
			if Spell_Castable(rs["噬灵瘟疫"]) and awm.IsSpellInRange(rs["噬灵瘟疫"],"target") == 1 and (not CheckDebuffByName("target",rs["噬灵瘟疫"])) then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["噬灵瘟疫"])
			end
			if Spell_Castable(rs["精神鞭笞"]) and awm.IsSpellInRange(rs["精神鞭笞"],"target") == 1 then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["精神鞭笞"])
			end

			if Spell_Castable(rs["惩击"]) and awm.IsSpellInRange(rs["惩击"],"target") == 1 and not CheckBuff("player",rs["暗影形态"]) then
				awm.FaceCombat(target)
				awm.CastSpellByName(rs["惩击"])
			end					   
		end		
	end
	if Class == "PALADIN" then
	    if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "healer" and Is_Dungeon and (UnitInParty("player") or IsInRaid("player")) then
		    local leader = nil
			local leader_name = nil
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) and UnitIsGroupLeader("party"..i) then
						leader = "party"..i
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) and UnitIsGroupLeader("raid"..i) then
						leader = "raid"..i
					end
				end
			end

			if leader then
			    leader_name = awm.UnitGUID(leader)
			end

			local Status = {}
			local Lowest_Health = 100
			local Lowest_Health_Party = nil
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("party"..i)
						Status[i].Guid = awm.UnitGUID("party"..i)
						Status[i].Cur_Health = (awm.UnitHealth("party"..i)/awm.UnitHealthMax("party"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("party"..i)/awm.UnitPowerMax("party"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","party"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("party"..i,1)
						if name and (dispelType == "Disease" or dispelType == "Poison") and Spell_Castable(rs["纯净术"]) and Easy_Data.Combat["骑士纯净术"] then
							awm.CastSpellByName(rs["纯净术"],"party"..i)
						end

						if name and (dispelType == "Disease" or dispelType == "Magic" or dispelType == "Poison") and Spell_Castable(rs["清洁术"]) and Easy_Data.Combat["骑士清洁术"] then
							awm.CastSpellByName(rs["清洁术"],"party"..i)
						end
					end
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if Spell_Castable(rs["神启"]) and Cur_Power < 60 then
						awm.CastSpellByName(rs["神启"])
						return
					end

					if health <= Easy_Data.Combat["骑士圣疗术血量"] and Spell_Castable(rs["圣疗术"]) and Easy_Data.Combat["骑士圣疗术"] then
					    awm.CastSpellByName(rs["圣疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["骑士保护祝福血量"] and Spell_Castable(rs["保护祝福"]) and Easy_Data.Combat["骑士保护祝福"] and not CheckDebuffByName(Member_target,rs["自律"]) then
					    awm.CastSpellByName(rs["保护祝福"],Member_target)
					end

					if health <= 10 and Spell_Castable(rs["保护之手"]) and not CheckDebuffByName(Member_target,rs["自律"]) then
					    awm.CastSpellByName(rs["保护之手"],Member_target)
					end

					if health < 30 and Member_distance < 20 and Spell_Castable(rs["神圣震击"]) then
						awm.CastSpellByName(rs["神圣震击"],Member_target)
						return
					end

					if health <= Easy_Data.Combat["骑士圣光术血量"] and Spell_Castable(rs["圣光术"]) and Easy_Data.Combat["骑士圣光术"] then
					    if Spell_Castable(rs["神恩术"]) then
							awm.CastSpellByName(rs["神恩术"])
						end

					    awm.CastSpellByName(rs["圣光术"],Member_target)
					end

					if health <= Easy_Data.Combat["骑士圣光闪现血量"] and Spell_Castable(rs["圣光闪现"]) and Easy_Data.Combat["骑士圣光闪现"] then
					    if Spell_Castable(rs["神恩术"]) then
							awm.CastSpellByName(rs["神恩术"])
						end

					    awm.CastSpellByName(rs["圣光闪现"],Member_target)
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("raid"..i)
						Status[i].Guid = awm.UnitGUID("raid"..i)
						Status[i].Cur_Health = (awm.UnitHealth("raid"..i)/awm.UnitHealthMax("raid"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("raid"..i)/awm.UnitPowerMax("raid"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","raid"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("raid"..i,1)
						if name and (dispelType == "Disease" or dispelType == "Poison") and Spell_Castable(rs["纯净术"]) and Easy_Data.Combat["骑士纯净术"] then
							awm.CastSpellByName(rs["纯净术"],"raid"..i)
						end

						if name and (dispelType == "Disease" or dispelType == "Magic" or dispelType == "Poison") and Spell_Castable(rs["清洁术"]) and Easy_Data.Combat["骑士清洁术"] then
							awm.CastSpellByName(rs["清洁术"],"raid"..i)
						end
					end
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Spell_Castable(rs["神启"]) and Cur_Power < 60 then
						awm.CastSpellByName(rs["神启"])
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if health <= Easy_Data.Combat["骑士圣疗术血量"] and Spell_Castable(rs["圣疗术"]) and Easy_Data.Combat["骑士圣疗术"] then
					    awm.CastSpellByName(rs["圣疗术"],Member_target)
					end

					if health <= Easy_Data.Combat["骑士保护祝福血量"] and Spell_Castable(rs["保护祝福"]) and Easy_Data.Combat["骑士保护祝福"] and not CheckDebuffByName(Member_target,rs["自律"]) then
					    awm.CastSpellByName(rs["保护祝福"],Member_target)
					end

					if health <= 10 and Spell_Castable(rs["保护之手"]) and not CheckDebuffByName(Member_target,rs["自律"]) then
					    awm.CastSpellByName(rs["保护之手"],Member_target)
					end

					if health < 30 and Member_distance < 20 and Spell_Castable(rs["神圣震击"]) then
						awm.CastSpellByName(rs["神圣震击"],Member_target)
						return
					end

					if health <= Easy_Data.Combat["骑士圣光术血量"] and Spell_Castable(rs["圣光术"]) and Easy_Data.Combat["骑士圣光术"] then
					    if Spell_Castable(rs["神恩术"]) then
							awm.CastSpellByName(rs["神恩术"])
						end

					    awm.CastSpellByName(rs["圣光术"],Member_target)
					end

					if health <= Easy_Data.Combat["骑士圣光闪现血量"] and Spell_Castable(rs["圣光闪现"]) and Easy_Data.Combat["骑士圣光闪现"] then
					    if Spell_Castable(rs["神恩术"]) then
							awm.CastSpellByName(rs["神恩术"])
						end

					    awm.CastSpellByName(rs["圣光闪现"],Member_target)
					end
				end
			end	  
		else
		    if Cur_Health <= 15 and Spell_Castable(rs["圣疗术"]) then
			    awm.CastSpellByName(rs["圣疗术"],"player")
				return
			end

			if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "tank" and not CheckBuff("player",rs["正义之怒"]) and Spell_Castable(rs["正义之怒"]) then
			    awm.CastSpellByName(rs["正义之怒"],"player")
				return
			end

			if not CheckDebuffByName("player",rs["自律"]) and Spell_Castable(rs["复仇之怒"]) and Easy_Data.Combat["骑士复仇之怒"] then
			    awm.CastSpellByName(rs["复仇之怒"],"player")
				return
			end

			if Cur_Health <= 15 and Spell_Castable(rs["保护祝福"]) and not CheckDebuffByName("player",rs["自律"]) and (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"]) and not CheckBuff("player",rs["圣佑术"])) then
				awm.CastSpellByName(rs["保护祝福"],"player")
				return
			end

			if Cur_Health <= 15 and Spell_Castable(rs["圣盾术"]) and not CheckDebuffByName("player",rs["自律"]) and (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"]) and not CheckBuff("player",rs["圣佑术"])) then
				awm.CastSpellByName(rs["圣盾术"],"player")
				return
			end

			if Cur_Health <= 15 and Spell_Castable(rs["圣佑术"]) and not CheckDebuffByName("player",rs["自律"]) and (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"]) and not CheckBuff("player",rs["圣佑术"])) then
				awm.CastSpellByName(rs["圣佑术"],"player")
				return
			end

			if (CheckBuff("player",rs["保护祝福"]) or CheckBuff("player",rs["圣盾术"]) or CheckBuff("player",rs["圣佑术"])) and Spell_Castable(rs["圣光术"]) and Cur_Health <= 60 then
			    if Spell_Castable(rs["神恩术"]) then
				    awm.CastSpellByName(rs["神恩术"])
				end

			    awm.CastSpellByName(rs["圣光术"],"player")
				return
			end

			if (CheckBuff("player",rs["保护祝福"]) or CheckBuff("player",rs["圣盾术"]) or CheckBuff("player",rs["圣佑术"])) and Spell_Castable(rs["圣光闪现"]) and Cur_Health <= 60 then
			    if Spell_Castable(rs["神恩术"]) then
				    awm.CastSpellByName(rs["神恩术"])
				end

			    awm.CastSpellByName(rs["圣光闪现"],"player")
				return
			end

			if (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"])) and not CheckBuff("player",rs["王者祝福"]) and Spell_Castable(rs["王者祝福"]) and Easy_Data.Combat["骑士王者祝福"] then
			    awm.CastSpellByName(rs["王者祝福"],"player")
				return
			end

			if (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"])) and not CheckBuff("player",rs["智慧祝福"]) and Spell_Castable(rs["智慧祝福"]) and Easy_Data.Combat["骑士智慧祝福"] then
			    awm.CastSpellByName(rs["智慧祝福"],"player")
				return
			end

			if (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"])) and not CheckBuff("player",rs["庇护祝福"]) and Spell_Castable(rs["庇护祝福"]) and Easy_Data.Combat["骑士庇护祝福"] then
			    awm.CastSpellByName(rs["庇护祝福"],"player")
				return
			end

			if (not CheckBuff("player",rs["保护祝福"]) and not CheckBuff("player",rs["圣盾术"])) and not CheckBuff("player",rs["力量祝福"]) and Spell_Castable(rs["力量祝福"]) and Easy_Data.Combat["骑士力量祝福"] then
			    awm.CastSpellByName(rs["力量祝福"],"player")
				return
			end

			if distance < 8 and Spell_Castable(rs["奉献"]) then
				awm.CastSpellByName(rs["奉献"])
				return
			end

			if Cur_Health < 60 and Spell_Castable(rs["神圣震击"]) then
				awm.CastSpellByName(rs["神圣震击"],"player")
				return
			end


			if distance >= 4.9 then
				Run(x,y,z)
				return
			end

			if Spell_Castable(rs["神启"]) and Cur_Power < 60 then
			    awm.CastSpellByName(rs["神启"])
				return
			end

			if Spell_Castable(rs["复仇者之盾"]) then
			    awm.CastSpellByName(rs["复仇者之盾"])
				return
			end
		
			if not CheckBuff("player",rs["十字军圣印"]) and Spell_Castable(rs["十字军圣印"]) and Easy_Data.Combat["骑士十字军圣印"] then
				awm.CastSpellByName(rs["十字军圣印"])
				return
			end

			if not CheckBuff("player",rs["正义圣印"]) and Spell_Castable(rs["正义圣印"]) and Easy_Data.Combat["骑士正义圣印"] then
				awm.CastSpellByName(rs["正义圣印"])
				return
			end

			if not CheckBuff("player",rs["光明圣印"]) and Spell_Castable(rs["光明圣印"]) and Easy_Data.Combat["骑士光明圣印"] then
				awm.CastSpellByName(rs["光明圣印"])
				return
			end

			if not CheckBuff("player",rs["智慧圣印"]) and Spell_Castable(rs["智慧圣印"]) and Easy_Data.Combat["骑士智慧圣印"] then
				awm.CastSpellByName(rs["智慧圣印"])
				return
			end

			if not CheckBuff("player",rs["公正圣印"]) and Spell_Castable(rs["公正圣印"]) and Easy_Data.Combat["骑士公正圣印"] then
				awm.CastSpellByName(rs["公正圣印"])
				return
			end

			if not CheckBuff("player",rs["命令圣印"]) and Spell_Castable(rs["命令圣印"]) and Easy_Data.Combat["骑士命令圣印"] then
				awm.CastSpellByName(rs["命令圣印"])
				return
			end

			if Spell_Castable(rs["愤怒之锤"]) and Tar_Health < 20 then
				awm.CastSpellByName(rs["愤怒之锤"])
			end

			if Spell_Castable(rs["制裁之锤"]) then
				awm.CastSpellByName(rs["制裁之锤"])
			end


			if Spell_Castable(rs["审判"]) and not CheckDebuffByName("target",rs["十字军审判"]) and not CheckDebuffByName("target",rs["正义审判"]) and not CheckDebuffByName("target",rs["圣光审判"]) and not CheckDebuffByName("target",rs["智慧审判"]) and not CheckDebuffByName("target",rs["公正审判"]) and not CheckDebuffByName("target",rs["命令审判"]) then
				awm.CastSpellByName(rs["审判"])
			end

			if Spell_Castable(rs["十字军打击"]) then
			    awm.CastSpellByName(rs["十字军打击"])
				return
			end

			if GetUnitSpeed("player") > 0 then
				if distance <= 2 and GetTime() - Combat.Time > 1 then
					Combat.Time = GetTime()
					Try_Stop()
				end
				awm.InteractUnit("target")
			end
		end
	end
	if Class == "HUNTER" then
	    local Shoot_Distance = 8
		if GetExpansionLevel() == 1 then
		    Shoot_Distance = 5
		end


		if PetHasActionBar() and not awm.UnitIsDead("pet") and Spell_Castable(rs["治疗宠物"]) and not CheckBuff("pet",rs["治疗宠物"]) then
		    local Pet_Health = (awm.UnitHealth("pet")/awm.UnitHealthMax("pet")) * 100
			if Pet_Health <= Easy_Data.Combat["猎人治疗宠物血量"] then
			    awm.CastSpellByName(rs["治疗宠物"],"pet")
				return
			end
		end

		if Cur_Health <= Easy_Data.Combat["猎人假死血量"] and Spell_Castable(rs["假死"]) then
		    awm.CastSpellByName(rs["假死"],"player")
			return
		end

		if PetHasActionBar() and not awm.UnitIsDead("pet") and awm.UnitTarget("pet") ~= awm.UnitGUID("target") then
		    awm.PetAttack("target")
		end

		if PetHasActionBar() and not awm.UnitIsDead("pet") and Spell_Castable(rs["狂野怒火"]) and Easy_Data.Combat["猎人狂野怒火"] then
		    awm.CastSpellByName(rs["狂野怒火"])
			return
		end

		if PetHasActionBar() and not awm.UnitIsDead("pet") and Spell_Castable(rs["胁迫"]) and Easy_Data.Combat["猎人胁迫"] then
		    awm.CastSpellByName(rs["胁迫"])
			return
		end

		-- 等宠物先手
		if PetHasActionBar() and not awm.UnitIsDead("pet") and not awm.UnitAffectingCombat("player") and not awm.UnitAffectingCombat("pet") and distance >= 35 then
		    Try_Stop()
			return
		end

		if Combat.Forst then
		    MoveBackwardStart()
			return
		end

		if distance <= 34 and Spell_Castable(rs["乱射"]) and #Combat_Monster >= 2 then
		    awm.CastSpellByName(rs["乱射"])
			return
		end

		if distance < 10 and Spell_Castable(rs["冰冻陷阱"]) and GetTime() - Combat.Hunter_Trap > 47 and Easy_Data.Combat["猎人冰冻陷阱"] then
		    awm.CastSpellByName(rs["冰冻陷阱"])
			Combat.Hunter_Trap = GetTime()
			Combat.Forst = true
			C_Timer.After(1.7,function() Combat.Forst = false Try_Stop() end)
			return
		end

		if Spell_Castable(rs["爆炸陷阱"]) and GetTime() - Combat.Hunter_Trap > 47 and Easy_Data.Combat["猎人爆炸陷阱"] then
		    Combat.Hunter_Trap = GetTime()
		    awm.CastSpellByName(rs["爆炸陷阱"])
			return
		end

		if Spell_Castable(rs["献祭陷阱"]) and GetTime() - Combat.Hunter_Trap > 47 and Easy_Data.Combat["猎人献祭陷阱"] then
		    Combat.Hunter_Trap = GetTime()
		    awm.CastSpellByName(rs["献祭陷阱"])
			return
		end

		if distance > Shoot_Distance and awm.IsSpellInRange(rs["自动射击"],"target") == 1 then
		    awm.FaceCombat("target")
			if GetTime() - Combat.Time > 1 then
			    Try_Stop()
				Combat.Time = GetTime()
			end
			if awm.IsSpellInRange(rs["猎人印记"],"target") == 1 and Spell_Castable(rs["猎人印记"]) and not CheckDebuffByName("target",rs["猎人印记"]) then
				awm.CastSpellByName(rs["猎人印记"])
				return
			end
			if Spell_Castable(rs["急速射击"]) and not CheckBuff("player",rs["急速射击"]) and IsAutoRepeatSpell(rs["自动射击"]) then
				awm.CastSpellByName(rs["急速射击"],"player")
				return
			end

			if awm.IsSpellInRange(rs["自动射击"],"target") == 1 and not IsAutoRepeatSpell(rs["自动射击"]) then
				awm.CastSpellByName(rs["自动射击"])
				return
			end
			if Spell_Castable(rs["奥术射击"]) and awm.IsSpellInRange(rs["奥术射击"],"target") == 1 and Easy_Data.Combat["猎人奥术射击"] then
			    awm.CastSpellByName(rs["奥术射击"])
				return
			end
			if Spell_Castable(rs["震荡射击"]) and awm.IsSpellInRange(rs["震荡射击"],"target") == 1 and Easy_Data.Combat["猎人震荡射击"] then
			    awm.CastSpellByName(rs["震荡射击"])
				return
			end
			if Spell_Castable(rs["多重射击"]) and awm.IsSpellInRange(rs["多重射击"],"target") == 1 and #Combat_Monster >= 2 and Easy_Data.Combat["猎人多重射击"] then
			    awm.CastSpellByName(rs["多重射击"])
				return
			end

			if awm.IsSpellInRange(rs["蝰蛇钉刺"],"target") == 1 and Spell_Castable(rs["蝰蛇钉刺"]) and not CheckDebuffByName("target",rs["蝰蛇钉刺"]) and not CheckDebuffByName("target",rs["毒蛇钉刺"]) and UnitPower("target",0) > Easy_Data.Combat["猎人蝰蛇钉刺蓝量"] and Easy_Data.Combat["猎人蝰蛇钉刺"] then
				awm.CastSpellByName("蝰蛇钉刺")
				return
			end

			if awm.IsSpellInRange(rs["毒蛇钉刺"],"target") == 1 and Spell_Castable(rs["毒蛇钉刺"]) and not CheckDebuffByName("target",rs["毒蛇钉刺"]) and not CheckDebuffByName("target",rs["蝰蛇钉刺"]) and Easy_Data.Combat["猎人毒蛇钉刺"] then
				awm.CastSpellByName("毒蛇钉刺")
				return
			end
			if awm.IsSpellInRange(rs["瞄准射击"],"target") == 1 and Spell_Castable(rs["瞄准射击"]) then
				awm.CastSpellByName("瞄准射击","target")
				return
			end
		end

		if distance <= Shoot_Distance then
		    local Unit_Tar = awm.UnitTarget("target")
			if Combat.Forst then
			    return
			end

			if not Unit_Tar or Unit_Tar ~= Player_GUID then
			    Combat.Forst = true
				C_Timer.After(1.7,function() Combat.Forst = false Try_Stop() end)
				return
			end
		    if distance >= 4 then
				Run(x,y,z)
				return
			end

			if Spell_Castable(rs["猫鼬撕咬"]) and distance <= 5 then
				awm.CastSpellByName(rs["猫鼬撕咬"],"target")
				return
			end
			if Spell_Castable(rs["猛禽一击"]) and distance <= 5 then
				awm.CastSpellByName(rs["猛禽一击"])
				awm.InteractUnit(target)
				return
			else
				if GetUnitSpeed("player") > 0 then
					if distance <= 2 and GetTime() - Combat.Time > 1 then
						Try_Stop()
						Combat.Time = GetTime()
					end
					awm.InteractUnit("target")
				end
			end
		end
	end
	if Class == "DRUID" then
	    if Easy_Data["战斗职能"] and Easy_Data["战斗职能"] == "healer" and Is_Dungeon and (UnitInParty("player") or IsInRaid("player")) then
			local leader = nil
			local leader_name = nil
			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) and UnitIsGroupLeader("party"..i) then
						leader = "party"..i
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) and UnitIsGroupLeader("raid"..i) then
						leader = "raid"..i
					end
				end
			end

			if leader then
			    leader_name = awm.UnitGUID(leader)
			end

			local Status = {}
			local Lowest_Health = 100
			local Lowest_Health_Party = nil

			local Count = 0

			if Cur_Power < 50 and Spell_Castable(rs["激活"]) then
			    awm.CastSpellByName(rs["激活"],"player")
			end

			if not CheckBuff("player",rs["生命之树"]) and Spell_Castable(rs["生命之树"]) then
			    awm.CastSpellByName(rs["生命之树"],"player")
			end

			if UnitInParty("player") then
				for i = 1,5 do 
					if UnitGUID("party"..i) ~= nil and awm.ObjectExists("party"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("party"..i)
						Status[i].Guid = awm.UnitGUID("party"..i)
						Status[i].Cur_Health = (awm.UnitHealth("party"..i)/awm.UnitHealthMax("party"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("party"..i)/awm.UnitPowerMax("party"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","party"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("party"..i,1)
						if name and dispelType == "Curse" and Spell_Castable(rs["解除诅咒"]) and Easy_Data.Combat["小德解除诅咒"] then
							awm.CastSpellByName(rs["解除诅咒"],"party"..i)
						end

						if name and dispelType == "Poison" and Spell_Castable(rs["驱毒术"]) and Easy_Data.Combat["小德驱毒术"] then
							awm.CastSpellByName(rs["驱毒术"],"party"..i)
						end

						if CheckBuff("party"..i,rs["回春术"]) or CheckBuff("party"..i,rs["愈合"]) and Spell_Castable(rs["迅捷治愈"]) then
						    awm.CastSpellByName(rs["迅捷治愈"])
						end

						if Easy_Data.Combat["小德宁静"] and Spell_Castable(rs["宁静"]) and Status[i].Cur_Health < Easy_Data.Combat["小德宁静血量"] then
						    Count = Count + 1
						end
					end
				end

				if Count >= 2 and Easy_Data.Combat["小德宁静"] and Spell_Castable(rs["宁静"]) then
				    awm.CastSpellByName(rs["宁静"])
					return
				end

				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if health <= Easy_Data.Combat["小德回春术血量"] and not CheckBuff(Member_target,rs["回春术"]) and Spell_Castable(rs["回春术"]) and Easy_Data.Combat["小德回春术"] then
					    awm.CastSpellByName(rs["回春术"],Member_target)
					end

					if health <= Easy_Data.Combat["小德愈合血量"] and not CheckBuff(Member_target,rs["愈合"]) and Spell_Castable(rs["愈合"]) and Easy_Data.Combat["小德愈合"] then
					    awm.CastSpellByName(rs["愈合"],Member_target)
					end

					if health <= Easy_Data.Combat["小德治疗之触血量"] and Spell_Castable(rs["治疗之触"]) and Easy_Data.Combat["小德治疗之触"] then
					    awm.CastSpellByName(rs["治疗之触"],Member_target)
					end
				end
			elseif IsInRaid("player") then
				for i = 1,40 do 
					if UnitGUID("raid"..i) ~= nil and awm.ObjectExists("raid"..i) then
						Status[i] = {}
						Status[i].Name = awm.UnitFullName("raid"..i)
						Status[i].Guid = awm.UnitGUID("raid"..i)
						Status[i].Cur_Health = (awm.UnitHealth("raid"..i)/awm.UnitHealthMax("raid"..i)) * 100
						Status[i].Cur_Power = (awm.UnitPower("raid"..i)/awm.UnitPowerMax("raid"..i)) * 100
						Status[i].Distance = awm.GetDistanceBetweenObjects("player","raid"..i)

						if Status[i].Cur_Health < Lowest_Health then
						    Lowest_Health = Status[i].Cur_Health
						    Lowest_Health_Party = i
						end

						local name, icon, count, dispelType, duration, expirationTime = awm.UnitDebuff("raid"..i,1)
						if name and dispelType == "Curse" and Spell_Castable(rs["解除诅咒"]) and Easy_Data.Combat["小德解除诅咒"] then
							awm.CastSpellByName(rs["解除诅咒"],"raid"..i)
						end

						if name and dispelType == "Poison" and Spell_Castable(rs["驱毒术"]) and Easy_Data.Combat["小德驱毒术"] then
							awm.CastSpellByName(rs["驱毒术"],"raid"..i)
						end

						if CheckBuff("raid"..i,rs["回春术"]) or CheckBuff("raid"..i,rs["愈合"]) and Spell_Castable(rs["迅捷治愈"]) then
						    awm.CastSpellByName(rs["迅捷治愈"])
						end

						if Easy_Data.Combat["小德宁静"] and Spell_Castable(rs["宁静"]) and Status[i].Cur_Health < Easy_Data.Combat["小德宁静血量"] then
						    Count = Count + 1
						end
					end
				end


				if Count >= 2 and Easy_Data.Combat["小德宁静"] and Spell_Castable(rs["宁静"]) then
				    awm.CastSpellByName(rs["宁静"])
					return
				end


				if Lowest_Health_Party then
				    local Member_target = Status[Lowest_Health_Party].Guid
					local health = Status[Lowest_Health_Party].Cur_Health
					local Member_distance = Status[Lowest_Health_Party].Distance

					local Memx,Memy,Memz = awm.ObjectPosition(Member_target)

					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,Memx,Memy,Memz+2.25,flags)
					if hit == 1 or In_Sight then
						Run(x,y,z)
						return
					end

					if Member_distance >= 39 then
					    Run(Memx,Memy,Memz)
					    return
					end

					if health <= Easy_Data.Combat["小德回春术血量"] and not CheckBuff(Member_target,rs["回春术"]) and Spell_Castable(rs["回春术"]) and Easy_Data.Combat["小德回春术"] then
					    awm.CastSpellByName(rs["回春术"],Member_target)
					end

					if health <= Easy_Data.Combat["小德愈合血量"] and not CheckBuff(Member_target,rs["愈合"]) and Spell_Castable(rs["愈合"]) and Easy_Data.Combat["小德愈合"] then
					    awm.CastSpellByName(rs["愈合"],Member_target)
					end

					if health <= Easy_Data.Combat["小德治疗之触血量"] and Spell_Castable(rs["治疗之触"]) and Easy_Data.Combat["小德治疗之触"] then
					    awm.CastSpellByName(rs["治疗之触"],Member_target)
					end
				end
			end
		else
		    if Cur_Power < 50 and Spell_Castable(rs["激活"]) then
			    awm.CastSpellByName(rs["激活"],"player")
			end

			if Spell_Castable(rs["树皮术"]) and Easy_Data.Combat["小德树皮术"] and not CheckBuff("player",rs["树皮术"]) and Cur_Health < Easy_Data.Combat["小德树皮术血量"] then
				awm.CastSpellByName(rs["树皮术"],"player")
				return
			end

			if not CheckBuff("player",rs["枭兽形态"]) and Spell_Castable(rs["枭兽形态"]) and Easy_Data.Combat["小德枭兽形态"] then
				awm.CastSpellByName(rs["枭兽形态"],"player")
				return
			end

			if not CheckBuff("player",rs["熊形态"]) and Spell_Castable(rs["熊形态"]) and Easy_Data.Combat["小德熊形态"] then
				awm.CastSpellByName(rs["熊形态"],"player")
				return
			end

			if not CheckBuff("player",rs["巨熊形态"]) and Spell_Castable(rs["巨熊形态"]) and Easy_Data.Combat["小德巨熊形态"] then
				awm.CastSpellByName(rs["巨熊形态"],"player")
				return
			end

			if not CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["猎豹形态"]) and Easy_Data.Combat["小德猎豹形态"] then
				awm.CastSpellByName(rs["猎豹形态"],"player")
				return
			end

			if not CheckBuff("player",rs["回春术"]) and Spell_Castable(rs["回春术"]) and Easy_Data.Combat["小德回春术"] and Cur_Health <= Easy_Data.Combat["小德回春术血量"] then
				awm.CastSpellByName(rs["回春术"],"player")
				return
			end

			if distance > 35 and not CheckBuff("player",rs["熊形态"]) and not CheckBuff("player",rs["巨熊形态"]) and not CheckBuff("player",rs["猎豹形态"]) then
			    Run(x,y,z)
			elseif distance > 5 and (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"]) or CheckBuff("player",rs["猎豹形态"])) then
			    if distance > 9 and distance < 24 and Spell_Castable(rs["野性冲锋"]) then
				    awm.CastSpellByName(rs["野性冲锋"],"target")
				end

			    Run(x,y,z)
			end


			awm.FaceCombat(target)

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"]) or CheckBuff("player",rs["猎豹形态"])) and Spell_Castable(rs["精灵之火（野性）"]) and not CheckDebuffByName("target",rs["精灵之火（野性）"]) then
			    awm.CastSpellByName(rs["精灵之火（野性）"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["挫志咆哮"]) and not CheckDebuffByName("target",rs["挫志咆哮"]) then
			    awm.CastSpellByName(rs["挫志咆哮"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["激怒"]) and Cur_Health > 60 then
			    awm.CastSpellByName(rs["激怒"])
				return
			end


			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["狂暴回复"]) and Cur_Health < 40 then
			    awm.CastSpellByName(rs["狂暴回复"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["裂伤（熊）"]) and not CheckDebuffByName("target",rs["裂伤（熊）"]) then
			    awm.CastSpellByName(rs["裂伤（熊）"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["猛击"]) then
			    awm.CastSpellByName(rs["猛击"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["横扫"]) and #Combat_Monster >= 2 then
			    awm.CastSpellByName(rs["横扫"])
				return
			end

			if (CheckBuff("player",rs["熊形态"]) or CheckBuff("player",rs["巨熊形态"])) and Spell_Castable(rs["重殴"]) then
			    awm.CastSpellByName(rs["重殴"])
				return
			end

			if CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["斜掠"]) and not CheckDebuffByName("target",rs["斜掠"]) then
			    awm.CastSpellByName(rs["斜掠"])
				return
			end

			if CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["裂伤（豹）"]) and not CheckDebuffByName("target",rs["裂伤（豹）"]) then
			    awm.CastSpellByName(rs["裂伤（豹）"])
				return
			end

			if CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["凶猛撕咬"]) and not CheckDebuffByName("target",rs["凶猛撕咬"]) and Easy_Data.Combat["小德凶猛撕咬"] and GetComboPoints("player", "target") >= Easy_Data.Combat["小德终结点数"] then
			    awm.CastSpellByName(rs["凶猛撕咬"])
				return
			end

			if CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["割裂"]) and not CheckDebuffByName("target",rs["割裂"]) and Easy_Data.Combat["小德割裂"] and GetComboPoints("player", "target") >= Easy_Data.Combat["小德终结点数"] then
			    awm.CastSpellByName(rs["重殴"])
				return
			end

			if CheckBuff("player",rs["猎豹形态"]) and Spell_Castable(rs["猛虎之怒"]) and not CheckBuff("player",rs["猛虎之怒"]) then
			    awm.CastSpellByName(rs["猛虎之怒"])
				return
			end


			if Spell_Castable(rs["月火术"]) and awm.IsSpellInRange(rs["月火术"],"target") == 1 and Easy_Data.Combat["小德月火术"] and not CheckDebuffByName("target",rs["月火术"]) then
				awm.CastSpellByName(rs["月火术"])
				return
			end

			if Spell_Castable(rs["愤怒"]) and awm.IsSpellInRange(rs["愤怒"],"target") == 1 and Easy_Data.Combat["小德愤怒"] then
				awm.CastSpellByName(rs["愤怒"])
				return
			end

			if Spell_Castable(rs["星火术"]) and awm.IsSpellInRange(rs["星火术"],"target") == 1 and Easy_Data.Combat["小德星火术"] then
				awm.CastSpellByName(rs["星火术"])
				return
			end


			if Spell_Castable(rs["飓风"]) and distance < 36 and Easy_Data.Combat["小德飓风"] then
				awm.CastSpellByName(rs["飓风"])
				return
			end


			if GetTime() - Combat.Time > 1 then
			    Combat.Time = GetTime()
				if distance <= 2 and GetUnitSpeed("player") > 0 then
					Try_Stop()
					return
				else
				    awm.InteractUnit("target")
					return
				end
			end
		end
	end
end


function Skill_Level(name) --判断副职业等级
    for i = 1, GetNumSkillLines() do 
		local skillName, _, _, skillRank, _, _,skillMaxRank, _, _, _, _, _,_ = GetSkillLineInfo(i)
		if skillName == name then
			return skillRank,skillMaxRank
		end
	end
	return 0,0
end

function Skin_Find()
    local Find_List = {}
	for i = 1,#Mobs_ID do
	    Find_Object(Mobs_ID[i],Find_List)
	end
	return Find_List
end
function Find_Corpse()
    local body = {}
	local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)

		if awm.ObjectIsPlayer(ThisUnit)
		    and Easy_Data["玩家检测"]
		    and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") 
			and tonumber(Easy_Data["玩家检测距离"])
			and awm.GetDistanceBetweenObjects("player",ThisUnit) <= tonumber(Easy_Data["玩家检测距离"]) then
			    return {}
		end

		if awm.IsGuid(ThisUnit) then
		    local guid = awm.UnitGUID(ThisUnit)
			local Creaturetype = awm.UnitCreatureType(ThisUnit)
			if awm.UnitIsDead(ThisUnit)
			and awm.ObjectIsUnit(ThisUnit) then
			    if (awm.UnitIsLootable(guid) and Easy_Data["需要拾取"]) then
					body[#body + 1] = ThisUnit
                elseif (awm.UnitIsSkinnable(ThisUnit) and Easy_Data["需要剥皮"])
				and Skill_Level(rs["剥皮"]) > 0
				and GetItemCount(Check_Client("剥皮小刀","Skinning Knife")) > 0
				and (Creaturetype == Check_Client("野兽","Beast") or Creaturetype == Check_Client("龙类","Dragonkin") or Creaturetype == Check_Client("未指定","Not specified") or Creaturetype == Check_Client("未分类","Not specified")) then
				    body[#body + 1] = ThisUnit
				elseif Easy_Data["采集尸体"] and awm.CorpseCanLoot(ThisUnit) and (Creaturetype ~= Check_Client("野兽","Beast") and Creaturetype ~= Check_Client("龙类","Dragonkin")) then
				    body[#body + 1] = ThisUnit
				end
			end
		end
	end
	return body
end
function Find_Object(id,table)
	local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)

		if awm.ObjectIsPlayer(ThisUnit)
		    and Easy_Data["玩家检测"]
		    and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") 
			and tonumber(Easy_Data["玩家检测距离"])
			and awm.GetDistanceBetweenObjects("player",ThisUnit) <= tonumber(Easy_Data["玩家检测距离"]) then
			    return {}
		end

		if awm.IsGuid(ThisUnit) then
			local guid = awm.ObjectId(ThisUnit)
			local name = awm.UnitFullName(ThisUnit)
			if awm.ObjectExists(ThisUnit)
			and ((Easy_Data["只击杀无目标怪物"] and not awm.UnitIsTapped(ThisUnit)) or not Easy_Data["只击杀无目标怪物"])
			and ((tonumber(id) ~= nil and guid == id) or name == id) then
				table[#table + 1] = ThisUnit
			end
		end
	end
end
function Vaild_Black(Object)
	for i = 0,#Black_List,1 do
	    if Black_List[i] == awm.UnitGUID(Object) then
		    return true
		end
	end
	return false
end
function Vaild_Looted(Object)
    for i = 0,#Monster_Has_Killed,1 do
	    if Monster_Has_Killed[i] == awm.UnitGUID(Object) then
		    return true
		end
	end
	return false
end

function Detect_Item(d_item,Far_Distance)
    local x,y,z = awm.ObjectPosition(d_item)
	local Px,Py,Pz = awm.ObjectPosition("player")
	local obj_name = awm.UnitFullName(d_item)
	local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)

	if distance > Far_Distance then
		return false
	end
    if Vaild_Black(d_item) then
		return false
	end
	if Vaild_Looted(d_item) then
		return false
	end
	return true
end


function Skin_Process()
	local Current_Map = C_Map.GetBestMapForUnit("player")
	local Px,Py,Pz = awm.ObjectPosition("player")
	if Grind.Step == 1 then -- 巡逻扫描
	    Note_Head = Check_UI("巡逻扫描","Scaning Objects")

		if not IsMounted() and not UnitAffectingCombat("player") then

			if GetItemCount(Check_Client("空气微粒","Mote of Air")) > 10 then
				awm.UseItemByName(Check_Client("空气微粒","Mote of Air"))
				return
			end

			if GetItemCount(Check_Client("火焰微粒","Mote of Fire")) > 10 then
				awm.UseItemByName(Check_Client("火焰微粒","Mote of Fire"))
				return
			end

			if GetItemCount(Check_Client("土之微粒","Mote of Earth")) > 10 then
				awm.UseItemByName(Check_Client("土之微粒","Mote of Earth"))
				return
			end

			if GetItemCount(Check_Client("生命微粒","Mote of Life")) > 10 then
				awm.UseItemByName(Check_Client("生命微粒","Mote of Life"))
				return
			end

			if GetItemCount(Check_Client("法力微粒","Mote of Mana")) > 10 then
				awm.UseItemByName(Check_Client("法力微粒","Mote of Mana"))
				return
			end

			if GetItemCount(Check_Client("暗影微粒","Mote of Shadow")) > 10 then
				awm.UseItemByName(Check_Client("暗影微粒","Mote of Shadow"))
				return
			end

			if GetItemCount(Check_Client("水之微粒","Mote of Water")) > 10 then
				awm.UseItemByName(Check_Client("水之微粒","Mote of Water"))
				return
			end
		end

		Gather_Timer = false
		Skin_Timer = false
		Interact_Step = false
		Recheck_Target = false
		Combating = false
		Stop_Yet = false
		Target_Info.Item = nil
		Target_Info.GUID = nil

		if Mobs_Coord == nil or #Mobs_Coord == 0 then
		    Note_Set(Check_UI("先填入自定义点位","Please first complete the custom nodes list"))
		    return
		end

		if Grind.Move > #Mobs_Coord then
		    Grind.Move = 1
		end
		local Coord = Mobs_Coord[Grind.Move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Gather_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
			Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
			Sever_Run(Current_Map,Mobs_MapID,x,y,z)
			return
		end

		if tonumber(Easy_Data["扫描间隔"]) == nil then
		    Easy_Data["扫描间隔"] = 2
		end

		if GetTime() - Scan_Time > Easy_Data["扫描间隔"] then
			Scan_Time = GetTime()

			local body = Find_Corpse()
			local Find_List = Skin_Find()

			Note_Set(Check_UI("可击杀拾取"..#Find_List.."/"..#body.."个, 地点 = "..Grind.Move,"Mobs around / dead - "..#Find_List.."/"..#body..", Nodes = "..Grind.Move))

			if #body > 0 then
				local Far_Distance = Easy_Data["击杀扫描范围"]
				for i = 1,#body do
					local findx,findy,findz = awm.ObjectPosition(body[i])
					local obj_name = awm.UnitFullName(body[i])
					local distance2 = awm.GetDistanceBetweenPositions(findx,findy,findz,Px,Py,Pz)
					if Detect_Item(body[i],Far_Distance) then
						
						Far_Distance = awm.GetDistanceBetweenObjects("player",body[i])
						Target_Info.Item = body[i]
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
						Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
					end
				end
				if Target_Info.Item ~= nil then
				    textout(Check_UI("进入拾取阶段","Start Looting Process"))
					Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
					Grind.Step = 2
					return
				end
			end

			if #Find_List > 0 then
				local Far_Distance = Easy_Data["击杀扫描范围"]
				for i = 1,#Find_List do
					local findx,findy,findz = awm.ObjectPosition(Find_List[i])
					local obj_name = awm.UnitFullName(Find_List[i])
					local distance2 = awm.GetDistanceBetweenPositions(findx,findy,findz,Px,Py,Pz)
					if Detect_Item(Find_List[i],Far_Distance) then
						Far_Distance = awm.GetDistanceBetweenObjects("player",Find_List[i])
						Target_Info.Item = Find_List[i]
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
						Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
					end
				end
				if Target_Info.Item ~= nil then
				    textout(Check_UI("进入击杀阶段","Start Killing Process"))
					Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
					Grind.Step = 2
					return
				end
			end
		end

		local Check_Distance = 1.7
		if IsFlying("player") then
		    Check_Distance = 9
		end

		if Gather_Distance > Check_Distance then
		    if UnitAffectingCombat("player") and Gather_Distance < Easy_Data["击杀扫描范围"] then
			    local Combat_Monster = Combat_Scan()

				local Far_Distance = Easy_Data["击杀扫描范围"]

				if #Combat_Monster > 0 then
					for i = 1,#Combat_Monster do
						local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
						if distance < Easy_Data["击杀扫描范围"] and distance < Far_Distance then
							Far_Distance = distance
							Target_Info.Item = Combat_Monster[i]
							Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
							Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
						end
					end
					if Target_Info.Item ~= nil then
						textout(Check_UI("进入击杀阶段","Start Killing Process"))
						Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
						Grind.Step = 2
						return
					end
				end
			end

			local Continent = GetInstanceInfo()
			local map_id = select(8, GetInstanceInfo())	
		    if Easy_Data["飞行采集"] and Continent == Check_Client("外域","Outland") and not IsFlying("player") then
				if IsMounted() or CheckBuff("player",rs["旅行形态"]) then
					if not Has_Fly then
						Has_Fly = true
						C_Timer.After(5,function() Has_Fly = false end)
						awm.JumpOrAscendStart()
						textout("开始飞行")
					end
					return
				end
				Run(x,y,z)
			else
			    if Has_Fly and IsFlying("player") then
				    awm.AscendStop()
				end

				Run(x,y,z)
			end
	    else
		    Grind.Move = Grind.Move + 1
		end
	end
	if Grind.Step == 2 then -- 采集
	    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz)

		Note_Head = Check_UI("击杀流程","Killing Process")

		local Target_Recheck = awm.UnitGUID(Target_Info.Item)
		if Target_Recheck == nil and distance < 80 then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Mount_useble = GetTime()
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标不存在, 返回继续巡逻","Target not exist, back to mobs find process"))
			return
		elseif Target_Recheck ~= Target_Info.GUID then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Mount_useble = GetTime()
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标错误, 返回继续巡逻","Target Errors, back to mobs find process"))
			return
		end
		if distance < 40 then
			if Mount_useble < GetTime() then
				Mount_useble = GetTime() + 30
			end
		elseif distance > 1000 then
		    Black_List[#Black_List + 1] = Target_Info.GUID
			Coordinates_Get = false
			Mount_useble = GetTime()	
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil

			Grind.Step = 1

			textout(Check_UI("与人物距离超过1000码, 判断为虚假物品","Distance over 1000 yard, bilzzard fooling us"))
			return
		end

		if (Target_Info.Item == nil or not awm.ObjectExists(Target_Info.Item)) and distance < 80 then
		    Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_Looted(Target_Info.Item) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Item = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标消失","Target do not exist"))
			return
		elseif (not awm.UnitIsLootable(Target_Info.Item) or not Easy_Data["需要拾取"])
		and (not awm.UnitIsSkinnable(Target_Info.Item) or not Easy_Data["需要剥皮"] or GetItemCount(Check_Client("剥皮小刀","Skinning Knife")) == 0 or (awm.UnitLevel(Target_Info.Item) * 5 > Skill_Level(rs["剥皮"]) and Skill_Level(rs["剥皮"]) > 100))
		and (not Easy_Data["采集尸体"] or (Easy_Data["采集尸体"] and not awm.CorpseCanLoot(Target_Info.Item)))
		and awm.UnitIsDead(Target_Info.Item)
		and (GetExpansionLevel() ~= 0 or not Easy_Data["需要剥皮"]) then
		    if not Loot_Timer then
				Loot_Timer = true
				Loot_Time = GetTime()
			end
			if Loot_Timer then
				local time = GetTime() - Loot_Time
				if time <= 2 then
					return
				end
			end
			Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_Looted(Target_Info.Item) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Item = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标无法拾取","Mobs body cannot be looted"))
			return
		end

		if awm.UnitAffectingCombat("player") then
			local Combat_Monster = Combat_Scan()
			if #Combat_Monster > 0 then
				if #Combat_Monster > 1 then
					Multi_Target = true
				else
					Multi_Target = false
				end
				Note_Set(Check_UI("反击! 怪物"..#Combat_Monster.."只, 设定距离"..Easy_Data["击杀扫描范围"].."码","Fight Back! Mobs around amount "..#Combat_Monster..", Set distance "..Easy_Data["击杀扫描范围"].." yard"))
				local Far_Distance = 500
				if Combat_Target ~= nil then
					if not awm.ObjectExists(Combat_Target) then
						Combat_Target = nil
					elseif awm.ObjectExists(Combat_Target) and (awm.UnitIsDead(Combat_Target) or not awm.UnitCanAttack("player",Combat_Target) or awm.GetDistanceBetweenObjects("player",Combat_Target) >= Easy_Data["击杀扫描范围"] or not awm.UnitAffectingCombat(Combat_Target)) then
						Combat_Target = nil
					else
						Scan_Combat = true
						CombatSystem(Combat_Target)
						return
					end
				end
				for i = 1,#Combat_Monster do
					local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
					if distance < Easy_Data["击杀扫描范围"] and distance < Far_Distance then
						Far_Distance = distance
						Combat_Target = Combat_Monster[i]
					end
				end
				if Combat_Target ~= nil then
					Combating = true

					Skin_Timer = false
					Loot_Timer = false

					CombatSystem(Combat_Target)
					
					return
				else
					Combating = false
				end
			end
		end

		if awm.ObjectExists(Target_Info.Item) then
		    Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
			awm.TargetUnit(Target_Info.Item)
			if Easy_Data["只击杀无目标怪物"] and awm.UnitIsTapped(Target_Info.Item) and not awm.UnitIsDead(Target_Info.Item) then
			    Coordinates_Get = false
				Mount_useble = GetTime()
				Tried_Mount = GetTime()

				Target_Info.Item = nil
				Target_Info.GUID = nil
				Loot_Timer = false
				Grind.Step = 1
				textout(Check_UI("目标已被其他玩家占领","Mobs combats with other players"))
				return
			end
		else
		    Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
		    return
		end

		if not Gather_Timer then
			Gather_Timer = true
			Gather_Time = GetTime()
		end
		if Gather_Timer then
		    local time = GetTime() - Gather_Time
			if time >= Easy_Data["极限击杀时间"] then
				Black_List[#Black_List + 1] = Target_Info.GUID
				Coordinates_Get = false
				Mount_useble = GetTime()
				Target_Info.Item = nil
				Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
				Target_Info.GUID = nil
				Grind.Step = 1
				textout(Check_UI("击杀超时, 加入黑名单","Over max Killing time, black it"))
				return
			end
		end
		local Real_distance = awm.GetDistanceBetweenObjects(Target_Info.Item,"player")
		if awm.UnitIsDead(Target_Info.Item) then
		    if Real_distance > 4 then
			    Loot_Timer = false
				Skin_Timer = false
				Note_Set(Check_UI("拾取物品中... < 距离 > = "..math.floor(Real_distance),"Looting items... < Distance > = "..math.floor(Real_distance)))
				Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
				Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
			    if not Skin_Timer then
				    Skin_Timer = true
					Skin_Time = GetTime()
				else
				    local time = GetTime() - Skin_Time
					if time >= 10 and Easy_Data["需要剥皮"] and (awm.UnitIsSkinnable(Target_Info.Item) or GetExpansionLevel() == 0) then
					    Coordinates_Get = false
						Mount_useble = GetTime()
						Tried_Mount = GetTime()

						if not Vaild_Looted(Target_Info.Item) then
							Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
						end

						Target_Info.Item = nil
						Target_Info.GUID = nil
						Loot_Timer = false
						Grind.Step = 1
						textout(Check_UI("剥皮采集超时","Skin / gather corpse over time"))
						return
					elseif time >= 10 and Easy_Data["需要拾取"] and awm.UnitIsLootable(Target_Info.Item) then
					    Coordinates_Get = false
						Mount_useble = GetTime()
						Tried_Mount = GetTime()

						if not Vaild_Looted(Target_Info.Item) then
							Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
						end

						Target_Info.Item = nil
						Target_Info.GUID = nil
						Loot_Timer = false
						Grind.Step = 1
						textout(Check_UI("拾取超时","Loot over time"))
						return
					end
				end

			    Note_Set(Check_UI("拾取物品中...","Looting items..."))
			    Loot_Timer = false
				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.5,function() if Interact_Step then Interact_Step = false end end)
				    awm.InteractUnit(Target_Info.Item)
				else
				    if LootFrame:IsVisible() then
					    if GetNumLootItems() == 0 then
						    CloseLoot()
							LootFrame_Close()
							return
						end
						for i = 1,GetNumLootItems() do
							LootSlot(i)
						end
					end
				end
			end
		else
		    local name = awm.UnitFullName(Target_Info.Item)

			if IsFlying() and not UnitAffectingCombat("player") and awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Pz) < 45 then
			    local flags = bit.bor(0x10, 0x100, 0x1)
				local hit = awm.TraceLine(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz,flags)
				if hit == 0 then
					awm.Interval_Move(Target_Info.objx,Target_Info.objy,Target_Info.objz)
					return
				end
			end

			CombatSystem(Target_Info.Item)
		end
	end
end

function Replenishment_Vars()
    local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()

    if Easy_Data["一次性补给"] and not Auto_Purchase.One_Time_Supply then
		Auto_Purchase.One_Time_Supply = true

		awm.SpellStopCasting()
		awm.SpellStopTargeting()

		Sell.Step = 2

		if Class ~= "MAGE" then
			Auto_Purchase.Food = true
		end
		if Class == "HUNTER" then
			Auto_Purchase.Hunter_PetFood = true
			Auto_Purchase.Hunter_Ammo = true
		end
	end
end


function MainThread()
    local Px,Py,Pz = nil,nil,nil
    Px,Py,Pz = awm.ObjectPosition("player")

	Level = awm.UnitLevel("player")

	local Current_Map = C_Map.GetBestMapForUnit("player")

	if Px == nil or Py == nil or Pz == nil then
		return
	end

	if teleport.x == 0 and teleport.y == 0 and teleport.z == 0 then -- 传送检测
	    teleport.x = Px
		teleport.y = Py
		teleport.z = Pz
	else
	    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,teleport.x,teleport.y,teleport.z)
		if Easy_Data["传送检测"] and distance > Easy_Data["传送距离"] and not CheckDeadOrNot() then
		    Note_Head = Check_UI("传送警报","Teleport Warning")
			PlaySoundFile(567478)
			if not teleport.timer then
			    teleport.timer = true
				teleport.time = GetTime()
				PlayWinSound(awm.GetExeDirectory()..[[\Alarm.wav]])
			else
			    Note_Set(Check_UI("重新开始时间 = ","Restart Work After = ")..math.floor(90 - GetTime() + teleport.time)..Check_UI(" 秒"," Seconds"))
			    if GetTime() - teleport.time > 90 then
				    teleport.timer = false
					Coordinates_Get = false
					teleport.x,teleport.y,teleport.z = 0,0,0
					PlayWinSound(awm.GetExeDirectory()..[[\Alarm.wav]])
				end
			end
			return
		else
		    teleport.x = Px
			teleport.y = Py
			teleport.z = Pz
		end
	end

	if GetTime() - Destroy_Time > 20 then -- 摧毁
	    Destroy_Time = GetTime()
		Auto_Destroy()
	end

	if CheckDeadOrNot() then -- 判断人物是否死亡
	    Note_Head = Check_UI("死亡跑尸","Deadth Process")
		Event_Reset()
		Death_Run()
		return
	end

	if not UnitAffectingCombat("player") and not IsFlying() and not Buff_Check() then
	    Note_Head = Check_UI("BUFF增加","BUFF Adding")
	    return
	end

	if not UnitAffectingCombat("player") and not IsFlying() and not CheckUse() then
	    Note_Head = Check_UI("宝石制造","Gem Producting")
	    return
	end

	local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100
	if (awm.UnitAffectingCombat("player") and Cur_Health <= Easy_Data["反击百分比"] and Easy_Data["巡逻反击"]) or Scan_Combat then
	    if not awm.UnitAffectingCombat("player") and Scan_Combat then
		    Scan_Combat = false
			return
		end
		local Combat_Monster = Combat_Scan()
		if #Combat_Monster > 0 then
			Note_Set(Check_UI("反击! 怪物"..#Combat_Monster.."只, 设定距离"..Easy_Data["击杀扫描范围"].."码","Fight Back! Mobs around amount "..#Combat_Monster..", Set distance "..Easy_Data["击杀扫描范围"].." yard"))
			local Far_Distance = 500
			if Combat_Target ~= nil then
				if not awm.ObjectExists(Combat_Target) then
					Combat_Target = nil
				elseif awm.ObjectExists(Combat_Target) and (awm.UnitIsDead(Combat_Target) or not awm.UnitCanAttack("player",Combat_Target) or awm.GetDistanceBetweenObjects("player",Combat_Target) >= Easy_Data["击杀扫描范围"] or not awm.UnitAffectingCombat(Combat_Target)) then
					Combat_Target = nil
				else
					Scan_Combat = true
					CombatSystem(Combat_Target)
					return
				end
			end
			for i = 1,#Combat_Monster do
				local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
				local level = awm.UnitLevel(Combat_Monster[i])
				if distance < Easy_Data["击杀扫描范围"] and distance < Far_Distance and level - awm.UnitLevel("player") <= 5 then
					Far_Distance = distance
					Combat_Target = Combat_Monster[i]
				end
			end
			if Combat_Target ~= nil then
				Scan_Combat = true
				CombatSystem(Combat_Target)
				return
			else
				Scan_Combat = false
			end
		else
			Scan_Combat = false
		end
	end

	if Easy_Data["自定义路径"] and Easy_Data["读取文件内容"] then
	    Easy_Data["执行内容"] = awm.ReadFile(Easy_Data["文件路径"])
	elseif Easy_Data["自定义路径"] and Easy_Data["读取编辑框内容"] then
	    Easy_Data["执行内容"] = Basic_UI.Custom["执行内容"]:GetText()	
	end

	if Easy_Data["自定义路径"] and Execute_File ~= Easy_Data["执行内容"] then
	    RunScript(Easy_Data["执行内容"])
		Execute_File = Easy_Data["执行内容"]
	end

	if Easy_Data["内置路径"] and Execute_File ~= Easy_Data["内置路径内容"] then
	    RunScript(Easy_Data["内置路径内容"])
		Execute_File = Easy_Data["内置路径内容"]
	end

	if not awm.UnitAffectingCombat("player") and Easy_Data["需要吃喝"] and Grind.Step == 1 and not IsSwimming() and not IsFlying() then
	    if Start_Restore or Cur_Health < Easy_Data["回血百分比"] or (Cur_Power < Easy_Data["回蓝百分比"] and Class ~= "WARRIOR" and Class ~= "ROGUE") then
		    Start_Restore = true
			if not NeedHeal() then
				return
			end
		end
		Start_Restore = false	     
	end

	if Easy_Data["需要卖物"] or Easy_Data["需要修理"] then
	    if not Check_BagFree() or Sell.Step ~= 1 then
		    Note_Head = Check_UI("卖物","Vendor")

			if Easy_Data["自定义商人"] then
			    Merchant_Name = Easy_Data["自定义商人名字"]
				local Coord = string.split(Easy_Data["自定义商人坐标"],",")
				Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = tonumber(Merchant_Coord.mapid),tonumber(Merchant_Coord.x),tonumber(Merchant_Coord.y),tonumber(Merchant_Coord.z)
			end

			Replenishment_Vars()

			Event_Reset()

			local starttime, durationtime, enable = GetItemCooldown(6948)
			if GetItemCount(6948) > 0 and durationtime < 10 and Easy_Data["需要炉石"] then
				Note_Set(Check_UI("炉石回城","Using Hearthstone"))
				if IsMounted() then
					Dismount()
				end
				if not CastingBarFrame:IsVisible() then
					awm.UseItemByName(6948)
				end
				return
			end

			if not Has_Mail and Easy_Data["需要邮寄"] and Easy_Data["卖物前邮寄"] then
			    if Easy_Data["自定义邮箱"] then
					local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
					Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
					Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
				end


				if (Easy_Data["服务器地图"] and Mail_Coord.mapid ~= nil and Current_Map ~= Mail_Coord.mapid and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
					if Current_Map == Mail_Coord.mapid then
						Easy_Data.Sever_Map_Calculated = false
						Continent_Move = false
					end
					Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
					Sever_Run(Current_Map,Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z)
					return
				end

				Mail(Mail_Coord.x,Mail_Coord.y,Mail_Coord.z)
				return
			end

			if (Easy_Data["服务器地图"] and Merchant_Coord.mapid ~= nil and Current_Map ~= Merchant_Coord.mapid) or Easy_Data.Sever_Map_Calculated or Continent_Move then
			    Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Merchant_Coord.mapid,Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z)
				return
			end

			Sell_JunkRun(Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z)
			return
		end
	end

	if Easy_Data["需要邮寄"] then
		if math.floor(GetMoney()/10000) > Easy_Data["触发邮寄"] then
		    Note_Head = Check_UI("邮寄","Mail")
			
			if Easy_Data["自定义邮箱"] then
				local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
			end

			Event_Reset()

			Replenishment_Vars()

			local starttime, durationtime, enable = GetItemCooldown(6948)
			if GetItemCount(6948) > 0 and durationtime < 10 and Easy_Data["需要炉石"] then
				Note_Set(Check_UI("炉石回城","Using Hearthstone"))
				if IsMounted() then
					Dismount()
				end
				if not CastingBarFrame:IsVisible() then
					awm.UseItemByName(6948)
				end
				return
			end

			if (Easy_Data["服务器地图"] and Mail_Coord.mapid ~= nil and Current_Map ~= Mail_Coord.mapid) or Easy_Data.Sever_Map_Calculated or Continent_Move then
			    Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z)
				return
			end
			
			Mail(Mail_Coord.x,Mail_Coord.y,Mail_Coord.z)
			return
		end
	end

	if Auto_Purchase.Lack_Money and GetMoney() >= 50111 then
	    Auto_Purchase.Lack_Money = false
	end

	if Class == "HUNTER" then -- 子弹逻辑
	    if GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT")) < Easy_Data["子弹最小数量"] and not Auto_Purchase.Hunter_Ammo and not Auto_Purchase.Lack_Money then
			local Count = Hunter_Ammo_Count()
			if Count ~= nil and Count < Easy_Data["子弹最小数量"] then
				Auto_Purchase.Hunter_Ammo = true
				return
			end
		end

		if Auto_Purchase.Hunter_Ammo then
			Note_Head = Check_UI("购买子弹","Bullets Buy")

			
			frame:SetBackdropColor(0,0,0,0)

			Event_Reset()
			if not Buff_Check() then
				Note_Set(Check_UI("上BUFF...","Buff Adding...."))
				return
			end
			CheckProtection()

			Replenishment_Vars()

			local starttime, durationtime, enable = GetItemCooldown(6948)
			if GetItemCount(6948) > 0 and durationtime < 10 and Easy_Data["需要炉石"] then
				Note_Set(Check_UI("炉石回城","Using Hearthstone"))
				if IsMounted() then
					Dismount()
				end
				if not CastingBarFrame:IsVisible() then
					awm.UseItemByName(6948)
				end
				return
			else

				BulletRun(Ammo_Vendor_Coord.x,Ammo_Vendor_Coord.y,Ammo_Vendor_Coord.z)
			end
			return
		end
	end

	if Class == "HUNTER" and Easy_Data["需要召唤宠物"] and Easy_Data["宠物食物"] ~= nil and Level >= 10 then
		local Count = GetItemCount(Easy_Data["宠物食物"])
		if Count ~= nil and Count == 0 then
		    Auto_Purchase.Hunter_PetFood = true
		end

		if Auto_Purchase.Hunter_PetFood then
			Note_Head = Check_UI("购买宠物食品","Buy Pet Food")

			if Auto_Purchase.Lack_Money then
				Auto_Purchase.Hunter_PetFood = false
				return
			end

			if Count < Easy_Data["宠物食物数量"] and not Auto_Purchase.Lack_Money then
				Event_Reset()

				if not Buff_Check() then
					Note_Set(Check_UI("上BUFF...","Buff Adding...."))
					return
				end

				local starttime, durationtime, enable = GetItemCooldown(6948)
				if GetItemCount(6948) > 0 and durationtime < 10 and Easy_Data["需要炉石"] then
					Note_Set(Check_UI("炉石回城","Using Hearthstone"))
					if IsMounted() then
						Dismount()
					end
					if not CastingBarFrame:IsVisible() then
						awm.UseItemByName(6948)
					end
					return
				end

				Replenishment_Vars()

				Pet_Food_Vendor_Name = Easy_Data["宠物商人名字"]

				local Coord = string.split(Easy_Data["宠物商人坐标"],",")
			    Pet_Food_Vendor_Coord.mapid,Pet_Food_Vendor_Coord.x,Pet_Food_Vendor_Coord.y,Pet_Food_Vendor_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Pet_Food_Vendor_Coord.mapid,Pet_Food_Vendor_Coord.x,Pet_Food_Vendor_Coord.y,Pet_Food_Vendor_Coord.z = tonumber(Pet_Food_Vendor_Coord.mapid),tonumber(Pet_Food_Vendor_Coord.x),tonumber(Pet_Food_Vendor_Coord.y),tonumber(Pet_Food_Vendor_Coord.z)


				Pet_Food_Run(Pet_Food_Vendor_Coord.x,Pet_Food_Vendor_Coord.y,Pet_Food_Vendor_Coord.z)
				return
			end

			if Count >= Easy_Data["宠物食物数量"] then
				Auto_Purchase.Hunter_PetFood = false
			end
		end
	end

	if Class ~= "MAGE" and Easy_Data["购买吃喝"] then
	    if GetMoney() > 2000 and Has_Bought_Food_Drink then -- 足够钱买食物了
			Has_Bought_Food_Drink = false
		end
		local Food_Count = 0
		for i = 1,#Food_Full_List do
			Food_Count = Food_Count + GetItemCount(Food_Full_List[i])
		end
			
		local Drink_Count = 0
		for i = 1,#Drink_Full_List do
			Drink_Count = Drink_Count + GetItemCount(Drink_Full_List[i])
		end

		if not Auto_Purchase.Food then
			if (Food_Count <= Easy_Data["最小食物数量"] or (Drink_Count <= Easy_Data["最小食物数量"] and Class ~= "WARRIOR" and Class ~= "ROGUE")) and not Auto_Purchase.Lack_Money then
				Auto_Purchase.Food = true
				return
			end
		elseif Auto_Purchase.Food then
		    Note_Head = Check_UI("购买吃喝","Food & Drink Buy")
			if Auto_Purchase.Lack_Money then
				Auto_Purchase.Food = false
				return
			end

			if (Food_Count < Easy_Data["食物保留数量"] or (Drink_Count < Easy_Data["饮料保留数量"] and Class ~= "ROGUE" and Class ~= "WARRIOR")) and not Auto_Purchase.Lack_Money then
				Event_Reset()

				if not Buff_Check() then
					Note_Set(Check_UI("上BUFF...","Buff Adding...."))
					return
				end

				local starttime, durationtime, enable = GetItemCooldown(6948)
				if GetItemCount(6948) > 0 and durationtime < 10 and Easy_Data["需要炉石"] then
					Note_Set(Check_UI("炉石回城","Using Hearthstone"))
					if IsMounted() then
						Dismount()
					end
					if not CastingBarFrame:IsVisible() then
						awm.UseItemByName(6948)
					end
					return
				end

				Replenishment_Vars()

				Food_Drink_Run(Food_Vendor_Coord.x,Food_Vendor_Coord.y,Food_Vendor_Coord.z)
			end

			if Food_Count >= Easy_Data["食物保留数量"] and (Drink_Count >= Easy_Data["饮料保留数量"] or Class == "ROGUE" or Class == "WARRIOR") then
				Auto_Purchase.Food = false
			end
			return
		end
	end

	Skin_Process()
end


Coordinates_Get = false -- 判断要不要取新的navmesh
local coordinates = {} -- 路径点的table
local Path_Index = 2
local lastx,lasty,lastz = 0,0,0
local Stop_Run = false -- 卡点
local stuckx,stucky = nil,nil
local Reset_Stuck = 0 -- 3秒检测一次
local Reset_Path = 0 -- 死亡路径重置和间隔路径重置
local rx,ry,rz = 0,0,0 -- Run参数对比
Tried_Mount = GetTime()
local Stuck_Step = 1 -- 第一步跳 第二步移动
local Nil_Reset = GetTime()
local Nav_Time = GetTime()
local Mount_Tried_Times = 0 -- 上马尝试次数 大于3次不再尝试

function Run(x,y,z) -- 寻路call 
	local Px,Py,Pz = nil,nil,nil
	Px,Py,Pz = awm.ObjectPosition("player")
	if Px == nil or Py == nil or Pz == nil then
		return
	end

	if rx ~= x and ry ~= y and rz ~= z then
	   Coordinates_Get = false
	   rx,ry,rz = x,y,z
	   Reset_Stuck = GetTime()
	end

	if (GetTime() - Nav_Time) > 3 and (GetTime() - Reset_Stuck) > 3 then
	    lastx,lasty,lastz = awm.ObjectPosition("player")
		Reset_Stuck = GetTime()
	else
	    Nav_Time = GetTime()
	end

	if not Coordinates_Get then
		Coordinates_Get = true
		Path_Index = 2
		coordinates = {}
		awm.SetPathfindingVariables(Easy_Data["躲避物体距离"], Easy_Data["躲避物体体积"], Easy_Data["平滑寻路间隔"], Easy_Data["平滑寻路间隔"])
		local map_id = select(8, GetInstanceInfo())	
		coordinates = awm.FindPath(map_id, Px,Py,Pz, x, y, z, Easy_Data["平滑寻路"], Easy_Data["躲避物体"], Easy_Data["水中寻路"],Easy_Data["有效寻路"])
	end

	if awm.UnitIsDeadOrGhost("player") and GetTime() - Reset_Path > 15 then
	    Reset_Path = GetTime()
		Coordinates_Get = false
		return
	elseif not awm.UnitIsDeadOrGhost("player") and Easy_Data["地图刷新"] and GetTime() - Reset_Path > Easy_Data["地图刷新间隔"] then
	    Reset_Path = GetTime()
		Coordinates_Get = false
		return
	end

	if not Easy_Data["使用坐骑"] and Mount_useble < GetTime() then
	    Mount_useble = GetTime() + 120
	elseif not IsOutdoors() and Easy_Data["使用坐骑"] and Mount_useble < GetTime() then
	    Mount_useble = GetTime() + 20
	end

	if DoesSpellExist(rs["旅行形态"]) and Mount_useble < GetTime() + 1 and not CheckBuff("player",rs["旅行形态"]) and Spell_Castable(rs["旅行形态"]) and not IsSwimming() and IsOutdoors() then
	    Reset_Stuck = GetTime()
	    Mount_useble = GetTime()
		awm.CastSpellByName(rs["旅行形态"],"player")
		textout(Check_UI("旅行形态 切换","Travel Form Shift"))
		return
	elseif not DoesSpellExist(rs["旅行形态"]) and not IsMounted() and awm.UnitLevel("player") >= 30 and not awm.UnitIsGhost("player") and Mount_useble < GetTime() and not awm.UnitAffectingCombat("player") and not IsSwimming() and IsOutdoors() then
	    Reset_Stuck = GetTime()
		if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
			if Tried_Mount < GetTime() then
				Tried_Mount = GetTime() + 5
				Stop_Moving = true
				Mount_Tried_Times = Mount_Tried_Times + 1

				if Easy_Data["使用坐骑物品"] then
				    awm.UseItemByName(Easy_Data["坐骑物品名字"])
				elseif Easy_Data["使用坐骑技能"] then
				    awm.CastSpellByName(Easy_Data["坐骑技能名字"])
				else
					awm.UseAction(Easy_Data["动作条坐骑位置"])
                end

				textout(Check_UI("上马 - "..Easy_Data["动作条坐骑位置"],"Mounting - "..Easy_Data["动作条坐骑位置"]))
				C_Timer.After(5,function() Stop_Moving = false end)
				return
			end
			if Mount_Tried_Times > 5 then

			    Mount_useble = GetTime() + 15
				return
			end
		end
		return
	end

	Mount_Tried_Times = 0

	if coordinates == nil or coordinates == 0 or awm.GetActiveNodeCount() == 0 then
		awm.Interval_Move(x,y,z)
		if GetTime() - Nil_Reset > 3 then
		    Nil_Reset = GetTime()
			Coordinates_Get = false
			textout(Check_UI("导航路径 = 无.. 检查地图包设置或无路径生成","Navigation path = nil.. Check your map folder settings or no path found"))
		end
		return
	end

	if (GetTime() - Reset_Stuck) > 3 and not Stop_Run then
	    Reset_Stuck = GetTime()
		local Px,Py,Pz = awm.ObjectPosition("player")
		local StuckDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,lastx,lasty,lastz)
		if StuckDistance <= 3 then
			Stop_Run = true
			stuckx,stucky = nil,nil
			if Stuck_Step == 1 then
				Stuck_Step = 2
			elseif Stuck_Step == 2 then
				Stuck_Step = 3
			else
				Stuck_Step = 1
			end
		end
		lastx,lasty,lastz = awm.ObjectPosition("player")
		return
	end

	if Stop_Run then
		if stuckx == nil or stucky == nil then
		    textout(Check_UI("脱离 = ","Navigation Stucking = ")..Stuck_Step)
		    if Stuck_Step == 1 then
				stuckx = random(Px-10,Px+10)
				stucky = random(Py-10,Py+10)
				awm.Interval_Move(stuckx,stucky,Pz)
				C_Timer.After(0.5,awm.JumpOrAscendStart)
				C_Timer.After(1,awm.AscendStop)
			elseif Stuck_Step == 2 then
			    if coordinates ~= nil and coordinates ~= 0 and awm.GetActiveNodeCount() > 0 then
					stuckx,stucky,stuckz = awm.GetActiveNodeByIndex(Path_Index)
					Mount_useble = GetTime() + 10

					if IsMounted() and not IsFlying() then
					    Dismount()
					end
				else
				    stuckx = random(Px-20,Px+20)
					stucky = random(Py-20,Py+20)
				end
			else
			    if not IsFlying() then
			        awm.JumpOrAscendStart()
				end
			    stuckx = random(Px-30,Px+30)
				stucky = random(Py-30,Py+30)
			end

			C_Timer.After(2,function()
				Stop_Run = false
				Coordinates_Get = false
				awm.AscendStop()
				Reset_Stuck = GetTime()
			end)
		end
		awm.Interval_Move(stuckx,stucky,Pz)
		return
	end

	if awm.GetActiveNodeCount() > 0 then
	    local x1,y1,z1 = awm.GetActiveNodeByIndex(Path_Index)
		local distance1 = awm.GetDistanceBetweenPositions(x1,y1,Pz,Px,Py,Pz)

		local Check_Distance = 1

		if IsFlying() then
		    Check_Distance = 3
		end

		if distance1 ~= nil and distance1 > Check_Distance and not Stop_Moving then
		    if (Auto_Purchase.Food or Sell.Step ~= 1 or Auto_Purchase.Hunter_PetFood or Auto_Purchase.Hunter_Ammo) and awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) < 100 then
			    awm.Interval_Move(x1, y1, z1)
		    elseif Grind.Step == 1 and Easy_Data["飞行采集"] and IsFlying() and GetInstanceInfo() == Check_Client("外域","Outland") then
			    if not Easy_Data["固定飞行高度"] then

					if tonumber(Easy_Data["飞行高度"]) == nil then
						Easy_Data["飞行高度"] = 30
					end

					local Z_now = 0

					if GetTime() - Fly_Scan > 3 then
					    Fly_Scan = GetTime()

						_,_,Z_now = awm.FindClosestPointOnMesh(select(8, GetInstanceInfo()) ,Px,Py,Pz)

						if Z_now then
						    Fly_Z = Z_now
						else
						    Fly_Z = Pz
						end
					end

					if Fly_Z and Pz <= Fly_Z + Easy_Data["飞行高度"] then
						awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"])
					elseif Fly_Z and Pz >= Fly_Z + Easy_Data["飞行高度"] + 20 then
						awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"])
					else
					    awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"] + 3)
					end
				else
				    if tonumber(Easy_Data["飞行高度"]) == nil then
						Easy_Data["飞行高度"] = 30
					end

					if Pz <= Easy_Data["飞行高度"] then
						awm.Interval_Move(x1, y1, Easy_Data["飞行高度"])
					elseif Pz <= Easy_Data["飞行高度"] + 20 then
						awm.Interval_Move(x1, y1, Easy_Data["飞行高度"])
					else
					    awm.Interval_Move(x1, y1, Easy_Data["飞行高度"] + 3)
					end
				end
			elseif Grind.Step == 2 and awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) > 50 and not UnitAffectingCombat("player") and Easy_Data["飞行采集"] and IsFlying() and GetInstanceInfo() == Check_Client("外域","Outland") then

			    if not Easy_Data["固定飞行高度"] then

					if tonumber(Easy_Data["飞行高度"]) == nil then
						Easy_Data["飞行高度"] = 30
					end

					local Z_now = 0

					if GetTime() - Fly_Scan > 3 then
					    Fly_Scan = GetTime()

						_,_,Z_now = awm.FindClosestPointOnMesh(select(8, GetInstanceInfo()) ,Px,Py,Pz)

						if Z_now then
						    Fly_Z = Z_now
						else
						    Fly_Z = Pz
						end
					end

					if Fly_Z and Pz <= Fly_Z + Easy_Data["飞行高度"] then
						awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"])
					elseif Fly_Z and Pz >= Fly_Z + Easy_Data["飞行高度"] + 20 then
						awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"])
					else
					    awm.Interval_Move(x1, y1, Fly_Z + Easy_Data["飞行高度"] + 3)
					end
				else
				    if tonumber(Easy_Data["飞行高度"]) == nil then
						Easy_Data["飞行高度"] = 30
					end

					if Pz <= Easy_Data["飞行高度"] then
						awm.Interval_Move(x1, y1, Easy_Data["飞行高度"])
					elseif Pz <= Easy_Data["飞行高度"] + 20 then
						awm.Interval_Move(x1, y1, Easy_Data["飞行高度"])
					else
					    awm.Interval_Move(x1, y1, Easy_Data["飞行高度"] + 3)
					end
				end
			else
		        awm.Interval_Move(x1, y1, z1)
			end
		end
		if distance1 <= Check_Distance then
			Path_Index = Path_Index + 1
			local Path_Odd = Path_Index - awm.GetActiveNodeCount()
			if Path_Odd > 0 then
				Path_Index = 2
				Coordinates_Get = false
				coordinates = {}
				return
			end
		end
	end
end

---- 界面 ----
local function Create_Nav_UI() -- 导航UI
    Basic_UI.Nav = {}
	Basic_UI.Nav.Py = -10
	local function Frame_Create()
		Basic_UI.Nav.frame = CreateFrame('frame',"Basic_UI.Nav.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Nav.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Nav.frame:SetSize(600,1500)
		Basic_UI.Nav.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Nav.frame:Hide()
		Basic_UI.Nav.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Nav.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Nav.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("导航","navigation"))
		Basic_UI.Nav.button:SetSize(130,20)
		Basic_UI.Nav.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Nav.frame:Show()
			Basic_UI.Nav.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Nav.frame:Hide() Basic_UI.Nav.button:SetBackdropColor(0,0,0,0) end
	end

	local function enable_Nav_Water()
	    Basic_UI.Nav["水中寻路"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("水中寻路","Navigation allow water"))
		Basic_UI.Nav["水中寻路"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["水中寻路"]:GetChecked() then
				Easy_Data["水中寻路"] = true
			elseif not Basic_UI.Nav["水中寻路"]:GetChecked() then
				Easy_Data["水中寻路"] = false
			end
		end)
		if Easy_Data["水中寻路"] ~= nil then
			if Easy_Data["水中寻路"] then
				Basic_UI.Nav["水中寻路"]:SetChecked(true)
			else
				Basic_UI.Nav["水中寻路"]:SetChecked(false)
			end
		else
			Easy_Data["水中寻路"] = true
			Basic_UI.Nav["水中寻路"]:SetChecked(true)
		end
	end

	local function enable_Smooth()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["平滑寻路"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("平滑寻路","Smooth Navigation"))
		Basic_UI.Nav["平滑寻路"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["平滑寻路"]:GetChecked() then
				Easy_Data["平滑寻路"] = true
			elseif not Basic_UI.Nav["平滑寻路"]:GetChecked() then
				Easy_Data["平滑寻路"] = false
			end
		end)
		if Easy_Data["平滑寻路"] ~= nil then
			if Easy_Data["平滑寻路"] then
				Basic_UI.Nav["平滑寻路"]:SetChecked(true)
			else
				Basic_UI.Nav["平滑寻路"]:SetChecked(false)
			end
		else
			Easy_Data["平滑寻路"] = true
			Basic_UI.Nav["平滑寻路"]:SetChecked(true)
		end

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("平滑寻路 导航点位 距离间隔","Smooth Navigation Distance Between Points"))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["平滑寻路间隔"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"4",false,280,24)
		Basic_UI.Nav["平滑寻路间隔"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["平滑寻路间隔"] = tonumber(Basic_UI.Nav["平滑寻路间隔"]:GetText())
		end)
		if Easy_Data["平滑寻路间隔"] ~= nil then
			Basic_UI.Nav["平滑寻路间隔"]:SetText(Easy_Data["平滑寻路间隔"])
		else
			Easy_Data["平滑寻路间隔"] = tonumber(Basic_UI.Nav["平滑寻路间隔"]:GetText())
		end

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("平滑寻路 导航点位 最大角度","Smooth Navigation Angles Between Points"))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["平滑寻路角度"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"0.3",false,280,24)
		Basic_UI.Nav["平滑寻路角度"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["平滑寻路角度"] = tonumber(Basic_UI.Nav["平滑寻路角度"]:GetText())
		end)
		if Easy_Data["平滑寻路角度"] ~= nil then
			Basic_UI.Nav["平滑寻路角度"]:SetText(Easy_Data["平滑寻路角度"])
		else
			Easy_Data["平滑寻路角度"] = tonumber(Basic_UI.Nav["平滑寻路角度"]:GetText())
		end
	end

	local function enable_PPP()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["躲避物体"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("躲避动态物体","Aviod Dynamic Object"))
		Basic_UI.Nav["躲避物体"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["躲避物体"]:GetChecked() then
				Easy_Data["躲避物体"] = true
			elseif not Basic_UI.Nav["躲避物体"]:GetChecked() then
				Easy_Data["躲避物体"] = false
			end
		end)
		if Easy_Data["躲避物体"] ~= nil then
			if Easy_Data["躲避物体"] then
				Basic_UI.Nav["躲避物体"]:SetChecked(true)
			else
				Basic_UI.Nav["躲避物体"]:SetChecked(false)
			end
		else
			Easy_Data["躲避物体"] = false
			Basic_UI.Nav["躲避物体"]:SetChecked(false)
		end

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("躲避动态物体 - 与墙保持的距离","Aviod Dynamic Object - Distance away from walls"))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["躲避物体距离"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"1",false,280,24)
		Basic_UI.Nav["躲避物体距离"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["躲避物体距离"] = tonumber(Basic_UI.Nav["躲避物体距离"]:GetText())
		end)
		if Easy_Data["躲避物体距离"] ~= nil then
			Basic_UI.Nav["躲避物体距离"]:SetText(Easy_Data["躲避物体距离"])
		else
			Easy_Data["躲避物体距离"] = tonumber(Basic_UI.Nav["躲避物体距离"]:GetText())
		end

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("躲避动态物体 - 无视物体体积","Aviod Dynamic Object - Object Size"))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["躲避物体体积"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"0.5",false,280,24)
		Basic_UI.Nav["躲避物体体积"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["躲避物体体积"] = tonumber(Basic_UI.Nav["躲避物体体积"]:GetText())
		end)
		if Easy_Data["躲避物体体积"] ~= nil then
			Basic_UI.Nav["躲避物体体积"]:SetText(Easy_Data["躲避物体体积"])
		else
			Easy_Data["躲避物体体积"] = tonumber(Basic_UI.Nav["躲避物体体积"]:GetText())
		end
	end

	local function enable_Vaild()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["有效寻路"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("有效寻路","Vaild Path"))
		Basic_UI.Nav["有效寻路"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["有效寻路"]:GetChecked() then
				Easy_Data["有效寻路"] = true
			elseif not Basic_UI.Nav["有效寻路"]:GetChecked() then
				Easy_Data["有效寻路"] = false
			end
		end)
		if Easy_Data["有效寻路"] ~= nil then
			if Easy_Data["有效寻路"] then
				Basic_UI.Nav["有效寻路"]:SetChecked(true)
			else
				Basic_UI.Nav["有效寻路"]:SetChecked(false)
			end
		else
			Easy_Data["有效寻路"] = false
			Basic_UI.Nav["有效寻路"]:SetChecked(false)
		end
	end

	local function Mount_Slot()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		Basic_UI.Nav["使用坐骑"] = Create_Check_Button(Basic_UI.Nav.frame, "TOPLEFT",10, Basic_UI.Nav.Py, Check_UI("使用坐骑","Use mount"))
		Basic_UI.Nav["使用坐骑"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["使用坐骑"]:GetChecked() then
				Easy_Data["使用坐骑"] = true
			elseif not Basic_UI.Nav["使用坐骑"]:GetChecked() then
				Easy_Data["使用坐骑"] = false
			end
		end)
		if Easy_Data["使用坐骑"] ~= nil then
			if Easy_Data["使用坐骑"] then
				Basic_UI.Nav["使用坐骑"]:SetChecked(true)
			else
				Basic_UI.Nav["使用坐骑"]:SetChecked(false)
			end
		else
		    if UnitLevel("player") >= 30 then
				Easy_Data["使用坐骑"] = true
				Basic_UI.Nav["使用坐骑"]:SetChecked(true)
			else
			    Easy_Data["使用坐骑"] = false
				Basic_UI.Nav["使用坐骑"]:SetChecked(false)
			end
		end
	 

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header1 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("坐骑在动作条(或快捷栏)第几格(第一页)","What action slot you put mount in")) 

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20

		Basic_UI.Nav["动作条坐骑位置"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"1",false,280,24)
		Basic_UI.Nav["动作条坐骑位置"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["动作条坐骑位置"] = tonumber(Basic_UI.Nav["动作条坐骑位置"]:GetText())
		end)
		if Easy_Data["动作条坐骑位置"] ~= nil then
			Basic_UI.Nav["动作条坐骑位置"]:SetText(Easy_Data["动作条坐骑位置"])
		else
			Easy_Data["动作条坐骑位置"]= tonumber(Basic_UI.Nav["动作条坐骑位置"]:GetText())
		end


		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		Basic_UI.Nav["使用坐骑物品"] = Create_Check_Button(Basic_UI.Nav.frame, "TOPLEFT",10, Basic_UI.Nav.Py, Check_UI("使用坐骑物品","Use mount item name"))
		Basic_UI.Nav["使用坐骑物品"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["使用坐骑物品"]:GetChecked() then
				Easy_Data["使用坐骑物品"] = true
			elseif not Basic_UI.Nav["使用坐骑物品"]:GetChecked() then
				Easy_Data["使用坐骑物品"] = false
			end
		end)
		if Easy_Data["使用坐骑物品"] ~= nil then
			if Easy_Data["使用坐骑物品"] then
				Basic_UI.Nav["使用坐骑物品"]:SetChecked(true)
			else
				Basic_UI.Nav["使用坐骑物品"]:SetChecked(false)
			end
		else
			Easy_Data["使用坐骑物品"] = false
			Basic_UI.Nav["使用坐骑物品"]:SetChecked(false)
		end


		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("坐骑物品 = ","Mount item name = "))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["坐骑物品名字"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"",false,280,24)
		Basic_UI.Nav["坐骑物品名字"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["坐骑物品名字"] = Basic_UI.Nav["坐骑物品名字"]:GetText()
		end)
		if Easy_Data["坐骑物品名字"] ~= nil then
			Basic_UI.Nav["坐骑物品名字"]:SetText(Easy_Data["坐骑物品名字"])
		else
			Easy_Data["坐骑物品名字"] = Basic_UI.Nav["坐骑物品名字"]:GetText()
		end


		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		Basic_UI.Nav["使用坐骑技能"] = Create_Check_Button(Basic_UI.Nav.frame, "TOPLEFT",10, Basic_UI.Nav.Py, Check_UI("使用坐骑技能","Use mount spell name"))
		Basic_UI.Nav["使用坐骑技能"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["使用坐骑技能"]:GetChecked() then
				Easy_Data["使用坐骑技能"] = true
			elseif not Basic_UI.Nav["使用坐骑技能"]:GetChecked() then
				Easy_Data["使用坐骑技能"] = false
			end
		end)
		if Easy_Data["使用坐骑技能"] ~= nil then
			if Easy_Data["使用坐骑技能"] then
				Basic_UI.Nav["使用坐骑技能"]:SetChecked(true)
			else
				Basic_UI.Nav["使用坐骑技能"]:SetChecked(false)
			end
		else
			Easy_Data["使用坐骑技能"] = false
			Basic_UI.Nav["使用坐骑技能"]:SetChecked(false)
		end


		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header2 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("坐骑技能 = ","Mount sepll name = "))

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20
		Basic_UI.Nav["坐骑技能名字"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"",false,280,24)
		Basic_UI.Nav["坐骑技能名字"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["坐骑技能名字"] = Basic_UI.Nav["坐骑技能名字"]:GetText()
		end)
		if Easy_Data["坐骑技能名字"] ~= nil then
			Basic_UI.Nav["坐骑技能名字"]:SetText(Easy_Data["坐骑技能名字"])
		else
			Easy_Data["坐骑技能名字"] = Basic_UI.Nav["坐骑技能名字"]:GetText()
		end
	end

	local function enable_Sever_Map()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["服务器地图"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("加载云地图 (跨大陆使用, 副本勿开启)","Load server navigation system (use to across continents, disable it in dungeon profiles)"))
		Basic_UI.Nav["服务器地图"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["服务器地图"]:GetChecked() then
				Easy_Data["服务器地图"] = true
			elseif not Basic_UI.Nav["服务器地图"]:GetChecked() then
				Easy_Data["服务器地图"] = false
			end
		end)
		if Easy_Data["服务器地图"] ~= nil then
			if Easy_Data["服务器地图"] then
				Basic_UI.Nav["服务器地图"]:SetChecked(true)
			else
				Basic_UI.Nav["服务器地图"]:SetChecked(false)
			end
		else
			Easy_Data["服务器地图"] = false
			Basic_UI.Nav["服务器地图"]:SetChecked(false)
		end
	end

	local function enable_Mesh_Refresh()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["地图刷新"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("自动重新计算路径","Auto recalculate paths"))
		Basic_UI.Nav["地图刷新"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["地图刷新"]:GetChecked() then
				Easy_Data["地图刷新"] = true
			elseif not Basic_UI.Nav["地图刷新"]:GetChecked() then
				Easy_Data["地图刷新"] = false
			end
		end)
		if Easy_Data["地图刷新"] ~= nil then
			if Easy_Data["地图刷新"] then
				Basic_UI.Nav["地图刷新"]:SetChecked(true)
			else
				Basic_UI.Nav["地图刷新"]:SetChecked(false)
			end
		else
			Easy_Data["地图刷新"] = false
			Basic_UI.Nav["地图刷新"]:SetChecked(false)
		end


		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header1 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("重新计算间隔 (秒)","Recalculation interval time (seconds)")) 

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20

		Basic_UI.Nav["地图刷新间隔"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"20",false,280,24)
		Basic_UI.Nav["地图刷新间隔"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["地图刷新间隔"] = tonumber(Basic_UI.Nav["地图刷新间隔"]:GetText())
		end)
		if Easy_Data["地图刷新间隔"] ~= nil then
			Basic_UI.Nav["地图刷新间隔"]:SetText(Easy_Data["地图刷新间隔"])
		else
			Easy_Data["地图刷新间隔"]= tonumber(Basic_UI.Nav["地图刷新间隔"]:GetText())
		end
	end

	Frame_Create()
	Button_Create()
	enable_Nav_Water()
	enable_Smooth()
	enable_PPP()
	enable_Vaild()
	Mount_Slot()
	enable_Sever_Map()
	enable_Mesh_Refresh()
end

local function Create_Config_UI() -- 游戏设置
    Basic_UI.Set = {}
	Basic_UI.Set.Py = -10
	local function Frame_Create()
		Basic_UI.Set.frame = CreateFrame('frame',"Basic_UI.Set.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Set.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Set.frame:SetSize(600,1500)
		Basic_UI.Set.frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
		title= true, 
		edgeSize =15, 
		titleSize = 32})
		Basic_UI.Set.frame:Hide()
		Basic_UI.Set.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Set.frame:SetBackdropBorderColor(1,0,1,1)
		Basic_UI.Set.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Set.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("脚本","profile"))
		Basic_UI.Set.button:SetSize(130,20)
		Basic_UI.Set.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Set.frame:Show()
			Basic_UI.Set.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Set.frame:Hide() Basic_UI.Set.button:SetBackdropColor(0,0,0,0) end
	end

	local function Gathering_Set_UI() -- 飞行采集 离地距离 
	    Basic_UI.Set["飞行采集"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_Client("飞行采集","Gathering with flying mount"))
		Basic_UI.Set["飞行采集"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["飞行采集"]:GetChecked() then
				Easy_Data["飞行采集"] = true
			elseif not Basic_UI.Set["飞行采集"]:GetChecked() then
				Easy_Data["飞行采集"] = false
			end
		end)
		if Easy_Data["飞行采集"] ~= nil then
			if Easy_Data["飞行采集"] then
				Basic_UI.Set["飞行采集"]:SetChecked(true)
			else
				Basic_UI.Set["飞行采集"]:SetChecked(false)
			end
		else
			Easy_Data["飞行采集"] = false
			Basic_UI.Set["飞行采集"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("离地飞行高度","Fly height with the closest polygon")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["飞行高度"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py, 70,false,280,24)
		Basic_UI.Set["飞行高度"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["飞行高度"] = tonumber(Basic_UI.Set["飞行高度"]:GetText())
		end)
		if Easy_Data["飞行高度"] ~= nil then
			Basic_UI.Set["飞行高度"]:SetText(Easy_Data["飞行高度"])
		else
			Easy_Data["飞行高度"] = tonumber(Basic_UI.Set["飞行高度"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		Basic_UI.Set["固定飞行高度"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_Client("固定飞行高度","Fixed Flying Z Height"))
		Basic_UI.Set["固定飞行高度"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["固定飞行高度"]:GetChecked() then
				Easy_Data["固定飞行高度"] = true
			elseif not Basic_UI.Set["固定飞行高度"]:GetChecked() then
				Easy_Data["固定飞行高度"] = false
			end
		end)
		if Easy_Data["固定飞行高度"] ~= nil then
			if Easy_Data["固定飞行高度"] then
				Basic_UI.Set["固定飞行高度"]:SetChecked(true)
			else
				Basic_UI.Set["固定飞行高度"]:SetChecked(false)
			end
		else
			Easy_Data["固定飞行高度"] = true
			Basic_UI.Set["固定飞行高度"]:SetChecked(true)
		end
	end

	local function Max_Gather_Time_UI() -- 极限击杀时间
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("最大击杀时间 (超过时间拉黑)","Max Kill time (Blacklist object if overtime)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["极限击杀时间"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"200",false,280,24)
		Basic_UI.Set["极限击杀时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["极限击杀时间"] = tonumber(Basic_UI.Set["极限击杀时间"]:GetText())
		end)
		if Easy_Data["极限击杀时间"] ~= nil then
			Basic_UI.Set["极限击杀时间"]:SetText(Easy_Data["极限击杀时间"])
		else
			Easy_Data["极限击杀时间"] = tonumber(Basic_UI.Set["极限击杀时间"]:GetText())
		end
	end

	local function Hearth_stone() -- 使用炉石
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["需要炉石"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_Client("使用炉石","Use Hearthstone"))
		Basic_UI.Set["需要炉石"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要炉石"]:GetChecked() then
				Easy_Data["需要炉石"] = true
			elseif not Basic_UI.Set["需要炉石"]:GetChecked() then
				Easy_Data["需要炉石"] = false
			end
		end)
		if Easy_Data["需要炉石"] ~= nil then
			if Easy_Data["需要炉石"] then
				Basic_UI.Set["需要炉石"]:SetChecked(true)
			else
				Basic_UI.Set["需要炉石"]:SetChecked(false)
			end
		else
			Easy_Data["需要炉石"] = false
			Basic_UI.Set["需要炉石"]:SetChecked(false)
		end
	end

	local function FightBack_Choose_UI() -- 采矿采药反击
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30	    
	    Basic_UI.Set["巡逻反击"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_Client("巡逻地图时反击怪物","Fight mobs when navigation"))
		Basic_UI.Set["巡逻反击"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["巡逻反击"]:GetChecked() then
				Easy_Data["巡逻反击"] = true
			elseif not Basic_UI.Set["巡逻反击"]:GetChecked() then
				Easy_Data["巡逻反击"] = false
			end
		end)
		if Easy_Data["巡逻反击"] ~= nil then
			if Easy_Data["巡逻反击"] then
				Basic_UI.Set["巡逻反击"]:SetChecked(true)
			else
				Basic_UI.Set["巡逻反击"]:SetChecked(false)
			end
		else
			Easy_Data["巡逻反击"] = true
			Basic_UI.Set["巡逻反击"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("巡逻反击的血量(%)","Health percent begin Fight back(%)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["反击百分比"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"50",false,280,24)
		Basic_UI.Set["反击百分比"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["反击百分比"] = tonumber(Basic_UI.Set["反击百分比"]:GetText())
		end)
		if Easy_Data["反击百分比"] ~= nil then
			Basic_UI.Set["反击百分比"]:SetText(Easy_Data["反击百分比"])
		else
			Easy_Data["反击百分比"]= tonumber(Basic_UI.Set["反击百分比"]:GetText())
		end
	end

	local function Gather_Set_UI() -- 扫描范围
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("击杀扫描的范围","Killing scan range")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["击杀扫描范围"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"200",false,280,24)
		Basic_UI.Set["击杀扫描范围"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["击杀扫描范围"] = tonumber(Basic_UI.Set["击杀扫描范围"]:GetText())
		end)
		if Easy_Data["击杀扫描范围"] ~= nil then
			Basic_UI.Set["击杀扫描范围"]:SetText(Easy_Data["击杀扫描范围"])
		else
			Easy_Data["击杀扫描范围"] = tonumber(Basic_UI.Set["击杀扫描范围"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("地图物品扫描间隔时间","Maps game object scan interval time")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["扫描间隔"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"1",false,280,24)
		Basic_UI.Set["扫描间隔"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["扫描间隔"] = tonumber(Basic_UI.Set["扫描间隔"]:GetText())
		end)
		if Easy_Data["扫描间隔"] ~= nil then
			Basic_UI.Set["扫描间隔"]:SetText(Easy_Data["扫描间隔"])
		else
			Easy_Data["扫描间隔"] = tonumber(Basic_UI.Set["扫描间隔"]:GetText())
		end
	end

	local function Use_Potions() -- 使用回复药水
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["使用药水"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("使用血量和蓝量药水","Use Potions"))
		Basic_UI.Set["使用药水"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["使用药水"]:GetChecked() then
				Easy_Data["使用药水"] = true
			elseif not Basic_UI.Set["使用药水"]:GetChecked() then
				Easy_Data["使用药水"] = false
			end
		end)
		if Easy_Data["使用药水"] ~= nil then
			if Easy_Data["使用药水"] then
				Basic_UI.Set["使用药水"]:SetChecked(true)
			else
				Basic_UI.Set["使用药水"]:SetChecked(false)
			end
		else
			Easy_Data["使用药水"] = true
			Basic_UI.Set["使用药水"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("回血药水使用血量百分比","Health potion use percentage(%)")) 

		Basic_UI.Set["回血药水百分比"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py - 20,"40",false,280,24)

		Basic_UI.Set["回血药水百分比"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回血药水百分比"] = tonumber(Basic_UI.Set["回血药水百分比"]:GetText())
		end)
		if Easy_Data["回血药水百分比"] ~= nil then
			Basic_UI.Set["回血药水百分比"]:SetText(Easy_Data["回血药水百分比"])
		else
			Easy_Data["回血药水百分比"] = tonumber(Basic_UI.Set["回血药水百分比"]:GetText())
		end

		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,Check_UI("回蓝药水使用蓝量百分比","Mana potion use percentage(%)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["回蓝药水百分比"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"40",false,280,24)

		Basic_UI.Set["回蓝药水百分比"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回蓝药水百分比"] = tonumber(Basic_UI.Set["回蓝药水百分比"]:GetText())
		end)
		if Easy_Data["回蓝药水百分比"] ~= nil then
			Basic_UI.Set["回蓝药水百分比"]:SetText(Easy_Data["回蓝药水百分比"])
		else
			Easy_Data["回蓝药水百分比"] = tonumber(Basic_UI.Set["回蓝药水百分比"]:GetText())
		end
	end

	local function Tick_Food_Drink() -- 需要使用吃喝
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["需要吃喝"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_Client("需要使用吃喝回蓝回血","Need use food and drink items to regenerate health and power"))
		Basic_UI.Set["需要吃喝"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要吃喝"]:GetChecked() then
				Easy_Data["需要吃喝"] = true
			elseif not Basic_UI.Set["需要吃喝"]:GetChecked() then
				Easy_Data["需要吃喝"] = false
			end
		end)
		if Easy_Data["需要吃喝"] ~= nil then
			if Easy_Data["需要吃喝"] then
				Basic_UI.Set["需要吃喝"]:SetChecked(true)
			else
				Basic_UI.Set["需要吃喝"]:SetChecked(false)
			end
		else
			Easy_Data["需要吃喝"] = true
			Basic_UI.Set["需要吃喝"]:SetChecked(true)
		end
	end

	local function Enable_Food_Drink() -- 使用吃喝的百分比
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("使用回血物品的血量(%)","Health percent begin use Food item(%)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["回血百分比"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"50",false,280,24)
		Basic_UI.Set["回血百分比"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回血百分比"] = tonumber(Basic_UI.Set["回血百分比"]:GetText())
		end)
		if Easy_Data["回血百分比"] ~= nil then
			Basic_UI.Set["回血百分比"]:SetText(Easy_Data["回血百分比"])
		else
			Easy_Data["回血百分比"]= tonumber(Basic_UI.Set["回血百分比"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("使用回蓝物品的蓝量(%)","Power percent begin use Drink item(%)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["回蓝百分比"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"60",false,280,24)
		Basic_UI.Set["回蓝百分比"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回蓝百分比"] = tonumber(Basic_UI.Set["回蓝百分比"]:GetText())
		end)
		if Easy_Data["回蓝百分比"] ~= nil then
			Basic_UI.Set["回蓝百分比"]:SetText(Easy_Data["回蓝百分比"])
		else
			Easy_Data["回蓝百分比"]= tonumber(Basic_UI.Set["回蓝百分比"]:GetText())
		end
	end

	local function Buy_Food_Drink() -- 自动购买吃喝
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["购买吃喝"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_Client("需要自动购买吃喝物品","Need auto buy food and drink items from merchant"))
		Basic_UI.Set["购买吃喝"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["购买吃喝"]:GetChecked() then
				Easy_Data["购买吃喝"] = true
			elseif not Basic_UI.Set["购买吃喝"]:GetChecked() then
				Easy_Data["购买吃喝"] = false
			end
		end)
		if Easy_Data["购买吃喝"] ~= nil then
			if Easy_Data["购买吃喝"] then
				Basic_UI.Set["购买吃喝"]:SetChecked(true)
			else
				Basic_UI.Set["购买吃喝"]:SetChecked(false)
			end
		else
			Easy_Data["购买吃喝"] = true
			Basic_UI.Set["购买吃喝"]:SetChecked(true)
		end
		
		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["一次性补给"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("一次回城补给所有物品","Replenishment in one time after back to campus"))
		Basic_UI.Set["一次性补给"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["一次性补给"]:GetChecked() then
				Easy_Data["一次性补给"] = true
			elseif not Basic_UI.Set["一次性补给"]:GetChecked() then
				Easy_Data["一次性补给"] = false
			end
		end)
		if Easy_Data["一次性补给"] ~= nil then
			if Easy_Data["一次性补给"] then
				Basic_UI.Set["一次性补给"]:SetChecked(true)
			else
				Basic_UI.Set["一次性补给"]:SetChecked(false)
			end
		else
			Easy_Data["一次性补给"] = true
			Basic_UI.Set["一次性补给"]:SetChecked(true)
		end


	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("低于多少食物或饮料 开始购买","Under the Food or Drink amout, start auto purchase logic")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["最小食物数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"5",false,280,24)

		Basic_UI.Set["最小食物数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["最小食物数量"] = tonumber(Basic_UI.Set["最小食物数量"]:GetText())
		end)
		if Easy_Data["最小食物数量"] ~= nil then
			Basic_UI.Set["最小食物数量"]:SetText(Easy_Data["最小食物数量"])
		else
			Easy_Data["最小食物数量"] = tonumber(Basic_UI.Set["最小食物数量"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("食物保留数量","Food keep amount")) 

		Basic_UI.Set["食物保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py - 20,"50",false,280,24)

		Basic_UI.Set["食物保留数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["食物保留数量"] = tonumber(Basic_UI.Set["食物保留数量"]:GetText())
		end)
		if Easy_Data["食物保留数量"] ~= nil then
			Basic_UI.Set["食物保留数量"]:SetText(Easy_Data["食物保留数量"])
		else
			Easy_Data["食物保留数量"] = tonumber(Basic_UI.Set["食物保留数量"]:GetText())
		end

		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,Check_UI("饮料保留数量","Drink keep amount")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["饮料保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"50",false,280,24)

		Basic_UI.Set["饮料保留数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["饮料保留数量"] = tonumber(Basic_UI.Set["饮料保留数量"]:GetText())
		end)
		if Easy_Data["饮料保留数量"] ~= nil then
			Basic_UI.Set["饮料保留数量"]:SetText(Easy_Data["饮料保留数量"])
		else
			Easy_Data["饮料保留数量"] = tonumber(Basic_UI.Set["饮料保留数量"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("回血药水保留数量","Health potion keep amount")) 

		Basic_UI.Set["回血药水保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py - 20,"15",false,280,24)

		Basic_UI.Set["回血药水保留数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回血药水保留数量"] = tonumber(Basic_UI.Set["回血药水保留数量"]:GetText())
		end)
		if Easy_Data["回血药水保留数量"] ~= nil then
			Basic_UI.Set["回血药水保留数量"]:SetText(Easy_Data["回血药水保留数量"])
		else
			Easy_Data["回血药水保留数量"] = tonumber(Basic_UI.Set["回血药水保留数量"]:GetText())
		end

		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,Check_UI("回蓝药水保留数量","Mana potion keep amount")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["回蓝药水保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"15",false,280,24)

		Basic_UI.Set["回蓝药水保留数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回蓝药水保留数量"] = tonumber(Basic_UI.Set["回蓝药水保留数量"]:GetText())
		end)
		if Easy_Data["回蓝药水保留数量"] ~= nil then
			Basic_UI.Set["回蓝药水保留数量"]:SetText(Easy_Data["回蓝药水保留数量"])
		else
			Easy_Data["回蓝药水保留数量"] = tonumber(Basic_UI.Set["回蓝药水保留数量"]:GetText())
		end
	end

	local function Gather_Corpse()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["采集尸体"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_Client("需要采集尸体","Need gather corpse items"))
		Basic_UI.Set["采集尸体"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["采集尸体"]:GetChecked() then
				Easy_Data["采集尸体"] = true
			elseif not Basic_UI.Set["采集尸体"]:GetChecked() then
				Easy_Data["采集尸体"] = false
			end
		end)
		if Easy_Data["采集尸体"] ~= nil then
			if Easy_Data["采集尸体"] then
				Basic_UI.Set["采集尸体"]:SetChecked(true)
			else
				Basic_UI.Set["采集尸体"]:SetChecked(false)
			end
		else
			Easy_Data["采集尸体"] = false
			Basic_UI.Set["采集尸体"]:SetChecked(false)
		end
	end
	local function Loot_UI()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["需要拾取"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("需要拾取怪物尸体","Loot mobs' bodies"))
		Basic_UI.Set["需要拾取"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要拾取"]:GetChecked() then
				Easy_Data["需要拾取"] = true
			elseif not Basic_UI.Set["需要拾取"]:GetChecked() then
				Easy_Data["需要拾取"] = false
			end
		end)
		if Easy_Data["需要拾取"] ~= nil then
			if Easy_Data["需要拾取"] then
				Basic_UI.Set["需要拾取"]:SetChecked(true)
			else
				Basic_UI.Set["需要拾取"]:SetChecked(false)
			end
		else
			Easy_Data["需要拾取"] = true
			Basic_UI.Set["需要拾取"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["需要剥皮"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("需要剥皮怪物尸体","Skin mobs' bodies"))
		Basic_UI.Set["需要剥皮"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要剥皮"]:GetChecked() then
				Easy_Data["需要剥皮"] = true
			elseif not Basic_UI.Set["需要剥皮"]:GetChecked() then
				Easy_Data["需要剥皮"] = false
			end
		end)
		if Easy_Data["需要剥皮"] ~= nil then
			if Easy_Data["需要剥皮"] then
				Basic_UI.Set["需要剥皮"]:SetChecked(true)
			else
				Basic_UI.Set["需要剥皮"]:SetChecked(false)
			end
		else
			Easy_Data["需要剥皮"] = true
			Basic_UI.Set["需要剥皮"]:SetChecked(true)
		end
	end


	local function Player_Detection() -- 玩家检测
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["玩家检测"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("附近有玩家时, 不打怪 不拾取 不做任务","When players around, stop all reactions"))
		Basic_UI.Set["玩家检测"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["玩家检测"]:GetChecked() then
				Easy_Data["玩家检测"] = true
			elseif not Basic_UI.Set["玩家检测"]:GetChecked() then
				Easy_Data["玩家检测"] = false
			end
		end)
		if Easy_Data["玩家检测"] ~= nil then
			if Easy_Data["玩家检测"] then
				Basic_UI.Set["玩家检测"]:SetChecked(true)
			else
				Basic_UI.Set["玩家检测"]:SetChecked(false)
			end
		else
			Easy_Data["玩家检测"] = false
			Basic_UI.Set["玩家检测"]:SetChecked(false)
		end
		
		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("附近玩家检测范围 (码)","Player detect distance (yard)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["玩家检测距离"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"10",false,280,24)
		Basic_UI.Set["玩家检测距离"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["玩家检测距离"] = tonumber(Basic_UI.Set["玩家检测距离"]:GetText())
		end)
		if Easy_Data["玩家检测距离"] ~= nil then
			Basic_UI.Set["玩家检测距离"]:SetText(Easy_Data["玩家检测距离"])
		else
			Easy_Data["玩家检测距离"]= tonumber(Basic_UI.Set["玩家检测距离"]:GetText())
		end
	end

	local function Only_Kill_Myself() -- 不击杀其他玩家目标
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["只击杀无目标怪物"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("只击杀无目标怪物","Only kill mobs with no other target players"))
		Basic_UI.Set["只击杀无目标怪物"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["只击杀无目标怪物"]:GetChecked() then
				Easy_Data["只击杀无目标怪物"] = true
			elseif not Basic_UI.Set["只击杀无目标怪物"]:GetChecked() then
				Easy_Data["只击杀无目标怪物"] = false
			end
		end)
		if Easy_Data["只击杀无目标怪物"] ~= nil then
			if Easy_Data["只击杀无目标怪物"] then
				Basic_UI.Set["只击杀无目标怪物"]:SetChecked(true)
			else
				Basic_UI.Set["只击杀无目标怪物"]:SetChecked(false)
			end
		else
			Easy_Data["只击杀无目标怪物"] = true
			Basic_UI.Set["只击杀无目标怪物"]:SetChecked(true)
		end
	end

	local function Hunter_Bullet()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("弹药小于数值自动购买","Amount of needing to purchase ammo")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["子弹最小数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"100",false,280,24)
		Basic_UI.Set["子弹最小数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["子弹最小数量"] = tonumber(Basic_UI.Set["子弹最小数量"]:GetText())
		end)
		if Easy_Data["子弹最小数量"] ~= nil then
			Basic_UI.Set["子弹最小数量"]:SetText(Easy_Data["子弹最小数量"])
		else
			Easy_Data["子弹最小数量"]= tonumber(Basic_UI.Set["子弹最小数量"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("弹药大于数值停止购买","Amount of stop purchasing ammo")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["子弹最大数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"500",false,280,24)
		Basic_UI.Set["子弹最大数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["子弹最大数量"] = tonumber(Basic_UI.Set["子弹最大数量"]:GetText())
		end)
		if Easy_Data["子弹最大数量"] ~= nil then
			Basic_UI.Set["子弹最大数量"]:SetText(Easy_Data["子弹最大数量"])
		else
			Easy_Data["子弹最大数量"]= tonumber(Basic_UI.Set["子弹最大数量"]:GetText())
		end
	end

	local function Hunter_callpet() -- 猎人宠物
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["需要召唤宠物"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_Client("猎人需要召唤宠物 (宠物先自己抓)","Hunter needs to call pet to fight with character (you need to have one first)"))
		Basic_UI.Set["需要召唤宠物"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要召唤宠物"]:GetChecked() then
				Easy_Data["需要召唤宠物"] = true
			elseif not Basic_UI.Set["需要召唤宠物"]:GetChecked() then
				Easy_Data["需要召唤宠物"] = false
			end
		end)
		if Easy_Data["需要召唤宠物"] ~= nil then
			if Easy_Data["需要召唤宠物"] then
				Basic_UI.Set["需要召唤宠物"]:SetChecked(true)
			else
				Basic_UI.Set["需要召唤宠物"]:SetChecked(false)
			end
		else
			Easy_Data["需要召唤宠物"] = true
			Basic_UI.Set["需要召唤宠物"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("宠物食物名字","Pet Food Full Name")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["宠物食物"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("硬肉干","Tough Jerky"),false,280,24)
		Basic_UI.Set["宠物食物"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["宠物食物"] = Basic_UI.Set["宠物食物"]:GetText()
		end)
		if Easy_Data["宠物食物"] ~= nil then
			Basic_UI.Set["宠物食物"]:SetText(Easy_Data["宠物食物"])
		else
			Easy_Data["宠物食物"]= Basic_UI.Set["宠物食物"]:GetText()
		end

		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,Check_UI("宠物食物购买数量","Pet Food Buy Amount")) 

			Basic_UI.Set.Py = Basic_UI.Set.Py - 20

			Basic_UI.Set["宠物食物数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"15",false,280,24)
			Basic_UI.Set["宠物食物数量"]:SetScript("OnEditFocusLost", function(self)
				Easy_Data["宠物食物数量"] = tonumber(Basic_UI.Set["宠物食物数量"]:GetText())
			end)
			if Easy_Data["宠物食物数量"] ~= nil then
				Basic_UI.Set["宠物食物数量"]:SetText(Easy_Data["宠物食物数量"])
			else
				Easy_Data["宠物食物数量"]= tonumber(Basic_UI.Set["宠物食物数量"]:GetText())
			end

			Basic_UI.Set.Py = Basic_UI.Set.Py - 30
			local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("宠物商人名字","Pet Vendor NPC Full Name")) 

			Basic_UI.Set.Py = Basic_UI.Set.Py - 20

			Basic_UI.Set["宠物商人名字"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("旅店老板格罗斯克","Innkeeper Grosk"),false,280,24)
			Basic_UI.Set["宠物商人名字"]:SetScript("OnEditFocusLost", function(self)
				Easy_Data["宠物商人名字"] = Basic_UI.Set["宠物商人名字"]:GetText()
			end)
			if Easy_Data["宠物商人名字"] ~= nil then
				Basic_UI.Set["宠物商人名字"]:SetText(Easy_Data["宠物商人名字"])
			else
				Easy_Data["宠物商人名字"]= Basic_UI.Set["宠物商人名字"]:GetText()
			end

			Basic_UI.Set["获取商人名字"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取目标名字","Generate Full Name"))
			Basic_UI.Set["获取商人名字"]:SetSize(150,24)
			Basic_UI.Set["获取商人名字"]:SetScript("OnClick", function(self)
				if awm.ObjectExists("target") then
					local name = awm.UnitFullName("target")
					if name == nil then
						textout(Check_UI("商人名字为空","A blank name"))
						return
					end
					Basic_UI.Set["宠物商人名字"]:SetText(name)
					Easy_Data["宠物商人名字"] = name
				else
					textout(Check_UI("请先选择一个目标","Choose a target first"))
				end
			end)

			Basic_UI.Set.Py = Basic_UI.Set.Py - 30
			local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("宠物商人坐标","Pet Vendor NPC Coordinate")) 

			Basic_UI.Set.Py = Basic_UI.Set.Py - 20

			Basic_UI.Set["宠物商人坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"1411,340,-4687,16",false,280,24)
			Basic_UI.Set["宠物商人坐标"]:SetScript("OnEditFocusLost", function(self)
				Easy_Data["宠物商人坐标"] = Basic_UI.Set["宠物商人坐标"]:GetText()
			end)
			if Easy_Data["宠物商人坐标"] ~= nil then
				Basic_UI.Set["宠物商人坐标"]:SetText(Easy_Data["宠物商人坐标"])
			else
				Easy_Data["宠物商人坐标"]= Basic_UI.Set["宠物商人坐标"]:GetText()
			end

			Basic_UI.Set["获取商人坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
			Basic_UI.Set["获取商人坐标"]:SetSize(150,24)
			Basic_UI.Set["获取商人坐标"]:SetScript("OnClick", function(self)
				local x,y,z = awm.ObjectPosition("player")
				local Current_Map = C_Map.GetBestMapForUnit("player")
				local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
				Basic_UI.Set["宠物商人坐标"]:SetText(string)
				Easy_Data["宠物商人坐标"] = string
			end)
	end

	Frame_Create()
	Button_Create()
	Gathering_Set_UI()
	Max_Gather_Time_UI()
	Hearth_stone()
	FightBack_Choose_UI()
	Gather_Set_UI()

	Tick_Food_Drink()
	Enable_Food_Drink()
	Buy_Food_Drink()

	Gather_Corpse()
	Loot_UI()
	Player_Detection()
	Only_Kill_Myself()

	if Class == "HUNTER" then
		Hunter_Bullet()
		Hunter_callpet()
	end
end

local function Create_Sell_UI() -- 出售UI
    Basic_UI.Sell = {}
	Basic_UI.Sell.Py = -10
	local function Frame_Create()
		Basic_UI.Sell.frame = CreateFrame('frame',"Basic_UI.Sell.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Sell.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Sell.frame:SetSize(600,1500)
		Basic_UI.Sell.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Sell.frame:Hide()
		Basic_UI.Sell.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Sell.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Sell.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("出售","vendor"))
		Basic_UI.Sell.button:SetSize(130,20)
		Basic_UI.Sell.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Sell.frame:Show()
			Basic_UI.Sell.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Sell.frame:Hide() Basic_UI.Sell.button:SetBackdropColor(0,0,0,0) end
	end

	local function Need_Vendor()
	    Basic_UI.Sell["需要卖物"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",10, Basic_UI.Sell.Py, Check_UI("需要卖物","Need Vendor"))
		Basic_UI.Sell["需要卖物"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["需要卖物"]:GetChecked() then
				Easy_Data["需要卖物"] = true
			elseif not Basic_UI.Sell["需要卖物"]:GetChecked() then
				Easy_Data["需要卖物"] = false
			end
		end)
		if Easy_Data["需要卖物"] ~= nil then
			if Easy_Data["需要卖物"] then
				Basic_UI.Sell["需要卖物"]:SetChecked(true)
			else
				Basic_UI.Sell["需要卖物"]:SetChecked(false)
			end
		else
			Easy_Data["需要卖物"] = true
			Basic_UI.Sell["需要卖物"]:SetChecked(true)
		end

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		Basic_UI.Sell["模糊字售卖"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",10, Basic_UI.Sell.Py, Check_UI("模糊字售卖","Vague word vendor items"))
		Basic_UI.Sell["模糊字售卖"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["模糊字售卖"]:GetChecked() then
				Easy_Data["模糊字售卖"] = true
			elseif not Basic_UI.Sell["模糊字售卖"]:GetChecked() then
				Easy_Data["模糊字售卖"] = false
			end
		end)
		if Easy_Data["模糊字售卖"] ~= nil then
			if Easy_Data["模糊字售卖"] then
				Basic_UI.Sell["模糊字售卖"]:SetChecked(true)
			else
				Basic_UI.Sell["模糊字售卖"]:SetChecked(false)
			end
		else
			Easy_Data["模糊字售卖"] = false
			Basic_UI.Sell["模糊字售卖"]:SetChecked(false)
		end

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		Basic_UI.Sell["需要修理"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",10, Basic_UI.Sell.Py, Check_UI("需要修理","Need Repair"))
		Basic_UI.Sell["需要修理"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["需要修理"]:GetChecked() then
				Easy_Data["需要修理"] = true
			elseif not Basic_UI.Sell["需要修理"]:GetChecked() then
				Easy_Data["需要修理"] = false
			end
		end)
		if Easy_Data["需要修理"] ~= nil then
			if Easy_Data["需要修理"] then
				Basic_UI.Sell["需要修理"]:SetChecked(true)
			else
				Basic_UI.Sell["需要修理"]:SetChecked(false)
			end
		else
			Easy_Data["需要修理"] = true
			Basic_UI.Sell["需要修理"]:SetChecked(true)
		end

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		local Header1 = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("触发修理耐久度","Inventory durability to fix")) 

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20

		Basic_UI.Sell["修理耐久度"] = Create_EditBox(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,"0.1",false,280,24)
		Basic_UI.Sell["修理耐久度"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["修理耐久度"] = tonumber(Basic_UI.Sell["修理耐久度"]:GetText())
		end)
		if Easy_Data["修理耐久度"] ~= nil then
			Basic_UI.Sell["修理耐久度"]:SetText(Easy_Data["修理耐久度"])
		else
			Easy_Data["修理耐久度"]= tonumber(Basic_UI.Sell["修理耐久度"]:GetText())
		end
	end

	local function Custom_Vendor()
	    Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		Basic_UI.Sell["自定义商人"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",10, Basic_UI.Sell.Py, Check_UI("自定义商人信息","Custom Vendor Info"))
		Basic_UI.Sell["自定义商人"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["自定义商人"]:GetChecked() then
				Easy_Data["自定义商人"] = true
			elseif not Basic_UI.Sell["自定义商人"]:GetChecked() then
				Easy_Data["自定义商人"] = false
			end
		end)
		if Easy_Data["自定义商人"] ~= nil then
			if Easy_Data["自定义商人"] then
				Basic_UI.Sell["自定义商人"]:SetChecked(true)
			else
				Basic_UI.Sell["自定义商人"]:SetChecked(false)
			end
		else
			Easy_Data["自定义商人"] = false
			Basic_UI.Sell["自定义商人"]:SetChecked(false)
		end

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		local Header1 = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("自定义商人名字","Custom Vendor Full Name")) 

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20

		Basic_UI.Sell["自定义商人名字"] = Create_EditBox(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)
		Basic_UI.Sell["自定义商人名字"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自定义商人名字"] = Basic_UI.Sell["自定义商人名字"]:GetText()
		end)
		if Easy_Data["自定义商人名字"] ~= nil then
			Basic_UI.Sell["自定义商人名字"]:SetText(Easy_Data["自定义商人名字"])
		else
			Easy_Data["自定义商人名字"]= Basic_UI.Sell["自定义商人名字"]:GetText()
		end

		Basic_UI.Sell["获取商人名字"] = Create_Button(Basic_UI.Sell.frame,"TOPLEFT",320, Basic_UI.Sell.Py,Check_UI("获取目标名字","Generate Full Name"))
		Basic_UI.Sell["获取商人名字"]:SetSize(150,24)
		Basic_UI.Sell["获取商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Sell["自定义商人名字"]:SetText(name)
				Easy_Data["自定义商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		local Header1 = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("自定义商人坐标","Custom Vendor Coordinate")) 

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20

		Basic_UI.Sell["自定义商人坐标"] = Create_EditBox(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,"mapid,x,y,z",false,280,24)
		Basic_UI.Sell["自定义商人坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自定义商人坐标"] = Basic_UI.Sell["自定义商人坐标"]:GetText()
		end)
		if Easy_Data["自定义商人坐标"] ~= nil then
			Basic_UI.Sell["自定义商人坐标"]:SetText(Easy_Data["自定义商人坐标"])
		else
			Easy_Data["自定义商人坐标"]= Basic_UI.Sell["自定义商人坐标"]:GetText()
		end

		Basic_UI.Sell["获取商人坐标"] = Create_Button(Basic_UI.Sell.frame,"TOPLEFT",320, Basic_UI.Sell.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Sell["获取商人坐标"]:SetSize(150,24)
		Basic_UI.Sell["获取商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Sell["自定义商人坐标"]:SetText(string)
			Easy_Data["自定义商人坐标"] = string
		end)
	end

	local function Vendor_Trigger()
	    Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		local Header1 = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("背包剩余多少格, 回城卖物","Freeslots less than how many number to vendor")) 

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20

		Basic_UI.Sell["卖物格数"] = Create_EditBox(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,"15",false,280,24)
		Basic_UI.Sell["卖物格数"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["卖物格数"] = tonumber(Basic_UI.Sell["卖物格数"]:GetText())
		end)
		if Easy_Data["卖物格数"] ~= nil then
			Basic_UI.Sell["卖物格数"]:SetText(Easy_Data["卖物格数"])
		else
			Easy_Data["卖物格数"]= tonumber(Basic_UI.Sell["卖物格数"]:GetText())
		end
	end
	local function Item_Color_UI() -- 售卖颜色
	    Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
	    local Header1 = Create_Header(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,Check_UI("售卖颜色","Vendor Item Color")) 

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20
		Basic_UI.Sell["灰色"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",10, Basic_UI.Sell.Py, Check_UI("灰色","Grey"))
		Basic_UI.Sell["灰色"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["灰色"]:GetChecked() then
				Easy_Data["灰色"] = true
			elseif not Basic_UI.Sell["灰色"]:GetChecked() then
				Easy_Data["灰色"] = false
			end
		end)
		if Easy_Data["灰色"] ~= nil then
			if Easy_Data["灰色"] then
				Basic_UI.Sell["灰色"]:SetChecked(true)
			else
				Basic_UI.Sell["灰色"]:SetChecked(false)
			end
		else
			Easy_Data["灰色"] = true
			Basic_UI.Sell["灰色"]:SetChecked(true)
		end

		Basic_UI.Sell["白色"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",80, Basic_UI.Sell.Py, Check_UI("白色","White"))
		Basic_UI.Sell["白色"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["白色"]:GetChecked() then
				Easy_Data["白色"] = true
			elseif not Basic_UI.Sell["白色"]:GetChecked() then
				Easy_Data["白色"] = false
			end
		end)
		if Easy_Data["白色"] ~= nil then
			if Easy_Data["白色"] then
				Basic_UI.Sell["白色"]:SetChecked(true)
			else
				Basic_UI.Sell["白色"]:SetChecked(false)
			end
		else
			Easy_Data["白色"] = true
			Basic_UI.Sell["白色"]:SetChecked(true)
		end

		Basic_UI.Sell["绿色"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",150, Basic_UI.Sell.Py, Check_UI("绿色","Green"))
		Basic_UI.Sell["绿色"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["绿色"]:GetChecked() then
				Easy_Data["绿色"] = true
			elseif not Basic_UI.Sell["绿色"]:GetChecked() then
				Easy_Data["绿色"] = false
			end
		end)
		if Easy_Data["绿色"] ~= nil then
			if Easy_Data["绿色"] then
				Basic_UI.Sell["绿色"]:SetChecked(true)
			else
				Basic_UI.Sell["绿色"]:SetChecked(false)
			end
		else
			Easy_Data["绿色"] = true
			Basic_UI.Sell["绿色"]:SetChecked(true)
		end

		Basic_UI.Sell["蓝色"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",220, Basic_UI.Sell.Py, Check_UI("蓝色","Blue"))
		Basic_UI.Sell["蓝色"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["蓝色"]:GetChecked() then
				Easy_Data["蓝色"] = true
			elseif not Basic_UI.Sell["蓝色"]:GetChecked() then
				Easy_Data["蓝色"] = false
			end
		end)
		if Easy_Data["蓝色"] ~= nil then
			if Easy_Data["蓝色"] then
				Basic_UI.Sell["蓝色"]:SetChecked(true)
			else
				Basic_UI.Sell["蓝色"]:SetChecked(false)
			end
		else
			Easy_Data["蓝色"] = true
			Basic_UI.Sell["蓝色"]:SetChecked(true)
		end

		Basic_UI.Sell["紫色"] = Create_Check_Button(Basic_UI.Sell.frame, "TOPLEFT",290, Basic_UI.Sell.Py, Check_UI("紫色","Purple"))
		Basic_UI.Sell["紫色"]:SetScript("OnClick", function(self)
			if Basic_UI.Sell["紫色"]:GetChecked() then
				Easy_Data["紫色"] = true
			elseif not Basic_UI.Sell["紫色"]:GetChecked() then
				Easy_Data["紫色"] = false
			end
		end)
		if Easy_Data["紫色"] ~= nil then
			if Easy_Data["紫色"] then
				Basic_UI.Sell["紫色"]:SetChecked(true)
			else
				Basic_UI.Sell["紫色"]:SetChecked(false)
			end
		else
			Easy_Data["紫色"] = true
			Basic_UI.Sell["紫色"]:SetChecked(true)
		end
	end

	local function Keep_Item() -- 保留物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["保留物品"],",")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Sell["保留列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
	    local header = Create_Header(Basic_UI.Sell.frame,"TopLeft",10,Basic_UI.Sell.Py,Check_UI("保留物品","Keep Item"))

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 20
	    Basic_UI.Sell["保留物品"] = Create_Scroll_Edit(Basic_UI.Sell.frame,"TopLeft",10,Basic_UI.Sell.Py,Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal"),570,100)

		Basic_UI.Sell["保留物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["保留物品"] = Basic_UI.Sell["保留物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["保留物品"] == nil then
            Easy_Data["保留物品"] = Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal")
        else
            Basic_UI.Sell["保留物品"]:SetText(Easy_Data["保留物品"])
        end

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 80

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 30
		Basic_UI.Sell["保留列表"] = Create_Scroll(Basic_UI.Sell.frame,"TopLeft",10,Basic_UI.Sell.Py,570,200)

		Basic_UI.Sell.Py = Basic_UI.Sell.Py - 180

		Update_List()
	end

	Frame_Create()
	Button_Create()
	Need_Vendor()
	Custom_Vendor()
	Vendor_Trigger()
	Item_Color_UI()
	Keep_Item()
end

local function Create_Destroy_UI() -- 摧毁UI
    Basic_UI.Destroy = {}
	Basic_UI.Destroy.Py = -10
	local function Frame_Create()
		Basic_UI.Destroy.frame = CreateFrame('frame',"Basic_UI.Destroy.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Destroy.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Destroy.frame:SetSize(600,1500)
		Basic_UI.Destroy.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Destroy.frame:Hide()
		Basic_UI.Destroy.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Destroy.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Destroy.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("摧毁","destroy"))
		Basic_UI.Destroy.button:SetSize(130,20)
		Basic_UI.Destroy.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Destroy.frame:Show()
			Basic_UI.Destroy.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Destroy.frame:Hide() Basic_UI.Destroy.button:SetBackdropColor(0,0,0,0) end
	end

	local function Destroy_Color_UI() -- 摧毁颜色
	    local Header1 = Create_Header(Basic_UI.Destroy.frame,"TOPLEFT",10, Basic_UI.Destroy.Py,Check_UI("摧毁颜色","Destroy Item Color")) 

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 20
		Basic_UI.Destroy["摧毁灰色"] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT",10, Basic_UI.Destroy.Py, Check_UI("灰色","Grey"))
		Basic_UI.Destroy["摧毁灰色"]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy["摧毁灰色"]:GetChecked() then
				Easy_Data["摧毁灰色"] = true
			elseif not Basic_UI.Destroy["摧毁灰色"]:GetChecked() then
				Easy_Data["摧毁灰色"] = false
			end
		end)
		if Easy_Data["摧毁灰色"] ~= nil then
			if Easy_Data["摧毁灰色"] then
				Basic_UI.Destroy["摧毁灰色"]:SetChecked(true)
			else
				Basic_UI.Destroy["摧毁灰色"]:SetChecked(false)
			end
		else
			Easy_Data["摧毁灰色"] = false
			Basic_UI.Destroy["摧毁灰色"]:SetChecked(false)
		end

		Basic_UI.Destroy["摧毁白色"] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT",80, Basic_UI.Destroy.Py, Check_UI("白色","White"))
		Basic_UI.Destroy["摧毁白色"]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy["摧毁白色"]:GetChecked() then
				Easy_Data["摧毁白色"] = true
			elseif not Basic_UI.Destroy["摧毁白色"]:GetChecked() then
				Easy_Data["摧毁白色"] = false
			end
		end)
		if Easy_Data["摧毁白色"] ~= nil then
			if Easy_Data["摧毁白色"] then
				Basic_UI.Destroy["摧毁白色"]:SetChecked(true)
			else
				Basic_UI.Destroy["摧毁白色"]:SetChecked(false)
			end
		else
			Easy_Data["摧毁白色"] = false
			Basic_UI.Destroy["摧毁白色"]:SetChecked(false)
		end

		Basic_UI.Destroy["摧毁绿色"] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT",150, Basic_UI.Destroy.Py, Check_UI("绿色","Green"))
		Basic_UI.Destroy["摧毁绿色"]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy["摧毁绿色"]:GetChecked() then
				Easy_Data["摧毁绿色"] = true
			elseif not Basic_UI.Destroy["摧毁绿色"]:GetChecked() then
				Easy_Data["摧毁绿色"] = false
			end
		end)
		if Easy_Data["摧毁绿色"] ~= nil then
			if Easy_Data["摧毁绿色"] then
				Basic_UI.Destroy["摧毁绿色"]:SetChecked(true)
			else
				Basic_UI.Destroy["摧毁绿色"]:SetChecked(false)
			end
		else
			Easy_Data["摧毁绿色"] = false
			Basic_UI.Destroy["摧毁绿色"]:SetChecked(false)
		end

		Basic_UI.Destroy["摧毁蓝色"] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT",220, Basic_UI.Destroy.Py, Check_UI("蓝色","Blue"))
		Basic_UI.Destroy["摧毁蓝色"]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy["摧毁蓝色"]:GetChecked() then
				Easy_Data["摧毁蓝色"] = true
			elseif not Basic_UI.Destroy["摧毁蓝色"]:GetChecked() then
				Easy_Data["摧毁蓝色"] = false
			end
		end)
		if Easy_Data["摧毁蓝色"] ~= nil then
			if Easy_Data["摧毁蓝色"] then
				Basic_UI.Destroy["摧毁蓝色"]:SetChecked(true)
			else
				Basic_UI.Destroy["摧毁蓝色"]:SetChecked(false)
			end
		else
			Easy_Data["摧毁蓝色"] = false
			Basic_UI.Destroy["摧毁蓝色"]:SetChecked(false)
		end

		Basic_UI.Destroy["摧毁紫色"] = Create_Check_Button(Basic_UI.Destroy.frame, "TOPLEFT",290, Basic_UI.Destroy.Py, Check_UI("紫色","Purple"))
		Basic_UI.Destroy["摧毁紫色"]:SetScript("OnClick", function(self)
			if Basic_UI.Destroy["摧毁紫色"]:GetChecked() then
				Easy_Data["摧毁紫色"] = true
			elseif not Basic_UI.Destroy["摧毁紫色"]:GetChecked() then
				Easy_Data["摧毁紫色"] = false
			end
		end)
		if Easy_Data["摧毁紫色"] ~= nil then
			if Easy_Data["摧毁紫色"] then
				Basic_UI.Destroy["摧毁紫色"]:SetChecked(true)
			else
				Basic_UI.Destroy["摧毁紫色"]:SetChecked(false)
			end
		else
			Easy_Data["摧毁紫色"] = false
			Basic_UI.Destroy["摧毁紫色"]:SetChecked(false)
		end
	end

	local function Destroy_Item() -- 摧毁物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["摧毁物品"],",")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Destroy["摧毁列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 30
	    local header = Create_Header(Basic_UI.Destroy.frame,"TopLeft",10,Basic_UI.Destroy.Py,Check_UI("摧毁物品","Destroy Item"))

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 20
	    Basic_UI.Destroy["摧毁物品"] = Create_Scroll_Edit(Basic_UI.Destroy.frame,"TopLeft",10,Basic_UI.Destroy.Py,Check_UI("铜矿,银矿,铁矿石","item1,item2,item3"),570,100)

		Basic_UI.Destroy["摧毁物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["摧毁物品"] = Basic_UI.Destroy["摧毁物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["摧毁物品"] == nil then
            Easy_Data["摧毁物品"] = Check_UI("铜矿,银矿,铁矿石","item1,item2,item3")
        else
            Basic_UI.Destroy["摧毁物品"]:SetText(Easy_Data["摧毁物品"])
        end

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 80

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 30
		Basic_UI.Destroy["摧毁列表"] = Create_Scroll(Basic_UI.Destroy.frame,"TopLeft",10,Basic_UI.Destroy.Py,570,200)

		Basic_UI.Destroy.Py = Basic_UI.Destroy.Py - 180

		Update_List()
	end

	Frame_Create()
	Button_Create()
	Destroy_Color_UI()
	Destroy_Item()
end

local function Create_Mail_UI() -- 邮寄UI
    Basic_UI.Mail = {}
	Basic_UI.Mail.Py = -10
	local function Frame_Create()
		Basic_UI.Mail.frame = CreateFrame('frame',"Basic_UI.Mail.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Mail.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Mail.frame:SetSize(600,1500)
		Basic_UI.Mail.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Mail.frame:Hide()
		Basic_UI.Mail.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Mail.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Mail.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("邮寄","mail"))
		Basic_UI.Mail.button:SetSize(130,20)
		Basic_UI.Mail.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Mail.frame:Show()
			Basic_UI.Mail.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Mail.frame:Hide() Basic_UI.Mail.button:SetBackdropColor(0,0,0,0) end
	end

	local function Need_Mail()
	    Basic_UI.Mail["需要邮寄"] = Create_Check_Button(Basic_UI.Mail.frame, "TOPLEFT",10, Basic_UI.Mail.Py, Check_UI("需要邮寄","Need Mail"))
		Basic_UI.Mail["需要邮寄"]:SetScript("OnClick", function(self)
			if Basic_UI.Mail["需要邮寄"]:GetChecked() then
				Easy_Data["需要邮寄"] = true
			elseif not Basic_UI.Mail["需要邮寄"]:GetChecked() then
				Easy_Data["需要邮寄"] = false
			end
		end)
		if Easy_Data["需要邮寄"] ~= nil then
			if Easy_Data["需要邮寄"] then
				Basic_UI.Mail["需要邮寄"]:SetChecked(true)
			else
				Basic_UI.Mail["需要邮寄"]:SetChecked(false)
			end
		else
			Easy_Data["需要邮寄"] = false
			Basic_UI.Mail["需要邮寄"]:SetChecked(false)
		end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		Basic_UI.Mail["卖物前邮寄"] = Create_Check_Button(Basic_UI.Mail.frame, "TOPLEFT",10, Basic_UI.Mail.Py, Check_UI("卖物前先进行邮寄","Mail before every vendor process"))
		Basic_UI.Mail["卖物前邮寄"]:SetScript("OnClick", function(self)
			if Basic_UI.Mail["卖物前邮寄"]:GetChecked() then
				Easy_Data["卖物前邮寄"] = true
			elseif not Basic_UI.Mail["卖物前邮寄"]:GetChecked() then
				Easy_Data["卖物前邮寄"] = false
			end
		end)
		if Easy_Data["卖物前邮寄"] ~= nil then
			if Easy_Data["卖物前邮寄"] then
				Basic_UI.Mail["卖物前邮寄"]:SetChecked(true)
			else
				Basic_UI.Mail["卖物前邮寄"]:SetChecked(false)
			end
		else
			Easy_Data["卖物前邮寄"] = true
			Basic_UI.Mail["卖物前邮寄"]:SetChecked(true)
		end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		Basic_UI.Mail["模糊字邮寄"] = Create_Check_Button(Basic_UI.Mail.frame, "TOPLEFT",10, Basic_UI.Mail.Py, Check_UI("模糊字邮寄","Vague word mail items"))
		Basic_UI.Mail["模糊字邮寄"]:SetScript("OnClick", function(self)
			if Basic_UI.Mail["模糊字邮寄"]:GetChecked() then
				Easy_Data["模糊字邮寄"] = true
			elseif not Basic_UI.Mail["模糊字邮寄"]:GetChecked() then
				Easy_Data["模糊字邮寄"] = false
			end
		end)
		if Easy_Data["模糊字邮寄"] ~= nil then
			if Easy_Data["模糊字邮寄"] then
				Basic_UI.Mail["模糊字邮寄"]:SetChecked(true)
			else
				Basic_UI.Mail["模糊字邮寄"]:SetChecked(false)
			end
		else
			Easy_Data["模糊字邮寄"] = false
			Basic_UI.Mail["模糊字邮寄"]:SetChecked(false)
		end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
	    Basic_UI.Mail["自定义邮箱"] = Create_Check_Button(Basic_UI.Mail.frame, "TOPLEFT",10, Basic_UI.Mail.Py, Check_UI("自定义邮箱","Custom Mail Coord"))
		Basic_UI.Mail["自定义邮箱"]:SetScript("OnClick", function(self)
			if Basic_UI.Mail["自定义邮箱"]:GetChecked() then
				Easy_Data["自定义邮箱"] = true
			elseif not Basic_UI.Mail["自定义邮箱"]:GetChecked() then
				Easy_Data["自定义邮箱"] = false
			end
		end)
		if Easy_Data["自定义邮箱"] ~= nil then
			if Easy_Data["自定义邮箱"] then
				Basic_UI.Mail["自定义邮箱"]:SetChecked(true)
			else
				Basic_UI.Mail["自定义邮箱"]:SetChecked(false)
			end
		else
			Easy_Data["自定义邮箱"] = false
			Basic_UI.Mail["自定义邮箱"]:SetChecked(false)
		end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		local Header1 = Create_Header(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,Check_UI("自定义邮箱坐标","Custom Mail Coordinate")) 

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20

		Basic_UI.Mail["自定义邮箱坐标"] = Create_EditBox(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,"mapid,x,y,z",false,280,24)
		Basic_UI.Mail["自定义邮箱坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自定义邮箱坐标"] = Basic_UI.Mail["自定义邮箱坐标"]:GetText()
		end)
		if Easy_Data["自定义邮箱坐标"] ~= nil then
			Basic_UI.Mail["自定义邮箱坐标"]:SetText(Easy_Data["自定义邮箱坐标"])
		else
			Easy_Data["自定义邮箱坐标"]= Basic_UI.Mail["自定义邮箱坐标"]:GetText()
		end

		Basic_UI.Mail["获取邮箱坐标"] = Create_Button(Basic_UI.Mail.frame,"TOPLEFT",320, Basic_UI.Mail.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Mail["获取邮箱坐标"]:SetSize(150,24)
		Basic_UI.Mail["获取邮箱坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Mail["自定义邮箱坐标"]:SetText(string)
			Easy_Data["自定义邮箱坐标"] = string
		end)
	end

	local function Mail_Name()
	    Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		local Header2 = Create_Header(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,Check_UI("邮寄角色名字","Character name of receive mails")) 

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20
		Basic_UI.Mail["邮寄角色"] = Create_EditBox(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,"我是你的小姐姐",false,280,24)
		Basic_UI.Mail["邮寄角色"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["邮寄角色"] = Basic_UI.Mail["邮寄角色"]:GetText()
		end)
		if Easy_Data["邮寄角色"] ~= nil then
			Basic_UI.Mail["邮寄角色"]:SetText(Easy_Data["邮寄角色"])
		else
			Easy_Data["邮寄角色"] = Basic_UI.Mail["邮寄角色"]:GetText()
		end
	end

	local function trigger_mail()
	    Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		local Header2 = Create_Header(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,Check_UI("多少金币触发邮寄","Over the amount of gold, go to mailbox")) 

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20
		Basic_UI.Mail["触发邮寄"] = Create_EditBox(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,"1000",false,280,24)
		Basic_UI.Mail["触发邮寄"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["触发邮寄"] = tonumber(Basic_UI.Mail["触发邮寄"]:GetText())
		end)
		if Easy_Data["触发邮寄"] ~= nil then
			Basic_UI.Mail["触发邮寄"]:SetText(Easy_Data["触发邮寄"])
		else
			Easy_Data["触发邮寄"] = tonumber(Basic_UI.Mail["触发邮寄"]:GetText())
		end
	end

	local function Mail_Gold()
	    Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
	    Basic_UI.Mail["邮寄金币"] = Create_Check_Button(Basic_UI.Mail.frame, "TOPLEFT",10, Basic_UI.Mail.Py, Check_UI("邮寄金币","Need Mail Gold"))
		Basic_UI.Mail["邮寄金币"]:SetScript("OnClick", function(self)
			if Basic_UI.Mail["邮寄金币"]:GetChecked() then
				Easy_Data["邮寄金币"] = true
			elseif not Basic_UI.Mail["邮寄金币"]:GetChecked() then
				Easy_Data["邮寄金币"] = false
			end
		end)
		if Easy_Data["邮寄金币"] ~= nil then
			if Easy_Data["邮寄金币"] then
				Basic_UI.Mail["邮寄金币"]:SetChecked(true)
			else
				Basic_UI.Mail["邮寄金币"]:SetChecked(false)
			end
		else
			Easy_Data["邮寄金币"] = true
			Basic_UI.Mail["邮寄金币"]:SetChecked(true)
		end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		local Header2 = Create_Header(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,Check_UI("保留金币数量","Amount of gold keep in bag")) 

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20
		Basic_UI.Mail["保留金币"] = Create_EditBox(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,"100",false,280,24)
		Basic_UI.Mail["保留金币"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["保留金币"] = tonumber(Basic_UI.Mail["保留金币"]:GetText())
		end)
		if Easy_Data["保留金币"] ~= nil then
			Basic_UI.Mail["保留金币"]:SetText(Easy_Data["保留金币"])
		else
			Easy_Data["保留金币"] = tonumber(Basic_UI.Mail["保留金币"]:GetText())
		end
	end

	local function Mail_Item() -- 邮寄物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["邮寄物品"],",")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Mail["邮寄列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
	    local header = Create_Header(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,Check_UI("邮寄物品","Mail Item"))

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20
	    Basic_UI.Mail["邮寄物品"] = Create_Scroll_Edit(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal"),570,100)

		Basic_UI.Mail["邮寄物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["邮寄物品"] = Basic_UI.Mail["邮寄物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["邮寄物品"] == nil then
            Easy_Data["邮寄物品"] = Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal")
        else
            Basic_UI.Mail["邮寄物品"]:SetText(Easy_Data["邮寄物品"])
        end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 80

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		Basic_UI.Mail["邮寄列表"] = Create_Scroll(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,570,200)

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 180

		Update_List()
	end

	local function Save_Mail_Item() -- 邮寄过滤物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["邮寄过滤物品"],",")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Mail["邮寄过滤列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
					else
					    Keep_Frame[i]:SetPoint("TOPLEFT",10, (-30 * (i - 1) - 10))
						Keep_Frame[i]:SetText(ItemList[i].."("..i..")")
						Keep_Frame[i]:Show()
					end
				end
			end

			if #Keep_Frame > #ItemList then
				for i = #ItemList + 1,#Keep_Frame do
					Keep_Frame[i]:Hide()
				end
			end
		end

	    Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
	    local header = Create_Header(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,Check_UI("邮寄过滤物品","Items Will Not Be Mailed"))

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 20
	    Basic_UI.Mail["邮寄过滤物品"] = Create_Scroll_Edit(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal"),570,100)

		Basic_UI.Mail["邮寄过滤物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["邮寄过滤物品"] = Basic_UI.Mail["邮寄过滤物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["邮寄过滤物品"] == nil then
            Easy_Data["邮寄过滤物品"] = Check_UI("梦叶草,山鼠草,特效法力药水,奥术水晶","Dreamfoil,Mountain Silversage,Arcane Crystal")
        else
            Basic_UI.Mail["邮寄过滤物品"]:SetText(Easy_Data["邮寄过滤物品"])
        end

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 80

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 30
		Basic_UI.Mail["邮寄过滤列表"] = Create_Scroll(Basic_UI.Mail.frame,"TopLeft",10,Basic_UI.Mail.Py,570,200)

		Basic_UI.Mail.Py = Basic_UI.Mail.Py - 180

		Update_List()
	end

	Frame_Create()
	Button_Create()
	Need_Mail()
	Mail_Name()
	trigger_mail()
	Mail_Gold()
	Mail_Item()
	Save_Mail_Item()
end

local function Create_Custom_UI() -- 自定义UI
    Basic_UI.Custom = {}
	Basic_UI.Custom.Py = -10
	local function Frame_Create()
		Basic_UI.Custom.frame = CreateFrame('frame',"Basic_UI.Custom.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Custom.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Custom.frame:SetSize(600,1500)
		Basic_UI.Custom.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Custom.frame:Hide()
		Basic_UI.Custom.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Custom.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Custom.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("自定义","customize"))
		Basic_UI.Custom.button:SetSize(130,20)
		Basic_UI.Custom.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Custom.frame:Show()
			Basic_UI.Custom.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Custom.frame:Hide() Basic_UI.Custom.button:SetBackdropColor(0,0,0,0) end
	end

	Frame_Create()
	Button_Create()

	local function Custom_Set_UI() -- 读取自定义文件
		Basic_UI.Custom["自定义路径"] = Create_Check_Button(Basic_UI.Custom.frame, "TOPLEFT",10, Basic_UI.Custom.Py, Check_UI("使用自定义路径","Use custom nodes profile"))
		Basic_UI.Custom["自定义路径"]:SetScript("OnClick", function(self)
			if Basic_UI.Custom["自定义路径"]:GetChecked() then
				Easy_Data["自定义路径"] = true
			elseif not Basic_UI.Custom["自定义路径"]:GetChecked() then
				Easy_Data["自定义路径"] = false
			end
		end)
		if Easy_Data["自定义路径"] ~= nil then
			if Easy_Data["自定义路径"] then
				Basic_UI.Custom["自定义路径"]:SetChecked(true)
			else
				Basic_UI.Custom["自定义路径"]:SetChecked(false)
			end
		else
			Easy_Data["自定义路径"] = true
			Basic_UI.Custom["自定义路径"]:SetChecked(true)
		end


		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		Basic_UI.Custom["读取文件内容"] = Create_Check_Button(Basic_UI.Custom.frame, "TOPLEFT",10, Basic_UI.Custom.Py, Check_UI("直接读取文件内容","Directly read file content"))
		Basic_UI.Custom["读取文件内容"]:SetScript("OnClick", function(self)
			if Basic_UI.Custom["读取文件内容"]:GetChecked() then
				Easy_Data["读取文件内容"] = true
			elseif not Basic_UI.Custom["读取文件内容"]:GetChecked() then
				Easy_Data["读取文件内容"] = false
			end
		end)
		if Easy_Data["读取文件内容"] ~= nil then
			if Easy_Data["读取文件内容"] then
				Basic_UI.Custom["读取文件内容"]:SetChecked(true)
			else
				Basic_UI.Custom["读取文件内容"]:SetChecked(false)
			end
		else
			Easy_Data["读取文件内容"] = false
			Basic_UI.Custom["读取文件内容"]:SetChecked(false)
		end


		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		Basic_UI.Custom["读取编辑框内容"] = Create_Check_Button(Basic_UI.Custom.frame, "TOPLEFT",10, Basic_UI.Custom.Py, Check_UI("读取编辑框内容","Read editbox content"))
		Basic_UI.Custom["读取编辑框内容"]:SetScript("OnClick", function(self)
			if Basic_UI.Custom["读取编辑框内容"]:GetChecked() then
				Easy_Data["读取编辑框内容"] = true
			elseif not Basic_UI.Custom["读取编辑框内容"]:GetChecked() then
				Easy_Data["读取编辑框内容"] = false
			end
		end)
		if Easy_Data["读取编辑框内容"] ~= nil then
			if Easy_Data["读取编辑框内容"] then
				Basic_UI.Custom["读取编辑框内容"]:SetChecked(true)
			else
				Basic_UI.Custom["读取编辑框内容"]:SetChecked(false)
			end
		else
			Easy_Data["读取编辑框内容"] = true
			Basic_UI.Custom["读取编辑框内容"]:SetChecked(true)
		end
	end

	local function File_Route() -- 读取路径
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("文件路径 (例子 = C:"..[[\\]].."profiles"..[[\\]].."nodes.lua)","File Route (Example = C:"..[[\\]].."profiles"..[[\\]].."nodes.lua)"))

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20
	    Basic_UI.Custom["文件路径"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,"C:"..[[\\]].."123.lua",570,50)

		Basic_UI.Custom["文件路径"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["文件路径"] = Basic_UI.Custom["文件路径"]:GetText()
		end)
        if Easy_Data["文件路径"] == nil then
            Easy_Data["文件路径"] = "C:"..[[\\]].."123.lua"
        else
            Basic_UI.Custom["文件路径"]:SetText(Easy_Data["文件路径"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	end

	local function Read_button() -- 读取文件
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    Basic_UI.Custom["读取路径"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("读取文件内容至编辑框","Write file content to Editbox"))
		Basic_UI.Custom["读取路径"]:SetSize(300,24)
		Basic_UI.Custom["读取路径"]:SetScript("OnClick", function(self)
			local content = awm.ReadFile(Easy_Data["文件路径"])
			Easy_Data["执行内容"] = content
			Basic_UI.Custom["执行内容"]:SetText(Easy_Data["执行内容"])
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    Basic_UI.Custom["执行内容"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,[[print('loading')]],570,350)


        if Easy_Data["执行内容"] == nil then
            Easy_Data["执行内容"] = [[print('loading')]]
        else
            Basic_UI.Custom["执行内容"]:SetText(Easy_Data["执行内容"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 180
	end

	Custom_Set_UI()
	File_Route()
	Read_button()
end

local function Create_Internal_UI() -- 内置路径UI
    Basic_UI.Internal = {}
	Basic_UI.Internal.Py = -10
	local function Frame_Create()
		Basic_UI.Internal.frame = CreateFrame('frame',"Basic_UI.Internal.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Internal.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Internal.frame:SetSize(600,1500)
		Basic_UI.Internal.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Internal.frame:Hide()
		Basic_UI.Internal.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Internal.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Internal.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("内置路径","fixed path"))
		Basic_UI.Internal.button:SetSize(130,20)
		Basic_UI.Internal.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Internal.frame:Show()
			Basic_UI.Internal.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Internal.frame:Hide() Basic_UI.Internal.button:SetBackdropColor(0,0,0,0) end
	end

	Frame_Create()
	Button_Create()

	local function Internal_Set_UI() -- 读取内置路径
		Basic_UI.Internal["内置路径"] = Create_Check_Button(Basic_UI.Internal.frame, "TOPLEFT",10, Basic_UI.Internal.Py, Check_UI("使用内置路径","Use fixed path"))
		Basic_UI.Internal["内置路径"]:SetScript("OnClick", function(self)
			if Basic_UI.Internal["内置路径"]:GetChecked() then
				Easy_Data["内置路径"] = true
			elseif not Basic_UI.Internal["内置路径"]:GetChecked() then
				Easy_Data["内置路径"] = false
			end
		end)
		if Easy_Data["内置路径"] ~= nil then
			if Easy_Data["内置路径"] then
				Basic_UI.Internal["内置路径"]:SetChecked(true)
			else
				Basic_UI.Internal["内置路径"]:SetChecked(false)
			end
		else
			Easy_Data["内置路径"] = false
			Basic_UI.Internal["内置路径"]:SetChecked(false)
		end
	end

	local function Path_Choose()
	    Basic_UI.Internal.Py = Basic_UI.Internal.Py - 30
        local text = Create_Header(Basic_UI.Internal.frame,"TOPLeft", 10, Basic_UI.Internal.Py,Check_UI("路径选择","Path Choose"))

        Basic_UI.Internal.Py = Basic_UI.Internal.Py - 30


		local function Path_Match()
			if Easy_Data["内置路径选择"] == "地狱火半岛 - 暗影微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					    {-696.01,1607.97,47.22},
						{-764.97,1569.23,44.39},
						{-807.36,1525.95,34.82},
						{-944.59,1525.65,45.11},
						{-1072.44,1475.78,32.86},
						{-1196.39,1455.70,35.06},
					}

					Mobs_ID = {
						17014,
						19527,
					}
 
                    if Faction == "Horde" then
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
						Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
						Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

						Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

						Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

					else
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
						Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
						Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

						Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

						Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

					end
				]]
			end

			if Easy_Data["内置路径选择"] == "地狱火半岛 - 暗影微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					    {-1338.0094,2913.8933,-11.7770},
						{-1396.9066,3037.8772,1.7122},
						{-1387.3746,3141.6716,23.5895},
						{-1331.0092,3188.5144,38.2914},
					}

					Mobs_ID = {
						16975,
						16974,
					}
 
                    if Faction == "Horde" then
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
						Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
						Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

						Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

						Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

					else
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
						Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
						Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

						Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

						Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

					end
				]]
			end

			if Easy_Data["内置路径选择"] == "地狱火半岛 - 火焰微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					    {709.7770,2569.8662,278.4229},
						{788.7070,2514.9717,293.6392},
						{825.8525,2438.2051,289.6417},
						{795.0065,2344.6199,281.1342},
						{777.4792,2275.3232,281.3649},
						{790.4044,2169.4739,272.3723},
						{835.8944,2070.3159,272.1377},
						{687.8526,2379.5195,274.9344},
					}

					Mobs_ID = {
						22323,
					}
 
                    if Faction == "Horde" then
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
						Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
						Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

						Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

						Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
						Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

					else
						Mobs_MapID = 1944

						Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
						Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
						Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

						Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

						Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
						Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

					end
				]]
			end



			if Easy_Data["内置路径选择"] == "影月谷 - 空气微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-2785.5295,962.3314,-0.2014},
					{-2769.2559,823.2537,24.5045},
					{-2774.5808,708.7526,-10.2590},
					{-2797.1423,589.6010,-8.7857},
					{-3006.9500,397.5617,2.7197},
					{-3003.4585,232.3683,-6.0723},
					{-3020.7573,132.5932,23.0049},
					}

					Mobs_ID = {21060}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 空气微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-4301.7456,612.7772,61.3771},
					{-4156.3433,677.9629,6.0389},
					{-4249.4326,792.1012,26.0999},
					{-4379.3364,863.1837,15.3386},
					{-4380.0068,1001.8097,47.9492},
					}

					Mobs_ID = {21060}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 法力微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3001.2288,239.5243,-9.3989},
					}

					Mobs_ID = {21901}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 法力微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-4301.7456,612.7772,61.3771},
					{-4440.0332,680.6124,163.2785},
					{-4473.6074,512.7693,120.3207},
					{-4423.9927,395.5807,102.5699},
					}

					Mobs_ID = {21901}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 法力微粒 - 3" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-4840.1611,361.5446,58.8418},
					{-4830.4424,472.0039,51.5968},
					{-4884.1313,686.8325,67.1166},
					{-5235.0273,752.7383,46.7111},
					{-5261.3110,551.1938,46.0821},
					{-5258.2324,455.1319,56.3577},
					{-5304.6758,269.5157,59.7288},
					{-5288.8271,82.6506,35.1200},
					{-5198.7993,-37.3664,71.7160},
					{-5140.3945,-128.1385,62.4158},
					{-4924.0415,59.4062,52.8253},
					{-4819.6494,386.9833,47.7418},
					}

					Mobs_ID = {23501}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 水之微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-2958.5056,1201.4475,8.6044},
					{-2964.0312,1377.7797,8.6962},
					{-2888.3318,1456.1698,7.5516},
					{-2802.3735,1505.5004,7.4636},
					{-2776.4773,1618.5056,12.1340},
					{-2999.4463,1618.5382,58.6559},
					}

					Mobs_ID = {21059}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 火焰微粒 - 土之微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3193.34,1478.80,56.44},
					{-3061.01,1500.54,22.63},
					{-3075.59,1412.32,12.09},
					{-3139.08,1359.19,15.38},
					{-3375.32,1542.46,65.90},
					{-3482.42,1604.03,57.95},
					{-3585.83,1602.43,54.99},
					{-3665.08,1568.28,52.55},
					{-3789.12,1507.37,54.05},
					}

					Mobs_ID = {21050,21061}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 生命微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3165.76,2293.38,68.16},
					{-3203.57,2245.31,67.67},
					{-3179.02,2197.98,69.63},
					{-3168.01,2130.94,83.90},
					{-3065.99,2170.55,82.52},
					{-3012.47,2235.62,77.50},
					{-3037.30,2327.74,69.31},
					}

					Mobs_ID = {21386,19826,19827}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 生命微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3640.70,2613.00,95.82},
					{-3666.17,2513.95,97.63},
					{-3694.84,2459.28,95.33},
					{-3764.40,2430.52,92.54},
					{-3794.68,2341.21,123.55},
					}

					Mobs_ID = {19802}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 暗影微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3587.51,1061.40,56.21},
					{-3652.19,1134.96,76.87},
					{-3701.58,1073.50,79.52},
					{-3701.56,1021.31,81.07},
					{-3754.75,993.61,83.50},
					}

					Mobs_ID = {19801,21520,19744}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "影月谷 - 暗影微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3634.32,2608.96,91.72},
					{-3667.76,2516.26,95.61},
					{-3725.64,2454.58,96.69},
					{-3752.58,2390.18,96.38},
					{-3814.25,2445.48,102.12},
					{-3889.94,2510.15,111.32},
					{-3849.61,2573.11,107.19},
					{-3804.56,2608.31,102.37},
					{-3784.93,2676.31,111.46},
					{-3700.42,2613.51,103.40},
					}

					Mobs_ID = {21309,19802,21656,19800,21928,21337}

                    Mobs_MapID = 1948
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("考尔苏","Korthul")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3091, 2579, 61

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -2987, 2568, 79

						Ammo_Vendor_Name = Check_Client("考尔苏","Korthul")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3091, 2579, 61

						Food_Vendor_Name = Check_Client("塔戈洛姆","Targrom")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -2940, 2675, 93
						
					else -- 联盟
						Mobs_MapID = 1948

						Merchant_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1948, -3939, 2201, 102

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1948, -4056, 2178, 110

						Ammo_Vendor_Name = Check_Client("达格尔·塑铁","Daggle Ironshaper")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1948, -3939, 2201, 102

						Food_Vendor_Name = Check_Client("德雷格·掠云","Dreg Cloudsweeper")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1948, -4080, 2185, 107
						
					end
				]]
			end



			if Easy_Data["内置路径选择"] == "泰罗卡森林 - 水之微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-3355.68,3593.91,275.51},
					{-3451.08,3569.83,276.94},
					{-3641.80,3674.53,280.62},
					{-3765.50,3678.00,280.68},
					{-3864.87,3654.08,278.94},
					{-3940.11,3633.51,277.32},
					{-4035.55,3479.54,275.19},
					{-3939.73,3350.92,273.06},
					{-3629.53,3520.11,272.28},
					}

					Mobs_ID = {21728}
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1952
						
						Merchant_Name = Check_Client("巴尔·塔雷特","Bar Talet")
						
						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2639, 4425, 37
						
						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1944, -598, 4151, 66
						
						Ammo_Vendor_Name = Check_Client("度德斯","Dod'ss")
						
						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2641, 4374, 35
						
						Food_Vendor_Name = Check_Client("旅店老板格里尔卡","Innkeeper Grilka")
						
						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2621, 4450, 36
						
					else -- 联盟
						Mobs_MapID = 1952

						Merchant_Name = Check_Client("塞希尔·梅尔斯","Cecil Meyers")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2977, 4029, 3

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1952, -2931, 4009, -2

						Ammo_Vendor_Name = Check_Client("法比安·兰苏利","Fabian Lanzonelli")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2925, 3965, 0.2

						Food_Vendor_Name = Check_Client("旅店老板贝莉比","Innkeeper Biribi")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2921, 4020, 0
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "泰罗卡森林 - 生命微粒 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-2723.08,3293.57,13.63},
					{-2457.38,3354.04,-9.80},
					{-2171.95,3381.94,-23.47},
					{-2178.31,3572.16,-30.90},
					{-2120.70,3665.26,-32.31},
					{-2106.15,3841.88,5.67},
					{-2251.60,4050.31,-13.07},
					{-2346.50,4077.73,-10.80},
					{-2433.34,4049.95,8.18},
					{-2534.32,4015.20,8.74},
					{-2640.99,3853.93,-11.81},
					}

					Mobs_ID = {18464}
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1952
						
						Merchant_Name = Check_Client("巴尔·塔雷特","Bar Talet")
						
						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2639, 4425, 37
						
						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1944, -598, 4151, 66
						
						Ammo_Vendor_Name = Check_Client("度德斯","Dod'ss")
						
						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2641, 4374, 35
						
						Food_Vendor_Name = Check_Client("旅店老板格里尔卡","Innkeeper Grilka")
						
						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2621, 4450, 36
						
					else -- 联盟
						Mobs_MapID = 1952

						Merchant_Name = Check_Client("塞希尔·梅尔斯","Cecil Meyers")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2977, 4029, 3

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1952, -2931, 4009, -2

						Ammo_Vendor_Name = Check_Client("法比安·兰苏利","Fabian Lanzonelli")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2925, 3965, 0.2

						Food_Vendor_Name = Check_Client("旅店老板贝莉比","Innkeeper Biribi")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2921, 4020, 0
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "泰罗卡森林 - 生命微粒 - 2" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-2198.53,3139.79,-19.63},
					{-2138.62,3151.08,-35.76},
					{-2102.26,3226.59,-41.11},
					{-2088.14,3330.00,-50.19},
					{-2112.20,3406.18,-47.73},
					{-2100.41,3513.47,-56.46},
					}

					Mobs_ID = {21816}
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1952
						
						Merchant_Name = Check_Client("巴尔·塔雷特","Bar Talet")
						
						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2639, 4425, 37
						
						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1944, -598, 4151, 66
						
						Ammo_Vendor_Name = Check_Client("度德斯","Dod'ss")
						
						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2641, 4374, 35
						
						Food_Vendor_Name = Check_Client("旅店老板格里尔卡","Innkeeper Grilka")
						
						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2621, 4450, 36
						
					else -- 联盟
						Mobs_MapID = 1952

						Merchant_Name = Check_Client("塞希尔·梅尔斯","Cecil Meyers")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2977, 4029, 3

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1952, -2931, 4009, -2

						Ammo_Vendor_Name = Check_Client("法比安·兰苏利","Fabian Lanzonelli")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2925, 3965, 0.2

						Food_Vendor_Name = Check_Client("旅店老板贝莉比","Innkeeper Biribi")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2921, 4020, 0
					end
				]]
			end

			if Easy_Data["内置路径选择"] == "泰罗卡森林 - 生命微粒 - 3" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {
					{-2881.70,4468.16,-0.80},
					{-2878.67,4585.18,-4.56},
					{-2840.17,4675.07,-4.17},
					{-2948.11,4677.50,-10.55},
					{-2990.69,4712.74,-13.21},
					{-2992.21,4785.17,-13.62},
					{-2917.94,4842.05,-9.21},
					{-2817.39,4882.34,-4.50},
					{-2743.20,4934.99,-0.25},
					{-2725.83,5005.89,3.12},
					{-2948.30,5038.99,-14.07},
					{-3031.26,5141.65,-15.40},
					{-3036.87,5269.92,-12.42},
					{-3199.62,5354.98,-12.72},
					{-3311.58,5347.94,-13.89},
					{-3297.40,5696.86,15.04},
					{-3324.76,5857.61,-8.54},
					{-3420.85,5895.15,-24.15},
					{-3518.50,5925.39,-27.74},
					{-3656.73,5937.44,-17.84},
					{-3748.41,5969.45,2.95},
					{-3783.94,5775.02,0.28},
					{-3792.45,5660.32,-9.92},
					{-3818.27,5568.24,-11.79},
					{-3794.12,5366.54,-11.84},
					{-3823.61,5216.00,-28.51},
					{-3694.38,4761.76,-17.09},
					{-3679.49,4716.21,-17.19},
					{-3822.75,4443.85,7.13},
					{-3706.03,4321.55,7.57},
					{-3628.42,4276.08,2.80},
					{-3553.28,4246.16,-1.42},
					{-3429.87,4223.59,-1.03},
					}

					Mobs_ID = {22095,22307,22100,18465,22045}
 
                    if Faction == "Horde" then -- 阵营判断，部落
						Mobs_MapID = 1952
						
						Merchant_Name = Check_Client("巴尔·塔雷特","Bar Talet")
						
						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2639, 4425, 37
						
						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1944, -598, 4151, 66
						
						Ammo_Vendor_Name = Check_Client("度德斯","Dod'ss")
						
						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2641, 4374, 35
						
						Food_Vendor_Name = Check_Client("旅店老板格里尔卡","Innkeeper Grilka")
						
						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2621, 4450, 36
						
					else -- 联盟
						Mobs_MapID = 1952

						Merchant_Name = Check_Client("塞希尔·梅尔斯","Cecil Meyers")

						Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1952, -2977, 4029, 3

						Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1952, -2931, 4009, -2

						Ammo_Vendor_Name = Check_Client("法比安·兰苏利","Fabian Lanzonelli")

						Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1952, -2925, 3965, 0.2

						Food_Vendor_Name = Check_Client("旅店老板贝莉比","Innkeeper Biribi")

						Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1952, -2921, 4020, 0
					end
				]]
			end


			if Easy_Data["内置路径选择"] == "纳格兰双采 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {{-1362.493,6895.016,53.223},{-1355.782,6848.717,60.508},{-1325.595,6802.823,77.773},{-1312.688,6749.741,89.375},{-1309.169,6691.842,95.987},{-1308.796,6647.59,99.165},{-1311.004,6616.135,113.814},{-1322.432,6557.145,110.823},{-1332.712,6482.939,98.554},{-1334.535,6424.882,85.239},{-1347.989,6390.375,81.255},{-1395.254,6361.837,80.523},{-1455.911,6326.023,82.384},{-1538.474,6303.472,96.261},{-1602.304,6299.47,98.566},{-1662.063,6290.327,100.968},{-1706.999,6301.437,93.809},{-1813.719,6329.154,85.738},{-1908.16,6322.676,85.916},{-1983.852,6306.605,90.118},{-2041.726,6283.276,95.974},{-2073.626,6223.857,120.455},{-2067.756,6117.86,166.929},{-2110.559,6164.961,137.667},{-2146.106,6226.747,108.788},{-2165.775,6281.704,94.197},{-2180.677,6314.747,82.053},{-2231.711,6320.962,73.079},{-2271.561,6303.741,89.236},{-2311.346,6279.652,93.1},{-2343.222,6215.692,108.352},{-2372.526,6166.871,117.137},{-2406.635,6137.458,123.041},{-2460.321,6133.87,119.657},{-2498.113,6145.466,112.913},{-2545.389,6164.441,101.179},{-2600.621,6192.131,81.659},{-2628.13,6233.81,73.069},{-2636.963,6305.176,72.096},{-2672.301,6347.084,76.596},{-2704.885,6378.607,81.449},{-2739.881,6431.841,87.784},{-2762.045,6491.713,86.356},{-2787.227,6516.843,86.246},{-2822.509,6546.399,80.942},{-2851.899,6596.202,73.408},{-2869.14,6643.98,65.695},{-2871.204,6701.48,54.732},{-2858.1,6769.802,39.928},{-2857.319,6848.021,35.741},{-2864.888,6962.394,33.112},{-2877.121,7050.198,46.455},{-2911.749,7146.184,66.765},{-2941.317,7214.342,60.014},{-2955.329,7266.009,60.683},{-2965.602,7338.18,58.836},{-2951.811,7395.933,52.986},{-2923.469,7443.444,48.152},{-2886.817,7507.255,38.309},{-2862.092,7538.413,36.857},{-2846.202,7597.441,32.596},{-2824.867,7662.781,26.598},{-2818.025,7728.314,25.785},{-2826.638,7792.864,26.435},{-2840.391,7872.84,28.351},{-2872.901,7936.24,33.136},{-2911.344,7973.316,29.731},{-2961.012,7984.932,28.775},{-3003.735,8029.497,22.849},{-2991.822,8085.388,20.097},{-2960.141,8169.74,13.185},{-2939.297,8228.805,11.541},{-2929.071,8263.609,5.736},{-2900.137,8338.372,7.72},{-2862.337,8435.025,16.769},{-2821.707,8535.01,21.593},{-2774.254,8573.447,22.656},{-2698.38,8625.847,15.513},{-2628.354,8670.351,14.346},{-2573.588,8680.046,17.73},{-2510.406,8679.871,22.291},{-2413.616,8694.509,24.454},{-2346.219,8721.366,28.534},{-2295.966,8759.962,34.845},{-2248.74,8812.169,45.442},{-2162.839,8864.579,53.515},{-2098.562,8898.745,66.332},{-2035.312,8951.946,86.353},{-1992.243,8997.786,99.544},{-1947.216,9050.066,111.249},{-1910.21,9100.625,119.254},{-1846.791,9158.746,127.57},{-1781.717,9174.402,130.424},{-1698.195,9137.457,123.411},{-1658.474,9089.763,110.781},{-1562.258,9003.437,106.234},{-1477.675,8903.242,98.428},{-1458.656,8853.904,97.019},{-1442.763,8722.013,80.165},{-1425.097,8658.092,75.614},{-1335.748,8578.743,81.442},{-1227.958,8616.161,106.917},{-1142.946,8691.834,126.933},{-1109.985,8759.536,141.518},{-1058.357,8828.811,157.484},{-967.364,8883.425,171.011},{-888.652,8925.394,176.122},{-815.697,8903.875,187.8},{-777.523,8838.54,199.759},{-767.795,8793.138,200.315},{-735.568,8730.916,204.69},{-723.704,8660.254,182.419},{-708.345,8604.639,161.415},{-689.076,8512.477,127.127},{-736.74,8463.255,107.992},{-778.557,8426.245,94.153},{-823.35,8380.512,82.236},{-859.656,8346.411,71.792},{-930.516,8277.477,51.8},{-973.882,8218.029,48.259},{-975.24,8175.67,48.443},{-1030.552,8142.057,45.078},{-1124.496,8167.977,38.939},{-1229.133,8186.497,31.374},{-1283.08,8228.707,26.687},{-1328.887,8293.179,24.376},{-1359.847,8329.92,26.556},{-1421.066,8313.677,22.098},{-1469.629,8255.381,13.397},{-1512.979,8179.926,6.538},{-1583.245,8157.59,1.368},{-1680.216,8133.866,-5.995},{-1743.255,8124.963,-4.371},{-1802.293,8095.278,-1.228},{-1905.375,8111.846,3.901},{-1957.554,8153.62,11.936},{-2002.28,8211.688,19.678},{-2034.955,8293.407,29.323},{-2055.806,8347.302,38.323},{-2099.713,8446.067,46.934},{-2153.777,8517.955,51.089},{-2229.919,8563.232,38.401},{-2352.739,8554.234,10.347},{-2427.146,8495.191,-6.161},{-2417.793,8396.526,-9.468},{-2397.469,8270.862,-9.49},{-2398.549,8150.184,-7.847},{-2371.503,8067.587,-1.117},{-2368.766,7947.437,14.34},{-2380.318,7846.428,23.417},{-2439.786,7766.794,26.079},{-2503.19,7649.838,40.396},{-2543.896,7575.986,41.546},{-2604.585,7558.85,52.228},{-2722.674,7532.377,59.583},{-2788.732,7478.61,60.819},{-2840.503,7408.376,59.555},{-2862.93,7331.963,55.373},{-2863.789,7262.571,49.258},{-2854.647,7188.04,40.519},{-2840.471,7144.726,34.039},{-2791.173,7067.331,25.619},{-2728.848,6995.916,27.486},{-2644.035,6951.883,36.386},{-2526.423,6933.22,47.393},{-2462.632,6888.432,57.62},{-2471.335,6798.347,51.584},{-2487.559,6699.42,55.146},{-2486.81,6607.645,65.043},{-2443.377,6524.032,64.851},{-2383.513,6458.367,59.448},{-2294.308,6471.112,59.752},{-2257.995,6557.5,54.381},{-2237.446,6675.976,42.13},{-2209.525,6765.532,41.494},{-2165.572,6864.495,40.875},{-2136.252,6958.162,44.354},{-2128.228,7033.818,47.856},{-2136.149,7132.146,39.924},{-2177.306,7254.937,19.979},{-2189.97,7317.126,10.791},{-2223.051,7412.683,3.611},{-2259.226,7492.743,-0.005},{-2288.887,7603.922,6.183},{-2244.816,7742.681,5.97},{-2162.898,7800.062,8.001},{-2051.872,7796.824,23.517},{-1958.028,7744.161,47.992},{-1844.471,7686.826,43.879},{-1788.343,7657.564,42.684},{-1679.369,7612.532,43.104},{-1593.557,7585.154,43.732},{-1503.118,7570.884,47.861},{-1381.196,7584.019,51.507},{-1284.767,7600.506,56.028},{-1191.204,7627.542,60.174},{-1116.764,7658.968,65.459},{-1036.591,7730.968,79.453},{-1001.278,7817.694,86.68},{-966.754,7952.599,72.347},{-926.594,8016.371,73.136},{-857.728,8078.159,81.693},{-794.188,8110.132,96.865},{-734.985,8100.52,103.979},{-716.176,8018.16,122.674},{-695.919,7940.523,131.392},{-655.757,7840.393,118.294},{-662.679,7789.352,109.048},{-684.65,7728.622,106.5},{-702.493,7697.354,106.487},{-735.735,7658.126,105.798},{-748.36,7616.947,102.432},{-749.192,7583.943,91.43},{-731.322,7525.246,88.567},{-746.838,7480.969,84.037},{-783.464,7422.428,81.474},{-805.375,7334.042,81.835},{-807.161,7258.368,82.096},{-793.047,7189.29,78.895},{-753.5,7090.252,74.443},{-769.631,7021.229,71.393},{-786.047,6963.791,70.037},{-814.843,6905.729,71.914},{-863.642,6879.357,70.923},{-913.465,6916.94,71.734},{-868.323,7022.493,69.428},{-835.676,7119.919,67.545},{-838.776,7207.015,69.769},{-868.99,7276.427,67.495},{-923.465,7325.163,66.165},{-980.577,7320.594,61.414},{-1038.137,7311.09,61.841},{-1125.594,7341.859,61.883},{-1200.672,7418.135,61.724},{-1274.66,7462.256,55.369},{-1335.546,7472.051,51.4},{-1418.516,7434.169,42.176},{-1516.476,7437.738,29.569},{-1589.641,7461.2,39.686},{-1646.388,7482.714,39.939},{-1708.956,7499.004,40.034},{-1794.683,7511.208,36.031},{-1872.518,7494.202,32.398},{-1900.091,7454.986,31.866},{-1909.062,7408.776,38.572},{-1872.645,7331.713,40.104},{-1803.119,7251.21,39.291},{-1726.678,7176.148,42.726},{-1640.287,7113.899,51.922},{-1545.12,7040.622,62.756},{-1473.716,6974.113,55.978},{-1408.725,6910.132,48.897},{-1356.638,6871.947,46.836},}

                    Mobs_MapID = 1951
 
                    Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
					Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1946, -199, 5490, 21

					Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1946, -199, 5507, 24

					Ammo_Vendor_Name = Check_Client("萨莉娜·白星","Sarinei Whitestar")
					Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1946, -203, 5478, 23

					Food_Vendor_Name = Check_Client("旅店老板考伊斯·斯托克顿","Innkeeper Coryth Stoktron")
					Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1946, -175, 5529, 29
				]]
			end

			if Easy_Data["内置路径选择"] == "赞加沼泽双采 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {{-311.251,8250.686,45.638},{-295.168,8217.68,43.078},{-272.584,8183.403,42.902},{-249.629,8154.691,42.754},{-238.583,8124.654,41.469},{-243.316,8083.355,40.119},{-257.846,8051.07,40.592},{-259.508,8010.212,41.171},{-256.723,7932.797,37.605},{-255.605,7867.385,36.166},{-252.316,7797.796,41.711},{-232.059,7724.75,42.578},{-222.124,7675.808,39.495},{-225.818,7606.938,42.065},{-238.45,7538.162,44.753},{-246.338,7467.24,46.051},{-244.126,7412.817,45.96},{-242.457,7344.272,49.343},{-239.707,7259.431,48.657},{-226.975,7172.244,45.732},{-236.44,7113.396,43.669},{-260.69,7057.278,45.161},{-293.11,6981.539,48.596},{-302.482,6930.378,48.542},{-318.254,6875.979,49.413},{-340.102,6825.678,50.697},{-373.67,6774.623,52.595},{-400.21,6744.327,52.407},{-420.196,6716.945,52.759},{-420.175,6679.67,53.864},{-412.098,6628.497,51},{-418.328,6587.869,48.758},{-432.908,6534.055,46.552},{-448.015,6496.691,44.733},{-468.604,6472.848,43.352},{-501.287,6422.68,45.435},{-506.698,6364.949,43.932},{-515.907,6304.618,41.928},{-520.631,6243.624,40.849},{-524.803,6182.567,34.838},{-527.232,6137.039,35.184},{-544.621,6108.475,36.34},{-577.152,6096.046,38.293},{-605.823,6101.681,39.055},{-652.443,6119.715,40.157},{-692.205,6119.987,42.763},{-727.824,6103.229,45.512},{-771.022,6076.191,48.85},{-810.45,6040.551,49.31},{-861.078,5992.952,49.82},{-886.04,5964.461,49.007},{-913.21,5913.373,50.895},{-924.377,5838.171,51.969},{-938.743,5779.657,53.496},{-973.148,5740.142,55.918},{-1016.816,5695.203,60.643},{-1044.359,5646.854,63.812},{-1078.281,5576.374,61.858},{-1105.881,5533.225,57.514},{-1143.67,5461.409,50.043},{-1125.443,5411.015,48.554},{-1109.509,5368.192,48.313},{-1080.962,5291.841,50.852},{-1053.676,5196.979,51.651},{-1028.983,5121.901,52.406},{-984.141,5099.121,55.414},{-925.591,5099.876,59.944},{-860.652,5118.404,61.901},{-813.007,5146.778,57.196},{-787.395,5169.347,52.671},{-728.462,5240.518,43.991},{-704.098,5305.281,38.4},{-670.783,5348.648,36.834},{-617.887,5348.313,37.894},{-551.576,5347.721,42.831},{-498.127,5352.157,42.773},{-422.861,5363.434,45.689},{-355.323,5383.993,44.671},{-308.635,5385.234,44.668},{-250.305,5372.135,43.746},{-207.761,5372.782,43.065},{-144.617,5377.426,42.316},{-87.107,5379.674,40.994},{-34.957,5352.977,43.111},{39.27,5322.274,44.891},{90.356,5309.52,46.021},{127.124,5292.571,47.518},{177.651,5250.274,49.689},{200.642,5209.74,43.36},{249.568,5185.902,38.413},{284.265,5162.122,40.058},{329.4,5157.974,41.016},{388.996,5166.292,44.019},{414.141,5150.79,39.258},{466.641,5108.806,37.475},{527.502,5085.999,34.71},{583.21,5068.567,30.922},{643.988,5061.711,28.973},{677.981,5051.599,32.635},{747.498,5035.354,23.371},{806.348,5037.595,21.881},{898.034,5073.216,23.561},{935.081,5164.179,25.902},{945.476,5245.983,25.451},{927.018,5334.615,29.998},{915.973,5410.809,31.263},{908.94,5480.305,34.965},{899.513,5534.349,35.675},{870.167,5614.365,37.651},{822.417,5660.027,41.512},{810.551,5720.728,43.511},{794.473,5790.173,43.202},{774.311,5832.868,41.998},{731.659,5894.347,37.287},{690.918,5958.724,33.417},{685.436,5999.998,32.032},{705.801,6040.083,31.476},{729.542,6087.552,31.686},{746.467,6147.93,31.659},{758.881,6200.56,31.35},{771.07,6244.928,30.787},{778.228,6284.662,30.211},{788.639,6331.704,26.954},{795.875,6408.923,27.275},{793.831,6468.257,27.092},{794.119,6508.048,26.803},{805.606,6562.636,26.526},{804.152,6612.344,26.667},{795.035,6658.868,25.554},{795.421,6711.323,25.046},{816.852,6762.932,25.097},{840.668,6827.15,27.227},{857.476,6872.354,29.426},{879.53,6925.581,31.212},{902.892,6981.615,32.647},{923.58,7045.98,33.035},{919.111,7091.389,32.026},{916.668,7140.215,31.225},{924.355,7195.165,30.641},{911.461,7241.696,28.855},{907.194,7286.191,27.525},{906.407,7340.003,26.947},{912.678,7370.863,31.936},{937.016,7442.839,34.737},{977.723,7486.601,33.27},{1032,7506.064,29.618},{1083.508,7528.577,28.861},{1106.211,7548.426,30.927},{1128.913,7597.352,32.521},{1148.305,7636.625,33.872},{1173.397,7677.433,34.298},{1195.425,7712.554,34.956},{1205.485,7754.506,37.246},{1203.635,7815.176,36.956},{1211.179,7873.977,35.523},{1205.255,7945.467,34.984},{1207.004,8017.794,38.27},{1228.268,8086.836,39.312},{1233.771,8153.365,39.758},{1230.28,8202.404,38.465},{1229.717,8259.952,36.773},{1232.497,8310.984,35.555},{1240.554,8359.71,34.859},{1248.19,8405.151,34.889},{1232.48,8478.241,34.861},{1222.214,8540.302,35.671},{1209.774,8612.636,37.573},{1173.473,8648.792,37.018},{1126.388,8673.617,34.875},{1052.864,8674.776,33.085},{991.629,8664.716,32.606},{917.24,8648.86,31.791},{835.603,8617.818,31.773},{778.521,8605.921,32.292},{712.935,8598.226,32.878},{643.834,8597.19,34.282},{577.078,8632.717,37.326},{530.601,8664.176,40.7},{465.3,8701.351,40.825},{443.769,8734.895,41.802},{406.302,8810.548,44.088},{385.178,8873.886,46.641},{339.54,8918.783,49.149},{281.936,8949.762,47.138},{228.537,8966.009,45.501},{177.75,8981.828,44.167},{136.15,8992.39,42.814},{66.556,8993.604,40.863},{3.719,8985.434,40.29},{-53.3,8974.925,40.548},{-112.079,8958.531,41.162},{-136.378,8933.572,42.348},{-155.825,8888.515,44.984},{-179.847,8814.251,37.299},{-199.969,8751.102,32.963},{-214.742,8695.434,32.668},{-221.438,8648.142,35.887},{-244.418,8606.746,38.088},{-278.701,8572.654,39.236},{-289.252,8555.763,39.299},{-300.936,8528.277,40.003},{-298.332,8504.322,40.439},{-285.919,8472.053,40.898},{-256.582,8423.986,42.481},{-243.52,8393.322,45.289},{-204.438,8399.37,41.603},{-141.317,8409.999,41.909},{-90.779,8406.506,46.157},{-38.162,8396.21,48.148},{12.62,8383.879,50.061},{70.585,8364.924,49.585},{115.19,8340.55,46.045},{150.832,8313.901,43.13},{193.098,8271.856,38.496},{229,8241.649,37.419},{257.297,8220.28,36.811},{286.67,8233.816,34.76},{321.801,8267.637,33.678},{362.125,8306.866,34.022},{395.629,8346.226,35.083},{461.772,8390.146,36.861},{509.375,8414.764,36.674},{553.6,8431.627,36.909},{577.085,8465.509,35.76},{596.018,8503.432,34.875},{625.693,8519.077,34.553},{665.455,8518.176,33.805},{699.656,8514.169,33.302},{745.132,8500.789,31.846},{781.521,8488.438,30.96},{808.556,8475.081,30.362},{850.506,8448.668,30.208},{875.968,8430.095,30.699},{895.376,8410.754,31.177},{910.673,8388.02,31.85},{927.206,8359.242,32.419},{930.743,8326.457,32.254},{924.832,8290.167,32.013},{915.545,8261.208,31.316},{905.876,8229.2,31.349},{889.794,8196.08,33.357},{867.423,8177.9,31.451},{832.249,8163.302,31.095},{821.474,8155.891,30.417},{813.238,8108.498,30.189},{802.418,8066.377,30.695},{792.789,8028.894,31.145},{784.02,7994.76,31.555},{770.124,7949.998,32.142},{741.266,7899.147,32.33},{720.976,7864.792,32.127},{693.948,7819.443,31.187},{674.013,7781.402,30.381},{649.686,7729.049,28.536},{641.038,7694.078,27.338},{633.209,7654.032,26.898},{602.57,7614.571,28.79},{589.102,7572.097,27.432},{576.13,7550.586,28.191},{553.949,7552.969,28.843},{524.35,7585.729,30.594},{496.068,7598.171,30.65},{445.943,7586.813,31.137},{420.281,7578.965,31.669},{392.436,7543.663,31.664},{367.381,7514.412,32.732},{345.926,7477.505,33.585},{346.899,7459.086,34.94},{348.622,7424.507,38.514},{327.169,7384.391,42.491},{314.837,7336.824,45.488},{319.117,7301.568,44.677},{339.55,7265.872,40.596},{359.779,7229.104,37.134},{370.359,7210.203,35.842},{387.519,7170.49,35.745},{388.735,7137.96,35.073},{359.085,7112.405,34.134},{327.13,7065.429,30.801},{316.361,7017.542,29.248},{318.495,6971.7,30.351},{331.326,6942.869,32.146},{325.495,6909.077,41.993},{293.026,6879.02,41.53},{275.917,6846.707,42.286},{277.842,6808.299,41.386},{290.625,6748.194,36.967},{304.243,6698.272,33.734},{321.455,6631.543,31.206},{334.694,6588.899,30.63},{343.589,6542.783,31.445},{347.755,6516.243,31.706},{363.966,6477.461,33.208},{383.336,6429.008,31.854},{407.538,6385.678,31.662},{429.714,6342.921,33.006},{444.43,6310.326,34.622},{483.435,6264.981,34.413},{511.646,6226.46,33.952},{528.867,6193.505,34.877},{544.015,6145.364,35.332},{552.377,6113.189,34.708},{567.756,6048.615,31.229},{578.549,6000.189,31.23},{588.745,5953.515,33.234},{594.637,5882.655,36.236},{599.805,5818.281,37.528},{584.894,5759.941,39.186},{554.314,5737.873,37.837},{508.73,5706.436,34.061},{457.399,5641.394,30.026},{419.537,5605.963,30.024},{370.574,5543.275,32.425},{340.521,5503.64,32.202},{307.814,5464.797,33.517},{282.667,5452.144,34.643},{251.456,5446.142,37},{210.424,5465.121,39.166},{164.897,5498.83,38.038},{146.807,5511.547,37.238},{76.843,5551.313,32.063},{41.086,5574.644,31.724},{3.478,5601.761,31.182},{-44.167,5658.912,30.325},{-86.256,5664.82,29.12},{-131.103,5653.055,29.367},{-151.897,5678.465,27.802},{-121.899,5714.924,26.743},{-73.566,5753.815,28.346},{-60.249,5783.74,28.949},{-74.183,5823.456,26.753},{-67.528,5848.759,26.847},{-61.328,5881.337,27.1},{-70.965,5911.419,27.333},{-88.002,5928.634,26.235},{-125.871,5928.241,35.074},{-154.714,5858.768,35.084},{-168.036,5805.977,37.376},{-185.273,5772.944,38.241},{-210.69,5764.133,36.976},{-238.734,5788.687,34.258},{-279.804,5844.688,29.537},{-303.977,5875.792,27.936},{-321.918,5896.315,29.131},{-341.336,5930.916,27.438},{-372.181,5943.847,25.954},{-395.764,5966.227,25.348},{-389.188,5998.833,28.932},{-336.856,6050.405,31.779},{-301.402,6094.586,35.261},{-265.644,6141.142,34.753},{-217.485,6195.162,31.907},{-217.389,6240.412,31.364},{-241.543,6291.303,29.825},{-231.163,6331.918,31.168},{-203.738,6374.933,31.865},{-173.333,6401.047,32.008},{-121.442,6442.592,31.104},{-102.455,6491.793,35.021},{-133.332,6511.829,33.047},{-197.144,6536.336,29.763},{-245.761,6571.76,28.006},{-274.249,6613.624,31.396},{-278.936,6646.818,32.963},{-260.057,6675.582,30.76},{-220.941,6743.807,29.552},{-199.498,6776.103,29.888},{-149.446,6822.509,30.234},{-114.919,6853.683,30.03},{-86.103,6877.818,29.765},{-45.745,6895.335,28.631},{-24.51,6928.764,30.562},{-14.379,6961.516,31.702},{-0.958,7021.146,30.314},{13.296,7081.275,26.821},{25.268,7133.537,25.996},{29.16,7155.971,26.297},{39.435,7207.963,27.284},{59.362,7270.344,29.104},{103.779,7318.384,30.282},{147.304,7360.653,30.402},{173.028,7425.953,31.54},{185.592,7496.373,32.072},{208.814,7565.595,31.263},{224.694,7605.062,31.425},{243.23,7645.756,32.763},{288.805,7697.512,34.105},{346.191,7728.295,35.868},{402.406,7764.7,35.416},{430.189,7810.505,34.221},{443.449,7862.143,34.779},{420.125,7921.831,31.762},{395.782,7965.055,35.405},{362.939,8008.325,36.631},{323.047,8038.398,36.478},{283.282,8065.113,36.771},{218.216,8107.223,36.477},{167.016,8129.353,36.245},{122.8,8142.78,37.076},{87.071,8179.372,32.896},{53.609,8204.301,31.26},{30.832,8232.556,32.011},{-6.967,8256.205,33.655},{-46.499,8277.056,35.585},{-94.617,8301.652,38.186},{-143.222,8320.862,40.442},{-196.504,8342.112,44.382},{-241.819,8365.079,44.635},{-302.668,8341.578,44.533},{-336.268,8304.387,44.449},}

                    Mobs_MapID = 1946
 
                    Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
					Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1946, -199, 5490, 21

					Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1946, -199, 5507, 24

					Ammo_Vendor_Name = Check_Client("萨莉娜·白星","Sarinei Whitestar")
					Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1946, -203, 5478, 23

					Food_Vendor_Name = Check_Client("旅店老板考伊斯·斯托克顿","Innkeeper Coryth Stoktron")
					Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1946, -175, 5529, 29
				]]
			end

			if Easy_Data["内置路径选择"] == "刀锋山双采 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {{2187.744,6092.331,159.655},{2176.513,6051.846,153.069},{2149.766,5984.918,151.54},{2128.842,5958.421,151.373},{2089.056,5927.157,151.797},{2054.055,5899.732,151.577},{2014.084,5897.774,149.683},{1958.525,5882.858,149.376},{1909.071,5873.312,148.868},{1858.55,5878.751,151.498},{1798.262,5895.348,165.288},{1770.986,5876.107,166.59},{1782.452,5837.559,182.28},{1797.872,5813.371,198.058},{1830.756,5800.167,208.698},{1854.227,5786.214,221.422},{1869.625,5751.204,236.664},{1872.15,5719.302,250.619},{1884.212,5695.54,262.243},{1917.974,5682.487,275.76},{1948.328,5681.179,278.861},{1988.243,5685.316,279.186},{2020.217,5697.716,277.422},{2046.922,5709.274,280.289},{2083.564,5723.738,284.003},{2122.749,5728.79,286.17},{2153.929,5748.02,282.309},{2178.704,5775.47,280.583},{2200.574,5788.678,279.355},{2239.434,5776.829,278.811},{2276.53,5763.885,280.797},{2317.375,5760.702,278.365},{2348.914,5757.544,283.031},{2377.71,5765.108,283.822},{2407.944,5753.896,285.636},{2430.533,5708.148,285.391},{2432.14,5669.931,280.702},{2433.841,5610.846,280.487},{2441.256,5570.287,279.382},{2461.407,5522.877,279.602},{2473.803,5499.895,280.496},{2629.964,5315.367,287.998},{2649.573,5312.354,288.659},{2684.41,5313.325,285.201},{2701.311,5304.135,287.891},{2706.345,5279.1,284.366},{2689.142,5254.272,279.512},{2688.716,5228.643,276.515},{2665.499,5223.895,284.214},{2625.391,5242.379,282.014},{2595.565,5268.69,282.114},{2572.735,5292.218,282.252},{2555.976,5307.907,282.748},{2503.36,5339.352,284.172},{2496.019,5353.546,282.107},{2503.466,5402.189,281.515},{2502.213,5442.001,278.734},{2483.548,5462.872,277.234},{2460.419,5486.223,278.566},{2429.23,5527.956,283.346},{2395.48,5570.707,285.607},{2353.116,5600.689,282.754},{2299.527,5627.8,281.985},{2259.027,5640.801,280.914},{2193.531,5659.419,278.602},{2133.545,5666.409,281.136},{2100.456,5663.003,281.228},{2060.415,5642.067,281.429},{2002.163,5631.516,280.143},{1927.589,5619.354,278.83},{1864.806,5614.316,275.936},{1783.293,5611.25,278.816},{1720.684,5600.214,279.007},{1685.373,5571.906,279.177},{1642.146,5513.637,282.738},{1609.121,5475.109,287.206},{1607.315,5450.04,285.613},{1621.996,5408.632,284.967},{1627.518,5377.403,283.634},{1613.1,5326.814,280.872},{1614.045,5280.665,280.537},{1631.845,5234.398,282.545},{1648.856,5195.944,284.739},{1674.525,5152.491,285.814},{1707.469,5109.128,285.337},{1729.429,5104.729,283.703},{1807.087,5106.756,285.956},{1851.346,5107.46,286.704},{1910.311,5116.529,285.289},{1966.509,5126.241,285.492},{2010.196,5121.95,285.248},{2056.718,5113.296,283.232},{2093.201,5111.447,281.097},{2113.642,5081.505,274.431},{2132.373,5065.78,270.701},{2151.742,5043.361,274.396},{2153.908,5015.886,241.326},{2177.396,4970.352,191.498},{2164.179,4933.637,174.456},{2141.48,4899.309,168.716},{2095.274,4902.847,165.541},{2060.172,4916.733,161.453},{2033.052,4926.134,157.917},{2003.887,4914.525,155.99},{1960.25,4911.082,155.703},{1925.443,4909.688,158.883},{1893.553,4926.003,161.006},{1867.958,4924.464,182.924},{1833.551,4921.091,183.641},{1790.951,4926.249,186.624},{1748.433,4934.434,190.793},{1701.764,4937.346,202.817},{1664.906,4952.468,195.413},{1651.662,4953.324,204.176},{1632.544,4938.729,197.981},{1625.557,4908.095,195.77},{1624.979,4865.124,182.551},{1618.608,4817.724,178.515},{1610.438,4779.318,169.548},{1629.946,4740.803,159.393},{1643.068,4698.631,153.971},{1636.035,4655.633,163.221},{1650.788,4625.187,161.132},{1700.583,4619.12,163.497},{1734.76,4630.304,165.424},{1774.345,4668.58,167.444},{1832.035,4716.708,168.933},{1880.863,4726.273,171.026},{1933.503,4718.472,167.49},{1999.974,4719.628,168.583},{2099.737,4755.179,173.817},{2155.742,4770.428,179.258},{2198.002,4821.623,184.507},{2196.773,4877.392,184.297},{2192.887,4959.458,204.403},{2173.788,4987.519,215.814},{2128.132,5010.45,234.303},{2107.013,5030.441,246.694},{2101.222,5052.694,255.454},{2108.215,5080.653,266.096},{2103.083,5119.465,278.566},{2128.192,5131.562,276.625},{2169.193,5142.881,273.937},{2208.325,5141.017,272.182},{2294.554,5160.695,287.896},{2363.101,5189.565,289.645},{2432.812,5217.912,293.149},{2483.074,5223.331,292.604},{2532.587,5213.482,290.317},{2586.806,5181.988,285.177},{2609.46,5170.991,283.571},{2668.884,5146.995,282.596},{2716.205,5131.498,286.594},{2752.745,5111.73,289.657},{2781.758,5088.176,292.237},{2819.812,5042.236,293.421},{2859.837,5006.595,293.156},{2924.874,4974.295,292.172},{2985.619,4954.408,289.407},{3039.263,4953.856,288.514},{3129.534,4952.279,290.726},{3184.116,4943.377,293.347},{3222.199,4916.937,292.137},{3261.934,4888.406,291.693},{3318.902,4871.686,293},{3388.441,4853.834,292.841},{3455.693,4828.868,291.251},{3498.203,4802.233,288.441},{3536.041,4757.897,281.609},{3586.568,4694.284,280.283},{3624.138,4685.04,279.266},{3661.88,4693.789,279.443},{3704.988,4722.323,282.43},{3702.311,4746.031,284.101},{3717.845,4820.895,282.329},{3717.603,4860.614,284.394},{3710.95,4917.596,289.995},{3693.416,4985.633,297.044},{3648.541,5015.085,293.841},{3587.807,5015.758,289.989},{3522.146,5005.667,283.998},{3463.968,5004.065,281.384},{3413.535,5007.298,279.368},{3357.305,5028.966,277.123},{3328.733,5055.897,274.111},{3291.747,5099.632,271.231},{3222.33,5117.562,276.136},{3193.081,5113.996,279.125},{3117.259,5113.294,283.061},{3058.641,5151.129,279.772},{3034.523,5191.334,271.455},{3028.48,5236.95,259.132},{3031.899,5269.961,248.582},{3011.034,5304.697,228.777},{2976.495,5317.829,205.702},{2946.085,5354.542,182.282},{2949.375,5374.793,175.336},{2999.69,5392.101,167.321},{3034.106,5384.974,166.113},{3069.978,5356.587,164.124},{3097.71,5337.34,161.976},{3139.32,5325.154,161.25},{3177.322,5318.602,161.039},{3216.795,5313.38,161.179},{3264,5298.536,164.049},{3305.993,5304.441,167.66},{3347.007,5335.607,168.348},{3385.147,5388.015,164.861},{3411.153,5412.724,163.294},{3420.506,5453.957,161.465},{3394.5,5479.717,159.417},{3348.272,5473.248,157.816},{3290.487,5498.882,156.863},{3241.404,5530.698,156.624},{3187.95,5555.186,157.069},{3141.154,5597.79,156.255},{3110.94,5620.939,154.972},{3076.909,5645.736,154.647},{3038.111,5673.792,154.48},{2999.136,5709.422,154.68},{2971.826,5747.08,153.991},{2969.181,5787.004,151.731},{2992.532,5838.131,154.022},{3007.583,5876.049,183.201},{3029.788,5975.602,209.984},{3045.725,6016.682,386.39},{3082.393,6058.833,442.347},{3115.713,6083.277,483.727},{3176.094,6127.722,515.308},{3208.808,6177.353,528.467},{3251.415,6229.122,541.055},{3299.588,6294.348,551.263},{3351.414,6357.93,556.271},{3395.706,6404.812,549.27},{3424.508,6446.738,532.455},{3438.195,6473.322,467.793},{3444.953,6489.04,387.127},{3448.194,6496.617,330.266},{3455.354,6505.316,264.133},{3482.743,6520.316,231.974},{3502.318,6539.204,216.232},{3567.053,6568.434,196.169},{3619.2,6580.327,174.663},{3685.745,6627.171,168.855},{3732.518,6655.13,176.837},{3742.325,6712.3,172.397},{3737.77,6754.059,173.483},{3724.82,6822.518,173.195},{3715.163,6916.251,170.702},{3711.75,6975.988,166.287},{3695.145,7040.043,160.878},{3678.478,7088.795,167.917},{3649.884,7147.074,163.61},{3613.348,7203.292,177.145},{3546.413,7254.008,164.272},{3493.242,7270.659,161.979},{3436.825,7283.253,162.462},{3372.283,7292.702,163.675},{3319.669,7279.217,166.565},{3277.389,7253.5,170.123},{3227.864,7218.339,176.837},{3214.104,7191.951,181.141},{3228.806,7151.962,182.765},{3228.174,7136.981,192.332},{3198.347,7109.914,232.753},{3166.505,7085.774,274.098},{3141.465,7072.989,302.292},{3134.717,7070.441,343.577},{3134.717,7070.441,396.776},{3138.948,7018.991,435.133},{3165.528,6851.994,505.672},{3177.3,6710.516,551.725},{3173.221,6647.494,565.748},{3166.455,6545.12,585.001},{3159.917,6431.702,598.054},{3150.797,6366.539,597.421},{3135.752,6294.181,588.324},{3116.816,6219.9,571.717},{3094.564,6153.956,547.348},{3068.535,6102.034,495.843},{3041.445,6072.717,441.237},{2976.875,6049.719,325.079},{2918.653,6055.494,219.858},{2879.005,6090.465,168.009},{2821.213,6204.225,89.9},{2774.91,6304.862,64.283},{2724.575,6380.582,58.109},{2669.071,6396.866,54.135},{2551.881,6430.279,49.557},{2459.078,6446.227,50.594},{2356.161,6444.425,50.706},{2267.465,6435.938,50.799},{2181.71,6437.905,45.174},{2117.127,6446.916,38.234},{2077.593,6455.137,32.107},{2038.224,6440.02,43.894},{1950.412,6437.253,99.345},{1934.233,6450.163,125.844},{1976.144,6454.764,183.311},{2010.576,6512.793,177.456},{2034.84,6583.243,175.417},{2081.906,6658.718,188.828},{2124.744,6732.46,193.967},{2158.109,6787.05,207.521},{2176.143,6834.28,214.362},{2164.593,6873.97,212.848},{2141.625,6910.073,221.299},{2076.626,6923.06,217.566},{2011.73,6923.097,210.992},{1935.868,6925.775,207.451},{1889.962,6914.652,196.155},{1821.255,6897.09,181.687},{1749.009,6895.366,175.664},{1697.008,6877.083,178.155},{1634.575,6835.382,175.434},{1567.091,6812.401,159.896},{1554.91,6765.882,154.544},{1593.258,6747.649,161.383},{1662.785,6714.343,164.133},{1745.668,6714.651,171.682},{1798.657,6683.466,171.74},{1852.891,6634.856,165.605},{1903.393,6593.951,169.836},{1924.508,6546.512,151.429},{1937.717,6511.489,128.62},{1893.22,6468.677,61.975},{1829.917,6493.091,44.843},{1781.111,6523.558,39.785},{1706.053,6565.4,57.942},{1653.509,6603.912,68.983},{1605.825,6613.507,87.805},{1573.49,6591.175,86.925},{1521.038,6591.482,58.739},{1443.21,6573.848,40.497},{1423.032,6513.295,33.617},{1436.547,6466.619,27.884},{1508.043,6401.185,31.56},{1554.069,6357.048,44.02},{1605.837,6341.043,50.099},{1681.185,6336.386,54.87},{1777.209,6335.36,45.79},{1807.743,6334.87,80.838},{1855.152,6337.306,128.481},{1923.793,6353.902,176.301},{1975.127,6354.973,175.516},{2018.997,6323.692,169.079},{2030.433,6236.146,157.255},{2004.221,6166.986,154.737},{1915.228,6160.064,158.216},{1854.318,6123.961,153.957},{1795.861,6098.437,152.733},{1731.622,6076.057,164.66},{1734.115,6035.489,160.134},{1821.985,6011.275,151.183},{1900.657,5980.471,156.336},{1973.158,5975.492,159.439},{2045.413,5993.904,158.994},{2107.746,6030.357,159.208},{2169.617,6082.05,154.758},}

                    Mobs_MapID = 1949
 
                    Merchant_Name = Check_Client("辛叶·快蹄","Zinyen Swiftstrider")

					Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1949, 3023, 5504, 145

					Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1949, 3019, 5450, 149

					Ammo_Vendor_Name = Check_Client("塞布雷·星歌","Cymbre Starsong")

					Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1949, 2985, 5529, 148

					Food_Vendor_Name = Check_Client("瑟尔琳萨·乌木","Xerintha Ravenoak")

					Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1949, 2949, 5457, 146
				]]
			end

			if Easy_Data["内置路径选择"] == "虚空风暴双采 - 1" then
			    Easy_Data["内置路径内容"] = [[
					Mobs_Coord = {{3294.453,2463.069,161.913},{3330.727,2482.449,163.255},{3392.061,2527.307,169.06},{3450.901,2572.919,176.934},{3506.046,2612.105,182.474},{3540.35,2648.866,187.716},{3631.137,2714.419,178.354},{3681.046,2786.986,168.429},{3613.879,2872.326,185.843},{3571.449,2928.204,173.625},{3527.938,3006.808,164.439},{3456.861,3053.944,161.043},{3403.151,3021.132,162.812},{3352.193,2929.904,164.719},{3344.88,2876.49,167.418},{3383.93,2843.794,169.16},{3439.254,2830.543,168.094},{3495.032,2831.7,167.164},{3544.79,2840.263,169.588},{3567.739,2840.813,192.033},{3645.367,2841.156,194.601},{3718.836,2913.727,161.033},{3751.731,2993.838,145.247},{3817.129,3060.05,140.92},{3925.463,3099.897,149.957},{3968.472,3058.085,152.628},{3985.927,2995.659,164.856},{3984.168,2932.407,165.852},{3988.191,2874,166.258},{4044.497,2839.736,172.418},{4103.391,2835.217,185.509},{4192.549,2842.909,191.752},{4261.936,2898.012,176.55},{4284.395,2911.095,171.138},{4339.852,2937.792,164.724},{4345.447,2978.154,155.311},{4337.889,3041.833,151.745},{4347.506,3102.992,158.541},{4337.576,3159.463,176.959},{4320.693,3166.004,191.261},{4225.061,3159.471,204.332},{4143.421,3140.824,199.725},{4081.985,3107.554,194.494},{4030.475,3057.965,188.536},{4005.418,2985.475,175.727},{4006.808,2920.335,173.658},{4021.844,2857.925,162.058},{4142.13,2867.651,186.727},{4195.926,2918.814,194.599},{4281.363,2982.471,181.217},{4364.636,3002.642,171.853},{4444.828,2991.926,155.577},{4493.009,2962.766,147.662},{4543.12,2941.021,154.477},{4554.341,2840.062,160.3},{4556.544,2790.824,183.328},{4559.284,2734.693,219.492},{4573.605,2598.801,224.854},{4573.588,2459.794,214.735},{4605.787,2368.973,205.651},{4647.392,2346.69,207.694},{4731.832,2342.417,215.893},{4748.376,2372.718,216.161},{4735.079,2410.462,223.157},{4746.988,2449.416,257.1},{4741.841,2475.43,287.207},{4720.434,2540.699,273.797},{4710.008,2587.125,256.417},{4700.041,2719.938,214.528},{4710.852,2789.051,182.592},{4750.283,2860.531,168.558},{4830.928,2898.35,165.088},{4904.827,2924.878,175.467},{4959.665,2908.934,162.178},{5033.647,2896.914,145.002},{5096.556,2921.032,138.011},{5115.356,2979.302,125.476},{5048.396,3025.788,117.642},{4992.594,3041.482,128.461},{4932.463,3024.803,140.002},{4913.434,3003.407,166.52},{4877.582,2966.751,170.728},{4841.433,2980.561,175.083},{4808.616,3032.554,190.142},{4743.79,3137.601,202.602},{4698.379,3208.612,195.101},{4637.014,3287.782,201.015},{4572.978,3351.616,182.018},{4544.685,3377.106,195.769},{4475.316,3438.251,211.747},{4422.169,3455.992,210.627},{4362.361,3452.64,202.341},{4325.773,3452.942,192.215},{4216.152,3484.634,177.989},{4143.562,3530.79,165.225},{4073.133,3593.281,154.029},{4012.16,3650.919,152.919},{3948.35,3698.431,143.199},{3919.871,3740.346,155.559},{3924.91,3764.406,159.734},{3977.736,3797.501,183.534},{4014.271,3814.778,217.61},{4055.359,3849.849,228.557},{4107.484,3911.377,217.529},{4132.013,4005.002,219.454},{4111.591,4103.957,220.781},{4019.992,4153.306,219.031},{3910.037,4154.773,231.772},{3870.598,4044.012,214.905},{3875.362,3955.99,219.268},{3898.705,3914.857,220.052},{3948.793,3861.164,213.016},{3965.655,3790.849,183.79},{4026.777,3657.155,150.08},{4060.545,3569.517,144.102},{3999.811,3495.164,147.206},{3953.036,3420.95,147.133},{3905.831,3336.35,144.554},{3917.808,3272.753,140.346},{3939.223,3188.631,143.537},{3925.834,3131.792,145.942},{3828.99,3098.682,139.425},{3707.49,3041.629,140.482},{3624.417,3011.121,143.778},{3568.135,3023.44,148.806},{3519.523,3068.509,153.109},{3452.212,3094.715,153.065},{3383.002,3071.304,154.663},{3336.736,3053.507,153.131},{3318.575,3039.506,184.471},{3263.564,3049.561,175.741},{3222.936,3088.437,153.614},{3166.989,3150.047,134.527},{3105.411,3201.548,121.928},{3095.741,3226.798,133.759},{3103.207,3281.317,135.73},{3127.334,3347.539,136.911},{3203.352,3436.903,144.227},{3285.064,3469.832,154.239},{3346.175,3496.649,170.556},{3420.117,3565.294,176.6},{3457.882,3635.988,177.998},{3499.64,3733.437,162.37},{3477.878,3822.577,168.104},{3449.548,3905.85,189.933},{3421.181,3980.219,202.464},{3358.585,4009.969,202.122},{3300.175,3999.11,199.831},{3205.228,3980.557,194.571},{3098.378,3960.414,197.61},{3038.624,3900.128,188.779},{2977.244,3843.105,181.783},{2929.221,3781.199,170.385},{2899.462,3705.852,179.921},{2920.33,3638.998,175.893},}
 

					Mobs_MapID = 1953

					Merchant_Name = Check_Client("布拉兹","Blazzle")

					Merchant_Coord.mapid, Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z = 1953, 3063, 3677, 142

					Mail_Coord.mapid, Mail_Coord.x, Mail_Coord.y, Mail_Coord.z = 1953, 3055, 3687, 143

					Ammo_Vendor_Name = Check_Client("商人迪格里兹","Dealer Digriz")

					Ammo_Vendor_Coord.mapid, Ammo_Vendor_Coord.x, Ammo_Vendor_Coord.y, Ammo_Vendor_Coord.z = 1953, 4152, 3068, 337

					Food_Vendor_Name = Check_Client("甘特","Gant")

					Food_Vendor_Coord.mapid, Food_Vendor_Coord.x, Food_Vendor_Coord.y, Food_Vendor_Coord.z = 1953, 3073, 3656, 143
				]]
			end
		end



		local Internal_Path_Drop = CreateFrame("frame",nil, Basic_UI.Internal.frame, "UIDropDownMenuTemplate")
		Internal_Path_Drop:SetPoint("TOPLeft",10,Basic_UI.Internal.Py)

        Internal_Path_Drop:SetFrameStrata('TOOLTIP')

		UIDropDownMenu_SetWidth(Internal_Path_Drop, 400)
		if Easy_Data["内置路径选择"] == nil then
			UIDropDownMenu_SetText(Internal_Path_Drop, Check_UI("无","Nil"))
		else
			UIDropDownMenu_SetText(Internal_Path_Drop, Easy_Data["内置路径选择"])
			Path_Match()
		end

		local function Path_Drop_OnClick(self, arg1, arg2, checked)
			if arg1 == 0 then
				Easy_Data["内置路径选择"] = nil
				UIDropDownMenu_SetText(Internal_Path_Drop, Check_UI("无","Nil"))
			else
                Easy_Data["内置路径选择"] = arg1
                UIDropDownMenu_SetText(Internal_Path_Drop, arg1)
			end

			Path_Match()
		end


		UIDropDownMenu_Initialize(Internal_Path_Drop, function(self, level, menuList)
			local info = UIDropDownMenu_CreateInfo()
			info.func = Path_Drop_OnClick

			info.text, info.arg1 = Check_UI("[暗影微粒 - 地狱火半岛] 右下","[Mote of Shadow - Hellfire Peninsula] 1"), "地狱火半岛 - 暗影微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[暗影微粒 - 地狱火半岛] 中间靠下","[Mote of Shadow - Hellfire Peninsula] 2"), "地狱火半岛 - 暗影微粒 - 2"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[火焰微粒 - 地狱火半岛] 右上","[Mote of Fire - Hellfire Peninsula] 1"), "地狱火半岛 - 火焰微粒 - 1"
			UIDropDownMenu_AddButton(info)


			info.text, info.arg1 = Check_UI("[空气微粒 - 影月谷] 1","[Mote of Air - Shadowmoon Valley] 1"), "影月谷 - 空气微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[空气微粒 - 影月谷] 2","[Mote of Air - Shadowmoon Valley] 2"), "影月谷 - 空气微粒 - 2"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[法力微粒 - 影月谷] 1","[Mote of Mana - Shadowmoon Valley] 1"), "影月谷 - 法力微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[法力微粒 - 影月谷] 2","[Mote of Mana - Shadowmoon Valley] 2"), "影月谷 - 法力微粒 - 2"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[水之微粒 - 影月谷] 1","[Mote of Water - Shadowmoon Valley] 1"), "影月谷 - 水之微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[火焰微粒 - 土之微粒 - 影月谷] 1","[Mote of Fire - Mote of Earth - Shadowmoon Valley] 1"), "影月谷 - 火焰微粒 - 土之微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[生命微粒 - 影月谷] 1","[Mote of Life - Shadowmoon Valley] 1"), "影月谷 - 生命微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[生命微粒 - 影月谷] 2","[Mote of Life - Shadowmoon Valley] 2"), "影月谷 - 生命微粒 - 2"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[暗影微粒 - 影月谷] 1","[Mote of Fire - Mote of Shadow - Shadowmoon Valley] 1"), "影月谷 - 暗影微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[暗影微粒 - 影月谷] 2","[Mote of Fire - Mote of Shadow - Shadowmoon Valley] 2"), "影月谷 - 暗影微粒 - 2"
			UIDropDownMenu_AddButton(info)



			info.text, info.arg1 = Check_UI("[水之微粒 - 泰罗卡森林] 1","[Mote of Water - Terokkar Forest] 1"), "泰罗卡森林 - 水之微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[生命微粒 - 泰罗卡森林] 1","[Mote of Life - Terokkar Forest] 1"), "泰罗卡森林 - 生命微粒 - 1"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[生命微粒 - 泰罗卡森林] 2","[Mote of Life - Terokkar Forest] 2"), "泰罗卡森林 - 生命微粒 - 2"
			UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[生命微粒 - 泰罗卡森林] 3","[Mote of Life - Terokkar Forest] 3"), "泰罗卡森林 - 生命微粒 - 3"
			UIDropDownMenu_AddButton(info)




            info.text, info.arg1 = Check_UI("[纳格兰] 野外双采 + 吸气 - 1","[Nagrand] Mining + Herbalism + Mote - 1"), "纳格兰双采 - 1"
			--UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[赞加沼泽] 野外双采 + 吸气 - 1","[Zangarmarsh] Mining + Herbalism + Mote - 1"), "赞加沼泽双采 - 1"
			--UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[刀锋山] 野外双采 + 吸气 - 1","[Blade's Edge Mountains] Mining + Herbalism + Mote - 1"), "刀锋山双采 - 1"
			--UIDropDownMenu_AddButton(info)

			info.text, info.arg1 = Check_UI("[虚空风暴] 野外双采 + 吸气 - 1","[Netherstorm] Mining + Herbalism + Mote - 1"), "虚空风暴双采 - 1"
			--UIDropDownMenu_AddButton(info)

		end)
	end

	Internal_Set_UI()
	Path_Choose()
end

local function Create_Rotation_UI() -- 战斗UI
    Basic_UI.Combat = {}
	Basic_UI.Combat.Py = -10
	local function Frame_Create()
		Basic_UI.Combat.frame = CreateFrame('frame',"Basic_UI.Combat.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Combat.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Combat.frame:SetSize(600,1500)
		Basic_UI.Combat.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Combat.frame:Hide()
		Basic_UI.Combat.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Combat.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Combat.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("战斗系统","rotation"))
		Basic_UI.Combat.button:SetSize(130,20)
		Basic_UI.Combat.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Combat.frame:Show()
			Basic_UI.Combat.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Combat.frame:Hide() Basic_UI.Combat.button:SetBackdropColor(0,0,0,0) end
	end

	Frame_Create()
	Button_Create()


	if Class == "ROGUE" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("使用 终结技能的连击点数","Combat points to cast spells")) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["盗贼终结点数"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"5",false,280,24)
		Basic_UI.Combat["盗贼终结点数"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["盗贼终结点数"] = tonumber(Basic_UI.Combat["盗贼终结点数"]:GetText())
		end)
		if Easy_Data.Combat["盗贼终结点数"] ~= nil then
			Basic_UI.Combat["盗贼终结点数"]:SetText(Easy_Data.Combat["盗贼终结点数"])
		else
			Easy_Data.Combat["盗贼终结点数"] = tonumber(Basic_UI.Combat["盗贼终结点数"]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["盗贼毒药"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 毒药","Use poison"))
		Basic_UI.Combat["盗贼毒药"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["盗贼毒药"]:GetChecked() then
				Easy_Data.Combat["盗贼毒药"] = true
			elseif not Basic_UI.Combat["盗贼毒药"]:GetChecked() then
				Easy_Data.Combat["盗贼毒药"] = false
			end
		end)
		if Easy_Data.Combat["盗贼毒药"] ~= nil then
			if Easy_Data.Combat["盗贼毒药"] then
				Basic_UI.Combat["盗贼毒药"]:SetChecked(true)
			else
				Basic_UI.Combat["盗贼毒药"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["盗贼毒药"] = true
			Basic_UI.Combat["盗贼毒药"]:SetChecked(true)
		end

		local Spell = 
		{
			{rs["切割"],true},
			{rs["刺骨"],true},
			{rs["割裂"],false},
			{rs["破甲"],false},
			{rs["肾击"],true},
			{rs["佯攻"],false},
		}

		for i = 1,#Spell do
			local Var = "盗贼"..Spell[i][1]
			if i%2 ~= 0 then
			    Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
				Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..Spell[i][1])
            else
			    Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",280, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..Spell[i][1])
			end

			Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
				if Basic_UI.Combat[Var]:GetChecked() then
					Easy_Data.Combat[Var] = true
				elseif not Basic_UI.Combat[Var]:GetChecked() then
					Easy_Data.Combat[Var] = false
				end
			end)
			if Easy_Data.Combat[Var] ~= nil then
				if Easy_Data.Combat[Var] then
					Basic_UI.Combat[Var]:SetChecked(true)
				else
					Basic_UI.Combat[Var]:SetChecked(false)
				end
			else
				Easy_Data.Combat[Var] = Spell[i][2]
				Basic_UI.Combat[Var]:SetChecked(Spell[i][2])
			end
		end

	
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 使用 - ","Health percentage to use ")..rs["闪避"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["盗贼闪避血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"40",false,280,24)
		Basic_UI.Combat["盗贼闪避血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["盗贼闪避血量"] = tonumber(Basic_UI.Combat["盗贼闪避血量"]:GetText())
		end)
		if Easy_Data.Combat["盗贼闪避血量"] ~= nil then
			Basic_UI.Combat["盗贼闪避血量"]:SetText(Easy_Data.Combat["盗贼闪避血量"])
		else
			Easy_Data.Combat["盗贼闪避血量"] = tonumber(Basic_UI.Combat["盗贼闪避血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 使用 - ","Health percentage to use ")..rs["消失"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["盗贼消失血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"10",false,280,24)
		Basic_UI.Combat["盗贼消失血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["盗贼消失血量"] = tonumber(Basic_UI.Combat["盗贼消失血量"]:GetText())
		end)
		if Easy_Data.Combat["盗贼消失血量"] ~= nil then
			Basic_UI.Combat["盗贼消失血量"]:SetText(Easy_Data.Combat["盗贼消失血量"])
		else
			Easy_Data.Combat["盗贼消失血量"] = tonumber(Basic_UI.Combat["盗贼消失血量"]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("消失后回血回蓝时间 (秒)","Eat and Drink time after vanish (Sec)")) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["盗贼消失时间"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"10",false,280,24)
		Basic_UI.Combat["盗贼消失时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["盗贼消失时间"] = tonumber(Basic_UI.Combat["盗贼消失时间"]:GetText())
		end)
		if Easy_Data.Combat["盗贼消失时间"] ~= nil then
			Basic_UI.Combat["盗贼消失时间"]:SetText(Easy_Data.Combat["盗贼消失时间"])
		else
			Easy_Data.Combat["盗贼消失时间"] = tonumber(Basic_UI.Combat["盗贼消失时间"]:GetText())
		end
	end
	if Class == "HUNTER" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["假死"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["猎人假死血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"30",false,280,24)
		Basic_UI.Combat["猎人假死血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["猎人假死血量"] = tonumber(Basic_UI.Combat["猎人假死血量"]:GetText())
		end)
		if Easy_Data.Combat["猎人假死血量"] ~= nil then
			Basic_UI.Combat["猎人假死血量"]:SetText(Easy_Data.Combat["猎人假死血量"])
		else
			Easy_Data.Combat["猎人假死血量"] = tonumber(Basic_UI.Combat["猎人假死血量"]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 使用 - ","Health percentage to use ")..rs["治疗宠物"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["猎人治疗宠物血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"40",false,280,24)
		Basic_UI.Combat["猎人治疗宠物血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["猎人治疗宠物血量"] = tonumber(Basic_UI.Combat["猎人治疗宠物血量"]:GetText())
		end)
		if Easy_Data.Combat["猎人治疗宠物血量"] ~= nil then
			Basic_UI.Combat["猎人治疗宠物血量"]:SetText(Easy_Data.Combat["猎人治疗宠物血量"])
		else
			Easy_Data.Combat["猎人治疗宠物血量"] = tonumber(Basic_UI.Combat["猎人治疗宠物血量"]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人狂野怒火"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["狂野怒火"])
		Basic_UI.Combat["猎人狂野怒火"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人狂野怒火"]:GetChecked() then
				Easy_Data.Combat["猎人狂野怒火"] = true
			elseif not Basic_UI.Combat["猎人狂野怒火"]:GetChecked() then
				Easy_Data.Combat["猎人狂野怒火"] = false
			end
		end)
		if Easy_Data.Combat["猎人狂野怒火"] ~= nil then
			if Easy_Data.Combat["猎人狂野怒火"] then
				Basic_UI.Combat["猎人狂野怒火"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人狂野怒火"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人狂野怒火"] = true
			Basic_UI.Combat["猎人狂野怒火"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人胁迫"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["胁迫"])
		Basic_UI.Combat["猎人胁迫"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人胁迫"]:GetChecked() then
				Easy_Data.Combat["猎人胁迫"] = true
			elseif not Basic_UI.Combat["猎人胁迫"]:GetChecked() then
				Easy_Data.Combat["猎人胁迫"] = false
			end
		end)
		if Easy_Data.Combat["猎人胁迫"] ~= nil then
			if Easy_Data.Combat["猎人胁迫"] then
				Basic_UI.Combat["猎人胁迫"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人胁迫"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人胁迫"] = true
			Basic_UI.Combat["猎人胁迫"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人冰冻陷阱"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冰冻陷阱"])
		Basic_UI.Combat["猎人冰冻陷阱"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人冰冻陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人冰冻陷阱"] = true
			elseif not Basic_UI.Combat["猎人冰冻陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人冰冻陷阱"] = false
			end
		end)
		if Easy_Data.Combat["猎人冰冻陷阱"] ~= nil then
			if Easy_Data.Combat["猎人冰冻陷阱"] then
				Basic_UI.Combat["猎人冰冻陷阱"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人冰冻陷阱"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人冰冻陷阱"] = false
			Basic_UI.Combat["猎人冰冻陷阱"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人爆炸陷阱"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["爆炸陷阱"])
		Basic_UI.Combat["猎人爆炸陷阱"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人爆炸陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人爆炸陷阱"] = true
			elseif not Basic_UI.Combat["猎人爆炸陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人爆炸陷阱"] = false
			end
		end)
		if Easy_Data.Combat["猎人爆炸陷阱"] ~= nil then
			if Easy_Data.Combat["猎人爆炸陷阱"] then
				Basic_UI.Combat["猎人爆炸陷阱"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人爆炸陷阱"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人爆炸陷阱"] = false
			Basic_UI.Combat["猎人爆炸陷阱"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人献祭陷阱"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["献祭陷阱"])
		Basic_UI.Combat["猎人献祭陷阱"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人献祭陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人献祭陷阱"] = true
			elseif not Basic_UI.Combat["猎人献祭陷阱"]:GetChecked() then
				Easy_Data.Combat["猎人献祭陷阱"] = false
			end
		end)
		if Easy_Data.Combat["猎人献祭陷阱"] ~= nil then
			if Easy_Data.Combat["猎人献祭陷阱"] then
				Basic_UI.Combat["猎人献祭陷阱"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人献祭陷阱"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人献祭陷阱"] = true
			Basic_UI.Combat["猎人献祭陷阱"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人奥术射击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["奥术射击"])
		Basic_UI.Combat["猎人奥术射击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人奥术射击"]:GetChecked() then
				Easy_Data.Combat["猎人奥术射击"] = true
			elseif not Basic_UI.Combat["猎人奥术射击"]:GetChecked() then
				Easy_Data.Combat["猎人奥术射击"] = false
			end
		end)
		if Easy_Data.Combat["猎人奥术射击"] ~= nil then
			if Easy_Data.Combat["猎人奥术射击"] then
				Basic_UI.Combat["猎人奥术射击"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人奥术射击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人奥术射击"] = true
			Basic_UI.Combat["猎人奥术射击"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人震荡射击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["震荡射击"])
		Basic_UI.Combat["猎人震荡射击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人震荡射击"]:GetChecked() then
				Easy_Data.Combat["猎人震荡射击"] = true
			elseif not Basic_UI.Combat["猎人震荡射击"]:GetChecked() then
				Easy_Data.Combat["猎人震荡射击"] = false
			end
		end)
		if Easy_Data.Combat["猎人震荡射击"] ~= nil then
			if Easy_Data.Combat["猎人震荡射击"] then
				Basic_UI.Combat["猎人震荡射击"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人震荡射击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人震荡射击"] = true
			Basic_UI.Combat["猎人震荡射击"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人多重射击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["多重射击"])
		Basic_UI.Combat["猎人多重射击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人多重射击"]:GetChecked() then
				Easy_Data.Combat["猎人多重射击"] = true
			elseif not Basic_UI.Combat["猎人多重射击"]:GetChecked() then
				Easy_Data.Combat["猎人多重射击"] = false
			end
		end)
		if Easy_Data.Combat["猎人多重射击"] ~= nil then
			if Easy_Data.Combat["猎人多重射击"] then
				Basic_UI.Combat["猎人多重射击"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人多重射击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人多重射击"] = true
			Basic_UI.Combat["猎人多重射击"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人逃脱"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["逃脱"])
		Basic_UI.Combat["猎人逃脱"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人蝰蛇钉刺"]:GetChecked() then
				Easy_Data.Combat["猎人逃脱"] = true
			elseif not Basic_UI.Combat["猎人逃脱"]:GetChecked() then
				Easy_Data.Combat["猎人逃脱"] = false
			end
		end)
		if Easy_Data.Combat["猎人逃脱"] ~= nil then
			if Easy_Data.Combat["猎人逃脱"] then
				Basic_UI.Combat["猎人逃脱"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人逃脱"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人逃脱"] = true
			Basic_UI.Combat["猎人逃脱"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人毒蛇钉刺"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["毒蛇钉刺"])
		Basic_UI.Combat["猎人毒蛇钉刺"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人毒蛇钉刺"]:GetChecked() then
				Easy_Data.Combat["猎人毒蛇钉刺"] = true
			elseif not Basic_UI.Combat["猎人毒蛇钉刺"]:GetChecked() then
				Easy_Data.Combat["猎人毒蛇钉刺"] = false
			end
		end)
		if Easy_Data.Combat["猎人毒蛇钉刺"] ~= nil then
			if Easy_Data.Combat["猎人毒蛇钉刺"] then
				Basic_UI.Combat["猎人毒蛇钉刺"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人毒蛇钉刺"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人毒蛇钉刺"] = true
			Basic_UI.Combat["猎人毒蛇钉刺"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["猎人蝰蛇钉刺"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["蝰蛇钉刺"])
		Basic_UI.Combat["猎人蝰蛇钉刺"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["猎人蝰蛇钉刺"]:GetChecked() then
				Easy_Data.Combat["猎人蝰蛇钉刺"] = true
			elseif not Basic_UI.Combat["猎人蝰蛇钉刺"]:GetChecked() then
				Easy_Data.Combat["猎人蝰蛇钉刺"] = false
			end
		end)
		if Easy_Data.Combat["猎人蝰蛇钉刺"] ~= nil then
			if Easy_Data.Combat["猎人蝰蛇钉刺"] then
				Basic_UI.Combat["猎人蝰蛇钉刺"]:SetChecked(true)
			else
				Basic_UI.Combat["猎人蝰蛇钉刺"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["猎人蝰蛇钉刺"] = false
			Basic_UI.Combat["猎人蝰蛇钉刺"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("敌人蓝量 使用 - ","Target Power to use ")..rs["蝰蛇钉刺"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["猎人蝰蛇钉刺蓝量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"400",false,280,24)
		Basic_UI.Combat["猎人蝰蛇钉刺蓝量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["猎人蝰蛇钉刺蓝量"] = tonumber(Basic_UI.Combat["猎人蝰蛇钉刺蓝量"]:GetText())
		end)
		if Easy_Data.Combat["猎人蝰蛇钉刺蓝量"] ~= nil then
			Basic_UI.Combat["猎人蝰蛇钉刺蓝量"]:SetText(Easy_Data.Combat["猎人蝰蛇钉刺蓝量"])
		else
			Easy_Data.Combat["猎人蝰蛇钉刺蓝量"] = tonumber(Basic_UI.Combat["猎人蝰蛇钉刺蓝量"]:GetText())
		end
	end

	if Class == "MAGE" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		Basic_UI.Combat["法师奥术飞弹"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["奥术飞弹"])
		Basic_UI.Combat["法师奥术飞弹"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师奥术飞弹"]:GetChecked() then
				Easy_Data.Combat["法师奥术飞弹"] = true
			elseif not Basic_UI.Combat["法师奥术飞弹"]:GetChecked() then
				Easy_Data.Combat["法师奥术飞弹"] = false
			end
		end)
		if Easy_Data.Combat["法师奥术飞弹"] ~= nil then
			if Easy_Data.Combat["法师奥术飞弹"] then
				Basic_UI.Combat["法师奥术飞弹"]:SetChecked(true)
			else
				Basic_UI.Combat["法师奥术飞弹"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师奥术飞弹"] = false
			Basic_UI.Combat["法师奥术飞弹"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师暴风雪"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["暴风雪"])
		Basic_UI.Combat["法师暴风雪"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师暴风雪"]:GetChecked() then
				Easy_Data.Combat["法师暴风雪"] = true
			elseif not Basic_UI.Combat["法师暴风雪"]:GetChecked() then
				Easy_Data.Combat["法师暴风雪"] = false
			end
		end)
		if Easy_Data.Combat["法师暴风雪"] ~= nil then
			if Easy_Data.Combat["法师暴风雪"] then
				Basic_UI.Combat["法师暴风雪"]:SetChecked(true)
			else
				Basic_UI.Combat["法师暴风雪"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师暴风雪"] = false
			Basic_UI.Combat["法师暴风雪"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师冰甲术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冰甲术"])
		Basic_UI.Combat["法师冰甲术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师冰甲术"]:GetChecked() then
				Easy_Data.Combat["法师冰甲术"] = true

				Basic_UI.Combat["法师魔甲术"] = false
				Basic_UI.Combat["法师魔甲术"]:SetChecked(false)

				Easy_Data.Combat["法师熔岩护甲"] = false
				Basic_UI.Combat["法师熔岩护甲"]:SetChecked(false)
			elseif not Basic_UI.Combat["法师冰甲术"]:GetChecked() then
				Easy_Data.Combat["法师冰甲术"] = false
			end
		end)
		if Easy_Data.Combat["法师冰甲术"] ~= nil then
			if Easy_Data.Combat["法师冰甲术"] then
				Basic_UI.Combat["法师冰甲术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师冰甲术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师冰甲术"] = true
			Basic_UI.Combat["法师冰甲术"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师熔岩护甲"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["熔岩护甲"])
		Basic_UI.Combat["法师熔岩护甲"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师熔岩护甲"]:GetChecked() then
				Easy_Data.Combat["法师熔岩护甲"] = true

				Basic_UI.Combat["法师魔甲术"] = false
				Basic_UI.Combat["法师魔甲术"]:SetChecked(false)

				Basic_UI.Combat["法师冰甲术"] = false
				Basic_UI.Combat["法师冰甲术"]:SetChecked(false)
			elseif not Basic_UI.Combat["法师熔岩护甲"]:GetChecked() then
				Easy_Data.Combat["法师熔岩护甲"] = false
			end
		end)
		if Easy_Data.Combat["法师熔岩护甲"] ~= nil then
			if Easy_Data.Combat["法师熔岩护甲"] then
				Basic_UI.Combat["法师熔岩护甲"]:SetChecked(true)
			else
				Basic_UI.Combat["法师熔岩护甲"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师熔岩护甲"] = false
			Basic_UI.Combat["法师熔岩护甲"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师活动炸弹"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["活动炸弹"])
		Basic_UI.Combat["法师活动炸弹"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师活动炸弹"]:GetChecked() then
				Easy_Data.Combat["法师活动炸弹"] = true
			elseif not Basic_UI.Combat["法师活动炸弹"]:GetChecked() then
				Easy_Data.Combat["法师活动炸弹"] = false
			end
		end)
		if Easy_Data.Combat["法师活动炸弹"] ~= nil then
			if Easy_Data.Combat["法师活动炸弹"] then
				Basic_UI.Combat["法师活动炸弹"]:SetChecked(true)
			else
				Basic_UI.Combat["法师活动炸弹"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师活动炸弹"] = false
			Basic_UI.Combat["法师活动炸弹"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师冰枪术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冰枪术"])
		Basic_UI.Combat["法师冰枪术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师冰枪术"]:GetChecked() then
				Easy_Data.Combat["法师冰枪术"] = true
			elseif not Basic_UI.Combat["法师冰枪术"]:GetChecked() then
				Easy_Data.Combat["法师冰枪术"] = false
			end
		end)
		if Easy_Data.Combat["法师冰枪术"] ~= nil then
			if Easy_Data.Combat["法师冰枪术"] then
				Basic_UI.Combat["法师冰枪术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师冰枪术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师冰枪术"] = true
			Basic_UI.Combat["法师冰枪术"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师冰锥术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冰锥术"])
		Basic_UI.Combat["法师冰锥术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师冰锥术"]:GetChecked() then
				Easy_Data.Combat["法师冰锥术"] = true
			elseif not Basic_UI.Combat["法师冰锥术"]:GetChecked() then
				Easy_Data.Combat["法师冰锥术"] = false
			end
		end)
		if Easy_Data.Combat["法师冰锥术"] ~= nil then
			if Easy_Data.Combat["法师冰锥术"] then
				Basic_UI.Combat["法师冰锥术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师冰锥术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师冰锥术"] = true
			Basic_UI.Combat["法师冰锥术"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师冲击波"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冲击波"])
		Basic_UI.Combat["法师冲击波"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师冲击波"]:GetChecked() then
				Easy_Data.Combat["法师冲击波"] = true
			elseif not Basic_UI.Combat["法师冲击波"]:GetChecked() then
				Easy_Data.Combat["法师冲击波"] = false
			end
		end)
		if Easy_Data.Combat["法师冲击波"] ~= nil then
			if Easy_Data.Combat["法师冲击波"] then
				Basic_UI.Combat["法师冲击波"]:SetChecked(true)
			else
				Basic_UI.Combat["法师冲击波"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师冲击波"] = false
			Basic_UI.Combat["法师冲击波"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师法力护盾"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["法力护盾"])
		Basic_UI.Combat["法师法力护盾"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师法力护盾"]:GetChecked() then
				Easy_Data.Combat["法师法力护盾"] = true
			elseif not Basic_UI.Combat["法师法力护盾"]:GetChecked() then
				Easy_Data.Combat["法师法力护盾"] = false
			end
		end)
		if Easy_Data.Combat["法师法力护盾"] ~= nil then
			if Easy_Data.Combat["法师法力护盾"] then
				Basic_UI.Combat["法师法力护盾"]:SetChecked(true)
			else
				Basic_UI.Combat["法师法力护盾"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师法力护盾"] = false
			Basic_UI.Combat["法师法力护盾"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师寒冰护体"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["寒冰护体"])
		Basic_UI.Combat["法师寒冰护体"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师寒冰护体"]:GetChecked() then
				Easy_Data.Combat["法师寒冰护体"] = true
			elseif not Basic_UI.Combat["法师寒冰护体"]:GetChecked() then
				Easy_Data.Combat["法师寒冰护体"] = false
			end
		end)
		if Easy_Data.Combat["法师寒冰护体"] ~= nil then
			if Easy_Data.Combat["法师寒冰护体"] then
				Basic_UI.Combat["法师寒冰护体"]:SetChecked(true)
			else
				Basic_UI.Combat["法师寒冰护体"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师寒冰护体"] = true
			Basic_UI.Combat["法师寒冰护体"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师寒冰箭"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["寒冰箭"])
		Basic_UI.Combat["法师寒冰箭"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师寒冰箭"]:GetChecked() then
				Easy_Data.Combat["法师寒冰箭"] = true
			elseif not Basic_UI.Combat["法师寒冰箭"]:GetChecked() then
				Easy_Data.Combat["法师寒冰箭"] = false
			end
		end)
		if Easy_Data.Combat["法师寒冰箭"] ~= nil then
			if Easy_Data.Combat["法师寒冰箭"] then
				Basic_UI.Combat["法师寒冰箭"]:SetChecked(true)
			else
				Basic_UI.Combat["法师寒冰箭"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师寒冰箭"] = true
			Basic_UI.Combat["法师寒冰箭"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师火球术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["火球术"])
		Basic_UI.Combat["法师火球术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师火球术"]:GetChecked() then
				Easy_Data.Combat["法师火球术"] = true
			elseif not Basic_UI.Combat["法师火球术"]:GetChecked() then
				Easy_Data.Combat["法师火球术"] = false
			end
		end)
		if Easy_Data.Combat["法师火球术"] ~= nil then
			if Easy_Data.Combat["法师火球术"] then
				Basic_UI.Combat["法师火球术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师火球术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师火球术"] = false
			Basic_UI.Combat["法师火球术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师烈焰风暴"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["烈焰风暴"])
		Basic_UI.Combat["法师烈焰风暴"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师烈焰风暴"]:GetChecked() then
				Easy_Data.Combat["法师烈焰风暴"] = true
			elseif not Basic_UI.Combat["法师烈焰风暴"]:GetChecked() then
				Easy_Data.Combat["法师烈焰风暴"] = false
			end
		end)
		if Easy_Data.Combat["法师烈焰风暴"] ~= nil then
			if Easy_Data.Combat["法师烈焰风暴"] then
				Basic_UI.Combat["法师烈焰风暴"]:SetChecked(true)
			else
				Basic_UI.Combat["法师烈焰风暴"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师烈焰风暴"] = false
			Basic_UI.Combat["法师烈焰风暴"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师龙息术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["龙息术"])
		Basic_UI.Combat["法师龙息术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师龙息术"]:GetChecked() then
				Easy_Data.Combat["法师龙息术"] = true
			elseif not Basic_UI.Combat["法师龙息术"]:GetChecked() then
				Easy_Data.Combat["法师龙息术"] = false
			end
		end)
		if Easy_Data.Combat["法师龙息术"] ~= nil then
			if Easy_Data.Combat["法师龙息术"] then
				Basic_UI.Combat["法师龙息术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师龙息术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师龙息术"] = false
			Basic_UI.Combat["法师龙息术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师魔法抑制"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["魔法抑制"])
		Basic_UI.Combat["法师魔法抑制"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师魔法抑制"]:GetChecked() then
				Easy_Data.Combat["法师魔法抑制"] = true
			elseif not Basic_UI.Combat["法师魔法抑制"]:GetChecked() then
				Easy_Data.Combat["法师魔法抑制"] = false
			end
		end)
		if Easy_Data.Combat["法师魔法抑制"] ~= nil then
			if Easy_Data.Combat["法师魔法抑制"] then
				Basic_UI.Combat["法师魔法抑制"]:SetChecked(true)
			else
				Basic_UI.Combat["法师魔法抑制"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师魔法抑制"] = false
			Basic_UI.Combat["法师魔法抑制"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师魔法增效"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["魔法增效"])
		Basic_UI.Combat["法师魔法增效"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师魔法增效"]:GetChecked() then
				Easy_Data.Combat["法师魔法增效"] = true
			elseif not Basic_UI.Combat["法师魔法增效"]:GetChecked() then
				Easy_Data.Combat["法师魔法增效"] = false
			end
		end)
		if Easy_Data.Combat["法师魔法增效"] ~= nil then
			if Easy_Data.Combat["法师魔法增效"] then
				Basic_UI.Combat["法师魔法增效"]:SetChecked(true)
			else
				Basic_UI.Combat["法师魔法增效"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师魔法增效"] = true
			Basic_UI.Combat["法师魔法增效"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师魔甲术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["法师魔甲术"])
		Basic_UI.Combat["法师魔甲术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师魔甲术"]:GetChecked() then
				Easy_Data.Combat["法师魔甲术"] = true

				Easy_Data.Combat["法师冰甲术"] = false
				Basic_UI.Combat["法师冰甲术"]:SetChecked(false)

				Easy_Data.Combat["法师熔岩护甲"] = false
				Basic_UI.Combat["法师熔岩护甲"]:SetChecked(false)
			elseif not Basic_UI.Combat["法师魔甲术"]:GetChecked() then
				Easy_Data.Combat["法师魔甲术"] = false
			end
		end)
		if Easy_Data.Combat["法师魔甲术"] ~= nil then
			if Easy_Data.Combat["法师魔甲术"] then
				Basic_UI.Combat["法师魔甲术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师魔甲术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师魔甲术"] = false
			Basic_UI.Combat["法师魔甲术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师炎爆术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["炎爆术"])
		Basic_UI.Combat["法师炎爆术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师炎爆术"]:GetChecked() then
				Easy_Data.Combat["法师炎爆术"] = true
			elseif not Basic_UI.Combat["法师炎爆术"]:GetChecked() then
				Easy_Data.Combat["法师炎爆术"] = false
			end
		end)
		if Easy_Data.Combat["法师炎爆术"] ~= nil then
			if Easy_Data.Combat["法师炎爆术"] then
				Basic_UI.Combat["法师炎爆术"]:SetChecked(true)
			else
				Basic_UI.Combat["法师炎爆术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师炎爆术"] = false
			Basic_UI.Combat["法师炎爆术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师召唤水元素"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤水元素"])
		Basic_UI.Combat["法师召唤水元素"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师召唤水元素"]:GetChecked() then
				Easy_Data.Combat["法师召唤水元素"] = true
			elseif not Basic_UI.Combat["法师召唤水元素"]:GetChecked() then
				Easy_Data.Combat["法师召唤水元素"] = false
			end
		end)
		if Easy_Data.Combat["法师召唤水元素"] ~= nil then
			if Easy_Data.Combat["法师召唤水元素"] then
				Basic_UI.Combat["法师召唤水元素"]:SetChecked(true)
			else
				Basic_UI.Combat["法师召唤水元素"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师召唤水元素"] = true
			Basic_UI.Combat["法师召唤水元素"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["法师灼烧"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["灼烧"])
		Basic_UI.Combat["法师灼烧"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["法师灼烧"]:GetChecked() then
				Easy_Data.Combat["法师灼烧"] = true
			elseif not Basic_UI.Combat["法师灼烧"]:GetChecked() then
				Easy_Data.Combat["法师灼烧"] = false
			end
		end)
		if Easy_Data.Combat["法师灼烧"] ~= nil then
			if Easy_Data.Combat["法师灼烧"] then
				Basic_UI.Combat["法师灼烧"]:SetChecked(true)
			else
				Basic_UI.Combat["法师灼烧"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["法师灼烧"] = true
			Basic_UI.Combat["法师灼烧"]:SetChecked(true)
		end
	end

	if Class == "WARRIOR" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		Basic_UI.Combat["战士战斗姿态"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["战斗姿态"])
		Basic_UI.Combat["战士战斗姿态"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士战斗姿态"]:GetChecked() then
				Easy_Data.Combat["战士战斗姿态"] = true

				Easy_Data.Combat["战士狂暴姿态"] = false
				Basic_UI.Combat["战士狂暴姿态"]:SetChecked(false)

				Easy_Data.Combat["战士防御姿态"] = false
				Basic_UI.Combat["战士防御姿态"]:SetChecked(false)
			elseif not Basic_UI.Combat["战士战斗姿态"]:GetChecked() then
				Easy_Data.Combat["战士战斗姿态"] = false
			end
		end)
		if Easy_Data.Combat["战士战斗姿态"] ~= nil then
			if Easy_Data.Combat["战士战斗姿态"] then
				Basic_UI.Combat["战士战斗姿态"]:SetChecked(true)
			else
				Basic_UI.Combat["战士战斗姿态"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士战斗姿态"] = false
			Basic_UI.Combat["战士战斗姿态"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士防御姿态"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["防御姿态"])
		Basic_UI.Combat["战士防御姿态"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士防御姿态"]:GetChecked() then
				Easy_Data.Combat["战士防御姿态"] = true

				Easy_Data.Combat["战士狂暴姿态"] = false
				Basic_UI.Combat["战士狂暴姿态"]:SetChecked(false)

				Easy_Data.Combat["战士战斗姿态"] = false
				Basic_UI.Combat["战士战斗姿态"]:SetChecked(false)
			elseif not Basic_UI.Combat["战士防御姿态"]:GetChecked() then
				Easy_Data.Combat["战士防御姿态"] = false
			end
		end)
		if Easy_Data.Combat["战士防御姿态"] ~= nil then
			if Easy_Data.Combat["战士防御姿态"] then
				Basic_UI.Combat["战士防御姿态"]:SetChecked(true)
			else
				Basic_UI.Combat["战士防御姿态"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士防御姿态"] = true
			Basic_UI.Combat["战士防御姿态"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士狂暴姿态"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["狂暴姿态"])
		Basic_UI.Combat["战士狂暴姿态"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士狂暴姿态"]:GetChecked() then
				Easy_Data.Combat["战士狂暴姿态"] = true

				Easy_Data.Combat["战士战斗姿态"] = false
				Basic_UI.Combat["战士战斗姿态"]:SetChecked(false)

				Easy_Data.Combat["战士防御姿态"] = false
				Basic_UI.Combat["战士防御姿态"]:SetChecked(false)
			elseif not Basic_UI.Combat["战士狂暴姿态"]:GetChecked() then
				Easy_Data.Combat["战士狂暴姿态"] = false
			end
		end)
		if Easy_Data.Combat["战士狂暴姿态"] ~= nil then
			if Easy_Data.Combat["战士狂暴姿态"] then
				Basic_UI.Combat["战士狂暴姿态"]:SetChecked(true)
			else
				Basic_UI.Combat["战士狂暴姿态"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士狂暴姿态"] = false
			Basic_UI.Combat["战士狂暴姿态"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士死亡之愿"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["死亡之愿"])
		Basic_UI.Combat["战士死亡之愿"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士死亡之愿"]:GetChecked() then
				Easy_Data.Combat["战士死亡之愿"] = true
			elseif not Basic_UI.Combat["战士死亡之愿"]:GetChecked() then
				Easy_Data.Combat["战士死亡之愿"] = false
			end
		end)
		if Easy_Data.Combat["战士死亡之愿"] ~= nil then
			if Easy_Data.Combat["战士死亡之愿"] then
				Basic_UI.Combat["战士死亡之愿"]:SetChecked(true)
			else
				Basic_UI.Combat["战士死亡之愿"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士死亡之愿"] = true
			Basic_UI.Combat["战士死亡之愿"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士致死打击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["致死打击"])
		Basic_UI.Combat["战士致死打击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士致死打击"]:GetChecked() then
				Easy_Data.Combat["战士致死打击"] = true
			elseif not Basic_UI.Combat["战士致死打击"]:GetChecked() then
				Easy_Data.Combat["战士致死打击"] = false
			end
		end)
		if Easy_Data.Combat["战士致死打击"] ~= nil then
			if Easy_Data.Combat["战士致死打击"] then
				Basic_UI.Combat["战士致死打击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士致死打击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士致死打击"] = false
			Basic_UI.Combat["战士致死打击"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士刺耳怒吼"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["刺耳怒吼"])
		Basic_UI.Combat["战士刺耳怒吼"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士刺耳怒吼"]:GetChecked() then
				Easy_Data.Combat["战士刺耳怒吼"] = true

			elseif not Basic_UI.Combat["战士刺耳怒吼"]:GetChecked() then
				Easy_Data.Combat["战士刺耳怒吼"] = false
			end
		end)
		if Easy_Data.Combat["战士刺耳怒吼"] ~= nil then
			if Easy_Data.Combat["战士刺耳怒吼"] then
				Basic_UI.Combat["战士刺耳怒吼"]:SetChecked(true)
			else
				Basic_UI.Combat["战士刺耳怒吼"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士刺耳怒吼"] = false
			Basic_UI.Combat["战士刺耳怒吼"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士战斗怒吼"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["战斗怒吼"])
		Basic_UI.Combat["战士战斗怒吼"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士战斗怒吼"]:GetChecked() then
				Easy_Data.Combat["战士战斗怒吼"] = true

				Easy_Data.Combat["战士挫志怒吼"] = false
			    Basic_UI.Combat["战士挫志怒吼"]:SetChecked(false)

				Easy_Data.Combat["战士命令怒吼"] = false
				Basic_UI.Combat["战士命令怒吼"]:SetChecked(false)

			elseif not Basic_UI.Combat["战士战斗怒吼"]:GetChecked() then
				Easy_Data.Combat["战士战斗怒吼"] = false
			end
		end)
		if Easy_Data.Combat["战士战斗怒吼"] ~= nil then
			if Easy_Data.Combat["战士战斗怒吼"] then
				Basic_UI.Combat["战士战斗怒吼"]:SetChecked(true)
			else
				Basic_UI.Combat["战士战斗怒吼"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士战斗怒吼"] = false
			Basic_UI.Combat["战士战斗怒吼"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士命令怒吼"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["命令怒吼"])
		Basic_UI.Combat["战士命令怒吼"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士命令怒吼"]:GetChecked() then
				Easy_Data.Combat["战士命令怒吼"] = true

				Easy_Data.Combat["战士挫志怒吼"] = false
			    Basic_UI.Combat["战士挫志怒吼"]:SetChecked(false)

				Easy_Data.Combat["战士战斗怒吼"] = false
				Basic_UI.Combat["战士战斗怒吼"]:SetChecked(false)

			elseif not Basic_UI.Combat["战士命令怒吼"]:GetChecked() then
				Easy_Data.Combat["战士命令怒吼"] = false
			end
		end)
		if Easy_Data.Combat["战士命令怒吼"] ~= nil then
			if Easy_Data.Combat["战士命令怒吼"] then
				Basic_UI.Combat["战士命令怒吼"]:SetChecked(true)
			else
				Basic_UI.Combat["战士命令怒吼"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士命令怒吼"] = false
			Basic_UI.Combat["战士命令怒吼"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士挫志怒吼"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["挫志怒吼"])
		Basic_UI.Combat["战士挫志怒吼"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士挫志怒吼"]:GetChecked() then
				Easy_Data.Combat["战士挫志怒吼"] = true

				Easy_Data.Combat["战士战斗怒吼"] = false
			    Basic_UI.Combat["战士战斗怒吼"]:SetChecked(false)

				Easy_Data.Combat["战士命令怒吼"] = false
				Basic_UI.Combat["战士命令怒吼"]:SetChecked(false)

			elseif not Basic_UI.Combat["战士挫志怒吼"]:GetChecked() then
				Easy_Data.Combat["战士挫志怒吼"] = false
			end
		end)
		if Easy_Data.Combat["战士挫志怒吼"] ~= nil then
			if Easy_Data.Combat["战士挫志怒吼"] then
				Basic_UI.Combat["战士挫志怒吼"]:SetChecked(true)
			else
				Basic_UI.Combat["战士挫志怒吼"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士挫志怒吼"] = true
			Basic_UI.Combat["战士挫志怒吼"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士横扫攻击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["横扫攻击"])
		Basic_UI.Combat["战士横扫攻击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士横扫攻击"]:GetChecked() then
				Easy_Data.Combat["战士横扫攻击"] = true
			elseif not Basic_UI.Combat["战士横扫攻击"]:GetChecked() then
				Easy_Data.Combat["战士横扫攻击"] = false
			end
		end)
		if Easy_Data.Combat["战士横扫攻击"] ~= nil then
			if Easy_Data.Combat["战士横扫攻击"] then
				Basic_UI.Combat["战士横扫攻击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士横扫攻击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士横扫攻击"] = true
			Basic_UI.Combat["战士横扫攻击"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士嗜血"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["嗜血"])
		Basic_UI.Combat["战士嗜血"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士嗜血"]:GetChecked() then
				Easy_Data.Combat["战士嗜血"] = true
			elseif not Basic_UI.Combat["战士嗜血"]:GetChecked() then
				Easy_Data.Combat["战士嗜血"] = false
			end
		end)
		if Easy_Data.Combat["战士嗜血"] ~= nil then
			if Easy_Data.Combat["战士嗜血"] then
				Basic_UI.Combat["战士嗜血"]:SetChecked(true)
			else
				Basic_UI.Combat["战士嗜血"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士嗜血"] = true
			Basic_UI.Combat["战士嗜血"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士暴怒"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["暴怒"])
		Basic_UI.Combat["战士暴怒"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士暴怒"]:GetChecked() then
				Easy_Data.Combat["战士暴怒"] = true
			elseif not Basic_UI.Combat["战士暴怒"]:GetChecked() then
				Easy_Data.Combat["战士暴怒"] = false
			end
		end)
		if Easy_Data.Combat["战士暴怒"] ~= nil then
			if Easy_Data.Combat["战士暴怒"] then
				Basic_UI.Combat["战士暴怒"]:SetChecked(true)
			else
				Basic_UI.Combat["战士暴怒"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士暴怒"] = true
			Basic_UI.Combat["战士暴怒"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士破釜沉舟"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["破釜沉舟"])
		Basic_UI.Combat["战士破釜沉舟"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士破釜沉舟"]:GetChecked() then
				Easy_Data.Combat["战士破釜沉舟"] = true
			elseif not Basic_UI.Combat["战士破釜沉舟"]:GetChecked() then
				Easy_Data.Combat["战士破釜沉舟"] = false
			end
		end)
		if Easy_Data.Combat["战士破釜沉舟"] ~= nil then
			if Easy_Data.Combat["战士破釜沉舟"] then
				Basic_UI.Combat["战士破釜沉舟"]:SetChecked(true)
			else
				Basic_UI.Combat["战士破釜沉舟"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士破釜沉舟"] = true
			Basic_UI.Combat["战士破釜沉舟"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士惩戒痛击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["惩戒痛击"])
		Basic_UI.Combat["战士惩戒痛击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士惩戒痛击"]:GetChecked() then
				Easy_Data.Combat["战士惩戒痛击"] = true
			elseif not Basic_UI.Combat["战士惩戒痛击"]:GetChecked() then
				Easy_Data.Combat["战士惩戒痛击"] = false
			end
		end)
		if Easy_Data.Combat["战士惩戒痛击"] ~= nil then
			if Easy_Data.Combat["战士惩戒痛击"] then
				Basic_UI.Combat["战士惩戒痛击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士惩戒痛击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士惩戒痛击"] = false
			Basic_UI.Combat["战士惩戒痛击"]:SetChecked(false)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士英勇打击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["英勇打击"])
		Basic_UI.Combat["战士英勇打击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士英勇打击"]:GetChecked() then
				Easy_Data.Combat["战士英勇打击"] = true
			elseif not Basic_UI.Combat["战士英勇打击"]:GetChecked() then
				Easy_Data.Combat["战士英勇打击"] = false
			end
		end)
		if Easy_Data.Combat["战士英勇打击"] ~= nil then
			if Easy_Data.Combat["战士英勇打击"] then
				Basic_UI.Combat["战士英勇打击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士英勇打击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士英勇打击"] = true
			Basic_UI.Combat["战士英勇打击"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士雷霆一击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["雷霆一击"])
		Basic_UI.Combat["战士雷霆一击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士雷霆一击"]:GetChecked() then
				Easy_Data.Combat["战士雷霆一击"] = true
			elseif not Basic_UI.Combat["战士雷霆一击"]:GetChecked() then
				Easy_Data.Combat["战士雷霆一击"] = false
			end
		end)
		if Easy_Data.Combat["战士雷霆一击"] ~= nil then
			if Easy_Data.Combat["战士雷霆一击"] then
				Basic_UI.Combat["战士雷霆一击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士雷霆一击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士雷霆一击"] = true
			Basic_UI.Combat["战士雷霆一击"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士顺劈斩"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["顺劈斩"])
		Basic_UI.Combat["战士顺劈斩"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士顺劈斩"]:GetChecked() then
				Easy_Data.Combat["战士顺劈斩"] = true
			elseif not Basic_UI.Combat["战士顺劈斩"]:GetChecked() then
				Easy_Data.Combat["战士顺劈斩"] = false
			end
		end)
		if Easy_Data.Combat["战士顺劈斩"] ~= nil then
			if Easy_Data.Combat["战士顺劈斩"] then
				Basic_UI.Combat["战士顺劈斩"]:SetChecked(true)
			else
				Basic_UI.Combat["战士顺劈斩"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士顺劈斩"] = true
			Basic_UI.Combat["战士顺劈斩"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士旋风斩"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["旋风斩"])
		Basic_UI.Combat["战士旋风斩"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士旋风斩"]:GetChecked() then
				Easy_Data.Combat["战士旋风斩"] = true
			elseif not Basic_UI.Combat["战士旋风斩"]:GetChecked() then
				Easy_Data.Combat["战士旋风斩"] = false
			end
		end)
		if Easy_Data.Combat["战士旋风斩"] ~= nil then
			if Easy_Data.Combat["战士旋风斩"] then
				Basic_UI.Combat["战士旋风斩"]:SetChecked(true)
			else
				Basic_UI.Combat["战士旋风斩"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士旋风斩"] = true
			Basic_UI.Combat["战士旋风斩"]:SetChecked(true)
		end
		
		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["战士猛击"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["猛击"])
		Basic_UI.Combat["战士猛击"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["战士猛击"]:GetChecked() then
				Easy_Data.Combat["战士猛击"] = true
			elseif not Basic_UI.Combat["战士猛击"]:GetChecked() then
				Easy_Data.Combat["战士猛击"] = false
			end
		end)
		if Easy_Data.Combat["战士猛击"] ~= nil then
			if Easy_Data.Combat["战士猛击"] then
				Basic_UI.Combat["战士猛击"]:SetChecked(true)
			else
				Basic_UI.Combat["战士猛击"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["战士猛击"] = true
			Basic_UI.Combat["战士猛击"]:SetChecked(true)
		end
	end

	if Class == "PRIEST" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		Basic_UI.Combat["牧师驱散魔法"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["驱散魔法"])
		Basic_UI.Combat["牧师驱散魔法"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师驱散魔法"]:GetChecked() then
				Easy_Data.Combat["牧师驱散魔法"] = true
			elseif not Basic_UI.Combat["牧师驱散魔法"]:GetChecked() then
				Easy_Data.Combat["牧师驱散魔法"] = false
			end
		end)
		if Easy_Data.Combat["牧师驱散魔法"] ~= nil then
			if Easy_Data.Combat["牧师驱散魔法"] then
				Basic_UI.Combat["牧师驱散魔法"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师驱散魔法"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师驱散魔法"] = true
			Basic_UI.Combat["牧师驱散魔法"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师驱除疾病"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["驱除疾病"])
		Basic_UI.Combat["牧师驱除疾病"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师驱除疾病"]:GetChecked() then
				Easy_Data.Combat["牧师驱除疾病"] = true
			elseif not Basic_UI.Combat["牧师驱除疾病"]:GetChecked() then
				Easy_Data.Combat["牧师驱除疾病"] = false
			end
		end)
		if Easy_Data.Combat["牧师驱除疾病"] ~= nil then
			if Easy_Data.Combat["牧师驱除疾病"] then
				Basic_UI.Combat["牧师驱除疾病"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师驱除疾病"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师驱除疾病"] = true
			Basic_UI.Combat["牧师驱除疾病"]:SetChecked(true)
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师治疗之环"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗之环"])
		Basic_UI.Combat["牧师治疗之环"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师治疗之环"]:GetChecked() then
				Easy_Data.Combat["牧师治疗之环"] = true
			elseif not Basic_UI.Combat["牧师治疗之环"]:GetChecked() then
				Easy_Data.Combat["牧师治疗之环"] = false
			end
		end)
		if Easy_Data.Combat["牧师治疗之环"] ~= nil then
			if Easy_Data.Combat["牧师治疗之环"] then
				Basic_UI.Combat["牧师治疗之环"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师治疗之环"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师治疗之环"] = false
			Basic_UI.Combat["牧师治疗之环"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗之环"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师治疗之环血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"30",false,280,24)
		Basic_UI.Combat["牧师治疗之环血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师治疗之环血量"] = tonumber(Basic_UI.Combat["牧师治疗之环血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师治疗之环血量"] ~= nil then
			Basic_UI.Combat["牧师治疗之环血量"]:SetText(Easy_Data.Combat["牧师治疗之环血量"])
		else
			Easy_Data.Combat["牧师治疗之环血量"] = tonumber(Basic_UI.Combat["牧师治疗之环血量"]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师治疗祷言"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗祷言"])
		Basic_UI.Combat["牧师治疗祷言"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师治疗祷言"]:GetChecked() then
				Easy_Data.Combat["牧师治疗祷言"] = true
			elseif not Basic_UI.Combat["牧师治疗祷言"]:GetChecked() then
				Easy_Data.Combat["牧师治疗祷言"] = false
			end
		end)
		if Easy_Data.Combat["牧师治疗祷言"] ~= nil then
			if Easy_Data.Combat["牧师治疗祷言"] then
				Basic_UI.Combat["牧师治疗祷言"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师治疗祷言"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师治疗祷言"] = false
			Basic_UI.Combat["牧师治疗祷言"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗祷言"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师治疗祷言血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"50",false,280,24)
		Basic_UI.Combat["牧师治疗祷言血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师治疗祷言血量"] = tonumber(Basic_UI.Combat["牧师治疗祷言血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师治疗祷言血量"] ~= nil then
			Basic_UI.Combat["牧师治疗祷言血量"]:SetText(Easy_Data.Combat["牧师治疗祷言血量"])
		else
			Easy_Data.Combat["牧师治疗祷言血量"] = tonumber(Basic_UI.Combat["牧师治疗祷言血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师快速治疗"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["快速治疗"])
		Basic_UI.Combat["牧师快速治疗"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师快速治疗"]:GetChecked() then
				Easy_Data.Combat["牧师快速治疗"] = true
			elseif not Basic_UI.Combat["牧师快速治疗"]:GetChecked() then
				Easy_Data.Combat["牧师快速治疗"] = false
			end
		end)
		if Easy_Data.Combat["牧师快速治疗"] ~= nil then
			if Easy_Data.Combat["牧师快速治疗"] then
				Basic_UI.Combat["牧师快速治疗"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师快速治疗"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师快速治疗"] = true
			Basic_UI.Combat["牧师快速治疗"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["快速治疗"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师快速治疗血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"20",false,280,24)
		Basic_UI.Combat["牧师快速治疗血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师快速治疗血量"] = tonumber(Basic_UI.Combat["牧师快速治疗血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师快速治疗血量"] ~= nil then
			Basic_UI.Combat["牧师快速治疗血量"]:SetText(Easy_Data.Combat["牧师快速治疗血量"])
		else
			Easy_Data.Combat["牧师快速治疗血量"] = tonumber(Basic_UI.Combat["牧师快速治疗血量"]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师治疗术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗术"])
		Basic_UI.Combat["牧师治疗术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师治疗术"] = true
			elseif not Basic_UI.Combat["牧师治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师治疗术"] = false
			end
		end)
		if Easy_Data.Combat["牧师治疗术"] ~= nil then
			if Easy_Data.Combat["牧师治疗术"] then
				Basic_UI.Combat["牧师治疗术"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师治疗术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师治疗术"] = true
			Basic_UI.Combat["牧师治疗术"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师治疗术血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat["牧师治疗术血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师治疗术血量"] = tonumber(Basic_UI.Combat["牧师治疗术血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师治疗术血量"] ~= nil then
			Basic_UI.Combat["牧师治疗术血量"]:SetText(Easy_Data.Combat["牧师治疗术血量"])
		else
			Easy_Data.Combat["牧师治疗术血量"] = tonumber(Basic_UI.Combat["牧师治疗术血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师强效治疗术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["强效治疗术"])
		Basic_UI.Combat["牧师强效治疗术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师强效治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师强效治疗术"] = true
			elseif not Basic_UI.Combat["牧师强效治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师强效治疗术"] = false
			end
		end)
		if Easy_Data.Combat["牧师强效治疗术"] ~= nil then
			if Easy_Data.Combat["牧师强效治疗术"] then
				Basic_UI.Combat["牧师强效治疗术"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师强效治疗术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师强效治疗术"] = true
			Basic_UI.Combat["牧师强效治疗术"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["强效治疗术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师强效治疗术血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"40",false,280,24)
		Basic_UI.Combat["牧师强效治疗术血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师强效治疗术血量"] = tonumber(Basic_UI.Combat["牧师强效治疗术血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师强效治疗术血量"] ~= nil then
			Basic_UI.Combat["牧师强效治疗术血量"]:SetText(Easy_Data.Combat["牧师强效治疗术血量"])
		else
			Easy_Data.Combat["牧师强效治疗术血量"] = tonumber(Basic_UI.Combat["牧师强效治疗术血量"]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师恢复"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["恢复"])
		Basic_UI.Combat["牧师恢复"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师恢复"]:GetChecked() then
				Easy_Data.Combat["牧师恢复"] = true
			elseif not Basic_UI.Combat["牧师恢复"]:GetChecked() then
				Easy_Data.Combat["牧师恢复"] = false
			end
		end)
		if Easy_Data.Combat["牧师恢复"] ~= nil then
			if Easy_Data.Combat["牧师恢复"] then
				Basic_UI.Combat["牧师恢复"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师恢复"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师恢复"] = true
			Basic_UI.Combat["牧师恢复"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["恢复"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师恢复血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"70",false,280,24)
		Basic_UI.Combat["牧师恢复血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师恢复血量"] = tonumber(Basic_UI.Combat["牧师恢复血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师恢复血量"] ~= nil then
			Basic_UI.Combat["牧师恢复血量"]:SetText(Easy_Data.Combat["牧师恢复血量"])
		else
			Easy_Data.Combat["牧师恢复血量"] = tonumber(Basic_UI.Combat["牧师恢复血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["牧师次级治疗术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["次级治疗术"])
		Basic_UI.Combat["牧师次级治疗术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["牧师次级治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师次级治疗术"] = true
			elseif not Basic_UI.Combat["牧师次级治疗术"]:GetChecked() then
				Easy_Data.Combat["牧师次级治疗术"] = false
			end
		end)
		if Easy_Data.Combat["牧师次级治疗术"] ~= nil then
			if Easy_Data.Combat["牧师次级治疗术"] then
				Basic_UI.Combat["牧师次级治疗术"]:SetChecked(true)
			else
				Basic_UI.Combat["牧师次级治疗术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["牧师次级治疗术"] = false
			Basic_UI.Combat["牧师次级治疗术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["次级治疗术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["牧师次级治疗术血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"70",false,280,24)
		Basic_UI.Combat["牧师次级治疗术血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["牧师次级治疗术血量"] = tonumber(Basic_UI.Combat["牧师次级治疗术血量"]:GetText())
		end)
		if Easy_Data.Combat["牧师次级治疗术血量"] ~= nil then
			Basic_UI.Combat["牧师次级治疗术血量"]:SetText(Easy_Data.Combat["牧师次级治疗术血量"])
		else
			Easy_Data.Combat["牧师次级治疗术血量"] = tonumber(Basic_UI.Combat["牧师次级治疗术血量"]:GetText())
		end
	end

	if Class == "WARLOCK" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		Basic_UI.Combat["术士召唤地狱猎犬"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤地狱猎犬"])
		Basic_UI.Combat["术士召唤地狱猎犬"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士召唤地狱猎犬"]:GetChecked() then
				Easy_Data.Combat["术士召唤地狱猎犬"] = true

				Easy_Data.Combat["术士召唤恶魔卫士"] = false
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(false)

				Easy_Data.Combat["术士召唤小鬼"] = false
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)

				Easy_Data.Combat["术士召唤魅魔"] = false
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)

				Easy_Data.Combat["术士召唤虚空行者"] = false
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(false)

			elseif not Basic_UI.Combat["术士召唤地狱猎犬"]:GetChecked() then
				Easy_Data.Combat["术士召唤地狱猎犬"] = false
			end
		end)
		if Easy_Data.Combat["术士召唤地狱猎犬"] ~= nil then
			if Easy_Data.Combat["术士召唤地狱猎犬"] then
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(true)
			else
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士召唤地狱猎犬"] = false
			Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士召唤恶魔卫士"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤恶魔卫士"])
		Basic_UI.Combat["术士召唤恶魔卫士"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士召唤恶魔卫士"]:GetChecked() then
				Easy_Data.Combat["术士召唤恶魔卫士"] = true

				Easy_Data.Combat["术士召唤地狱猎犬"] = false
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)

				Easy_Data.Combat["术士召唤小鬼"] = false
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)

				Easy_Data.Combat["术士召唤魅魔"] = false
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)

				Easy_Data.Combat["术士召唤虚空行者"] = false
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(false)

			elseif not Basic_UI.Combat["术士召唤恶魔卫士"]:GetChecked() then
				Easy_Data.Combat["术士召唤恶魔卫士"] = false
			end
		end)
		if Easy_Data.Combat["术士召唤恶魔卫士"] ~= nil then
			if Easy_Data.Combat["术士召唤恶魔卫士"] then
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(true)
			else
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士召唤恶魔卫士"] = false
			Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士召唤虚空行者"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤虚空行者"])
		Basic_UI.Combat["术士召唤虚空行者"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士召唤虚空行者"]:GetChecked() then
				Easy_Data.Combat["术士召唤虚空行者"] = true

				Easy_Data.Combat["术士召唤地狱猎犬"] = false
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)

				Easy_Data.Combat["术士召唤小鬼"] = false
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)

				Easy_Data.Combat["术士召唤魅魔"] = false
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)

				Easy_Data.Combat["术士召唤恶魔卫士"] = false
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(false)

			elseif not Basic_UI.Combat["术士召唤虚空行者"]:GetChecked() then
				Easy_Data.Combat["术士召唤虚空行者"] = false
			end
		end)
		if Easy_Data.Combat["术士召唤虚空行者"] ~= nil then
			if Easy_Data.Combat["术士召唤虚空行者"] then
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(true)
			else
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士召唤虚空行者"] = true
			Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士召唤小鬼"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤小鬼"])
		Basic_UI.Combat["术士召唤小鬼"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士召唤小鬼"]:GetChecked() then
				Easy_Data.Combat["术士召唤小鬼"] = true

				Easy_Data.Combat["术士召唤地狱猎犬"] = false
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)

				Easy_Data.Combat["术士召唤虚空行者"] = false
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(false)

				Easy_Data.Combat["术士召唤魅魔"] = false
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)

				Easy_Data.Combat["术士召唤恶魔卫士"] = false
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(false)

			elseif not Basic_UI.Combat["术士召唤小鬼"]:GetChecked() then
				Easy_Data.Combat["术士召唤小鬼"] = false
			end
		end)
		if Easy_Data.Combat["术士召唤小鬼"] ~= nil then
			if Easy_Data.Combat["术士召唤小鬼"] then
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(true)
			else
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士召唤小鬼"] = false
			Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士召唤魅魔"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["召唤魅魔"])
		Basic_UI.Combat["术士召唤魅魔"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士召唤魅魔"]:GetChecked() then
				Easy_Data.Combat["术士召唤魅魔"] = true

				Easy_Data.Combat["术士召唤地狱猎犬"] = false
				Basic_UI.Combat["术士召唤地狱猎犬"]:SetChecked(false)

				Easy_Data.Combat["术士召唤小鬼"] = false
				Basic_UI.Combat["术士召唤小鬼"]:SetChecked(false)

				Easy_Data.Combat["术士召唤虚空行者"] = false
				Basic_UI.Combat["术士召唤虚空行者"]:SetChecked(false)

				Easy_Data.Combat["术士召唤恶魔卫士"] = false
				Basic_UI.Combat["术士召唤恶魔卫士"]:SetChecked(false)

			elseif not Basic_UI.Combat["术士召唤魅魔"]:GetChecked() then
				Easy_Data.Combat["术士召唤魅魔"] = false
			end
		end)
		if Easy_Data.Combat["术士召唤魅魔"] ~= nil then
			if Easy_Data.Combat["术士召唤魅魔"] then
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(true)
			else
				Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士召唤魅魔"] = false
			Basic_UI.Combat["术士召唤魅魔"]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士邪甲术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["邪甲术"])
		Basic_UI.Combat["术士邪甲术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士邪甲术"]:GetChecked() then
				Easy_Data.Combat["术士邪甲术"] = true

				Easy_Data.Combat["术士魔甲术"] = false
				Basic_UI.Combat["术士魔甲术"]:SetChecked(false)

				Easy_Data.Combat["术士恶魔皮肤"] = false
				Basic_UI.Combat["术士恶魔皮肤"]:SetChecked(false)
			elseif not Basic_UI.Combat["术士邪甲术"]:GetChecked() then
				Easy_Data.Combat["术士邪甲术"] = false
			end
		end)
		if Easy_Data.Combat["术士邪甲术"] ~= nil then
			if Easy_Data.Combat["术士邪甲术"] then
				Basic_UI.Combat["术士邪甲术"]:SetChecked(true)
			else
				Basic_UI.Combat["术士邪甲术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士邪甲术"] = false
			Basic_UI.Combat["术士邪甲术"]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士恶魔皮肤"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["恶魔皮肤"])
		Basic_UI.Combat["术士恶魔皮肤"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士恶魔皮肤"]:GetChecked() then
				Easy_Data.Combat["术士恶魔皮肤"] = true

				Easy_Data.Combat["术士魔甲术"] = false
				Basic_UI.Combat["术士魔甲术"]:SetChecked(false)

				Easy_Data.Combat["术士邪甲术"] = false
				Basic_UI.Combat["术士邪甲术"]:SetChecked(false)
			elseif not Basic_UI.Combat["术士恶魔皮肤"]:GetChecked() then
				Easy_Data.Combat["术士恶魔皮肤"] = false
			end
		end)
		if Easy_Data.Combat["术士恶魔皮肤"] ~= nil then
			if Easy_Data.Combat["术士恶魔皮肤"] then
				Basic_UI.Combat["术士恶魔皮肤"]:SetChecked(true)
			else
				Basic_UI.Combat["术士恶魔皮肤"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士恶魔皮肤"] = false
			Basic_UI.Combat["术士恶魔皮肤"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士魔甲术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["术士魔甲术"])
		Basic_UI.Combat["术士魔甲术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士魔甲术"]:GetChecked() then
				Easy_Data.Combat["术士魔甲术"] = true

				Easy_Data.Combat["术士恶魔皮肤"] = false
				Basic_UI.Combat["术士恶魔皮肤"]:SetChecked(false)

				Easy_Data.Combat["术士邪甲术"] = false
				Basic_UI.Combat["术士邪甲术"]:SetChecked(false)
			elseif not Basic_UI.Combat["术士魔甲术"]:GetChecked() then
				Easy_Data.Combat["术士魔甲术"] = false
			end
		end)
		if Easy_Data.Combat["术士魔甲术"] ~= nil then
			if Easy_Data.Combat["术士魔甲术"] then
				Basic_UI.Combat["术士魔甲术"]:SetChecked(true)
			else
				Basic_UI.Combat["术士魔甲术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士魔甲术"] = true
			Basic_UI.Combat["术士魔甲术"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士生命分流"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["生命分流"])
		Basic_UI.Combat["术士生命分流"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士生命分流"]:GetChecked() then
				Easy_Data.Combat["术士生命分流"] = true
			elseif not Basic_UI.Combat["术士生命分流"]:GetChecked() then
				Easy_Data.Combat["术士生命分流"] = false
			end
		end)
		if Easy_Data.Combat["术士生命分流"] ~= nil then
			if Easy_Data.Combat["术士生命分流"] then
				Basic_UI.Combat["术士生命分流"]:SetChecked(true)
			else
				Basic_UI.Combat["术士生命分流"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士生命分流"] = true
			Basic_UI.Combat["术士生命分流"]:SetChecked(true)
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["生命分流"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["术士生命分流血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat["术士生命分流血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["术士生命分流血量"] = tonumber(Basic_UI.Combat["术士生命分流血量"]:GetText())
		end)
		if Easy_Data.Combat["术士生命分流血量"] ~= nil then
			Basic_UI.Combat["术士生命分流血量"]:SetText(Easy_Data.Combat["术士生命分流血量"])
		else
			Easy_Data.Combat["术士生命分流血量"] = tonumber(Basic_UI.Combat["术士生命分流血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("蓝量百分比 = ","Power percentage to cast = ")..rs["生命分流"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["术士生命分流蓝量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat["术士生命分流蓝量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["术士生命分流蓝量"] = tonumber(Basic_UI.Combat["术士生命分流蓝量"]:GetText())
		end)
		if Easy_Data.Combat["术士生命分流蓝量"] ~= nil then
			Basic_UI.Combat["术士生命分流蓝量"]:SetText(Easy_Data.Combat["术士生命分流蓝量"])
		else
			Easy_Data.Combat["术士生命分流蓝量"] = tonumber(Basic_UI.Combat["术士生命分流蓝量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士生命通道"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["生命通道"])
		Basic_UI.Combat["术士生命通道"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士生命通道"]:GetChecked() then
				Easy_Data.Combat["术士生命通道"] = true
			elseif not Basic_UI.Combat["术士生命通道"]:GetChecked() then
				Easy_Data.Combat["术士生命通道"] = false
			end
		end)
		if Easy_Data.Combat["术士生命通道"] ~= nil then
			if Easy_Data.Combat["术士生命通道"] then
				Basic_UI.Combat["术士生命通道"]:SetChecked(true)
			else
				Basic_UI.Combat["术士生命通道"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士生命通道"] = true
			Basic_UI.Combat["术士生命通道"]:SetChecked(true)
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("宠物血量百分比 = ","Pet Health percentage to cast = ")..rs["生命通道"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["术士生命通道血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat["术士生命通道血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["术士生命通道血量"] = tonumber(Basic_UI.Combat["术士生命通道血量"]:GetText())
		end)
		if Easy_Data.Combat["术士生命通道血量"] ~= nil then
			Basic_UI.Combat["术士生命通道血量"]:SetText(Easy_Data.Combat["术士生命通道血量"])
		else
			Easy_Data.Combat["术士生命通道血量"] = tonumber(Basic_UI.Combat["术士生命通道血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士恐惧"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["恐惧"])
		Basic_UI.Combat["术士恐惧"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士恐惧"]:GetChecked() then
				Easy_Data.Combat["术士恐惧"] = true
			elseif not Basic_UI.Combat["术士恐惧"]:GetChecked() then
				Easy_Data.Combat["术士恐惧"] = false
			end
		end)
		if Easy_Data.Combat["术士恐惧"] ~= nil then
			if Easy_Data.Combat["术士恐惧"] then
				Basic_UI.Combat["术士恐惧"]:SetChecked(true)
			else
				Basic_UI.Combat["术士恐惧"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士恐惧"] = true
			Basic_UI.Combat["术士恐惧"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士死亡缠绕"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["死亡缠绕"])
		Basic_UI.Combat["术士死亡缠绕"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士死亡缠绕"]:GetChecked() then
				Easy_Data.Combat["术士死亡缠绕"] = true
			elseif not Basic_UI.Combat["术士死亡缠绕"]:GetChecked() then
				Easy_Data.Combat["术士死亡缠绕"] = false
			end
		end)
		if Easy_Data.Combat["术士死亡缠绕"] ~= nil then
			if Easy_Data.Combat["术士死亡缠绕"] then
				Basic_UI.Combat["术士死亡缠绕"]:SetChecked(true)
			else
				Basic_UI.Combat["术士死亡缠绕"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士死亡缠绕"] = true
			Basic_UI.Combat["术士死亡缠绕"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士灵魂之火"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["灵魂之火"])
		Basic_UI.Combat["术士灵魂之火"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士灵魂之火"]:GetChecked() then
				Easy_Data.Combat["术士灵魂之火"] = true
			elseif not Basic_UI.Combat["术士灵魂之火"]:GetChecked() then
				Easy_Data.Combat["术士灵魂之火"] = false
			end
		end)
		if Easy_Data.Combat["术士灵魂之火"] ~= nil then
			if Easy_Data.Combat["术士灵魂之火"] then
				Basic_UI.Combat["术士灵魂之火"]:SetChecked(true)
			else
				Basic_UI.Combat["术士灵魂之火"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士灵魂之火"] = true
			Basic_UI.Combat["术士灵魂之火"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士暗影之怒"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["暗影之怒"])
		Basic_UI.Combat["术士暗影之怒"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士暗影之怒"]:GetChecked() then
				Easy_Data.Combat["术士暗影之怒"] = true
			elseif not Basic_UI.Combat["术士暗影之怒"]:GetChecked() then
				Easy_Data.Combat["术士暗影之怒"] = false
			end
		end)
		if Easy_Data.Combat["术士暗影之怒"] ~= nil then
			if Easy_Data.Combat["术士暗影之怒"] then
				Basic_UI.Combat["术士暗影之怒"]:SetChecked(true)
			else
				Basic_UI.Combat["术士暗影之怒"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士暗影之怒"] = true
			Basic_UI.Combat["术士暗影之怒"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士地狱烈焰"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["地狱烈焰"])
		Basic_UI.Combat["术士地狱烈焰"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士地狱烈焰"]:GetChecked() then
				Easy_Data.Combat["术士地狱烈焰"] = true
			elseif not Basic_UI.Combat["术士地狱烈焰"]:GetChecked() then
				Easy_Data.Combat["术士地狱烈焰"] = false
			end
		end)
		if Easy_Data.Combat["术士地狱烈焰"] ~= nil then
			if Easy_Data.Combat["术士地狱烈焰"] then
				Basic_UI.Combat["术士地狱烈焰"]:SetChecked(true)
			else
				Basic_UI.Combat["术士地狱烈焰"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士地狱烈焰"] = false
			Basic_UI.Combat["术士地狱烈焰"]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士灵魂链接"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["灵魂链接"])
		Basic_UI.Combat["术士灵魂链接"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士灵魂链接"]:GetChecked() then
				Easy_Data.Combat["术士灵魂链接"] = true
			elseif not Basic_UI.Combat["术士灵魂链接"]:GetChecked() then
				Easy_Data.Combat["术士灵魂链接"] = false
			end
		end)
		if Easy_Data.Combat["术士灵魂链接"] ~= nil then
			if Easy_Data.Combat["术士灵魂链接"] then
				Basic_UI.Combat["术士灵魂链接"]:SetChecked(true)
			else
				Basic_UI.Combat["术士灵魂链接"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士灵魂链接"] = true
			Basic_UI.Combat["术士灵魂链接"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士吸取生命"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["吸取生命"])
		Basic_UI.Combat["术士吸取生命"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士吸取生命"]:GetChecked() then
				Easy_Data.Combat["术士吸取生命"] = true
			elseif not Basic_UI.Combat["术士吸取生命"]:GetChecked() then
				Easy_Data.Combat["术士吸取生命"] = false
			end
		end)
		if Easy_Data.Combat["术士吸取生命"] ~= nil then
			if Easy_Data.Combat["术士吸取生命"] then
				Basic_UI.Combat["术士吸取生命"]:SetChecked(true)
			else
				Basic_UI.Combat["术士吸取生命"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士吸取生命"] = true
			Basic_UI.Combat["术士吸取生命"]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["吸取生命"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		Basic_UI.Combat["术士吸取生命血量"] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat["术士吸取生命血量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat["术士吸取生命血量"] = tonumber(Basic_UI.Combat["术士吸取生命血量"]:GetText())
		end)
		if Easy_Data.Combat["术士吸取生命血量"] ~= nil then
			Basic_UI.Combat["术士吸取生命血量"]:SetText(Easy_Data.Combat["术士吸取生命血量"])
		else
			Easy_Data.Combat["术士吸取生命血量"] = tonumber(Basic_UI.Combat["术士吸取生命血量"]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士腐蚀之种"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["腐蚀之种"])
		Basic_UI.Combat["术士腐蚀之种"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士腐蚀之种"]:GetChecked() then
				Easy_Data.Combat["术士腐蚀之种"] = true
			elseif not Basic_UI.Combat["术士腐蚀之种"]:GetChecked() then
				Easy_Data.Combat["术士腐蚀之种"] = false
			end
		end)
		if Easy_Data.Combat["术士腐蚀之种"] ~= nil then
			if Easy_Data.Combat["术士腐蚀之种"] then
				Basic_UI.Combat["术士腐蚀之种"]:SetChecked(true)
			else
				Basic_UI.Combat["术士腐蚀之种"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士腐蚀之种"] = true
			Basic_UI.Combat["术士腐蚀之种"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士生命虹吸"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["生命虹吸"])
		Basic_UI.Combat["术士生命虹吸"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士生命虹吸"]:GetChecked() then
				Easy_Data.Combat["术士生命虹吸"] = true
			elseif not Basic_UI.Combat["术士生命虹吸"]:GetChecked() then
				Easy_Data.Combat["术士生命虹吸"] = false
			end
		end)
		if Easy_Data.Combat["术士生命虹吸"] ~= nil then
			if Easy_Data.Combat["术士生命虹吸"] then
				Basic_UI.Combat["术士生命虹吸"]:SetChecked(true)
			else
				Basic_UI.Combat["术士生命虹吸"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士生命虹吸"] = true
			Basic_UI.Combat["术士生命虹吸"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士火焰之雨"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["火焰之雨"])
		Basic_UI.Combat["术士火焰之雨"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士火焰之雨"]:GetChecked() then
				Easy_Data.Combat["术士火焰之雨"] = true
			elseif not Basic_UI.Combat["术士火焰之雨"]:GetChecked() then
				Easy_Data.Combat["术士火焰之雨"] = false
			end
		end)
		if Easy_Data.Combat["术士火焰之雨"] ~= nil then
			if Easy_Data.Combat["术士火焰之雨"] then
				Basic_UI.Combat["术士火焰之雨"]:SetChecked(true)
			else
				Basic_UI.Combat["术士火焰之雨"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士火焰之雨"] = false
			Basic_UI.Combat["术士火焰之雨"]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士厄运诅咒"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["厄运诅咒"])
		Basic_UI.Combat["术士厄运诅咒"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士厄运诅咒"]:GetChecked() then
				Easy_Data.Combat["术士厄运诅咒"] = true
			elseif not Basic_UI.Combat["术士厄运诅咒"]:GetChecked() then
				Easy_Data.Combat["术士厄运诅咒"] = false
			end
		end)
		if Easy_Data.Combat["术士厄运诅咒"] ~= nil then
			if Easy_Data.Combat["术士厄运诅咒"] then
				Basic_UI.Combat["术士厄运诅咒"]:SetChecked(true)
			else
				Basic_UI.Combat["术士厄运诅咒"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士厄运诅咒"] = false
			Basic_UI.Combat["术士厄运诅咒"]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士痛苦诅咒"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["痛苦诅咒"])
		Basic_UI.Combat["术士痛苦诅咒"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士痛苦诅咒"]:GetChecked() then
				Easy_Data.Combat["术士痛苦诅咒"] = true
			elseif not Basic_UI.Combat["术士痛苦诅咒"]:GetChecked() then
				Easy_Data.Combat["术士痛苦诅咒"] = false
			end
		end)
		if Easy_Data.Combat["术士痛苦诅咒"] ~= nil then
			if Easy_Data.Combat["术士痛苦诅咒"] then
				Basic_UI.Combat["术士痛苦诅咒"]:SetChecked(true)
			else
				Basic_UI.Combat["术士痛苦诅咒"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士痛苦诅咒"] = true
			Basic_UI.Combat["术士痛苦诅咒"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士痛苦无常"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["痛苦无常"])
		Basic_UI.Combat["术士痛苦无常"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士痛苦无常"]:GetChecked() then
				Easy_Data.Combat["术士痛苦无常"] = true
			elseif not Basic_UI.Combat["术士痛苦无常"]:GetChecked() then
				Easy_Data.Combat["术士痛苦无常"] = false
			end
		end)
		if Easy_Data.Combat["术士痛苦无常"] ~= nil then
			if Easy_Data.Combat["术士痛苦无常"] then
				Basic_UI.Combat["术士痛苦无常"]:SetChecked(true)
			else
				Basic_UI.Combat["术士痛苦无常"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士痛苦无常"] = true
			Basic_UI.Combat["术士痛苦无常"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士烧尽"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["烧尽"])
		Basic_UI.Combat["术士烧尽"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士烧尽"]:GetChecked() then
				Easy_Data.Combat["术士烧尽"] = true
			elseif not Basic_UI.Combat["术士烧尽"]:GetChecked() then
				Easy_Data.Combat["术士烧尽"] = false
			end
		end)
		if Easy_Data.Combat["术士烧尽"] ~= nil then
			if Easy_Data.Combat["术士烧尽"] then
				Basic_UI.Combat["术士烧尽"]:SetChecked(true)
			else
				Basic_UI.Combat["术士烧尽"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士烧尽"] = true
			Basic_UI.Combat["术士烧尽"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士燃烧"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["术士燃烧"])
		Basic_UI.Combat["术士燃烧"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士燃烧"]:GetChecked() then
				Easy_Data.Combat["术士燃烧"] = true
			elseif not Basic_UI.Combat["术士燃烧"]:GetChecked() then
				Easy_Data.Combat["术士燃烧"] = false
			end
		end)
		if Easy_Data.Combat["术士燃烧"] ~= nil then
			if Easy_Data.Combat["术士燃烧"] then
				Basic_UI.Combat["术士燃烧"]:SetChecked(true)
			else
				Basic_UI.Combat["术士燃烧"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士燃烧"] = false
			Basic_UI.Combat["术士燃烧"]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士献祭"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["献祭"])
		Basic_UI.Combat["术士献祭"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士献祭"]:GetChecked() then
				Easy_Data.Combat["术士献祭"] = true
			elseif not Basic_UI.Combat["术士献祭"]:GetChecked() then
				Easy_Data.Combat["术士献祭"] = false
			end
		end)
		if Easy_Data.Combat["术士献祭"] ~= nil then
			if Easy_Data.Combat["术士献祭"] then
				Basic_UI.Combat["术士献祭"]:SetChecked(true)
			else
				Basic_UI.Combat["术士献祭"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士献祭"] = true
			Basic_UI.Combat["术士献祭"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士腐蚀术"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["腐蚀术"])
		Basic_UI.Combat["术士腐蚀术"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士腐蚀术"]:GetChecked() then
				Easy_Data.Combat["术士腐蚀术"] = true
			elseif not Basic_UI.Combat["术士腐蚀术"]:GetChecked() then
				Easy_Data.Combat["术士腐蚀术"] = false
			end
		end)
		if Easy_Data.Combat["术士腐蚀术"] ~= nil then
			if Easy_Data.Combat["术士腐蚀术"] then
				Basic_UI.Combat["术士腐蚀术"]:SetChecked(true)
			else
				Basic_UI.Combat["术士腐蚀术"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士腐蚀术"] = true
			Basic_UI.Combat["术士腐蚀术"]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		Basic_UI.Combat["术士灼热之痛"] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["灼热之痛"])
		Basic_UI.Combat["术士灼热之痛"]:SetScript("OnClick", function(self)
			if Basic_UI.Combat["术士灼热之痛"]:GetChecked() then
				Easy_Data.Combat["术士灼热之痛"] = true
			elseif not Basic_UI.Combat["术士灼热之痛"]:GetChecked() then
				Easy_Data.Combat["术士灼热之痛"] = false
			end
		end)
		if Easy_Data.Combat["术士灼热之痛"] ~= nil then
			if Easy_Data.Combat["术士灼热之痛"] then
				Basic_UI.Combat["术士灼热之痛"]:SetChecked(true)
			else
				Basic_UI.Combat["术士灼热之痛"]:SetChecked(false)
			end
		else
			Easy_Data.Combat["术士灼热之痛"] = true
			Basic_UI.Combat["术士灼热之痛"]:SetChecked(true)
		end
	end

	if Class == "DRUID" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		local Var = "小德解除诅咒"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["解除诅咒"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德驱毒术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["驱毒术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德回春术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["回春术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["回春术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德回春术血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德宁静"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["宁静"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["宁静"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德宁静血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"20",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德愈合"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["愈合"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["愈合"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德愈合血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"40",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end
		

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德治疗之触"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗之触"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗之触"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德治疗之触血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"30",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德巨熊形态"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["巨熊形态"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德枭兽形态"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["枭兽形态"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德熊形态"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["熊形态"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德猎豹形态"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["猎豹形态"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德月火术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["月火术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德愤怒"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["愤怒"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德星火术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["星火术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德树皮术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["树皮术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["树皮术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德树皮术血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"50",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("小德终结技能使用点数","Druid Combat Point To Cast")) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "小德终结点数"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"3",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德割裂"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["割裂"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德凶猛撕咬"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["凶猛撕咬"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "小德飓风"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["飓风"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end
	end

	if Class == "PALADIN" then
		if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		local Var = "骑士清洁术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["清洁术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士纯净术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["纯净术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士保护祝福"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["保护祝福"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["保护祝福"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "骑士保护祝福血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"10",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士圣光闪现"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["圣光闪现"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["圣光闪现"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "骑士圣光闪现血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"80",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士圣光术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["圣光术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["圣光术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "骑士圣光术血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"50",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end



		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士圣疗术"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["圣疗术"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["圣疗术"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "骑士圣疗术血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"15",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士虔诚光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["虔诚光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士专注光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["专注光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士惩戒光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["惩戒光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士暗影抗性光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["暗影抗性光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士冰霜抗性光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["冰霜抗性光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士火焰抗性光环"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["火焰抗性光环"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士王者祝福"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["王者祝福"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士智慧祝福"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["智慧祝福"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士庇护祝福"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["庇护祝福"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士力量祝福"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["力量祝福"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士十字军圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["十字军圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士正义圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["正义圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士光明圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["光明圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士智慧圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["智慧圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士公正圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["公正圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士命令圣印"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["命令圣印"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "骑士复仇之怒"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["复仇之怒"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end
	end

	if Class == "SHAMAN" then
	    if not Easy_Data.Combat then
		    Easy_Data.Combat = {}
		end

		local Var = "增强萨满"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("增强萨满","Enhancement SHAMAN"))
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "元素萨满"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("元素萨满","Elemental SHAMAN"))
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = false
			Basic_UI.Combat[Var]:SetChecked(false)
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "萨满次级治疗波"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["次级治疗波"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["次级治疗波"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "萨满次级治疗波血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"80",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "萨满治疗波"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗波"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗波"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "萨满治疗波血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"40",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end


		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Var = "萨满治疗链"
		Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..rs["治疗链"])
		Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
			if Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = true
			elseif not Basic_UI.Combat[Var]:GetChecked() then
				Easy_Data.Combat[Var] = false
			end
		end)
		if Easy_Data.Combat[Var] ~= nil then
			if Easy_Data.Combat[Var] then
				Basic_UI.Combat[Var]:SetChecked(true)
			else
				Basic_UI.Combat[Var]:SetChecked(false)
			end
		else
			Easy_Data.Combat[Var] = true
			Basic_UI.Combat[Var]:SetChecked(true)
		end

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
		local Header2 = Create_Header(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,Check_UI("血量百分比 = ","Health percentage to cast = ")..rs["治疗链"]) 

		Basic_UI.Combat.Py = Basic_UI.Combat.Py - 20
		local Var = "萨满治疗链血量"
		Basic_UI.Combat[Var] = Create_EditBox(Basic_UI.Combat.frame,"TOPLEFT",10, Basic_UI.Combat.Py,"55",false,280,24)
		Basic_UI.Combat[Var]:SetScript("OnEditFocusLost", function(self)
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end)
		if Easy_Data.Combat[Var] ~= nil then
			Basic_UI.Combat[Var]:SetText(Easy_Data.Combat[Var])
		else
			Easy_Data.Combat[Var] = tonumber(Basic_UI.Combat[Var]:GetText())
		end

		local Spell = 
		{
			{rs["烈焰震击"],true},
			{rs["地震术"],true},
			{rs["冰霜震击"],true},
			{rs["闪电箭"],true},
			{rs["闪电之盾"],false},
			{rs["闪电链"],true},
			{rs["风暴打击"],true},
			{rs["萨满之怒"],true},
			{rs["水之护盾"],true},
			{rs["大地之盾"],false},
			{rs["嗜血"],true},

			{rs["石化武器"],true},
			{rs["火舌武器"],false},
			{rs["冰封武器"],false},
			{rs["风怒武器"],false},
			{rs["祛病术"],true},
			{rs["消毒术"],true},

			{rs["石肤图腾"],false},
			{rs["地缚图腾"],false},
			{rs["石爪图腾"],false},
			{rs["大地之力图腾"],true},
			{rs["灼热图腾"],false},
			{rs["战栗图腾"],false},
			{rs["火焰新星图腾"],false},
			{rs["治疗之泉图腾"],false},
			{rs["抗寒图腾"],false},
			{rs["法力之泉图腾"],true},
			{rs["熔岩图腾"],false},
			{rs["火舌图腾"],false},
			{rs["抗火图腾"],false},
			{rs["根基图腾"],false},
			{rs["自然抗性图腾"],false},
			{rs["风怒图腾"],false},
			{rs["净化图腾"],false},
			{rs["法力之潮图腾"],false},
			{rs["天怒图腾"],false},
			{rs["空气之怒图腾"],true},
			{rs["土元素图腾"],false},
			{rs["风墙图腾"],false},
			{rs["火元素图腾"],true},
			{rs["清毒图腾"],false},
			{rs["祛病图腾"],false},
			{rs["风之优雅图腾"],false},
		}

		for i = 1,#Spell do
			local Var = "萨满"..Spell[i][1]
			if i%2 ~= 0 then
			    Basic_UI.Combat.Py = Basic_UI.Combat.Py - 30
				Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",10, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..Spell[i][1])
            else
			    Basic_UI.Combat[Var] = Create_Check_Button(Basic_UI.Combat.frame, "TOPLEFT",280, Basic_UI.Combat.Py, Check_UI("使用 ","Use ")..Spell[i][1])
			end

			Basic_UI.Combat[Var]:SetScript("OnClick", function(self)
				if Basic_UI.Combat[Var]:GetChecked() then
					Easy_Data.Combat[Var] = true
				elseif not Basic_UI.Combat[Var]:GetChecked() then
					Easy_Data.Combat[Var] = false
				end
			end)
			if Easy_Data.Combat[Var] ~= nil then
				if Easy_Data.Combat[Var] then
					Basic_UI.Combat[Var]:SetChecked(true)
				else
					Basic_UI.Combat[Var]:SetChecked(false)
				end
			else
				Easy_Data.Combat[Var] = Spell[i][2]
				Basic_UI.Combat[Var]:SetChecked(Spell[i][2])
			end
		end
	end
end

local function Create_GUIDE_UI() -- 功能说明UI
    Basic_UI.Guide = {}
	Basic_UI.Guide.Py = -10
	local function Frame_Create()
		Basic_UI.Guide.frame = CreateFrame('frame',"Basic_UI.Guide.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Guide.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Guide.frame:SetSize(600,1500)
		Basic_UI.Guide.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
		Basic_UI.Guide.frame:Hide()
		Basic_UI.Guide.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Guide.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Guide.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("使用说明","User GUIDE"))
		Basic_UI.Guide.button:SetSize(130,20)
		Basic_UI.Guide.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Guide.frame:Show()
			Basic_UI.Guide.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Guide.frame:Hide() Basic_UI.Guide.button:SetBackdropColor(0,0,0,0) end
	end

	Frame_Create()
	Button_Create()

	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("野外自定义打怪","Open world custom mobs farm")) 

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("支持职业 - 全部","Class supportive - All"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("请使用自定义坐标生成 录制路径","Please user generator to record route"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("天赋请自行随意设置","Please set ur talent with ur favor"))
end

Create_Nav_UI()
Create_Config_UI()
Create_Sell_UI()
Create_Destroy_UI()
Create_Mail_UI()
Create_Custom_UI()
Create_Internal_UI()

Create_Rotation_UI()
Create_GUIDE_UI()

function Bot_Begin()
    Run_Time = GetTime()
	BOT_Frame:SetScript("OnUpdate", MainThread)
	textout(Check_UI("开始工作","Start to work"))
end
function Bot_End()
    BOT_Frame:SetScript("OnUpdate", function() end)
	textout(Check_UI("停止工作","Stop to work"))
	teleport.x,teleport.y,teleport.z = 0,0,0
	Coordinates_Get = false
	Easy_Data.Sever_Map_Calculated = false
	Continent_Move = false
	Event_Reset()
end
Bot_Begin()

Spell_Casting = false
Spell_Channel_Casting = false
Merchant_Show = false
Gossip_Show = false
Quest_Show = false
Mount_useble = GetTime()
Trainer_Show = false
Stop_Moving = false
Has_Stop_Moving = false
Pet_Dead = false
Coprse_In_Range = false -- 进入复活范围
InstanceCorpse = false
In_Sight = false

local Script = CreateFrame("frame")
function Script:BeginEvent(event,arg1,arg2,_,_,arg5,arg6,_,_,_,_,_,_,_)
	if event == "CHAT_MSG_SYSTEM" then
	    if arg1 == TRANSFER_ABORT_TOO_MANY_INSTANCES then
			 Real_Flush_time = GetTime()
			 Real_Flush = true
			 Real_Flush_times = Real_Flush_times + 1
		end
	end	
	if event == "UNIT_SPELLCAST_SENT" and arg1 == "player" then
	    Spell_Casting = true
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
	    if not Spell_Channel_Casting then 
			Spell_Casting = false
		end
	end
	if event == "UNIT_SPELLCAST_FAILED" and arg1 == "player" then
	    Spell_Channel_Casting = false
		Spell_Casting = false
	end
	if event == "UNIT_SPELLCAST_INTERRUPTED" and arg1 == "player" then
	    Spell_Channel_Casting = false
		Spell_Casting = false
	end
	if event == "UNIT_SPELLCAST_CHANNEL_STOP" and arg1 == "player" then
	    Spell_Channel_Casting = false
		Spell_Casting = false
	end
	if event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
	    Spell_Channel_Casting = true
	end
	if event == "UI_ERROR_MESSAGE" then
	    if arg2 == SPELL_FAILED_LINE_OF_SIGHT then
            In_Sight = true
			C_Timer.After(5,function() if In_Sight then In_Sight = false end end)
		end

	    if arg2 == SPELL_FAILED_CANT_BE_DISENCHANTED or arg2 == ERR_CANT_BE_DISENCHANTED then
		    if not ValidResolve(Disenchant_Black_Name) and Easy_Data["分解黑名单"] and not CastingBarFrame:IsVisible() and HasDisenchant then
				Easy_Data["不分解物品"] = Easy_Data["不分解物品"]..","..Disenchant_Black_Name
				Basic_UI.Disenchant["分解物品"]:SetText(Easy_Data["不分解物品"])
			end
		end
		if arg2 == SPELL_FAILED_UNIT_NOT_INFRONT or arg2 == ERR_BADATTACKFACING or arg2 == ERR_USE_BAD_ANGLE or arg2 == SPELL_FAILED_CUSTOM_ERROR_141 then
			if awm.ObjectExists("target") then
			    Combat.Face_Time = GetTime()
				awm.FaceTarget("target")
			end
		end
		if arg2 == ERR_PET_SPELL_DEAD or arg2 == PETTAME_DEAD or arg2 == SPELL_FAILED_CUSTOM_ERROR_63 or arg2 == PETTAME_NOPETAVAILABLE or arg1 == 280 then
		    if not Pet_Dead then
			    Pet_Dead = true
			    C_Timer.After(15,function() Pet_Dead = false end)
			end
		end
		if arg2 == PETTAME_NOTDEAD then
		    Pet_Dead = false
		end
		if arg2 == SPELL_FAILED_TARGETS_DEAD then
			Pet_Dead = true
			C_Timer.After(15,function() Pet_Dead = false end)
		end
		if arg2 == SPELL_FAILED_MOVING then
		    if not Has_Stop_Moving then
				Try_Stop()
				Stop_Moving = true
				Has_Stop_Moving = true
				Mount_useble = GetTime() + 1.5
				Tried_Mount = GetTime() + 1.5
				C_Timer.After(5,function() Stop_Moving = false Has_Stop_Moving = false end)
			end
		end
		if arg2 == SPELL_FAILED_NOT_STANDING or arg2 == ERR_LOOT_NOTSTANDING or arg2 == ERR_CANTATTACK_NOTSTANDING then
            DoEmote("STAND")
		end
		if arg2 == ERR_MOUNT_TOOFARAWAY or arg2 == SPELL_FAILED_UNDERWATER_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_NO_MOUNTS_ALLOWED or arg2 == SPELL_FAILED_MOUNT_NO_UNDERWATER_HERE or arg2 == SPELL_FAILED_MOUNT_NO_FLOAT_HERE or arg2 == SPELL_FAILED_MOUNT_ABOVE_WATER_HERE or arg2 == SPELL_FAILED_GROUND_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_FLYING_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_FLOATING_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_CUSTOM_ERROR_511 or arg2 == SPELL_FAILED_CUSTOM_ERROR_50 or arg2 == SPELL_FAILED_CUSTOM_ERROR_169 then
            Mount_useble = GetTime() + 25
			Stop_Moving = false
		end 
		if arg2 == SPELL_FAILED_ONLY_OUTDOORS or arg1 == 1 then
            Mount_useble = GetTime() + 25
			Stop_Moving = false
		end
		if arg2 == ERR_AFFECTING_COMBAT or arg2 == SPELL_FAILED_AFFECTING_COMBAT then
            Mount_useble = GetTime() + 25
			Stop_Moving = false
		end
		if arg2 == SPELL_FAILED_ONLY_ABOVEWATER or arg2 == SPELL_FAILED_ONLY_NOT_SWIMMING or arg2 == SPELL_FAILED_ONLY_UNDERWATER then
            Mount_useble = GetTime() + 60
			Stop_Moving = false
		end
		if arg2 == ERR_ABILITY_COOLDOWN or arg2 == ERR_ITEM_COOLDOWN or arg2 == ERR_SPELL_COOLDOWN or arg2 == SPELL_FAILED_ITEM_NOT_READY then
            Mount_useble = GetTime() + 15
			Stop_Moving = false
		end
	end

	if event == "CONFIRM_LOOT_ROLL" then
		ConfirmLootRoll(arg1, arg2)
	end   
	if event == "GOSSIP_SHOW" then
	    Gossip_Show = true
	end
	if event == "GOSSIP_CLOSED" then
	    Gossip_Show = false
	end
	if event == "MERCHANT_SHOW" then
	    Merchant_Show = true
	    RepairAllItems()
	end
	if event == "MERCHANT_CLOSED" then
	    Merchant_Show = false
	end
	if event == "TRAINER_SHOW" then
	   Trainer_Show = true
	end
	if event == "TRAINER_CLOSED" then
	   Trainer_Show = false
	end
	if event == "CORPSE_IN_RANGE" then
	    Coprse_In_Range = true
		C_Timer.After(20,function() Coprse_In_Range = false end)
	end

	if event == "LOADING_SCREEN_DISABLED" then
		Coordinates_Get = false
		textout(Check_UI("世界重新载入, 关闭刷新所有功能","World loading... refresh and reopen all functions"))
	end

	if event == "CHAT_MSG_WHISPER" then
	    if Easy_Data["密语回复"] then
		    textout(Check_UI("收到悄悄话, 稍后回复","Whisper detected, reply in moments"))
			C_Timer.After(tonumber(Easy_Data["密语回复延时"]),
			function()
				local type = math.random(1,5)
				local reply_msg = ""
				if type == 1 then
					reply_msg = Easy_Data.whisper_1
				elseif type == 2 then
					reply_msg = Easy_Data.whisper_2
				elseif type == 3 then
					reply_msg = Easy_Data.whisper_3
				elseif type == 4 then
					reply_msg = Easy_Data.whisper_4
				elseif type == 5 then
					reply_msg = Easy_Data.whisper_5
				else
				    reply_msg = Easy_Data.whisper_5
				end
				awm.RunMacroText("/reply "..reply_msg)
			end)
		end
	end

	if event == "QUEST_DETAIL" then
	    Quest_Show = true
	end
	if event == "QUEST_GREETING" then
	    Quest_Show = true
	end
	if event == "QUEST_FINISHED" then
	    Quest_Show = false
	end
	if event == "CORPSE_IN_INSTANCE" then
	    InstanceCorpse = true
	end
end	
Script:RegisterEvent("CHAT_MSG_SYSTEM")
Script:RegisterEvent("UNIT_SPELLCAST_SENT")
Script:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
Script:RegisterEvent("UNIT_SPELLCAST_FAILED")
Script:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
Script:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
Script:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")

Script:RegisterEvent("UI_ERROR_MESSAGE")
Script:RegisterEvent("CONFIRM_LOOT_ROLL")
Script:RegisterEvent("GOSSIP_SHOW")
Script:RegisterEvent("GOSSIP_CLOSED")
Script:RegisterEvent("TRAINER_SHOW")
Script:RegisterEvent("TRAINER_CLOSED")
Script:RegisterEvent("MERCHANT_SHOW")
Script:RegisterEvent("MERCHANT_CLOSED")
Script:RegisterEvent("CORPSE_IN_RANGE")
Script:RegisterEvent("LOADING_SCREEN_DISABLED")
Script:RegisterEvent("CHAT_MSG_WHISPER")
Script:RegisterEvent("QUEST_DETAIL")
Script:RegisterEvent("QUEST_FINISHED")
Script:RegisterEvent("QUEST_GREETING")
Script:RegisterEvent("CORPSE_IN_INSTANCE")

Script:SetScript("OnEvent",Script.BeginEvent)

local combatlog = CreateFrame("Frame")
combatlog:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatlog:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function combatlog:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

	if (subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" or subevent == "SWING_MISSED") and sourceGUID == awm.UnitGUID("player") then
		local missType,Spell_Name,amountMissed,Miss_Reason = select(12, ...)
		if Miss_Reason == "EVADE" then
		    textout(Check_UI("怪物闪避, 开始检查坐标和技能","Monster Evade, Check coord and spells"))
			if awm.ObjectExists("target") then
			    if not Vaild_Black("target") then
			        Black_List[#Black_List + 1] = awm.UnitGUID("target")
				end

			    awm.FaceDirection(awm.GetAnglesBetweenObjects("player","target"))
				C_Timer.After(0.5,function() awm.MoveForwardStart() end)
				C_Timer.After(2,function() Try_Stop() end)
			end
		elseif Miss_Reason == "IMMUNE" and Spell_Name == rs["寒冰箭"] then
		    textout(Check_UI("怪物抵抗, 开始检查坐标和技能","Monster IMMUNE, Check coord and spells"))
			if not Monster_Evade then
			    Monster_Evade = true
				C_Timer.After(15,function() Monster_Evade = false end)
			end
			if awm.ObjectExists("target") then
			    if not Vaild_Black("target") then
			        Black_List[#Black_List + 1] = awm.UnitGUID("target")
				end
			end
		end
	end
end


local Detail_Frame = CreateFrame("Frame")
local Generate = false
local Dungeon_Run_Time = ""
local Mine_Level_Monitor = ""
local Loot_Amount_Monitor = ""
local Black_List_Monitor = ""
Detail_Frame:SetScript("OnUpdate", function()
    if not Generate then
	    Generate = true
	    
		Dungeon_Run_Time = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_Run_Time:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_Run_Time:SetText(Check_UI("运行时间: ","Running time: ")..math.floor(GetTime() - Run_Time))
		Dungeon_Run_Time:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Loot_Amount_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Loot_Amount_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Loot_Amount_Monitor:SetText(Check_UI("已击杀怪物: ","Killed total amount: ")..#Monster_Has_Killed)
		Loot_Amount_Monitor:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Black_List_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Black_List_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Black_List_Monitor:SetText(Check_UI("已拉黑怪物: ","Blacklist total amount: ")..#Black_List)
		Black_List_Monitor:Show()
	else
	    Dungeon_Run_Time:SetText(Check_UI("运行时间: ","Running time: ")..math.floor(GetTime() - Run_Time)..Check_UI(" 秒"," seconds"))
		Loot_Amount_Monitor:SetText(Check_UI("已击杀怪物: ","Killed total amount: ")..#Monster_Has_Killed)
		Black_List_Monitor:SetText(Check_UI("已拉黑怪物: ","Blacklist total amount: ")..#Black_List)
	end
end)