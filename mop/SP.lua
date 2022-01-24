Function_Load_In = true
local Function_Version = "1120"
textout(Check_UI("奴隶围栏 - "..Function_Version,"Slave pens - "..Function_Version))

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

	local Notice = frame:CreateFontString(nil,"ARTWORK","GameFontNormalHuge")
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
local Dead_Repop = 0 -- 死亡后多少秒开始跑尸体

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

local Dungeon_In = {mapid = 1946, x = 749.2, y = 7013.74, z = -72}
local Dungeon_Out = {mapid = 1946, x = 121, y= -148, z = 0}
local Dungeon_Flush_Point = {mapid = 1946, x = 725, y = 7012, z = -72}

local Flush_Time = false
local Dungeon_Flush = false -- 是否爆本
local Real_Flush = false -- 触发爆本
local Real_Flush_time = 0 -- 第一次爆本时间
local Real_Flush_times = 0 -- 爆本计数

local Merchant_Coord = {mapid = 1946, x = -1707, y = -1424, z = 34}
local Merchant_Name = "匠人比尔"
local Mail_Coord = {mapid = 1946, x = -1656, y = -1344, z = 32}
local Has_Mail = false

local Reset_Instance = false

local Interact_Step = false
local HasStop = false

local SP_Timer = false -- 技能计时
local SP_Time = 0
local Target_Monster = nil -- 选定怪物

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

local Attracted_Mobs = false -- 39 - 43怪 提前引怪

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
	 Attracted_Mobs = false
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
	Attracted_Mobs = false
end

