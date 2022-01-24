Function_Load_In = true
local Function_Version = "1124"
textout(Check_UI("定点冰枪术击杀 - "..Function_Version,"Fixed Spot Mobs Farm - "..Function_Version))

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
local Item_Used = false -- 间隔一段时间使用物品
local Start_Restore = false -- 是否正在回血

local Learn_Step = 1 -- 学技能步骤
local Learn_Time = 0
local Has_Mail = false -- 邮寄过了
local Start_Buy_Ammo = false -- 开始买子弹
local Has_Bought_Food_Drink = false -- 足够钱买食物
local Start_Buy_Food = false -- 开始买食物
local Start_Buy_Pet_Food = false

local Forst = false -- 冰环后跑
local Multi_Target = false -- 多怪物
local Monster_Evade = false -- 怪物闪避
local Face_Time = 0 -- 面对怪物
local Combating = false
local Combat_In_Range = false
local Scan_Combat = false -- 巡逻反击

local Dead = {
    Repop = 0,
	Shift = false,
	Shift_Step = 1,
	Safe = {},
}
local Execute_File = ""

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
    if GetTime() - Dead.Repop <= 5 then
	    Note_Set(Check_UI("等待跑尸复活时间 = ","Time waitting for going to Retrieve Corpse = ")..math.floor(7 - GetTime() + Dead.Repop))
	    return
	end
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

function Buff_Check()
    if Class == "MAGE" and not awm.UnitAffectingCombat("player") and not IsMounted() then
		if Spell_Castable(rs["奥术智慧"]) and not CheckBuff("player",rs["奥术智慧"]) and awm.UnitPower("player")/awm.UnitPowerMax("player") > 0.9 then
			awm.TargetUnit("player")
			awm.CastSpellByName(rs["奥术智慧"],"player")
			Note_Set(rs["奥术智慧"])
			return false
		end
		if not MakingDrinkOrEat() then
		    Note_Set(Check_UI("制造食物和水","Making Diet"))
			return false
		end
	end
	return true
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
	if Food_Name ~= nil and item == Food_Name then
	    return true
	end
	if Drink_Name ~= nil and item == Drink_Name then
	    return true
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

	if Class == "ROGUE" and string.find(item,Check_Client("速效药膏","Instant Poison")) then
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

	for i = 1,GetMerchantNumItems() do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if Ammo_type == nil then
			return nil
		elseif Ammo_type == "Array" then
			if Level >= 45 and id == Check_Client("锯齿箭","Jagged Arrow") then
				return Check_Client("锯齿箭","Jagged Arrow")
			elseif Level >= 35 and id == Check_Client("锐锋箭","Razor Arrow") then
				return Check_Client("锐锋箭","Razor Arrow")
			elseif Level >= 10 and id == Check_Client("锋利的箭","Sharp Arrow") then
				return Check_Client("锋利的箭","Sharp Arrow")
			elseif id == Check_Client("劣质箭","Rough Arrow") then
				return Check_Client("劣质箭","Rough Arrow")
			end
		elseif Ammo_type == "Bullet" then
			if Level >= 45 and id == Check_Client("精准弹丸","Accurate Slugs") then
				return Check_Client("精准弹丸","Accurate Slugs")
			elseif Level >= 35 and id == Check_Client("实心子弹","Solid Shot") then
				return Check_Client("实心子弹","Solid Shot")
			elseif Level >= 10 and id == Check_Client("重弹丸","Heavy Shot") then
				return Check_Client("重弹丸","Heavy Shot")
			elseif id == Check_Client("轻弹丸","Light Shot") then
				return Check_Client("轻弹丸","Light Shot")
			end
		end
	end
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
	    local item1 = GetItemCount(Check_Client("劣质箭","Rough Arrow"))
		local item2 = GetItemCount(Check_Client("锋利的箭","Sharp Arrow"))
		local item3 = GetItemCount(Check_Client("锐锋箭","Razor Arrow"))
		local item4 = GetItemCount(Check_Client("锯齿箭","Jagged Arrow"))
		Ammo_Count = Ammo_Count + item1
		if Level >= 10 then
		    Ammo_Count = Ammo_Count + item2
		end
		if Level >= 25 then
		    Ammo_Count = Ammo_Count + item3
		end
		if Level >= 40 then
		    Ammo_Count = Ammo_Count + item4
		end
		if GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT")) <= 2 then
		    if item1 > 0 then
			    EquipItemByName(Check_Client("劣质箭","Rough Arrow"))
			end
			if item2 > 0 and Level >= 10 then
			    EquipItemByName(Check_Client("锋利的箭","Sharp Arrow"))
			end
			if item3 > 0 and Level >= 25 then
			    EquipItemByName(Check_Client("锐锋箭","Razor Arrow"))
			end
			if item4 > 0 and Level >= 40 then
			    EquipItemByName(Check_Client("锯齿箭","Jagged Arrow"))
			end
		end
	elseif Ammo_type == "Bullet" then
	    local item1 = GetItemCount(Check_Client("轻弹丸","Light Shot"))
		local item2 = GetItemCount(Check_Client("重弹丸","Heavy Shot"))
		local item3 = GetItemCount(Check_Client("实心子弹","Solid Shot"))
		local item4 = GetItemCount(Check_Client("精准弹丸","Accurate Slugs"))
		Ammo_Count = Ammo_Count + item1
		if Level >= 10 then
		    Ammo_Count = Ammo_Count + item2
		end
		if Level >= 25 then
		    Ammo_Count = Ammo_Count + item3
		end
		if Level >= 40 then
		    Ammo_Count = Ammo_Count + item4
		end
		if GetInventoryItemCount("player",GetInventorySlotInfo("AMMOSLOT")) <= 2 then
		    if item1 > 0 then
			    EquipItemByName(Check_Client("轻弹丸","Light Shot"))
			end
			if item2 > 0 and Level >= 10 then
			    EquipItemByName(Check_Client("重弹丸","Heavy Shot"))
			end
			if item3 > 0 and Level >= 25 then
			    EquipItemByName(Check_Client("实心子弹","Solid Shot"))
			end
			if item4 > 0 and Level >= 40 then
			    EquipItemByName(Check_Client("精准弹丸","Accurate Slugs"))
			end
		end
	end
	return Ammo_Count
