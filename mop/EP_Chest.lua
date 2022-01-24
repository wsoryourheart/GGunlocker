Function_Load_In = true
local Function_Version = "0107"
textout(Check_UI("野外开锁练习 - "..Function_Version,"Lockpicking Practice - "..Function_Version))

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
	Item = nil,
	GUID = nil,
	objx = nil,
	objy = nil,
	objz = nil,
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
	Start_CountDown = false,
	CountDown = 0,
}

local Scan_Time = 0 -- 扫描间隔时间

local Loot_Timer = false
local Loot_Time = 0

local Gather_Timer = false -- 采集计时
local Gather_Time = GetTime() -- 开始采集时间

local Black_List = {} -- 采集黑名单
local Item_Has_Loot = {}
local Combat_Target = nil -- 需要击杀的干扰目标
local Recheck_Target = false -- 重新检查目标的pointer
local Combating = false -- 正在战斗
local Stop_Yet = false -- 停止采集

local Has_Call_Pet = false -- 召唤宠物

local Interact_Step = false
local Eat_Time = 0 -- 吃喝 制造食物 间隔计时
local Start_Restore = false -- 是否正在回血

local Has_Mail = false -- 邮寄过了

local Combat_In_Range = false
local Scan_Combat = false -- 巡逻反击

local Dead = {
    Repop = GetTime(),
	Shift = false,
	Shift_Step = 1,
	Safe = {},
}

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
    Repop = 0,
	Shift = false,
	Shift_Step = 1,
	Safe = {},
}

