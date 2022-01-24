Function_Load_In = true
local Function_Version = "1229"
textout(Check_UI("蒸汽地窟 - "..Function_Version,"Steamvault - "..Function_Version))

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
    Notice:SetText("<"..Note_Head.."> "..text)
end


_,Class = awm.UnitClass("player")
local Faction = UnitFactionGroup("player")
local Realm = GetRealmName() -- 服务器名称
Level = awm.UnitLevel("player")
local _,Race = UnitRace("player")
------------------------------------------------------------------------
local Run_Timer = false
local Run_Time = GetTime()
local Out_Dungeon_Time = GetTime()
local Dungeon_Time = 0

Easy_Data.Sever_Map_Calculated = false
Continent_Move = false

local Destroy_Time = 0
local Dead_Repop = GetTime() -- 死亡后多少秒开始跑尸体

local Dungeon_step = 1 -- 副本步骤
local Dungeon_step1 = 1 -- 打怪
local Dungeon_step2 = 1 -- 出本
local Dungeon_move = 1
local gather_move = 1
local Target_Item = nil
local Obj_x,Obj_y,Obj_z = 0,0,0

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

local Dungeon_In = {mapid = 1946, x = 820, y = 6960, z = -80.6}
local Dungeon_Out = {mapid = 1946, x = -28, y= 4, z = -4.28}
local Dungeon_Flush_Point = {mapid = 1946, x = 817.21, y = 6934.93, z = -80.59}

local Flush_Time = false
local Dungeon_Flush = false -- 是否爆本
local Real_Flush = false -- 触发爆本
local Real_Flush_time = 0 -- 第一次爆本时间
local Real_Flush_times = 0 -- 爆本计数

local Merchant_Coord = {mapid = 1946, x = -1707, y = -1424, z = 34}
local Merchant_Name = "匠人比尔"

local Mail_Coord = {mapid = 1946, x = -1656, y = -1344, z = 32}
local Has_Mail = false

local Flash_Coord = {mapid = 1946, x = -1707, y = -1424, z = 34}
local Flash_Name = ""

local Reset_Instance = false

local Interact_Step = false
local HasStop = false

local SP_Timer = false -- 玛拉顿技能计时
local SP_Time = 0
local Target_Monster = nil -- 玛拉顿选定怪物

local Body_Choose = false -- 尸体选择
local Body_Target = nil
local Open_Slot = false
local Open_Slot_Time = 0
local Body_Choose_Time = 0 -- 尸体选择冷却
local Body_Number = 0

local OBJ_Killed = {} -- 统计击杀数
local Need_Reset = false -- 判断是否为残本

local log_Spell = false

local Using_Fixed_Path = false
local Fixed_Move = 1
local Shui_Ku = Check_Client("盘牙水库","Coilfang Reservoir")
local Fixed_Finish = false

local Start_Buy_Flash = false
local Has_Bought_Flash = false

local Vanish_Time = 0

if Easy_Data.ResetTimes == nil then
    Easy_Data.ResetTimes = {}
end

function Vars_Reset()
     Dungeon_step = 1
	 Dungeon_step1 = 1
	 Dungeon_step2 = 1
	 Dungeon_move = 1
	 HasStop = false
	 Target_Monster = nil
	 OBJ_Killed = {}
	 if Easy_Data["清理分解黑名单"] then
	     Easy_Data["不分解物品"] = ""
		 Basic_UI.Disenchant["分解物品"]:SetText(Easy_Data["不分解物品"])
	 end
end
function Event_Reset()
    Dungeon_move = 1
	Dungeon_step1 = 1
	Dungeon_step2 = 1
	HasStop = false
	Target_Monster = nil
end

function CheckDeadOrNot() -- 判断角色是否死亡
    if awm.UnitIsDeadOrGhost("player") and not CheckBuff("player",rs["假死"]) then
	    if not awm.UnitIsGhost("player") then

		    Dead_Repop = GetTime()

			local Path = 
			{
			{565.56,6940.61,16.84},{564.99,6941.14,-5.38},{568.93,6940.79,-26.77},{577.34,6939.47,-40.89},{585.83,6932.56,-42.02},{598.56,6918.92,-45.57},{603.49,6909.79,-47.12},{607.54,6900.28,-48.22},{610.75,6892.74,-49.10},{615.56,6888.97,-57.20},{624.14,6881.87,-69.89},{631.53,6874.67,-74.60},{640.99,6865.70,-79.47},{652.42,6866.18,-82.56},{658.28,6865.26,-81.57},{668.91,6862.13,-75.58},{677.19,6859.68,-72.13}
			}

			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance == 545 and not Using_Fixed_Path then
			    Using_Fixed_Path = true
				Fixed_Move = 1
				Fixed_Finish = false
				textout(Check_UI("副本内死亡","Die in dungeon"))
			end

			if Instance == 545 and not Reset_Instance and Dungeon_move >= 141 then
			    Reset_Instance = true
			end

			Event_Reset()

			local Px,Py,Pz = awm.ObjectPosition("player")
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,731,6862,-70)
			local distance2 = awm.GetDistanceBetweenPositions(Px,Py,Pz,820,6960,-80.6)
			if (GetSubZoneText() == Shui_Ku or ((distance1 < 180 or distance2 < 180) and Pz <= -62)) and not Using_Fixed_Path then
				Go_In_Dungeon()
				Fixed_Finish = false
				textout(Check_UI("盘牙水库死亡","Die near the dungeon"))
			end

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
    local deathx,deathy,deathz = awm.GetCorpsePosition()

    if GetTime() - Dead_Repop <= 5 then
	    Note_Set(Check_UI("等待跑尸复活时间 = ","Time waitting for going to Retrieve Corpse = ")..math.floor(5 - GetTime() + Dead_Repop))

		local Px,Py,Pz = awm.ObjectPosition("player")
		local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,731,6862,-70)
		local distance2 = awm.GetDistanceBetweenPositions(Px,Py,Pz,820,6960,-80.6)
		if (GetSubZoneText() == Shui_Ku or ((distance1 < 180 or distance2 < 180) and deathz <= -62)) and not Using_Fixed_Path then
			Go_In_Dungeon()
			Fixed_Finish = false
			textout(Check_UI("盘牙水库死亡","Die near the dungeon"))
		end
	    return
	end

	Event_Reset()

	frame:SetBackdropColor(0,0,0,0)
	local Px,Py,Pz = awm.ObjectPosition("player")
	local DeathDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,deathx,deathy,deathz)
	if DeathDistance == nil then
	    return
	end
	if Coprse_In_Range then
	    awm.RetrieveCorpse()
	end
	if DeathDistance > 2 and not InstanceCorpse then
	    Note_Set(Check_UI("剩余距离 = ","Corpse Distance = ")..math.floor(DeathDistance))
		Interact_Step = false
	    
		if (awm.GetDistanceBetweenPositions(deathx,deathy,deathz,764,6915,-70) < 5 and not Using_Fixed_Path and not Fixed_Finish) or (Using_Fixed_Path and not Fixed_Finish) then
		    if GetSubZoneText() == Shui_Ku and Pz <= -65 then
			    Using_Fixed_Path = false
				Fixed_Finish = true
				return
			end
			Go_In_Dungeon()
			return
		end
		
		Run(deathx,deathy,deathz)
		return
	elseif DeathDistance <= 2 or InstanceCorpse then
	    if InstanceCorpse then
		    Note_Set(Check_UI("尸体在副本内","Corpse in dungeon"))
			local x,y,z = 820,6960,-80.6
			if Interact_Step then
			    x,y,z = 817.21,6934.93,-80.59
			end
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 2 then
		        Run(x,y,z)
				return
			else
				if not Interact_Step then
				    Interact_Step = true
					C_Timer.After(5,function()
					    if Interact_Step then
							Interact_Step = false
						end
					end)
				end				
			end
		end
		Note_Set(Check_UI("复活尸体","Retrieve Corpse"))
		awm.RetrieveCorpse()
	end
end

function NeedHeal()-- 判断血蓝吃喝
    if not awm.UnitAffectingCombat("player") then
	    if Class == "MAGE" then
		    Easy_Data["回血物品"] = EatCount()
			Easy_Data["回蓝物品"] = DrinkCount()
		end

		local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	    local Cur_Power = (awm.UnitPower("player")/awm.UnitPowerMax("player")) * 100
		if Cur_Health < 99 and not CheckBuff("player",rs["进食"]) then
			Note_Set(Check_UI("使用回血...","Restore health..."))
			if IsMounted() then
				Dismount()
			end
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
				if not Item_Used then
				    Item_Used = true
					C_Timer.After(1.5,function() Item_Used = false end)
					awm.UseItemByName(Easy_Data["回血物品"])
					textout(Check_UI("使用回血物品...","Use food item"))
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(5,function() Stop_Moving = false end)
			end
			return false
		end
		if Cur_Power < 99 and not CheckBuff("player",rs["喝水"]) then
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			if IsMounted() then
				Dismount()
			end
			Start_Restore = true
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
				if not Item_Used then
				    Item_Used = true
					C_Timer.After(1.5,function() Item_Used = false end)
					awm.UseItemByName(Easy_Data["回蓝物品"])
					textout(Check_UI("使用回蓝物品...","Use drink item"))
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(5,function() Stop_Moving = false end)
			end
			return false
		end
		if CheckBuff("player",rs["喝水"]) and (Cur_Health < 99 or Cur_Power < 99) then
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			return false
		end
		if CheckBuff("player",rs["进食"]) and (Cur_Health < 99 or Cur_Power < 99) then
			Note_Set(Check_UI("回血中...","Restore health..."))
			return false
		end
    end
	return true
end

function Buff_Check()
    if Class == "MAGE" and not awm.UnitAffectingCombat("player") and not IsMounted() then
		if not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
			if Spell_Castable(rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) then
				awm.TargetUnit("player")
				awm.CastSpellByName(rs["冰甲术"])
				return false
			end
			if Spell_Castable(rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
				awm.TargetUnit("player")
				awm.CastSpellByName(rs["霜甲术"])
				return false
			end
		end
		if Spell_Castable(rs["奥术智慧"]) and not CheckBuff("player",rs["奥术智慧"]) and awm.UnitPower("player")/awm.UnitPowerMax("player") > 0.9 then
			awm.TargetUnit("player")
			awm.CastSpellByName(rs["奥术智慧"])
			return false
		end
		if not MakingDrinkOrEat() then
			return false
		end
	end
	if Class == "PRIEST" and not IsMounted() then
		if not CheckBuff("player",rs["暗影形态"]) and Spell_Castable(rs["暗影形态"]) then
			awm.TargetUnit("player")
			awm.CastSpellByName(rs["暗影形态"])
			return false
		end
		if not CheckBuff("player",rs["真言术：韧"]) and Spell_Castable(rs["真言术：韧"]) and awm.UnitPower("player")/awm.UnitPowerMax("player") > 0.9 and not awm.UnitAffectingCombat("player") then
			awm.TargetUnit("player")
			awm.CastSpellByName(rs["真言术：韧"])
			return false
		end
	end
	if Class == "WARLOCK" and not IsMounted() then
		if not CheckBuff("player",rs["术士魔甲术"]) and Spell_Castable(rs["术士魔甲术"]) then
			awm.TargetUnit("player")
			awm.CastSpellByName(rs["术士魔甲术"])
			return false
		end
	end
	if Class == "HUNTER" and not IsMounted() then
	    if Easy_Data["需要召唤宠物"] then
			if not PetHasActionBar() and not IsMounted() then
				if not Pet_Dead and not Has_Call_Pet and Level > 11 then
					Note_Set(Check_UI("尝试召唤宠物...","Try to call pet"))
					Has_Call_Pet = true
					if Spell_Castable(rs["召唤宠物"]) and not Spell_Casting and not Spell_Channel_Casting then
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
					if Spell_Castable(rs["复活宠物"]) and not Spell_Casting and not Spell_Channel_Casting then
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
				if Spell_Castable(rs["复活宠物"]) and not Spell_Casting and not Spell_Channel_Casting then
					awm.CastSpellByName(rs["复活宠物"])
				end
				return false
			elseif PetHasActionBar() and not awm.UnitIsDead("pet") and (awm.UnitHealth("pet")/awm.UnitHealthMax("pet")) < 0.5 and not IsMounted() and not awm.UnitAffectingCombat("player") then
				Note_Set(Check_UI("治疗宠物中...","Healing pet..."))
				if not Stop_Moving and GetUnitSpeed("player") > 0 then
					Stop_Moving = true
					Try_Stop()
					C_Timer.After(5,function() Stop_Moving = false end)
				end
				if Spell_Castable(rs["治疗宠物"]) and not Spell_Casting and not Spell_Channel_Casting then
					awm.CastSpellByName(rs["治疗宠物"])
					return false
				end
				return false
			end
			if PetHasActionBar() and not IsMounted() and not awm.UnitAffectingCombat("player") and not awm.UnitIsDead("pet") then
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

		if Spell_Castable(rs["雄鹰守护"]) and not CheckBuff("player",rs["雄鹰守护"]) then
		     awm.TargetUnit("player")
			 awm.CastSpellByName(rs["雄鹰守护"])
			 return false
		end

		if Spell_Castable(rs["强击光环"]) and not CheckBuff("player",rs["强击光环"]) then
		     awm.TargetUnit("player")
			 awm.CastSpellByName(rs["强击光环"])
			 return false
		end
	end
	if Class == "DRUID" and not IsMounted() and not CheckBuff("player",rs["野性印记"]) then
	    awm.CastSpellByName(rs["野性印记"],"player")
	end
	if Class == "DRUID" and not IsMounted() and not CheckBuff("player",rs["荆棘术"]) then
	    awm.CastSpellByName(rs["荆棘术"],"player")
	end
	return true
end
function CheckUse()
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
	if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力红宝石"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(8008) then
		awm.UseItemByName(rs["法力红宝石"])
	end
	if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力黄水晶"]) > 0 and not CastingBarFrame:IsVisible()  and CheckCooldown(8007) then
		awm.UseItemByName(rs["法力黄水晶"])
	end
	if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力翡翠"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5513) then
		awm.UseItemByName(rs["法力翡翠"])
	end
	if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力玛瑙"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5514) then
		awm.UseItemByName(rs["法力玛瑙"])
	end
	if awm.UnitPower("player") < 1000 and GetItemCount(Check_Client("特效法力药水","Major Mana Potion")) > 0 and not CastingBarFrame:IsVisible() and (CheckCooldown(13444)) then
		awm.UseItemByName(Check_Client("特效法力药水","Major Mana Potion"))
	end
	if awm.UnitHealth("player") < 2000 and GetItemCount(Check_Client("特效治疗药水","Major Healing Potion")) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(13446) then
		awm.UseItemByName(Check_Client("特效治疗药水","Major Healing Potion"))
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
	if SellDistance > 3 then 
	    Note_Set(Check_UI(Merchant_Name.." ,坐标 = "..x..","..y..","..z, Merchant_Name..", Coord = "..x..","..y..","..z))
		Run(x,y,z)
		Sell.Interact_Step = false
	elseif SellDistance <= 3 then
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
			if not Sell.Interact_Step then
				Sell.Interact_Step = true
				C_Timer.After(0.1, function() 
				Sell.Interact_Step = false
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
				textout(Check_UI("卖物完成","Vendor Process End"))
				Using_Fixed_Path = false
				Fixed_Finish = false
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
            if not Sell.Interact_Step then
				Sell.Interact_Step = true
				C_Timer.After(1, function() Sell.Interact_Step = false awm.InteractUnit("target") end)
			end
			return					
		end
	end
end

function ValidItem(item) -- 不售卖的装备列表
	local ItemList = string.split(Easy_Data["保留物品"],",")
    -- Loops through all spells to see if we have a matching spells with the one passed in
	if Easy_Data["回血物品"] ~= nil and GetItemCount(Easy_Data["回血物品"]) < 10 and item == Easy_Data["回血物品"] then
	    return true
	end
	if Easy_Data["回蓝物品"] ~= nil and GetItemCount(Easy_Data["回蓝物品"]) < 10 and item == Easy_Data["回蓝物品"] then
	    return true
	end

	if (item == Check_Client("特效法力药水","Major Mana Potion") or item == Check_Client("特效治疗药水","Major Healing Potion")) and GetItemCount(item) <= 10 then
	    return true
	end
	if item == Check_Client("矿工锄","Mining Pick") or item == Check_Client("剥皮小刀","Skinning Knife") or item == Check_Client("潜行者工具","Thieves' Tools") or item == Check_Client("闪光粉","Flash Powder") then
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
    -- Loops through all spells to see if we have a matching spells with the one passed in
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
				if item and not ValidItem(item) then -- 去除保留物品
					if (item and Valid_Destroy(item)) or (item and Valid_Destroy_Quality(quality)) then
						awm.PickupContainerItem(bag, slot)
						awm.DeleteCursorItem()
					end
				end
			end
        end
    end
end

function Buy_Flash(name)
    local Num = GetMerchantNumItems()
	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == name then
		    if GetMoney() >= money then
				BuyMerchantItem(i,1)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 1个","Buy Foods At Store Slot "..i.." For 1"))
			else
			    Has_Bought_Flash = true
			    textout(Check_UI("没有足够钱财购买闪光粉","Not enough money to buy Flash Powder"))
				return
			end
		end
	end
end
function Flash_Run(x,y,z)
	local Name = Flash_Name
    local Px,Py,Pz = awm.ObjectPosition("player")
	local SellDistance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if SellDistance > 3 then 
	    Note_Set(Check_UI("购买闪光粉 = "..Name,"Go buy Flash Powder, Vendor name - "..Name))
		Run(x,y,z)
		Interact_Step = false
	elseif SellDistance <= 3 then
	    Note_Set(Check_UI("正在购买闪光粉","Flash Powder buying"))
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
			local Flash_Count = GetItemCount(rs["闪光粉"])
			if Flash_Count < Easy_Data["闪光粉购买数量"] and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(2,function() Interact_Step = false end)
				Buy_Flash(rs["闪光粉"])
			elseif Flash_Count >= Easy_Data["闪光粉购买数量"] then
			    Start_Buy_Flash = false
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

local Disenchant_Black_Name = "" -- 正在被分解的物品无法被分解, 加入黑名单
local HasDisenchant = false
local HasDisenchant_Time = 0
local Disenchant_bag = nil
local Disenchant_slot = nil
function Valid_Resolve_Quality(q) -- 装备品质比较
    if q == 0 and Easy_Data["分解灰色"] then
	    return true
	elseif q == 1 and Easy_Data["分解白色"] then
	    return true
	elseif q == 2 and Easy_Data["分解绿色"] then
	    return true
	elseif q == 3 and Easy_Data["分解蓝色"] then
	    return true
	elseif q == 4 and Easy_Data["分解紫色"] then
	    return true
	end
	return false
end
function ValidResolve(item)
    local ResolveList = string.split(Easy_Data["不分解物品"],",")
    -- Loops through all spells to see if we have a matching spells with the one passed in
    if #ResolveList > 0 then
		for i = 0, #ResolveList, 1 do
			if ResolveList[i] == item then
				return true
			end
		end
	end
end
function Check_ResolveItemExist()
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
				local type = select(6, GetItemInfo(link))
				if type == ARMOR or type == WEAPON then
					if item and Valid_Resolve_Quality(quality) and not ValidResolve(item) then
						return false
					end
				end
			end
		end
	end
	return true
end
function Auto_Resolve() -- 自动分解
    if CastingBarFrame:IsVisible() then
	    return
	end
	if HasDisenchant then
	    local time = GetTime() - HasDisenchant_Time
	    if time > 5 then
		    HasDisenchant = false
		end
		return
	end
	if Disenchant_bag ~= nil and Disenchant_slot ~= nil then
	    local link = GetContainerItemLink(Disenchant_bag, Disenchant_slot)
		if link == nil then
		    Disenchant_bag = nil
			Disenchant_slot = nil
			textout(Check_UI("物品分解完毕或消失","Item Disappear or Has Been Disenchanted"))
			return
		end
        local item = select(1, GetItemInfo(link))
		local quality = select(3, GetItemInfo(link))
		local type = select(6, GetItemInfo(link))
		if type == "Armor" or type == "Weapon" or type == "武器" or type == "护甲" then
			if item == nil or not Valid_Resolve_Quality(quality) or ValidResolve(item) then
				Disenchant_bag = nil
				Disenchant_slot = nil
				textout(Check_UI("物品分解完毕或消失","Item Disappear or Has Been Disenchanted"))
				return
			end
		else
		    Disenchant_bag = nil
			Disenchant_slot = nil
			textout(Check_UI("物品不是武器或者护甲","Item is not Wepaon or Armor"))
			return
		end


	    if not awm.SpellIsTargeting() then
			awm.CastSpellByName(Check_Client("分解","Disenchant"))
			textout(Check_UI("释放技能 - 分解","Cast - Disenchant"))
			return
		else
			if not HasDisenchant then
				HasDisenchant = true
				HasDisenchant_Time = GetTime()
			end
			Disenchant_Black_Name = item
			awm.UseContainerItem(Disenchant_bag, Disenchant_slot)
			textout(Check_UI("开始分解","Begin To Disenchant"))
		end
	    return
	end
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
				local type = select(6, GetItemInfo(link))
				if type == "Armor" or type == "Weapon" or type == "武器" or type == "护甲" then
					if item and Valid_Resolve_Quality(quality) and not ValidResolve(item) then
						Disenchant_bag = bag
						Disenchant_slot = slot
						Disenchant_Black_Name = item
						textout(Check_UI("分解第"..Disenchant_bag.."背包中第"..Disenchant_slot.."格物品","Disenchant item location - Bag "..Disenchant_bag..", Slot - "..Disenchant_slot))
						return
					end
				end
			end
        end
    end
end

function Out_Dungeon_buff()
    if not awm.UnitAffectingCombat("player") and not IsMounted() then -- 判断角色buff
		if DoesSpellExist(rs["冰甲术"]) and (not CheckBuff("player",rs["冰甲术"])) and Spell_Castable(rs["冰甲术"]) then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["冰甲术"])
			return false
		end
		if DoesSpellExist(rs["野性印记"]) and (not CheckBuff("player",rs["野性印记"])) and Spell_Castable(rs["野性印记"]) then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["野性印记"])
			return false
		end
		if DoesSpellExist(rs["猎豹守护"]) and (not CheckBuff("player",rs["猎豹守护"])) and Spell_Castable(rs["猎豹守护"]) and not Mount_useble then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["猎豹守护"])
			return false
		end
		if DoesSpellExist(rs["王者祝福"]) and (not CheckBuff("player",rs["王者祝福"])) and Spell_Castable(rs["王者祝福"]) then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["王者祝福"])
			return false
		end
		if DoesSpellExist(rs["虔诚光环"]) and (not CheckBuff("player",rs["虔诚光环"])) and Spell_Castable(rs["虔诚光环"]) then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["虔诚光环"])
			return false
		end
		if DoesSpellExist(rs["真言术：韧"]) and (not CheckBuff("player",rs["真言术：韧"])) and Spell_Castable(rs["真言术：韧"]) then
			if (IsMounted()) then
				Dismount()
			end
			awm.CastSpellByName(rs["真言术：韧"])
			return false
		end
		if DoesSpellExist(rs["术士魔甲术"]) and (not CheckBuff("player",rs["术士魔甲术"])) and Spell_Castable(rs["术士魔甲术"]) and Class == "WARLOCK" then
			if IsMounted() then
				Dismount()
			end
			awm.CastSpellByName(rs["术士魔甲术"])
			return false
		end
	end
	return true