end
function BuyBullets()
    local Num = GetMerchantNumItems()
	local Ammo = Hunter_Ammo_Name()
	if Ammo == nil then
	    Start_Buy_Ammo = false
		return
	end
	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == Ammo then
		    if GetMoney() >= money then
				BuyMerchantItem(i,200)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 200只","Buy Bullets At Store Slot "..i.." For 200"))
			else
			    Start_Buy_Ammo = false
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
				Start_Buy_Ammo = false
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

function Buy_Food_Drinks(name)
    local Num = GetMerchantNumItems()
	for i = 1,Num do 
	    local id,_,money,_ = GetMerchantItemInfo(i)
		if id == name then
		    if GetMoney() >= money then
				BuyMerchantItem(i,1)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 1个","Buy Foods At Store Slot "..i.." For 1"))
			else
			    Has_Bought_Food_Drink = true
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
			local Food_Count = GetItemCount(Food_Name)
		    local Drink_Count = GetItemCount(Drink_Name)
			if (Food_Count < Easy_Data["食物数量"] or (Drink_Count < Easy_Data["食物数量"]) and Class ~= "ROGUE" and Class ~= "WARRIOR") and not Interact_Step then
			    Interact_Step = true
				C_Timer.After(2,function() Interact_Step = false end)
				if Food_Count < Easy_Data["食物数量"] then
					Buy_Food_Drinks(Food_Name)
				elseif Drink_Count < Easy_Data["食物数量"] and Class ~= "ROGUE" and Class ~= "WARRIOR" then
				    Buy_Food_Drinks(Drink_Name)
				end
			elseif Food_Count >= Easy_Data["食物数量"] and (Drink_Count >= Easy_Data["食物数量"] or Class == "ROGUE" or Class == "WARRIOR") then
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
				BuyMerchantItem(i,1)
				textout(Check_UI("购买完毕, 购买第"..i.."格物品 1个","Buy Pet Food At Store Slot "..i.." For 1"))
			else
			    Has_Bought_Food_Drink = true
			    textout(Check_UI("没有足够钱财购买宠物食物","Not enough money to buy Pet Food"))
				return
			end
		end
	end
