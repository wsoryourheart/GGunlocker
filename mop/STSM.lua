Function_Load_In = true
local Function_Version = "1120"
textout(Check_UI("斯坦索姆 - "..Function_Version,"Stratholme - "..Function_Version))

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

local Dungeon_In = {mapid = 1423, x = 3240, y = -4063, z = 108}
local Dungeon_Out = {mapid = 1423, x = 3587, y = -3636, z = 138}
local Dungeon_Flush_Point = {mapid = 1423, x = 3223, y = -4034, z = 108}

local Flush_Time = false
local Dungeon_Flush = false -- 是否爆本
local Real_Flush = false -- 触发爆本
local Real_Flush_time = 0 -- 第一次爆本时间
local Real_Flush_times = 0 -- 爆本计数

local Merchant_Coord = {mapid = 1423, x = -1707, y = -1424, z = 34}
local Merchant_Name = "匠人比尔"

local Mail_Coord = {mapid = 1423, x = -1656, y = -1344, z = 32}
local Has_Mail = false

local Reset_Instance = false

local Interact_Step = false
local HasStop = false

local ST_Timer = false -- 玛拉顿技能计时
local ST_Time = 0
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

local Forst = false -- 冰环后跑
local Face_Time = 0 -- 面对怪物
local Combat_In_Range = false

local Pet_Attack = false

