Function_Load_In = true
local Function_Version = "0111"
textout(Check_UI("野外升级 - "..Function_Version,"Leveling - "..Function_Version))

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


_,Class = UnitClass("player")
local Faction = UnitFactionGroup("player")
local Realm = GetRealmName() -- 服务器名称
Level = UnitLevel("player")
local _,Race = UnitRace("player")
------------------------------------------------------------------------
local Run_Timer = GetTime()

Easy_Data.Sever_Map_Calculated = false
Continent_Move = false

local teleport = {x = 0, y = 0, z = 0, timer = false, time = 0}
local Destroy_Time = 0 -- 自动摧毁
local Equip_Time = 0 -- 自动装备

local Grind = {Step = 1, Move = 1, Random_Path = {},}
Mission = {
    Step = 1,
	ID = nil, -- 任务id
	Flow = 1, -- 任务流程
	Text = {}, -- 任务文本
	Time = GetTime(),
	Timer = false,
	Execute = {},
	Info = {},
}

local Target_Info = {
    Mob = nil,
	GUID = nil,
	objx = nil,
	objy = nil,
	objz = nil,
}

local Monster_Has_Killed = {} -- 已击杀怪物
local Has_Scan = false -- 扫描间隔
local Scan_Time = 0 -- 扫描间隔时间

local Loot_Timer = false
local Loot_Time = 0

local Black_Timer = false
local Black_Time = 0

local Has_Call_Pet = false -- 召唤宠物

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

local Interact_Step = false
local Eat_Time = 0 -- 吃喝 制造食物 间隔计时

local Has_Learn = false -- 已经学过技能
local Learn_Step = 1 -- 学技能步骤
local Has_Mail = false -- 邮寄过了

local Combat_In_Range = false

local Dead = {
    Repop = GetTime(),
	Shift = false,
	Shift_Step = 1,
	Safe = {},
}

local Start_Restore = false -- 是否正在回血
local Reset_Killed = 0

local Scan_Combat = false

local Combat = {
    Spell_Timer = false,

	Vanish = 0, -- 盗贼消失计时
	Time = 0,
	Hunter_Trap = 0, -- 猎人陷阱计时
	Face_Time = GetTime(),
	Forst = false,
	Combat_In_Range = false,

	Fixed_Target = false,
	Fixed_Time = 0,
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

	Pet_Food_Vendor_Name = "" -- 宠物食品NPC名字
	Pet_Food_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}

	Trainer_Name = ""
	Trainer_Coord = {mapid = 0, x = 0, y = 0, z = 0} -- 技能导师坐标

	Mobs_ID = {} -- 怪物ID
	Mobs_Coord = {}
	Mobs_MapID = 0
	Black_Spot = {}

	Ammo_Vendor_Name = "" -- 弹药商
	Ammo_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}

	Food_Vendor_Name = "" -- 吃喝购买
	Food_Vendor_Coord = {mapid = 0, x = 0, y = 0, z = 0}
end
Grind_Config()

function Event_Reset()
    Grind.Step = 1

	Mission.Flow = 1
	Mission.Timer = false
	Mission.Step = 1
end

function CheckDeadOrNot() -- 判断角色是否死亡
    if awm.UnitIsDeadOrGhost("player") and not CheckBuff("player",rs["假死"]) then
	    if not awm.UnitIsGhost("player") then
		    if Target_Info.GUID and not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
				Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
				textout(Check_UI("< "..Target_Info.GUID.." > 黑名单","< "..Target_Info.GUID.." > Add into Black list"))
			end

			if Combat_Target and awm.UnitGUID(Combat_Target) and not Vaild_mobs(Monster_Has_Killed,awm.UnitGUID(Combat_Target)) then
				Monster_Has_Killed[#Monster_Has_Killed + 1] = awm.UnitGUID(Combat_Target)
				textout(Check_UI("< "..awm.UnitGUID(Combat_Target).." > 黑名单","< "..awm.UnitGUID(Combat_Target).." > Add into Black list"))
			end

		    Dead.Repop = GetTime()
			Dead.Shift = false
			Grind.Step = 1
			Dead.Shift_Step = 1
			Dead.Safe = {}
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
function Valid_Quest_Item(item)
    for id in pairs(Mission.Info) do
		if id and C_QuestLog.IsOnQuest(id) and Mission.Info[id].ValidItem ~= nil and type(Mission.Info[id].ValidItem) == "string" and Mission.Info[id].ValidItem == item then
		    return true
		elseif id and C_QuestLog.IsOnQuest(id) and Mission.Info[id].ValidItem ~= nil and tonumber(Mission.Info[id].ValidItem) and tonumber(Mission.Info[id].ValidItem) == tonumber(select(2,GetItemInfo(item)):match("item:(%d+):")) then
		    return true
		elseif id and C_QuestLog.IsOnQuest(id) and Mission.Info[id].ValidItem ~= nil and type(Mission.Info[id].ValidItem) == "table" and #Mission.Info[id].ValidItem > 0 then
		    for i = 1,#Mission.Info[id].ValidItem do
			    if item == Mission.Info[id].ValidItem[i] or (tonumber(Mission.Info[id].ValidItem[i]) and tonumber(select(2,GetItemInfo(item)):match("item:(%d+):")) == tonumber(Mission.Info[id].ValidItem[i])) then
				    return true
				end
			end
		end
	end
	if Easy_Data["销毁任务物品"] then
		return false
	else
	    return true
	end
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
					if (item and Valid_Destroy(item)) or (item and Valid_Destroy_Quality(quality)) or (item and type == 12 and not Valid_Quest_Item(item)) then
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

function Auto_Learn() -- 自动学技能
    local Skip_Spell = string.split(Easy_Data["技能过滤"],",")

    local allAvailableOptions = GetNumTrainerServices()
	local money = GetMoney()
    local level = awm.UnitLevel("player")
	for i = 1, allAvailableOptions, 1 do
        local spell = GetTrainerServiceInfo(i)

		local autolearn = true
		if #Skip_Spell > 0 then
		    for s = 1,#Skip_Spell do
			    if Skip_Spell[s] == spell then
				    autolearn = false				    
				end
			end
		end

        if spell ~= nil and autolearn then
            if GetTrainerServiceLevelReq(i) <= level then
                if GetTrainerServiceCost(i) <= money then
                    BuyTrainerService(i)
                    if IsTradeskillTrainer() then
                        CloseTrainer()
                    end
                end
            end
        end
    end
end
function Spell_Run(x,y,z)
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Learn_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if Learn_Distance >= 4 then
	    Note_Set(Check_UI("距离剩余 = "..math.floor(Learn_Distance),"Distance = "..math.floor(Learn_Distance)))
		Run(x,y,z)
		Interact_Step = false
	else
	    Note_Set(Check_UI("开始学习步骤 - "..Learn_Step,"Begin Spell Learn Step - "..Learn_Step))
		if type(Trainer_Name) == "string" then
		    awm.TargetUnit(Trainer_Name)
		elseif type(Trainer_Name) == "number" then
		    local total = awm.GetObjectCount()
			local Far_Distance = 100
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local id = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectIsUnit(ThisUnit) 
				    and not awm.UnitIsDead(ThisUnit) 
					and not awm.UnitAffectingCombat(ThisUnit) 
					and id == Trainer_Name 
					and distance < Far_Distance then
					    awm.TargetUnit(ThisUnit)
				end
			end		    
		end
		if Trainer_Show then
			Auto_Learn()
			if Learn_Step == 1 then
				Learn_Step = 2
				CloseTrainer()
				local random_Time = math.random(10,15) + math.random()
				C_Timer.After(random_Time, function() Learn_Step = 3 end)
			end
			if Learn_Step == 3 then
				Learn_Step = 4
				CloseTrainer()
				local random_Time = math.random(10,15) + math.random()
				C_Timer.After(random_Time, function() Learn_Step = 5 end)
			end
			if Learn_Step == 5 then
				Learn_Step = 1
				Has_Learn = true
				Easy_Data["已经学过技能"] = true
				CloseTrainer()
				awm.ClearTarget()
				textout(Check_UI("学习完毕","Learn logic end"))
			end
			return
		elseif Gossip_Show then
			if not Interact_Step then
				Interact_Step = true
				local title1,gossip1,title2,gossip2,title3,gossip3,title4,gossip4,title5,gossip5 = GetGossipOptions()
				if gossip1 == "trainer" then
					SelectGossipOption(1)
				elseif gossip2 == "trainer" then
					SelectGossipOption(2)
				elseif gossip3 == "trainer" then
					SelectGossipOption(3)
				elseif gossip4 == "trainer" then
					SelectGossipOption(4)
				elseif gossip5 == "trainer" then
					SelectGossipOption(5)
				end
				C_Timer.After(1, function() Interact_Step = false end)
			end
		else
            if not Interact_Step then
				Interact_Step = true
				C_Timer.After(1, function() Interact_Step = false awm.InteractUnit("target") end)
			end
			return					
		end
	end
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
		    if GetMoney() >= money then
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
		    if GetMoney() >= money then
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

local Need_Equip_Name = nil
local try_equip = false
local Try_Times = 0
function Auto_Equip()
    if Need_Equip_Name ~= nil then
	    Note_Set(Check_UI("自动装备 - "..Need_Equip_Name,"Auto Equip - "..Need_Equip_Name))
		if not try_equip and not IsEquippedItem(Need_Equip_Name) then
		    try_equip = true
			Try_Times = Try_Times + 1
			C_Timer.After(1,function() try_equip = false end)
			EquipItemByName(Need_Equip_Name)
			EquipPendingItem(0)
		elseif IsEquippedItem(Need_Equip_Name) then
		    Need_Equip_Name = nil
			return
		elseif Try_Times >= 5 then
		    Need_Equip_Name = nil
			Try_Times = 0
			return
		end
	    return
	end
    for bag = 0,4 do
	    if GetBagName(bag) ~= nil then
		    for slot = 1,16 do
			    local link = GetContainerItemLink(bag, slot)

				local Detection = false
				for table = 1,#Equip_Black_List do
					if link and Equip_Black_List[table] == GetItemInfo(link) then
						Detection = true
					end
				end

				if link ~= nil and IsEquippableItem(link) and not Detection then
				    local item_name = GetItemInfo(link)
					local item_level = select(4,GetItemInfo(link))
					local require_level = select(5,GetItemInfo(link))
					local item_quality = select(3,GetItemInfo(link))
					local item_class = select(12,GetItemInfo(link))
					local item_sub_class = select(13,GetItemInfo(link))
					local Equip_Invslot_id = select(9,GetItemInfo(link))

					if UnitLevel("player") >= require_level then

						if (Class == "MAGE" or Class == "WARLOCK" or Class == "PRIEST" or Class == "HUNTER") and item_class == 4 and item_sub_class == 1 and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
							Need_Equip_Name = item_name
							return
						elseif (Class == "PALADIN" or Class == "WARRIOR") and item_class == 4 and item_sub_class == 4 and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
							Need_Equip_Name = item_name
							return
						elseif Class == "SHAMAN" and item_class == 4 and item_sub_class == 3 and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
							Need_Equip_Name = item_name
							return
						elseif (Class == "ROGUE" or Class == "DRUID") and item_class == 4 and item_sub_class == 2 and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
							Need_Equip_Name = item_name
							return
						end

						if item_class == 2 then
							if Class == "MAGE" and (item_sub_class == 10 or item_sub_class == 19) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "PRIEST" and (item_sub_class == 10 or item_sub_class == 19) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "WARLOCK" and (item_sub_class == 10 or item_sub_class == 19) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "DRUID" and (item_sub_class == 13 or item_sub_class == 4 or item_sub_class == 10) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "SHAMAN" and (item_sub_class == 13 or item_sub_class == 0 or item_sub_class == 4 or item_sub_class == 10) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "ROGUE" and (item_sub_class == 15 or item_sub_class == 13 or item_sub_class == 0 or item_sub_class == 7) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "WARRIOR" and (item_sub_class == 13 or item_sub_class == 0 or item_sub_class == 4 or item_sub_class == 7) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "PALADIN" and (item_sub_class == 0 or item_sub_class == 4 or item_sub_class == 7) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							elseif Class == "HUNTER" and (item_sub_class == 2 or item_sub_class == 18) and Check_Equip(Equip_Invslot_id,item_level,item_quality) then
								Need_Equip_Name = item_name
								return
							end
						end

						if item_class == 1 and item_sub_class == 0 and (GetBagName(1) == nil or GetBagName(2) == nil or GetBagName(3) == nil or GetBagName(4) == nil) then
							Need_Equip_Name = item_name
							return
						end
					end
				end
			end
		end
	end
	Equip_Time = GetTime()
end
function Check_Equip(invslot,level,quality) -- 检查是否符合条件
	local equip_link = GetInventoryItemLink("player", invslot)
	if invslot == "INVTYPE_ROBE" then
		equip_link = GetInventoryItemLink("player", INVSLOT_CHEST)
	elseif invslot == "INVTYPE_CHEST" then
		equip_link = GetInventoryItemLink("player", INVSLOT_CHEST)
	elseif invslot == "INVTYPE_HEAD" then
		equip_link = GetInventoryItemLink("player", INVSLOT_HEAD)
	elseif invslot == "INVTYPE_NECK" then
		equip_link = GetInventoryItemLink("player", INVSLOT_NECK)
	elseif invslot == "INVTYPE_SHOULDER" then
		equip_link = GetInventoryItemLink("player", INVSLOT_SHOULDER)
	elseif invslot == "INVTYPE_BODY" then
		equip_link = GetInventoryItemLink("player", INVSLOT_BODY)
	elseif invslot == "INVTYPE_WAIST" then
		equip_link = GetInventoryItemLink("player", INVSLOT_WAIST)
	elseif invslot == "INVTYPE_LEGS" then
		equip_link = GetInventoryItemLink("player", INVSLOT_LEGS)
	elseif invslot == "INVTYPE_FEET" then
		equip_link = GetInventoryItemLink("player", INVSLOT_FEET)
	elseif invslot == "INVTYPE_WRIST" then
		equip_link = GetInventoryItemLink("player", INVSLOT_WRIST)
	elseif invslot == "INVTYPE_HAND" then
		equip_link = GetInventoryItemLink("player", INVSLOT_HAND)
	elseif invslot == "INVTYPE_FINGER" then
		equip_link = GetInventoryItemLink("player", INVSLOT_FINGER2)
	elseif invslot == "INVTYPE_TRINKET" then
		equip_link = GetInventoryItemLink("player", INVSLOT_TRINKET1)
	elseif invslot == "INVTYPE_WEAPON" then
		equip_link = GetInventoryItemLink("player", INVSLOT_MAINHAND)
	elseif invslot == "INVTYPE_SHIELD" then
		equip_link = GetInventoryItemLink("player", INVSLOT_OFFHAND)
	elseif invslot == "INVTYPE_RANGED" then
		equip_link = GetInventoryItemLink("player", INVSLOT_RANGED)
	elseif invslot == "INVTYPE_CLOAK" then
		equip_link = GetInventoryItemLink("player", INVSLOT_BACK)
	elseif invslot == "INVTYPE_2HWEAPON" then
		equip_link = GetInventoryItemLink("player", INVSLOT_MAINHAND)
	elseif invslot == "INVTYPE_TABARD" then
		equip_link = GetInventoryItemLink("player", INVSLOT_TABARD)
	elseif invslot == "INVTYPE_WEAPONMAINHAND" then
		equip_link = GetInventoryItemLink("player", INVSLOT_MAINHAND)
	elseif invslot == "INVTYPE_WEAPONOFFHAND" then
		equip_link = GetInventoryItemLink("player", INVSLOT_OFFHAND)
	elseif invslot == "INVTYPE_HOLDABLE" then
		equip_link = GetInventoryItemLink("player", INVSLOT_OFFHAND)
	elseif invslot == "INVTYPE_THROWN" then
		equip_link = GetInventoryItemLink("player", INVSLOT_MAINHAND)
	elseif invslot == "INVTYPE_RANGEDRIGHT" then
		equip_link = GetInventoryItemLink("player", INVSLOT_RANGED)
	else
	    equip_link = 1
	end
	if equip_link == nil then
	    textout(Check_UI("该位置未装备物品, 替换"..invslot,"Inventory slot = nil, replace it"..invslot))
		return true
	elseif equip_link ~= 1 then
		local equip_level = select(4,GetItemInfo(equip_link))
		local equip_quality = select(3,GetItemInfo(equip_link))
		if level > equip_level and quality >= equip_quality then
		    textout(Check_UI("等级更好, 替换","Item level better, replace it"))
		    return true
		elseif level >= equip_level and quality > equip_quality then
		    textout(Check_UI("品质更好, 替换","Item quality better, replace it"))
			return true
		elseif level - equip_level >= 3 and quality >= 1 then
			textout(Check_UI("物品等级跨越3级, 替换","Item level gap greater than 3, replace it"))
			return true
		elseif level - equip_level >= 5 then
			textout(Check_UI("物品等级跨越5级, 替换","Item level gap greater than 5, replace it"))
			return true
		end
	end
	return false
end

function Grind_Information()
    if Race == "Tauren" then
	    if Class == "HUNTER" then
			Trainer_Name = Check_Client("雅文·刺鬃","Yaw Sharpmane")
			Trainer_Coord = {mapid = 1412, x = -2180, y = -408, z = -5}
		elseif Class == "WARRIOR" then
			Trainer_Name = Check_Client("克朗·石蹄","Krang Stonehoof")
			Trainer_Coord = {mapid = 1412, x = -2347, y = -495, z = -9}
		elseif Class == "DRUID" then
			Trainer_Name = Check_Client("根妮亚·符文图腾","Gennia Runetotem")
			Trainer_Coord = {mapid = 1412, x = -2315, y = -442, z = -5}
		elseif Class == "SHAMAN" then
			Trainer_Name = Check_Client("纳姆·逐星","Narm Skychaser")
			Trainer_Coord = {mapid = 1412, x = -2298, y = -437, z = -5}
		end
		if Level >= 1 and Level <= 3 then
			Mobs_ID = { 2955 }
			Mobs_MapID = 1412
			Mobs_Coord =
			{
			{-2905,-370,53},
			{-3005,-483,38},
			{-3127,-420,33},
			{-3042,-279,41},
			{-3160,-263,40},
			{-3190,-391,29}
			}

			Merchant_Name = Check_Client("瓦利亚·韧皮","Varia Hardhide")
			Merchant_Coord = {mapid = 1412, x = -2918, y = -219, z = 54}
			Mail_Coord = {mapid = 1412, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("卡文尼·柔风","Kawnie Softbreeze")
			Ammo_Vendor_Coord = {mapid = 1412, x = -2893, y = -279, z = 54}

			Food_Vendor_Name = Check_Client("卡文尼·柔风","Kawnie Softbreeze")
			Food_Vendor_Coord = {mapid = 1412, x = -2893, y = -279, z = 54}
		elseif Level >= 4 and Level <= 6 then
			Mobs_ID = { 2961 }
			Mobs_MapID = 1412
			Mobs_Coord =
			{
			{-3362,-436,63},
			{-3386,-209,59},
			}
			Merchant_Name = Check_Client("瓦利亚·韧皮","Varia Hardhide")
			Merchant_Coord = {mapid = 1412, x = -2918, y = -219, z = 54}
			Mail_Coord = {mapid = 1412, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("卡文尼·柔风","Kawnie Softbreeze")
			Ammo_Vendor_Coord = {mapid = 1412, x = -2893, y = -279, z = 53}

			Food_Vendor_Name = Check_Client("卡文尼·柔风","Kawnie Softbreeze")
			Food_Vendor_Coord = {mapid = 1412, x = -2893, y = -279, z = 53}
		elseif Level >= 7 and Level <= 9 then
			Mobs_ID = { 2956, 2949, 2950, 2958, 2969, 2951 }
			Mobs_MapID = 1412
			Mobs_Coord =
			{
			{-2681,-450,-7},
			{-2670,-751,-5}
			}
			Black_Spot = {{-2739,-439,-4.3,30}}
			Merchant_Name = Check_Client("肯纳·鹰眼","Kennah Hawkseye")
			Merchant_Coord = {mapid = 1412, x = -2275, y = -289, z = -9}
			Mail_Coord = {mapid = 1412, x = -2336, y = -367, z = -8}

			Ammo_Vendor_Name = Check_Client("姆拉特·远行","Moorat Longstride")
			Ammo_Vendor_Coord = {mapid = 1412, x = -2247, y = -308, z = -9}

			Food_Vendor_Name = Check_Client("加纳·麦风","Jhawna Oatwind")
			Food_Vendor_Coord = {mapid = 1412, x = -2379, y = -399, z = -4}

		elseif Level >= 10 and Level <= 11 then
			Mobs_ID = { 2959, 3035, 2970, 2957 }
			Mobs_MapID = 1412
			Mobs_Coord =
			{
			{-1911,-347,-5},
			{-1772,-561,-4},
			{-1882,-709,-9}
			}
			Merchant_Name = Check_Client("肯纳·鹰眼","Kennah Hawkseye")
			Merchant_Coord = {mapid = 1412, x = -2275, y = -289, z = -9}
			Mail_Coord = {mapid = 1412, x = -2336, y = -367, z = -8}

			Ammo_Vendor_Name = Check_Client("姆拉特·远行","Moorat Longstride")
			Ammo_Vendor_Coord = {mapid = 1412, x = -2247, y = -308, z = -9}

			Food_Vendor_Name = Check_Client("加纳·麦风","Jhawna Oatwind")
			Food_Vendor_Coord = {mapid = 1412, x = -2379, y = -399, z = -4}

		elseif Level >= 12 and Level <= 15 then
			Mobs_ID = { Check_Client("钢鬃寻水者","Razormane Water Seeker"), Check_Client("钢鬃织棘者","Razormane Thornweaver"), Check_Client("钢鬃猎手","Razormane Hunter"), Check_Client("长鬃草原狮","Savannah Highmane"), Check_Client("赤鳞鞭尾龙","Sunscale Lashtail"), Check_Client("巨型平原陆行鸟","Greater Plainstrider")}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-151.342651,  -2714.420654, 91.667053},
            {-130.659622,  -2745.893066, 92.971779},
            {-108.888397,  -2771.359619, 93.383476},
            {-85.764336,  -2794.625977, 94.818245},
            {-60.362385,  -2818.897949, 92.771545},
            {-42.944874,  -2843.637939, 91.674232},
            {-31.619328,  -2874.473633, 91.666748},
            {-51.143387,  -2910.022949, 92.668396},
            {-73.539230,  -2928.188477, 94.040024},
            {-98.831116,  -2944.085205, 92.362045},
            {-126.733582,  -2944.553955, 91.667641},
            {-156.696579,  -2909.666016, 93.204819},
            {-151.342651,  -2714.420654, 91.667053}
			}
			Black_Spot = {}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

		elseif Level >= 16 and Level <= 19 then
			Mobs_ID = { 
			Check_Client("草原幼狮","Savannah Cub"),
			Check_Client("冲锋斑马","Zhevra Charger"),
			Check_Client("草原狮后","Savannah Matriarch"),
			Check_Client("暴躁的平原陆行鸟","Ornery Plainstrider"),
			Check_Client("赤鳞镰爪龙","Sunscale Scytheclaw"),
			Check_Client("赤鳞尖啸龙","Sunscale Screecher"),
			Check_Client("草原狮王","Savannah Patriarch"),
			Check_Client("长颈鹿","Barrens Giraffe"),
			Check_Client("草原徘徊者","Savannah Prowler"),
			Check_Client("乱齿土狼","Hecklefang Hyena"),
			}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-837,-3278,94},
			{-702,-3405,91},
			{-607,-3516,93},
			{-495,-3528,92},
			{-451,-3401,92},
			{-673,-3296,96},
			}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

		elseif Level >= 20 and Level <= 22 then
			Mobs_ID = { 3426, 3245, 3241, 3256, 4129, 3240, 3247, 3463, 3260, 3258 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2173,-2002,93},
			{-2191,-1832,94},
			{-2118,-2085,94}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

		elseif Level >= 23 and Level <= 24 then
			Mobs_ID = { 3466, 3239, 3424, 3473 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2392,-2285,91},
			{-2494,-2399,91},
			{-2654,-2285,92},
			{-2610,-2075,92.66}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

		elseif Level >= 25 and Level <= 27 then
			Mobs_ID = { 3434, 3238, 4128, 5832, 3472, 3249, 3436 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-3442,-1842,91},
			{-3545,-1892,91},
			{-3605,-1941,92},
			{-3734,-1953,92.66},
			{-3819,-2099,92},
			{-3863,-2183,94},
			{-3760,-2282,91},
			{-3670,-2144,93}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

		elseif Level >= 28 and Level <= 32 then
			Mobs_ID = { 3818,3825,6073,6115,3821 }
			Mobs_MapID = 1440
			Mobs_Coord =
			{
			{2205.12,-2463.99,87.07},
			{2255.34,-2356.56,107.62},
			{2188.43,-2285.27,97.63},
			{2117.33,-2296.49,98.95},
			{2038.18,-2271.62,107.59},
			{1963.97,-2300.43,90.94},
			{1960.28,-2132.68,99.25},
			}
			Merchant_Name = Check_Client("布克拉姆","Burkrum")
			Merchant_Coord = {mapid = 1440, x = 2354, y = -2540, z = 102}
			Mail_Coord = {mapid = 1440, x = 2331.42, y = -2545.12, z = 101.56}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

		elseif Level >= 33 and Level <= 35 then
			Mobs_ID = {683,681,1150,1108,736,682}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-11921.67,-206.48,14.11},{-11827.11,-237.52,16.64},{-11706.57,-211.00,39.56},{-11659.87,-129.09,17.05},{-11676.74,-39.60,14.91},{-11659.38,37.11,17.99},{-11590.73,98.33,17.43},{-11548.94,186.79,16.98},{-11539.45,306.53,38.86},{-11633.14,351.85,45.16},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = {686,1152,1114,1096,4260}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12219.51,143.34,16.55},{-12264.71,76.40,15.50},{-12293.90,-24.07,25.23},{-12271.32,-123.74,21.20},{-12234.86,-228.29,17.58},{-12369.33,-229.49,17.91},{-12348.36,-413.52,15.96},{-12288.82,-477.07,15.71},{-12161.00,-599.17,15.06},{-12098.60,-647.25,16.20},{-12052.10,-717.86,17.02},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

		elseif Level >= 41 and Level <= 45 then
			Mobs_ID = {690,772,687}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12961.03,-116.54,13.02},{-12900.36,-76.99,8.46},{-12855.35,-20.89,15.53},{-12840.28,29.51,12.81},{-12807.55,110.51,15.75},{-13053.72,341.05,19.80},{-13189.97,436.13,11.82},{-13286.68,508.89,3.59},{-13367.79,610.84,8.92},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

		elseif Level >= 46 and Level <= 48 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

		elseif Level >= 49 and Level <= 51 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 6512, 9167, 6559, 9164 }
			Mobs_MapID = 1449
			Mobs_Coord =
			{
			{ -6456.568359375, -891.36578369141, -274.83392333984 },
			{ -6540.1196289063, -701.29125976563, -268.04959106445 },
			{ -6712.9560546875, -600.27264404297, -270.72622680664 },
			{ -6826.2578125, -500.36874389648, -273.47332763672 },
			{ -6933.748046875, -496.25326538086, -273.27359008789 }
			}
			Merchant_Name = Check_Client("吉波尔特","Gibbert")
			Merchant_Coord = {mapid = 1449, x = -6144, y = -1098, z = -202}
			Mail_Coord = {mapid = 1449, x = -6174, y = -1078, z = -202}

			Ammo_Vendor_Name = Check_Client("奈尔加","Nergal")
			Ammo_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			Food_Vendor_Name = Check_Client("奈尔加","Nergal")
			Food_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("布克拉姆","Burkrum")
			Ammo_Vendor_Coord = {mapid = 1440, x = 2355, y = -2540, z = 102}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = {16879,19434}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-8.51,2304.82,73.57},{56.79,2351.78,65.70},{158.26,2477.52,58.19},{282.43,2496.49,105.31},{317.64,2372.79,83.33},
			}
			Merchant_Name = Check_Client("雷甘·曼库索","Reagan Mancuso")
			Merchant_Coord = {mapid = 1944, x = 179.78, y = 2605.40, z = 87.28}
			Mail_Coord = {mapid = 1944, x = 172.3, y = 2623.74, z = 87.09}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
			Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

		end
	elseif Race == "Troll" or Race == "Orc" then
	    if Class == "HUNTER" then
			Trainer_Name = Check_Client("索塔尔","Thotar")
			Trainer_Coord = {mapid = 1411, x = 275, y = -4704, z = 11}
		elseif Class == "WARRIOR" then
			Trainer_Name = Check_Client("塔绍尔·锯痕","Tarshaw Jaggedscar")
			Trainer_Coord = {mapid = 1411, x = 311, y = -4827, z = 9.58}
		elseif Class == "ROGUE" then
			Trainer_Name = Check_Client("卡普拉克","Kaplak")
			Trainer_Coord = {mapid = 1411, x = 268, y = -4710, z = 17.49}
		elseif Class == "WARLOCK" then
			Trainer_Name = Check_Client("杜格鲁·血怒","Dhugru Gorelust")
			Trainer_Coord = {mapid = 1411, x = 356, y = -4837, z = 11}
		elseif Class == "PRIEST" then
			Trainer_Name = Check_Client("泰金","Tai'jin")
			Trainer_Coord = {mapid = 1411, x = 294, y = -4831, z = 11}
		elseif Class == "MAGE" then
			Trainer_Name = Check_Client("安苏瓦","Un'Thuwa")
			Trainer_Coord = {mapid = 1411, x = -839, y = -4939, z = 21}
		elseif Class == "SHAMAN" then
			Trainer_Name = Check_Client("斯瓦特","Swart")
			Trainer_Coord = {mapid = 1411, x = 307, y = -4839, z = 11}
		end
		if Level >= 1 and Level <= 3 then
			Mobs_ID = { 3098 }
			Mobs_MapID = 1411
			Mobs_Coord =
			{
			{ -551.01312255859, -4314.5336914063, 38.908874511719 },
            { -489.63919067383, -4347.5146484375, 39.543106079102 },
            { -413.80426025391, -4330.0776367188, 44.117992401123 },
            { -326.70364379883, -4297.1215820313, 57.394786834717 }
			}

			Merchant_Name = 3159 -- 克赞荆条
			Merchant_Coord = {mapid = 1411, x = -588.9937, y = -4102.5239, z = 43.5442}
			Mail_Coord = {mapid = 1411, x = -443, y = -2649, z = 95}

			Ammo_Vendor_Name = Check_Client("多克纳","Duokna")
			Ammo_Vendor_Coord = {mapid = 1411, x = -565, y = -4214, z = 41}

			Food_Vendor_Name = Check_Client("兹拉克","Zlagk")
			Food_Vendor_Coord = {mapid = 1411, x = -560, y = -4217, z = 41}

		elseif Level >= 4 and Level <= 6 then
			Mobs_ID = { 3103, 3102, 3101 }
			Mobs_MapID = 1411
			Mobs_Coord =
			{
			{ -213.36685180664, -4391.2436523438, 63.36954498291 },
            { -287.32418823242, -4281.6977539063, 60.551067352295 },
            { -116.87115478516, -4329.6352539063, 66.041969299316 }
			}
			Merchant_Name = 3159 -- 克赞荆条
			Merchant_Coord = {mapid = 1411, x = -588.9937, y = -4102.5239, z = 43.5442}
			Mail_Coord = {mapid = 1411, x = -443, y = -2649, z = 95}

			Ammo_Vendor_Name = Check_Client("多克纳","Duokna")
			Ammo_Vendor_Coord = {mapid = 1411, x = -565, y = -4214, z = 41}

			Food_Vendor_Name = Check_Client("兹拉克","Zlagk")
			Food_Vendor_Coord = {mapid = 1411, x = -560, y = -4217, z = 41}

			
			
		elseif Level >= 7 and Level <= 9 then
			Mobs_ID = { 3099, 3125, 3128, 3129, 3111, 3112, 3113, 3114 }
			Mobs_MapID = 1411
			Mobs_Coord =
			{
			{207.869400, -4731.613281, 13.286960}, 
            {176.972443, -4705.242188, 18.321346}, 
            {139.435013, -4674.808594, 22.335291}, 
            {94.897247, -4662.572754, 34.230789}, 
            {74.851120, -4633.574219, 40.576107}, 
            {8.630533, -4625.984375, 42.696388}, 
            {-23.760706, -4631.594238, 41.195129}, 
            {-73.338333, -4642.855469, 37.365341},
            {-137.758331, -4658.680664, 34.450512}, 
            {-182.141006, -4686.292969, 32.329018}, 
            {-223.728210, -4714.499512, 29.011219}, 
            {-251.844559, -4730.098633, 32.319424}, 
            {-257.439880, -4843.892090, 31.190092}, 
            {-234.280762, -4900.123535, 28.748905}, 
            {-204.762329, -4911.139648, 25.165537}, 
            {-176.550949, -4871.037598, 19.460142}, 
            {-144.165344, -4911.080078, 20.289595}, 
            {-130.013977, -4948.105957, 20.486889},
            {-126.222748, -4972.639648, 19.441652}, 
            {-103.995132, -4993.116211, 17.344095}, 
            {-71.036064, -5011.212402, 15.092132}, 
            {-24.396248, -5007.360352, 12.479616}, 
            {-2.357885, -4943.493164, 14.533060}, 
            {2.360584, -4900.118164, 16.497021}, 
            {18.373260, -4850.567383, 20.621611}, 
            {64.984497, -4795.629883, 22.140747}, 
            {107.026917, -4773.905762, 17.123232}, 
            {133.211121, -4746.179199, 14.626560},
            {106.643608, -4715.814941, 23.865471},
            {82.413109, -4673.870117, 35.873409}
			}
			Black_Spot = {{73.27,-4577.63,56.61,70}}
			Merchant_Name = Check_Client("格劳特","Ghrawt")
			Merchant_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}
			Mail_Coord = {mapid = 1411, x = 322, y = -4706, z = 14}

			Ammo_Vendor_Name = Check_Client("格劳特","Ghrawt")
			Ammo_Vendor_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}

			Food_Vendor_Name = Check_Client("旅店老板格罗斯克","Innkeeper Grosk")
			Food_Vendor_Coord = {mapid = 1411, x = 340, y = -4686, z = 16}

			
			
		elseif Level >= 10 and Level <= 11 then
			Mobs_ID = { 3123, 3100, 3127 }
			Mobs_MapID = 1411
			Mobs_Coord =
			{
			{ 1290.7847900391, -4765.2451171875, 19.493337631226 },   
			{ 1229.0876464844, -4917.1831054688, 11.688507080078 },
			{ 1410.9993896484, -4852.7685546875, 15.389236450195 }
			}
			Black_Spot = {}
			Merchant_Name = Check_Client("格劳特","Ghrawt")
			Merchant_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}
			Mail_Coord = {mapid = 1411, x = 322, y = -4706, z = 14}

			Ammo_Vendor_Name = Check_Client("格劳特","Ghrawt")
			Ammo_Vendor_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}

			Food_Vendor_Name = Check_Client("旅店老板格罗斯克","Innkeeper Grosk")
			Food_Vendor_Coord = {mapid = 1411, x = 340, y = -4686, z = 16}

			
			
		elseif Level >= 12 and Level <= 15 then
			Mobs_ID = { Check_Client("钢鬃寻水者","Razormane Water Seeker"), Check_Client("钢鬃织棘者","Razormane Thornweaver"), Check_Client("钢鬃猎手","Razormane Hunter"), Check_Client("长鬃草原狮","Savannah Highmane"), Check_Client("赤鳞鞭尾龙","Sunscale Lashtail"), Check_Client("巨型平原陆行鸟","Greater Plainstrider")}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-151.342651,  -2714.420654, 91.667053},
            {-130.659622,  -2745.893066, 92.971779},
            {-108.888397,  -2771.359619, 93.383476},
            {-85.764336,  -2794.625977, 94.818245},
            {-60.362385,  -2818.897949, 92.771545},
            {-42.944874,  -2843.637939, 91.674232},
            {-31.619328,  -2874.473633, 91.666748},
            {-51.143387,  -2910.022949, 92.668396},
            {-73.539230,  -2928.188477, 94.040024},
            {-98.831116,  -2944.085205, 92.362045},
            {-126.733582,  -2944.553955, 91.667641},
            {-156.696579,  -2909.666016, 93.204819},
            {-151.342651,  -2714.420654, 91.667053}
			}
			Black_Spot = {}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 16 and Level <= 19 then
			Mobs_ID = { 
			Check_Client("草原幼狮","Savannah Cub"),
			Check_Client("冲锋斑马","Zhevra Charger"),
			Check_Client("草原狮后","Savannah Matriarch"),
			Check_Client("暴躁的平原陆行鸟","Ornery Plainstrider"),
			Check_Client("赤鳞镰爪龙","Sunscale Scytheclaw"),
			Check_Client("赤鳞尖啸龙","Sunscale Screecher"),
			Check_Client("草原狮王","Savannah Patriarch"),
			Check_Client("长颈鹿","Barrens Giraffe"),
			Check_Client("草原徘徊者","Savannah Prowler"),
			Check_Client("乱齿土狼","Hecklefang Hyena"),
			}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-837,-3278,94},
			{-702,-3405,91},
			{-607,-3516,93},
			{-495,-3528,92},
			{-451,-3401,92},
			{-673,-3296,96},
			}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 20 and Level <= 22 then
			Mobs_ID = { 3426, 3245, 3241, 3256, 4129, 3240, 3247, 3463, 3260, 3258 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2173,-2002,93},
			{-2191,-1832,94},
			{-2118,-2085,94}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 23 and Level <= 24 then
			Mobs_ID = { 3466, 3239, 3424, 3473 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2392,-2285,91},
			{-2494,-2399,91},
			{-2654,-2285,92},
			{-2610,-2075,92.66}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 25 and Level <= 27 then
			Mobs_ID = { 3434, 3238, 4128, 5832, 3472, 3249, 3436 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-3442,-1842,91},
			{-3545,-1892,91},
			{-3605,-1941,92},
			{-3734,-1953,92.66},
			{-3819,-2099,92},
			{-3863,-2183,94},
			{-3760,-2282,91},
			{-3670,-2144,93}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 28 and Level <= 32 then
			Mobs_ID = { 3818,3825,6073,6115,3821 }
			Mobs_MapID = 1440
			Mobs_Coord =
			{
			{2205.12,-2463.99,87.07},
			{2255.34,-2356.56,107.62},
			{2188.43,-2285.27,97.63},
			{2117.33,-2296.49,98.95},
			{2038.18,-2271.62,107.59},
			{1963.97,-2300.43,90.94},
			{1960.28,-2132.68,99.25},
			}
			Merchant_Name = Check_Client("布克拉姆","Burkrum")
			Merchant_Coord = {mapid = 1440, x = 2354, y = -2540, z = 102}
			Mail_Coord = {mapid = 1440, x = 2331.42, y = -2545.12, z = 101.56}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 33 and Level <= 35 then
			Mobs_ID = {683,681,1150,1108,736,682}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-11921.67,-206.48,14.11},{-11827.11,-237.52,16.64},{-11706.57,-211.00,39.56},{-11659.87,-129.09,17.05},{-11676.74,-39.60,14.91},{-11659.38,37.11,17.99},{-11590.73,98.33,17.43},{-11548.94,186.79,16.98},{-11539.45,306.53,38.86},{-11633.14,351.85,45.16},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = {686,1152,1114,1096,4260}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12219.51,143.34,16.55},{-12264.71,76.40,15.50},{-12293.90,-24.07,25.23},{-12271.32,-123.74,21.20},{-12234.86,-228.29,17.58},{-12369.33,-229.49,17.91},{-12348.36,-413.52,15.96},{-12288.82,-477.07,15.71},{-12161.00,-599.17,15.06},{-12098.60,-647.25,16.20},{-12052.10,-717.86,17.02},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 41 and Level <= 45 then
			Mobs_ID = {690,772,687}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12961.03,-116.54,13.02},{-12900.36,-76.99,8.46},{-12855.35,-20.89,15.53},{-12840.28,29.51,12.81},{-12807.55,110.51,15.75},{-13053.72,341.05,19.80},{-13189.97,436.13,11.82},{-13286.68,508.89,3.59},{-13367.79,610.84,8.92},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 46 and Level <= 48 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 49 and Level <= 51 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 6512, 9167, 6559, 9164 }
			Mobs_MapID = 1449
			Mobs_Coord =
			{
			{ -6456.568359375, -891.36578369141, -274.83392333984 },
			{ -6540.1196289063, -701.29125976563, -268.04959106445 },
			{ -6712.9560546875, -600.27264404297, -270.72622680664 },
			{ -6826.2578125, -500.36874389648, -273.47332763672 },
			{ -6933.748046875, -496.25326538086, -273.27359008789 }
			}
			Merchant_Name = Check_Client("吉波尔特","Gibbert")
			Merchant_Coord = {mapid = 1449, x = -6144, y = -1098, z = -202}
			Mail_Coord = {mapid = 1449, x = -6174, y = -1078, z = -202}

			Ammo_Vendor_Name = Check_Client("奈尔加","Nergal")
			Ammo_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			Food_Vendor_Name = Check_Client("奈尔加","Nergal")
			Food_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			
			
		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("布克拉姆","Burkrum")
			Ammo_Vendor_Coord = {mapid = 1440, x = 2355, y = -2540, z = 102}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

			
			
		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = {16879,19434}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-8.51,2304.82,73.57},{56.79,2351.78,65.70},{158.26,2477.52,58.19},{282.43,2496.49,105.31},{317.64,2372.79,83.33},
			}
			Merchant_Name = Check_Client("雷甘·曼库索","Reagan Mancuso")
			Merchant_Coord = {mapid = 1944, x = 179.78, y = 2605.40, z = 87.28}
			Mail_Coord = {mapid = 1944, x = 172.3, y = 2623.74, z = 87.09}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			
			
		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
			Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			
			
		end
	elseif Race == "Scourge" then
	    if Level < 10 then
			if Class == "WARRIOR" then
				Trainer_Name = Check_Client("奥斯蒂尔·德·蒙","Austil de Mon")
				Trainer_Coord = {mapid = 1420, x = 2254, y = 238, z = 33}
			elseif Class == "ROGUE" then
				Trainer_Name = Check_Client("马里恩·考尔","Marion Call")
				Trainer_Coord = {mapid = 1420, x = 2271, y = 243, z = 41}
			elseif Class == "WARLOCK" then
				Trainer_Name = Check_Client("鲁伯特·鲍什","Rupert Boch")
				Trainer_Coord = {mapid = 1420, x = 2259, y = 250, z = 41}
			elseif Class == "PRIEST" then
				Trainer_Name = Check_Client("黑暗牧师贝里尔","Dark Cleric Beryl")
				Trainer_Coord = {mapid = 1420, x = 2265, y = 251, z = 41}
			elseif Class == "MAGE" then
				Trainer_Name = Check_Client("凯恩·火歌","Cain Firesong")
				Trainer_Coord = {mapid = 1420, x = 2256, y = 233, z = 41}
			end
		else
		    if Class == "HUNTER" then
				Trainer_Name = Check_Client("索塔尔","Thotar")
				Trainer_Coord = {mapid = 1411, x = 275, y = -4704, z = 11}
			elseif Class == "WARRIOR" then
				Trainer_Name = Check_Client("塔绍尔·锯痕","Tarshaw Jaggedscar")
				Trainer_Coord = {mapid = 1411, x = 311, y = -4827, z = 9.58}
			elseif Class == "ROGUE" then
				Trainer_Name = Check_Client("卡普拉克","Kaplak")
				Trainer_Coord = {mapid = 1411, x = 268, y = -4710, z = 17.49}
			elseif Class == "WARLOCK" then
				Trainer_Name = Check_Client("杜格鲁·血怒","Dhugru Gorelust")
				Trainer_Coord = {mapid = 1411, x = 356, y = -4837, z = 11}
			elseif Class == "PRIEST" then
				Trainer_Name = Check_Client("泰金","Tai'jin")
				Trainer_Coord = {mapid = 1411, x = 294, y = -4831, z = 11}
			elseif Class == "MAGE" then
				Trainer_Name = Check_Client("安苏瓦","Un'Thuwa")
				Trainer_Coord = {mapid = 1411, x = -839, y = -4939, z = 21}
			elseif Class == "SHAMAN" then
				Trainer_Name = Check_Client("斯瓦特","Swart")
				Trainer_Coord = {mapid = 1411, x = 307, y = -4839, z = 11}
			end
		end

		if Level >= 1 and Level <= 3 then
			Mobs_ID = { 1501,1508,1502,1890,1512 }
			Mobs_MapID = 1420
			Mobs_Coord =
			{
			{1916,1593,84},
			{2003,1561,78},
			{2103,1590,75}
			}

			Merchant_Name = Check_Client("铁匠兰德","Blacksmith Rand")
			Merchant_Coord = {mapid = 1420, x = 1842, y = 1570, z = 96}
			Mail_Coord = {mapid = 1420, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Ammo_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			Food_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Food_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			
			
		elseif Level >= 4 and Level <= 5 then
			Mobs_ID = { 1501,1508,1502,1890,1512,1509,1513 }
			Mobs_MapID = 1420
			Mobs_Coord =
			{
			{2072,1421,62},
			{1995,1373,62}
			}

			Merchant_Name = Check_Client("铁匠兰德","Blacksmith Rand")
			Merchant_Coord = {mapid = 1420, x = 1842, y = 1570, z = 96}
			Mail_Coord = {mapid = 1420, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Ammo_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			Food_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Food_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			
			
		elseif Level >= 6 and Level <= 9 then
			Mobs_ID = { 1547,1553,1935,1934,1535 }
			Mobs_MapID = 1420
			Mobs_Coord =
			{
			{2165,1208,42},
			{2300,1335,33},
			{2421,1330,31},
			{2506,1216,58}
			}

			Merchant_Name = Check_Client("铁匠兰德","Blacksmith Rand")
			Merchant_Coord = {mapid = 1420, x = 1842, y = 1570, z = 96}
			Mail_Coord = {mapid = 1420, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Ammo_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			Food_Vendor_Name = Check_Client("乔舒·基恩","Joshua Kien")
			Food_Vendor_Coord = {mapid = 1420, x = 1866, y = 1574, z = 94}

			
			
		elseif Level >= 10 and Level <= 11 then
			Mobs_ID = { 3123, 3100, 3127 }
			Mobs_MapID = 1411
			Mobs_Coord =
			{
			{ 1290.7847900391, -4765.2451171875, 19.493337631226 },   
			{ 1229.0876464844, -4917.1831054688, 11.688507080078 },
			{ 1410.9993896484, -4852.7685546875, 15.389236450195 }
			}
			Black_Spot = {}
			Merchant_Name = Check_Client("格劳特","Ghrawt")
			Merchant_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}
			Mail_Coord = {mapid = 1411, x = 322, y = -4706, z = 14}

			Ammo_Vendor_Name = Check_Client("格劳特","Ghrawt")
			Ammo_Vendor_Coord = {mapid = 1411, x = 362, y = -4763, z = 12}

			Food_Vendor_Name = Check_Client("旅店老板格罗斯克","Innkeeper Grosk")
			Food_Vendor_Coord = {mapid = 1411, x = 340, y = -4686, z = 16}

			
			
		elseif Level >= 12 and Level <= 15 then
			Mobs_ID = { Check_Client("钢鬃寻水者","Razormane Water Seeker"), Check_Client("钢鬃织棘者","Razormane Thornweaver"), Check_Client("钢鬃猎手","Razormane Hunter"), Check_Client("长鬃草原狮","Savannah Highmane"), Check_Client("赤鳞鞭尾龙","Sunscale Lashtail"), Check_Client("巨型平原陆行鸟","Greater Plainstrider")}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-151.342651,  -2714.420654, 91.667053},
            {-130.659622,  -2745.893066, 92.971779},
            {-108.888397,  -2771.359619, 93.383476},
            {-85.764336,  -2794.625977, 94.818245},
            {-60.362385,  -2818.897949, 92.771545},
            {-42.944874,  -2843.637939, 91.674232},
            {-31.619328,  -2874.473633, 91.666748},
            {-51.143387,  -2910.022949, 92.668396},
            {-73.539230,  -2928.188477, 94.040024},
            {-98.831116,  -2944.085205, 92.362045},
            {-126.733582,  -2944.553955, 91.667641},
            {-156.696579,  -2909.666016, 93.204819},
            {-151.342651,  -2714.420654, 91.667053}
			}
			Black_Spot = {}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 16 and Level <= 19 then
			Mobs_ID = { 
			Check_Client("草原幼狮","Savannah Cub"),
			Check_Client("冲锋斑马","Zhevra Charger"),
			Check_Client("草原狮后","Savannah Matriarch"),
			Check_Client("暴躁的平原陆行鸟","Ornery Plainstrider"),
			Check_Client("赤鳞镰爪龙","Sunscale Scytheclaw"),
			Check_Client("赤鳞尖啸龙","Sunscale Screecher"),
			Check_Client("草原狮王","Savannah Patriarch"),
			Check_Client("长颈鹿","Barrens Giraffe"),
			Check_Client("草原徘徊者","Savannah Prowler"),
			Check_Client("乱齿土狼","Hecklefang Hyena"),
			}
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-837,-3278,94},
			{-702,-3405,91},
			{-607,-3516,93},
			{-495,-3528,92},
			{-451,-3401,92},
			{-673,-3296,96},
			}
			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 20 and Level <= 22 then
			Mobs_ID = { 3426, 3245, 3241, 3256, 4129, 3240, 3247, 3463, 3260, 3258 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2173,-2002,93},
			{-2191,-1832,94},
			{-2118,-2085,94}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 23 and Level <= 24 then
			Mobs_ID = { 3466, 3239, 3424, 3473 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-2392,-2285,91},
			{-2494,-2399,91},
			{-2654,-2285,92},
			{-2610,-2075,92.66}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 25 and Level <= 27 then
			Mobs_ID = { 3434, 3238, 4128, 5832, 3472, 3249, 3436 }
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-3442,-1842,91},
			{-3545,-1892,91},
			{-3605,-1941,92},
			{-3734,-1953,92.66},
			{-3819,-2099,92},
			{-3863,-2183,94},
			{-3760,-2282,91},
			{-3670,-2144,93}
			}
			Merchant_Name = Check_Client("萨努耶·符文图腾","Sanuye Runetotem")
			Merchant_Coord = {mapid = 1413, x = -2374, y = -1948, z = 96.09}
			Mail_Coord = {mapid = 1413, x = -2352, y = -1945, z = 96.04}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板比鲁拉","Innkeeper Byula")
			Food_Vendor_Coord = {mapid = 1413, x = -2376, y = -1995, z = 96.71}

			
			
		elseif Level >= 28 and Level <= 32 then
			Mobs_ID = { 3818,3825,6073,6115,3821 }
			Mobs_MapID = 1440
			Mobs_Coord =
			{
			{2205.12,-2463.99,87.07},
			{2255.34,-2356.56,107.62},
			{2188.43,-2285.27,97.63},
			{2117.33,-2296.49,98.95},
			{2038.18,-2271.62,107.59},
			{1963.97,-2300.43,90.94},
			{1960.28,-2132.68,99.25},
			}
			Merchant_Name = Check_Client("布克拉姆","Burkrum")
			Merchant_Coord = {mapid = 1440, x = 2354, y = -2540, z = 102}
			Mail_Coord = {mapid = 1440, x = 2331.42, y = -2545.12, z = 101.56}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			
			
		elseif Level >= 33 and Level <= 35 then
			Mobs_ID = {683,681,1150,1108,736,682}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-11921.67,-206.48,14.11},{-11827.11,-237.52,16.64},{-11706.57,-211.00,39.56},{-11659.87,-129.09,17.05},{-11676.74,-39.60,14.91},{-11659.38,37.11,17.99},{-11590.73,98.33,17.43},{-11548.94,186.79,16.98},{-11539.45,306.53,38.86},{-11633.14,351.85,45.16},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = {686,1152,1114,1096,4260}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12219.51,143.34,16.55},{-12264.71,76.40,15.50},{-12293.90,-24.07,25.23},{-12271.32,-123.74,21.20},{-12234.86,-228.29,17.58},{-12369.33,-229.49,17.91},{-12348.36,-413.52,15.96},{-12288.82,-477.07,15.71},{-12161.00,-599.17,15.06},{-12098.60,-647.25,16.20},{-12052.10,-717.86,17.02},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 41 and Level <= 45 then
			Mobs_ID = {690,772,687}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12961.03,-116.54,13.02},{-12900.36,-76.99,8.46},{-12855.35,-20.89,15.53},{-12840.28,29.51,12.81},{-12807.55,110.51,15.75},{-13053.72,341.05,19.80},{-13189.97,436.13,11.82},{-13286.68,508.89,3.59},{-13367.79,610.84,8.92},
			}
			Merchant_Name = Check_Client("维哈尔","Vharr")
			Merchant_Coord = {mapid = 1434, x = -12357, y = 155, z = 4}
			Mail_Coord = {mapid = 1434, x = -12388, y = 145, z = 2.6}

			Ammo_Vendor_Name = Check_Client("尤索克","Uthok")
			Ammo_Vendor_Coord = {mapid = 1434, x = -12357, y = 207, z = 4}

			Food_Vendor_Name = Check_Client("纳加特","Nargatt")
			Food_Vendor_Coord = {mapid = 1434, x = -12414, y = 166, z = 3}

			
			
		elseif Level >= 46 and Level <= 48 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 49 and Level <= 51 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 6512, 9167, 6559, 9164 }
			Mobs_MapID = 1449
			Mobs_Coord =
			{
			{ -6456.568359375, -891.36578369141, -274.83392333984 },
			{ -6540.1196289063, -701.29125976563, -268.04959106445 },
			{ -6712.9560546875, -600.27264404297, -270.72622680664 },
			{ -6826.2578125, -500.36874389648, -273.47332763672 },
			{ -6933.748046875, -496.25326538086, -273.27359008789 }
			}
			Merchant_Name = Check_Client("吉波尔特","Gibbert")
			Merchant_Coord = {mapid = 1449, x = -6144, y = -1098, z = -202}
			Mail_Coord = {mapid = 1449, x = -6174, y = -1078, z = -202}

			Ammo_Vendor_Name = Check_Client("奈尔加","Nergal")
			Ammo_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			Food_Vendor_Name = Check_Client("奈尔加","Nergal")
			Food_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			
			
		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("布克拉姆","Burkrum")
			Ammo_Vendor_Coord = {mapid = 1440, x = 2355, y = -2540, z = 102}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

			
			
		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = {16879,19434}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-8.51,2304.82,73.57},{56.79,2351.78,65.70},{158.26,2477.52,58.19},{282.43,2496.49,105.31},{317.64,2372.79,83.33},
			}
			Merchant_Name = Check_Client("雷甘·曼库索","Reagan Mancuso")
			Merchant_Coord = {mapid = 1944, x = 179.78, y = 2605.40, z = 87.28}
			Mail_Coord = {mapid = 1944, x = 172.3, y = 2623.74, z = 87.09}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			
			
		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
			Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			
			
		end
    elseif Race == "Gnome" or Race == "Dwarf" then
	    if Class == "HUNTER" then
			Trainer_Name = Check_Client("格瑞夫","Grif Wildheart")
			Trainer_Coord = {mapid = 1426, x = -5618, y = -454, z = 407}
		elseif Class == "WARRIOR" then
			Trainer_Name = Check_Client("格兰尼斯·快斧","Granis Swiftaxe")
			Trainer_Coord = {mapid = 1426, x = -5605, y = -530, z = 399}
		elseif Class == "ROGUE" then
			Trainer_Name = Check_Client("霍格拉尔·巴坎","Hogral Bakkan")
			Trainer_Coord = {mapid = 1426, x = -5604, y = -540, z = 399}
		elseif Class == "WARLOCK" then
			Trainer_Name = Check_Client("吉姆瑞兹·黑轮","Gimrizz Shadowcog")
			Trainer_Coord = {mapid = 1426, x = -5640, y = -528, z = 404}
		elseif Class == "PRIEST" then
			Trainer_Name = Check_Client("马克萨恩·安沃尔","Maxan Anvol")
			Trainer_Coord = {mapid = 1426, x = -5590, y = -529, z = 399}
		elseif Class == "MAGE" then
			Trainer_Name = Check_Client("玛济斯·石衣","Magis Sparkmantle")
			Trainer_Coord = {mapid = 1426, x = -5586, y = -537, z = 403}
		elseif Class == "PALADIN" then
			Trainer_Name = Check_Client("阿扎尔·战锤","Azar Stronghammer")
			Trainer_Coord = {mapid = 1426, x = -5586, y = -542, z = 403}
		end

		if Level >= 1 and Level <= 2 then
			Mobs_ID = { 705,724,707 }
			Mobs_MapID = 1426
			Mobs_Coord =
			{
			{ -6282.015625, 383.44763183594, 381.86318969727 },
			{ -6385.2036132813, 384.4162902832, 380.50671386719 },
			{ -6311.30859375, 278.41387939453, 380.18960571289 }
			}

			Merchant_Name = Check_Client("雷布莱德·寒椅","Rybrad Coldbank")
			Merchant_Coord = {mapid = 1426, x = -6101, y = 390, z = 395}
			Mail_Coord = {mapid = 1426, x = -6104, y = 384, z = 395}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1426, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Ammo_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			Food_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Food_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			
			
		elseif Level >= 3 and Level <= 4 then
			Mobs_ID = { 708 }
			Mobs_MapID = 1426
			Mobs_Coord =
			{
			{ -6175.1259765625, 518.62292480469, 386.59783935547 },
			{ -6189.462890625, 683.94036865234, 386.97052001953 },
			{ -6256.185546875, 770.64996337891, 386.19329833984 },
			{ -6301.0600585938, 793.66735839844, 390.35296630859 }
			}
			Merchant_Name = Check_Client("雷布莱德·寒椅","Rybrad Coldbank")
			Merchant_Coord = {mapid = 1426, x = -6101, y = 390, z = 395}
			Mail_Coord = {mapid = 1426, x = -6104, y = 384, z = 395}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1426, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Ammo_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			Food_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Food_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			
			
		elseif Level >= 5 and Level <= 6 then
			Mobs_ID = { 708,706 }
			Mobs_MapID = 1426
			Mobs_Coord =
			{
			{ -6175.1259765625, 518.62292480469, 386.59783935547 },
			{ -6189.462890625, 683.94036865234, 386.97052001953 },
			{ -6256.185546875, 770.64996337891, 386.19329833984 },
			{ -6301.0600585938, 793.66735839844, 390.35296630859 },
			{ -6387.6435546875, 739.50677490234, 386.65362548828 },
			{ -6465.7685546875, 503.1923828125, 386.47924804688 }
			}
			Merchant_Name = Check_Client("雷布莱德·寒椅","Rybrad Coldbank")
			Merchant_Coord = {mapid = 1426, x = -6101, y = 390, z = 395}
			Mail_Coord = {mapid = 1426, x = -6104, y = 384, z = 395}

			Ammo_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Ammo_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			Food_Vendor_Name = Check_Client("艾德林·怒流","Adlin Pridedrift")
			Food_Vendor_Coord = {mapid = 1426, x = -6226, y = 319, z = 383}

			
			
		elseif Level >= 7 and Level <= 9 then
			Mobs_ID = { 1125,1128,1199,1138 }
			Mobs_MapID = 1426
			Mobs_Coord =
			{
			{ -5627.294921875, -349.39163208008, 392.87435913086 },
			{ -5690.6459960938, -367.09774780273, 366.86740112305 },
			{ -5765.603515625, -414.50299072266, 365.17068481445 },
			{ -5803.9033203125, -361.796875, 367.90808105469 },
			{ -5771.1870117188, -261.04193115234, 356.35430908203 }
			}
			Merchant_Name = Check_Client("格劳恩·索姆温","Grawn Thromwyn")
			Merchant_Coord = {mapid = 1426, x = -5590, y = -428, z = 397}
			Mail_Coord = {mapid = 1426, x = -6104, y = 384, z = 395}

			Ammo_Vendor_Name = Check_Client("克雷格·比尔姆","Kreg Bilmn")
			Ammo_Vendor_Coord = {mapid = 1426, x = -5597, y = -521, z = 399}

			Food_Vendor_Name = Check_Client("旅店老板贝尔姆","Innkeeper Belm")
			Food_Vendor_Coord = {mapid = 1426, x = -5601, y = -531, z = 399}

			
			
		elseif Level >= 10 and Level <= 12 then
			Mobs_ID = { 1116,1689,1127 }
			Mobs_MapID = 1426
			Mobs_Coord =
			{
			{-5547.46,-1818.37,399.58},
			{-5657.36,-1824.78,400.19},
			{-5614.98,-1699.21,399.08}
			}
			Black_Spot = {{-5725,-1876,399,30}}

			Merchant_Name = Check_Client("格劳恩·索姆温","Grawn Thromwyn")
			Merchant_Coord = {mapid = 1426, x = -5590, y = -428, z = 397}
			Mail_Coord = {mapid = 1426, x = -6104, y = 384, z = 395}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1426, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("克雷格·比尔姆","Kreg Bilmn")
			Ammo_Vendor_Coord = {mapid = 1426, x = -5597, y = -521, z = 399}

			Food_Vendor_Name = Check_Client("旅店老板贝尔姆","Innkeeper Belm")
			Food_Vendor_Coord = {mapid = 1426, x = -5601, y = -531, z = 399}

			
			
		elseif Level >= 13 and Level <= 16 then
			Mobs_ID = { 1186, 1190, 767 }
			Mobs_MapID = 1432
			Mobs_Coord =
			{
			{ -5158.703125, -2766.265625, 334.38165283203 },
			{ -5070.5307617188, -2801.7626953125, 324.83166503906 },
			{ -4959.23828125, -2750.8061523438, 323.22366333008 },
			{ -4864.3784179688, -2776.408203125, 323.822265625 },
			{ -4772.5361328125, -2819.0407714844, 324.11859130859 },
			{ -4705.861328125, -2807.0783691406, 326.01712036133 },
			{ -5011.1318359375, -2885.3635253906, 337.11917114258 },
			{ -5087.453125, -2946.6513671875, 329.88024902344 },
			{ -5148.0561523438, -2923.5378417969, 328.83578491211 },
			{ -5188.5893554688, -2978.6137695313, 334.97158813477 },
			{ -5192.3002929688, -3043.7145996094, 331.34066772461 }
			}
			Merchant_Name = Check_Client("摩汉·铜喉","Morhan Coppertongue")
			Merchant_Coord = {mapid = 1432, x = -5343, y = -2932, z = 324}
			Mail_Coord = {mapid = 1432, x = -5365, y = -2954, z = 323}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1432, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("雅尼·铁心","Yanni Stoutheart")
			Ammo_Vendor_Coord = {mapid = 1432, x = -5381, y = -2952, z = 322}

			Food_Vendor_Name = Check_Client("旅店老板纳克罗·壁炉","Innkeeper Hearthstove")
			Food_Vendor_Coord = {mapid = 1432, x = -5377, y = -2973, z = 323}

			
			
		elseif Level >= 17 and Level <= 22 then
			Mobs_ID = { 1192, 1189 }
			Mobs_MapID = 1432
			Mobs_Coord =
			{
			{ -5197.9326171875, -4009.4470214844, 332.21124267578 },
			{ -5281.724609375, -4098.7836914063, 327.14566040039 },
			{ -5349.51953125, -4085.0417480469, 332.42248535156 },
			{ -5273.6123046875, -3987.8666992188, 333.29702758789 },
			{ -5215.5068359375, -3927.0051269531, 333.91186523438 },
			{ -5199.7114257813, -3837.8774414063, 324.62564086914 },
			{ -5274.62109375, -3751.4211425781, 307.45272827148 }
			}
			Merchant_Name = Check_Client("摩汉·铜喉","Morhan Coppertongue")
			Merchant_Coord = {mapid = 1432, x = -5343, y = -2932, z = 324}
			Mail_Coord = {mapid = 1432, x = -5365, y = -2954, z = 323}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1432, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("雅尼·铁心","Yanni Stoutheart")
			Ammo_Vendor_Coord = {mapid = 1432, x = -5381, y = -2952, z = 322}

			Food_Vendor_Name = Check_Client("旅店老板纳克罗·壁炉","Innkeeper Hearthstove")
			Food_Vendor_Coord = {mapid = 1432, x = -5377, y = -2973, z = 323}

			
			
        elseif Level >= 23 and Level <= 27 then
			Mobs_ID = { 1021, 1020,}
			Mobs_MapID = 1437
			Mobs_Coord =
			{
			{-3437.41,-1037.15,7.75},
			{-3450.07,-1102.41,6.59},
			{-3434.91,-1210.74,10.55},
			{-3425.74,-1267.92,7.38},
			{-3447.86,-1341.83,9.22},
			{-3440.54,-1443.03,9.15},
			}

			Black_Spot = {{-3485,-1469,9,50}}

			Merchant_Name = Check_Client("艾德温娜·蒙佐尔","Edwina Monzor")
			Merchant_Coord = {mapid = 1437, x = -3755, y = -848, z = 9}
			Mail_Coord = {mapid = 1437, x = -3793, y = -838, z = 9}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1437, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("格鲁哈姆·拉姆杜恩","Gruham Rumdnul")
			Ammo_Vendor_Coord = {mapid = 1437, x = -3745, y = -890, z = 11}

			Food_Vendor_Name = Check_Client("旅店老板赫布瑞克","Innkeeper Helbrek")
			Food_Vendor_Coord = {mapid = 1437, x = -3827, y = -831, z = 10}

			
			
		elseif Level >= 28 and Level <= 30 then
			Mobs_ID = { 1022, 1023, 1025, 1026, 1028 }
			Mobs_MapID = 1437
			Mobs_Coord =
			{
			{ -3393.6496582031, -1825.3525390625, 24.926782608032 },
			{ -3457.9501953125, -1799.5618896484, 25.226417541504 },
			{ -3501.6315917969, -1837.3560791016, 17.618154525757 },
			{ -3516.4716796875, -1801.9805908203, 23.771390914917 },
			{ -3488.4377441406, -1743.2677001953, 24.041215896606 },
			{ -3410.6103515625, -1790.1060791016, 24.253717422485 },
			{ -3390.8405761719, -1846.2995605469, 24.442901611328 }
			}
			Merchant_Name = Check_Client("艾德温娜·蒙佐尔","Edwina Monzor")
			Merchant_Coord = {mapid = 1437, x = -3755, y = -848, z = 9}
			Mail_Coord = {mapid = 1437, x = -3793, y = -838, z = 9}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1437, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("格鲁哈姆·拉姆杜恩","Gruham Rumdnul")
			Ammo_Vendor_Coord = {mapid = 1437, x = -3745, y = -890, z = 11}

			Food_Vendor_Name = Check_Client("旅店老板赫布瑞克","Innkeeper Helbrek")
			Food_Vendor_Coord = {mapid = 1437, x = -3827, y = -831, z = 10}

			
			
		elseif Level >= 30 and Level <= 35 then
			Mobs_ID = { 2578,2559 }
			Mobs_MapID = 1417
			Mobs_Coord =
			{
			{ -1227.8811035156, -2693.1198730469, 46.882392883301 },
			{ -1294.2021484375, -2635.0422363281, 58.812900543213 },
			{ -1338.9913330078, -2580.6257324219, 70.270263671875 },
			{ -1396.9836425781, -2516.9877929688, 71.519706726074 },
			{ -1447.7210693359, -2501.6101074219, 65.338081359863 },
			{ -1395.2674560547, -2413.37109375, 62.19299697876 },
			{ -1314.6290283203, -2405.4895019531, 65.682815551758 },
			{ -1243.6151123047, -2417.2062988281, 52.3327293396 },
			{ -1183.7395019531, -2449.0112304688, 51.653388977051 },
			{ -1146.1866455078, -2505.181640625, 51.764392852783 },
			{ -1153.7667236328, -2588.3718261719, 56.122611999512 },
			{ -1155.2996826172, -2675.3293457031, 53.0198097229 },
			{ -1237.1459960938, -2670.1635742188, 46.546680450439 }
			}
			Merchant_Name = Check_Client("加诺斯·铁心","Jannos Ironwill")
			Merchant_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}
			Mail_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1417, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("特鲁克·蛮鬃","Truk Wildbeard")
			Food_Vendor_Coord = {mapid = 1425, x = 380, y = -2128, z = 121}

			
			
		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = { 2565,2560,2579 }
			Mobs_MapID = 1417
			Mobs_Coord =
			{
			{ -920.15753173828, -2396.0681152344, 51.024871826172 },
			{ -850.89630126953, -2325.2497558594, 57.678855895996 },
			{ -741.65570068359, -2211.1062011719, 54.864974975586 }
			}
			Merchant_Name = Check_Client("加诺斯·铁心","Jannos Ironwill")
			Merchant_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}
			Mail_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1417, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("特鲁克·蛮鬃","Truk Wildbeard")
			Food_Vendor_Coord = {mapid = 1425, x = 380, y = -2128, z = 121}

			
			
		elseif Level >= 41 and Level <= 46 then
			Mobs_ID = { 2923 }
			Mobs_MapID = 1425
			Mobs_Coord =
			{
			{  139.4935,  -2163.1365,  103.2498 },
			{  82.2254,  -2200.5745,  101.2750 },
			{  23.4963,  -2336.5054,  124.0746 },
			{  111.5553,  -2452.8733,  121.8952 },
			{  144.0345,  -2410.9438,  121.2586 },
			{  173.4029,  -2338.6418,  119.0738 },
			{  230.3576,  -2292.9080,  109.2548 },
			{  177.0975,  -2215.1440,  100.7853 }
			}
			Merchant_Name = Check_Client("哈尔甘","Harggan")
			Merchant_Coord = {mapid = 1425, x = 333, y = -2091, z = 131}
			Mail_Coord = {mapid = 1425, x = 293, y = -2115, z = 121}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1425, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("特鲁克·蛮鬃","Truk Wildbeard")
			Food_Vendor_Coord = {mapid = 1425, x = 380, y = -2128, z = 121}

			
			
		elseif Level >= 47 and Level <= 51 then
			Mobs_ID = { 2926,2929 }
			Mobs_MapID = 1425
			Mobs_Coord =
			{
			{ -34.897003173828, -4283.4404296875, 118.0394821167 },
			{ 35.971252441406, -4347.1123046875, 128.21725463867 },
			{ 138.37495422363, -4341.5151367188, 117.37651062012 },
			{ 124.85785675049, -4241.19921875, 122.23017883301 },
			{ 77.723411560059, -4203.419921875, 126.73424530029 },
			{ -10.432680130005, -4090.2548828125, 121.73518371582 },
			{ 302.11837768555, -3939.8693847656, 132.29455566406 },
			{ 250.86175537109, -3767.8215332031, 138.17242431641 },
			{ 138.02377319336, -3690.7199707031, 132.6554107666 }
			}
			Merchant_Name = Check_Client("哈尔甘","Harggan")
			Merchant_Coord = {mapid = 1425, x = 333, y = -2091, z = 131}
			Mail_Coord = {mapid = 1425, x = 293, y = -2115, z = 121}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1425, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("特鲁克·蛮鬃","Truk Wildbeard")
			Food_Vendor_Coord = {mapid = 1425, x = 380, y = -2128, z = 121}

			
			
		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 1783, 1791 }
			Mobs_MapID = 1422
			Mobs_Coord =
			{
			{ 1044.4290771484, -1668.4829101563, 60.869873046875 },
			{ 1087.0151367188, -1742.7958984375, 61.63969039917 },
			{ 1159.2176513672, -1765.2452392578, 60.590740203857 },
			{ 1200.3905029297, -1732.2366943359, 60.508640289307 }
			}
			Merchant_Name = Check_Client("罗伯特·埃比斯彻尔","Robert Aebischer")
			Merchant_Coord = {mapid = 1424, x = -815, y = -572, z = 15}
			Mail_Coord = {mapid = 1424, x = -852, y = -546, z = 10}

			Pet_Food_Vendor_Name = ""
			Pet_Food_Vendor_Coord = {mapid = 1424, x = 0, y = 0, z = 0}

			Ammo_Vendor_Name = Check_Client("莎拉·雷克劳夫特","Sarah Raycroft")
			Ammo_Vendor_Coord = {mapid = 1424, x = -774, y = -505, z = 23}

			Food_Vendor_Name = Check_Client("旅店老板安德森","Innkeeper Anderson")
			Food_Vendor_Coord = {mapid = 1424, x = -857, y = -570, z = 11}

			
			
		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("维撒克","Wixxrak")
			Ammo_Vendor_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

			
			
		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = { 16972, 16907, 16879}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-1016.08,2424.03,11.16},
			{-921.98,2336.54,-5.15},
			{-824.54,2212.60,7.23},
			{-751.06,2207.63,13.05},
			{-624.35,2208.46,48.00},
			{-649.94,2098.04,50.35},
			{-710.60,2004.60,45.81}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		end
	elseif Race == "Human" then
	    if Class == "HUNTER" then
			Trainer_Name = Check_Client("格瑞夫","Grif Wildheart")
			Trainer_Coord = {mapid = 1426, x = -5618, y = -454, z = 407}
		elseif Class == "WARRIOR" then
			Trainer_Name = Check_Client("里瑞亚·杜拉克","Lyria Du Lac")
			Trainer_Coord = {mapid = 1429, x = -9461, y = 109, z = 57}
		elseif Class == "ROGUE" then
			Trainer_Name = Check_Client("科瑞恩·塞尔留斯","Keryn Sylvius")
			Trainer_Coord = {mapid = 1429, x = -9465, y = 12, z = 63}
		elseif Class == "WARLOCK" then
			Trainer_Name = Check_Client("玛克西米利安·克洛文","Maximillian Crowe")
			Trainer_Coord = {mapid = 1429, x = -9472, y = -5, z = 49}
		elseif Class == "PRIEST" then
			Trainer_Name = Check_Client("女牧师洁塞塔","Priestess Josetta")
			Trainer_Coord = {mapid = 1429, x = -9460, y = 33, z = 63}
		elseif Class == "MAGE" then
			Trainer_Name = Check_Client("扎尔迪玛·维夫希尔特","Zaldimar Wefhellt")
			Trainer_Coord = {mapid = 1429, x = -9471, y = 34, z = 63}
		elseif Class == "PALADIN" then
			Trainer_Name = Check_Client("威尔海姆修士","Brother Wilhelm")
			Trainer_Coord = {mapid = 1429, x = -9468, y = 108, z = 57}
		end

		if Level >= 1 and Level <= 4 then
			Mobs_ID = { 299, 6 }
			Mobs_MapID = 1429
			Mobs_Coord =
			{
			{ -8887.2587890625, -71.955154418945, 85.034568786621 },
            { -8770.15625, -100.92608642578, 87.387283325195 }
			}

			Merchant_Name = Check_Client("高德瑞克·洛斯迦","Godric Rothgar")
			Merchant_Coord = {mapid = 1429, x = -8898, y = -119, z = 81}
			Mail_Coord = {mapid = 1429, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("丹尼尔修士","Brother Danil")
			Ammo_Vendor_Coord = {mapid = 1429, x = -8901, y = -112, z = 81}

			Food_Vendor_Name = Check_Client("丹尼尔修士","Brother Danil")
			Food_Vendor_Coord = {mapid = 1429, x = -8901, y = -112, z = 81}

			
			
		elseif Level >= 5 and Level <= 6 then
			Mobs_ID = { 38 }
			Mobs_MapID = 1429
			Mobs_Coord =
			{
			{ -9050.1474609375, -341.41525268555, 73.453102111816 },
            { -8975.1142578125, -342.28173828125, 73.478393554688 }
			}
			Merchant_Name = Check_Client("高德瑞克·洛斯迦","Godric Rothgar")
			Merchant_Coord = {mapid = 1429, x = -8898, y = -119, z = 81}
			Mail_Coord = {mapid = 1429, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("丹尼尔修士","Brother Danil")
			Ammo_Vendor_Coord = {mapid = 1429, x = -8901, y = -112, z = 81}

			Food_Vendor_Name = Check_Client("丹尼尔修士","Brother Danil")
			Food_Vendor_Coord = {mapid = 1429, x = -8901, y = -112, z = 81}

			
			
		elseif Level >= 7 and Level <= 11 then
			Mobs_ID = { 822, 113, 116, 524, 30 }
			Mobs_MapID = 1429
			Mobs_Coord =
			{
			{ -9733.66796875, -24.693840026855, 37.182224273682 },
            { -9857.5576171875, -41.252010345459, 25.96185874939 },
            { -9993.0859375, -19.967067718506, 35.228393554688 },
            { -10035.9765625, 123.68696594238, 31.800380706787 }
			}
			Merchant_Name = Check_Client("科瑞娜·斯蒂利","Corina Steele")
			Merchant_Coord = {mapid = 1429, x = -9464, y = 93, z = 58}
			Mail_Coord = {mapid = 1429, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("布洛葛·哈姆菲斯特","Brog Hamfist")
			Ammo_Vendor_Coord = {mapid = 1429, x = -9465, y = 9, z = 56}

			Food_Vendor_Name = Check_Client("旅店老板法雷","Innkeeper Farley")
			Food_Vendor_Coord = {mapid = 1429, x = -9462, y = 16, z = 56}

			
			
		elseif Level >= 12 and Level <= 13 then
			Mobs_ID = { 481,480,834,199,454 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{-9845.9414,954.6282,29.1435},
			{-9920.3564,1025.2079,37.5110},
			{-9932.0586,1116.8896,35.4391},
			}
			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 14 and Level <= 18 then
			Mobs_ID = { 157, 454, 95, 504, 1109 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{ -10473.965820313, 915.60736083984, 37.949291229248 },
			{ -10351.077148438, 1154.0876464844, 35.538948059082 },
			{ -10390.3203125, 1303.5198974609, 40.831115722656 },
			{ -10443.49609375, 1449.2360839844, 47.786613464355 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 19 and Level <= 21 then
			Mobs_ID = { 154, 547, 122, 115, 573, 449 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{ -10768.84375, 944.79925537109, 40.661457061768 },
			{ -10736.432617188, 805.53497314453, 36.118595123291 },
			{ -10900.829101563, 857.08068847656, 33.78987121582 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 22 and Level <= 24 then
			Mobs_ID = { 539, 565, 217, 569, 213 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10971.568359375, 462.83367919922, 41.352508544922 },
			{ -10889.151367188, 517.72222900391, 34.809421539307 },
			{ -10713.182617188, 537.60699462891, 34.278942108154 },
			{ -10577.893554688, 561.21807861328, 32.040554046631 },
			{ -10476.579101563, 594.99572753906, 26.153076171875 }
			}

			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 25 and Level <= 27 then
			Mobs_ID = { 930 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10641.6171875, -47.907432556152, 30.729801177979 },
			{ -10580.059570313, -25.166402816772, 38.282318115234 },
			{ -10529.778320313, -47.534629821777, 44.159851074219 },
			{ -10480.03515625, -30.929027557373, 49.302352905273 },
			{ -10422.744140625, -48.635917663574, 46.46004486084 },
			{ -10370.0546875, -30.689149856567, 47.451221466064 },
			{ -10332.063476563, -43.858402252197, 42.952816009521 },
			{ -10289.361328125, -83.647644042969, 44.188137054443 },
			}

			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 28 and Level <= 30 then
			Mobs_ID = { 628, 1258, 923, 889, 891 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10812.376953125, -635.34436035156, 40.303768157959 },
			{ -10821.747070313, -530.84869384766, 39.760833740234 },
			{ -11002.163085938, -224.66459655762, 14.063296318054 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 30 and Level <= 35 then
			Mobs_ID = { 683,681,1150 }
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{ -11615.685546875, -359.75622558594, 20.864900588989 },
			{ -11599.58984375, -441.0803527832, 14.185316085815 },
			{ -11638.529296875, -507.44320678711, 19.320255279541 },
			{ -11689, -503.58444213867, 19.531423568726 },
			{ -11739.643554688, -484.67538452148, 17.094821929932 },
			{ -11765.278320313, -404.92068481445, 16.620769500732 },
			{ -11715.068359375, -399.69976806641, 19.627069473267 },
			{ -11663.743164063, -377.13031005859, 15.833731651306 },
			{ -11564.2890625, 170.98567199707, 17.209957122803 },
			{ -11626.194335938, 109.48350524902, 16.398012161255 },
			{ -11668.440429688, 33.36243057251, 15.955871582031 },
			{ -11672.295898438, -62.004047393799, 17.111911773682 },
			{ -11622.171875, -382.38363647461, 16.777088165283 },
			{ -11687.310546875, -482.69644165039, 16.000625610352 },
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = {686,1152,1114,1096,4260}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12219.51,143.34,16.55},{-12264.71,76.40,15.50},{-12293.90,-24.07,25.23},{-12271.32,-123.74,21.20},{-12234.86,-228.29,17.58},{-12369.33,-229.49,17.91},{-12348.36,-413.52,15.96},{-12288.82,-477.07,15.71},{-12161.00,-599.17,15.06},{-12098.60,-647.25,16.20},{-12052.10,-717.86,17.02},
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 41 and Level <= 45 then
			Mobs_ID = {690,772,687}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12961.03,-116.54,13.02},{-12900.36,-76.99,8.46},{-12855.35,-20.89,15.53},{-12840.28,29.51,12.81},{-12807.55,110.51,15.75},{-13053.72,341.05,19.80},{-13189.97,436.13,11.82},{-13286.68,508.89,3.59},{-13367.79,610.84,8.92},
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 46 and Level <= 48 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 49 and Level <= 51 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 6512, 9167, 6559, 9164 }
			Mobs_MapID = 1449
			Mobs_Coord =
			{
			{ -6456.568359375, -891.36578369141, -274.83392333984 },
			{ -6540.1196289063, -701.29125976563, -268.04959106445 },
			{ -6712.9560546875, -600.27264404297, -270.72622680664 },
			{ -6826.2578125, -500.36874389648, -273.47332763672 },
			{ -6933.748046875, -496.25326538086, -273.27359008789 }
			}
			Merchant_Name = Check_Client("吉波尔特","Gibbert")
			Merchant_Coord = {mapid = 1449, x = -6144, y = -1098, z = -202}
			Mail_Coord = {mapid = 1449, x = -6174, y = -1078, z = -202}

			Ammo_Vendor_Name = Check_Client("奈尔加","Nergal")
			Ammo_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			Food_Vendor_Name = Check_Client("奈尔加","Nergal")
			Food_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			
			
		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("维撒克","Wixxrak")
			Ammo_Vendor_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

			
			
		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = { 16972, 16907, 16879}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-1016.08,2424.03,11.16},
			{-921.98,2336.54,-5.15},
			{-824.54,2212.60,7.23},
			{-751.06,2207.63,13.05},
			{-624.35,2208.46,48.00},
			{-649.94,2098.04,50.35},
			{-710.60,2004.60,45.81}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		end
	elseif Race == "NightElf" then
	    if Class == "HUNTER" then
			Trainer_Name = Check_Client("格瑞夫","Grif Wildheart")
			Trainer_Coord = {mapid = 1426, x = -5618, y = -454, z = 407}
		elseif Class == "WARRIOR" then
			Trainer_Name = Check_Client("里瑞亚·杜拉克","Lyria Du Lac")
			Trainer_Coord = {mapid = 1429, x = -9461, y = 109, z = 57}
		elseif Class == "ROGUE" then
			Trainer_Name = Check_Client("科瑞恩·塞尔留斯","Keryn Sylvius")
			Trainer_Coord = {mapid = 1429, x = -9465, y = 12, z = 63}
		elseif Class == "WARLOCK" then
			Trainer_Name = Check_Client("玛克西米利安·克洛文","Maximillian Crowe")
			Trainer_Coord = {mapid = 1429, x = -9472, y = -5, z = 49}
		elseif Class == "PRIEST" then
			Trainer_Name = Check_Client("女牧师洁塞塔","Priestess Josetta")
			Trainer_Coord = {mapid = 1429, x = -9460, y = 33, z = 63}
		elseif Class == "MAGE" then
			Trainer_Name = Check_Client("扎尔迪玛·维夫希尔特","Zaldimar Wefhellt")
			Trainer_Coord = {mapid = 1429, x = -9471, y = 34, z = 63}
		elseif Class == "PALADIN" then
			Trainer_Name = Check_Client("威尔海姆修士","Brother Wilhelm")
			Trainer_Coord = {mapid = 1429, x = -9468, y = 108, z = 57}
		elseif Class == "DRUID" then
			Trainer_Name = Check_Client("玛尔德利恩","Maldryn")
			Trainer_Coord = {mapid = 1453, x = -8751, y = 1124, z = 92}
		end

		if Level >= 1 and Level <= 2 then
			Mobs_ID = { 1984,2031 }
			Mobs_MapID = 1438
			Mobs_Coord =
			{
			{ 10312.786132813, 849.58917236328, 1331.0374755859 },
			{ 10291.701171875, 919.39251708984, 1336.5690917969 },
			{ 10393.73828125, 970.37316894531, 1325.6768798828 }, 
			}

			Merchant_Name = Check_Client("奇娜","Keina")
			Merchant_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}
			Mail_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}

			Ammo_Vendor_Name = Check_Client("奇娜","Keina")
			Ammo_Vendor_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}

			Food_Vendor_Name = Check_Client("德林拉尔","Dellylah")
			Food_Vendor_Coord = {mapid = 1438, x = 10450, y = 779, z = 1322}

			
			
		elseif Level >= 3 and Level <= 4 then
			Mobs_ID = { 1989 }
			Mobs_MapID = 1438
			Mobs_Coord =
			{
			{ 10369.564453125, 1006.2192382813, 1334.681640625 },
			{ 10295.2109375, 955.55224609375, 1334.9990234375 }, 
			}

			Merchant_Name = Check_Client("奇娜","Keina")
			Merchant_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}
			Mail_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}

			Ammo_Vendor_Name = Check_Client("奇娜","Keina")
			Ammo_Vendor_Coord = {mapid = 1438, x = 10436, y = 794, z = 1322}

			Food_Vendor_Name = Check_Client("德林拉尔","Dellylah")
			Food_Vendor_Coord = {mapid = 1438, x = 10450, y = 779, z = 1322}

			
			
		elseif Level >= 6 and Level <= 9 then
			Mobs_ID = { 1995,1998,2042 }
			Mobs_MapID = 1438
			Mobs_Coord =
			{
			{ 9776.6904296875, 1064.4427490234, 1297.3250732422 },
			{ 9708.84375, 1127.4400634766, 1275.8333740234 },
			{ 9772.6923828125, 1191.6964111328, 1279.5329589844 },
			{ 9835.6962890625, 1129.4719238281, 1297.134765625 },
			{ 9822.5751953125, 808.88409423828, 1304.3957519531 },
			{ 9778.591796875, 627.28912353516, 1295.7025146484 },
			{ 9723.337890625, 540.21258544922, 1308.0924072266 },
			}
			Merchant_Name = Check_Client("吉娜·羽弓","Jeena Featherbow")
			Merchant_Coord = {mapid = 1438, x = 9821, y = 968, z = 1308}
			Mail_Coord = {mapid = 1438, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("吉娜·羽弓","Jeena Featherbow")
			Ammo_Vendor_Coord = {mapid = 1438, x = 9821, y = 968, z = 1308}

			Food_Vendor_Name = Check_Client("旅店老板凯达米尔","Innkeeper Keldamyr")
			Food_Vendor_Coord = {mapid = 1438, x = -8901, y = -112, z = 81}

			
			
		elseif Level >= 10 and Level <= 13 then
			Mobs_ID = { 481,480,834,199,454 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{-9845.9414,954.6282,29.1435},
			{-9920.3564,1025.2079,37.5110},
			{-9932.0586,1116.8896,35.4391},
			}
			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 14 and Level <= 17 then
			Mobs_ID = { 157, 454, 95, 504, 1109 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{ -10473.965820313, 915.60736083984, 37.949291229248 },
			{ -10351.077148438, 1154.0876464844, 35.538948059082 },
			{ -10390.3203125, 1303.5198974609, 40.831115722656 },
			{ -10443.49609375, 1449.2360839844, 47.786613464355 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 17 and Level <= 21 then
			Mobs_ID = { 154, 547, 122, 115, 573, 449 }
			Mobs_MapID = 1436
			Mobs_Coord =
			{
			{ -10768.84375, 944.79925537109, 40.661457061768 },
			{ -10736.432617188, 805.53497314453, 36.118595123291 },
			{ -10900.829101563, 857.08068847656, 33.78987121582 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 22 and Level <= 24 then
			Mobs_ID = { 539, 565, 217, 569, 213 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10971.568359375, 462.83367919922, 41.352508544922 },
			{ -10889.151367188, 517.72222900391, 34.809421539307 },
			{ -10713.182617188, 537.60699462891, 34.278942108154 },
			{ -10577.893554688, 561.21807861328, 32.040554046631 },
			{ -10476.579101563, 594.99572753906, 26.153076171875 }
			}

			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 25 and Level <= 27 then
			Mobs_ID = { 930 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10641.6171875, -47.907432556152, 30.729801177979 },
			{ -10580.059570313, -25.166402816772, 38.282318115234 },
			{ -10529.778320313, -47.534629821777, 44.159851074219 },
			{ -10480.03515625, -30.929027557373, 49.302352905273 },
			{ -10422.744140625, -48.635917663574, 46.46004486084 },
			{ -10370.0546875, -30.689149856567, 47.451221466064 },
			{ -10332.063476563, -43.858402252197, 42.952816009521 },
			{ -10289.361328125, -83.647644042969, 44.188137054443 },
			}

			Black_Spot = {}

			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 28 and Level <= 30 then
			Mobs_ID = { 628, 1258, 923, 889, 891 }
			Mobs_MapID = 1431
			Mobs_Coord =
			{
			{ -10812.376953125, -635.34436035156, 40.303768157959 },
			{ -10821.747070313, -530.84869384766, 39.760833740234 },
			{ -11002.163085938, -224.66459655762, 14.063296318054 }
			}
			Merchant_Name = Check_Client("威廉·马克葛瑞格","William MacGregor")
			Merchant_Coord = {mapid = 1436, x = -10658, y = 996, z = 32}
			Mail_Coord = {mapid = 1436, x = -10644, y = 1158, z = 33}

			Ammo_Vendor_Name = Check_Client("军需官刘易斯","Quartermaster Lewis")
			Ammo_Vendor_Coord = {mapid = 1436, x = -10500, y = 1021, z = 60}

			Food_Vendor_Name = Check_Client("旅店老板希瑟尔","Innkeeper Heather")
			Food_Vendor_Coord = {mapid = 1436, x = -10653, y = 1166, z = 34}

			
			
		elseif Level >= 30 and Level <= 35 then
			Mobs_ID = { 683,681,1150 }
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{ -11615.685546875, -359.75622558594, 20.864900588989 },
			{ -11599.58984375, -441.0803527832, 14.185316085815 },
			{ -11638.529296875, -507.44320678711, 19.320255279541 },
			{ -11689, -503.58444213867, 19.531423568726 },
			{ -11739.643554688, -484.67538452148, 17.094821929932 },
			{ -11765.278320313, -404.92068481445, 16.620769500732 },
			{ -11715.068359375, -399.69976806641, 19.627069473267 },
			{ -11663.743164063, -377.13031005859, 15.833731651306 },
			{ -11564.2890625, 170.98567199707, 17.209957122803 },
			{ -11626.194335938, 109.48350524902, 16.398012161255 },
			{ -11668.440429688, 33.36243057251, 15.955871582031 },
			{ -11672.295898438, -62.004047393799, 17.111911773682 },
			{ -11622.171875, -382.38363647461, 16.777088165283 },
			{ -11687.310546875, -482.69644165039, 16.000625610352 },
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 36 and Level <= 40 then
			Mobs_ID = {686,1152,1114,1096,4260}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12219.51,143.34,16.55},{-12264.71,76.40,15.50},{-12293.90,-24.07,25.23},{-12271.32,-123.74,21.20},{-12234.86,-228.29,17.58},{-12369.33,-229.49,17.91},{-12348.36,-413.52,15.96},{-12288.82,-477.07,15.71},{-12161.00,-599.17,15.06},{-12098.60,-647.25,16.20},{-12052.10,-717.86,17.02},
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 41 and Level <= 45 then
			Mobs_ID = {690,772,687}
			Mobs_MapID = 1434
			Mobs_Coord =
			{
			{-12961.03,-116.54,13.02},{-12900.36,-76.99,8.46},{-12855.35,-20.89,15.53},{-12840.28,29.51,12.81},{-12807.55,110.51,15.75},{-13053.72,341.05,19.80},{-13189.97,436.13,11.82},{-13286.68,508.89,3.59},{-13367.79,610.84,8.92},
			}
			Merchant_Name = Check_Client("加奎琳娜·德拉米特","Jaquilina Dramet")
			Merchant_Coord = {mapid = 1434, x = -11622, y = -60, z = 10}
			Mail_Coord = {mapid = 1434, x = -10546, y = -1157, z = 27}

			Ammo_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Ammo_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			Food_Vendor_Name = Check_Client("布鲁斯下士","Corporal Bluth")
			Food_Vendor_Coord = {mapid = 1434, x = -11295, y = -201, z = 75}

			
			
		elseif Level >= 46 and Level <= 48 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 49 and Level <= 51 then
			Mobs_ID = { 5426,5419,5429,5420,5423,5424 }
			Mobs_MapID = 1446
			Mobs_Coord =
			{
			{ -7748.3989257813, -3362.7641601563, 56.326625823975 },
			{ -7811.9711914063, -3262.6687011719, 67.665267944336 },
			{ -7983.3393554688, -3183.2963867188, 61.045162200928 },
			{ -8098.8701171875, -3427.5876464844, 35.739597320557 },
			{ -8053.078125, -3656.0051269531, 62.948265075684 }
			}
			Merchant_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Merchant_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}
			Mail_Coord = {mapid = 1446, x = -7154, y = -3829, z = 8}

			Ammo_Vendor_Name = Check_Client("布雷兹里克·巴克舒特","Blizrik Buckshot")
			Ammo_Vendor_Coord = {mapid = 1446, x = -7141, y = -3719, z = 8}

			Food_Vendor_Name = Check_Client("迪尔格·奎克里弗","Dirge Quikcleave")
			Food_Vendor_Coord = {mapid = 1446, x = -7168, y = -3850, z = 8}

			
			
		elseif Level >= 52 and Level <= 57 then
			Mobs_ID = { 6512, 9167, 6559, 9164 }
			Mobs_MapID = 1449
			Mobs_Coord =
			{
			{ -6456.568359375, -891.36578369141, -274.83392333984 },
			{ -6540.1196289063, -701.29125976563, -268.04959106445 },
			{ -6712.9560546875, -600.27264404297, -270.72622680664 },
			{ -6826.2578125, -500.36874389648, -273.47332763672 },
			{ -6933.748046875, -496.25326538086, -273.27359008789 }
			}
			Merchant_Name = Check_Client("吉波尔特","Gibbert")
			Merchant_Coord = {mapid = 1449, x = -6144, y = -1098, z = -202}
			Mail_Coord = {mapid = 1449, x = -6174, y = -1078, z = -202}

			Ammo_Vendor_Name = Check_Client("奈尔加","Nergal")
			Ammo_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			Food_Vendor_Name = Check_Client("奈尔加","Nergal")
			Food_Vendor_Coord = {mapid = 1449, x = -6157, y = -1067, z = -194}

			
			
		elseif Level >= 58 and Level <= 59 then
			Mobs_ID = { 7445,7456,7449,7452 }
			Mobs_MapID = 1452
			Mobs_Coord =
			{
			{5864.03,-4701.91,758.80},{5801.80,-4717.54,763.22},{5680.07,-4661.34,773.86},{5713.33,-4570.40,765.20},{5771.42,-4555.56,765.30},
			}
			Merchant_Name = Check_Client("维撒克","Wixxrak")
			Merchant_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}
			Mail_Coord = {mapid = 1452, x = 6705, y = -4667, z = 721}

			Ammo_Vendor_Name = Check_Client("维撒克","Wixxrak")
			Ammo_Vendor_Coord = {mapid = 1452, x = 6733, y = -4698, z = 721}

			Food_Vendor_Name = Check_Client("旅店老板维兹奇","Innkeeper Vizzie")
			Food_Vendor_Coord = {mapid = 1452, x = 6695, y = -4673, z = 721}

			
			
		elseif Level >= 60 and Level <= 64 then
			Mobs_ID = { 16972, 16907, 16879}
			Mobs_MapID = 1944
			Mobs_Coord =
			{
			{-1016.08,2424.03,11.16},
			{-921.98,2336.54,-5.15},
			{-824.54,2212.60,7.23},
			{-751.06,2207.63,13.05},
			{-624.35,2208.46,48.00},
			{-649.94,2098.04,50.35},
			{-710.60,2004.60,45.81}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		elseif Level >= 65 and Level <= 70 then
			Mobs_ID = { 17131,17132,17159,18062,18334 }
			Mobs_MapID = 1951
			Mobs_Coord =
			{
			{-835.86,8275.30,30.15},
			{-760.86,8272.00,40.07},
			{-858.22,8194.36,29.10},
			{-875.02,8143.31,24.30},
			{-963.85,7962.06,26.02},
			{-927.63,7887.39,34.61},
			{-1007.02,7815.56,29.85},
			{-1131.76,7860.01,15.37},
			{-1035.64,8011.45,18.62}
			}
			Merchant_Name = Check_Client("马库斯·斯卡兰","Markus Scylan")
			Merchant_Coord = {mapid = 1944, x = -707.80, y = 2716.12, z = 94.73}
			Mail_Coord = {mapid = 1944, x = -707.41, y = 2700.37, z = 94.43}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			
			
		end
	end
end

function Vaild_mobs(table,target)
    for i = 1,#table do
	    if table[i] == target then
		    return true
		end
	end
	return false
end
function Vaild_Black(target)
    local x,y,z = awm.ObjectPosition(target)
    for i = 1,#Black_Spot do
	    local distance = awm.GetDistanceBetweenPositions(x,y,z,Black_Spot[i][1],Black_Spot[i][2],Black_Spot[i][3])
	    if distance < Black_Spot[i][4] then
		    return true
		end
	end
	return false
end
function Find_Corpse()
    local body = {}
	local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		local guid = awm.UnitGUID(ThisUnit)

		if awm.ObjectIsPlayer(ThisUnit)
		    and Easy_Data["玩家检测"]
		    and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") 
			and tonumber(Easy_Data["玩家检测距离"])
			and awm.GetDistanceBetweenObjects("player",ThisUnit) <= tonumber(Easy_Data["玩家检测距离"]) then
			    return {}
		end

		if Easy_Data["需要拾取"] and awm.UnitIsLootable(guid) and awm.UnitIsDead(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
		    if Easy_Data["只拾取我击杀"] and Vaild_mobs(Monster_Has_Killed,guid) then
		        body[#body + 1] = ThisUnit
			elseif not Easy_Data["只拾取我击杀"] then
			    body[#body + 1] = ThisUnit
			end
		end
	end
	return body
end
function Find_Mobs(table)
    local Monster = {}
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local id = awm.ObjectId(ThisUnit)
		local name = awm.UnitFullName(ThisUnit)
		local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		local guid = awm.UnitGUID(ThisUnit)

		if awm.ObjectIsPlayer(ThisUnit)
		    and Easy_Data["玩家检测"]
		    and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") 
			and tonumber(Easy_Data["玩家检测距离"])
			and awm.GetDistanceBetweenObjects("player",ThisUnit) <= tonumber(Easy_Data["玩家检测距离"]) then
			    return {}
		end


		if awm.ObjectIsUnit(ThisUnit)
		and not awm.UnitIsDead(ThisUnit)
		and awm.UnitCanAttack("player",ThisUnit)
		and not awm.UnitAffectingCombat(ThisUnit)
		and ((Easy_Data["只击杀无目标怪物"] and not awm.UnitIsTapped(ThisUnit)) or not Easy_Data["只击杀无目标怪物"])
		and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player")
		and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("pet")
		and not Vaild_mobs(Monster_Has_Killed,guid)
		and distance < 100 then
		    for m = 1,#table do
			    if (tonumber(table[m]) ~= nil and id == table[m]) or name == table[m] then
				    Monster[#Monster + 1] = ThisUnit
				end
			end
		end
	end
	return Monster
end
function Find_Items(table)
    local Monster = {}
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local id = awm.ObjectId(ThisUnit)
		local name = awm.UnitFullName(ThisUnit)
		local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)

		if awm.ObjectIsPlayer(ThisUnit)
		    and Easy_Data["玩家检测"]
		    and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player") 
			and tonumber(Easy_Data["玩家检测距离"])
			and awm.GetDistanceBetweenObjects("player",ThisUnit) <= tonumber(Easy_Data["玩家检测距离"]) then
			    return {}
		end

		if distance < 100 then
		    for m = 1,#table do
			    if name == table[m] or (tonumber(table[m]) ~= nil and id == table[m]) then
				    Monster[#Monster + 1] = ThisUnit
				end
			end
		end
	end
	return Monster
end
function Find_Nearest_Mob(info)
    local Monster = nil
	local Far_Distance = 500
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.UnitTarget(ThisUnit)
		local id = awm.ObjectId(ThisUnit)
		local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		local name = awm.UnitFullName(ThisUnit)

		if awm.ObjectIsUnit(ThisUnit) and distance < Far_Distance then
			if (tostring(info) ~= nil and name ~= nil and name == tostring(info)) or (tonumber(info) ~= nil and id == tonumber(info)) then
				Monster = ThisUnit
				Far_Distance = distance
			end
		end
	end
	return Monster
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

function Grinding()
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")

    if Grind.Step == 1 then

	    Note_Head = Check_UI("打野升级","Mobs Leveling Mode")

	    Loot_Timer = false
		Interact_Step = false
		Target_Info.Mob = nil
		Target_Info.GUID = nil
		Black_Timer = false

		if Grind.Move > #Mobs_Coord then
		    Grind.Move = 1
		end
		local Coord = Mobs_Coord[Grind.Move]
		if Coord == nil then
		    Note_Set(Check_UI("巡逻路径无法读取","Grind path is not readable"))
		    return
		end
		local x,y,z = Coord[1],Coord[2],Coord[3]
		if x == nil or y == nil or z == nil then
		    Note_Set(Check_UI("巡逻坐标无法读取","Grind coords are not readable"))
		    return
		end

		local Gather_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if not awm.UnitAffectingCombat("player") then
			if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mobs_MapID,x,y,z)
				return
			end
		else
		    local table = Combat_Scan()
			if table ~= nil and #table > 0 and Gather_Distance <= 200 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance and awm.UnitLevel(table[i]) - awm.UnitLevel("player") <= 3 then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    textout(Check_UI("进入反击阶段","Fight Process"))
				    Grind.Step = 2
					return
				end
			end
			if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mobs_MapID,x,y,z)
				return
			end
		end

		if not Has_Scan then
		    Has_Scan = true
			Scan_Time = GetTime()
			local body = Find_Corpse()
			local Mobs = Find_Mobs(Mobs_ID)
			Note_Set(Check_UI("巡逻点 = "..Grind.Move..", 附近尸体 = "..#body..", 附近怪物 "..#Mobs, "Node = "..Grind.Move..",Lootable Bodys = "..#body..", Killable Mobs = "..#Mobs))
			if body ~= nil and #body > 0 then
				local Far_Distance = 100
				for i = 1,#body do
				    local tarx,tary,tarz = awm.ObjectPosition(body[i])
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,Pz)
					if distance < Far_Distance and not Vaild_Black(body[i]) then
						Far_Distance = distance
						Target_Info.Mob = body[i]
						Target_Info.GUID = awm.UnitGUID(body[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(body[i])
					end
				end
				if Target_Info.Mob ~= nil then
					textout(Check_UI("进入拾取阶段","Loot Process"))
					Grind.Step = 2
					return
				end
			end
			if Mobs ~= nil and #Mobs > 0 then
				local Far_Distance = 200
				for i = 1,#Mobs do
					local Mob_level = awm.UnitLevel(Mobs[i])
					local distance = awm.GetDistanceBetweenObjects("player",Mobs[i])
					if Mob_level - Level <= 5 and distance < Far_Distance and not Vaild_Black(Mobs[i]) then
						Far_Distance = distance
						Target_Info.Mob = Mobs[i]
						Target_Info.GUID = awm.UnitGUID(Mobs[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Mobs[i])
					end
				end
				if Target_Info.Mob ~= nil then
					textout(Check_UI("进入击杀阶段","Kill Process"))
					Grind.Step = 2
					return
				end
			end
		elseif Has_Scan and (GetTime() - Scan_Time) > 0.8 then
		    Has_Scan = false
		end

		if Gather_Distance > 4 then
		    Run(x,y,z)
		else
		    if Easy_Data["随机路径"] and #Mobs_Coord > 2 then
			    local seed = math.random(1,10)
			    if #Grind.Random_Path ~= #Mobs_Coord then
                    for i = 1,#Mobs_Coord do
					    Grind.Random_Path[i] = nil
					end
				end

				if Grind.Random_Path[Grind.Move] == nil then
				    if seed > 5 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				elseif not Grind.Random_Path[Grind.Move] then
				    local seed2 = math.random(2,4)
				    if seed > seed2 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				elseif Grind.Random_Path[Grind.Move] then
				    local seed2 = math.random(6,8)
				    if seed > seed2 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				end
			else
		        Grind.Move = Grind.Move + 1
			end
		end
	end
	if Grind.Step == 2 then
	    Note_Head = Check_UI("打野击杀","Mobs Leveling Kill Mode")
		if Target_Info.objx == nil or Target_Info.objy == nil or Target_Info.objz == nil then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("怪物坐标无法读取, 返回继续巡逻","Target coord memory cannot read"))
			return
		end

		if not Black_Timer then
		    Black_Timer = true
			Black_Time = GetTime()
		else
		    if GetTime() - Black_Time > Easy_Data["最大击杀时间"] then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			    Target_Info.Mob = nil
				Target_Info.GUID = nil
			    Grind.Step = 1
				return
			end
	    end

		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz)

		if distance > 1000 then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
		    return
		end 

		local Target_Recheck = awm.UnitGUID(Target_Info.Mob)
		if Target_Recheck == nil and distance < 80 then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标不存在, 返回继续巡逻","Target not exist, back to mobs find process"))
			return
		elseif Target_Recheck ~= Target_Info.GUID then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标错误, 返回继续巡逻","Target Errors, back to mobs find process"))
			return
		end
		if awm.UnitAffectingCombat("player") then
		    local table = Combat_Scan()

		    if Target_Info.Mob ~= nil
			and awm.ObjectExists(Target_Info.Mob)
			and awm.ObjectIsUnit(Target_Info.Mob)
			and (awm.UnitTarget(Target_Info.Mob) and (awm.UnitTarget(Target_Info.Mob) == awm.UnitGUID("player") or awm.UnitTarget(Target_Info.Mob) == awm.UnitGUID("pet"))) 
			and awm.UnitCanAttack("player",Target_Info.Mob) 
			and not awm.UnitIsDead(Target_Info.Mob) then
			    local text = Check_UI("正在击杀怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				CombatSystem(Target_Info.Mob)
				return
			end
			if table ~= nil and #table > 0 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    local text = Check_UI("正在反击怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				    CombatSystem(Target_Info.Mob)
					return
				end
			end
		end

		if not awm.ObjectExists(Target_Info.Mob) and distance < 80 then
		    Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标消失","Target do not exist"))
			return
		elseif not awm.UnitIsLootable(awm.UnitGUID(Target_Info.Mob)) and awm.UnitIsDead(Target_Info.Mob) then
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

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标无法拾取","Mobs body cannot be looted"))
			return
		elseif not Easy_Data["需要拾取"] and awm.UnitIsLootable(awm.UnitGUID(Target_Info.Mob)) and awm.UnitIsDead(Target_Info.Mob) then
			Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("不执行拾取选项","The loot option is disable"))
			return
		end
		
		if awm.ObjectExists(Target_Info.Mob) then
		    Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
			awm.TargetUnit(Target_Info.Mob)

			local Mob_level = awm.UnitLevel(Target_Info.Mob)
			local Grey_Level = 5 -- 怪物变灰等级

			if Level <= 5 then
			    Grey_Level = 0
			elseif Level >= 6 and Level <= 49 then
			    Grey_Level = Level - math.floor(Level/10) - 5
			elseif Level == 50 then
			    Grey_Level = 40
		    elseif Level >= 51 and Level <= 59 then
			    Grey_Level = Level - 11
			elseif Level >= 60 then
			    Grey_Level = 51
			end

			if Mob_level < Grey_Level then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
				Target_Info.Mob = nil
				Target_Info.GUID = nil
				Grind.Step = 1
				textout(Check_UI("目标等级差 大于"..(Level - Grey_Level).."级 判断没有经验","Target Level difference > "..(Level - Grey_Level)..", no Exp."))
			    return
			end

			if Easy_Data["只击杀无目标怪物"] and awm.UnitIsTapped(Target_Info.Mob) and not awm.UnitIsDead(Target_Info.Mob) then
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

		local Real_distance = awm.GetDistanceBetweenObjects(Target_Info.Mob,"player")

		if Real_distance < 30 then
		    if Mount_useble < GetTime() then
				Mount_useble = GetTime() + 5
			end
		end

		if awm.UnitIsDead(Target_Info.Mob) then
		    if Real_distance > 4 then
			    Loot_Timer = false
				Note_Set("拾取物品中... < 距离 > = "..math.floor(Real_distance),"Looting items... < Distance > = "..math.floor(Real_distance))
				Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
				Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
			    Note_Set("拾取物品中...","Looting items...")
			    Loot_Timer = false
				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.7,function() Interact_Step = false end )
				    awm.InteractUnit(Target_Info.Mob)
				else
				    if LootFrame:IsVisible() then
					    if GetNumLootItems() == 0 then
						    CloseLoot()
							return
						end
						for i = 1,GetNumLootItems() do
							if LootSlotHasItem(i) then
								LootSlot(i)
								ConfirmLootSlot(i)
								if awm.UnitInParty("player") or awm.UnitInRaid("player") then
									SetLootMethod("freeforall")
								end
							end
						end
					end
				end
			end
		else
		    local name = awm.UnitFullName(Target_Info.Mob)
			Note_Set(Check_UI("击杀指定目标, 名字: "..name.." 距离:"..math.floor(Real_distance),"Killing mobs, Target Name = "..name..", Distance = :"..math.floor(Real_distance)))
			CombatSystem(Target_Info.Mob)
		end
	end
end

function Mission_Wrapper()
    -- 巨魔 杜隆塔尔 - 起点
        Mission.Info[4641] = {}
		Mission.Info[4641].Min_Level = 1
		Mission.Info[4641].Max_Level = 6

		Mission.Info[4641].StartNPC = Check_Client("卡尔图克","Kaltunk")
		Mission.Info[4641].Smapid,Mission.Info[4641].Sx,Mission.Info[4641].Sy,Mission.Info[4641].Sz = 1411,-607.43,-4251.33,38.96

		Mission.Info[4641].EndNPC = Check_Client("高内克","Gornek")
		Mission.Info[4641].Emapid,Mission.Info[4641].Ex,Mission.Info[4641].Ey,Mission.Info[4641].Ez = 1411,-600.13,-4186.19,41.09
		Mission.Info[4641].Slot_Choose = 1 -- 选择奖励

	-- 巨魔 杜隆塔尔 - 小试身手
	    Mission.Info[788] = {}
		Mission.Info[788].Min_Level = 1
		Mission.Info[788].Max_Level = 6

		Mission.Info[788].StartNPC = Check_Client("高内克","Gornek")
		Mission.Info[788].Smapid,Mission.Info[788].Sx,Mission.Info[788].Sy,Mission.Info[788].Sz = 1411,-600.13,-4186.19,41.09

		Mission.Info[788].EndNPC = Check_Client("高内克","Gornek")
		Mission.Info[788].Emapid,Mission.Info[788].Ex,Mission.Info[788].Ey,Mission.Info[788].Ez = 1411,-600.13,-4186.19,41.09
		Mission.Info[788].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[788] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {3098}
				Mobs_Coord = 
				{
				{-519.694092, -4298.775879, 37.917625},
				{-491.723083, -4249.230957, 45.543457},
				{-464.349030, -4215.101563, 50.380604},
				{-415.945648, -4199.207520, 51.788055},
				{-387.802368, -4222.821777, 56.626774},
				{-398.345825, -4247.102051, 51.858566},
				{-388.569427, -4288.544434, 48.518810},
				{-380.448425, -4306.330078, 46.965271},
				{-409.674255, -4323.841797, 43.407055},
				{-413.030365, -4357.842285, 41.729374},
				{-388.426575, -4361.907715, 40.750473},
				{-360.216949, -4379.005371, 47.489300},
				{-384.905273, -4385.322754, 41.398190},
				{-413.266846, -4409.466309, 46.071346},
				{-444.058990, -4424.120605, 50.950340},
				{-474.577789, -4447.296875, 50.430824},
				{-516.795349, -4445.188965, 50.811943},
				{-542.943909, -4420.432129, 42.513077},
				{-606.890259, -4410.489746, 43.511787},
				{-618.480835, -4381.139160, 42.567795},
				{-644.363647, -4353.737305, 43.873493},
				{-677.925476, -4316.778320, 46.726414},
				{-519.694092, -4298.775879, 37.917625}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 巨魔 杜隆塔尔 - 工蝎的尾巴
	    Mission.Info[789] = {}
		Mission.Info[789].Min_Level = 1
		Mission.Info[789].Max_Level = 6

		Mission.Info[789].StartNPC = Check_Client("高内克","Gornek")
		Mission.Info[789].Smapid,Mission.Info[789].Sx,Mission.Info[789].Sy,Mission.Info[789].Sz = 1411,-600.13,-4186.19,41.09

		Mission.Info[789].EndNPC = Check_Client("高内克","Gornek")
		Mission.Info[789].Emapid,Mission.Info[789].Ex,Mission.Info[789].Ey,Mission.Info[789].Ez = 1411,-600.13,-4186.19,41.09
		Mission.Info[789].Slot_Choose = 1 -- 选择奖励

		Mission.Info[789].Vaild_Item = Check_Client("工蝎的尾巴","Scorpid Worker Tail")

		Mission.Execute[789] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {3124}
				Mobs_Coord = 
				{
				{-402.724701, -4113.630371, 50.088787},
				{-436.692596, -4127.180664, 51.041859},
				{-444.800201, -4148.026367, 52.253780},
				{-415.510773, -4163.545410, 51.521927},
				{-384.408783, -4159.039063, 52.024765},
				{-360.317413, -4155.986816, 53.288601},
				{-327.490265, -4181.648926, 52.480061},
				{-296.960785, -4202.645996, 51.633297},
				{-275.567230, -4191.733398, 53.003075},
				{-251.358658, -4181.799316, 55.871059},
				{-298.499695, -4140.463867, 54.925049},
				{-333.566101, -4116.399902, 49.612926},
				{-353.156006, -4089.008057, 51.104538},
				{-367.624146, -4056.597900, 51.130741},
				{-388.093445, -4057.100098, 51.656582},
				{-413.378662, -4068.603760, 50.680054},
				{-435.371582, -4088.372070, 49.692841},
				{-441.850250, -4120.831055, 51.016045},
				{-445.306488, -4142.459473, 51.891155},
				{-416.378204, -4125.883789, 50.367718},
				{-402.724701, -4113.630371, 50.088787}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 巨魔 杜隆塔尔 - 邪灵劣魔
	    Mission.Info[792] = {}
		Mission.Info[792].Min_Level = 2
		Mission.Info[792].Max_Level = 6

		Mission.Info[792].StartNPC = Check_Client("祖雷萨","Zureetha Fargaze")
		Mission.Info[792].Smapid,Mission.Info[792].Sx,Mission.Info[792].Sy,Mission.Info[792].Sz = 1411,-629.05,-4228.06,38.15

		Mission.Info[792].EndNPC = Check_Client("祖雷萨","Zureetha Fargaze")
		Mission.Info[792].Emapid,Mission.Info[792].Ex,Mission.Info[792].Ey,Mission.Info[792].Ez = 1411,-629.05,-4228.06,38.15
		Mission.Info[792].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[792] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {3101}
				Mobs_Coord = 
				{
				{-264.232635, -4269.237305, 62.238537},
				{-234.903488, -4293.075684, 63.113583},
				{-224.908783, -4315.424316, 65.284416},
				{-209.933350, -4333.109375, 66.013443},
				{-204.725555, -4352.968750, 65.209236},
				{-211.370255, -4376.195801, 63.641285},
				{-208.991669, -4401.705078, 63.944572},
				{-219.336273, -4422.220703, 63.331226},
				{-254.883698, -4396.174805, 64.286461},
				{-264.138123, -4363.829102, 55.030899},
				{-272.805359, -4334.749512, 61.735893}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 巨魔 杜隆塔尔 - 邪灵劣魔 (术士)
	    Mission.Info[1485] = {}
		Mission.Info[1485].Min_Level = 2
		Mission.Info[1485].Max_Level = 6

		Mission.Info[1485].StartNPC = 5765
		Mission.Info[1485].Smapid,Mission.Info[1485].Sx,Mission.Info[1485].Sy,Mission.Info[1485].Sz = 1411,-623.5496,-4214.3447,38.1351

		Mission.Info[1485].EndNPC = 5765
		Mission.Info[1485].Emapid,Mission.Info[1485].Ex,Mission.Info[1485].Ey,Mission.Info[1485].Ez = 1411,-623.5496,-4214.3447,38.1351
		Mission.Info[1485].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[1485] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {3101}
				Mobs_Coord = 
				{
				{-264.232635, -4269.237305, 62.238537},
				{-234.903488, -4293.075684, 63.113583},
				{-224.908783, -4315.424316, 65.284416},
				{-209.933350, -4333.109375, 66.013443},
				{-204.725555, -4352.968750, 65.209236},
				{-211.370255, -4376.195801, 63.641285},
				{-208.991669, -4401.705078, 63.944572},
				{-219.336273, -4422.220703, 63.331226},
				{-254.883698, -4396.174805, 64.286461},
				{-264.138123, -4363.829102, 55.030899},
				{-272.805359, -4334.749512, 61.735893}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 巨魔 杜隆塔尔 - 戈加尔的清凉果
	    Mission.Info[4402] = {}
		Mission.Info[4402].Min_Level = 1
		Mission.Info[4402].Max_Level = 6

		Mission.Info[4402].StartNPC = Check_Client("戈加尔","Galgar")
		Mission.Info[4402].Smapid,Mission.Info[4402].Sx,Mission.Info[4402].Sy,Mission.Info[4402].Sz = 1411,-561.63,-4221.80,41.59

		Mission.Info[4402].EndNPC = Check_Client("戈加尔","Galgar")
		Mission.Info[4402].Emapid,Mission.Info[4402].Ex,Mission.Info[4402].Ey,Mission.Info[4402].Ez = 1411,-561.63,-4221.80,41.59
		Mission.Info[4402].Slot_Choose = 1 -- 选择奖励

		Mission.Info[4402].Vaild_Item = Check_Client("仙人掌果","Cactus Apple")

		Mission.Execute[4402] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("仙人掌果","Cactus Apple")}
				Mobs_Coord = 
				{
				{-491.236267, -4301.412109, 42.570087},
				{-485.917572, -4291.492188, 43.396664},
				{-479.635590, -4321.195801, 43.930367},
				{-474.869690, -4322.001465, 44.705093},
				{-411.460388, -4272.016602, 45.862667},
				{-403.998047, -4264.323242, 49.371555},
				{-423.275116, -4188.757324, 51.742641},
				{-428.564209, -4188.305176, 50.759312},
				{-423.383240, -4170.302734, 51.693871},
				{-443.293396, -4123.729492, 51.090347},
				{-413.862488, -4059.489014, 52.040764},
				{-408.558533, -4062.983887, 51.631805},
				{-491.236267, -4301.412109, 42.570087}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Gather_Items()
			end 
		end

	-- 巨魔 杜隆塔尔 - 萨克斯
	    Mission.Info[790] = {}
		Mission.Info[790].Min_Level = 1
		Mission.Info[790].Max_Level = 6

		Mission.Info[790].StartNPC = Check_Client("哈纳祖","Hana'zua")
		Mission.Info[790].Smapid,Mission.Info[790].Sx,Mission.Info[790].Sy,Mission.Info[790].Sz = 1411,-397.76,-4108.99,50.20

		Mission.Info[790].EndNPC = Check_Client("哈纳祖","Hana'zua")
		Mission.Info[790].Emapid,Mission.Info[790].Ex,Mission.Info[790].Ey,Mission.Info[790].Ez = 1411,-397.76,-4108.99,50.20
		Mission.Info[790].Slot_Choose = 1 -- 选择奖励

		Mission.Info[790].Vaild_Item = Check_Client("萨科斯的爪子","Sarkoth's Mangled Claw")

		Mission.Execute[790] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {3281}
				Mobs_Coord = 
				{
				{-571.228394, -4124.583496, 73.105110},
				{-566.479492, -4099.980469, 72.695450},
				{-536.229248, -4107.705078, 65.375160},
				{-535.329285, -4108.092773, 65.156685},
				{-526.985535, -4132.420898, 69.656387}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 巨魔 杜隆塔尔 - 萨科斯 2
        Mission.Info[804] = {}
		Mission.Info[804].Min_Level = 1
		Mission.Info[804].Max_Level = 6

		Mission.Info[804].StartNPC = Check_Client("哈纳祖","Hana'zua")
		Mission.Info[804].Smapid,Mission.Info[804].Sx,Mission.Info[804].Sy,Mission.Info[804].Sz = 1411,-397.76,-4108.99,50.20

		Mission.Info[804].EndNPC = Check_Client("高内克","Gornek")
		Mission.Info[804].Emapid,Mission.Info[804].Ex,Mission.Info[804].Ey,Mission.Info[804].Ez = 1411,-600.13,-4186.19,41.09
		Mission.Info[804].Slot_Choose = 1 -- 选择奖励

	-- 巨魔 杜隆塔尔 - 苦工的重担
        Mission.Info[2161] = {}
		Mission.Info[2161].Min_Level = 6
		Mission.Info[2161].Max_Level = 12

		Mission.Info[2161].StartNPC = Check_Client("乌克尔","Ukor")
		Mission.Info[2161].Smapid,Mission.Info[2161].Sx,Mission.Info[2161].Sy,Mission.Info[2161].Sz = 1411,-599.43,-4715.33,35.15

		Mission.Info[2161].EndNPC = Check_Client("旅店老板格罗斯克","Innkeeper Grosk")
		Mission.Info[2161].Emapid,Mission.Info[2161].Ex,Mission.Info[2161].Ey,Mission.Info[2161].Ez = 1411,340.36,-4686.29,16.46
		Mission.Info[2161].Slot_Choose = 1 -- 选择奖励

	-- 巨魔 杜隆塔尔 - 向奥格尼尔报告
        Mission.Info[823] = {}
		Mission.Info[823].Min_Level = 6
		Mission.Info[823].Max_Level = 12

		Mission.Info[823].StartNPC = Check_Client("加德林大师","Master Gadrin")
		Mission.Info[823].Smapid,Mission.Info[823].Sx,Mission.Info[823].Sy,Mission.Info[823].Sz = 1411,-825.43,-4920.33,19.15

		Mission.Info[823].EndNPC = Check_Client("奥戈尼尔·魂痕","Orgnil Soulscar")
		Mission.Info[823].Emapid,Mission.Info[823].Ex,Mission.Info[823].Ey,Mission.Info[823].Ez = 1411,287.27,-4724.88,13.13
		Mission.Info[823].Slot_Choose = 1 -- 选择奖励

	-- 巨魔 杜隆塔尔 - 野猪人的进犯
	    Mission.Info[837] = {}
		Mission.Info[837].Min_Level = 10
		Mission.Info[837].Max_Level = 15

		Mission.Info[837].StartNPC = Check_Client("加索克","Gar'Thok")
		Mission.Info[837].Smapid,Mission.Info[837].Sx,Mission.Info[837].Sy,Mission.Info[837].Sz = 1411,276.19,-4713.10,18.56

		Mission.Info[837].EndNPC = Check_Client("加索克","Gar'Thok")
		Mission.Info[837].Emapid,Mission.Info[837].Ex,Mission.Info[837].Ey,Mission.Info[837].Ez = 1411,276.19,-4713.10,18.56
		Mission.Info[837].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[837] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3111
				Mobs_Coord[#Mobs_Coord + 1] = {142.67, -4463.52, 35.87}
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3112
				Mobs_Coord[#Mobs_Coord + 1] = {100.95, -4292.84, 57.52}
			end
			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3113
				Mobs_Coord[#Mobs_Coord + 1] = {355.85, -4197.09, 26.59}
			end
			if not Mission.Text[4].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3114
				Mobs_Coord[#Mobs_Coord + 1] = {355.85, -4197.09, 26.59}
			end
			Mobs_MapID = 1411
			Black_Spot = {}
			Kill_Mobs()	   
		end

	-- 巨魔 杜隆塔尔 - 沙漠之风
	    Mission.Info[834] = {}
		Mission.Info[834].Min_Level = 8
		Mission.Info[834].Max_Level = 12

		Mission.Info[834].StartNPC = Check_Client("雷兹拉克","Rezlak")
		Mission.Info[834].Smapid,Mission.Info[834].Sx,Mission.Info[834].Sy,Mission.Info[834].Sz = 1411,999.63,-4414.80,14.39

		Mission.Info[834].EndNPC = Check_Client("雷兹拉克","Rezlak")
		Mission.Info[834].Emapid,Mission.Info[834].Ex,Mission.Info[834].Ey,Mission.Info[834].Ez = 1411,999.63,-4414.80,14.39
		Mission.Info[834].Slot_Choose = 1 -- 选择奖励

		Mission.Info[834].Vaild_Item = Check_Client("装满货物的袋子","Sack of Supplies")

		Mission.Execute[834] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("被偷走的补给袋","Stolen Supply Sack")}
				Mobs_Coord = 
				{
				{1032,-4546,16},
				{894,-4632,17},
				{639,-4590,4},
				{621,-4536,9}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				Gather_Items()
			end 
		end

    -- 牛头 莫高雷 - 开始狩猎
	    Mission.Info[747] = {}
		Mission.Info[747].Min_Level = 1
		Mission.Info[747].Max_Level = 11

		Mission.Info[747].StartNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[747].Smapid,Mission.Info[747].Sx,Mission.Info[747].Sy,Mission.Info[747].Sz = 1412,-2912.6958, -257.5399, 52.9409

		Mission.Info[747].EndNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[747].Emapid,Mission.Info[747].Ex,Mission.Info[747].Ey,Mission.Info[747].Ez = 1412,-2912.6958, -257.5399, 52.9409
		Mission.Info[747].Slot_Choose = 1 -- 选择奖励

		Mission.Info[747].Vaild_Item = {Check_Client("平原陆行鸟肉","Plainstrider Meat"),Check_Client("平原陆行鸟的羽毛","Plainstrider Feather")}

		Mission.Execute[747] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
			if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 2955
				Mobs_Coord = {
				{ -3044.568, -424.9129, 42.31211 },
				{ -2965.743, -519.0424, 44.38055 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 2955
				Mobs_Coord = {
			    { -3044.568, -424.9129, 42.31211 },
				{ -2965.743, -519.0424, 44.38055 },
			    }
			end
			Mobs_MapID = 1412
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 牛头 莫高雷 - 一件琐事1
	    Mission.Info[752] = {}
		Mission.Info[752].Min_Level = 1
		Mission.Info[752].Max_Level = 11

		Mission.Info[752].StartNPC = Check_Client("鹰风酋长","Chief Hawkwind")
		Mission.Info[752].Smapid,Mission.Info[752].Sx,Mission.Info[752].Sy,Mission.Info[752].Sz = 1412,-2877.9480, -221.8298, 54.8208

		Mission.Info[752].EndNPC = Check_Client("鹰风酋长的母亲","Greatmother Hawkwind")
		Mission.Info[752].Emapid,Mission.Info[752].Ex,Mission.Info[752].Ey,Mission.Info[752].Ez = 1412,-3052.54, -522.498, 26.93135
		Mission.Info[752].Slot_Choose = 1 -- 选择奖励

	-- 牛头 莫高雷 - 一件琐事2
	    Mission.Info[753] = {}
		Mission.Info[753].Min_Level = 1
		Mission.Info[753].Max_Level = 11

		Mission.Info[753].StartNPC = Check_Client("鹰风酋长的母亲","Greatmother Hawkwind")
		Mission.Info[753].Smapid,Mission.Info[753].Sx,Mission.Info[753].Sy,Mission.Info[753].Sz = 1412,-3052.54, -522.498, 26.93135

		Mission.Info[753].EndNPC = Check_Client("鹰风酋长","Chief Hawkwind")
		Mission.Info[753].Emapid,Mission.Info[753].Ex,Mission.Info[753].Ey,Mission.Info[753].Ez = 1412,-2877.9480, -221.8298, 54.8208
		Mission.Info[753].Slot_Choose = 1 -- 选择奖励

		Mission.Info[753].ValidItem = Check_Client("水罐","Water Pitcher")

		Mission.Execute[753] = function()
			Mobs_ID = {2907}
			Mobs_Coord = 
			{
			{ -3058.43, -529.7466, 26.06688 },
			}
			Mobs_MapID = 1412
			Black_Spot = {}
			Gather_Items()
		end

	-- 牛头 莫高雷 - 继续狩猎
	    Mission.Info[750] = {}
		Mission.Info[750].Min_Level = 1
		Mission.Info[750].Max_Level = 11

		Mission.Info[750].StartNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[750].Smapid,Mission.Info[750].Sx,Mission.Info[750].Sy,Mission.Info[750].Sz = 1412,-2912.6958, -257.5399, 52.9409

		Mission.Info[750].EndNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[750].Emapid,Mission.Info[750].Ex,Mission.Info[750].Ey,Mission.Info[750].Ez = 1412,-2912.6958, -257.5399, 52.9409
		Mission.Info[750].Slot_Choose = 1 -- 选择奖励

		Mission.Info[750].Vaild_Item = Check_Client("山狮皮","Mountain Cougar Pelt")

		Mission.Execute[750] = function()
		    Mobs_ID = {2961}
			Mobs_Coord = {
			{ -3367.766, -182.5303, 70.82774 },
			{ -3379.08, -314.6036, 65.86173 },
			{ -3328.04, -244.9055, 47.44741 },
			}
			
			Mobs_MapID = 1412
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 牛头 莫高雷 - 大地之母仪祭1
	    Mission.Info[755] = {}
		Mission.Info[755].Min_Level = 1
		Mission.Info[755].Max_Level = 11

		Mission.Info[755].StartNPC = Check_Client("鹰风酋长","Chief Hawkwind")
		Mission.Info[755].Smapid,Mission.Info[755].Sx,Mission.Info[755].Sy,Mission.Info[755].Sz = 1412,-2877.9480, -221.8298, 54.8208

		Mission.Info[755].EndNPC = Check_Client("灰舌先知","Seer Graytongue")
		Mission.Info[755].Emapid,Mission.Info[755].Ex,Mission.Info[755].Ey,Mission.Info[755].Ez = 1412,-3430.31, -139.28, 103.0778
		Mission.Info[755].Slot_Choose = 1 -- 选择奖励

	-- 牛头 莫高雷 - 力量仪祭
	    Mission.Info[757] = {}
		Mission.Info[757].Min_Level = 1
		Mission.Info[757].Max_Level = 11

		Mission.Info[757].StartNPC = Check_Client("灰舌先知","Seer Graytongue")
		Mission.Info[757].Smapid,Mission.Info[757].Sx,Mission.Info[757].Sy,Mission.Info[757].Sz = 1412,-3430.31, -139.28, 103.0778

		Mission.Info[757].EndNPC = Check_Client("鹰风酋长","Chief Hawkwind")
		Mission.Info[757].Emapid,Mission.Info[757].Ex,Mission.Info[757].Ey,Mission.Info[757].Ez = 1412,-2877.9480, -221.8298, 54.8208
		Mission.Info[757].Slot_Choose = 1 -- 选择奖励

		Mission.Info[757].Vaild_Item = Check_Client("刺背腰带","Bristleback Belt")

		Mission.Execute[757] = function()
		    Mobs_ID = {2952,2953}
			Mobs_Coord = {
			{ -3045.221, -1044.777, 49.11142 },
			{ -2991.399, -1008.174, 57.05619 },
			{ -3064.722, -1158.837, 66.11977 },
			}
			
			Mobs_MapID = 1412
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 牛头 莫高雷 - 大地之母仪祭2
	    Mission.Info[763] = {}
		Mission.Info[763].Min_Level = 6
		Mission.Info[763].Max_Level = 11

		Mission.Info[763].StartNPC = Check_Client("鹰风酋长","Chief Hawkwind")
		Mission.Info[763].Smapid,Mission.Info[763].Sx,Mission.Info[763].Sy,Mission.Info[763].Sz = 1412,-2877.9480, -221.8298, 54.8208

		Mission.Info[763].EndNPC = Check_Client("贝恩·血蹄","Baine Bloodhoof")
		Mission.Info[763].Emapid,Mission.Info[763].Ex,Mission.Info[763].Ey,Mission.Info[763].Ez = 1412,-2333.54, -393.073, -8.01249
		Mission.Info[763].Slot_Choose = 1 -- 选择奖励

		Mission.Info[763].Vaild_Item = Check_Client("鹰风图腾","Totem of Hawkwind")

	-- 牛头 莫高雷 - 斗猪
	    Mission.Info[780] = {}
		Mission.Info[780].Min_Level = 1
		Mission.Info[780].Max_Level = 11

		Mission.Info[780].StartNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[780].Smapid,Mission.Info[780].Sx,Mission.Info[780].Sy,Mission.Info[780].Sz = 1412,-2912.6958, -257.5399, 52.9409

		Mission.Info[780].EndNPC = Check_Client("格鲁尔·鹰风","Grull Hawkwind")
		Mission.Info[780].Emapid,Mission.Info[780].Ex,Mission.Info[780].Ey,Mission.Info[780].Ez = 1412,-2912.6958, -257.5399, 52.9409
		Mission.Info[780].Slot_Choose = 1 -- 选择奖励

		Mission.Info[780].Vaild_Item = {Check_Client("斗猪头","Battleboar Snout"),Check_Client("斗猪肋排","Battleboar Flank")}

		Mission.Execute[780] = function()
		    Mobs_ID = {2966}
			Mobs_Coord = {
			{ -3079.331, -736.5469, 37.23475 },
			{ -3040.029, -776.1455, 53.34627 },
			{ -3082.498, -802.806, 50.91237 },
			}
			
			Mobs_MapID = 1412
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 牛头 莫高雷 - 未完的任务
	    Mission.Info[363] = {}
		Mission.Info[363].Min_Level = 6
		Mission.Info[363].Max_Level = 11

		Mission.Info[363].StartNPC = Check_Client("安图尔·荒野","Antur Fallow")
		Mission.Info[363].Smapid,Mission.Info[363].Sx,Mission.Info[363].Sy,Mission.Info[363].Sz = 1412,-3066.02, 68.8002, 79.38358

		Mission.Info[363].EndNPC = Check_Client("旅店老板考乌斯","Innkeeper Kauth")
		Mission.Info[363].Emapid,Mission.Info[363].Ex,Mission.Info[363].Ey,Mission.Info[363].Ez = 1412,-2365.37, -347.31, -8.956864
		Mission.Info[363].Slot_Choose = 1 -- 选择奖励

		Mission.Info[363].Vaild_Item = Check_Client("一捆毛皮","Bundle of Furs")

	-- 亡灵 提瑞斯法林地 - 突然醒来
	    Mission.Info[363] = {}
		Mission.Info[363].Min_Level = 1
		Mission.Info[363].Max_Level = 9

		Mission.Info[363].StartNPC = Check_Client("管理员摩尔多","Undertaker Mordo")
		Mission.Info[363].Smapid,Mission.Info[363].Sx,Mission.Info[363].Sy,Mission.Info[363].Sz = 1420,1678.9887695313, 1667.8616943359, 135.7716217041

		Mission.Info[363].EndNPC = Check_Client("暗影牧师萨维斯","Shadow Priest Sarvis")
		Mission.Info[363].Emapid,Mission.Info[363].Ex,Mission.Info[363].Ey,Mission.Info[363].Ez = 1420,1843.3172607422, 1639.9049072266, 97.627853393555
		Mission.Info[363].Slot_Choose = 1 -- 选择奖励

	-- 亡灵 提瑞斯法林地 - 无脑的僵尸
	    Mission.Info[364] = {}
		Mission.Info[364].Min_Level = 1
		Mission.Info[364].Max_Level = 9

		Mission.Info[364].StartNPC = Check_Client("暗影牧师萨维斯","Shadow Priest Sarvis")
		Mission.Info[364].Smapid,Mission.Info[364].Sx,Mission.Info[364].Sy,Mission.Info[364].Sz = 1420,1843.3172607422, 1639.9049072266, 97.627853393555

		Mission.Info[364].EndNPC = Check_Client("暗影牧师萨维斯","Shadow Priest Sarvis")
		Mission.Info[364].Emapid,Mission.Info[364].Ex,Mission.Info[364].Ey,Mission.Info[364].Ez = 1420,1843.3172607422, 1639.9049072266, 97.627853393555
		Mission.Info[364].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[364] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1501
				Mobs_Coord = {
				{ 1943.0283203125, 1575.6262207031, 81.647171020508 },
				{ 1979.8159179688, 1568.2503662109, 78.845977783203 },
				{ 1929.4652099609, 1615.4041748047, 82.036758422852 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1502
				Mobs_Coord = {
			    { 1943.0283203125, 1575.6262207031, 81.647171020508 },
				{ 1979.8159179688, 1568.2503662109, 78.845977783203 },
				{ 1929.4652099609, 1615.4041748047, 82.036758422852 },
			    }
			end
			
			Mobs_MapID = 1420
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 亡灵 提瑞斯法林地 - 断骨骷髅
	    Mission.Info[3901] = {}
		Mission.Info[3901].Min_Level = 1
		Mission.Info[3901].Max_Level = 9

		Mission.Info[3901].StartNPC = Check_Client("暗影牧师萨维斯","Shadow Priest Sarvis")
		Mission.Info[3901].Smapid,Mission.Info[3901].Sx,Mission.Info[3901].Sy,Mission.Info[3901].Sz = 1420,1843.3172607422, 1639.9049072266, 97.627853393555

		Mission.Info[3901].EndNPC = Check_Client("暗影牧师萨维斯","Shadow Priest Sarvis")
		Mission.Info[3901].Emapid,Mission.Info[3901].Ex,Mission.Info[3901].Ey,Mission.Info[3901].Ez = 1420,1843.3172607422, 1639.9049072266, 97.627853393555
		Mission.Info[3901].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[3901] = function()
		    Mobs_ID = {1890}
			Mobs_Coord = {
			{ 2022.588, 1608.356, 71.68052 },
			{ 1981.18, 1546.04, 86.33405 },
			}
			
			Mobs_MapID = 1420
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 亡灵 提瑞斯法林地 - 被诅咒者
	    Mission.Info[376] = {}
		Mission.Info[376].Min_Level = 1
		Mission.Info[376].Max_Level = 9

		Mission.Info[376].StartNPC = Check_Client("新兵艾尔雷斯","Novice Elreth")
		Mission.Info[376].Smapid,Mission.Info[376].Sx,Mission.Info[376].Sy,Mission.Info[376].Sz = 1420,1847.73046875, 1638.6535644531, 96.933372497559

		Mission.Info[376].EndNPC = Check_Client("新兵艾尔雷斯","Novice Elreth")
		Mission.Info[376].Emapid,Mission.Info[376].Ex,Mission.Info[376].Ey,Mission.Info[376].Ez = 1420,1847.73046875, 1638.6535644531, 96.933372497559
		Mission.Info[376].Slot_Choose = 1 -- 选择奖励

		Mission.Info[376].Vaild_Item = {Check_Client("食腐狼的爪子","Scavenger Paw"),Check_Client("夜行蝙蝠翼","Duskbat Wing")}

		Mission.Execute[376] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1508
				Mobs_ID[#Mobs_ID + 1] = 1509
				Mobs_Coord = {
				{ 1955.6733398438, 1666.4564208984, 76.957168579102 },
				{ 2000.2473144531, 1690.1400146484, 78.49210357666 },
				{ 2063.8752441406, 1624.4948730469, 69.239295959473 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1512
				Mobs_Coord = {
			    { 1955.6733398438, 1666.4564208984, 76.957168579102 },
				{ 2000.2473144531, 1690.1400146484, 78.49210357666 },
				{ 2063.8752441406, 1624.4948730469, 69.239295959473 },
			    }
			end
			
			Mobs_MapID = 1420
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 亡灵 提瑞斯法林地 - 夜行蜘蛛洞穴
	    Mission.Info[380] = {}
		Mission.Info[380].Min_Level = 1
		Mission.Info[380].Max_Level = 9

		Mission.Info[380].StartNPC = 1570
		Mission.Info[380].Smapid,Mission.Info[380].Sx,Mission.Info[380].Sy,Mission.Info[380].Sz = 1420,1848.8227539063, 1580.4724121094, 94.661865234375

		Mission.Info[380].EndNPC = 1570
		Mission.Info[380].Emapid,Mission.Info[380].Ex,Mission.Info[380].Ey,Mission.Info[380].Ez = 1420,1848.8227539063, 1580.4724121094, 94.661865234375
		Mission.Info[380].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[380] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1504
				Mobs_Coord = {
				{ 2130.226, 1656.775, 77.96231 },
				{ 2081.121, 1750.845, 76.82242 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 1505
				Mobs_Coord = {
			    { 2044.83, 1830.721, 107.8134 },
				{ 2044.297, 1861.692, 102.8651 },
				{ 2051.1691894531, 1901.4561767578, 101.56972503662 },
				{ 2018.8582763672, 1904.6694335938, 105.25565338135 },
				{ 2024.2390136719, 1980.5086669922, 99.712417602539 },	
			    }
			end
			
			Mobs_MapID = 1420
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 亡灵 提瑞斯法林地 - 捡破烂
	    Mission.Info[3902] = {}
		Mission.Info[3902].Min_Level = 1
		Mission.Info[3902].Max_Level = 9

		Mission.Info[3902].StartNPC = Check_Client("亡灵卫兵萨尔坦","Deathguard Saltain")
		Mission.Info[3902].Smapid,Mission.Info[3902].Sx,Mission.Info[3902].Sy,Mission.Info[3902].Sz = 1420,1862.3186035156, 1606.8564453125, 95.0126953125

		Mission.Info[3902].EndNPC = Check_Client("亡灵卫兵萨尔坦","Deathguard Saltain")
		Mission.Info[3902].Emapid,Mission.Info[3902].Ex,Mission.Info[3902].Ey,Mission.Info[3902].Ez = 1420,1862.3186035156, 1606.8564453125, 95.0126953125
		Mission.Info[3902].Slot_Choose = 1 -- 选择奖励

		Mission.Info[3902].Vaild_Item = Check_Client("破烂装备","Scavenged Goods")

		Mission.Execute[3902] = function()
		    Mobs_ID = {164662}
			Mobs_Coord = {
			{ 1971.462, 1594.006, 82.32432 },
			{ 1966.481, 1552.365, 84.58966 },
			{ 1901.98, 1571.76, 89.07417 },
			}
			
			Mobs_MapID = 1420
			Black_Spot = {}
			Gather_Items()
		end

	-- 亡灵 提瑞斯法林地 - 血色十字军
	    Mission.Info[381] = {}
		Mission.Info[381].Min_Level = 1
		Mission.Info[381].Max_Level = 9

		Mission.Info[381].StartNPC = 1570
		Mission.Info[381].Smapid,Mission.Info[381].Sx,Mission.Info[381].Sy,Mission.Info[381].Sz = 1420,1848.8227539063, 1580.4724121094, 94.661865234375

		Mission.Info[381].EndNPC = 1570
		Mission.Info[381].Emapid,Mission.Info[381].Ex,Mission.Info[381].Ey,Mission.Info[381].Ez = 1420,1848.8227539063, 1580.4724121094, 94.661865234375
		Mission.Info[381].Slot_Choose = 1 -- 选择奖励

		Mission.Info[381].Vaild_Item = Check_Client("血色十字军臂章","Scarlet Armband")

		Mission.Execute[381] = function()
		    Mobs_ID = {1506,1507}
			Mobs_Coord = {
			{ 1856.754, 1377.965, 74.94774 },
			{ 1831.157, 1325.295, 86.4718 },
			}
		    
			Mobs_MapID = 1420
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 部落 杜隆塔尔 - 驯服野兽1
	    Mission.Info[6062] = {}
		Mission.Info[6062].Min_Level = 10
		Mission.Info[6062].Max_Level = 30

		Mission.Info[6062].StartNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6062].Smapid,Mission.Info[6062].Sx,Mission.Info[6062].Sy,Mission.Info[6062].Sz = 1411,275.34,-4704.00,11.63

		Mission.Info[6062].EndNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6062].Emapid,Mission.Info[6062].Ex,Mission.Info[6062].Ey,Mission.Info[6062].Ez = 1411,275.34,-4704.00,11.63
		Mission.Info[6062].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6062].Vaild_Item = Check_Client("驯兽棒","Taming Rod")

		Mission.Execute[6062] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("可怕的杂斑野猪","Dire Mottled Boar")}
				Mobs_Coord = 
				{
				{207.869400, -4731.613281, 13.286960}, 
				{176.972443, -4705.242188, 18.321346}, 
				{139.435013, -4674.808594, 22.335291}, 
				{94.897247, -4662.572754, 34.230789}, 
				{74.851120, -4633.574219, 40.576107}, 
				{8.630533, -4625.984375, 42.696388},
				{-148.95,-4702.65,29.90},
				{-199.14,-4725.76,32.03},
				{-258.07,-4775.23,29.04},
				{-345.70,-4778.57,36.16},
				}
				Mobs_MapID = 1411
				Black_Spot = {}

				if PetHasActionBar() then
				    awm.PetPassiveMode()
					awm.PetWait()
				end

				if Grind.Step == 2 and awm.ObjectExists("target") and awm.UnitFullName("target") == Check_Client("可怕的杂斑野猪","Dire Mottled Boar") and IsItemInRange(Check_Client("驯兽棒","Taming Rod"),"target") then
				    Try_Stop()
					awm.UseItemByName(Check_Client("驯兽棒","Taming Rod"))
					return
				end

				local Monster = {}
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local id = awm.ObjectId(ThisUnit)
					local name = awm.UnitFullName(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if distance < 100 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) then
						for m = 1,#Mobs_ID do
							if name == Mobs_ID[m] then
								Monster[#Monster + 1] = ThisUnit
							end
						end
					end
				end

				Gather_Items()
			end 
		end

	-- 部落 杜隆塔尔 - 驯服野兽2
	    Mission.Info[6083] = {}
		Mission.Info[6083].Min_Level = 10
		Mission.Info[6083].Max_Level = 30

		Mission.Info[6083].StartNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6083].Smapid,Mission.Info[6083].Sx,Mission.Info[6083].Sy,Mission.Info[6083].Sz = 1411,275.34,-4704.00,11.63

		Mission.Info[6083].EndNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6083].Emapid,Mission.Info[6083].Ex,Mission.Info[6083].Ey,Mission.Info[6083].Ez = 1411,275.34,-4704.00,11.63
		Mission.Info[6083].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6083].Vaild_Item = Check_Client("驯兽棒","Taming Rod")

		Mission.Execute[6083] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("海浪蟹","Surf Crawler")}
				Mobs_Coord = 
				{
				{-951.41,-5161.60,-1.18},
				{-1017,-5141,1.77},
				{-884.94,-5330,0.38}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				if Grind.Step == 2 and awm.ObjectExists("target") and awm.UnitFullName("target") == Check_Client("海浪蟹","Surf Crawler") and IsItemInRange(Check_Client("驯兽棒","Taming Rod"),"target") then
				    Try_Stop()
					awm.UseItemByName(Check_Client("驯兽棒","Taming Rod"))
					return
				end
				if PetHasActionBar() then
				    awm.PetPassiveMode()
					awm.PetWait()
				end

				local Monster = {}
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local id = awm.ObjectId(ThisUnit)
					local name = awm.UnitFullName(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if distance < 100 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) then
						for m = 1,#Mobs_ID do
							if name == Mobs_ID[m] then
								Monster[#Monster + 1] = ThisUnit
							end
						end
					end
				end

				Gather_Items(Monster)
			end 
		end

	-- 部落 杜隆塔尔 - 驯服野兽3
	    Mission.Info[6082] = {}
		Mission.Info[6082].Min_Level = 10
		Mission.Info[6082].Max_Level = 30

		Mission.Info[6082].StartNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6082].Smapid,Mission.Info[6082].Sx,Mission.Info[6082].Sy,Mission.Info[6082].Sz = 1411,275.34,-4704.00,11.63

		Mission.Info[6082].EndNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6082].Emapid,Mission.Info[6082].Ex,Mission.Info[6082].Ey,Mission.Info[6082].Ez = 1411,275.34,-4704.00,11.63
		Mission.Info[6082].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6082].Vaild_Item = Check_Client("驯兽棒","Taming Rod")

		Mission.Execute[6082] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("硬甲蝎","Armored Scorpid")}
				Mobs_Coord = 
				{
				{183.41,-4424.60,35},
				{203,-4337,42}
				}
				Mobs_MapID = 1411
				Black_Spot = {}
				if Grind.Step == 2 and awm.ObjectExists("target") and awm.UnitFullName("target") == Check_Client("硬甲蝎","Armored Scorpid") and IsItemInRange(Check_Client("驯兽棒","Taming Rod"),"target") then
				    Try_Stop()
					awm.UseItemByName(Check_Client("驯兽棒","Taming Rod"))
					return
				end
				if PetHasActionBar() then
				    awm.PetPassiveMode()
					awm.PetWait()
				end

				local Monster = {}
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local id = awm.ObjectId(ThisUnit)
					local name = awm.UnitFullName(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if distance < 100 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) then
						for m = 1,#Mobs_ID do
							if name == Mobs_ID[m] then
								Monster[#Monster + 1] = ThisUnit
							end
						end
					end
				end

				Gather_Items(Monster)
			end 
		end

	-- 部落 杜隆塔尔 - 驯服野兽4
        Mission.Info[6081] = {}
		Mission.Info[6081].Min_Level = 10
		Mission.Info[6081].Max_Level = 30

		Mission.Info[6081].StartNPC = Check_Client("索塔尔","Thotar")
		Mission.Info[6081].Smapid,Mission.Info[6081].Sx,Mission.Info[6081].Sy,Mission.Info[6081].Sz = 1411,275.34,-4704.00,11.63

		Mission.Info[6081].EndNPC = Check_Client("奥玛克","Ormak Grimshot")
		Mission.Info[6081].Emapid,Mission.Info[6081].Ex,Mission.Info[6081].Ey,Mission.Info[6081].Ez = 1454,2100.27,-4606.88,58.13
		Mission.Info[6081].Slot_Choose = 1 -- 选择奖励

	-- 部落 杜隆塔尔 - 部落的新兵
        Mission.Info[840] = {}
		Mission.Info[840].Min_Level = 10
		Mission.Info[840].Max_Level = 20

		Mission.Info[840].StartNPC = Check_Client("塔克林·寻路者","Takrin Pathseeker")
		Mission.Info[840].Smapid,Mission.Info[840].Sx,Mission.Info[840].Sy,Mission.Info[840].Sz = 1411,271.34,-4650.00,11.71

		Mission.Info[840].EndNPC = Check_Client("卡加尔·战痕","Kargal Battlescar")
		Mission.Info[840].Emapid,Mission.Info[840].Ex,Mission.Info[840].Ey,Mission.Info[840].Ez = 1413,303.43,-3686.16,27.07
		Mission.Info[840].Slot_Choose = 1 -- 选择奖励

		Mission.Info[840].Vaild_Item = Check_Client("募兵信","Recruitment Letter")

	-- 部落 贫瘠之地 - 十字路口征兵
        Mission.Info[842] = {}
		Mission.Info[842].Min_Level = 10
		Mission.Info[842].Max_Level = 20

		Mission.Info[842].StartNPC = Check_Client("卡加尔·战痕","Kargal Battlescar")
		Mission.Info[842].Smapid,Mission.Info[842].Sx,Mission.Info[842].Sy,Mission.Info[842].Sz = 1413,303.43,-3686.16,27.07

		Mission.Info[842].EndNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[842].Emapid,Mission.Info[842].Ex,Mission.Info[842].Ey,Mission.Info[842].Ez = 1413,-482.43,-2670.16,97.35
		Mission.Info[842].Slot_Choose = 1 -- 选择奖励

		Mission.Info[842].Vaild_Item = Check_Client("签过字的募兵信","Signed Recruitment Letter")

	-- 部落 贫瘠之地 - 平原陆行鸟的威胁
	    Mission.Info[844] = {}
		Mission.Info[844].Min_Level = 12
		Mission.Info[844].Max_Level = 20

		Mission.Info[844].StartNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[844].Smapid,Mission.Info[844].Sx,Mission.Info[844].Sy,Mission.Info[844].Sz = 1413,-482.48,-2670.19,97.35

		Mission.Info[844].EndNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[844].Emapid,Mission.Info[844].Ex,Mission.Info[844].Ey,Mission.Info[844].Ez = 1413,-482.48,-2670.19,97.35
		Mission.Info[844].Slot_Choose = 1 -- 选择奖励

		Mission.Info[844].Vaild_Item = Check_Client("陆行鸟的喙","Plainstrider Beak")

		Mission.Execute[844] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("巨型平原陆行鸟","Greater Plainstrider")}
				Mobs_Coord = 
				{
				{-151.342651,  -2714.420654, 91.667053},
				{-130.659622,  -2745.893066, 92.971779},
				{-108.888397,  -2771.359619, 93.383476},
				{-85.764336,  -2794.625977, 94.818245},
				{-60.362385,  -2818.897949, 92.771545},
				{-42.944874,  -2843.637939, 91.674232},
				{-31.619328,  -2874.473633, 91.666748},
				{-51.143387,  -2910.022949, 92.668396},
				{-73.539230,  -2928.188477, 94.040024},
				{-98.831116,  -2944.085205, 92.362045},
				{-126.733582,  -2944.553955, 91.667641},
				{-156.696579,  -2909.666016, 93.204819},
				{-151.342651,  -2714.420654, 91.667053}
				}
				Mobs_MapID = 1413
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 部落 贫瘠之地 - 送往奥格瑞玛的肉
        Mission.Info[6365] = {}
		Mission.Info[6365].Min_Level = 10
		Mission.Info[6365].Max_Level = 20

		Mission.Info[6365].StartNPC = Check_Client("扎尔夫","Zargh")
		Mission.Info[6365].Smapid,Mission.Info[6365].Sx,Mission.Info[6365].Sy,Mission.Info[6365].Sz = 1413,-403,-2709.00,97.71

		Mission.Info[6365].EndNPC = Check_Client("迪弗拉克","Devrak")
		Mission.Info[6365].Emapid,Mission.Info[6365].Ex,Mission.Info[6365].Ey,Mission.Info[6365].Ez = 1413,-437.43,-2596.16,95.79
		Mission.Info[6365].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6365].Vaild_Item = Check_Client("扎尔夫的肉品","Zargh's Meats")

	-- 部落 贫瘠之地 - 飞往奥格瑞玛
        Mission.Info[6384] = {}
		Mission.Info[6384].Min_Level = 10
		Mission.Info[6384].Max_Level = 20

		Mission.Info[6384].StartNPC = Check_Client("迪弗拉克","Devrak")
		Mission.Info[6384].Smapid,Mission.Info[6384].Sx,Mission.Info[6384].Sy,Mission.Info[6384].Sz = 1413,-437.43,-2596.16,95.79

		Mission.Info[6384].EndNPC = Check_Client("旅店老板格雷什卡","Innkeeper Gryshka")
		Mission.Info[6384].Emapid,Mission.Info[6384].Ex,Mission.Info[6384].Ey,Mission.Info[6384].Ez = 1454,1633.99,-4439.37,15.43
		Mission.Info[6384].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6384].Vaild_Item = Check_Client("扎尔夫的肉品","Zargh's Meats")

	-- 部落 贫瘠之地 - 双足飞龙管理员多拉斯
        Mission.Info[6385] = {}
		Mission.Info[6385].Min_Level = 10
		Mission.Info[6385].Max_Level = 20

		Mission.Info[6385].StartNPC = Check_Client("旅店老板格雷什卡","Innkeeper Gryshka")
		Mission.Info[6385].Smapid,Mission.Info[6385].Sx,Mission.Info[6385].Sy,Mission.Info[6385].Sz = 1454,1633.99,-4439.37,15.43

		Mission.Info[6385].EndNPC = Check_Client("多拉斯","Doras")
		Mission.Info[6385].Emapid,Mission.Info[6385].Ex,Mission.Info[6385].Ey,Mission.Info[6385].Ez = 1454,1676.99,-4313.37,61.57
		Mission.Info[6385].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6385].Vaild_Item = Check_Client("格雷什卡的信","Gryshka's Letter")

	-- 部落 贫瘠之地 - 返回十字路口
        Mission.Info[6386] = {}
		Mission.Info[6386].Min_Level = 10
		Mission.Info[6386].Max_Level = 20

		Mission.Info[6386].StartNPC = Check_Client("多拉斯","Doras")
		Mission.Info[6386].Smapid,Mission.Info[6386].Sx,Mission.Info[6386].Sy,Mission.Info[6386].Sz = 1454,1676.99,-4313.37,61.57

		Mission.Info[6386].EndNPC = Check_Client("扎尔夫","Zargh")
		Mission.Info[6386].Emapid,Mission.Info[6386].Ex,Mission.Info[6386].Ey,Mission.Info[6386].Ez = 1413,-403,-2709.00,97.71
		Mission.Info[6386].Slot_Choose = 1 -- 选择奖励

		Mission.Info[6386].Vaild_Item = Check_Client("格雷什卡的信","Gryshka's Letter")

	-- 部落 贫瘠之地 - 偷钱的迅猛龙
	    Mission.Info[869] = {}
		Mission.Info[869].Min_Level = 13
		Mission.Info[869].Max_Level = 17

		Mission.Info[869].StartNPC = Check_Client("加兹罗格","Gazrog")
		Mission.Info[869].Smapid,Mission.Info[869].Sx,Mission.Info[869].Sy,Mission.Info[869].Sz = 1413,-435.95,-2639.21,96.28

		Mission.Info[869].EndNPC = Check_Client("加兹罗格","Gazrog")
		Mission.Info[869].Emapid,Mission.Info[869].Ex,Mission.Info[869].Ey,Mission.Info[869].Ez = 1413,-435.95,-2639.21,96.28
		Mission.Info[869].Slot_Choose = 1 -- 选择奖励

		Mission.Info[869].Vaild_Item = Check_Client("迅猛龙的头颅","Raptor Head")

		Mission.Execute[869] = function()
		    if #Mission.Text == 1 then
			    Mission.Flow = 1
			end
			if Mission.Flow == 1 then
			    Mobs_ID = {Check_Client("赤鳞尖啸龙","Sunscale Screecher")}
				Mobs_Coord = 
				{
				{-247.663483, -2365.395264, 92.713531},
				{-185.993423, -2312.391113, 91.836052},
				{-162.856033, -2250.649414, 91.667313},
				{-122.168808, -2194.997314, 93.276222},
				{-130.056778, -2141.241943, 91.666733},
				{-178.377457, -2098.310059, 91.666786},
				{-195.532486, -2039.404785, 92.669762},
				{-204.620132, -1983.236572, 93.381302},
				{-244.352173, -1925.622681, 92.503059},
				{-286.289368, -1867.853638, 92.686836},
				{-345.465332, -1804.573975, 95.038979},
				{-412.924927, -1779.364868, 92.044434},
				{-488.876160, -1757.028687, 91.666702},
				{-564.993896, -1767.717163, 93.114845},
				{-560.234680, -1836.799683, 91.691727},
				{-537.584167, -1932.610840, 92.654686},
				{-468.154694, -2019.529907, 93.788551},
				{-404.006775, -2024.557617, 91.666779},
				{-359.584625, -2058.773438, 94.418671},
				{-305.000244, -2085.579346, 96.684151},
				{-295.696289, -2145.446045, 96.963326},
				{-287.714752, -2197.615723, 96.162453},
				{-247.663483, -2365.395264, 92.713531}
				}
				Mobs_MapID = 1413
				Black_Spot = {}
				Kill_Mobs()
			end		   
		end

	-- 部落 贫瘠之地 - 菌类孢子
	    Mission.Info[848] = {}
		Mission.Info[848].Min_Level = 15
		Mission.Info[848].Max_Level = 20

		Mission.Info[848].StartNPC = Check_Client("药剂师赫布瑞姆","Apothecary Helbrim")
		Mission.Info[848].Smapid,Mission.Info[848].Sx,Mission.Info[848].Sy,Mission.Info[848].Sz = 1413,-424.63,-2589.80,95.82

		Mission.Info[848].EndNPC = Check_Client("药剂师赫布瑞姆","Apothecary Helbrim")
		Mission.Info[848].Emapid,Mission.Info[848].Ex,Mission.Info[848].Ey,Mission.Info[848].Ez = 1413,-424.63,-2589.80,95.82
		Mission.Info[848].Slot_Choose = 1 -- 选择奖励

		Mission.Info[848].Vaild_Item = Check_Client("菌类孢子","Fungal Spores")

		Mission.Execute[848] = function()
			Mobs_ID = {Check_Client("丰满的蘑菇","Laden Mushroom")}
			Mobs_Coord = 
			{
			{-1045,-2153,81},
			{-985,-2096,80},
			{-947,-2079,80},
			{-982,-2030,81},
			{-1118,-2043,83}
			}
			Mobs_MapID = 1413
			Black_Spot = {}
			Gather_Items()
		end

	-- 部落 贫瘠之地 - 码头管理员迪兹维格
        Mission.Info[1492] = {}
		Mission.Info[1492].Min_Level = 15
		Mission.Info[1492].Max_Level = 20

		Mission.Info[1492].StartNPC = Check_Client("药剂师赫布瑞姆","Apothecary Helbrim")
		Mission.Info[1492].Smapid,Mission.Info[1492].Sx,Mission.Info[1492].Sy,Mission.Info[1492].Sz = 1413,-424.63,-2589.80,95.82

		Mission.Info[1492].EndNPC = Check_Client("码头管理员迪兹维格","Wharfmaster Dizzywig")
		Mission.Info[1492].Emapid,Mission.Info[1492].Ex,Mission.Info[1492].Ey,Mission.Info[1492].Ez = 1413,-985.60,-3796.71,5.13
		Mission.Info[1492].Slot_Choose = 1 -- 选择奖励

		Mission.Info[1492].Vaild_Item = Check_Client("保险箱","Secure Crate")

	-- 部落 贫瘠之地 - 野猪人的袭击
	    Mission.Info[871] = {}
		Mission.Info[871].Min_Level = 13
		Mission.Info[871].Max_Level = 20

		Mission.Info[871].StartNPC = Check_Client("索克","Thork")
		Mission.Info[871].Smapid,Mission.Info[871].Sx,Mission.Info[871].Sy,Mission.Info[871].Sz = 1413,-473.95,-2595.21,103.28

		Mission.Info[871].EndNPC = Check_Client("索克","Thork")
		Mission.Info[871].Emapid,Mission.Info[871].Ex,Mission.Info[871].Ey,Mission.Info[871].Ez = 1413,-473.95,-2595.21,103.28
		Mission.Info[871].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[871] = function()
		    Mobs_ID = {}
			Mobs_Coord = {
			{-151.342651,  -2714.420654, 91.667053},
            {-130.659622,  -2745.893066, 92.971779},
            {-108.888397,  -2771.359619, 93.383476},
            {-85.764336,  -2794.625977, 94.818245},
            {-60.362385,  -2818.897949, 92.771545},
            {-42.944874,  -2843.637939, 91.674232},
            {-31.619328,  -2874.473633, 91.666748},
            {-51.143387,  -2910.022949, 92.668396},
            {-73.539230,  -2928.188477, 94.040024},
            {-98.831116,  -2944.085205, 92.362045},
            {-126.733582,  -2944.553955, 91.667641},
            {-156.696579,  -2909.666016, 93.204819},
            {-151.342651,  -2714.420654, 91.667053}
			}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = Check_Client("钢鬃寻水者","Razormane Water Seeker")
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = Check_Client("钢鬃织棘者","Razormane Thornweaver")
			end
			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = Check_Client("钢鬃猎手","Razormane Hunter")
			end
			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()   
		end

	-- 部落 贫瘠之地 - 斑马的威胁
	    Mission.Info[845] = {}
		Mission.Info[845].Min_Level = 14
		Mission.Info[845].Max_Level = 20

		Mission.Info[845].StartNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[845].Smapid,Mission.Info[845].Sx,Mission.Info[845].Sy,Mission.Info[845].Sz = 1413,-482.48,-2670.19,97.35

		Mission.Info[845].EndNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[845].Emapid,Mission.Info[845].Ex,Mission.Info[845].Ey,Mission.Info[845].Ez = 1413,-482.48,-2670.19,97.35
		Mission.Info[845].Slot_Choose = 1 -- 选择奖励

		Mission.Info[845].Vaild_Item = Check_Client("斑马蹄","Zhevra Hooves")

		Mission.Execute[845] = function()
			Mobs_ID = {Check_Client("巨型平原陆行鸟","Greater Plainstrider"),Check_Client("快步斑马","Zhevra Runner"),Check_Client("赤鳞尖啸龙","Sunscale Screecher"),Check_Client("敏捷的平原陆行鸟","Fleeting Plainstrider"),Check_Client("雌性草原狮","Savannah Huntress"),Check_Client("长鬃草原狮","Savannah Highmane")}
			Mobs_Coord = 
			{
			{-247.663483, -2365.395264, 92.713531},
			{-185.993423, -2312.391113, 91.836052},
			{-162.856033, -2250.649414, 91.667313},
			{-122.168808, -2194.997314, 93.276222},
			{-130.056778, -2141.241943, 91.666733},
			{-178.377457, -2098.310059, 91.666786},
			{-195.532486, -2039.404785, 92.669762},
			{-204.620132, -1983.236572, 93.381302},
			{-244.352173, -1925.622681, 92.503059},
			{-286.289368, -1867.853638, 92.686836},
			{-345.465332, -1804.573975, 95.038979},
			{-412.924927, -1779.364868, 92.044434},
			{-488.876160, -1757.028687, 91.666702},
			{-564.993896, -1767.717163, 93.114845},
			{-560.234680, -1836.799683, 91.691727},
			{-537.584167, -1932.610840, 92.654686},
			{-468.154694, -2019.529907, 93.788551},
			{-404.006775, -2024.557617, 91.666779},
			{-359.584625, -2058.773438, 94.418671},
			{-305.000244, -2085.579346, 96.684151},
			{-295.696289, -2145.446045, 96.963326},
			{-287.714752, -2197.615723, 96.162453},
			{-247.663483, -2365.395264, 92.713531}
			}
			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 部落 贫瘠之地 - 草原上的徘徊者
	    Mission.Info[903] = {}
		Mission.Info[903].Min_Level = 15
		Mission.Info[903].Max_Level = 20

		Mission.Info[903].StartNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[903].Smapid,Mission.Info[903].Sx,Mission.Info[903].Sy,Mission.Info[903].Sz = 1413,-482.48,-2670.19,97.35

		Mission.Info[903].EndNPC = Check_Client("瑟格拉·黑棘","Sergra Darkthorn")
		Mission.Info[903].Emapid,Mission.Info[903].Ex,Mission.Info[903].Ey,Mission.Info[903].Ez = 1413,-482.48,-2670.19,97.35
		Mission.Info[903].Slot_Choose = 1 -- 选择奖励

		Mission.Info[903].Vaild_Item = Check_Client("徘徊者的爪子","Prowler Claws")

		Mission.Execute[903] = function()
			Mobs_ID = {
			Check_Client("草原徘徊者","Savannah Prowler"),
			}
			Mobs_Coord = 
			{
			{-457.879913, -1877.417358, 91.700020},
            {-534.833862, -1844.140991, 91.738434},
            {-592.488586, -1808.720215, 91.667847},
            {-645.287598, -1841.462891, 94.378883},
            {-708.439880, -1853.303223, 92.764397},
            {-782.250122, -1845.797974, 93.377945},
            {-879.505066, -1844.589233, 93.348129},
            {-927.362427, -1821.055786, 92.263092},
            {-975.320007, -1819.201904, 94.647537},
            {-1014.26776, -1809.193604, 92.387459},
            {-973.525024, -1741.480347, 91.742065},
            {-935.675659, -1686.091675, 93.084534},
            {-883.468689, -1694.891357, 91.721336},
            {-814.436218, -1722.913818, 94.710289},
            {-763.156616, -1739.270508, 91.682426},
            {-687.415955, -1727.927002, 92.154060},
            {-629.167480, -1691.791992, 93.566063},
            {-457.879913, -1877.417358, 91.700020},
			}
			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 部落 贫瘠之地 - 半人马护腕
	    Mission.Info[855] = {}
		Mission.Info[855].Min_Level = 15
		Mission.Info[855].Max_Level = 20

		Mission.Info[855].StartNPC = Check_Client("雷戈萨·死门","Regthar Deathgate")
		Mission.Info[855].Smapid,Mission.Info[855].Sx,Mission.Info[855].Sy,Mission.Info[855].Sz = 1413,-307.135,-1971.95,96.39

		Mission.Info[855].EndNPC = Check_Client("雷戈萨·死门","Regthar Deathgate")
		Mission.Info[855].Emapid,Mission.Info[855].Ex,Mission.Info[855].Ey,Mission.Info[855].Ez = 1413,-307.135,-1971.95,96.39
		Mission.Info[855].Slot_Choose = 1 -- 选择奖励

		Mission.Info[855].Vaild_Item = Check_Client("半人马护腕","Centaur Bracers")

		Mission.Execute[855] = function()
			Mobs_ID = {3272,3273}
			Mobs_Coord = 
			{
			{ 59.103652954102, -2031.1226806641, 91.953453063965 },
			{ 124.52667999268, -2005.427734375, 94.344734191895 },
			{ 141.3828125, -1889.9747314453, 96.288948059082 },
			{ 103.19069671631, -1865.4400634766, 94.409980773926 },
			{ 29.871591567993, -1852.4400634766, 95.164131164551 },
			{ -7.5354838371277, -1816.7202148438, 93.234352111816 },
			{ -128.8046875, -1818.8883056641, 92.991645812988 },
			{ -69.921585083008, -1968.4079589844, 92.852165222168 }
			}
			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 部落 贫瘠之地 - 南海海盗
	    Mission.Info[887] = {}
		Mission.Info[887].Min_Level = 15
		Mission.Info[887].Max_Level = 20

		Mission.Info[887].StartNPC = Check_Client("加兹鲁维","Gazlowe")
		Mission.Info[887].Smapid,Mission.Info[887].Sx,Mission.Info[887].Sy,Mission.Info[887].Sz = 1413,-835,-3728,26

		Mission.Info[887].EndNPC = Check_Client("加兹鲁维","Gazlowe")
		Mission.Info[887].Emapid,Mission.Info[887].Ex,Mission.Info[887].Ey,Mission.Info[887].Ez = 1413,-835,-3728,26
		Mission.Info[887].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[887] = function()
			Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3381
				Mobs_Coord = {
				{ -1370.4666748047, -3850.1599121094, 19.044441223145 },
				{ -1485.7080078125, -3844.1276855469, 22.651817321777 },
				{ -1611.1364746094, -3856.9729003906, 13.643441200256 },
				{ -1673.4350585938, -3837.2707519531, 13.925818443298 }
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 3382
				Mobs_Coord = {
			    { -1370.4666748047, -3850.1599121094, 19.044441223145 },
				{ -1485.7080078125, -3844.1276855469, 22.651817321777 },
				{ -1611.1364746094, -3856.9729003906, 13.643441200256 },
				{ -1673.4350585938, -3837.2707519531, 13.925818443298 }
			    }
			end
			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()  
		end

	-- 部落 贫瘠之地 - 丢失的货物1
	    Mission.Info[890] = {}
		Mission.Info[890].Min_Level = 15
		Mission.Info[890].Max_Level = 24

		Mission.Info[890].StartNPC = Check_Client("加兹鲁维","Gazlowe")
		Mission.Info[890].Smapid,Mission.Info[890].Sx,Mission.Info[890].Sy,Mission.Info[890].Sz = 1413,-835,-3728,26

		Mission.Info[890].EndNPC = Check_Client("码头管理员迪兹维格","Wharfmaster Dizzywig")
		Mission.Info[890].Emapid,Mission.Info[890].Ex,Mission.Info[890].Ey,Mission.Info[890].Ez = 1413,-985.59918212891, -3796.7102050781, 5.1259198189082
		Mission.Info[890].Slot_Choose = 1 -- 选择奖励

		Mission.Info[890].Vaild_Item = Check_Client("加兹鲁维的账本","Gazlowe's Ledger")

	-- 部落 贫瘠之地 - 丢失的货物2
	    Mission.Info[892] = {}
		Mission.Info[892].Min_Level = 15
		Mission.Info[892].Max_Level = 24

		Mission.Info[892].StartNPC = Check_Client("码头管理员迪兹维格","Wharfmaster Dizzywig")
		Mission.Info[892].Smapid,Mission.Info[892].Sx,Mission.Info[892].Sy,Mission.Info[892].Sz = 1413,-985.59918212891, -3796.7102050781, 5.1259198189282

		Mission.Info[892].EndNPC = Check_Client("加兹鲁维","Gazlowe")
		Mission.Info[892].Emapid,Mission.Info[892].Ex,Mission.Info[892].Ey,Mission.Info[892].Ez = 1413,-835,-3728,26
		Mission.Info[892].Slot_Choose = 1 -- 选择奖励

		Mission.Info[892].Vaild_Item = Check_Client("加兹鲁维的账本","Gazlowe's Ledger")

	-- 部落 贫瘠之地 - 迅猛龙角
	    Mission.Info[865] = {}
		Mission.Info[865].Min_Level = 18
		Mission.Info[865].Max_Level = 27

		Mission.Info[865].StartNPC = Check_Client("麦伯克·米希瑞克斯","Mebok Mizzyrix")
		Mission.Info[865].Smapid,Mission.Info[865].Sx,Mission.Info[865].Sy,Mission.Info[865].Sz = 1413,-928.98168945313, -3697.2321777344, 7.9881491661072

		Mission.Info[865].EndNPC = Check_Client("麦伯克·米希瑞克斯","Mebok Mizzyrix")
		Mission.Info[865].Emapid,Mission.Info[865].Ex,Mission.Info[865].Ey,Mission.Info[865].Ez = 1413,-928.98168945313, -3697.2321777344, 7.9881491661072
		Mission.Info[865].Slot_Choose = 1 -- 选择奖励

		Mission.Info[865].Vaild_Item = Check_Client("完整的迅猛龙角","Intact Raptor Horn")

		Mission.Execute[865] = function()
		    if Level < 20 then
				Mobs_ID = { 
				Check_Client("草原幼狮","Savannah Cub"),
				Check_Client("冲锋斑马","Zhevra Charger"),
				Check_Client("草原狮后","Savannah Matriarch"),
				Check_Client("暴躁的平原陆行鸟","Ornery Plainstrider"),
				Check_Client("赤鳞镰爪龙","Sunscale Scytheclaw"),
				Check_Client("赤鳞尖啸龙","Sunscale Screecher"),
				Check_Client("草原狮王","Savannah Patriarch"),
				Check_Client("长颈鹿","Barrens Giraffe"),
				Check_Client("草原徘徊者","Savannah Prowler"),
				Check_Client("乱齿土狼","Hecklefang Hyena"),
				}
			else
			    Mobs_ID = { 
				Check_Client("赤鳞镰爪龙","Sunscale Scytheclaw"),
				Check_Client("赤鳞尖啸龙","Sunscale Screecher"),
				}
			end
			Mobs_MapID = 1413
			Mobs_Coord =
			{
			{-837,-3278,94},
			{-702,-3405,91},
			{-607,-3516,93},
			{-495,-3528,92},
			{-451,-3401,92},
			{-673,-3296,96},
			}

			Mobs_MapID = 1413
			Black_Spot = {}
			Kill_Mobs()
		end

	-- 部落 贫瘠之地 - 向卡德拉克报到
	    Mission.Info[6541] = {}
		Mission.Info[6541].Min_Level = 22
		Mission.Info[6541].Max_Level = 30

		Mission.Info[6541].StartNPC = Check_Client("索克","Thork")
		Mission.Info[6541].Smapid,Mission.Info[6541].Sx,Mission.Info[6541].Sy,Mission.Info[6541].Sz = 1413,-473.95,-2595.21,103.28

		Mission.Info[6541].EndNPC = Check_Client("卡德拉克","Kadrak")
		Mission.Info[6541].Emapid,Mission.Info[6541].Ex,Mission.Info[6541].Ey,Mission.Info[6541].Ez = 1413,1246.34,-2253.31,108.29
		Mission.Info[6541].Slot_Choose = 1 -- 选择奖励

	-- 部落 贫瘠之地 - 在战斗中失踪
	    Mission.Info[4921] = {}
		Mission.Info[4921].Min_Level = 19
		Mission.Info[4921].Max_Level = 28

		Mission.Info[4921].StartNPC = Check_Client("曼科里克","Mankrik")
		Mission.Info[4921].Smapid,Mission.Info[4921].Sx,Mission.Info[4921].Sy,Mission.Info[4921].Sz = 1413,-520.9833984375, -2641.4079589844, 95.787773132324

		Mission.Info[4921].EndNPC = Check_Client("曼科里克","Mankrik")
		Mission.Info[4921].Emapid,Mission.Info[4921].Ex,Mission.Info[4921].Ey,Mission.Info[4921].Ez = 1413,-520.9833984375, -2641.4079589844, 95.787773132324
		Mission.Info[4921].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[4921] = function()
			Mobs_ID = {Check_Client("血肉模糊的尸体","Beaten Corpse")}
			Mobs_Coord = 
			{
			{ -1787.19, -2375.77, 91.68489 }
			}
			Mobs_MapID = 1413
			Black_Spot = {}

			if Grind.Step == 2 and awm.ObjectExists("target") and awm.UnitFullName("target") == Check_Client("血肉模糊的尸体","Beaten Corpse") and (Gossip_Show or Quest_Show) then
			    awm.RunMacroText("/click GossipTitleButton1")
			end
			Gather_Items()
		end

	-- 部落 贫瘠之地 - 复仇的怒火
	    Mission.Info[899] = {}
		Mission.Info[899].Min_Level = 19
		Mission.Info[899].Max_Level = 28

		Mission.Info[899].StartNPC = Check_Client("曼科里克","Mankrik")
		Mission.Info[899].Smapid,Mission.Info[899].Sx,Mission.Info[899].Sy,Mission.Info[899].Sz = 1413,-520.9833984375, -2641.4079589844, 95.787773132324

		Mission.Info[899].EndNPC = Check_Client("曼科里克","Mankrik")
		Mission.Info[899].Emapid,Mission.Info[899].Ex,Mission.Info[899].Ey,Mission.Info[899].Ez = 1413,-520.9833984375, -2641.4079589844, 95.787773132324
		Mission.Info[899].Slot_Choose = 1 -- 选择奖励

		Mission.Info[899].Vaild_Item = Check_Client("刺背野猪人的獠牙","Bristleback Quilboar Tusk")

		Mission.Execute[899] = function()
			Mobs_ID = {3260,3258,3261}
			Mobs_Coord = 
			{
			{ -1944.986, -2149.074, 93.43854 },
			{ -2172.524, -2569.22, 91.66766 }
			}
			Mobs_MapID = 1413
			Black_Spot = {}

			
			Kill_Mobs()
		end

    -- 部落 石爪山脉 - 地精侵略者
	    Mission.Info[1062] = {}
		Mission.Info[1062].Min_Level = 19
		Mission.Info[1062].Max_Level = 28

		Mission.Info[1062].StartNPC = Check_Client("希雷斯·碎石","Seereth Stonebreak")
		Mission.Info[1062].Smapid,Mission.Info[1062].Sx,Mission.Info[1062].Sy,Mission.Info[1062].Sz = 1413,-270.9250793457, -950.25811767578, 14.19591999054

		Mission.Info[1062].EndNPC = Check_Client("希雷斯·碎石","Seereth Stonebreak")
		Mission.Info[1062].Emapid,Mission.Info[1062].Ex,Mission.Info[1062].Ey,Mission.Info[1062].Ez = 1413,-270.9250793457, -950.25811767578, 14.19591999054
		Mission.Info[1062].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[1062] = function()
			Mobs_ID = {3989,3991,4074}
			Mobs_Coord = 
			{
			{ 1037.55859375, 18.736604690552, 10.756222724915 },
			{ 1079.0241699219, -85.32852935791, 6.5774831771851 },
			{ 1133.5311279297, 77.956367492676, -2.0098576545715 },
			{ 1122.8917236328, 167.09767150879, -0.075059339404106 },
			{ 1150.7193603516, 233.51089477539, 4.4198522567749 },
			{ 1188.8482666016, 303.34991455078, 25.378604888916 },
			}
			Mobs_MapID = 1442
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 石爪山脉 - 盗窃的蜘蛛
	    Mission.Info[6461] = {}
		Mission.Info[6461].Min_Level = 19
		Mission.Info[6461].Max_Level = 28

		Mission.Info[6461].StartNPC = Check_Client("辛吉拉","Xen'Zilla")
		Mission.Info[6461].Smapid,Mission.Info[6461].Sx,Mission.Info[6461].Sy,Mission.Info[6461].Sz = 1442,-177.56803894043, -233.31727600098, 8.7874307632446

		Mission.Info[6461].EndNPC = Check_Client("辛吉拉","Xen'Zilla")
		Mission.Info[6461].Emapid,Mission.Info[6461].Ex,Mission.Info[6461].Ey,Mission.Info[6461].Ez = 1442,-177.56803894043, -233.31727600098, 8.7874307632446
		Mission.Info[6461].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[6461] = function()

		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 4005
				Mobs_Coord = {
				{ 520.21636962891, 333.31994628906, 52.285945892334 },
				{ 453.98608398438, 324.28466796875, 49.800800323486 },
				{ 428.22344970703, 372.54333496094, 52.004676818848 },
				{ 425.20565795898, 475.86254882813, 98.528930664063 },
				{ 433.35455322266, 545.97393798828, 87.571311950684 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 4007
				Mobs_Coord = {
			    { 926.96099853516, 308.23547363281, 23.026433944702 },
				{ 886.02319335938, 270.22900390625, 24.133514404297 },
				{ 827.12628173828, 235.83651733398, 23.339897155762 },
				{ 881.53155517578, 198.13948059082, 25.198820114136 },
				{ 950.16235351563, 198.09838867188, 22.221603393555 },
				{ 971.24261474609, 236.64395141602, 21.718942642212 },
			    }
			end
			Mobs_MapID = 1442
			Black_Spot = {}

			
			Kill_Mobs()
		end
    
	-- 双方 荆棘谷 - 欢迎来到丛林
	    Mission.Info[583] = {}
		Mission.Info[583].Min_Level = 33
		Mission.Info[583].Max_Level = 43

		Mission.Info[583].StartNPC = Check_Client("巴尼尔·石罐","Barnil Stonepot")
		Mission.Info[583].Smapid,Mission.Info[583].Sx,Mission.Info[583].Sy,Mission.Info[583].Sz = 1434,-11616.661132813, -54.83251953125, 11.055826187134

		Mission.Info[583].EndNPC = 715
		Mission.Info[583].Emapid,Mission.Info[583].Ex,Mission.Info[583].Ey,Mission.Info[583].Ez = 1434,-11628.60546875, -54.556911468506, 10.939603805542
		Mission.Info[583].Slot_Choose = 1 -- 选择奖励

	-- 双方 荆棘谷 - 供与求
	    Mission.Info[575] = {}
		Mission.Info[575].Min_Level = 38
		Mission.Info[575].Max_Level = 43

		Mission.Info[575].StartNPC = Check_Client("崔斯里克","Drizzlik")
		Mission.Info[575].Smapid,Mission.Info[575].Sx,Mission.Info[575].Sy,Mission.Info[575].Sz = 1434,-14469.603515625, 415.38238525391, 25.365613937378

		Mission.Info[575].EndNPC = Check_Client("崔斯里克","Drizzlik")
		Mission.Info[575].Emapid,Mission.Info[575].Ex,Mission.Info[575].Ey,Mission.Info[575].Ez = 1434,-14469.603515625, 415.38238525391, 25.365613937378
		Mission.Info[575].Slot_Choose = 1 -- 选择奖励

		Mission.Info[575].Vaild_Item = Check_Client("淡水鳄的皮","Large River Crocolisk Skin")

		Mission.Execute[575] = function()
			Mobs_ID = {1150}
			Mobs_Coord = 
			{
			{ -11599.296875, 35.755325317383, 14.508272171021 },
			{ -11541.279296875, 162.9174041748, 12.975573539734 },
			{ -11511.190429688, -22.871179580688, 21.057191848755 },
			{ -11579.981445313, -85.506156921387, 11.991297721863 },
			{ -11625.490234375, -173.38827514648, 11.545145988464 },
			{ -11675.899414063, -328.00109863281, 11.708605766296 },
			{ -11771.708007813, -387.53668212891, 12.342811584473 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 收集鳄鱼皮
	    Mission.Info[577] = {}
		Mission.Info[577].Min_Level = 38
		Mission.Info[577].Max_Level = 43

		Mission.Info[577].StartNPC = Check_Client("崔斯里克","Drizzlik")
		Mission.Info[577].Smapid,Mission.Info[577].Sx,Mission.Info[577].Sy,Mission.Info[577].Sz = 1434,-14469.603515625, 415.38238525391, 25.365613937378

		Mission.Info[577].EndNPC = Check_Client("崔斯里克","Drizzlik")
		Mission.Info[577].Emapid,Mission.Info[577].Ex,Mission.Info[577].Ey,Mission.Info[577].Ez = 1434,-14469.603515625, 415.38238525391, 25.365613937378
		Mission.Info[577].Slot_Choose = 1 -- 选择奖励

		Mission.Info[577].Vaild_Item = Check_Client("淡水鳄的皮","Large River Crocolisk Skin")

		Mission.Execute[577] = function()
			Mobs_ID = {1114,1152,684,772}
			Mobs_Coord = 
			{
			{ -12220.223632813, -425.3078918457, 15.941739082336 },
			{ -12322.864257813, -390.86752319336, 18.371313095093 },
			{ -12410.60546875, -372.72662353516, 14.483702659607 },
			{ -12521.903320313, -328.69314575195, 17.856422424316 },
			{ -12581.66015625, -332.0139465332, 17.178590774536 },
			{ -12391.849609375, -517.67498779297, 13.995443344116 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎虎1
	    Mission.Info[185] = {}
		Mission.Info[185].Min_Level = 33
		Mission.Info[185].Max_Level = 43

		Mission.Info[185].StartNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[185].Smapid,Mission.Info[185].Sx,Mission.Info[185].Sy,Mission.Info[185].Sz = 1434,-11620.508789063, -51.902290344238, 11.142639160156

		Mission.Info[185].EndNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[185].Emapid,Mission.Info[185].Ex,Mission.Info[185].Ey,Mission.Info[185].Ez = 1434,-11620.508789063, -51.902290344238, 11.142639160156
		Mission.Info[185].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[185] = function()
			Mobs_ID = {681}
			Mobs_Coord = 
			{
			{ -11648.89, 79.74737, 16.2452 },
			{ -11764.68, 15.64974, 22.8135 },
			{ -11578.47, 158.6179, 18.55413 },
			{ -11686.46, -46.5631, 15.55608 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎虎2
	    Mission.Info[186] = {}
		Mission.Info[186].Min_Level = 33
		Mission.Info[186].Max_Level = 43

		Mission.Info[186].StartNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[186].Smapid,Mission.Info[186].Sx,Mission.Info[186].Sy,Mission.Info[186].Sz = 1434,-11620.508789063, -51.902290344238, 11.142639160156

		Mission.Info[186].EndNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[186].Emapid,Mission.Info[186].Ex,Mission.Info[186].Ey,Mission.Info[186].Ez = 1434,-11620.508789063, -51.902290344238, 11.142639160156
		Mission.Info[186].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[186] = function()
			Mobs_ID = {682}
			Mobs_Coord = 
			{
			{ -11784.16, -688.9999, 40.93209 },
			{ -11855.14, -764.3093, 33.80068 },
			{ -11715.11, -776.4238, 35.5542 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎虎3
	    Mission.Info[187] = {}
		Mission.Info[187].Min_Level = 35
		Mission.Info[187].Max_Level = 43

		Mission.Info[187].StartNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[187].Smapid,Mission.Info[187].Sx,Mission.Info[187].Sy,Mission.Info[187].Sz = 1434,-11620.508789063, -51.902290344238, 11.142639160156

		Mission.Info[187].EndNPC = Check_Client("艾耶克·罗欧克","Ajeck Rouack")
		Mission.Info[187].Emapid,Mission.Info[187].Ex,Mission.Info[187].Ey,Mission.Info[187].Ez = 1434,-11620.508789063, -51.902290344238, 11.142639160156
		Mission.Info[187].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[187] = function()
			Mobs_ID = {1085}
			Mobs_Coord = 
			{
			{ -11832.01, 185.0187, 17.32015 },
			{ -11978.33, 176.2361, 15.16508 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎豹1
	    Mission.Info[190] = {}
		Mission.Info[190].Min_Level = 33
		Mission.Info[190].Max_Level = 43

		Mission.Info[190].StartNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[190].Smapid,Mission.Info[190].Sx,Mission.Info[190].Sy,Mission.Info[190].Sz = 1434,-11617.422851563, -48.013507843018, 10.973052024841

		Mission.Info[190].EndNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[190].Emapid,Mission.Info[190].Ex,Mission.Info[190].Ey,Mission.Info[190].Ez = 1434,-11617.422851563, -48.013507843018, 10.973052024841
		Mission.Info[190].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[190] = function()
			Mobs_ID = {683}
			Mobs_Coord = 
			{
			{ -11646.35, -371.4661, 15.49884 },
			{ -11714.28, -418.146, 18.78361 },
			{ -11599.29, -462.9434, 20.41858 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎豹2
	    Mission.Info[191] = {}
		Mission.Info[191].Min_Level = 33
		Mission.Info[191].Max_Level = 43

		Mission.Info[191].StartNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[191].Smapid,Mission.Info[191].Sx,Mission.Info[191].Sy,Mission.Info[191].Sz = 1434,-11617.422851563, -48.013507843018, 10.973052024841

		Mission.Info[191].EndNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[191].Emapid,Mission.Info[191].Ex,Mission.Info[191].Ey,Mission.Info[191].Ez = 1434,-11617.422851563, -48.013507843018, 10.973052024841
		Mission.Info[191].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[191] = function()
			Mobs_ID = {736}
			Mobs_Coord = 
			{
			{ -11546.176757813, 291.56420898438, 39.003074645996 },
			{ -11569.37109375, 370.15637207031, 44.338539123535 },
			{ -11688.700195313, 394.46737670898, 44.117687225342 },
			{ -11750.459960938, 381.94360351563, 44.364406585693 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎豹3
	    Mission.Info[192] = {}
		Mission.Info[192].Min_Level = 38
		Mission.Info[192].Max_Level = 43

		Mission.Info[192].StartNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[192].Smapid,Mission.Info[192].Sx,Mission.Info[192].Sy,Mission.Info[192].Sz = 1434,-11617.422851563, -48.013507843018, 10.973052024841

		Mission.Info[192].EndNPC = Check_Client("埃尔加丁爵士","Sir S. J. Erlgadin")
		Mission.Info[192].Emapid,Mission.Info[192].Ex,Mission.Info[192].Ey,Mission.Info[192].Ez = 1434,-11617.422851563, -48.013507843018, 10.973052024841
		Mission.Info[192].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[192] = function()
			Mobs_ID = {684}
			Mobs_Coord = 
			{
			{ -12289.24, -721.2285, 16.42788 },
			{ -12341.02, -719.5842, 17.427 },
			{ -12344.7, -783.6655, 32.90751 },
			{ -12325.4, -820.4417, 32.73768 },
			{ -12389.26, -814.9001, 33.29208 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎龙1
	    Mission.Info[194] = {}
		Mission.Info[194].Min_Level = 33
		Mission.Info[194].Max_Level = 43

		Mission.Info[194].StartNPC = 715
		Mission.Info[194].Smapid,Mission.Info[194].Sx,Mission.Info[194].Sy,Mission.Info[194].Sz = 1434,-11628.60546875, -54.556911468506, 10.939603805542

		Mission.Info[194].EndNPC = 715
		Mission.Info[194].Emapid,Mission.Info[194].Ex,Mission.Info[194].Ey,Mission.Info[194].Ez = 1434,-11628.60546875, -54.556911468506, 10.939603805542
		Mission.Info[194].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[194] = function()
			Mobs_ID = {685}
			Mobs_Coord = 
			{
			{ -11792.92, 424.1548, 47.39228 },
			{ -11869.68, 492.3004, 45.02847 },
			{ -11846.51, 673.3763, 45.87722 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎龙2
	    Mission.Info[195] = {}
		Mission.Info[195].Min_Level = 35
		Mission.Info[195].Max_Level = 43

		Mission.Info[195].StartNPC = 715
		Mission.Info[195].Smapid,Mission.Info[195].Sx,Mission.Info[195].Sy,Mission.Info[195].Sz = 1434,-11628.60546875, -54.556911468506, 10.939603805542

		Mission.Info[195].EndNPC = 715
		Mission.Info[195].Emapid,Mission.Info[195].Ex,Mission.Info[195].Ey,Mission.Info[195].Ez = 1434,-11628.60546875, -54.556911468506, 10.939603805542
		Mission.Info[195].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[195] = function()
			Mobs_ID = {686}
			Mobs_Coord = 
			{
			{ -12179.8, -145.6739, 16.36476 },
			{ -12072.47, -204.9903, 20.54469 },
			{ -12139.89, 214.8129, 15.76915 },
			{ -12048.75, 178.9295, 18.20256 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 猎龙3
	    Mission.Info[196] = {}
		Mission.Info[196].Min_Level = 40
		Mission.Info[196].Max_Level = 43

		Mission.Info[196].StartNPC = 715
		Mission.Info[196].Smapid,Mission.Info[196].Sx,Mission.Info[196].Sy,Mission.Info[196].Sz = 1434,-11628.60546875, -54.556911468506, 10.939603805542

		Mission.Info[196].EndNPC = 715
		Mission.Info[196].Emapid,Mission.Info[196].Ex,Mission.Info[196].Ey,Mission.Info[196].Ez = 1434,-11628.60546875, -54.556911468506, 10.939603805542
		Mission.Info[196].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[196] = function()
			Mobs_ID = {687}
			Mobs_Coord = 
			{
			{ -12830.15, 15.93515, 12.07738 },
			{ -12752.75, 84.94567, 10.85021 },
			{ -12835.77, 133.3213, 17.85523 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 荆棘谷 - 格罗姆高保卫战1
	    Mission.Info[568] = {}
		Mission.Info[568].Min_Level = 35
		Mission.Info[568].Max_Level = 45

		Mission.Info[568].StartNPC = Check_Client("指挥官阿格罗戈什","Commander Aggro'gosh")
		Mission.Info[568].Smapid,Mission.Info[568].Sx,Mission.Info[568].Sy,Mission.Info[568].Sz = 1434,-12395.1074, 165.7113, 2.7079

		Mission.Info[568].EndNPC = Check_Client("指挥官阿格罗戈什","Commander Aggro'gosh")
		Mission.Info[568].Emapid,Mission.Info[568].Ex,Mission.Info[568].Ey,Mission.Info[568].Ez = 1434,-12395.1074, 165.7113, 2.7079
		Mission.Info[568].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[568] = function()
			Mobs_ID = {686}
			Mobs_Coord = 
			{
			{ -12179.8, -145.6739, 16.36476 },
			{ -12072.47, -204.9903, 20.54469 },
			{ -12139.89, 214.8129, 15.76915 },
			{ -12048.75, 178.9295, 18.20256 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 荆棘谷 - 格罗姆高保卫战2
	    Mission.Info[569] = {}
		Mission.Info[569].Min_Level = 37
		Mission.Info[569].Max_Level = 45

		Mission.Info[569].StartNPC = Check_Client("指挥官阿格罗戈什","Commander Aggro'gosh")
		Mission.Info[569].Smapid,Mission.Info[569].Sx,Mission.Info[569].Sy,Mission.Info[569].Sz = 1434,-12395.1074, 165.7113, 2.7079

		Mission.Info[569].EndNPC = Check_Client("指挥官阿格罗戈什","Commander Aggro'gosh")
		Mission.Info[569].Emapid,Mission.Info[569].Ex,Mission.Info[569].Ey,Mission.Info[569].Ez = 1434,-12395.1074, 165.7113, 2.7079
		Mission.Info[569].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[569] = function()
			Mobs_ID = {1144,1142}
			Mobs_Coord = 
			{
			{ -12468.4727, -88.2002, 17.2659 },
			{ -12463.2393, -202.1888, 15.7293 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 恶性竞争
	    Mission.Info[213] = {}
		Mission.Info[213].Min_Level = 39
		Mission.Info[213].Max_Level = 45

		Mission.Info[213].StartNPC = Check_Client("科博克","Kebok")
		Mission.Info[213].Smapid,Mission.Info[213].Sx,Mission.Info[213].Sy,Mission.Info[213].Sz = 1434,-14449.833984375, 497.92529296875, 26.282745361328

		Mission.Info[213].EndNPC = Check_Client("科博克","Kebok")
		Mission.Info[213].Emapid,Mission.Info[213].Ex,Mission.Info[213].Ey,Mission.Info[213].Ez = 1434,-14449.833984375, 497.92529296875, 26.282745361328
		Mission.Info[213].Slot_Choose = 1 -- 选择奖励

		Mission.Info[213].ValidItem = Check_Client("打磨过的水晶","Tumbled Crystal")

		Mission.Execute[213] = function()
			Mobs_ID = {1096,4260}
			Mobs_Coord = 
			{
			{ -11945.866210938, -634.35168457031, 15.4366979599 },
			{ -12021.223632813, -722.27655029297, 15.124855041504 },
			{ -12092.268554688, -708.80450439453, 15.35326385498 },
			{ -12148.209960938, -655.07598876953, 15.703637123108 },
			{ -12149.71875, -581.72607421875, 13.696750640869 },
			{ -12111.713867188, -521.470703125, 15.268515586853 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 荆棘谷 - 摩克萨尔丁的魔法1
	    Mission.Info[570] = {}
		Mission.Info[570].Min_Level = 38
		Mission.Info[570].Max_Level = 45

		Mission.Info[570].StartNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[570].Smapid,Mission.Info[570].Sx,Mission.Info[570].Sy,Mission.Info[570].Sz = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[570].EndNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[570].Emapid,Mission.Info[570].Ex,Mission.Info[570].Ey,Mission.Info[570].Ez = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[570].Slot_Choose = 1 -- 选择奖励

		Mission.Info[570].ValidItem = {Check_Client("深喉猎豹的爪子","Shadowmaw Claw"),Check_Client("雌虎的牙齿","Pristine Tigress Fang")}

		Mission.Execute[570] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 684
				Mobs_Coord = {
				{ -12289.24, -721.2285, 16.42788 },
				{ -12341.02, -719.5842, 17.427 },
				{ -12344.7, -783.6655, 32.90751 },
				{ -12325.4, -820.4417, 32.73768 },
				{ -12389.26, -814.9001, 33.29208 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 772
				Mobs_Coord = {
			    { -12513.6035, -398.6194, 11.9662 },
				{ -12554.6211, -338.0836, 15.2034 },
				{ -12605.1201, -304.1652, 14.8477 },
				{ -12661.3516, -340.8416, 15.7762 },
				{ -12694.5049, -388.3169, 13.3860 },
			    }
			end

			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 荆棘谷 - 摩克萨尔丁的魔法2
	    Mission.Info[572] = {}
		Mission.Info[572].Min_Level = 38
		Mission.Info[572].Max_Level = 45

		Mission.Info[572].StartNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[572].Smapid,Mission.Info[572].Sx,Mission.Info[572].Sy,Mission.Info[572].Sz = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[572].EndNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[572].Emapid,Mission.Info[572].Ex,Mission.Info[572].Ey,Mission.Info[572].Ez = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[572].Slot_Choose = 1 -- 选择奖励

		Mission.Info[572].ValidItem = Check_Client("丛林捕猎者的羽毛","Jungle Stalker Feather")

		Mission.Execute[572] = function()
			Mobs_ID = {687}
			Mobs_Coord = 
			{
			{ -12830.15, 15.93515, 12.07738 },
			{ -12752.75, 84.94567, 10.85021 },
			{ -12835.77, 133.3213, 17.85523 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 部落 荆棘谷 - 摩克萨尔丁的魔法3
	    Mission.Info[571] = {}
		Mission.Info[571].Min_Level = 38
		Mission.Info[571].Max_Level = 45

		Mission.Info[571].StartNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[571].Smapid,Mission.Info[571].Sx,Mission.Info[571].Sy,Mission.Info[571].Sz = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[571].EndNPC = Check_Client("先知摩克萨尔丁","Far Seer Mok'thardin")
		Mission.Info[571].Emapid,Mission.Info[571].Ex,Mission.Info[571].Ey,Mission.Info[571].Ez = 1434,-12412.8467, 171.2354, 3.3292
		Mission.Info[571].Slot_Choose = 1 -- 选择奖励

		Mission.Info[571].ValidItem = Check_Client("成年大猩猩的肌腱","Aged Gorilla Sinew")

		Mission.Execute[571] = function()
			Mobs_ID = {1557, 858, 767}
			Mobs_Coord = 
			{
			{ -14017.536132813, 192.39897155762, 12.878389358521 },
			{ -14028.381835938, 101.11884307861, 10.01810836792 },
			{ -13975.932617188, 60.401435852051, 13.56217956543 },
			{ -13909.1796875, 50.019962310791, 16.33051109314 },
			{ -13843.962890625, 93.376243591309, 18.91771697998 },
			{ -13989.749023438, 184.98622131348, 14.912951469421 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 歌唱水晶碎片
	    Mission.Info[605] = {}
		Mission.Info[605].Min_Level = 41
		Mission.Info[605].Max_Level = 45

		Mission.Info[605].StartNPC = Check_Client("克兰克·菲兹巴布","Crank Fizzlebub")
		Mission.Info[605].Smapid,Mission.Info[605].Sx,Mission.Info[605].Sy,Mission.Info[605].Sz = 1434,-14453.356445313, 490.26193237305, 15.125855445862

		Mission.Info[605].EndNPC = Check_Client("克兰克·菲兹巴布","Crank Fizzlebub")
		Mission.Info[605].Emapid,Mission.Info[605].Ex,Mission.Info[605].Ey,Mission.Info[605].Ez = 1434,-14453.356445313, 490.26193237305, 15.125855445862
		Mission.Info[605].Slot_Choose = 1 -- 选择奖励

		Mission.Info[605].ValidItem = Check_Client("歌唱水晶碎片","Singing Crystal Shard")

		Mission.Execute[605] = function()
			Mobs_ID = {688,689}
			Mobs_Coord = 
			{
			{ -11950.798828125, 440.57461547852, 23.717008590698 },
			{ -11947.848632813, 540.33117675781, 25.166229248047 },
			{ -11914.698242188, 598.28961181641, 25.37407875061 },
			{ -11892.641601563, 653.81903076172, 23.855152130127 },
			{ -11888.955078125, 716.35229492188, 25.916555404663 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 风险投资公司
	    Mission.Info[600] = {}
		Mission.Info[600].Min_Level = 41
		Mission.Info[600].Max_Level = 45

		Mission.Info[600].StartNPC = Check_Client("克兰克·菲兹巴布","Crank Fizzlebub")
		Mission.Info[600].Smapid,Mission.Info[600].Sx,Mission.Info[600].Sy,Mission.Info[600].Sz = 1434,-14453.356445313, 490.26193237305, 15.125855445862

		Mission.Info[600].EndNPC = Check_Client("克兰克·菲兹巴布","Crank Fizzlebub")
		Mission.Info[600].Emapid,Mission.Info[600].Ex,Mission.Info[600].Ey,Mission.Info[600].Ez = 1434,-14453.356445313, 490.26193237305, 15.125855445862
		Mission.Info[600].Slot_Choose = 1 -- 选择奖励

		Mission.Info[600].ValidItem = Check_Client("蓝色歌唱水晶","Singing Blue Crystal")

		Mission.Execute[600] = function()
			Mobs_ID = {674,675,677}
			Mobs_Coord = 
			{
			{ -12930.5, -432.272, 31.85675 },
			{ -13035.7, -407.856, 42.91424 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 鼻烟
	    Mission.Info[587] = {}
		Mission.Info[587].Min_Level = 42
		Mission.Info[587].Max_Level = 45

		Mission.Info[587].StartNPC = Check_Client("迪格","Deeg")
		Mission.Info[587].Smapid,Mission.Info[587].Sx,Mission.Info[587].Sy,Mission.Info[587].Sz = 1434,-14459.245117188, 502.99951171875, 26.272928237915

		Mission.Info[587].EndNPC = Check_Client("迪格","Deeg")
		Mission.Info[587].Emapid,Mission.Info[587].Ex,Mission.Info[587].Ey,Mission.Info[587].Ez = 1434,-14459.245117188, 502.99951171875, 26.272928237915
		Mission.Info[587].Slot_Choose = 1 -- 选择奖励

		Mission.Info[587].ValidItem = Check_Client("鼻烟","Snuff")

		Mission.Execute[587] = function()
			Mobs_ID = {1561,1562,1563,1564}
			Mobs_Coord = 
			{
			{ -14449.89, 115.2673, 5.115073 },
			{ -14316.06, 101.388, 3.315305 },
			{ -14548.6, 181.4139, 2.740773 },
			{ -14659.615234375, 294.83306884766, 3.6648206710815 },
			{ -14689.92578125, 429.30059814453, 1.0784224271774 },
			{ -14736.715820313, 502.21221923828, 3.532420873642 },	
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 吓唬病鬼
	    Mission.Info[606] = {}
		Mission.Info[606].Min_Level = 41
		Mission.Info[606].Max_Level = 45

		Mission.Info[606].StartNPC = Check_Client("“海狼”马克基雷",[["Sea Wolf" MacKinley]])
		Mission.Info[606].Smapid,Mission.Info[606].Sx,Mission.Info[606].Sy,Mission.Info[606].Sz = 1434,-14447.416992188, 448.00137329102, 15.63452911377

		Mission.Info[606].EndNPC = Check_Client("“病鬼”菲利普",[["Shaky" Phillipe]])
		Mission.Info[606].Emapid,Mission.Info[606].Ex,Mission.Info[606].Ey,Mission.Info[606].Ez = 1434,-14299.418945313, 504.57727050781, 8.9710502624512
		Mission.Info[606].Slot_Choose = 1 -- 选择奖励

		Mission.Info[606].ValidItem = Check_Client("薄雾谷猩猩的内脏","Mistvale Giblets")

		Mission.Execute[606] = function()
			Mobs_ID = {1557, 858, 767}
			Mobs_Coord = 
			{
			{ -14017.536132813, 192.39897155762, 12.878389358521 },
			{ -14028.381835938, 101.11884307861, 10.01810836792 },
			{ -13975.932617188, 60.401435852051, 13.56217956543 },
			{ -13909.1796875, 50.019962310791, 16.33051109314 },
			{ -13843.962890625, 93.376243591309, 18.91771697998 },
			{ -13989.749023438, 184.98622131348, 14.912951469421 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 荆棘谷 - 向马克基雷回报
	    Mission.Info[607] = {}
		Mission.Info[607].Min_Level = 41
		Mission.Info[607].Max_Level = 45

		Mission.Info[607].StartNPC = Check_Client("“病鬼”菲利普",[["Shaky" Phillipe]])
		Mission.Info[607].Smapid,Mission.Info[607].Sx,Mission.Info[607].Sy,Mission.Info[607].Sz = 1434,-14299.418945313, 504.57727050781, 8.9710502624512

		Mission.Info[607].EndNPC = Check_Client("“海狼”马克基雷",[["Sea Wolf" MacKinley]])
		Mission.Info[607].Emapid,Mission.Info[607].Ex,Mission.Info[607].Ey,Mission.Info[607].Ez = 1434,-14447.416992188, 448.00137329102, 15.63452911377
		Mission.Info[607].Slot_Choose = 1 -- 选择奖励

		Mission.Info[607].ValidItem = Check_Client("菲利浦的还款","Shaky's Payment")

	-- 双方 荆棘谷 - 一捆海蛇草
	    Mission.Info[617] = {}
		Mission.Info[617].Min_Level = 44
		Mission.Info[617].Max_Level = 45

		Mission.Info[617].StartNPC = Check_Client("海盗布劳兹",[[Privateer Bloads]])
		Mission.Info[617].Smapid,Mission.Info[617].Sx,Mission.Info[617].Sy,Mission.Info[617].Sz = 1434,-14418.234375, 513.46179199219, 4.9805459976196

		Mission.Info[617].EndNPC = Check_Client("海盗布劳兹",[[Privateer Bloads]])
		Mission.Info[617].Emapid,Mission.Info[617].Ex,Mission.Info[617].Ey,Mission.Info[617].Ez = 1434,-14418.234375, 513.46179199219, 4.9805459976196
		Mission.Info[617].Slot_Choose = 1 -- 选择奖励

		Mission.Info[617].ValidItem = Check_Client("海蛇草","Akiris Reed")

		Mission.Execute[617] = function()
			Mobs_ID = {1907}
			Mobs_Coord = 
			{
			{ -13913.43, 659.749, 10.0505 },
			{ -13879.91, 622.181, 23.99511 },
			{ -13745.62, 621.9655, 15.27303 },
			{ -13746.26, 539.2366, 45.81221 },
			}
			Mobs_MapID = 1434
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 废土的公正1
	    Mission.Info[1690] = {}
		Mission.Info[1690].Min_Level = 46
		Mission.Info[1690].Max_Level = 50

		Mission.Info[1690].StartNPC = 7407
		Mission.Info[1690].Smapid,Mission.Info[1690].Sx,Mission.Info[1690].Sy,Mission.Info[1690].Sz = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715

		Mission.Info[1690].EndNPC = 7407
		Mission.Info[1690].Emapid,Mission.Info[1690].Ex,Mission.Info[1690].Ey,Mission.Info[1690].Ez = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715
		Mission.Info[1690].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[1690] = function()
			Mobs_ID = {5618,5616}
			Mobs_Coord = 
			{
			{ -7009.101, -4358.335, 9.794332 },
			{ -6954.234, -4356.155, 11.25837 },
			{ -6953.513, -4417.397, 11.26283 },
			{ -7409.34, -4584.32, 8.831115 },
			}
			Mobs_MapID = 1446
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 废土的公正2
	    Mission.Info[1691] = {}
		Mission.Info[1691].Min_Level = 46
		Mission.Info[1691].Max_Level = 50

		Mission.Info[1691].StartNPC = 7407
		Mission.Info[1691].Smapid,Mission.Info[1691].Sx,Mission.Info[1691].Sy,Mission.Info[1691].Sz = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715

		Mission.Info[1691].EndNPC = 7407
		Mission.Info[1691].Emapid,Mission.Info[1691].Ex,Mission.Info[1691].Ey,Mission.Info[1691].Ez = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715
		Mission.Info[1691].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[1691] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 5623
				Mobs_ID[#Mobs_ID + 1] = 5617
				Mobs_ID[#Mobs_ID + 1] = 5615
				Mobs_ID[#Mobs_ID + 1] = 7847
				Mobs_Coord = {
				{ -7617.348, -4634.288, 9.605574 },
				{ -7584.054, -4609.758, 10.33483 },
				{ -7567.99, -4715.201, 10.57014 },
				{ -7392.966, -4429.778, 12.06491 },
				{ -7551.129, -4284.086, 9.477499 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 5623
				Mobs_ID[#Mobs_ID + 1] = 7847
				Mobs_Coord = {
			    { -7595.35, -4364.916, 9.693474 },
				{ -7647.42, -4311.488, 9.077011 },
				{ -7645.074, -4400.289, 11.6368 },
			    }
			end

			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = 5617
				Mobs_ID[#Mobs_ID + 1] = 7847
				Mobs_Coord = {
			    { -7583.647, -4253.99, 9.550691 },
				{ -7688.061, -4254.031, 9.436271 },
				{ -7688.636, -4421.888, 10.5853 },
			    }
			end

			Mobs_MapID = 1446
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 收集水袋
	    Mission.Info[1707] = {}
		Mission.Info[1707].Min_Level = 46
		Mission.Info[1707].Max_Level = 50

		Mission.Info[1707].StartNPC = Check_Client("操作员鲁格伦克","Privateer Bloads")
		Mission.Info[1707].Smapid,Mission.Info[1707].Sx,Mission.Info[1707].Sy,Mission.Info[1707].Sz = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715

		Mission.Info[1707].EndNPC = Check_Client("操作员鲁格伦克","Privateer Bloads")
		Mission.Info[1707].Emapid,Mission.Info[1707].Ex,Mission.Info[1707].Ey,Mission.Info[1707].Ez = 1446,-7186.6391601563, -3838.5986328125, 8.6642417907715
		Mission.Info[1707].Slot_Choose = 1 -- 选择奖励

		Mission.Info[1707].ValidItem = Check_Client("废土水袋","Wastewander Water Pouch")

		Mission.Execute[1707] = function()
			Mobs_ID = {5618,5616}
			Mobs_Coord = 
			{
			{ -7009.101, -4358.335, 9.794332 },
			{ -6954.234, -4356.155, 11.25837 },
			{ -6953.513, -4417.397, 11.26283 },
			{ -7409.34, -4584.32, 8.831115 },
			}
			Mobs_MapID = 1446
			Black_Spot = {}

			
			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 海盗的帽子！
	    Mission.Info[8365] = {}
		Mission.Info[8365].Min_Level = 46
		Mission.Info[8365].Max_Level = 50

		Mission.Info[8365].StartNPC = Check_Client("傲慢的店主","Haughty Modiste")
		Mission.Info[8365].Smapid,Mission.Info[8365].Sx,Mission.Info[8365].Sy,Mission.Info[8365].Sz = 1446,-6899.216796875, -4811.37890625, 8.6669826507568

		Mission.Info[8365].EndNPC = Check_Client("傲慢的店主","Haughty Modiste")
		Mission.Info[8365].Emapid,Mission.Info[8365].Ex,Mission.Info[8365].Ey,Mission.Info[8365].Ez = 1446,-6899.216796875, -4811.37890625, 8.6669826507568
		Mission.Info[8365].Slot_Choose = 1 -- 选择奖励

		Mission.Info[8365].ValidItem = Check_Client("南海海盗帽","Southsea Pirate Hat")

		Mission.Execute[8365] = function()
			Mobs_ID = {7855,7856,7857,7858}
			Mobs_Coord = 
			{
			{ -7893.136, -5190.024, 2.730446 },
			{ -7855.76, -5108.79, 6.833609 },
			{ -7976.93, -5187.187, 1.860373 },
			{ -8016.263, -5275.582, 0.6147336 },
			}
			Mobs_MapID = 1446
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 南海复仇
	    Mission.Info[8366] = {}
		Mission.Info[8366].Min_Level = 46
		Mission.Info[8366].Max_Level = 50

		Mission.Info[8366].StartNPC = Check_Client("安全主管吉罗姆·比格维兹","Security Chief Bilgewhizzle")
		Mission.Info[8366].Smapid,Mission.Info[8366].Sx,Mission.Info[8366].Sy,Mission.Info[8366].Sz = 1446,-6974.0087890625, -4845.6899414063, 7.9859747886658

		Mission.Info[8366].EndNPC = Check_Client("安全主管吉罗姆·比格维兹","Security Chief Bilgewhizzle")
		Mission.Info[8366].Emapid,Mission.Info[8366].Ex,Mission.Info[8366].Ey,Mission.Info[8366].Ez = 1446,-6974.0087890625, -4845.6899414063, 7.9859747886658
		Mission.Info[8366].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[8366] = function()
			Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 7855
				Mobs_ID[#Mobs_ID + 1] = 7856
				Mobs_ID[#Mobs_ID + 1] = 7857
				Mobs_ID[#Mobs_ID + 1] = 7858
				Mobs_Coord = {
				{ -7994.5581054688, -5287.3393554688, 0.57632333040237 },
				{ -8006.248046875, -5356.1010742188, 0.61141049861908 },
				{ -8060.298828125, -5305.32421875, 0.67434948682785 },
				{ -8074.8994140625, -5264.7763671875, 0.6278954744339 },
				{ -8076.216796875, -5205.48828125, 3.8292253017426 },
				{ -8052.5463867188, -5209.4604492188, 1.2437551021576 },
				{ -8014.99609375, -5244.8999023438, 0.64129287004471 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 7855
				Mobs_ID[#Mobs_ID + 1] = 7856
				Mobs_ID[#Mobs_ID + 1] = 7857
				Mobs_ID[#Mobs_ID + 1] = 7858
				Mobs_Coord = {
			    { -7994.5581054688, -5287.3393554688, 0.57632333040237 },
				{ -8006.248046875, -5356.1010742188, 0.61141049861908 },
				{ -8060.298828125, -5305.32421875, 0.67434948682785 },
				{ -8074.8994140625, -5264.7763671875, 0.6278954744339 },
				{ -8076.216796875, -5205.48828125, 3.8292253017426 },
				{ -8052.5463867188, -5209.4604492188, 1.2437551021576 },
				{ -8014.99609375, -5244.8999023438, 0.64129287004471 },
			    }
			end

			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = 7855
				Mobs_ID[#Mobs_ID + 1] = 7856
				Mobs_ID[#Mobs_ID + 1] = 7857
				Mobs_ID[#Mobs_ID + 1] = 7858
				Mobs_Coord = {
			    { -7994.5581054688, -5287.3393554688, 0.57632333040237 },
				{ -8006.248046875, -5356.1010742188, 0.61141049861908 },
				{ -8060.298828125, -5305.32421875, 0.67434948682785 },
				{ -8074.8994140625, -5264.7763671875, 0.6278954744339 },
				{ -8076.216796875, -5205.48828125, 3.8292253017426 },
				{ -8052.5463867188, -5209.4604492188, 1.2437551021576 },
				{ -8014.99609375, -5244.8999023438, 0.64129287004471 },
			    }
			end

			if not Mission.Text[4].finished then
			    Mobs_ID[#Mobs_ID + 1] = 7855
				Mobs_ID[#Mobs_ID + 1] = 7856
				Mobs_ID[#Mobs_ID + 1] = 7857
				Mobs_ID[#Mobs_ID + 1] = 7858
				Mobs_Coord = {
			    { -8014.72, -5215.52, 2.23529 },
				{ -8082.063, -5265.415, 0.6388634 },
				{  -7996.1709,  -5393.3740,  1.1206 },
			    }
			end
			Mobs_MapID = 1446
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 口渴的地精
	    Mission.Info[2605] = {}
		Mission.Info[2605].Min_Level = 49
		Mission.Info[2605].Max_Level = 50

		Mission.Info[2605].StartNPC = Check_Client("马林·诺格弗格","Marin Noggenfogger")
		Mission.Info[2605].Smapid,Mission.Info[2605].Sx,Mission.Info[2605].Sy,Mission.Info[2605].Sz = 1446,-7193.4224,  -3793.4822,  9.6798

		Mission.Info[2605].EndNPC = Check_Client("马林·诺格弗格","Marin Noggenfogger")
		Mission.Info[2605].Emapid,Mission.Info[2605].Ex,Mission.Info[2605].Ey,Mission.Info[2605].Ez = 1446,-7193.4224,  -3793.4822,  9.6798
		Mission.Info[2605].Slot_Choose = 1 -- 选择奖励

		Mission.Info[2605].ValidItem = Check_Client("饱满的露水腺","Laden Dew Gland")

		Mission.Execute[2605] = function()
			Mobs_ID = {5481}
			Mobs_Coord = 
			{
			{ -8807.1, -2281.327, 8.881041 },
			{ -8912.646, -2190.575, 8.915486 },
			{ -8978.965, -2214.72, 9.144907 },
			}
			Mobs_MapID = 1446
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 好味道
	    Mission.Info[2606] = {}
		Mission.Info[2606].Min_Level = 49
		Mission.Info[2606].Max_Level = 50

		Mission.Info[2606].StartNPC = Check_Client("马林·诺格弗格","Marin Noggenfogger")
		Mission.Info[2606].Smapid,Mission.Info[2606].Sx,Mission.Info[2606].Sy,Mission.Info[2606].Sz = 1446,-7193.4224, -3793.4822, 9.6798

		Mission.Info[2606].EndNPC = Check_Client("斯普琳科","Sprinkle")
		Mission.Info[2606].Emapid,Mission.Info[2606].Ex,Mission.Info[2606].Ey,Mission.Info[2606].Ez = 1446, -7111.1089, -3741.7766, 8.5263
		Mission.Info[2606].Slot_Choose = 1 -- 选择奖励

		Mission.Info[2606].ValidItem = Check_Client("灌木露水","Thistleshrub Dew")

	-- 双方 塔纳利斯 - 砂槌食人魔
	    Mission.Info[5863] = {}
		Mission.Info[5863].Min_Level = 49
		Mission.Info[5863].Max_Level = 50

		Mission.Info[5863].StartNPC = Check_Client("安迪·利恩","Andi Lynn")
		Mission.Info[5863].Smapid,Mission.Info[5863].Sx,Mission.Info[5863].Sy,Mission.Info[5863].Sz = 1446,-7135.4775,  -3863.1086,  9.4317

		Mission.Info[5863].EndNPC = Check_Client("安迪·利恩","Andi Lynn")
		Mission.Info[5863].Emapid,Mission.Info[5863].Ex,Mission.Info[5863].Ey,Mission.Info[5863].Ez = 1446,-7135.4775,  -3863.1086,  9.4317
		Mission.Info[5863].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[5863] = function()
			Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 5474
				Mobs_Coord = {
				{ -8197.253, -3013.958, 13.94667 },
				{ -8315.76, -3121.82, 8.643859 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 5472
				Mobs_Coord = {
			    { -8361.659, -3020.637, 8.673813 },
				{ -8481.89, -3053.726, 10.52962 },
			    }
			end

			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = 12046
				Mobs_Coord = {
			    { -8534.26, -3082.25, 8.701457 },
			    }
			end
			Mobs_MapID = 1446
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 双方 塔纳利斯 - 灌木谷
	    Mission.Info[3362] = {}
		Mission.Info[3362].Min_Level = 50
		Mission.Info[3362].Max_Level = 50

		Mission.Info[3362].StartNPC = Check_Client("特兰雷克","Tran'rek")
		Mission.Info[3362].Smapid,Mission.Info[3362].Sx,Mission.Info[3362].Sy,Mission.Info[3362].Sz = 1446,-7105.8398,  -3776.8347,  8.7097

		Mission.Info[3362].EndNPC = Check_Client("特兰雷克","Tran'rek")
		Mission.Info[3362].Emapid,Mission.Info[3362].Ex,Mission.Info[3362].Ey,Mission.Info[3362].Ez = 1446,-7105.8398,  -3776.8347,  8.7097
		Mission.Info[3362].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[3362] = function()
			Mobs_ID = {5490,5485,5481}
			Mobs_Coord = 
			{
			{ -8807.1, -2281.327, 8.881041 },
			{ -8912.646, -2190.575, 8.915486 },
			{ -8978.965, -2214.72, 9.144907 },
			{ -8846.526, -2246.773, 11.34692 },
			{ -8912.646, -2190.575, 8.915486 },	
			}
		    
			Mobs_MapID = 1446
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 矮人的交易
	    local Mission_Current_ID = 179
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 658
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6214,328,383

		Mission.Info[Mission_Current_ID].EndNPC = 658
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6214,328,383
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("硬狼肉","Tough Wolf Meat")

		Mission.Execute[Mission_Current_ID] = function()
			Mobs_ID = {705}
			Mobs_Coord = 
			{
			{ -6298.688, 383.0619, 380.5989 },
			{ -6245.87, 395.645, 385.851 },
			}
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 新的威胁
	    local Mission_Current_ID = 170
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 713
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6216.5302734375, 339.00152587891, 383.27093505859

		Mission.Info[Mission_Current_ID].EndNPC = 713
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6216.5302734375, 339.00152587891, 383.27093505859
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 707
				Mobs_Coord = {
				{ -6425.751, 379.5114, 388.1526 },
			    { -6336.913, 301.5876, 379.9715 },
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 724
				Mobs_Coord = {
			    { -6248.37, 513.557, 386.3719 },
				{ -6313.75, 661.829, 385.956 },
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 寒脊山谷的送信任务
	    local Mission_Current_ID = 233
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 658
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6214.853515625, 328.18121337891, 383.48596191406

		Mission.Info[Mission_Current_ID].EndNPC = 714
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6222.47, 688.973, 384.9191
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("一摞信件","A Stack of Letters")

	-- 侏儒 丹莫罗 - 寒脊山谷的送信任务2
	    local Mission_Current_ID = 234
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 714
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6222.47, 688.973, 384.9191

		Mission.Info[Mission_Current_ID].EndNPC = 786
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6363, 567.085, 385.7677
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("给格瑞林·白须的信","A Letter to Grelin Whitebeard")

	-- 侏儒 丹莫罗 - 猎杀野猪
	    local Mission_Current_ID = 183
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 714
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6222.47, 688.973, 384.9191

		Mission.Info[Mission_Current_ID].EndNPC = 714
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6222.47, 688.973, 384.9191
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 708
				Mobs_Coord = {
				{ -6203.726, 588.9388, 388.308 },
				{ -6151.559, 719.2426, 392.1659 },
				{ -6223.63, 724.0927, 386.9388 },
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 逃难者的困境
	    local Mission_Current_ID = 3361
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 8416
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6098.494140625, 396.29983520508, 395.54037475586

		Mission.Info[Mission_Current_ID].EndNPC = 8416
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6098.494140625, 396.29983520508, 395.54037475586
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = {Check_Client("菲利克斯的盒子","Felix's Box"), Check_Client("菲利克斯的箱子","Felix's Chest"), Check_Client("菲利克斯的螺钉桶","Felix's Bucket of Bolts")}

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 148499
				Mobs_Coord = {
				{ -6381.01, 775.867, 386.2132 }
			    }
			end
			if not Mission.Text[2].finished then
			    Mobs_ID[#Mobs_ID + 1] = 178084
				Mobs_Coord = {
				{ -6502.56, 676.646, 387.2743 },
			    }
			end
			if not Mission.Text[3].finished then
			    Mobs_ID[#Mobs_ID + 1] = 178085
				Mobs_Coord = {
				{ -6477.463, 506.0959, 385.9102 },
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Gather_Items()
		end

	-- 侏儒 丹莫罗 - 巨魔洞穴
	    local Mission_Current_ID = 182
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 786
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6363, 567.085, 385.7677

		Mission.Info[Mission_Current_ID].EndNPC = 786
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6363, 567.085, 385.7677
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 706
				Mobs_Coord = {
				{ -6477.463, 506.0959, 385.9102 },
				{ -6502.56, 676.646, 387.2743 },
				{ -6381.01, 775.867, 386.2132 },
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 被窃取的日记
	    local Mission_Current_ID = 218
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 786
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6363, 567.085, 385.7677

		Mission.Info[Mission_Current_ID].EndNPC = 786
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6363, 567.085, 385.7677
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("格瑞林·白须的日记","Grelin Whitebeard's Journal")

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = 808
				Mobs_Coord = {
				{ -6508.82, 300.758, 370.346 },
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 森内尔的观察站
	    local Mission_Current_ID = 282
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 786
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6363, 567.085, 385.7677

		Mission.Info[Mission_Current_ID].EndNPC = 1965
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6235.87, 152.989, 428.3168
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("格瑞林的报告","Grelin's Report")

	-- 侏儒 丹莫罗 - 热酒快递
	    local Mission_Current_ID = 3364
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 12738
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6371.1313476563, 571.81591796875, 385.74417114258

		Mission.Info[Mission_Current_ID].EndNPC = 836
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6056.38, 385.213, 392.7624
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("德南的热酒","Durnan's Scalding Mornbrew")

	-- 侏儒 丹莫罗 - 归还酒杯
	    local Mission_Current_ID = 3365
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1
		Mission.Info[Mission_Current_ID].Max_Level = 7

		Mission.Info[Mission_Current_ID].StartNPC = 836
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6056.38, 385.213, 392.7624

		Mission.Info[Mission_Current_ID].EndNPC = 12738
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6371.1313476563, 571.81591796875, 385.74417114258
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = Check_Client("诺里斯的杯子","Nori's Mug")

	-- 侏儒 丹莫罗 - 森内尔的观察站
	    local Mission_Current_ID = 420
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 10

		Mission.Info[Mission_Current_ID].StartNPC = 1965
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6235.7749,152.9201,428.3425

		Mission.Info[Mission_Current_ID].EndNPC = 1252
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5644.3599,-499.2207,396.6697
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2619

	-- 侏儒 丹莫罗 - 塔诺克的补给品
	    local Mission_Current_ID = 2160
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 10

		Mission.Info[Mission_Current_ID].StartNPC = 6782
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-6249.2432,135.1621,431.6005

		Mission.Info[Mission_Current_ID].EndNPC = 6806
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5591.3442,-523.5645,399.6528
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = "7646"

	-- 侏儒 丹莫罗 - 贝尔丁的工具
	    local Mission_Current_ID = 400
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('萨雷克·黑石','Tharek Blackstone')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5573,-464,401

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('贝尔丁·钢架','Beldin Steelgrill')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5488,-682,394
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2999

	-- 侏儒 丹莫罗 - 海格纳的弹药
	    local Mission_Current_ID = 5541
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('罗斯洛·鲁治','Loslor Rudge')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5499,-664,395

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('海格纳·重枪','Hegnar Rumbleshot')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-6015,-201,407
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 13850

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = Check_Client("弹药箱","Ammo Crate")
				Mobs_Coord = {
				{-5745.49, -370.75, 365.90}
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Gather_Items()
		end

	-- 侏儒 丹莫罗 - 灰色洞穴
	    local Mission_Current_ID = 313
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('驾驶员迪恩·石轮','Pilot Stonegear')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5473,-641,393

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('驾驶员迪恩·石轮','Pilot Stonegear')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5473,-641,393
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2671

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
			    Mobs_ID[#Mobs_ID + 1] = Check_Client("雪怪","Wendigo")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("雪怪幼崽","Young Wendigo")
				Mobs_Coord = {
				{-5695.309570, -296.212097, 364.711395},
				{-5609.870605, -270.285767, 367.818420},

				{-5695.309570, -296.212097, 364.711395},
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 贝尔丁的补给
	    local Mission_Current_ID = 317
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('驾驶员贝隆·风箱','Pilot Bellowfiz')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5466,-632,393

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('驾驶员贝隆·风箱','Pilot Bellowfiz')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5466,-632,393
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = {769,6952}

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("大峭壁野猪","Large Crag Boar")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("老峭壁野猪","Elder Crag Boar")
				Mobs_Coord = {
				{-5526.463379, -598.597778, 406.693176},
				{-5555.305176, -644.095703, 406.903015},
				{-5595.618164, -673.093872, 406.578888},
				{-5646.822266, -646.062744, 402.661804},
				{-5680.976074, -607.648560, 402.619476},
				{-5724.496582, -578.821228, 399.850037},
				{-5776.788574, -590.487610, 398.069122},
				{-5806.188477, -632.758301, 398.554413},
				{-5838.509277, -672.523376, 398.793396},
				{-5882.794922, -649.639465, 398.518616},
				{-5920.274902, -616.058777, 400.480286},
				{-5949.629883, -572.330566, 404.565674},
				{-5959.709473, -523.118469, 408.067719},
				{-5961.766113, -474.228912, 407.404388},
				{-5911.418945, -464.715363, 412.568207},
				{-5865.885254, -489.453888, 408.591675},
				{-5820.780273, -515.092896, 404.547943},
				{-5799.371582, -559.635254, 399.884857},
				{-5750.312988, -563.467773, 398.477478},
				{-5706.854980, -541.258484, 398.751587},
				{-5658.026367, -517.788147, 401.581940},
				{-5606.741211, -495.234131, 398.719788},
				{-5557.425781, -499.793884, 400.407806},

				{-5526.463379, -598.597778, 406.693176},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("黑熊幼崽","Young Black Bear")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("冰爪熊","Ice Claw Bear")
				Mobs_Coord = {
				{-5526.463379, -598.597778, 406.693176},
				{-5555.305176, -644.095703, 406.903015},
				{-5595.618164, -673.093872, 406.578888},
				{-5646.822266, -646.062744, 402.661804},
				{-5680.976074, -607.648560, 402.619476},
				{-5724.496582, -578.821228, 399.850037},
				{-5776.788574, -590.487610, 398.069122},
				{-5806.188477, -632.758301, 398.554413},
				{-5838.509277, -672.523376, 398.793396},
				{-5882.794922, -649.639465, 398.518616},
				{-5920.274902, -616.058777, 400.480286},
				{-5949.629883, -572.330566, 404.565674},
				{-5959.709473, -523.118469, 408.067719},
				{-5961.766113, -474.228912, 407.404388},
				{-5911.418945, -464.715363, 412.568207},
				{-5865.885254, -489.453888, 408.591675},
				{-5820.780273, -515.092896, 404.547943},
				{-5799.371582, -559.635254, 399.884857},
				{-5750.312988, -563.467773, 398.477478},
				{-5706.854980, -541.258484, 398.751587},
				{-5658.026367, -517.788147, 401.581940},
				{-5606.741211, -495.234131, 398.719788},
				{-5557.425781, -499.793884, 400.407806},

				{-5526.463379, -598.597778, 406.693176},
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 艾沃沙酒1
	    local Mission_Current_ID = 318
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('驾驶员贝隆·风箱','Pilot Bellowfiz')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5466,-632,393

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('雷杰德·麦酒','Rejold Barleybrew')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5378,315,394
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2999

	-- 侏儒 丹莫罗 - 艾沃沙酒2
	    local Mission_Current_ID = 319
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('雷杰德·麦酒','Rejold Barleybrew')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5378,315,394

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('雷杰德·麦酒','Rejold Barleybrew')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5378,315,394
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2999

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}
		    if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("冰爪熊","Ice Claw Bear")
				Mobs_Coord = {
				{-5526.463379, -598.597778, 406.693176},
				{-5555.305176, -644.095703, 406.903015},
				{-5595.618164, -673.093872, 406.578888},
				{-5646.822266, -646.062744, 402.661804},
				{-5680.976074, -607.648560, 402.619476},
				{-5724.496582, -578.821228, 399.850037},
				{-5776.788574, -590.487610, 398.069122},
				{-5806.188477, -632.758301, 398.554413},
				{-5838.509277, -672.523376, 398.793396},
				{-5882.794922, -649.639465, 398.518616},
				{-5920.274902, -616.058777, 400.480286},
				{-5949.629883, -572.330566, 404.565674},
				{-5959.709473, -523.118469, 408.067719},
				{-5961.766113, -474.228912, 407.404388},
				{-5911.418945, -464.715363, 412.568207},
				{-5865.885254, -489.453888, 408.591675},
				{-5820.780273, -515.092896, 404.547943},
				{-5799.371582, -559.635254, 399.884857},
				{-5750.312988, -563.467773, 398.477478},
				{-5706.854980, -541.258484, 398.751587},
				{-5658.026367, -517.788147, 401.581940},
				{-5606.741211, -495.234131, 398.719788},
				{-5557.425781, -499.793884, 400.407806},

				{-5526.463379, -598.597778, 406.693176},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("老峭壁野猪","Elder Crag Boar")
				Mobs_Coord = {
				{-5526.463379, -598.597778, 406.693176},
				{-5555.305176, -644.095703, 406.903015},
				{-5595.618164, -673.093872, 406.578888},
				{-5646.822266, -646.062744, 402.661804},
				{-5680.976074, -607.648560, 402.619476},
				{-5724.496582, -578.821228, 399.850037},
				{-5776.788574, -590.487610, 398.069122},
				{-5806.188477, -632.758301, 398.554413},
				{-5838.509277, -672.523376, 398.793396},
				{-5882.794922, -649.639465, 398.518616},
				{-5920.274902, -616.058777, 400.480286},
				{-5949.629883, -572.330566, 404.565674},
				{-5959.709473, -523.118469, 408.067719},
				{-5961.766113, -474.228912, 407.404388},
				{-5911.418945, -464.715363, 412.568207},
				{-5865.885254, -489.453888, 408.591675},
				{-5820.780273, -515.092896, 404.547943},
				{-5799.371582, -559.635254, 399.884857},
				{-5750.312988, -563.467773, 398.477478},
				{-5706.854980, -541.258484, 398.751587},
				{-5658.026367, -517.788147, 401.581940},
				{-5606.741211, -495.234131, 398.719788},
				{-5557.425781, -499.793884, 400.407806},

				{-5526.463379, -598.597778, 406.693176},
				{-5793.9272,-826.7646,397.5802},
				{-5797.8306,-902.9378,398.6010},
			    }
			end

			if not Mission.Text[3].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("雪豹","Snow Leopard")
				Mobs_Coord = {
				{-5526.463379, -598.597778, 406.693176},
				{-5555.305176, -644.095703, 406.903015},
				{-5595.618164, -673.093872, 406.578888},
				{-5646.822266, -646.062744, 402.661804},
				{-5680.976074, -607.648560, 402.619476},
				{-5724.496582, -578.821228, 399.850037},
				{-5776.788574, -590.487610, 398.069122},
				{-5806.188477, -632.758301, 398.554413},
				{-5838.509277, -672.523376, 398.793396},
				{-5882.794922, -649.639465, 398.518616},
				{-5920.274902, -616.058777, 400.480286},
				{-5949.629883, -572.330566, 404.565674},
				{-5959.709473, -523.118469, 408.067719},
				{-5961.766113, -474.228912, 407.404388},
				{-5911.418945, -464.715363, 412.568207},
				{-5865.885254, -489.453888, 408.591675},
				{-5820.780273, -515.092896, 404.547943},
				{-5799.371582, -559.635254, 399.884857},
				{-5750.312988, -563.467773, 398.477478},
				{-5706.854980, -541.258484, 398.751587},
				{-5658.026367, -517.788147, 401.581940},
				{-5606.741211, -495.234131, 398.719788},
				{-5557.425781, -499.793884, 400.407806},

				{-5526.463379, -598.597778, 406.693176},
			    }
			end
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 艾沃沙酒3
	    local Mission_Current_ID = 320
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('雷杰德·麦酒','Rejold Barleybrew')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5378,315,394

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('驾驶员贝隆·风箱','Pilot Bellowfiz')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5466,-632,393
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2696

	-- 侏儒 丹莫罗 - 自动净化装置
	    local Mission_Current_ID = 412
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 8
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('拉兹·滑链','Razzle Sprysprocket')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5497,-455,395

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('拉兹·滑链','Razzle Sprysprocket')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5497,-455,395
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = {3083,3084}

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			Mobs_ID[#Mobs_ID + 1] = Check_Client("麻疯侏儒","Leper Gnome")
			Mobs_ID[#Mobs_ID + 1] = Check_Client("吉波维特","Gibblewilt")
			Mobs_Coord = {
			{-5347.257813, 464.254028, 385.117767},
            {-5362.902832, 528.053101, 385.959076},
            {-5298.063477, 536.186768, 385.018463},
            {-5233.213867, 543.136963, 390.308960},
            {-5239.994629, 478.001526, 384.928101},
            {-5287.197266, 439.795441, 385.001251},
            {-5347.257813, 464.254028, 385.117767},
			}
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 丹莫罗 - 该死的石腭怪！
	    local Mission_Current_ID = 432
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 10
		Mission.Info[Mission_Current_ID].Max_Level = 14

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('工头乔尼·石眉','Foreman Stonebrow')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1426,-5726.4814,-1600.3198,385.9159

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('工头乔尼·石眉','Foreman Stonebrow')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1426,-5726.4814,-1600.3198,385.9159
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = {3083,3084}

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			Mobs_ID[#Mobs_ID + 1] = Check_Client("石腭击颅者","Rockjaw Skullthumper")
			Mobs_Coord = {
			{-5799.535156, -1535.418457, 359.733398},
            {-5786.242676, -1599.204956, 358.864044},
            {-5766.538574, -1660.363647, 358.971527}, -- 
            {-5786.242676, -1599.204956, 358.864044},
            {-5799.535156, -1535.418457, 359.733398},
			}
		    
			Mobs_MapID = 1426
			Black_Spot = {}

			Kill_Mobs()
		end

    -- 侏儒 洛克莫丹 - 塞尔萨玛血肠
	    local Mission_Current_ID = 418
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('维德拉·壁炉','Vidra Hearthstove')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5394,-2954,322

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('维德拉·壁炉','Vidra Hearthstove')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5394,-2954,322
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = {3172,3173,3174}

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("山猪","Mountain Boar")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("癞皮山猪","Mangy Mountain Boar")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("老山猪","Elder Mountain Boar")
				Mobs_Coord = {
				{-5429.817383, -2784.651123, 364.122131}, ---- 
				{-5331.570801, -2917.215088, 345.985168},
				{-5251.885742, -2986.064209, 336.498688},
				{-5231.775391, -3055.732666, 337.280060},
				{-5163.999512, -3060.558105, 326.849457},
				{-5098.419434, -3067.808105, 321.039642},
				{-5033.049805, -3065.001709, 321.600433},
				{-4968.069336, -3062.212158, 322.760529},
				{-4975.186035, -3000.687988, 344.613312},
				{-4987.942383, -2936.816162, 337.229187},
				{-4984.349609, -2870.126465, 337.871490},
				{-4981.372559, -2807.379639, 318.933258},
				{-4969.038086, -2743.485840, 322.466309},
				{-5034.039551, -2745.151611, 333.053864},
				{-5099.231445, -2752.953125, 337.283813},
				{-5092.115723, -2817.119873, 327.645782},
				{-5094.686035, -2882.834229, 329.087616},
				{-5102.660645, -2947.861328, 332.783386},
				{-5110.650391, -3013.005127, 330.186005},
				{-5176.173828, -3009.997559, 334.947174},
				{-5237.843750, -2987.438232, 334.567047},
				{-5237.105469, -2922.091553, 338.373657},
				{-5235.979980, -2855.945068, 337.248871},
				{-5233.489746, -2790.314941, 343.786133},
				{-5298.189941, -2788.364258, 350.873810},
				{-5363.675781, -2786.389893, 357.423340},
            
				{-5429.817383, -2784.651123, 364.122131},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("灰斑黑熊","Grizzled Black Bear")
				Mobs_Coord = {
				{-5429.817383, -2784.651123, 364.122131}, ---- 
				{-5331.570801, -2917.215088, 345.985168},
				{-5251.885742, -2986.064209, 336.498688},
				{-5231.775391, -3055.732666, 337.280060},
				{-5163.999512, -3060.558105, 326.849457},
				{-5098.419434, -3067.808105, 321.039642},
				{-5033.049805, -3065.001709, 321.600433},
				{-4968.069336, -3062.212158, 322.760529},
				{-4975.186035, -3000.687988, 344.613312},
				{-4987.942383, -2936.816162, 337.229187},
				{-4984.349609, -2870.126465, 337.871490},
				{-4981.372559, -2807.379639, 318.933258},
				{-4969.038086, -2743.485840, 322.466309},
				{-5034.039551, -2745.151611, 333.053864},
				{-5099.231445, -2752.953125, 337.283813},
				{-5092.115723, -2817.119873, 327.645782},
				{-5094.686035, -2882.834229, 329.087616},
				{-5102.660645, -2947.861328, 332.783386},
				{-5110.650391, -3013.005127, 330.186005},
				{-5176.173828, -3009.997559, 334.947174},
				{-5237.843750, -2987.438232, 334.567047},
				{-5237.105469, -2922.091553, 338.373657},
				{-5235.979980, -2855.945068, 337.248871},
				{-5233.489746, -2790.314941, 343.786133},
				{-5298.189941, -2788.364258, 350.873810},
				{-5363.675781, -2786.389893, 357.423340},
            
				{-5429.817383, -2784.651123, 364.122131},
			    }
			end

			if not Mission.Text[3].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("森林潜伏者","Forest Lurker")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("林木潜伏者","Wood Lurker")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("峭壁潜伏者","Cliff Lurker")
				Mobs_Coord = {
				{-5429.817383, -2784.651123, 364.122131}, ---- 
				{-5331.570801, -2917.215088, 345.985168},
				{-5251.885742, -2986.064209, 336.498688},
				{-5231.775391, -3055.732666, 337.280060},
				{-5163.999512, -3060.558105, 326.849457},
				{-5098.419434, -3067.808105, 321.039642},
				{-5033.049805, -3065.001709, 321.600433},
				{-4968.069336, -3062.212158, 322.760529},
				{-4975.186035, -3000.687988, 344.613312},
				{-4987.942383, -2936.816162, 337.229187},
				{-4984.349609, -2870.126465, 337.871490},
				{-4981.372559, -2807.379639, 318.933258},
				{-4969.038086, -2743.485840, 322.466309},
				{-5034.039551, -2745.151611, 333.053864},
				{-5099.231445, -2752.953125, 337.283813},
				{-5092.115723, -2817.119873, 327.645782},
				{-5094.686035, -2882.834229, 329.087616},
				{-5102.660645, -2947.861328, 332.783386},
				{-5110.650391, -3013.005127, 330.186005},
				{-5176.173828, -3009.997559, 334.947174},
				{-5237.843750, -2987.438232, 334.567047},
				{-5237.105469, -2922.091553, 338.373657},
				{-5235.979980, -2855.945068, 337.248871},
				{-5233.489746, -2790.314941, 343.786133},
				{-5298.189941, -2788.364258, 350.873810},
				{-5363.675781, -2786.389893, 357.423340},
            
				{-5429.817383, -2784.651123, 364.122131},
			    }
			end
		    
			Mobs_MapID = 1432
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 荣誉学员
	    local Mission_Current_ID = 6387
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('布洛克·寻石者','Brock Stoneseeker')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5366,-3014,319

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('索格拉姆·伯雷森','Thorgrum Borrelson')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5424,-2929,347
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16310

	-- 侏儒 洛克莫丹 - 飞往铁炉堡
	    local Mission_Current_ID = 6391
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('索格拉姆·伯雷森','Thorgrum Borrelson')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5424,-2929,347

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('高尼尔·石趾','Golnir Bouldertoe')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1455,-4708,-1120,504
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16310

	-- 侏儒 洛克莫丹 - 格莱斯·瑟登
	    local Mission_Current_ID = 6388
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('高尼尔·石趾','Golnir Bouldertoe')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1455,-4708,-1120,504

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('格莱斯·瑟登','Gryth Thurden')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1455,-4821,-1152,502
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16311

	-- 侏儒 洛克莫丹 - 向布洛克回复
	    local Mission_Current_ID = 6392
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('格莱斯·瑟登','Gryth Thurden')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1455,-4821,-1152,502

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('布洛克·寻石者','Brock Stoneseeker')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5366,-3014,319
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16311

	-- 侏儒 洛克莫丹 - 狗头人的耳朵
	    local Mission_Current_ID = 416
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('巡山人卡德雷尔','Mountaineer Kadrell')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5339,-3009,324

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('巡山人卡德雷尔','Mountaineer Kadrell')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5339,-3009,324
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 3110

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠歹徒","Tunnel Rat Vermin")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠斥候","Tunnel Rat Scout")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠地卜师","Tunnel Rat Geomancer")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠掘地工","Tunnel Rat Digger")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠征粮官","Tunnel Rat Forager")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠勘探员","Tunnel Rat Surveyor")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("坑道鼠狗头人","Tunnel Rat Kobold")
				Mobs_Coord = {
				{-5027.623535, -3062.966064, 319.738983},
				{-4964.916504, -3081.630127, 316.312683},
				{-4898.845703, -3081.779785, 318.890076},
				{-4841.146484, -3051.194824, 315.442993},
				{-4898.845703, -3081.779785, 318.890076},
				{-4964.916504, -3081.630127, 316.312683},
				{-5027.623535, -3062.966064, 319.738983},
			    }
			end

			Mobs_MapID = 1432
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 巡山人卡尔·雷矛的任务
	    local Mission_Current_ID = 1339
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('巡山人卡德雷尔','Mountaineer Kadrell')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5339,-3009,324

		Mission.Info[Mission_Current_ID].EndNPC = 1343
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-4825,-2676,341
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16311

	-- 侏儒 洛克莫丹 - 保卫国王的领土1
	    local Mission_Current_ID = 224
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('巡山人库伯弗林特','Mountaineer Cobbleflint')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5832,-2602,313

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('巡山人库伯弗林特','Mountaineer Cobbleflint')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5832,-2602,313
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2536
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石穴居人","Stonesplinter Trogg")
			Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石怪斥候","Stonesplinter Scout")
			Mobs_Coord = {
			{-5767.814453, -2860.265625, 368.752686},
			{-5771.588379, -2890.991699, 364.367157},
			{-5795.156250, -2912.138184, 365.141663},
			{-5815.679199, -2936.043213, 363.729980},
			{-5847.953613, -2934.333252, 360.606506},
			{-5874.073730, -2918.202881, 366.301392},
			{-5890.244141, -2946.405518, 366.322723},
			{-5914.212402, -2926.310547, 367.727081},
			{-5933.685547, -2901.331787, 368.080627},
			{-5946.477051, -2872.810303, 373.712524},
			{-5919.357910, -2887.534180, 368.775574},
			{-5887.889160, -2892.761963, 369.149933},
			{-5855.597168, -2898.406006, 365.119659},
			{-5828.646973, -2880.538574, 365.366272},
			{-5814.473145, -2852.548340, 365.874176},

			{-5767.814453, -2860.265625, 368.752686},
			}

			Mobs_MapID = 1432
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 保卫国王的领土2
	    local Mission_Current_ID = 237
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('巡山人格拉维戈','Mountaineer Gravelgaw')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5893,-2642,310

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('巡山人格拉维戈','Mountaineer Gravelgaw')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5893,-2642,310
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2536
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石怪先知","Stonesplinter Seer")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石怪击颅者","Stonesplinter Skullthumper")
				Mobs_Coord = {
				{-5767.814453, -2860.265625, 368.752686},
				{-5771.588379, -2890.991699, 364.367157},
				{-5795.156250, -2912.138184, 365.141663},
				{-5815.679199, -2936.043213, 363.729980},
				{-5847.953613, -2934.333252, 360.606506},
				{-5874.073730, -2918.202881, 366.301392},
				{-5890.244141, -2946.405518, 366.322723},
				{-5914.212402, -2926.310547, 367.727081},
				{-5933.685547, -2901.331787, 368.080627},
				{-5946.477051, -2872.810303, 373.712524},
				{-5919.357910, -2887.534180, 368.775574},
				{-5887.889160, -2892.761963, 369.149933},
				{-5855.597168, -2898.406006, 365.119659},
				{-5828.646973, -2880.538574, 365.366272},
				{-5814.473145, -2852.548340, 365.874176},

				{-5767.814453, -2860.265625, 368.752686},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石怪先知","Stonesplinter Seer")
				Mobs_ID[#Mobs_ID + 1] = Check_Client("碎石怪击颅者","Stonesplinter Skullthumper")
				Mobs_Coord = {
				{-5767.814453, -2860.265625, 368.752686},
				{-5771.588379, -2890.991699, 364.367157},
				{-5795.156250, -2912.138184, 365.141663},
				{-5815.679199, -2936.043213, 363.729980},
				{-5847.953613, -2934.333252, 360.606506},
				{-5874.073730, -2918.202881, 366.301392},
				{-5890.244141, -2946.405518, 366.322723},
				{-5914.212402, -2926.310547, 367.727081},
				{-5933.685547, -2901.331787, 368.080627},
				{-5946.477051, -2872.810303, 373.712524},
				{-5919.357910, -2887.534180, 368.775574},
				{-5887.889160, -2892.761963, 369.149933},
				{-5855.597168, -2898.406006, 365.119659},
				{-5828.646973, -2880.538574, 365.366272},
				{-5814.473145, -2852.548340, 365.874176},

				{-5767.814453, -2860.265625, 368.752686},
			    }
			end

			Mobs_MapID = 1432
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 铁环挖掘场
	    local Mission_Current_ID = 436
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 14	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('吉恩·角盔','Jern Hornhelm')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5359,-3020,319

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('麦格玛尔·落斧','Magmar Fellhew')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5713,-3783,322
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 16311

	-- 侏儒 洛克莫丹 - 挖掘进度报告
	    local Mission_Current_ID = 298
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 15	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('勘察员基恩萨·铁环','Prospector Ironband')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5694,-3812,321

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('吉恩·角盔','Jern Hornhelm')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5360,-3020,319
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

	-- 侏儒 洛克莫丹 - 向铁炉堡报告
	    local Mission_Current_ID = 301
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 15	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('吉恩·角盔','Jern Hornhelm')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5360,-3020,319

		Mission.Info[Mission_Current_ID].EndNPC = 1356
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1455,-4631.2485,-1303.8207,503.3819
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

	-- 侏儒 洛克莫丹 - 铁环的火药
	    local Mission_Current_ID = 302
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 15	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = 1356
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1455,-4631.2485,-1303.8207,503.3819

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('吉恩·角盔','Jern Hornhelm')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5360,-3020,319
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

	-- 侏儒 洛克莫丹 - 挖掘场的补给品
	    local Mission_Current_ID = 273
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 15	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('吉恩·角盔','Jern Hornhelm')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5360,-3020,319

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('胡达尔','Huldar')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5762,-3433,305
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("杂斑迅猛龙","Mottled Raptor")
				Mobs_Coord = {
				{-5762,-3433,305},
			    }
			end

			Mobs_MapID = 1432
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 恶战之后
	    local Mission_Current_ID = 454
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 15	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('胡达尔','Huldar')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5762,-3433,305

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('米兰','Miran')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-5764,-3431,305
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

	-- 侏儒 洛克莫丹 - 向巡山人罗克加报告
	    local Mission_Current_ID = 468
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 20	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('巡山人卡德雷尔','Mountaineer Kadrell')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1432,-5339,-3009,324

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('巡山人罗克加','Mountaineer Rockgar')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1432,-4678,-2695,319
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2637

	-- 侏儒 洛克莫丹 - 日常供货
	    local Mission_Current_ID = 469
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 22	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('埃纳尔·石钳','Einar Stonegrip')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3232,-2453,15

		Mission.Info[Mission_Current_ID].EndNPC = 2094
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3683,-741,10
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 3347

	-- 侏儒 洛克莫丹 - 寻找挖掘队1
	    local Mission_Current_ID = 305
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 24	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('塔雷尔·石纹','Tarrel Rockweaver')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3583,-864,12

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('麦琳·石纹','Merrin Rockweaver')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3590,-1998,116
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 3618

	-- 侏儒 洛克莫丹 - 寻找挖掘队2
	    local Mission_Current_ID = 306
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 26	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('麦琳·石纹','Merrin Rockweaver')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3590,-1998,116

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('塔雷尔·石纹','Tarrel Rockweaver')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3583,-864,12
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639

	-- 侏儒 洛克莫丹 - 奥莫尔的复仇1
	    local Mission_Current_ID = 294
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 24
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('奥莫尔·铁衣','Ormer Ironbraid')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3559,-1961,114

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('奥莫尔·铁衣','Ormer Ironbraid')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3559,-1961,114
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("杂斑迅猛龙","Mottled Raptor")
				Mobs_Coord = {
				{-3562.046143, -1204.768799, 9.728870},
				{-3598.143311, -1241.295410, 9.812984},
				{-3634.484375, -1276.712402, 9.386258},
				{-3672.241699, -1310.809814, 10.619190},
				{-3657.758057, -1359.088745, 14.685269},
				{-3605.490479, -1361.066040, 12.411640},
				{-3583.116455, -1315.967651, 9.998257},
				{-3552.095947, -1273.732544, 10.066821},

				{-3486.425781, -1349.177856, 9.518096},
				{-3527.443848, -1406.970215, 9.485151},
				{-3488.146240, -1444.897705, 9.155530},
				{-3450.197510, -1481.874756, 10.465382},
				{-3418.083984, -1525.434570, 10.811813},
				{-3411.544678, -1577.440674, 9.689511},
				{-3399.906006, -1626.443115, 9.434511},
				{-3351.192139, -1650.578369, 10.071388},
				{-3298.922607, -1631.153076, 8.462274},
				{-3325.318115, -1583.628174, 9.338202},
				{-3341.543701, -1531.616333, 9.850189},
				{-3368.126709, -1483.753540, 10.260417},
				{-3393.245850, -1436.482544, 7.575748},
				{-3427.082031, -1395.232666, 10.527288},
				{-3432.227051, -1350.164185, 9.994441},
				{-3453.472168, -1309.239380, 9.489848}, 
				{-3476.788574, -1259.704712, 11.213412},
				{-3519.840088, -1230.986572, 9.305507},

				{-3562.046143, -1204.768799, 9.728870},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("杂斑尖啸龙","Mottled Screecher")
				Mobs_Coord = {
				{-3562.046143, -1204.768799, 9.728870},
				{-3598.143311, -1241.295410, 9.812984},
				{-3634.484375, -1276.712402, 9.386258},
				{-3672.241699, -1310.809814, 10.619190},
				{-3657.758057, -1359.088745, 14.685269},
				{-3605.490479, -1361.066040, 12.411640},
				{-3583.116455, -1315.967651, 9.998257},
				{-3552.095947, -1273.732544, 10.066821},

				{-3486.425781, -1349.177856, 9.518096},
				{-3527.443848, -1406.970215, 9.485151},
				{-3488.146240, -1444.897705, 9.155530},
				{-3450.197510, -1481.874756, 10.465382},
				{-3418.083984, -1525.434570, 10.811813},
				{-3411.544678, -1577.440674, 9.689511},
				{-3399.906006, -1626.443115, 9.434511},
				{-3351.192139, -1650.578369, 10.071388},
				{-3298.922607, -1631.153076, 8.462274},
				{-3325.318115, -1583.628174, 9.338202},
				{-3341.543701, -1531.616333, 9.850189},
				{-3368.126709, -1483.753540, 10.260417},
				{-3393.245850, -1436.482544, 7.575748},
				{-3427.082031, -1395.232666, 10.527288},
				{-3432.227051, -1350.164185, 9.994441},
				{-3453.472168, -1309.239380, 9.489848}, 
				{-3476.788574, -1259.704712, 11.213412},
				{-3519.840088, -1230.986572, 9.305507},

				{-3562.046143, -1204.768799, 9.728870},
			    }
			end

			Mobs_MapID = 1437
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 奥莫尔的复仇2
	    local Mission_Current_ID = 295
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 26	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('奥莫尔·铁衣','Ormer Ironbraid')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3559,-1961,114

		Mission.Info[Mission_Current_ID].EndNPC = Check_Client('奥莫尔·铁衣','Ormer Ironbraid')
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3559,-1961,114
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("杂斑镰爪龙","Mottled Scytheclaw")
				Mobs_Coord = {
				{-3328.448975, -1839.753418, 24.607635},
				{-3355.684570, -1808.495972, 24.560816},
				{-3421.554199, -1773.172241, 25.681429},
				{-3486.749756, -1743.761597, 24.292381},
				{-3527.310303, -1767.517212, 26.740234},
				{-3519.336914, -1798.348633, 24.196915},
				{-3569.286377, -1835.465454, 25.896276},
				{-3530.531250, -1851.154907, 24.261114},
				{-3513.890137, -1875.546021, 23.704124},
				{-3503.829346, -1899.741821, 24.188175}, -- 10
				{-3491.423096, -1903.022949, 25.795750},
				{-3477.749268, -1887.992554, 25.183531},
				{-3472.586914, -1871.258179, 24.971315},
				{-3452.052734, -1848.194092, 24.625753},
				{-3414.424316, -1867.092651, 23.936825},
				{-3390.309814, -1853.112915, 24.942839},
				{-3368.297607, -1859.569092, 22.464094},
				{-3341.311768, -1869.031616, 26.297615},
				{-3328.448975, -1839.753418, 24.607635},
			    }
			end

			if not Mission.Text[2].finished then
				Mobs_ID[#Mobs_ID + 1] = Check_Client("杂斑刺喉龙","Mottled Razormaw")
				Mobs_Coord = {
				{-3328.448975, -1839.753418, 24.607635},
				{-3355.684570, -1808.495972, 24.560816},
				{-3421.554199, -1773.172241, 25.681429},
				{-3486.749756, -1743.761597, 24.292381},
				{-3527.310303, -1767.517212, 26.740234},
				{-3519.336914, -1798.348633, 24.196915},
				{-3569.286377, -1835.465454, 25.896276},
				{-3530.531250, -1851.154907, 24.261114},
				{-3513.890137, -1875.546021, 23.704124},
				{-3503.829346, -1899.741821, 24.188175}, -- 10
				{-3491.423096, -1903.022949, 25.795750},
				{-3477.749268, -1887.992554, 25.183531},
				{-3472.586914, -1871.258179, 24.971315},
				{-3452.052734, -1848.194092, 24.625753},
				{-3414.424316, -1867.092651, 23.936825},
				{-3390.309814, -1853.112915, 24.942839},
				{-3368.297607, -1859.569092, 22.464094},
				{-3341.311768, -1869.031616, 26.297615},
				{-3328.448975, -1839.753418, 24.607635},
			    }
			end

			Mobs_MapID = 1437
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 侏儒 洛克莫丹 - 绿色守卫者
	    local Mission_Current_ID = 463
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 26	
		Mission.Info[Mission_Current_ID].Max_Level = 30

		Mission.Info[Mission_Current_ID].StartNPC = Check_Client('大副菲兹莫斯','First Mate Fitzsimmons')
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1437,-3792,-840,9

		Mission.Info[Mission_Current_ID].EndNPC = 1244
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1437,-3262,-2719,9
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639

	-- 人类 艾尔文森林 - 身边的危机
	    local Mission_Current_ID = 783
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 823
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8933.54296875, -136.52333068848, 83.263160705566

		Mission.Info[Mission_Current_ID].EndNPC = 197
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8902.5888671875, -162.60646057129, 81.939010620117
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639

	-- 人类 艾尔文森林 - 剿灭狗头人
	    local Mission_Current_ID = 7
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 197
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8902.5888671875, -162.60646057129, 81.939010620117

		Mission.Info[Mission_Current_ID].EndNPC = 197
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8902.5888671875, -162.60646057129, 81.939010620117
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 6
				Mobs_Coord = {
				{ -8794.597, -170.3217, 81.48666 },
				{ -8753.58, -192.765, 85.61461 },
				{ -8754.476, -158.6685, 83.89332 },
				{ -8752.918, -113.6868, 85.5629 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 伊根·派特斯金纳
	    local Mission_Current_ID = 5261
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 823
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8933.54296875, -136.52333068848, 83.263160705566

		Mission.Info[Mission_Current_ID].EndNPC = 196
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8869.2177734375, -163.23654174805, 80.205444335938
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639

	-- 人类 艾尔文森林 - 林中的群狼
	    local Mission_Current_ID = 33
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 196
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8869.2177734375, -163.23654174805, 80.205444335938

		Mission.Info[Mission_Current_ID].EndNPC = 196
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8869.2177734375, -163.23654174805, 80.205444335938
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 750
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 299
				Mobs_ID[#Mobs_ID + 1] = 69
				Mobs_Coord = {
				{ -8863.207, -136.2185, 80.90886 },
				{ -8850.373, -82.50789, 84.09917 },
				{ -8840.124, -44.89239, 88.12297 },
				{ -8873.831, -46.82303, 87.3131 },
				{ -8788.428, -69.56817, 90.2059 },
				{ -8737.283, -92.64852, 90.60722 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 回音山调查行动
	    local Mission_Current_ID = 15
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 197
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8902.5888671875, -162.60646057129, 81.939010620117

		Mission.Info[Mission_Current_ID].EndNPC = 197
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8902.5888671875, -162.60646057129, 81.939010620117
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 257
				Mobs_Coord = {
				{ -8680.79, -120.071, 90.73534 },
				{ -8698.7, -70.0094, 90.22086 },
				{ -8718.665, -145.1767, 86.37503 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 回音山清剿行动
	    local Mission_Current_ID = 21
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 197
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8902.5888671875, -162.60646057129, 81.939010620117

		Mission.Info[Mission_Current_ID].EndNPC = 197
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8902.5888671875, -162.60646057129, 81.939010620117
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 2639
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 80
				Mobs_Coord = {
				{ -8671.607, -122.2088, 92.05831 },
				{ -8628.457, -143.5685, 86.3891 },
				{ -8601.23, -138.195, 87.6999 },
				{ -8555.47, -149.37, 88.3994 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 潜行者兄弟会
	    local Mission_Current_ID = 18
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 823
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8933.54296875, -136.52333068848, 83.263160705566

		Mission.Info[Mission_Current_ID].EndNPC = 823
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8933.54296875, -136.52333068848, 83.263160705566
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 752
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 38
				Mobs_Coord = {
				{ -8994.59, -312.364, 71.82119 },
				{ -9031.57, -304.335, 74.40742 },
				{ -9064.702, -267.1084, 73.94706 },
				{ -8975.7, -338.156, 73.1845 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 米莉·奥斯沃斯
	    local Mission_Current_ID = 3903
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 823
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8933.54296875, -136.52333068848, 83.263160705566

		Mission.Info[Mission_Current_ID].EndNPC = 9296
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8850.29, -224.03, 81.69663
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

	-- 人类 艾尔文森林 - 加瑞克·帕德弗特的赏金
	    local Mission_Current_ID = 6
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 823
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8933.54296875, -136.52333068848, 83.263160705566

		Mission.Info[Mission_Current_ID].EndNPC = 823
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8933.54296875, -136.52333068848, 83.263160705566
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 182
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 103
				Mobs_Coord = {
				{ -9056.48, -460.903, 72.64869 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 米莉的葡萄
	    local Mission_Current_ID = 3904
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 9296
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8850.29, -224.03, 81.69663

		Mission.Info[Mission_Current_ID].EndNPC = 9296
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8850.29, -224.03, 81.69663
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励
		Mission.Info[Mission_Current_ID].ValidItem = 11119

		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 161557
				Mobs_Coord = {
				{ -8994.59, -312.364, 71.82119 },
				{ -9031.57, -304.335, 74.40742 },
				{ -9064.702, -267.1084, 73.94706 },
				{ -8975.7, -338.156, 73.1845 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Gather_Items()
		end

	-- 人类 艾尔文森林 - 葡萄出货单
	    local Mission_Current_ID = 3905
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 1	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 9296
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8850.29, -224.03, 81.69663

		Mission.Info[Mission_Current_ID].EndNPC = 952
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-8902.13, -181.646, 113.1572
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励
		Mission.Info[Mission_Current_ID].ValidItem = 11125

	-- 人类 艾尔文森林 - 去闪金镇报到
	    local Mission_Current_ID = 54
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 197
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-8902.5888671875, -162.60646057129, 81.939010620117

		Mission.Info[Mission_Current_ID].EndNPC = 240
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9465.5205078125, 74.006942749023, 56.596576690674
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励
		Mission.Info[Mission_Current_ID].ValidItem = 745

	-- 人类 艾尔文森林 - 休息和放松
	    local Mission_Current_ID = 2158
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 6774
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9044.56, -45.9817, 88.33617

		Mission.Info[Mission_Current_ID].EndNPC = 295
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9462.6630859375, 16.191514968872, 56.963500976563
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励
		Mission.Info[Mission_Current_ID].ValidItem = 745

	-- 人类 艾尔文森林 - 狗头人的蜡烛
	    local Mission_Current_ID = 60
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 8	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 253
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9460.3017578125, 31.938911437988, 56.966060638428

		Mission.Info[Mission_Current_ID].EndNPC = 253
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9460.3017578125, 31.938911437988, 56.966060638428
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 772
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {475, 327, 79}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 79
				Mobs_Coord = {
				{ -9752.418, 112.4061, 14.66776 },
				{ -9777.741, 101.0768, 7.325231 },
				{ -9809.988, 117.7006, 6.619633 },
				{ -9837.411, 127.9723, 7.130891 },
				{ -9850.695, 148.1168, 8.834337 },
				{ -9838.743, 160.836, 6.411521 },
				{ -9847.171, 214.9978, 15.61774 },
				{ -9875.063, 215.9385, 15.62878 },
				{ -9904.305, 226.2799, 16.4798 },
				{ -9854.212, 177.8579, 20.69469 },
				{ -9806.155, 143.3485, 52.63388 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 法戈第矿洞
	    local Mission_Current_ID = 62
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 240
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9465.5205078125, 74.006942749023, 56.596576690674

		Mission.Info[Mission_Current_ID].EndNPC = 240
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9465.5205078125, 74.006942749023, 56.596576690674
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 772
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 79
				Mobs_Coord = {
				{-9793.067, 148.622, 24.34465}
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 金砂交易
	    local Mission_Current_ID = 47
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 241
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9496.3193359375, 72.826393127441, 56.415367126465

		Mission.Info[Mission_Current_ID].EndNPC = 241
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9496.3193359375, 72.826393127441, 56.415367126465
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 773
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {475, 327, 79}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 79
				Mobs_Coord = {
				{ -9752.418, 112.4061, 14.66776 },
				{ -9777.741, 101.0768, 7.325231 },
				{ -9809.988, 117.7006, 6.619633 },
				{ -9837.411, 127.9723, 7.130891 },
				{ -9850.695, 148.1168, 8.834337 },
				{ -9838.743, 160.836, 6.411521 },
				{ -9847.171, 214.9978, 15.61774 },
				{ -9875.063, 215.9385, 15.62878 },
				{ -9904.305, 226.2799, 16.4798 },
				{ -9854.212, 177.8579, 20.69469 },
				{ -9806.155, 143.3485, 52.63388 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 鱼人的威胁
	    local Mission_Current_ID = 40
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 241
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9496.3193359375, 72.826393127441, 56.415367126465

		Mission.Info[Mission_Current_ID].EndNPC = 240
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9465.5205078125, 74.006942749023, 56.596576690674
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 773

	-- 人类 艾尔文森林 - 送往暴风城的货物
	    local Mission_Current_ID = 61
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 8	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 253
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9460.3017578125, 31.938911437988, 56.966060638428

		Mission.Info[Mission_Current_ID].EndNPC = 279
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1453,-8857.69, 625.498, 95.99046
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 957

	-- 人类 艾尔文森林 - 年轻的恋人
	    local Mission_Current_ID = 106
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 251
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-10014.012695313, 37.605033874512, 35.171493530273

		Mission.Info[Mission_Current_ID].EndNPC = 252
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9930.048828125, 499.734375, 32.338943481445
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1208

	-- 人类 艾尔文森林 - 丢失的项链
	    local Mission_Current_ID = 85
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 246
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9889.6806640625, 338.4665222168, 36.498054504395

		Mission.Info[Mission_Current_ID].EndNPC = 247
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9923.6806640625, 38.387153625488, 32.412586212158
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1208

	-- 人类 艾尔文森林 - 托米的祖母
	    local Mission_Current_ID = 111
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 252
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9930.048828125, 499.734375, 32.338943481445

		Mission.Info[Mission_Current_ID].EndNPC = 248
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9880.6298828125, 322.6188659668, 37.740612030029
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1208

	-- 人类 艾尔文森林 - 给威廉·匹斯特的信
	    local Mission_Current_ID = 107
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 248
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9880.6298828125, 322.6188659668, 37.740612030029

		Mission.Info[Mission_Current_ID].EndNPC = 253
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9460.3017578125, 31.938911437988, 56.966060638428
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1252

	-- 人类 艾尔文森林 - 比利的馅饼1
	    local Mission_Current_ID = 86
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 247
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9923.6806640625, 38.387153625488, 32.412586212158

		Mission.Info[Mission_Current_ID].EndNPC = 246
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9889.6806640625, 338.4665222168, 36.498054504395
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 769
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 113
				Mobs_Coord = {
				{ -9923.681, 38.38715, 32.41259 },
				{ -9947.661, 114.8901, 32.98557 },
				{ -9908.547, 110.3794, 32.33413 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 比利的馅饼2
	    local Mission_Current_ID = 84
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 246
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9889.6806640625, 338.4665222168, 36.498054504395

		Mission.Info[Mission_Current_ID].EndNPC = 247
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9923.6806640625, 38.387153625488, 32.412586212158
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 962

	-- 人类 艾尔文森林 - 收集海藻
	    local Mission_Current_ID = 112
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 253
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9460.3017578125, 31.938911437988, 56.966060638428

		Mission.Info[Mission_Current_ID].EndNPC = 253
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9460.3017578125, 31.938911437988, 56.966060638428
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1256
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 285
				Mobs_Coord = {
				{ -9448.861328125, -281.42269897461, 59.176082611084 },
				{ -9408.677734375, -316.36846923828, 60.726345062256 },
				{ -9397.59765625, -369.1985168457, 59.765251159668 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 梅贝尔的隐形水
	    local Mission_Current_ID = 114
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 6	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 253
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9460.3017578125, 31.938911437988, 56.966060638428

		Mission.Info[Mission_Current_ID].EndNPC = 251
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-10014.012695313, 37.605033874512, 35.171493530273
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 1257
		
	-- 人类 艾尔文森林 - 玉石矿洞
	    local Mission_Current_ID = 76
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 8	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 240
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9465.5205078125, 74.006942749023, 56.596576690674

		Mission.Info[Mission_Current_ID].EndNPC = 240
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9465.5205078125, 74.006942749023, 56.596576690674
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 772
		Mission.Execute[Mission_Current_ID] = function()
		    Mobs_ID = {}
			Mobs_Coord = {}

			if not Mission.Text[1].finished then
				Mobs_ID[#Mobs_ID + 1] = 79
				Mobs_Coord = {
				{ -9092.9130859375, -564.03131103516, 61.811069488525 },
			    }
			end

			Mobs_MapID = 1429
			Black_Spot = {}

			Kill_Mobs()
		end

	-- 人类 艾尔文森林 - 卫兵托马斯
	    local Mission_Current_ID = 35
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 8	
		Mission.Info[Mission_Current_ID].Max_Level = 12

		Mission.Info[Mission_Current_ID].StartNPC = 240
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9465.5205078125, 74.006942749023, 56.596576690674

		Mission.Info[Mission_Current_ID].EndNPC = 261
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1429,-9610.232421875, -1032.0521240234, 41.122341156006
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 772

	-- 人类 艾尔文森林 - 向格里安·斯托曼报到
	    local Mission_Current_ID = 109
	    Mission.Info[Mission_Current_ID] = {}
		Mission.Info[Mission_Current_ID].Min_Level = 12	
		Mission.Info[Mission_Current_ID].Max_Level = 20

		Mission.Info[Mission_Current_ID].StartNPC = 240
		Mission.Info[Mission_Current_ID].Smapid,Mission.Info[Mission_Current_ID].Sx,Mission.Info[Mission_Current_ID].Sy,Mission.Info[Mission_Current_ID].Sz = 1429,-9465.5205078125, 74.006942749023, 56.596576690674

		Mission.Info[Mission_Current_ID].EndNPC = 234
		Mission.Info[Mission_Current_ID].Emapid,Mission.Info[Mission_Current_ID].Ex,Mission.Info[Mission_Current_ID].Ey,Mission.Info[Mission_Current_ID].Ez = 1436,-10508.791015625, 1045.2322998047, 60.518814086914
		Mission.Info[Mission_Current_ID].Slot_Choose = 1 -- 选择奖励

		Mission.Info[Mission_Current_ID].ValidItem = 772
end
Mission_Wrapper()


function Mission_Search()
    local Mission_List = {}
    local Completed_Mission = {}
	for id in pairs(GetQuestsCompleted()) do 
		Completed_Mission[#Completed_Mission + 1] = id
	end
    if Race == "Troll" or Race == "Orc" then
	    local XieLing = 792 -- 术士邪灵恶魔 = 1485
	    if Class == "WARLOCK" then
		    XieLing = 1485
		end
        Mission_List = {4641,788,789,XieLing,4402,790,804,2161,823,837,834,840,842,6365,6384,6385,6386,844,869,848,1492,871,845,903,855,887,890,892,865,6541,4921,899,1062,6461,583,575,577,185,186,187,190,191,192,194,195,196,568,569,213,570,572,571,605,600,587,606,607,617,1690,1691,1707,8365,8366,2605,2606,5863,3362}
		if Class == "HUNTER" then
		    Mission_List[#Mission_List + 1] = 6062
			Mission_List[#Mission_List + 1] = 6083
			Mission_List[#Mission_List + 1] = 6082
			Mission_List[#Mission_List + 1] = 6081
		end
	elseif Race == "Tauren" then
	    Mission_List = {747,752,753,750,755,757,763,780,844,869,848,1492,871,845,903,855,887,890,892,865,6541,4921,899,1062,6461,583,575,577,185,186,187,190,191,192,194,195,196,568,569,213,570,572,571,605,600,587,606,607,617,1690,1691,1707,8365,8366,2605,2606,5863,3362}
		if Class == "HUNTER" then
		    Mission_List[#Mission_List + 1] = 6062
			Mission_List[#Mission_List + 1] = 6083
			Mission_List[#Mission_List + 1] = 6082
			Mission_List[#Mission_List + 1] = 6081
		end
	elseif Race == "Scourge" then
	    Mission_List = {363,364,3901,376,380,3902,381,840,842,844,869,848,1492,871,845,903,855,887,890,892,865,6541,4921,899,1062,6461,583,575,577,185,186,187,190,191,192,194,195,196,568,569,213,570,572,571,605,600,587,606,607,617,1690,1691,1707,8365,8366,2605,2606,5863,3362}
		if Class == "HUNTER" then
		    Mission_List[#Mission_List + 1] = 6062
			Mission_List[#Mission_List + 1] = 6083
			Mission_List[#Mission_List + 1] = 6082
			Mission_List[#Mission_List + 1] = 6081
		end
	elseif Race == "Gnome" or Race == "Dwarf" then
	    Mission_List = {179,170,233,234,183,3361,182,218,282,3364,3365,420,2160,400,5541,313,317,318,319,320,412,432,418,6387,6391,6388,6392,416,1339,224,237,436,298,301,302,273,454,468,469,305,306,294,295,463,1690,1691,1707,8365,8366,2605,2606,5863,3362}
	elseif Race == "Human" then
	    if Class ~= "WARRIOR" and Class ~= "WARLOCK" then
	        Mission_List = {783,7,5261,33,15,21,18,3903,6,3904,3905,54,2158,60,62,47,40,61,106,85,111,107,86,84,112,114,76,35,109,}
		else
		    Mission_List = {783,7,5261,33,15,21,18,3903,6,3904,3905,54,2158,60,62,47,61,106,85,111,107,86,84,112,114,76,35,109,}
		end
	elseif Race == "NightElf" then
	    Mission_List = {}
    end
    for i = 1,#Mission_List do
        local Mission_Has_Completed = false
		local Mission_Skip = false
        for d = 1,#Completed_Mission do
             if Mission_List[i] == Completed_Mission[d] then
                  Mission_Has_Completed = true
             end
        end

		local Skip_List = string.split(Easy_Data["任务过滤"],",")
		if #Skip_List > 0 then
		    for d = 1,#Skip_List do
			    if Mission_List[i] == tonumber(Skip_List[d]) then
				     Mission_Skip = true				   
				end
			end
		end

        if not Mission_Has_Completed and not Mission_Skip and Level >= Mission.Info[Mission_List[i]].Min_Level and Level <= Mission.Info[Mission_List[i]].Max_Level then
             Mission.ID = Mission_List[i]
			 return 
        end
    end
end
function NPC_Accpet(NPC_ID)
    local Find_List = Find_Nearest_Mob(NPC_ID)
	local On_List = C_QuestLog.IsOnQuest(Mission.ID)
	if Mission.ID == nil then
	    return
	end
    if Find_List ~= nil then
	    local x,y,z = awm.ObjectPosition(Find_List)
		local distance = awm.GetDistanceBetweenObjects("player",Find_List)
		if distance > 4 then
		    Run(x,y,z)
			return
		end

		AcceptQuest()

        if not QuestFrame:IsVisible() and not GossipFrame:IsVisible() then
            if not Interact_Step then
                awm.InteractUnit(Find_List)
                Interact_Step = true
                C_Timer.After(1,function() Interact_Step = false end)
            end
        else
            if not On_List and not Interact_Step then
			    Interact_Step = true
                C_Timer.After(3,function() CloseQuest() CloseGossip() Interact_Step = false end)

				if GossipFrame:IsVisible() or QuestFrame:IsVisible() then
					local title1,_,_,_,_,_,_,title2,_,_,_,_,_,_,title3,_,_,_,_,_,_,title4,_,_,_,_,_,_,title5 = GetGossipAvailableQuests()
					if title1 ~= nil and title1 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipAvailableQuest(1)
					elseif title2 ~= nil and title2 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipAvailableQuest(2)
					elseif title3 ~= nil and title3 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipAvailableQuest(3)
					elseif title4 ~= nil and title4 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipAvailableQuest(4)
					elseif title5 ~= nil and title5 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipAvailableQuest(5)
					end  

					for i = 1,5 do
					    if GetAvailableTitle(i) == C_QuestLog.GetQuestInfo(Mission.ID) then
						    SelectAvailableQuest(i)
						end
					end
				end

				return
			end
        end
	else
	    textout(Check_UI("无法找到任务NPC","Can't find quest NPC"))
    end
end
function NPC_Complete(NPC_ID)
	local Find_List = Find_Nearest_Mob(NPC_ID)

    if Find_List ~= nil then
	    local x,y,z = awm.ObjectPosition(Find_List)
		local distance = awm.GetDistanceBetweenObjects("player",Find_List)
		if distance > 4 then
		    Run(x,y,z)
			return
		end

		GetQuestReward(Mission.Info[Mission.ID].Slot_Choose)
        CompleteQuest()

        if not QuestFrame:IsVisible() and not GossipFrame:IsVisible() then
            if not Interact_Step then
                awm.InteractUnit(Find_List)
                Interact_Step = true
                C_Timer.After(1,function() Interact_Step = false end)
            end
        else
            if not Interact_Step then
			    Interact_Step = true
                C_Timer.After(1,function() CloseQuest() CloseGossip() Interact_Step = false end)
				if GossipFrame:IsVisible() or QuestFrame:IsVisible() then
				    
					local title1,_,_,_,_,_,title2,_,_,_,_,_,title3,_,_,_,_,_,title4,_,_,_,_,_,title5 = GetGossipActiveQuests()
					if title1 ~= nil and title1 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipActiveQuest(1)
					elseif title2 ~= nil and title2 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipActiveQuest(2)
					elseif title3 ~= nil and title3 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipActiveQuest(3)
					elseif title4 ~= nil and title4 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipActiveQuest(4)
					elseif title5 ~= nil and title5 == C_QuestLog.GetQuestInfo(Mission.ID) then
						SelectGossipActiveQuest(5)
					end

					for i = 1,5 do
					    if GetActiveTitle(i) == C_QuestLog.GetQuestInfo(Mission.ID) then
						    SelectActiveQuest(i)
						end
					end
				end

				return
			end
        end
	else
	    textout(Check_UI("无法找到任务NPC","Can't find quest NPC"))
    end
end
function NPC_SelectGossip(titleword) -- NPC窗口选项
	local Options = C_GossipInfo.GetOptions()
	for i = 1,#Options do
	    if string.find(Options[i].name, titleword) then	    
			C_GossipInfo.SelectOption(i)
			Gossip_Has_Selected = true
			textout("选择对话框"..i)
			return
		end
	end
	textout("未检测到符合的对话框")
end

function Kill_Mobs()
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")

    if Grind.Step == 1 then
	    Loot_Timer = false
		Interact_Step = false
		Target_Info.Mob = nil
		Target_Info.GUID = nil
		Combating = false
		Black_Timer = false

		Note_Head = Check_UI("任务升级 = ","Questing Leveling Mode = ")..Mission.ID

		if Grind.Move > #Mobs_Coord then
		    Grind.Move = 1
		end
		local Coord = Mobs_Coord[Grind.Move]
		if Coord == nil then
		    Note_Set(Check_UI("巡逻路径无法读取","Grind path is not readable"))
		    return
		end
		local x,y,z = Coord[1],Coord[2],Coord[3]
		if x == nil or y == nil or z == nil then
		    Note_Set(Check_UI("巡逻坐标无法读取","Grind coords are not readable"))
		    return
		end

		local Gather_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if not awm.UnitAffectingCombat("player") then
			if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mobs_MapID,x,y,z)
				return
			end
		else
		    local table = Combat_Scan()
			if table ~= nil and #table > 0 and Gather_Distance <= 200 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance and awm.UnitLevel(table[i]) - awm.UnitLevel("player") <= 3 then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    textout(Check_UI("进入反击阶段","Fight Process"))
				    Grind.Step = 2
					return
				end
			end
			if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mobs_MapID,x,y,z)
				return
			end
		end

		if not Has_Scan then
		    Has_Scan = true
			Scan_Time = GetTime()
			local body = Find_Corpse()
			local Mobs = Find_Mobs(Mobs_ID)
			Note_Set(Check_UI("巡逻点 = "..Grind.Move..", 附近尸体 = "..#body..", 附近怪物 "..#Mobs, "Node = "..Grind.Move..",Lootable Bodys = "..#body..", Killable Mobs = "..#Mobs))
			if body ~= nil and #body > 0 then
				local Far_Distance = 100
				for i = 1,#body do
				    local tarx,tary,tarz = awm.ObjectPosition(body[i])
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,Pz)
					if distance < Far_Distance and not Vaild_Black(body[i]) then
						Far_Distance = distance
						Target_Info.Mob = body[i]
						Target_Info.GUID = awm.UnitGUID(body[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(body[i])
					end
				end
				if Target_Info.Mob ~= nil then
					textout(Check_UI("进入拾取阶段","Loot Process"))
					Grind.Step = 2
					return
				end
			end
			if Mobs ~= nil and #Mobs > 0 then
				local Far_Distance = 200
				for i = 1,#Mobs do
					local Mob_level = awm.UnitLevel(Mobs[i])
					local distance = awm.GetDistanceBetweenObjects("player",Mobs[i])
					if Mob_level - Level <= 5 and distance < Far_Distance and not Vaild_Black(Mobs[i]) then
						Far_Distance = distance
						Target_Info.Mob = Mobs[i]
						Target_Info.GUID = awm.UnitGUID(Mobs[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Mobs[i])
					end
				end
				if Target_Info.Mob ~= nil then
					textout(Check_UI("进入击杀阶段","Kill Process"))
					Grind.Step = 2
					return
				end
			end
		elseif Has_Scan and (GetTime() - Scan_Time) > 0.8 then
		    Has_Scan = false
		end

		if Gather_Distance > 4 then
		    Run(x,y,z)
		else
		    if Easy_Data["随机路径"] and #Mobs_Coord > 2 then
			    local seed = math.random(1,10)
			    if #Grind.Random_Path ~= #Mobs_Coord then
                    for i = 1,#Mobs_Coord do
					    Grind.Random_Path[i] = nil
					end
				end

				if Grind.Random_Path[Grind.Move] == nil then
				    if seed > 5 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				elseif not Grind.Random_Path[Grind.Move] then
				    local seed2 = math.random(2,4)
				    if seed > seed2 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				elseif Grind.Random_Path[Grind.Move] then
				    local seed2 = math.random(6,8)
				    if seed > seed2 then
					    Grind.Move = Grind.Move + 1
						Grind.Random_Path[Grind.Move] = true
					else
					    Grind.Move = Grind.Move + 2
						Grind.Random_Path[Grind.Move] = false
					end
				end
			else
		        Grind.Move = Grind.Move + 1
			end
		end
	end
	if Grind.Step == 2 then
		if Target_Info.objx == nil or Target_Info.objy == nil or Target_Info.objz == nil then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("怪物坐标无法读取, 返回继续巡逻","Target coord memory cannot read"))
			return
		end

		if not Black_Timer then
		    Black_Timer = true
			Black_Time = GetTime()
		else
		    if GetTime() - Black_Time > Easy_Data["最大击杀时间"] then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			    Target_Info.Mob = nil
				Target_Info.GUID = nil
			    Grind.Step = 1
				return
			end
	    end

		Note_Head = Check_UI("任务击杀 = ","Qusting Leveling Kill Mode = ")..Mission.ID
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz)

		if distance > 1000 then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
		    return
		end 

		local Target_Recheck = awm.UnitGUID(Target_Info.Mob)
		if Target_Recheck == nil and distance < 80 then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标不存在, 返回继续巡逻","Target not exist, back to mobs find process"))
			return
		elseif Target_Recheck ~= Target_Info.GUID then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标错误, 返回继续巡逻","Target Errors, back to mobs find process"))
			return
		end
		if awm.UnitAffectingCombat("player") then
		    local table = Combat_Scan()

		    if Target_Info.Mob ~= nil
			and awm.ObjectExists(Target_Info.Mob)
			and awm.ObjectIsUnit(Target_Info.Mob)
			and (awm.UnitTarget(Target_Info.Mob) and (awm.UnitTarget(Target_Info.Mob) == awm.UnitGUID("player") or awm.UnitTarget(Target_Info.Mob) == awm.UnitGUID("pet"))) 
			and awm.UnitCanAttack("player",Target_Info.Mob) 
			and not awm.UnitIsDead(Target_Info.Mob) then
			    local text = Check_UI("正在击杀怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				CombatSystem(Target_Info.Mob)
				return
			end
			
			if table ~= nil and #table > 0 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    local text = Check_UI("正在反击怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				    CombatSystem(Target_Info.Mob)
					return
				end
			end
		end


		if not awm.ObjectExists(Target_Info.Mob) and distance < 80 then
		    Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标消失","Target do not exist"))
			return
		elseif not awm.UnitIsLootable(Target_Info.Mob) and awm.UnitIsDead(Target_Info.Mob) then
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

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标无法拾取","Mobs body cannot be looted"))
			return
		elseif not Easy_Data["需要拾取"] and awm.UnitIsLootable(Target_Info.Mob) and awm.UnitIsDead(Target_Info.Mob) then
			Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("不执行拾取选项","The loot option is disable"))
			return
		end
		
		if awm.ObjectExists(Target_Info.Mob) then
		    Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
			awm.TargetUnit(Target_Info.Mob)

			if Easy_Data["只击杀无目标怪物"] and awm.UnitIsTapped(Target_Info.Mob) and not awm.UnitIsDead(Target_Info.Mob) then
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

		local Real_distance = awm.GetDistanceBetweenObjects(Target_Info.Mob,"player")
		if Real_distance < 30 then
		    if Mount_useble < GetTime() then
				Mount_useble = GetTime() + 5
			end
		end

		if awm.UnitIsDead(Target_Info.Mob) then
		    if Real_distance > 4 then
			    Loot_Timer = false
				Note_Set("拾取物品中... < 距离 > = "..math.floor(Real_distance),"Looting items... < Distance > = "..math.floor(Real_distance))
				Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
				Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
			    Note_Set("拾取物品中...","Looting items...")
			    Loot_Timer = false
				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.7,function() Interact_Step = false end )
				    awm.InteractUnit(Target_Info.Mob)
				else
				    if LootFrame:IsVisible() then
					    if GetNumLootItems() == 0 then
						    CloseLoot()
							return
						end
						for i = 1,GetNumLootItems() do
							if LootSlotHasItem(i) then
								LootSlot(i)
								ConfirmLootSlot(i)
								if awm.UnitInParty("player") or awm.UnitInRaid("player") then
									SetLootMethod("freeforall")
								end
							end
						end
					end
				end
			end
		else
		    local name = awm.UnitFullName(Target_Info.Mob)
			Note_Set(Check_UI("击杀指定目标, 名字: "..name.." 距离:"..math.floor(Real_distance),"Killing mobs, Target Name = "..name..", Distance = :"..math.floor(Real_distance)))
			CombatSystem(Target_Info.Mob)
		end
	end
end
function Gather_Items(Mob_Table)
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")

    if Grind.Step == 1 then
	    Loot_Timer = false
		Interact_Step = false
		Target_Info.Mob = nil
		Target_Info.GUID = nil
		Black_Timer = false

		Note_Head = Check_UI("任务采集 = ","Qusting Gathering Mode = ")..Mission.ID

		if Grind.Move > #Mobs_Coord then
		    Grind.Move = 1
		end
		local Coord = Mobs_Coord[Grind.Move]
		if Coord == nil then
		    Note_Set(Check_UI("巡逻路径无法读取","Grind path is not readable"))
		    return
		end
		local x,y,z = Coord[1],Coord[2],Coord[3]
		if x == nil or y == nil or z == nil then
		    Note_Set(Check_UI("巡逻坐标无法读取","Grind coords are not readable"))
		    return
		end

		if not awm.UnitAffectingCombat("player") then
			if (Easy_Data["服务器地图"] and Mobs_MapID ~= nil and Current_Map ~= Mobs_MapID) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Mobs_MapID,x,y,z)
				return
			end
		end

		local Gather_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if awm.UnitAffectingCombat("player") then
		    local table = Combat_Scan()
			if table ~= nil and #table > 0 and Gather_Distance <= 200 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    Grind.Step = 2
					return
				end
			end
		end

		if Gather_Distance > 4 then
			if Gather_Distance < 100 and not Has_Scan then
			    Has_Scan = true
				Scan_Time = GetTime()

				local Mobs = nil
				if Mob_Table == nil then
					Mobs = Find_Items(Mobs_ID)
				else
				    Mobs = Mob_Table
				end
				Note_Set(Check_UI("巡逻点 = "..Grind.Move..",可采集物品 = "..#Mobs, "Node = "..Grind.Move..", Lootable Items  = "..#Mobs))
				if Mobs ~= nil and #Mobs > 0 then
				    local Far_Distance = 100
					for i = 1,#Mobs do
					    local distance = awm.GetDistanceBetweenObjects("player",Mobs[i])
						if distance < Far_Distance and not Vaild_Black(Mobs[i]) then
						    Far_Distance = distance
							Target_Info.Mob = Mobs[i]
							Target_Info.GUID = awm.UnitGUID(Mobs[i])
							Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Mobs[i])
						end
					end
					if Target_Info.Mob ~= nil then
					    Grind.Step = 2
						return
					end
				end
			elseif Has_Scan and (GetTime() - Scan_Time) > 0.8 then
			    Has_Scan = false
			elseif Gather_Distance > 100 then
			    Note_Set(Check_UI("巡逻点 = "..Grind.Move..", 距离 = "..math.floor(Gather_Distance), "Node = "..Grind.Move..", Distance = "..math.floor(Gather_Distance)))
			end
		    Run(x,y,z)
		else
		    if not Has_Scan then
			    Has_Scan = true
				Scan_Time = GetTime()
				
				local Mobs = nil
				if Mob_Table == nil then
					Mobs = Find_Items(Mobs_ID)
				else
				    Mobs = Mob_Table
				end

				Note_Set(Check_UI("巡逻点 = "..Grind.Move..",可采集物品 = "..#Mobs, "Node = "..Grind.Move..", Lootable Items  = "..#Mobs))
				if Mobs ~= nil and #Mobs > 0 then
				    local Far_Distance = 100
					for i = 1,#Mobs do
					    local distance = awm.GetDistanceBetweenObjects("player",Mobs[i])
						if distance < Far_Distance and not Vaild_Black(Mobs[i]) then
						    Far_Distance = distance
							Target_Info.Mob = Mobs[i]
							Target_Info.GUID = awm.UnitGUID(Mobs[i])
							Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Mobs[i])
						end
					end
					if Target_Info.Mob ~= nil then
					    Grind.Step = 2
						return
					else
					    Grind.Move = Grind.Move + 1
					end
				else
				    if Easy_Data["随机路径"] and #Mobs_Coord > 2 then
						local seed = math.random(1,10)
						if #Grind.Random_Path ~= #Mobs_Coord then
							for i = 1,#Mobs_Coord do
								Grind.Random_Path[i] = nil
							end
						end

						if Grind.Random_Path[Grind.Move] == nil then
							if seed > 5 then
								Grind.Move = Grind.Move + 1
								Grind.Random_Path[Grind.Move] = true
							else
								Grind.Move = Grind.Move + 2
								Grind.Random_Path[Grind.Move] = false
							end
						elseif not Grind.Random_Path[Grind.Move] then
							local seed2 = math.random(2,4)
							if seed > seed2 then
								Grind.Move = Grind.Move + 1
								Grind.Random_Path[Grind.Move] = true
							else
								Grind.Move = Grind.Move + 2
								Grind.Random_Path[Grind.Move] = false
							end
						elseif Grind.Random_Path[Grind.Move] then
							local seed2 = math.random(6,8)
							if seed > seed2 then
								Grind.Move = Grind.Move + 1
								Grind.Random_Path[Grind.Move] = true
							else
								Grind.Move = Grind.Move + 2
								Grind.Random_Path[Grind.Move] = false
							end
						end
					else
						Grind.Move = Grind.Move + 1
					end
				end
			elseif Has_Scan and (GetTime() - Scan_Time) > 0.05 then
			    Has_Scan = false
			end
		end
	end
	if Grind.Step == 2 then
		if Target_Info.objx == nil or Target_Info.objy == nil or Target_Info.objz == nil then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("物品坐标无法读取, 返回继续巡逻","Target coord memory cannot read"))
			return
		end

		if not Black_Timer then
		    Black_Timer = true
			Black_Time = GetTime()
		else
		    if GetTime() - Black_Time > Easy_Data["最大击杀时间"] then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			    Target_Info.Mob = nil
				Target_Info.GUID = nil
			    Grind.Step = 1
				return
			end
	    end

		Note_Head = Check_UI("任务采集开始 = ","Qusting Gathering Items = ")..Mission.ID
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz)

		if distance > 1000 then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
		    Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
		    return
		end 

		local Target_Recheck = awm.UnitGUID(Target_Info.Mob)
		if Target_Recheck == nil and distance < 80 then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标不存在, 返回继续巡逻","Target not exist, back to mobs find process"))
			return
		elseif Target_Recheck ~= Target_Info.GUID then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标错误, 返回继续巡逻","Target Errors, back to mobs find process"))
			return
		end
		if awm.UnitAffectingCombat("player") then
		    local table = Combat_Scan()

		    if Target_Info.Mob ~= nil and awm.ObjectExists(Target_Info.Mob) and awm.ObjectIsUnit(Target_Info.Mob) and (awm.UnitAffectingCombat(Target_Info.Mob) or awm.UnitHealth(Target_Info.Mob)/awm.UnitHealthMax(Target_Info.Mob) < 0.9) and awm.UnitCanAttack("player",Target_Info.Mob) and not awm.UnitIsDead(Target_Info.Mob) then
			    local text = Check_UI("正在击杀怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				CombatSystem(Target_Info.Mob)
				return
			end
			
			if table ~= nil and #table > 0 then
			    local Far_Distance = 50
			    for i = 1,#table do
				    local distance = awm.GetDistanceBetweenObjects("player",table[i])
					if distance < Far_Distance then
					    Far_Distance = distance
						Target_Info.Mob = table[i]
						Target_Info.GUID = awm.UnitGUID(table[i])
						Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(table[i])
					end
				end
				if Target_Info.Mob ~= nil then
				    local text = Check_UI("正在反击怪物 - "..awm.UnitFullName(Target_Info.Mob)..", 怪物剩余血量 - "..math.floor(awm.UnitHealth(Target_Info.Mob)),"Fighting with - "..awm.UnitFullName(Target_Info.Mob)..", Mobs health - "..math.floor(awm.UnitHealth(Target_Info.Mob)))
				    Note_Set(text)
				    CombatSystem(Target_Info.Mob)
					return
				end
			end
		end

		if not Loot_Timer then
			Loot_Timer = true
			Loot_Time = GetTime()
		elseif GetTime() - Loot_Time > 180 then
		    Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标采集超时","Item loot overtime"))
			return
		end
		if not awm.ObjectExists(Target_Info.Mob) and distance < 80 then
		    Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标消失","Target do not exist"))
			return
		elseif not awm.UnitIsLootable(Target_Info.Mob) and awm.UnitIsDead(Target_Info.Mob) and awm.ObjectIsUnit(Target_Info.Mob) then
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

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标无法拾取","Mobs body cannot be looted"))
			return
		elseif not Easy_Data["需要拾取"] and awm.UnitIsLootable(Target_Info.Mob) and awm.UnitIsDead(Target_Info.Mob) and awm.ObjectIsUnit(Target_Info.Mob) then
			Coordinates_Get = false
			Mount_useble = GetTime()
			Tried_Mount = GetTime()

			if not Vaild_mobs(Monster_Has_Killed,Target_Info.GUID) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("不执行拾取选项","The loot option is disable"))
			return
		end
		
		if awm.ObjectExists(Target_Info.Mob) then
		    Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
			if awm.ObjectIsUnit(Target_Info.Mob) then
				awm.TargetUnit(Target_Info.Mob)
			end
		else
		    Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
		    return
		end

		local Real_distance = awm.GetDistanceBetweenObjects(Target_Info.Mob,"player")

		if Real_distance < 30 then
		    if Mount_useble < GetTime() then
				Mount_useble = GetTime() + 5
			end
		end

		if awm.UnitIsDead(Target_Info.Mob) then
		    if Real_distance > 4 then
			    Loot_Timer = false
				Note_Set("拾取物品中... < 距离 > = "..math.floor(Real_distance),"Looting items... < Distance > = "..math.floor(Real_distance))
				Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Mob)
				Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
			    Note_Set("拾取物品中...","Looting items...")
			    Loot_Timer = false
				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.7,function() Interact_Step = false end )
				    awm.InteractUnit(Target_Info.Mob)
				else
				    if LootFrame:IsVisible() then
					    if GetNumLootItems() == 0 then
						    CloseLoot()
							return
						end
						for i = 1,GetNumLootItems() do
							if LootSlotHasItem(i) then
								LootSlot(i)
								ConfirmLootSlot(i)
								if awm.UnitInParty("player") or awm.UnitInRaid("player") then
									SetLootMethod("freeforall")
								end
							end
						end
					end
				end
			end
		else
			local name = awm.UnitFullName(Target_Info.Mob)
			Note_Set(Check_UI("互动指定目标, 名字: "..name.." 距离:"..math.floor(Real_distance),"Interacting items, Target Name = "..name..", Distance = :"..math.floor(Real_distance)))
			if distance >= 5 then
				Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
				Try_Stop()
				if not Interact_Step then
					Interact_Step = true
					C_Timer.After(1,function() Interact_Step = false end)
					awm.InteractUnit(Target_Info.Mob)
				else
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							CloseLoot()
							return
						end
						for i = 1,GetNumLootItems() do
							if LootSlotHasItem(i) then
								LootSlot(i)
								ConfirmLootSlot(i)
								if awm.UnitInParty("player") or awm.UnitInRaid("player") then
									SetLootMethod("freeforall")
								end
							end
						end
					end
				end
			end
		end
	end
end

function Questing()
    local Px,Py,Pz = awm.ObjectPosition("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")

	if Mission.ID ~= nil then
	    local name = C_QuestLog.GetQuestInfo(Mission.ID)
		if Mission.ID ~= nil and name ~= nil then
	        Note_Head = Check_UI("任务 = ","Mission = ")..name..", ID = "..Mission.ID
		end

		Mission.Text = C_QuestLog.GetQuestObjectives(Mission.ID) -- 获取当前任务文本
		if Mission.Text == nil then
		    Mission.Text = {}
		end
	else
	    Mission.Text = {}
	end

	if Mission.Step == 1 then -- 判断任务ID
		Mission.Flow = 1

		Mission_Search()
		if Gossip_Show or Quest_Show then
			CloseQuest()
		end
        if Mission.ID ~= nil then
			Loot_Timer = false
		    Interact_Step = false
			Grind.Step = 1
		    if not Mission.Timer then
				Mission.Timer = true
				Mission.Time = GetTime()
				return
			end
			if Mission.Timer then
				if GetTime() - Mission.Time <= 1 then
					return
				end
			end
			if GossipFrame:IsVisible() or QuestFrame:IsVisible() then
			    CloseQuest()
			end

            Mission.Step = 2
			Mission.Timer = false
		else
		    Grinding()
		    return
        end
    end
	if Mission.Step == 2 then -- 判断任务ID
		if not Mission.Timer then
			Mission.Timer = true
			Mission.Time = GetTime()
			return
		end
		if Mission.Timer then
			if GetTime() - Mission.Time <= 1 then
				return
			end
		end

		local Completed_Mission = {}
		for id in pairs(GetQuestsCompleted()) do 
			Completed_Mission[#Completed_Mission + 1] = id
		end
        for i = 1,#Completed_Mission do
            if Mission.ID == Completed_Mission[i] then
                Mission.ID = nil
				Event_Reset()
				return
            end
        end
		if Mission.ID == nil then
		    return
		end

		local On_List = C_QuestLog.IsOnQuest(Mission.ID)
		local Completable = IsQuestComplete(Mission.ID)

		if PetHasActionBar() and not awm.ObjectExists("target") and not UnitAffectingCombat("player") then -- 猎人关闭宝宝攻击模式, 不招惹怪物
			awm.PetPassiveMode()
		end

		if not On_List then
			local Info = Mission.Info[Mission.ID]
			local NPC = Find_Nearest_Mob(Info.StartNPC)
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Info.Sx,Info.Sy,Info.Sz)
			if not NPC and distance > 4 then
				if (Easy_Data["服务器地图"] and Info.Smapid ~= nil and Current_Map ~= Info.Smapid) or Easy_Data.Sever_Map_Calculated or Continent_Move then
					Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
					Sever_Run(Current_Map,Info.Smapid,Info.Sx,Info.Sy,Info.Sz)
					return
				end

				Note_Set(Check_UI("接取任务, 距离 = ","Go To Take The Quest, Distance = ")..math.floor(distance))
			    Run(Info.Sx,Info.Sy,Info.Sz)
				Interact_Step = false
			else
			    Note_Set(Check_UI("接取任务, 距离 = ","Go To Take The Quest, Distance = ")..math.floor(distance))
			    NPC_Accpet(Info.StartNPC)
			end
			return
		end
		if Completable then
		    local Info = Mission.Info[Mission.ID]
			local NPC = Find_Nearest_Mob(Info.EndNPC)
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Info.Ex,Info.Ey,Info.Ez)
			if not NPC and distance > 4 then
				if (Easy_Data["服务器地图"] and Info.Emapid ~= nil and Current_Map ~= Info.Emapid) or Easy_Data.Sever_Map_Calculated or Continent_Move then
					Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
					Sever_Run(Current_Map,Info.Emapid,Info.Ex,Info.Ey,Info.Ez)
					return
				end

				Note_Set(Check_UI("领取任务奖励, 距离 = ","Go To Complete The Quest, Distance = ")..math.floor(distance))
			    Run(Info.Ex,Info.Ey,Info.Ez)
				Interact_Step = false
			else
			    Note_Set(Check_UI("领取任务奖励, 距离 = ","Go To Complete The Quest, Distance = ")..math.floor(distance))
			    NPC_Complete(Info.EndNPC)
			end
			return
		end
		local execute = Mission.Execute[Mission.ID]
		if execute ~= nil then
			execute()
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
    local Px,Py,Pz = awm.ObjectPosition("player")
	Level = awm.UnitLevel("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")

	if Px == nil or Py == nil or Pz == nil then
		return
	end

	if GetTime() - Reset_Killed > 1800 then
	    Monster_Has_Killed = {}
		Reset_Killed = GetTime()
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

	if not Buff_Check() and not UnitAffectingCombat("player") then
	    Note_Head = Check_UI("BUFF增加","BUFF Adding")
	    return
	end

	if not CheckUse() and not UnitAffectingCombat("player") then
	    Note_Head = Check_UI("宝石制造","Gem Producting")
	    return
	end

	local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player",0)/awm.UnitPowerMax("player",0)) * 100
	if ((awm.UnitAffectingCombat("player") and Cur_Health <= Easy_Data["反击百分比"] and Easy_Data["巡逻反击"]) or Scan_Combat) and Grind.Step == 1 then
	    if not awm.UnitAffectingCombat("player") and Scan_Combat then
		    Scan_Combat = false
			return
		end
		local Combat_Monster = Combat_Scan()
		if #Combat_Monster > 0 then
			Note_Set(Check_UI("反击! 怪物"..#Combat_Monster.."只, 设定距离"..Easy_Data["采集反击范围"].."码","Fight Back! Mobs around amount "..#Combat_Monster..", Set distance "..Easy_Data["采集反击范围"].." yard"))
			local Far_Distance = 500
			if Combat_Target ~= nil then
				if not awm.ObjectExists(Combat_Target) then
					Combat_Target = nil
				elseif awm.ObjectExists(Combat_Target) and (awm.UnitIsDead(Combat_Target) or not awm.UnitCanAttack("player",Combat_Target) or awm.GetDistanceBetweenObjects("player",Combat_Target) >= Easy_Data["采集反击范围"] or not awm.UnitAffectingCombat(Combat_Target)) then
					Combat_Target = nil		   
				else
					Scan_Combat = true
					CombatSystem(Combat_Target)
					return
				end
			else
			    for i = 1,#Combat_Monster do
					local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
					local level = awm.UnitLevel(Combat_Monster[i])
					if distance < Easy_Data["采集反击范围"] and distance < Far_Distance and level - awm.UnitLevel("player") <= 5 then
						Far_Distance = distance
						Combat_Target = Combat_Monster[i]
					end
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

	if not awm.UnitAffectingCombat("player") and Easy_Data["需要吃喝"] and Grind.Step == 1 and not IsSwimming() then
	    if Start_Restore or Cur_Health < Easy_Data["回血百分比"] or (Cur_Power < Easy_Data["回蓝百分比"] and Class ~= "WARRIOR" and Class ~= "ROGUE") then
		    Start_Restore = true
			if not NeedHeal() then
				return
			end
		end
		Start_Restore = false	     
	end

	if Easy_Data["完全使用自定义文件内容"] then
	    RunScript(Read_File(Easy_Data["自定义文件位置"]))
	elseif Easy_Data["融合自定义文件"] then
	    Grind_Information()
		RunScript(Read_File(Easy_Data["自定义文件位置"]))
	else
	    Grind_Information()
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

	if Auto_Purchase.Lack_Money and GetMoney() >= 30011 then
	    Auto_Purchase.Lack_Money = false
	end

	if Easy_Data["自动学技能"] then
	    local level_gap = Level/Easy_Data["自动学技能间隔"]
		local Learn = Easy_Data["已经学过技能"]
		if Learn ~= nil and Learn and not Has_Learn then
		    Has_Learn = true
		end
		if level_gap == math.floor(level_gap) and not Has_Learn then
		    Note_Head = Check_UI("学习技能","Spell Learn")
		 
			Event_Reset()

			if (Easy_Data["服务器地图"] and Trainer_Coord.mapid ~= nil and Current_Map ~= Trainer_Coord.mapid) or Easy_Data.Sever_Map_Calculated or Continent_Move then
			    Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,Trainer_Coord.mapid,Trainer_Coord.x,Trainer_Coord.y,Trainer_Coord.z)
				return
			end

		    Spell_Run(Trainer_Coord.x,Trainer_Coord.y,Trainer_Coord.z)
			return
		elseif level_gap ~= math.floor(level_gap) then
		    Has_Learn = false
			Easy_Data["已经学过技能"] = false
		end
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

	if GetTime() - Equip_Time > 15 and Easy_Data["自动换装"] and not awm.UnitAffectingCombat("player") then
	    Note_Head = Check_UI("自动换装","Auto Equip")
		Auto_Equip()
		return
	end

	if Easy_Data["需要任务"] then
	    Questing()
	else
	    Grinding()
	end
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

					if IsMounted() then
					    Dismount()
					end
				else
				    stuckx = random(Px-20,Px+20)
					stucky = random(Py-20,Py+20)
				end
			else
			    awm.JumpOrAscendStart()
			    stuckx = random(Px-30,Px+30)
				stucky = random(Py-30,Py+30)
			end

			C_Timer.After(2,function()
				Stop_Run = false
				Coordinates_Get = false
				awm.AscendStop()
			end)
		end
		awm.MoveTo(stuckx,stucky,Pz)
		return
	end

	if coordinates == nil or coordinates == 0 or awm.GetActiveNodeCount() == 0 then
		awm.Interval_Move(x,y,z)
		if GetTime() - Nil_Reset > 3 then
		    Nil_Reset = GetTime()
			Coordinates_Get = false
			textout(Check_UI("导航路径 = 无.. 检查地图包设置或无路径生成","Navigation path = nil.. Check your map folder settings or no path found"))
		end
		return
	end
	if awm.GetActiveNodeCount() > 0 then
	    local x1,y1,z1 = awm.GetActiveNodeByIndex(Path_Index)
		local distance1 = awm.GetDistanceBetweenPositions(x1,y1,Pz,Px,Py,Pz)

		if distance1 ~= nil and distance1 > 1 and not Stop_Moving then
			awm.Interval_Move(x1,y1,z1)
		end
		if distance1 <= 1 then
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
		Basic_UI.Nav["躲避物体体积"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"0.1",false,280,24)
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
			Easy_Data["服务器地图"] = true
			Basic_UI.Nav["服务器地图"]:SetChecked(true)
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
			Easy_Data["地图刷新"] = true
			Basic_UI.Nav["地图刷新"]:SetChecked(true)
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

	local function Enable_Quest()
	    Basic_UI.Set["需要任务"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("1 - 60 任务自动升级","1 - 60 Questing"))
		Basic_UI.Set["需要任务"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要任务"]:GetChecked() then
				Easy_Data["需要任务"] = true
			elseif not Basic_UI.Set["需要任务"]:GetChecked() then
				Easy_Data["需要任务"] = false
			end
		end)
		if Easy_Data["需要任务"] ~= nil then
			if Easy_Data["需要任务"] then
				Basic_UI.Set["需要任务"]:SetChecked(true)
			else
				Basic_UI.Set["需要任务"]:SetChecked(false)
			end
		else
			Easy_Data["需要任务"] = true
			Basic_UI.Set["需要任务"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["销毁任务物品"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("销毁任务物品","Auto destroy quest items"))
		Basic_UI.Set["销毁任务物品"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["销毁任务物品"]:GetChecked() then
				Easy_Data["销毁任务物品"] = true
			elseif not Basic_UI.Set["销毁任务物品"]:GetChecked() then
				Easy_Data["销毁任务物品"] = false
			end
		end)
		if Easy_Data["销毁任务物品"] ~= nil then
			if Easy_Data["销毁任务物品"] then
				Basic_UI.Set["销毁任务物品"]:SetChecked(true)
			else
				Basic_UI.Set["销毁任务物品"]:SetChecked(false)
			end
		else
			Easy_Data["销毁任务物品"] = false
			Basic_UI.Set["销毁任务物品"]:SetChecked(false)
		end
	end

	local function Enable_loot()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["需要拾取"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("需要拾取","Enable loot"))
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

	    Basic_UI.Set["只拾取我击杀"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("只拾取我击杀的怪物尸体","Only loot mobs that killed by the character"))
		Basic_UI.Set["只拾取我击杀"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["只拾取我击杀"]:GetChecked() then
				Easy_Data["只拾取我击杀"] = true
			elseif not Basic_UI.Set["只拾取我击杀"]:GetChecked() then
				Easy_Data["只拾取我击杀"] = false
			end
		end)
		if Easy_Data["只拾取我击杀"] ~= nil then
			if Easy_Data["只拾取我击杀"] then
				Basic_UI.Set["只拾取我击杀"]:SetChecked(true)
			else
				Basic_UI.Set["只拾取我击杀"]:SetChecked(false)
			end
		else
			Easy_Data["只拾取我击杀"] = false
			Basic_UI.Set["只拾取我击杀"]:SetChecked(false)
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

	local function Enable_Inventory() -- 自动换装
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["自动换装"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("自动换装","Auto equip higher level gears(inventories)"))
		Basic_UI.Set["自动换装"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["自动换装"]:GetChecked() then
				Easy_Data["自动换装"] = true
			elseif not Basic_UI.Set["自动换装"]:GetChecked() then
				Easy_Data["自动换装"] = false
			end
		end)
		if Easy_Data["自动换装"] ~= nil then
			if Easy_Data["自动换装"] then
				Basic_UI.Set["自动换装"]:SetChecked(true)
			else
				Basic_UI.Set["自动换装"]:SetChecked(false)
			end
		else
			Easy_Data["自动换装"] = true
			Basic_UI.Set["自动换装"]:SetChecked(true)
		end
	end

	local function Enable_Spell_Learn() -- 自动学技能
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["自动学技能"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("自动学技能","Auto learn spells"))
		Basic_UI.Set["自动学技能"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["自动学技能"]:GetChecked() then
				Easy_Data["自动学技能"] = true
			elseif not Basic_UI.Set["自动学技能"]:GetChecked() then
				Easy_Data["自动学技能"] = false
			end
		end)
		if Easy_Data["自动学技能"] ~= nil then
			if Easy_Data["自动学技能"] then
				Basic_UI.Set["自动学技能"]:SetChecked(true)
			else
				Basic_UI.Set["自动学技能"]:SetChecked(false)
			end
		else
			Easy_Data["自动学技能"] = true
			Basic_UI.Set["自动学技能"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("学习技能间隔等级(设置3, 即为 3/6/9级学习技能)","Character level gap of learning spells (E.g. number 3, learn spells at 3/6/9...)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["自动学技能间隔"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"6",false,280,24)
		Basic_UI.Set["自动学技能间隔"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自动学技能间隔"] = tonumber(Basic_UI.Set["自动学技能间隔"]:GetText())
		end)
		if Easy_Data["自动学技能间隔"] ~= nil then
			Basic_UI.Set["自动学技能间隔"]:SetText(Easy_Data["自动学技能间隔"])
		else
			Easy_Data["自动学技能间隔"]= tonumber(Basic_UI.Set["自动学技能间隔"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("不学习的技能名字 (格式 = name1,name2,name3,name4,)","Spell Name to skip auto learn (Format = name1,name2,name3,name4,)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["技能过滤"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"侦测魔法,奥术飞弹,法术反制,缓落术,解除次级诅咒,魔法增效,魔法抑制,灼烧,烈焰风暴,防护火焰结界,暴风雪,防护冰霜结界,冰锥术,",false,500,24)
		Basic_UI.Set["技能过滤"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["技能过滤"] = Basic_UI.Set["技能过滤"]:GetText()
		end)
		if Easy_Data["技能过滤"] ~= nil then
			Basic_UI.Set["技能过滤"]:SetText(Easy_Data["技能过滤"])
		else
			Easy_Data["技能过滤"]= Basic_UI.Set["技能过滤"]:GetText()
		end
	end

	local function FightBack_Choose_UI() -- 巡逻反击
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

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("巡逻时遇到怪物开始反击的范围","Fight back range when navigating")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["采集反击范围"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"40",false,280,24)
		Basic_UI.Set["采集反击范围"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["采集反击范围"] = tonumber(Basic_UI.Set["采集反击范围"]:GetText())
		end)
		if Easy_Data["采集反击范围"] ~= nil then
			Basic_UI.Set["采集反击范围"]:SetText(Easy_Data["采集反击范围"])
		else
			Easy_Data["采集反击范围"] = tonumber(Basic_UI.Set["采集反击范围"]:GetText())
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

	    Basic_UI.Set["需要吃喝"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("需要使用吃喝回蓝回血","Need use food and drink items to regenerate health and power"))
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
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("使用回血物品的血量(%)","Health percent begin use Food item(%)")) 

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
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("使用回蓝物品的蓝量(%)","Power percent begin use Drink item(%)")) 

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

		Basic_UI.Set["食物保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py - 20,"10",false,280,24)

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
		Basic_UI.Set["饮料保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"10",false,280,24)

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

		Basic_UI.Set["回血药水保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py - 20,"1",false,280,24)

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
		Basic_UI.Set["回蓝药水保留数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",300, Basic_UI.Set.Py,"1",false,280,24)

		Basic_UI.Set["回蓝药水保留数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["回蓝药水保留数量"] = tonumber(Basic_UI.Set["回蓝药水保留数量"]:GetText())
		end)
		if Easy_Data["回蓝药水保留数量"] ~= nil then
			Basic_UI.Set["回蓝药水保留数量"]:SetText(Easy_Data["回蓝药水保留数量"])
		else
			Easy_Data["回蓝药水保留数量"] = tonumber(Basic_UI.Set["回蓝药水保留数量"]:GetText())
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

	local function Quest_Skip() -- 任务过滤
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("需要跳过的任务ID (格式 = ID数字,ID数字,ID数字,ID数字,)","Quest ID to skip (Format = ID number,ID number,ID number,ID number,)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["任务过滤"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"",false,500,24)
		Basic_UI.Set["任务过滤"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["任务过滤"] = Basic_UI.Set["任务过滤"]:GetText()
		end)
		if Easy_Data["任务过滤"] ~= nil then
			Basic_UI.Set["任务过滤"]:SetText(Easy_Data["任务过滤"])
		else
			Easy_Data["任务过滤"]= Basic_UI.Set["任务过滤"]:GetText()
		end
	end

	local function Black_List_Time() -- 拉黑时间
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("最大击杀或者采集时间 (超过即自动拉黑)","Max kill or gather time on one item (Exceed will auto blacklist it)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20

		Basic_UI.Set["最大击杀时间"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"240",false,280,24)
		Basic_UI.Set["最大击杀时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["最大击杀时间"] = tonumber(Basic_UI.Set["最大击杀时间"]:GetText())
			if not Easy_Data["最大击杀时间"] then
			    Easy_Data["最大击杀时间"] = 240
			end
		end)
		if Easy_Data["最大击杀时间"] ~= nil then
			Basic_UI.Set["最大击杀时间"]:SetText(Easy_Data["最大击杀时间"])
		else
			Easy_Data["最大击杀时间"]= tonumber(Basic_UI.Set["最大击杀时间"]:GetText())
			if not Easy_Data["最大击杀时间"] then
			    Easy_Data["最大击杀时间"] = 240
			end
		end
	end

	local function Enable_Random_Path()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30

	    Basic_UI.Set["随机路径"] = Create_Check_Button(Basic_UI.Set.frame,"TopLeft",10,Basic_UI.Set.Py,Check_UI("随机生成击杀巡逻或采集巡逻路径 (防止开火车)","Randomize the mobs kill path or gather path (Prevent the same path with a lot users)"))
		Basic_UI.Set["随机路径"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["随机路径"]:GetChecked() then
				Easy_Data["随机路径"] = true
			elseif not Basic_UI.Set["随机路径"]:GetChecked() then
				Easy_Data["随机路径"] = false
			end
		end)
		if Easy_Data["随机路径"] ~= nil then
			if Easy_Data["随机路径"] then
				Basic_UI.Set["随机路径"]:SetChecked(true)
			else
				Basic_UI.Set["随机路径"]:SetChecked(false)
			end
		else
			Easy_Data["随机路径"] = false
			Basic_UI.Set["随机路径"]:SetChecked(false)
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
	Enable_Quest()
	Enable_loot()
	Hearth_stone()
	Enable_Inventory()
	Enable_Spell_Learn()
	FightBack_Choose_UI()
	Use_Potions()
	Tick_Food_Drink()
	Enable_Food_Drink()
	Buy_Food_Drink()
	Player_Detection()
	Only_Kill_Myself()
	Black_List_Time()
	Enable_Random_Path()

	Quest_Skip()
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

		Basic_UI.Sell["卖物格数"] = Create_EditBox(Basic_UI.Sell.frame,"TOPLEFT",10, Basic_UI.Sell.Py,"1",false,280,24)
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

local function Create_Custom_UI() -- 自定义面板
    Basic_UI.Custom = {}
	Basic_UI.Custom.Py = -10
	local function Frame_Create()
		Basic_UI.Custom.frame = CreateFrame('frame',"Basic_UI.Custom.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Custom.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Custom.frame:SetSize(600,1500)
		Basic_UI.Custom.frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
		title= true, 
		edgeSize =15, 
		titleSize = 32})
		Basic_UI.Custom.frame:Hide()
		Basic_UI.Custom.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Custom.frame:SetBackdropBorderColor(1,0,1,1)
		Basic_UI.Custom.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 55
		Basic_UI.Custom.button = Create_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("自定义设置","Custom Panel"))
		Basic_UI.Custom.button:SetSize(135,50)
		Basic_UI.Custom.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Custom.frame:Show()
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Custom.frame:Hide() end
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Custom.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("自定义","Customize"))
		Basic_UI.Custom.button:SetSize(130,20)
		Basic_UI.Custom.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Custom.frame:Show()
			Basic_UI.Custom.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Custom.frame:Hide() Basic_UI.Custom.button:SetBackdropColor(0,0,0,0) end
	end

	local function Button_Profile_Load()
		Basic_UI.Custom["加载文件"] = Create_Button(Basic_UI.Custom.frame, "TopLeft",10,Basic_UI.Custom.Py,Check_UI("加载文件","Load Profile"))
		Basic_UI.Custom["加载文件"]:SetSize(135,40)
		Basic_UI.Custom["加载文件"]:SetScript("OnClick", function(self)
		    local content = Read_File(Easy_Data["自定义文件位置"])
			if content then
		        Basic_UI.Custom["自定义文件内容"]:SetText(content)
				Easy_Data["自定义文件内容"] = content
			end
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	end

	local function Need_Custom()
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    Basic_UI.Custom["完全使用自定义文件内容"] = Create_Check_Button(Basic_UI.Custom.frame, "TOPLEFT",10, Basic_UI.Custom.Py, Check_UI("完全使用自定义文件内容进行工作","100% Custom and use your own profile"))
		Basic_UI.Custom["完全使用自定义文件内容"]:SetScript("OnClick", function(self)
			if Basic_UI.Custom["完全使用自定义文件内容"]:GetChecked() then
				Easy_Data["完全使用自定义文件内容"] = true
			elseif not Basic_UI.Custom["完全使用自定义文件内容"]:GetChecked() then
				Easy_Data["完全使用自定义文件内容"] = false
			end
		end)
		if Easy_Data["完全使用自定义文件内容"] ~= nil then
			if Easy_Data["完全使用自定义文件内容"] then
				Basic_UI.Custom["完全使用自定义文件内容"]:SetChecked(true)
			else
				Basic_UI.Custom["完全使用自定义文件内容"]:SetChecked(false)
			end
		else
			Easy_Data["完全使用自定义文件内容"] = false
			Basic_UI.Custom["完全使用自定义文件内容"]:SetChecked(false)
		end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		Basic_UI.Custom["融合自定义文件"] = Create_Check_Button(Basic_UI.Custom.frame, "TOPLEFT",10, Basic_UI.Custom.Py, Check_UI("只替换自定义文件内容, 工作主体仍为内置路径","Combine custom mode, only replace part of grind route from custom file"))
		Basic_UI.Custom["融合自定义文件"]:SetScript("OnClick", function(self)
			if Basic_UI.Custom["融合自定义文件"]:GetChecked() then
				Easy_Data["融合自定义文件"] = true
			elseif not Basic_UI.Custom["融合自定义文件"]:GetChecked() then
				Easy_Data["融合自定义文件"] = false
			end
		end)
		if Easy_Data["融合自定义文件"] ~= nil then
			if Easy_Data["融合自定义文件"] then
				Basic_UI.Custom["融合自定义文件"]:SetChecked(true)
			else
				Basic_UI.Custom["融合自定义文件"]:SetChecked(false)
			end
		else
			Easy_Data["融合自定义文件"] = false
			Basic_UI.Custom["融合自定义文件"]:SetChecked(false)
		end
	end

	local function Profile_read()
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("配置文件路径","Profile Path"))

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20
	    Basic_UI.Custom["自定义文件位置"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,[[E:\BattleNet\World of Warcraft\_classic_\Interface\AddOns\Wow_Defender\Script\troll_1-60.lua]],570,80)

		Basic_UI.Custom["自定义文件位置"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自定义文件位置"] = Basic_UI.Custom["自定义文件位置"]:GetText()
		end)
        if Easy_Data["自定义文件位置"] == nil then
            Easy_Data["自定义文件位置"] = [[E:\BattleNet\World of Warcraft\_classic_\Interface\AddOns\Wow_Defender\Script\troll_1-60.lua]]
        else
            Basic_UI.Custom["自定义文件位置"]:SetText(Easy_Data["自定义文件位置"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 60
	end

	local function Profile_content() -- 自定义文件内容
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("自定义文件内容","Profile Content"))

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20
	    Basic_UI.Custom["自定义文件内容"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,"",570,300)

		Basic_UI.Custom["自定义文件内容"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["自定义文件内容"] = Basic_UI.Custom["自定义文件内容"]:GetText()
		end)
        if Easy_Data["自定义文件内容"] == nil then
		    local content = awm.ReadFile(Easy_Data["自定义文件位置"])
			if content then
		        Basic_UI.Custom["自定义文件内容"]:SetText(content)
				Easy_Data["自定义文件内容"] = content
			end
        else
            Basic_UI.Custom["自定义文件内容"]:SetText(Easy_Data["自定义文件内容"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 280
	end


	Frame_Create()
	Button_Create()
	Button_Profile_Load()
	Need_Custom()
	Profile_read()
	Profile_content()
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

	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("野外升级 1 - 70","Open world level up 1 - 70")) 

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("支持职业 - 全部","Class supportive - All"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("支持种族 - 不支持 TBC 新种族","Race supportive - Not support TBC new races"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("任务支持 - 部落 + 联盟 1 - 58 (精灵暂不支持)","Quest line supportive - Horde + Alliance 1 - 58 (not support Elf)"))
	
	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("请勾选 导航 - 服务器地图包 需要跨大陆进行练习","Please enable Sever navigation"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("天赋请自行随意设置","Please set ur talent with ur favor"))
end

local function CreateButton()

	local ButtonLayout = CreateFrame('frame',"ButtonFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
	ButtonLayout:SetPoint("TopRight",-(GetScreenWidth()/5),-(GetScreenHeight()/5))
	ButtonLayout:SetSize(150,30)
	ButtonLayout:SetMovable(true)
	ButtonLayout:RegisterForDrag("LeftButton")
	ButtonLayout:EnableMouse(true)
	ButtonLayout:SetClampedToScreen(true)
	ButtonLayout:SetToplevel(true)
	ButtonLayout:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",edgeFile="Interface/ChatFrame/ChatFrameBackground",title= true, edgeSize =1, titleSize = 5})
	ButtonLayout:Show()
	ButtonLayout:SetBackdropColor(0,0,0,0)
	ButtonLayout:SetBackdropBorderColor(0,0,0,0)

	local button2 = CreateFrame("Button","button2",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext2 = button2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext2:SetText(Check_UI("手动添加黑名单","Manual blacklist mobs"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top")
	button2:SetSize(150,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
	    if Target_Info.GUID then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Target_Info.Mob = nil
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("手动黑名单添加成功","Manual blacklist target"))
			return
		end
	end)
end

Create_Nav_UI()
Create_Config_UI()
Create_Sell_UI()
Create_Destroy_UI()
Create_Mail_UI()
Create_Custom_UI()
Create_Rotation_UI()
Create_GUIDE_UI()
CreateButton()

function Bot_Begin()
    Run_Timer = GetTime()
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
Equip_Black_List = {}
Equip_Bag,Equip_Slot = 0,0
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

		if arg2 == ERR_PROFICIENCY_NEEDED or arg2 == PROFICIENCY_NEEDED then -- 不会使用物品
		    local link = GetContainerItemLink(Equip_Bag,Equip_Slot)
			local item = select(1, GetItemInfo(link))
		    Equip_Black_List[#Equip_Black_List + 1] = item
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

	if event == "ITEM_LOCK_CHANGED" then
	    Equip_Bag,Equip_Slot = arg1,arg2
	end
end	
Script:RegisterEvent("CHAT_MSG_SYSTEM")
Script:RegisterEvent("UNIT_SPELLCAST_SENT")
Script:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
Script:RegisterEvent("UNIT_SPELLCAST_FAILED")
Script:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
Script:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
Script:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
Script:RegisterEvent("EXECUTE_CHAT_LINE")
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
Script:RegisterEvent("ITEM_LOCK_CHANGED")

Script:SetScript("OnEvent",Script.BeginEvent)

local combatlog = CreateFrame("Frame")
combatlog:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatlog:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function combatlog:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...

	if subevent == "PARTY_KILL" and sourceGUID == awm.UnitGUID("player") then
	    lastx,lasty,lastz = 0,0,0
		textout(Check_UI("你成功击杀了 ".."< "..destName.." > ","You successfully killed ".."< "..destName.." > "))
		if not Vaild_mobs(Monster_Has_Killed,destGUID) then
			Monster_Has_Killed[#Monster_Has_Killed + 1] = destGUID
			textout(Check_UI("< "..destName.." > 已被加入我击杀的列表中","< "..destName.." > Add into mobs kill list"))
		end
	end

	if (subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" or subevent == "SWING_MISSED") and sourceGUID == awm.UnitGUID("player") then
		local missType,Spell_Name,amountMissed,Miss_Reason = select(12, ...)
		if Miss_Reason == "EVADE" then
		    textout(Check_UI("怪物闪避, 开始检查坐标和技能","Monster Evade, Check coord and spells"))
			if awm.ObjectExists("target") then
			    awm.FaceDirection(awm.GetAnglesBetweenObjects("player","target"))
				awm.JumpOrAscendStart()
				C_Timer.After(0.5,function() awm.MoveForwardStart() end)
				C_Timer.After(2,function() Try_Stop() awm.AscendStop() end)
			end
		elseif Miss_Reason == "IMMUNE" and Spell_Name == rs["寒冰箭"] then
		    textout(Check_UI("怪物抵抗, 开始检查坐标和技能","Monster IMMUNE, Check coord and spells"))
			if not Monster_Evade then
			    Monster_Evade = true
				C_Timer.After(15,function() Monster_Evade = false end)
			end
		end
	end
end


local Detail_Frame = CreateFrame("Frame")
local Generate = false
local Dungeon_Run_Time = ""
local Dungeon_Killed = ""
local Initial_Money = GetMoney()
local Money_Monitor = ""
local Initial_Level = awm.UnitLevel("player")
local Level_Monitor = ""
Detail_Frame:SetScript("OnUpdate", function()
    if not Generate then
	    Generate = true

		Dungeon_Run_Time = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_Run_Time:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_Run_Time:SetText(Check_UI("运行时间: ","Running time: ")..math.floor(GetTime() - Run_Timer))
		Dungeon_Run_Time:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Dungeon_Killed = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_Killed:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_Killed:SetText(Check_UI("击杀: ","Killed: ")..#Monster_Has_Killed)
		Dungeon_Killed:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Money_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Money_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Money_Monitor:SetText(Check_UI("金币: ","Profit: ")..(GetMoney() - Initial_Money) / 10000)
		Money_Monitor:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Level_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Level_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Level_Monitor:SetText(Check_UI("等级提升: ","Level up: ")..(awm.UnitLevel("player") - Initial_Level))
		Level_Monitor:Show()
	else
	    Dungeon_Run_Time:SetText(Check_UI("运行时间: ","Running time: ")..math.floor(GetTime() - Run_Timer)..Check_UI(" 秒"," seconds"))
		Dungeon_Killed:SetText(Check_UI("击杀: ","Killed: ")..#Monster_Has_Killed..Check_UI(" 只"," mobs"))
		Money_Monitor:SetText(Check_UI("金币: ","Profit: ")..((GetMoney() - Initial_Money)/10000)..Check_UI(" 金"," gold"))
		Level_Monitor:SetText(Check_UI("等级提升: ","Level up: ")..(awm.UnitLevel("player") - Initial_Level))
	end
end)