end

function IsFacing(x,y,z)
    local px,py,pz = awm.ObjectPosition("player")
    local facing = awm.GetAnglesBetweenPositions(px,py,pz,x,y,z)
	local face = awm.UnitFacing("player")
	local player_Face = math.floor(face * 10^3  + 0.5) / 10^3
	local Angle_Face = math.floor(facing * 10^3  + 0.5) / 10^3
	if math.abs(player_Face - Angle_Face) < 0.01 then
	    return true
	else
	    return false
	end
end
function FacePosition(x,y,z)
    local px,py,pz = awm.ObjectPosition("player")
    local facing = awm.GetAnglesBetweenPositions(px,py,pz,x,y,z)
	awm.FaceDirection(facing)
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

function Find_Game_Obj(x,y,z,scan_range)
    local table = {
	{Check_Client("远古苔","Ancient Lichen"),340,"Herb"},
	{Check_Client("魔草","Felweed"),300,"Herb"},
	{Check_Client("邪雾草","Ragveil"),325,"Herb"},
	{Check_Client("烈焰菇","Flame Cap"),335,"Herb"},
	{Check_Client("梦露花","Dreaming Glory"),315,"Herb"},

	{Check_Client("魔铁矿脉","Fel Iron Deposit"),300,"Mine"},
	{Check_Client("精金矿脉","Adamantite Deposit"),325,"Mine"},
	{Check_Client("富精金矿脉","Rich Adamantite Deposit"),350,"Mine"},
	{Check_Client("氪金矿脉","Khorium Vein"),375,"Mine"},
	}
    local target = nil
    local total = awm.GetObjectCount()
	local Far_Distance = 60
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.UnitFullName(ThisUnit)
		local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
		local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z1)
		for t = 1,#table do
		    local info = table[t]
			local name,level,type = info[1],info[2],info[3]
			local Current_level = 0
			if type == "Herb" then
			    Current_level = Skill_Level(rs["草药学"])
			else
			    Current_level = Skill_Level(rs["采矿"])
			end
			if awm.ObjectIsGameObject(ThisUnit) and guid ~= nil and name == guid and Current_level >= level and distance < Far_Distance and distance < scan_range then
			    if type == "Mine" and Easy_Data["蒸汽采矿"] and GetItemCount(Check_Client("矿工锄","Mining Pick")) > 0 then
					Far_Distance = distance
					target = ThisUnit
				elseif type == "Herb" and Easy_Data["蒸汽采药"] then
				    Far_Distance = distance
					target = ThisUnit
				end
			end
		end
	end
	return target
end