local Dungeon_Enter_step = 1 -- 带小号进本门口

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
		    if not awm.GetCorpsePosition() then
			    return
			end

		    Dead_Repop = GetTime()
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
    if GetTime() - Dead_Repop <= 5 then
	    Note_Set(Check_UI("等待跑尸复活时间 = ","Time waitting for going to Retrieve Corpse = ")..math.floor(5 - GetTime() + Dead_Repop))
	    return
	end
	Event_Reset()

	frame:SetBackdropColor(0,0,0,0)
	local deathx,deathy,deathz = awm.GetCorpsePosition()
	if awm.GetDistanceBetweenPositions(deathx,deathy,deathz,3392.31,-3378.48,142.72) <= 2 then
	    deathx,deathy,deathz = 3240,-4063,108
	end

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
		
		Run(deathx,deathy,deathz)
		return
	elseif DeathDistance <= 2 or InstanceCorpse then
	    if InstanceCorpse then
		    Note_Set(Check_UI("尸体在副本内","Corpse in dungeon"))
			local x,y,z = 3240,-4063,108
			if Interact_Step then
			    x,y,z = 3223,-4034,108
			end
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
			if distance > 2 then
			    if distance <= 10 then
					awm.MoveTo(x,y,z)
					return
				end
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
    if awm.UnitPower("player") < 4500 and GetItemCount(rs["法力刚玉"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(22044) then
		awm.UseItemByName(rs["法力刚玉"])
	end
	if awm.UnitPower("player") < 4500 and GetItemCount(rs["法力红宝石"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(8008) then
		awm.UseItemByName(rs["法力红宝石"])
	end
	if awm.UnitPower("player") < 4500 and GetItemCount(rs["法力黄水晶"]) > 0 and not CastingBarFrame:IsVisible()  and CheckCooldown(8007) then
		awm.UseItemByName(rs["法力黄水晶"])
	end
	if awm.UnitPower("player") < 4500 and GetItemCount(rs["法力翡翠"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5513) then
		awm.UseItemByName(rs["法力翡翠"])
	end
	if awm.UnitPower("player") < 4500 and GetItemCount(rs["法力玛瑙"]) > 0 and not CastingBarFrame:IsVisible() and CheckCooldown(5514) then
		awm.UseItemByName(rs["法力玛瑙"])
	end
	if awm.UnitPower("player") < 4500 and GetItemCount(Check_Client("特效法力药水","Major Mana Potion")) > 0 and not CastingBarFrame:IsVisible() and (CheckCooldown(13444)) then
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
				textout(Check_UI("我卖完了哦, 又要重新开始工作了","Vendor logic end, restart to work"))
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
		elseif awm.ObjectExists("target") then
            if awm.GetDistanceBetweenObjects("player","target") <= 3 then
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
	if Easy_Data["回血物品"] ~= nil and GetItemCount(Easy_Data["回血物品"]) < 10 and item == Easy_Data["回血物品"] then
	    return true
	end
	if Easy_Data["回蓝物品"] ~= nil and GetItemCount(Easy_Data["回蓝物品"]) < 10 and item == Easy_Data["回蓝物品"] then
	    return true
	end

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
		if id ~= nil and guid == id and distance < Far_Distance and distance < scan_range and not awm.ObjectIsPlayer(ThisUnit) then
			Far_Distance = distance
			target = ThisUnit
		elseif id == nil and distance < Far_Distance and distance < scan_range and not awm.ObjectIsPlayer(ThisUnit) then
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

function Combat_Scan()
    local Monster = {}
    local total = awm.GetObjectCount()
	for i = 1,total do
		local ThisUnit = awm.GetObjectWithIndex(i)
		local guid = awm.ObjectId(ThisUnit)
		local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
		local target = awm.UnitTarget(ThisUnit)
		if awm.UnitAffectingCombat(ThisUnit) and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) then
			Monster[#Monster + 1] = ThisUnit
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

function CombatSystem(target)
    if not awm.ObjectExists(target) then
	    return
	end

	awm.TargetUnit(target)
	if (awm.ObjectId(target) == 10384 or awm.ObjectId(target) == 10385) and awm.UnitTarget(target) and not CastingBarFrame:IsVisible() then
		awm.RunMacroText("/跳舞")
	end

	local Px,Py,Pz = awm.ObjectPosition("player")
	local x,y,z = awm.ObjectPosition(target)
	local distance = awm.GetDistanceBetweenObjects("player",target)
	local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	local Cur_Power = (awm.UnitPower("player")/awm.UnitPowerMax("player")) * 100
	local Tar_Health = (awm.UnitHealth("target")/awm.UnitHealthMax("target")) * 100
	local Tar_Power = (awm.UnitPower("target")/awm.UnitPowerMax("target")) * 100

	if awm.IsAoEPending() then
	    awm.ClickPosition(x,y,z)
		return
	end
	if Spell_Channel_Casting or Spell_Casting or CastingBarFrame:IsVisible() then
	    return
	end

    local flags = bit.bor(0x10, 0x100, 0x1)
    local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
	if hit == 1 then
	    Run(x,y,z)
		return
	end

	if GetTime() - Face_Time > 1 and distance < 35 and Tar_Health < 100 and awm.UnitAffectingCombat("player") and awm.UnitAffectingCombat("target") then
	    Face_Time = GetTime()
		awm.FaceTarget("target")
		return
	end

	if distance <= 4 and awm.ObjectExists(target) then
	    local obj_face = awm.UnitFacing("player")
		local need_face = awm.GetAnglesBetweenObjects("player","target")

		awm.InteractUnit(target)
		if GetUnitSpeed("player") > 0 and math.abs(obj_face - need_face) < 0.4 then
			Try_Stop()
		elseif math.abs(obj_face - need_face) > 0.4 then
		    awm.FaceDirection(need_face)
		end
	end

	if distance >= 33 and not Combat_In_Range then
	    Run(x,y,z)
		return
    elseif distance < 33 and not Combat_In_Range then
	    Combat_In_Range = true
		Try_Stop()
		C_Timer.After(10,function()
		    if Combat_In_Range then
				Combat_In_Range = false 
			end	
		end)
	end

	if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
		awm.CastSpellByName(rs["寒冰护体"])
		return
	end

	if Spell_Castable(rs["法力护盾"]) and not CheckBuff("player",rs["法力护盾"]) and UnitPower('player') >= 2000 then
		awm.CastSpellByName(rs["法力护盾"])
		return
	end

	if Spell_Castable(rs["冰冷血脉"]) and not CheckBuff("player",rs["冰冷血脉"]) and distance <= 35 and (Dungeon_step1 == 9 or Dungeon_step1 == 19 or Dungeon_step1 == 30) then
		awm.CastSpellByName(rs["冰冷血脉"])
		return
	end

	if not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
		if Spell_Castable(rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) then
			awm.CastSpellByName(rs["冰甲术"])
			return
		end
		if Spell_Castable(rs["霜甲术"]) and not CheckBuff("player",rs["冰甲术"]) and not CheckBuff("player",rs["霜甲术"]) then
			awm.CastSpellByName(rs["霜甲术"])
			return
		end		
	end
	if distance < 10 and Spell_Castable(rs["冰霜新星"]) then
		awm.CastSpellByName(rs["冰霜新星"])
		Forst = true
		C_Timer.After(1,function() Forst = false Try_Stop() end)
		return
	end
	if Forst then
		awm.MoveBackwardStart()
		return
	end

	if ((CheckDebuffByName(target,rs["冰霜新星"]) and UnitPower("player") <= 2000) or UnitPower("player") <= 400) and Spell_Castable(rs["唤醒"]) and (Dungeon_step1 == 9 or Dungeon_step1 == 19 or Dungeon_step1 == 30) then
	    awm.CastSpellByName(rs["唤醒"])
		return
	end

	if distance > 35 then
		Run(x,y,z)
		return
	end

	if PetHasActionBar() and Spell_Castable(rs["冰冻术"]) and distance <= 30 then
		awm.CastSpellByName(rs["冰冻术"])
	end

	if Spell_Castable(rs["火焰冲击"]) and awm.IsSpellInRange(rs["火焰冲击"],"target") == 1 then
		awm.CastSpellByName(rs["火焰冲击"])
	end

	if distance <= 35 and Spell_Castable(rs["冰枪术"]) and CheckDebuffByName("target",rs["冰霜新星"]) then
		awm.CastSpellByName(rs["冰枪术"])
		return
	end

	awm.FaceCombat(target)

	if Spell_Castable(rs["寒冰箭"]) and awm.IsSpellInRange(rs["寒冰箭"],"target") == 1 then
		awm.CastSpellByName(rs["寒冰箭"])
	end
end


function STSM()
    local Px,Py,Pz = awm.ObjectPosition("player")
	if tonumber(Px) == nil or tonumber(Py) == nil or tonumber(Pz) == nil then
	    return
	end

	if (Dungeon_step1 == 4 or Dungeon_step1 == 9 or Dungeon_step1 == 18 or Dungeon_step1 == 19 or Dungeon_step1 == 29 or Dungeon_step1 == 30) and not CastingBarFrame:IsVisible() then
		if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
			awm.CastSpellByName(rs["魔法抑制"],"player")
		end
	end

	if (Dungeon_step1 == 4 or Dungeon_step1 == 9 or Dungeon_step1 == 19 or Dungeon_step1 == 30) and not CastingBarFrame:IsVisible() then
	    if Dungeon_move <= 29 and UnitPower("player") <= 4500 then
			UseItem()
		elseif Dungeon_move > 29 and Dungeon_move < 37 and UnitPower("player") <= 1000 then
		    UseItem()
		elseif Dungeon_move >= 37 then
		    UseItem()
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

		Note_Set(Check_UI("出发出发","Go to reach point")..Dungeon_move)
		local x,y,z = 3597,-3655,138
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if distance > 1 then
			if distance > 50 then
			    awm.Stuck()
				return
			end
			Run(x,y,z)
			return 
		elseif distance <= 1 then
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

			Dungeon_step1 = 2
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 2 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
		if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
			awm.CastSpellByName(rs["魔法抑制"],"player")
			return
		end
		HasStop = false
		Dungeon_step1 = Dungeon_step1 + 1
		ST_Timer = false
		return
	end
	if Dungeon_step1 == 3 then -- 开仆从入口大门
	    local x,y,z = 3623.47,-3642.92,138.51
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,3623.47,-3642.92,138.51)
		if distance >= 1 then
		    Run(x,y,z)
		else
		    local total = awm.GetObjectCount()
			local Far_Distance = 20
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if guid == 175368 and not CastingBarFrame:IsVisible() then
                    awm.InteractUnit(ThisUnit)
				end
			end

		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
				return
			else
			    local time = GetTime() - ST_Time
				if time >= 2.5 and not CastingBarFrame:IsVisible() then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end

	if Dungeon_step1 == 4 then -- 1 
	    Note_Head = Check_UI("拉怪 - 1","Pulling mobs - 1")

		local Path = 
		{
		{3627.81,-3640.56,138.49},
		{3625.45,-3628.81,138.95},
		{3623.56,-3622.32,138.70},
		{3626.81,-3610.98,138.39},
		{3637.22,-3598.80,137.96},
		{3652.50,-3597.84,137.27},
		{3652.50,-3597.84,137.27}, -- 7 冰枪 10390 3643,-3629,138
		{3684.47,-3577.66,138.74},
		{3697.85,-3581.50,139.75},
		{3703.10,-3591.67,140.05},
		{3709.51,-3627.66,141.13},
		{3705.89,-3630.16,140.92},
		{3697.08,-3651.37,139.09}, -- 13 闪现
		{3696.55,-3656.39,138.90}, -- 14 下雪 3699.44,-3642.18,139.75
		{3696.52,-3652.95,139.01}, -- 15 冰环
		{3676.96,-3662.23,138.55},
		{3676.96,-3662.23,138.55}, -- 17 下雪 3696.47,-3651.26,139.09
		{3657.92,-3635.47,138.34}, -- 18 闪现 下雪 3677.22,-3660.69,138.59
		{3652.42,-3626.80,137.82}, -- 19 下雪 3666.85,-3647.09,138.55
		{3665.07,-3605.99,137.05}, -- 20 闪现 下雪 3658.62,-3631.38,139.44
	    {3671.59,-3607.06,137.14}, -- 21 下雪 3660.97,-3622.61,138.00
		{3695.67,-3627.13,139.74}, -- 22 闪现下雪 3677.45,-3617.40,138.52
		{3697.67,-3650.76,139.13}, -- 23 下雪 3689.95,-3632.60,139.23
		}

		if Dungeon_move == 100 then -- 剩下一只怪
			local Monster = Combat_Scan()

			if #Monster == 0 and not UnitAffectingCombat("player") then
			    Dungeon_move = #Path + 1
				return
			end

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end
		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 7 then -- 冰枪
			local Scan_Distance = 5
			if Dungeon_move == 7 then
				Target_ID = nil
				tarx,tary,tarz = 3643,-3629,138
				Scan_Distance = 10
			end
			if Target_Monster == nil then
				Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
			else
				awm.TargetUnit(Target_Monster)
				if IsFacing(tarx,tary,tarz) then
					awm.CastSpellByName(rs["冰枪术"],Target_Monster)
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				else
					FacePosition(tarx,tary,tarz)
					return
				end
			end
			if Target_Monster == nil then
				Dungeon_move = Dungeon_move + 1
				awm.SpellStopCasting()
				Target_Monster = nil
			end
			return
		end

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 1 then
			    local total = awm.GetObjectCount()
				local Far_Distance = 6
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					if guid == 175368 and not CastingBarFrame:IsVisible() then
						awm.InteractUnit(ThisUnit)
					end
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end

			if Dungeon_move == 13 or Dungeon_move == 18 or Dungeon_move == 20 or Dungeon_move == 22 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and UnitPower("player") >= 1000 then
					Interact_Step = true
					C_Timer.After(0.1,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    local Monster = Combat_Scan()
				for i = 1,#Monster do
					local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
					if distance <= 8 and Dungeon_move >= 18 then
						awm.CastSpellByName(rs["冰霜新星"])
					end

					if (distance <= 8 or (awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200)) and Distance >= 5 then
						if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"])
						end
					end

					-- 10390 骷髅守护者
					if Distance >= 5 and awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200 then
					    if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
							awm.CastSpellByName(rs["防护冰霜结界"])
						end
					end
				end
			end

			if Dungeon_move == 16 and not CheckBuff("player",rs["冰冷血脉"]) and Spell_Castable(rs["冰冷血脉"]) then
			    awm.CastSpellByName(rs["冰冷血脉"])
			end

			awm.MoveTo(x,y,z)

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			local Monster = Combat_Scan()
			if #Monster == 0 and not UnitAffectingCombat("player") and Dungeon_move >= 17 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 3 then
					    Dungeon_move = #Path + 1
						return
					end
				end
				return
			elseif #Monster == 1 and Dungeon_move >= 17 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 1.5 then
					    Dungeon_move = 100
						return
					end
				end
				return
			end

			if Dungeon_move == 15 then
			    if Spell_Castable(rs["冰霜新星"]) then
			        awm.CastSpellByName(rs["冰霜新星"])
				end
			end

			if Dungeon_move == 14 or Dungeon_move == 17 or Dungeon_move == 18 or Dungeon_move == 19 or Dungeon_move == 20 or Dungeon_move == 21 or Dungeon_move == 22 or Dungeon_move == 23 then -- 暴风雪
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 14 then
				    sx,sy,sz = 3699.44,-3642.18,139.75
					s_time = 5
				elseif Dungeon_move == 17 then
				    sx,sy,sz = 3696.47,-3651.26,139.09
					s_time = 7.5
				elseif Dungeon_move == 18 then
				    sx,sy,sz = 3677.22,-3660.69,138.59
					s_time = 7
				elseif Dungeon_move == 19 then
				    sx,sy,sz = 3666.85,-3647.09,138.55
					s_time = 7
				elseif Dungeon_move == 20 then
				    sx,sy,sz = 3658.62,-3631.38,139.44
					s_time = 7
				elseif Dungeon_move == 21 then
				    sx,sy,sz = 3660.97,-3622.61,138.00
					s_time = 7
				elseif Dungeon_move == 22 then
				    sx,sy,sz = 3677.45,-3617.40,138.52
					s_time = 7
				elseif Dungeon_move == 23 then
				    sx,sy,sz = 3689.95,-3632.60,139.23
					s_time = 7.5
				end

				if CheckBuff("player",rs["冰冷血脉"]) then
					s_time = 6
				end

				if ST_Timer then
				    local time = GetTime() - ST_Time
					if time >= s_time then
					    ST_Timer = false
						awm.SpellStopCasting()
						awm.SpellStopTargeting()
						Target_Monster = nil
						if Dungeon_move == 23 then
						    Dungeon_move = 15
						else
							Dungeon_move = Dungeon_move + 1
						end
						return
					end
				end

				if not CastingBarFrame:IsVisible() then
				    if UnitPower("player") > 2000 or CheckBuff("player",rs["节能施法"]) then
						awm.CastSpellByName(rs["暴风雪"])
					else
						awm.CastSpellByName(rs["暴风雪(等级 1)"])
					end
				    if awm.IsAoEPending() then
					    awm.ClickPosition(sx,sy,sz)
					end
				else
				    if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 5 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if UnitAffectingCombat("player") then
		    Dungeon_step1 = 4
			Dungeon_move = 100
			return
		end

		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 91
			return
		end
		if #body_list > 0 then
			if not Body_Choose then
				Body_Target = body_list[1].Unit
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
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 6 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 2
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 7 then -- 等冰箱和水元素
	    Note_Head = Check_UI("等待冰箱和水元素","Waiting Spell Duration")
		if not awm.UnitAffectingCombat("player") then
		    local starttime1, duration1, enabled, _ = GetSpellCooldown(rs["寒冰屏障"])
			local endtime1 = starttime1 + duration1
			if GetTime() < endtime1 then
			    Note_Set("冰箱")
			    return
			end

			local starttime2, duration2, enabled, _ = GetSpellCooldown(rs["召唤水元素"])
			local endtime2 = starttime2 + duration2
			if GetTime() < endtime2 then
			    Note_Set("水元素")
			    return
			end

			local starttime3, duration3, enabled, _ = GetSpellCooldown(rs["急速冷却"])
			local endtime3 = starttime3 + duration3
			if endtime3 - GetTime() >= 120 then
			    Note_Set("急速冷却")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["唤醒"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 120 then
			    Note_Set("唤醒")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 30 then
			    Note_Set("冰冷血脉")
			    return
			end

			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 3
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 8 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end
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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = 4
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 9 then -- 2 
	    Note_Head = Check_UI("拉怪 - 2","Pulling mobs - 2")

		local Path = 
		{
		{3651.93,-3540.87,137.86}, -- 1 寻路 等待胖子位置 3601.27,-3484.09,135.46
		{3652.26,-3521.84,136.99},
		{3656.78,-3511.21,136.70},
		{3656.78,-3511.21,136.70}, -- 4 冰枪 3682.11,-3486.17,134.27
		{3638.82,-3507.08,137.68},
		{3638.82,-3507.08,137.68}, -- 6 冰枪 3644,-3477,138
		{3623.22,-3503.05,136.80},
		{3623.22,-3503.05,136.80}, -- 8 冰枪 3597,-3480,135
		{3623.22,-3503.05,136.80}, -- 9 反制
		{3640.6785,-3508.9001,137.7578}, -- 10 召唤水元素
		{3636.0408,-3517.6003,136.4553}, -- 11 冰箱
		{3636.0408,-3517.6003,136.4553}, -- 12 水元素冰环 3636.0408,-3517.6003,136.4553
		{3644.0093,-3538.4866,138.0452}, -- 13 闪现 出冰箱
		{3644.0093,-3538.4866,138.0452}, -- 14 下雪 3637.6011,-3521.3430,136.6640
		{3650.2004,-3552.5488,137.9645}, -- 15 冰环
		{3650.2004,-3552.5488,137.9645}, -- 16 下雪 3642.0220,-3532.8958,137.7797
		{3651.5037,-3557.2703,137.9756},
		{3651.5037,-3557.2703,137.9756}, -- 18 下雪 3642.6838,-3535.6047,138.0004
		{3654.7720,-3580.8950,137.7351}, -- 19 闪现
		{3654.7720,-3580.8950,137.7351}, -- 20 下雪 3645.6770,-3547.5342,138.0702
		{3655.2205,-3589.4680,137.3052}, 
		{3655.2205,-3589.4680,137.3052}, -- 22 下雪 3650.0813,-3560.8684,138.0677
		{3648.6458,-3619.1865,137.4443}, -- 23 闪现
		{3648.6458,-3619.1865,137.4443}, -- 24 下雪 3652.6650,-3583.9929,137.7617	
		{3651.7388,-3625.9390,137.7706}, -- 25 冰环
		{3651.7388,-3625.9390,137.7706}, -- 26 下雪 3653.6885,-3601.5833,137.1192
		{3668.7336,-3650.4902,138.5838}, -- 27 闪现
		{3668.7336,-3650.4902,138.5838}, -- 28 下雪 3656.3169,-3629.3784,137.9371
		{3677.6826,-3662.0789,138.5768}, -- 29 冰环
		{3677.6826,-3662.0789,138.5768}, -- 30 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 31 闪现
        {3699.5996,-3652.0259,139.1076}, -- 32 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 34 下雪 3696.5029,-3648.8608,139.2266
		{3698.6372,-3618.3665,140.0967}, -- 35 急冷
		{3699.4294,-3611.9712,139.6280}, -- 36 召唤水元素
		{3711.9927,-3603.2114,141.2154}, -- 37 冰箱
		{3711.9927,-3603.2114,141.2154}, -- 38 水元素冰环 3711.9927,-3603.2114,141.2154
		{3681.1082,-3602.8723,137.5952}, -- 39 冰环 闪现 出冰箱
		{3681.1082,-3602.8723,137.5952}, -- 40 唤醒 5s
		{3681.1082,-3602.8723,137.5952}, -- 41 下雪 3705.9221,-3604.6782,140.3820
		{3670.9695,-3605.1873,137.0954},
		{3670.9695,-3605.1873,137.0954}, -- 43 下雪 3695.9614,-3604.9395,138.9726
		{3651.9612,-3618.4634,137.3329}, -- 44 闪现
		{3651.9612,-3618.4634,137.3329}, -- 45 下雪 3682.2654,-3609.0073,137.9412
		{3644.2390,-3624.7107,137.8329}, -- 46 水元素冰环 3665.2993,-3616.3259,137.7217
		{3644.2390,-3624.7107,137.8329}, -- 47 下雪 3665.2993,-3616.3259,137.7217
		{3671.7183,-3653.8928,138.6474}, -- 48 闪现
		{3671.7183,-3653.8928,138.6474}, -- 49 下雪 3657.1460,-3630.9497,138.0008
		{3677.6826,-3662.0789,138.5768},
		{3677.6826,-3662.0789,138.5768}, -- 51 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 52 闪现
        {3699.5996,-3652.0259,139.1076}, -- 53 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 55 下雪 3696.5029,-3648.8608,139.2266
		}

		if Dungeon_move == 100 then -- 剩下一只怪
			local Monster = Combat_Scan()

			if #Monster == 0 and not UnitAffectingCombat("player") then
			    Dungeon_move = #Path + 1
				return
			end

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 4 or Dungeon_move == 6 then -- 冰枪
			local Scan_Distance = 5
			if Dungeon_move == 4 then
				Target_ID = nil
				tarx,tary,tarz = 3682.11,-3486.17,134.27
				Scan_Distance = 10
			elseif Dungeon_move == 6 then
				Target_ID = nil
				tarx,tary,tarz = 3644,-3477,138
				Scan_Distance = 10
			end
			if Target_Monster == nil then
				Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
			else
				awm.TargetUnit(Target_Monster)
				if IsFacing(tarx,tary,tarz) then
					awm.CastSpellByName(rs["冰枪术"],Target_Monster)
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				else
					FacePosition(tarx,tary,tarz)
					return
				end
			end
			if Target_Monster == nil then
				Dungeon_move = Dungeon_move + 1
				awm.SpellStopCasting()
				Target_Monster = nil
			end
			return
		end

		if Dungeon_move == 8 or Dungeon_move == 9 then -- 冰枪
			if Dungeon_move == 8 then
				Target_ID = nil
				tarx,tary,tarz = 3597,-3480,135
			elseif Dungeon_move == 9 then
				Target_ID = nil
				tarx,tary,tarz = 3605,-3515,137
			end
			if Target_Monster == nil then
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
					if guid ~= 10414 and distance < Far_Distance and not awm.ObjectIsPlayer(ThisUnit) then
						Far_Distance = distance
						Target_Monster = ThisUnit
					end
				end
			else
				awm.TargetUnit(Target_Monster)
				if IsFacing(tarx,tary,tarz) then
				    if Dungeon_move == 8 then
						awm.CastSpellByName(rs["冰枪术"],Target_Monster)
					else
					    awm.CastSpellByName(rs["法术反制"],Target_Monster)
					end
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				else
					FacePosition(tarx,tary,tarz)
					return
				end
			end
			if Target_Monster == nil then
				Dungeon_move = Dungeon_move + 1
				awm.SpellStopCasting()
				Target_Monster = nil
			end
			return
		end

		if Dungeon_move == 14 or Dungeon_move == 16 or Dungeon_move == 18 or Dungeon_move == 20 or Dungeon_move == 22 or Dungeon_move == 24 or Dungeon_move == 26 or Dungeon_move == 28 or Dungeon_move == 30 or Dungeon_move == 32 or Dungeon_move == 34 or Dungeon_move == 41 or Dungeon_move == 43 or Dungeon_move == 45 or Dungeon_move == 47 or Dungeon_move == 49 or Dungeon_move == 51 or Dungeon_move == 53 or Dungeon_move == 55 then -- 暴风雪
			local sx,sy,sz = 0,0,0
			local s_time = 1.5
			local Monster = Combat_Scan()

			if Dungeon_move == 14 then
				sx,sy,sz = 3637.6011,-3521.3430,136.6640
				s_time = 6
			elseif Dungeon_move == 16 then
				sx,sy,sz = 3642.0220,-3532.8958,137.7797
				s_time = 4
			elseif Dungeon_move == 18 then
				sx,sy,sz = 3642.6838,-3535.6047,138.0004
				s_time = 5
			elseif Dungeon_move == 20 then
				sx,sy,sz = 3645.6770,-3547.5342,138.0702
				s_time = 7
			elseif Dungeon_move == 22 then
				sx,sy,sz = 3650.0813,-3560.8684,138.0677
				s_time = 7
			elseif Dungeon_move == 24 then
				sx,sy,sz = 3652.6650,-3583.9929,137.7617
				s_time = 7.5
			elseif Dungeon_move == 26 then
				sx,sy,sz = 3653.6885,-3601.5833,137.1192
				s_time = 7.5
			elseif Dungeon_move == 28 then
				sx,sy,sz = 3656.3169,-3629.3784,137.9371
				s_time = 7
            elseif Dungeon_move == 30 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7
			elseif Dungeon_move == 32 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 34 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			elseif Dungeon_move == 41 then
				sx,sy,sz = 3705.9221,-3604.6782,140.3820
				s_time = 2.3
			elseif Dungeon_move == 43 then
				sx,sy,sz = 3695.9614,-3604.9395,138.9726
				s_time = 7
			elseif Dungeon_move == 45 then
				sx,sy,sz = 3682.2654,-3609.0073,137.9412
				s_time = 7
			elseif Dungeon_move == 47 then
				sx,sy,sz = 3665.2993,-3616.3259,137.7217
				s_time = 7.5
			elseif Dungeon_move == 49 then
				sx,sy,sz = 3657.1460,-3630.9497,138.0008
				s_time = 7.5
			elseif Dungeon_move == 51 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7.5
			elseif Dungeon_move == 53 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 55 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			end

			local Count = 0
			local Pet_Stay = false -- 水宝宝被蝙蝠卡bug

			for i = 1,#Monster do 
				local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
				local guid = awm.ObjectId(Monster[i])
				if distance <= 7 and guid ~= 10461 and guid ~= 10536 and guid ~= 10441 then
					Count = Count + 1
				end
				if Count >= 3 then
					if Dungeon_move >= 19 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
				if (Dungeon_move == 18 or Dungeon_move == 26) and CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
				    s_time = 6
				end

				if (guid == 10384 or guid == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
				    awm.TargetUnit(Monster[i])
				    awm.RunMacroText("/跳舞")
				end

				if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
				    Pet_Stay = true
				end

				if guid == 10408 and Dungeon_move == 20 then
				    s_time = 6.2
				end
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
					if not Pet_Attack then
						Pet_Attack = true
						C_Timer.After(0.5,function() Pet_Attack = false end)
						awm.PetWait()
						awm.PetPassiveMode()
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
					local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end

					if Dungeon_move >= 22 and Dungeon_move <= 35 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3649.97,-3561.99,138.13)
						end
					elseif Dungeon_move >= 46 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3665.2993,-3616.3259,137.7217)
						end
					end
				end 
			end

			if CheckBuff("player",rs["冰冷血脉"]) and s_time > 6.2 then
				s_time = 6.2
			end

			if ST_Timer then
				local time = GetTime() - ST_Time
				if time >= s_time then
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
			    if Dungeon_move == 14 and not CheckBuff("player",rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
					return
				end

				if (UnitPower("player") > 2000 or CheckBuff("player",rs["节能施法"])) and Dungeon_move ~= 41 and (not ST_Timer or GetTime() - ST_Time < 4) then
					awm.CastSpellByName(rs["暴风雪"])
				else
					awm.CastSpellByName(rs["暴风雪(等级 1)"])
				end
				if awm.IsAoEPending() then
					awm.ClickPosition(sx,sy,sz)
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
				end

				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end
			else
				if not ST_Timer then
					ST_Timer = true
					ST_Time = GetTime()
				end
			end
			return
		end

		if Dungeon_move == 40 then
		    local Monster = Combat_Scan()
			local Forzen = false
			for i = 1,#Monster do
			    local ThisUnit = Monster[i]
				local Debuff = CheckDebuffByName(ThisUnit,rs["冰冻术"])

				if Debuff then
				    Forzen = true
				end
			end

			if not Forzen then
			    awm.SpellStopCasting()
				Dungeon_move = Dungeon_move + 1
				ST_Timer = false
				return
			end

		    if ST_Timer then
			    if GetTime() - ST_Time >= 4.5 then
				    awm.SpellStopCasting()
					Dungeon_move = Dungeon_move + 1
					ST_Timer = false
					return
				end
			end

		    if not CastingBarFrame:IsVisible() then
			    if Spell_Castable(rs["唤醒"]) then
				    awm.CastSpellByName(rs["唤醒"])
				end
				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			else
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			end
			return
		end

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 13 or Dungeon_move == 19 or Dungeon_move == 23 or Dungeon_move == 27 or Dungeon_move == 31 or Dungeon_move == 39 or Dungeon_move == 44 or Dungeon_move == 48 or Dungeon_move == 52 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and (UnitPower("player") >= 1000 or Dungeon_move == 39) then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			elseif Dungeon_move == 15 or Dungeon_move == 25 or Dungeon_move == 31 or Dungeon_move == 33 or Dungeon_move == 42 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    awm.CastSpellByName(rs["冰霜新星"])
				end
			else
			    if Distance >= 5 and (Dungeon_move < 2 or Dungeon_move > 13) then
					local Monster = Combat_Scan()
					for i = 1,#Monster do
						local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
						if (distance <= 8 or (awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200)) and Distance >= 5 then
							if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
								awm.CastSpellByName(rs["寒冰护体"])
							end
						end

						-- 10390 骷髅守护者
						if Distance >= 5 and awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200 and Dungeon_move <= 24 then
							if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
								awm.CastSpellByName(rs["防护冰霜结界"])
							end
						end

						if (awm.ObjectId(Monster[i]) == 10384 or awm.ObjectId(Monster[i]) == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
							awm.TargetUnit(Monster[i])
							awm.RunMacroText("/跳舞")
						end
					end
				end
			end

			if Dungeon_move < 10 then
			    local target = nil
				for i = 1,awm.GetObjectCount() do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
					if guid == 10411 and awm.UnitCanAttack("player",ThisUnit) and not UnitIsDead(ThisUnit) and distance <= 30 and hit == 0 then
						target = ThisUnit
					end
				end

				if target then
				    local tarx,tary,tarz = awm.ObjectPosition(target)
					local distance = awm.GetDistanceBetweenObjects("player",target)

					if Spell_Castable(rs["火焰冲击"]) and distance <= 19 then
						if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["火焰冲击"],target)
							awm.SpellStopCasting()
							return
						else
							FacePosition(tarx,tary,tarz)
							return
						end
					elseif Spell_Castable(rs["法术反制"]) and distance <= 29 then
					     awm.CastSpellByName(rs["法术反制"],target)
					end
				end
			end

			if Dungeon_move == 21 and PetHasActionBar() then
			    if Spell_Castable(rs["冰冻术"]) then
					awm.CastSpellByName(rs["冰冻术"])
				end
				if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
					awm.ClickPosition(3649.97,-3561.99,138.13)
				end

			end

			if (Dungeon_move == 19 or Dungeon_move == 21) and not CheckBuff("player",rs["冰冷血脉"]) and Spell_Castable(rs["冰冷血脉"]) then
			    awm.CastSpellByName(rs["冰冷血脉"],'player')
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
			else
				awm.MoveTo(x,y,z)		
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			local Monster = Combat_Scan()
			if #Monster == 0 and not UnitAffectingCombat("player") and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 3 then
					    Dungeon_move = #Path + 1
						return
					end
				end
				return
			elseif (#Monster == 2 or #Monster == 1) and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 1.5 then
					    Dungeon_move = 100
						return
					end
				end
				return
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
				    local target = nil
					for i = 1,awm.GetObjectCount() do
					    local ThisUnit = awm.GetObjectWithIndex(i)
					    local guid = awm.ObjectId(ThisUnit)
						local distance_pet = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if guid == 10411 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and distance_pet <= 50 and distance_pet >= 35 then
						    target = ThisUnit
						elseif guid == 10411 and awm.UnitIsDead(ThisUnit) then
						    if not Pet_Attack then
								Pet_Attack = true
								C_Timer.After(0.5,function() Pet_Attack = false end)
								awm.PetWait()
								awm.PetPassiveMode()
							end
						end
					end

					if target then
					    awm.PetAttack(target)
				    else
						if not Pet_Attack then
							Pet_Attack = true
							C_Timer.After(0.5,function() Pet_Attack = false end)
							awm.PetWait()
							awm.PetPassiveMode()
						end
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
				    local Pet_Stay = false
					for i = 1,#Monster do 
						local guid = awm.ObjectId(Monster[i])
						if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
							Pet_Stay = true
						end
					end
				    local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end
				end 
			end

			if Dungeon_move == 1 then
			    if Spell_Castable(rs["寒冰护体"]) then
				    awm.CastSpellByName(rs["寒冰护体"])
					return
				end
				if Spell_Castable(rs["防护冰霜结界"]) then
				    awm.CastSpellByName(rs["防护冰霜结界"])
					return
				end

				if Easy_Data["法师魔甲术"] and not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				    awm.CastSpellByName(rs["法师魔甲术"],"player")
					return
				end

				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 200
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(3657,-3493,136,x1,y1,z1)
					if guid == 10414 and not awm.ObjectIsPlayer(ThisUnit) then
					    if distance <= 10 then
						    Dungeon_move = Dungeon_move + 1
							return
						else
						    target = ThisUnit
						end
					end
				end

				if not target then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			    return
			end

			if Dungeon_move == 10 or Dungeon_move == 36 then -- 水元素
			    if Spell_Castable(rs["召唤水元素"]) then
			        awm.CastSpellByName(rs["召唤水元素"])
				end
				if PetHasActionBar() then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 11 or Dungeon_move == 37 then -- 冰箱
			    if Spell_Castable(rs["寒冰屏障"]) then
			        awm.CastSpellByName(rs["寒冰屏障"])
				end
				if CheckBuff("player",rs["寒冰屏障"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 12 or Dungeon_move == 38 then -- 冰冻术
			    local sx,sy,sz = 0,0,0
				if Dungeon_move == 12 then                    sx,sy,sz = 3636.0408,-3517.6003,136.4553                  
                elseif Dungeon_move == 38 then
				    sx,sy,sz = 3711.9927,-3603.2114,141.2154
				end
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time >= 9.3 then
					    if not awm.IsAoEPending() then
						    awm.CastSpellByName(rs["冰冻术"])
						else
						    awm.ClickPosition(sx,sy,sz)
							Dungeon_move = Dungeon_move + 1
							ST_Timer = false
							return
						end
					end
				end
				return
			end

			if Dungeon_move == 13 or Dungeon_move == 39 then -- 冰冷血脉
			    local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
				local endtime4 = starttime4 + duration4

				if CheckBuff('player',rs["冰冷血脉"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end

				if endtime4 - GetTime() <= 1 then
					awm.CastSpellByName(rs["冰冷血脉"])
					return
				else
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 35 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 10 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if UnitAffectingCombat("player") then
		    Dungeon_step1 = 9
			Dungeon_move = 100
			return
		end

		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 91
			return
		end
		if #body_list > 0 then
			if not Body_Choose then
				Body_Target = body_list[1].Unit
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
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 11 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 2
			Dungeon_move = 100
			return
		end
	end
	if Dungeon_step1 == 12 then -- 等冰箱和水元素
	    Note_Head = Check_UI("等待冰箱和水元素","Waiting Spell Duration")
		if not awm.UnitAffectingCombat("player") then
		    local starttime1, duration1, enabled, _ = GetSpellCooldown(rs["寒冰屏障"])
			local endtime1 = starttime1 + duration1
			if endtime1 - GetTime() >= 20 then
			    Note_Set("冰箱")
			    return
			end

			local starttime2, duration2, enabled, _ = GetSpellCooldown(rs["召唤水元素"])
			local endtime2 = starttime2 + duration2
			if endtime2 - GetTime() >= 20 then
			    Note_Set("水元素")
			    return
			end

			local starttime3, duration3, enabled, _ = GetSpellCooldown(rs["急速冷却"])
			local endtime3 = starttime3 + duration3
			if endtime3 - GetTime() >= 200 then
			    Note_Set("急速冷却")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["唤醒"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 200 then
			    Note_Set("唤醒")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 20 then
			    Note_Set("冰冷血脉")
			    return
			end

			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 3
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 13 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = 9
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 14 then -- 开锁 
	    Note_Head = Check_UI("打开大门","Open Gate")

		local Path = 
		{
		{3644.63,-3537.30,138.01},
		{3638.27,-3529.36,137.52},
		{3616.13,-3523.76,138.10},
		{3602.22,-3504.87,137.20},
		{3589.58,-3487.27,135.34},
		{3577.58,-3470.57,135.72},
		{3573.2935,-3462.6533,136.1030},
		{3572.76,-3452.82,135.93},
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 0.9 then
		    ST_Timer = false

			
			if Distance >= 5 then
				if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
		    else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == #Path then
			    if UnitAffectingCombat("player") then
				    CombatSystem(Combat_Scan()[1])
					return
				else
				    if not NeedHeal() then
						Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 				return
	 				end
				end
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 15 then -- 开国王广场大门
	    local x,y,z = 3572.7393,-3452.8547,135.9237
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if distance >= 1 then
		    Run(x,y,z)
		else
		    local total = awm.GetObjectCount()
			local Far_Distance = 20
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if guid == 175352 and not CastingBarFrame:IsVisible() then
                    awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end

		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
				return
			else
			    local time = GetTime() - ST_Time
				if time >= 2.5 and not CastingBarFrame:IsVisible() then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end

	if Dungeon_step1 == 16 then -- 开国王广场大门
	    local x,y,z = 3556.9065,-3436.1270,136.2311
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if distance >= 1 then
			local total = awm.GetObjectCount()
			local Far_Distance = 6
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if (guid == 175353 or guid == 175352) and awm.GetDistanceBetweenObjects("player",ThisUnit) < Far_Distance then
					awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end
		    Run(x,y,z)
		else
		    local total = awm.GetObjectCount()
			local Far_Distance = 20
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if guid == 175353 and not CastingBarFrame:IsVisible() then
                    awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end

		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
				return
			else
			    local time = GetTime() - ST_Time
				if time >= 2.5 and not CastingBarFrame:IsVisible() then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end

    if Dungeon_step1 == 17 then -- 前往第三波 
	    Note_Head = Check_UI("前往目标 - 3","Go target position - 3")

		local Path = 
		{
		{3553.91,-3433.42,135.87},
		{3556.07,-3427.62,136.58},
		{3555.70,-3422.11,136.83},
		{3555.21,-3417.68,136.85},
		{3551.43,-3411.25,135.73},
		{3548.21,-3407.28,134.50},
		{3524.26,-3401.95,133.33}, -- 7 闪现
		{3508.40,-3400.53,134.93}, -- 8 隐身
		{3494.11,-3399.97,136.74}, -- 9 等5秒
		{3492.7207,-3399.5957,136.9256},
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move >= 8 and UnitAffectingCombat("player") and Spell_Castable(rs["隐形术"]) then
			    awm.CastSpellByName(rs["隐形术"])
			end
			
			if Dungeon_move == 7 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and UnitPower("player") >= 1000 then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else

			    if Distance >= 5 and not CheckBuff("player",rs["隐形术"]) then
					if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					    awm.CastSpellByName(rs["寒冰护体"])
					end
				end
			end

			local total = awm.GetObjectCount()
			local Far_Distance = 6
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if (guid == 175353 or guid == 175352) and awm.GetDistanceBetweenObjects("player",ThisUnit) < Far_Distance then
					awm.InteractUnit(ThisUnit)
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
		    else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then
		    if Dungeon_move == 9 then
			    if not ST_Timer then
				    ST_Time = GetTime()
					ST_Timer = true
				else
				    if GetTime() - ST_Time > 10 then
					    awm.RunMacroText("/cancelAura "..rs["隐形术"])
					    Dungeon_move = Dungeon_move + 1
						return
					end
				end
			    return
			end

			if Dungeon_move == 10 then
			    if Spell_Castable(rs["寒冰护体"]) then
				    awm.CastSpellByName(rs["寒冰护体"])
				end
				local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 200
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(3550,-3349,129,x1,y1,z1)
					if guid == 10414 and not awm.ObjectIsPlayer(ThisUnit) then
					    if distance <= 15 then
						    Dungeon_move = Dungeon_move + 1
							return
						else
						    target = ThisUnit
						end
					end
				end

				if not target then
				    Dungeon_move = Dungeon_move + 1
					return
				end
			    return
			end

			HasStop = false

			Dungeon_move = Dungeon_move + 1
		end
	end

	if Dungeon_step1 == 18 then -- 3 
	    Note_Head = Check_UI("拉怪 - 3","Pulling mobs - 3")

		local Path = 
		{
		{3472.9138,-3391.4158,138.0291},
		{3463.9346,-3382.1545,138.0547},
		{3463.9346,-3382.1545,138.0547}, -- 3 冰枪 3437,-3377,141
		{3492.4426,-3400.2078,136.9854},
		{3509.3604,-3399.5193,134.8136},
		{3542.3616,-3368.8394,132.0437}, -- 6 闪现
		{3542.3616,-3368.8394,132.0437}, -- 7 冰枪 3563,-3347,129
		{3537.9099,-3381.7290,132.3765},
		{3537.9099,-3381.7290,132.3765}, -- 9 反制 3534,-3350,131
		{3547.3589,-3415.8579,135.1982}, -- 10 冰环
		{3554.5859,-3433.7131,135.9305}, -- 11 开门
		{3570.7734,-3450.1899,136.2460}, -- 12 开门 175353 和 175352
		{3577.8262,-3457.3340,135.5790}, -- 13
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 3 or Dungeon_move == 7 or Dungeon_move == 9 then -- 冰枪
			local Scan_Distance = 5
			if Dungeon_move == 3 then
				Target_ID = nil
				tarx,tary,tarz = 3437,-3377,141
				Scan_Distance = 10
			elseif Dungeon_move == 7 then
				Target_ID = nil
				tarx,tary,tarz = 3563,-3347,129
				Scan_Distance = 10
			elseif Dungeon_move == 9 then
				Target_ID = nil
				tarx,tary,tarz = 3534,-3350,131
				Scan_Distance = 10
			end
			if Target_Monster == nil then
				Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
			else
				awm.TargetUnit(Target_Monster)
				if IsFacing(tarx,tary,tarz) then
					awm.CastSpellByName(rs["冰枪术"],Target_Monster)
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				else
					FacePosition(tarx,tary,tarz)
					return
				end
			end
			if Target_Monster == nil then
				Dungeon_move = Dungeon_move + 1
				awm.SpellStopCasting()
				Target_Monster = nil
			end
			return
		end

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 6 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and UnitPower("player") >= 1000 then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					    awm.CastSpellByName(rs["寒冰护体"])
					end
					if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
					    awm.CastSpellByName(rs["防护冰霜结界"])
					end
				end
			end

			if Dungeon_move == 11 or Dungeon_move == 12 or Dungeon_move == 13 then
				local total = awm.GetObjectCount()
				local Far_Distance = 6
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					if guid == 175353 or guid == 175352 then
						awm.InteractUnit(ThisUnit)
					end
				end
			end

			if Dungeon_move < 10 then
			    local target = nil
				for i = 1,awm.GetObjectCount() do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
					if guid == 10411 and awm.UnitCanAttack("player",ThisUnit) and not UnitIsDead(ThisUnit) and distance <= 30 and hit == 0 then
						target = ThisUnit
					end
				end

				if target then
				    local tarx,tary,tarz = awm.ObjectPosition(target)
					local distance = awm.GetDistanceBetweenObjects("player",target)

					if Spell_Castable(rs["火焰冲击"]) and distance <= 19 then
						if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["火焰冲击"],target)
							awm.SpellStopCasting()
							return
						else
							FacePosition(tarx,tary,tarz)
							return
						end
					elseif Spell_Castable(rs["法术反制"]) and distance <= 29 then
					     awm.CastSpellByName(rs["法术反制"],target)
					end
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
			else
				awm.MoveTo(x,y,z)		
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false


			if Dungeon_move == 10 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    awm.CastSpellByName(rs["冰霜新星"])
				end
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 19 then -- 3 A怪 
	    Note_Head = Check_UI("A怪 - 3","Killing mobs - 3")

		local Path = 
		{
		{3629.7747,-3497.6328,136.7849}, -- 1 闪现
		{3634.9985,-3500.0176,136.4113},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578}, -- 4 下雪 3624.5344,-3497.0469,137.0162
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578}, -- 10 召唤水元素
		{3636.0408,-3517.6003,136.4553}, -- 11 冰箱
		{3636.0408,-3517.6003,136.4553}, -- 12 水元素冰环 3636.0408,-3517.6003,136.4553
		{3644.0093,-3538.4866,138.0452}, -- 13 闪现 出冰箱
		{3644.0093,-3538.4866,138.0452}, -- 14 下雪 3637.6011,-3521.3430,136.6640
		{3650.2004,-3552.5488,137.9645}, -- 15 冰环
		{3650.2004,-3552.5488,137.9645}, -- 16 下雪 3642.0220,-3532.8958,137.7797
		{3651.5037,-3557.2703,137.9756},
		{3651.5037,-3557.2703,137.9756}, -- 18 下雪 3642.6838,-3535.6047,138.0004
		{3654.7720,-3580.8950,137.7351}, -- 19 闪现
		{3654.7720,-3580.8950,137.7351}, -- 20 下雪 3645.6770,-3547.5342,138.0702
		{3655.2205,-3589.4680,137.3052}, 
		{3655.2205,-3589.4680,137.3052}, -- 22 下雪 3650.0813,-3560.8684,138.0677
		{3648.6458,-3619.1865,137.4443}, -- 23 闪现
		{3648.6458,-3619.1865,137.4443}, -- 24 下雪 3652.6650,-3583.9929,137.7617	
		{3651.7388,-3625.9390,137.7706}, -- 25 冰环
		{3651.7388,-3625.9390,137.7706}, -- 26 下雪 3653.6885,-3601.5833,137.1192
		{3668.7336,-3650.4902,138.5838}, -- 27 闪现
		{3668.7336,-3650.4902,138.5838}, -- 28 下雪 3656.3169,-3629.3784,137.9371
		{3677.6826,-3662.0789,138.5768}, -- 29 冰环
		{3677.6826,-3662.0789,138.5768}, -- 30 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 31 闪现
        {3699.5996,-3652.0259,139.1076}, -- 32 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 34 下雪 3696.5029,-3648.8608,139.2266
		{3698.6372,-3618.3665,140.0967}, -- 35 急冷
		{3699.4294,-3611.9712,139.6280}, -- 36 召唤水元素
		{3711.9927,-3603.2114,141.2154}, -- 37 冰箱
		{3711.9927,-3603.2114,141.2154}, -- 38 水元素冰环 3711.9927,-3603.2114,141.2154
		{3681.1082,-3602.8723,137.5952}, -- 39 冰环 闪现 出冰箱
		{3681.1082,-3602.8723,137.5952}, -- 40 唤醒 5s
		{3681.1082,-3602.8723,137.5952}, -- 41 下雪 3705.9221,-3604.6782,140.3820
		{3670.9695,-3605.1873,137.0954},
		{3670.9695,-3605.1873,137.0954}, -- 43 下雪 3695.9614,-3604.9395,138.9726
		{3651.9612,-3618.4634,137.3329}, -- 44 闪现
		{3651.9612,-3618.4634,137.3329}, -- 45 下雪 3682.2654,-3609.0073,137.9412
		{3644.2390,-3624.7107,137.8329}, -- 46 水元素冰环 3665.2993,-3616.3259,137.7217
		{3644.2390,-3624.7107,137.8329}, -- 47 下雪 3665.2993,-3616.3259,137.7217
		{3671.7183,-3653.8928,138.6474}, -- 48 闪现
		{3671.7183,-3653.8928,138.6474}, -- 49 下雪 3657.1460,-3630.9497,138.0008
		{3677.6826,-3662.0789,138.5768},
		{3677.6826,-3662.0789,138.5768}, -- 51 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 52 闪现
        {3699.5996,-3652.0259,139.1076}, -- 53 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 55 下雪 3696.5029,-3648.8608,139.2266
		}

		if Dungeon_move == 100 then -- 剩下一只怪
			local Monster = Combat_Scan()

			if #Monster == 0 and not UnitAffectingCombat("player") then
			    Dungeon_move = #Path + 1
				return
			end

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 4 or Dungeon_move == 14 or Dungeon_move == 16 or Dungeon_move == 18 or Dungeon_move == 20 or Dungeon_move == 22 or Dungeon_move == 24 or Dungeon_move == 26 or Dungeon_move == 28 or Dungeon_move == 30 or Dungeon_move == 32 or Dungeon_move == 34 or Dungeon_move == 41 or Dungeon_move == 43 or Dungeon_move == 45 or Dungeon_move == 47 or Dungeon_move == 49 or Dungeon_move == 51 or Dungeon_move == 53 or Dungeon_move == 55 then -- 暴风雪
			local sx,sy,sz = 0,0,0
			local s_time = 1.5
			local Monster = Combat_Scan()

			if Dungeon_move == 4 then
				sx,sy,sz = 3624.5344,-3497.0469,137.0162
				s_time = 4
			elseif Dungeon_move == 14 then
				sx,sy,sz = 3637.6011,-3521.3430,136.6640
				s_time = 6
			elseif Dungeon_move == 16 then
				sx,sy,sz = 3642.0220,-3532.8958,137.7797
				s_time = 4
			elseif Dungeon_move == 18 then
				sx,sy,sz = 3642.6838,-3535.6047,138.0004
				s_time = 5
			elseif Dungeon_move == 20 then
				sx,sy,sz = 3645.6770,-3547.5342,138.0702
				s_time = 7
			elseif Dungeon_move == 22 then
				sx,sy,sz = 3650.0813,-3560.8684,138.0677
				s_time = 7
			elseif Dungeon_move == 24 then
				sx,sy,sz = 3652.6650,-3583.9929,137.7617
				s_time = 7.5
			elseif Dungeon_move == 26 then
				sx,sy,sz = 3653.6885,-3601.5833,137.1192
				s_time = 7.5
			elseif Dungeon_move == 28 then
				sx,sy,sz = 3656.3169,-3629.3784,137.9371
				s_time = 7
            elseif Dungeon_move == 30 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7
			elseif Dungeon_move == 32 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 34 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			elseif Dungeon_move == 41 then
				sx,sy,sz = 3705.9221,-3604.6782,140.3820
				s_time = 2.3
			elseif Dungeon_move == 43 then
				sx,sy,sz = 3695.9614,-3604.9395,138.9726
				s_time = 7
			elseif Dungeon_move == 45 then
				sx,sy,sz = 3682.2654,-3609.0073,137.9412
				s_time = 7
			elseif Dungeon_move == 47 then
				sx,sy,sz = 3665.2993,-3616.3259,137.7217
				s_time = 7.5
			elseif Dungeon_move == 49 then
				sx,sy,sz = 3657.1460,-3630.9497,138.0008
				s_time = 7.5
			elseif Dungeon_move == 51 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7.5
			elseif Dungeon_move == 53 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 55 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			end

			local Count = 0
			local Pet_Stay = false -- 水宝宝被蝙蝠卡bug

			for i = 1,#Monster do 
				local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
				local guid = awm.ObjectId(Monster[i])
				if distance <= 7 and guid ~= 10461 and guid ~= 10536 and guid ~= 10441 then
					Count = Count + 1
				end
				if Count >= 3 then
					if Dungeon_move >= 19 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
				if (Dungeon_move == 18 or Dungeon_move == 26) and CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
				    s_time = 6
				end

				if (guid == 10384 or guid == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
				    awm.TargetUnit(Monster[i])
				    awm.RunMacroText("/跳舞")
				end

				if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
				    Pet_Stay = true
				end

				if guid == 10408 and Dungeon_move == 20 then
				    s_time = 6.2
				end
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
					if not Pet_Attack then
						Pet_Attack = true
						C_Timer.After(0.5,function() Pet_Attack = false end)
						awm.PetWait()
						awm.PetPassiveMode()
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
					local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end

					if Dungeon_move >= 22 and Dungeon_move <= 35 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3649.97,-3561.99,138.13)
						end
					elseif Dungeon_move >= 46 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3665.2993,-3616.3259,137.7217)
						end
					end
				end 
			end

			if CheckBuff("player",rs["冰冷血脉"]) and s_time > 6.2 then
				s_time = 6.2
			end

			if ST_Timer then
				local time = GetTime() - ST_Time
				if time >= s_time then
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
			    if Dungeon_move == 14 and not CheckBuff("player",rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
					return
				end

				if (UnitPower("player") > 2000 or CheckBuff("player",rs["节能施法"])) and Dungeon_move ~= 4 and Dungeon_move ~= 41 and (not ST_Timer or GetTime() - ST_Time < 4) then
					awm.CastSpellByName(rs["暴风雪"])
				else
					awm.CastSpellByName(rs["暴风雪(等级 1)"])
				end
				if awm.IsAoEPending() then
					awm.ClickPosition(sx,sy,sz)
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
				end

				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end
			else
				if not ST_Timer then
					ST_Timer = true
					ST_Time = GetTime()
				end
			end
			return
		end

		if Dungeon_move == 40 then
		    local Monster = Combat_Scan()
			local Forzen = false
			for i = 1,#Monster do
			    local ThisUnit = Monster[i]
				local Debuff = CheckDebuffByName(ThisUnit,rs["冰冻术"])

				if Debuff then
				    Forzen = true
				end
			end

			if not Forzen then
			    awm.SpellStopCasting()
				Dungeon_move = Dungeon_move + 1
				ST_Timer = false
				return
			end

		    if ST_Timer then
			    if GetTime() - ST_Time >= 4.5 then
				    awm.SpellStopCasting()
					Dungeon_move = Dungeon_move + 1
					ST_Timer = false
					return
				end
			end

		    if not CastingBarFrame:IsVisible() then
			    if Spell_Castable(rs["唤醒"]) then
				    awm.CastSpellByName(rs["唤醒"])
				end

				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			else
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			end
			return
		end

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 1 or Dungeon_move == 13 or Dungeon_move == 19 or Dungeon_move == 23 or Dungeon_move == 27 or Dungeon_move == 31 or Dungeon_move == 39 or Dungeon_move == 44 or Dungeon_move == 48 or Dungeon_move == 52 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and (UnitPower("player") >= 1000 or Dungeon_move == 39) then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			elseif Dungeon_move == 15 or Dungeon_move == 25 or Dungeon_move == 31 or Dungeon_move == 33 or Dungeon_move == 42 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    awm.CastSpellByName(rs["冰霜新星"])
				end
			else
			    if Distance >= 5 and (Dungeon_move < 2 or Dungeon_move > 13) then
					local Monster = Combat_Scan()
					for i = 1,#Monster do
						local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
						if (distance <= 8 or (awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200)) and Distance >= 5 then
							if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
								awm.CastSpellByName(rs["寒冰护体"])
							end
						end

						-- 10390 骷髅守护者
						if Distance >= 5 and awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200 and Dungeon_move <= 24 then
							if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
								awm.CastSpellByName(rs["防护冰霜结界"])
							end
						end

						if (awm.ObjectId(Monster[i]) == 10384 or awm.ObjectId(Monster[i]) == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
							awm.TargetUnit(Monster[i])
							awm.RunMacroText("/跳舞")
						end
					end
				end
			end

			if Dungeon_move == 3 then
			    if Easy_Data["法师魔甲术"] and not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				    awm.CastSpellByName(rs["法师魔甲术"],"player")
					return
				end
			end

			awm.MoveTo(x,y,z)		

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			local Monster = Combat_Scan()
			if #Monster == 0 and not UnitAffectingCombat("player") and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 3 then
					    Dungeon_move = #Path + 1
						return
					end
				end
				return
			elseif (#Monster == 2 or #Monster == 1) and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 1.5 then
					    Dungeon_move = 100
						return
					end
				end
				return
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
				    local target = nil
					for i = 1,awm.GetObjectCount() do
					    local ThisUnit = awm.GetObjectWithIndex(i)
					    local guid = awm.ObjectId(ThisUnit)
						local distance_pet = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if guid == 10411 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and distance_pet <= 50 and distance_pet >= 35 then
						    target = ThisUnit
						elseif guid == 10411 and awm.UnitIsDead(ThisUnit) then
						    if not Pet_Attack then
								Pet_Attack = true
								C_Timer.After(0.5,function() Pet_Attack = false end)
								awm.PetWait()
								awm.PetPassiveMode()
							end
						end
					end

					if target then
					    awm.PetAttack(target)
				    else
						if not Pet_Attack then
							Pet_Attack = true
							C_Timer.After(0.5,function() Pet_Attack = false end)
							awm.PetWait()
							awm.PetPassiveMode()
						end
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
				    local Pet_Stay = false
					for i = 1,#Monster do 
						local guid = awm.ObjectId(Monster[i])
						if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
							Pet_Stay = true
						end
					end
				    local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end
				end 
			end

			if Dungeon_move == 10 or Dungeon_move == 36 then -- 水元素
			    if Spell_Castable(rs["召唤水元素"]) then
			        awm.CastSpellByName(rs["召唤水元素"])
				end
				if PetHasActionBar() then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 11 or Dungeon_move == 37 then -- 冰箱
			    if Spell_Castable(rs["寒冰屏障"]) then
			        awm.CastSpellByName(rs["寒冰屏障"])
				end
				if CheckBuff("player",rs["寒冰屏障"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 12 or Dungeon_move == 38 then -- 冰冻术
			    local sx,sy,sz = 0,0,0
				if Dungeon_move == 12 then                    sx,sy,sz = 3636.0408,-3517.6003,136.4553                  
                elseif Dungeon_move == 38 then
				    sx,sy,sz = 3711.9927,-3603.2114,141.2154
				end
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time >= 9.3 then
					    if not awm.IsAoEPending() then
						    awm.CastSpellByName(rs["冰冻术"])
						else
						    awm.ClickPosition(sx,sy,sz)
							Dungeon_move = Dungeon_move + 1
							ST_Timer = false
							return
						end
					end
				end
				return
			end

			if Dungeon_move == 13 or Dungeon_move == 39 then -- 冰冷血脉
			    local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
				local endtime4 = starttime4 + duration4

				if CheckBuff('player',rs["冰冷血脉"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end

				if endtime4 - GetTime() <= 1 then
					awm.CastSpellByName(rs["冰冷血脉"])
					return
				else
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 35 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			Dungeon_move = Dungeon_move + 1
		end
	end

	if Dungeon_step1 == 20 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if UnitAffectingCombat("player") then
		    Dungeon_step1 = 19
			Dungeon_move = 100
			return
		end

		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 91
			return
		end
		if #body_list > 0 then
			if not Body_Choose then
				Body_Target = body_list[1].Unit
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
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 21 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 2
			Dungeon_move = 100
			return
		end
	end
	if Dungeon_step1 == 22 then -- 开锁 
	    Note_Head = Check_UI("打开大门 - 2","Open Gate - 2")

		local Path = 
		{
		{3644.63,-3537.30,138.01},
		{3638.27,-3529.36,137.52},
		{3616.13,-3523.76,138.10},
		{3602.22,-3504.87,137.20},
		{3589.58,-3487.27,135.34},
		{3577.58,-3470.57,135.72},
		{3573.2935,-3462.6533,136.1030},
		{3572.76,-3452.82,135.93},
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 0.9 then
		    ST_Timer = false

			
			if Distance >= 5 then
				if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
		    else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == #Path then
			    if UnitAffectingCombat("player") then
				    CombatSystem(Combat_Scan()[1])
					return
				else
				    if not NeedHeal() then
						Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 				return
	 				end
				end
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 23 then -- 开国王广场大门
	    local x,y,z = 3572.7393,-3452.8547,135.9237
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if distance >= 1 then
		    Run(x,y,z)
		else
		    local total = awm.GetObjectCount()
			local Far_Distance = 20
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if guid == 175352 and not CastingBarFrame:IsVisible() then
                    awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end

		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
				return
			else
			    local time = GetTime() - ST_Time
				if time >= 2.5 and not CastingBarFrame:IsVisible() then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end

	if Dungeon_step1 == 24 then -- 开国王广场大门
	    local x,y,z = 3556.9065,-3436.1270,136.2311
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if distance >= 1 then
		    local total = awm.GetObjectCount()
			local Far_Distance = 6
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if (guid == 175353 or guid == 175352) and awm.GetDistanceBetweenObjects("player",ThisUnit) < Far_Distance then
					awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end
		    Run(x,y,z)
		else
		    local total = awm.GetObjectCount()
			local Far_Distance = 20
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if guid == 175353 and not CastingBarFrame:IsVisible() then
                    awm.InteractUnit(ThisUnit)
				end
				if CastingBarFrame:IsVisible() then
				    return
				end
			end

		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
				return
			else
			    local time = GetTime() - ST_Time
				if time >= 2.5 and not CastingBarFrame:IsVisible() then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end
	if Dungeon_step1 == 25 then -- 前往第四波 
	    Note_Head = Check_UI("前往目标 - 4","Go target position - 4")

		local Path = 
		{
		{3554.07,-3434.26,135.95},
		{3555.43,-3427.86,136.22},
		{3556.11,-3421.75,136.89},
		{3553.77,-3413.19,136.21},
		{3551.71,-3406.35,135.14},
		{3551.23,-3395.38,133.35},
		{3555.54,-3373.75,132.91},
		{3558.03,-3361.81,132.34},
		{3563.16,-3355.80,131.82},
		{3571.18,-3351.38,130.58},
		{3576.84,-3348.08,129.67},
		{3587.93,-3345.46,128.40},
		{3594.87,-3341.20,127.35},
		{3603.68,-3336.32,125.50},
		{3610.81,-3335.65,124.29},
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Distance > 0.9 then
		    ST_Timer = false


			if Distance >= 5  then
				if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
				end
			end

			local total = awm.GetObjectCount()
			local Far_Distance = 6
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				if (guid == 175353 or guid == 175352) and awm.GetDistanceBetweenObjects("player",ThisUnit) < Far_Distance then
					awm.InteractUnit(ThisUnit)
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
		    else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then

			HasStop = false

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 26 then
	    if UnitAffectingCombat("player") then
		    ST_Timer = false
		    if Spell_Castable(rs["魔爆术"]) then
			    awm.CastSpellByName(rs["魔爆术"])
			end
			return
		else
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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
		    if not ST_Timer then
			    ST_Timer = true
				ST_Time = GetTime()
			else
			    if GetTime() - ST_Time > 5 then
				    Dungeon_step1 = Dungeon_step1 + 1
					ST_Timer = false
					return
				end
			end
		end
	end
	if Dungeon_step1 == 27 then -- 等冰箱和水元素
	    Note_Head = Check_UI("等待冰箱和水元素","Waiting Spell Duration")
		if not awm.UnitAffectingCombat("player") then
		    local starttime1, duration1, enabled, _ = GetSpellCooldown(rs["寒冰屏障"])
			local endtime1 = starttime1 + duration1
			if GetTime() < endtime1 then
			    Note_Set("冰箱")
			    return
			end

			local starttime2, duration2, enabled, _ = GetSpellCooldown(rs["召唤水元素"])
			local endtime2 = starttime2 + duration2
			if GetTime() < endtime2 then
			    Note_Set("水元素")
			    return
			end

			local starttime3, duration3, enabled, _ = GetSpellCooldown(rs["急速冷却"])
			local endtime3 = starttime3 + duration3
			if endtime3 - GetTime() >= 160 then
			    Note_Set("急速冷却")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["唤醒"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 185 then
			    Note_Set("唤醒")
			    return
			end

			local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
			local endtime4 = starttime4 + duration4
			if endtime4 - GetTime() >= 20 then
			    Note_Set("冰冷血脉")
			    return
			end

			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    local Monster = Combat_Scan()

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end
	end
	if Dungeon_step1 == 28 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

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
			if not CheckBuff("player",rs["魔法抑制"]) and Spell_Castable(rs["魔法抑制"]) then
				awm.CastSpellByName(rs["魔法抑制"],"player")
				return
			end
			HasStop = false
			Dungeon_step1 = Dungeon_step1 + 1
			return
		else
		    local Monster = Combat_Scan()

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end
	end
	if Dungeon_step1 == 29 then -- 4 
	    Note_Head = Check_UI("拉怪 - 4","Pulling mobs - 4")

		local Path = 
		{
		{3619.00,-3334.95,123.28},
		{3627.85,-3335.63,122.90},
		{3634.29,-3343.23,125.09},
		{3639.51,-3345.14,125.54},
		{3643.53,-3345.27,125.64},
		{3661.14,-3357.84,126.12}, -- 3661.27,-3358.57,126.11
		{3664.58,-3365.36,126.23},
		{3669.14,-3372.61,127.68},
		{3677.07,-3384.52,130.75},
		{3677.07,-3384.52,130.75}, -- 10 冰枪 3688,-3413,133
		{3672.41,-3376.50,128.68},
		{3656.82,-3350.57,125.75}, -- 12 闪现
		{3636.37,-3339.21,124.04},
		{3624.4951,-3336.4812,123.3563},
		{3624.4951,-3336.4812,123.3563}, -- 15 冰枪 3656,-3329,123
		{3612.5908,-3335.1638,124.0059},
		{3612.5908,-3335.1638,124.0059},
		{3593.1965,-3338.6765,126.8237},
		{3576.9958,-3340.6724,128.7176},
		{3547.2585,-3338.2288,129.3223},
		{3547.2585,-3338.2288,129.3223}, -- 21 冰枪 3513,-3326,131
		{3546.5750,-3346.1414,129.1738},
		{3546.5750,-3346.1414,129.1738}, -- 23 反制 3561,-3323,129
		{3546.7087,-3388.5793,133.0469}, -- 24 闪现
		{3550.6001,-3421.3196,135.9138}, -- 25 冰环
		{3554.5859,-3433.7131,135.9305}, -- 26 开门
		{3570.7734,-3450.1899,136.2460}, -- 27 开门 175353 和 175352
		{3577.8262,-3457.3340,135.5790}, -- 28
		}

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 10 or Dungeon_move == 15 or Dungeon_move == 21 then -- 冰枪
			local Scan_Distance = 5
			if Dungeon_move == 10 then
				Target_ID = nil
				tarx,tary,tarz = 3688,-3413,133
				Scan_Distance = 10
			elseif Dungeon_move == 15 then
				Target_ID = nil
				tarx,tary,tarz = 3656,-3329,123
				Scan_Distance = 10
			elseif Dungeon_move == 21 then
				Target_ID = nil
				tarx,tary,tarz = 3513,-3326,131
				Scan_Distance = 10
			end
			if Target_Monster == nil then
				Target_Monster = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)
			else
				awm.TargetUnit(Target_Monster)
				if IsFacing(tarx,tary,tarz) then
					awm.CastSpellByName(rs["冰枪术"],Target_Monster)
					Dungeon_move = Dungeon_move + 1
					awm.SpellStopCasting()
					Target_Monster = nil
					return
				else
					FacePosition(tarx,tary,tarz)
					return
				end
			end
			if Target_Monster == nil then
				Dungeon_move = Dungeon_move + 1
				awm.SpellStopCasting()
				Target_Monster = nil
			end
			return
		end

		if Dungeon_move == 23 then -- 反制
			if Dungeon_move == 23 then
				Target_ID = nil
				tarx,tary,tarz = 3561,-3323,129
			end
			if Target_Monster == nil then
				local total = awm.GetObjectCount()
				local Far_Distance = 10
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(tarx,tary,tarz,x1,y1,z1)
					if guid ~= 10414 and distance < Far_Distance and not awm.ObjectIsPlayer(ThisUnit) then
						Far_Distance = distance
						Target_Monster = ThisUnit
					end
				end
			else
				awm.TargetUnit(Target_Monster)
				awm.CastSpellByName(rs["法术反制"],Target_Monster)
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

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 12 or Dungeon_move == 24 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and UnitPower("player") >= 1000 then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else

			    if Distance >= 5 and (Dungeon_move < 2 or Dungeon_move > 10) then
					if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					    awm.CastSpellByName(rs["寒冰护体"])
					end
					if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
					    awm.CastSpellByName(rs["防护冰霜结界"])
					end
				end
			end

			if Dungeon_move == 26 or Dungeon_move == 27 or Dungeon_move == 28 then
				local total = awm.GetObjectCount()
				local Far_Distance = 6
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					if guid == 175353 or guid == 175352 then
						awm.InteractUnit(ThisUnit)
					end
				end
			end

			if Dungeon_move < 25 then
				local target = nil
				for i = 1,awm.GetObjectCount() do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
					local flags = bit.bor(0x10, 0x100, 0x1)
					local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
					if guid == 10411 and awm.UnitCanAttack("player",ThisUnit) and not UnitIsDead(ThisUnit) and distance <= 30 and hit == 0 then
						target = ThisUnit
					end
				end

				if target then
				    local tarx,tary,tarz = awm.ObjectPosition(target)
					local distance = awm.GetDistanceBetweenObjects("player",target)

					if Spell_Castable(rs["火焰冲击"]) and distance <= 19 then
						if IsFacing(tarx,tary,tarz) then
							awm.CastSpellByName(rs["火焰冲击"],target)
							awm.SpellStopCasting()
							return
						else
							FacePosition(tarx,tary,tarz)
							return
						end
					elseif Spell_Castable(rs["法术反制"]) and distance <= 29 then
					     awm.CastSpellByName(rs["法术反制"],target)
					end
				end
			end

			if Dungeon_move == 1 then
			    Run(x,y,z)
			else
				awm.MoveTo(x,y,z)		
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false


			if Dungeon_move == 25 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    awm.CastSpellByName(rs["冰霜新星"])
				end
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 30 then -- 4 A怪 
	    Note_Head = Check_UI("A怪 - 4","Killing mobs - 4")

		local Path = 
		{
		{3629.7747,-3497.6328,136.7849}, -- 1 闪现
		{3634.9985,-3500.0176,136.4113},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578}, -- 4 下雪 3624.5344,-3497.0469,137.0162
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578},
		{3640.6785,-3508.9001,137.7578}, -- 10 召唤水元素
		{3636.0408,-3517.6003,136.4553}, -- 11 冰箱
		{3636.0408,-3517.6003,136.4553}, -- 12 水元素冰环 3636.0408,-3517.6003,136.4553
		{3644.0093,-3538.4866,138.0452}, -- 13 闪现 出冰箱
		{3644.0093,-3538.4866,138.0452}, -- 14 下雪 3637.6011,-3521.3430,136.6640
		{3650.2004,-3552.5488,137.9645}, -- 15 冰环
		{3650.2004,-3552.5488,137.9645}, -- 16 下雪 3642.0220,-3532.8958,137.7797
		{3651.5037,-3557.2703,137.9756},
		{3651.5037,-3557.2703,137.9756}, -- 18 下雪 3642.6838,-3535.6047,138.0004
		{3654.7720,-3580.8950,137.7351}, -- 19 闪现
		{3654.7720,-3580.8950,137.7351}, -- 20 下雪 3645.6770,-3547.5342,138.0702
		{3655.2205,-3589.4680,137.3052}, 
		{3655.2205,-3589.4680,137.3052}, -- 22 下雪 3650.0813,-3560.8684,138.0677
		{3648.6458,-3619.1865,137.4443}, -- 23 闪现
		{3648.6458,-3619.1865,137.4443}, -- 24 下雪 3652.6650,-3583.9929,137.7617	
		{3651.7388,-3625.9390,137.7706}, -- 25 冰环
		{3651.7388,-3625.9390,137.7706}, -- 26 下雪 3653.6885,-3601.5833,137.1192
		{3668.7336,-3650.4902,138.5838}, -- 27 闪现
		{3668.7336,-3650.4902,138.5838}, -- 28 下雪 3656.3169,-3629.3784,137.9371
		{3677.6826,-3662.0789,138.5768}, -- 29 冰环
		{3677.6826,-3662.0789,138.5768}, -- 30 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 31 闪现
        {3699.5996,-3652.0259,139.1076}, -- 32 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 34 下雪 3696.5029,-3648.8608,139.2266
		{3698.6372,-3618.3665,140.0967}, -- 35 急冷
		{3699.4294,-3611.9712,139.6280}, -- 36 召唤水元素
		{3711.9927,-3603.2114,141.2154}, -- 37 冰箱
		{3711.9927,-3603.2114,141.2154}, -- 38 水元素冰环 3711.9927,-3603.2114,141.2154
		{3681.1082,-3602.8723,137.5952}, -- 39 冰环 闪现 出冰箱
		{3681.1082,-3602.8723,137.5952}, -- 40 唤醒 5s
		{3681.1082,-3602.8723,137.5952}, -- 41 下雪 3705.9221,-3604.6782,140.3820
		{3670.9695,-3605.1873,137.0954},
		{3670.9695,-3605.1873,137.0954}, -- 43 下雪 3695.9614,-3604.9395,138.9726
		{3651.9612,-3618.4634,137.3329}, -- 44 闪现
		{3651.9612,-3618.4634,137.3329}, -- 45 下雪 3682.2654,-3609.0073,137.9412
		{3644.2390,-3624.7107,137.8329}, -- 46 水元素冰环 3665.2993,-3616.3259,137.7217
		{3644.2390,-3624.7107,137.8329}, -- 47 下雪 3665.2993,-3616.3259,137.7217
		{3671.7183,-3653.8928,138.6474}, -- 48 闪现
		{3671.7183,-3653.8928,138.6474}, -- 49 下雪 3657.1460,-3630.9497,138.0008
		{3677.6826,-3662.0789,138.5768},
		{3677.6826,-3662.0789,138.5768}, -- 51 下雪 3666.1260,-3645.3411,138.5448
		{3699.5996,-3652.0259,139.1076}, -- 52 闪现
        {3699.5996,-3652.0259,139.1076}, -- 53 下雪 3678.3218,-3660.6248,138.6168
		{3699.6184,-3629.8071,140.0518},
		{3699.6184,-3629.8071,140.0518}, -- 55 下雪 3696.5029,-3648.8608,139.2266
		}

		if Dungeon_move == 100 then -- 剩下一只怪
			local Monster = Combat_Scan()

			if #Monster == 0 and not UnitAffectingCombat("player") then
			    Dungeon_move = #Path + 1
				return
			end

			local target = Monster[1]

			if target then
				CombatSystem(target)

				return
			end
			return
		end

		if Dungeon_move > #Path then
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			HasStop = false
			return
		end
		Note_Set(Dungeon_move)
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 4 or Dungeon_move == 14 or Dungeon_move == 16 or Dungeon_move == 18 or Dungeon_move == 20 or Dungeon_move == 22 or Dungeon_move == 24 or Dungeon_move == 26 or Dungeon_move == 28 or Dungeon_move == 30 or Dungeon_move == 32 or Dungeon_move == 34 or Dungeon_move == 41 or Dungeon_move == 43 or Dungeon_move == 45 or Dungeon_move == 47 or Dungeon_move == 49 or Dungeon_move == 51 or Dungeon_move == 53 or Dungeon_move == 55 then -- 暴风雪
			local sx,sy,sz = 0,0,0
			local s_time = 1.5
			local Monster = Combat_Scan()

			if Dungeon_move == 4 then
				sx,sy,sz = 3624.5344,-3497.0469,137.0162
				s_time = 5.5
			elseif Dungeon_move == 14 then
				sx,sy,sz = 3637.6011,-3521.3430,136.6640
				s_time = 6
			elseif Dungeon_move == 16 then
				sx,sy,sz = 3642.0220,-3532.8958,137.7797
				s_time = 4
			elseif Dungeon_move == 18 then
				sx,sy,sz = 3642.6838,-3535.6047,138.0004
				s_time = 5
			elseif Dungeon_move == 20 then
				sx,sy,sz = 3645.6770,-3547.5342,138.0702
				s_time = 7
			elseif Dungeon_move == 22 then
				sx,sy,sz = 3650.0813,-3560.8684,138.0677
				s_time = 7
			elseif Dungeon_move == 24 then
				sx,sy,sz = 3652.6650,-3583.9929,137.7617
				s_time = 7.5
			elseif Dungeon_move == 26 then
				sx,sy,sz = 3653.6885,-3601.5833,137.1192
				s_time = 7.5
			elseif Dungeon_move == 28 then
				sx,sy,sz = 3656.3169,-3629.3784,137.9371
				s_time = 7
            elseif Dungeon_move == 30 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7
			elseif Dungeon_move == 32 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 34 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			elseif Dungeon_move == 41 then
				sx,sy,sz = 3705.9221,-3604.6782,140.3820
				s_time = 2.3
			elseif Dungeon_move == 43 then
				sx,sy,sz = 3695.9614,-3604.9395,138.9726
				s_time = 7
			elseif Dungeon_move == 45 then
				sx,sy,sz = 3682.2654,-3609.0073,137.9412
				s_time = 7
			elseif Dungeon_move == 47 then
				sx,sy,sz = 3665.2993,-3616.3259,137.7217
				s_time = 7.5
			elseif Dungeon_move == 49 then
				sx,sy,sz = 3657.1460,-3630.9497,138.0008
				s_time = 7.5
			elseif Dungeon_move == 51 then
				sx,sy,sz = 3666.1260,-3645.3411,138.5448
				s_time = 7.5
			elseif Dungeon_move == 53 then
				sx,sy,sz = 3678.3218,-3660.6248,138.6168
				s_time = 7.5
			elseif Dungeon_move == 55 then
				sx,sy,sz = 3696.5029,-3648.8608,139.2266
				s_time = 7.5
			end

			local Count = 0
			local Pet_Stay = false -- 水宝宝被蝙蝠卡bug

			for i = 1,#Monster do 
				local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
				local guid = awm.ObjectId(Monster[i])
				if distance <= 7 and guid ~= 10461 and guid ~= 10536 and guid ~= 10441 then
					Count = Count + 1
				end
				if Count >= 3 then
					if Dungeon_move >= 19 then
					    awm.CastSpellByName(rs["冰霜新星"])
					end
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
				if (Dungeon_move == 18 or Dungeon_move == 26) and CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
				    s_time = 6
				end

				if (guid == 10384 or guid == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
				    awm.TargetUnit(Monster[i])
				    awm.RunMacroText("/跳舞")
				end

				if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
				    Pet_Stay = true
				end

				if guid == 10408 and Dungeon_move == 20 then
				    s_time = 6.2
				end
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
					if not Pet_Attack then
						Pet_Attack = true
						C_Timer.After(0.5,function() Pet_Attack = false end)
						awm.PetWait()
						awm.PetPassiveMode()
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
					local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end

					if Dungeon_move >= 22 and Dungeon_move <= 35 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3649.97,-3561.99,138.13)
						end
					elseif Dungeon_move >= 46 then
					    if Spell_Castable(rs["冰冻术"]) then
							awm.CastSpellByName(rs["冰冻术"])
						end
						if awm.IsAoEPending() and Spell_Castable(rs["冰冻术"]) then
							awm.ClickPosition(3665.2993,-3616.3259,137.7217)
						end
					end
				end 
			end

			if CheckBuff("player",rs["冰冷血脉"]) and s_time > 6.2 then
				s_time = 6.2
			end

			if ST_Timer then
				local time = GetTime() - ST_Time
				if time >= s_time then
					ST_Timer = false
					awm.SpellStopCasting()
					awm.SpellStopTargeting()
					Target_Monster = nil
					Dungeon_move = Dungeon_move + 1
					return
				end
			end

			if not CastingBarFrame:IsVisible() then
			    if Dungeon_move == 14 and not CheckBuff("player",rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
					awm.CastSpellByName(rs["寒冰护体"])
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
					return
				end

				if (UnitPower("player") > 2000 or CheckBuff("player",rs["节能施法"])) and Dungeon_move ~= 4 and Dungeon_move ~= 41 and (not ST_Timer or GetTime() - ST_Time < 4) then
					awm.CastSpellByName(rs["暴风雪"])
				else
					awm.CastSpellByName(rs["暴风雪(等级 1)"])
				end
				if awm.IsAoEPending() then
					awm.ClickPosition(sx,sy,sz)
					if not ST_Timer then
						ST_Timer = true
						ST_Time = GetTime()
					end
				end

				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end
			else
				if not ST_Timer then
					ST_Timer = true
					ST_Time = GetTime()
				end
			end
			return
		end

		if Dungeon_move == 40 then
		    local Monster = Combat_Scan()
			local Forzen = false
			for i = 1,#Monster do
			    local ThisUnit = Monster[i]
				local Debuff = CheckDebuffByName(ThisUnit,rs["冰冻术"])

				if Debuff then
				    Forzen = true
				end
			end

			if not Forzen then
			    awm.SpellStopCasting()
				Dungeon_move = Dungeon_move + 1
				ST_Timer = false
				return
			end

		    if ST_Timer then
			    if GetTime() - ST_Time >= 4.5 then
				    awm.SpellStopCasting()
					Dungeon_move = Dungeon_move + 1
					ST_Timer = false
					return
				end
			end

		    if not CastingBarFrame:IsVisible() then
			    if Spell_Castable(rs["唤醒"]) then
				    awm.CastSpellByName(rs["唤醒"])
				end

				if not ST_Timer and CastingBarFrame:IsVisible() then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			else
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				end 
			end
			return
		end

		if Distance > 0.9 then
		    ST_Timer = false

			if Dungeon_move == 1 or Dungeon_move == 13 or Dungeon_move == 19 or Dungeon_move == 23 or Dungeon_move == 27 or Dungeon_move == 31 or Dungeon_move == 39 or Dungeon_move == 44 or Dungeon_move == 48 or Dungeon_move == 52 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step and not CheckBuff("player",rs["寒冰屏障"]) and (UnitPower("player") >= 1000 or Dungeon_move == 39) then
					Interact_Step = true
					C_Timer.After(0.07,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			elseif Dungeon_move == 15 or Dungeon_move == 25 or Dungeon_move == 31 or Dungeon_move == 33 or Dungeon_move == 42 then
			    if Spell_Castable(rs["冰霜新星"]) then
				    awm.CastSpellByName(rs["冰霜新星"])
				end
			else
			    if Distance >= 5 and (Dungeon_move < 2 or Dungeon_move > 13) then
					local Monster = Combat_Scan()
					for i = 1,#Monster do
						local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
						if (distance <= 8 or (awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200)) and Distance >= 5 then
							if not CheckBuff(rs["寒冰护体"]) and Spell_Castable(rs["寒冰护体"]) then
								awm.CastSpellByName(rs["寒冰护体"])
							end
						end

						-- 10390 骷髅守护者
						if Distance >= 5 and awm.ObjectId(Monster[i]) == 10390 and awm.UnitPower(Monster[i]) > 200 and Dungeon_move <= 24 then
							if not CheckBuff(rs["防护冰霜结界"]) and Spell_Castable(rs["防护冰霜结界"]) then
								awm.CastSpellByName(rs["防护冰霜结界"])
							end
						end

						if (awm.ObjectId(Monster[i]) == 10384 or awm.ObjectId(Monster[i]) == 10385) and awm.UnitTarget(Monster[i]) and not CastingBarFrame:IsVisible() then
							awm.TargetUnit(Monster[i])
							awm.RunMacroText("/跳舞")
						end
					end
				end
			end

			if Dungeon_move == 3 then
			    if Easy_Data["法师魔甲术"] and not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
				    awm.CastSpellByName(rs["法师魔甲术"],"player")
					return
				end
			end

			awm.MoveTo(x,y,z)		

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			local Monster = Combat_Scan()
			if #Monster == 0 and not UnitAffectingCombat("player") and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 3 then
					    Dungeon_move = #Path + 1
						return
					end
				end
				return
			elseif (#Monster == 2 or #Monster == 1) and Dungeon_move >= 24 then
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time > 1.5 then
					    Dungeon_move = 100
						return
					end
				end
				return
			end

			if PetHasActionBar() then
			    if Dungeon_move < 13 or (Dungeon_move >= 36 and Dungeon_move <= 38) then
				    local target = nil
					for i = 1,awm.GetObjectCount() do
					    local ThisUnit = awm.GetObjectWithIndex(i)
					    local guid = awm.ObjectId(ThisUnit)
						local distance_pet = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if guid == 10411 and not awm.UnitIsDead(ThisUnit) and awm.UnitCanAttack("player",ThisUnit) and distance_pet <= 50 and distance_pet >= 35 then
						    target = ThisUnit
						elseif guid == 10411 and awm.UnitIsDead(ThisUnit) then
						    if not Pet_Attack then
								Pet_Attack = true
								C_Timer.After(0.5,function() Pet_Attack = false end)
								awm.PetWait()
								awm.PetPassiveMode()
							end
						end
					end

					if target then
					    awm.PetAttack(target)
				    else
						if not Pet_Attack then
							Pet_Attack = true
							C_Timer.After(0.5,function() Pet_Attack = false end)
							awm.PetWait()
							awm.PetPassiveMode()
						end
					end
				elseif Dungeon_move == 13 or Dungeon_move == 14 or Dungeon_move == 39 or Dungeon_move == 40 or Dungeon_move == 41 then
				    local pet_target = awm.UnitTarget("pet")
					if not pet_target or (awm.UnitTarget(pet_target) and awm.UnitTarget(pet_target) == UnitGUID("player")) then
					    local Far_Distance = 100
						local target = nil
						for i = 1,#Monster do
							local distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if distance <= Far_Distance and not CheckDebuffByName(Monster[i],rs["冰冻术"]) then
							    target = Monster[i]
								Far_Distance = distance
							end
						end
						if target then
						    awm.PetAttack(target)
						end
					end
				else
				    local Pet_Stay = false
					for i = 1,#Monster do 
						local guid = awm.ObjectId(Monster[i])
						if guid == 10408 and awm.UnitTarget(Monster[i]) and awm.UnitTarget(Monster[i]) == UnitGUID("pet") then
							Pet_Stay = true
						end
					end
				    local distance = awm.GetDistanceBetweenObjects("pet","player")
					if distance >= 8 and not Pet_Stay then
					    awm.PetFollow()
					else
					    local pet_target = awm.UnitTarget("pet")
						local target = nil
						if not pet_target or awm.ObjectId(pet_target) ~= 10414 then
							local total = awm.GetObjectCount()
							for i = 1,total do
								local ThisUnit = awm.GetObjectWithIndex(i)
								local guid = awm.ObjectId(ThisUnit)
								if guid == 10414 then
									target = ThisUnit
								end
							end
						end
						if target and not Pet_Attack then
						    Pet_Attack = true
							C_Timer.After(2,function() Pet_Attack = false end)
						    awm.PetAttack(target)
						end
					end
				end 
			end

			if Dungeon_move == 10 or Dungeon_move == 36 then -- 水元素
			    if Spell_Castable(rs["召唤水元素"]) then
			        awm.CastSpellByName(rs["召唤水元素"])
				end
				if PetHasActionBar() then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 11 or Dungeon_move == 37 then -- 冰箱
			    if Spell_Castable(rs["寒冰屏障"]) then
			        awm.CastSpellByName(rs["寒冰屏障"])
				end
				if CheckBuff("player",rs["寒冰屏障"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 12 or Dungeon_move == 38 then -- 冰冻术
			    local sx,sy,sz = 0,0,0
				if Dungeon_move == 12 then                    sx,sy,sz = 3636.0408,-3517.6003,136.4553                  
                elseif Dungeon_move == 38 then
				    sx,sy,sz = 3711.9927,-3603.2114,141.2154
				end
			    if not ST_Timer then
				    ST_Timer = true
					ST_Time = GetTime()
				else
				    if GetTime() - ST_Time >= 9.3 then
					    if not awm.IsAoEPending() then
						    awm.CastSpellByName(rs["冰冻术"])
						else
						    awm.ClickPosition(sx,sy,sz)
							Dungeon_move = Dungeon_move + 1
							ST_Timer = false
							return
						end
					end
				end
				return
			end

			if Dungeon_move == 13 or Dungeon_move == 39 then -- 冰冷血脉
			    local starttime4, duration4, enabled, _ = GetSpellCooldown(rs["冰冷血脉"])
				local endtime4 = starttime4 + duration4

				if CheckBuff('player',rs["冰冷血脉"]) then
				    Dungeon_move = Dungeon_move + 1
					return
				end

				if endtime4 - GetTime() <= 1 then
					awm.CastSpellByName(rs["冰冷血脉"])
					return
				else
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 35 then -- 急冷
			    awm.CastSpellByName(rs["急速冷却"])
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 31 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if UnitAffectingCombat("player") then
		    Dungeon_step1 = 30
			Dungeon_move = 100
			return
		end

		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 91
			return
		end
		if #body_list > 0 then
			if not Body_Choose then
				Body_Target = body_list[1].Unit
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
		    Dungeon_step1 = Dungeon_step1 + 1
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 32 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰屏障"]) then
		    awm.CastSpellByName(rs["寒冰屏障"])
		end

		if CheckDebuffByName("player",Check_Client("死尸虫","Cadaver Worms")) and Spell_Castable(rs["寒冰护体"]) then
		    awm.CastSpellByName(rs["寒冰护体"])
		end

		if not awm.UnitAffectingCombat("player") then
		    if not MakingDrinkOrEat() then
	 	 	    Note_Set(Check_UI("做面包和水...","Making food and drink..."))
				return
	 		end   
			if not NeedHeal() then
				Note_Set(Check_UI("恢复血蓝...","Restore health and mana..."))
	 	 		return
	 		end
			if not CheckUse() then
			    Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			    return
			end
			HasStop = false
			Dungeon_step1 = 91
			Dungeon_move = 1
			return
		else
		    HasStop = false
			Dungeon_step1 = Dungeon_step1 - 2
			Dungeon_move = 100
			return
		end
	end

	if Dungeon_step1 == 91 then -- 出本
	    local x1,y1,z1 = 3623,-3643,138
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)

		if distance >= 2 then

			local total = awm.GetObjectCount()
			local Far_Distance = 6
			for i = 1,total do
				local ThisUnit = awm.GetObjectWithIndex(i)
				local guid = awm.ObjectId(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects('player',ThisUnit)
				if (guid == 175353 or guid == 175352 or guid == 175368) and distance < Far_Distance then
					Far_Distance = distance
					awm.InteractUnit(ThisUnit)
				end
			end

			Run(x1,y1,z1)
		else
		    Dungeon_step = 2
			Dungeon_move = 1
		end
	end
end

function Go_Out()
    local Px,Py,Pz = awm.ObjectPosition("player")
    frame:SetBackdropColor(0,0,0,0)
	Note_Set(Check_UI("执行出去副本","Go out dungeon")..Dungeon_step2)
	if Dungeon_step2 == 1 then
	    if awm.UnitAffectingCombat("player") then
		    local Monster = Combat_Scan()
			target = Monster[1]
			awm.TargetUnit(target)
			Note_Set(Check_UI("击杀怪物 = ","Kill mob = ")..awm.UnitFullName(target))
		    if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
				awm.CastSpellByName(rs["寒冰护体"])
				return
			end

			if Spell_Castable(rs["火焰冲击"]) and awm.IsSpellInRange(rs["火焰冲击"],"target") == 1 then
				awm.CastSpellByName(rs["火焰冲击"])
				return
			end

			awm.FaceCombat(target)

			if Spell_Castable(rs["寒冰箭"]) and awm.IsSpellInRange(rs["寒冰箭"],"target") == 1 then
				awm.CastSpellByName(rs["寒冰箭"])
				return
			end
			return
		end

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
	    if awm.UnitAffectingCombat("player") then
		    local Monster = Combat_Scan()
			target = Monster[1]
			awm.TargetUnit(target)
			Note_Set(Check_UI("击杀怪物 = ","Kill mob = ")..awm.UnitFullName(target))
		    if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
				awm.CastSpellByName(rs["寒冰护体"])
				return
			end

			if Spell_Castable(rs["火焰冲击"]) and awm.IsSpellInRange(rs["火焰冲击"],"target") == 1 then
				awm.CastSpellByName(rs["火焰冲击"])
				return
			end

			awm.FaceCombat(target)

			if Spell_Castable(rs["寒冰箭"]) and awm.IsSpellInRange(rs["寒冰箭"],"target") == 1 then
				awm.CastSpellByName(rs["寒冰箭"])
				return
			end
			return
		end

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

				local total = awm.GetObjectCount()
				local Far_Distance = 6
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenObjects('player',ThisUnit)
					if (guid == 175353 or guid == 175352 or guid == 175368) and distance < Far_Distance then
					    Far_Distance = distance
						awm.InteractUnit(ThisUnit)
					end
				end

				Run(x1,y1,z1)
			end
		end
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

		if #OBJ_Killed >= 1 and not Need_Reset and not Reset_Instance then
		    Need_Reset = true
			textout(Check_UI("怪物击杀, 判断残本","Mobs kill, Force reset dungeon"))
		end

		Dungeon_Enter_step = 1 -- 还原

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
				if Faction == "Horde" then -- 部落联盟分开设置 
					Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1420, 2237, 312, 36
					Merchant_Name = Check_Client("亚伯·温特斯","Abe Winters")
				else
					Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1421, -755, 1496, 17
					Merchant_Name = 3534
				end

				if Easy_Data["工匠威尔海姆"] then
				    Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1423,2261.3110,-5321.6191,81.8985
					Merchant_Name = 16376
				end
			end

			if Instance == 329 and Dungeon_step == 2 then
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
				elseif awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1) < 50 then
				    if not Interact_Step and Easy_Data["需要喊话"] then
						Interact_Step = true
						C_Timer.After(0.5,function() Interact_Step = false end)
						awm.RunMacroText("/party "..Easy_Data["出本喊话"])
					end
					Note_Set(Check_UI("出本卖物 = ","Go Out Dungeon To Vendor = ")..Merchant_Name)
					Run(x1,y1,z1)
					frame:SetBackdropColor(0,0,0,0)
					return
				end
		    elseif Instance ~= 329 then
			    frame:SetBackdropColor(0,0,0,0)
			    Note_Head = Check_UI("卖物","Vendor")

				Dungeon_Enter_step = 1 -- 还原

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
					if awm.GetDistanceBetweenPositions(Px,Py,Pz,3187,-4039,108) <= 6 then
						if CastingBarFrame:IsVisible() then
							return
						end

						local total = awm.GetObjectCount(false)
						for i = 1,total do
							local ThisUnit = awm.GetObjectWithIndex(i)
							local name = awm.ObjectId(ThisUnit)
							if awm.ObjectIsGameObject(ThisUnit) and name == 175369 and awm.GetDistanceBetweenObjects("player",ThisUnit) < 10 then
								awm.InteractUnit(ThisUnit)
							end
						end
					end

					if not Has_Mail and Easy_Data["需要邮寄"] and Easy_Data["卖物前邮寄"] then
						Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1423,2288.6501,-5317.5947,88.7706

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

					Sell_JunkRun(Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z)
				end
				return
			end
		end
	end

	if Easy_Data["需要邮寄"] and not awm.UnitAffectingCombat("player") then
		if #Easy_Data.ResetTimes / Easy_Data["触发邮寄"] == math.floor(#Easy_Data.ResetTimes / Easy_Data["触发邮寄"]) and #Easy_Data.ResetTimes ~= 0 and #Easy_Data.ResetTimes ~= 1 and not Has_Mail then
			Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1423,2288.6501,-5317.5947,88.7706

			if Easy_Data["自定义邮箱"] then
				local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
			end
			
			
			if Instance == 329 and Dungeon_step == 2 then
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
					if not Interact_Step and Easy_Data["需要喊话"] then
						Interact_Step = true
						C_Timer.After(0.5,function() Interact_Step = false end)
						awm.RunMacroText("/party "..Easy_Data["出本喊话"])
					end
				    
				    Note_Set(Check_UI("出本邮寄, 坐标 = ","Go Out To Mail, Coord = ")..x1..","..y1..","..z1)
					frame:SetBackdropColor(0,0,0,0)
					Run(x1,y1,z1)
					return
				end
			elseif Instance ~= 329 then
				frame:SetBackdropColor(0,0,0,0)
				Note_Head = Check_UI("邮寄","Mail")
				
				Dungeon_Enter_step = 1 -- 还原

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
				    if awm.GetDistanceBetweenPositions(Px,Py,Pz,3187,-4039,108) <= 6 then
						if CastingBarFrame:IsVisible() then
							return
						end

						local total = awm.GetObjectCount(false)
						for i = 1,total do
							local ThisUnit = awm.GetObjectWithIndex(i)
							local name = awm.ObjectId(ThisUnit)
							if awm.ObjectIsGameObject(ThisUnit) and name == 175369 and awm.GetDistanceBetweenObjects("player",ThisUnit) < 10 then
								awm.InteractUnit(ThisUnit)
							end
						end
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

	if Instance == 329 then
        Real_Flush = false -- 触发爆本
        Real_Flush_time = 0 -- 第一次爆本时间
		Real_Flush_times = 0 -- 爆本计数

		Easy_Data.Sever_Map_Calculated = false
        Continent_Move = false

		Dungeon_Enter_step = 1 -- 还原

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
		    STSM()
		end
		if Dungeon_step == 2 then
		    Reset_Instance = true
			Note_Head = Check_UI("结束","End Process")
			Go_Out()
		end
	else
	    Note_Head = Check_UI("正常进本","Run Into Dungeon")
		if tonumber(Easy_Data["等待时间"]) == nil then
		    Easy_Data["等待时间"] = 5
		end
		if GetTime() - Out_Dungeon_Time < Easy_Data["等待时间"] then
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

		if Dungeon_Enter_step == 1 then
		    mapid,x,y,z = Dungeon_In.mapid, 3235.1301,-4052.3149,108.4536
		elseif Dungeon_Enter_step == 2 then
		    mapid,x,y,z = Dungeon_In.mapid, 3230.4683,-4054.6228,108.9293
		elseif Dungeon_Enter_step == 3 then
		    mapid,x,y,z = Dungeon_In.mapid, 3231.1470,-4056.8247,108.9375
		end

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
					C_Timer.After(0.5,function() Interact_Step = false end)
					awm.RunMacroText("/party "..Easy_Data["进本喊话"])
				end
			end

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,Dungeon_In.x,Dungeon_In.y,Dungeon_In.z) >= 30 then
			    Dungeon_Enter_step = 1 -- 还原步骤
			end

			if awm.GetDistanceBetweenPositions(Px,Py,Pz,3187,-4039,108) <= 6 then
			    if CastingBarFrame:IsVisible() then
				    return
				end

				local total = awm.GetObjectCount(false)
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local name = awm.ObjectId(ThisUnit)
					if awm.ObjectIsGameObject(ThisUnit) and name == 175369 and awm.GetDistanceBetweenObjects("player",ThisUnit) < 10 then
						awm.InteractUnit(ThisUnit)
					end
				end
			end

			if (Easy_Data["服务器地图"] and Current_Map ~= 1423 and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,1423,Dungeon_In.x,Dungeon_In.y,Dungeon_In.z)
				return
			end

			if distance <= 10 then
			    awm.MoveTo(x,y,z)
				return
			end

			Run(x,y,z)
			return
		elseif distance <= 1 and not Dungeon_Flush then
		    Dungeon_Enter_step = Dungeon_Enter_step + 1

			if not Interact_Step and Dungeon_Enter_step > 3 then
				Interact_Step = true
				
				C_Timer.After(1.5,function() 
					Interact_Step = false 
					if Instance ~= 329 then
						Dungeon_Flush = true
						C_Timer.After(30,function() Dungeon_Flush = false Dungeon_Enter_step = 1 end)
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
local Reset_Path = 0 -- 死亡路径重置和间隔路径重置
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
		awm.SetPathfindingVariables(0.5, 2, 6, 0.3)
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
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("斯坦索姆 爆本 本外等待坐标","Stratholme Wait Point")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["STSM等待坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"3223,-4034,108",false,280,24)
		Basic_UI.Set["STSM等待坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["STSM等待坐标"] = Basic_UI.Set["STSM等待坐标"]:GetText()
			local coord_package = string.split(Easy_Data["STSM等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		end)
		if Easy_Data["STSM等待坐标"] ~= nil then
			Basic_UI.Set["STSM等待坐标"]:SetText(Easy_Data["STSM等待坐标"])
			local coord_package = string.split(Easy_Data["STSM等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		else
			Easy_Data["STSM等待坐标"] = Basic_UI.Set["STSM等待坐标"]:GetText()
		end

		Basic_UI.Set["获取等待坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Set["获取等待坐标"]:SetSize(120,24)
		Basic_UI.Set["获取等待坐标"]:SetScript("OnClick", function(self)
			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance ~= 329 then
			    local x,y,z = awm.ObjectPosition("player")
				Basic_UI.Set["STSM等待坐标"]:SetText(math.floor(x)..","..math.floor(y)..","..math.floor(z))
				Easy_Data["STSM等待坐标"] = Basic_UI.Set["STSM等待坐标"]:GetText()
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

	local function Vendor_Place() -- 售卖位置
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["工匠威尔海姆"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("出售NPC = 工匠威尔海姆 (需要声望)","Vendor NPC = Craftsman Wilhelm (Need reputation)"))
		Basic_UI.Set["工匠威尔海姆"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["工匠威尔海姆"]:GetChecked() then
				Easy_Data["工匠威尔海姆"] = true
			elseif not Basic_UI.Set["工匠威尔海姆"]:GetChecked() then
				Easy_Data["工匠威尔海姆"] = false
			end
		end)
		if Easy_Data["工匠威尔海姆"] ~= nil then
			if Easy_Data["工匠威尔海姆"] then
				Basic_UI.Set["工匠威尔海姆"]:SetChecked(true)
			else
				Basic_UI.Set["工匠威尔海姆"]:SetChecked(false)
			end
		else
			Easy_Data["工匠威尔海姆"] = true
			Basic_UI.Set["工匠威尔海姆"]:SetChecked(true)
		end
	end

	local function Mojia_UI() -- 法师魔甲术
	    Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["法师魔甲术"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("A 怪时使用 ","Killing mobs shift to ")..rs["法师魔甲术"])
		Basic_UI.Set["法师魔甲术"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["法师魔甲术"]:GetChecked() then
				Easy_Data["法师魔甲术"] = true
			elseif not Basic_UI.Set["法师魔甲术"]:GetChecked() then
				Easy_Data["法师魔甲术"] = false
			end
		end)
		if Easy_Data["法师魔甲术"] ~= nil then
			if Easy_Data["法师魔甲术"] then
				Basic_UI.Set["法师魔甲术"]:SetChecked(true)
			else
				Basic_UI.Set["法师魔甲术"]:SetChecked(false)
			end
		else
			Easy_Data["法师魔甲术"] = false
			Basic_UI.Set["法师魔甲术"]:SetChecked(false)
		end
	end

	Frame_Create()
	Button_Create()	

	Stuck_Fly_Set_UI()
	Loot_UI()
	Loot_Interval()
	Wait_point()
	Dungeon_Wait_Time()
	Order_UI()
	Vendor_Place()
	Mojia_UI()
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