local Dead = {
    Repop = 0,
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
	Food_Name = ""
	Drink_Name = ""
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
    Target_Info.Mob = nil
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
		Mail_Info.Start_CountDown = false
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

			if Mail_Info.Start_CountDown and GetTime() > Mail_Info.CountDown then
			    Has_Mail = true
				textout(Check_UI("邮寄完毕","Mail logic end"))
				return
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
					if not Mail_Info.Start_CountDown then
					    Mail_Info.Start_CountDown = true
						Mail_Info.CountDown = GetTime() + 15
						textout(Check_UI("邮寄完毕, 开始计时 15 秒","Mail logic end, Start Count 15 secs"))
						return
					end
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

function Mine_Herb_Find()
    local Lock_Rank = 0
	local Find_List = {}
    for i = 1, GetNumSkillLines() do 
		skillName, _, _, skillRank, _, _,skillMaxRank, _, _, _, _, _,_ = GetSkillLineInfo(i)
		if string.find (skillName, rs["开锁"]) then
		    Lock_Rank = skillRank
		end
	end
	if Lock_Rank <= 100 then
	    -- 棘齿城
		Find_Object(123330,Find_List)
		Find_Object(123332,Find_List)
		Find_Object(123333,Find_List)
		Find_Object(123331,Find_List)

		-- 赤脊山
		Find_Object(178246,Find_List)
		Find_Object(178244,Find_List)
		Find_Object(178245,Find_List)
	end
	if Lock_Rank >= 100 and Lock_Rank <= 135 then
		Find_Object(179486,Find_List)
	end
	if Lock_Rank >= 120 and Lock_Rank <= 175 then
		Find_Object(179488,Find_List)
	end
	if Lock_Rank >= 170 and Lock_Rank <= 215 then
		Find_Object(179490,Find_List)
	end
	if Lock_Rank >= 215 and Lock_Rank <= 240 then
		Find_Object(179494,Find_List)
	end
	if Lock_Rank >= 235 and Lock_Rank <= 300 then
		Find_Object(179496,Find_List)
	end
	if Lock_Rank >= 300 and Lock_Rank <= 350 then
		Find_Object(Check_Client("柳条箱","Wicker Chest"),Find_List)
	end
		
	return Find_List
end

function Find_Object(id,table)
	local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		if awm.IsGuid(ThisUnit) then
			local guid = awm.ObjectId(ThisUnit)
			local name = awm.UnitFullName(ThisUnit)
			if awm.ObjectExists(ThisUnit) and ((tonumber(id) ~= nil and guid == id) or name == id) then
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
    for i = 0,#Item_Has_Loot,1 do
	    if Item_Has_Loot[i] == awm.UnitGUID(Object) then
		    return true
		end
	end
	return false
end

function Path_Information()
    local LR = 0
    for i = 1, GetNumSkillLines() do 
		skillName, _, _, skillRank, _, _,skillMaxRank, _, _, _, _, _,_ = GetSkillLineInfo(i)
		if string.find (skillName, rs["开锁"]) then
		    LR = skillRank
		end
	end
	if Faction == "Horde" then
	    if LR >= 0 and LR < 100 then
		    Mobs_MapID = 1413
		    Mobs_Coord = {{-1458.1742,-3968.6792,7.5615}}

			Merchant_Name = Check_Client("哈里沙·白蹄","Halija Whitestrider")
			Merchant_Coord = {mapid = 1413, x = -539, y = -2672, z = 95.79}
			Mail_Coord = {mapid = 1413, x = -445, y = -2649, z = 95.77}

			Ammo_Vendor_Name = Check_Client("阿瑟罗克","Uthrok")
			Ammo_Vendor_Coord = {mapid = 1413, x = -351, y = -2556, z = 95.79}

			Food_Vendor_Name = Check_Client("旅店老板伯兰德·草风","Innkeeper Boorand Plainswind")
			Food_Vendor_Coord = {mapid = 1413, x = -407, y = -2645, z = 96}

			Food_Name = Check_Client("新鲜的红苹果","Shiny Red Apple")
			Drink_Name = Check_Client("清凉的泉水","Refreshing Spring Water")
			return
		end
		if LR >= 100 and LR < 135 then
		    Mobs_MapID = 1424
		    Mobs_Coord = {{  -508.6841,  -1565.1615, 52.5156 },
					{  -557.9238,  -1514.6595, 53.3281 },
					{  -510.3687,  -1388.0970, 52.8974 },
					{  -475.2944,  -1367.0297, 52.6039 }}

			Merchant_Name = Check_Client("奥特","Ott")
			Merchant_Coord = {mapid = 1424, x = -158, y = -867, z = 56}
			Mail_Coord = {mapid = 1424, x = -21, y = -927, z = 55}

			Ammo_Vendor_Name = Check_Client("凯伦·苏萨隆","Kayren Soothallow")
			Ammo_Vendor_Coord = {mapid = 1424, x = -24, y = -935, z = 55}

			Food_Vendor_Name = Check_Client("旅店老板沙恩","Innkeeper Shay")
			Food_Vendor_Coord = {mapid = 1424, x = -5, y = -942, z = 57}

			Food_Name = Check_Client("肉排","Haunch of Meat")
			Drink_Name = Check_Client("冰镇牛奶","Ice Cold Milk")
			return
		end
		if LR >= 135 and LR < 175 then
		    Mobs_MapID = 1424
		    Mobs_Coord = {{ -492.3027, -1536.2855, 65.1543 },
					{ -451.2556, -1564.5658, 64.9075 },
					{ -478.0867, -1609.7196, 64.8790 },
					{ -549.5287, -1589.1458, 64.8550 },
					{ -612.4960, -1553.6277, 64.8197 },
					{ -631.4655, -1501.5449, 63.4963 },
					{ -597.5280, -1423.2792, 65.0480 },
					{ -529.6053, -1340.0817, 64.3481 },
					{ -446.5982, -1319.4618, 64.6769 },
					{ -563.3232, -1383.2477, 65.5280 },
					{ -521.4888, -1469.6847, 75.1972 },
					{ -457.1212, -1422.1442, 92.6159 },
					{ -502.4872, -1467.9436, 84.1208 }}

			Merchant_Name = Check_Client("奥特","Ott")
			Merchant_Coord = {mapid = 1424, x = -158, y = -867, z = 56}
			Mail_Coord = {mapid = 1424, x = -21, y = -927, z = 55}

			Ammo_Vendor_Name = Check_Client("凯伦·苏萨隆","Kayren Soothallow")
			Ammo_Vendor_Coord = {mapid = 1424, x = -24, y = -935, z = 55}

			Food_Vendor_Name = Check_Client("旅店老板沙恩","Innkeeper Shay")
			Food_Vendor_Coord = {mapid = 1424, x = -5, y = -942, z = 57}

			Food_Name = Check_Client("肉排","Haunch of Meat")
			Drink_Name = Check_Client("冰镇牛奶","Ice Cold Milk")
			return
		end
		if LR >= 175 and LR < 215 then
		    Mobs_MapID = 1418
		    Mobs_Coord = {{ -6349.0898, -3097.5684, 301.1107 },
					{ -6378.1646, -3103.9832, 310.8357 },
					{ -6360.4727, -3082.5850, 310.8357 },
					{ -6327.6909, -3107.9224, 310.8372 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 215 and LR < 240 then
		    Mobs_MapID = 1427
		    Mobs_Coord = {{ -6693.7324, -1164.1721, 184.4021 },
					{ -6584.7817, -1187.9811, 186.3764 },
					{ -6514.2017, -1234.8075, 180.8594 },
					{ -6463.0552, -1218.5374, 180.9397 },
					{ -6436.0625, -1243.5914, 180.9373 },
					{ -6446.1157, -1285.9603, 180.9279 },
					{ -6532.7046, -1266.0278, 180.9536 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 240 and LR < 300 then
		    Mobs_MapID = 1427
		    Mobs_Coord = {{ -6520.8696, -1296.3278, 200.9513 },
					{ -6507.0884, -1354.5636, 208.9726 },
					{ -6583.6064, -1281.3937, 208.7431 },
					{ -6635.4072, -1314.4014, 208.5850 },
					{ -6744.6753, -1402.7174, 214.8926 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 300 and LR <= 350 then
		    Mobs_MapID = 1946
		    Mobs_Coord = {{-259.75,7031.73,20.66},{-193.15,7035.00,18.37},{-161.30,7012.77,20.31},{-117.78,6949.31,18.85},{-57.24,6962.23,22.91},{-34.12,7021.69,20.15},{-24.97,7063.24,18.82},{-52.23,7088.47,19.19},{-60.90,7120.60,18.77},{-82.29,7173.19,18.98},{-100.75,7202.09,19.25},{-134.24,7233.74,23.00},{-161.97,7277.81,22.62},{-160.37,7322.13,22.21},{-208.79,7371.42,20.63},{-258.81,7276.00,21.17}}

			Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
			Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

			Ammo_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Ammo_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Vendor_Name = Check_Client("弗洛伊德·平克","Floyd Pinkus")
			Food_Vendor_Coord = {mapid = 1944, x = 190.87, y = 2610.92, z = 87.28}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
	else
	    if LR >= 0 and LR < 100 then
		    Mobs_MapID = 1433
		    Mobs_Coord = {{-9228.1963,-2701.3533,89.0865}}

			Merchant_Name = Check_Client("科瑞娜·斯蒂利","Corina Steele")
			Merchant_Coord = {mapid = 1429, x = -9464, y = 93, z = 58}
			Mail_Coord = {mapid = 1429, x = -9455, y = 45, z = 56}

			Ammo_Vendor_Name = Check_Client("布洛葛·哈姆菲斯特","Brog Hamfist")
			Ammo_Vendor_Coord = {mapid = 1429, x = -9465, y = 9, z = 56}

			Food_Vendor_Name = Check_Client("旅店老板法雷","Innkeeper Farley")
			Food_Vendor_Coord = {mapid = 1429, x = -9462, y = 16, z = 56}

			Food_Name = Check_Client("奥特兰克冷酪","Alterac Swiss")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 100 and LR < 135 then
		    Mobs_MapID = 1424
		    Mobs_Coord = {{  -508.6841,  -1565.1615, 52.5156 },
					{  -557.9238,  -1514.6595, 53.3281 },
					{  -510.3687,  -1388.0970, 52.8974 },
					{  -475.2944,  -1367.0297, 52.6039 }}

			Merchant_Name = Check_Client("加诺斯·铁心","Jannos Ironwill")
			Merchant_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}
			Mail_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Food_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Name = Check_Client("野猪火腿","Wild Hog Shank")
			Drink_Name = Check_Client("蜂蜜饮料","Sweet Nectar")
			return
		end
		if LR >= 135 and LR < 175 then
		    Mobs_MapID = 1424
		    Mobs_Coord = {{ -492.3027, -1536.2855, 65.1543 },
					{ -451.2556, -1564.5658, 64.9075 },
					{ -478.0867, -1609.7196, 64.8790 },
					{ -549.5287, -1589.1458, 64.8550 },
					{ -612.4960, -1553.6277, 64.8197 },
					{ -631.4655, -1501.5449, 63.4963 },
					{ -597.5280, -1423.2792, 65.0480 },
					{ -529.6053, -1340.0817, 64.3481 },
					{ -446.5982, -1319.4618, 64.6769 },
					{ -563.3232, -1383.2477, 65.5280 },
					{ -521.4888, -1469.6847, 75.1972 },
					{ -457.1212, -1422.1442, 92.6159 },
					{ -502.4872, -1467.9436, 84.1208 }}

			Merchant_Name = Check_Client("加诺斯·铁心","Jannos Ironwill")
			Merchant_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}
			Mail_Coord = {mapid = 1417, x = -1278, y = -2521, z = 21}

			Ammo_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Ammo_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Vendor_Name = Check_Client("维基·隆萨夫","Vikki Lonsav")
			Food_Vendor_Coord = {mapid = 1417, x = -1275, y = -2538, z = 21}

			Food_Name = Check_Client("野猪火腿","Wild Hog Shank")
			Drink_Name = Check_Client("蜂蜜饮料","Sweet Nectar")
			return
		end
		if LR >= 175 and LR < 215 then
		    Mobs_MapID = 1418
		    Mobs_Coord = {{ -6349.0898, -3097.5684, 301.1107 },
					{ -6378.1646, -3103.9832, 310.8357 },
					{ -6360.4727, -3082.5850, 310.8357 },
					{ -6327.6909, -3107.9224, 310.8372 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 215 and LR < 240 then
		    Mobs_MapID = 1427
		    Mobs_Coord = {{ -6693.7324, -1164.1721, 184.4021 },
					{ -6584.7817, -1187.9811, 186.3764 },
					{ -6514.2017, -1234.8075, 180.8594 },
					{ -6463.0552, -1218.5374, 180.9397 },
					{ -6436.0625, -1243.5914, 180.9373 },
					{ -6446.1157, -1285.9603, 180.9279 },
					{ -6532.7046, -1266.0278, 180.9536 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 240 and LR < 300 then
		    Mobs_MapID = 1427
		    Mobs_Coord = {{ -6520.8696, -1296.3278, 200.9513 },
					{ -6507.0884, -1354.5636, 208.9726 },
					{ -6583.6064, -1281.3937, 208.7431 },
					{ -6635.4072, -1314.4014, 208.5850 },
					{ -6744.6753, -1402.7174, 214.8926 }}

			Merchant_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Merchant_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}
			Mail_Coord = {mapid = 1417, x = -928, y = -3525, z = 70}

			Ammo_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Ammo_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Vendor_Name = Check_Client("大铁匠博恩奈特","Master Smith Burninate")
			Food_Vendor_Coord = {mapid = 1427, x = -6524, y = -1188, z = 309}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
		if LR >= 300 and LR <= 350 then
		    Mobs_MapID = 1946
		    Mobs_Coord = {{-259.75,7031.73,20.66},{-193.15,7035.00,18.37},{-161.30,7012.77,20.31},{-117.78,6949.31,18.85},{-57.24,6962.23,22.91},{-34.12,7021.69,20.15},{-24.97,7063.24,18.82},{-52.23,7088.47,19.19},{-60.90,7120.60,18.77},{-82.29,7173.19,18.98},{-100.75,7202.09,19.25},{-134.24,7233.74,23.00},{-161.97,7277.81,22.62},{-160.37,7322.13,22.21},{-208.79,7371.42,20.63},{-258.81,7276.00,21.17}}

			Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			Merchant_Coord = {mapid = 1946, x = -198, y = 5490, z = 21.84}
			Mail_Coord = {mapid = 1946, x = -198.66, y = 5506.75, z = 22.34}

			Ammo_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Ammo_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Vendor_Name = Check_Client("希德·利巴迪","Sid Limbardi")
			Food_Vendor_Coord = {mapid = 1944, x = -707.19, y = 2740.04, z = 94.73}

			Food_Name = Check_Client("烤鹌鹑","Roasted Quail")
			Drink_Name = Check_Client("晨露酒","Morning Glory Dew")
			return
		end
	end
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


function Gather_Process()
	local Current_Map = C_Map.GetBestMapForUnit("player")
	local Px,Py,Pz = awm.ObjectPosition("player")

	if Skill_Level(rs["开锁"]) > 200 and Skill_Level(rs["开锁"]) <= 300 then
		local gate = {}
		Find_Object(Check_Client("采掘场大门","Quarry Gate"),gate)
		if #gate > 0 then
			if awm.GetDistanceBetweenObjects("player",gate[1]) < 5 then
				awm.InteractUnit(gate[1])
			end
		end
	end

	if Grind.Step == 1 then -- 巡逻扫描
	    Note_Head = Check_UI("巡逻扫描","Scaning Objects")

		Gather_Timer = false
		Interact_Step = false
		Recheck_Target = false
		Combating = false
		Stop_Yet = false
		Target_Info.Item = nil
		Target_Info.GUID = nil

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

			local Find_List = Mine_Herb_Find()
			Note_Set(Check_UI("可采集物品"..#Find_List.."个, 地点 = "..Grind.Move,"Items around - "..#Find_List..", Nodes = "..Grind.Move))
			if #Find_List > 0 then
				local Far_Distance = Easy_Data["采集扫描范围"]
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
				    textout(Check_UI("进入采集阶段","Start Gather Process"))
					Target_Info.GUID = awm.UnitGUID(Target_Info.Item)
					Grind.Step = 2
					return
				end
			end
		end

		if Gather_Distance > 1.7 then
			Run(x,y,z)
			if Skill_Level(rs["开锁"]) > 300 and not awm.UnitAffectingCombat("player") and not CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["潜行"]) and Gather_Distance <= 50 and not IsMounted() then
				 awm.CastSpellByName(rs["潜行"])
			end
	    else
		    Grind.Move = Grind.Move + 1
		end
	end
	if Grind.Step == 2 then -- 采集
	    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objx,Target_Info.objy,Target_Info.objz)

		Note_Head = Check_UI("采集流程","Gather Process")

		if distance < 30 then
			if Mount_useble < GetTime() then
				Mount_useble = GetTime() + 10
			end
		    if not awm.ObjectExists(Target_Info.Item) then
				Coordinates_Get = false
				Item_Has_Loot[#Item_Has_Loot + 1] = Target_Info.GUID
				Mount_useble = GetTime()
				Target_Info.Item = nil
				Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
				Target_Info.GUID = nil
				Grind.Step = 1

				textout(Check_UI("物品消失, 判断采集完毕","Item disappear, end gather process"))
				return
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
		if not Gather_Timer then
			Gather_Timer = true
			Gather_Time = GetTime()
		end
		if Gather_Timer then
		    local time = GetTime() - Gather_Time
			if time >= Easy_Data["极限采集时间"] then
				Black_List[#Black_List + 1] = Target_Info.GUID
				Coordinates_Get = false
				Mount_useble = GetTime()
				Target_Info.Item = nil
				Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
				Target_Info.GUID = nil
				Grind.Step = 1
				textout(Check_UI("采集超时, 加入黑名单","Over max gather time, black it")) 
				return
			end
		end
		if distance > 5 and not Combating then
		    if Skill_Level(rs["开锁"]) > 300 and not awm.UnitAffectingCombat("player") and not CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["潜行"]) and not IsMounted() then
				 awm.CastSpellByName(rs["潜行"])
			end
		    Stop_Yet = false
			Note_Set(Check_UI("前往采集目的地... 距离:","Go to gather items, distance - ")..math.floor(distance))
			local distance2 = awm.GetDistanceBetweenPositions(Px,Py,Pz,Target_Info.objy,Target_Info.objy,Pz) -- 上下距离
		    if distance2 <= 2 and distance > 5 then
			    awm.MoveTo(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			else
			    Run(Target_Info.objx,Target_Info.objy,Target_Info.objz)
			end
		else

		    if awm.UnitAffectingCombat("player") then
			    local Combat_Monster = Combat_Scan()
				if #Combat_Monster > 0 then
				    if #Combat_Monster > 1 then
					    Multi_Target = true
					else
					    Multi_Target = false
					end
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
					end
					for i = 1,#Combat_Monster do
					    local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
						if distance < Easy_Data["采集反击范围"] and distance < Far_Distance then
						    Far_Distance = distance
							Combat_Target = Combat_Monster[i]
						end
					end
					if Combat_Target ~= nil then
						Combating = true
						CombatSystem(Combat_Target)
						return
					else
					    Combating = false
					end
				else
				    Combating = false
				end
			else
			    Combating = false
			end
		    Note_Set(Check_UI("物品 = ","Name = ")..awm.UnitFullName(Target_Info.Item)..Check_Client(", 距离 = ",", Distance = ")..math.floor(distance))
			awm.ClearTarget()
			if not Recheck_Target then
			    Recheck_Target = true
				Target_Info.Item = nil

				local Find_List = Mine_Herb_Find()

				local Far_Distance = 10
				for i = 1,#Find_List do
					local ThisUnit = Find_List[i]
					local x,y,z = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(x,y,z,Target_Info.objx,Target_Info.objy,Target_Info.objz)
					if distance < Far_Distance then
					    Far_Distance = distance
					    Target_Info.Item = ThisUnit
						Target_Info.GUID = awm.UnitGUID(ThisUnit)
					end
				end
				if Target_Info.Item == nil then
				    Coordinates_Get = false
					Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
					Grind.Step = 1

					textout(Check_Client("重新扫描失败, 回到巡逻步骤","Rescan false, back to step 1"))
					return
				else
				    Target_Info.objx,Target_Info.objy,Target_Info.objz = awm.ObjectPosition(Target_Info.Item)
				end
			end
			if IsMounted() then
			    Dismount()
			end
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

			local Speed = GetUnitSpeed("player")
			if not Stop_Yet and Speed == 0 then
			    Stop_Yet = true
		        awm.InteractUnit(Target_Info.Item)
				C_Timer.After(1,function() Stop_Yet = false end)
			elseif Speed > 0 then
				Try_Stop()
			end
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
			if not teleport.timer then
			    teleport.timer = true
				teleport.time = GetTime()
			else
			    Note_Set(Check_UI("重新开始时间 = ","Restart Work After = ")..math.floor(90 - GetTime() + teleport.time)..Check_UI(" 秒"," Seconds"))
			    if GetTime() - teleport.time > 90 then
				    teleport.timer = false
					Coordinates_Get = false
					teleport.x,teleport.y,teleport.z = 0,0,0
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
	if (awm.UnitAffectingCombat("player") and Cur_Health <= Easy_Data["反击百分比"] and Easy_Data["巡逻反击"]) or Scan_Combat then
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
			end
			for i = 1,#Combat_Monster do
				local distance = awm.GetDistanceBetweenObjects("player",Combat_Monster[i])
				local level = awm.UnitLevel(Combat_Monster[i])
				if distance < Easy_Data["采集反击范围"] and distance < Far_Distance and level - awm.UnitLevel("player") <= 5 then
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

	Path_Information()
	

	if not awm.UnitAffectingCombat("player") and Easy_Data["需要吃喝"] and Grind.Step == 1 and not IsSwimming() then
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

	Gather_Process()
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
			Easy_Data["平滑寻路"] = false
			Basic_UI.Nav["平滑寻路"]:SetChecked(false)
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

	local function FightBack_Choose_UI() -- 采矿采药反击
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
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("采集时遇到怪物开始反击的范围","Fight back range when gathing items")) 

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

	local function Max_Gather_Time_UI() -- 极限采集时间
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("最大采集时间 (超过时间拉黑)","Max gather time (Blacklist object if overtime)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["极限采集时间"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"200",false,280,24)
		Basic_UI.Set["极限采集时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["极限采集时间"] = tonumber(Basic_UI.Set["极限采集时间"]:GetText())
		end)
		if Easy_Data["极限采集时间"] ~= nil then
			Basic_UI.Set["极限采集时间"]:SetText(Easy_Data["极限采集时间"])
		else
			Easy_Data["极限采集时间"] = tonumber(Basic_UI.Set["极限采集时间"]:GetText())
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

	local function Gather_Set_UI() -- 扫描范围
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_Client("采集扫描的范围","Item scan range")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["采集扫描范围"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"200",false,280,24)
		Basic_UI.Set["采集扫描范围"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["采集扫描范围"] = tonumber(Basic_UI.Set["采集扫描范围"]:GetText())
		end)
		if Easy_Data["采集扫描范围"] ~= nil then
			Basic_UI.Set["采集扫描范围"]:SetText(Easy_Data["采集扫描范围"])
		else
			Easy_Data["采集扫描范围"] = tonumber(Basic_UI.Set["采集扫描范围"]:GetText())
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
	FightBack_Choose_UI()
	Max_Gather_Time_UI()

	Hearth_stone()

	Gather_Set_UI()
	Use_Potions()

	Tick_Food_Drink()
	Enable_Food_Drink()
	Buy_Food_Drink()
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

	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("1 - 350 开锁 野外练习","1 - 350 Chest Level up")) 

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("支持职业 - 盗贼","Class supportive - ROGUE"))
	
	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("请勾选 导航 - 服务器地图包 需要跨大陆进行练习","Please enable Sever navigation"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("请自行购买 - ","Please buy yourself with - ")..Check_Client("潜行者工具","Thieves' Tools"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("70级 开锁才能练到 350, 1级 5点上限","Only Level 70 could level to 350, 1 level = 5 skill points"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("天赋请自行随意设置","Please set ur talent with ur favor"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("1 - 100 部落 贫瘠之地 (需要自己手动上船)","1 - 100 The Barrens (Manually go up to the ship)"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("1 - 100 联盟 赤脊山","1 - 100 Alliance Redridge Mountains"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("100 - 175 希尔斯布莱德丘陵","100 - 175 Hillsbrad Foothills"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("175 - 215 荒芜之地","175 - 215 Badlands"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("215 - 300 灼热峡谷","215 - 300 Searing Gorge"))

	Basic_UI.Guide.Py = Basic_UI.Guide.Py - 30
	local Header = Create_Header(Basic_UI.Guide.frame,"TOPLEFT",10, Basic_UI.Guide.Py,Check_UI("300 - 350 外域","300 - 350 OutLand"))
end

Create_Nav_UI()
Create_Config_UI()
Create_Sell_UI()
Create_Destroy_UI()
Create_Mail_UI()
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
			    awm.FaceDirection(awm.GetAnglesBetweenObjects("player","target"))
				C_Timer.After(0.5,function() awm.MoveForwardStart() end)
				C_Timer.After(2,function() Try_Stop() end)
			end
		elseif Miss_Reason == "IMMUNE" then
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
local Herb_Level_Monitor = ""
local Initial_Herb_Level = Skill_Level(rs["开锁"])
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
		Herb_Level_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Herb_Level_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Herb_Level_Monitor:SetText(Check_UI("采药等级提升: ","Herbalism Level up: ")..Initial_Herb_Level)
		Herb_Level_Monitor:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Loot_Amount_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Loot_Amount_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Loot_Amount_Monitor:SetText(Check_UI("已采集物品: ","Gather total amount: ")..#Item_Has_Loot)
		Loot_Amount_Monitor:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Black_List_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Black_List_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Black_List_Monitor:SetText(Check_UI("已拉黑物品: ","Blacklist total amount: ")..#Black_List)
		Black_List_Monitor:Show()
	else
	    Dungeon_Run_Time:SetText(Check_UI("运行时间: ","Running time: ")..math.floor(GetTime() - Run_Time)..Check_UI(" 秒"," seconds"))
		Herb_Level_Monitor:SetText(Check_UI("开锁等级提升: ","Lockpicking Level up: ")..(Skill_Level(rs["开锁"]) - Initial_Herb_Level))
		Loot_Amount_Monitor:SetText(Check_UI("已采集物品: ","Gather total amount: ")..#Item_Has_Loot)
		Black_List_Monitor:SetText(Check_UI("已拉黑物品: ","Blacklist total amount: ")..#Black_List)
	end
end)