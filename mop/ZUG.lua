Function_Load_In = true
local Function_Version = "0922"
textout(Check_UI("祖尔格拉布 - "..Function_Version,"ZG - "..Function_Version))

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
local Jump_move = 1
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

local Dungeon_In = {mapid = 1434, x = -11915.8945, y = -1233.551, z = 92.2611}
local Dungeon_Out = {mapid = 1434, x = -11916.817, y = -1224.86, z = 93.15}
local Dungeon_Flush_Point = {mapid = 1434, x = -11915.8945, y = -1202.551, z = 92.2611}

local Flush_Time = false
local Dungeon_Flush = false -- 是否爆本
local Real_Flush = false -- 触发爆本
local Real_Flush_time = 0 -- 第一次爆本时间
local Real_Flush_times = 0 -- 爆本计数

local Merchant_Coord = {mapid = 1434, x = -1707, y = -1424, z = 34}
local Merchant_Name = "匠人比尔"

local Mail_Coord = {mapid = 1434, x = -1656, y = -1344, z = 32}
local Has_Mail = false

local Reset_Instance = false

local Interact_Step = false
local HasStop = false
local Jump_Time = 0
local HasJump = false

local ZG_Timer = false -- 玛拉顿技能计时
local ZG_Time = 0
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


if Easy_Data.ResetTimes == nil then
    Easy_Data.ResetTimes = {}
end