function Gather_Process()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end
	frame:SetBackdropColor(0,0,0,0)

    if Dungeon_step1 == 1 then
		HasStop = false

		Note_Head = Check_UI("初始化","First enter")

		local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
		local Out_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
		if Out_Distance == nil then
		    return
		end
		if (Easy_Data["需要卖物"] or Easy_Data["需要修理"]) and (not Check_BagFree() or Sell.Step ~= 1) and Out_Distance < 40 then
		    Note_Set(Check_UI("出本卖物 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
		    Run(x1,y1,z1)
			return
		end

		local path = {{-8.11,6.99,-4.29}}
		if Dungeon_move > #path then
		    Dungeon_step1 = 2
			Dungeon_move = 1
			return
		end
		Note_Set(Check_UI("出发出发","Go to reach point")..Dungeon_move)
		local Coord = path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if distance > 1 then
			if Dungeon_move == 1 and distance > 30 then
			    awm.Stuck()
				return
			end
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 2 then -- 开始流程
	    Note_Head = Check_UI("巡逻地图","Searching maps")

		local Path = 
		{
		{-16.66,5.96,-4.29},
		{-3.13,4.32,-4.28},
		{-13.45,-14.13,-5.07},
		{-13.85,-26.68,-8.49},
		{-13.80,-43.34,-13.51},
		{-10.74,-50.91,-16.24},
		{-9.95,-56.18,-18.06}, -- 闷 17802 -6.48,-63.7,-19.92
		{-8.11,-62.13,-19.92},
		{-9.55,-68.80,-19.92},
		{-14.28,-77.60,-19.92},
		{-13.24,-83.70,-19.92}, -- 扫 17802/17801 > 30, -7.01,-92.08,-20.98
		{-6.42,-97.31,-21.94},
		{-1.64,-106.62,-21.79},
		{3.11,-109.52,-21.50}, -- 扫 17802/17801 > 30, 8.25,-121.79,-21.25
		{18.07,-131.37,-22.22},
		{14.20,-136.99,-22.22}, -- 闷 17802, 扫自己位置8码
		{14.80,-145.60,-22.45},
		{17.41,-150.86,-22.62},
		{17.51,-156.47,-22.53},
		{12.18,-162.32,-22.40},
		{8.66,-163.29,-22.30},
		{7.44,-167.48,-22.21}, -- 21695 < 5, 18.08,-191.95,-22.43 扰乱
		{-1.03,-178.48,-23.08},
		{-4.41,-192.91,-22.04},
		{-15.82,-200.16,-21.89},
		{-23.61,-201.32,-21.94},
		{-30.17,-199.74,-20.98},
		{-37.31,-188.78,-20.11},
		{-45.56,-179.71,-20.03},
		{-49.97,-176.67,-20.13}, -- 扫矿 -53.29,-175.58,-20.02
		{-42.88,-182.15,-20.04},
		{-38.95,-189.32,-19.95},
		{-34.23,-194.66,-20.13},
		{-30.70,-200.81,-20.63},
		{-24.26,-209.75,-20.66},
		{-15.86,-221.96,-20.81},
		{-7.44,-241.91,-19.70},
		{-9.10,-246.28,-16.07},
		{-12.12,-258.12,-19.36},
		{-3.79,-267.34,-18.23},
		{-2.00,-271.49,-14.81},
		{1.56,-278.04,-11.01}, -- 扫矿 4.75,-278.01,-8.36
		{3.73,-280.80,-10.81},
		{5.73,-286.60,-15.14},
		{12.85,-290.67,-15.03}, -- 扫 17802 < 35 55.36,-307.24,-7.87
		{25.73,-286.40,-16.75},
		{37.13,-281.38,-18.52},
		{43.57,-275.38,-20.47},
		{50.00,-268.59,-21.96}, -- 扫 44.92,-270.04,-21.83
		{44.18,-275.82,-20.33}, -- 扫 17802 < 35 55.36,-307.24,-7.87 
		{10.08,-294.46,-14.73},
		{-15.03,-312.05,-29.57}, -- 扫草 -15.03, -312.05, -62.49
		{-10.99,-280.73,-28.58},
		{-15.85,-259.17,-18.87},
		{-15.10,-244.85,-12.17},
		{2.63,-229.51,-21.79}, -- 扫矿 6.10,-229.52,-22.17
		{-14.84,-227.88,-20.79},
		{-25.41,-222.78,-19.66},
		{-31.57,-223.38,-18.85}, -- 闷 17800 -36.61,-216.91,-18.30
		{-37.95,-217.73,-18.45},
		{-42.96,-220.47,-18.55},
		{-44.90,-221.66,-18.48},
		{-45.13,-227.76,-18.34},
		{-57.02,-229.39,-17.92}, -- 开始 闷离自己最近的盘牙战士
		{-65.15,-235.48,-18.80},
		{-70.98,-234.14,-19.03},
		{-73.64,-237.76,-19.08},
		{-77.60,-241.65,-17.99},
		{-73.44,-246.39,-17.20},
		{-80.25,-253.15,-13.02},
		{-83.15,-257.24,-11.62},
		{-84.69,-261.70,-10.31},
		{-85.00,-264.92,-9.56},
		{-84.61,-269.82,-9.39},
		{-77.47,-271.97,-8.57},
		{-76.52,-276.93,-7.77}, -- 结束 闷棍扫描
		{-74.48,-279.07,-7.77},
		{-76.42,-283.08,-7.77}, -- 扫 17800 < 5, -88.88,-366.57,-7.76
		{-72.94,-291.08,-7.77},
		{-70.48,-297.07,-7.76},
		{-71.53,-321.67,-7.77},
		{-68.15,-343.17,-7.77},
		{-68.30,-372.74,-7.77},
		{-120.87,-374.74,-7.77},
		{-136.84,-358.62,-7.77},
		{-129.75,-346.80,-7.72},
		{-126.28,-344.56,-7.62},
		{-116.59,-340.46,-7.48},
		{-123.78,-331.92,-7.41},
		{-149.77,-315.02,-7.40},
		{-166.23,-304.09,-7.69},
		{-172.74,-294.23,-8.00}, -- 闷 17800 -169.91,-285.36,-8.16
		{-173.32,-280.60,-8.14},
		{-189.55,-269.11,-7.77},
		{-203.43,-269.18,-8.02},
		{-225.32,-269.51,-7.87},
		{-246.57,-256.81,-8.81},
		{-243.60,-249.43,-7.78},
		{-243.71,-226.75,-8.10},
		{-243.50,-209.93,-8.08},
		{-243.36,-198.83,-8.01},
		{-259.29,-187.41,-7.67},
		{-262.65,-183.21,-7.39}, -- 扫矿 -262.35,-186.12,-7.60
		{-247.43,-161.83,-4.30}, -- 扫草 -245.75,-163.17,-2.66
		{-230.10,-143.04,-3.64},
		{-207.47,-150.61,-3.23},
		{-204.72,-173.01,-2.65},
		{-213.95,-186.11,-5.03},
		{-216.43,-182.46,-4.15}, -- 扫草 -220.60,-186.44,-5.34
		{-201.47,-168.22,-3.32},
		{-210.27,-149.29,-2.46},
		{-229.59,-144.42,-2.84},
		{-249.00,-163.44,-4.84},
		{-260.29,-168.56,-6.81},
		{-274.22,-155.65,-5.96},
		{-282.99,-142.19,-8.71},
		{-285.79,-137.86,-7.94},
		{-257.63,-114.64,-9.82},
		{-256.08,-104.50,-7.76},
		{-246.60,-108.57,-7.76},
		{-202.97,-122.56,-6.22}, -- 扫矿 -202.97,-122.56,-6.22
		{-205.81,-103.24,-7.75}, -- 扫草 -205.81,-103.24,-7.75
		{-217.95,-87.07,-7.76},
		{-241.28,-83.83,-7.76},
		{-260.26,-109.56,-7.76},
		{-285.92,-137.24,-7.82},
		{-300.82,-136.56,-8.22},
		{-315.40,-148.18,-8.28},
		{-336.76,-152.93,-7.14},
		{-387.07,-159.18,-7.76}, -- 扫矿 -388.82,-157.54,-7.75
		{-365.01,-136.89,-7.76}, -- 扫矿 -363.75,-135.72,-7.75
		{-357.45,-138.82,-7.76}, -- 扫草 -354.51,-136.02,-7.75
		{-358.6598,-123.2519,-7.7555},
		{-354.4349,-118.4225,-7.7555},
		{-352.7416,-116.6652,-7.7555},
		{-354.1198,-111.9759,-7.7555},
		{-363.8176,-87.5658,-7.7555}, -- 扫矿 -364.52,-85.54,-6.72
		{-352.4515,-116.6829,-7.7555},
		{-357.45,-138.82,-7.76},
		{-354.17,-151.17,-7.38},
		{-342.36,-167.69,-7.75},
		{-339.35,-195.10,-7.76}, -- 扫矿 -339.41,-196.92,-5.72 
		{-324.98,-183.60,-7.76},
		{-310.45,-206.33,-7.76}, -- 扫草 -310.21, -206.71, -7.75
		{-328.18,-180.72,-7.75}, -- 扫草 -328.18,-180.72,-7.75
		{-290.67,-191.27,-7.76}, -- 扫矿 -287.92,-192.02,-7.75
		{-270.19,-180.96,-30.50},
		{-271.31,-206.74,-30.50}, -- 扫草 -271.31,-206.74,-67.64
		{-304.82,-221.42,-29.48},
		{-303.75,-253.22,-27.68},
		{-286.18,-262.70,-20.47},
		{-265.17,-265.68,-10.85},
		{-229.15,-267.13,-7.85},
		{-189.22,-269.21,-7.76},
		{-176.54,-269.87,-7.76},
		{-173.23,-277.83,-7.98}, -- 闷 17800 -169.91,-285.36,-8.16
		{-172.83,-283.32,-8.11},
		{-170.47,-297.55,-7.97},
		{-160.97,-313.38,-7.41},
		{-135.69,-301.82,-7.45}, -- 取消潜行
		{-122.75,-305.17,-29.76},
		{-89.84,-300.78,-29.48},
		{-52.47,-292.27,-29.48},
		{-12.90,-288.05,-29.48}, -- 恢复潜行
		{-12.98,-273.84,-24.98},
		{-15.88,-255.35,-17.82},
		{-8.81,-240.53,-19.55},
		{-19.44,-211.40,-21.61},
		{-7.60,-193.21,-21.81}, -- 21695 < 5, 18.08,-191.95,-22.43 扰乱
		{10.37,-169.33,-22.27},
		{11.64,-161.11,-22.40}, -- 闷 17802, 扫自己位置8码
		{15.02,-155.09,-22.56},
		{17.45,-143.45,-22.70},
		{19.31,-133.95,-22.24},
		{21.52,-122.66,-22.20},
		{20.72,-106.77,-21.23},
		{2.56,-91.18,-21.86},
		{-6.79,-83.83,-19.92},
		{-11.30,-71.34,-19.92}, -- 闷 17802 -6.48,-63.7,-19.92
		{-8.51,-61.98,-19.92},
		{-7.74,-54.58,-17.55},
		{-8.44,-23.89,-7.55},
		{-4.24,-11.84,-4.66},
		{-2.83,-3.71,-4.33},
		{-7.79,5.43,-4.24},
		}
		if Dungeon_move > #Path then
		    Dungeon_step = 2
		    Dungeon_step1 = 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		Note_Set(Dungeon_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))

		if Distance > 1 then
		    SP_Timer = false

			local starttime, duration, enabled, _ = GetSpellCooldown(rs["潜行"])
			local endtime = starttime + duration

			if not CheckBuff("player",rs["潜行"]) and GetTime() > endtime and not awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["潜行"])
			    return
			end

			if awm.UnitAffectingCombat("player") and Spell_Castable(rs["消失"]) and GetItemCount(Check_Client("闪光粉","Flash Powder")) > 0 then
			    awm.CastSpellByName(rs["消失"])
			    return
			end

			if Dungeon_move >= 64 and Dungeon_move <= 76 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
						if guid == 17802 and distance < Far_Distance then
							Far_Distance = distance
							target = ThisUnit
						end
					end
				end
				if target ~= nil then
				    if Spell_Castable(rs["闷棍"]) then
				        awm.CastSpellByName(rs["闷棍"],target)
					end
				end
			end

			awm.Interval_Move(x,y,z)

			return 
		elseif Distance <= 1 then
			HasStop = false

			if Dungeon_move == 7 or Dungeon_move == 16 or Dungeon_move == 59 or Dungeon_move == 92 or Dungeon_move == 156 or Dungeon_move == 171 or Dungeon_move == 179 then
			    local tarx,tary,tarz = 0,0,0
				local Mob_Id = 0
				local Far_Distance = 30
				if Dungeon_move == 7 or Dungeon_move == 179 then
				    tarx,tary,tarz = -6.48,-63.7,-19.92
					Mob_Id = 17802
					Far_Distance = 30
				elseif Dungeon_move == 16 or Dungeon_move == 171 then
				    tarx,tary,tarz = Px,Py,Pz
					Mob_Id = 17802
					Far_Distance = 25
				elseif Dungeon_move == 59 then
				    tarx,tary,tarz = -36.61,-216.91,-18.30
					Mob_Id = 17800
					Far_Distance = 10
				elseif Dungeon_move == 92 then
				    tarx,tary,tarz = -169.91,-285.36,-8.16
					Mob_Id = 17800
					Far_Distance = 10
				elseif Dungeon_move == 156 then
				    tarx,tary,tarz = -169.91,-285.36,-8.16
					Mob_Id = 17800
					Far_Distance = 10
				end

			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
						if guid == Mob_Id and distance < Far_Distance then
							Far_Distance = distance
							target = ThisUnit
						end
					end
				end
				if target ~= nil then
				    TargetUnit(target)
				    if CheckDebuffByName(target,rs["闷棍"]) then
					    Dungeon_move = Dungeon_move + 1
						return
					end
				    if Spell_Castable(rs["闷棍"]) then
					    if GetUnitSpeed("player") > 0 then
					        Try_Stop()
						end
					    awm.FaceTarget(target)
				        awm.CastSpellByName(rs["闷棍"],target)
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 11 or Dungeon_move == 14 or Dungeon_move == 22 or Dungeon_move == 169 or Dungeon_move == 175 then
			    local tarx,tary,tarz = 0,0,0
				local Mob_Id = 0
				local Aviod_Distance = 30

				if Dungeon_move == 11 then
				    tarx,tary,tarz = -7.01,-92.08,-20.98
					Mob_Id = 17802
					Aviod_Distance = 10
				elseif Dungeon_move == 14 then
				    tarx,tary,tarz = 8.25,-121.79,-21.25
					Mob_Id = 17802
					Aviod_Distance = 10
				elseif Dungeon_move == 22 or Dungeon_move == 169 then
				    tarx,tary,tarz = -1.03,-178.48,-23.08
					Mob_Id = 21695
					Aviod_Distance = 15
				elseif Dungeon_move == 175 then
				    tarx,tary,tarz = 14,-97,-22
					Mob_Id = 17802
					Aviod_Distance = 15
				end

				local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
						if guid == Mob_Id and distance < Aviod_Distance then
							Aviod_Distance = distance
							target = ThisUnit
						end
					end
				end
				if target ~= nil then
				    return
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 45 or Dungeon_move == 50 or Dungeon_move == 76 then
			    local tarx,tary,tarz = 0,0,0
				local Mob_Id = 0
				local Aviod_Distance = 30

				if Dungeon_move == 45 or Dungeon_move == 50 then
				    tarx,tary,tarz = 55.36,-307.24,-7.87
					Mob_Id = 17802
					Aviod_Distance = 15
				elseif Dungeon_move == 76 then
				    tarx,tary,tarz = -88.88,-366.57,-7.76
					Mob_Id = 17800
					Aviod_Distance = 20
				end

				local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
						if guid == Mob_Id and distance < Aviod_Distance then
							Far_Distance = distance
							target = ThisUnit
						end
					end
				end
				if target == nil then
				    return
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 30 or Dungeon_move == 42 or Dungeon_move == 49 or Dungeon_move == 52 or Dungeon_move == 103 or Dungeon_move == 104 or Dungeon_move == 121 or Dungeon_move == 122 or Dungeon_move == 130 or Dungeon_move == 131 or Dungeon_move == 132 or Dungeon_move == 137 or Dungeon_move == 142 or Dungeon_move == 144 or Dungeon_move == 145 or Dungeon_move == 146 or Dungeon_move == 148 then
			    local x,y,z = 0,0,0
				local scan_range = 8

				if Dungeon_move == 30 then
				    x,y,z = -53.29,-175.58,-20.02
					scan_range = 3
				elseif Dungeon_move == 42 then
				    x,y,z = 4.75,-278.01,-8.36
					scan_range = 3
				elseif Dungeon_move == 49 then
				    x,y,z = 44.92,-270.04,-21.83
					scan_range = 3
				elseif Dungeon_move == 52 then
				    x,y,z = -15.03, -312.05, -62.49
					scan_range = 3
				elseif Dungeon_move == 103 then
				    x,y,z = -262.35,-186.12,-7.60
					scan_range = 3
				elseif Dungeon_move == 104 then
				    x,y,z = -245.75,-163.17,-2.66
					scan_range = 3
				elseif Dungeon_move == 121 then
				    x,y,z = -202.97,-122.56,-6.22
					scan_range = 3
				elseif Dungeon_move == 122 then
				    x,y,z = -205.81,-103.24,-7.75
					scan_range = 3
				elseif Dungeon_move == 122 then
				    x,y,z = -205.81,-103.24,-7.75
					scan_range = 3
				elseif Dungeon_move == 130 then
				    x,y,z = -388.82,-157.54,-7.75
					scan_range = 3
				elseif Dungeon_move == 131 then
				    x,y,z = -363.75,-135.72,-7.75
					scan_range = 3
				elseif Dungeon_move == 132 then
				    x,y,z = -354.51,-136.02,-7.75
					scan_range = 3
				elseif Dungeon_move == 137 then
				    x,y,z = -364.52,-85.54,-6.72
					scan_range = 3
				elseif Dungeon_move == 142 then
				    x,y,z = -339.41,-196.92,-5.72
					scan_range = 3
				elseif Dungeon_move == 144 then
				    x,y,z = -310.21, -206.71, -7.75
					scan_range = 3
				elseif Dungeon_move == 145 then
				    x,y,z = -328.18,-180.72,-7.75
					scan_range = 3
				elseif Dungeon_move == 146 then
				    x,y,z = -287.92,-192.02,-7.75
					scan_range = 3
				elseif Dungeon_move == 148 then
				    x,y,z = -271.31,-206.74,-67.64
					scan_range = 3
				end
				local target = Find_Game_Obj(x,y,z,scan_range)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				else
				    Target_Item = target
					Obj_x,Obj_y,Obj_z = awm.ObjectPosition(Target_Item)
					Dungeon_step1 = 30
					gather_move = 1
					textout(Check_UI("采集 - ","Gather - ")..awm.UnitFullName(Target_Item)..", "..math.floor(awm.GetDistanceBetweenObjects("player",Target_Item)))
				end
				return
			end

			if (Dungeon_move == 82 or Dungeon_move == 83 or Dungeon_move == 91) and Easy_Data["蒸汽开锁"] then
			    local x,y,z = 0,0,0
				local scan_range = 8
				local step = 0

				if Dungeon_move == 83 and Easy_Data["右箱子"] then
				    x,y,z = -47.32,-368.25,-7.76
					scan_range = 8
					step = 33
				elseif Dungeon_move == 82 and Easy_Data["左箱子卡桥"] then
				    x,y,z = -54.52,-320.91,-7.76
					scan_range = 8
					step = 34
				elseif Dungeon_move == 82 and Easy_Data["左箱子下水"] then
				    x,y,z = -54.52,-320.91,-7.76
					scan_range = 8
					step = 37
				elseif Dungeon_move == 91 and Easy_Data["守卫箱子"] then
				    x,y,z = -153.6201,-273.9537,-7.7555
					scan_range = 8
					step = 35
				end

				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = scan_range
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z1)
					if guid ~= nil and (guid == 184941 or (Skill_Level(rs["开锁"]) >= 350 and guid == 184940)) and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end

				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				else
				    Target_Item = target
					Obj_x,Obj_y,Obj_z = awm.ObjectPosition(Target_Item)
					Dungeon_step1 = step
					gather_move = 1
					textout(Check_UI("采集 - ","Gather - ")..awm.UnitFullName(Target_Item)..", "..math.floor(awm.GetDistanceBetweenObjects("player",Target_Item)))
				end
				return
			end

			if Dungeon_move == 56 then
			    local x,y,z = 6.10,-229.52,-22.17
				local scan_range = 4
			    local target = Find_Game_Obj(x,y,z,scan_range)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				else
				    Target_Item = target
					Obj_x,Obj_y,Obj_z = awm.ObjectPosition(Target_Item)
					Dungeon_step1 = 31
					gather_move = 1
					textout(Check_UI("采集 - ","Gather - ")..awm.UnitFullName(Target_Item)..", "..math.floor(awm.GetDistanceBetweenObjects("player",Target_Item)))
				end
				return
			end
			if Dungeon_move == 109 then
			    local x,y,z = -220.60,-186.44,-5.34
				local scan_range = 3
			    local target = Find_Game_Obj(x,y,z,scan_range)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				else
				    Target_Item = target
					Obj_x,Obj_y,Obj_z = awm.ObjectPosition(Target_Item)
					Dungeon_step1 = 32
					gather_move = 1
					textout(Check_UI("采集 - ","Gather - ")..awm.UnitFullName(Target_Item)..", "..math.floor(awm.GetDistanceBetweenObjects("player",Target_Item)))
				end
				return
			end

			if Easy_Data["蒸汽吸气"] and (Dungeon_move == 114 or (Dungeon_move >= 117 and Dungeon_move <= 125) or (Dungeon_move >= 141 and Dungeon_move <= 146)) and GetItemCount(Check_Client("气阀微粒提取器","Zapthrottle Mote Extractor")) > 0 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 20
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z1)
					if guid ~= nil and guid == 17378 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end

				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				else
				    Target_Item = target
					Obj_x,Obj_y,Obj_z = awm.ObjectPosition(Target_Item)
					Dungeon_step1 = 36
					gather_move = 1
					textout(Check_UI("采集 - ","Gather - ")..awm.UnitFullName(Target_Item)..", "..math.floor(awm.GetDistanceBetweenObjects("player",Target_Item)))
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 30 then -- 双采步骤
	    Note_Head = Check_UI("采集","Gathering")
		if not awm.ObjectExists(Target_Item) then
		    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
			    Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
			    if Spell_Castable(rs["潜行"]) then
			        awm.CastSpellByName(rs["潜行"])
				end
			    return
			end
			Dungeon_step1 = 2
			return
		else
			local x,y,z = awm.ObjectPosition(Target_Item)
			local distance = awm.GetDistanceBetweenObjects("player",Target_Item)
			if distance <= 4 then
			    Note_Set(Check_UI("距离内, 距离 = ","In Distance, Distance = ")..string.format("%.1f", distance))

				if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end

			    if LootFrame:IsVisible() then
					if GetNumLootItems() == 0 then
						CloseLoot()
						LootFrame_Close()
					end
					for i = 1,GetNumLootItems() do
						LootSlot(i)
						ConfirmLootSlot(i)
					end
					return
				end
			    awm.InteractUnit(Target_Item)
			else
			    Note_Set(Check_UI("距离外, 距离 = ","Out Distance, Distance = ")..string.format("%.1f", distance))
			    awm.Interval_Move(x,y,z)
			end
		end
	end
	if Dungeon_step1 == 31 then -- 台子旁的矿
	    Note_Head = Check_UI("采集","Gathering")
	    if gather_move == 1 then
			if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
			    if Spell_Castable(rs["潜行"]) then
			        awm.CastSpellByName(rs["潜行"])
				end
			    return
			end

		    local x,y,z = -2.08,-242.65,-21.52
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 1 then
			    awm.Interval_Move(x,y,z)
			else
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 30
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(4.97,-246.32,-22.85,x1,y1,z1)
					if guid == 17802 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
				    if CheckDebuffByName(target,rs["闷棍"]) then
					    gather_move = gather_move + 1
						return
					end
				    if Spell_Castable(rs["闷棍"]) then
					    if GetUnitSpeed("player") > 0 then
					        Try_Stop()
						end
					    awm.FaceTarget(target)
				        awm.CastSpellByName(rs["闷棍"],target)
					end
				else
				    gather_move = gather_move + 1
				end
				return
			end
		end

		if gather_move == 2 then
		    local x,y,z = 2.63,-229.51,-21.79
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 1 then
			    awm.Interval_Move(x,y,z)
			else
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 15

				local Men = false
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(39.66,-206.20,-22.61,x1,y1,z1)
					if guid == 21695 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
					if guid == 17802 and awm.GetDistanceBetweenPositions(4.97,-246.32,-22.85,x1,y1,z1) < 10 then
					    if CheckDebuffByName(ThisUnit,rs["闷棍"]) then
						    Men = true
						end
					end
				end
				if not Men then
				    gather_move = 1
					textout(Check_UI("怪物闷棍效果消失","Mob Debuff gone"))
				    return
				end

				if target ~= nil then
					if not awm.ObjectExists(Target_Item) then
					    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
							Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
							if Spell_Castable(rs["潜行"]) then
								awm.CastSpellByName(rs["潜行"])
							end
							return
						end
						Dungeon_step1 = 2
						return
					else
						local x,y,z = awm.ObjectPosition(Target_Item)
						local distance = awm.GetDistanceBetweenObjects("player",Target_Item)
						if distance <= 4 then
							if LootFrame:IsVisible() then
								if GetNumLootItems() == 0 then
									CloseLoot()
									LootFrame_Close()
								end
								for i = 1,GetNumLootItems() do
									LootSlot(i)
									ConfirmLootSlot(i)
								end
								return
							end
							awm.InteractUnit(Target_Item)
						else
							awm.Interval_Move(x,y,z)
						end
					end
				else
				    gather_move = gather_move + 1
				    return
				end
				return
			end
		end

		if gather_move == 3 then
		    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
			    if Spell_Castable(rs["潜行"]) then
			        awm.CastSpellByName(rs["潜行"])
				end
			    return
			end
			if awm.UnitAffectingCombat("player") and Spell_Castable(rs["消失"]) and GetItemCount(Check_Client("闪光粉","Flash Powder")) > 0 then
			    awm.CastSpellByName(rs["消失"])
			    return
			end

		    local x,y,z = 2.63,-229.51,-21.79
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 1 then
			    awm.Interval_Move(x,y,z)
			else
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 15

				local Men = false
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(39.66,-206.20,-22.61,x1,y1,z1)
					if guid == 21695 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end

					if guid == 17802 and awm.GetDistanceBetweenPositions(4.97,-246.32,-22.85,x1,y1,z1) < 10 then
					    if CheckDebuffByName(ThisUnit,rs["闷棍"]) then
						    Men = true
						end
					end
				end

				if not Men then
				    gather_move = 1
					textout(Check_UI("怪物闷棍效果消失","Mob Debuff gone"))
				    return
				end

				if target ~= nil then
				    gather_move = 2
				else
				    return
				end
				return
			end
		end
	end
	if Dungeon_step1 == 32 then -- 树旁边的草药
	    Note_Head = Check_UI("采集","Gathering")
	    if gather_move == 1 then
			if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
			    Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
			    if Spell_Castable(rs["潜行"]) then
			        awm.CastSpellByName(rs["潜行"])
				end
			    return
			end

		    local x,y,z = -225.81,-189.58,-6.02
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 1 then
			    Run(x,y,z)
			else
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 3
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-232.86,-192.24,-6.63,x1,y1,z1)
					if guid == 17805 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
				    if CheckDebuffByName(target,rs["闷棍"]) then
					    gather_move = gather_move + 1
						return
					end
				    if Spell_Castable(rs["闷棍"]) then
					    if GetUnitSpeed("player") then
					        Try_Stop()
						end
					    awm.FaceTarget(target)
				        awm.CastSpellByName(rs["闷棍"],target)
					end
				else
				    gather_move = gather_move + 1
				end
				return
			end
		end

		if gather_move == 2 then
		    local x,y,z = -216.93,-186.54,-5.05
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 1 then
			    awm.Interval_Move(x,y,z)
			else
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 15

				local Men = false
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(39.66,-206.20,-22.61,x1,y1,z1)
					if guid == 17805 and awm.GetDistanceBetweenPositions(-232.86,-192.24,-6.63,x1,y1,z1) < 3 then
					    if CheckDebuffByName(ThisUnit,rs["闷棍"]) then
						    Men = true
						end
					end
				end
				if not Men then
				    gather_move = 1
					textout(Check_UI("怪物闷棍效果消失","Mob Debuff gone"))
				    return
				end
				if not awm.ObjectExists(Target_Item) then
				    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
						Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
						if Spell_Castable(rs["潜行"]) then
							awm.CastSpellByName(rs["潜行"])
						end
						return
					end
					Dungeon_step1 = 2
					return
				else
					local x,y,z = awm.ObjectPosition(Target_Item)
					local distance = awm.GetDistanceBetweenObjects("player",Target_Item)
					if distance <= 4 then
						if LootFrame:IsVisible() then
							if GetNumLootItems() == 0 then
								CloseLoot()
								LootFrame_Close()
							end
							for i = 1,GetNumLootItems() do
								LootSlot(i)
								ConfirmLootSlot(i)
							end
							return
						end
						awm.InteractUnit(Target_Item)
					else
						awm.Interval_Move(x,y,z)
					end
				end
				return
			end
		end
	end

	if Dungeon_step1 == 33 then -- 右边箱子
	    Note_Head = Check_UI("采集箱子 - 右","Gathering Chest - Right")
		local Path = 
		{
		{-94.8566,-390.5045,-7.7939}, -- 等待 110 到达位置
		{-90.77,-378.55,-7.76}, -- 扫怪物
		{-90.77,-378.55,-7.76}, -- 射击怪物
		{-120.12,-370.85,-7.77},
		{-131.55,-366.32,-7.77},
		{-134.01,-355.16,-7.77},
		{-161.02,-344.17,-29.55}, -- 等待15秒
		{-169.02,-348.17,-29.52},
		{-198.31,-343.54,-29.80},
		{-224.67,-325.88,-29.48},
		{-284.10,-230.52,-29.49},
		{-286.70,-223.60,-29.48},
		{-295.59,-222.04,-29.48},
		{-302.29,-226.13,-29.48},
		{-305.96,-255.39,-26.92},
		{-276.34,-271.52,-14.59},
		{-260.93,-270.23,-9.14},
		{-245.90,-266.34,-8.68}, -- 开始扰乱
		{-236.55,-269.31,-7.78},
		{-228.45,-272.06,-7.76}, -- 暗影步 17799 -206.16,-268.93,-8.08
		{-184.70,-266.64,-7.76}, -- 开疾跑 闪避 清buff
		{-173.23,-280.61,-8.14},
		{-161.86,-307.11,-7.50}, -- 致盲
		{-134.26,-323.97,-7.41},
		{-120.91,-330.80,-7.41},
		{-92.58,-340.16,-7.77},
		{-61.03,-354.55,-7.77},
		{-51.68,-358.71,-7.77}, -- 消失
		{-47.19,-364.45,-7.77}, -- 开盒子
		{-50.8849,-386.0176,-7.7717},
		{-67.2252,-389.6039,-7.7673},
		}
		local Coord = Path[gather_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if gather_move == 20 and DoesSpellExist(rs["暗影步"]) then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))
		    local starttime, duration, enabled, _ = GetSpellCooldown(rs["暗影步"])
			local endtime = starttime + duration
			if GetTime() < endtime then
				gather_move = 21
				return
			end
		    if Distance > 1 and Spell_Castable(rs["暗影步"]) then
			    awm.Interval_Move(x,y,z + 0.3)
			elseif Distance < 1 and Spell_Castable(rs["暗影步"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-206.16,-268.93,-8.08,x1,y1,z1)
					if guid == 17799 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["暗影步"],target)
				end
			end
			return
		end

		if Distance > 1 then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))

		    SP_Timer = false

			if gather_move >= 18 and gather_move <= 21 and Spell_Castable(rs["扰乱"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-225.53,-255.75,-7.90,x1,y1,z1)
					if guid == 17805 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					local distance = awm.GetDistanceBetweenObjects("player",target)
					if distance < 30 then
					    if not awm.IsAoEPending() then
						    awm.CastSpellByName(rs["扰乱"])
						else
						    local tarx,tary,tarz = awm.ObjectPosition(target)
						    awm.ClickPosition(tarx,tary,tarz)
						end
					end
				end
			end

			if gather_move >= 19 and gather_move <= 25 then
			    local Run_starttime, Run_duration, Run_enabled, _ = GetSpellCooldown(rs["疾跑"])
				local Run_endtime = Run_starttime + Run_duration
				if GetTime() < Run_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["疾跑"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			    if Spell_Castable(rs["疾跑"]) then
				    awm.CastSpellByName(rs["疾跑"])
				end

				local Avoid_starttime, Avoid_duration, Avoid_enabled, _ = GetSpellCooldown(rs["闪避"])
				local Avoid_endtime = Avoid_starttime + Avoid_duration
				if GetTime() < Avoid_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["闪避"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end

				if Spell_Castable(rs["闪避"]) then
				    awm.CastSpellByName(rs["闪避"])
				end
				if Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) then
				    awm.CastSpellByName(rs["暗影斗篷"])
				end

				if not Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["伺机待发"]) then
				    awm.CastSpellByName(rs["伺机待发"])
				end
			end

			if (gather_move == 23 or gather_move == 24) and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-169.91,-285.36,-8.16,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
			end

			local starttime, duration, enabled, _ = GetSpellCooldown(rs["潜行"])
			local endtime = starttime + duration

			if not CheckBuff("player",rs["潜行"]) and GetTime() > endtime and not awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["潜行"])
			    return
			end

			awm.Interval_Move(x,y,z + 0.3)

			return 
		elseif Distance <= 1 then
		    if gather_move == 1 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime then
				    Note_Set(math.floor(endtime - GetTime())..Check_UI(", 等待消失CD",", Wait for vanish CD") )
					return
				end


				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 8
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-67.03,-349.04,-7.76,x1,y1,z1)
					if guid == 17722 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					gather_move = 2
				else
					return
				end
				return
			end

			if gather_move == 2 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5

				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-57.51,-376.58,-7.76,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						target = ThisUnit
						Far_Distance = distance
					end
				end
				if target ~= nil then
					Target_Monster = target
					gather_move = 3
					return
				end
				return
			end

			if gather_move == 3 then
			    if awm.ObjectExists(Target_Monster) and not awm.UnitAffectingCombat(Target_Monster) then
					if tonumber(Easy_Data["射击动作条"]) == nil then
						Easy_Data["射击动作条"] = 2
					end
					awm.TargetUnit(Target_Monster)
					if not CastingBarFrame:IsVisible() then
						awm.UseAction(Easy_Data["射击动作条"])
					end
				elseif not awm.ObjectExists(Target_Monster) then
					gather_move = 2
				elseif awm.UnitAffectingCombat(Target_Monster) then
					gather_move = 4
				end
				return
			end

			if gather_move == 7 then
			    if not SP_Timer then
				    SP_Time = GetTime()
					SP_Timer = true
					return
				else
				    local time = GetTime() - SP_Time
					if time >= 15 then
					    gather_move = gather_move + 1
						SP_Timer = false
						return
					end
				end
				return
			end

			if (gather_move == 23 or gather_move == 24) and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-169.91,-285.36,-8.16,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
				return
			end

			if (gather_move == 28 or gather_move == 29) and Spell_Castable(rs["消失"]) and awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["消失"])
				Vanish_Time = GetTime()
				return
			elseif (gather_move == 28 or gather_move == 29) and not Spell_Castable(rs["消失"]) and awm.UnitAffectingCombat("player") and GetTime() - Vanish_Time > 1.5 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime and Spell_Castable(rs["伺机待发"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			end

			if gather_move == 29 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				if duration > 0 and GetTime() < starttime + 3 then
				    return
				end

			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-47.32,-368.25,-7.76,x1,y1,z1)
					if (guid == 184941 or guid == 184940) and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.InteractUnit(target)
				else
				    gather_move = gather_move + 1
					return
				end
				return
			end

			if gather_move == 31 then
			    gather_move = 1
				Dungeon_move = 84
				Dungeon_step1 = 2
			    return
			end

		    gather_move = gather_move + 1
		end
	end
	if Dungeon_step1 == 34 then -- 左边箱子
	    Note_Head = Check_UI("采集箱子 - 左","Gathering Chest - Left")
		local Path = 
		{
		{-53.5101,-351.7153,-7.7673}, -- 1 等待 110 到达位置
		{-95.4833,-333.3281,-7.7672},
		{-104.9476,-331.5238,-7.7053}, -- 3 闷 17722 -110,-330,-7.65
		{-111.7371,-328.3338,-7.4783},
		{-103.8123,-315.3171,-7.7033}, -- 5 等待 110 到达位置
		{-90.8499,-311.7054,-7.7673}, -- 6 扫怪物
		{-90.8499,-311.7054,-7.7673}, -- 7 射击怪物

		{-96.2205,-316.1225,-7.7673}, -- 8 开始疾跑 闪避
		{-102.7933,-317.2707,-7.6806}, -- 9 致盲 海妖
		{-116.7624,-321.7784,-7.4079},
		{-147.9220,-324.9357,-7.4326},
		{-145.6628,-324.7951,-7.4170},
		{-149.5957,-328.0672,-7.5073}, -- 13 结束 疾跑 闪避
		{-147.2747,-329.4021,-8.1565}, -- 14 等待45秒 -- -147.2747,-329.3821,-8.1565
		{-147.5807,-323.3647,-7.4349}, -- 15 跳出来
		{-134.26,-323.97,-7.41},
		{-112.1645,-322.5121,-7.4070},
		{-74.4742,-328.4383,-7.7673},
		{-66.2647,-326.3569,-7.7673},
		{-59.8539,-324.5054,-7.7673}, -- 20 消失
		{-51.60,-322.75,-7.76}, -- 21 开盒子
		{-45.26,-321.01,-7.77},
		{-37.26,-331.96,-7.77},
		{-40.10,-343.14,-7.77},
		{-44.31,-348.81,-7.77},
		{-55.68,-349.97,-7.77},
		{-59.38,-347.80,-7.77},
		}
		local Coord = Path[gather_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 0.8 then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))
		    SP_Timer = false

			if gather_move >= 8 and gather_move <= 13 then
			    local Run_starttime, Run_duration, Run_enabled, _ = GetSpellCooldown(rs["疾跑"])
				local Run_endtime = Run_starttime + Run_duration
				if GetTime() < Run_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["疾跑"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			    if Spell_Castable(rs["疾跑"]) then
				    awm.CastSpellByName(rs["疾跑"])
				end

				local Avoid_starttime, Avoid_duration, Avoid_enabled, _ = GetSpellCooldown(rs["闪避"])
				local Avoid_endtime = Avoid_starttime + Avoid_duration
				if GetTime() < Avoid_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["闪避"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end

				if Spell_Castable(rs["闪避"]) then
				    awm.CastSpellByName(rs["闪避"])
				end
				if Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) then
				    awm.CastSpellByName(rs["暗影斗篷"])
				end

				if not Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["伺机待发"]) then
				    awm.CastSpellByName(rs["伺机待发"])
				end
			end

			if gather_move >= 9 and gather_move <= 13 and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-104,-325,-7,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
			end

			if gather_move == 14 then
			    awm.RunMacroText("/cancelaura "..rs["疾跑"])
			end

			if gather_move == 15 then
			    if not IsFacing(x,y,z) then
				    FacePosition(x,y,z)
					return
				end
				if Pz <= -7.5 then
				    awm.JumpOrAscendStart()
				end

				if Pz <= -12 then
				    awm.Stuck()
					return
				end
			end

			local starttime, duration, enabled, _ = GetSpellCooldown(rs["潜行"])
			local endtime = starttime + duration

			if not CheckBuff("player",rs["潜行"]) and GetTime() > endtime and not awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["潜行"])
			    return
			end

			awm.MoveTo(x,y,z + 0.3)

			return 
		elseif Distance <= 0.8 then
		    if gather_move == 1 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime then
				    Note_Set(math.floor(endtime - GetTime())..Check_UI(", 等待消失CD",", Wait for vanish CD") )
					return
				end

				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-93.30,-317.68,-7.76,x1,y1,z1)
					if guid == 17722 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					gather_move = 2
				else
					return
				end
				return
			end

			if gather_move == 3 then
			    local tarx,tary,tarz = -110,-330,-7.65
				local Mob_Id = 17722
				local Far_Distance = 5

			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
						if guid == Mob_Id and distance < Far_Distance then
							Far_Distance = distance
							target = ThisUnit
						end
					end
				end
				if target ~= nil then
				    TargetUnit(target)
				    if CheckDebuffByName(target,rs["闷棍"]) then
					    gather_move = gather_move + 1
						return
					end
				    if Spell_Castable(rs["闷棍"]) then
					    if GetUnitSpeed("player") > 0 then
					        Try_Stop()
						end
					    awm.FaceTarget(target)
				        awm.CastSpellByName(rs["闷棍"],target)
					end
				else
				    gather_move = gather_move + 1
				end
				return
			end
		  
		    if gather_move == 5 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime then
				    Note_Set(math.floor(endtime - GetTime())..Check_UI(", 等待消失CD",", Wait for vanish CD") )
					return
				end

				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-70.57,-327.33,-7.76,x1,y1,z1)
					if guid == 17722 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					gather_move = gather_move + 1
					return
				else
					return
				end
				return
			end

			if gather_move == 6 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5

				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-60.82,-318.98,-7.76,x1,y1,z1)
					if guid == 17722 and distance < Far_Distance and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						target = ThisUnit
						Far_Distance = distance
					end
				end
				if target ~= nil then
					Target_Monster = target
					gather_move = 7
					return
				end
				return
			end

			if gather_move == 7 then
			    if awm.ObjectExists(Target_Monster) and not awm.UnitAffectingCombat(Target_Monster) then
					if tonumber(Easy_Data["射击动作条"]) == nil then
						Easy_Data["射击动作条"] = 2
					end
					awm.TargetUnit(Target_Monster)
					if not CastingBarFrame:IsVisible() then
						awm.UseAction(Easy_Data["射击动作条"])
					end
				elseif not awm.ObjectExists(Target_Monster) then
					gather_move = 6
				elseif awm.UnitAffectingCombat(Target_Monster) then
					gather_move = 8
				end
				return
			end

			if gather_move == 14 then
			    if not SP_Timer then
				    SP_Time = GetTime()
					SP_Timer = true
					return
				else
				    local time = GetTime() - SP_Time
					if time >= 46 then
					    gather_move = gather_move + 1
						SP_Timer = false
						return
					elseif not Interact_Step and GetUnitSpeed("player") == 0 then
					    Interact_Step = true
					    awm.JumpOrAscendStart()
						C_Timer.After(2,function() Interact_Step = false end)
					end
				end
				return
			end

			if gather_move == 15 then
			    awm.AscendStop()
			end

			if gather_move >= 9 and gather_move <= 13 and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-104,-325,-7,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
			end

			if (gather_move == 20 or gather_move == 21) and Spell_Castable(rs["消失"]) then
			    awm.CastSpellByName(rs["消失"])
				Vanish_Time = GetTime()
				return
			elseif (gather_move == 20 or gather_move == 21) and not Spell_Castable(rs["消失"]) and GetTime() - Vanish_Time > 1.5 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime and Spell_Castable(rs["伺机待发"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			end

			if gather_move == 21 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				if duration > 0 and GetTime() < starttime + 3 then
				    return
				end

			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-54.52,-320.91,-7.76,x1,y1,z1)
					if (guid == 184941 or guid == 184940) and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.InteractUnit(target)
				else
				    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
						Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
						if Spell_Castable(rs["潜行"]) then
							awm.CastSpellByName(rs["潜行"])
						end
						return
					end
				    gather_move = gather_move + 1
					return
				end
				return
			end

			if gather_move == 27 then
			    gather_move = 1
				Dungeon_step1 = 2
				Dungeon_move = 82
			    return
			end

		    gather_move = gather_move + 1
		end
	end
	if Dungeon_step1 == 37 then -- 左边箱子
	    Note_Head = Check_UI("采集箱子 - 左","Gathering Chest - Left")
		local Path = 
		{
		{-53.5101,-351.7153,-7.7673}, -- 等待 110 到达位置
		{-74.2747,-351.6499,-7.7673}, -- 扫怪物
		{-74.2747,-351.6499,-7.7673}, -- 射击怪物
		{-113.4600,-372.5861,-7.7673},
		{-131.8366,-366.5327,-7.7673},
		{-136.7912,-356.7791,-7.7673},
		{-161.02,-344.17,-29.55}, -- 等待15秒
		{-169.02,-348.17,-29.52},
		{-198.31,-343.54,-29.80},
		{-224.67,-325.88,-29.48},
		{-284.10,-230.52,-29.49},
		{-286.70,-223.60,-29.48},
		{-295.59,-222.04,-29.48},
		{-302.29,-226.13,-29.48},
		{-305.96,-255.39,-26.92},
		{-276.34,-271.52,-14.59},
		{-260.93,-270.23,-9.14},
		{-245.90,-266.34,-8.68}, -- 开始扰乱 疾跑 闪避 清debuff
		{-236.55,-269.31,-7.78},
		{-228.45,-272.06,-7.76}, -- 暗影步 17799 -206.16,-268.93,-8.08
		{-184.70,-266.64,-7.76}, -- 开疾跑 闪避 清buff
		{-173.23,-280.61,-8.14},
		{-161.86,-307.11,-7.50}, -- 致盲
		{-134.26,-323.97,-7.41},
		{-112.1645,-322.5121,-7.4070},
		{-74.4742,-328.4383,-7.7673},
		{-66.2647,-326.3569,-7.7673},
		{-59.8539,-324.5054,-7.7673}, -- 消失
		{-51.60,-322.75,-7.76}, -- 开盒子
		{-45.26,-321.01,-7.77},
		{-37.26,-331.96,-7.77},
		{-40.10,-343.14,-7.77},
		{-44.31,-348.81,-7.77},
		{-55.68,-349.97,-7.77},
		{-59.38,-347.80,-7.77},
		}
		local Coord = Path[gather_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if gather_move == 20 and DoesSpellExist(rs["暗影步"]) then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))
		    local starttime, duration, enabled, _ = GetSpellCooldown(rs["暗影步"])
			local endtime = starttime + duration
			if GetTime() < endtime then
				gather_move = 21
				return
			end
		    if Distance > 1 and Spell_Castable(rs["暗影步"]) then
			    awm.Interval_Move(x,y,z + 0.3)
			elseif Distance < 1 and Spell_Castable(rs["暗影步"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-206.16,-268.93,-8.08,x1,y1,z1)
					if guid == 17799 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["暗影步"])
				end
			end
			return
		end

		if Distance > 1 then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))
		    SP_Timer = false

			if gather_move >= 18 and gather_move <= 21 and Spell_Castable(rs["扰乱"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-225.53,-255.75,-7.90,x1,y1,z1)
					if guid == 17805 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					local distance = awm.GetDistanceBetweenObjects("player",target)
					if distance < 30 then
					    if not awm.IsAoEPending() then
						    awm.CastSpellByName(rs["扰乱"])
						else
						    local tarx,tary,tarz = awm.ObjectPosition(target)
						    awm.ClickPosition(tarx,tary,tarz)
						end
					end
				end
			end

			if gather_move >= 17 and gather_move <= 25 then
			    local Run_starttime, Run_duration, Run_enabled, _ = GetSpellCooldown(rs["疾跑"])
				local Run_endtime = Run_starttime + Run_duration
				if GetTime() < Run_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["疾跑"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			    if Spell_Castable(rs["疾跑"]) then
				    awm.CastSpellByName(rs["疾跑"])
				end

				local Avoid_starttime, Avoid_duration, Avoid_enabled, _ = GetSpellCooldown(rs["闪避"])
				local Avoid_endtime = Avoid_starttime + Avoid_duration
				if GetTime() < Avoid_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["闪避"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end

				if Spell_Castable(rs["闪避"]) then
				    awm.CastSpellByName(rs["闪避"])
				end
				if Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) then
				    awm.CastSpellByName(rs["暗影斗篷"])
				end

				if not Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["伺机待发"]) then
				    awm.CastSpellByName(rs["伺机待发"])
				end
			end

			if gather_move == 23 and Spell_Castable(rs["凿击"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-169.91,-285.36,-8.16,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["凿击"],target)
				end
			end

			if gather_move == 24 and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 15
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance and not CheckDebuffByName(ThisUnit,rs["凿击"]) then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
			end

			local starttime, duration, enabled, _ = GetSpellCooldown(rs["潜行"])
			local endtime = starttime + duration

			if not CheckBuff("player",rs["潜行"]) and GetTime() > endtime and not awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["潜行"])
			    return
			end

			awm.Interval_Move(x,y,z + 0.3)

			return 
		elseif Distance <= 1 then

		    if gather_move == 1 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime then
				    Note_Set(math.floor(endtime - GetTime())..Check_UI(", 等待消失CD",", Wait for vanish CD") )
					return
				end

				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-72.01,-320.88,-7.76,x1,y1,z1)
					if guid == 17722 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					gather_move = 2
				else
					return
				end
				return
			end

			if gather_move == 2 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5

				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-53.81,-334.36,-7.76,x1,y1,z1)
					if guid == 17801 and distance < Far_Distance and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						target = ThisUnit
						Far_Distance = distance
					end
				end
				if target ~= nil then
					Target_Monster = target
					gather_move = 3
					return
				end
				return
			end

			if gather_move == 3 then
			    if awm.ObjectExists(Target_Monster) and not awm.UnitAffectingCombat(Target_Monster) then
					if tonumber(Easy_Data["射击动作条"]) == nil then
						Easy_Data["射击动作条"] = 2
					end
					awm.TargetUnit(Target_Monster)
					if not CastingBarFrame:IsVisible() then
						awm.UseAction(Easy_Data["射击动作条"])
					end
				elseif not awm.ObjectExists(Target_Monster) then
					gather_move = 2
				elseif awm.UnitAffectingCombat(Target_Monster) then
					gather_move = 4
				end
				return
			end

			if gather_move == 7 then
			    if not SP_Timer then
				    SP_Time = GetTime()
					SP_Timer = true
					return
				else
				    local time = GetTime() - SP_Time
					if time >= 19 then
					    gather_move = gather_move + 1
						SP_Timer = false
						return
					end
				end
				return
			end

			if gather_move == 23 and Spell_Castable(rs["凿击"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-169.91,-285.36,-8.16,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["凿击"],target)
				end
			end

			if gather_move == 24 and Spell_Castable(rs["致盲"]) then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 15
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance and not CheckDebuffByName(ThisUnit,rs["凿击"]) then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.TargetUnit(target)
					awm.CastSpellByName(rs["致盲"],target)
				end
			end

			if (gather_move == 28 or gather_move == 29) and Spell_Castable(rs["消失"]) and GetTime() - Vanish_Time > 2 then
			    awm.CastSpellByName(rs["消失"])
				Vanish_Time = GetTime()
				return
			elseif (gather_move == 28 or gather_move == 29) and not Spell_Castable(rs["消失"]) and GetTime() - Vanish_Time > 2 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime and Spell_Castable(rs["伺机待发"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			end

			if gather_move == 29 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				if duration > 0 and GetTime() < starttime + 3 then
				    return
				end

			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-54.52,-320.91,-7.76,x1,y1,z1)
					if (guid == 184941 or guid == 184940) and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.InteractUnit(target)
				else
				    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
						Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
						if Spell_Castable(rs["潜行"]) then
							awm.CastSpellByName(rs["潜行"])
						end
						return
					end
				    gather_move = gather_move + 1
					return
				end
				return
			end

			if gather_move == 35 then
			    gather_move = 1
				Dungeon_step1 = 2
				Dungeon_move = 82
			    return
			end

		    gather_move = gather_move + 1
		end
	end

	if Dungeon_step1 == 35 then -- 守卫箱子
	    Note_Head = Check_UI("采集箱子 - 守卫","Gathering Chest - Guard")
		local Path = 
		{
		{-170.0246,-315.7596,-7.5629},
		{-170.0246,-315.7596,-7.5629}, -- 2 扫怪物
		{-170.0246,-315.7596,-7.5629}, -- 3 射击怪物
		{-155.7267,-326.6697,-7.5715},
		{-149.3575,-328.3300,-7.5094},
		{-146.9249,-329.2383,-8.8098}, -- 6 等待45秒
		{-147.5807,-323.3647,-7.4349}, -- 7 跳出来
		{-159.62,-283.37,-8.12},
		{-153.8930,-275.7739,-7.8132}, -- 9 消失
		{-153.8930,-275.7739,-7.8132}, -- 10 开盒子
		{-161.42,-275.42,-7.79},
		{-155.69,-300.18,-7.54},
		{-180.58,-317.33,-7.58},
		}
		local Coord = Path[gather_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 1 then
		    Note_Set(gather_move..Check_UI(", 距离 = ",", Distance = ")..string.format("%.1f", Distance))
		    SP_Timer = false

			if gather_move >= 8 and gather_move <= 9 then
			    local Run_starttime, Run_duration, Run_enabled, _ = GetSpellCooldown(rs["疾跑"])
				local Run_endtime = Run_starttime + Run_duration
				if GetTime() < Run_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["疾跑"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			    if Spell_Castable(rs["疾跑"]) then
				    awm.CastSpellByName(rs["疾跑"])
				end

				local Avoid_starttime, Avoid_duration, Avoid_enabled, _ = GetSpellCooldown(rs["闪避"])
				local Avoid_endtime = Avoid_starttime + Avoid_duration
				if GetTime() < Avoid_endtime and Spell_Castable(rs["伺机待发"]) and not CheckBuff("player",rs["闪避"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end

				if Spell_Castable(rs["闪避"]) then
				    awm.CastSpellByName(rs["闪避"])
				end
				if Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) then
				    awm.CastSpellByName(rs["暗影斗篷"])
				end

				if not Spell_Castable(rs["暗影斗篷"]) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["伺机待发"]) then
				    awm.CastSpellByName(rs["伺机待发"])
				end
			end

			if gather_move == 7 then
			    if not IsFacing(x,y,z) then
				    FacePosition(x,y,z)
					return
				end
				if Pz <= -7.5 then
				    awm.JumpOrAscendStart()
				end
			end

			local starttime, duration, enabled, _ = GetSpellCooldown(rs["潜行"])
			local endtime = starttime + duration

			if not CheckBuff("player",rs["潜行"]) and GetTime() > endtime and not awm.UnitAffectingCombat("player") then
			    awm.CastSpellByName(rs["潜行"])
			    return
			end

			awm.Interval_Move(x,y,z + 0.3)

			return 
		elseif Distance <= 1 then
			if gather_move == 2 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime then
				    Note_Set(math.floor(endtime - GetTime())..Check_UI(", 等待消失CD",", Wait for vanish CD") )
					return
				end

			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 5

				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-159.62,-283.37,-8.128,x1,y1,z1)
					if guid == 17800 and distance < Far_Distance and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						target = ThisUnit
						Far_Distance = distance
					end
				end
				if target ~= nil then
					Target_Monster = target
					gather_move = 3
					return
				end
				return
			end

			if gather_move == 3 then
			    if awm.ObjectExists(Target_Monster) and not awm.UnitAffectingCombat(Target_Monster) then
					if tonumber(Easy_Data["射击动作条"]) == nil then
						Easy_Data["射击动作条"] = 2
					end
					awm.TargetUnit(Target_Monster)
					if not CastingBarFrame:IsVisible() then
						awm.UseAction(Easy_Data["射击动作条"])
					end
				elseif not awm.ObjectExists(Target_Monster) then
					gather_move = 2
				elseif awm.UnitAffectingCombat(Target_Monster) then
					gather_move = 4
				end
				return
			end

			if gather_move == 6 then
			    if not SP_Timer then
				    SP_Time = GetTime()
					SP_Timer = true
					return
				else
				    local time = GetTime() - SP_Time
					if time >= 52 then
					    gather_move = gather_move + 1
						SP_Timer = false
						return
					end
				end
				return
			end

			if gather_move == 7 then
			    awm.AscendStop()
			end

			if (gather_move == 9 or Dungeon_move == 10) and Spell_Castable(rs["消失"]) then
			    awm.CastSpellByName(rs["消失"])
				Vanish_Time = GetTime()
				return
			elseif (gather_move == 9 or Dungeon_move == 10) and not Spell_Castable(rs["消失"]) and GetTime() - Vanish_Time > 1.5 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				local endtime = starttime + duration
				if GetTime() < endtime and Spell_Castable(rs["伺机待发"]) then
					awm.CastSpellByName(rs["伺机待发"])
					return
				end
			end

			if gather_move == 10 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["消失"])
				if duration > 0 and GetTime() < starttime + 3 then
				    return
				end

			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-153.8930,-275.7739,-7.8132,x1,y1,z1)
					if (guid == 184941 or guid == 184940) and distance < Far_Distance then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target ~= nil then
					awm.InteractUnit(target)
				else
				    gather_move = gather_move + 1
					return
				end
				return
			end

			if gather_move == 13 then
			    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
					Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
					if Spell_Castable(rs["潜行"]) then
						awm.CastSpellByName(rs["潜行"])
					end
					return
				end
			    gather_move = 1
				Dungeon_step1 = 2
				return
			end

		    gather_move = gather_move + 1
		end
	end
	if Dungeon_step1 == 36 then -- 吸气步骤
	    Note_Head = Check_UI("采集","Gathering")
		if not awm.ObjectExists(Target_Item) then
		    if not CheckBuff("player",rs["潜行"]) and not awm.UnitAffectingCombat("player") then
			    Note_Set(Check_UI("释放技能 = ","Cast = ")..rs["潜行"])
			    if Spell_Castable(rs["潜行"]) then
			        awm.CastSpellByName(rs["潜行"])
				end
			    return
			end
			Dungeon_step1 = 2
			return
		else
			local x,y,z = awm.ObjectPosition(Target_Item)
			local distance = awm.GetDistanceBetweenObjects("player",Target_Item)
			if distance <= 4 then
			    Note_Set(Check_UI("距离内, 距离 = ","In Distance, Distance = ")..string.format("%.1f", distance))
			    if LootFrame:IsVisible() then
					if GetNumLootItems() == 0 then
						CloseLoot()
						LootFrame_Close()
					end
					for i = 1,GetNumLootItems() do
						LootSlot(i)
						ConfirmLootSlot(i)
					end
					return
				end
			    awm.UseItemByName(Check_Client("气阀微粒提取器","Zapthrottle Mote Extractor"))
			else
			    Note_Set(Check_UI("距离外, 距离 = ","Out Distance, Distance = ")..string.format("%.1f", distance))
			    Run(x,y,z)
			end
		end
	end
end

function Go_Out()
    local Px,Py,Pz = awm.ObjectPosition("player")
    frame:SetBackdropColor(0,0,0,0)
	Note_Set(Check_UI("执行出去副本","Go out dungeon")..Dungeon_step2)
	if Dungeon_step2 == 1 then
	    Try_Stop()
		if DoesSpellExist("分解") or DoesSpellExist("Disenchant") then
			if Easy_Data["需要分解"] and not Check_ResolveItemExist() then
				Note_Set(Check_UI("分解物品 - ","Disenchanting items - ")..Disenchant_Black_Name)
				Auto_Resolve()
				return
			end
		else
		    textout(Check_UI("未检测到有分解技能","No disenchant spell exist"))
		end
		if awm.SpellIsTargeting() then
		    awm.SpellStopTargeting()
			return
		end

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

		if GetItemCount(Check_Client("水之微粒","Mote of Water")) > 10 then
		    awm.UseItemByName(Check_Client("水之微粒","Mote of Water"))
			return
		end


	    Dungeon_step2 = 2
	end

	if Dungeon_step2 == 2 then
		if GetItemCount(6948) == 0 and Easy_Data["卡死重置"] then
			Note_Set(Check_UI("卡死重置副本","Stuck reset dungeon"))
			awm.Stuck()
			return
		else
			if Dungeon_Time <= Easy_Data["副本重置时间"] then
				local waittime = Easy_Data["副本重置时间"] - Dungeon_Time
				waittime = math.floor(waittime)
				Note_Set(Check_UI("等待重置 : "..waittime.." 秒","Wait to reset "..waittime.." seconds"))
				return
			else	
			    Note_Set(Check_UI("执行出本","Go out Dungeon now"))

				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z

				Run(x1,y1,z1)
			end
		end
	end
end

function Go_In_Dungeon()
    Note_Head = Check_UI("进盘牙水库","Go in the dungeon area")
	Px,Py,Pz = awm.ObjectPosition("player")
	local Path = 
	{
	{565.56,6940.61,16.84},{564.99,6941.14,-5.38},{568.93,6940.79,-26.77},{577.34,6939.47,-40.89},{585.83,6932.56,-42.02},{598.56,6918.92,-45.57},{603.49,6909.79,-47.12},{607.54,6900.28,-48.22},{610.75,6892.74,-49.10},{615.56,6888.97,-57.20},{624.14,6881.87,-69.89},{631.53,6874.67,-74.60},{640.99,6865.70,-79.47},{652.42,6866.18,-82.56},{658.28,6865.26,-81.57},{668.91,6862.13,-75.58},{677.19,6859.68,-72.13}
	}

	if not Using_Fixed_Path then
	    Using_Fixed_Path = true
		Fixed_Finish = false
		Fixed_Move = 1
		for i = 1,#Path do
		    local Coord = Path[i]
	        local x,y,z = Coord[1],Coord[2],Coord[3]
		    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance <= 15 then
			    Fixed_Move = i
				return
			end
		end
	end

	if Fixed_Move > #Path then
		Fixed_Move = 1
		HasStop = false
		Fixed_Finish = true
		return
	end
	Note_Set(Fixed_Move)
	local Coord = Path[Fixed_Move]
	local x,y,z = Coord[1],Coord[2],Coord[3]
	local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if Distance > 2.5 then
		SP_Timer = false
		if Fixed_Move == 1 and Distance >= 30 then
		    local Breathing = false
            for i = 1,MIRRORTIMER_NUMTIMERS do
			    if GetMirrorTimerInfo(i) == "BREATH" then
				    Breathing = true
			    end
			end
			if Breathing then
				awm.JumpOrAscendStart()
			else
				awm.AscendStop()
			end
		end
		if Fixed_Move == 2 and Pz >= 10 then
			awm.SetPitch(-1.57)
			if GetUnitSpeed("player") == 0 then
				awm.MoveForwardStart()
				C_Timer.After(1,function() Try_Stop() end)
			end
			return
		end
		if Fixed_Move == 1 then
			Run(x,y,z)
		else
		    awm.Interval_Move(x,y,z)
		end
		return 
	elseif Distance <= 2.5 then 
		HasStop = false
		if Fixed_Move == 1 then
		    Try_Stop()
		end
		Fixed_Move = Fixed_Move + 1
	end
end

function Go_Out_Dungeon()
    Note_Head = Check_UI("出盘牙水库","Out of the dungeon area")
	Px,Py,Pz = awm.ObjectPosition("player")
	local Path = 
	{
	{677.19,6859.68,-72.13},
	{668.91,6862.13,-75.58},
	{658.28,6865.26,-81.57},
	{652.42,6866.18,-82.56},
	{640.99,6865.70,-79.47},
	{631.53,6874.67,-74.60},
	{624.14,6881.87,-69.89},
	{615.56,6888.97,-57.20},
	{610.75,6892.74,-49.10},
	{607.54,6900.28,-48.22},
	{603.49,6909.79,-47.12},
	{598.56,6918.92,-45.57},
	{585.83,6932.56,-42.02},
	{577.34,6939.47,-40.89},
	{568.93,6940.79,-26.77},
	{564.99,6941.14,-5.38},
	{565.56,6940.61,16.84}
	}
	if not Using_Fixed_Path then
	    Using_Fixed_Path = true
		Fixed_Finish = false
		Fixed_Move = 1
	end

	if Fixed_Move > #Path then
		Fixed_Move = 1
		HasStop = false
		Fixed_Finish = true
		return
	end
	Note_Set(Fixed_Move)
	local Coord = Path[Fixed_Move]
	local x,y,z = Coord[1],Coord[2],Coord[3]
	local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
	if Distance > 2 then
		SP_Timer = false
		if Fixed_Move == 1 then
		    Run(x,y,z)
			return
		end
		awm.Interval_Move(x,y,z)
		return 
	elseif Distance <= 2 then 
	    if Fixed_Move == 17 and IsSwimming() then
		    if GetUnitSpeed("player") == 0 then
				awm.SetPitch(1.57)

				MoveForwardStart()
			end
			return
		elseif Fixed_Move == 17 and not IsSwimming() then
		    Try_Stop()
			Fixed_Move = Fixed_Move + 1
			return
		end
		HasStop = false

		Fixed_Move = Fixed_Move + 1
	end
end

function MainThread()
    local Px,Py,Pz = awm.ObjectPosition("player")
	Level = awm.UnitLevel("player")
	local Current_Map = C_Map.GetBestMapForUnit("player")
	local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()

	if Px == nil or Py == nil or Pz == nil then
		return
	end
	
	Dungeon_Time = math.floor(GetTime() - Run_Time)

	if GetTime() - Destroy_Time > 20 then -- 摧毁
	    Destroy_Time = GetTime()
		Auto_Destroy()
	end

	if not frame:IsVisible() then
		awm.ForceQuit()
		return
	end
	if GetItemCount(Check_Client("梦境药剂","Elixir of Dream Vision")) > 0 then
	    Note_Head = Check_UI("反破解","Anti Crack")
	    Note_Set(Check_UI("背包内有梦境药剂, 请移除","Elixir of Dream Vision Count > 0, please detroy it first"))
		return
	end

	if CheckDeadOrNot() then -- 判断人物是否死亡
		Note_Head = Check_UI("死亡跑尸","Deadth Process")
		if Run_Timer and Reset_Instance and awm.UnitIsGhost("player") then
		    local time = Dungeon_Time
			if time <= Easy_Data["副本重置时间"] then
				local waittime = Easy_Data["副本重置时间"] - time
				waittime = math.floor(waittime)
				Note_Set(Check_UI("等待重置 : "..waittime.." 秒","Wait Reset : "..waittime.." Second"))
				return
			else
				Vars_Reset()
				C_Timer.After(10,function() ResetInstances() textout(Check_UI("副本重置成功","Dungeon Reset Success")) end)
				Reset_Instance = false
				Easy_Data.ResetTimes[#Easy_Data.ResetTimes + 1] = GetTime()
				Run_Timer = false
			end
			return
		end

		Event_Reset()
		Death_Run()
		return
	end
	if InstanceCorpse then
	    textout(Check_UI("副本跑尸结束, 重置所有步骤","Enter dungeon to repop, reset all variables"))
		InstanceCorpse = false
		return
	end

	if (Easy_Data["需要卖物"] or Easy_Data["需要修理"]) then
	    if not Check_BagFree() or Sell.Step ~= 1 then
			if Easy_Data["自定义商人"] then
			    Merchant_Name = Easy_Data["自定义商人名字"]
				local Coord = string.split(Easy_Data["自定义商人坐标"],",")
				Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = tonumber(Merchant_Coord.mapid),tonumber(Merchant_Coord.x),tonumber(Merchant_Coord.y),tonumber(Merchant_Coord.z)
			else
				Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1946, -198,5490,21.84
				Merchant_Name = Check_Client("芬德雷·迅矛","Fedryen Swiftspear")
			end

			if Instance == 545 and Dungeon_step == 2 then
				local starttime, durationtime, enable = GetItemCooldown(6948)
				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
				Note_Head = Check_UI("卖物","Vendor")
				if GetItemCount(6948) > 0 and durationtime < 10 then
					CheckProtection()
				
				    if IsMounted() then
						Dismount()
					end
					Note_Set(Check_UI("炉石卖物 = ","Hearth Stone Using, Vendor name = ")..Merchant_Name)
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					frame:SetBackdropColor(0,0,0,0)
					return
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 40 then
					Note_Set(Check_UI("出本卖物 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
					Run(x1,y1,z1)
					frame:SetBackdropColor(0,0,0,0)
					return
				end
		    elseif Instance ~= 545 then
			    frame:SetBackdropColor(0,0,0,0)
			    Note_Head = Check_UI("卖物","Vendor")

			    Event_Reset()
				if not Out_Dungeon_buff() then
					Note_Set(Check_UI("上BUFF...","Buff Adding...."))
					return
				end
				CheckProtection()

				local starttime, durationtime, enable = GetItemCooldown(6948)
				if GetItemCount(6948) > 0 and durationtime < 10 then
				    Note_Set(Check_UI("炉石回城","Using Hearthstone"))
				    if IsMounted() then
					    Dismount()
					end
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					return
				else
				    if (GetSubZoneText() ~= Shui_Ku and Pz >= 10) or Pz >= 10 then
					    Using_Fixed_Path = false
						Fixed_Finish = false
					end
				    if (GetSubZoneText() == Shui_Ku and not Using_Fixed_Path and not Fixed_Finish and Pz <= 10) or (Using_Fixed_Path and not Fixed_Finish) then
					    Go_Out_Dungeon()
						return
					end

				    if not Has_Mail and Easy_Data["需要邮寄"] and Easy_Data["卖物前邮寄"] then
						if Easy_Data["自定义邮箱"] then
							local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
						else
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1946, -198.66, 5506.75, 22.34
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

					if (Easy_Data["服务器地图"] and Merchant_Coord.mapid ~= nil and Current_Map ~= Merchant_Coord.mapid and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
					    if Current_Map == Merchant_Coord.mapid then
						    Easy_Data.Sever_Map_Calculated = false
							Continent_Move = false
						end
						Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
						Sever_Run(Current_Map,Merchant_Coord.mapid,Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z)
						return
					end

					Sell_JunkRun(Merchant_Coord.x, Merchant_Coord.y, Merchant_Coord.z)
				end
				return
			end
		end
	end

	if Easy_Data["购买闪光粉"] then
	    if Has_Bought_Flash then
		    Start_Buy_Flash = false
			if GetMoney() > 2000 then
			    Has_Bought_Flash = false
			end
		end
		if (Start_Buy_Flash or GetItemCount(rs["闪光粉"]) < Easy_Data["闪光粉购买触发"]) and not Has_Bought_Flash then
		    if Faction == "Horde" then
				Flash_Coord.mapid, Flash_Coord.x,Flash_Coord.y,Flash_Coord.z = 1944,225.4818,2839.3574,131.3409
				Flash_Name = 16588
			else
			    Flash_Coord.mapid, Flash_Coord.x,Flash_Coord.y,Flash_Coord.z = 1944,-782,2757,120
				Flash_Name = 16829
			end
		   
			if Instance == 545 and Dungeon_step == 2 then
			    if GetItemCount(rs["闪光粉"]) < Easy_Data["闪光粉购买触发"] and not Start_Buy_Flash then
					Start_Buy_Flash = true
					return
				end

				local starttime, durationtime, enable = GetItemCooldown(6948)
				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
				Note_Head = rs["闪光粉"]
				if GetItemCount(6948) > 0 and durationtime < 10 then
					CheckProtection()
				
				    if IsMounted() then
						Dismount()
					end
					Note_Set(Check_UI("炉石 = ","Hearth Stone Using, Vendor name = ")..Merchant_Name)
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					frame:SetBackdropColor(0,0,0,0)
					return
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 40 then
					Note_Set(Check_UI("出本 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
					Run(x1,y1,z1)
					frame:SetBackdropColor(0,0,0,0)
					return
				end
		    elseif Instance ~= 545 then
			    if GetItemCount(rs["闪光粉"]) < Easy_Data["闪光粉购买触发"] and not Start_Buy_Flash then
					Start_Buy_Flash = true
					return
				end

			    frame:SetBackdropColor(0,0,0,0)
			    Note_Head = rs["闪光粉"]

			    Event_Reset()
				if not Out_Dungeon_buff() then
					Note_Set(Check_UI("上BUFF...","Buff Adding...."))
					return
				end
				CheckProtection()

				local starttime, durationtime, enable = GetItemCooldown(6948)
				if GetItemCount(6948) > 0 and durationtime < 10 then
				    Note_Set(Check_UI("炉石回城","Using Hearthstone"))
				    if IsMounted() then
					    Dismount()
					end
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					return
				else
				    if (GetSubZoneText() ~= Shui_Ku and Pz >= 10) or Pz >= 10 then
					    Using_Fixed_Path = false
						Fixed_Finish = false
					end
				    if (GetSubZoneText() == Shui_Ku and not Using_Fixed_Path and not Fixed_Finish and Pz <= 10) or (Using_Fixed_Path and not Fixed_Finish) then
					    Go_Out_Dungeon()
						return
					end

					if not Has_Mail and Easy_Data["需要邮寄"] and Easy_Data["卖物前邮寄"] then
						if Easy_Data["自定义邮箱"] then
							local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
						else
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1946, -198.66, 5506.75, 22.34
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

					Flash_Run(Flash_Coord.x,Flash_Coord.y,Flash_Coord.z)
				end
				return
			end
		end
	end

	if Easy_Data["需要邮寄"] and not awm.UnitAffectingCombat("player") then
		if #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] == math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) and #Easy_Data.ResetTimes ~= 0 and #Easy_Data.ResetTimes ~= 1 and not Has_Mail then
		    if Easy_Data["自定义邮箱"] then
				local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
				Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
			else
				Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1946, -198.66, 5506.75, 22.34
			end
			
			
			if Instance == 545 and Dungeon_step == 2 then
				Note_Head = Check_UI("邮寄","Mail")
				    
				local starttime, durationtime, enable = GetItemCooldown(6948)
				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
				if GetItemCount(6948) > 0 and durationtime < 10 and not IsMounted() then
					CheckProtection()
				    Note_Set(Check_UI("炉石邮寄, 坐标 = ","Using Herath Stone Back To Mail, Coord = ")..x1..","..y1..","..z1)
					frame:SetBackdropColor(0,0,0,0)
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					return
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 40 then
				    
				    Note_Set(Check_UI("出本邮寄, 坐标 = ","Go Out To Mail, Coord = ")..x1..","..y1..","..z1)
					frame:SetBackdropColor(0,0,0,0)
					Run(x1,y1,z1)
					return
				end
			elseif Instance ~= 545 then
				frame:SetBackdropColor(0,0,0,0)
				Note_Head = Check_UI("邮寄","Mail")
				
				Event_Reset()

				if not Out_Dungeon_buff() then
					Note_Set(Check_UI("上BUFF...","Buff Adding...."))
					return
				end
				CheckProtection()

				local starttime, durationtime, enable = GetItemCooldown(6948)
				if GetItemCount(6948) > 0 and durationtime < 10 then
				    Note_Set(Check_UI("炉石邮寄","Using Herath Stone Back To Mail"))
				    if IsMounted() then
					    Dismount()
					end
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					return
				else
				    if (GetSubZoneText() ~= Shui_Ku and Pz >= 10) or Pz >= 10 then
					    Using_Fixed_Path = false
						Fixed_Finish = false
					end
				    if (GetSubZoneText() == Shui_Ku and not Using_Fixed_Path and not Fixed_Finish and Pz <= 10) or (Using_Fixed_Path and not Fixed_Finish) then
					    Go_Out_Dungeon()
						return
					end
				     
					if (Easy_Data["服务器地图"] and Mail_Coord.mapid ~= nil and Current_Map ~= Mail_Coord.mapid and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
					    if Current_Map == Merchant_Coord.mapid then
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
				return
			end
		elseif #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] ~= math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) then
			Has_Mail = false
		end
	end

	if Instance == 545 then
        Real_Flush = false -- 触发爆本
        Real_Flush_time = 0 -- 第一次爆本时间
		Real_Flush_times = 0 -- 爆本计数

		Easy_Data.Sever_Map_Calculated = false
        Continent_Move = false

		Using_Fixed_Path = false
		Fixed_Finish = false

		if not Run_Timer then
		    Run_Timer = true
			Run_Time = GetTime()
		end
		Out_Dungeon_Time = GetTime() -- 出本五秒干活

		if Need_Reset then
		    Note_Head = Check_UI("残本重置","Go out reset")
		    Dungeon_step = 2
			Need_Reset = false
			Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
			return
		end

		if Dungeon_step == 1 then
		    Gather_Process()
		end
		if Dungeon_step == 2 then
		    Reset_Instance = true
			Note_Head = Check_UI("结束","End Process")
			Go_Out()
		end
	else
	    Note_Head = Check_UI("正常进本","Run Into Dungeon")
		if GetTime() - Out_Dungeon_Time < 5 then
		    return
		end

		CheckProtection()
	    Event_Reset()
	    if not Out_Dungeon_buff() then
		    Note_Set(Check_UI("上BUFF...","Buff Adding...."))
			return
		end
	    if Reset_Instance then
		    ResetInstances()
			textout(Check_UI("副本重置成功","Dungeon Reset Success"))
			Vars_Reset()
			Reset_Instance = false
			Run_Timer = false
			Easy_Data.ResetTimes[#Easy_Data.ResetTimes + 1] = GetTime()
		end
		frame:SetBackdropColor(0,0,0,0)

		local mapid,x,y,z = Dungeon_In.mapid, Dungeon_In.x,Dungeon_In.y,Dungeon_In.z
		local Fx,Fy,Fz = Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z
		Fx,Fy,Fz = tonumber(Fx),tonumber(Fy),tonumber(Fz)
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if distance == nil then
		    return
		end
		if Dungeon_Flush then
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,Fx,Fy,Fz)
			Note_Set(Check_UI("爆本了, 前往坐标距离剩余 ","Dungeon Run Over 5 Reset Per Hour, Goto Wait Point, Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))
			if distance1 > 2 then
				Run(Fx,Fy,Fz)
			else
				if not Flush_Time then
					Flush_Time = true
					C_Timer.After(30,function() Dungeon_Flush = false Flush_Time = false end)
				end
			end
			return
		end

		if Easy_Data["爆本等待时间"] == nil then
			Easy_Data["爆本等待时间"] = 300
			return
		end
		if Real_Flush then
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,Fx,Fy,Fz)
			if distance1 > 2 then
				Note_Set(Check_UI("爆本, 前往坐标距离剩余 ","Dungeon Run Over 5 Reset Per Hour, Goto Wait Point Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))
				Run(Fx,Fy,Fz)
				return
			end
			local time = GetTime() - Real_Flush_time
			local waittime = math.floor(Easy_Data["爆本等待时间"] - time)
			Note_Set(Check_UI("爆本等待剩余时间 - "..waittime.." 秒","Need to wait - "..waittime.." secs"))
			if time >= Easy_Data["爆本等待时间"] then
				Real_Flush = false
			else
				return
			end
		end
		if distance > 1 and not Dungeon_Flush then
			Note_Set(Check_UI("前往坐标距离剩余 ","Distance - ")..math.floor(distance)..Check_UI("码...","Yard..."))
			if distance < 30 then
				if Mount_useble then
					Mount_useble = false
					C_Timer.After(20,function() if not Mount_useble then  Mount_useble = true end end)
				end
			end

			if distance < 100 and not IsSwimming() and not CheckBuff("player",rs["潜行"]) and Spell_Castable(rs["潜行"]) and not IsMounted() and not UnitAffectingCombat("player") then
				awm.CastSpellByName(rs["潜行"])
			end

			if (Easy_Data["服务器地图"] and Current_Map ~= 1946 and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,1946,Dungeon_In.x,Dungeon_In.y,Dungeon_In.z)
				return
			end

			if (GetSubZoneText() ~= Shui_Ku and Current_Map == 1946 and Pz > -51 and not Using_Fixed_Path and not Fixed_Finish) or (Using_Fixed_Path and not Fixed_Finish) then
				Go_In_Dungeon()
				return
			end

			Run(x,y,z)
			return
		elseif distance <= 1 and not Dungeon_Flush then
			if not Interact_Step then
				Interact_Step = true
				    
				C_Timer.After(1.5,function() 
					Interact_Step = false 
					if Instance ~= 545 then
						Dungeon_Flush = true
						C_Timer.After(30,function() Dungeon_Flush = false end)
					end
				end)
			end
		end
	end
end



Coordinates_Get = false -- 判断要不要取新的navmesh
local coordinates = {} -- 路径点的table
local Path_Index = 2
local lastx,lasty,lastz = 0,0,0
local Stop_Run = false -- 卡点
local stuckx,stucky = nil,nil
local Reset_Stuck = 0 -- 3秒检测一次
local Reset_Path = 0
local rx,ry,rz = 0,0,0 -- Run参数对比
Tried_Mount = false
local Stuck_Step = 1 -- 第一步跳 第二步移动
local Nil_Reset = GetTime()
local Nav_Time = GetTime()
local DRUID_Shift = 0 -- 小德变身冷却1秒
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
		awm.SetPathfindingVariables(1.5, 3.5, 6.0, 0.3)
		local map_id = select(8, GetInstanceInfo())	
		coordinates = awm.FindPath(map_id, Px,Py,Pz, x , y, z, Easy_Data["平滑寻路"], Easy_Data["躲避物体"], Easy_Data["水中寻路"],Easy_Data["有效寻路"])
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

	if (GetActionCount(Easy_Data["动作条坐骑位置"]) == 0 and awm.UnitLevel("player") >= 30 and Mount_useble and Class ~= "WARLOCK" and Class ~= "DRUID") or (Class == "WARLOCK" and UnitLevel("player") <= 40) or (Class == "DRUID" and not DoesSpellExist(rs["旅行形态"])) then
		Mount_useble = false
		C_Timer.After(120,function() 
		    if not Mount_useble then
		        Mount_useble = true 
			end
		end)
	end
	if Class == "DRUID" and DoesSpellExist(rs["旅行形态"]) and Mount_useble and not CheckBuff("player",rs["旅行形态"]) and (GetTime() - DRUID_Shift) > 1 and Spell_Castable(rs["旅行形态"]) then
	    Reset_Stuck = GetTime()
	    DRUID_Shift = GetTime()
		awm.CastSpellByName(rs["旅行形态"],"player")
		textout(Check_UI("旅行形态 切换","Travel Form Shift"))
		return
	elseif Class ~= "DRUID" and not IsMounted() and awm.UnitLevel("player") >= 30 and not awm.UnitIsGhost("player") and Mount_useble and not awm.UnitAffectingCombat("player") and not IsSwimming() and IsOutdoors() then
	    Reset_Stuck = GetTime()
		if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
			if not Tried_Mount then
				Tried_Mount = true
				Stop_Moving = true
				Mount_Tried_Times = Mount_Tried_Times + 1
				awm.UseAction(Easy_Data["动作条坐骑位置"])
				textout(Check_UI("上马 - "..Easy_Data["动作条坐骑位置"],"Mounting - "..Easy_Data["动作条坐骑位置"]))
				C_Timer.After(5,function() Stop_Moving = false Tried_Mount = false end)
				return
			end
			if Mount_Tried_Times > 5 then

			    Mount_useble = false
				C_Timer.After(15,function() if not Mount_useble then Mount_useble = true end end)
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
		    textout(Check_UI("寻路途中卡住, 尝试脱离","Mesh stucking, try to get rid of it"))
		    if Stuck_Step == 1 then
				stuckx = random(Px-10,Px+10)
				stucky = random(Py-10,Py+10)
				awm.Interval_Move(stuckx,stucky,Pz)
				C_Timer.After(0.5,awm.JumpOrAscendStart)
				C_Timer.After(1,awm.AscendStop)
			elseif Stuck_Step == 2 then
			    if coordinates ~= nil and coordinates ~= 0 and awm.GetActiveNodeCount() > 0 then
					stuckx,stucky,stuckz = awm.GetActiveNodeByIndex(Path_Index)
					Mount_useble = false
					C_Timer.After(10,function() 
					    if not Mount_useble then 
						    Mount_useble = true 
						end 
					end)

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
		awm.Interval_Move(stuckx,stucky,Pz)
		return
	end

	if coordinates == nil or coordinates == 0 or awm.GetActiveNodeCount() == 0 then
	    if IsSwimming() and Using_Fixed_Path and Fixed_Move == 1 then
			awm.Interval_Move(x, y, z + 1)
		else
		    awm.Interval_Move(x,y,z)
		end
		if GetTime() - Nil_Reset > 3 then
		    Nil_Reset = GetTime()
			Coordinates_Get = false
			textout(Check_UI("导航路径不存在, 直接前往","Mesh waypoints = nil, directly go to the destination"))
		end
		return
	end
	if awm.GetActiveNodeCount() > 0 then
	    local x1,y1,z1 = awm.GetActiveNodeByIndex(Path_Index)
		local distance1 = awm.GetDistanceBetweenPositions(x1,y1,Pz,Px,Py,Pz)
		local losFlags = bit.bor(0x1,0x2)
        local hit = TraceLine(x1,y1,z1 + 2.25, Px,Py,Pz + 2.25, losFlags)
		if hit == 1 and GetTime() - Nil_Reset > 3 then
		    Nil_Reset = GetTime()
		    Coordinates_Get = false
			textout(Check_UI("自动避开障碍物","Aviod objects that cannot go through"))
			return
		end

		if distance1 ~= nil and distance1 > 1 and not Stop_Moving then
		    if IsSwimming() and Using_Fixed_Path and Fixed_Move == 1 then
			    awm.Interval_Move(x1, y1, z1 + 1)
			else
			    awm.Interval_Move(x1, y1, z1)
			end
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
	else
		if IsSwimming() and Using_Fixed_Path and Fixed_Move == 1 then
			awm.Interval_Move(x1, y1, z1 + 1)
		else
		    awm.Interval_Move(x,y,z)
		end
	    if GetTime() - Nil_Reset > 3 then
		    Nil_Reset = GetTime()
			Coordinates_Get = false
			textout(Check_UI("导航路径0, 直接前往","Mesh waypoints = 0, directly go to the destination"))
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

	local function Teleport_UI() -- 传送检测
		Basic_UI.Nav["传送检测"] = Create_Check_Button(Basic_UI.Nav.frame, "TOPLEFT",10, Basic_UI.Nav.Py, Check_UI("传送距离检测","Enable teleport detection by distance"))
		Basic_UI.Nav["传送检测"]:SetScript("OnClick", function(self)
			if Basic_UI.Nav["传送检测"]:GetChecked() then
				Easy_Data["传送检测"] = true
			elseif not Basic_UI.Nav["传送检测"]:GetChecked() then
				Easy_Data["传送检测"] = false
			end
		end)
		if Easy_Data["传送检测"] ~= nil then
			if Easy_Data["传送检测"] then
				Basic_UI.Nav["传送检测"]:SetChecked(true)
			else
				Basic_UI.Nav["传送检测"]:SetChecked(false)
			end
		else
			Easy_Data["传送检测"] = false
			Basic_UI.Nav["传送检测"]:SetChecked(false)
		end

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30
		local Header1 = Create_Header(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,Check_UI("传送检测触发距离(码)","Teleport detection alarm distance (yards)")) 

		Basic_UI.Nav.Py = Basic_UI.Nav.Py - 20

		Basic_UI.Nav["传送距离"] = Create_EditBox(Basic_UI.Nav.frame,"TOPLEFT",10, Basic_UI.Nav.Py,"100",false,280,24)
		Basic_UI.Nav["传送距离"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["传送距离"] = tonumber(Basic_UI.Nav["传送距离"]:GetText())
		end)
		if Easy_Data["传送距离"] ~= nil then
			Basic_UI.Nav["传送距离"]:SetText(Easy_Data["传送距离"])
		else
			Easy_Data["传送距离"]= tonumber(Basic_UI.Nav["传送距离"]:GetText())
		end
	end

	local function enable_Nav_Water()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

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
	end

	local function enable_Sever_Map()
	    Basic_UI.Nav.Py = Basic_UI.Nav.Py - 30

	    Basic_UI.Nav["服务器地图"] = Create_Check_Button(Basic_UI.Nav.frame,"TopLeft",10,Basic_UI.Nav.Py,Check_UI("加载云地图 (跨大陆使用)","Load server navigation system (use to across continents)"))
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
	Teleport_UI()
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

	local function Stuck_Fly_Set_UI() -- 卡死重置
	    Basic_UI.Set["卡死重置"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("卡死复活重置","Stuck Reset - Suicide in dungeon, reset and run to dungeon in spirit status"))
		Basic_UI.Set["卡死重置"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["卡死重置"]:GetChecked() then
				Easy_Data["卡死重置"] = true
			elseif not Basic_UI.Set["卡死重置"]:GetChecked() then
				Easy_Data["卡死重置"] = false
			end
		end)
		if Easy_Data["卡死重置"] ~= nil then
			if Easy_Data["卡死重置"] then
				Basic_UI.Set["卡死重置"]:SetChecked(true)
			else
				Basic_UI.Set["卡死重置"]:SetChecked(false)
			end
		else
			Easy_Data["卡死重置"] = false
			Basic_UI.Set["卡死重置"]:SetChecked(false)
		end
	end

	local function Function_UI()
		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["蒸汽采矿"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 采矿","The Steamvault Mining"))
		Basic_UI.Set["蒸汽采矿"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["蒸汽采矿"]:GetChecked() then
				Easy_Data["蒸汽采矿"] = true
			elseif not Basic_UI.Set["蒸汽采矿"]:GetChecked() then
				Easy_Data["蒸汽采矿"] = false
			end
		end)
		if Easy_Data["蒸汽采矿"] ~= nil then
			if Easy_Data["蒸汽采矿"] then
				Basic_UI.Set["蒸汽采矿"]:SetChecked(true)
			else
				Basic_UI.Set["蒸汽采矿"]:SetChecked(false)
			end
		else
			Easy_Data["蒸汽采矿"] = true
			Basic_UI.Set["蒸汽采矿"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["蒸汽采药"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 采药","The Steamvault Herbalism"))
		Basic_UI.Set["蒸汽采药"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["蒸汽采药"]:GetChecked() then
				Easy_Data["蒸汽采药"] = true
			elseif not Basic_UI.Set["蒸汽采药"]:GetChecked() then
				Easy_Data["蒸汽采药"] = false
			end
		end)
		if Easy_Data["蒸汽采药"] ~= nil then
			if Easy_Data["蒸汽采药"] then
				Basic_UI.Set["蒸汽采药"]:SetChecked(true)
			else
				Basic_UI.Set["蒸汽采药"]:SetChecked(false)
			end
		else
			Easy_Data["蒸汽采药"] = true
			Basic_UI.Set["蒸汽采药"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["蒸汽开锁"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 开箱子","The Steamvault Chest Farm"))
		Basic_UI.Set["蒸汽开锁"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["蒸汽开锁"]:GetChecked() then
				Easy_Data["蒸汽开锁"] = true
			elseif not Basic_UI.Set["蒸汽开锁"]:GetChecked() then
				Easy_Data["蒸汽开锁"] = false
			end
		end)
		if Easy_Data["蒸汽开锁"] ~= nil then
			if Easy_Data["蒸汽开锁"] then
				Basic_UI.Set["蒸汽开锁"]:SetChecked(true)
			else
				Basic_UI.Set["蒸汽开锁"]:SetChecked(false)
			end
		else
			Easy_Data["蒸汽开锁"] = false
			Basic_UI.Set["蒸汽开锁"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["蒸汽吸气"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 吸取气体","The Steamvault Mote Farm"))
		Basic_UI.Set["蒸汽吸气"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["蒸汽吸气"]:GetChecked() then
				Easy_Data["蒸汽吸气"] = true
			elseif not Basic_UI.Set["蒸汽吸气"]:GetChecked() then
				Easy_Data["蒸汽吸气"] = false
			end
		end)
		if Easy_Data["蒸汽吸气"] ~= nil then
			if Easy_Data["蒸汽吸气"] then
				Basic_UI.Set["蒸汽吸气"]:SetChecked(true)
			else
				Basic_UI.Set["蒸汽吸气"]:SetChecked(false)
			end
		else
			Easy_Data["蒸汽吸气"] = false
			Basic_UI.Set["蒸汽吸气"]:SetChecked(false)
		end
	end

	local function Chest_UI()
		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["左箱子卡桥"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 开左边箱子 (卡bug点)","The Steamvault Left Side Chest (Method 1)"))
		Basic_UI.Set["左箱子卡桥"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["左箱子卡桥"]:GetChecked() then
				Easy_Data["左箱子卡桥"] = true
			elseif not Basic_UI.Set["左箱子卡桥"]:GetChecked() then
				Easy_Data["左箱子卡桥"] = false
			end
		end)
		if Easy_Data["左箱子卡桥"] ~= nil then
			if Easy_Data["左箱子卡桥"] then
				Basic_UI.Set["左箱子卡桥"]:SetChecked(true)
			else
				Basic_UI.Set["左箱子卡桥"]:SetChecked(false)
			end
		else
			Easy_Data["左箱子卡桥"] = false
			Basic_UI.Set["左箱子卡桥"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["左箱子下水"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 开左边箱子 (正常开法)","The Steamvault Left Side Chest (Method 2)"))
		Basic_UI.Set["左箱子下水"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["左箱子下水"]:GetChecked() then
				Easy_Data["左箱子下水"] = true
			elseif not Basic_UI.Set["左箱子下水"]:GetChecked() then
				Easy_Data["左箱子下水"] = false
			end
		end)
		if Easy_Data["左箱子下水"] ~= nil then
			if Easy_Data["左箱子下水"] then
				Basic_UI.Set["左箱子下水"]:SetChecked(true)
			else
				Basic_UI.Set["左箱子下水"]:SetChecked(false)
			end
		else
			Easy_Data["左箱子下水"] = true
			Basic_UI.Set["左箱子下水"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["右箱子"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 开右边箱子","The Steamvault Right Side Chest"))
		Basic_UI.Set["右箱子"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["右箱子"]:GetChecked() then
				Easy_Data["右箱子"] = true
			elseif not Basic_UI.Set["右箱子"]:GetChecked() then
				Easy_Data["右箱子"] = false
			end
		end)
		if Easy_Data["右箱子"] ~= nil then
			if Easy_Data["右箱子"] then
				Basic_UI.Set["右箱子"]:SetChecked(true)
			else
				Basic_UI.Set["右箱子"]:SetChecked(false)
			end
		else
			Easy_Data["右箱子"] = true
			Basic_UI.Set["右箱子"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["守卫箱子"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("蒸汽地窟 开双守卫箱子","The Steamvault Guard Chest"))
		Basic_UI.Set["守卫箱子"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["守卫箱子"]:GetChecked() then
				Easy_Data["守卫箱子"] = true
			elseif not Basic_UI.Set["守卫箱子"]:GetChecked() then
				Easy_Data["守卫箱子"] = false
			end
		end)
		if Easy_Data["守卫箱子"] ~= nil then
			if Easy_Data["守卫箱子"] then
				Basic_UI.Set["守卫箱子"]:SetChecked(true)
			else
				Basic_UI.Set["守卫箱子"]:SetChecked(false)
			end
		else
			Easy_Data["守卫箱子"] = true
			Basic_UI.Set["守卫箱子"]:SetChecked(true)
		end
	end

	local function Spell_Place()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("盗贼 射击技能 动作条位置","Rogue Shoot Spell Action Slot ")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["射击动作条"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"2",false,280,24)
		Basic_UI.Set["射击动作条"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["射击动作条"] = tonumber(Basic_UI.Set["射击动作条"]:GetText())
		end)
		if Easy_Data["射击动作条"] ~= nil then
			Basic_UI.Set["射击动作条"]:SetText(Easy_Data["射击动作条"])
		else
			Easy_Data["射击动作条"] = tonumber(Basic_UI.Set["射击动作条"]:GetText())
		end
	end

	local function Wait_point()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("蒸汽地窟 爆本 本外等待坐标","The Steamvault Wait Point")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["蒸汽等待坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"712,6999,-74",false,280,24)
		Basic_UI.Set["蒸汽等待坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["蒸汽等待坐标"] = Basic_UI.Set["蒸汽等待坐标"]:GetText()
			local coord_package = string.split(Easy_Data["蒸汽等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		end)
		if Easy_Data["蒸汽等待坐标"] ~= nil then
			Basic_UI.Set["蒸汽等待坐标"]:SetText(Easy_Data["蒸汽等待坐标"])
			local coord_package = string.split(Easy_Data["蒸汽等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		else
			Easy_Data["蒸汽等待坐标"] = Basic_UI.Set["蒸汽等待坐标"]:GetText()
		end

		Basic_UI.Set["获取等待坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Set["获取等待坐标"]:SetSize(120,24)
		Basic_UI.Set["获取等待坐标"]:SetScript("OnClick", function(self)
			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance ~= 545 then
			    local x,y,z = awm.ObjectPosition("player")
				Basic_UI.Set["蒸汽等待坐标"]:SetText(math.floor(x)..","..math.floor(y)..","..math.floor(z))
				Easy_Data["蒸汽等待坐标"] = Basic_UI.Set["蒸汽等待坐标"]:GetText()
				Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = x,y,z
			else
			    textout(Check_UI("不要在副本内点击按钮","Don't click it in dungeon"))
			end
		end)
	end

	local function Dungeon_Wait_Time()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("副本运行最低时间 (每小时重置上限)(秒)","Dungeon Minimum Reset Wait Time(Second) (5 Run Per Hour)")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["副本重置时间"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"900",false,280,24)
		Basic_UI.Set["副本重置时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["副本重置时间"] = tonumber(Basic_UI.Set["副本重置时间"]:GetText())
		end)
		if Easy_Data["副本重置时间"] ~= nil then
			Basic_UI.Set["副本重置时间"]:SetText(Easy_Data["副本重置时间"])
		else
			Easy_Data["副本重置时间"] = tonumber(Basic_UI.Set["副本重置时间"]:GetText())
		end
	end

	local function Flash_Powder()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["购买闪光粉"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("盗贼 自动购买 - ","Rogue auto buy - ")..rs["闪光粉"])
		Basic_UI.Set["购买闪光粉"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["购买闪光粉"]:GetChecked() then
				Easy_Data["购买闪光粉"] = true
			elseif not Basic_UI.Set["购买闪光粉"]:GetChecked() then
				Easy_Data["购买闪光粉"] = false
			end
		end)
		if Easy_Data["购买闪光粉"] ~= nil then
			if Easy_Data["购买闪光粉"] then
				Basic_UI.Set["购买闪光粉"]:SetChecked(true)
			else
				Basic_UI.Set["购买闪光粉"]:SetChecked(false)
			end
		else
			Easy_Data["购买闪光粉"] = true
			Basic_UI.Set["购买闪光粉"]:SetChecked(true)
		end

	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("低于多少数量 自动购买 - ","Lower than how many start to buy - ")..rs["闪光粉"]) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["闪光粉购买触发"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"10",false,280,24)
		Basic_UI.Set["闪光粉购买触发"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["闪光粉购买触发"] = tonumber(Basic_UI.Set["闪光粉购买触发"]:GetText())
		end)
		if Easy_Data["闪光粉购买触发"] ~= nil then
			Basic_UI.Set["闪光粉购买触发"]:SetText(Easy_Data["闪光粉购买触发"])
		else
			Easy_Data["闪光粉购买触发"] = tonumber(Basic_UI.Set["闪光粉购买触发"]:GetText())
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("自动购买 多少 闪光粉 - ","Auto buy how many - ")..rs["闪光粉"]) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["闪光粉购买数量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"100",false,280,24)
		Basic_UI.Set["闪光粉购买数量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["闪光粉购买数量"] = tonumber(Basic_UI.Set["闪光粉购买数量"]:GetText())
		end)
		if Easy_Data["闪光粉购买数量"] ~= nil then
			Basic_UI.Set["闪光粉购买数量"]:SetText(Easy_Data["闪光粉购买数量"])
		else
			Easy_Data["闪光粉购买数量"] = tonumber(Basic_UI.Set["闪光粉购买数量"]:GetText())
		end
	end

	Frame_Create()
	Button_Create()	

	Stuck_Fly_Set_UI()
	Function_UI()
	Chest_UI()
	Spell_Place()
	Wait_point()
	Dungeon_Wait_Time()
	Flash_Powder()
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

local function Create_Disenchant_UI() -- 分解UI
    Basic_UI.Disenchant = {}
	Basic_UI.Disenchant.Py = -10
	local function Frame_Create()
		Basic_UI.Disenchant.frame = CreateFrame('frame',"Basic_UI.Disenchant.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Disenchant.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Disenchant.frame:SetSize(600,1500)
		Basic_UI.Disenchant.frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
		title= true, 
		edgeSize =15, 
		titleSize = 32})
		Basic_UI.Disenchant.frame:Hide()
		Basic_UI.Disenchant.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Disenchant.frame:SetBackdropBorderColor(1,0,1,1)
		Basic_UI.Disenchant.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Disenchant.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("分解","disenchant"))
		Basic_UI.Disenchant.button:SetSize(130,20)
		Basic_UI.Disenchant.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Disenchant.frame:Show()
			Basic_UI.Disenchant.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Disenchant.frame:Hide() Basic_UI.Disenchant.button:SetBackdropColor(0,0,0,0) end
	end

	local function Resolve_Set_UI() -- 分解
		Basic_UI.Disenchant["需要分解"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("需要分解","Need Disenchant"))
		Basic_UI.Disenchant["需要分解"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["需要分解"]:GetChecked() then
				Easy_Data["需要分解"] = true
			elseif not Basic_UI.Disenchant["需要分解"]:GetChecked() then
				Easy_Data["需要分解"] = false
			end
		end)
		if Easy_Data["需要分解"] ~= nil then
			if Easy_Data["需要分解"] then
				Basic_UI.Disenchant["需要分解"]:SetChecked(true)
			else
				Basic_UI.Disenchant["需要分解"]:SetChecked(false)
			end
		else
			Easy_Data["需要分解"] = false
			Basic_UI.Disenchant["需要分解"]:SetChecked(false)
		end

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
		Basic_UI.Disenchant["分解黑名单"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("添加不可分解物品进入黑名单","Blacklist Un-Disenchant items"))
		Basic_UI.Disenchant["分解黑名单"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解黑名单"]:GetChecked() then
				Easy_Data["分解黑名单"] = true
			elseif not Basic_UI.Disenchant["分解黑名单"]:GetChecked() then
				Easy_Data["分解黑名单"] = false
			end
		end)
		if Easy_Data["分解黑名单"] ~= nil then
			if Easy_Data["分解黑名单"] then
				Basic_UI.Disenchant["分解黑名单"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解黑名单"]:SetChecked(false)
			end
		else
			Easy_Data["分解黑名单"] = true
			Basic_UI.Disenchant["分解黑名单"]:SetChecked(true)
		end

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
		Basic_UI.Disenchant["清理分解黑名单"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("自动清理分解黑名单","Auto Reset Disenchant Blacklist"))
		Basic_UI.Disenchant["清理分解黑名单"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["清理分解黑名单"]:GetChecked() then
				Easy_Data["清理分解黑名单"] = true
			elseif not Basic_UI.Disenchant["清理分解黑名单"]:GetChecked() then
				Easy_Data["清理分解黑名单"] = false
			end
		end)
		if Easy_Data["清理分解黑名单"] ~= nil then
			if Easy_Data["清理分解黑名单"] then
				Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(true)
			else
				Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(false)
			end
		else
			Easy_Data["清理分解黑名单"] = false
			Basic_UI.Disenchant["清理分解黑名单"]:SetChecked(false)
		end
	end

	local function Disenchant_Color_UI() -- 分解颜色
	    Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
	    local Header1 = Create_Header(Basic_UI.Disenchant.frame,"TOPLEFT",10, Basic_UI.Disenchant.Py,Check_UI("分解颜色","Disenchant Item Color")) 

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 20
		Basic_UI.Disenchant["分解灰色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",10, Basic_UI.Disenchant.Py, Check_UI("灰色","Grey"))
		Basic_UI.Disenchant["分解灰色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解灰色"]:GetChecked() then
				Easy_Data["分解灰色"] = true
			elseif not Basic_UI.Disenchant["分解灰色"]:GetChecked() then
				Easy_Data["分解灰色"] = false
			end
		end)
		if Easy_Data["分解灰色"] ~= nil then
			if Easy_Data["分解灰色"] then
				Basic_UI.Disenchant["分解灰色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解灰色"]:SetChecked(false)
			end
		else
			Easy_Data["分解灰色"] = true
			Basic_UI.Disenchant["分解灰色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解白色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",80, Basic_UI.Disenchant.Py, Check_UI("白色","White"))
		Basic_UI.Disenchant["分解白色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解白色"]:GetChecked() then
				Easy_Data["分解白色"] = true
			elseif not Basic_UI.Disenchant["分解白色"]:GetChecked() then
				Easy_Data["分解白色"] = false
			end
		end)
		if Easy_Data["分解白色"] ~= nil then
			if Easy_Data["分解白色"] then
				Basic_UI.Disenchant["分解白色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解白色"]:SetChecked(false)
			end
		else
			Easy_Data["分解白色"] = true
			Basic_UI.Disenchant["分解白色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解绿色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",150, Basic_UI.Disenchant.Py, Check_UI("绿色","Green"))
		Basic_UI.Disenchant["分解绿色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解绿色"]:GetChecked() then
				Easy_Data["分解绿色"] = true
			elseif not Basic_UI.Disenchant["分解绿色"]:GetChecked() then
				Easy_Data["分解绿色"] = false
			end
		end)
		if Easy_Data["分解绿色"] ~= nil then
			if Easy_Data["分解绿色"] then
				Basic_UI.Disenchant["分解绿色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解绿色"]:SetChecked(false)
			end
		else
			Easy_Data["分解绿色"] = true
			Basic_UI.Disenchant["分解绿色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解蓝色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",220, Basic_UI.Disenchant.Py, Check_UI("蓝色","Blue"))
		Basic_UI.Disenchant["分解蓝色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解蓝色"]:GetChecked() then
				Easy_Data["分解蓝色"] = true
			elseif not Basic_UI.Disenchant["分解蓝色"]:GetChecked() then
				Easy_Data["分解蓝色"] = false
			end
		end)
		if Easy_Data["分解蓝色"] ~= nil then
			if Easy_Data["分解蓝色"] then
				Basic_UI.Disenchant["分解蓝色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解蓝色"]:SetChecked(false)
			end
		else
			Easy_Data["分解蓝色"] = true
			Basic_UI.Disenchant["分解蓝色"]:SetChecked(true)
		end

		Basic_UI.Disenchant["分解紫色"] = Create_Check_Button(Basic_UI.Disenchant.frame, "TOPLEFT",290, Basic_UI.Disenchant.Py, Check_UI("紫色","Purple"))
		Basic_UI.Disenchant["分解紫色"]:SetScript("OnClick", function(self)
			if Basic_UI.Disenchant["分解紫色"]:GetChecked() then
				Easy_Data["分解紫色"] = true
			elseif not Basic_UI.Disenchant["分解紫色"]:GetChecked() then
				Easy_Data["分解紫色"] = false
			end
		end)
		if Easy_Data["分解紫色"] ~= nil then
			if Easy_Data["分解紫色"] then
				Basic_UI.Disenchant["分解紫色"]:SetChecked(true)
			else
				Basic_UI.Disenchant["分解紫色"]:SetChecked(false)
			end
		else
			Easy_Data["分解紫色"] = true
			Basic_UI.Disenchant["分解紫色"]:SetChecked(true)
		end
	end

	local function Disenchant_Item() -- 分解物品
	    local Keep_Frame = {}
	    local function Update_List()
		    local ItemList = string.split(Easy_Data["不分解物品"],",")
			if #ItemList > 0 then
			    for i = 1,#ItemList do
				    if not Keep_Frame[i] then
					    Keep_Frame[i] = Create_Header(Basic_UI.Disenchant["分解列表"],"TOPLEFT",10, (-30 * (i - 1) - 10),ItemList[i].."("..i..")")
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

	    Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
	    local header = Create_Header(Basic_UI.Disenchant.frame,"TopLeft",10,Basic_UI.Disenchant.Py,Check_UI("不分解物品","Not Disenchant Item"))

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 20
	    Basic_UI.Disenchant["分解物品"] = Create_Scroll_Edit(Basic_UI.Disenchant.frame,"TopLeft",10,Basic_UI.Disenchant.Py,Check_Client("铜矿,银矿,铁矿石","item1,item2,item3"),570,100)

		Basic_UI.Disenchant["分解物品"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["不分解物品"] = Basic_UI.Disenchant["分解物品"]:GetText()
			Update_List()
		end)
        if Easy_Data["不分解物品"] == nil then
            Easy_Data["不分解物品"] = Check_UI("铜矿,银矿,铁矿石","item1,item2,item3")
        else
            Basic_UI.Disenchant["分解物品"]:SetText(Easy_Data["不分解物品"])
        end

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 80

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 30
		Basic_UI.Disenchant["分解列表"] = Create_Scroll(Basic_UI.Disenchant.frame,"TopLeft",10,Basic_UI.Disenchant.Py,570,200)

		Basic_UI.Disenchant.Py = Basic_UI.Disenchant.Py - 180
		Update_List()
	end

	Frame_Create()
	Button_Create()
	Resolve_Set_UI()
	Disenchant_Color_UI()
	Disenchant_Item()
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
		local Header2 = Create_Header(Basic_UI.Mail.frame,"TOPLEFT",10, Basic_UI.Mail.Py,Check_UI("重置多少次触发邮寄","After how many times dungeon reset to mail items and gold")) 

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

local function Create_Clear_UI() -- 运行次数清除UI
    Detail_UI.Custom = {}
	
    Detail_UI.Custom["清空次数"] = Create_Button(Detail_UI.Panel,"TopLeft",10,Detail_UI.Py,Check_UI("清空副本次数","Clear Reset Log"))
	Detail_UI.Custom["清空次数"]:SetSize(190,35)
	Detail_UI.Custom["清空次数"]:SetScript("OnClick", function(self)
		Easy_Data.ResetTimes = {}
		textout(Check_UI("副本重置记录次数清空","Dungeon reset log clear"))
	end)

	Detail_UI.Py = Detail_UI.Py - 35

	Detail_UI.Custom = {}	
    Detail_UI.Custom["卡死按钮"] = Create_Button(Detail_UI.Panel,"TopLeft",10,Detail_UI.Py,Check_UI("卡死返回墓地","Suicide yourself"))
	Detail_UI.Custom["卡死按钮"]:SetSize(190,35)
	Detail_UI.Custom["卡死按钮"]:SetScript("OnClick", function(self)
		Bot_End()
		Try_Stop()

		C_Timer.After(1.5,function()
			awm.Stuck()
		end)
	end)

	Detail_UI.Py = Detail_UI.Py - 5
end

Create_Nav_UI()
Create_Config_UI()
Create_Sell_UI()
Create_Destroy_UI()
Create_Disenchant_UI()
Create_Mail_UI()
Create_Clear_UI()

function Bot_Begin()
    Run_Timer = false
	BOT_Frame:SetScript("OnUpdate", MainThread)
	textout(Check_UI("开始工作","Start to work"))
end
function Bot_End()
    BOT_Frame:SetScript("OnUpdate", function() end)
	textout(Check_UI("停止工作","Stop to work"))
	Coordinates_Get = false
	Easy_Data.Sever_Map_Calculated = false
	Continent_Move = false
end

Bot_Begin()



Spell_Casting = false
Spell_Channel_Casting = false
Merchant_Show = false
Gossip_Show = false
Quest_Show = false
Mount_useble = true
Trainer_Show = false
Stop_Moving = false
Has_Stop_Moving = false
Pet_Dead = false
In_Sight = false -- 目标不在视野中
Coprse_In_Range = false -- 进入复活范围
InstanceCorpse = false

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
	    if arg2 == SPELL_FAILED_CANT_BE_DISENCHANTED or arg2 == ERR_CANT_BE_DISENCHANTED then
		    if not ValidResolve(Disenchant_Black_Name) and Easy_Data["分解黑名单"] and not CastingBarFrame:IsVisible() and HasDisenchant then
				Easy_Data["不分解物品"] = Easy_Data["不分解物品"]..","..Disenchant_Black_Name
				Basic_UI.Disenchant["分解物品"]:SetText(Easy_Data["不分解物品"])
			end
		end
		if arg2 == SPELL_FAILED_UNIT_NOT_INFRONT or arg2 == ERR_BADATTACKFACING or arg2 == ERR_USE_BAD_ANGLE or arg2 == SPELL_FAILED_CUSTOM_ERROR_141 then
			if awm.ObjectExists("target") then
			    if GetUnitSpeed("player") then
					Try_Stop()
				end
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
				C_Timer.After(1.5,function() Tried_Mount = false if not Mount_useble then Mount_useble = true end end)
				C_Timer.After(5,function() Stop_Moving = false Has_Stop_Moving = false end)
			end
		end
		if arg2 == SPELL_FAILED_NOT_STANDING or arg2 == ERR_LOOT_NOTSTANDING or arg2 == ERR_CANTATTACK_NOTSTANDING then
            DoEmote("STAND")
		end
		if arg2 == SPELL_FAILED_LINE_OF_SIGHT then
            In_Sight = true
			C_Timer.After(15,function() In_Sight = false end)
		end
		if arg2 == ERR_MOUNT_TOOFARAWAY or arg2 == SPELL_FAILED_UNDERWATER_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_NO_MOUNTS_ALLOWED or arg2 == SPELL_FAILED_MOUNT_NO_UNDERWATER_HERE or arg2 == SPELL_FAILED_MOUNT_NO_FLOAT_HERE or arg2 == SPELL_FAILED_MOUNT_ABOVE_WATER_HERE or arg2 == SPELL_FAILED_GROUND_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_FLYING_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_FLOATING_MOUNT_NOT_ALLOWED or arg2 == SPELL_FAILED_CUSTOM_ERROR_511 or arg2 == SPELL_FAILED_CUSTOM_ERROR_50 or arg2 == SPELL_FAILED_CUSTOM_ERROR_169 then
            Mount_useble = false
			Stop_Moving = false
			C_Timer.After(25,function() if not Mount_useble then Mount_useble = true end end)
		end 
		if arg2 == SPELL_FAILED_ONLY_OUTDOORS or arg1 == 1 then
            Mount_useble = false
			Stop_Moving = false
			C_Timer.After(25,function() if not Mount_useble then Mount_useble = true end end)
		end
		if arg2 == ERR_AFFECTING_COMBAT or arg2 == SPELL_FAILED_AFFECTING_COMBAT then
            Mount_useble = false
			Stop_Moving = false
			C_Timer.After(25,function() if not Mount_useble then Mount_useble = true end end)
		end
		if arg2 == SPELL_FAILED_ONLY_ABOVEWATER or arg2 == SPELL_FAILED_ONLY_NOT_SWIMMING or arg2 == SPELL_FAILED_ONLY_UNDERWATER then
            Mount_useble = false
			Stop_Moving = false
			C_Timer.After(60,function() if not Mount_useble then Mount_useble = true end end)
		end
		if arg2 == ERR_ABILITY_COOLDOWN or arg2 == ERR_ITEM_COOLDOWN or arg2 == ERR_SPELL_COOLDOWN or arg2 == SPELL_FAILED_ITEM_NOT_READY then
            Mount_useble = false
			Stop_Moving = false
			C_Timer.After(15,function() if not Mount_useble then Mount_useble = true end end)
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

local f = CreateFrame("Frame")

f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function f:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

	if subevent == "PARTY_KILL" and sourceGUID == awm.UnitGUID("player") then
	    textout(Check_UI("成功击杀 - ","MOBS Dead - ")..destName)
		OBJ_Killed[#OBJ_Killed + 1] = destGUID
	end
end

local Detail_Frame = CreateFrame("Frame")
local Generate = false
local Dungeon_Run_Time = ""
local Dungeon_reset = ""
local Dungeon_Killed = ""
local Initial_Money = GetMoney()
local Money_Monitor = ""
Detail_Frame:SetScript("OnUpdate", function()
    if not Generate then
	    Generate = true
	    
		Detail_UI.Py = Detail_UI.Py - 30
		Dungeon_Run_Time = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_Run_Time:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_Run_Time:SetText(Check_UI("副本时间: ","Dungeon time: ")..Dungeon_Time)
		Dungeon_Run_Time:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Dungeon_reset = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_reset:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_reset:SetText(Check_UI("重置: ","Reset: ")..#Easy_Data.ResetTimes)
		Dungeon_reset:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Dungeon_Killed = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Dungeon_Killed:SetPoint("TopLeft",10,Detail_UI.Py)
		Dungeon_Killed:SetText(Check_UI("击杀: ","Killed: ")..#OBJ_Killed)
		Dungeon_Killed:Show()

		Detail_UI.Py = Detail_UI.Py - 30
		Money_Monitor = Detail_UI.Panel:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		Money_Monitor:SetPoint("TopLeft",10,Detail_UI.Py)
		Money_Monitor:SetText(Check_UI("金币: ","Profit: ")..(GetMoney() - Initial_Money) / 10000)
		Money_Monitor:Show()
	else
	    Dungeon_Run_Time:SetText(Check_UI("副本时间: ","Dungeon time: ")..Dungeon_Time..Check_UI(" 秒"," seconds"))
		Dungeon_reset:SetText(Check_UI("重置: ","Reset: ")..#Easy_Data.ResetTimes)
		Dungeon_Killed:SetText(Check_UI("击杀: ","Killed: ")..#OBJ_Killed..Check_UI(" 只"," mobs"))
		Money_Monitor:SetText(Check_UI("金币: ","Profit: ")..((GetMoney() - Initial_Money)/10000)..Check_UI(" 金"," gold"))
	end
end)