function CheckDeadOrNot() -- 判断角色是否死亡
    if awm.UnitIsDeadOrGhost("player") and not CheckBuff("player",rs["假死"]) then
	    if not awm.UnitIsGhost("player") then
		    if not awm.GetCorpsePosition() then
			    return
			end

		    Dead_Repop = GetTime()
			Event_Reset()

			Using_Fixed_Path = false
			Fixed_Finish = false

			local Path = 
			{
			{565.56,6940.61,16.84},{564.99,6941.14,-5.38},{568.93,6940.79,-26.77},{577.34,6939.47,-40.89},{585.83,6932.56,-42.02},{598.56,6918.92,-45.57},{603.49,6909.79,-47.12},{607.54,6900.28,-48.22},{610.75,6892.74,-49.10},{615.56,6888.97,-57.20},{624.14,6881.87,-69.89},{631.53,6874.67,-74.60},{640.99,6865.70,-79.47},{652.42,6866.18,-82.56},{658.28,6865.26,-81.57},{668.91,6862.13,-75.58},{677.19,6859.68,-72.13}
			}

			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance == 547 and not Using_Fixed_Path then
			    Using_Fixed_Path = true
				Fixed_Move = 1
				Fixed_Finish = false
				textout(Check_UI("副本内死亡","Die in dungeon"))
			end

			if Instance == 547 and not Reset_Instance and not Need_Reset and ((not Easy_Data["奴隶30走廊"] and not Easy_Data["奴隶40走廊"]) or #OBJ_Killed >= 1) then
			    Need_Reset = true
				textout(Check_UI("副本内死亡, 重置副本","Die in dungeon, Reset Dungeon"))
			end

			local Px,Py,Pz = awm.ObjectPosition("player")
			local distance1 = awm.GetDistanceBetweenPositions(Px,Py,Pz,731,6862,-70)
			local distance2 = awm.GetDistanceBetweenPositions(Px,Py,Pz,749.2,7013.74,-72)
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
		local distance2 = awm.GetDistanceBetweenPositions(Px,Py,Pz,749.2,7013.74,-72)
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
	    
		if (awm.GetDistanceBetweenPositions(deathx,deathy,deathz,742,7011,-73) < 5 and not Using_Fixed_Path and not Fixed_Finish) or (Using_Fixed_Path and not Fixed_Finish) then
		    if GetSubZoneText() == Shui_Ku and Pz <= -65 then
			    Using_Fixed_Path = false
				Fixed_Finish = true
				return
			end
			Go_In_Dungeon()
			return
		end

		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,deathx,deathy,Pz)
		if distance <= 3 and DeathDistance >= 20 and not IsSwimming() then
		    if Pz > deathz then
			    if not Interact_Step then
				    Interact_Step = true
					awm.SetPitch(-1.57)
					awm.MoveForwardStart()
				    C_Timer.After(3,function() Try_Stop() Interact_Step = false end)
				end
			elseif Pz < deathz then
			    if not Interact_Step then
				    Interact_Step = true
					awm.SetPitch(1.57)
					awm.MoveForwardStart()
				    C_Timer.After(3,function() Try_Stop() Interact_Step = false end)
				end
			end
			return
		end

		Interact_Step = false

		Run(deathx,deathy,deathz)
		return
	elseif DeathDistance <= 2 or InstanceCorpse then
	    if InstanceCorpse then
		    Note_Set(Check_UI("尸体在副本内","Corpse in dungeon"))
			local x,y,z = 749.20,7013.74,-72
			if Interact_Step then
			    x,y,z = 725,7012,-72
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
	if GetItemCount(rs["法力刚玉"]) == 0 and DoesSpellExist(rs["制造魔法玉石"]) then
	   if not CastingBarFrame:IsVisible() then
	       awm.CastSpellByName(rs["制造魔法玉石"])
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
    if awm.UnitPower("player") < 3000 and GetItemCount(rs["法力刚玉"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(22044) then
		awm.UseItemByName(rs["法力刚玉"])
	end

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

	if not Easy_Data["大蓝使用蓝量"] then
	    Easy_Data["大蓝使用蓝量"] = 1000
	end

	if Easy_Data["使用大蓝"] and awm.UnitPower("player") < Easy_Data["大蓝使用蓝量"] and GetItemCount(Check_Client("特效法力药水","Major Mana Potion")) > 0 and not CastingBarFrame:IsVisible() and (CheckCooldown(13444)) then
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
	if (item == Check_Client("特效法力药水","Major Mana Potion") or item == Check_Client("特效治疗药水","Major Healing Potion")) and GetItemCount(item) <= 10 then
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

function Find_Object_Position(id,x,y,z,scan_range)
    local target = nil
    local total = awm.GetObjectCount()
	local Far_Distance = 200
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.ObjectId(ThisUnit)
		local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
		local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z1)
		if id and type(id) == "number" and guid == id and distance < Far_Distance and distance < scan_range and not awm.ObjectIsPlayer(ThisUnit) then
			Far_Distance = distance
			target = ThisUnit
		elseif id and type(id) == "table" and distance < Far_Distance and distance < scan_range and not awm.ObjectIsPlayer(ThisUnit) then
			for tab = 1,#id do
				if id[tab] == guid then
					Far_Distance = distance
					target = ThisUnit
				end
			end
		elseif not id and distance < Far_Distance and distance < scan_range and not awm.ObjectIsPlayer(ThisUnit) then
			Far_Distance = distance
			target = ThisUnit
		end
	end
	return target
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
		if awm.ObjectExists(ThisUnit) and awm.ObjectIsGameObject(ThisUnit) then
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
				if guid and name == guid and Current_level >= level and distance < Far_Distance and distance < scan_range then
					if type == "Mine" and GetItemCount(Check_Client("矿工锄","Mining Pick")) > 0 and Easy_Data["围栏采矿"] then
						Far_Distance = distance
						target = ThisUnit
					elseif type == "Herb" and Easy_Data["围栏采药"] then
						Far_Distance = distance
						target = ThisUnit
					end
				end
			end
		end
	end
	return target
end

function Find_Nearest_Uncombat_Object(id,x,y,z)
    local target = nil
    local total = awm.GetObjectCount()
	local Far_Distance = 60
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
			local guid = awm.ObjectId(ThisUnit)
			local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
			local distance = awm.GetDistanceBetweenPositions(x,y,z,x1,y1,z)
			if id and type(id) == "number" and guid == id and distance < Far_Distance and not awm.UnitTarget(ThisUnit) then
				Far_Distance = distance
				target = ThisUnit
			elseif id and type(id) == "table" and distance < Far_Distance and not awm.UnitTarget(ThisUnit) then
			    for tab = 1,#id do
				    if id[tab] == guid then
					    Far_Distance = distance
						target = ThisUnit
					end
				end
			elseif not id and distance < Far_Distance and not awm.UnitTarget(ThisUnit) then
				Far_Distance = distance
				target = ThisUnit
			end
		end
	end
	return target
end

function Combat_Scan()
    local Monster = {}
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
			if awm.UnitAffectingCombat(ThisUnit) and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and awm.UnitTarget(ThisUnit) and awm.UnitTarget(ThisUnit) == awm.UnitGUID("player") then
				Monster[#Monster + 1] = ThisUnit
			end
		end
	end
	return Monster
end
function Find_Body()
    local Px,Py,Pz = awm.ObjectPosition("player")
    local body = {}
	local total,updated,added,removed = awm.GetObjectCount()
	local Far_Distance = 20
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
			local guid = awm.UnitGUID(ThisUnit)
			local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
			if awm.UnitIsDead(ThisUnit) and awm.UnitIsLootable(guid) and Easy_Data["需要拾取"] then
				local body_table = {distance = distance,ThisUnit}
				body_table.distance = distance
				body_table.Unit = ThisUnit
				body[#body + 1] = body_table
			end
		end
	end

	if #body > 0 then
        table.sort(body, function(a, b)
			if a.distance < b.distance then
				return true
			elseif a.distance == b.distance then
				return false
			end
			return false
		end)
	end

	return body
end
function Is_Together(table)
    for i = 1,#table do
	    local number = math.random(1,#table)
		local distance = awm.GetDistanceBetweenObjects(table[number],table[i])
	    if distance >= 16 then
		    return false
		end
	end
	return true
end
function Is_Together2(Combat_Table)
    local Distance_Table = {}
    for i = 1,#Combat_Table do
		local distance = awm.GetDistanceBetweenObjects("player",Combat_Table[i])
		Distance_Table[#Distance_Table + 1] = distance
	end
	if #Distance_Table > 1 then

		table.sort(Distance_Table, function(a, b)
			if a < b then
				return true
			elseif a == b then
				return false
			end
			return false
		end)

		for i = 1,#Distance_Table - 1 do
			local distance = Distance_Table[i + 1] - Distance_Table[i]
			if distance >= 7 then
				return false
			end
		end
	end
	return true
end


function SP_30()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end
	if not CheckBuff("player","精神错乱") and not CheckBuff("player","Flip Out") and not CheckBuff("player","呀啊啊啊啊") and not CheckBuff("player","Yaaarrrr") then
	    if Easy_Data["使用风蛇"] then
		    if GetItemCount("美味风蛇") > 0 then
			    awm.UseItemByName("美味风蛇")
				textout("使用物品 - 美味风蛇")
			elseif GetItemCount("Savory Deviate Delight") > 0 then
			    awm.UseItemByName("Savory Deviate Delight")
				textout("Use item - Savory Deviate Delight")
			end
		end
	end

	if Dungeon_step1 == 4 and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["寒冰屏障"]) then
	    awm.CastSpellByName(rs["寒冰屏障"])
	end
	if CheckBuff("player",rs["寒冰屏障"]) then
		awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
	end

	if Dungeon_step1 >= 4 then
	    if not CastingBarFrame:IsVisible() then
		    UseItem()
		end
	end

	if Dungeon_step1 == 5 then
	    if not CastingBarFrame:IsVisible() then
			if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				awm.CastSpellByName(rs["法师魔甲术"],"player")
			end
		end
	end


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

		local path = {{129.82,-126.43,-1.59}}
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
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = 121.16, -129.47,Pz
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往副本门口, 距离 = ","Go the door")..math.floor(distance))
		if distance > 1 then
		    if CheckBuff("player",rs["奥术智慧"]) then
			    awm.RunMacroText("/cancelAura "..rs["奥术智慧"])
			    return
			end
			if CheckBuff("player",rs["冰甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["冰甲术"])
				return
			end
			if CheckBuff("player",rs["法师魔甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["法师魔甲术"])
				return
			end
			if CheckBuff("player",rs["魔法抑制"]) then
				awm.RunMacroText("/cancelAura "..rs["魔法抑制"])
				return
			end
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	elseif Dungeon_step1 == 3 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
		if not awm.UnitAffectingCombat("player") then
		    if not MakingDrinkOrEat() then
	 	 	    Note_Set(Check_UI("做面包和水...","Making food and drink..."))
				return
	 		end   
			if not NeedHeal() then
				Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 		return
	 		end
	 		if not CheckBuff("player",rs["奥术智慧"]) then
				Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Buff Adding..."))
			    awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 		return
	 		end
			if not CheckBuff("player",rs["冰甲术"]) then
			    Note_Set(rs["冰甲术"]..Check_UI("BUFF增加中...","Buff Adding"))
				awm.CastSpellByName(rs["冰甲术"])
	 	 		return
	 		end
			if not CheckUse() then
			    Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			    return
			end
			Dungeon_step1 = 4
		end
		HasStop = false
		Dungeon_step1 = 4
	elseif Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local Path = 
		{
		{129.99, -120.93, -1.59}, -- 1 等待龙虾位置
		{102.50, -95.21, -1.59},
		{75.43, -82.78, -2.95},
		{66.82, -84.21, -2.59}, -- 4 下雪 第一波龙虾
		{52.55, -70.64, -2.64},
		{28.86, -56.28, -2.99},
		{18.62, -46.40, -2.91}, -- 7 反制 第二波龙虾
		{0.98, -14.52, -1.52}, -- 8 闪现
		{1.76, 8.50, 1.71},
		{-9.18, 12.85, 3.52},
		{-21.04, 23.02, 2.82},
		{-35.09, 25.99, 0.78},
		{-47.37, 21.21, -1.43},
		{-65.57,15.32,-1.59},
		{-76.87,0.51,-5.33}, -- 15 冰环
		{-111.77,-15.98,-8.37}, -- 16 没奴隶冰环 有奴隶吹风
		{-107.77,-26.57,-3.91}, -- 17 没奴隶冰环 有奴隶吹风
		{-103.79,-47.04,-2.99}, -- 18 冰环
		{-92.78,-121.83,-2.00}, -- 19 闪现 下雪 -119.63,-142.53,-2.32
		{-84.67,-124.28,-1.54},
		{-79.61,-131.08,-1.58},
		{-68.37,-131.85,-1.59},
		{-60.15,-134.85,-1.59},
		{-39.31,-163.79,-1.57},
		{-28.93,-190.30,-2.55},
		{-20.02,-208.63,-1.67}, -- 26 闪现
		{-22.34,-231.47,-2.40}, -- 27 吹风
		{-10.80,-271.15,-0.84}, -- 28 反制
		{-7.83, -295.41, 2.89}, -- 29 冰环
		{-0.04,-297.96,3.03}, -- 30 急冷
		{2.98,-303.41,3.03}, -- 31 冰环
		{66.91,-322.28,3.04}, -- 32 闪现 下雪
		{90.57,-327.69,3.03}, -- 33 下雪
		{70.43,-342.37,3.04},
		{67.69,-342.85,3.04}, -- 35 调整角度 闪现
		{52.41,-346.04,6.13}, -- 36 修正方向, 拉技师110
		{52.41,-346.04,6.13}, -- 37 等待5s
		{32.87,-340.17,6.08},
		{9.77,-348.35,6.08}, -- 39 等待怪物 -21.28,-379.91,6.08
		{9.77,-348.35,6.08}, -- 40 下雪 -16.16,-370.42,6.08
		{33.56,-340.37,6.11},
		{40.54,-342.37,6.08}, -- 42 下雪 9.67,-349.10,6.08 7.5s
		{53.56,-346.52,6.08},
		{70.40,-340.65,6.08},
		{87.78,-346.53,3.03},
		{91.34,-376.84,3.03},
		{80.70,-383.42,3.03}, -- 47 到达下雪位置
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 5
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.8 then
		    SP_Timer = false

			if Dungeon_move == 8 or Dungeon_move == 19 or Dungeon_move == 26 or Dungeon_move == 32 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 45 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and Distance >= 35 then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 15 or Dungeon_move == 18 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    local target = nil
					local Monster1 = nil

					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
							local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
							if guid == 17957 and distance <= 10 then
							    target = ThisUnit
							end
							if guid == 17963 and distance <= 20 then
							    Monster1 = ThisUnit
							end
						end
					end

					if target and not Monster1 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end
			if Dungeon_move == 16 or Dungeon_move == 17 then
			    local Monster = nil
				local Monster1 = nil
				local Monster2 = nil

			    local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
						if guid == 17957 and distance <= 10 then
							Monster = ThisUnit
							Monster1 = ThisUnit
						elseif guid == 17963 and distance <= 20 then
						    Monster2 = ThisUnit
						end
					end
				end

				if Monster ~= nil then				    
					local tarx,tary,tarz = awm.ObjectPosition(Monster)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
					if distance <= 8 and Monster2 == nil and Spell_Castable(rs["冰霜新星"]) then
						awm.CastSpellByName(rs["冰霜新星"])
					elseif distance <= 8 and Spell_Castable(rs["冰锥术(等级 1)"]) then
					    Try_Stop()
					    if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["冰锥术(等级 1)"])
						elseif not IsFacing(tarx,tary,tarz) then 
						    awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
						end
						return
					end
				elseif Monster1 ~= nil and Spell_Castable(rs["冰锥术(等级 1)"]) then
				    Try_Stop()
				    local tarx,tary,tarz = awm.ObjectPosition(Monster1)
					if IsFacing(tarx,tary,tarz) then
						awm.CastSpellByName(rs["冰锥术(等级 1)"])
					elseif not IsFacing(tarx,tary,tarz) then 
						awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
					end
					return
				end
			end
			if Dungeon_move == 35 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 45 and Dungeon_move <= 46 then
			    local Monster = Combat_Scan()
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz)
					local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz)
					local id = awm.ObjectId(ThisUnit)
					if id and id == 17940 and Spell_Castable(rs["法术反制"]) and tarz >= 4 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and distance_avoid > 5 and distance_avoid1 > 20 and awm.UnitTarget(ThisUnit) then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			awm.MoveTo(x,y,z)

			if Distance >= 7 then
				if Dungeon_move ~= 32 and Dungeon_move ~= 8 and Dungeon_move ~= 26 and Dungeon_move ~= 19 then
				    CheckProtection()
				end
			end

			if Dungeon_move == 41 and Pz <= 3.5 then
			    Dungeon_move = 45
				textout(Check_UI("你从台子掉落了,直接进行AOE","You fall from the stair, Start AOE directly"))
				return
			end

			if Dungeon_move == 41 then
			    if DoesSpellExist(rs["防护火焰结界"]) and not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				end
				return
			end

			return 
		elseif Distance <= 0.8 then
			HasStop = false

			if Dungeon_move == 1 then
			    local target1 = Find_Object_Position({17816,17817},108.03,-98.82,-1.59,30)
				if not target1 then
				    Dungeon_move = 2
					textout(Check_UI("龙虾到位","Mobs2 on position"))
				end
				return
			end


			if Dungeon_move == 4 then -- 下雪
			    Try_Stop()
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},Px,Py,Pz)

				if awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end

				if not target1 then
				    Dungeon_step1 = 10
					Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
					textout(Check_UI("残本重置","Go out dungeon to reset"))
					return
				end
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance <= 36 then
					    if SP_Timer then
							local time = GetTime() - SP_Time
							if time >= 2 and not awm.UnitAffectingCombat("player") then
								SP_Timer = false
								awm.SpellStopCasting()
								Target_Monster = nil
								return
							end
						end

						if not CastingBarFrame:IsVisible() then
							if not awm.IsAoEPending() then
								awm.CastSpellByName(rs["暴风雪(等级 1)"])
							else
								awm.ClickPosition(tarx, tary, tarz)
							end
						else
							if not SP_Timer then
								SP_Timer = true
								SP_Time = GetTime()
							end
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 7 then -- 反制
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},19.02, -46.512, -2)
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance < 30 then
					    awm.CastSpellByName(rs["法术反制"],target1)
						Dungeon_move = Dungeon_move + 1
						awm.SpellStopCasting()
						return
					end
				end
				Dungeon_move = 8
				awm.SpellStopCasting()
				return
			end

			if Dungeon_move == 28 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 28 then
				    Target_ID = nil
					tarx,tary,tarz = 7.84,-256,0.85
					Scan_Distance = 8
				end
				if Target_Monster == nil then
				    Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
				else
				    awm.TargetUnit(Target_Monster)
					awm.CastSpellByName(rs["法术反制"])
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				end
				if Target_Monster == nil then
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
				end
				return
			end

			if Dungeon_move == 29 or Dungeon_move == 31 then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end
			if Dungeon_move == 30 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			if (Dungeon_move == 19 and Easy_Data["击杀医师"]) or Dungeon_move == 32 or Dungeon_move == 33 or Dungeon_move == 40 or Dungeon_move == 42 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 19 then
				    sx,sy,sz = -119.63,-142.53,-2.32
					s_time = 1.5
				elseif Dungeon_move == 32 then
				    sx,sy,sz = 33.88,-312.36,3.03
					s_time = 2.8
				elseif Dungeon_move == 33 then
				    sx,sy,sz = 119.08,-308.96,3.03
					s_time = 1.5
				elseif Dungeon_move == 40 then
				    sx,sy,sz = -16.16,-370.42,6.08
					s_time = 7.5
				elseif Dungeon_move == 42 then
				    sx,sy,sz = 9.67,-349.10,6.08
					s_time = 7.5
					for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if distance <= 8 then
						    if Spell_Castable(rs["冰霜新星"]) then
							    awm.CastSpellByName(rs["冰霜新星"])
							end
							SP_Timer = false
							awm.SpellStopCasting()
							Target_Monster = nil
							Dungeon_move = Dungeon_move + 1
							return
						end
					end
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
					else
					    awm.ClickPosition(sx,sy,sz)
					end
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 35 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 3.312) < 0.01 then -- 3.35
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(3.312)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end
			if Dungeon_move == 36 then
			    if not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				elseif CheckBuff("player",rs["防护火焰结界"]) then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 37 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 60
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(101.92,-340.67,3.03,x1,y1,z1)
						local distance1 = awm.GetDistanceBetweenPositions(91.16,-356.92,3.03,x1,y1,z1)
						local distance2 = awm.GetDistanceBetweenPositions(76.38,-361.47,3.03,x1,y1,z1)
						local distance3 = awm.GetDistanceBetweenPositions(64.73,-364.45,3.03,x1,y1,z1)
						local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,x1,y1,z1)
						local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,x1,y1,z1)
						local distance_avoid2 = awm.GetDistanceBetweenPositions(40.16,-389.70,3.03,x1,y1,z1)
						if guid and guid == 17940 and distance_avoid > 5 and distance_avoid1 > 20 and distance_avoid2 > 20 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
							if distance < Far_Distance then
								Far_Distance = distance
								target = ThisUnit
							end
							if distance1 < Far_Distance then
								Far_Distance = distance1
								target = ThisUnit
							end
							if distance2 < Far_Distance then
								Far_Distance = distance2
								target = ThisUnit
							end
							if distance3 < Far_Distance then
								Far_Distance = distance3
								target = ThisUnit
							end
						end
					end
				end

				if target ~= nil then
				    awm.TargetUnit(target)
				    if Spell_Castable(rs["法术反制"]) then
				        awm.CastSpellByName(rs["法术反制"],target)
					else
					    awm.CastSpellByName(rs["火球术(等级 1)"],target)
					end
				end
				if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time > 12 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
					end
				end
				return
			end

			if Dungeon_move == 39 then
			    local Monster = Combat_Scan()
			    if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(-21.28,-379.91,tarz,tarx,tary,tarz)
						if distance < 12 then
						    Dungeon_move = 40
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end


			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

	    local Path = 
		{
		{78.71,-382.63,3.03}, -- 1 等待怪物 55.42,-411.78,3.03 12码
		{78.71,-382.63,3.03}, -- 2 第一波 57.53,-410.19,3.03
		{78.71,-382.63,3.03}, -- 3 第二波 64.69,-413.33,3.03
		{78.71,-382.63,3.03}, -- 4 第三波 75.21,-417.54,3.03
		{82.85,-373.22,3.03}, -- 5
		{73.22,-338.022,3.03}, -- 6 闪现
		{73.22,-338.022,3.03}, -- 7 跳台子 -- 74.24,-335.79,3.03
		{72.78,-336.04,6.11}, -- 8 等待20s -- 72.39,-336.74,6.11
		{87.78,-346.53,3.03}, -- 9
		{91.34,-376.84,3.03}, -- 10
		{78.71,-382.63,3.03}, -- 11 到达下雪位置
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.7 then
		    SP_Timer = false
			HasStop = false
			if Dungeon_move == 6 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			local Monster = Combat_Scan()
			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if distance < 8 then
					CheckProtection()
				end
			end

			if Dungeon_move == 7 and Pz >= 5.9 then
			    Try_Stop()
			    Dungeon_move = 8
				return
			elseif Dungeon_move == 7 and HasStop then
			    return
			end

			awm.MoveTo(x,y,z)

			return 
		elseif Distance <= 0.7 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			local Monster = Combat_Scan()
			if Dungeon_move == 1 then -- 扫描怪物距离
			    Note_Set(Dungeon_move.." | "..#Monster)
				if not CheckBuff("player",rs["冰冷血脉"]) and Spell_Castable(rs["冰冷血脉"]) then
				    awm.CastSpellByName(rs["冰冷血脉"])
				end

				if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(55.42,-411.78,3.03,tarx,tary,tarz)
						local distance1 = awm.GetDistanceBetweenPositions(67.77,-415.16,3.03,tarx,tary,tarz)
						local distance2 = awm.GetDistanceBetweenPositions(75.21,-417.54,3.03,tarx,tary,tarz)
					    if distance2 < 14 then
						    Dungeon_move = 4
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						end
						if distance1 < 14 then
						    Dungeon_move = 3
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						end
						if distance < 15 then
						    Dungeon_move = 2
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    local target = nil
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							if guid and guid == 17941 then
								target = ThisUnit
							end
						end
					end
					if target == nil then
						Dungeon_step1 = 6
					else
						local face = awm.UnitFacing(target)
						local tarx,tary,tarz = awm.ObjectPosition(target)
						if tarz >= 20 then
							Dungeon_step1 = 6
						end
					end
				end
				return
			end

			if Dungeon_move == 2 or Dungeon_move == 3 or Dungeon_move == 4 then -- 暴风雪
			    Note_Set(Dungeon_move.." | "..#Monster)
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				local Mage_Mob = false

				if Dungeon_move == 2 then
				    sx,sy,sz = 57.53,-410.19,3.03
					s_time = 5
				elseif Dungeon_move == 3 then
				    sx,sy,sz = 67.77,-415.16,3.03
					s_time = 7
				elseif Dungeon_move == 4 then
				    sx,sy,sz = 75.21,-417.54,3.03
					s_time = 7.5
				end

				local Mobs_Down = false
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local guid = awm.ObjectId(ThisUnit)

					if guid == 17961 then
					    Mage_Mob = true
					end

					if tarz <= 4 then
					    Mobs_Down = true
					end

					if distance < 8 then
						SP_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Spell_Castable(rs["冰霜新星"]) then
							awm.CastSpellByName(rs["冰霜新星"])
						end
						Dungeon_move = 5
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					end
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if Mage_Mob and not CastingBarFrame:IsVisible() then
				    if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
					    awm.CastSpellByName(rs["寒冰护体"],"player")
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 3000 and Is_Together(Monster) and Dungeon_move ~= 2 then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 5000 and Dungeon_move == 3 then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Dungeon_move == 4 and not Mobs_Down then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						else
							awm.CastSpellByName(rs["暴风雪(等级 1)"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
							end
						end
					else
					    awm.ClickPosition(sx,sy,sz)
					end					
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 7 then
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end
			 
			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() HasStop = false end)
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						local time = math.random(7,11)/100 + math.random()/100
						C_Timer.After(time,awm.MoveForwardStart)
						C_Timer.After(0.25,function() awm.MoveForwardStop() end)
					end
				end
				return
			end

			if Dungeon_move == 8 then
			    if not awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and not CastingBarFrame:IsVisible() then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 18 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
					if time <= 10 and awm.UnitPower("player") < 3000 and Spell_Castable(rs["唤醒"]) and not CastingBarFrame:IsVisible() then
					    awm.CastSpellByName(rs["唤醒"])
						return
					end
				end
				return
			end

			if Dungeon_move == 11 then
			    awm.AscendStop()
			    Dungeon_move = 1
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 6 then -- 拾取阶段
	    local body_list = Find_Body()
		if GetItemCount(Check_Client("裂纹的蚌壳","Jaggal Clam")) > 0 then
		    awm.UseItemByName(Check_Client("裂纹的蚌壳","Jaggal Clam"))
		end
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
		if #body_list > 0 then
			local distance1 = awm.GetDistanceBetweenObjects("player",body_list[1].Unit)
			local x,y,z = awm.ObjectPosition(body_list[1].Unit)
			if distance1 >= 5 then
				if Mount_useble then
					Mount_useble = false
					C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
				end
				Run(x,y,z)
				Interact_Step = false
				Open_Slot = false
			else
				if not Open_Slot then
					Open_Slot = true
					Open_Slot_Time = GetTime()
					if LootFrame:IsVisible() then
						CloseLoot()
						LootFrame_Close()
						return
					end
					awm.InteractUnit(body_list[1].Unit)
				else
					local time = GetTime() - Open_Slot_Time
					local Interval = tonumber(Easy_Data["拾取间隔"])
					if Interval == nil then
						Interval = 0.5
					end
					if time > Interval then
						Open_Slot = false
					end
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							CloseLoot()
							LootFrame_Close()
							return
						end
						for i = 1,GetNumLootItems() do
							LootSlot(i)
							ConfirmLootSlot(i)
						end
					end
				end
			end
	    else
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
	elseif Dungeon_step1 == 7 then -- 出本到门神
	    Note_Head = Check_UI("出本到门神","Go out dungeon Phase 1")

		local Path = 
		{
		{98.73,-411.45,3.03}, -- 开箱子
		{111.47,-379.19,3.03},
		{111.27,-350.35,3.03},
		{111.08,-323.09,3.03},
		{88.25,-319.89,3.03}, -- 开箱子
		{69.69,-321.00,3.04},
		{-8.58,-301.57,2.94},
		}
		if Dungeon_move > #Path then
		    if not Easy_Data["围栏采药"] and not Easy_Data["围栏采矿"] then
		        Dungeon_step1 = 8
			else
			    Dungeon_step1 = 9
			end
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			
			awm.MoveTo(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false
			
			if Dungeon_move == 1 then
			    if not MakingDrinkOrEat() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
			    if not CheckUse() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
				end
				Dungeon_move = Dungeon_move + 1
			    return
			end

			if Dungeon_move == 5 then
			    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
				local target1 = Find_Object_Position(17940,135.59,-304.62,3.03,15)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				elseif target ~= nil and target1 == nil then
				    Dungeon_step1 = 20
				elseif target1 ~= nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 8 then -- 出本到门口
	    Note_Head = Check_UI("出本到门口","Go out dungeon Phase 2")

		Reset_Instance = true

		local Path = 
		{
		{-9.91,-282.48,-0.89},
		{-11.79,-255.58,-1.20},
		{-13.65,-228.94,-1.59},
		{-15.44,-203.34,-1.59},
		{-16.44,-188.99,-1.57},
		{-29.18,-173.37,-1.59},
		{-41.63,-166.69,-1.47},
		{-45.09,-154.85,-1.58},
		{-58.04,-135.75,-1.58},
		{-69.03,-131.55,-1.59},
		{-84.30,-126.44,-1.51},
		{-87.44,-118.06,-1.78},
		{-88.16,-105.80,-4.89},
		{-100.72,-58.97,-2.43},
		{-112.73,-16.37,-8.54},
		{-91.56,-6.80,-7.80},
		{-78.13,-6.11,-7.46},
		{-79.82,5.36,-5.01},
		{-68.94,15.21,-1.92},
		{-54.13,19.49,-1.59},
		{-47.06,21.11,-1.39},
		{-34.08,26.67,0.99},
		{-23.50,25.08,2.56},
		{-16.15,19.29,3.37},
		{3.37,-13.13,-1.47},
		{8.22,-33.05,-2.10},
		{62.13,-63.96,-2.77},
		{111.52,-92.45,-1.59},
		{122.57,-105.59,-1.59},
		{122.75,-125.88,-0.72},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false

			if (Dungeon_move == 27 or Dungeon_move == 28) and IsFacing(x,y,Pz) and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(1.5,function() Interact_Step = false end)
			    awm.JumpOrAscendStart()
			end
			
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if Dungeon_move == 27 or Dungeon_move == 28 then
			    awm.AscendStop()
			end
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 6 then
			    local target = Find_Object_Position(17961,-48.23,-166.59,-1.48,30)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 23 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 9 then -- 采集
	    Note_Head = Check_UI("双采","Mining and Herbalism")

		Reset_Instance = true

		local Path = 
		{
			{-14.54,-310.31,2.53},
			{-22.88,-324.64,-1.57},
			{-15.52,-327.92,-1.58},
			{-41.61,-328.49,-1.58},
			{-71.42,-314.72,-1.49},
			{-95.73,-320.61,-1.59},
			{-110.10,-317.16,-1.58},
			{-138.17,-305.09,-0.62},
			{-148.54,-280.47,-1.58},
			{-151.02,-267.22,-1.59},
			{-146.65,-255.57,-1.59},
			{-155.46,-278.88,-1.58},
			{-141.47,-279.57,-1.59},
			{-130.21,-273.45,-1.59},
			{-123.97,-281.95,-1.59},
			{-128.07,-307.63,-1.39},
			{-105.70,-319.32,-1.59},
			{-71.91,-327.56,-1.56},
			{-46.57,-327.44,-1.58},
			{-23.48,-327.97,-1.59},
			{-14.77,-301.38,2.34},
			{-10.30,-280.59,-0.76},
			{-6.50,-268.03,-0.42},
			{-13.46,-255.50,-1.33},
			{-20.17,-243.31,-2.06},
			{-21.03,-219.86,-2.25},
			{-21.44,-206.95,-1.77},
			{-1.73,-187.94,-1.56},
			{-19.76,-175.02,-1.59},
			{-34.85,-167.70,-1.59},
			{-39.85,-165.07,-1.50},
			{-58.20,-135.51,-1.58},
			{-58.78,-151.83,-1.43},
			{-58.71,-135.10,-1.58},
			{-71.30,-130.60,-1.59},
			{-81.53,-127.91,-1.59},
			{-84.02,-125.88,-1.53},
			{-86.71,-120.80,-1.92},
			{-104.22,-123.91,-2.15},
			{-100.10,-101.21,-4.46},
			{-102.73,-69.06,-3.20},
			{-116.16,-27.34,-6.38},
			{-108.27,-6.19,-8.84},
			{-92.39,3.06,-6.15},
			{-81.43,5.31,-5.26},
			{-70.27,8.89,-2.90},
			{-62.73,16.97,-1.59},
			{-58.39,15.09,-1.59},
			{-48.26,20.90,-1.59},
			{-30.08,28.25,1.72},
			{-25.23,26.45,2.37},
			{-19.08,21.61,3.05},
			{3.80,2.20,-0.40},
			{4.74,-4.35,-1.30},
			{-4.42,-3.98,-1.23},
			{1.28,-20.34,-1.70},
			{-9.80,-45.35,-2.55},
			{-9.90,-69.16,-1.59},
			{17.19,-69.33,-1.59},
			{54.26,-91.94,-2.87},
			{57.33,-77.51,-2.59},
			{99.07,-85.14,-2.18},
			{120.69,-111.13,-0.70},
			{121.20,-125.18,-0.26},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 39 then
			    local target = Find_Object_Position(21128,-119.63,-142.53,-2.32,30)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if Dungeon_move == 3 or Dungeon_move == 5 or Dungeon_move == 7 or Dungeon_move == 11 or Dungeon_move == 14 or Dungeon_move == 23 or Dungeon_move == 28 or Dungeon_move == 33 or Dungeon_move == 39 or Dungeon_move == 43 or Dungeon_move == 48 or Dungeon_move == 55 or Dungeon_move == 58 or Dungeon_move == 61 then
			    local S = {}
				if Dungeon_move == 3 then
				    S.x,S.y,S.z = -15.10,-328.10,-1.58
				elseif Dungeon_move == 5 then
				    S.x,S.y,S.z = -71.61,-314.31,-1.48
				elseif Dungeon_move == 7 then
				    S.x,S.y,S.z = -110.10,-317.16,-1.58
				elseif Dungeon_move == 11 then
				    S.x,S.y,S.z = -146.68,-255.88,-1.58
				elseif Dungeon_move == 14 then
				    S.x,S.y,S.z = -130.50,-273.60,-1.58
				elseif Dungeon_move == 23 then
				    S.x,S.y,S.z = -6.49,-268.13,-0.4
				elseif Dungeon_move == 28 then
				    S.x,S.y,S.z = 0.00,-186.66,-1.55
				elseif Dungeon_move == 33 then
				    S.x,S.y,S.z = -58.80,-152.35,-1.42
				elseif Dungeon_move == 39 then
				    S.x,S.y,S.z = -136.80,-128.96,-1.69
				elseif Dungeon_move == 43 then
				    S.x,S.y,S.z = -108.11,-5.77,-8.77
				elseif Dungeon_move == 48 then
				    S.x,S.y,S.z = -55.62,13.89,-1.58
				elseif Dungeon_move == 55 then
				    S.x,S.y,S.z = -8.01,-3.30,-1.21
				elseif Dungeon_move == 58 then
				    S.x,S.y,S.z = -9.61,-69.09,-1.58
				elseif Dungeon_move == 61 then
				    S.x,S.y,S.z = 57.38,-76.99,-2.58
				end

				Target_Item = nil
				local target = Find_Game_Obj(S.x,S.y,S.z,15)
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

			if Dungeon_move == 29 or Dungeon_move == 32 then
			    local target = Find_Object_Position(17961,-58.80,-152.35,-1.42,40)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 9 or Dungeon_move == 12 then
			    local target = Find_Object_Position(17957,-48.75,-262.20,-0.89,20)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 52 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 10 then -- 准备出本
	    local x,y,z = 122,-122,0
		local distance = awm.GetDistanceBetweenPositions(x,y,z,Px,Py,Pz)
		if distance > 2 then
		    if Mount_useble then
				Mount_useble = false
				C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
			end
			Run(x,y,z)
		else
		    Dungeon_step1 = 1
			Dungeon_move = 1
			Dungeon_step = 2
			return
		end
	elseif Dungeon_step1 == 20 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
		if target == nil then
		    Dungeon_step1 = 7
			Dungeon_move = 5
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 30 then -- 双采步骤
		if not awm.ObjectExists(Target_Item) then
			Dungeon_step1 = 9
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
			    Run(x,y,z)
			end
		end
	end
end
function SP_40()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end
	if not CheckBuff("player","精神错乱") and not CheckBuff("player","Flip Out") and not CheckBuff("player","呀啊啊啊啊") and not CheckBuff("player","Yaaarrrr") then
	    if Easy_Data["使用风蛇"] then
		    if GetItemCount("美味风蛇") > 0 then
			    awm.UseItemByName("美味风蛇")
				textout("使用物品 - 美味风蛇")
			elseif GetItemCount("Savory Deviate Delight") > 0 then
			    awm.UseItemByName("Savory Deviate Delight")
				textout("Use item - Savory Deviate Delight")
			end
		end
	end

	if Dungeon_step1 == 4 and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["寒冰屏障"]) then
	    awm.CastSpellByName(rs["寒冰屏障"])
	end
	if CheckBuff("player",rs["寒冰屏障"]) and not (Dungeon_move == 66 and Dungeon_step1 == 4) then
		awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
	end

	if Dungeon_step1 >= 4 then
	    if not CastingBarFrame:IsVisible() then
		    UseItem()
		end
	end

	if Dungeon_step1 == 5 then
	    frame:SetBackdropColor(0,0,0,0)
	    if not CastingBarFrame:IsVisible() then
			if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				awm.CastSpellByName(rs["法师魔甲术"],"player")
			end
		end
	end


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

		local path = {{129.82,-126.43,-1.59}}
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
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = 121.16, -129.47,Pz
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往副本门口, 距离 = ","Go the door")..math.floor(distance))
		if distance > 1 then
		    if CheckBuff("player",rs["奥术智慧"]) then
			    awm.RunMacroText("/cancelAura "..rs["奥术智慧"])
			    return
			end
			if CheckBuff("player",rs["冰甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["冰甲术"])
				return
			end
			if CheckBuff("player",rs["法师魔甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["法师魔甲术"])
				return
			end
			if CheckBuff("player",rs["魔法抑制"]) then
				awm.RunMacroText("/cancelAura "..rs["魔法抑制"])
				return
			end
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	elseif Dungeon_step1 == 3 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
		if not awm.UnitAffectingCombat("player") then
		    if not MakingDrinkOrEat() then
	 	 	    Note_Set(Check_UI("做面包和水...","Making food and drink..."))
				return
	 		end   
			if not NeedHeal() then
				Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 		return
	 		end
	 		if not CheckBuff("player",rs["奥术智慧"]) then
				Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Buff Adding..."))
			    awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 		return
	 		end
			if not CheckBuff("player",rs["冰甲术"]) then
			    Note_Set(rs["冰甲术"]..Check_UI("BUFF增加中...","Buff Adding"))
				awm.CastSpellByName(rs["冰甲术"])
	 	 		return
	 		end
			if not CheckUse() then
			    Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			    return
			end
			Dungeon_step1 = 4
		end
		HasStop = false
		Dungeon_step1 = 4
	elseif Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local Path = 
		{
		{129.99, -120.93, -1.59}, -- 1 等待龙虾位置
		{102.50, -95.21, -1.59},
		{75.43, -82.78, -2.95},
		{66.82, -84.21, -2.59}, -- 4 下雪 第一波龙虾
		{52.55, -70.64, -2.64},
		{28.86, -56.28, -2.99},
		{18.62, -46.40, -2.91}, -- 7 反制 第二波龙虾
		{0.98, -14.52, -1.52}, -- 8 闪现
		{1.76, 8.50, 1.71},
		{-9.18, 12.85, 3.52},
		{-21.04, 23.02, 2.82},
		{-35.09, 25.99, 0.78},
		{-47.37, 21.21, -1.43},
		{-65.57,15.32,-1.59},
		{-76.87,0.51,-5.33}, -- 15 冰环
		{-111.77,-15.98,-8.37}, -- 16 吹风
		{-113.001,-23.48,-6.39}, -- 17 吹风
		{-103.79,-47.04,-2.99}, -- 18 冰环
		{-92.78,-121.83,-2.00}, -- 19 闪现 下雪 -119.63,-142.53,-2.32
		{-84.67,-124.28,-1.54},
		{-79.61,-131.08,-1.58},
		{-68.37,-131.85,-1.59},
		{-60.15,-134.85,-1.59},
		{-39.31,-163.79,-1.57},
		{-28.93,-190.30,-2.55},
		{-20.02,-208.63,-1.67}, -- 26 闪现 -- -20.54,-206.23,-1.67
		{-22.34,-231.47,-2.40}, -- 27 吹风
		{-10.80,-271.15,-0.84}, -- 28 反制
		{-7.83, -295.41, 2.89}, -- 29 冰环
		{-0.04,-297.96,3.03}, -- 30 急冷
		{2.98,-303.41,3.03}, -- 31 冰环
		{66.91,-322.28,3.04}, -- 32 闪现 下雪
		{90.57,-327.69,3.03}, -- 33 下雪
		{70.43,-342.37,3.04},
		{67.69,-342.85,3.04}, -- 35 调整角度 闪现
		{52.41,-346.04,6.13}, -- 36 修正方向, 拉技师110
		{52.41,-346.04,6.13}, -- 37 等待5s
		{32.87,-340.17,6.08},
		{9.77,-348.35,6.08}, -- 39 等待怪物 -21.28,-379.91,6.08 -- 9.48,-348.57,6.08
		{9.77,-348.35,6.08}, -- 40 下雪 下雪位置 -16.16,-370.42,6.08
		{33.56,-340.37,6.11},
		{40.54,-342.37,6.08}, -- 42 下雪 下雪位置 9.67,-349.10,6.08 7.5s
		{53.56,-346.52,6.08},
		{70.40,-340.65,6.08},
		{87.78,-346.53,3.03},
		{91.34,-376.84,3.03},
		{107.52,-421.47,3.03}, -- 47 等待怪物到位
		{107.52,-421.47,3.03}, -- 48 下雪 126.43,-449.76,3.03
		{97.22,-353.46,3.03}, -- 49 闪现
		{73.70,-336.96,3.03}, -- 50 跳台子
		{72.78,-336.04,6.11}, -- 51 等待18s
		{76.47,-338.13,3.03}, -- 52 下台子 判断 boss 位置 成功到达55
		{73.70,-336.96,3.03}, -- 53 跳台子
		{72.78,-336.04,6.11}, -- 54 等待 3s 返回52
		{87.78,-346.53,3.03}, -- 55
		{91.34,-376.84,3.03}, -- 56
		{78.71,-382.63,3.03}, -- 57 到达下雪位置 等待怪物
		{78.71,-382.63,3.03}, -- 58 第一波 57.53,-410.19,3.03
		{78.71,-382.63,3.03}, -- 59 第二波 64.69,-413.33,3.03
		{91.34,-376.84,3.03}, -- 60 
		{85.98,-357.88,3.03}, -- 61 闪现
		{65.83,-357.52,3.03}, -- 62 下雪 39.16,-377.8,3.03
		{71.02,-352.27,3.03}, -- 63 反制 49.21,-365.61,3.03 ID = 17940
		{73.70,-336.96,3.03}, -- 64 跳台子
		{72.78,-336.04,6.11}, -- 65
		{71.90,-337.81,6.11}, -- 66 等待18s
		{87.78,-346.53,3.03}, -- 67
		{91.34,-376.84,3.03}, -- 68
		{78.71,-382.63,3.03}, -- 69 到达下雪位置
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 5
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.8 then
		    SP_Timer = false

			if Dungeon_move == 8 or Dungeon_move == 19 or Dungeon_move == 26 or Dungeon_move == 32 or Dungeon_move == 49 or Dungeon_move == 61 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 45 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and Distance >= 35 then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 15 or Dungeon_move == 18 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    local target = nil
					local Monster1 = nil

					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
							local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
							if guid == 17957 and distance <= 10 then
							    target = ThisUnit
							end
							if guid == 17963 and distance <= 20 then
							    Monster1 = ThisUnit
							end
						end
					end

					if target and not Monster1 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end
			if Dungeon_move == 16 or Dungeon_move == 17 then
			    local Monster = nil
				local Monster1 = nil
				local Monster2 = nil

			    local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
						if guid == 17957 and distance <= 10 then
							Monster = ThisUnit
							Monster1 = ThisUnit
						elseif guid == 17963 and distance <= 20 then
						    Monster2 = ThisUnit
						end
					end
				end

				if Monster ~= nil then				    
					local tarx,tary,tarz = awm.ObjectPosition(Monster)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
					if distance <= 8 and Monster2 == nil and Spell_Castable(rs["冰霜新星"]) then
						awm.CastSpellByName(rs["冰霜新星"])
					elseif distance <= 8 and Spell_Castable(rs["冰锥术(等级 1)"]) then
					    Try_Stop()
					    if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["冰锥术(等级 1)"])
						elseif not IsFacing(tarx,tary,tarz) then 
						    awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
						end
						return
					end
				elseif Monster1 ~= nil and Spell_Castable(rs["冰锥术(等级 1)"]) then
				    Try_Stop()
				    local tarx,tary,tarz = awm.ObjectPosition(Monster1)
					if IsFacing(tarx,tary,tarz) then
						awm.CastSpellByName(rs["冰锥术(等级 1)"])
					elseif not IsFacing(tarx,tary,tarz) then 
						awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
					end
					return
				end
			end
			if Dungeon_move == 35 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 45 and Dungeon_move <= 46 then
			    local Monster = Combat_Scan()
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz)
					local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz)
					local id = awm.ObjectId(ThisUnit)
					if id and id == 17940 and Spell_Castable(rs["法术反制"]) and tarz >= 4 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and distance_avoid > 5 and distance_avoid1 > 20 and awm.UnitTarget(ThisUnit) then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			if (Dungeon_move == 50 or Dungeon_move == 53 or Dungeon_move == 64) and Distance < 1.2 then
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			awm.MoveTo(x,y,z)
			if Distance >= 7 then
				if Dungeon_move ~= 32 and Dungeon_move ~= 8 and Dungeon_move ~= 26 and Dungeon_move ~= 19 and Dungeon_move ~= 61 and Dungeon_move ~= 49 then
				    CheckProtection()
				end
			end

			if Dungeon_move == 41 and Pz <= 3.5 then
			    Dungeon_move = 50
				textout(Check_UI("你从台子掉落了,直接进行AOE","You fall from the stair, Start AOE directly"))
				return
			end

			if Dungeon_move == 41 then
			    if DoesSpellExist(rs["防护火焰结界"]) and not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				end
				return
			end

			if Dungeon_move == 64 and Spell_Castable(rs["冰霜新星"]) and Distance <= 4 then
			    awm.CastSpellByName(rs["冰霜新星"])
			end

			return 
		elseif Distance <= 0.8 then
			HasStop = false
			local Monster = Combat_Scan()

			if Dungeon_move == 1 then
			    local target1 = Find_Object_Position({17816,17817},108.03,-98.82,-1.59,30)
				if not target1 then
				    Dungeon_move = 2
					textout(Check_UI("龙虾到位","Mobs2 on position"))
				end
				return
			end


			if Dungeon_move == 4 then -- 下雪
			    Try_Stop()
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},Px,Py,Pz)

				if awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end

				if not target1 then
				    Dungeon_step1 = 10
					Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
					textout(Check_UI("残本重置","Go out dungeon to reset"))
					return
				end
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance <= 36 then
					    if SP_Timer then
							local time = GetTime() - SP_Time
							if time >= 2 and not awm.UnitAffectingCombat("player") then
								SP_Timer = false
								awm.SpellStopCasting()
								Target_Monster = nil
								return
							end
						end

						if not CastingBarFrame:IsVisible() then
							if not awm.IsAoEPending() then
								awm.CastSpellByName(rs["暴风雪(等级 1)"])
							else
								awm.ClickPosition(tarx, tary, tarz)
							end
						else
							if not SP_Timer then
								SP_Timer = true
								SP_Time = GetTime()
							end
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 7 then -- 反制
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},19.02, -46.512, -2)
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance < 30 then
					    awm.CastSpellByName(rs["法术反制"],target1)
						Dungeon_move = Dungeon_move + 1
						awm.SpellStopCasting()
						return
					end
				end
				Dungeon_move = 8
				awm.SpellStopCasting()
				return
			end

			if Dungeon_move == 28 or Dungeon_move == 63 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 28 then
				    Target_ID = nil
					tarx,tary,tarz = 7.84,-256,0.85
					Scan_Distance = 8
				elseif Dungeon_move == 63 then
				    Target_ID = 17940
					tarx,tary,tarz = 49.21,-365.61,3.03
					Scan_Distance = 6
				end
				if Target_Monster == nil then
				    Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
				else
				    awm.TargetUnit(Target_Monster)
					awm.CastSpellByName(rs["法术反制"])
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				end
				if Target_Monster == nil then
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
				end
				return
			end

			if Dungeon_move == 29 or Dungeon_move == 31 then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end
			if Dungeon_move == 30 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			if (Dungeon_move == 19 and Easy_Data["击杀医师"]) or Dungeon_move == 32 or Dungeon_move == 33 or Dungeon_move == 40 or Dungeon_move == 42 or Dungeon_move == 48 or Dungeon_move == 58 or Dungeon_move == 59 or Dungeon_move == 62 then -- 暴风雪
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 19 then
				    sx,sy,sz = -119.63,-142.53,-2.32
					s_time = 1.5
				elseif Dungeon_move == 32 then
				    sx,sy,sz = 33.88,-312.36,3.03
					s_time = 2.8
				elseif Dungeon_move == 33 then
				    sx,sy,sz = 119.08,-308.96,3.03
					s_time = 1.5
				elseif Dungeon_move == 40 then
				    sx,sy,sz = -16.16,-370.42,6.08
					s_time = 7.5
				elseif Dungeon_move == 42 then
				    sx,sy,sz = 9.67,-349.10,6.08
					s_time = 7.5
					for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if distance <= 8 then
						    if Spell_Castable(rs["冰霜新星"]) then
							    awm.CastSpellByName(rs["冰霜新星"])
							end
							SP_Timer = false
							awm.SpellStopCasting()
							Target_Monster = nil
							Dungeon_move = Dungeon_move + 1
							return
						end
					end
				elseif Dungeon_move == 48 then
				    sx,sy,sz = 126.43,-449.76,3.03
					s_time = 1.5
				elseif Dungeon_move == 58 then
				    sx,sy,sz = 57.53,-410.19,3.03
					s_time = 5
				elseif Dungeon_move == 59 then
				    sx,sy,sz = 64.69,-413.33,3.03
					s_time = 4
				elseif Dungeon_move == 62 then
				    sx,sy,sz = 39.16,-377.8,3.03
					s_time = 1.5
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
					else
					    awm.ClickPosition(sx,sy,sz)
					end
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 35 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 3.312) < 0.01 then -- 3.35 
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(3.312)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end
			if Dungeon_move == 36 then
			    if not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				elseif CheckBuff("player",rs["防护火焰结界"]) then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 37 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 60
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(101.92,-340.67,3.03,x1,y1,z1)
						local distance1 = awm.GetDistanceBetweenPositions(91.16,-356.92,3.03,x1,y1,z1)
						local distance2 = awm.GetDistanceBetweenPositions(76.38,-361.47,3.03,x1,y1,z1)
						local distance3 = awm.GetDistanceBetweenPositions(64.73,-364.45,3.03,x1,y1,z1)
						local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,x1,y1,z1)
						local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,x1,y1,z1)
						local distance_avoid2 = awm.GetDistanceBetweenPositions(40.16,-389.70,3.03,x1,y1,z1)
						if guid and guid == 17940 and distance_avoid > 5 and distance_avoid1 > 20 and distance_avoid2 > 20 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
							if distance < Far_Distance then
								Far_Distance = distance
								target = ThisUnit
							end
							if distance1 < Far_Distance then
								Far_Distance = distance1
								target = ThisUnit
							end
							if distance2 < Far_Distance then
								Far_Distance = distance2
								target = ThisUnit
							end
							if distance3 < Far_Distance then
								Far_Distance = distance3
								target = ThisUnit
							end
						end
					end
				end

				if target then
				    awm.TargetUnit(target)
				    if Spell_Castable(rs["法术反制"]) then
				        awm.CastSpellByName(rs["法术反制"],target)
					else
					    awm.CastSpellByName(rs["火球术(等级 1)"],target)
					end
				end
				if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time > 12 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
					end
				end

				
				-- 扫描 boss

				local Boss = nil
				local Mob1 = nil -- 要引的怪物群1
				local Mob2 = nil -- 要引的怪物群2
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					if guid == 17941 then
						Boss = ThisUnit
					end

					if awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						Mob1 = ThisUnit
					end

					if awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						Mob1 = ThisUnit
					end
				end

				if not Mob1 and not Mob2 then
					Attracted_Mobs = true
				end

				if Boss then
					local face = awm.UnitFacing(Boss)
					local tarx,tary,tarz = awm.ObjectPosition(Boss)
					if tarz >= 13 then
						if Mob1 and not CastingBarFrame:IsVisible() then
							awm.CastSpellByName(rs["火球术(等级 1)"],Mob1)
							return
						end

						if Mob2 and not CastingBarFrame:IsVisible() then
							awm.CastSpellByName(rs["火球术(等级 1)"],Mob2)
							return
						end
					end
				end


				return
			end

			if Dungeon_move == 39 then -- 等怪 顺便引怪
			    local Monster = Combat_Scan()
			    if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(-21.28,-379.91,tarz,tarx,tary,tarz)
						if distance < 12 then
						    awm.SpellStopCasting()
							awm.SpellStopTargeting()
						    Dungeon_move = 40
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end

					-- 扫描 boss

					local Boss = nil
					local Mob1 = nil -- 要引的怪物群1
					local Mob2 = nil -- 要引的怪物群2
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						if guid == 17941 then
							Boss = ThisUnit
						end

						if awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						    Mob1 = ThisUnit
						end

						if awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						    Mob1 = ThisUnit
						end
					end

					if not Mob1 and not Mob2 then
					    Attracted_Mobs = true
					end

					if Boss then
						local face = awm.UnitFacing(Boss)
						local tarx,tary,tarz = awm.ObjectPosition(Boss)
						if tarz >= 13 then
							if Mob1 and not CastingBarFrame:IsVisible() then
							    awm.CastSpellByName(rs["火球术(等级 1)"],Mob1)
								return
							end

							if Mob2 and not CastingBarFrame:IsVisible() then
							    awm.CastSpellByName(rs["火球术(等级 1)"],Mob2)
								return
							end
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end

			if Dungeon_move == 47 then -- 扫描怪物距离

			    for i = 1,#Monster do
				    local ThisUnit = Monster[i]
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")					
					if distance <= 15 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 5 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
				return
			end

			if Dungeon_move == 50 or Dungeon_move == 53 or Dungeon_move == 64 then -- 跳台子
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			if Dungeon_move == 51 or Dungeon_move == 66 then -- 等待
			    if Dungeon_move == 66 and Spell_Castable(rs["寒冰屏障"]) then
				    awm.CastSpellByName(rs["寒冰屏障"])
				end
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and (Dungeon_move ~= 51 or tarz >= 4) then
					    awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
					if distance <= 25 and tarz >= 4 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 22 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 55 and Attracted_Mobs then
						    Dungeon_move = 67
							return
						else
						    Dungeon_move = Dungeon_move + 1
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 52 then -- 扫描怪物距离
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 2.2 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 53
						return
					end
				end
			    
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					if guid == 17941 then
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = 55
				else
				    local face = awm.UnitFacing(target)
					local tarx,tary,tarz = awm.ObjectPosition(target)
					if face > 6 and tarz <= 13 then
					    Dungeon_move = 55
					end
				end
				return
			end

			if Dungeon_move == 54 then -- 等待
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and tarz >= 4 then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					elseif distance <= 10 and tarz >= 4 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 52
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 3 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 52
						return
					end
				end
				return
			end

			if Dungeon_move == 57 then -- 扫描怪物距离
			    Note_Set(Dungeon_move.." | "..#Monster)
				if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(55.42,-411.78,tarz,tarx,tary,tarz)
						local distance1 = awm.GetDistanceBetweenPositions(67.77,-415.16,tarz,tarx,tary,tarz)
					    if distance1 < 12 then
						    Dungeon_move = 59
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						elseif distance < 12 then
						    Dungeon_move = 58
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end


			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

	    local Path = 
		{
		{78.71,-382.63,3.03}, -- 1 等待怪物 55.42,-411.78,3.03 12码
		{78.71,-382.63,3.03}, -- 2 第一波 57.53,-410.19,3.03
		{78.71,-382.63,3.03}, -- 3 第二波 64.69,-413.33,3.03
		{78.71,-382.63,3.03}, -- 4 第三波 75.21,-417.54,3.03
		{82.85,-373.22,3.03}, -- 5
		{73.22,-338.022,3.03}, -- 6 闪现
		{73.22,-338.022,3.03}, -- 7 跳台子
		{72.78,-336.04,6.11}, -- 8 等待20s -- 72.39,-336.74,6.11
		{87.78,-346.53,3.03}, -- 9
		{91.34,-376.84,3.03}, -- 10
		{78.71,-382.63,3.03}, -- 11 到达下雪位置
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.7 then
		    SP_Timer = false
			HasStop = false
			if Dungeon_move == 6 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 7 and Distance < 3 then
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			local Monster = Combat_Scan()
			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if distance < 8 then
					CheckProtection()
				end
			end

			awm.MoveTo(x,y,z)

			return 
		elseif Distance <= 0.7 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			local Monster = Combat_Scan()
			if Dungeon_move == 1 then -- 扫描怪物距离
			    Note_Set(Dungeon_move.." | "..#Monster)

				if not CheckBuff("player",rs["冰冷血脉"]) and Spell_Castable(rs["冰冷血脉"]) then
				    awm.CastSpellByName(rs["冰冷血脉"])
				end

				if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(55.42,-411.78,tarz,tarx,tary,tarz)
						local distance1 = awm.GetDistanceBetweenPositions(67.77,-415.16,tarz,tarx,tary,tarz)
						local distance2 = awm.GetDistanceBetweenPositions(75.21,-417.54,tarz,tarx,tary,tarz)
					    if distance2 < 12 then
						    Dungeon_move = 4
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						elseif distance1 < 12 then
						    Dungeon_move = 3
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						elseif distance < 12 then
						    Dungeon_move = 2
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    local target = nil
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							if guid == 17941 then
								target = ThisUnit
							end
						end
					end
					if target == nil then
						Dungeon_step1 = 6
					else
						local face = awm.UnitFacing(target)
						local tarx,tary,tarz = awm.ObjectPosition(target)
						if tarz >= 20 then
							Dungeon_step1 = 6
						end
					end
				end
				return
			end

			if Dungeon_move == 2 or Dungeon_move == 3 or Dungeon_move == 4 then -- 暴风雪
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				local Mage_Mob = false

				if Dungeon_move == 2 then
				    sx,sy,sz = 57.53,-410.19,3.03
					s_time = 5
				elseif Dungeon_move == 3 then
				    sx,sy,sz = 67.77,-415.16,3.03
					s_time = 7
				elseif Dungeon_move == 4 then
				    sx,sy,sz = 75.21,-417.54,3.03
					s_time = 7.5
				end

				local Mobs_Down = false
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local guid = awm.ObjectId(ThisUnit)

					if guid == 17961 then
					    Mage_Mob = true
					end

					if tarz <= 4 then
					    Mobs_Down = true
					end

					if distance < 8 then
						SP_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Spell_Castable(rs["冰霜新星"]) then
							awm.CastSpellByName(rs["冰霜新星"])
						end
						Dungeon_move = 5
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					end
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if Mage_Mob and not CastingBarFrame:IsVisible() then
				    if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
					    awm.CastSpellByName(rs["寒冰护体"],"player")
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 3000 and Is_Together(Monster) and Dungeon_move ~= 2 then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 5000 and Dungeon_move == 3 then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Dungeon_move == 4 and not Mobs_Down then
							awm.CastSpellByName(rs["暴风雪"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("使用","Cast ")..rs["暴风雪"])
							end
						else
							awm.CastSpellByName(rs["暴风雪(等级 1)"])
							if not log_Spell then
								log_Spell = true
								textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
							end
						end
					else
					    awm.ClickPosition(sx,sy,sz)
					end					
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 7 then
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			if Dungeon_move == 8 then
			    if not awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end

			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and not CastingBarFrame:IsVisible() then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 18 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
					if time <= 10 and awm.UnitPower("player") < 3000 and Spell_Castable(rs["唤醒"]) and not CastingBarFrame:IsVisible() then
					    awm.CastSpellByName(rs["唤醒"])
						return
					end
				end
				return
			end

			if Dungeon_move == 11 then
			    Dungeon_move = 1
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 6 then -- 拾取阶段
	    local body_list = Find_Body()
		if GetItemCount(Check_Client("裂纹的蚌壳","Jaggal Clam")) > 0 then
		    awm.UseItemByName(Check_Client("裂纹的蚌壳","Jaggal Clam"))
		end
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
		if #body_list > 0 then
		    
			if not Body_Choose then
				Body_Number = Body_Number + 1
				local number = math.random(1,3)
				if #body_list < 3 and #body_list > 1 then
					number = math.random(1,#body_list)
				elseif #body_list == 1 then
					number = 1
				end
				if number > #body_list then
					number = 1
					Body_Number = 1
				end
				Body_Target = body_list[number].Unit
				Body_Choose = true
				Body_Choose_Time = GetTime()
			else
				local time = GetTime() - Body_Choose_Time
				if time > 7 then
					Body_Choose = false
					Body_Target = nil
					return
				end
			end
			if Body_Target == nil or not awm.ObjectExists(Body_Target) then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local Found_it = false -- 看选择的尸体还在不在列表
			for i = 1,#body_list do
				if body_list[i].Unit == Body_Target then
					Found_it = true
				end
			end
			if not Found_it then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local distance1 = awm.GetDistanceBetweenObjects("player",Body_Target)
			local x,y,z = awm.ObjectPosition(Body_Target)
			if distance1 >= 5 then
				if Mount_useble then
					Mount_useble = false
					C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
				end
				Run(x,y,z)
				Interact_Step = false
				Open_Slot = false
			else
				if not Open_Slot then
					Open_Slot = true
					Open_Slot_Time = GetTime()
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							local number = math.random(1,#body_list)
							Body_Choose = true
							Body_Target = body_list[number].Unit
						end
						CloseLoot()
						LootFrame_Close()
						return
					end
					awm.InteractUnit(Body_Target)
				else
					local time = GetTime() - Open_Slot_Time
					local Interval = tonumber(Easy_Data["拾取间隔"])
					if Interval == nil then
						Interval = 0.5
					end
					if time > Interval then
						Open_Slot = false
					end
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							Body_Choose = false
							Body_Target = nil
							CloseLoot()
							LootFrame_Close()
							return
						end
						for i = 1,GetNumLootItems() do
							LootSlot(i)
							ConfirmLootSlot(i)
						end
					end
				end
			end
	    else
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
	elseif Dungeon_step1 == 7 then -- 出本到门神
	    Note_Head = Check_UI("出本到门神","Go out dungeon Phase 1")

		local Path = 
		{
		{98.73,-411.45,3.03}, -- 开箱子
		{111.47,-379.19,3.03},
		{111.27,-350.35,3.03},
		{111.08,-323.09,3.03},
		{88.25,-319.89,3.03}, -- 开箱子
		{69.69,-321.00,3.04},
		{-8.58,-301.57,2.94},
		}
		if Dungeon_move > #Path then
		    if not Easy_Data["围栏采药"] and not Easy_Data["围栏采矿"] then
		        Dungeon_step1 = 8
			else
			    Dungeon_step1 = 9
			end
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			
			awm.MoveTo(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 1 then
			    local target = Find_Object_Position(184933,134.58,-446.51,3.03,5)
				local target1 = Find_Object_Position(17940,134.58,-446.51,3.03,15)
				if target ~= nil and target1 == nil then
				    Dungeon_step1 = 21
					return
				end
			end
			
			if Dungeon_move == 1 then
			    if not MakingDrinkOrEat() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
			    if not CheckUse() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
				end
				Dungeon_move = Dungeon_move + 1
			    return
			end

			if Dungeon_move == 5 then
			    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
				local target1 = Find_Object_Position(17940,135.59,-304.62,3.03,15)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				elseif target ~= nil and target1 == nil then
				    Dungeon_step1 = 20
				elseif target1 ~= nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 8 then -- 出本到门口
	    Note_Head = Check_UI("出本到门口","Go out dungeon Phase 2")

		Reset_Instance = true

		local Path = 
		{
		{-9.91,-282.48,-0.89},
		{-11.79,-255.58,-1.20},
		{-13.65,-228.94,-1.59},
		{-15.44,-203.34,-1.59},
		{-16.44,-188.99,-1.57},
		{-29.18,-173.37,-1.59},
		{-41.63,-166.69,-1.47},
		{-45.09,-154.85,-1.58},
		{-58.04,-135.75,-1.58},
		{-69.03,-131.55,-1.59},
		{-84.30,-126.44,-1.51},
		{-87.44,-118.06,-1.78},
		{-88.16,-105.80,-4.89},
		{-100.72,-58.97,-2.43},
		{-112.73,-16.37,-8.54},
		{-91.56,-6.80,-7.80},
		{-78.13,-6.11,-7.46},
		{-79.82,5.36,-5.01},
		{-68.94,15.21,-1.92},
		{-54.13,19.49,-1.59},
		{-47.06,21.11,-1.39},
		{-34.08,26.67,0.99},
		{-23.50,25.08,2.56},
		{-16.15,19.29,3.37},
		{3.37,-13.13,-1.47},
		{8.22,-33.05,-2.10},
		{62.13,-63.96,-2.77},
		{111.52,-92.45,-1.59},
		{122.57,-105.59,-1.59},
		{122.75,-125.88,-0.72},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			
			if (Dungeon_move == 27 or Dungeon_move == 28) and IsFacing(x,y,Pz) and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(1.5,function() Interact_Step = false end)
			    awm.JumpOrAscendStart()
			end

			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if Dungeon_move == 27 or Dungeon_move == 28 then
			    awm.AscendStop()
			end

		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 6 then
			    local target = Find_Object_Position(17961,-48.23,-166.59,-1.48,30)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 23 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 9 then -- 采集
	    Note_Head = Check_UI("双采","Mining and Herbalism")

		Reset_Instance = true

		local Path = 
		{
			{-14.54,-310.31,2.53},
			{-22.88,-324.64,-1.57},
			{-15.52,-327.92,-1.58},
			{-41.61,-328.49,-1.58},
			{-71.42,-314.72,-1.49},
			{-95.73,-320.61,-1.59},
			{-110.10,-317.16,-1.58},
			{-138.17,-305.09,-0.62},
			{-148.54,-280.47,-1.58},
			{-151.02,-267.22,-1.59},
			{-146.65,-255.57,-1.59},
			{-155.46,-278.88,-1.58},
			{-141.47,-279.57,-1.59},
			{-130.21,-273.45,-1.59},
			{-123.97,-281.95,-1.59},
			{-128.07,-307.63,-1.39},
			{-105.70,-319.32,-1.59},
			{-71.91,-327.56,-1.56},
			{-46.57,-327.44,-1.58},
			{-23.48,-327.97,-1.59},
			{-14.77,-301.38,2.34},
			{-10.30,-280.59,-0.76},
			{-6.50,-268.03,-0.42},
			{-13.46,-255.50,-1.33},
			{-20.17,-243.31,-2.06},
			{-21.03,-219.86,-2.25},
			{-21.44,-206.95,-1.77},
			{-1.73,-187.94,-1.56},
			{-19.76,-175.02,-1.59},
			{-34.85,-167.70,-1.59},
			{-39.85,-165.07,-1.50},
			{-58.20,-135.51,-1.58},
			{-58.78,-151.83,-1.43},
			{-58.71,-135.10,-1.58},
			{-71.30,-130.60,-1.59},
			{-81.53,-127.91,-1.59},
			{-84.02,-125.88,-1.53},
			{-86.71,-120.80,-1.92},
			{-104.22,-123.91,-2.15},
			{-100.10,-101.21,-4.46},
			{-102.73,-69.06,-3.20},
			{-116.16,-27.34,-6.38},
			{-108.27,-6.19,-8.84},
			{-92.39,3.06,-6.15},
			{-81.43,5.31,-5.26},
			{-70.27,8.89,-2.90},
			{-62.73,16.97,-1.59},
			{-58.39,15.09,-1.59},
			{-48.26,20.90,-1.59},
			{-30.08,28.25,1.72},
			{-25.23,26.45,2.37},
			{-19.08,21.61,3.05},
			{3.80,2.20,-0.40},
			{4.74,-4.35,-1.30},
			{-4.42,-3.98,-1.23},
			{1.28,-20.34,-1.70},
			{-9.80,-45.35,-2.55},
			{-9.90,-69.16,-1.59},
			{17.19,-69.33,-1.59},
			{54.26,-91.94,-2.87},
			{57.33,-77.51,-2.59},
			{99.07,-85.14,-2.18},
			{120.69,-111.13,-0.70},
			{121.20,-125.18,-0.26},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 39 then
			    local target = Find_Object_Position(21128,-119.63,-142.53,-2.32,30)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if Dungeon_move == 3 or Dungeon_move == 5 or Dungeon_move == 7 or Dungeon_move == 11 or Dungeon_move == 14 or Dungeon_move == 23 or Dungeon_move == 28 or Dungeon_move == 33 or Dungeon_move == 39 or Dungeon_move == 43 or Dungeon_move == 48 or Dungeon_move == 55 or Dungeon_move == 58 or Dungeon_move == 61 then
			    local S = {}
				if Dungeon_move == 3 then
				    S.x,S.y,S.z = -15.10,-328.10,-1.58
				elseif Dungeon_move == 5 then
				    S.x,S.y,S.z = -71.61,-314.31,-1.48
				elseif Dungeon_move == 7 then
				    S.x,S.y,S.z = -110.10,-317.16,-1.58
				elseif Dungeon_move == 11 then
				    S.x,S.y,S.z = -146.68,-255.88,-1.58
				elseif Dungeon_move == 14 then
				    S.x,S.y,S.z = -130.50,-273.60,-1.58
				elseif Dungeon_move == 23 then
				    S.x,S.y,S.z = -6.49,-268.13,-0.4
				elseif Dungeon_move == 28 then
				    S.x,S.y,S.z = 0.00,-186.66,-1.55
				elseif Dungeon_move == 33 then
				    S.x,S.y,S.z = -58.80,-152.35,-1.42
				elseif Dungeon_move == 39 then
				    S.x,S.y,S.z = -136.80,-128.96,-1.69
				elseif Dungeon_move == 43 then
				    S.x,S.y,S.z = -108.11,-5.77,-8.77
				elseif Dungeon_move == 48 then
				    S.x,S.y,S.z = -55.62,13.89,-1.58
				elseif Dungeon_move == 55 then
				    S.x,S.y,S.z = -8.01,-3.30,-1.21
				elseif Dungeon_move == 58 then
				    S.x,S.y,S.z = -9.61,-69.09,-1.58
				elseif Dungeon_move == 61 then
				    S.x,S.y,S.z = 57.38,-76.99,-2.58
				end

				Target_Item = nil
				local target = Find_Game_Obj(S.x,S.y,S.z,15)
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

			if Dungeon_move == 29 or Dungeon_move == 32 then
			    local target = Find_Object_Position(17961,-58.80,-152.35,-1.42,40)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 9 or Dungeon_move == 12 then
			    local target = Find_Object_Position(17957,-48.75,-262.20,-0.89,20)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 52 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 10 then -- 准备出本
	    local x,y,z = 122,-122,0
		local distance = awm.GetDistanceBetweenPositions(x,y,z,Px,Py,Pz)
		if distance > 2 then
		    if Mount_useble then
				Mount_useble = false
				C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
			end
			Run(x,y,z)
		else
		    Dungeon_step1 = 1
			Dungeon_move = 1
			Dungeon_step = 2
			return
		end
	elseif Dungeon_step1 == 20 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
		if target == nil then
		    Dungeon_step1 = 7
			Dungeon_move = 5
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 21 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,134.58,-446.51,3.03,5)
		if target == nil then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 30 then -- 双采步骤
		if not awm.ObjectExists(Target_Item) then
			Dungeon_step1 = 9
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
			    Run(x,y,z)
			end
		end
	end
end

function SP_30_Wall()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end
	if not CheckBuff("player","精神错乱") and not CheckBuff("player","Flip Out") and not CheckBuff("player","呀啊啊啊啊") and not CheckBuff("player","Yaaarrrr") then
	    if Easy_Data["使用风蛇"] then
		    if GetItemCount("美味风蛇") > 0 then
			    awm.UseItemByName("美味风蛇")
				textout("使用物品 - 美味风蛇")
			elseif GetItemCount("Savory Deviate Delight") > 0 then
			    awm.UseItemByName("Savory Deviate Delight")
				textout("Use item - Savory Deviate Delight")
			end
		end
	end

	if Dungeon_step1 == 4 and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["寒冰屏障"]) then
	    awm.CastSpellByName(rs["寒冰屏障"])
	end
	if CheckBuff("player",rs["寒冰屏障"]) then
		awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
	end

	if Dungeon_step1 >= 4 then
	    if not CastingBarFrame:IsVisible() then
		    UseItem()
		end
	end

	if Dungeon_step1 == 5 then
	    if not CastingBarFrame:IsVisible() then
			if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				awm.CastSpellByName(rs["法师魔甲术"],"player")
			end
		end
	end


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

		local path = {{129.82,-126.43,-1.59}}
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
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = 121.16, -129.47,Pz
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往副本门口, 距离 = ","Go the door")..math.floor(distance))
		if distance > 1 then
		    if CheckBuff("player",rs["奥术智慧"]) then
			    awm.RunMacroText("/cancelAura "..rs["奥术智慧"])
			    return
			end
			if CheckBuff("player",rs["冰甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["冰甲术"])
				return
			end
			if CheckBuff("player",rs["法师魔甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["法师魔甲术"])
				return
			end
			if CheckBuff("player",rs["魔法抑制"]) then
				awm.RunMacroText("/cancelAura "..rs["魔法抑制"])
				return
			end
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	elseif Dungeon_step1 == 3 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
		if not awm.UnitAffectingCombat("player") then
		    if not MakingDrinkOrEat() then
	 	 	    Note_Set(Check_UI("做面包和水...","Making food and drink..."))
				return
	 		end   
			if not NeedHeal() then
				Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 		return
	 		end
	 		if not CheckBuff("player",rs["奥术智慧"]) then
				Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Buff Adding..."))
			    awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 		return
	 		end
			if not CheckBuff("player",rs["冰甲术"]) then
			    Note_Set(rs["冰甲术"]..Check_UI("BUFF增加中...","Buff Adding"))
				awm.CastSpellByName(rs["冰甲术"])
	 	 		return
	 		end
			if not CheckUse() then
			    Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			    return
			end
			Dungeon_step1 = 4
		end
		HasStop = false
		Dungeon_step1 = 4
	elseif Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local Path = 
		{
		{129.99, -120.93, -1.59}, -- 1 等待龙虾位置
		{102.50, -95.21, -1.59},
		{75.43, -82.78, -2.95},
		{66.82, -84.21, -2.59}, -- 4 下雪 第一波龙虾
		{52.55, -70.64, -2.64},
		{28.86, -56.28, -2.99},
		{18.62, -46.40, -2.91}, -- 7 反制 第二波龙虾
		{0.98, -14.52, -1.52}, -- 8 闪现
		{1.76, 8.50, 1.71},
		{-9.18, 12.85, 3.52},
		{-21.04, 23.02, 2.82},
		{-35.09, 25.99, 0.78},
		{-47.37, 21.21, -1.43},
		{-65.57,15.32,-1.59},
		{-76.87,0.51,-5.33}, -- 15 冰环
		{-111.77,-15.98,-8.37}, -- 16 没奴隶冰环 有奴隶吹风
		{-107.77,-26.57,-3.91}, -- 17 没奴隶冰环 有奴隶吹风
		{-103.79,-47.04,-2.99}, -- 18 冰环
		{-92.78,-121.83,-2.00}, -- 19 闪现 下雪 -119.63,-142.53,-2.32
		{-84.67,-124.28,-1.54},
		{-79.61,-131.08,-1.58},
		{-68.37,-131.85,-1.59},
		{-60.15,-134.85,-1.59},
		{-39.31,-163.79,-1.57},
		{-28.93,-190.30,-2.55},
		{-20.02,-208.63,-1.67}, -- 26 闪现
		{-22.34,-231.47,-2.40},
		{-10.80,-271.15,-0.84}, -- 28 反制
		{-7.83, -295.41, 2.89}, -- 29 冰环
		{-0.04,-297.96,3.03}, -- 30 急冷
		{2.98,-303.41,3.03}, -- 31 冰环
		{66.91,-322.28,3.04}, -- 32 闪现 下雪
		{90.57,-327.69,3.03}, -- 33 下雪
		{70.43,-342.37,3.04},
		{67.69,-342.85,3.04}, -- 35 调整角度 闪现
		{52.41,-346.04,6.13}, -- 36 修正方向, 拉技师110
		{52.41,-346.04,6.13}, -- 37 等待5s
		{32.87,-340.17,6.08},
		{9.77,-348.35,6.08}, -- 39 等待怪物 -21.28,-379.91,6.08
		{9.77,-348.35,6.08}, -- 40 下雪 -16.16,-370.42,6.08
		{33.56,-340.37,6.11},
		{40.54,-342.37,6.08}, -- 42 下雪 9.67,-349.10,6.08 7.5s
		{53.56,-346.52,6.08},
		{70.40,-340.65,6.08},
		{87.78,-346.53,3.03},
		{77.30,-331.96,3.03},
		{2.14,-320.44,3.03}, -- 47 到达下雪位置
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 5
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.9 then
		    SP_Timer = false

			if Dungeon_move == 8 or Dungeon_move == 19 or Dungeon_move == 26 or Dungeon_move == 32 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 45 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and Distance >= 35 then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 15 or Dungeon_move == 18 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    local target = nil
					local Monster1 = nil

					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
							local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
							if guid == 17957 and distance <= 10 then
							    target = ThisUnit
							end
							if guid == 17963
							and (awm.GetDistanceBetweenPositions(tarx,tary,tarz,-101,-14,-8) < 3 or awm.GetDistanceBetweenPositions(tarx,tary,tarz,-113,-8,-8) < 3) 
							then
							    Monster1 = ThisUnit
							end
						end
					end

					if target and not Monster1 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end
			if Dungeon_move == 16 or Dungeon_move == 17 then
			    local Monster = nil
				local Monster1 = nil
				local Monster2 = nil

			    local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
						if guid == 17957 and distance <= 10 then
							Monster = ThisUnit
							Monster1 = ThisUnit
						elseif guid == 17963 and distance <= 20 then
						    Monster2 = ThisUnit
						end
					end
				end

				if Monster ~= nil then				    
					local tarx,tary,tarz = awm.ObjectPosition(Monster)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
					if distance <= 8 and Monster2 == nil and Spell_Castable(rs["冰霜新星"]) then
						awm.CastSpellByName(rs["冰霜新星"])
					elseif distance <= 8 and Spell_Castable(rs["冰锥术(等级 1)"]) then
					    Try_Stop()
					    if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["冰锥术(等级 1)"])
						elseif not IsFacing(tarx,tary,tarz) then 
						    awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
						end
						return
					end
				elseif Monster1 ~= nil and Spell_Castable(rs["冰锥术(等级 1)"]) then
				    Try_Stop()
				    local tarx,tary,tarz = awm.ObjectPosition(Monster1)
					if IsFacing(tarx,tary,tarz) then
						awm.CastSpellByName(rs["冰锥术(等级 1)"])
					elseif not IsFacing(tarx,tary,tarz) then 
						awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
					end
					return
				end
			end
			if Dungeon_move == 35 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 47 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 45 and Dungeon_move <= 46 then
			    local Monster = Combat_Scan()
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz)
					local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz)
					local id = awm.ObjectId(ThisUnit)
					if id and id == 17940 and Spell_Castable(rs["法术反制"]) and tarz >= 4 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and distance_avoid > 5 and distance_avoid1 > 20 and awm.UnitTarget(ThisUnit) then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			awm.MoveTo(x,y,z)

			if Distance >= 7 then
				if Dungeon_move ~= 32 and Dungeon_move ~= 8 and Dungeon_move ~= 26 and Dungeon_move ~= 19 then
				    CheckProtection()
				end
			end

			if Dungeon_move == 41 and Pz <= 3.5 then
			    Dungeon_move = 45
				textout(Check_UI("你从台子掉落了,直接进行AOE","You fall from the stair, Start AOE directly"))
				return
			end

			if Dungeon_move == 41 then
			    if DoesSpellExist(rs["防护火焰结界"]) and not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				end
				return
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == 1 then
			    local target1 = Find_Object_Position({17816,17817},108.03,-98.82,-1.59,30)
				if not target1 then
				    Dungeon_move = 2
					textout(Check_UI("龙虾到位","Mobs2 on position"))
				end
				return
			end


			if Dungeon_move == 4 then -- 下雪
			    Try_Stop()
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},Px,Py,Pz)

				if awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end

				if not target1 then
				    Dungeon_step1 = 10
					Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
					textout(Check_UI("残本重置","Go out dungeon to reset"))
					return
				end
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance <= 36 then
					    if SP_Timer then
							local time = GetTime() - SP_Time
							if time >= 2 and not awm.UnitAffectingCombat("player") then
								SP_Timer = false
								awm.SpellStopCasting()
								Target_Monster = nil
								return
							end
						end

						if not CastingBarFrame:IsVisible() then
							if not awm.IsAoEPending() then
								awm.CastSpellByName(rs["暴风雪(等级 1)"])
							else
								awm.ClickPosition(tarx, tary, tarz)
							end
						else
							if not SP_Timer then
								SP_Timer = true
								SP_Time = GetTime()
							end
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 7 then -- 反制
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},19.02, -46.512, -2)
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance < 30 then
					    awm.CastSpellByName(rs["法术反制"],target1)
						Dungeon_move = Dungeon_move + 1
						awm.SpellStopCasting()
						return
					end
				end
				Dungeon_move = 8
				awm.SpellStopCasting()
				return
			end

			if Dungeon_move == 28 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 28 then
				    Target_ID = nil
					tarx,tary,tarz = 7.84,-256,0.85
					Scan_Distance = 8
				end
				if Target_Monster == nil then
				    Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
				else
				    awm.TargetUnit(Target_Monster)
					awm.CastSpellByName(rs["法术反制"])
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				end
				if Target_Monster == nil then
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
				end
				return
			end

			if Dungeon_move == 29 or Dungeon_move == 31 then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end
			if Dungeon_move == 30 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			if (Dungeon_move == 19 and Easy_Data["击杀医师"]) or Dungeon_move == 32 or Dungeon_move == 33 or Dungeon_move == 40 or Dungeon_move == 42 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 19 then
				    sx,sy,sz = -119.63,-142.53,-2.32
					s_time = 1.5
				elseif Dungeon_move == 32 then
				    sx,sy,sz = 33.88,-312.36,3.03
					s_time = 2.8
				elseif Dungeon_move == 33 then
				    sx,sy,sz = 119.08,-308.96,3.03
					s_time = 1.5
				elseif Dungeon_move == 40 then
				    sx,sy,sz = -16.16,-370.42,6.08
					s_time = 7.5
				elseif Dungeon_move == 42 then
				    sx,sy,sz = 9.67,-349.10,6.08
					s_time = 7.5
					for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if distance <= 8 then
						    if Spell_Castable(rs["冰霜新星"]) then
							    awm.CastSpellByName(rs["冰霜新星"])
							end
							SP_Timer = false
							awm.SpellStopCasting()
							Target_Monster = nil
							Dungeon_move = Dungeon_move + 1
							return
						end
					end
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
					else
					    awm.ClickPosition(sx,sy,sz)
					end
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 35 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 3.312) < 0.01 then -- 3.35
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(3.312)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end
			if Dungeon_move == 36 then
			    if not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				elseif CheckBuff("player",rs["防护火焰结界"]) then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 37 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 60
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(101.92,-340.67,3.03,x1,y1,z1)
						local distance1 = awm.GetDistanceBetweenPositions(91.16,-356.92,3.03,x1,y1,z1)
						local distance2 = awm.GetDistanceBetweenPositions(76.38,-361.47,3.03,x1,y1,z1)
						local distance3 = awm.GetDistanceBetweenPositions(64.73,-364.45,3.03,x1,y1,z1)
						local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,x1,y1,z1)
						local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,x1,y1,z1)
						local distance_avoid2 = awm.GetDistanceBetweenPositions(40.16,-389.70,3.03,x1,y1,z1)
						if guid and guid == 17940 and distance_avoid > 5 and distance_avoid1 > 20 and distance_avoid2 > 20 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
							if distance < Far_Distance then
								Far_Distance = distance
								target = ThisUnit
							end
							if distance1 < Far_Distance then
								Far_Distance = distance1
								target = ThisUnit
							end
							if distance2 < Far_Distance then
								Far_Distance = distance2
								target = ThisUnit
							end
							if distance3 < Far_Distance then
								Far_Distance = distance3
								target = ThisUnit
							end
						end
					end
				end

				if target ~= nil then
				    awm.TargetUnit(target)
				    if Spell_Castable(rs["法术反制"]) then
				        awm.CastSpellByName(rs["法术反制"],target)
					else
					    awm.CastSpellByName(rs["火球术(等级 1)"],target)
					end
				end
				if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time > 12 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
					end
				end
				return
			end

			if Dungeon_move == 39 then
			    local Monster = Combat_Scan()
			    if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(-21.28,-379.91,tarz,tarx,tary,tarz)
						if distance < 12 then
						    Dungeon_move = 40
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end

			if Dungeon_move == 47 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 5.9397) < 0.01 then
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(5.9397)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end


			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

	    local Path = 
		{
		{11.425,-323.249,5.96}, -- 1 到达位置
		{11.425,-323.249,5.96}, -- 2 开始调整高度到 5.19 以下
		{11.425,-323.249,5.96}, -- 3 扫描距离 开始调整
		{11.425,-323.249,5.96}, -- 4 向下退 测试位置
		{11.425,-323.249,5.96}, -- 5 向上走
		{11.425,-323.249,5.96}, -- 6 扫描距离
		{11.425,-323.249,5.96}, -- 7 下雪 40.67,-327.68,5.11
		{11.425,-323.249,5.96}, -- 8 向下退
		{11.425,-323.249,5.96}, -- 9 扫描位置 决定 10 或者 11
		{11.425,-323.249,5.96}, -- 10 下雪 40.67,-327.68,5.11 (回到 5 如果掉下去 9)
		{11.425,-323.249,5.96}, -- 11 唤醒或者等待
		{6.37,-320.45,3.03}, -- 12
		{2.14,-320.44,3.03}, -- 13 等待10秒
		{2.14,-320.44,3.03}, -- 14 闪现上墙
		}

		if Dungeon_move == 2 then
		    Note_Set(Check_UI("调整位置","Adjust position"))
		    local face = awm.UnitFacing("player")
			if math.abs(face - 5.4) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(5.4)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
			    if Pz > 5.27 then
					local standard_Time = 0.01

					if GetFramerate() < 60 then
					    standard_Time = 0.006
					end

					if GetFramerate() < 50 then
					    standard_Time = 0.003
					end

					if GetFramerate() < 40 then
					    standard_Time = 0.002
					end

					if GetFramerate() < 30 then
					    standard_Time = 0.001
					end

					if GetFramerate() < 20 then
					    standard_Time = 0
					end

					if not SP_Timer then
						SP_Timer = true
						awm.FaceDirection(5.4)
						awm.MoveBackwardStart()
						C_Timer.After(standard_Time,awm.MoveBackwardStop)
						C_Timer.After(0.25,function() 
							if SP_Timer and Dungeon_move == 2 then 
								SP_Timer = false 
							end 
						end)
					end
					return
				else
				    awm.MoveBackwardStop()
					SP_Timer = false
					Dungeon_move = Dungeon_move + 1
					return
				end
			end
			return
		end

		if Dungeon_move == 3 then -- 扫描怪物距离
		    if Pz <= 4 then
			    Dungeon_move = 12
				return
			end
		    Note_Set(Check_UI("等待怪物","Wait for monster"))
		    local Monster = Combat_Scan()
			if #Monster > 0 then
				Note_Set(Dungeon_move.." | "..#Monster)
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(51.09,-330.57,tarz,tarx,tary,tarz)
					local distance1 = awm.GetDistanceBetweenPositions(45.98,-325.75,tarz,tarx,tary,tarz)
					local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if (distance < 2 or distance1 <= 12 or distance2 < 36) and math.abs(2.9459 - awm.UnitFacing(ThisUnit)) < 0.2 then
						SP_Timer = false
						Dungeon_move = 4
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						return   
					end

					if distance2 <= 7 then
						SP_Timer = false
						Dungeon_move = 4
						textout(Check_UI("怪物太近 - "..awm.UnitFullName(ThisUnit)..", 躲避","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Avoid!"))
						return  
					end
				end
			else
				if not SP_Timer then
					SP_Timer = true
					SP_Time = GetTime()
				else
					local time = GetTime() - SP_Time

					Note_Set(Check_UI("等待进入拾取阶段 - ","Wait loot - ")..math.floor(5 - time))

					if time >= 5 then
						Dungeon_step1 = 6
						SP_Timer = false
					end
				end
			end
			return
		end

		if Dungeon_move == 4 or Dungeon_move == 8 then
		    Note_Set(Check_UI("向下移动","Move down"))

			local Angle = 5.5

			if Dungeon_move == 4 then
			    Angle = 5.81
			end

		    local Monster = Combat_Scan()

		    local face = awm.UnitFacing("player")

			if math.abs(face - Angle) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(Angle)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
			    local Success = true
			    for i = 1,#Monster do
				    local ThisUnit = Monster[i]
					local Monster_face = awm.UnitFacing(ThisUnit)
					if math.abs(Monster_face - 2.9459) < 0.2 and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
					    Success = false
					end
				end
			    if not Success then
				    local standard_Time = 0.01

					if Dungeon_move == 8 then
						if GetFramerate() > 60 then
							standard_Time = 0.012
						end

						if GetFramerate() <= 60 then
							standard_Time = 0.008
						end

						if GetFramerate() < 50 then
							standard_Time = 0.005
						end

						if GetFramerate() < 40 then
							standard_Time = 0.002
						end

						if GetFramerate() < 30 then
							standard_Time = 0.001
						end

						if GetFramerate() < 20 then
							standard_Time = 0
						end
					elseif Dungeon_move == 4 then
					    if GetFramerate() > 60 then
							standard_Time = 0.02
						end

						if GetFramerate() <= 60 then
							standard_Time = 0.01
						end

						if GetFramerate() < 50 then
							standard_Time = 0.007
						end

						if GetFramerate() < 40 then
							standard_Time = 0.005
						end

						if GetFramerate() < 30 then
							standard_Time = 0.003
						end

						if GetFramerate() < 20 then
							standard_Time = 0.002
						end
					end

					if not SP_Timer then
						SP_Timer = true
						awm.FaceDirection(Angle)
						awm.MoveBackwardStart()
						C_Timer.After(standard_Time,awm.MoveBackwardStop)
						C_Timer.After(0.5,function() 
							if SP_Timer and (Dungeon_move == 4 or Dungeon_move == 8) then 
								SP_Timer = false 
							end 
						end)
					end
					return
				else
				    awm.MoveBackwardStop()
					SP_Timer = false
					if Dungeon_move == 4 then
						Dungeon_move = 5
					elseif Dungeon_move == 8 then
					    Dungeon_move = 9 
					end
					return
				end
			end
			return
		end

		if Dungeon_move == 5 then -- 上走
		    Note_Set(Check_UI("向上移动","Move up"))

		    local Monster = Combat_Scan()

		    local face = awm.UnitFacing("player")

			if math.abs(face - 5.17) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(5.17)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
				if not SP_Timer then
					SP_Timer = true
					awm.FaceDirection(5.17)
					awm.MoveForwardStart()
					C_Timer.After(0.027,awm.MoveForwardStop)

					C_Timer.After(0.1,function() 
						SP_Timer = false
						Dungeon_move = 6
					end)
				end				
				return
			end
			return
		end

		if Dungeon_move == 6 then -- 扫描怪物距离
		    if Pz <= 4 then
			    Dungeon_move = 12
				return
			end
		   
		    Note_Set(Check_UI("等待怪物","Wait for monster"))
			local Monster = Combat_Scan()
			if #Monster > 0 then
				Note_Set(Dungeon_move.." | "..#Monster)
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(51.09,-330.57,tarz,tarx,tary,tarz)
					local distance1 = awm.GetDistanceBetweenPositions(45.98,-325.75,tarz,tarx,tary,tarz)
					local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if (distance < 2 or distance1 <= 12 or distance2 < 36) and math.abs(2.9459 - awm.UnitFacing(ThisUnit)) < 0.2 then
						SP_Timer = false
						if Pz >= 4 then
							Dungeon_move = 7
						else
						    Dungeon_move = 12
						end
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						return   
					end

					if distance2 <= 5 then
						SP_Timer = false
						Dungeon_move = 8
						textout(Check_UI("怪物太近 - "..awm.UnitFullName(ThisUnit)..", 躲避","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Avoid!"))
						return  
					end
				end
			else
				if not SP_Timer then
					SP_Timer = true
					SP_Time = GetTime()
				else
					local time = GetTime() - SP_Time

					Note_Set(Check_UI("等待进入拾取阶段 - ","Wait loot - ")..math.floor(5 - time))

					if time >= 5 then
						Dungeon_step1 = 6
						SP_Timer = false
					end
				end
			end
			return
		end

		if Dungeon_move == 7 then -- 暴风雪 
			
			local sx,sy,sz = 40.67,-327.68,5.11

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,sx,sy,sz) >= 36 then
			    Dungeon_move = 12
				return
			end

			if Race ~= "Gnome" and Race ~= "Dwarf" then
			    sx,sy,sz = 40.82,-325.45,5.11
			end

			local Monster = Combat_Scan()

			local s_time = 8
			Note_Set(Dungeon_move..Check_UI(", 敌人 = "..#Monster,", Enemy = "..#Monster))


			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
				local distance = awm.GetDistanceBetweenPositions(25.25,-325.98,tarz,tarx,tary,tarz)
				local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if distance < 4 then
					SP_Timer = false
					log_Spell = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = 8
					textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
					return
				elseif distance2 <= 14 then
					SP_Timer = false
					log_Spell = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = 8
					textout(Check_UI("距离靠近 - "..awm.UnitFullName(ThisUnit),"Mobs distance - "..awm.UnitFullName(ThisUnit)..", too close to me"))
					return
				end
			end
			if SP_Timer then
				local time = GetTime() - SP_Time
				if time >= s_time then
					SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					log_Spell = false
					Dungeon_move = 8
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
				if not awm.IsAoEPending()then
					if CheckBuff("player",rs["节能施法"]) then
						awm.CastSpellByName(rs["暴风雪"])

						if not log_Spell then
							log_Spell = true
							textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
						end
					elseif UnitPower("player") > 2500 and Is_Together2(Monster) then
						awm.CastSpellByName(rs["暴风雪"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("使用","Cast ")..rs["暴风雪"])
						end
					else
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
						end
					end
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				else
					awm.ClickPosition(sx,sy,sz)
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
			end
			return
		end

		if Dungeon_move == 9 then -- 决定程序
		    local Monster = Combat_Scan()
			SP_Timer = false
			if Is_Together2(Monster) and not (UnitPower("player") < 3000 and Spell_Castable(rs["唤醒"])) and UnitPower("player") > 1000 then
				Dungeon_move = 10
			else
				Dungeon_move = 11
			end
			return
		end

		if Dungeon_move == 10 then -- 暴风雪 
			
			local sx,sy,sz = 40.67,-327.68,5.11

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,sx,sy,sz) >= 36 then
			    Dungeon_move = 12
				return
			end

			if Race ~= "Gnome" and Race ~= "Dwarf" then
			    sx,sy,sz = 40.82,-325.45,5.11
			end

			local Monster = Combat_Scan()

			local s_time = 8
			Note_Set(Dungeon_move..Check_UI(", 敌人 = "..#Monster,", Enemy = "..#Monster))


			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
				local id = awm.ObjectId(ThisUnit)
				if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
					awm.TargetUnit(ThisUnit)
					awm.CastSpellByName(rs["法术反制"],ThisUnit)
					awm.CastSpellByName(rs["防护火焰结界"])
				end
			end

			if SP_Timer then
				local time = GetTime() - SP_Time
				if time >= s_time then
					SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					log_Spell = false
					if Pz <= 4 then
					    Dungeon_move = 12
					else
						Dungeon_move = 5
					end
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
				if not awm.IsAoEPending()then
					if CheckBuff("player",rs["节能施法"]) then
						awm.CastSpellByName(rs["暴风雪"])

						if not log_Spell then
							log_Spell = true
							textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
						end
					elseif UnitPower("player") > 2500 and Is_Together2(Monster) then
						awm.CastSpellByName(rs["暴风雪"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("使用","Cast ")..rs["暴风雪"])
						end
					else
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
						end
					end
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				else
					awm.ClickPosition(sx,sy,sz)
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
			end
			return
		end

		if Dungeon_move == 11 then
		    local Monster = Combat_Scan()

			local left_time = 6.5
			if not SP_Timer then
				SP_Timer = true
				SP_Time = GetTime()
			else
				if GetTime() - SP_Time > left_time and not CastingBarFrame:IsVisible() then
					    
					SP_Timer = false
					if Pz <= 4 then
					    Dungeon_move = 12
					else
						Dungeon_move = 5
					end
					return
				end
			end
			if UnitPower("player") <= 3000 and Spell_Castable(rs["唤醒"]) and not CastingBarFrame:IsVisible() then
				awm.CastSpellByName(rs["唤醒"])
				return
			end

			if not CastingBarFrame:IsVisible() then
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					elseif id == 17961 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			return
		end


		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.7 then
		    SP_Timer = false
			HasStop = false

			if Dungeon_move == 14 then
			    if Pz >= 4 then
					Dungeon_move = 1
					return
				end
				return
			end

			awm.MoveTo(x,y,z)

			return 
		elseif Distance <= 0.7 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			local Monster = Combat_Scan()

			if Dungeon_move == 13 then -- 等待10秒
			    local face = awm.UnitFacing("player")
			    if math.abs(face - 5.8897) > 0.01 and awm.GetUnitMovementFlags("player") == 0 then
					if not Interact_Step then
					    Try_Stop()
						Interact_Step = true
					    awm.FaceDirection(5.8897)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				end
			    if not CastingBarFrame:IsVisible() then
					for i = 1,#Monster do
						local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
						local id = awm.ObjectId(ThisUnit)
						if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						    awm.TargetUnit(ThisUnit)
						    awm.CastSpellByName(rs["法术反制"],ThisUnit)
							awm.CastSpellByName(rs["寒冰护体"])
						elseif id == 17961 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						    awm.TargetUnit(ThisUnit)
						    awm.CastSpellByName(rs["法术反制"],ThisUnit)
							awm.CastSpellByName(rs["寒冰护体"])
						end
					end
				end

			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 10 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
				return
			end

			if Dungeon_move == 14 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 5.8897) < 0.01 then -- 5.9397
					    if Spell_Castable(rs["闪现术"]) then
					        awm.CastSpellByName(rs["闪现术"])
						end
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(5.8897)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 6 then -- 拾取阶段
	    local body_list = Find_Body()
		if GetItemCount(Check_Client("裂纹的蚌壳","Jaggal Clam")) > 0 then
		    awm.UseItemByName(Check_Client("裂纹的蚌壳","Jaggal Clam"))
		end
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
		if #body_list > 0 then
			if not Body_Choose then
				Body_Number = Body_Number + 1
				local number = math.random(1,3)
				if #body_list < 3 and #body_list > 1 then
					number = math.random(1,#body_list)
				elseif #body_list == 1 then
					number = 1
				end
				if number > #body_list then
					number = 1
					Body_Number = 1
				end
				Body_Target = body_list[number].Unit
				Body_Choose = true
				Body_Choose_Time = GetTime()
			else
				local time = GetTime() - Body_Choose_Time
				if time > 7 then
					Body_Choose = false
					Body_Target = nil
					return
				end
			end
			if Body_Target == nil or not awm.ObjectExists(Body_Target) then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local Found_it = false -- 看选择的尸体还在不在列表
			for i = 1,#body_list do
				if body_list[i].Unit == Body_Target then
					Found_it = true
				end
			end
			if not Found_it then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local distance1 = awm.GetDistanceBetweenObjects("player",Body_Target)
			local x,y,z = awm.ObjectPosition(Body_Target)
			if distance1 >= 5 then
				if Mount_useble then
					Mount_useble = false
					C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
				end
				Run(x,y,z)
				Interact_Step = false
				Open_Slot = false
			else
				if not Open_Slot then
					Open_Slot = true
					Open_Slot_Time = GetTime()
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							local number = math.random(1,#body_list)
							Body_Choose = true
							Body_Target = body_list[number].Unit
						end
						CloseLoot()
						LootFrame_Close()
						return
					end
					awm.InteractUnit(Body_Target)
				else
					local time = GetTime() - Open_Slot_Time
					local Interval = tonumber(Easy_Data["拾取间隔"])
					if Interval == nil then
						Interval = 0.5
					end
					if time > Interval then
						Open_Slot = false
					end
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							Body_Choose = false
							Body_Target = nil
							CloseLoot()
							LootFrame_Close()
							return
						end
						for i = 1,GetNumLootItems() do
							LootSlot(i)
							ConfirmLootSlot(i)
						end
					end
				end
			end
	    else
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
	elseif Dungeon_step1 == 7 then -- 出本到门神
	    Note_Head = Check_UI("出本到门神","Go out dungeon Phase 1")

		local Path = 
		{
		{75.65,-325.63,3.04},
		{113.56,-329.02,3.04},
		{98.73,-411.45,3.03}, -- 开箱子
		{111.47,-379.19,3.03},
		{111.27,-350.35,3.03},
		{111.08,-323.09,3.03},
		{88.25,-319.89,3.03}, -- 开箱子
		{69.69,-321.00,3.04},
		{-8.58,-301.57,2.94},
		}
		if Dungeon_move > #Path then
		    if not Easy_Data["围栏采药"] and not Easy_Data["围栏采矿"] then
		        Dungeon_step1 = 8
			else
			    Dungeon_step1 = 9
			end
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			
			awm.MoveTo(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false
			
			if Dungeon_move == 1 then
			    if not MakingDrinkOrEat() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
			    if not CheckUse() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
				end
				Dungeon_move = Dungeon_move + 1
			    return
			end

			if Dungeon_move == 7 and CalculateTotalNumberOfFreeBagSlots() > 0 then
			    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
				local target1 = Find_Object_Position(17940,135.59,-304.62,3.03,15)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				elseif target ~= nil and target1 == nil then
				    Dungeon_step1 = 20
				elseif target1 ~= nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 8 then -- 出本到门口
	    Note_Head = Check_UI("出本到门口","Go out dungeon Phase 2")

		Reset_Instance = true

		local Path = 
		{
		{-9.91,-282.48,-0.89},
		{-11.79,-255.58,-1.20},
		{-13.65,-228.94,-1.59},
		{-15.44,-203.34,-1.59},
		{-16.44,-188.99,-1.57},
		{-29.18,-173.37,-1.59},
		{-41.63,-166.69,-1.47},
		{-45.09,-154.85,-1.58},
		{-58.04,-135.75,-1.58},
		{-69.03,-131.55,-1.59},
		{-84.30,-126.44,-1.51},
		{-87.44,-118.06,-1.78},
		{-88.16,-105.80,-4.89},
		{-100.72,-58.97,-2.43},
		{-112.73,-16.37,-8.54},
		{-91.56,-6.80,-7.80},
		{-78.13,-6.11,-7.46},
		{-79.82,5.36,-5.01},
		{-68.94,15.21,-1.92},
		{-54.13,19.49,-1.59},
		{-47.06,21.11,-1.39},
		{-34.08,26.67,0.99},
		{-23.50,25.08,2.56},
		{-16.15,19.29,3.37},
		{3.37,-13.13,-1.47},
		{8.22,-33.05,-2.10},
		{62.13,-63.96,-2.77},
		{111.52,-92.45,-1.59},
		{122.57,-105.59,-1.59},
		{122.75,-125.88,-0.72},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false

			if (Dungeon_move == 27 or Dungeon_move == 28) and IsFacing(x,y,Pz) and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(1.5,function() Interact_Step = false end)
			    awm.JumpOrAscendStart()
			end
			
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if Dungeon_move == 27 or Dungeon_move == 28 then
			    awm.AscendStop()
			end

		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 6 then
			    local target = Find_Object_Position(17961,-48.23,-166.59,-1.48,30)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 23 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 9 then -- 采集
	    Reset_Instance = true

	    Note_Head = Check_UI("双采","Mining and Herbalism")
		local Path = 
		{
			{-14.54,-310.31,2.53},
			{-22.88,-324.64,-1.57},
			{-15.52,-327.92,-1.58},
			{-41.61,-328.49,-1.58},
			{-71.42,-314.72,-1.49},
			{-95.73,-320.61,-1.59},
			{-110.10,-317.16,-1.58},
			{-138.17,-305.09,-0.62},
			{-148.54,-280.47,-1.58},
			{-151.02,-267.22,-1.59},
			{-146.65,-255.57,-1.59},
			{-155.46,-278.88,-1.58},
			{-141.47,-279.57,-1.59},
			{-130.21,-273.45,-1.59},
			{-123.97,-281.95,-1.59},
			{-128.07,-307.63,-1.39},
			{-105.70,-319.32,-1.59},
			{-71.91,-327.56,-1.56},
			{-46.57,-327.44,-1.58},
			{-23.48,-327.97,-1.59},
			{-14.77,-301.38,2.34},
			{-10.30,-280.59,-0.76},
			{-6.50,-268.03,-0.42},
			{-13.46,-255.50,-1.33},
			{-20.17,-243.31,-2.06},
			{-21.03,-219.86,-2.25},
			{-21.44,-206.95,-1.77},
			{-1.73,-187.94,-1.56},
			{-19.76,-175.02,-1.59},
			{-34.85,-167.70,-1.59},
			{-39.85,-165.07,-1.50},
			{-58.20,-135.51,-1.58},
			{-58.78,-151.83,-1.43},
			{-58.71,-135.10,-1.58},
			{-71.30,-130.60,-1.59},
			{-81.53,-127.91,-1.59},
			{-84.02,-125.88,-1.53},
			{-86.71,-120.80,-1.92},
			{-104.22,-123.91,-2.15},
			{-100.10,-101.21,-4.46},
			{-102.73,-69.06,-3.20},
			{-116.16,-27.34,-6.38},
			{-108.27,-6.19,-8.84},
			{-92.39,3.06,-6.15},
			{-81.43,5.31,-5.26},
			{-70.27,8.89,-2.90},
			{-62.73,16.97,-1.59},
			{-58.39,15.09,-1.59},
			{-48.26,20.90,-1.59},
			{-30.08,28.25,1.72},
			{-25.23,26.45,2.37},
			{-19.08,21.61,3.05},
			{3.80,2.20,-0.40},
			{4.74,-4.35,-1.30},
			{-4.42,-3.98,-1.23},
			{1.28,-20.34,-1.70},
			{-9.80,-45.35,-2.55},
			{-9.90,-69.16,-1.59},
			{17.19,-69.33,-1.59},
			{54.26,-91.94,-2.87},
			{57.33,-77.51,-2.59},
			{99.07,-85.14,-2.18},
			{120.69,-111.13,-0.70},
			{121.20,-125.18,-0.26},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 39 then
			    local target = Find_Object_Position(21128,-119.63,-142.53,-2.32,30)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if Dungeon_move == 3 or Dungeon_move == 5 or Dungeon_move == 7 or Dungeon_move == 11 or Dungeon_move == 14 or Dungeon_move == 23 or Dungeon_move == 28 or Dungeon_move == 33 or Dungeon_move == 39 or Dungeon_move == 43 or Dungeon_move == 48 or Dungeon_move == 55 or Dungeon_move == 58 or Dungeon_move == 61 then
			    local S = {}
				if Dungeon_move == 3 then
				    S.x,S.y,S.z = -15.10,-328.10,-1.58
				elseif Dungeon_move == 5 then
				    S.x,S.y,S.z = -71.61,-314.31,-1.48
				elseif Dungeon_move == 7 then
				    S.x,S.y,S.z = -110.10,-317.16,-1.58
				elseif Dungeon_move == 11 then
				    S.x,S.y,S.z = -146.68,-255.88,-1.58
				elseif Dungeon_move == 14 then
				    S.x,S.y,S.z = -130.50,-273.60,-1.58
				elseif Dungeon_move == 23 then
				    S.x,S.y,S.z = -6.49,-268.13,-0.4
				elseif Dungeon_move == 28 then
				    S.x,S.y,S.z = 0.00,-186.66,-1.55
				elseif Dungeon_move == 33 then
				    S.x,S.y,S.z = -58.80,-152.35,-1.42
				elseif Dungeon_move == 39 then
				    S.x,S.y,S.z = -136.80,-128.96,-1.69
				elseif Dungeon_move == 43 then
				    S.x,S.y,S.z = -108.11,-5.77,-8.77
				elseif Dungeon_move == 48 then
				    S.x,S.y,S.z = -55.62,13.89,-1.58
				elseif Dungeon_move == 55 then
				    S.x,S.y,S.z = -8.01,-3.30,-1.21
				elseif Dungeon_move == 58 then
				    S.x,S.y,S.z = -9.61,-69.09,-1.58
				elseif Dungeon_move == 61 then
				    S.x,S.y,S.z = 57.38,-76.99,-2.58
				end

				Target_Item = nil
				local target = Find_Game_Obj(S.x,S.y,S.z,15)
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

			if Dungeon_move == 29 or Dungeon_move == 32 then
			    local target = Find_Object_Position(17961,-58.80,-152.35,-1.42,40)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 9 or Dungeon_move == 12 then
			    local target = Find_Object_Position(17957,-48.75,-262.20,-0.89,20)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 52 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 10 then -- 准备出本
	    local x,y,z = 122,-122,0
		local distance = awm.GetDistanceBetweenPositions(x,y,z,Px,Py,Pz)
		if distance > 2 then
		    if Mount_useble then
				Mount_useble = false
				C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
			end
			Run(x,y,z)
		else
		    Dungeon_step1 = 1
			Dungeon_move = 1
			Dungeon_step = 2
			return
		end
	elseif Dungeon_step1 == 20 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
		if target == nil or CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 7
			Dungeon_move = 5
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 30 then -- 双采步骤
		if not awm.ObjectExists(Target_Item) then
			Dungeon_step1 = 9
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
			    Run(x,y,z)
			end
		end
	end
end

function SP_40_Wall()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end
	if not CheckBuff("player","精神错乱") and not CheckBuff("player","Flip Out") and not CheckBuff("player","呀啊啊啊啊") and not CheckBuff("player","Yaaarrrr") then
	    if Easy_Data["使用风蛇"] then
		    if GetItemCount("美味风蛇") > 0 then
			    awm.UseItemByName("美味风蛇")
				textout("使用物品 - 美味风蛇")
			elseif GetItemCount("Savory Deviate Delight") > 0 then
			    awm.UseItemByName("Savory Deviate Delight")
				textout("Use item - Savory Deviate Delight")
			end
		end
	end

	if Dungeon_step1 == 4 and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["寒冰屏障"]) then
	    awm.CastSpellByName(rs["寒冰屏障"])
	end
	if CheckBuff("player",rs["寒冰屏障"]) and not (Dungeon_move == 66 and Dungeon_step1 == 4) then
		awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
	end

	if Dungeon_step1 >= 4 then
	    if not CastingBarFrame:IsVisible() then
		    UseItem()
		end
	end

	if Dungeon_step1 == 5 then
	    frame:SetBackdropColor(0,0,0,0)
	    if not CastingBarFrame:IsVisible() then
			if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				awm.CastSpellByName(rs["法师魔甲术"],"player")
			end
		end
	end


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

		local path = {{129.82,-126.43,-1.59}}
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
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = 121.16, -129.47,Pz
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往副本门口, 距离 = ","Go the door")..math.floor(distance))
		if distance > 1 then
		    if CheckBuff("player",rs["奥术智慧"]) then
			    awm.RunMacroText("/cancelAura "..rs["奥术智慧"])
			    return
			end
			if CheckBuff("player",rs["冰甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["冰甲术"])
				return
			end
			if CheckBuff("player",rs["法师魔甲术"]) then
				awm.RunMacroText("/cancelAura "..rs["法师魔甲术"])
				return
			end
			if CheckBuff("player",rs["魔法抑制"]) then
				awm.RunMacroText("/cancelAura "..rs["魔法抑制"])
				return
			end
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	elseif Dungeon_step1 == 3 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
		if not awm.UnitAffectingCombat("player") then
		    if not MakingDrinkOrEat() then
	 	 	    Note_Set(Check_UI("做面包和水...","Making food and drink..."))
				return
	 		end   
			if not NeedHeal() then
				Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 		return
	 		end
	 		if not CheckBuff("player",rs["奥术智慧"]) then
				Note_Set(Check_UI(rs["奥术智慧"].." BUFF增加中...",rs["奥术智慧"].."Buff Adding..."))
			    awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 		return
	 		end
			if not CheckBuff("player",rs["冰甲术"]) then
			    Note_Set(rs["冰甲术"]..Check_UI("BUFF增加中...","Buff Adding"))
				awm.CastSpellByName(rs["冰甲术"])
	 	 		return
	 		end
			if not CheckUse() then
			    Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			    return
			end
			Dungeon_step1 = 4
		end
		HasStop = false
		Dungeon_step1 = 4
	elseif Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local Path = 
		{
		{129.99, -120.93, -1.59}, -- 1 等待龙虾位置
		{102.50, -95.21, -1.59},
		{75.43, -82.78, -2.95},
		{66.82, -84.21, -2.59}, -- 4 下雪 第一波龙虾
		{52.55, -70.64, -2.64},
		{28.86, -56.28, -2.99},
		{18.62, -46.40, -2.91}, -- 7 反制 第二波龙虾
		{0.98, -14.52, -1.52}, -- 8 闪现
		{1.76, 8.50, 1.71},
		{-9.18, 12.85, 3.52},
		{-21.04, 23.02, 2.82},
		{-35.09, 25.99, 0.78},
		{-47.37, 21.21, -1.43},
		{-65.57,15.32,-1.59},
		{-76.87,0.51,-5.33}, -- 15 冰环
		{-111.77,-15.98,-8.37}, -- 16 吹风
		{-113.001,-23.48,-6.39}, -- 17 吹风
		{-103.79,-47.04,-2.99}, -- 18 冰环
		{-92.78,-121.83,-2.00}, -- 19 闪现 下雪 -119.63,-142.53,-2.32
		{-84.67,-124.28,-1.54},
		{-79.61,-131.08,-1.58},
		{-68.37,-131.85,-1.59},
		{-60.15,-134.85,-1.59},
		{-39.31,-163.79,-1.57},
		{-28.93,-190.30,-2.55},
		{-20.02,-208.63,-1.67}, -- 26 闪现
		{-22.34,-231.47,-2.40},
		{-10.80,-271.15,-0.84}, -- 28 反制
		{-7.83, -295.41, 2.89}, -- 29 冰环
		{-0.04,-297.96,3.03}, -- 30 急冷
		{2.98,-303.41,3.03}, -- 31 冰环
		{66.91,-322.28,3.04}, -- 32 闪现 下雪
		{90.57,-327.69,3.03}, -- 33 下雪
		{70.43,-342.37,3.04},
		{67.69,-342.85,3.04}, -- 35 调整角度 闪现
		{52.41,-346.04,6.13}, -- 36 修正方向, 拉技师110
		{52.41,-346.04,6.13}, -- 37 等待5s
		{32.87,-340.17,6.08},
		{9.77,-348.35,6.08}, -- 39 等待怪物 -21.28,-379.91,6.08 -- 9.48,-348.57,6.08
		{9.77,-348.35,6.08}, -- 40 下雪 下雪位置 -16.16,-370.42,6.08
		{33.56,-340.37,6.11},
		{40.54,-342.37,6.08}, -- 42 下雪 下雪位置 9.67,-349.10,6.08 7.5s
		{53.56,-346.52,6.08},
		{70.40,-340.65,6.08},
		{87.78,-346.53,3.03},
		{91.34,-376.84,3.03},
		{107.52,-421.47,3.03}, -- 47 等待怪物到位
		{107.52,-421.47,3.03}, -- 48 下雪 126.43,-449.76,3.03
		{97.22,-353.46,3.03}, -- 49 闪现
		{73.70,-336.96,3.03}, -- 50 跳台子
		{72.78,-336.04,6.11}, -- 51 等待18s
		{76.47,-338.13,3.03}, -- 52 下台子 判断 boss 位置 成功到达55
		{73.70,-336.96,3.03}, -- 53 跳台子
		{72.78,-336.04,6.11}, -- 54 等待 3s 返回52
		{87.78,-346.53,3.03}, -- 55
		{91.34,-376.84,3.03}, -- 56
		{78.71,-382.63,3.03}, -- 57 到达下雪位置 等待怪物
		{78.71,-382.63,3.03}, -- 58 第一波 57.53,-410.19,3.03
		{78.71,-382.63,3.03}, -- 59 第二波 64.69,-413.33,3.03
		{91.34,-376.84,3.03}, -- 60 
		{85.98,-357.88,3.03}, -- 61 闪现
		{65.83,-357.52,3.03}, -- 62 下雪 39.16,-377.8,3.03
		{71.02,-352.27,3.03}, -- 63 反制 49.21,-365.61,3.03 ID = 17940
		{73.70,-336.96,3.03}, -- 64 跳台子
		{72.78,-336.04,6.11}, -- 65
		{71.90,-337.81,6.11}, -- 66 等待18s
		{87.78,-346.53,3.03}, -- 67
		{77.30,-331.96,3.03},
		{2.14,-320.44,3.03}, -- 69 到达下雪位置
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 5
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.8 then
		    SP_Timer = false

			if Dungeon_move == 8 or Dungeon_move == 19 or Dungeon_move == 26 or Dungeon_move == 32 or Dungeon_move == 49 or Dungeon_move == 61 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

			if Dungeon_move == 45 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and Distance >= 35 then
				    Interact_Step = true
				    C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			end

            if Dungeon_move == 15 or Dungeon_move == 18 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    local target = nil
					local Monster1 = nil

					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
							local guid = awm.ObjectId(ThisUnit)
							local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
							local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
							if guid == 17957 and distance <= 10 then
							    target = ThisUnit
							end
							if guid == 17963 and distance <= 20 then
							    Monster1 = ThisUnit
							end
						end
					end

					if target and not Monster1 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end
			if Dungeon_move == 16 or Dungeon_move == 17 then
			    local Monster = nil
				local Monster1 = nil
				local Monster2 = nil

			    local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
						if guid == 17957 and distance <= 10 then
							Monster = ThisUnit
							Monster1 = ThisUnit
						elseif guid == 17963 and distance <= 20 then
						    Monster2 = ThisUnit
						end
					end
				end

				if Monster ~= nil then				    
					local tarx,tary,tarz = awm.ObjectPosition(Monster)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,Px,Py,tarz)
					if distance <= 8 and Monster2 == nil and Spell_Castable(rs["冰霜新星"]) then
						awm.CastSpellByName(rs["冰霜新星"])
					elseif distance <= 8 and Spell_Castable(rs["冰锥术(等级 1)"]) then
					    Try_Stop()
					    if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["冰锥术(等级 1)"])
						elseif not IsFacing(tarx,tary,tarz) then 
						    awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
						end
						return
					end
				elseif Monster1 ~= nil and Spell_Castable(rs["冰锥术(等级 1)"]) then
				    Try_Stop()
				    local tarx,tary,tarz = awm.ObjectPosition(Monster1)
					if IsFacing(tarx,tary,tarz) then
						awm.CastSpellByName(rs["冰锥术(等级 1)"])
					elseif not IsFacing(tarx,tary,tarz) then 
						awm.FaceDirection(awm.GetAnglesBetweenPositions(Px,Py,Pz,tarx,tary,tarz))
					end
					return
				end
			end
			if Dungeon_move == 35 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 69 and Pz >= 4 then
			    Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 45 and Dungeon_move <= 46 then
			    local Monster = Combat_Scan()
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz)
					local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz)
					local id = awm.ObjectId(ThisUnit)
					if id and id == 17940 and Spell_Castable(rs["法术反制"]) and tarz >= 4 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and distance_avoid > 5 and distance_avoid1 > 20 and awm.UnitTarget(ThisUnit) then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			if (Dungeon_move == 50 or Dungeon_move == 53 or Dungeon_move == 64) and Distance < 1.2 then
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			awm.MoveTo(x,y,z)
			if Distance >= 7 then
				if Dungeon_move ~= 32 and Dungeon_move ~= 8 and Dungeon_move ~= 26 and Dungeon_move ~= 19 and Dungeon_move ~= 61 and Dungeon_move ~= 49 then
				    CheckProtection()
				end
			end

			if Dungeon_move == 41 and Pz <= 3.5 then
			    Dungeon_move = 50
				textout(Check_UI("你从台子掉落了,直接进行AOE","You fall from the stair, Start AOE directly"))
				return
			end

			if Dungeon_move == 41 then
			    if DoesSpellExist(rs["防护火焰结界"]) and not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				end
				return
			end

			if Dungeon_move == 64 and Spell_Castable(rs["冰霜新星"]) and Distance <= 4 then
			    awm.CastSpellByName(rs["冰霜新星"])
			end

			return 
		elseif Distance <= 0.8 then
			HasStop = false
			local Monster = Combat_Scan()

			if Dungeon_move == 1 then
			    local target1 = Find_Object_Position({17816,17817},108.03,-98.82,-1.59,30)
				if not target1 then
				    Dungeon_move = 2
					textout(Check_UI("龙虾到位","Mobs2 on position"))
				end
				return
			end


			if Dungeon_move == 4 then -- 下雪
			    Try_Stop()
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},Px,Py,Pz)

				if awm.UnitAffectingCombat("player") then
				    SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end

				if not target1 then
				    Dungeon_step1 = 10
					Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
					textout(Check_UI("残本重置","Go out dungeon to reset"))
					return
				end
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance <= 36 then
					    if SP_Timer then
							local time = GetTime() - SP_Time
							if time >= 2 and not awm.UnitAffectingCombat("player") then
								SP_Timer = false
								awm.SpellStopCasting()
								Target_Monster = nil
								return
							end
						end

						if not CastingBarFrame:IsVisible() then
							if not awm.IsAoEPending() then
								awm.CastSpellByName(rs["暴风雪(等级 1)"])
							else
								awm.ClickPosition(tarx, tary, tarz)
							end
						else
							if not SP_Timer then
								SP_Timer = true
								SP_Time = GetTime()
							end
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 7 then -- 反制
				local target1 = Find_Nearest_Uncombat_Object({17816,17817},19.02, -46.512, -2)
	   				
				if target1 then
				    local tarx, tary, tarz = awm.ObjectPosition(target1)
					local tar_distance = awm.GetDistanceBetweenPositions(tarx, tary, Pz, Px, Py, Pz)
					if tar_distance < 30 then
					    awm.CastSpellByName(rs["法术反制"],target1)
						Dungeon_move = Dungeon_move + 1
						awm.SpellStopCasting()
						return
					end
				end
				Dungeon_move = 8
				awm.SpellStopCasting()
				return
			end

			if Dungeon_move == 28 or Dungeon_move == 63 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 28 then
				    Target_ID = nil
					tarx,tary,tarz = 7.84,-256,0.85
					Scan_Distance = 8
				elseif Dungeon_move == 63 then
				    Target_ID = 17940
					tarx,tary,tarz = 49.21,-365.61,3.03
					Scan_Distance = 6
				end
				if Target_Monster == nil then
				    Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
				else
				    awm.TargetUnit(Target_Monster)
					awm.CastSpellByName(rs["法术反制"])
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				end
				if Target_Monster == nil then
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
				end
				return
			end

			if Dungeon_move == 29 or Dungeon_move == 31 then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end
			if Dungeon_move == 30 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			if (Dungeon_move == 19 and Easy_Data["击杀医师"]) or Dungeon_move == 32 or Dungeon_move == 33 or Dungeon_move == 40 or Dungeon_move == 42 or Dungeon_move == 48 or Dungeon_move == 58 or Dungeon_move == 59 or Dungeon_move == 62 then -- 暴风雪
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 19 then
				    sx,sy,sz = -119.63,-142.53,-2.32
					s_time = 1.5
				elseif Dungeon_move == 32 then
				    sx,sy,sz = 33.88,-312.36,3.03
					s_time = 2.8
				elseif Dungeon_move == 33 then
				    sx,sy,sz = 119.08,-308.96,3.03
					s_time = 1.5
				elseif Dungeon_move == 40 then
				    sx,sy,sz = -16.16,-370.42,6.08
					s_time = 7.5
				elseif Dungeon_move == 42 then
				    sx,sy,sz = 9.67,-349.10,6.08
					s_time = 7.5
					for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if distance <= 8 then
						    if Spell_Castable(rs["冰霜新星"]) then
							    awm.CastSpellByName(rs["冰霜新星"])
							end
							SP_Timer = false
							awm.SpellStopCasting()
							Target_Monster = nil
							Dungeon_move = Dungeon_move + 1
							return
						end
					end
				elseif Dungeon_move == 48 then
				    sx,sy,sz = 126.43,-449.76,3.03
					s_time = 1.5
				elseif Dungeon_move == 58 then
				    sx,sy,sz = 57.53,-410.19,3.03
					s_time = 5
				elseif Dungeon_move == 59 then
				    sx,sy,sz = 64.69,-413.33,3.03
					s_time = 4
				elseif Dungeon_move == 62 then
				    sx,sy,sz = 39.16,-377.8,3.03
					s_time = 1.5
				end

				if SP_Timer then
				    local time = GetTime() - SP_Time
					if time >= s_time then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
					else
					    awm.ClickPosition(sx,sy,sz)
					end
				else
				    if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 35 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 3.312) < 0.01 then -- 3.35 
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(3.312)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end
			if Dungeon_move == 36 then
			    if not CheckBuff("player",rs["防护火焰结界"]) and Spell_Castable(rs["防护火焰结界"]) then
			        awm.CastSpellByName(rs["防护火焰结界"],"player")
				elseif CheckBuff("player",rs["防护火焰结界"]) then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 37 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 60
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					if awm.ObjectExists(ThisUnit) and awm.ObjectIsUnit(ThisUnit) then
						local guid = awm.ObjectId(ThisUnit)
						local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenPositions(101.92,-340.67,3.03,x1,y1,z1)
						local distance1 = awm.GetDistanceBetweenPositions(91.16,-356.92,3.03,x1,y1,z1)
						local distance2 = awm.GetDistanceBetweenPositions(76.38,-361.47,3.03,x1,y1,z1)
						local distance3 = awm.GetDistanceBetweenPositions(64.73,-364.45,3.03,x1,y1,z1)
						local distance_avoid = awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,x1,y1,z1)
						local distance_avoid1 = awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,x1,y1,z1)
						local distance_avoid2 = awm.GetDistanceBetweenPositions(40.16,-389.70,3.03,x1,y1,z1)
						if guid and guid == 17940 and distance_avoid > 5 and distance_avoid1 > 20 and distance_avoid2 > 20 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
							if distance < Far_Distance then
								Far_Distance = distance
								target = ThisUnit
							end
							if distance1 < Far_Distance then
								Far_Distance = distance1
								target = ThisUnit
							end
							if distance2 < Far_Distance then
								Far_Distance = distance2
								target = ThisUnit
							end
							if distance3 < Far_Distance then
								Far_Distance = distance3
								target = ThisUnit
							end
						end
					end
				end

				if target then
				    awm.TargetUnit(target)
				    if Spell_Castable(rs["法术反制"]) then
				        awm.CastSpellByName(rs["法术反制"],target)
					else
					    awm.CastSpellByName(rs["火球术(等级 1)"],target)
					end
				end
				if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time > 12 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
					end
				end

				
				-- 扫描 boss

				local Boss = nil
				local Mob1 = nil -- 要引的怪物群1
				local Mob2 = nil -- 要引的怪物群2
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					if guid == 17941 then
						Boss = ThisUnit
					end

					if awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						Mob1 = ThisUnit
					end

					if awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						Mob1 = ThisUnit
					end
				end

				if not Mob1 and not Mob2 then
					Attracted_Mobs = true
				end

				if Boss then
					local face = awm.UnitFacing(Boss)
					local tarx,tary,tarz = awm.ObjectPosition(Boss)
					if tarz >= 13 then
						if Mob1 and not CastingBarFrame:IsVisible() then
							awm.CastSpellByName(rs["火球术(等级 1)"],Mob1)
							return
						end

						if Mob2 and not CastingBarFrame:IsVisible() then
							awm.CastSpellByName(rs["火球术(等级 1)"],Mob2)
							return
						end
					end
				end


				return
			end

			if Dungeon_move == 39 then -- 等怪 顺便引怪
			    local Monster = Combat_Scan()
			    if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(-21.28,-379.91,tarz,tarx,tary,tarz)
						if distance < 12 then
						    awm.SpellStopCasting()
							awm.SpellStopTargeting()
						    Dungeon_move = 40
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end

					-- 扫描 boss

					local Boss = nil
					local Mob1 = nil -- 要引的怪物群1
					local Mob2 = nil -- 要引的怪物群2
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local guid = awm.ObjectId(ThisUnit)
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						if guid == 17941 then
							Boss = ThisUnit
						end

						if awm.GetDistanceBetweenPositions(48.20,-365.89,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						    Mob1 = ThisUnit
						end

						if awm.GetDistanceBetweenPositions(36.57,-382.83,3.03,tarx,tary,tarz) <= 5 and not awm.UnitTarget(ThisUnit) and not awm.UnitAffectingCombat(ThisUnit) then
						    Mob1 = ThisUnit
						end
					end

					if not Mob1 and not Mob2 then
					    Attracted_Mobs = true
					end

					if Boss then
						local face = awm.UnitFacing(Boss)
						local tarx,tary,tarz = awm.ObjectPosition(Boss)
						if tarz >= 13 then
							if Mob1 and not CastingBarFrame:IsVisible() then
							    awm.CastSpellByName(rs["火球术(等级 1)"],Mob1)
								return
							end

							if Mob2 and not CastingBarFrame:IsVisible() then
							    awm.CastSpellByName(rs["火球术(等级 1)"],Mob2)
								return
							end
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end

			if Dungeon_move == 47 then -- 扫描怪物距离
			    for i = 1,#Monster do
				    local ThisUnit = Monster[i]
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")					
					if distance <= 15 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 5 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
				return
			end

			if Dungeon_move == 50 or Dungeon_move == 53 or Dungeon_move == 64 then -- 跳台子
			    if Pz >= 5.8 then
				    Try_Stop()
					Dungeon_move = Dungeon_move + 1
					return
				end


			    local face = awm.UnitFacing("player")
				if math.abs(face - 2.7166) > 0.01 then
					if not Interact_Step then
						Interact_Step = true
					    awm.FaceDirection(2.7166)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				else
				    if not HasStop then
					    HasStop = true
						C_Timer.After(0.5,function() 
							if HasStop then
							    Try_Stop()
								HasStop = false 
							end
						end)
						awm.MoveForwardStart()
						C_Timer.After(0.1,awm.JumpOrAscendStart)
						C_Timer.After(0.11,awm.MoveForwardStart)
						C_Timer.After(0.2,awm.MoveForwardStop)
					end
				end
				return
			end

			if Dungeon_move == 51 or Dungeon_move == 66 then -- 等待
			    if Dungeon_move == 66 and Spell_Castable(rs["寒冰屏障"]) then
				    awm.CastSpellByName(rs["寒冰屏障"])
				end
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and (Dungeon_move ~= 51 or tarz >= 4) then
					    awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
					if distance <= 25 and tarz >= 4 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					local Time_Strict = 22
					if Dungeon_move == 66 or Attracted_Mobs then
					    Time_Strict = 17
					end


					if time >= Time_Strict then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 55 and Attracted_Mobs then
						    Dungeon_move = 67
							return
						else
						    Dungeon_move = Dungeon_move + 1
						end
						return
					end
				end
				return
			end

			if Dungeon_move == 52 then -- 扫描怪物距离
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 2.2 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 53
						return
					end
				end
			    
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					if guid == 17941 then
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = 55
				else
				    local face = awm.UnitFacing(target)
					local tarx,tary,tarz = awm.ObjectPosition(target)
					if face > 6 and tarz <= 13 then
					    Dungeon_move = 55
					end
				end
				return
			end

			if Dungeon_move == 54 then -- 等待
			    for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 and distance <= 30 and Spell_Castable(rs["法术反制"]) and tarz >= 4 then
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					elseif distance <= 10 and tarz >= 4 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 52
						return
					end
				end
			    if GetUnitSpeed("player") > 0 then
				    Try_Stop()
					return
				end
			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 3 then
					    SP_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 52
						return
					end
				end
				return
			end

			if Dungeon_move == 57 then -- 扫描怪物距离
			    Note_Set(Dungeon_move.." | "..#Monster)
				if #Monster > 0 then
				    for i = 1,#Monster do
					    local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					    local distance = awm.GetDistanceBetweenPositions(55.42,-411.78,tarz,tarx,tary,tarz)
						local distance1 = awm.GetDistanceBetweenPositions(67.77,-415.16,tarz,tarx,tary,tarz)
					    if distance1 < 12 then
						    Dungeon_move = 59
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return  
						elseif distance < 12 then
						    Dungeon_move = 58
							textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						    return   
						end
					end
				else
				    Dungeon_step1 = 6
				end
				return
			end

			if Dungeon_move == 69 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 5.9397) < 0.01 then
					    awm.CastSpellByName(rs["闪现术"])
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(5.9397)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end


			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

	    local Path = 
		{
		{11.425,-323.249,5.96}, -- 1 到达位置
		{11.425,-323.249,5.96}, -- 2 开始调整高度到 5.19 以下
		{11.425,-323.249,5.96}, -- 3 扫描距离 开始调整
		{11.425,-323.249,5.96}, -- 4 向下退 测试位置
		{11.425,-323.249,5.96}, -- 5 向上走
		{11.425,-323.249,5.96}, -- 6 扫描距离
		{11.425,-323.249,5.96}, -- 7 下雪 40.67,-327.68,5.11
		{11.425,-323.249,5.96}, -- 8 向下退
		{11.425,-323.249,5.96}, -- 9 扫描位置 决定 10 或者 11
		{11.425,-323.249,5.96}, -- 10 下雪 40.67,-327.68,5.11 (回到 5 如果掉下去 9)
		{11.425,-323.249,5.96}, -- 11 唤醒或者等待
		{6.37,-320.45,3.03}, -- 12
		{2.14,-320.44,3.03}, -- 13 等待10秒
		{2.14,-320.44,3.03}, -- 14 闪现上墙
		}

		if Dungeon_move == 2 then
		    Note_Set(Check_UI("调整位置","Adjust position"))
		    local face = awm.UnitFacing("player")
			if math.abs(face - 5.4) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(5.4)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
			    if Pz > 5.27 then
					local standard_Time = 0.01

					if GetFramerate() < 60 then
					    standard_Time = 0.006
					end

					if GetFramerate() < 50 then
					    standard_Time = 0.003
					end

					if GetFramerate() < 40 then
					    standard_Time = 0.002
					end

					if GetFramerate() < 30 then
					    standard_Time = 0.001
					end

					if GetFramerate() < 20 then
					    standard_Time = 0
					end

					if not SP_Timer then
						SP_Timer = true
						awm.FaceDirection(5.4)
						awm.MoveBackwardStart()
						C_Timer.After(standard_Time,awm.MoveBackwardStop)
						C_Timer.After(0.25,function() 
							if SP_Timer and Dungeon_move == 2 then 
								SP_Timer = false 
							end 
						end)
					end
					return
				else
				    awm.MoveBackwardStop()
					SP_Timer = false
					Dungeon_move = Dungeon_move + 1
					return
				end
			end
			return
		end

		if Dungeon_move == 3 then -- 扫描怪物距离
		    if Pz <= 4 then
			    Dungeon_move = 12
				return
			end

		    Note_Set(Check_UI("等待怪物","Wait for monster"))
		    local Monster = Combat_Scan()
			if #Monster > 0 then
				Note_Set(Dungeon_move.." | "..#Monster)
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(51.09,-330.57,tarz,tarx,tary,tarz)
					local distance1 = awm.GetDistanceBetweenPositions(45.98,-325.75,tarz,tarx,tary,tarz)
					local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if (distance < 2 or distance1 <= 12 or distance2 < 36) and math.abs(2.9459 - awm.UnitFacing(ThisUnit)) < 0.2 then
						SP_Timer = false
						Dungeon_move = 4
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						return   
					end

					if distance2 <= 7 then
						SP_Timer = false
						Dungeon_move = 4
						textout(Check_UI("怪物太近 - "..awm.UnitFullName(ThisUnit)..", 躲避","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Avoid!"))
						return  
					end
				end
			else
				if not SP_Timer then
					SP_Timer = true
					SP_Time = GetTime()
				else
					local time = GetTime() - SP_Time

					Note_Set(Check_UI("等待进入拾取阶段 - ","Wait loot - ")..math.floor(5 - time))

					if time >= 5 then
						Dungeon_step1 = 6
						SP_Timer = false
					end
				end
			end
			return
		end

		if Dungeon_move == 4 or Dungeon_move == 8 then
		    Note_Set(Check_UI("向下移动","Move down"))

			local Angle = 5.5

			if Dungeon_move == 4 then
			    Angle = 5.81
			end

		    local Monster = Combat_Scan()

		    local face = awm.UnitFacing("player")

			if math.abs(face - Angle) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(Angle)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
			    local Success = true
			    for i = 1,#Monster do
				    local ThisUnit = Monster[i]
					local Monster_face = awm.UnitFacing(ThisUnit)
					if math.abs(Monster_face - 2.9459) < 0.2 and awm.GetUnitMovementFlags(ThisUnit) ~= 0 then
					    Success = false
					end
				end
			    if not Success then
				    local standard_Time = 0.01

					if Dungeon_move == 8 then
						if GetFramerate() > 60 then
							standard_Time = 0.012
						end

						if GetFramerate() <= 60 then
							standard_Time = 0.008
						end

						if GetFramerate() < 50 then
							standard_Time = 0.005
						end

						if GetFramerate() < 40 then
							standard_Time = 0.002
						end

						if GetFramerate() < 30 then
							standard_Time = 0.001
						end

						if GetFramerate() < 20 then
							standard_Time = 0
						end
					elseif Dungeon_move == 4 then
					    if GetFramerate() > 60 then
							standard_Time = 0.02
						end

						if GetFramerate() <= 60 then
							standard_Time = 0.01
						end

						if GetFramerate() < 50 then
							standard_Time = 0.007
						end

						if GetFramerate() < 40 then
							standard_Time = 0.005
						end

						if GetFramerate() < 30 then
							standard_Time = 0.003
						end

						if GetFramerate() < 20 then
							standard_Time = 0.002
						end
					end

					if not SP_Timer then
						SP_Timer = true
						awm.FaceDirection(Angle)
						awm.MoveBackwardStart()
						C_Timer.After(standard_Time,awm.MoveBackwardStop)
						C_Timer.After(0.5,function() 
							if SP_Timer and (Dungeon_move == 4 or Dungeon_move == 8) then 
								SP_Timer = false 
							end 
						end)
					end
					return
				else
				    awm.MoveBackwardStop()
					SP_Timer = false
					if Dungeon_move == 4 then
						Dungeon_move = 5
					elseif Dungeon_move == 8 then
					    Dungeon_move = 9 
					end
					return
				end
			end
			return
		end

		if Dungeon_move == 5 then -- 上走
		    Note_Set(Check_UI("向上移动","Move up"))

		    local Monster = Combat_Scan()

		    local face = awm.UnitFacing("player")

			if math.abs(face - 5.17) > 0.01 then
			    if not Interact_Step then
					Interact_Step = true
					awm.FaceDirection(5.17)
					C_Timer.After(0.1,function() Interact_Step = false end)
				end
				return
			else
				if not SP_Timer then
					SP_Timer = true
					awm.FaceDirection(5.17)
					awm.MoveForwardStart()
					C_Timer.After(0.027,awm.MoveForwardStop)

					C_Timer.After(0.1,function() 
						SP_Timer = false
						Dungeon_move = 6
					end)
				end				
				return
			end
			return
		end

		if Dungeon_move == 6 then -- 扫描怪物距离
		    if Pz <= 4 then
			    Dungeon_move = 12
				return
			end

		    Note_Set(Check_UI("等待怪物","Wait for monster"))
			local Monster = Combat_Scan()
			if #Monster > 0 then
				Note_Set(Dungeon_move.." | "..#Monster)
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(51.09,-330.57,tarz,tarx,tary,tarz)
					local distance1 = awm.GetDistanceBetweenPositions(45.98,-325.75,tarz,tarx,tary,tarz)
					local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
					if (distance < 2 or distance1 <= 12 or distance2 < 36) and math.abs(2.9459 - awm.UnitFacing(ThisUnit)) < 0.2 then
						SP_Timer = false
						if Pz >= 4 then
							Dungeon_move = 7
						else
						    Dungeon_move = 12
						end
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit)..", 开始下雪","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Cast!"))
						return   
					end

					if distance2 <= 5 then
						SP_Timer = false
						Dungeon_move = 8
						textout(Check_UI("怪物太近 - "..awm.UnitFullName(ThisUnit)..", 躲避","Mobs close to me - "..awm.UnitFullName(ThisUnit)..", Avoid!"))
						return  
					end
				end
			else
				if not SP_Timer then
					SP_Timer = true
					SP_Time = GetTime()
				else
					local time = GetTime() - SP_Time

					Note_Set(Check_UI("等待进入拾取阶段 - ","Wait loot - ")..math.floor(5 - time))

					if time >= 5 then
						Dungeon_step1 = 6
						SP_Timer = false
					end
				end
			end
			return
		end

		if Dungeon_move == 7 then -- 暴风雪 
			
			local sx,sy,sz = 40.67,-327.68,5.11

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,sx,sy,sz) >= 36 then
			    Dungeon_move = 12
				return
			end

			if Race ~= "Gnome" and Race ~= "Dwarf" then
			    sx,sy,sz = 40.82,-325.45,5.11
			end

			local Monster = Combat_Scan()

			local s_time = 8
			Note_Set(Dungeon_move..Check_UI(", 敌人 = "..#Monster,", Enemy = "..#Monster))


			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
				local distance = awm.GetDistanceBetweenPositions(25.25,-325.98,tarz,tarx,tary,tarz)
				local distance2 = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if distance < 4 then
					SP_Timer = false
					log_Spell = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = 8
					textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
					return
				elseif distance2 <= 14 then
					SP_Timer = false
					log_Spell = false
					awm.SpellStopCasting()
					Target_Monster = nil
					Dungeon_move = 8
					textout(Check_UI("距离靠近 - "..awm.UnitFullName(ThisUnit),"Mobs distance - "..awm.UnitFullName(ThisUnit)..", too close to me"))
					return
				end
			end
			if SP_Timer then
				local time = GetTime() - SP_Time
				if time >= s_time then
					SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					log_Spell = false
					Dungeon_move = 8
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
				if not awm.IsAoEPending()then
					if CheckBuff("player",rs["节能施法"]) then
						awm.CastSpellByName(rs["暴风雪"])

						if not log_Spell then
							log_Spell = true
							textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
						end
					elseif UnitPower("player") > 2500 and Is_Together2(Monster) then
						awm.CastSpellByName(rs["暴风雪"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("使用","Cast ")..rs["暴风雪"])
						end
					else
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
						end
					end
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				else
					awm.ClickPosition(sx,sy,sz)
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
			end
			return
		end

		if Dungeon_move == 9 then -- 决定程序
		    local Monster = Combat_Scan()
			SP_Timer = false
			if Is_Together2(Monster) and not (UnitPower("player") < 3000 and Spell_Castable(rs["唤醒"])) and UnitPower("player") > 1000 then
				Dungeon_move = 10
			else
				Dungeon_move = 11
			end
			return
		end

		if Dungeon_move == 10 then -- 暴风雪 
			
			local sx,sy,sz = 40.67,-327.68,5.11

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,sx,sy,sz) >= 36 then
			    Dungeon_move = 12
				return
			end

			if Race ~= "Gnome" and Race ~= "Dwarf" then
			    sx,sy,sz = 40.82,-325.45,5.11
			end

			local Monster = Combat_Scan()

			local s_time = 8
			Note_Set(Dungeon_move..Check_UI(", 敌人 = "..#Monster,", Enemy = "..#Monster))


			for i = 1,#Monster do
				local ThisUnit = Monster[i]
				local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
				local id = awm.ObjectId(ThisUnit)
				if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
					awm.TargetUnit(ThisUnit)
					awm.CastSpellByName(rs["法术反制"],ThisUnit)
					awm.CastSpellByName(rs["防护火焰结界"])
				end
			end

			if SP_Timer then
				local time = GetTime() - SP_Time
				if time >= s_time then
					SP_Timer = false
					awm.SpellStopCasting()
					Target_Monster = nil
					log_Spell = false
					if Pz <= 4 then
					    Dungeon_move = 12
					else
						Dungeon_move = 5
					end
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
				if not awm.IsAoEPending()then
					if CheckBuff("player",rs["节能施法"]) then
						awm.CastSpellByName(rs["暴风雪"])

						if not log_Spell then
							log_Spell = true
							textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
						end
					elseif UnitPower("player") > 2500 and Is_Together2(Monster) then
						awm.CastSpellByName(rs["暴风雪"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("使用","Cast ")..rs["暴风雪"])
						end
					else
					    awm.CastSpellByName(rs["暴风雪(等级 1)"])
						if not log_Spell then
							log_Spell = true
							textout(Check_UI("法力不足, 使用","Power not enough, Cast ")..rs["暴风雪(等级 1)"])
						end
					end
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				else
					awm.ClickPosition(sx,sy,sz)
					if not SP_Timer then
						SP_Timer = true
						SP_Time = GetTime()
					end
				end
			end
			return
		end

		if Dungeon_move == 11 then
		    local Monster = Combat_Scan()

			local left_time = 6.5
			if not SP_Timer then
				SP_Timer = true
				SP_Time = GetTime()
			else
				if GetTime() - SP_Time > left_time and not CastingBarFrame:IsVisible() then
					    
					SP_Timer = false
					if Pz <= 4 then
					    Dungeon_move = 12
					else
						Dungeon_move = 5
					end
					return
				end
			end
			if UnitPower("player") <= 3000 and Spell_Castable(rs["唤醒"]) and not CastingBarFrame:IsVisible() then
				awm.CastSpellByName(rs["唤醒"])
				return
			end

			if not CastingBarFrame:IsVisible() then
				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
					local id = awm.ObjectId(ThisUnit)
					if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					elseif id == 17961 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						awm.TargetUnit(ThisUnit)
						awm.CastSpellByName(rs["法术反制"],ThisUnit)
						awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			return
		end


		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 0.7 then
		    SP_Timer = false
			HasStop = false

			if Dungeon_move == 14 then
			    if Pz >= 4 then
					Dungeon_move = 1
					return
				end
				return
			end

			awm.MoveTo(x,y,z)

			return 
		elseif Distance <= 0.7 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			local Monster = Combat_Scan()

			if Dungeon_move == 13 then -- 等待10秒
			    local face = awm.UnitFacing("player")
			    if math.abs(face - 5.8897) > 0.01 and awm.GetUnitMovementFlags("player") == 0 then
					if not Interact_Step then
					    Try_Stop()
						Interact_Step = true
					    awm.FaceDirection(5.8897)
						C_Timer.After(0.1,function() Interact_Step = false end)
					end
				end
			    if not CastingBarFrame:IsVisible() then
					for i = 1,#Monster do
						local ThisUnit = Monster[i]
						local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects(ThisUnit,"player")
						local id = awm.ObjectId(ThisUnit)
						if id == 17940 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						    awm.TargetUnit(ThisUnit)
						    awm.CastSpellByName(rs["法术反制"],ThisUnit)
							awm.CastSpellByName(rs["寒冰护体"])
						elseif id == 17961 and awm.GetUnitMovementFlags(ThisUnit) == 0 then
						    awm.TargetUnit(ThisUnit)
						    awm.CastSpellByName(rs["法术反制"],ThisUnit)
							awm.CastSpellByName(rs["寒冰护体"])
						end
					end
				end

			    if not SP_Timer then
				    SP_Timer = true
					SP_Time = GetTime()
				else
				    local time = GetTime() - SP_Time
					if time >= 10 then
					    SP_Timer = false
						Dungeon_move = Dungeon_move + 1
						return
					end
				end
				return
			end

			if Dungeon_move == 14 then
			    local face = awm.UnitFacing("player")
				Try_Stop()
			    if Pz <= 4 then
			        if math.abs(face - 5.8897) < 0.01 then -- 5.9397
					    if Spell_Castable(rs["闪现术"]) then
					        awm.CastSpellByName(rs["闪现术"])
						end
					else
					    if not Interact_Step then
						    Interact_Step = true
					        awm.FaceDirection(5.8897)
							C_Timer.After(0.1,function() Interact_Step = false end)
						end
					end
				else
				    Dungeon_move = 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 6 then -- 拾取阶段
	    local body_list = Find_Body()
		if GetItemCount(Check_Client("裂纹的蚌壳","Jaggal Clam")) > 0 then
		    awm.UseItemByName(Check_Client("裂纹的蚌壳","Jaggal Clam"))
		end
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
		if #body_list > 0 then
		    
			if not Body_Choose then
				Body_Number = Body_Number + 1
				local number = math.random(1,3)
				if #body_list < 3 and #body_list > 1 then
					number = math.random(1,#body_list)
				elseif #body_list == 1 then
					number = 1
				end
				if number > #body_list then
					number = 1
					Body_Number = 1
				end
				Body_Target = body_list[number].Unit
				Body_Choose = true
				Body_Choose_Time = GetTime()
			else
				local time = GetTime() - Body_Choose_Time
				if time > 7 then
					Body_Choose = false
					Body_Target = nil
					return
				end
			end
			if Body_Target == nil or not awm.ObjectExists(Body_Target) then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local Found_it = false -- 看选择的尸体还在不在列表
			for i = 1,#body_list do
				if body_list[i].Unit == Body_Target then
					Found_it = true
				end
			end
			if not Found_it then
				Body_Choose = false
				Body_Target = nil
				return
			end
			local distance1 = awm.GetDistanceBetweenObjects("player",Body_Target)
			local x,y,z = awm.ObjectPosition(Body_Target)
			if distance1 >= 5 then
				if Mount_useble then
					Mount_useble = false
					C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
				end
				Run(x,y,z)
				Interact_Step = false
				Open_Slot = false
			else
				if not Open_Slot then
					Open_Slot = true
					Open_Slot_Time = GetTime()
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							local number = math.random(1,#body_list)
							Body_Choose = true
							Body_Target = body_list[number].Unit
						end
						CloseLoot()
						LootFrame_Close()
						return
					end
					awm.InteractUnit(Body_Target)
				else
					local time = GetTime() - Open_Slot_Time
					local Interval = tonumber(Easy_Data["拾取间隔"])
					if Interval == nil then
						Interval = 0.5
					end
					if time > Interval then
						Open_Slot = false
					end
					if LootFrame:IsVisible() then
						if GetNumLootItems() == 0 then
							Body_Choose = false
							Body_Target = nil
							CloseLoot()
							LootFrame_Close()
							return
						end
						for i = 1,GetNumLootItems() do
							LootSlot(i)
							ConfirmLootSlot(i)
						end
					end
				end
			end
	    else
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		end
	elseif Dungeon_step1 == 7 then -- 出本到门神
	    Note_Head = Check_UI("出本到门神","Go out dungeon Phase 1")

		local Path = 
		{
		{75.65,-325.63,3.04},
		{113.56,-329.02,3.04},
		{98.73,-411.45,3.03}, -- 开箱子
		{111.47,-379.19,3.03},
		{111.27,-350.35,3.03},
		{111.08,-323.09,3.03},
		{88.25,-319.89,3.03}, -- 开箱子
		{69.69,-321.00,3.04},
		{-8.58,-301.57,2.94},
		}
		if Dungeon_move > #Path then
		    if not Easy_Data["围栏采药"] and not Easy_Data["围栏采矿"] then
		        Dungeon_step1 = 8
			else
			    Dungeon_step1 = 9
			end
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			
			awm.MoveTo(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 3 then
			    local target = Find_Object_Position(184933,134.58,-446.51,3.03,5)
				local target1 = Find_Object_Position(17940,134.58,-446.51,3.03,15)
				if target ~= nil and target1 == nil then
				    Dungeon_step1 = 21
					return
				end
			end
			
			if Dungeon_move == 1 then
			    if not MakingDrinkOrEat() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
			    if not CheckUse() and CalculateTotalNumberOfFreeBagSlots() > 0 then
					return
				end
				Dungeon_move = Dungeon_move + 1
			    return
			end

			if Dungeon_move == 7 then
			    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
				local target1 = Find_Object_Position(17940,135.59,-304.62,3.03,15)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				elseif target ~= nil and target1 == nil then
				    Dungeon_step1 = 20
				elseif target1 ~= nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 8 then -- 出本到门口
	    Note_Head = Check_UI("出本到门口","Go out dungeon Phase 2")
		Reset_Instance = true

		local Path = 
		{
		{-9.91,-282.48,-0.89},
		{-11.79,-255.58,-1.20},
		{-13.65,-228.94,-1.59},
		{-15.44,-203.34,-1.59},
		{-16.44,-188.99,-1.57},
		{-29.18,-173.37,-1.59},
		{-41.63,-166.69,-1.47},
		{-45.09,-154.85,-1.58},
		{-58.04,-135.75,-1.58},
		{-69.03,-131.55,-1.59},
		{-84.30,-126.44,-1.51},
		{-87.44,-118.06,-1.78},
		{-88.16,-105.80,-4.89},
		{-100.72,-58.97,-2.43},
		{-112.73,-16.37,-8.54},
		{-91.56,-6.80,-7.80},
		{-78.13,-6.11,-7.46},
		{-79.82,5.36,-5.01},
		{-68.94,15.21,-1.92},
		{-54.13,19.49,-1.59},
		{-47.06,21.11,-1.39},
		{-34.08,26.67,0.99},
		{-23.50,25.08,2.56},
		{-16.15,19.29,3.37},
		{3.37,-13.13,-1.47},
		{8.22,-33.05,-2.10},
		{62.13,-63.96,-2.77},
		{111.52,-92.45,-1.59},
		{122.57,-105.59,-1.59},
		{122.75,-125.88,-0.72},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false

			if (Dungeon_move == 27 or Dungeon_move == 28) and IsFacing(x,y,Pz) and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(1.5,function() Interact_Step = false end)
			    awm.JumpOrAscendStart()
			end
			
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if Dungeon_move == 27 or Dungeon_move == 28 then
			    awm.AscendStop()
			end
		  
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 6 then
			    local target = Find_Object_Position(17961,-48.23,-166.59,-1.48,30)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 23 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 9 then -- 采集
	    Reset_Instance = true

	    Note_Head = Check_UI("双采","Mining and Herbalism")
		local Path = 
		{
			{-14.54,-310.31,2.53},
			{-22.88,-324.64,-1.57},
			{-15.52,-327.92,-1.58},
			{-41.61,-328.49,-1.58},
			{-71.42,-314.72,-1.49},
			{-95.73,-320.61,-1.59},
			{-110.10,-317.16,-1.58},
			{-138.17,-305.09,-0.62},
			{-148.54,-280.47,-1.58},
			{-151.02,-267.22,-1.59},
			{-146.65,-255.57,-1.59},
			{-155.46,-278.88,-1.58},
			{-141.47,-279.57,-1.59},
			{-130.21,-273.45,-1.59},
			{-123.97,-281.95,-1.59},
			{-128.07,-307.63,-1.39},
			{-105.70,-319.32,-1.59},
			{-71.91,-327.56,-1.56},
			{-46.57,-327.44,-1.58},
			{-23.48,-327.97,-1.59},
			{-14.77,-301.38,2.34},
			{-10.30,-280.59,-0.76},
			{-6.50,-268.03,-0.42},
			{-13.46,-255.50,-1.33},
			{-20.17,-243.31,-2.06},
			{-21.03,-219.86,-2.25},
			{-21.44,-206.95,-1.77},
			{-1.73,-187.94,-1.56},
			{-19.76,-175.02,-1.59},
			{-34.85,-167.70,-1.59},
			{-39.85,-165.07,-1.50},
			{-58.20,-135.51,-1.58},
			{-58.78,-151.83,-1.43},
			{-58.71,-135.10,-1.58},
			{-71.30,-130.60,-1.59},
			{-81.53,-127.91,-1.59},
			{-84.02,-125.88,-1.53},
			{-86.71,-120.80,-1.92},
			{-104.22,-123.91,-2.15},
			{-100.10,-101.21,-4.46},
			{-102.73,-69.06,-3.20},
			{-116.16,-27.34,-6.38},
			{-108.27,-6.19,-8.84},
			{-92.39,3.06,-6.15},
			{-81.43,5.31,-5.26},
			{-70.27,8.89,-2.90},
			{-62.73,16.97,-1.59},
			{-58.39,15.09,-1.59},
			{-48.26,20.90,-1.59},
			{-30.08,28.25,1.72},
			{-25.23,26.45,2.37},
			{-19.08,21.61,3.05},
			{3.80,2.20,-0.40},
			{4.74,-4.35,-1.30},
			{-4.42,-3.98,-1.23},
			{1.28,-20.34,-1.70},
			{-9.80,-45.35,-2.55},
			{-9.90,-69.16,-1.59},
			{17.19,-69.33,-1.59},
			{54.26,-91.94,-2.87},
			{57.33,-77.51,-2.59},
			{99.07,-85.14,-2.18},
			{120.69,-111.13,-0.70},
			{121.20,-125.18,-0.26},
		}
		if Dungeon_move > #Path then
		    Dungeon_step1 = 10
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if Distance > 1 then
		    SP_Timer = false
			awm.Interval_Move(x,y,z)
			return 
		elseif Distance <= 1 then 
		    if GetUnitSpeed("player") > 0 then
			    Try_Stop()
				return
			end
			HasStop = false

			if Dungeon_move == 39 then
			    local target = Find_Object_Position(21128,-119.63,-142.53,-2.32,30)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if Dungeon_move == 3 or Dungeon_move == 5 or Dungeon_move == 7 or Dungeon_move == 11 or Dungeon_move == 14 or Dungeon_move == 23 or Dungeon_move == 28 or Dungeon_move == 33 or Dungeon_move == 39 or Dungeon_move == 43 or Dungeon_move == 48 or Dungeon_move == 55 or Dungeon_move == 58 or Dungeon_move == 61 then
			    local S = {}
				if Dungeon_move == 3 then
				    S.x,S.y,S.z = -15.10,-328.10,-1.58
				elseif Dungeon_move == 5 then
				    S.x,S.y,S.z = -71.61,-314.31,-1.48
				elseif Dungeon_move == 7 then
				    S.x,S.y,S.z = -110.10,-317.16,-1.58
				elseif Dungeon_move == 11 then
				    S.x,S.y,S.z = -146.68,-255.88,-1.58
				elseif Dungeon_move == 14 then
				    S.x,S.y,S.z = -130.50,-273.60,-1.58
				elseif Dungeon_move == 23 then
				    S.x,S.y,S.z = -6.49,-268.13,-0.4
				elseif Dungeon_move == 28 then
				    S.x,S.y,S.z = 0.00,-186.66,-1.55
				elseif Dungeon_move == 33 then
				    S.x,S.y,S.z = -58.80,-152.35,-1.42
				elseif Dungeon_move == 39 then
				    S.x,S.y,S.z = -136.80,-128.96,-1.69
				elseif Dungeon_move == 43 then
				    S.x,S.y,S.z = -108.11,-5.77,-8.77
				elseif Dungeon_move == 48 then
				    S.x,S.y,S.z = -55.62,13.89,-1.58
				elseif Dungeon_move == 55 then
				    S.x,S.y,S.z = -8.01,-3.30,-1.21
				elseif Dungeon_move == 58 then
				    S.x,S.y,S.z = -9.61,-69.09,-1.58
				elseif Dungeon_move == 61 then
				    S.x,S.y,S.z = 57.38,-76.99,-2.58
				end

				Target_Item = nil
				local target = Find_Game_Obj(S.x,S.y,S.z,15)
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

			if Dungeon_move == 29 or Dungeon_move == 32 then
			    local target = Find_Object_Position(17961,-58.80,-152.35,-1.42,40)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 9 or Dungeon_move == 12 then
			    local target = Find_Object_Position(17957,-48.75,-262.20,-0.89,20)
				if target ~= nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 52 then
			    local target = Find_Object_Position(17959, -21.41, 1.86, -1, 10)
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	elseif Dungeon_step1 == 10 then -- 准备出本
	    local x,y,z = 122,-122,0
		local distance = awm.GetDistanceBetweenPositions(x,y,z,Px,Py,Pz)
		if distance > 2 then
		    if Mount_useble then
				Mount_useble = false
				C_Timer.After(30,function() if not Mount_useble then  Mount_useble = true end end)
			end
			Run(x,y,z)
		else
		    Dungeon_step1 = 1
			Dungeon_move = 1
			Dungeon_step = 2
			return
		end
	elseif Dungeon_step1 == 20 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,135.59,-304.62,3.03,5)
		if target == nil then
		    Dungeon_step1 = 7
			Dungeon_move = 5
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 21 then -- 开左侧箱子
	    local target = Find_Object_Position(184933,134.58,-446.51,3.03,5)
		if target == nil then
		    Dungeon_step1 = 7
			Dungeon_move = 1
			return
		else 
		    local x,y,z = awm.ObjectPosition(target)
			local distance = awm.GetDistanceBetweenObjects("player",target)
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
			    awm.InteractUnit(target)
			else
			    Run(x,y,z)
			end
		end
	elseif Dungeon_step1 == 30 then -- 双采步骤
		if not awm.ObjectExists(Target_Item) then
			Dungeon_step1 = 9
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

				if not Interact_Step and Easy_Data["需要喊话"] and awm.GetDistanceBetweenPositions(x1,y1,z1,Px,Py,Pz) < 20 then
					Interact_Step = true
					C_Timer.After(0.5,function() Interact_Step = false end)
					awm.RunMacroText("/party "..Easy_Data["出本喊话"])
				end

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
	{565.56,6940.61,16.84},
	{564.99,6941.14,-5.38},
	{568.93,6940.79,-26.77},
	{577.34,6939.47,-40.89},
	{585.83,6932.56,-42.02},
	{598.56,6918.92,-45.57},
	{603.49,6909.79,-47.12},
	{607.54,6900.28,-48.22},
	{610.75,6892.74,-49.10},
	{615.56,6888.97,-57.20},
	{624.14,6881.87,-69.89},
	{631.53,6874.67,-74.60},
	{640.99,6865.70,-79.47},
	{652.42,6866.18,-82.56},
	{658.28,6865.26,-81.57},
	{668.91,6862.13,-75.58},
	{677.19,6859.68,-72.13}
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
			    if not Interact_Step then
				    Interact_Step = true
					C_Timer.After(1,function() Interact_Step = false end)
					awm.JumpOrAscendStart()
				end
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

			if Instance == 547 and Dungeon_step == 2 then
				local starttime, durationtime, enable = GetItemCooldown(6948)
				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
				Note_Head = Check_UI("卖物","Vendor")
				if GetItemCount(6948) > 0 and durationtime < 10 and not Easy_Data["需要喊话"] then
					CheckProtection()
				
				    if IsMounted() then
						Dismount()
					end
					Note_Set(Check_UI("炉石卖物 = ","Hearth Stone Using, Vendor name = ")..Merchant_Name)
					if not CastingBarFrame:IsVisible() then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					frame:SetBackdropColor(0,0,0,0)
					return
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 40 then
				    if not Interact_Step and Easy_Data["需要喊话"] then
						Interact_Step = true
						C_Timer.After(1.5,function() Interact_Step = false end)
						awm.RunMacroText("/party "..Easy_Data["出本喊话"])
					end
					Note_Set(Check_UI("出本卖物 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
					Run(x1,y1,z1)
					frame:SetBackdropColor(0,0,0,0)
					return
				end
		    elseif Instance ~= 547 then
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
					if not CastingBarFrame:IsVisible() then
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
						Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1946, -198.66, 5506.75, 22.34

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

	if Easy_Data["需要邮寄"] and not awm.UnitAffectingCombat("player") then
		if #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] == math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) and #Easy_Data.ResetTimes ~= 0 and #Easy_Data.ResetTimes ~= 1 and not Has_Mail then
		    Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1946, -198.66, 5506.75, 22.34
			if Easy_Data["自定义邮箱"] then
				local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
			end
			
			
			if Instance == 547 and Dungeon_step == 2 then
				Note_Head = Check_UI("邮寄","Mail")
				    
				local starttime, durationtime, enable = GetItemCooldown(6948)
				local x1,y1,z1 = Dungeon_Out.x,Dungeon_Out.y,Dungeon_Out.z
				if GetItemCount(6948) > 0 and durationtime < 10 and not IsMounted() and not Easy_Data["需要喊话"] then
					CheckProtection()
				    Note_Set(Check_UI("炉石邮寄, 坐标 = ","Using Herath Stone Back To Mail, Coord = ")..x1..","..y1..","..z1)
					frame:SetBackdropColor(0,0,0,0)
					if not Spell_Casting and not Spell_Channel_Casting then
						awm.UseItemByName(Check_Client("炉石","Hearthstone"))
					end
					return
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 40 then
					if not Interact_Step and Easy_Data["需要喊话"] then
						Interact_Step = true
						C_Timer.After(1.5,function() Interact_Step = false end)
						awm.RunMacroText("/party "..Easy_Data["出本喊话"])
					end
				    
				    Note_Set(Check_UI("出本邮寄, 坐标 = ","Go Out To Mail, Coord = ")..x1..","..y1..","..z1)
					frame:SetBackdropColor(0,0,0,0)
					Run(x1,y1,z1)
					return
				end
			elseif Instance ~= 547 then
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

	if Instance == 547 then
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
		    if not awm.UnitAffectingCombat("player") then
		        if not MakingDrinkOrEat() then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
			    if not CheckUse() then
					return
				end
			end
		    Dungeon_step = 2
			Need_Reset = false
			Run_Time = Run_Time - tonumber(Easy_Data["副本重置时间"])
			return
		end

		if Dungeon_step == 1 then
		    if Easy_Data["奴隶30"] then
		        SP_30()
			elseif Easy_Data["奴隶40"] then
			    SP_40()
			elseif Easy_Data["奴隶30走廊"] then
			    SP_30_Wall()
			elseif Easy_Data["奴隶40走廊"] then
			    SP_40_Wall()
			end
			return
		end
		if Dungeon_step == 2 then
		    Reset_Instance = true
			Note_Head = Check_UI("结束","End Process")
			Go_Out()
			return
		end
	else
	    Note_Head = Check_UI("正常进本","Run Into Dungeon")
		if tonumber(Easy_Data["等待时间"]) == nil then
		    Easy_Data["等待时间"] = 5
		end
		if (GetTime() - Out_Dungeon_Time) < Easy_Data["等待时间"] then
		    return
		end

		if not awm.UnitAffectingCombat("player") then
			if not MakingDrinkOrEat() then
			    if IsMounted() then
					Dismount()
				end
			    return
			end
			local flag = awm.GetUnitMovementFlags("player")
			if not flag == 1048576 and not flag == 1048608 and not flag == 1048577 and not flag == 1048593 then
			    if not NeedHeal() then
				    if IsMounted() then
						Dismount()
					end
				    return
				end
	 		end
			if not CheckUse() then
			    if IsMounted() then
					Dismount()
				end
			    return
			end
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
				if not Interact_Step and Easy_Data["需要喊话"] then
					Interact_Step = true
					C_Timer.After(1.5,function() Interact_Step = false end)
					awm.RunMacroText("/party "..Easy_Data["进本喊话"])
				end
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
					if Instance ~= 547 then
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
		awm.SetPathfindingVariables(0.5, 2, 6, 0.3) -- 1.5, 3.5, 6.0, 0.3
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
	if DoesSpellExist(rs["旅行形态"]) and Mount_useble and not CheckBuff("player",rs["旅行形态"]) and (GetTime() - DRUID_Shift) > 1 and Spell_Castable(rs["旅行形态"]) then
	    Reset_Stuck = GetTime()
	    DRUID_Shift = GetTime()
		awm.CastSpellByName(rs["旅行形态"],"player")
		textout(Check_UI("旅行形态 切换","Travel Form Shift"))
		return
	elseif not DoesSpellExist(rs["旅行形态"]) and not IsMounted() and awm.UnitLevel("player") >= 30 and not awm.UnitIsGhost("player") and Mount_useble and not awm.UnitAffectingCombat("player") and not IsSwimming() and IsOutdoors() then
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
			awm.Interval_Move(x,y,z + 1)
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
	    Basic_UI.Set["奴隶30"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 28 - 32 只怪 + 开箱子","Slave Pens 28 - 32 mobs + Lock Picking"))
		Basic_UI.Set["奴隶30"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["奴隶30"]:GetChecked() then
				Easy_Data["奴隶30"] = true

				Easy_Data["奴隶40"] = false
				Basic_UI.Set["奴隶40"]:SetChecked(false)

				Easy_Data["奴隶30走廊"] = false
				Basic_UI.Set["奴隶30走廊"]:SetChecked(false)

				Easy_Data["奴隶40走廊"] = false
				Basic_UI.Set["奴隶40走廊"]:SetChecked(false)

			elseif not Basic_UI.Set["奴隶30"]:GetChecked() then
				Easy_Data["奴隶30"] = false
			end
		end)
		if Easy_Data["奴隶30"] ~= nil then
			if Easy_Data["奴隶30"] then
				Basic_UI.Set["奴隶30"]:SetChecked(true)
			else
				Basic_UI.Set["奴隶30"]:SetChecked(false)
			end
		else
			Easy_Data["奴隶30"] = true
			Basic_UI.Set["奴隶30"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["奴隶40"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 39 - 43 只怪 + 开箱子","Slave Pens 39 - 43 mobs + Lock Picking"))
		Basic_UI.Set["奴隶40"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["奴隶40"]:GetChecked() then
				Easy_Data["奴隶40"] = true

				Easy_Data["奴隶30"] = false
				Basic_UI.Set["奴隶30"]:SetChecked(false)

				Easy_Data["奴隶30走廊"] = false
				Basic_UI.Set["奴隶30走廊"]:SetChecked(false)

				Easy_Data["奴隶40走廊"] = false
				Basic_UI.Set["奴隶40走廊"]:SetChecked(false)

			elseif not Basic_UI.Set["奴隶40"]:GetChecked() then
				Easy_Data["奴隶40"] = false
			end
		end)
		if Easy_Data["奴隶40"] ~= nil then
			if Easy_Data["奴隶40"] then
				Basic_UI.Set["奴隶40"]:SetChecked(true)
			else
				Basic_UI.Set["奴隶40"]:SetChecked(false)
			end
		else
			Easy_Data["奴隶40"] = false
			Basic_UI.Set["奴隶40"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["奴隶30走廊"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 28 - 32 只怪 走廊击杀 + 开箱子","Slave Pens 28 - 32 mobs + Lock Picking, Alts can earn exp at dungeon door"))
		Basic_UI.Set["奴隶30走廊"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["奴隶30走廊"]:GetChecked() then
				Easy_Data["奴隶30走廊"] = true

				Easy_Data["奴隶40"] = false
				Basic_UI.Set["奴隶40"]:SetChecked(false)

				Easy_Data["奴隶30"] = false
				Basic_UI.Set["奴隶30"]:SetChecked(false)

				Easy_Data["奴隶40走廊"] = false
				Basic_UI.Set["奴隶40走廊"]:SetChecked(false)

			elseif not Basic_UI.Set["奴隶30走廊"]:GetChecked() then
				Easy_Data["奴隶30走廊"] = false
			end
		end)
		if Easy_Data["奴隶30走廊"] ~= nil then
			if Easy_Data["奴隶30走廊"] then
				Basic_UI.Set["奴隶30走廊"]:SetChecked(true)
			else
				Basic_UI.Set["奴隶30走廊"]:SetChecked(false)
			end
		else
			Easy_Data["奴隶30走廊"] = false
			Basic_UI.Set["奴隶30走廊"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["奴隶40走廊"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 39 - 43 只怪 走廊击杀 + 开箱子","Slave Pens 39 - 43 mobs + Lock Picking, Alts can earn exp at dungeon door"))
		Basic_UI.Set["奴隶40走廊"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["奴隶40走廊"]:GetChecked() then
				Easy_Data["奴隶40走廊"] = true

				Easy_Data["奴隶40"] = false
				Basic_UI.Set["奴隶40"]:SetChecked(false)

				Easy_Data["奴隶30"] = false
				Basic_UI.Set["奴隶30"]:SetChecked(false)

				Easy_Data["奴隶30走廊"] = false
				Basic_UI.Set["奴隶30走廊"]:SetChecked(false)

			elseif not Basic_UI.Set["奴隶40走廊"]:GetChecked() then
				Easy_Data["奴隶40走廊"] = false
			end
		end)
		if Easy_Data["奴隶40走廊"] ~= nil then
			if Easy_Data["奴隶40走廊"] then
				Basic_UI.Set["奴隶40走廊"]:SetChecked(true)
			else
				Basic_UI.Set["奴隶40走廊"]:SetChecked(false)
			end
		else
			Easy_Data["奴隶40走廊"] = false
			Basic_UI.Set["奴隶40走廊"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["击杀医师"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 击杀医师怪物 4只 (多1矿草点)","Slave Pens Kill Coilfang Scale-Healer 4 Mobs (1 mining and herb node extra)"))
		Basic_UI.Set["击杀医师"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["击杀医师"]:GetChecked() then
				Easy_Data["击杀医师"] = true
			elseif not Basic_UI.Set["击杀医师"]:GetChecked() then
				Easy_Data["击杀医师"] = false
			end
		end)
		if Easy_Data["击杀医师"] ~= nil then
			if Easy_Data["击杀医师"] then
				Basic_UI.Set["击杀医师"]:SetChecked(true)
			else
				Basic_UI.Set["击杀医师"]:SetChecked(false)
			end
		else
			Easy_Data["击杀医师"] = false
			Basic_UI.Set["击杀医师"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["围栏采矿"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 采矿","Slave Pens Mining"))
		Basic_UI.Set["围栏采矿"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["围栏采矿"]:GetChecked() then
				Easy_Data["围栏采矿"] = true
			elseif not Basic_UI.Set["围栏采矿"]:GetChecked() then
				Easy_Data["围栏采矿"] = false
			end
		end)
		if Easy_Data["围栏采矿"] ~= nil then
			if Easy_Data["围栏采矿"] then
				Basic_UI.Set["围栏采矿"]:SetChecked(true)
			else
				Basic_UI.Set["围栏采矿"]:SetChecked(false)
			end
		else
			Easy_Data["围栏采矿"] = false
			Basic_UI.Set["围栏采矿"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["围栏采药"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("奴隶围栏 采药","Slave Pens Herbalism"))
		Basic_UI.Set["围栏采药"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["围栏采药"]:GetChecked() then
				Easy_Data["围栏采药"] = true
			elseif not Basic_UI.Set["围栏采药"]:GetChecked() then
				Easy_Data["围栏采药"] = false
			end
		end)
		if Easy_Data["围栏采药"] ~= nil then
			if Easy_Data["围栏采药"] then
				Basic_UI.Set["围栏采药"]:SetChecked(true)
			else
				Basic_UI.Set["围栏采药"]:SetChecked(false)
			end
		else
			Easy_Data["围栏采药"] = false
			Basic_UI.Set["围栏采药"]:SetChecked(false)
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
	end

	local function Loot_Interval()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("拾取间隔时间","Lott interval")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["拾取间隔"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"0.05",false,280,24)

		Basic_UI.Set["拾取间隔"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["拾取间隔"] = Basic_UI.Set["拾取间隔"]:GetText()
		end)
		if Easy_Data["拾取间隔"] ~= nil then
			Basic_UI.Set["拾取间隔"]:SetText(Easy_Data["拾取间隔"])
		else
			Easy_Data["拾取间隔"] = Basic_UI.Set["拾取间隔"]:GetText()
		end
	end

	local function Wait_point()
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("奴隶围栏 爆本 本外等待坐标","Slave Pens Wait Point")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["围栏等待坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"712,6999,-74",false,280,24)
		Basic_UI.Set["围栏等待坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["围栏等待坐标"] = Basic_UI.Set["围栏等待坐标"]:GetText()
			local coord_package = string.split(Easy_Data["围栏等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		end)
		if Easy_Data["围栏等待坐标"] ~= nil then
			Basic_UI.Set["围栏等待坐标"]:SetText(Easy_Data["围栏等待坐标"])
			local coord_package = string.split(Easy_Data["围栏等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		else
			Easy_Data["围栏等待坐标"] = Basic_UI.Set["围栏等待坐标"]:GetText()
		end

		Basic_UI.Set["获取等待坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Set["获取等待坐标"]:SetSize(120,24)
		Basic_UI.Set["获取等待坐标"]:SetScript("OnClick", function(self)
			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance ~= 547 then
			    local x,y,z = awm.ObjectPosition("player")
				Basic_UI.Set["围栏等待坐标"]:SetText(math.floor(x)..","..math.floor(y)..","..math.floor(z))
				Easy_Data["围栏等待坐标"] = Basic_UI.Set["围栏等待坐标"]:GetText()
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

	local function Order_UI() -- 喊话命令
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["需要喊话"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("需要进出本喊话带小号","Command bring alts in or out dungeon"))
		Basic_UI.Set["需要喊话"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["需要喊话"]:GetChecked() then
				Easy_Data["需要喊话"] = true
			elseif not Basic_UI.Set["需要喊话"]:GetChecked() then
				Easy_Data["需要喊话"] = false
			end
		end)
		if Easy_Data["需要喊话"] ~= nil then
			if Easy_Data["需要喊话"] then
				Basic_UI.Set["需要喊话"]:SetChecked(true)
			else
				Basic_UI.Set["需要喊话"]:SetChecked(false)
			end
		else
			Easy_Data["需要喊话"] = false
			Basic_UI.Set["需要喊话"]:SetChecked(false)
		end


		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("进本喊话命令","Command of going into dungeon")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["进本喊话"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"go in",false,280,24)

		Basic_UI.Set["进本喊话"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["进本喊话"] = Basic_UI.Set["进本喊话"]:GetText()
		end)
		if Easy_Data["进本喊话"] ~= nil then
			Basic_UI.Set["进本喊话"]:SetText(Easy_Data["进本喊话"])
		else
			Easy_Data["进本喊话"] = Basic_UI.Set["进本喊话"]:GetText()
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("出本喊话命令","Command of going out dungeon")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["出本喊话"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"go out",false,280,24)

		Basic_UI.Set["出本喊话"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["出本喊话"] = Basic_UI.Set["出本喊话"]:GetText()
		end)
		if Easy_Data["出本喊话"] ~= nil then
			Basic_UI.Set["出本喊话"]:SetText(Easy_Data["出本喊话"])
		else
			Easy_Data["出本喊话"] = Basic_UI.Set["出本喊话"]:GetText()
		end


		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header2 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("副本外等待小号时间","Wait time outside the dungeon for alts")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["等待时间"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"5",false,280,24)

		Basic_UI.Set["等待时间"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["等待时间"] = tonumber(Basic_UI.Set["等待时间"]:GetText())
		end)
		if Easy_Data["等待时间"] ~= nil then
			Basic_UI.Set["等待时间"]:SetText(Easy_Data["等待时间"])
		else
			Easy_Data["等待时间"] = tonumber(Basic_UI.Set["等待时间"]:GetText())
		end
	end

	local function Item_Use_UI() -- 使用风蛇
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["使用风蛇"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("侏儒 巨魔 使用风蛇","Auto use Savory Deviate Delight"))
		Basic_UI.Set["使用风蛇"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["使用风蛇"]:GetChecked() then
				Easy_Data["使用风蛇"] = true
			elseif not Basic_UI.Set["使用风蛇"]:GetChecked() then
				Easy_Data["使用风蛇"] = false
			end
		end)
		if Easy_Data["使用风蛇"] ~= nil then
			if Easy_Data["使用风蛇"] then
				Basic_UI.Set["使用风蛇"]:SetChecked(true)
			else
				Basic_UI.Set["使用风蛇"]:SetChecked(false)
			end
		else
			Easy_Data["使用风蛇"] = false
			Basic_UI.Set["使用风蛇"]:SetChecked(false)
		end
	end

	local function Mana_Use_UI() -- 大蓝使用
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["使用大蓝"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("低于 指定法力值 使用特效法力药水","Current power lower than specific value, use Major Mana Potion"))
		Basic_UI.Set["使用大蓝"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["使用大蓝"]:GetChecked() then
				Easy_Data["使用大蓝"] = true
			elseif not Basic_UI.Set["使用大蓝"]:GetChecked() then
				Easy_Data["使用大蓝"] = false
			end
		end)
		if Easy_Data["使用大蓝"] ~= nil then
			if Easy_Data["使用大蓝"] then
				Basic_UI.Set["使用大蓝"]:SetChecked(true)
			else
				Basic_UI.Set["使用大蓝"]:SetChecked(false)
			end
		else
			Easy_Data["使用大蓝"] = true
			Basic_UI.Set["使用大蓝"]:SetChecked(true)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("特效法力药水 低于多少蓝量 使用","Specific power value to use Major Mana Potion")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["大蓝使用蓝量"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"1000",false,280,24)

		Basic_UI.Set["大蓝使用蓝量"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["大蓝使用蓝量"] = tonumber(Basic_UI.Set["大蓝使用蓝量"]:GetText())
		end)
		if Easy_Data["大蓝使用蓝量"] ~= nil then
			Basic_UI.Set["大蓝使用蓝量"]:SetText(Easy_Data["大蓝使用蓝量"])
		else
			Easy_Data["大蓝使用蓝量"] = tonumber(Basic_UI.Set["大蓝使用蓝量"]:GetText())
		end
	end

	Frame_Create()
	Button_Create()	

	Stuck_Fly_Set_UI()
	Function_UI()
	Loot_UI()
	Loot_Interval()
	Wait_point()
	Dungeon_Wait_Time()
	Order_UI()
	Item_Use_UI()
	Mana_Use_UI()
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

local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
if Instance == 547 and not Easy_Data["奴隶30走廊"] and not Easy_Data["奴隶40走廊"] then
    Need_Reset = true
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
function Script:BeginEvent(event,arg1,arg2,arg3,arg4,arg5,arg6,_,_,_,_,_,_,_)
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
			    Face_Time = GetTime()
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