function Vars_Reset()
     Dungeon_step = 1
	 Dungeon_step1 = 1
	 Dungeon_step2 = 1
	 Dungeon_move = 1
	 Jump_move = 1
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
	Jump_move = 1
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
			local x,y,z = Dungeon_In.x,Dungeon_In.y,Dungeon_In.z
			if Interact_Step then
			    x,y,z = -11915.8945,-1202.551,92.2611
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
		if id ~= nil and guid == id and distance < Far_Distance and distance < scan_range then
			Far_Distance = distance
			target = ThisUnit
		elseif id == nil and distance < Far_Distance and distance < scan_range then
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

	if #body <= 1 and Easy_Data["需要剥皮"] and Skill_Level(rs["剥皮"]) >= 300 then
	    for i = 1,total do
			local ThisUnit = awm.GetObjectWithIndex(i)
			local guid = awm.UnitGUID(ThisUnit)
			local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
			local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x1,y1,z1)
			if awm.UnitIsDead(ThisUnit) and awm.UnitIsSkinnable(guid) then
				local body_table = {distance = distance,ThisUnit}
				body_table.distance = distance
				body_table.Unit = ThisUnit
				body[#body + 1] = body_table
			end
		end
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


function ZG_36()
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
	if Dungeon_step1 >= 4 and not CastingBarFrame:IsVisible() then
		UseItem()
	end

	if Dungeon_step1 == 5 and not CastingBarFrame:IsVisible() then
		if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
			awm.CastSpellByName(rs["法师魔甲术"],"player")
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
		local x,y,z = -11916.0625,-1249.0980,92.5346
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if distance > 1 then
			if distance > 50 then
			    awm.Stuck()
				return
			end
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 2
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = -11917.0889,-1244.1870,92.5342
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
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	end
	if Dungeon_step1 == 3 then -- 血蓝恢复
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
	end
	if Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

		local Path = 
		{
		{-11916.79,-1249.95,92.53}, -- 检查buff
		{-11917.98,-1277.53,85.38},
		{-11943.00,-1268.89,85.37},
		{-11941.14,-1294.53,73.98},
		{-11950.09,-1309.73,62.42},
		{-11949.00,-1336.63,61.87},
		{-11936.21,-1361.12,61.60},
		{-11942.36,-1372.13,61.65},
		{-11943.65,-1391.60,62.65},
		{-11957.41,-1397.40,69.28},
		{-11965.41,-1404.89,71.78},
		{-11966.54,-1419.43,71.24},
		{-11955.05,-1415.53,77.89},
		{-11953.60,-1406.03,84.33}, -- 上马 开盾
		{-11946.79,-1415.20,85.16},
		{-11916.37,-1431.11,46.13},
		{-11921.58,-1448.09,42.90},
		{-11933.74,-1501.65,34.59},
		{-11940.67,-1531.62,40.58},
		{-11901.99,-1554.92,36.84},
		{-11872.1416,-1566.1510,8.9027},
		{-11867.3887,-1566.8153,12.5976}, -- 跳 面对 6.1997
		{-11858.8379,-1567.2820,16.4498},
		{-11822.7275,-1542.4856,17.2527}, -- 行走闪现
		{-11793.62,-1545.49,19.17},
		{-11769.81,-1550.59,18.81},
		{-11762.83,-1550.69,15.93},
		{-11760.5557,-1552.4899,17.0521}, -- 脱战
		{-11767.34,-1549.18,17.72},
		{-11795.09,-1544.59,19.20},
		{-11821.57,-1550.64,18.92},
		{-11835.59,-1549.53,24.38}, -- 恢复
		{-11835.59,-1549.53,24.38}, -- 扫 11359 == nil 或者 (-11861.16,-1590.45,21.10 > 40 and -11835.59,-1549.53,24.38 > 40) (tarz <= 25)
		{-11861.16,-1590.45,21.10}, -- 扫 11359 == nil 或者 -11867.44,-1676.24,19.57 > 38 而且怪物朝向 > 4 (tarz <= 25)
		{-11866.92,-1599.74,19.58},
		{-11865.35,-1673.20,19.58}, 
		{-11867.44,-1676.24,19.57}, -- 15043 -11881.44,-1685.63,14.53
		{-11865.35,-1673.20,19.58},
		{-11865.70,-1591.07,19.58}, -- 闪现
		{-11839.16,-1545.39,23.10},
		{-11843.56,-1540.03,18.25},
		{-11853.08,-1530.54,10.06}, -- 跳
		{-11861.61,-1496.22,8.94}, -- 反制 15043, -11892.90, -1496.04, 12.97
		{-11827.95,-1480.46,8.91}, -- 闪现 冰环
		{-11821.7197,-1483.4459,13.0263},
		{-11814.8232,-1472.8654,18.0102},
		{-11794.7686,-1468.8326,37.1761},
		{-11790.2490,-1464.2147,38.6832},
		{-11782.3018,-1469.7611,46.3094},
		{-11765.2021,-1483.3679,36.9993},
		{-11734.1885,-1491.5686,40.5470},
        {bx,by,bz}, -- 闪现
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
		{bx,by,bz}, -- 下雪
		{jx,jy,jz},
		{-11710.00,-1559.81,8.96}, -- 落水闪现
		{-11712.8945,-1560.5325,11.1474}, -- 落水闪现
		{-11708.7949,-1562.1304,10.3572},
		{-11707.94,-1604.53,13.51},
		{-11707.49,-1617.32,14.93},
		{-11706.7773,-1635.3887,16.4120}, -- 下雪 -11707.80,-1605.30,13.42
		{-11706.12,-1656.64,16.26}, -- 冰环
		{-11705.56,-1672.62,14.76},
		{-11705.32,-1679.34,13.66},
		{-11701.25,-1691.59,9.34},
		{-11702.22,-1697.65,10.51},
		{-11704.29,-1712.60,12.14},
		{-11700.23,-1724.71,10.50},
		{-11698.81,-1727.18,8.93}, -- 反制 15043 -11714,-1731,12
		{-11685.18,-1753.21,11.32}, -- 闪现
		{-11675.37,-1757.42,14.05},
		{-11657.40,-1759.08,23.10},
		{-11641.96,-1764.07,34.21},
		{-11647.55,-1776.06,35.39},
		{-11650.37,-1783.63,36.73},
		{-11655.46,-1792.10,37.70},
		{-11675.88,-1784.76,13.02},
		{-11702.08,-1776.59,12.32}, -- 急冷 冰环
		{-11704.75,-1771.70,11.25},
		{-11728.01,-1749.66,11.42}, -- 闪现
		{-11740.11,-1744.34,15.98},
		{-11744.23,-1744.14,17.12},
		{-11745.33,-1747.04,19.71}, -- 点击跳跃
		{-11742.62,-1754.06,17.27},
		{-11750.08,-1758.27,14.49},
		{-11755.38,-1764.41,11.41},
		{-11759.70,-1768.81,8.88},
		{-11779.15,-1768.01,8.74},
		{-11775.28,-1758.72,17.28},
		{-11775.9404,-1756.5320,18.0101},
		{-11774.02,-1744.43,12.97},
		{-11787.98,-1733.83,11.39},
		{-11809.88,-1727.93,11.23},
		{-11833.92,-1728.77,9.38},
		{-11840.97,-1730.87,8.93},
		{-11870.83,-1765.41,12.45}, -- 闪现
		{-11872.31,-1775.71,19.36},
		{-11881.44,-1778.92,24.17},
		{-11889.29,-1771.62,25.99},
		{-11902.50,-1768.91,35.17},
		{-11914.78,-1766.56,42.95},
		{-11904.76,-1748.74,14.78},
		{-11896.93,-1744.19,13.77}, -- 冰环
		{-11877.89,-1700.12,10.56}, -- 闪现
		{-11885.17,-1681.24,13.34},
		{-11883.07,-1665.10,11.37},
		{-11877.82,-1646.13,11.77},
		{-11871.30,-1598.69,12.16},
		{-11871.94,-1576.17,10.76},
		{-11872.5566,-1566.3904,8.9012},
		{-11867.3887,-1566.8153,12.5976}, -- 点击 跳
		{-11863.37,-1567.05,14.86},
		{-11839.37,-1549.06,23.23}, -- 闪现
		{-11816.03,-1544.45,18.21},
		{-11749.28,-1486.06,39.26},
		{bx,by,bz}, -- 闪现
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
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


		if Dungeon_move == 53 or Dungeon_move == 56 or Dungeon_move == 118 then
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.08 and HasStop then
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.08,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and not HasStop then
			    Jump_move = 2
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end

		if Distance > 0.9 then
		    ZG_Timer = false

			if Dungeon_move == 28 and not awm.UnitAffectingCombat("player") and Distance <= 3 then
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 24 or Dungeon_move == 39 or Dungeon_move == 44 or Dungeon_move == 52 or Dungeon_move == 57 or Dungeon_move == 71 or Dungeon_move == 81 or Dungeon_move == 97 or Dungeon_move == 105 or Dungeon_move == 114 or Dungeon_move == 117 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    if Dungeon_move == 57 then
					    if Distance <= 20 then
						    Interact_Step = true
							C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
						else
						    CheckProtection()
						end
					elseif Dungeon_move == 117 and Pz >= 41.5 then
						Interact_Step = true
						C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
					else
					    Interact_Step = true
						C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
					end
				end
			else
			    if Distance >= 7 or Dungeon_move == 56 then
					CheckProtection()
				end
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and distance < 40 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 34
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end
				end
			end

			if Dungeon_move == 14 and not IsMounted() then
			    if Spell_Castable(rs["寒冰护体"]) then
				    awm.CastSpellByName(rs["寒冰护体"])
				    return
				end

				if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
					if not Tried_Mount then
						Tried_Mount = true
						awm.UseAction(Easy_Data["动作条坐骑位置"])
						textout(Check_UI("坐骑位置 - "..Easy_Data["动作条坐骑位置"]..", 尝试召唤","Mount slot in action bar - "..Easy_Data["动作条坐骑位置"]..", try mount"))
						C_Timer.After(5,function() Tried_Mount = false end)
						return
					end		
				end
				return
			end

			if Dungeon_move == 21 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
				awm.ClickToMove(x,y,z)
				awm.JumpOrAscendStart()
				awm.AscendStop()
				return
			end

			if (Dungeon_move == 22 or Dungeon_move == 45 or Dungeon_move == 61 or Dungeon_move == 84 or Dungeon_move == 112) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()

				awm.JumpOrAscendStart()
			    awm.MoveForwardStop()

				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 42 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) and Pz >= 15 then
			    HasStop = true
			    awm.MoveForwardStart()

				awm.JumpOrAscendStart()
			    awm.MoveForwardStop()
				C_Timer.After(0.3, function() HasStop = false end)
				return
			elseif not HasStop and IsFacing(x,y,z) and Pz < 15 then
			    awm.AscendStop()
			end

			if Dungeon_move == 57 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) and Distance < 3 then
			    HasStop = true
			    awm.MoveForwardStart()

				awm.JumpOrAscendStart()
			    awm.MoveForwardStop()
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 71 then -- 反制
			    local target = nil
				local Scan_Distance = 15
				local tarx,tary,tarz = -11723,-1730,15
				local Target_ID = 15043

				target = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)

				if target ~= nil then
				    awm.TargetUnit(target)
					awm.CastSpellByName(rs["法术反制"],target)
				end
			end

			if Dungeon_move == 23 or Dungeon_move == 43 or Dungeon_move == 46 or (Dungeon_move == 57 and Distance > 3) or Dungeon_move == 62 or Dungeon_move == 85 or Dungeon_move == 92 or Dungeon_move == 113 then
			    awm.AscendStop()
			end

			if IsSwimming() or (Dungeon_move >= 1 and Dungeon_move <= 20) or Dungeon_move == 42 then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			if Dungeon_move == 79 and Spell_Castable(rs["急速冷却"]) and Spell_Castable(rs["冰霜新星"]) and Distance <= 8 then
			    awm.CastSpellByName(rs["冰霜新星"])
			end

			if Dungeon_move == 104 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["冰霜新星"])
				local endtime = starttime + duration
			    if Spell_Castable(rs["急速冷却"]) and GetTime() < endtime then
			        awm.CastSpellByName(rs["急速冷却"])
				end
			end

			if Dungeon_move >= 79 and Dungeon_move <= 90 and Dungeon_move ~= 80 and Dungeon_move ~= 81 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["冰霜新星"])
				local endtime = starttime + duration
			    if Spell_Castable(rs["急速冷却"]) and GetTime() < endtime then
			        awm.CastSpellByName(rs["急速冷却"])
				end
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 12 and not CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
						textout(Check_UI("附近怪物 - ","Mobs Amount - ")..count..", "..rs["冰霜新星"])
					end
				end
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == 13 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 30
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11916.37,-1431.11,46.13,x1,y1,z1)
					if guid ~= nil and (guid == 11372 or guid == 11371) and distance < Far_Distance and z1 <= 65 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = 14
					return
				end
			    return
			end

			if Dungeon_move == 28 then
			    if not awm.UnitAffectingCombat("player") then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 32 then
			    if not MakingDrinkOrEat() then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
	 			if not CheckBuff("player",rs["奥术智慧"]) then
					awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 			return
	 			end
				if not CheckBuff("player",rs["冰甲术"]) then
					awm.CastSpellByName(rs["冰甲术"])
	 	 			return
	 			end
				if not CheckUse() then
					Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
					return
				end
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 33 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 40
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11835.59,-1549.53,24.38,x1,y1,z1)
					local distance1 = awm.GetDistanceBetweenPositions(-11861.16,-1590.45,21.10,x1,y1,z1)
					if guid == 11359 and (distance < Far_Distance or distance1 < Far_Distance or awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1) < 40) and z1 <= 25 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 34 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 40) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							target = ThisUnit
						end
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				else
				    Dungeon_move = 33
					return
				end
				return
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
						    Dungeon_move = 34	
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end
				end

				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 42 then
			    local Monster = Find_Object_Position(11374,-11856.76,-1519.63,-13.34,30)
				if Monster == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				else
				    local distance = awm.GetDistanceBetweenObjects("player",Monster)
					if distance < 30 and not CheckDebuffByName(Monster,Check_Client("变形术","Polymorph")) and not CastingBarFrame:IsVisible() and Spell_Castable(Check_Client("变形术","Polymorph")) then
					    awm.CastSpellByName(Check_Client("变形术","Polymorph"),Monster)
					elseif CheckDebuffByName(Monster,Check_Client("变形术","Polymorph")) or distance >= 30 then
					    Dungeon_move = Dungeon_move + 1
						return
					end
				end
				return
			end

			if Dungeon_move == 37 or Dungeon_move == 54 or Dungeon_move == 55 or Dungeon_move == 62 or Dungeon_move == 119 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 37 then
				    sx,sy,sz = -11876.2764,-1689.5612,14.1080
					s_time = 1.5
				elseif Dungeon_move == 54 then
				    sx,sy,sz = -11733.8965,-1497.5901,38.0875
					s_time = 4
				elseif Dungeon_move == 55 then
				    sx,sy,sz = -11733.1738,-1491.9335,39.9250
					s_time = 7
				elseif Dungeon_move == 62 then
				    sx,sy,sz = -11707.80,-1605.30,13.42
					s_time = 4
				elseif Dungeon_move == 119 then
				    sx,sy,sz = -11733.8965,-1497.5901,38.0875
					s_time = 6
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 43 or Dungeon_move == 70 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 43 then
				    Target_ID = 15043
					tarx,tary,tarz = -11892.90, -1496.04, 12.97
					Scan_Distance = 8
				elseif Dungeon_move == 70 then
				    Target_ID = 15043
					tarx,tary,tarz = -11723,-1730,15
					Scan_Distance = 15
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

			if Dungeon_move == 44 or Dungeon_move == 63 or Dungeon_move == 79 or Dungeon_move == 80 or Dungeon_move == 104 or Dungeon_move == 110 or Dungeon_move == 112 or (Dungeon_move == 96 and Spell_Castable(rs["急速冷却"])) then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

	    local Path = 
		{
		{bx,by,bz}, -- 下雪
		{bx,by,bz}, -- 火冲
		{jx,jy,jz}, -- 点击 跳跃 -- -11710.4941,-1502.6415,32.8633
		{jx,jy,jz}, -- 下雪

		{-11731.61,-1534.17,8.94}, -- 闪现
		{-11735.89,-1537.97,14.50}, -- 跳
		{-11737.75,-1536.26,14.59},
		{-11747.95,-1535.51,14.39}, -- 跳
		{-11762.73,-1541.16,15.71},
		{-11771.42,-1546.24,19.11},
		{-11788.72,-1546.25,19.05},
		{-11797.79,-1542.85,19.21},
		{-11783.01,-1490.83,31.70}, -- 闪现
		{-11771.06,-1482.08,36.63},
		{-11746.86,-1487.43,39.84},

		{bx,by,bz},
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 3 or Dungeon_move == 17 then
		    if Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.12 and HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.12,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and GetTime() - Jump_Time >= 0.05 and not HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.04,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 and not IsFalling() then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 and not IsFalling() then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end



		if Distance > 0.5 then
		    ZG_Timer = false
			HasJump = false
			HasStop = false
			Jump_move = 1

			Note_Set(Check_UI("正在移动 ","Moving ")..Dungeon_move)

			if Dungeon_move == 5 or Dungeon_move == 13 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if (Dungeon_move == 6 or Dungeon_move == 8 or (Dungeon_move == 4 and Pz > 20)) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				C_Timer.After(0.07,function()
				    awm.JumpOrAscendStart()
					awm.MoveForwardStop()
				end)
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 9 or (Dungeon_move == 4 and Pz <= 20) then
			    awm.AscendStop()
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			if Dungeon_move >= 11 and Dungeon_move <= 16 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 10 then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end


			if IsSwimming() then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.5 then 
			local Monster = Combat_Scan()
			if #Monster == 0 then
			    Dungeon_step1 = 6
				Dungeon_move = 1
				return
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			HasStop = false

			if Dungeon_move == 2 then
			    if not CheckBuff("player",rs["节能施法"]) then
					local Eyu = nil
					local Far_Distance = 20
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local id = awm.ObjectId(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if awm.ObjectExists(ThisUnit) and not awm.UnitIsDead(ThisUnit) and id == 15043 and awm.UnitCanAttack("player",ThisUnit) and distance < 20 and distance < Far_Distance then		
							Far_Distance = distance
							Eyu = ThisUnit
						end
					end
					if Eyu ~= nil then
						awm.TargetUnit(Eyu)
						local tarx,tary,tarz = awm.ObjectPosition(Eyu)
						if not IsFacing(tarx,tary,tarz) then
							FacePosition(tarx,tary,tarz)
						else
							awm.CastSpellByName(rs["火焰冲击(等级 1)"],Eyu)
							Dungeon_move = 3
							return
						end
					else
						Dungeon_move = 3
						return
					end
				else
					Dungeon_move = 3
				end
				return
			end

			if Dungeon_move == 1 or Dungeon_move == 4 then -- 暴风雪
			    Note_Set(Dungeon_move.." | "..#Monster)
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				if Dungeon_move == 1 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				elseif Dungeon_move == 4 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				end

				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,tarx,tary,Pz)
					if Dungeon_move == 1 and distance < 14 and tarz >= 30 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 2
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 10 and tarz <= 20 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 1
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 3 and tarz >= 30 and awm.UnitFacing(ThisUnit) > 4.4 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 5
						textout(Check_UI("怪物回头失败 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", cannot move back"))
						return
					end
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 1 then
							Dungeon_move = 2
						elseif Dungeon_move == 4 then
						    Dungeon_move = 1
						end
						return
					end
				end

				if Spell_Castable(rs["唤醒"]) and Dungeon_move == 4 and UnitPower('player') < 3000 and not ZG_Timer and not CastingBarFrame:IsVisible() then
				    awm.CastSpellByName(rs["唤醒"])
				    return
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Is_Together(Monster) then
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 18 then -- 暴风雪
			    local sx,sy,sz = -11733.8965,-1497.5901,38.0875
				local s_time = 5

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 1
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 6 then
	    Note_Head = Check_UI("下桥","Off bridge")
		local x,y,z = -11709.4961,-1499.9115,31.3077
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往拾取, 距离 = ","Go the Loot")..math.floor(distance))
		if distance > 0.8 then
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 0.8 then
			Dungeon_step1 = 7
		end
	end
	if Dungeon_step1 == 7 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 8
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
		    Dungeon_step1 = 8
		end
	end

	if Dungeon_step1 == 8 then -- 卡死回城
	    if Easy_Data["需要喊话"] then
		    Need_Reset = true
		else
		    Reset_Instance = true
		end
		awm.Stuck()
	end
end

function ZG_16()
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

	if Dungeon_step1 >= 4 and not CastingBarFrame:IsVisible() then
		UseItem()
	end

	if Dungeon_step1 == 5 and not CastingBarFrame:IsVisible() then
		if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
			awm.CastSpellByName(rs["法师魔甲术"],"player")
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
		local x,y,z = -11916.0625,-1249.0980,92.5346
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if distance > 1 then
			if distance > 50 then
			    awm.Stuck()
				return
			end
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 2
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = -11917.0889,-1244.1870,92.5342
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
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	end
	if Dungeon_step1 == 3 then -- 血蓝恢复
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
	end
	if Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

		local Path = 
		{
		{-11916.79,-1249.95,92.53}, -- 检查buff
		{-11917.98,-1277.53,85.38},
		{-11943.00,-1268.89,85.37},
		{-11941.14,-1294.53,73.98},
		{-11950.09,-1309.73,62.42},
		{-11949.00,-1336.63,61.87},
		{-11936.21,-1361.12,61.60},
		{-11942.36,-1372.13,61.65},
		{-11943.65,-1391.60,62.65},
		{-11957.41,-1397.40,69.28},
		{-11965.41,-1404.89,71.78},
		{-11966.54,-1419.43,71.24},
		{-11955.05,-1415.53,77.89},
		{-11953.60,-1406.03,84.33}, -- 上马 开盾
		{-11946.79,-1415.20,85.16},
		{-11916.37,-1431.11,46.13},
		{-11921.58,-1448.09,42.90},
		{-11933.74,-1501.65,34.59},
		{-11940.67,-1531.62,40.58},
		{-11901.99,-1554.92,36.84},
		{-11872.1416,-1566.1510,8.9027},
		{-11867.3887,-1566.8153,12.5976}, -- 跳 面对 6.1997
		{-11858.8379,-1567.2820,16.4498},
		{-11822.7275,-1542.4856,17.2527}, -- 行走闪现
		{-11793.62,-1545.49,19.17},
		{-11769.81,-1550.59,18.81},
		{-11762.83,-1550.69,15.93},
		{-11760.5557,-1552.4899,17.0521}, -- 脱战
		{-11767.34,-1549.18,17.72},
		{-11795.09,-1544.59,19.20},
		{-11821.57,-1550.64,18.92},
		{-11835.59,-1549.53,24.38}, -- 恢复
		{-11835.59,-1549.53,24.38}, -- 扫 11359 == nil 或者 (-11861.16,-1590.45,21.10 > 40 and -11835.59,-1549.53,24.38 > 40) (tarz <= 25)
		{-11861.16,-1590.45,21.10}, -- 扫 11359 == nil 或者 -11867.44,-1676.24,19.57 > 38 而且怪物朝向 > 4 (tarz <= 25)
		{-11866.92,-1599.74,19.58},
		{-11865.35,-1673.20,19.58}, 
		{-11867.44,-1676.24,19.57}, -- 15043 -11881.44,-1685.63,14.53
		{-11865.35,-1673.20,19.58},
		{-11865.70,-1591.07,19.58}, -- 闪现
		{-11839.16,-1545.39,23.10}, -- 扫描
		{-11839.16,-1545.39,23.10}, -- 下雪
		{-11813.57,-1539.90,17.93},
		{-11800.17,-1525.66,21.30},
		{-11795.15,-1503.22,25.86}, -- 反制
		{-11750.01,-1487.11,38.85},
		{-11737.81,-1490.29,41.71},
		{-11733.17,-1491.95,39.92},	
        {bx,by,bz}, -- 闪现
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
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


		if Dungeon_move == 49 then
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.08 and HasStop then
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.08,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and not HasStop then
			    Jump_move = 2
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end

		if Distance > 0.9 then
		    ZG_Timer = false

			if Dungeon_move == 24 or Dungeon_move == 39 or Dungeon_move == 48 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and distance < 40 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 34
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end
				end
			end

			if Dungeon_move == 14 and not IsMounted() then
			    if Spell_Castable(rs["寒冰护体"]) then
				    awm.CastSpellByName(rs["寒冰护体"])
				    return
				end

				if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
					if not Tried_Mount then
						Tried_Mount = true
						awm.UseAction(Easy_Data["动作条坐骑位置"])
						textout(Check_UI("坐骑位置 - "..Easy_Data["动作条坐骑位置"]..", 尝试召唤","Mount slot in action bar - "..Easy_Data["动作条坐骑位置"]..", try mount"))
						C_Timer.After(5,function() Tried_Mount = false end)
						return
					end		
				end
				return
			end

			if Dungeon_move == 21 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
				awm.ClickToMove(x,y,z)
				awm.JumpOrAscendStart()
				awm.AscendStop()
				return
			end

			if Dungeon_move == 22 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				awm.JumpOrAscendStart()
				awm.MoveForwardStop()
				C_Timer.After(0.4, function() HasStop = false end)
				return
			end

			if Dungeon_move == 23 then
			    awm.AscendStop()
			end

			if Dungeon_move == 28 and not awm.UnitAffectingCombat("player") and Distance <= 3 then
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 41 and Dungeon_move <= 46 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 12 and not CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
							    count = count + 1
							end
						end
					end
					if count >= 3 then
				        awm.CastSpellByName(rs["冰霜新星"])
						textout(Check_UI("附近怪物 - ","Mobs Amount - ")..count..", "..rs["冰霜新星"])
					end
				end
			end

			if IsSwimming() or (Dungeon_move >= 1 and Dungeon_move <= 20) then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == 13 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 30
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11916.37,-1431.11,46.13,x1,y1,z1)
					if guid ~= nil and (guid == 11372 or guid == 11371) and distance < Far_Distance and z1 <= 65 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = 14
					return
				end
			    return
			end

			if Dungeon_move == 28 then
			    if not awm.UnitAffectingCombat("player") then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 32 then
			    if not MakingDrinkOrEat() then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
	 			if not CheckBuff("player",rs["奥术智慧"]) then
					awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 			return
	 			end
				if not CheckBuff("player",rs["冰甲术"]) then
					awm.CastSpellByName(rs["冰甲术"])
	 	 			return
	 			end
				if not CheckUse() then
					Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
					return
				end
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 33 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 40
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11835.59,-1549.53,24.38,x1,y1,z1)
					local distance1 = awm.GetDistanceBetweenPositions(-11861.16,-1590.45,21.10,x1,y1,z1)
					if guid == 11359 and (distance < Far_Distance or distance1 < Far_Distance or awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1) < 40) and z1 <= 25 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 34 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 40) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							target = ThisUnit
						end
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				else
				    Dungeon_move = 33
					return
				end
				return
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
						    Dungeon_move = 34	
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end
				end

				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 40 then
			    if not ZG_Timer then
				    ZG_Timer = true
					ZG_Time = GetTime()
				else
				    local time = GetTime() - ZG_Time
					if time >= 2 then
					    ZG_Timer = false
						Dungeon_move = 41
					end
				end
				return
			end

			if Dungeon_move == 44 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 44 then
				    Target_ID = 15043
					tarx,tary,tarz = -11817.24,-1513.66,19.43
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

			if Dungeon_move == 37 or Dungeon_move == 50 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 37 then
				    sx,sy,sz = -11876.2764,-1689.5612,14.1080
					s_time = 1.5
				elseif Dungeon_move == 50 then
				    sx,sy,sz = -11733.8965,-1497.5901,38.0875
					s_time = 4
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

	    local Path = 
		{
		{bx,by,bz}, -- 下雪
		{bx,by,bz}, -- 火冲
		{jx,jy,jz}, -- 点击 跳跃 -- -11710.4941,-1502.6415,32.8633
		{jx,jy,jz}, -- 下雪

		{-11731.61,-1534.17,8.94}, -- 闪现
		{-11735.89,-1537.97,14.50}, -- 跳
		{-11737.75,-1536.26,14.59},
		{-11747.95,-1535.51,14.39}, -- 跳
		{-11762.73,-1541.16,15.71},
		{-11771.42,-1546.24,19.11},
		{-11788.72,-1546.25,19.05},
		{-11797.79,-1542.85,19.21},
		{-11783.01,-1490.83,31.70}, -- 闪现
		{-11771.06,-1482.08,36.63},
		{-11746.86,-1487.43,39.84},

		{bx,by,bz},
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 3 or Dungeon_move == 17 then
		    if Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.12 and HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.12,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and GetTime() - Jump_Time >= 0.05 and not HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.04,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 and not IsFalling() then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 and not IsFalling() then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end



		if Distance > 0.5 then
		    ZG_Timer = false
			HasStop = false
			HasJump = false
			Jump_move = 1

			Note_Set(Check_UI("正在移动 ","Moving ")..Dungeon_move)

			if Dungeon_move == 5 or Dungeon_move == 13 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if (Dungeon_move == 6 or Dungeon_move == 8 or (Dungeon_move == 4 and Pz > 20)) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				C_Timer.After(0.07,function()
				    awm.JumpOrAscendStart()
					awm.MoveForwardStop()
				end)
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 9 or (Dungeon_move == 4 and Pz <= 20) then
			    awm.AscendStop()
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			if Dungeon_move >= 11 and Dungeon_move <= 16 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 10 then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end


			if IsSwimming() then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.5 then 
			local Monster = Combat_Scan()
			if #Monster == 0 then
			    Dungeon_step1 = 6
				Dungeon_move = 1
				return
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			HasStop = false

			if Dungeon_move == 2 then
			    if not CheckBuff("player",rs["节能施法"]) then
					local Eyu = nil
					local Far_Distance = 20
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local id = awm.ObjectId(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if awm.ObjectExists(ThisUnit) and not awm.UnitIsDead(ThisUnit) and id == 15043 and awm.UnitCanAttack("player",ThisUnit) and distance < 20 and distance < Far_Distance then		
							Far_Distance = distance
							Eyu = ThisUnit
						end
					end
					if Eyu ~= nil then
						awm.TargetUnit(Eyu)
						local tarx,tary,tarz = awm.ObjectPosition(Eyu)
						if not IsFacing(tarx,tary,tarz) then
							FacePosition(tarx,tary,tarz)
						else
							awm.CastSpellByName(rs["火焰冲击(等级 1)"],Eyu)
							Dungeon_move = 3
							return
						end
					else
						Dungeon_move = 3
						return
					end
				else
					Dungeon_move = 3
				end
				return
			end

			if Dungeon_move == 1 or Dungeon_move == 4 then -- 暴风雪
			    Note_Set(Dungeon_move.." | "..#Monster)
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				if Dungeon_move == 1 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				elseif Dungeon_move == 4 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				end

				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,tarx,tary,Pz)
					if Dungeon_move == 1 and distance < 14 and tarz >= 30 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 2
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 10 and tarz <= 20 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 1
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 3 and tarz >= 30 and awm.UnitFacing(ThisUnit) > 4.4 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 5
						textout(Check_UI("怪物回头失败 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", cannot move back"))
						return
					end
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 1 then
							Dungeon_move = 2
						elseif Dungeon_move == 4 then
						    Dungeon_move = 1
						end
						return
					end
				end

				if Spell_Castable(rs["唤醒"]) and Dungeon_move == 4 and UnitPower('player') < 3000 and not ZG_Timer and not CastingBarFrame:IsVisible() then
				    awm.CastSpellByName(rs["唤醒"])
				    return
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Is_Together(Monster) then
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 18 then -- 暴风雪
			    local sx,sy,sz = -11733.8965,-1497.5901,38.0875
				local s_time = 5

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 1
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 6 then
	    Note_Head = Check_UI("下桥","Off bridge")
		local x,y,z = -11709.4961,-1499.9115,31.3077
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往拾取, 距离 = ","Go the Loot")..math.floor(distance))
		if distance > 0.8 then
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 0.8 then
			Dungeon_step1 = 7
		end
	end
	if Dungeon_step1 == 7 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 8
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
		    Dungeon_step1 = 8
		end
	end

	if Dungeon_step1 == 8 then -- 卡死回城
	    if Easy_Data["需要喊话"] then
		    Need_Reset = true
		else
		    Reset_Instance = true
		end
		awm.Stuck()
	end
end

function ZG_2R()
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

	if (Dungeon_step1 == 4 or Dungeon_step1 == 9) and CheckDebuffByName("player",Check_Client("眩晕","Dazed")) and Spell_Castable(rs["寒冰屏障"]) then
	    awm.CastSpellByName(rs["寒冰屏障"])
	end
	if CheckBuff("player",rs["寒冰屏障"]) then
		awm.RunMacroText("/cancelAura "..rs["寒冰屏障"])
	end

	if Dungeon_step1 >= 4 and not CastingBarFrame:IsVisible() then
		UseItem()
	end

	if (Dungeon_step1 == 5 or Dungeon_step1 == 10) and not CastingBarFrame:IsVisible() then
		if not CheckBuff("player",rs["法师魔甲术"]) and Spell_Castable(rs["法师魔甲术"]) then
			awm.CastSpellByName(rs["法师魔甲术"],"player")
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
		local x,y,z = -11916.0625,-1249.0980,92.5346
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
		if distance > 1 then
			if distance > 50 then
			    awm.Stuck()
				return
			end
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 2
			Dungeon_move = 1
			return
		end
	end
	if Dungeon_step1 == 2 then
	    Note_Head = Check_UI("BUFF 解除","Unbuff")
		local x,y,z = -11917.0889,-1244.1870,92.5342
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
			awm.Interval_Move(x,y,z)
			return 
		elseif distance <= 1 then
			Dungeon_step1 = 3
		end
	end
	if Dungeon_step1 == 3 then -- 血蓝恢复
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
	end
	if Dungeon_step1 == 4 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

		local Path = 
		{
		{-11916.79,-1249.95,92.53}, -- 检查buff
		{-11917.98,-1277.53,85.38},
		{-11943.00,-1268.89,85.37},
		{-11941.14,-1294.53,73.98},
		{-11950.09,-1309.73,62.42},
		{-11949.00,-1336.63,61.87},
		{-11936.21,-1361.12,61.60},
		{-11942.36,-1372.13,61.65},
		{-11943.65,-1391.60,62.65},
		{-11957.41,-1397.40,69.28},
		{-11965.41,-1404.89,71.78},
		{-11966.54,-1419.43,71.24},
		{-11955.05,-1415.53,77.89},
		{-11953.60,-1406.03,84.33}, -- 上马 开盾
		{-11946.79,-1415.20,85.16},
		{-11916.37,-1431.11,46.13},
		{-11921.58,-1448.09,42.90},
		{-11933.74,-1501.65,34.59},
		{-11940.67,-1531.62,40.58},
		{-11901.99,-1554.92,36.84},
		{-11872.1416,-1566.1510,8.9027},
		{-11867.3887,-1566.8153,12.5976}, -- 跳 面对 6.1997
		{-11858.8379,-1567.2820,16.4498},
		{-11822.7275,-1542.4856,17.2527}, -- 行走闪现
		{-11793.62,-1545.49,19.17},
		{-11769.81,-1550.59,18.81},
		{-11762.83,-1550.69,15.93},
		{-11760.5557,-1552.4899,17.0521}, -- 脱战
		{-11767.34,-1549.18,17.72},
		{-11795.09,-1544.59,19.20},
		{-11821.57,-1550.64,18.92},
		{-11835.59,-1549.53,24.38}, -- 恢复
		{-11835.59,-1549.53,24.38}, -- 扫 11359 == nil 或者 (-11861.16,-1590.45,21.10 > 40 and -11835.59,-1549.53,24.38 > 40) (tarz <= 25)
		{-11861.16,-1590.45,21.10}, -- 扫 11359 == nil 或者 -11867.44,-1676.24,19.57 > 38 而且怪物朝向 > 4 (tarz <= 25)
		{-11866.92,-1599.74,19.58},
		{-11865.35,-1673.20,19.58}, 
		{-11867.44,-1676.24,19.57}, -- 15043 -11881.44,-1685.63,14.53
		{-11865.35,-1673.20,19.58},
		{-11865.70,-1591.07,19.58}, -- 闪现
		{-11839.16,-1545.39,23.10}, -- 扫描
		{-11839.16,-1545.39,23.10}, -- 下雪
		{-11813.57,-1539.90,17.93},
		{-11800.17,-1525.66,21.30},
		{-11795.15,-1503.22,25.86}, -- 反制
		{-11750.01,-1487.11,38.85},
		{-11737.81,-1490.29,41.71},
		{-11733.17,-1491.95,39.92},	
        {bx,by,bz}, -- 闪现
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
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


		if Dungeon_move == 49 then
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.08 and HasStop then
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.08,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and not HasStop then
			    Jump_move = 2
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end

		if Distance > 0.9 then
		    ZG_Timer = false

			if Dungeon_move == 24 or Dungeon_move == 39 or Dungeon_move == 48 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and distance < 40 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 34
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
						    return
						end
					end
				end
			end

			if Dungeon_move == 14 and not IsMounted() then
			    if Spell_Castable(rs["寒冰护体"]) then
				    awm.CastSpellByName(rs["寒冰护体"])
				    return
				end

				if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
					if not Tried_Mount then
						Tried_Mount = true
						awm.UseAction(Easy_Data["动作条坐骑位置"])
						textout(Check_UI("坐骑位置 - "..Easy_Data["动作条坐骑位置"]..", 尝试召唤","Mount slot in action bar - "..Easy_Data["动作条坐骑位置"]..", try mount"))
						C_Timer.After(5,function() Tried_Mount = false end)
						return
					end		
				end
				return
			end

			if Dungeon_move == 21 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
				awm.ClickToMove(x,y,z)
				awm.JumpOrAscendStart()
				awm.AscendStop()
				return
			end

			if Dungeon_move == 22 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				awm.JumpOrAscendStart()
				awm.MoveForwardStop()
				C_Timer.After(0.4, function() HasStop = false end)
				return
			end

			if Dungeon_move == 23 then
			    awm.AscendStop()
			end

			if Dungeon_move == 28 and not awm.UnitAffectingCombat("player") and Distance <= 3 then
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move >= 41 and Dungeon_move <= 46 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 12 and not CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
							    count = count + 1
							end
						end
					end
					if count >= 3 then
				        awm.CastSpellByName(rs["冰霜新星"])
						textout(Check_UI("附近怪物 - ","Mobs Amount - ")..count..", "..rs["冰霜新星"])
					end
				end
			end

			if IsSwimming() or (Dungeon_move >= 1 and Dungeon_move <= 20) then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false

			if Dungeon_move == 13 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 30
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11916.37,-1431.11,46.13,x1,y1,z1)
					if guid ~= nil and (guid == 11372 or guid == 11371) and distance < Far_Distance and z1 <= 65 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = 14
					return
				end
			    return
			end

			if Dungeon_move == 28 then
			    if not awm.UnitAffectingCombat("player") then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 32 then
			    if not MakingDrinkOrEat() then
					return
	 			end   
				if not NeedHeal() then
	 	 			return
	 			end
	 			if not CheckBuff("player",rs["奥术智慧"]) then
					awm.CastSpellByName(rs["奥术智慧"],"player")
	 	 			return
	 			end
				if not CheckBuff("player",rs["冰甲术"]) then
					awm.CastSpellByName(rs["冰甲术"])
	 	 			return
	 			end
				if not CheckUse() then
					Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
					return
				end
				Dungeon_move = Dungeon_move + 1
				return
			end

			if Dungeon_move == 33 then
			    local target = nil
				local total = awm.GetObjectCount()
				local Far_Distance = 40
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11835.59,-1549.53,24.38,x1,y1,z1)
					local distance1 = awm.GetDistanceBetweenPositions(-11861.16,-1590.45,21.10,x1,y1,z1)
					if guid == 11359 and (distance < Far_Distance or distance1 < Far_Distance or awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1) < 40) and z1 <= 25 then
						Far_Distance = distance
						target = ThisUnit
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				end
				return
			end

			if Dungeon_move == 34 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 40) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							target = ThisUnit
						end
					end
				end
				if target == nil then
				    Dungeon_move = Dungeon_move + 1
					return
				else
				    Dungeon_move = 33
					return
				end
				return
			end

			if Dungeon_move == 35 or Dungeon_move == 36 then
			    local target = nil
				local total = awm.GetObjectCount()
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local guid = awm.ObjectId(ThisUnit)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(-11866.92,-1599.74,19.58,x1,y1,z1)
					if Dungeon_move == 35 and guid == 11359 and (distance < 40 or awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38) and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
						    Dungeon_move = 34	
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end

					if Dungeon_move == 36 and guid == 11359 and awm.GetDistanceBetweenPositions(-11867.44,-1676.24,19.57,x1,y1,z1) < 38 and z1 <= 25 then
					    if awm.UnitFacing(ThisUnit) < 4 then
							Dungeon_move = 35
							return
						else
						    target = ThisUnit
						    if GetUnitSpeed("player") > 0 then
							    Try_Stop()
							end
							return
						end
					end
				end

				if target == nil then
				    Dungeon_move = Dungeon_move + 1
				end
				return
			end

			if Dungeon_move == 40 then
			    if not ZG_Timer then
				    ZG_Timer = true
					ZG_Time = GetTime()
				else
				    local time = GetTime() - ZG_Time
					if time >= 2 then
					    ZG_Timer = false
						Dungeon_move = 41
					end
				end
				return
			end

			if Dungeon_move == 44 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 44 then
				    Target_ID = 15043
					tarx,tary,tarz = -11817.24,-1513.66,19.43
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

			if Dungeon_move == 37 or Dungeon_move == 50 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 37 then
				    sx,sy,sz = -11876.2764,-1689.5612,14.1080
					s_time = 1.5
				elseif Dungeon_move == 50 then
				    sx,sy,sz = -11733.8965,-1497.5901,38.0875
					s_time = 4
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 5 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836


	    local Path = 
		{
		{bx,by,bz}, -- 下雪
		{bx,by,bz}, -- 火冲
		{jx,jy,jz}, -- 点击 跳跃 -- -11710.4941,-1502.6415,32.8633
		{jx,jy,jz}, -- 下雪

		{-11731.61,-1534.17,8.94}, -- 闪现
		{-11735.89,-1537.97,14.50}, -- 跳
		{-11737.75,-1536.26,14.59},
		{-11747.95,-1535.51,14.39}, -- 跳
		{-11762.73,-1541.16,15.71},
		{-11771.42,-1546.24,19.11},
		{-11788.72,-1546.25,19.05},
		{-11797.79,-1542.85,19.21},
		{-11783.01,-1490.83,31.70}, -- 闪现
		{-11771.06,-1482.08,36.63},
		{-11746.86,-1487.43,39.84},

		{bx,by,bz},
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 3 or Dungeon_move == 17 then
		    if Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.12 and HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.12,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and GetTime() - Jump_Time >= 0.05 and not HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.04,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 and not IsFalling() then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 and not IsFalling() then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end



		if Distance > 0.5 then
		    ZG_Timer = false
			HasStop = false
			Jump_move = 1

			Note_Set(Check_UI("正在移动 ","Moving ")..Dungeon_move)

			if Dungeon_move == 5 or Dungeon_move == 13 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if (Dungeon_move == 6 or Dungeon_move == 8 or (Dungeon_move == 4 and Pz > 20)) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				C_Timer.After(0.07,function()
				    awm.JumpOrAscendStart()
					awm.MoveForwardStop()
				end)
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 9 or (Dungeon_move == 4 and Pz <= 20) then
			    awm.AscendStop()
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			if Dungeon_move >= 11 and Dungeon_move <= 16 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 10 then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end


			if IsSwimming() then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.5 then 
			local Monster = Combat_Scan()
			if #Monster == 0 then
			    Dungeon_step1 = 6
				Dungeon_move = 1
				return
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			HasStop = false

			if Dungeon_move == 2 then
			    if not CheckBuff("player",rs["节能施法"]) then
					local Eyu = nil
					local Far_Distance = 20
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local id = awm.ObjectId(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if awm.ObjectExists(ThisUnit) and not awm.UnitIsDead(ThisUnit) and id == 15043 and awm.UnitCanAttack("player",ThisUnit) and distance < 20 and distance < Far_Distance then		
							Far_Distance = distance
							Eyu = ThisUnit
						end
					end
					if Eyu ~= nil then
						awm.TargetUnit(Eyu)
						local tarx,tary,tarz = awm.ObjectPosition(Eyu)
						if not IsFacing(tarx,tary,tarz) then
							FacePosition(tarx,tary,tarz)
						else
							awm.CastSpellByName(rs["火焰冲击(等级 1)"],Eyu)
							Dungeon_move = 3
							return
						end
					else
						Dungeon_move = 3
						return
					end
				else
					Dungeon_move = 3
				end
				return
			end

			if Dungeon_move == 1 or Dungeon_move == 4 then -- 暴风雪
			    Note_Set(Dungeon_move.." | "..#Monster)
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				if Dungeon_move == 1 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				elseif Dungeon_move == 4 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				end

				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,tarx,tary,Pz)
					if Dungeon_move == 1 and distance < 14 and tarz >= 30 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 2
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 10 and tarz <= 20 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 1
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 3 and tarz >= 30 and awm.UnitFacing(ThisUnit) > 4.4 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 5
						textout(Check_UI("怪物回头失败 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", cannot move back"))
						return
					end
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 1 then
							Dungeon_move = 2
						elseif Dungeon_move == 4 then
						    Dungeon_move = 1
						end
						return
					end
				end

				if Spell_Castable(rs["唤醒"]) and Dungeon_move == 4 and UnitPower('player') < 3000 and not ZG_Timer and not CastingBarFrame:IsVisible() then
				    awm.CastSpellByName(rs["唤醒"])
				    return
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Is_Together(Monster) then
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 18 then -- 暴风雪
			    local sx,sy,sz = -11733.8965,-1497.5901,38.0875
				local s_time = 5

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 1
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 6 then
	    Note_Head = Check_UI("下桥","Off bridge")
		local x,y,z = -11709.4961,-1499.9115,31.3077
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往拾取, 距离 = ","Go the Loot")..math.floor(distance))
		if distance > 0.8 then
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 0.8 then
			Dungeon_step1 = 7
		end
	end
	if Dungeon_step1 == 7 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 8
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
		    Dungeon_step1 = 8
		end
	end

	if Dungeon_step1 == 8 then -- 血蓝恢复
	    Note_Head = Check_UI("血蓝恢复","Restoring and making")
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

		if not CheckBuff("player",rs["寒冰护体"]) then
			Note_Set(rs["寒冰护体"]..Check_UI("BUFF增加中...","Buff Adding"))
			awm.CastSpellByName(rs["寒冰护体"])
	 	 	return
	 	end
		if not CheckUse() then
			Note_Set(Check_UI("制造宝石中...","Conjure GEM..."))
			return
		end
		HasStop = false
		Dungeon_step1 = 9
		Dungeon_move = 51
	end
	if Dungeon_step1 == 9 then -- 开始流程
	    Note_Head = Check_UI("拉怪","Pulling mobs")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

		local Path = 
		{
		{-11916.79,-1249.95,92.53}, -- 检查buff
		{-11917.98,-1277.53,85.38},
		{-11943.00,-1268.89,85.37},
		{-11941.14,-1294.53,73.98},
		{-11950.09,-1309.73,62.42},
		{-11949.00,-1336.63,61.87},
		{-11936.21,-1361.12,61.60},
		{-11942.36,-1372.13,61.65},
		{-11943.65,-1391.60,62.65},
		{-11957.41,-1397.40,69.28},
		{-11965.41,-1404.89,71.78},
		{-11966.54,-1419.43,71.24},
		{-11955.05,-1415.53,77.89},
		{-11953.60,-1406.03,84.33}, -- 上马 开盾
		{-11946.79,-1415.20,85.16},
		{-11916.37,-1431.11,46.13},
		{-11921.58,-1448.09,42.90},
		{-11933.74,-1501.65,34.59},
		{-11940.67,-1531.62,40.58},
		{-11901.99,-1554.92,36.84},
		{-11872.1416,-1566.1510,8.9027},
		{-11867.3887,-1566.8153,12.5976}, -- 跳 面对 6.1997
		{-11858.8379,-1567.2820,16.4498},
		{-11822.7275,-1542.4856,17.2527}, -- 行走闪现
		{-11793.62,-1545.49,19.17},
		{-11769.81,-1550.59,18.81},
		{-11762.83,-1550.69,15.93},
		{-11760.5557,-1552.4899,17.0521}, -- 脱战
		{-11767.34,-1549.18,17.72},
		{-11795.09,-1544.59,19.20},
		{-11821.57,-1550.64,18.92},
		{-11835.59,-1549.53,24.38}, -- 恢复
		{-11835.59,-1549.53,24.38}, -- 扫 11359 == nil 或者 (-11861.16,-1590.45,21.10 > 40 and -11835.59,-1549.53,24.38 > 40) (tarz <= 25)
		{-11861.16,-1590.45,21.10}, -- 扫 11359 == nil 或者 -11867.44,-1676.24,19.57 > 38 而且怪物朝向 > 4 (tarz <= 25)
		{-11866.92,-1599.74,19.58},
		{-11865.35,-1673.20,19.58}, 
		{-11867.44,-1676.24,19.57}, -- 15043 -11881.44,-1685.63,14.53
		{-11865.35,-1673.20,19.58},
		{-11865.70,-1591.07,19.58}, -- 闪现
		{-11839.16,-1545.39,23.10},
		{-11843.56,-1540.03,18.25},
		{-11853.08,-1530.54,10.06}, -- 跳
		{-11861.61,-1496.22,8.94}, -- 反制 15043, -11892.90, -1496.04, 12.97
		{-11827.95,-1480.46,8.91}, -- 闪现 冰环
		{-11821.7197,-1483.4459,13.0263},
		{-11814.8232,-1472.8654,18.0102},
		{-11794.7686,-1468.8326,37.1761},
		{-11790.2490,-1464.2147,38.6832},
		{-11782.3018,-1469.7611,46.3094},
		{-11765.2021,-1483.3679,36.9993},
		{-11734.1885,-1491.5686,40.5470},
        {bx,by,bz}, -- 闪现
		{bx,by,bz},
		{bx,by,bz},
		{bx,by,bz},
		{jx,jy,jz}, -- 跳跃
		{-11710.00,-1559.81,8.96}, -- 落水闪现
		{-11712.8945,-1560.5325,11.1474}, -- 落水闪现
		{-11708.7949,-1562.1304,10.3572},
		{-11707.94,-1604.53,13.51},
		{-11707.49,-1617.32,14.93},
		{-11706.7773,-1635.3887,16.4120}, -- 下雪 -11707.80,-1605.30,13.42
		{-11706.12,-1656.64,16.26}, -- 冰环
		{-11705.56,-1672.62,14.76},
		{-11705.32,-1679.34,13.66},
		{-11701.25,-1691.59,9.34},
		{-11702.22,-1697.65,10.51},
		{-11704.29,-1712.60,12.14},
		{-11700.23,-1724.71,10.50},
		{-11698.81,-1727.18,8.93}, -- 反制 15043 -11714,-1731,12
		{-11685.18,-1753.21,11.32}, -- 闪现
		{-11675.37,-1757.42,14.05},
		{-11657.40,-1759.08,23.10},
		{-11641.96,-1764.07,34.21},
		{-11647.55,-1776.06,35.39},
		{-11650.37,-1783.63,36.73},
		{-11655.46,-1792.10,37.70},
		{-11675.88,-1784.76,13.02},
		{-11702.08,-1776.59,12.32}, -- 急冷 冰环
		{-11704.75,-1771.70,11.25},
		{-11728.01,-1749.66,11.42}, -- 闪现
		{-11740.11,-1744.34,15.98},
		{-11744.23,-1744.14,17.12},
		{-11745.33,-1747.04,19.71}, -- 点击跳跃
		{-11742.62,-1754.06,17.27},
		{-11750.08,-1758.27,14.49},
		{-11755.38,-1764.41,11.41},
		{-11759.70,-1768.81,8.88},
		{-11779.15,-1768.01,8.74},
		{-11775.28,-1758.72,17.28},
		{-11775.9404,-1756.5320,18.0101},
		{-11774.02,-1744.43,12.97},
		{-11787.98,-1733.83,11.39},
		{-11809.88,-1727.93,11.23},
		{-11833.92,-1728.77,9.38},
		{-11840.97,-1730.87,8.93},
		{-11870.83,-1765.41,12.45}, -- 闪现
		{-11872.31,-1775.71,19.36},
		{-11881.44,-1778.92,24.17},
		{-11889.29,-1771.62,25.99},
		{-11902.50,-1768.91,35.17},
		{-11914.78,-1766.56,42.95},
		{-11904.76,-1748.74,14.78},
		{-11896.93,-1744.19,13.77}, -- 冰环
		{-11877.89,-1700.12,10.56}, -- 闪现
		{-11885.17,-1681.24,13.34},
		{-11883.07,-1665.10,11.37},
		{-11877.82,-1646.13,11.77},
		{-11871.30,-1598.69,12.16},
		{-11871.94,-1576.17,10.76},
		{-11872.5566,-1566.3904,8.9012},
		{-11867.3887,-1566.8153,12.5976}, -- 点击 跳
		{-11863.37,-1567.05,14.86},
		{-11839.37,-1549.06,23.23}, -- 闪现
		{-11816.03,-1544.45,18.21},
		{-11749.28,-1486.06,39.26},
		{bx,by,bz}, -- 闪现
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
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


		if Dungeon_move == 56 or Dungeon_move == 118 then
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.08 and HasStop then
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.08,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and not HasStop then
			    Jump_move = 2
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end

		if Distance > 0.9 then
		    ZG_Timer = false

			if Dungeon_move == 57 or Dungeon_move == 71 or Dungeon_move == 81 or Dungeon_move == 97 or Dungeon_move == 105 or Dungeon_move == 114 or Dungeon_move == 117 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
				    if Dungeon_move == 57 then
					    if Distance <= 20 then
						    Interact_Step = true
							C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
						else
						    CheckProtection()
						end
					elseif Dungeon_move == 117 and Pz >= 41.5 then
						Interact_Step = true
						C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
					else
					    Interact_Step = true
						C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
					end
				end
			else
			    if Distance >= 7 or Dungeon_move == 56 or Dungeon_move == 57 then
					CheckProtection()
				end
			end

			if (Dungeon_move == 61 or Dungeon_move == 84 or Dungeon_move == 112) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()

				awm.JumpOrAscendStart()
			    awm.MoveForwardStop()

				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 57 and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) and Distance < 3 then
			    HasStop = true
			    awm.MoveForwardStart()

				awm.JumpOrAscendStart()
			    awm.MoveForwardStop()
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 71 then -- 反制
			    local target = nil
				local Scan_Distance = 15
				local tarx,tary,tarz = -11723,-1730,15
				local Target_ID = 15043

				target = Find_Object_Position(Target_ID,tarx,tary,tarz,Scan_Distance)

				if target ~= nil then
				    awm.TargetUnit(target)
					awm.CastSpellByName(rs["法术反制"],target)
				end
			end

			if (Dungeon_move == 57 and Distance > 3) or Dungeon_move == 62 or Dungeon_move == 85 or Dungeon_move == 92 or Dungeon_move == 113 then
			    awm.AscendStop()
			end

			if Dungeon_move == 51 then
			    Run(x,y,z)
				return
			end

			if IsSwimming() then
			    awm.Interval_Move(x,y,z + 0.5)
			else
				awm.MoveTo(x,y,z)
			end

			if Dungeon_move == 79 and Spell_Castable(rs["急速冷却"]) and Spell_Castable(rs["冰霜新星"]) and Distance <= 8 then
			    awm.CastSpellByName(rs["冰霜新星"])
			end


			if Dungeon_move == 104 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["冰霜新星"])
				local endtime = starttime + duration
			    if Spell_Castable(rs["急速冷却"]) and GetTime() < endtime then
			        awm.CastSpellByName(rs["急速冷却"])
				end
			end

			if (Dungeon_move >= 79 and Dungeon_move <= 90 and Dungeon_move ~= 80 and Dungeon_move ~= 81) or Dungeon_move == 110 then
			    local starttime, duration, enabled, _ = GetSpellCooldown(rs["冰霜新星"])
				local endtime = starttime + duration
			    if Spell_Castable(rs["急速冷却"]) and GetTime() < endtime then
			        awm.CastSpellByName(rs["急速冷却"])
				end
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 11 and not CheckDebuffByName(Monster[i],rs["冰霜新星"]) then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
						textout(Check_UI("附近怪物 - ","Mobs Amount - ")..count..", "..rs["冰霜新星"])
					end
				end
			end

			return 
		elseif Distance <= 0.9 then
			HasStop = false
			
			if Dungeon_move == 61 then
			    Try_Stop()
			    if awm.UnitAffectingCombat("player") then
				    return
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
				Dungeon_move = 62
			    return
			end

			if Dungeon_move == 119 then -- 暴风雪
			    local Monster = Combat_Scan()
			    local sx,sy,sz = 0,0,0
				local s_time = 1.5
				if Dungeon_move == 119 then
				    sx,sy,sz = -11733.8965,-1497.5901,38.0875
					s_time = 6
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 70 then -- 反制
				local Scan_Distance = 8
				if Dungeon_move == 70 then
				    Target_ID = 15043
					tarx,tary,tarz = -11723,-1730,15
					Scan_Distance = 15
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

			if Dungeon_move == 63 or Dungeon_move == 104 or Dungeon_move == 110 or Dungeon_move == 112 or (Dungeon_move == 96 and Spell_Castable(rs["急速冷却"])) then -- 冰环
			    awm.CastSpellByName(rs["冰霜新星"])
			end

			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 10 then -- A怪
		Note_Head = Check_UI("击杀","AOE killing")

		local jx,jy,jz = -11707.24,-1503.85,32.79
		local bx,by,bz = -11707.99,-1500.38,31.18
		local Jump_Face = 4.8836

	    local Path = 
		{
		{bx,by,bz}, -- 下雪
		{bx,by,bz}, -- 火冲
		{jx,jy,jz}, -- 点击 跳跃 -- -11710.4941,-1502.6415,32.8633
		{jx,jy,jz}, -- 下雪

		{-11731.61,-1534.17,8.94}, -- 闪现
		{-11735.89,-1537.97,14.50}, -- 跳
		{-11737.75,-1536.26,14.59},
		{-11747.95,-1535.51,14.39}, -- 跳
		{-11762.73,-1541.16,15.71},
		{-11771.42,-1546.24,19.11},
		{-11788.72,-1546.25,19.05},
		{-11797.79,-1542.85,19.21},
		{-11783.01,-1490.83,31.70}, -- 闪现
		{-11771.06,-1482.08,36.63},
		{-11746.86,-1487.43,39.84},

		{bx,by,bz},
		{jx,jy,jz}, -- 点击 跳跃
		{jx,jy,jz}, -- 下雪
		}
		local Coord = Path[Dungeon_move]
		local x,y,z = Coord[1],Coord[2],Coord[3]
		local Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

		if Dungeon_move == 3 or Dungeon_move == 17 then
		    if Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end
		    if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
			    textout(Check_UI("头部成功","Head Jump Success"))
			    Try_Stop()
				Dungeon_move = Dungeon_move + 1
				Jump_move = 1
				return
			end
		    if Jump_move == 1 and GetTime() - Jump_Time >= 0.12 and HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.12,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
			elseif Jump_move == 1 and GetTime() - Jump_Time >= 0.05 and not HasStop then
			    HasJump = false
			    if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
			    Jump_Time = GetTime()
				awm.MoveBackwardStart()
				textout(Check_UI("向后移动, 准备跳桥","Move back, ready to jump"))

				C_Timer.After(0.04,function()
				    if GetUnitMovementFlags("player") ~= 0 and Jump_move == 1 then
				        Try_Stop()
					end
					if Jump_move == 1 then
					    Try_Stop()
						Jump_move = 2
						HasStop = false
						HasJump = false
					end
				end)
				return
			end

			if Jump_move == 2 and GetTime() - Jump_Time >= 0.3 and awm.GetUnitMovementFlags("player") == 0 and not IsFalling() then
				if math.abs(UnitFacing("player") - Jump_Face) > 0.01 then
				    awm.FaceDirection(Jump_Face)
					return
				end
				if HasJump and Pz <= 32.1 then
				    textout(Check_UI("头部失败","Head Jump Fail"))
				    HasJump = false
					HasStop = true -- 失败标志
					Jump_move = 1
					return
				end

				Jump_Time = GetTime()

				awm.MoveForwardStart()
				textout(Check_UI("前移","Move Forward"))

				C_Timer.After(0.08,function()
				    if not HasJump and Jump_move == 2 and Pz <= 32.1 then
					    HasJump = true
						awm.MoveForwardStart()
						awm.JumpOrAscendStart()
						textout(Check_UI("跳桥","Jump"))
						awm.MoveForwardStart()
						awm.MoveForwardStop()
					end
				end)
				C_Timer.After(0.3, function()
				    Try_Stop()
					if Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz >= 32.1 and not IsFalling() then
					    textout(Check_UI("成功","Jump Success"))
						HasJump = false
					    Dungeon_move = Dungeon_move + 1
						Jump_move = 1
						return
					elseif Jump_move == 2 and awm.GetUnitMovementFlags("player") == 0 and Pz < 32.1 and not IsFalling() then
					    textout(Check_UI("失败","Jump Fail"))
						HasJump = false
						HasStop = true -- 失败标志
						Jump_move = 1
						return
					end
				end)
				return
			end
			return
		end



		if Distance > 0.5 then
		    ZG_Timer = false
			HasStop = false

			Jump_move = 1

			Note_Set(Check_UI("正在移动 ","Moving ")..Dungeon_move)

			if Dungeon_move == 5 or Dungeon_move == 13 then -- 闪现
			    if IsFacing(x,y,z) and Spell_Castable(rs["闪现术"]) and not Interact_Step then
					Interact_Step = true
					C_Timer.After(0.15,function() awm.CastSpellByName(rs["闪现术"]) Interact_Step = false end)
				end
			else
			    if Distance >= 7 then
					CheckProtection()
				end
			end

			if (Dungeon_move == 6 or Dungeon_move == 8 or (Dungeon_move == 4 and Pz > 20)) and GetUnitSpeed("player") > 0 and not HasStop and IsFacing(x,y,z) then
			    HasStop = true
			    awm.MoveForwardStart()
				C_Timer.After(0.07,function()
				    awm.JumpOrAscendStart()
					awm.MoveForwardStop()
				end)
				C_Timer.After(0.3, function() HasStop = false end)
				return
			end

			if Dungeon_move == 9 or (Dungeon_move == 4 and Pz <= 20) then
			    awm.AscendStop()
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			if Dungeon_move >= 11 and Dungeon_move <= 16 then
				if Spell_Castable(rs["冰霜新星"]) then
				    local Monster = Combat_Scan()
					local count = 0
					if #Monster > 0 then
					    for i = 1,#Monster do
						    local Tar_distance = awm.GetDistanceBetweenObjects("player",Monster[i])
							if Tar_distance <= 10 then
							    count = count + 1
							end
						end
					end
					if count >= 4 then
				        awm.CastSpellByName(rs["冰霜新星"])
					end
				end
			end


			if IsSwimming() then
			    awm.Interval_Move(x,y,z + 0.5)			
			else
				awm.MoveTo(x,y,z)
			end

			return 
		elseif Distance <= 0.5 then 
			local Monster = Combat_Scan()
			if #Monster == 0 then
			    Dungeon_step1 = 11
				Dungeon_move = 1
				return
			end

			if (Dungeon_move >= 1 and Dungeon_move <= 4) and Pz <= 15 then
			    awm.AscendStop()
			    Dungeon_move = 5
				textout(Check_UI("掉落","Fall down"))
				return
			end

			HasStop = false

			if Dungeon_move == 2 then
			    if not CheckBuff("player",rs["节能施法"]) then
					local Eyu = nil
					local Far_Distance = 20
					local total = awm.GetObjectCount()
					for i = 1,total do
						local ThisUnit = awm.GetObjectWithIndex(i)
						local id = awm.ObjectId(ThisUnit)
						local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
						if awm.ObjectExists(ThisUnit) and not awm.UnitIsDead(ThisUnit) and id == 15043 and awm.UnitCanAttack("player",ThisUnit) and distance < 20 and distance < Far_Distance then		
							Far_Distance = distance
							Eyu = ThisUnit
						end
					end
					if Eyu ~= nil then
						awm.TargetUnit(Eyu)
						local tarx,tary,tarz = awm.ObjectPosition(Eyu)
						if not IsFacing(tarx,tary,tarz) then
							FacePosition(tarx,tary,tarz)
						else
							awm.CastSpellByName(rs["火焰冲击(等级 1)"],Eyu)
							Dungeon_move = 3
							return
						end
					else
						Dungeon_move = 3
						return
					end
				else
					Dungeon_move = 3
				end
				return
			end

			if Dungeon_move == 1 or Dungeon_move == 4 then -- 暴风雪
			    Note_Set(Dungeon_move.." | "..#Monster)
			    local sx,sy,sz = 0,0,0
				local s_time = 7.5

				if Dungeon_move == 1 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				elseif Dungeon_move == 4 then
				    sx,sy,sz = -11735.4873,-1490.7748,41.3999
					s_time = 7.5
				end

				for i = 1,#Monster do
					local ThisUnit = Monster[i]
					local tarx,tary,tarz = awm.ObjectPosition(ThisUnit)
					local guid = awm.ObjectId(ThisUnit)
					local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,tarx,tary,Pz)
					if Dungeon_move == 1 and distance < 14 and tarz >= 30 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 2
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 10 and tarz <= 20 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 1
						textout(Check_UI("怪物靠近 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", too close to me"))
						return
					elseif Dungeon_move == 4 and distance < 3 and tarz >= 30 and awm.UnitFacing(ThisUnit) > 4.4 and guid == 15043 then
						ZG_Timer = false
						log_Spell = false
						awm.SpellStopCasting()
						if Spell_Castable(rs["寒冰护体"]) and not CheckBuff("player",rs["寒冰护体"]) then
							awm.CastSpellByName(rs["寒冰护体"],"player")
						end
						Dungeon_move = 5
						textout(Check_UI("怪物回头失败 - "..awm.UnitFullName(ThisUnit),"Mobs - "..awm.UnitFullName(ThisUnit)..", cannot move back"))
						return
					end
				end

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						if Dungeon_move == 1 then
							Dungeon_move = 2
						elseif Dungeon_move == 4 then
						    Dungeon_move = 1
						end
						return
					end
				end

				if Spell_Castable(rs["唤醒"]) and Dungeon_move == 4 and UnitPower('player') < 3000 and not ZG_Timer and not CastingBarFrame:IsVisible() then
				    awm.CastSpellByName(rs["唤醒"])
				    return
				end

				if not CastingBarFrame:IsVisible() then
				    if not awm.IsAoEPending() then
					    if CheckBuff("player",rs["节能施法"]) then
							awm.CastSpellByName(rs["暴风雪"])

							if not log_Spell then
								log_Spell = true
								textout(rs["节能施法"]..Check_UI(", 使用",", Cast ")..rs["暴风雪"])
							end
						elseif awm.UnitPower("player") > 4000 and Is_Together(Monster) then
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end

			if Dungeon_move == 18 then -- 暴风雪
			    local sx,sy,sz = -11733.8965,-1497.5901,38.0875
				local s_time = 5

				if ZG_Timer then
				    local time = GetTime() - ZG_Time
					local time1 = s_time - time
					if time >= s_time then
					    ZG_Timer = false
						awm.SpellStopCasting()
						Target_Monster = nil
						Dungeon_move = 1
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
				    if not ZG_Timer then
						ZG_Timer = true
						ZG_Time = GetTime()
					end
				end
				return
			end
			Dungeon_move = Dungeon_move + 1
		end
	end
	if Dungeon_step1 == 11 then
	    Note_Head = Check_UI("下桥","Off bridge")
		local x,y,z = -11709.4961,-1499.9115,31.3077
		local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		Note_Set(Check_UI("前往拾取, 距离 = ","Go the Loot")..math.floor(distance))
		if distance > 0.8 then
			awm.MoveTo(x,y,z)
			return 
		elseif distance <= 0.8 then
			Dungeon_step1 = 12
		end
	end
	if Dungeon_step1 == 12 then -- 拾取阶段
	    local body_list = Find_Body()
		Note_Set(Check_UI("拾取... 附近尸体 = ","Loot, body count = ")..#body_list)
		if CalculateTotalNumberOfFreeBagSlots() == 0 then
		    Dungeon_step1 = 13
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
		    Dungeon_step1 = 13
		end
	end

	if Dungeon_step1 == 13 then -- 卡死回城
	    if Easy_Data["需要喊话"] then
		    Need_Reset = true
		else
		    Reset_Instance = true
		end
		awm.Stuck()
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

		if #OBJ_Killed >= 1 and not Need_Reset and not Reset_Instance then
		    Need_Reset = true
			textout(Check_UI("怪物击杀, 判断残本","Mobs kill, Force reset dungeon"))
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
				if Faction == "Horde" then -- 部落联盟分开设置 
					Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1434, -12357.7744, 155.5521, 4.2480
					Merchant_Name = Check_Client("维哈尔","Vharr")
				else
					Merchant_Coord.mapid, Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = 1434, -10590.5215, -1155.9293, 30.0596
					Merchant_Name = Check_Client("莫格·纳尔特里","Morg Gnarltree")
				end
			end

			if Instance == 309 and Dungeon_step == 2 then
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
		    elseif Instance ~= 309 then
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
				    if not Has_Mail and Easy_Data["需要邮寄"] and Easy_Data["卖物前邮寄"] then
						if Faction == "Horde" then -- 部落联盟分开设置 
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -12389.50,145.42,2.70
						else
							Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -10547.44,-1157.22,27.89
						end

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
		    if Faction == "Horde" then -- 部落联盟分开设置 
				Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -12389.50,145.42,2.70
			else
				Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = 1434, -10547.44,-1157.22,27.89
			end

			if Easy_Data["自定义邮箱"] then
				local Coord = string.split(Easy_Data["自定义邮箱坐标"],",")
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = Coord[1],Coord[2],Coord[3],Coord[4]
				Mail_Coord.mapid, Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = tonumber(Mail_Coord.mapid),tonumber(Mail_Coord.x),tonumber(Mail_Coord.y),tonumber(Mail_Coord.z)
			end
			
			
			if Instance == 309 and Dungeon_step == 2 then
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
			elseif Instance ~= 309 then
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

	if Instance == 309 then
        Real_Flush = false -- 触发爆本
        Real_Flush_time = 0 -- 第一次爆本时间
		Real_Flush_times = 0 -- 爆本计数

		Easy_Data.Sever_Map_Calculated = false
        Continent_Move = false

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
		    if Easy_Data["四波鳄鱼"] then
		        ZG_16()
			elseif Easy_Data["两波流"] then
			    ZG_2R()
			elseif Easy_Data["8波鳄鱼"] then
			    ZG_36()
			end
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

			if distance < 30 then
				local total = awm.GetObjectCount(false)
				for i = 1,total do
					local ThisUnit = awm.GetObjectWithIndex(i)
					local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
					local distance2 = awm.GetDistanceBetweenPositions(x1,y1,z1,-11916.19,-1221.09,92.28)
					local name = awm.UnitGUID(ThisUnit)
					if awm.ObjectIsGameObject(ThisUnit) and string.find(name,"180323") and distance2 < 3 and awm.GetDistanceBetweenObjects("player",ThisUnit) < 10 then
						awm.InteractUnit(ThisUnit)
					end
				end
			end

			if (Easy_Data["服务器地图"] and Current_Map ~= 1434 and PlayerFrame:IsVisible()) or Easy_Data.Sever_Map_Calculated or Continent_Move then
				Note_Set(Check_UI("使用云地图包进行寻路","Using Sever Map System"))
				Sever_Run(Current_Map,1434,Dungeon_In.x,Dungeon_In.y,Dungeon_In.z)
				return
			end

			Run(x,y,z)
			return
		elseif distance <= 1 and not Dungeon_Flush then
			if not Interact_Step then
				Interact_Step = true
				    
				C_Timer.After(1.5,function() 
					Interact_Step = false 
					if Instance ~= 309 then
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

	local function Choose_UI()
		Basic_UI.Set["8波鳄鱼"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("8波 鳄鱼","36 mobs pull"))
		Basic_UI.Set["8波鳄鱼"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["8波鳄鱼"]:GetChecked() then
				Easy_Data["8波鳄鱼"] = true

				Easy_Data["四波鳄鱼"] = false
				Basic_UI.Set["四波鳄鱼"]:SetChecked(false)

				Easy_Data["两波流"] = false
				Basic_UI.Set["两波流"]:SetChecked(false)

			elseif not Basic_UI.Set["8波鳄鱼"]:GetChecked() then
				Easy_Data["8波鳄鱼"] = false
			end
		end)
		if Easy_Data["8波鳄鱼"] ~= nil then
			if Easy_Data["8波鳄鱼"] then
				Basic_UI.Set["8波鳄鱼"]:SetChecked(true)
			else
				Basic_UI.Set["8波鳄鱼"]:SetChecked(false)
			end
		else
			Easy_Data["8波鳄鱼"] = true
			Basic_UI.Set["8波鳄鱼"]:SetChecked(true)
		end
	    
		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
	    Basic_UI.Set["四波鳄鱼"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("击杀 3 波鳄鱼","12 - 18 mobs pull"))
		Basic_UI.Set["四波鳄鱼"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["四波鳄鱼"]:GetChecked() then
				Easy_Data["四波鳄鱼"] = true

				Easy_Data["两波流"] = false
				Basic_UI.Set["两波流"]:SetChecked(false)

				Easy_Data["8波鳄鱼"] = false
				Basic_UI.Set["8波鳄鱼"]:SetChecked(false)

			elseif not Basic_UI.Set["四波鳄鱼"]:GetChecked() then
				Easy_Data["四波鳄鱼"] = false
			end
		end)
		if Easy_Data["四波鳄鱼"] ~= nil then
			if Easy_Data["四波鳄鱼"] then
				Basic_UI.Set["四波鳄鱼"]:SetChecked(true)
			else
				Basic_UI.Set["四波鳄鱼"]:SetChecked(false)
			end
		else
			Easy_Data["四波鳄鱼"] = false
			Basic_UI.Set["四波鳄鱼"]:SetChecked(false)
		end

		Basic_UI.Set.Py = Basic_UI.Set.Py - 30
		Basic_UI.Set["两波流"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("3波 鳄鱼 + 4波 鳄鱼","30 mobs pull"))
		Basic_UI.Set["两波流"]:SetScript("OnClick", function(self)
			if Basic_UI.Set["两波流"]:GetChecked() then
				Easy_Data["两波流"] = true

				Easy_Data["四波鳄鱼"] = false
				Basic_UI.Set["四波鳄鱼"]:SetChecked(false)

				Easy_Data["8波鳄鱼"] = false
				Basic_UI.Set["8波鳄鱼"]:SetChecked(false)

			elseif not Basic_UI.Set["两波流"]:GetChecked() then
				Easy_Data["两波流"] = false
			end
		end)
		if Easy_Data["两波流"] ~= nil then
			if Easy_Data["两波流"] then
				Basic_UI.Set["两波流"]:SetChecked(true)
			else
				Basic_UI.Set["两波流"]:SetChecked(false)
			end
		else
			Easy_Data["两波流"] = false
			Basic_UI.Set["两波流"]:SetChecked(false)
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
		Basic_UI.Set["需要剥皮"] = Create_Check_Button(Basic_UI.Set.frame, "TOPLEFT",10, Basic_UI.Set.Py, Check_UI("需要剥皮怪物","Need Skin Mobs"))
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
			Easy_Data["需要剥皮"] = false
			Basic_UI.Set["需要剥皮"]:SetChecked(false)
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
	    local Header1 = Create_Header(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,Check_UI("祖尔格拉布 爆本 本外等待坐标","ZUG Wait Point")) 

		Basic_UI.Set.Py = Basic_UI.Set.Py - 20
		Basic_UI.Set["祖格等待坐标"] = Create_EditBox(Basic_UI.Set.frame,"TOPLEFT",10, Basic_UI.Set.Py,"-11915.8945,-1202.551,92.2611",false,280,24)
		Basic_UI.Set["祖格等待坐标"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["祖格等待坐标"] = Basic_UI.Set["祖格等待坐标"]:GetText()
			local coord_package = string.split(Easy_Data["祖格等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		end)
		if Easy_Data["祖格等待坐标"] ~= nil then
			Basic_UI.Set["祖格等待坐标"]:SetText(Easy_Data["祖格等待坐标"])
			local coord_package = string.split(Easy_Data["祖格等待坐标"],",")
			Dungeon_Flush_Point.x,Dungeon_Flush_Point.y,Dungeon_Flush_Point.z = tonumber(coord_package[1]),tonumber(coord_package[2]),tonumber(coord_package[3])
		else
			Easy_Data["祖格等待坐标"] = Basic_UI.Set["祖格等待坐标"]:GetText()
		end

		Basic_UI.Set["获取等待坐标"] = Create_Button(Basic_UI.Set.frame,"TOPLEFT",320, Basic_UI.Set.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Set["获取等待坐标"]:SetSize(120,24)
		Basic_UI.Set["获取等待坐标"]:SetScript("OnClick", function(self)
			local Instance_Name,_,_,_,_,_,_,Instance = GetInstanceInfo()
			if Instance ~= 309 then
			    local x,y,z = awm.ObjectPosition("player")
				Basic_UI.Set["祖格等待坐标"]:SetText(math.floor(x)..","..math.floor(y)..","..math.floor(z))
				Easy_Data["祖格等待坐标"] = Basic_UI.Set["祖格等待坐标"]:GetText()
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

	Frame_Create()
	Button_Create()	

	Choose_UI()
	Loot_UI()
	Loot_Interval()
	Wait_point()
	Dungeon_Wait_Time()
	Order_UI()
	Item_Use_UI()
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

	if subevent == "PARTY_KILL" and sourceGUID == awm.UnitGUID("player") and string.find(destGUID,"15043") then
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