end
function Pet_Food_Run()
    local x,y,z = Pet_Food_Vendor_Coord.x,Pet_Food_Vendor_Coord.y,Pet_Food_Vendor_Coord.z
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
		if awm.IsGuid(ThisUnit) then
			local guid = awm.UnitTarget(ThisUnit)
			if awm.ObjectIsUnit(ThisUnit)
			and not awm.UnitIsDead(ThisUnit)
			and awm.UnitCanAttack("player",ThisUnit)
			and awm.UnitAffectingCombat(ThisUnit)
			and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("player")
			and awm.UnitGUID(ThisUnit) ~= awm.UnitGUID("pet") then
				if guid == awm.UnitGUID("player") or guid == awm.UnitGUID("pet") then
					Monster[#Monster + 1] = ThisUnit
				end
			end
		end
	end
	if #Monster >= 2 then
	    Multi_Target = true
	else
	    Multi_Target = false
	end
	return Monster
end

function CombatSystem(target)
    if not awm.ObjectExists(target) then
	    return
	end
	awm.TargetUnit(target)
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
	if IsMounted() and distance <= 40 then
	    Dismount()
	end
	if Mount_useble then
		Mount_useble = false
		C_Timer.After(5,function() 
			if not Mount_useble then
				Mount_useble = true
			end
		end)
	end
	if Spell_Channel_Casting or Spell_Casting or CastingBarFrame:IsVisible() then
	    return
	end

    local flags = bit.bor(0x10, 0x100, 0x1)
    local hit = awm.TraceLine(Px,Py,Pz+2.25,x,y,z+2.25,flags)
	if hit == 1 or In_Sight then
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

	if Spell_Castable(rs["法师魔甲术"]) and not CheckBuff("player",rs["法师魔甲术"]) then
		awm.CastSpellByName(rs["法师魔甲术"])
		return
	end

	if distance > 35 then
		Run(x,y,z)
		return
	end

	awm.FaceCombat(target)

	if Spell_Castable(rs["火焰冲击"]) and awm.IsSpellInRange(rs["火焰冲击"],"target") == 1 then
		awm.CastSpellByName(rs["火焰冲击"])
	end

	if distance <= 35 and Spell_Castable(rs["冰枪术"]) then
		awm.CastSpellByName(rs["冰枪术"])
		return
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

		local uuid = awm.ObjectId(ThisUnit)
		local name = awm.UnitFullName(ThisUnit)
		for s = 1,#Mobs_ID do
			local mob_id = Mobs_ID[s]
			if awm.ObjectExists(ThisUnit)
			and not awm.UnitIsDead(ThisUnit)
			and awm.UnitCanAttack("player",ThisUnit)
			and ((Easy_Data["只击杀无目标怪物"] and not awm.UnitIsTapped(ThisUnit)) or not Easy_Data["只击杀无目标怪物"])
			and mob_id
			and ((tonumber(mob_id) and uuid == tonumber(mob_id)) or name == mob_id) then
				Find_List[#Find_List + 1] = ThisUnit
			end
		end
	end
	return Find_List
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
			and id
			and ((tonumber(id) and guid == tonumber(id)) or name == id) then
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

		LoadString([[Mobs_Coord = {]]..Easy_Data["坐标列表"]..[[}]])()

		Mobs_ID = string.split(Easy_Data["怪物列表"],",")

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

		if tonumber(Easy_Data["扫描间隔"]) == nil then
		    Easy_Data["扫描间隔"] = 2
		end

		if GetTime() - Scan_Time > Easy_Data["扫描间隔"] then
			Scan_Time = GetTime()
			local Find_List = Skin_Find()

			Note_Set(Check_UI("可击杀"..#Find_List.."个, 地点 = "..Grind.Move,"Mobs around "..#Find_List..", Nodes = "..Grind.Move))

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

		if Gather_Distance > 1.7 then
		    if UnitAffectingCombat("player") and Gather_Distance < Easy_Data["击杀扫描范围"] then
			    local Combat_Monster = Combat_Scan()

				local Far_Distance = Easy_Data["击杀扫描范围"]

				if #Combat_Monster > 0 then
				    print("1")
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
			Run(x,y,z)
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
			Mount_useble = true
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标不存在, 返回继续巡逻","Target not exist, back to mobs find process"))
			return
		elseif Target_Recheck ~= Target_Info.GUID then
		    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			Mount_useble = true
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil
			Grind.Step = 1
			textout(Check_UI("目标错误, 返回继续巡逻","Target Errors, back to mobs find process"))
			return
		end
		if distance < 200 then
			if Mount_useble then
				Mount_useble = false
				C_Timer.After(30,function() Mount_useble = true end)
			end
		elseif distance > 1000 then
		    Black_List[#Black_List + 1] = Target_Info.GUID
			Coordinates_Get = false
			Mount_useble = true	
			Target_Info.Item = nil
			Target_Info.objx,Target_Info.objy,Target_Info.objz = 0,0,0
			Target_Info.GUID = nil

			Grind.Step = 1

			textout(Check_UI("与人物距离超过1000码, 判断为虚假物品","Distance over 1000 yard, bilzzard fooling us"))
			return
		end

		if (Target_Info.Item == nil or not awm.ObjectExists(Target_Info.Item)) and distance < 80 then
		    Coordinates_Get = false
			Mount_useble = true
			Tried_Mount = false

			if not Vaild_Looted(Target_Info.Item) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Item = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标消失","Target do not exist"))
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
				Mount_useble = true
				Tried_Mount = false

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
				Mount_useble = true
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
		    Coordinates_Get = false
			Mount_useble = true
			Tried_Mount = false

			if not Vaild_Looted(Target_Info.Item) then
			    Monster_Has_Killed[#Monster_Has_Killed + 1] = Target_Info.GUID
			end

			Target_Info.Item = nil
			Target_Info.GUID = nil
			Loot_Timer = false
			Grind.Step = 1
			textout(Check_UI("目标死亡","Target Dead"))
			return
		else
		    local name = awm.UnitFullName(Target_Info.Item)
			CombatSystem(Target_Info.Item)
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

	if not Buff_Check() and not CheckBuff("player",rs["进食"]) and not CheckBuff("player",rs["喝水"]) then
	    Note_Head = Check_UI("BUFF增加","BUFF Adding")
	    return
	end

	if Class == "MAGE" then
		Food_Name = EatCount()
		Drink_Name = DrinkCount()
	end

	if not UnitAffectingCombat("player") and Easy_Data["需要吃喝"] and not IsSwimming() then
		local Cur_Health = (awm.UnitHealth("player")/awm.UnitHealthMax("player")) * 100
	    local Cur_Power = (awm.UnitPower("player")/awm.UnitPowerMax("player")) * 100
		if (Cur_Health < Easy_Data["回血百分比"] or (Start_Restore and Cur_Health < 95)) and not CheckBuff("player",rs["进食"]) then
		    Note_Head = Check_UI("恢复阶段","Restore Process")
			Note_Set(Check_UI("使用回血...","Restore health..."))
			if IsMounted() then
				Dismount()
			end
			Start_Restore = true
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
				if Food_Name ~= nil and not Item_Used and GetItemCount(Food_Name) > 0 then
				    Item_Used = true
					C_Timer.After(1.5,function() Item_Used = false end)
					awm.UseItemByName(Food_Name)
					textout(Check_UI("使用回血物品...","Use food item"))
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(3,function() Stop_Moving = false end)
			end
			return
		end
		if (Cur_Power < Easy_Data["回蓝百分比"] or (Start_Restore and Cur_Power < 95)) and not CheckBuff("player",rs["喝水"]) and Class ~= "WARRIOR" and Class ~= "ROGUE" then
		    Note_Head = Check_UI("恢复阶段","Restore Process")
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			if IsMounted() then
				Dismount()
			end
			Start_Restore = true
			local Speed = GetUnitSpeed("player")
			if Speed == 0 then
				if Drink_Name ~= nil and not Item_Used and GetItemCount(Drink_Name) > 0 then
				    Item_Used = true
					C_Timer.After(1.5,function() Item_Used = false end)
					awm.UseItemByName(Drink_Name)
					textout(Check_UI("使用回蓝物品...","Use drink item"))
				end
			else
				Stop_Moving = true
				Try_Stop()
				C_Timer.After(5,function() Stop_Moving = false end)
			end
			return
		end
		if CheckBuff("player",rs["喝水"]) and (Cur_Health < 99 or Cur_Power < 99) then
			Note_Head = Check_UI("恢复阶段","Restore Process")
			Note_Set(Check_UI("回蓝中...","Restore Power..."))
			return
		end
		if CheckBuff("player",rs["进食"]) and (Cur_Health < 99 or Cur_Power < 99) then
		    Note_Head = Check_UI("恢复阶段","Restore Process")
			Note_Set(Check_UI("回血中...","Restore Health..."))
			return
		end

		if Start_Restore and (Cur_Health < 99 or (Cur_Power < 99 and Class ~= "WARRIOR" and Class ~= "ROGUE")) then
		    Note_Head = Check_UI("恢复阶段","Restore Process")
			Note_Set(Check_UI("原地等待状态恢复","Wait For Health Or Power Back To 100%"))
			return
		end
		Start_Restore = false	     
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
Tried_Mount = false
local Stuck_Step = 1 -- 第一步跳 第二步移动
local Nil_Reset = GetTime()
local Nav_Time = GetTime()
local DRUID_Shift = 0 -- 小德变身冷却1秒

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

	if Class == "DRUID" and DoesSpellExist(rs["旅行形态"]) and Mount_useble and not CheckBuff("player",rs["旅行形态"]) and (GetTime() - DRUID_Shift) > 1 and Spell_Castable(rs["旅行形态"]) then
	    Reset_Stuck = GetTime()
	    DRUID_Shift = GetTime()
		awm.CastSpellByName(rs["旅行形态"],"player")
		textout(Check_UI("旅行形态 切换","Travel Form Shift"))
		return
	elseif Class ~= "DRUID" and not IsMounted() and awm.UnitLevel("player") >= 30 and not awm.UnitIsGhost("player") and Mount_useble and not awm.UnitAffectingCombat("player") and not IsSwimming() then
	    Reset_Stuck = GetTime()
		if not CastingBarFrame:IsVisible() and not Spell_Channel_Casting and not Spell_Casting then
			if not Tried_Mount then
				Tried_Mount = true
				Stop_Moving = true
				awm.UseAction(Easy_Data["动作条坐骑位置"])
				textout(Check_UI("坐骑位置 - "..Easy_Data["动作条坐骑位置"]..", 尝试召唤","Mount slot in action bar - "..Easy_Data["动作条坐骑位置"]..", try mount"))
				C_Timer.After(5,function() Stop_Moving = false Tried_Mount = false end)
				return
			end		
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
		awm.MoveTo(stuckx,stucky,Pz)
		return
	end

	if coordinates == nil or coordinates == 0 or awm.GetActiveNodeCount() == 0 then
		awm.Interval_Move(x,y,z)
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
	else
		awm.Interval_Move(x,y,z)
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

	local function Max_Gather_Time_UI() -- 极限击杀时间
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

	Frame_Create()
	Button_Create()
	Max_Gather_Time_UI()
	Gather_Set_UI()

	Tick_Food_Drink()
	Enable_Food_Drink()

	Player_Detection()
	Only_Kill_Myself()
end

local function Create_Custom_UI() -- 自定义UI
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
	local function Moster_List() -- 击杀怪物ID
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("击杀怪物ID或名字 (例子: 怪物1,怪物2,怪物3,)","Kill list id or name (example: name1,name2,name3,name4,)"))

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20
	    Basic_UI.Custom["怪物列表"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,"",570,50)

		Basic_UI.Custom["怪物列表"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["怪物列表"] = Basic_UI.Custom["怪物列表"]:GetText()
		end)
        if Easy_Data["怪物列表"] == nil then
            Easy_Data["怪物列表"] = ""
        else
            Basic_UI.Custom["怪物列表"]:SetText(Easy_Data["怪物列表"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	end

	local function Coord_List() -- 
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("坐标列表 (例子: {x,y,z},{x1,y1,z1},{x2,y2,z2},)","Coord list (example: {x,y,z},{x1,y1,z1},{x2,y2,z2},)"))

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    Basic_UI.Custom["坐标列表"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,'',570,200)

		Basic_UI.Custom["坐标列表"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["坐标列表"] = Basic_UI.Custom["坐标列表"]:GetText()
		end)
        if Easy_Data["坐标列表"] == nil then
            Easy_Data["坐标列表"] = [[]]
        else
            Basic_UI.Custom["坐标列表"]:SetText(Easy_Data["坐标列表"])
        end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 180
	end

	Frame_Create()
	Button_Create()
	Moster_List()
	Coord_List()
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
	buttontext2:SetText(Check_UI("添加目标怪物至击杀列表","Add target mob into kill list"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top")
	button2:SetSize(200,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
	    if awm.ObjectExists("target") then
			local ID = awm.ObjectId("target")
			Easy_Data["怪物列表"] = Easy_Data["怪物列表"]..ID..","
			Basic_UI.Custom["怪物列表"]:SetText(Easy_Data["怪物列表"])
			textout(Check_UI("添加成功, ID = ","Add, ID = ")..ID)
			return
		end
	end)

	local button2 = CreateFrame("Button","button2",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext2 = button2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext2:SetText(Check_UI("添加当前地点至坐标列表","Add Current point into coord list"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top",0,-50)
	button2:SetSize(200,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
		local x,y,z = awm.ObjectPosition("player")
		Easy_Data["坐标列表"] = Easy_Data["坐标列表"].."{"..x..","..y..","..z.."},"
		Basic_UI.Custom["坐标列表"]:SetText(Easy_Data["坐标列表"])
		textout(Check_UI("添加成功, 地点 = ","Add, Point = ")..awm.ObjectPosition("player"))
		return
	end)

	local button2 = CreateFrame("Button","button2",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext2 = button2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext2:SetText(Check_UI("炸螃蟹","Crawler Path"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top",0,-100)
	button2:SetSize(200,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
		Easy_Data["坐标列表"] = [[{-10888.12,2126.25,1.20},{-10912.94,2120.60,2.89},{-10969.54,2096.63,3.46},]]
		Basic_UI.Custom["坐标列表"]:SetText(Easy_Data["坐标列表"])
		Easy_Data["怪物列表"] = [[1216,]]
		Basic_UI.Custom["怪物列表"]:SetText(Easy_Data["怪物列表"])
		return
	end)

	local button2 = CreateFrame("Button","button2",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext2 = button2:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext2:SetText(Check_UI("炸狼人","Worgen Path"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top",0,-150)
	button2:SetSize(200,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
		Easy_Data["坐标列表"] = [[{-4036.96,-2963.58,10.53},{-4108.97,-2947.20,11.63},{-3893.06,-3037.69,11.04},]]
		Basic_UI.Custom["坐标列表"]:SetText(Easy_Data["坐标列表"])
		Easy_Data["怪物列表"] = [[1007,1008,1009,]]
		Basic_UI.Custom["怪物列表"]:SetText(Easy_Data["怪物列表"])
		return
	end)
end

Create_Nav_UI()
Create_Config_UI()
Create_Custom_UI()
CreateButton()

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
Mount_useble = true
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
				Config_Panel.Sell_Mail["不分解物品"]:SetText(Easy_Data["不分解物品"])
			end
		end
		if arg2 == SPELL_FAILED_UNIT_NOT_INFRONT or arg2 == ERR_BADATTACKFACING or arg2 == ERR_USE_BAD_ANGLE or arg2 == SPELL_FAILED_CUSTOM_ERROR_141 then
			if awm.ObjectExists("target") and GetTime() - Face_Time > 2 then
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