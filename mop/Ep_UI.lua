local UI_Version = "0108"

local Key_Frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
local Key_Frame_Position = CreateFrame("Frame")
local function Key_Show_Frame()
	Key_Frame:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",edgeFile="Interface/ChatFrame/ChatFrameBackground",tile=true,edgeSize=1,tileSize=5,})
	Key_Frame:SetSize(4096,2160)
	Key_Frame:SetPoint("CENTER")
	Key_Frame:Show()
	Key_Frame:SetMovable(false)
	Key_Frame:SetBackdropColor(0,0,0,0)
	Key_Frame:SetBackdropBorderColor(0,0,0,0)

    local X_Coord = 550
    local Y_Coord = 250
    local Pos_Time = 0

	local Notice = Key_Frame:CreateFontString(nil,"OVERLAY","ArtifactAppearanceSetHighlightFont")
	Notice:SetPoint("CENTER",X_Coord,Y_Coord)
	Notice:SetText(Check_UI("无","Null"))
	Notice:Show()

    Key_Frame_Position:SetScript("OnUpdate",function() 
        if GetTime() - Pos_Time > 10 then
            local Game_Key = ReadFile(awm.GetExeDirectory()..[[\loader.json]])
            Game_Key = string.split(tostring(Game_Key),[[license]])
            Game_Key = string.split(Game_Key[2],[[",]])
            Game_Key = string.split(Game_Key[1],[["]])
            Game_Key = Game_Key[3]
            if Game_Key then
                Notice:SetText(Game_Key)
                Pos_Time = GetTime()
                if Y_Coord >= -180 then
                    Y_Coord = Y_Coord - math.random(50,100)
                    if X_Coord > 0 then
                        X_Coord = math.random(550,650)
                        X_Coord = 0 - X_Coord
                    else
                        X_Coord = math.random(550,650)
                    end
                    Notice:SetPoint("CENTER",X_Coord,Y_Coord)
                else
                    Y_Coord = 250
                    if X_Coord > 0 then
                        X_Coord = math.random(550,650)
                        X_Coord = 0 - X_Coord
                    else
                        X_Coord = math.random(550,650)
                    end
                    Notice:SetPoint("CENTER",X_Coord,Y_Coord)
                end
            end
        end
    end)
end
Key_Show_Frame()

Ep_Error = {}
function Error_Handle(msg)
    ScriptErrorsFrame:OnError(msg,MESSAGE_TYPE_ERROR,true)

    message(msg)

    local Error_Content = ScriptErrorsFrame.messages[#ScriptErrorsFrame.order]
    local stack = ScriptErrorsFrame.order[#ScriptErrorsFrame.order]
    local locals = ScriptErrorsFrame.locals[#ScriptErrorsFrame.order]

    if Error_Content then
        local Find_Original_Error = false
        for err = 1,#Ep_Error do
            if Error_Content == Ep_Error[err] then
                Find_Original_Error = true
                break
            end
        end

        if not Find_Original_Error then
            Ep_Error[#Ep_Error + 1] = Error_Content

            print(msg)

            if not awm.DirectoryExists(awm.GetExeDirectory().."\\Errors") then
                awm.CreateDirectory(awm.GetExeDirectory().."\\Errors")
            end

            if not awm.DirectoryExists(awm.GetExeDirectory().."\\Errors\\"..GetRealmName().." - "..UnitFullName("player")) then
                awm.CreateDirectory(awm.GetExeDirectory().."\\Errors\\"..GetRealmName().." - "..UnitFullName("player"))
            end

            if string.find(Error_Content,"attempt to yield across metamethod/C-call boundary") then
                return
            end

            awm.WriteFile(awm.GetExeDirectory().."\\Errors\\"..GetRealmName().." - "..UnitFullName("player").."\\"..time().." - "..#Ep_Error..".lua", Error_Content.."\n Stack = "..Str2Hex(DF_RC4("PvZ4UugeAp28eiBH",stack)).."\n Locals = "..Str2Hex(DF_RC4("PvZ4UugeAp28eiBH",locals)), true)

            print(Check_UI("报错! 报错! 请打包主程序目录下 Error文件夹中对应的角色名字文件夹, 发送至 经销商","Detect lua script errors, please send the Errors folder to your resllers"))
        end
    end
end
seterrorhandler(Error_Handle)

local T_Dump = {}
 
function T_Dump.dump(tab, ind)
    if (tab == nil) then
        return "nil"
    end ;
    local str = "{";
    if (ind == nil) then
        ind = "    ";
    end ;

    for k, v in pairs(tab) do

        k = "[" ..[["]].. tostring(k) ..[["]] .. "] = ";
        
        local s = "";
        if (type(v) == "nil") then
            s = "nil";
        elseif (type(v) == "boolean") then
            if (v) then
                s = "true";
            else
                s = "false";
            end ;
        elseif (type(v) == "number") then
            s = v;
        elseif (type(v) == "string") then
            s = "\"" .. v .. "\"";
        elseif (type(v) == "table") then
            s = T_Dump.dump_table(v, ind .. "    ");
            s = string.sub(s, 1, #s - 1);
        elseif (type(v) == "function") then
            s = "function : " .. v;
        elseif (type(v) == "thread") then
            s = "thread : " .. tostring(v);
        elseif (type(v) == "userdata") then
            s = "userdata : " .. tostring(v);
        else
            s = "nuknow : " .. tostring(v);
        end ;

        str = str .. "\n" .. ind .. k .. s .. ",";
    end

    local sss = string.sub(str, 1, #str - 1);
    if (#ind > 0) then
        ind = string.sub(ind, 1, #ind - 4)
    end ;
    sss = sss .. "\n" .. ind .. "}\n";

    awm.WriteFile(awm.GetExeDirectory().."\\Configs\\"..GetRealmName().." - "..UnitFullName("player").."\\Config.lua",sss, true)
    return sss;
end

local function Unlock_All()
    awm = {}
    CreateApiReferences(awm)

	awm.Unlock = function(s)
        return function (...) return Unlock(s, ...) end
    end
    awm.RunMacroText = awm.Unlock("RunMacroText")

    awm.Print_Spell = false

    awm.CastSpell = awm.Unlock("CastSpellByName")
    awm.CastSpellByID = awm.Unlock("CastSpellByID")

    local Last_Cast = ""
    awm.CastSpellByName = function(Spell_name,target)
        if awm.Print_Spell and Last_Cast ~= Spell_name then
            print(Spell_name)
            Last_Cast = Spell_name
        end
        
        if string.find(Spell_name,"等级") or string.find(Spell_name,"Rank") then
            if not target or not awm.ObjectExists(target) then
                awm.CastSpell(Spell_name)
            else
                awm.CastSpell(Spell_name,target)
            end
            return
        end

        for i = 1,100 do
            local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(Spell_name..Check_Client("(等级 ","(Rank ")..i..")")
            if name == nil and i >= 2 then
                local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(Spell_name..Check_Client("(等级 ","(Rank ")..(i - 1)..")")
                if not target or not awm.ObjectExists(target) then
                    awm.CastSpellByID(spellId)
                    return
                else
                    awm.CastSpellByID(spellId,target)
                    return
                end
            elseif name == nil and i == 1 then
                if not target or not awm.ObjectExists(target) then
                    awm.CastSpell(Spell_name)
                    return
                else
                    awm.CastSpell(Spell_name,target)
                    return
                end
            end
        end
    end

    awm.SetRaidTarget = awm.Unlock("SetRaidTarget")
    awm.ClickTradeButton = awm.Unlock("ClickTradeButton")

    awm.PickupItem = awm.Unlock("PickupItem")
    awm.UnitCastingInfo = awm.Unlock("UnitCastingInfo")

    awm.UnitCastingInfo = awm.Unlock("UnitCastingInfo")
	awm.InteractUnit = awm.Unlock("InteractUnit")
	awm.UseItemByName = awm.Unlock("UseItemByName")
	awm.UseContainerItem = awm.Unlock("UseContainerItem")
    awm.UseAction = awm.Unlock("UseAction")
    awm.RetrieveCorpse = awm.Unlock("RetrieveCorpse")
    awm.DoTradeSkill = awm.Unlock("DoTradeSkill")
    awm.UnitFullName = awm.Unlock("UnitFullName")
    awm.UnitGUID = awm.Unlock("UnitGUID")
    awm.UnitLevel = awm.Unlock("UnitLevel")
    awm.UnitBuff = awm.Unlock("UnitBuff")
    awm.UnitDebuff = awm.Unlock("UnitDebuff")
    awm.TargetUnit = awm.Unlock("TargetUnit")
    awm.PickupContainerItem = awm.Unlock("PickupContainerItem")
    awm.DeleteCursorItem = awm.Unlock("DeleteCursorItem")
    awm.ClearTarget = awm.Unlock("ClearTarget")
    awm.PetAttack = awm.Unlock("PetAttack")
    awm.UnitAffectingCombat = awm.Unlock("UnitAffectingCombat")
    awm.UnitCanAttack = awm.Unlock("UnitCanAttack")
    awm.AttackTarget = awm.Unlock("AttackTarget")
    awm.CopyToClipboard = awm.Unlock("CopyToClipboard")
    awm.IsSpellInRange = awm.Unlock("IsSpellInRange")
    awm.PetAssistMode = awm.Unlock("PetAssistMode")
    awm.PetDefensiveAssistMode = awm.Unlock("PetDefensiveAssistMode")
    awm.PetDefensiveMode = awm.Unlock("PetDefensiveMode")
    awm.PetFollow = awm.Unlock("PetFollow")
    awm.PetPassiveMode = awm.Unlock("PetPassiveMode")
    awm.PetStopAttack = awm.Unlock("PetStopAttack")
    awm.PetWait = awm.Unlock("PetWait")
    awm.Stuck = awm.Unlock("Stuck")
    awm.SpellIsTargeting = awm.Unlock("SpellIsTargeting")
    awm.SpellStopCasting = awm.Unlock("SpellStopCasting")
    awm.SpellStopTargeting = awm.Unlock("SpellStopTargeting")
    awm.UnitClass = awm.Unlock("UnitClass")
    awm.UnitHealth = awm.Unlock("UnitHealth")
    awm.UnitHealthMax = awm.Unlock("UnitHealthMax")
    awm.UnitPowerMax = awm.Unlock("UnitPowerMax")
    awm.UnitPower = awm.Unlock("UnitPower")
    awm.UnitInParty = awm.Unlock("UnitInParty")
    awm.UnitInRaid = awm.Unlock("UnitInRaid")
    awm.UnitIsDead = awm.Unlock("UnitIsDead")
    awm.UnitIsDeadOrGhost = awm.Unlock("UnitIsDeadOrGhost")
    awm.UnitIsEnemy = awm.Unlock("UnitIsEnemy")
    awm.UnitIsGhost = awm.Unlock("UnitIsGhost")
    awm.UnitCreatureType = awm.Unlock("UnitCreatureType")
    awm.UseInventoryItem = awm.Unlock("UseInventoryItem")

    awm.ForceQuit = awm.Unlock("ForceQuit")

	awm.MoveAndSteerStop = awm.Unlock("MoveAndSteerStop")
	awm.MoveForwardStop = awm.Unlock("MoveForwardStop")
	awm.MoveBackwardStop = awm.Unlock("MoveBackwardStop")
	awm.PitchDownStop = awm.Unlock("PitchDownStop")
	awm.PitchUpStop = awm.Unlock("PitchUpStop")
	awm.StrafeLeftStop = awm.Unlock("StrafeLeftStop")
	awm.StrafeRightStop = awm.Unlock("StrafeRightStop")
	awm.TurnLeftStop = awm.Unlock("TurnLeftStop")
	awm.TurnRightStop = awm.Unlock("TurnRightStop")
	awm.MoveForwardStart = awm.Unlock("MoveForwardStart")
    awm.MoveBackwardStart = awm.Unlock("MoveBackwardStart")
	awm.JumpOrAscendStart = awm.Unlock("JumpOrAscendStart")
	awm.AscendStop = awm.Unlock("AscendStop")

    awm.IsAoEPending = function() return awm.SpellIsTargeting() end

    awm.ObjectId = function(object)
        local guid = awm.UnitGUID(object)
        if guid and awm.ObjectExists(object) then
            return awm.ObjectDescriptor(object, 0x10, 6)
        else
            return 0
        end
    end

    awm.GetDistanceBetweenPositions = function(X1, Y1, Z1, X2, Y2, Z2)
        if X1 == nil or X2 == nil or Y1 == nil or Y2 == nil or Z1 == nil or Z2 == nil then
            return 50000
        end
        return math.sqrt(math.pow(X2 - X1, 2) + math.pow(Y2 - Y1, 2) + math.pow(Z2 - Z1, 2))
    end

    awm.GetAnglesBetweenObjects = function(Object1, Object2)
        if awm.ObjectExists(Object1) and awm.ObjectExists(Object2) then
            local X1, Y1, Z1 = awm.ObjectPosition(Object1)
            local X2, Y2, Z2 = awm.ObjectPosition(Object2)
            return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2),math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
        else
            return 0,0
        end
    end

    awm.GetAnglesBetweenPositions = function(X1, Y1, Z1, X2, Y2, Z2)
        if X1 == nil or X2 == nil or Y1 == nil or Y2 == nil or Z1 == nil or Z2 == nil then
            return 0,0
        end
        return math.atan2(Y2 - Y1, X2 - X1) % (math.pi * 2),math.atan((Z1 - Z2) / math.sqrt(math.pow(X1 - X2, 2) + math.pow(Y1 - Y2, 2))) % math.pi
    end

    awm.GetPositionFromPosition = function(X, Y, Z, Distance, AngleXY, AngleXYZ)
        if X == nil or Y == nil or Z == nil or Distance == nil or AngleXY == nil or AngleXYZ == nil then
            return 0,0,0
        end
        return math.cos(AngleXY) * Distance + X, math.sin(AngleXY) * Distance + Y, math.sin(AngleXYZ) * Distance + Z
    end

    awm.GetPositionBetweenPositions = function(X1, Y1, Z1, X2, Y2, Z2, DistanceFromPosition1)
        if X1 == nil or X2 == nil or Y1 == nil or Y2 == nil or Z1 == nil or Z2 == nil then
            return 0,0,0
        end
        local AngleXY, AngleXYZ = awm.GetAnglesBetweenPositions(X1, Y1, Z1, X2, Y2, Z2)
        return awm.GetPositionFromPosition(X1, Y1, Z1, DistanceFromPosition1, AngleXY, AngleXYZ)
    end

    awm.GetPositionBetweenObjects = function(unit1, unit2, DistanceFromPosition1)
        local X1, Y1, Z1 = awm.ObjectPosition(unit1)
        local X2, Y2, Z2 = awm.ObjectPosition(unit2)
        if not X1 or not X2 then
            return 0,0,0
        end
        local AngleXY, AngleXYZ = awm.GetAnglesBetweenPositions(X1, Y1, Z1, X2, Y2, Z2)
        return awm.GetPositionFromPosition(X1, Y1, Z1, DistanceFromPosition1, AngleXY, AngleXYZ)
    end

    awm.GetDistanceBetweenObjects = function(unit1, unit2)
        if not unit1 or not unit2 or not awm.ObjectExists(unit1) or not awm.ObjectExists(unit2) then
            return 50000
        end
        local X1, Y1, Z1 = awm.ObjectPosition(unit1)
        local X2, Y2, Z2 = awm.ObjectPosition(unit2)
        return math.sqrt((X2-X1)^2 + (Y2-Y1)^2 + (Z2-Z1)^2)
    end

    --------------------------------
    -- vanilla offsets
    --------------------------------
    if GetExpansionLevel() == 0 then
        function awm.UnitSummonedBy(obj) return awm.ObjectDescriptor(obj, 0x5C, 15) end
        function awm.UnitCreatedBy(obj) return awm.ObjectDescriptor(obj, 0x6C, 15) end
        function awm.UnitTarget(obj) return awm.ObjectDescriptor(obj, 0x9C, 15) end
        function awm.UnitFlags(obj) return awm.ObjectDescriptor(obj, 0x164, 6) end
        function awm.UnitFlags2(obj) return awm.ObjectDescriptor(obj, 0x178, 6) end
        function awm.UnitFlags3(obj) return awm.ObjectDescriptor(obj, 0x17C, 6) end
        function awm.UnitSpecId(obj) return 0 end
        function awm.UnitBoundingRadius(obj) return awm.ObjectDescriptor(obj, 0x190, 10) end
        function awm.UnitCombatReach(obj) return awm.ObjectDescriptor(obj, 0x194, 10) end
    --------------------------------
    -- TBC offsets
    --------------------------------
    elseif GetExpansionLevel() == 1 then  
        function awm.UnitSummonedBy(obj) return awm.ObjectDescriptor(obj, 0x5C, 15) end
        function awm.UnitCreatedBy(obj) return awm.ObjectDescriptor(obj, 0x6C, 15) end
        function awm.UnitTarget(obj) return awm.ObjectDescriptor(obj, 0x9C, 15) end
        function awm.UnitFlags(obj) return awm.ObjectDescriptor(obj, 0x174, 6) end
        function awm.UnitFlags2(obj) return awm.ObjectDescriptor(obj, 0x178, 6) end
        function awm.UnitFlags3(obj) return awm.ObjectDescriptor(obj, 0x17C, 6) end
        function awm.UnitSpecId(obj) return 0 end
        function awm.UnitBoundingRadius(obj) return awm.ObjectDescriptor(obj, 0x190, 10) end
        function awm.UnitCombatReach(obj) return awm.ObjectDescriptor(obj, 0x194, 10) end
    --------------------------------
    -- Shadowlands offsets
    --------------------------------
    else
        function awm.UnitSummonedBy(obj) return awm.ObjectField(obj, 0x1C18, 15) end
        function awm.UnitCreatedBy(obj) return awm.ObjectField(obj, 0x1C28, 15) end
        function awm.UnitTarget(obj) return awm.ObjectField(obj, 0x1C58, 15) end
        function awm.UnitFlags(obj) return awm.ObjectField(obj, 0x1CD8, 6) end
        function awm.UnitFlags2(obj) return awm.ObjectField(obj, 0x1CDC, 6) end
        function awm.UnitFlags3(obj) return awm.ObjectField(obj, 0x1CE0, 6) end
        function awm.UnitSpecId(obj) return awm.ObjectField(obj, 0x2264, 6) end
        function awm.UnitBoundingRadius(obj) return awm.ObjectField(obj, 0x1CEC, 10) end
        function awm.UnitCombatReach(obj) return awm.ObjectField(obj, 0x1CF0, 10) end
    end

    --------------------------------
    -- flags
    --------------------------------
    awm.UnitIsSkinnable = function(obj)
        if not awm.ObjectExists(obj) then
            return false
        end
        return bit.band(awm.UnitFlags(obj), 0x04000000) ~= 0 
    end

    awm.isguid = awm.IsGuid
    awm.IsGuid = function(obj)
        if awm.isguid(obj) and awm.isguid(obj) == 1 then
            return true
        else
            return false
        end
    end

    awm.CanLootUnit = CanLootUnit
    awm.UnitIsLootable = function(obj)
        if not awm.ObjectExists(obj) then
            return false
        end
        if awm.IsGuid(obj) then
            local hasloot,canloot = awm.CanLootUnit(obj)
            return hasloot
        else
            local Guid = awm.UnitGUID(obj)
            local hasloot,canloot = awm.CanLootUnit(Guid)
            return hasloot
        end
    end
    awm.UnitFeignDeathed = function(obj) return bit.band(awm.UnitFlags2(obj), 0x00000001) ~= 0 end

    awm.UnitIsTapped = function(obj)
        if not awm.ObjectExists(obj) then
            return false
        end
        local Tapped = awm.ObjectDescriptor(obj, 0x14, 6)
        if Tapped and Tapped == 16 then
            return true
        else
            return false
        end
    end

    awm.CorpseCanLoot = function(obj)
        if not awm.ObjectExists(obj) then
            return false
        end
        return bit.band(awm.UnitFlags(obj), 0x04000000) ~= 0
    end

    awm.ClickToMove = awm.MoveTo

	awm.MoveTo = function(x,y,z) 
        if not x or not y or not z then
            return
        end
        
		local real_facing = awm.UnitFacing("player")
		local player_Face = math.floor(real_facing * 10^3  + 0.5) / 10^3
        local Px,Py,Pz = awm.ObjectPosition("player")
        local Angle_Face = awm.GetAnglesBetweenPositions(Px,Py,Pz,x,y,z)
        Angle_Face = math.floor(Angle_Face * 10^3  + 0.5) / 10^3
    
		if math.abs(player_Face - Angle_Face) < 0.01 then
			awm.ClickToMove(x,y,z)
	    else
            if GetUnitSpeed("player") > 0 and math.abs(player_Face - Angle_Face) > 0.1 then
                Try_Stop()
                return
            end
		    awm.FaceDirection(Angle_Face)
	    end
	end

    local Interval_Moving = 0
    local cx,cy,cz = 0,0,0 -- last click
    awm.Interval_Move = function(x,y,z)
        if not x or not y or not z then
            return
        end
        
        local time = (math.random(4,8) + math.random()) / 10
        local time1 = (math.random(1,4) + math.random()) / 10
        local Px,Py,Pz = awm.ObjectPosition("player")
        local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
		if GetTime() - Interval_Moving > time and distance > 3 then
            Interval_Moving = GetTime()
            awm.ClickToMove(x,y,z)
            cx,cy,cz = x,y,z
            return
        elseif GetUnitSpeed("player") == 0 and GetTime() - Interval_Moving > time1 then
            Interval_Moving = GetTime()
            awm.ClickToMove(x,y,z)
            cx,cy,cz = x,y,z
            return
        elseif math.abs(cx - x) > 2 or math.abs(cy - y) > 2 or math.abs(cz - z) > 2 then
            Interval_Moving = GetTime()
            awm.ClickToMove(x,y,z)
            cx,cy,cz = x,y,z
            return
        end
	end

    awm.FaceTarget = function(target)
        if not awm.ObjectExists(target) then
            return
        end
	    local Unit_Face = awm.UnitFacing("player")
        local Direction = awm.GetAnglesBetweenObjects("player",target)
        if math.abs(Unit_Face - Direction) > 0.2 then
			awm.FaceDirection(Direction)
        end
    end
    awm.FaceCombat = function(target)
        if not awm.ObjectExists(target) then
            return
        end
	    local Target_Face = awm.GetAnglesBetweenObjects("player",target)
	    local Unit_Face = awm.UnitFacing("player")
		if math.abs(Unit_Face - Target_Face) > 0.4 and not UnitAffectingCombat("player") then
			awm.FaceTarget(target)
			return
		end
	end

    local Pitch_Interval = 0
    awm.SetPitch = function(Set_Pitch)
        local face,pitch = awm.UnitFacing("player")
        if math.abs(pitch - Set_Pitch) > 0.01 and GetTime() - Pitch_Interval > 0.5 then
            awm.FaceDirection(nil,Set_Pitch)
            Pitch_Interval = GetTime()
        end
    end

    awm.ObjectIsUnit = function(unit) 
	    if awm.ObjectExists(unit) and awm.ObjectType(unit) and (awm.ObjectType(unit) == 5 or awm.ObjectType(unit) == 6 or awm.ObjectType(unit) == 7) then
            return true
        end
        return false
	end

	awm.ObjectIsGameObject = function(unit) 
	    if awm.ObjectExists(unit) and awm.ObjectType(unit) and awm.ObjectType(unit) == 8 then
            return true
        end
        return false
	end

    awm.ObjectIsPlayer = function(unit) 
	    if awm.ObjectExists(unit) and awm.ObjectType(unit) and (awm.ObjectType(unit) == 6 or awm.ObjectType(unit) == 7) then
            return true
        end
        return false
	end

	awm.ObjectExists_Shift = awm.ObjectExists

	awm.ObjectExists = function(obj)
	    if awm.ObjectExists_Shift(obj) == nil then
		    return false
		elseif awm.ObjectExists_Shift(obj) == 1 then
		    return true
		else
		    return false
		end
	end

    awm.InternetRequestAsync = function(verb, url, parameters, extraHeader, callback)
        local id = SendHttpRequest(verb, url, parameters, extraHeader)
        local update
        update = function ()
            local response, status = RequestStatus(id)
            if response then
                callback(response, status)
            else
                C_Timer.After(0, update)
            end
        end
        C_Timer.After(0, update)
    end

    awm.InternetRequestSync = function(verb, url, parameters, extraHeader, callback)
        local response, status = InternetRequest(verb, url, parameters, extraHeader)
        callback(response, status)
    end

    awm.IsSwim = function() 
        local Move_flag = awm.GetUnitMovementFlags("player") 
        if Move_flag ~= 1048576 and Move_flag ~= 1048608 and Move_flag ~= 1048577 and Move_flag ~= 1048593 then
            return false
        else
            return true
        end
    end
end
Unlock_All()

function Try_Stop()
	awm.MoveAndSteerStop()
	awm.MoveForwardStop()
	awm.MoveBackwardStop()
	awm.PitchDownStop()
	awm.PitchUpStop()
	awm.StrafeLeftStop()
	awm.StrafeRightStop()
	awm.TurnLeftStop()
	awm.TurnRightStop()
	if GetUnitSpeed("player") > 0 then
		awm.MoveForwardStart()
		awm.MoveForwardStop()
	end
end

function CheckBuff(target,spell)
    if not awm.ObjectExists(target) then
        return false
    end

	for i = 1, 40 do 
		local name, icon, _, _, _, etime = awm.UnitBuff(target,i)
		if name then
            if name == spell then
                return true
            end
        end	
	end	
	return false
end
function CheckDebuffByName(object,spellname)
    if not awm.ObjectExists(object) then
        return false
    end

	for i = 1, 40 do 
		local name, icon, _, _, _, etime,_,_,_,Spellid = awm.UnitDebuff(object,i)
		if name then
            if name == spellname then
                return true
            end
        end	
	end	
	return false
end
function Spell_Castable(Spell)
    if not DoesSpellExist(Spell) then
	    return false
	end
	local starttime, duration, enabled, _ = GetSpellCooldown(Spell)
	local endtime = starttime + duration
	if GetTime() < endtime then
		return false
	end

    local usable, noMana = IsUsableSpell(Spell)
	if noMana then
		return false	
	end
	if not usable then
		return false
	end
	return true
end
function CheckCooldown(ItemId)
	local starttime, durationtime, enable = GetItemCooldown(ItemId)
	local endtime = durationtime + starttime
	if GetTime() < endtime then
	    return false
	end
	return true
end

function EatCount() -- 判断食物数量
    local Eat1 = GetItemCount(rs["魔法松饼"])
    local Eat2 = GetItemCount(rs["魔法面包"])
    local Eat3 = GetItemCount(rs["魔法黑面包"])
    local Eat4 = GetItemCount(rs["魔法粗面包"])
    local Eat5 = GetItemCount(rs["魔法酵母"])
    local Eat6 = GetItemCount(rs["魔法甜面包"])
	local Eat7 = GetItemCount(rs["魔法肉桂面包"])
	local Eat8 = GetItemCount(rs["魔法羊角面包"])
	local EatNumber = 0
	if Eat1 == 0 and Eat2 == 0 and Eat3 == 0 and Eat4 == 0 and Eat5 == 0 and Eat6 == 0 and Eat7 == 0 and Eat8 == 0 then
	   EatNumber = nil
	elseif Eat1 > 0 then
       EatNumber = rs["魔法松饼"]
	elseif Eat2 > 0 then   
       EatNumber = rs["魔法面包"]
	elseif Eat3 > 0 then   
       EatNumber = rs["魔法黑面包"]
	elseif Eat4 > 0 then   
       EatNumber = rs["魔法粗面包"]
	elseif Eat5 > 0 then   
       EatNumber = rs["魔法酵母"]
	elseif Eat6 > 0 then   
       EatNumber = rs["魔法甜面包"] 
	elseif Eat7 > 0 then   
       EatNumber = rs["魔法肉桂面包"] 
	elseif Eat8 > 0 then   
       EatNumber = rs["魔法羊角面包"] 
	end
	return EatNumber
end
function DrinkCount() -- 判断水数量
	local Drink1 = GetItemCount(rs["魔法水"])
	local Drink2 = GetItemCount(rs["魔法淡水"])
	local Drink3 = GetItemCount(rs["魔法纯净水"])
	local Drink4 = GetItemCount(rs["魔法泉水"])
	local Drink5 = GetItemCount(rs["魔法矿泉水"])
	local Drink6 = GetItemCount(rs["魔法苏打水"])
	local Drink7 = GetItemCount(rs["魔法晶水"])
	local Drink8 = GetItemCount(rs["魔法山泉水"])
	local Drink9 = GetItemCount(rs["魔法冰川水"])
	local DrinkNumber = 0
	if Drink1 == 0 and Drink2 == 0 and Drink3 == 0 and Drink4 == 0 and Drink5 == 0 and Drink6 == 0 and Drink7 == 0 and Drink8 == 0 and Drink9 == 0 then
	   DrinkNumber = nil
	elseif Drink1 > 0 then
       DrinkNumber = rs["魔法水"]
	elseif Drink2 > 0 then   
       DrinkNumber = rs["魔法淡水"]
	elseif Drink3 > 0 then   
       DrinkNumber = rs["魔法纯净水"]
	elseif Drink4 > 0 then   
       DrinkNumber = rs["魔法泉水"]
	elseif Drink5 > 0 then   
       DrinkNumber = rs["魔法矿泉水"]
	elseif Drink6 > 0 then   
       DrinkNumber = rs["魔法苏打水"]
	elseif Drink7 > 0 then   
       DrinkNumber = rs["魔法晶水"]
	elseif Drink8 > 0 then   
       DrinkNumber = rs["魔法山泉水"]
	elseif Drink9 > 0 then   
       DrinkNumber = rs["魔法冰川水"]
	end
	return DrinkNumber
end

local Make_Drink_Eat_Time = 0
function MakingDrinkOrEat() -- 判断造食
    if not awm.UnitAffectingCombat("player") then
        if DoesSpellExist(rs["造食术"]) and not CheckBuff("player",rs["进食"]) then
			local count_name = EatCount()
			if count_name == nil then
				if not CastingBarFrame:IsVisible() and Spell_Castable(rs["造食术"]) and GetTime() - Make_Drink_Eat_Time > 1.5 then
					Make_Drink_Eat_Time = GetTime()
					awm.CastSpellByName(rs["造食术"])
				end
				return false
			end
	    end
		if DoesSpellExist(rs["造水术"]) and not CheckBuff("player",rs["喝水"]) then
			local count_name = DrinkCount()
			if count_name == nil then
				if not CastingBarFrame:IsVisible() and Spell_Castable(rs["造水术"]) and GetTime() - Make_Drink_Eat_Time > 1.5 then
					Make_Drink_Eat_Time = GetTime()
					awm.CastSpellByName(rs["造水术"])
				end
				return false
			end
	    end
    end
    return true
end
-----------------------------------------------------------
function Encrypte()
    DF_Base64 = {}
    local string = string
    DF_Base64.__code = {
                'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
                'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
                'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
            };
    DF_Base64.__decode = {}
    for k,v in pairs(DF_Base64.__code) do
        DF_Base64.__decode[string.byte(v,1)] = k - 1
    end

    function DF_Base64.encode(text)
        local len = string.len(text)
        local left = len % 3
        len = len - left
        local res = {}
        local index  = 1
        for i = 1, len, 3 do
            local a = string.byte(text, i )
            local b = string.byte(text, i + 1)
            local c = string.byte(text, i + 2)
            -- num = a<<16 + b<<8 + c
            local num = a * 65536 + b * 256 + c 
            for j = 1, 4 do
                --tmp = num >> ((4 -j) * 6)
                local tmp = math.floor(num / (2 ^ ((4-j) * 6)))
                --curPos = tmp&0x3f
                local curPos = tmp % 64 + 1
                res[index] = DF_Base64.__code[curPos]
                index = index + 1
            end
        end

        if left == 1 then
            DF_Base64.__left1(res, index, text, len)
        elseif left == 2 then
            DF_Base64.__left2(res, index, text, len)        
        end
        return table.concat(res)
    end

    function DF_Base64.__left2(res, index, text, len)
        local num1 = string.byte(text, len + 1)
        num1 = num1 * 1024 --lshift 10 
        local num2 = string.byte(text, len + 2)
        num2 = num2 * 4 --lshift 2 
        local num = num1 + num2
   
        local tmp1 = math.floor(num / 4096) --rShift 12
        local curPos = tmp1 % 64 + 1
        res[index] = DF_Base64.__code[curPos]
    
        local tmp2 = math.floor(num / 64)
        curPos = tmp2 % 64 + 1
        res[index + 1] = DF_Base64.__code[curPos]

        curPos = num % 64 + 1
        res[index + 2] = DF_Base64.__code[curPos]
    
        res[index + 3] = "=" 
    end

    function DF_Base64.__left1(res, index,text, len)
        local num = string.byte(text, len + 1)
        num = num * 16 
    
        tmp = math.floor(num / 64)
        local curPos = tmp % 64 + 1
        res[index ] = DF_Base64.__code[curPos]
    
        curPos = num % 64 + 1
        res[index + 1] = DF_Base64.__code[curPos]
    
        res[index + 2] = "=" 
        res[index + 3] = "=" 
    end

    function DF_Base64.decode(text)
        local len = string.len(text)
        local left = 0 
        if string.sub(text, len - 1) == "==" then
            left = 2 
            len = len - 4
        elseif string.sub(text, len) == "=" then
            left = 1
            len = len - 4
        end

        local res = {}
        local index = 1
        local decode = DF_Base64.__decode
        for i =1, len, 4 do
            local a = decode[string.byte(text,i    )] 
            local b = decode[string.byte(text,i + 1)] 
            local c = decode[string.byte(text,i + 2)] 
            local d = decode[string.byte(text,i + 3)]

            --num = a<<18 + b<<12 + c<<6 + d
            local num = a * 262144 + b * 4096 + c * 64 + d
        
            local e = string.char(num % 256)
            num = math.floor(num / 256)
            local f = string.char(num % 256)
            num = math.floor(num / 256)
            res[index ] = string.char(num % 256)
            res[index + 1] = f
            res[index + 2] = e
            index = index + 3
        end

        if left == 1 then
            DF_Base64.__decodeLeft1(res, index, text, len)
        elseif left == 2 then
            DF_Base64.__decodeLeft2(res, index, text, len)
        end
        return table.concat(res)
    end

    function DF_Base64.__decodeLeft1(res, index, text, len)
        local decode = DF_Base64.__decode
        local a = decode[string.byte(text, len + 1)] 
        local b = decode[string.byte(text, len + 2)] 
        local c = decode[string.byte(text, len + 3)] 
        local num = a * 4096 + b * 64 + c
    
        local num1 = math.floor(num / 1024) % 256
        local num2 = math.floor(num / 4) % 256
        res[index] = string.char(num1)
        res[index + 1] = string.char(num2)
    end

    function DF_Base64.__decodeLeft2(res, index, text, len)
        local decode = DF_Base64.__decode
        local a = decode[string.byte(text, len + 1)] 
        local b = decode[string.byte(text, len + 2)]
        local num = a * 64 + b
        num = math.floor(num / 16)
        res[index] = string.char(num)
    end
    function KSA(key)
        local key_len = string.len(key)
        local S = {}
        local key_byte = {}

        for i = 0, 255 do
            S[i] = i
        end

        for i = 1, key_len do
            key_byte[i-1] = string.byte(key, i, i)
        end

        local j = 0
        for i = 0, 255 do
            j = (j + S[i] + key_byte[i % key_len]) % 256
            S[i], S[j] = S[j], S[i]
        end
        return S
    end

    function PRGA(S, text_len)
        local i = 0
        local j = 0
        local K = {}

        for n = 1, text_len do

            i = (i + 1) % 256
            j = (j + S[i]) % 256

            S[i], S[j] = S[j], S[i]
            K[n] = S[(S[i] + S[j]) % 256]
        end
        return K
    end

    function output(S, text)
        local len = string.len(text)
        local c = nil
        local res = {}
        for i = 1, len do
            c = string.byte(text, i, i)
            res[i] = string.char(bxor(S[i], c))
        end
        return table.concat(res)
    end

    function DF_RC4(key, text)
        local text_len = string.len(text)

        local S = KSA(key)        
        local K = PRGA(S, text_len) 
        return output(K, text)
    end
    local bit_op = {}
    function bit_op.cond_and(r_a, r_b)
        return (r_a + r_b == 2) and 1 or 0
    end

    function bit_op.cond_xor(r_a, r_b)
        return (r_a + r_b == 1) and 1 or 0
    end

    function bit_op.cond_or(r_a, r_b)
        return (r_a + r_b > 0) and 1 or 0
    end

    function bit_op.base(op_cond, a, b)
        -- bit operation
        if a < b then
            a, b = b, a
        end
        local res = 0
        local shift = 1
        while a ~= 0 do
            r_a = a % 2
            r_b = b % 2
   
            res = shift * bit_op[op_cond](r_a, r_b) + res 
            shift = shift * 2

            a = math.modf(a / 2)
            b = math.modf(b / 2)
        end
        return res
    end

    function bxor(a, b)
        return bit_op.base('cond_xor', a, b)
    end

    function band(a, b)
        return bit_op.base('cond_and', a, b)
    end

    function bor(a, b)
        return bit_op.base('cond_or', a, b)
    end
end
Encrypte()


-----------------------------------------------------------

function Create_Check_Button(parent,Point, xOff, yOff, displayname)
    local checkButton = CreateFrame("CheckButton",nil, parent, "UICheckButtonTemplate") --"OptionsCheckButtonTemplate"
	checkButton:SetPoint(Point,xOff, yOff)
	checkButton:SetSize(24,24)
	local text = checkButton:CreateFontString(nil, "ARTWORK","GameFontNormalSmall")
	text:SetText(displayname)
	text:SetPoint("BottomLeft",30,checkButton:GetHeight()/5)
	return checkButton
end

function Create_Button(parent,Point, xOff, yOff,displayname)
    local button = CreateFrame("button", nil, parent, "UIPanelButtonTemplate")
	button:SetText(displayname)
	button:SetPoint(Point,xOff,yOff)
	button:Show()
	return button
end

function Create_Page_Button(parent,Point, xOff, yOff,displayname)
    local button = CreateFrame("button", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	button:SetText(displayname)
	local buttontext = button:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext:SetText(displayname)
	buttontext:SetPoint("Center")
	buttontext:SetTextColor(1,1,1,1)
	button:SetPoint(Point,xOff,yOff)
	button:Show()
	button:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",edgeFile="Interface/ChatFrame/ChatFrameBackground",title= true, edgeSize =1, titleSize = 5})
	button:SetBackdropColor(0,0,0,0)
	button:SetBackdropBorderColor(1,1,1,0)
	return button
end
function Create_Header(parent, Point, xOff, yOff,displayname) -- 正常文字
    local Header = parent:CreateFontString(nil, "ARTWORK","GameFontNormal")
	Header:SetPoint(Point, xOff, yOff)
	Header:SetText(displayname)
	return Header
end
function Create_Small_Header(parent, Point, xOff, yOff,displayname) -- 正常文字
    local Header = parent:CreateFontString(nil, "ARTWORK","GameFontSmall")
	Header:SetPoint(Point, xOff, yOff)
	Header:SetText(displayname)
	return Header
end
function Create_EditBox(parent, Point, xOff, yOff,displayname,Multiline,Width,Height)
    local EditBox = CreateFrame("EditBox",nil, parent,BackdropTemplateMixin and "BackdropTemplate")
	EditBox:SetTextInsets(6, 10, 4, 5)
	EditBox:SetFontObject(ChatFontNormal)
	EditBox:SetText(displayname)
	EditBox:SetPoint(Point, xOff, yOff)
	EditBox:HighlightText()
	EditBox:SetAutoFocus(false)
	EditBox:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
	EditBox:SetMaxLetters(5000000)
	EditBox:SetMultiLine(Multiline)
	EditBox:SetSize(Width,Height)

	return EditBox
end
function Create_Scroll_Edit(parent, Point, xOff, yOff,displayname,Width,Height)
    local frame = CreateFrame("frame",nil,parent,BackdropTemplateMixin and "BackdropTemplate")
	frame:SetPoint(Point, xOff, yOff)
	frame:SetSize(Width,Height)
	frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})

	local Scroll = CreateFrame("ScrollFrame", "ScrollFrame",frame,"UIPanelScrollFrameTemplate")
	Scroll:SetSize(Width - 35,Height - 20)
	Scroll:SetPoint("TopLeft",5,-5)
	Scroll:Show()
	Scroll:SetFrameStrata('TOOLTIP')
    
    local EditBox = CreateFrame("EditBox",nil, parent,BackdropTemplateMixin and "BackdropTemplate")
	EditBox:SetTextInsets(6, 10, 4, 5)
	EditBox:SetFontObject(ChatFontNormal)
	EditBox:SetText(displayname)
	EditBox:SetPoint(Point, xOff, yOff)
	EditBox:HighlightText()
	EditBox:SetAutoFocus(false)
	EditBox:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
	EditBox:SetMaxLetters(5000000)
	EditBox:SetMultiLine(true)
	EditBox:SetSize(Width,Height)
	EditBox:SetBackdropColor(0.1,0.1,0.1,0)
	EditBox:SetBackdropBorderColor(1,1,1,0)

	Scroll:SetScrollChild(EditBox)

	return EditBox
end
function Create_Scroll(parent, Point, xOff, yOff,Width,Height)
    local frame = CreateFrame("frame",nil,parent,BackdropTemplateMixin and "BackdropTemplate")
	frame:SetPoint(Point, xOff, yOff)
	frame:SetSize(Width,Height)
	frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})

	local Scroll = CreateFrame("ScrollFrame", "ScrollFrame",frame,"UIPanelScrollFrameTemplate")
	Scroll:SetSize(Width - 35,Height - 20)
	Scroll:SetPoint("TopLeft",5,-5)
	Scroll:Show()
	Scroll:SetFrameStrata('TOOLTIP')

    local Panel = CreateFrame("Frame","MainFrame",parent, BackdropTemplateMixin and "BackdropTemplate")
	Panel:SetPoint(Point, xOff, yOff)
	Panel:SetSize(Width,Height)
	Panel:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",
	edgeFile="Interface/ChatFrame/ChatFrameBackground",
	title= true, 
	edgeSize =1, 
	titleSize = 5})
	Panel:SetBackdropColor(0,0,0,0)
	Panel:SetBackdropBorderColor(0.8,0.8,0.8,0)
	Panel:Show()

	Scroll:SetScrollChild(Panel)

	return Panel
end

-- 主程序
    color = {}
    color.white = "|CFFFFFFFF"
    color.red = "|CFFFF2400"

    if Easy_Data.UI == nil then
        Easy_Data.UI = Check_Client("CN","EN")
    end

    UI_Button_Py = -10

	rs = {} -- spell table
	local function Spell_Translate()
		local function Hunter()
			rs["假死"] = Check_Client("假死","Feign Death")

            local Pet_Spell1 = GetSpellInfo(Check_Client("召唤宠物","Call Pet"))
            local Pet_Spell2 = GetSpellInfo(Check_Client("召唤宠物","Beast Call"))

            if Pet_Spell1 then
                rs["召唤宠物"] = Check_Client("召唤宠物","Call Pet")
            else
                rs["召唤宠物"] = Check_Client("召唤宠物","Beast Call")
            end


			rs["喂养宠物"] = Check_Client("喂养宠物","Feed Pet")
			rs["复活宠物"] = Check_Client("复活宠物","Revive Pet")
			rs["治疗宠物"] = Check_Client("治疗宠物","Mend Pet")
			rs["雄鹰守护"] = Check_Client("雄鹰守护","Aspect of the Hawk")
			rs["强击光环"] = Check_Client("强击光环","Trueshot Aura")
			rs["自动射击"] = Check_Client("自动射击","Auto Shot")
			rs["奥术射击"] = Check_Client("奥术射击","Arcane Shot")
			rs["毒蛇钉刺"] = Check_Client("毒蛇钉刺","Serpent Sting")
			rs["猎人印记"] = Check_Client("猎人印记","Hunter's Mark")
			rs["猛禽一击"] = Check_Client("猛禽一击","Raptor Strike")
			rs["猎豹守护"] = Check_Client("猎豹守护","Aspect of the Cheetah")

            rs["冰冻陷阱"] = Check_Client("冰冻陷阱","Freezing Trap")
            rs["乱射"] = Check_Client("乱射","Volley")
            rs["逃脱"] = Check_Client("逃脱","Disengage")
            rs["爆炸陷阱"] = Check_Client("爆炸陷阱","Explosive Trap")
            rs["献祭陷阱"] = Check_Client("献祭陷阱","Immolation Trap")
            rs["猫鼬撕咬"] = Check_Client("猫鼬撕咬","Mongoose Bite")

            rs["蝰蛇钉刺"] = Check_Client("蝰蛇钉刺","Viper Sting")
            rs["多重射击"] = Check_Client("多重射击","Multi-Shot")
            rs["急速射击"] = Check_Client("急速射击","Rapid Fire")
            rs["瞄准射击"] = Check_Client("瞄准射击","Aimed Shot")
            rs["狂野怒火"] = Check_Client("狂野怒火","Bestial Wrath")
            rs["胁迫"] = Check_Client("胁迫","Intimidation")

            rs["震荡射击"] = Check_Client("震荡射击","Concussive Shot")
		end

		local function Mage()
	        rs["造食术"] = Check_Client("造食术","Conjure Food")
		    rs["造水术"] = Check_Client("造水术","Conjure Water")
		    rs["冰甲术"] = Check_Client("冰甲术","Ice Armor")
		    rs["霜甲术"] = Check_Client("霜甲术","Frost Armor")
		    rs["奥术智慧"] = Check_Client("奥术智慧","Arcane Intellect")

            if GetExpansionLevel() == 0 then
                rs["法师魔甲术"] = Check_Client("魔甲术","Mage Armor")
            else
                rs["法师魔甲术"] = Check_Client("法师护甲","Mage Armor")
            end

            rs["活动炸弹"] = Check_Client("活动炸弹","Living Bomb")
            rs["熔岩护甲"] = Check_Client("熔岩护甲","Molten Armor")

		    rs["寒冰护体"] = Check_Client("寒冰护体","Ice Barrier")
		    rs["法力护盾"] = Check_Client("法力护盾","Mana Shield")
		    rs["寒冰箭"] = Check_Client("寒冰箭","Frostbolt")
		    rs["冰霜新星"] = Check_Client("冰霜新星","Frost Nova")
		    rs["火焰冲击"] = Check_Client("火焰冲击","Fire Blast")
		    rs["火球术"] = Check_Client("火球术","Fireball")
		    rs["火球术(等级 1)"] = Check_Client("火球术(等级 1)","Fireball(Rank 1)")
		    rs["燃烧"] = Check_Client("燃烧","Combustion")
		    rs["灼烧"] = Check_Client("灼烧","Scorch")
		    rs["寒冰箭(等级 1)"] = Check_Client("寒冰箭(等级 1)","Frostbolt(Rank 1)")

		    rs["火焰冲击(等级 1)"] = Check_Client("火焰冲击(等级 1)","Fire Blast(Rank 1)")
		    rs["防护火焰结界"] = Check_Client("防护火焰结界","Fire Ward")
            rs["防护冰霜结界"] = Check_Client("防护冰霜结界","Frost Ward")
		    rs["冰锥术(等级 1)"] = Check_Client("冰锥术(等级 1)","Cone of Cold(Rank 1)")
            rs["冰锥术"] = Check_Client("冰锥术","Cone of Cold")
		    rs["魔爆术"] = Check_Client("魔爆术","Arcane Explosion")
		    rs["魔爆术(等级 1)"] = Check_Client("魔爆术(等级 1)","Arcane Explosion(Rank 1)")
		    rs["冰霜新星(等级 1)"] = Check_Client("冰霜新星(等级 1)","Frost Nova(Rank 1)")
		    rs["法术反制"] = Check_Client("法术反制","Counterspell")

            rs["变形术"] = Check_Client("变形术","Polymorph")

		    rs["魔法抑制"] = Check_Client("魔法抑制","Dampen Magic")
            rs["魔法增效"] = Check_Client("魔法增效","Amplify Magic")
            rs["气定神闲"] = Check_Client("气定神闲","Presence of Mind")
            rs["奥术强化"] = Check_Client("奥术强化","Arcane Power")
            rs["炎爆术"] = Check_Client("炎爆术","Pyroblast")
            rs["龙息术"] = Check_Client("龙息术","Dragon's Breath")
            rs["冲击波"] = Check_Client("冲击波","Blast Wave")
            rs["奥术飞弹"] = Check_Client("奥术飞弹","Arcane Missiles")
            rs["射击"] = Check_Client("射击","Shot")

		    rs["闪现术"] = Check_Client("闪现术","Blink")
            rs["隐形术"] = Check_Client("隐形术","Invisibility")
		    rs["急速冷却"] = Check_Client("急速冷却","Cold Snap")

		    rs["寒冰屏障"] = Check_Client("寒冰屏障","Ice Block")

		    rs["冰冷血脉"] = Check_Client("冰冷血脉","Icy Veins")

		    rs["暴风雪"] = Check_Client("暴风雪","Blizzard")
		    rs["节能施法"] = Check_Client("节能施法","Clearcasting")
		    rs["暴风雪(等级 1)"] = Check_Client("暴风雪(等级 1)","Blizzard(Rank 1)")
		    rs["唤醒"] = Check_Client("唤醒","Evocation")
		    rs["暴风雪(等级 4)"] = Check_Client("暴风雪(等级 4)","Blizzard(Rank 4)")
		    rs["烈焰风暴"] = Check_Client("烈焰风暴","Flamestrike")
		    rs["烈焰风暴(等级 1)"] = Check_Client("烈焰风暴(等级 1)","Flamestrike(Rank 1)")

            rs["召唤水元素"] = Check_Client("召唤水元素","Summon Water Elemental")
            rs["冰冻术"] = Check_Client("冰冻术","Freeze")

            rs["冰枪术"] = Check_Client("冰枪术","Ice Lance")

		    rs["魔法水"] = Check_Client("魔法水","Conjured Water")
		    rs["魔法淡水"] = Check_Client("魔法淡水","Conjured Fresh Water")
		    rs["魔法纯净水"] = Check_Client("魔法纯净水","Conjured Purified Water")
		    rs["魔法泉水"] = Check_Client("魔法泉水","Conjured Spring Water")
		    rs["魔法矿泉水"] = Check_Client("魔法矿泉水","Conjured Mineral Water")
		    rs["魔法苏打水"] = Check_Client("魔法苏打水","Conjured Sparkling Water")
		    rs["魔法晶水"] = Check_Client("魔法晶水","Conjured Crystal Water")
		    rs["魔法山泉水"] = Check_Client("魔法山泉水","Conjured Mountain Spring Water")
		    rs["魔法冰川水"] = Check_Client("魔法冰川水","Conjured Glacier Water")

		    rs["魔法松饼"] = Check_Client("魔法松饼","Conjured Muffin")
		    rs["魔法面包"] = Check_Client("魔法面包","Conjured Bread")
		    rs["魔法黑面包"] = Check_Client("魔法黑面包","Conjured Rye")
		    rs["魔法粗面包"] = Check_Client("魔法粗面包","Conjured Pumpernickel")
		    rs["魔法酵母"] = Check_Client("魔法酵母","Conjured Sourdough")
		    rs["魔法甜面包"] = Check_Client("魔法甜面包","Conjured Sweet Roll")
		    rs["魔法肉桂面包"] = Check_Client("魔法肉桂面包","Conjured Cinnamon Roll")
		    rs["魔法羊角面包"] = Check_Client("魔法羊角面包","Conjured Croissant")

            rs["法力刚玉"] = Check_Client("法力刚玉","Mana Emerald")
		    rs["法力红宝石"] = Check_Client("法力红宝石","Mana Ruby")
		    rs["法力黄水晶"] = Check_Client("法力黄水晶","Mana Citrine")
		    rs["法力翡翠"] = Check_Client("法力翡翠","Mana Jade")
		    rs["法力玛瑙"] = Check_Client("法力玛瑙","Mana Agate")

            rs["制造魔法玉石"] = Check_Client("制造魔法玉石","Conjure Mana Emerald")
		    rs["制造魔法红宝石"] = Check_Client("制造魔法红宝石","Conjure Mana Ruby")
		    rs["制造魔法黄水晶"] = Check_Client("制造魔法黄水晶","Conjure Mana Citrine")
		    rs["制造魔法翡翠"] = Check_Client("制造魔法翡翠","Conjure Mana Jade")
		    rs["制造魔法玛瑙"] = Check_Client("制造魔法玛瑙","Conjure Mana Agate")
	    end

		local function Paladin()
			rs["圣光术"] = Check_Client("圣光术","Holy Light")
			rs["圣光闪现"] = Check_Client("圣光闪现","Flash of Light")
			rs["奉献"] = Check_Client("奉献","Consecration")
			rs["王者祝福"] = Check_Client("王者祝福","Blessing of Kings")
			rs["制裁之锤"] = Check_Client("制裁之锤","Hammer of Justice")
			rs["虔诚光环"] = Check_Client("虔诚光环","Devotion Aura")
			rs["十字军圣印"] = Check_Client("十字军圣印","Seal of the Crusader")
            rs["十字军审判"] = Check_Client("十字军审判","Judgement of the Crusader")
			rs["审判"] = Check_Client("审判","Judgement")

            rs["正义审判"] = Check_Client("正义审判","Judgement of Righteousness")
            rs["正义之怒"] = Check_Client("正义之怒","Righteous Fury")
            rs["正义圣印"] = Check_Client("正义圣印","Seal of Righteousness")
            rs["纯净术"] = Check_Client("纯净术","Purify")
            rs["圣疗术"] = Check_Client("圣疗术","Lay on Hands")
            rs["智慧祝福"] = Check_Client("智慧祝福","Blessing of Wisdom")
            rs["专注光环"] = Check_Client("专注光环","Concentration Aura")
            rs["光明圣印"] = Check_Client("光明圣印","Seal of Light")
            rs["神恩术"] = Check_Client("神恩术","Divine Favor")
            rs["圣光审判"] = Check_Client("圣光审判","Judgement of Light")
            rs["智慧审判"] = Check_Client("智慧审判","Judgement of Wisdom")
            rs["智慧圣印"] = Check_Client("智慧圣印","Seal of Wisdom")
            rs["神圣震击"] = Check_Client("神圣震击","Holy Shock")
            rs["清洁术"] = Check_Client("清洁术","Cleanse")
            rs["神启"] = Check_Client("神启","Divine Illumination")
            rs["圣佑术"] = Check_Client("圣佑术","Divine Protection")
            rs["制裁之锤"] = Check_Client("制裁之锤","Hammer of Justice")
            rs["保护之手"] = Check_Client("保护之手","Hand of Protection")
            rs["正义防御"] = Check_Client("正义防御","Righteous Defense")
            rs["公正圣印"] = Check_Client("公正圣印","Seal of Justice")
            rs["公正审判"] = Check_Client("公正审判","Judgement of Justice")
            rs["暗影抗性光环"] = Check_Client("暗影抗性光环","Shadow Resistance Aura")
            rs["庇护祝福"] = Check_Client("庇护祝福","Blessing of Sanctuary")
            rs["冰霜抗性光环"] = Check_Client("冰霜抗性光环","Frost Resistance Aura")
            rs["圣盾术"] = Check_Client("圣盾术","Divine Shield")
            rs["火焰抗性光环"] = Check_Client("火焰抗性光环","Fire Resistance Aura")
            rs["神圣之盾"] = Check_Client("神圣之盾","Holy Shield")

            rs["复仇者之盾"] = Check_Client("复仇者之盾","Avenger's Shield")
            rs["力量祝福"] = Check_Client("力量祝福","Blessing of Might")
            rs["惩戒光环"] = Check_Client("惩罚光环","Retribution Aura")
            rs["命令审判"] = Check_Client("命令审判","Judgement of Command")
            rs["命令圣印"] = Check_Client("命令圣印","Seal of Command")
            rs["愤怒之锤"] = Check_Client("愤怒之锤","Hammer of Wrath")
            rs["十字军打击"] = Check_Client("十字军打击","Crusader Strike")
            rs["复仇之怒"] = Check_Client("复仇之怒","Avenging Wrath")

            rs["拯救祝福"] = Check_Client("拯救祝福","Blessing of Salvation")

            rs["保护祝福"] = Check_Client("保护祝福","Blessing of Protection")

            rs["自律"] = Check_Client("自律","Forbearance")
		end

		local function Priest()
			rs["暗影形态"] = Check_Client("暗影形态","Shadowform")
			rs["真言术：韧"] = Check_Client("真言术：韧","Power Word: Fortitude")
			rs["心灵之火"] = Check_Client("心灵之火","Inner Fire")
			rs["真言术：盾"] = Check_Client("真言术：盾","Power Word: Shield")
			rs["神圣新星"] = Check_Client("神圣新星","Holy Nova")
			rs["暗言术：痛"] = Check_Client("暗言术：痛","Shadow Word: Pain")
			rs["心灵震爆"] = Check_Client("心灵震爆","Mind Blast")
			rs["噬灵瘟疫"] = Check_Client("噬灵瘟疫","Devouring Plague")
			rs["精神鞭笞"] = Check_Client("精神鞭笞","Mind Flay")
			rs["惩击"] = Check_Client("惩击","Smite")
			rs["恢复"] = Check_Client("恢复","Renew")
			rs["心灵震爆"] = Check_Client("心灵震爆","Mind Blast")
			rs["心灵专注"] = Check_Client("心灵专注","Inner Focus")

            rs["心灵尖啸"] = Check_Client("心灵尖啸","Psychic Scream")
            rs["渐隐术"] = Check_Client("渐隐术","Fade")

            rs["吸血鬼的拥抱"] = Check_Client("吸血鬼的拥抱","Vampiric Embrace")
            rs["吸血鬼之触"] = Check_Client("吸血鬼之触","Vampiric Touch")
            rs["暗影恶魔"] = Check_Client("暗影恶魔","Shadowfiend")

            rs["防护暗影"] = Check_Client("防护暗影","Shadow Protection")

            rs["虚弱妖术"] = Check_Client("虚弱妖术","Hex of Weakness")

            rs["驱散魔法"] = Check_Client("驱散魔法","Dispel Magic")
            rs["治疗祷言"] = Check_Client("治疗祷言","Prayer of Healing")
            rs["治疗之环"] = Check_Client("治疗之环","Circle of Healing")
            rs["快速治疗"] = Check_Client("快速治疗","Flash Heal")
            rs["强效治疗术"] = Check_Client("强效治疗术","Greater Heal")
            rs["治疗术"] = Check_Client("治疗术","Heal")
            rs["次级治疗术"] = Check_Client("次级治疗术","Lesser Heal")

            rs["驱除疾病"] = Check_Client("驱除疾病","Abolish Disease")
		end

		local function Warlock()
			rs["术士魔甲术"] = Check_Client("魔甲术","Demon Armor")
			rs["暗影箭"] = Check_Client("暗影箭","Shadow Bolt")
			rs["痛苦诅咒"] = Check_Client("痛苦诅咒","Curse of Agony")
			rs["献祭"] = Check_Client("献祭","Immolate")
			rs["腐蚀术"] = Check_Client("腐蚀术","Corruption")
			rs["吸取生命"] = Check_Client("吸取生命","Drain Life")
            rs["吸取法力"] = Check_Client("吸取法力","Drain Mana")
			rs["生命虹吸"] = Check_Client("生命虹吸","Siphon Life")
            rs["黑暗契约"] = Check_Client("黑暗契约","Dark Pact")
            rs["暗影冥思"] = Check_Client("暗影冥思","Shadow Trance")

            rs["痛苦无常"] = Check_Client("痛苦无常","Unstable Affliction")
            rs["生命分流"] = Check_Client("生命分流","Life Tap")
            rs["灵魂碎片"] = Check_Client("灵魂碎片","Soul Shard")
            rs["吸取灵魂"] = Check_Client("吸取灵魂","Drain Soul")

            rs["召唤恶魔卫士"] = Check_Client("召唤恶魔卫士","Summon Felguard")
            rs["召唤小鬼"] = Check_Client("召唤小鬼","Summon Imp")
            rs["召唤魅魔"] = Check_Client("召唤魅魔","Summon Succubus")
            rs["召唤地狱猎犬"] = Check_Client("召唤地狱猎犬","Summon Felhunter")
            rs["召唤虚空行者"] = Check_Client("召唤虚空行者","Summon Voidwalker")
            rs["制造治疗石"] = Check_Client("制造治疗石","Create Healthstone")

            rs["邪甲术"] = Check_Client("邪甲术","Fel Armor")

            rs["恶魔皮肤"] = Check_Client("恶魔皮肤","Demon Skin")

            rs["恐惧"] = Check_Client("恐惧","Fear")

            rs["死亡缠绕"] = Check_Client("死亡缠绕","Death Coil")

            rs["厄运诅咒"] = Check_Client("厄运诅咒","Curse of Doom")
            rs["腐蚀之种"] = Check_Client("腐蚀之种","Seed of Corruption")
            rs["生命通道"] = Check_Client("生命通道","Health Funnel")
            rs["灵魂碎裂"] = Check_Client("灵魂碎裂","Soulshatter")
            rs["灼热之痛"] = Check_Client("灼热之痛","Searing Pain")

            rs["诅咒增幅"] = Check_Client("诅咒增幅","Amplify Curse")

            rs["灵魂之火"] = Check_Client("灵魂之火","Soul Fire")
            rs["火焰之雨"] = Check_Client("火焰之雨","Rain of Fire")
            rs["暗影灼烧"] = Check_Client("暗影灼烧","Shadowburn")
            rs["暗影之怒"] = Check_Client("暗影之怒","Shadowfury")
            rs["地狱烈焰"] = Check_Client("地狱烈焰","Hellfire")
            rs["恶魔支配"] = Check_Client("恶魔支配","Fel Domination")
            rs["灵魂链接"] = Check_Client("灵魂链接","Soul Link")
            rs["烧尽"] = Check_Client("烧尽","Incinerate")
            rs["术士燃烧"] = Check_Client("术士燃烧","Conflagrate")
		end

		local function Warrior()
			rs["冲锋"] = Check_Client("冲锋","Charge")
			rs["战斗怒吼"] = Check_Client("战斗怒吼","Battle Shout")
			rs["狂暴之怒"] = Check_Client("狂暴之怒","Berserker Rage")
			rs["嗜血"] = Check_Client("嗜血","Bloodthirst")
			rs["撕裂"] = Check_Client("撕裂","Rend")
			rs["顺劈斩"] = Check_Client("顺劈斩","Cleave")
			rs["英勇打击"] = Check_Client("英勇打击","Heroic Strike")
			rs["致死打击"] = Check_Client("致死打击","Mortal Strike")
			rs["猛击"] = Check_Client("猛击","Slam")
            rs["嘲讽"] = Check_Client("嘲讽","Taunt")
            rs["拦截"] = Check_Client("拦截","Intercept")
            rs["战斗姿态"] = Check_Client("战斗姿态","Battle Stance")
            rs["防御姿态"] = Check_Client("防御姿态","Defensive Stance")
            rs["狂暴姿态"] = Check_Client("狂暴姿态","Berserker Stance")
            rs["拳击"] = Check_Client("拳击","Pummel")
            rs["盾击"] = Check_Client("盾击","Shield Bash")
            rs["挫志怒吼"] = Check_Client("挫志怒吼","Demoralizing Shout")
            rs["刺耳怒吼"] = Check_Client("刺耳怒吼","Piercing Howl")
            rs["命令怒吼"] = Check_Client("命令怒吼","Commanding Shout")
            rs["死亡之愿"] = Check_Client("死亡之愿","死亡之愿")
            rs["鲁莽"] = Check_Client("鲁莽","Recklessness")
            rs["血性狂暴"] = Check_Client("血性狂暴","Bloodrage")
            rs["暴怒"] = Check_Client("暴怒","Rampage")
            rs["破釜沉舟"] = Check_Client("破釜沉舟","Last Stand")
            rs["反击风暴"] = Check_Client("反击风暴","Retaliation")
            rs["盾墙"] = Check_Client("盾墙","Shield Wall")
            rs["破胆怒吼"] = Check_Client("破胆怒吼","Intimidating Shout")
            rs["横扫攻击"] = Check_Client("横扫攻击","Sweeping Strikes")
            rs["盾牌格挡"] = Check_Client("盾牌格挡","Shield Block")
            rs["压制"] = Check_Client("压制","Overpower")
            rs["缴械"] = Check_Client("缴械","Disarm")
            rs["复仇"] = Check_Client("复仇","Revenge")
            rs["斩杀"] = Check_Client("斩杀","Execute")
            rs["震荡猛击"] = Check_Client("震荡猛击","Concussion Blow")
            rs["毁灭打击"] = Check_Client("毁灭打击","Devastate")
            rs["惩戒痛击"] = Check_Client("惩戒痛击","Mocking Blow")
            rs["雷霆一击"] = Check_Client("雷霆一击","Thunder Clap")
            rs["旋风斩"] = Check_Client("旋风斩","Whirlwind")
		end

		local function Shaman()
            rs["空气图腾"] = Check_Client("空气图腾","Air Totem")
            rs["水之图腾"] = Check_Client("水之图腾","Water Totem")
            rs["火焰图腾"] = Check_Client("火焰图腾","Fire Totem")
            rs["大地图腾"] = Check_Client("大地图腾","Earth Totem")

			rs["烈焰震击"] = Check_Client("烈焰震击","Flame Shock")
			rs["地震术"] = Check_Client("地震术","Earth Shock")
			rs["冰霜震击"] = Check_Client("冰霜震击","Frost Shock")
			rs["闪电箭"] = Check_Client("闪电箭","Lightning Bolt")
			rs["闪电之盾"] = Check_Client("闪电之盾","Lightning Shield")
			rs["治疗波"] = Check_Client("治疗波","Healing Wave")
			rs["次级治疗波"] = Check_Client("次级治疗波","Lesser Healing Wave")
            rs["石化武器"] = Check_Client("石化武器","Rockbiter Weapon")
            rs["石肤图腾"] = Check_Client("石肤图腾","Stoneskin Totem")
            rs["地缚图腾"] = Check_Client("地缚图腾","Earthbind Totem")
            rs["石爪图腾"] = Check_Client("石爪图腾","Stoneclaw Totem")
            rs["大地之力图腾"] = Check_Client("大地之力图腾","Strength of Earth Totem")
            rs["火舌武器"] = Check_Client("火舌武器","Flametongue Weapon")
            rs["灼热图腾"] = Check_Client("灼热图腾","Searing Totem")
            rs["火焰新星图腾"] = Check_Client("火焰新星图腾","Fire Nova Totem")
            rs["消毒术"] = Check_Client("消毒术","Cure Toxins")
            rs["战栗图腾"] = Check_Client("战栗图腾","Tremor Totem")
            rs["冰封武器"] = Check_Client("冰封武器","Frostbrand Weapon")
            rs["治疗之泉图腾"] = Check_Client("治疗之泉图腾","Healing Stream Totem")
            rs["抗寒图腾"] = Check_Client("抗寒图腾","Frost Resistance Totem")
            rs["法力之泉图腾"] = Check_Client("法力之泉图腾","Mana Spring Totem")
            rs["熔岩图腾"] = Check_Client("熔岩图腾","Magma Totem")
            rs["火舌图腾"] = Check_Client("火舌图腾","Flametongue Totem")
            rs["抗火图腾"] = Check_Client("抗火图腾","Fire Resistance Totem")
            rs["风怒武器"] = Check_Client("风怒武器","Windfury Weapon")
            rs["根基图腾"] = Check_Client("根基图腾","Grounding Totem")
            rs["自然抗性图腾"] = Check_Client("自然抗性图腾","Nature Resistance Totem")
            rs["自然迅捷"] = Check_Client("自然迅捷","Nature's Swiftness")
            rs["风怒图腾"] = Check_Client("风怒图腾","Windfury Totem")
            rs["闪电链"] = Check_Client("闪电链","Chain Lightning")
            rs["净化图腾"] = Check_Client("净化图腾","Cleansing Totem")
            rs["法力之潮图腾"] = Check_Client("法力之潮图腾","Mana Tide Totem")
            rs["风暴打击"] = Check_Client("风暴打击","Stormstrike")
            rs["萨满之怒"] = Check_Client("萨满之怒","Shamanistic Rage")
            rs["天怒图腾"] = Check_Client("天怒图腾","Totem of Wrath")
            rs["水之护盾"] = Check_Client("水之护盾","Water Shield")
            rs["空气之怒图腾"] = Check_Client("空气之怒图腾","Wrath of Air Totem")
            rs["土元素图腾"] = Check_Client("土元素图腾","Earth Elemental Totem")
            rs["大地之盾"] = Check_Client("大地之盾","Earth Shield")
            rs["治疗链"] = Check_Client("治疗链","Chain Heal")
            rs["风墙图腾"] = Check_Client("风墙图腾","Windwall Totem")
            rs["火元素图腾"] = Check_Client("火元素图腾","Fire Elemental Totem")
            rs["嗜血"] = Check_Client("嗜血","Bloodlust")

            rs["清毒图腾"] = Check_Client("清毒图腾","Poison Cleansing Totem")
            rs["祛病术"] = Check_Client("祛病术","Cure Disease")
            rs["祛病图腾"] = Check_Client("祛病图腾","Cure Disease Totem")
            rs["风之优雅图腾"] = Check_Client("风之优雅图腾","Grace of Air Totem")
		end

		local function Rogue()
			rs["切割"] = Check_Client("切割","切割")
			rs["肾击"] = Check_Client("肾击","Kidney Shot")
			rs["刺骨"] = Check_Client("刺骨","Eviscerate")
			rs["闪避"] = Check_Client("闪避","Evasion")
			rs["潜行"] = Check_Client("潜行","Stealth")

			rs["暗影步"] = Check_Client("暗影步","Shadowstep")
			rs["冲动"] = Check_Client("冲动","Adrenaline Rush")
			rs["出血"] = Check_Client("出血","Hemorrhage")
			rs["割裂"] = Check_Client("割裂","Rupture")

            rs["剑刃乱舞"] = Check_Client("剑刃乱舞","Blade Flurry")

            rs["凿击"] = Check_Client("凿击","Gouge")

            if GetExpansionLevel() == 0 then
                rs["影袭"] = Check_Client("邪恶攻击","Sinister Strike")
            else
                rs["影袭"] = Check_Client("影袭","Sinister Strike")
            end

            rs["偷袭"] = Check_Client("偷袭","Cheap Shot")

            rs["预谋"] = Check_Client("预谋","Premeditation")

            rs["闷棍"] = Check_Client("闷棍","Sap")
            rs["疾跑"] = Check_Client("疾跑","Sprint")
            rs["消失"] = Check_Client("消失","Vanish")

            rs["扰乱"] = Check_Client("扰乱","Distract")
            rs["暗影斗篷"] = Check_Client("暗影斗篷","Cloak of Shadows")
            rs["伺机待发"] = Check_Client("伺机待发","Preparation")
            rs["致盲"] = Check_Client("致盲","Blind")

            rs["鬼魅攻击"] = Check_Client("鬼魅攻击","Ghostly Strike")

            rs["佯攻"] = Check_Client("佯攻","Feint")

            rs["破甲"] = Check_Client("破甲","Expose Armor")

            rs["闪光粉"] = Check_Client("闪光粉","Flash Powder")
		end

		local function Druid()
			rs["月火术"] = Check_Client("月火术","Moonfire")
			rs["愤怒"] = Check_Client("愤怒","Wrath")
			rs["荆棘术"] = Check_Client("荆棘术","Thorns")
			rs["枭兽形态"] = Check_Client("枭兽形态","Moonkin Form")
			rs["回春术"] = Check_Client("回春术","Rejuvenation")
			rs["野性印记"] = Check_Client("野性印记","Mark of the Wild")
			rs["旅行形态"] = Check_Client("旅行形态","Travel Form")

            rs["激活"] = Check_Client("激活","Innervate")
            rs["树皮术"] = Check_Client("树皮术","Barkskin")
            rs["星火术"] = Check_Client("星火术","Starfire")
            rs["飓风"] = Check_Client("飓风","Hurricane")
            rs["原始狂怒"] = Check_Client("原始狂怒","Primal Fury")
            rs["挫志咆哮"] = Check_Client("挫志咆哮","Demoralizing Roar")
            rs["低吼"] = Check_Client("低吼","Growl")
            rs["熊形态"] = Check_Client("熊形态","Bear Form")
            rs["重殴"] = Check_Client("重殴","Maul")
            rs["激怒"] = Check_Client("激怒","Enrage")
            rs["猛击"] = Check_Client("猛击","Bash")
            rs["横扫"] = Check_Client("横扫","Swipe")
            rs["割裂"] = Check_Client("割裂","Rip")
            rs["猎豹形态"] = Check_Client("猎豹形态","Cat Form")
            rs["野性冲锋"] = Check_Client("野性冲锋","Feral Charge")

            rs["撕碎"] = Check_Client("撕碎","Shred")
            rs["猛虎之怒"] = Check_Client("猛虎之怒","Tiger's Fury")
            rs["斜掠"] = Check_Client("斜掠","Rake")
            rs["精灵之火（野性）"] = Check_Client("精灵之火（野性）","Faerie Fire (Feral)")
            rs["挑战咆哮"] = Check_Client("挑战咆哮","Challenging Roar")
            rs["凶猛撕咬"] = Check_Client("凶猛撕咬","Ferocious Bite")
            rs["狂暴回复"] = Check_Client("狂暴回复","Frenzied Regeneration")
            rs["巨熊形态"] = Check_Client("巨熊形态","Dire Bear Form")
            rs["裂伤（豹）"] = Check_Client("裂伤（豹）","Mangle (Cat)")
            rs["裂伤（熊）"] = Check_Client("裂伤（熊）","Mangle (Bear)")
            rs["割伤"] = Check_Client("割伤","Lacerate")
            rs["治疗之触"] = Check_Client("治疗之触","Healing Touch")
            rs["愈合"] = Check_Client("愈合","Regrowth")
            rs["消毒术"] = Check_Client("消毒术","Cure Poison")
            rs["解除诅咒"] = Check_Client("解除诅咒","Remove Curse")
            rs["驱毒术"] = Check_Client("驱毒术","Abolish Poison")

            rs["宁静"] = Check_Client("宁静","Tranquility")
            rs["迅捷治愈"] = Check_Client("迅捷治愈","Swiftmend")
            rs["生命之树"] = Check_Client("生命之树","Tree of Life")
		end

		rs["进食"] = Check_Client("进食","Food")
		rs["喝水"] = Check_Client("喝水","Drink")
		rs["攻击"] = Check_Client("攻击","Attack")

		rs["寻找草药"] = Check_Client("寻找草药","Find Herbs")
		rs["草药学"] = Check_Client("草药学","Herbalism")
		rs["寻找矿物"] = Check_Client("寻找矿物","Find Minerals")
		rs["采矿"] = Check_Client("采矿","Mining")
		rs["剥皮"] = Check_Client("剥皮","Skinning")
		rs["开锁"] = Check_Client("开锁","Lockpicking")
		rs["初级草药学"] = Check_Client("初级草药学","Apprentice Herbalist")
		rs["中级草药学"] = Check_Client("中级草药学","Journeyman Herbalist")
		rs["高级草药学"] = Check_Client("高级草药学","Expert Herbalist")
		rs["大师级草药学"] = Check_Client("大师级草药学","Artisan Herbalist")
		rs["初级采矿"] = Check_Client("初级采矿","Apprentice Miner")
		rs["中级采矿"] = Check_Client("中级采矿","Journeyman Miner")
		rs["高级采矿"] = Check_Client("高级采矿","Expert Miner")
		rs["大师级采矿"] = Check_Client("大师级采矿","Artisan Miner")
        rs["血性狂怒"] = Check_Client("血性狂怒","Blood Fury")

		Hunter()
		Mage()
		Priest()
		Warrior()
		Warlock()
		Rogue()
		Paladin()
		Druid()
		Shaman()
	end
	Spell_Translate()

    Function_Load_In = false
    awm.RunMacroText("/console SET AutoInteract 1")

    local function Create_Basic_UI() -- 基础UI
		Basic_UI = {} -- 基础 UI table

		local function UI_Panel()
			Basic_UI.Main_Panel = CreateFrame("Frame","Basic_UI.Main_Panel",UIParent, BackdropTemplateMixin and "BackdropTemplate")
			Basic_UI.Main_Panel:SetPoint("Center")
			Basic_UI.Main_Panel:SetSize(800,600)
			Basic_UI.Main_Panel:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",
			edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
			title= true, 
			edgeSize =24, 
			titleSize = 24})
			Basic_UI.Main_Panel:SetBackdropColor(0.1,0.1,0.1,0.78)
			Basic_UI.Main_Panel:SetBackdropBorderColor(1,1,1,0.78)
			Basic_UI.Main_Panel:Hide()
			Basic_UI.Main_Panel:SetMovable(true)
			Basic_UI.Main_Panel:EnableMouse(true)
			Basic_UI.Main_Panel:RegisterForDrag("LeftButton")
			Basic_UI.Main_Panel:SetScript("OnDragStart",Basic_UI.Main_Panel.StartMoving)
			Basic_UI.Main_Panel:SetScript("OnDragStop", Basic_UI.Main_Panel.StopMovingOrSizing)
			Basic_UI.Main_Panel:SetFrameStrata('FULLSCREEN_DIALOG')


			local frameHeader = Basic_UI.Main_Panel:CreateTexture("$parentHeader", "ARTWORK")
			frameHeader:SetPoint("TOP", 0, 14)
			frameHeader:SetTexture(131080)
			frameHeader:SetSize(400, 68)

			local frameHeaderText = Basic_UI.Main_Panel:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormal")
			frameHeaderText:SetPoint("TOP", frameHeader, 0, -14)
            if ORCA then
				frameHeaderText:SetText("ORCA")
            else
				frameHeaderText:SetText(Check_UI("喵喵拳","MMQ"))
            end
		end

		local function Main_Panel() -- 主面板 滑轮控制
			Basic_UI.Scroll = CreateFrame("ScrollFrame", "ScrollFrame",Basic_UI.Main_Panel,"UIPanelScrollFrameTemplate")
			Basic_UI.Scroll:SetSize(750,510)
			Basic_UI.Scroll:SetPoint("TOPLEFT",10,-30)
			Basic_UI.Scroll:Show()
			Basic_UI.Scroll:SetFrameStrata('FULLSCREEN_DIALOG')

			Basic_UI.Panel = CreateFrame("Frame","MainFrame",Basic_UI.Scroll, BackdropTemplateMixin and "BackdropTemplate")
			Basic_UI.Panel:SetPoint("TOP")
			Basic_UI.Panel:SetSize(750,1500)
			Basic_UI.Panel:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",
			edgeFile="Interface/ChatFrame/ChatFrameBackground",
			title= true, 
			edgeSize =1, 
			titleSize = 5})
			Basic_UI.Panel:SetBackdropColor(0,0,0,0)
			Basic_UI.Panel:SetBackdropBorderColor(0.8,0.8,0.8,0)
			Basic_UI.Panel:Show()
			Basic_UI.Panel:SetFrameStrata('FULLSCREEN_DIALOG')
		
			Basic_UI.Scroll:SetScrollChild(Basic_UI.Panel)
		end

		local function Close_Basic_UI() -- 关闭UI
			Basic_UI.Close_Panel = Create_Button(Basic_UI.Main_Panel,"BottomRight",-10,10,color.white..Check_UI("关闭","Close"))
			Basic_UI.Close_Panel:SetSize(110,35)
			Basic_UI.Close_Panel:Show()
			Basic_UI.Close_Panel:SetScript("OnClick", function(self)
				Basic_UI.Main_Panel:Hide()
			end)
		end

        local function Reset_All_Config_Button() -- 还原设置 UI
			Basic_UI.Reset_UI = Create_Button(Basic_UI.Main_Panel,"BottomLeft",10,10,color.white..Check_UI("还原设置","Reset Configs"))
			Basic_UI.Reset_UI:SetSize(110,35)
			Basic_UI.Reset_UI:SetScript("OnClick", function(self)
				Easy_Data = {}
				Easy_Data.UI = Check_Client("CN","EN")
				textout(Check_UI("还原设置成功","Reset successful"))
			end)
		end

		local function Top_Part() -- 顶侧选项面板
			Basic_UI["选项列表"] = CreateFrame('frame',"Chocies",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
			Basic_UI["选项列表"]:SetPoint("TopLeft",5,0)
			Basic_UI["选项列表"]:SetSize(140,1500)
			Basic_UI["选项列表"]:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
			Basic_UI["选项列表"]:SetBackdropColor(0.1,0.1,0.1,0)
			Basic_UI["选项列表"]:SetFrameStrata('TOOLTIP')
		end

		UI_Panel()
		Main_Panel()
		Close_Basic_UI()
		Top_Part()
		Reset_All_Config_Button()
	end

	local function Create_Top_UI()
		Top_UI = {}

		local function UI_Panel()
			Top_UI.Main_Panel = CreateFrame("Frame","Top_UI.Main_Panel",UIParent, BackdropTemplateMixin and "BackdropTemplate")
			Top_UI.Main_Panel:SetPoint("BottomRight",-30, 350)
			Top_UI.Main_Panel:SetSize(250,300)
			Top_UI.Main_Panel:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",
			edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
			title= true, 
			edgeSize =20, 
			titleSize = 16})
			Top_UI.Main_Panel:SetBackdropColor(0.1,0.1,0.1,0.5)
			Top_UI.Main_Panel:SetBackdropBorderColor(1,1,1,0.7)
			Top_UI.Main_Panel:Show()
			Top_UI.Main_Panel:SetMovable(true)
			Top_UI.Main_Panel:EnableMouse(true)
			Top_UI.Main_Panel:RegisterForDrag("LeftButton")
			Top_UI.Main_Panel:SetScript("OnDragStart",Top_UI.Main_Panel.StartMoving)
			Top_UI.Main_Panel:SetScript("OnDragStop", Top_UI.Main_Panel.StopMovingOrSizing)
			Top_UI.Main_Panel:SetFrameStrata('FULLSCREEN_DIALOG')


			local frameHeader = Top_UI.Main_Panel:CreateTexture("$parentHeader", "ARTWORK")
			frameHeader:SetPoint("TOP", 0, 14)
			frameHeader:SetTexture(131080)
			frameHeader:SetSize(250, 68)

			local frameHeaderText = Top_UI.Main_Panel:CreateFontString("$parentHeaderText", "ARTWORK", "GameFontNormalSmall")
			frameHeaderText:SetPoint("TOP", frameHeader, 0, -14)

            if ORCA then
				frameHeaderText:SetText("|CFFFFFFFF".."ORCA")
            else
				frameHeaderText:SetText("|CFFFFFFFF"..Check_UI("喵喵拳","MMQ"))
            end
		end

		local function Open_Basic_UI()
			Top_UI.Open_Panel = Create_Button(Top_UI.Main_Panel,"TopLeft",20,-30,color.white..Check_UI("设置","Config"))
			Top_UI.Open_Panel:SetSize(95,25)
			Top_UI.Open_Panel:SetScript("OnClick", function(self)
				if Basic_UI.Main_Panel:IsVisible() then
					Basic_UI.Main_Panel:Hide()
				else
					Basic_UI.Main_Panel:Show()
				end
			end)
		end

        local function Reload_Button_UI()
			Top_UI.Config_Button = Create_Button(Top_UI.Main_Panel,"TopLeft",140,-30,color.white..Check_UI("重新加载","Reload"))
			Top_UI.Config_Button:SetSize(95,25)
			Top_UI.Config_Button:SetScript("OnClick", function(self)

				awm.RunMacroText("/reload")
			end)
		end

		local function Start_Pause_Button()
			Top_UI.Start_Button = Create_Button(Top_UI.Main_Panel,"TopLeft",20,-60,color.white..Check_UI("启动","Start"))
			Top_UI.Start_Button:SetSize(95,25)
			Top_UI.Start_Button:SetScript("OnClick", function(self)
				if Function_Load_In == nil or not Function_Load_In then
					textout(Check_UI("请先选择需要启动的功能","Please choose one function first"))
					return
				end
				Bot_Begin()
			end)

			Top_UI.Pause_Button = Create_Button(Top_UI.Main_Panel,"TopLeft",140,-60,color.white..Check_UI("停止","Stop"))
			Top_UI.Pause_Button:SetSize(95,25)
			Top_UI.Pause_Button:SetScript("OnClick", function(self)
				if Function_Load_In == nil or not Function_Load_In then
					textout(Check_UI("请先选择需要启动的功能","Please choose one function first"))
					return
				end
				Bot_End()
			end)
		end

		local function FPS_Ping_UI()
			Top_UI.FPS = Create_Header(Top_UI.Main_Panel,"TopLeft",20,-90,color.white..Check_UI("帧数","FPS").." = "..math.floor(GetFramerate()))

			Top_UI.Ping = Create_Header(Top_UI.Main_Panel,"TopLeft",140,-90,color.white..Check_UI("延迟","Latency").." = ")

			local FPS_Frame = CreateFrame("frame")
			FPS_Frame:SetScript("OnUpdate",
			function() 
			local rate = nil
			rate = math.floor(GetFramerate())
			if rate == nil then
				return
			end
			Top_UI.FPS:SetText("|CFFFFFFFF"..Check_UI("帧数","FPS").." = "..rate)
			local _,_,_,ping = GetNetStats()
			if ping == nil then
				return
			end
			Top_UI.Ping:SetText("|CFFFFFFFF"..Check_UI("延迟","Latency").." = "..math.floor(ping))
			end)
		end

        local function Close_UI()
			Top_UI.Close_Button = Create_Button(Top_UI.Main_Panel,"BottomLeft",20,10,color.white..Check_UI("关闭","Close"))
			Top_UI.Close_Button:SetSize(95,25)
			Top_UI.Close_Button:SetScript("OnClick", function(self)
				Top_UI.Main_Panel:Hide()
                textout(Check_UI("输入 /ewp 再次显示界面","Command /ewp to show the Panel"))
			end)
		end

        local function UI_Shift()
			Top_UI.Close_Button = Create_Button(Top_UI.Main_Panel,"BottomLeft",140,10,color.white..Check_UI("English UI","中文界面"))
			Top_UI.Close_Button:SetSize(95,25)
			Top_UI.Close_Button:SetScript("OnClick", function(self)
                if Easy_Data.UI and Easy_Data.UI == "EN" then
			        Easy_Data.UI = "CN"
					awm.RunMacroText("/reload")
		        elseif Easy_Data.UI and Easy_Data.UI == "CN" then
			        Easy_Data.UI = "EN"
					awm.RunMacroText("/reload")
		        end
			end)
		end

		UI_Panel()
		Open_Basic_UI()

		Start_Pause_Button()
		Reload_Button_UI()
		FPS_Ping_UI()
        Close_UI()
        UI_Shift()
	end

	local function Create_Detail_UI()
		Detail_UI = {}
		Detail_UI.Py = -10

		local function Main_Panel() -- 主面板 滑轮控制
			Detail_UI.Scroll = CreateFrame("ScrollFrame", "ScrollFrame",Top_UI.Main_Panel,"UIPanelScrollFrameTemplate")
			Detail_UI.Scroll:SetSize(200,150)
			Detail_UI.Scroll:SetPoint("TOPLEFT",10,-110)
			Detail_UI.Scroll:Show()
			Detail_UI.Scroll:SetFrameStrata('FULLSCREEN_DIALOG')

			Detail_UI.Panel = CreateFrame("Frame","MainFrame",Detail_UI.Scroll, BackdropTemplateMixin and "BackdropTemplate")
			Detail_UI.Panel:SetPoint("TOP")
			Detail_UI.Panel:SetSize(200,500)
			Detail_UI.Panel:SetBackdrop({bgFile="Interface/ChatFrame/ChatFrameBackground",
			edgeFile="Interface/ChatFrame/ChatFrameBackground",
			title= true, 
			edgeSize =1, 
			titleSize = 5})
			Detail_UI.Panel:SetBackdropColor(0,0,0,0)
			Detail_UI.Panel:SetBackdropBorderColor(0.8,0.8,0.8,0)
			Detail_UI.Panel:Show()
			Detail_UI.Panel:SetFrameStrata('FULLSCREEN_DIALOG')
		
			Detail_UI.Scroll:SetScrollChild(Detail_UI.Panel)
		end

		Main_Panel()
	end


    function Load_Function()
        if Easy_Data.Function_Choose ~= nil then
	        if not Function_Load_In then
		        local Download_File = ""
			    if Easy_Data.Function_Choose == "双采练习" then
			        Download_File = "EP_Herb_Mine.lua"
			    elseif Easy_Data.Function_Choose == "剥皮练习" then
			        Download_File = "EP_Skin.lua"
			    elseif Easy_Data.Function_Choose == "开锁练习" then
			        Download_File = "EP_Chest.lua"
			    elseif Easy_Data.Function_Choose == "围栏法师" then
			        Download_File = "SP.lua"
                elseif Easy_Data.Function_Choose == "围栏小号" then
			        Download_File = "Alt_SP.lua"
                elseif Easy_Data.Function_Choose == "野外升级" then
			        Download_File = "Level_Profile.lua"
                elseif Easy_Data.Function_Choose == "野外采集" then
			        Download_File = "OP_Gather.lua"
                elseif Easy_Data.Function_Choose == "野外打怪" then
			        Download_File = "OP_Mobs.lua"
                elseif Easy_Data.Function_Choose == "野外冰枪" then
			        Download_File = "OP_DingDian.lua"
                elseif Easy_Data.Function_Choose == "记录插件" then
			        Download_File = "Profile_Genertor.lua"
                elseif Easy_Data.Function_Choose == "蒸汽盗贼" then
                    Download_File = "SteamVault.lua"
                elseif Easy_Data.Function_Choose == "祖格法师" then
                    Download_File = "ZUG.lua"
                elseif Easy_Data.Function_Choose == "监狱法师" then
                    Download_File = "JY.lua"
                elseif Easy_Data.Function_Choose == "监狱小号" then
                    Download_File = "Alt_JY.lua"
                elseif Easy_Data.Function_Choose == "影牙法师" then
                    Download_File = "YY.lua"
                elseif Easy_Data.Function_Choose == "影牙小号" then
                    Download_File = "Alt_YY.lua"
                elseif Easy_Data.Function_Choose == "血色法师" then
                    Download_File = "XS.lua"
                elseif Easy_Data.Function_Choose == "血色小号" then
                    Download_File = "Alt_XS.lua"
                elseif Easy_Data.Function_Choose == "血色XQ小号" then
                    Download_File = "Alt_XS_XQ.lua"
                elseif Easy_Data.Function_Choose == "玛拉顿法师" then
                    Download_File = "MLD.lua"
                elseif Easy_Data.Function_Choose == "玛拉顿小号" then
                    Download_File = "Alt_MLD.lua"
                elseif Easy_Data.Function_Choose == "斯坦索姆法师" then
                    Download_File = "STSM.lua"
                elseif Easy_Data.Function_Choose == "斯坦索姆小号" then
                    Download_File = "Alt_STSM.lua"
                elseif Easy_Data.Function_Choose == "城墙五人升级" then
                    Download_File = "Hell_Fire_Leveling.lua"
                    elseif Easy_Data.Function_Choose == "城墙五人产金" then
                    Download_File = "Hell_Fire_Profit.lua"


                elseif Easy_Data.Function_Choose == "XT打怪" then
                    Download_File = "XT_Mobs.lua"
                elseif Easy_Data.Function_Choose == "XT采集" then
                    Download_File = "XT_Gather.lua"
                elseif Easy_Data.Function_Choose == "XT旧世界采集" then
                    Download_File = "XT_MobsDQ.lua"
                elseif Easy_Data.Function_Choose == "XT测试" then
                    Download_File = "XT_CS.lua"
                elseif Easy_Data.Function_Choose == "XT螃蟹" then
                    Download_File = "XT_pangxie.lua"
                elseif Easy_Data.Function_Choose == "XT宝箱" then
                    Download_File = "XT_PP.lua"
                elseif Easy_Data.Function_Choose == "XT专业" then
                    Download_File = "XT_Professions.lua"
                elseif Easy_Data.Function_Choose == "XT飞行打野" then
                    Download_File = "XT_FlyMobs.lua"


                elseif Easy_Data.Function_Choose == "XQ斯坦索姆" then
                    Download_File = "XQ_STSM.lua"
                elseif Easy_Data.Function_Choose == "XQ玛拉顿" then
                    Download_File = "XQ_MLD.lua"
                elseif Easy_Data.Function_Choose == "XQ超级围栏" then
                    Download_File = "XQ_DFCJNLWL.lua"
                elseif Easy_Data.Function_Choose == "XQ双法迷宫" then
                    Download_File = "XQ_SFAYMG.lua"
                elseif Easy_Data.Function_Choose == "XQ双法生态" then
                    Download_File = "XQ_SFSTC.lua"
                elseif Easy_Data.Function_Choose == "XQ双法熔炉" then
                    Download_File = "XQ_SFXXRL.lua"
                elseif Easy_Data.Function_Choose == "XQ血色双门" then
                    Download_File = "XQ_XSSM.lua"
                elseif Easy_Data.Function_Choose == "XQ黑下" then
                    Download_File = "XQ_DFHSTXC.lua"
                elseif Easy_Data.Function_Choose == "XQ蒸汽盗贼" then
                    Download_File = "XQ_DZZQDK.lua"
                elseif Easy_Data.Function_Choose == "XQ圣骑士STSM" then
                    Download_File = "XQ_QSSTSM.lua"
                elseif Easy_Data.Function_Choose == "XQ测试" then
                    Download_File = "XQTEST.lua"
			    else
			        textout(Check_UI("请先选择需要加载的功能","Please choose a function first before load from sever"))
				    return
			    end
			    if Download_File ~= "" then
                    local function callback(response, status)
                        if status == 200 then
                            if not string.find(response,"Function_Load_In") and not string.find(response,"LoadPlugin") and not string.find(Download_File,"XQ") and not string.find(Download_File,"XT") then
                                LoadPlugin(response)
                            else
                                LoadString(response)()
                            end
                            textout(Check_UI("功能连接成功","Function status update"))
                        else
                            textout(Check_UI("文件下载失败: ","Error downloading file: ") .. status)
                        end
                    end
                    if Download_File == "XT_Gather.lua" 
                        or Download_File == "XT_Mobs.lua" 
                        or Download_File == "XT_MobsDQ.lua" 
                        or Download_File == "XT_CS.lua"
                        or Download_File == "XT_pangxie.lua"
                        or Download_File == "XT_Professions.lua"
                        or Download_File == "XT_FlyMobs.lua"
                        or Download_File == "XT_PP.lua" then
                            local time = GetServerTime()
				            local key = tostring((time - 321).."gbk"..Str2Hex(GetRealmName()..UnitFullName("player")).."lgJiBGLJnV9eTLmmpbLd5OwPJmuvJOnR")
				            local Data_Add = "CoCo"..time.."CoCo"..Str2Hex(GetRealmName()..UnitFullName("player"))
				            local data1 = Download_File
				            local data2 = DF_RC4(key,data1)
				            local data3 = DF_Base64.encode(data2)
				            local data = Str2Hex(data3)

                            SetHttpMode(false)

                            -- 23.224.77.242

                            awm.InternetRequestAsync("GET", "xt.shwow.site/HttpApiUt.ashx?action=DownloadFile&data="..data..Data_Add, "", "",callback)
                    elseif Download_File == "XQ_STSM.lua" 
                        or Download_File == "XQ_DFCJNLWL.lua" 
                        or Download_File == "XQ_MLD.lua"
                        or Download_File == "XQ_SFAYMG.lua"
                        or Download_File == "XQ_XSSM.lua" 
                        or Download_File == "XQTEST.lua"
                        or Download_File == "XQ_DFHSTXC.lua"
                        or Download_File == "XQ_SFXXRL.lua"
                        or Download_File == "XQ_DZZQDK.lua"
                        or Download_File == "XQ_QSSTSM.lua"
                        or Download_File == "XQ_SFSTC.lua" then
                            local time = GetServerTime()
				            local key = tostring((time - 321).."gbk"..Str2Hex(GetRealmName()..UnitFullName("player")).."lgJiBGLJnV9eTLmmpbLd5OwPJmuvJOnR")
				            local Data_Add = "CoCo"..time.."CoCo"..Str2Hex(GetRealmName()..UnitFullName("player"))
				            local data1 = Download_File
				            local data2 = DF_RC4(key,data1)
				            local data3 = DF_Base64.encode(data2)
				            local data = Str2Hex(data3)

                            SetHttpMode(false)

                            -- 23.224.140.117

                            awm.InternetRequestAsync("GET", "xq.shwow.site/HttpApiUt.ashx?action=DownloadFile&data="..data..Data_Add, "", "",callback)
                    else
                        awm.InternetRequestAsync("GET", "moptool.com/secret/"..Download_File, "", "",callback)
                    end
			    end
		    end
	    else
	        textout(Check_UI("请先选择需要加载的功能","Please choose a function first before load from sever"))
	    end
    end

	function All_Buttons_Hide()
		for i = 1,#Config_UI do
			Config_UI[i]()
		end
	end
	local function Create_Whisper_UI() -- 密语回复
		Basic_UI.Whisper = {}
		Basic_UI.Whisper.Py = -10
		local function Frame_Create()
			Basic_UI.Whisper.frame = CreateFrame('frame',"Basic_UI.Whisper.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
			Basic_UI.Whisper.frame:SetPoint("TopLeft",150,0)
			Basic_UI.Whisper.frame:SetSize(600,1500)
			Basic_UI.Whisper.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
			Basic_UI.Whisper.frame:SetBackdropColor(0.1,0.1,0.1,0)
			Basic_UI.Whisper.frame:Hide()
			Basic_UI.Whisper.frame:SetFrameStrata('TOOLTIP')
		end

		local function Button_Create()
			Basic_UI.Whisper.button = Create_Page_Button(Basic_UI["选项列表"],"Top",0,UI_Button_Py,Check_UI("密语回复","whisper"))
			Basic_UI.Whisper.button:SetSize(130,20)
			Basic_UI.Whisper.button:SetScript("OnClick", function(self)
				All_Buttons_Hide()
				Basic_UI.Whisper.frame:Show()
				Basic_UI.Whisper.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
			end)
			Config_UI[#Config_UI + 1] = function() Basic_UI.Whisper.frame:Hide() Basic_UI.Whisper.button:SetBackdropColor(0,0,0,0) end
		end

		local function Whisper() --密语选项

			Basic_UI.Whisper["密语回复"] = Create_Check_Button(Basic_UI.Whisper.frame,"TOPLEFT",10, Basic_UI.Whisper.Py,Check_UI("密语回复","Whisper reply"))
			Basic_UI.Whisper["密语回复"]:SetScript("OnClick", function(self)
				if Basic_UI.Whisper["密语回复"]:GetChecked() then
					Easy_Data["密语回复"] = true
					textout(Check_UI("启用密语回复","Enable whisper reply"))
				elseif not Basic_UI.Whisper["密语回复"]:GetChecked() then
					Easy_Data["密语回复"] = false
					textout(Check_UI("停止密语回复","Disable whisper reply"))
				end
			end)	
			if Easy_Data["密语回复"] ~= nil then
				if Easy_Data["密语回复"] then
					Basic_UI.Whisper["密语回复"]:SetChecked(true)
				else
					Basic_UI.Whisper["密语回复"]:SetChecked(false)
				end
			else
				Easy_Data["密语回复"] = false
				Basic_UI.Whisper["密语回复"]:SetChecked(false)
			end

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header1 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复延时(秒)","Delay whisper reply(sec)"))

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper["密语回复延时"] = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,"5",false,570,24)
			Basic_UI.Whisper["密语回复延时"]:SetScript("OnEditFocusLost", function(self)
				Easy_Data["密语回复延时"] = Basic_UI.Whisper["密语回复延时"]:GetText()
				textout(Check_UI("密语回复延时 - "..Easy_Data["密语回复延时"].."秒","Delay whisper reply rewrite to = "..Easy_Data["密语回复延时"].." second"))
			end)
			if Easy_Data["密语回复延时"] == nil then
				Easy_Data["密语回复延时"] = tonumber(Basic_UI.Whisper["密语回复延时"]:GetText())
			else
				Basic_UI.Whisper["密语回复延时"]:SetText(Easy_Data["密语回复延时"])
			end
			-----------------------------------------------------------------------------

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header1 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复 - 1","Whisper reply - 1"))
        
			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper.whisper_1 = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,Check_UI("请不要打扰我","Don't bother me"),false,570,24)
			Basic_UI.Whisper.whisper_1:SetScript("OnEditFocusLost", function(self)
				Easy_Data.whisper_1 = Basic_UI.Whisper.whisper_1:GetText()
				textout(Check_UI("密语回复1 = "..Easy_Data.whisper_1,"Whisper reply 1 save = "..Easy_Data.whisper_1))
			end)
			if Easy_Data.whisper_1 == nil then
				Easy_Data.whisper_1 = Check_UI("请不要打扰我","Don't bother me")
			else
				Basic_UI.Whisper.whisper_1:SetText(Easy_Data.whisper_1)
			end
			-----------------------------------------------------------------------------

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header2 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复 - 2","Whisper reply - 2"))
        
			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper.whisper_2 = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,Check_UI("我对你没兴趣","fuck away from me"),false,570,24)
			Basic_UI.Whisper.whisper_2:SetScript("OnEditFocusLost", function(self)
				Easy_Data.whisper_2 = Basic_UI.Whisper.whisper_2:GetText()
				textout(Check_UI("密语回复2 = "..Easy_Data.whisper_2,"Whisper reply 2 save = "..Easy_Data.whisper_2))
			end)
			if Easy_Data.whisper_2 == nil then
				Easy_Data.whisper_2 = Check_UI("我对你没兴趣","fuck away from me")
			else
				Basic_UI.Whisper.whisper_2:SetText(Easy_Data.whisper_2)
			end
			-----------------------------------------------------------------------------

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header3 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复 - 3","Whisper reply - 3"))
        
			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper.whisper_3 = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,Check_UI("请你离我远点, 别给我发消息了","don't message me, i am not interested with you"),false,570,24)
			Basic_UI.Whisper.whisper_3:SetScript("OnEditFocusLost", function(self)
				Easy_Data.whisper_3 = Basic_UI.Whisper.whisper_3:GetText()
				textout(Check_UI("密语回复3 = "..Easy_Data.whisper_3,"Whisper reply 3 save = "..Easy_Data.whisper_3))
			end)
			if Easy_Data.whisper_3 == nil then
				Easy_Data.whisper_3 = Check_UI("请你离我远点, 别给我发消息了","don't message me, i am not interested with you")
			else
				Basic_UI.Whisper.whisper_3:SetText(Easy_Data.whisper_3)
			end
			-----------------------------------------------------------------------------

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header4 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复 - 4","Whisper reply - 4"))
        
			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper.whisper_4 = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,Check_UI("没空","busy now"),false,570,24)
			Basic_UI.Whisper.whisper_4:SetScript("OnEditFocusLost", function(self)
				Easy_Data.whisper_4 = Basic_UI.Whisper.whisper_4:GetText()
				textout(Check_UI("密语回复4 = "..Easy_Data.whisper_4,"Whisper reply 4 save = "..Easy_Data.whisper_4))
			end)
			if Easy_Data.whisper_4 == nil then
				Easy_Data.whisper_4 = Check_UI("没空","busy now")
			else
				Basic_UI.Whisper.whisper_4:SetText(Easy_Data.whisper_4)
			end
			-----------------------------------------------------------------------------

			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 30
			local Header5 = Create_Header(Basic_UI.Whisper.frame,"TOPLeft", 10, Basic_UI.Whisper.Py,Check_UI("密语回复 - 5","Whisper reply - 5"))
        
			Basic_UI.Whisper.Py = Basic_UI.Whisper.Py - 20

			Basic_UI.Whisper.whisper_5 = Create_EditBox(Basic_UI.Whisper.frame,"TopLeft", 10, Basic_UI.Whisper.Py,Check_UI("满人了","no free position for you"),false,570,24)
			Basic_UI.Whisper.whisper_5:SetScript("OnEditFocusLost", function(self)
				Easy_Data.whisper_5 = Basic_UI.Whisper.whisper_5:GetText()
				textout(Check_UI("密语回复5 = "..Easy_Data.whisper_5,"Whisper reply 5 save = "..Easy_Data.whisper_5))
			end)
			if Easy_Data.whisper_5 == nil then
				Easy_Data.whisper_5 = Check_UI("满人了","no free position for you")
			else
				Basic_UI.Whisper.whisper_5:SetText(Easy_Data.whisper_5)
			end
		end

		Frame_Create()
		Button_Create()
		Whisper()
	end
	local function Create_Function_UI() -- 功能设置
        Basic_UI.Function = {}
		Basic_UI.Function.Py = -10
		local function Frame_Create()
			Basic_UI.Function.frame = CreateFrame('frame',"Basic_UI.Function.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
			Basic_UI.Function.frame:SetPoint("TopLeft",150,0)
			Basic_UI.Function.frame:SetSize(600,1500)
			Basic_UI.Function.frame:SetBackdrop({_,edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",_,_,edgeSize = 15,_})
			Basic_UI.Function.frame:SetBackdropColor(0.1,0.1,0.1,0)
			Basic_UI.Function.frame:Hide()
			Basic_UI.Function.frame:SetFrameStrata('FULLSCREEN_DIALOG')
		end

		local function Button_Create()
            UI_Button_Py = UI_Button_Py - 30

			Basic_UI.Function.button = Create_Page_Button(Basic_UI["选项列表"],"Top",0,UI_Button_Py,Check_UI("功能选择","function list"))
			Basic_UI.Function.button:SetSize(130,20)
			Basic_UI.Function.button:SetScript("OnClick", function(self)
				All_Buttons_Hide()
				Basic_UI.Function.frame:Show()
				Basic_UI.Function.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
			end)
			Config_UI[#Config_UI + 1] = function() Basic_UI.Function.frame:Hide() Basic_UI.Function.button:SetBackdropColor(0,0,0,0) end
		end

		local function Main_Function()
            local text = Create_Header(Basic_UI.Function.frame,"TOPLeft", 10, Basic_UI.Function.Py,Check_UI("基础版","Basic functions"))

            Basic_UI.Function.Py = Basic_UI.Function.Py - 30

			Function_Drop = CreateFrame("frame",nil, Basic_UI.Function.frame, "UIDropDownMenuTemplate")
			Function_Drop:SetPoint("TOPLeft",10,Basic_UI.Function.Py)

            Function_Drop:SetFrameStrata('TOOLTIP')

			UIDropDownMenu_SetWidth(Function_Drop, 400)
			if Easy_Data.Function_Choose == nil then
				UIDropDownMenu_SetText(Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
			else
				UIDropDownMenu_SetText(Function_Drop, Easy_Data.Function_Choose)
			end
			UIDropDownMenu_Initialize(Function_Drop, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				info.func = Function_Drop_OnClick
				info.text, info.arg1 = Check_UI("无","Null"), nil
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[副职业] 野外双采 1 - 375 练习","[Professions Practice] Mining/Herbalism 1 - 375"), "双采练习"
				UIDropDownMenu_AddButton(info)

				info.text, info.arg1 = Check_UI("[副职业] 野外剥皮 1 - 375 练习","[Professions Practice] Skining 1 - 375"), "剥皮练习"
				UIDropDownMenu_AddButton(info)

				info.text, info.arg1 = Check_UI("[副职业] 野外开锁 1 - 350 练习","[Professions Practice] Lockpicking 1 - 350"), "开锁练习"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[野外] 1 - 70 升级","[Open World] 1 - 70 Leveling"), "野外升级"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[野外] 自定义 + 内置路径 双采 + 吸气","[Open World] Custom + Fixed Path Mining / Herbalism + Mote"), "野外采集"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[野外] 自定义 + 内置路径 打怪","[Open World] Custom + Fixed Path Mobs Farm"), "野外打怪"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[野外] 法师自定义定点冰枪术(螃蟹 + 狼人)","[Open World] Custom Mage Fixed Point Mobs Farm"), "野外冰枪"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[野外] 自定义坐标生成","[Open World] Profile Generator"), "记录插件"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[围栏] 单法 AOE 双采 开箱 (不支持人类女和亡灵女)","[Slave Pens] Solo Mage AOE, Chest, Mining, Herbalism Farm (Not support human and undead female)"), "围栏法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[围栏] 小号自动跟随进出副本","[Slave Pens] Alts auto go in/out dungeon, fully afk"), "围栏小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[蒸汽地窟] 盗贼 双采 吸气 开箱","[SteamVault] Rouge Mining, Herbalism, Chest, Mote Farm"), "蒸汽盗贼"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[祖尔格拉布] 36/30/16只 鳄鱼 无飞天","[Zul'Gurub] 36/30/16 Mobs AOE Pull"), "祖格法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[监狱] 法师 大带小","[Stockade] Mage AOE Pull"), "监狱法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[监狱] 小号自动跟随进出副本","[Stockade] Alts auto go in/out dungeon, fully afk"), "监狱小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[影牙] 法师 大带小","[Shadowfang Keep] Mage AOE Pull"), "影牙法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[影牙] 小号自动跟随进出副本","[Shadowfang Keep] Alts auto go in/out dungeon, fully afk"), "影牙小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[血色] 法师 大带小 单门教堂","[Scarlet Monastery] Mage AOE Pull"), "血色法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[血色] 小号自动跟随进出副本","[Scarlet Monastery] Alts auto go in/out dungeon, fully afk"), "血色小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[血色] 小号自动跟随进出副本 - XQ 兼容版本","[Scarlet Monastery] Alts auto go in/out dungeon, fully afk - XQ Version"), "血色XQ小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[玛拉顿] 法师 双门","[Mara] Mage AOE Pull 160+"), "玛拉顿法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[玛拉顿] 小号自动跟随进出副本","[Mara] Alts auto go in/out dungeon, fully afk"), "玛拉顿小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[斯坦索姆] 法师 四波流","[Stratholme] Mage AOE Pull 160 - 190"), "斯坦索姆法师"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[斯坦索姆] 小号自动跟随进出副本","[Stratholme] Alts auto go in/out dungeon, fully afk"), "斯坦索姆小号"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[五人副本] 地狱火城墙 58 - 70 升级 (1坦, 3输出, 1治疗)","[5-man Dungeon] Hellfire Ramparts 58 - 70 Leveling (1 tank, 3 DPS, 1 healer)"), "城墙五人升级"
                UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("[五人副本] 地狱火城墙 70 产金 (1坦, 3输出, 1治疗)","[5-man Dungeon] Hellfire Ramparts 70 Profit (1 tank, 3 DPS, 1 healer)"), "城墙五人产金"
				UIDropDownMenu_AddButton(info)
			end)

			function Function_Drop_OnClick(self, arg1, arg2, checked)
				if arg1 == 0 then
					Easy_Data.Function_Choose = nil
					UIDropDownMenu_SetText(Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
				else
                    Easy_Data.Function_Choose = arg1
                    UIDropDownMenu_SetText(Function_Drop, arg1)
				end

                if Easy_Data.Function_Choose ~= nil and not Function_Load_In then
                    Load_Function()
                end
			end
            Basic_UI.Function.Py = Basic_UI.Function.Py - 70
		end

        local function XT_Function()
            local text = Create_Header(Basic_UI.Function.frame,"TOPLeft", 10, Basic_UI.Function.Py,Check_UI("XT 野外授权 (需要额外购买 XT 卡密)","XT Open World Functions (Paid Profiles)"))

            Basic_UI.Function.Py = Basic_UI.Function.Py - 30

			XT_Function_Drop = CreateFrame("frame",nil, Basic_UI.Function.frame, "UIDropDownMenuTemplate")
			XT_Function_Drop:SetPoint("TOPLeft",10,Basic_UI.Function.Py)

            XT_Function_Drop:SetFrameStrata('TOOLTIP')

			UIDropDownMenu_SetWidth(XT_Function_Drop, 400)
			if Easy_Data.Function_Choose == nil then
				UIDropDownMenu_SetText(XT_Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
			else
				UIDropDownMenu_SetText(XT_Function_Drop, Easy_Data.Function_Choose)
			end
			UIDropDownMenu_Initialize(XT_Function_Drop, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				info.func = XT_Drop
				info.text, info.arg1 = Check_UI("无","Null"), nil
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 野外 双采 + 吸气 (全路径授权)","Not Support English Client"), "XT采集"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 野外 打怪 (全路径授权)","Not Support English Client"), "XT打怪"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 旧世界双采(全路径授权)","Not Support English Client"), "XT旧世界采集"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 自动开氪金宝箱,BL全种族学坐骑, 萨布拉金炉石点","Not Support English Client"), "XT宝箱"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 1 - 20 大带小刷怪","Not Support English Client"), "XT螃蟹"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 自动练附魔 溶矿 工程","Not Support English Client"), "XT专业"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 飞行坐骑打野","Not Support English Client"), "XT飞行打野"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XT 作者测试使用 请勿选择","Not Support English Client"), "XT测试"
				UIDropDownMenu_AddButton(info)
			end)

			function XT_Drop(self, arg1, arg2, checked)
				if arg1 == 0 then
					Easy_Data.Function_Choose = nil
					UIDropDownMenu_SetText(XT_Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
				else
                    Easy_Data.Function_Choose = arg1
                    UIDropDownMenu_SetText(XT_Function_Drop, arg1)
				end

                if Easy_Data.Function_Choose ~= nil and not Function_Load_In then
                    Load_Function()
                end
			end

            Basic_UI.Function.Py = Basic_UI.Function.Py - 70
		end

        local function XQ_Function()
            local text = Create_Header(Basic_UI.Function.frame,"TOPLeft", 10, Basic_UI.Function.Py,Check_UI("XQ 副本授权 (需要额外购买 XQ 卡密)","XQ Dungeon Profiles (Paid Profiles)"))

            Basic_UI.Function.Py = Basic_UI.Function.Py - 30

			XQ_Function_Drop = CreateFrame("frame",nil, Basic_UI.Function.frame, "UIDropDownMenuTemplate")
			XQ_Function_Drop:SetPoint("TOPLeft",10,Basic_UI.Function.Py)

            XQ_Function_Drop:SetFrameStrata('TOOLTIP')

			UIDropDownMenu_SetWidth(XQ_Function_Drop, 400)
			if Easy_Data.Function_Choose == nil then
				UIDropDownMenu_SetText(XQ_Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
			else
				UIDropDownMenu_SetText(XQ_Function_Drop, Easy_Data.Function_Choose)
			end
			UIDropDownMenu_Initialize(XQ_Function_Drop, function(self, level, menuList)
				local info = UIDropDownMenu_CreateInfo()
				info.func = XQ_Drop
				info.text, info.arg1 = Check_UI("无","Null"), nil
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 法师 斯坦索姆 三波流 (100 G/小时)","XQ Mage Stsm 190+ AOE Pull (100 GPH)"), "XQ斯坦索姆"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 法师 玛拉顿双门 (70 G/小时)","XQ Mage Mara 160+ AOE Pull (70 GPH)"), "XQ玛拉顿"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 法师 超级奴隶围栏一波流 95+ 怪 (120 G/小时)","XQ Mage Slave Pens 95+ Mobs AOE Super Pull (120 GPH)"), "XQ超级围栏"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 双法 暗影迷宫 (250 G/小时)","XQ Dual Mage Shadow Labyrinth (250 GPH)"), "XQ双法迷宫"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 单法 血色双门一波流","XQ Mage Solo Scarlet Monastery + Armory"), "XQ血色双门"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 单法 黑石塔下层蜘蛛+人形精英 (80 G/小时)","XQ Mage Solo Blackrock Spire Spider's +  Elite Mobs (80 GPH)"), "XQ黑下"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 双法 生态船 (250 G/小时)","XQ Dual Mage The Botanica (250 GPH)"), "XQ双法生态"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 双法 鲜血熔炉 100 + 怪物 (安全升级副本)","XQ Dual Mage The Blood Furnace 100 Mobs+ (Safe leveling dungeon)"), "XQ双法熔炉"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 盗贼 蒸汽地窟 采矿 + 采药 + 吸水 + 宝箱 + 偷钱一条龙","XQ SteamVault rogue mining + herbing + chest + mote collect + pickpocket"), "XQ蒸汽盗贼"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 圣骑士 斯坦索姆 (需要巨人雕像)","XQ Paladin Stsm"), "XQ圣骑士STSM"
				UIDropDownMenu_AddButton(info)

                info.text, info.arg1 = Check_UI("XQ 作者测试使用","XQ Dev Test"), "XQ测试"
				UIDropDownMenu_AddButton(info)
			end)

			function XQ_Drop(self, arg1, arg2, checked)
				if arg1 == 0 then
					Easy_Data.Function_Choose = nil
					UIDropDownMenu_SetText(XQ_Function_Drop, Check_UI("选个功能嘛","CHOOSE A FUNCTION"))
				else
                    Easy_Data.Function_Choose = arg1
                    UIDropDownMenu_SetText(XQ_Function_Drop, arg1)
				end

                if Easy_Data.Function_Choose ~= nil and not Function_Load_In then
                    Load_Function()
                end
			end

            Basic_UI.Function.Py = Basic_UI.Function.Py - 70
		end

        Frame_Create()
        Button_Create()

        if not ORCA then
			Main_Function()
        end

        XT_Function()
        XQ_Function()
	end
	Create_Basic_UI()
	Create_Top_UI()
   
    Create_Detail_UI()
	Create_Whisper_UI()
	Create_Function_UI()

    if Easy_Data.Function_Choose then
		Load_Function()
    end

textout(Check_UI("UI 版本 = "..UI_Version.." 加载完成 (*≧m≦*)","UI Version = "..UI_Version.." Load Success (*≧m≦*)"))

if not ORCA then
    textout(Check_UI("下载更新地址 = https://download.moptool.com/#s/7qPtAsiA","Download site = https://download.moptool.com/#s/7qPtAsiA"))
end

print(Check_UI("<关于封号> 三方程序 + 准确时间 = 举报封号",""))
print(Check_UI("<关于封号> 数据异常 = 挂机时间, 地点, 拾取数量 等等因素 触发自动封号条件",""))
print(Check_UI("<关于封号> 三方程序 (只有日期 无 时分秒) = 考虑机器码永久封禁或者脚本被检测",""))

SlashCmdList['Top_UI'] = function()
    Top_UI.Main_Panel:Show()
end
SLASH_Top_UI1 = '/ewp'

local function Sever_Navigation()
    Sever_Map = {}

    local map = {}

    local function Initial()
        -- 卡利姆多
        map["莫高雷"] = 1412
        map["贫瘠之地"] = 1413
        map["千针石林"] = 1441
        map["加基森"] = 1446
        map["尘泥沼泽"] = 1445
        map["菲拉斯"] = 1444
        map["环形山"] = 1449
        map["希利苏斯"] = 1451
        map["凄凉之地"] = 1443
        map["石爪山脉"] = 1442
        map["杜隆塔尔"] = 1411
        map["奥格瑞玛"] = 1454
        map["艾萨拉"] = 1447
        map["灰谷"] = 1440
        map["黑海岸"] = 1439
        map["费伍德"] = 1448
        map["冬泉谷"] = 1452

        -- 东部
        map["提瑞斯法林地"] = 1420
        map["奥特兰克山脉"] = 1416
        map["阿拉希高地"] = 1417
        map["荒芜之地"] = 1418
        map["诅咒之地"] = 1419
        map["银松森林"] = 1421
        map["西瘟疫"] = 1422
        map["东瘟疫"] = 1423
        map["希尔斯布莱德丘陵"] = 1424 
        map["辛特兰"] = 1425
        map["丹莫罗"] = 1426
        map["灼热峡谷"] = 1427
        map["燃烧平原"] = 1428
        map["艾尔文森林"] = 1429
        map["逆风小径"] = 1430
        map["暮色森林"] = 1431
        map["洛克莫丹"] = 1432
        map["赤脊山"] = 1433
        map["荆棘谷"] = 1434
        map["悲伤沼泽"] = 1435
        map["西部荒野"] = 1436
        map["湿地"] = 1437
        map["暴风城"] = 1453
        map["铁炉堡"] = 1455
        map["幽暗城"] = 1458

        -- 外域
        map["地狱火半岛"] = 1944
        map["赞加沼泽"] = 1946
        map["影月谷"] = 1948
        map["埃索达"] = 1947
        map["刀锋山"] = 1949
        map["纳格兰"] = 1951
        map["泰罗卡森林"] = 1952
        map["虚空风暴"] = 1953
    end
    Initial()

    function GetContinient(mapid) -- 1 卡利姆多 2 东部王国
        local Kali = -- 卡利姆多
        {1412,1413,1441,1446,1445,1444,1449,1451,1443,1442,1411,1454,1447,1440,1439,1448,1452}

        local East_King = -- 东部王国
        {1420,1415,1416,1417,1418,1419,1421,1422,1423,1424,1425,1426,1427,1428,1429,1430,1431,1432,1433,1434,1435,1436,1437,1453,1455,1458}

        local WaiYu = -- 外域
        {1944,1946,1948,1949,1951,1952,1953}

        for i = 1,#Kali do
            if mapid == Kali[i] then
                return 1
            end
        end

        for i = 1,#East_King do
            if mapid == East_King[i] then
                return 2
            end
        end

        for i = 1,#WaiYu do
            if mapid == WaiYu[i] then
                return 3
            end
        end

        return nil
    end

    function Reverse_Table(table)
        local return_table = {}
        for i = 1,#table do
            return_table[#return_table + 1] = table[#table - i + 1]
        end
        return return_table
    end

    function Calculate_Sever_Map(Start_ID,End_ID)
        local Return_Mesh = {}

        if Start_ID == End_ID then
            Sever_Map_Move = 1
		    Easy_Data.Sever_Map_Calculated = false
		    Sever_Map_Table = {}
            Continent_Move = false
            Continent_Step = 1
            return Return_Mesh
        end

        --部落
        if Start_ID == map["希利苏斯"] then -- 希利苏斯
            Return_Mesh = Sever_Map["希利苏斯"]["希利苏斯 - 环形山"]
        end

        if Start_ID == map["环形山"] then -- 环形山
            if End_ID == map["希利苏斯"] then
                Return_Mesh = Sever_Map["环形山"]["环形山 - 希利苏斯"]
            else
                Return_Mesh = Sever_Map["环形山"]["环形山 - 加基森"]
            end
        end

        if Start_ID == map["加基森"] then -- 加基森
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] then
                Return_Mesh = Sever_Map["加基森"]["加基森 - 环形山"]
            else
                Return_Mesh = Sever_Map["加基森"]["加基森 - 千针石林"]
            end
        end

        if Start_ID == map["千针石林"] then -- 千针石林
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] or End_ID == map["加基森"] then
                Return_Mesh = Sever_Map["千针石林"]["千针石林 - 加基森"]
            else
                Return_Mesh = Sever_Map["千针石林"]["千针石林 - 菲拉斯"]
            end
        end

        if Start_ID == map["菲拉斯"] then -- 菲拉斯
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] or End_ID == map["加基森"] or End_ID == map["千针石林"] then
                Return_Mesh = Sever_Map["菲拉斯"]["菲拉斯 - 千针石林"]
            else
                Return_Mesh = Sever_Map["菲拉斯"]["菲拉斯 - 凄凉之地"]
            end
        end

        if Start_ID == map["凄凉之地"] then -- 凄凉之地
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] or End_ID == map["加基森"] or End_ID == map["千针石林"] or End_ID == map["菲拉斯"] then
                Return_Mesh = Sever_Map["凄凉之地"]["凄凉之地 - 菲拉斯"]
            else
                Return_Mesh = Sever_Map["凄凉之地"]["凄凉之地 - 石爪山脉"]
            end
        end

        if Start_ID == map["石爪山脉"] then -- 石爪山脉
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] or End_ID == map["加基森"] or End_ID == map["千针石林"] or End_ID == map["菲拉斯"] or End_ID == map["凄凉之地"] then
                Return_Mesh = Sever_Map["石爪山脉"]["石爪山脉 - 凄凉之地"]
            else
                Return_Mesh = Sever_Map["石爪山脉"]["石爪山脉 - 贫瘠之地"]
            end
        end

        if Start_ID == map["贫瘠之地"] then -- 贫瘠之地
            if End_ID == map["希利苏斯"] or End_ID == map["环形山"] or End_ID == map["加基森"] or End_ID == map["千针石林"] or End_ID == map["菲拉斯"] or End_ID == map["凄凉之地"] or End_ID == map["石爪山脉"] then
                Return_Mesh = Sever_Map["贫瘠之地"]["贫瘠之地 - 石爪山脉"]
            elseif End_ID == map["尘泥沼泽"] then
                Return_Mesh = Sever_Map["贫瘠之地"]["贫瘠之地 - 尘泥沼泽"]
            elseif End_ID == map["莫高雷"] then
                Return_Mesh = Sever_Map["贫瘠之地"]["贫瘠之地 - 莫高雷"]
            elseif End_ID == map["杜隆塔尔"] or End_ID == map["奥格瑞玛"] then
                Return_Mesh = Sever_Map["贫瘠之地"]["贫瘠之地 - 杜隆塔尔"]
            else
                Return_Mesh = Sever_Map["贫瘠之地"]["贫瘠之地 - 灰谷"]
            end
        end

        if Start_ID == map["莫高雷"] then -- 莫高雷
            Return_Mesh = Sever_Map["莫高雷"]["莫高雷 - 贫瘠之地"]
        end

        if Start_ID == map["尘泥沼泽"] then -- 尘泥沼泽
            Return_Mesh = Sever_Map["尘泥沼泽"]["尘泥沼泽 - 贫瘠之地"]
        end

        if Start_ID == map["杜隆塔尔"] then -- 杜隆塔尔
            if End_ID == map["奥格瑞玛"] then
                Return_Mesh = Sever_Map["杜隆塔尔"]["杜隆塔尔 - 奥格瑞玛"]
            else
                Return_Mesh = Sever_Map["杜隆塔尔"]["杜隆塔尔 - 贫瘠之地"]
            end
        end

        if Start_ID == map["奥格瑞玛"] then -- 奥格瑞玛
            Return_Mesh = Sever_Map["奥格瑞玛"]["奥格瑞玛 - 杜隆塔尔"]
        end

        if Start_ID == map["灰谷"] then -- 灰谷
            if End_ID == map["艾萨拉"] then
                Return_Mesh = Sever_Map["灰谷"]["灰谷 - 艾萨拉"]
            elseif End_ID == map["黑海岸"] then
                Return_Mesh = Sever_Map["灰谷"]["灰谷 - 黑海岸"]
            elseif End_ID == map["费伍德森林"] or End_ID == map["冬泉谷"] then
                Return_Mesh = Sever_Map["灰谷"]["灰谷 - 费伍德森林"]
            else
                Return_Mesh = Sever_Map["灰谷"]["灰谷 - 贫瘠之地"]
            end
        end

        if Start_ID == map["艾萨拉"] then -- 艾萨拉
            Return_Mesh = Sever_Map["艾萨拉"]["艾萨拉 - 灰谷"]
        end

        if Start_ID == map["黑海岸"] then -- 黑海岸
            Return_Mesh = Sever_Map["黑海岸"]["黑海岸 - 灰谷"]
        end

        if Start_ID == map["费伍德森林"] then -- 费伍德森林
            if End_ID == map["冬泉谷"] then
                Return_Mesh = Sever_Map["费伍德森林"]["费伍德森林 - 冬泉谷"]
            else
                Return_Mesh = Sever_Map["费伍德森林"]["费伍德森林 - 灰谷"]
            end
        end

        if Start_ID == map["冬泉谷"] then -- 冬泉谷
            Return_Mesh = Sever_Map["冬泉谷"]["冬泉谷 - 费伍德森林"]
        end

        -- 联盟
        if Start_ID == map["荆棘谷"] then -- 荆棘谷
            Return_Mesh = Sever_Map["荆棘谷"]["荆棘谷 - 暮色森林"]
        end

        if Start_ID == map["暮色森林"] then -- 暮色森林
            if End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] then
                Return_Mesh = Sever_Map["暮色森林"]["暮色森林 - 逆风小径"]
            elseif End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["暴风城"] then
                Return_Mesh = Sever_Map["暮色森林"]["暮色森林 - 西部荒野"]
            elseif End_ID == map["荆棘谷"] then
                Return_Mesh = Sever_Map["暮色森林"]["暮色森林 - 荆棘谷"]
            else
                Return_Mesh = Sever_Map["暮色森林"]["暮色森林 - 赤脊山"]
            end
        end

        if Start_ID == map["逆风小径"] then -- 逆风小径
            if End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] then
                Return_Mesh = Sever_Map["逆风小径"]["逆风小径 - 悲伤沼泽"]
            else
                Return_Mesh = Sever_Map["逆风小径"]["逆风小径 - 暮色森林"]
            end
        end

        if Start_ID == map["悲伤沼泽"] then -- 悲伤沼泽
            if End_ID == map["诅咒之地"] then
                Return_Mesh = Sever_Map["悲伤沼泽"]["悲伤沼泽 - 诅咒之地"]
            else
                Return_Mesh = Sever_Map["悲伤沼泽"]["悲伤沼泽 - 逆风小径"]
            end
        end

        if Start_ID == map["诅咒之地"] then -- 诅咒之地
            Return_Mesh = Sever_Map["诅咒之地"]["诅咒之地 - 悲伤沼泽"]
        end

        if Start_ID == map["西部荒野"] then -- 西部荒野
            if End_ID == map["艾尔文森林"] or End_ID == map["暴风城"] then
                Return_Mesh = Sever_Map["西部荒野"]["西部荒野 - 艾尔文森林"]
            else
                Return_Mesh = Sever_Map["西部荒野"]["西部荒野 - 暮色森林"]
            end
        end

        if Start_ID == map["艾尔文森林"] then -- 艾尔文森林
            if End_ID == map["西部荒野"] or End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] then
                Return_Mesh = Sever_Map["艾尔文森林"]["艾尔文森林 - 西部荒野"]
            elseif End_ID == map["暴风城"] then
                Return_Mesh = Sever_Map["艾尔文森林"]["艾尔文森林 - 暴风城"]
            else
                Return_Mesh = Sever_Map["艾尔文森林"]["艾尔文森林 - 赤脊山"]
            end
        end

        if Start_ID == map["赤脊山"] then -- 赤脊山
            if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] then
                Return_Mesh = Sever_Map["赤脊山"]["赤脊山 - 暮色森林"]
            elseif End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["暴风城"] then
                Return_Mesh = Sever_Map["赤脊山"]["赤脊山 - 艾尔文森林"]
            else
                Return_Mesh = Sever_Map["赤脊山"]["赤脊山 - 燃烧平原"]
            end
        end

        if Start_ID == map["燃烧平原"] then -- 燃烧平原
            if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] then
                Return_Mesh = Sever_Map["燃烧平原"]["燃烧平原 - 赤脊山"]
            else
                Return_Mesh = Sever_Map["燃烧平原"]["燃烧平原 - 灼热峡谷"]
            end
        end

        if Start_ID == map["灼热峡谷"] then -- 灼热峡谷
            if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] or End_ID == map["燃烧平原"] then
                Return_Mesh = Sever_Map["灼热峡谷"]["灼热峡谷 - 燃烧平原"]
            else
                Return_Mesh = Sever_Map["灼热峡谷"]["灼热峡谷 - 荒芜之地"]
            end
        end

        if Start_ID == map["荒芜之地"] then -- 荒芜之地
            if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] or End_ID == map["燃烧平原"] or End_ID == map["灼热峡谷"] then
                Return_Mesh = Sever_Map["荒芜之地"]["荒芜之地 - 灼热峡谷"]
            else
                Return_Mesh = Sever_Map["荒芜之地"]["荒芜之地 - 洛克莫丹"]
            end
        end

        if Start_ID == map["洛克莫丹"] then -- 洛克莫丹
            if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] or End_ID == map["燃烧平原"] or End_ID == map["灼热峡谷"] or End_ID == map["荒芜之地"] then
                Return_Mesh = Sever_Map["洛克莫丹"]["洛克莫丹 - 荒芜之地"]
            elseif End_ID == map["丹莫罗"] or End_ID == map["铁炉堡"] then
                Return_Mesh = Sever_Map["洛克莫丹"]["洛克莫丹 - 丹莫罗"]
            else
                Return_Mesh = Sever_Map["洛克莫丹"]["洛克莫丹 - 湿地"]
            end
        end

        if Start_ID == map["丹莫罗"] then -- 丹莫罗
            if End_ID == map["铁炉堡"] then
                Return_Mesh = Sever_Map["丹莫罗"]["丹莫罗 - 铁炉堡"]
            else
                Return_Mesh = Sever_Map["丹莫罗"]["丹莫罗 - 洛克莫丹"]
            end
        end

        if Start_ID == map["湿地"] then -- 湿地
            if End_ID == map["幽暗城"] or End_ID == map["阿拉希高地"] or End_ID == map["希尔斯布莱德丘陵"] or End_ID == map["奥特兰克山脉"] or End_ID == map["银松森林"] or End_ID == map["提瑞斯法林地"] or End_ID == map["西瘟疫"] or End_ID == map["东瘟疫"] or End_ID == map["辛特兰"] then
                Return_Mesh = Sever_Map["湿地"]["湿地 - 阿拉希高地"]
            else
                Return_Mesh = Sever_Map["湿地"]["湿地 - 洛克莫丹"]
            end
        end

        if Start_ID == map["阿拉希高地"] then -- 阿拉希高地
            if End_ID == map["幽暗城"] or End_ID == map["希尔斯布莱德丘陵"] or End_ID == map["奥特兰克山脉"] or End_ID == map["银松森林"] or End_ID == map["提瑞斯法林地"] or End_ID == map["西瘟疫"] or End_ID == map["东瘟疫"] or End_ID == map["辛特兰"] then
                Return_Mesh = Sever_Map["阿拉希高地"]["阿拉希高地 - 希尔斯布莱德丘陵"]
            else
                Return_Mesh = Sever_Map["阿拉希高地"]["阿拉希高地 - 湿地"]
            end
        end

        if Start_ID == map["希尔斯布莱德丘陵"] then -- 希尔斯布莱德丘陵
            if End_ID == map["幽暗城"] or End_ID == map["银松森林"] or End_ID == map["提瑞斯法林地"] or End_ID == map["西瘟疫"] or End_ID == map["东瘟疫"] then
                Return_Mesh = Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 银松森林"]
            elseif End_ID == map["奥特兰克山脉"] then
                Return_Mesh = Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 奥特兰克山脉"]
            elseif End_ID == map["辛特兰"] then
                Return_Mesh = Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 辛特兰"]
            else
                Return_Mesh = Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 阿拉希高地"]
            end
        end

        if Start_ID == map["奥特兰克山脉"] then -- 奥特兰克山脉
            Return_Mesh = Sever_Map["奥特兰克山脉"]["奥特兰克山脉 - 希尔斯布莱德丘陵"]
        end

        if Start_ID == map["银松森林"] then -- 银松森林
            if End_ID == map["幽暗城"] or End_ID == map["提瑞斯法林地"] or End_ID == map["西瘟疫"] or End_ID == map["东瘟疫"] then
                Return_Mesh = Sever_Map["银松森林"]["银松森林 - 提瑞斯法林地"]
            else
                Return_Mesh = Sever_Map["银松森林"]["银松森林 - 希尔斯布莱德丘陵"]
            end
        end

        if Start_ID == map["提瑞斯法林地"] then -- 提瑞斯法林地
            if End_ID == map["西瘟疫"] or End_ID == map["东瘟疫"] then
                Return_Mesh = Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 西瘟疫"]
            elseif End_ID == map["幽暗城"] then
                Return_Mesh = Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 幽暗城"]
            else
                Return_Mesh = Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 银松森林"]
            end
        end

        if Start_ID == map["西瘟疫"] then -- 西瘟疫
            if End_ID == map["东瘟疫"] then
                Return_Mesh = Sever_Map["西瘟疫"]["西瘟疫 - 东瘟疫"]
            else
                Return_Mesh = Sever_Map["西瘟疫"]["西瘟疫 - 提瑞斯法林地"]
            end
        end

        if Start_ID == map["东瘟疫"] then -- 东瘟疫
            Return_Mesh = Sever_Map["东瘟疫"]["东瘟疫 - 西瘟疫"]
        end

        if Start_ID == map["幽暗城"] then -- 幽暗城
            Return_Mesh = Sever_Map["幽暗城"]["幽暗城 - 提瑞斯法林地"]
        end

        if Start_ID == map["暴风城"] then -- 暴风城
            Return_Mesh = Sever_Map["暴风城"]["暴风城 - 艾尔文森林"]
        end
        if Start_ID == map["铁炉堡"] then -- 铁炉堡
            Return_Mesh = Sever_Map["铁炉堡"]["铁炉堡 - 丹莫罗"]
        end

        if Start_ID == map["辛特兰"] then -- 辛特兰
            Return_Mesh = Sever_Map["辛特兰"]["辛特兰 - 希尔斯布莱德丘陵"]
        end

        local x,y,z = awm.ObjectPosition("player")
        local Far_Distance = 500
        local point = 0

        for i = 1,#Return_Mesh do
            local mx,my,mz = Return_Mesh[i][1],Return_Mesh[i][2],Return_Mesh[i][3]
            local distance = awm.GetDistanceBetweenPositions(x,y,z,mx,my,mz)
            if distance < Far_Distance then
                Far_Distance = distance
                point = i
            end
        end
        if point > 1 then
            for i = 1,point - 1 do
                table.remove(Return_Mesh,1)
            end
        end

        return Return_Mesh
    end


    Easy_Data.Sever_Map_Calculated = false -- 是否已经计算过
    Sever_Map_Table = {} -- 云地图包table
    Sever_Map_Move = 1
    Continent_Move = false
    local Original_Start_ID = 0 -- 出发的位置
    local Continent_Step = 1
    function Sever_Run(Start_ID,End_ID,x,y,z)
        if (GetContinient(Start_ID) and GetContinient(End_ID) and GetContinient(Start_ID) ~= GetContinient(End_ID)) or Continent_Move then -- 不同大陆
            if not Continent_Move then
                Continent_Move = true
                Original_Start_ID = Start_ID
            end
            Continient_Run(Original_Start_ID,End_ID)
            return
        else
            Map_Run(Start_ID,End_ID,x,y,z)
        end
    end

    function Map_Run(Start_ID,End_ID,dest_x,dest_y,dest_z)
        if Sever_Map_Move >= #Sever_Map_Table and Easy_Data.Sever_Map_Calculated then
	        Sever_Map_Move = 1
		    Easy_Data.Sever_Map_Calculated = false
		    Sever_Map_Table = {}
            Continent_Step = 1
            Continent_Move = false
		    return
	    end
        if not Easy_Data.Sever_Map_Calculated then
            Sever_Map_Move = 1
            Sever_Map_Table = Calculate_Sever_Map(Start_ID,End_ID)
            Easy_Data.Sever_Map_Calculated = true
            if #Sever_Map_Table > 0 then
                textout(Check_UI("新的云地图路线已经生成, 点数总计 = ","New sever navigation request route has been generated, nodes total = ")..#Sever_Map_Table)
            end
        end
        if #Sever_Map_Table == 0 then
            Run(dest_x,dest_y,dest_z)
            return
        end

        local Px,Py,Pz = awm.ObjectPosition("player")
	    local Coord = Sever_Map_Table[Sever_Map_Move]
	    local x,y,z = Coord[1],Coord[2],Coord[3]
	    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)

        local dest_distance_to_point = awm.GetDistanceBetweenPositions(dest_x,dest_y,dest_z,x,y,z)
        local dest_distance_to_char = awm.GetDistanceBetweenPositions(dest_x,dest_y,dest_z,Px,Py,Pz)

        if Start_ID == End_ID and dest_distance_to_point > dest_distance_to_char then
            Sever_Map_Move = 1
		    Easy_Data.Sever_Map_Calculated = false
		    Sever_Map_Table = {}
		    return
        end

	    if distance >= 1.2 then
	        Run(x,y,z)
	    else
	        Sever_Map_Move = Sever_Map_Move + 1
            textout(Check_UI("下一地点 = ","Next Node = ")..Sever_Map_Move.."/"..#Sever_Map_Table)
	    end
    end

    function Continient_Run(Start_ID,End_ID)
        local Current_Continient = GetContinient(Start_ID)
        local End_Continient = GetContinient(End_ID)
        local Faction = UnitFactionGroup("player")
        local Current_Map = C_Map.GetBestMapForUnit("player")
        local Px,Py,Pz = awm.ObjectPosition("player")

        local Continent_Route = {}

        Continent_Route["贫瘠之地 - 荆棘谷"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["贫瘠之地"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["贫瘠之地"],-996.96,-3834.55,6.10)
                else
                    local x,y,z = -997.37,-3828.91,5.54
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6668") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(-1005.61,-3841.65,0,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = -996.96,-3834.55,6.10
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6668") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,-14277.75,582.87,0) <= 1 then
                            Continent_Step = 4
                            Sever_Map_Move = 1
                            textout(Check_UI("到达东部王国","Arrive to the destination"))
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
            if Continent_Step == 4 then
                local Path = 
                {
                {-14270.39,582.03,6.08},
                {-14277.96,572.15,6.14},
                {-14280.53,567.37,6.77},
                {-14286.77,555.73,8.89},
                {-14299.26,532.46,8.70},
                {-14299.43,504.11,9.00},
                {-14316.53,474.14,18.39},
                {-14317.88,458.87,21.91},
                {-14320.88,446.95,23.09},
                {-14301.08,437.52,30.58},
                {-14279.30,424.97,35.52},
                {-14273.84,406.09,37.08},
                {-14278.64,366.15,33.63},
                {-14269.53,349.68,32.42},
                {-14241.37,325.10,24.71},
                {-14251.56,283.21,26.78},
                {-14206.95,244.26,18.33},
                {-14145.65,248.17,14.80},
                {-14046.68,267.39,18.63},
                {-13967.50,281.84,18.63},
                {-13916.29,272.64,18.63},
                {-13778.09,206.15,21.23},
                {-13712.49,128.24,23.82},
                }

                if Sever_Map_Move > #Path then
                    Continent_Step = 1
                    Continent_Move = false
                    Sever_Map_Move = 1
                    textout(Check_UI("结束跨大陆导航","End Continent cross navigation"))
                    return
                end

                local x,y,z = Path[Sever_Map_Move][1],Path[Sever_Map_Move][2],Path[Sever_Map_Move][3]
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Sever_Map_Move = Sever_Map_Move + 1            
                end
            end
        end

        Continent_Route["荆棘谷 - 贫瘠之地"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["荆棘谷"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["荆棘谷"],-14277.03,574.22,6.1)
                else
                    local Path = {
                    {-13712.49,128.24,23.82},
                    {-13778.09,206.15,21.23},
                    {-13916.29,272.64,18.63},
                    {-13967.50,281.84,18.63},
                    {-14046.68,267.39,18.63},
                    {-14145.65,248.17,14.80},
                    {-14206.95,244.26,18.33},
                    {-14251.56,283.21,26.78},
                    {-14241.37,325.10,24.71},
                    {-14269.53,349.68,32.42},
                    {-14278.64,366.15,33.63},
                    {-14273.84,406.09,37.08},
                    {-14279.30,424.97,35.52},
                    {-14301.08,437.52,30.58},
                    {-14320.88,446.95,23.09},
                    {-14317.88,458.87,21.91},
                    {-14316.53,474.14,18.39},
                    {-14299.43,504.11,9.00},
                    {-14299.26,532.46,8.70},
                    {-14286.77,555.73,8.89},
                    {-14281.47,565.04,7.39},
                    }


                    Sever_Map_Move = 1

                    local Far_Distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,-13712.49,128.24,23.82)

                    for i = 1,#Path do
                        local x,y,z = Path[i][1],Path[i][2],Path[i][3]
                        local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                        if distance < Far_Distance then
                            Sever_Map_Move = i
                            Far_Distance = distance
                        end
                    end

                    textout(Check_UI("最近地点 = ","Closest point = ")..Sever_Map_Move)

                    Continent_Step = 2
           
                    return
                end
            end

            if Continent_Step == 2 then
            local Path = {
                {-13712.49,128.24,23.82},
                {-13778.09,206.15,21.23},
                {-13916.29,272.64,18.63},
                {-13967.50,281.84,18.63},
                {-14046.68,267.39,18.63},
                {-14145.65,248.17,14.80},
                {-14206.95,244.26,18.33},
                {-14251.56,283.21,26.78},
                {-14241.37,325.10,24.71},
                {-14269.53,349.68,32.42},
                {-14278.64,366.15,33.63},
                {-14273.84,406.09,37.08},
                {-14279.30,424.97,35.52},
                {-14301.08,437.52,30.58},
                {-14320.88,446.95,23.09},
                {-14317.88,458.87,21.91},
                {-14316.53,474.14,18.39},
                {-14299.43,504.11,9.00},
                {-14299.26,532.46,8.70},
                {-14286.77,555.73,8.89},
                {-14281.47,565.04,7.39},
                }


                if Sever_Map_Move > #Path then
                    local Ship = nil
                    local total = awm.GetObjectCount()
	                for i = 1,total do
		                local ThisUnit = awm.GetObjectWithIndex(i)
		                local id = awm.UnitGUID(ThisUnit)
		                local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                if string.find(id,"6668") and distance < 100 then
		                    Ship = ThisUnit
		                end
	                end
                    if Ship ~= nil then
                        local x,y,z = awm.ObjectPosition(Ship)
                        if awm.GetDistanceBetweenPositions(-14277.75,582.87,0,x,y,z) <= 1 then
                            Continent_Step = 4
                            textout(Check_UI("船只已到达","Ship arrive at the port"))
                        end
                    end
                    return
                end

                local x,y,z = Path[Sever_Map_Move][1],Path[Sever_Map_Move][2],Path[Sever_Map_Move][3]
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 2 then
                    Run(x,y,z)
                else
                    Continent_Step = 3
                    return
                end
            end

            if Continent_Step == 3 then
                local Path = {
                {-13712.49,128.24,23.82},
                {-13778.09,206.15,21.23},
                {-13916.29,272.64,18.63},
                {-13967.50,281.84,18.63},
                {-14046.68,267.39,18.63},
                {-14145.65,248.17,14.80},
                {-14206.95,244.26,18.33},
                {-14251.56,283.21,26.78},
                {-14241.37,325.10,24.71},
                {-14269.53,349.68,32.42},
                {-14278.64,366.15,33.63},
                {-14273.84,406.09,37.08},
                {-14279.30,424.97,35.52},
                {-14301.08,437.52,30.58},
                {-14320.88,446.95,23.09},
                {-14317.88,458.87,21.91},
                {-14316.53,474.14,18.39},
                {-14299.43,504.11,9.00},
                {-14299.26,532.46,8.70},
                {-14286.77,555.73,8.89},
                {-14281.47,565.04,7.39},
                }


                if Sever_Map_Move > #Path then
                    local Ship = nil
                    local total = awm.GetObjectCount()
	                for i = 1,total do
		                local ThisUnit = awm.GetObjectWithIndex(i)
		                local id = awm.UnitGUID(ThisUnit)
		                local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                if string.find(id,"6668") and distance < 100 then
		                    Ship = ThisUnit
		                end
	                end
                    if Ship ~= nil then
                        local x,y,z = awm.ObjectPosition(Ship)
                        if awm.GetDistanceBetweenPositions(-14277.75,582.87,0,x,y,z) <= 1 then
                            Continent_Step = 4
                            textout(Check_UI("船只已到达","Ship arrive at the port"))
                        end
                    end
                    return
                end

                local x,y,z = Path[Sever_Map_Move][1],Path[Sever_Map_Move][2],Path[Sever_Map_Move][3]
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Sever_Map_Move = Sever_Map_Move + 1
                end
            end


            if Continent_Step == 4 then
                local x,y,z = -14277.03,574.22,6.1
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 5
                end
            end
            if Continent_Step == 6 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6668") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,-1005.61,-3841.65,0) <= 1 then
                            Continent_Step = 6
                            textout(Check_UI("到达贫瘠之地","Arrive to the destination"))
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
            if Continent_Step == 6 then
                local x,y,z = -1012.83,-3858.09,-1.57
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 1
                    Continent_Move = false
                    textout(Check_UI("结束跨大陆导航","End Continent cross navigation"))
                end
            end
        end

        Continent_Route["湿地 - 尘泥沼泽"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["湿地"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["湿地"],-3899.91,-593.72,6.1)
                else
                    local x,y,z = -3896.74,-598.96,5.41
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6734") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(-3905.22,-585.81,0,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = -3899.91,-593.72,6.1
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6734") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,-4016.39,-4740.59,0) <= 1 then
                            Continent_Step = 4
                            textout(Check_UI("到达卡利姆多","Arrive to the destination"))
                            return
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end

            if Continent_Step == 4 then
                local x,y,z = -4031,-4761,-2.3
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 1
                    Continent_Move = false
                    textout(Check_UI("结束跨大陆导航","End Continent cross navigation"))
                end
            end
        end

        Continent_Route["尘泥沼泽 - 湿地"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["尘泥沼泽"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["尘泥沼泽"],-4008.47,-4733.32,6.07)
                else
                    local x,y,z = -4005.55,-4730.18,5.27
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6734") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(-4016.39,-4740.59,0,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = -4008.47,-4733.32,6.07
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6734") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,-3905.22,-585.81,0) <= 1 then
                            Continent_Step = 4
                            textout(Check_UI("到达湿地","Arrive to the destination"))
                            return
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
            if Continent_Step == 4 then
                local x,y,z = -3915,-564,-1.58
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 1
                    Continent_Move = false
                    textout(Check_UI("结束跨大陆导航","End Continent cross navigation"))
                end
            end
        end

        Continent_Route["杜隆塔尔 - 荆棘谷"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["杜隆塔尔"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["杜隆塔尔"],1365.99,-4633.97,54.11)
                else
                    local x,y,z = 1361.53,-4637.07,53.88
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6666") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(1360.85,-4631.31,71.86,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = 1365.99,-4633.97,54.11
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6666") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,-12464.01,231.56,49.53) <= 1 then
                            Continent_Step = 1
                            Continent_Move = false
                            textout(Check_UI("到达地点","Arrive to the destination"))
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
        end

        Continent_Route["荆棘谷 - 杜隆塔尔"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["荆棘谷"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["荆棘谷"],-12454.81,221.21,31.77)
                else
                    local x,y,z = -12450.72,218.51,31.63
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6666") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(-12464.01,231.56,49.53,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = -12454.81,221.21,31.77
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6666") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,1360.85,-4631.31,71.86) <= 1 then
                            Continent_Step = 1
                            Continent_Move = false
                            textout(Check_UI("到达地点","Arrive to the destination"))
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
        end

        Continent_Route["杜隆塔尔 - 提瑞斯法林地"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["杜隆塔尔"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["杜隆塔尔"],1316.51,-4652.95,54.10)
                else
                    local x,y,z = 1320.89,-4653.09,53.88
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6667") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(1318.11,-4658.05,71.86,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = 1316.51,-4652.95,54.10
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6667") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        Continent_Step = 1
                        textout(Check_UI("上船失败","Ship Gone"))
                    else
                        if awm.GetDistanceBetweenPositions(x,y,z,2062.38,293.00,114.97) <= 20 then
                            Continent_Step = 1
                            Continent_Move = false
                            textout(Check_UI("到达地点","Arrive to the destination"))
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    Continent_Step = 1
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                end
            end
        end

        Continent_Route["提瑞斯法林地 - 杜隆塔尔"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["提瑞斯法林地"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["提瑞斯法林地"],2068.51,294.96,97.23)
                else
                    local x,y,z = 2066.63,287.48,97.03
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        local Ship = nil
                        local total = awm.GetObjectCount()
	                    for i = 1,total do
		                    local ThisUnit = awm.GetObjectWithIndex(i)
		                    local id = awm.UnitGUID(ThisUnit)
		                    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		                    if string.find(id,"6667") and distance < 100 then
		                        Ship = ThisUnit
		                    end
	                    end
                        if Ship ~= nil then
                            local x,y,z = awm.ObjectPosition(Ship)
                            if awm.GetDistanceBetweenPositions(2062.38,293.00,114.97,x,y,z) <= 1 then
                                Continent_Step = 2
                                textout(Check_UI("船只已到达","Ship arrive at the port"))
                            end
                        end
                    end
                end
            end
            if Continent_Step == 2 then
                local x,y,z = 2068.51,294.96,97.23
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.Interval_Move(x,y,z)
                else
                    textout(Check_UI("已经上船","Wait the ship start"))
                    Continent_Step = 3
                end
            end
            if Continent_Step == 3 then
                local Ship = nil
                local total = awm.GetObjectCount()
	            for i = 1,total do
		            local ThisUnit = awm.GetObjectWithIndex(i)
		            local id = awm.UnitGUID(ThisUnit)
		            local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
		            if string.find(id,"6667") and distance < 100 then
		                Ship = ThisUnit
		            end
	            end
                if Ship ~= nil then
                    local x,y,z = awm.ObjectPosition(Ship)
                    if awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz) >= 40 then
                        textout(Check_UI("上船失败","Ship Gone"))
                        Continent_Step = 1
                    else
                        local distance = awm.GetDistanceBetweenPositions(x,y,z,1318.11,-4658.05,71.86)
                        if distance <= 1 then
                            textout(Check_UI("到达地点","Arrive to the destination"))
                            Continent_Move = false
                            Continent_Step = 1 
                        end
                    end
                elseif PlayerFrame:IsVisible() and Ship == nil then
                    textout(Check_UI("船只信息丢失","Ship obj vanish"))
                    Continent_Step = 1
                end
            end
        end

        Continent_Route["地狱火半岛 - 诅咒之地"] = function()
            if Continent_Step == 1 then
                local path = 
                {
                {-398.70,1240.57,35.96},
                {-399.43,1197.43,42.97},
                {-395.91,1162.41,46.63},
                {-395.08,1144.81,49.94},
                {-392.51,1125.80,55.10},
                {-385.13,1120.96,52.84},
                {-386.46,1078.89,62.66},
                {-381.69,1054.30,58.38},
                {-379.70,1032.44,54.47},
                {-375.28,1023.47,54.13},
                {-363.37,1001.74,54.19},
                {-341.50,1012.05,54.22},
                {-327.30,1013.72,54.26},
                {-286.35,1018.65,54.32},
                {-252.32,1020.02,54.33},
                {-246.95,963.49,84.34},
                {-246.00,939.02,84.38}
                }
                if Sever_Map_Move >= #path and Continent_Move then
	                Sever_Map_Move = 1
		            Continent_Move = false
		            Continent_Step = 2
		            return
	            end
                local Px,Py,Pz = awm.ObjectPosition("player")
	            local Coord = path[Sever_Map_Move]
	            local x,y,z = Coord[1],Coord[2],Coord[3]
	            local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
	            if distance >= 1.2 then
	                Run(x,y,z)
	            else
	                Sever_Map_Move = Sever_Map_Move + 1
                    textout(Check_UI("下一地点 = ","Next Node = ")..Sever_Map_Move.."/"..#path)
	            end
            end
            if Continent_Step == 2 then
                if Current_Map ~= map["地狱火半岛"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["地狱火半岛"],-248,921,84)
                else
                    local x,y,z = -248,921,84
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        Continent_Step = 3
                    end
                end
            end
            if Continent_Step == 3 then
                if Current_Map == map["诅咒之地"] then
                    Continent_Move = false
                    Continent_Step = 1 
                    return
                end
                local x,y,z = -244.73,895.67,88.83
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.MoveTo(x,y,z)
                end
            end
        end

        Continent_Route["诅咒之地 - 地狱火半岛"] = function()
            if Continent_Step == 1 then
                if Current_Map ~= map["诅咒之地"] or Easy_Data.Sever_Map_Calculated then
                    Map_Run(Current_Map,map["诅咒之地"],-11890,-3206,-14)
                else
                    local x,y,z = -11890,-3206,-14
                    local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                    if distance > 1 then
                        Run(x,y,z)
                    else
                        Continent_Step = 2
                    end
                end
            end
            if Continent_Step == 2 then
                if Current_Map == map["地狱火半岛"] then
                    Continent_Step = 3
                    Sever_Map_Move = 1
                    return
                end
                local x,y,z = -11908,-3208.08,13.03
                local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,z)
                if distance > 1 then
                    awm.MoveTo(x,y,z)
                end
            end
            if Continent_Step == 3 then
                local path = 
                {
                {-250.29,939.03,84.35},
                {-281.88,948.57,84.35},
                {-306.22,953.95,67.31},
                {-348.31,971.36,54.28},
                {-371.69,965.76,54.15},
                {-389.88,961.57,48.86},
                {-385.74,1080.04,61.94},
                {-371.28,1173.98,42.96},
                {-344.39,1236.55,37.43},
                {-301.05,1337.38,19.34}
                }
                if Sever_Map_Move >= #path and Continent_Move then
	                Sever_Map_Move = 1
		            Continent_Move = false
		            Continent_Step = 1
		            return
	            end
                local Px,Py,Pz = awm.ObjectPosition("player")
	            local Coord = path[Sever_Map_Move]
	            local x,y,z = Coord[1],Coord[2],Coord[3]
	            local distance = awm.GetDistanceBetweenPositions(Px,Py,Pz,x,y,Pz)
	            if distance >= 1.2 then
	                awm.Interval_Move(x,y,z)
	            else
	                Sever_Map_Move = Sever_Map_Move + 1
                    textout(Check_UI("下一地点 = ","Next Node = ")..Sever_Map_Move.."/"..#path)
	            end
            end
        end
        if Current_Continient == 1 then -- 人在卡利姆多
            if (End_Continient == 2 or End_Continient == 3) and Faction == "Horde" then
                if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] or End_ID == map["燃烧平原"] or End_ID == map["灼热峡谷"] or End_Continient == 3 then
                    Continent_Route["杜隆塔尔 - 荆棘谷"]()
                else
                    Continent_Route["杜隆塔尔 - 提瑞斯法林地"]()
                end
            elseif (End_Continient == 2 or End_Continient == 3) and Faction == "Alliance" then
                if End_ID == map["暮色森林"] or End_ID == map["荆棘谷"] or End_ID == map["艾尔文森林"] or End_ID == map["西部荒野"] or End_ID == map["赤脊山"] or End_ID == map["逆风小径"] or End_ID == map["诅咒之地"] or End_ID == map["悲伤沼泽"] or End_ID == map["暴风城"] or End_ID == map["燃烧平原"] or End_ID == map["灼热峡谷"] or End_Continient == 3 then
                    Continent_Route["贫瘠之地 - 荆棘谷"]()
                else
                    Continent_Route["尘泥沼泽 - 湿地"]()
                end
            end
        elseif Current_Continient == 2 then -- 人在东部王国
            if End_Continient == 1 and Faction == "Horde" then
                if Start_ID == map["暮色森林"] or Start_ID == map["荆棘谷"] or Start_ID == map["艾尔文森林"] or Start_ID == map["西部荒野"] or Start_ID == map["赤脊山"] or Start_ID == map["逆风小径"] or Start_ID == map["诅咒之地"] or Start_ID == map["悲伤沼泽"] or Start_ID == map["暴风城"] or Start_ID == map["燃烧平原"] or Start_ID == map["灼热峡谷"] then
                    Continent_Route["荆棘谷 - 杜隆塔尔"]()
                else
                    Continent_Route["提瑞斯法林地 - 杜隆塔尔"]()
                end
            elseif End_Continient == 1 and Faction == "Alliance" then
                if Start_ID == map["暮色森林"] or Start_ID == map["荆棘谷"] or Start_ID == map["艾尔文森林"] or Start_ID == map["西部荒野"] or Start_ID == map["赤脊山"] or Start_ID == map["逆风小径"] or Start_ID == map["诅咒之地"] or Start_ID == map["悲伤沼泽"] or Start_ID == map["暴风城"] or Start_ID == map["燃烧平原"] or Start_ID == map["灼热峡谷"] then
                    Continent_Route["荆棘谷 - 贫瘠之地"]()
                else
                    Continent_Route["湿地 - 尘泥沼泽"]()
                end
            elseif End_Continient == 3 then
                Continent_Route["诅咒之地 - 地狱火半岛"]()
            end  
        elseif Current_Continient == 3 then -- 人在东部王国
            Continent_Route["地狱火半岛 - 诅咒之地"]()
        end
    end

    function Find_Obj(obj)
        local Monster = nil
        local total = awm.GetObjectCount()
	    for i = 1,total do
		    local ThisUnit = awm.GetObjectWithIndex(i)
		    local id = awm.ObjectId(ThisUnit)
		    local name = awm.UnitFullName(ThisUnit)
		    local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
            local x1,y1,z1 = awm.ObjectPosition(ThisUnit)
		    if ((tonumber(obj) ~= nil and id == obj) or name == obj) and distance < 100 then
		        Monster = ThisUnit
		    end
	    end
	    return Monster
    end

    local function Map_1451() -- 希利苏斯
        Sever_Map["希利苏斯"] = {}
        Sever_Map["希利苏斯"]["希利苏斯 - 环形山"] = 
        {
        {-6828.42,747.57,42.49},{-6802.74,681.03,27.49},{-6807.69,571.23,0.19},{-6777.61,423.45,10.74},{-6785.04,270.63,4.82},{-6780.94,146.10,-0.36},{-6744.62,52.16,2.00},{-6684.47,-31.09,0.84},{-6602.66,-91.60,-1.96},{-6503.77,-164.18,-3.45},{-6406.06,-229.63,-6.38},{-6290.95,-381.21,-0.98},{-6226.98,-466.50,-60.95},{-6222.00,-575.95,-117.20},{-6255.52,-592.44,-126.36},{-6335.07,-549.29,-172.61},{-6416.04,-553.82,-211.02},{-6473.66,-524.92,-233.40},{-6523.47,-558.16,-269.55},{-6550.80,-611.78,-272.17},{-6572.61,-645.69,-271.81},{-6497.40,-774.31,-272.82},{-6438.21,-874.50,-271.87},{-6361.19,-1076.90,-272.22},{-6323.62,-1113.78,-270.04},{-6313.62,-1172.79,-269.68},{-6299.03,-1175.89,-268.62},{-6287.55,-1157.10,-256.57},{-6235.86,-1128.01,-230.94},{-6229.77,-1100.40,-218.32},{-6203.56,-1076.61,-208.25},{-6160.07,-1086.20,-204.38}
	    }
    end
    Map_1451()

    local function Map_1449() -- 环形山
        Sever_Map["环形山"] = {}
        Sever_Map["环形山"]["环形山 - 希利苏斯"] = Reverse_Table(Sever_Map["希利苏斯"]["希利苏斯 - 环形山"])
        Sever_Map["环形山"]["环形山 - 加基森"] = 
        {
        {-6312.73,-1176.43,-269.69},{-6373.82,-1264.64,-270.71},{-6411.28,-1323.23,-271.85},{-6504.88,-1475.34,-272.48},{-6686.27,-1765.17,-270.91},{-6825.03,-1893.08,-269.76},{-6989.30,-2085.75,-271.92},{-7033.12,-2078.25,-273.27},{-7059.10,-2073.83,-269.42},{-7171.95,-2079.09,-272.48},{-7291.63,-2140.10,-271.32},{-7312.01,-2197.05,-272.34},{-7292.41,-2245.46,-269.91},{-7308.97,-2292.30,-269.33},{-7379.87,-2286.05,-269.38},{-7441.58,-2265.05,-270.25},{-7534.21,-2231.41,-271.30},{-7677.64,-2179.79,-269.63},{-7786.32,-2056.67,-270.52},{-7839.64,-2063.24,-271.64},{-7878.78,-2115.59,-269.26},{-7930.02,-2141.10,-231.79},{-7987.60,-2114.33,-209.47},{-8080.67,-2116.96,-164.85},{-8099.36,-2107.79,-151.87},{-8145.55,-2076.66,-126.17},{-8211.37,-2084.92,-109.39},{-8276.36,-2072.44,-80.80},{-8490.12,-2081.50,-5.61},{-8558.13,-2108.78,8.85},{-8559.43,-2182.63,12.70},{-8451.12,-2396.16,34.92},{-8150.36,-2904.84,31.90},{-8087.93,-3095.00,40.96},{-7824.86,-3398.87,51.31},{-7253.71,-3716.71,9.07}
        }
    end
    Map_1449()

    local function Map_1446() -- 加基森
        Sever_Map["加基森"] = {}
        Sever_Map["加基森"]["加基森 - 环形山"] = Reverse_Table(Sever_Map["环形山"]["环形山 - 加基森"])
        Sever_Map["加基森"]["加基森 - 千针石林"] = 
        {
        {-7064.79,-3769.54,9.78},{-6983.99,-3723.15,31.26},{-6921.54,-3739.90,55.49},{-6887.76,-3776.04,51.75},{-6794.19,-3751.56,8.25},{-6744.47,-3704.35,-25.56},{-6671.60,-3694.66,-58.45},{-6639.07,-3731.54,-59.88},{-6493.40,-3713.38,-60.39},{-6295.97,-3705.01,-59.96},{-5992.58,-3708.06,-59.87},{-5845.69,-3637.54,-59.96},{-5764.54,-3583.30,-60.09},{-5664.09,-3499.47,-57.97},{-5636.40,-3466.61,-52.38},{-5603.82,-3375.45,-38.59},{-5590.89,-3325.87,-40.16},{-5556.87,-3266.70,-44.57},{-5578.69,-3232.24,-46.49},{-5583.35,-3143.83,-42.26},{-5598.23,-3099.19,-48.99},{-5606.52,-3065.50,-51.80},{-5618.39,-2946.91,-50.44},{-5589.74,-2887.36,-48.75},{-5548.96,-2824.85,-53.62},{-5547.59,-2798.91,-52.15},{-5546.63,-2774.01,-52.83},{-5552.15,-2755.08,-53.68},{-5552.41,-2731.13,-54.75},{-5508.21,-2680.34,-49.82},{-5509.38,-2607.22,-54.98},{-5469.91,-2555.81,-52.38},{-5494.05,-2553.57,-54.52},{-5531.55,-2537.36,-53.87},{-5547.54,-2508.15,-49.08},{-5565.95,-2463.42,-47.18},{-5586.61,-2409.57,-57.48},{-5545.11,-2373.65,-51.91}
	    }
    end
    Map_1446()

    local function Map_1441() -- 千针石林
        Sever_Map["千针石林"] = {}
        Sever_Map["千针石林"]["千针石林 - 加基森"] = Reverse_Table(Sever_Map["加基森"]["加基森 - 千针石林"])
        Sever_Map["千针石林"]["千针石林 - 菲拉斯"] = 
        {
        {-5505.14,-2351.80,-45.70},{-5445.49,-2340.08,-39.51},{-5381.19,-2341.75,-43.51},{-5349.17,-2326.86,-50.35},{-5324.52,-2238.29,-55.50},{-5278.21,-2177.88,-52.90},{-5272.40,-2069.90,-61.42},{-5222.59,-1980.59,-63.34},{-5225.69,-1889.34,-64.44},{-5244.53,-1842.02,-62.91},{-5216.31,-1770.22,-61.34},{-5192.53,-1744.48,-62.71},{-5122.50,-1753.42,-66.77},{-5015.82,-1760.43,-65.64},{-4969.95,-1725.92,-62.18},{-4944.25,-1688.95,-56.94},{-4961.72,-1633.70,-45.29},{-4974.54,-1537.84,-47.85},{-4895.07,-1473.06,-50.16},{-4891.93,-1415.95,-52.21},{-4860.45,-1399.49,-53.35},{-4782.56,-1345.33,-53.72},{-4772.05,-1303.93,-48.40},{-4757.39,-1281.71,-49.81},{-4746.03,-1244.71,-54.28},{-4759.88,-1203.38,-52.37},{-4735.70,-1147.40,-39.84},{-4718.40,-1104.05,-54.64},{-4661.68,-1107.31,-52.68},{-4599.16,-1075.96,-48.00},{-4533.70,-1012.65,-57.13},{-4451.82,-963.17,-57.70},{-4431.47,-943.45,-57.70},{-4375.38,-841.01,-57.65},{-4291.97,-784.99,-53.04},{-4272.95,-758.71,-42.80},{-4272.73,-678.10,-21.56},{-4300.96,-628.99,-8.95},{-4346.10,-595.80,1.80},{-4352.20,-550.54,8.20},{-4310.85,-480.43,26.13},{-4296.72,-385.26,40.81},{-4290.60,-319.00,52.99},{-4260.54,-286.57,54.72},{-4243.90,-197.83,58.93},{-4255.88,-132.63,61.05},{-4299.83,-82.64,62.28},{-4314.01,-38.85,62.56},{-4292.97,4.64,57.59},{-4245.10,69.76,55.61},{-4219.73,130.13,56.74},{-4227.14,215.90,56.02},{-4241.28,272.14,53.95}
        }
    end
    Map_1441()
    local function Map_1444() -- 菲拉斯
        Sever_Map["菲拉斯"] = {}
        Sever_Map["菲拉斯"]["菲拉斯 - 千针石林"] = Reverse_Table(Sever_Map["千针石林"]["千针石林 - 菲拉斯"])
        Sever_Map["菲拉斯"]["菲拉斯 - 凄凉之地"] = 
        {
        {-4527.02,413.20,45.62},{-4615.69,428.04,36.35},{-4628.25,520.20,37.08},{-4656.35,596.25,45.76},{-4683.98,723.40,76.32},{-4662.63,763.28,83.80},{-4648.43,837.90,82.30},{-4648.41,869.74,86.36},{-4675.76,904.27,87.20},{-4693.58,930.86,96.79},{-4687.51,957.11,98.57},{-4714.43,1005.80,107.20},{-4731.39,1012.91,109.10},{-4808.86,1043.61,103.75},{-4847.96,1060.79,92.99},{-4851.24,1085.12,91.16},{-4815.35,1149.07,90.03},{-4821.31,1188.94,87.33},{-4852.67,1257.16,82.84},{-4843.36,1318.66,81.20},{-4833.19,1388.50,79.74},{-4753.59,1468.80,93.13},{-4744.20,1664.43,89.27},{-4691.67,1810.66,91.60},{-4668.37,1864.29,85.11},{-4676.75,1919.31,77.85},{-4680.32,1937.58,73.10},{-4579.58,2017.51,48.74},{-4540.84,2031.09,45.30},{-4507.56,2039.80,51.59},{-4470.81,2048.69,45.58},{-4424.56,2077.71,48.02},{-4323.75,2107.52,70.06},{-4218.15,2100.60,83.06},{-4140.72,2094.87,89.26},{-4049.39,2116.17,110.87},{-3999.08,2093.95,119.99},{-3899.02,2078.84,120.31},{-3846.52,2119.49,113.93},{-3807.60,2121.39,113.96},{-3709.61,2164.33,88.18},{-3644.02,2178.20,69.66},{-3588.40,2146.16,60.63},{-3486.14,2083.92,40.16},{-3438.97,2092.86,38.90},{-3343.84,2220.13,32.28},{-3195.06,2216.95,34.24},{-3055.69,2216.99,42.92},{-2938.15,2250.46,45.75},{-2863.00,2256.64,47.58},{-2779.13,2317.67,54.31},{-2700.38,2320.49,71.23},{-2605.07,2256.98,86.98},{-2536.27,2264.41,105.49},{-2496.57,2283.44,114.65},{-2440.78,2335.26,114.63},{-2370.42,2364.96,106.67},{-2219.37,2403.76,53.98},{-2108.87,2352.18,59.92},{-2000.95,2445.56,59.82},{-1896.22,2433.10,59.82},{-1838.16,2235.86,59.82},{-1800.71,2181.07,59.82},{-1808.05,2091.60,62.99},{-1806.20,1972.82,59.23},{-1730.96,1917.77,59.20},{-1671.35,1844.47,58.93},{-1578.90,1728.08,58.92},{-1449.51,1556.62,58.93},{-1299.80,1571.33,58.98},{-1197.35,1648.70,63.43},{-1130.99,1714.10,62.84},{-1076.90,1867.56,61.73},{-1086.55,1930.92,61.21},{-1012.17,2007.95,58.49},{-844.02,1976.12,80.56},{-775.67,1936.50,88.44},{-677.26,1843.47,88.44},{-693.32,1623.45,88.37}
        }
    end
    Map_1444()

    local function Map_1443() -- 凄凉之地
        Sever_Map["凄凉之地"] = {}
        Sever_Map["凄凉之地"]["凄凉之地 - 菲拉斯"] = Reverse_Table(Sever_Map["菲拉斯"]["菲拉斯 - 凄凉之地"])
        Sever_Map["凄凉之地"]["凄凉之地 - 石爪山脉"] = 
        {
        {-655.35,1513.59,88.37},{-531.71,1452.89,88.37},{-435.24,1414.63,94.94},{-321.74,1387.31,95.54},{-270.75,1399.72,95.36},{-140.42,1423.71,98.03},{-90.07,1466.59,99.10},{-55.20,1498.16,99.75},{-11.52,1549.10,102.18},{37.40,1627.32,100.32},{56.53,1703.60,90.38},{88.49,1734.47,86.54},{158.60,1795.73,86.23},{265.71,1833.10,86.23},{307.04,1824.38,79.06},{492.23,1761.15,6.93},{646.62,1599.72,-18.13},{806.08,1560.91,-28.37},{916.92,1531.35,-13.64},{988.09,1537.07,-1.05},{1030.52,1540.87,10.00},{1154.73,1523.08,43.66},{1259.27,1412.83,86.57},{1369.02,1419.23,118.87},{1467.31,1409.73,137.52},{1521.01,1342.42,157.14},{1531.05,1180.10,150.14},{1508.08,1082.24,147.39},{1502.10,975.57,138.33},{1441.45,915.72,138.33},{1402.77,787.56,144.15},{1297.81,730.69,177.77},{1212.61,716.93,169.57},{1168.83,665.82,147.30},{1072.86,678.17,129.94},{1026.71,649.72,119.64},{908.70,652.89,96.79}
        }
    end
    Map_1443()

    local function Map_1442() -- 石爪山脉
        Sever_Map["石爪山脉"] = {}
        Sever_Map["石爪山脉"]["石爪山脉 - 凄凉之地"] = Reverse_Table(Sever_Map["凄凉之地"]["凄凉之地 - 石爪山脉"])
        Sever_Map["石爪山脉"]["石爪山脉 - 贫瘠之地"] = 
        {
        {872.92,608.26,89.06},{840.41,549.00,79.84},{817.99,486.59,66.80},{724.74,400.99,62.88},{657.26,373.60,53.80},{597.22,327.54,46.45},{556.64,322.43,50.30},{497.19,333.97,51.42},{418.88,337.83,46.05},{394.85,318.33,43.55},{280.36,314.95,39.59},{241.52,269.77,50.95},{188.93,189.75,51.68},{182.53,145.37,45.93},{157.37,112.92,37.29},{155.27,35.07,29.99},{96.50,-63.44,20.71},{73.54,-135.96,10.39},{33.79,-167.78,15.60},{0.79,-242.26,6.64},{-31.35,-274.17,-2.56},{-31.42,-344.46,-12.28},{-59.19,-436.73,-35.74},{-58.07,-477.84,-45.20},{-29.92,-552.41,-46.32},{-1.78,-585.69,-46.34},{-9.23,-626.77,-41.07},{-31.10,-654.98,-30.14},{-91.20,-673.69,-9.09},{-167.43,-691.62,0.15},{-183.75,-697.09,0.32},{-207.92,-720.61,2.03},{-241.58,-797.93,7.71},{-248.61,-924.01,8.72},{-253.53,-1083.84,37.87},{-281.37,-1189.91,64.79},{-348.31,-1280.44,88.82},{-386.43,-1350.25,91.76},{-410.07,-1392.00,91.70},{-467.99,-1428.10,91.70},{-527.47,-1569.20,91.67},{-520.28,-1660.92,91.67},{-438.26,-1819.61,95.79},{-408.20,-1933.86,95.84},{-312.58,-2030.43,92.53},{-280.80,-2216.86,95.80},{-315.53,-2336.68,93.68},{-339.83,-2365.50,91.70},{-348.64,-2501.36,94.01}
        }
    end
    Map_1442()

    local function Map_1413() -- 贫瘠之地
        Sever_Map["贫瘠之地"] = {}
        Sever_Map["贫瘠之地"]["贫瘠之地 - 石爪山脉"] = Reverse_Table(Sever_Map["石爪山脉"]["石爪山脉 - 贫瘠之地"])
        Sever_Map["贫瘠之地"]["贫瘠之地 - 莫高雷"] = 
        {
        {-678.95,-2640.05,95.82},{-819.04,-2575.69,91.67},{-898.85,-2522.47,95.56},{-1028.88,-2468.44,91.67},{-1157.75,-2454.46,95.05},{-1312.22,-2476.02,95.80},{-1388.43,-2503.63,95.79},{-1581.45,-2540.75,91.76},{-1634.25,-2518.82,91.67},{-1709.10,-2557.88,91.67},{-1789.21,-2531.04,91.67},{-2281.58,-2157.93,95.79},{-2288.98,-2130.01,95.79},{-2329.58,-1965.08,95.86},{-2350.73,-1898.71,95.78},{-2350.02,-1477.36,38.12},{-2431.39,-1102.74,-9.40}
        }

        Sever_Map["贫瘠之地"]["贫瘠之地 - 尘泥沼泽"] = 
        {
        {-678.95,-2640.05,95.82},{-819.04,-2575.69,91.67},{-898.85,-2522.47,95.56},{-1028.88,-2468.44,91.67},{-1157.75,-2454.46,95.05},{-1312.22,-2476.02,95.80},{-1388.43,-2503.63,95.79},{-1581.45,-2540.75,91.76},{-1634.25,-2518.82,91.67},{-1709.10,-2557.88,91.67},{-1789.21,-2531.04,91.67},{-2281.58,-2157.93,95.79},{-2362.04,-2160.15,92.38},{-2564.85,-2163.70,94.18},{-2769.16,-2193.96,95.78},{-2919.95,-2088.43,96.36},{-3097.83,-2050.20,92.02},{-3486.71,-2056.60,96.42},{-3525.26,-2163.10,91.67},{-3659.11,-2350.95,91.67},{-3688.52,-2573.19,56.37},{-3669.21,-2645.41,42.89},{-3655.11,-2720.74,33.82},{-3610.84,-2745.38,32.69},{-3563.39,-2797.72,30.51},{-3490.74,-2868.40,31.04},{-3459.90,-2887.82,32.69},{-3436.20,-2912.87,30.98},{-3426.55,-2971.53,31.01},{-3358.71,-3046.14,32.65}
        }

        Sever_Map["贫瘠之地"]["贫瘠之地 - 杜隆塔尔"] = 
        {
        {-219.47,-2688.71,95.97},{-111.18,-2693.35,95.97},{47.25,-2724.13,91.67},{71.69,-2812.61,96.09},{106.72,-2973.29,95.28},{114.23,-3072.69,95.83},{140.68,-3201.69,80.91},{231.76,-3443.02,29.44},{268.49,-3515.32,26.60},{314.14,-3704.41,26.74},{312.66,-3823.21,23.88},{292.59,-3932.54,32.02},{290.70,-4015.26,31.70},{283.12,-4141.36,29.21},{310.02,-4204.97,26.96},{327.87,-4287.34,23.48},{322.80,-4364.73,20.97},{304.82,-4387.37,19.24},{238.45,-4520.21,14.17},{233.02,-4559.03,14.32}
        }

        Sever_Map["贫瘠之地"]["贫瘠之地 - 灰谷"] = 
        {
        {-247.76,-2691.97,95.95},{-60.81,-2696.62,95.82},{58.01,-2713.66,91.67},{192.26,-2697.28,91.67},{494.21,-2603.91,91.71},{653.99,-2428.13,91.67},{761.73,-2280.29,91.68},{948.49,-2284.18,91.67},{1079.92,-2309.03,91.69},{1201.09,-2305.53,91.70},{1263.62,-2223.09,91.91},{1319.34,-2250.02,91.67},{1441.67,-2254.10,89.90},{1640.90,-2199.67,90.78},{1831.31,-2175.06,96.55},{1925.82,-2170.04,94.03}
        }
    end
    Map_1413()

    local function Map_1412() -- 莫高雷
        Sever_Map["莫高雷"] = {}
        Sever_Map["莫高雷"]["莫高雷 - 贫瘠之地"] = Reverse_Table(Sever_Map["贫瘠之地"]["贫瘠之地 - 莫高雷"])
    end
    Map_1412()

    local function Map_1445() -- 尘泥沼泽
        Sever_Map["尘泥沼泽"] = {}
        Sever_Map["尘泥沼泽"]["尘泥沼泽 - 贫瘠之地"] = Reverse_Table(Sever_Map["贫瘠之地"]["贫瘠之地 - 尘泥沼泽"])
    end
    Map_1445()

    local function Map_1411() -- 杜隆塔尔
        Sever_Map["杜隆塔尔"] = {}
        Sever_Map["杜隆塔尔"]["杜隆塔尔 - 贫瘠之地"] = Reverse_Table(Sever_Map["贫瘠之地"]["贫瘠之地 - 杜隆塔尔"])
        Sever_Map["杜隆塔尔"]["杜隆塔尔 - 奥格瑞玛"] = 
        {
        {456.08,-4732.64,6.76},{590.44,-4733.25,-8.17},{686.85,-4700.05,-8.52},{767.17,-4608.93,-0.74},{817.32,-4537.87,4.65},{1036.68,-4438.73,13.25},{1190.92,-4400.41,22.84},{1327.64,-4385.54,26.22},{1427.61,-4367.71,25.24},{1437.34,-4419.89,25.24},{1505.04,-4413.25,20.70},{1555.64,-4403.69,7.34}
        }
    end
    Map_1411()

    local function Map_1454() -- 奥格瑞玛
        Sever_Map["奥格瑞玛"] = {}
        Sever_Map["奥格瑞玛"]["奥格瑞玛 - 杜隆塔尔"] = Reverse_Table(Sever_Map["杜隆塔尔"]["杜隆塔尔 - 奥格瑞玛"])
    end
    Map_1454()

    local function Map_1440() -- 灰谷
        Sever_Map["灰谷"] = {}
        Sever_Map["灰谷"]["灰谷 - 贫瘠之地"] = Reverse_Table(Sever_Map["贫瘠之地"]["贫瘠之地 - 灰谷"])
        Sever_Map["灰谷"]["灰谷 - 艾萨拉"] = 
        {
        {1944.04,-2246.70,92.95},{2015.62,-2431.78,90.83},{2119.37,-2576.46,101.66},{2233.34,-2674.52,113.36},{2411.00,-2714.35,138.57},{2499.92,-2779.70,153.23},{2536.27,-2837.48,158.67},{2545.61,-2884.01,160.08},{2686.32,-3115.36,158.51},{2753.18,-3345.86,127.57},{2846.78,-3490.22,108.64},{2887.66,-3614.35,95.04},{2866.22,-3704.89,90.40},{2839.19,-3758.23,82.14},{2796.38,-3816.15,83.79},{2744.89,-3930.39,89.10},{2757.20,-4043.29,96.54},{2812.65,-4115.79,96.35},{2915.01,-4207.25,97.79},{3020.28,-4284.94,91.03},{3062.19,-4332.25,90.94}
        }

        Sever_Map["灰谷"]["灰谷 - 黑海岸"] = 
        {
        {1931.19,-2160.80,93.54},{1996.21,-1929.61,98.31},{2061.10,-1861.17,98.50},{2227.13,-1746.64,108.15},{2320.86,-1671.88,124.09},{2368.32,-1527.07,125.29},{2404.11,-1411.40,125.28},{2442.04,-1270.65,125.18},{2450.46,-1206.61,124.24},{2462.08,-1173.71,125.02},{2520.75,-991.59,129.31},{2505.71,-865.28,135.29},{2479.25,-820.45,137.76},{2482.18,-705.13,122.93},{2460.29,-663.74,117.01},{2443.75,-544.81,115.25},{2465.54,-500.05,114.81},{2525.22,-475.97,113.54},{2560.15,-471.53,109.22},{2601.44,-462.10,107.22},{2642.78,-443.45,107.23},{2679.71,-417.89,107.10},{2730.36,-370.96,107.09},{2800.38,-281.93,107.11},{2835.45,-238.85,106.06},{2866.04,-170.22,102.94},{2867.80,-86.19,101.16},{2830.05,9.58,94.37},{2830.77,164.92,101.35},{2861.10,181.18,95.97},{2913.34,188.18,88.95},{2981.13,150.68,71.98},{3019.11,150.32,63.75},{3071.41,205.13,47.40},{3113.85,224.62,33.65},{3245.24,227.62,10.14},{3333.87,214.65,12.99},{3459.42,217.47,12.94},{3564.07,214.53,5.23},{3608.16,217.02,1.02},{3690.91,192.48,4.42},{3731.91,174.13,6.68},{3782.88,142.95,8.75},{3873.72,67.76,15.48},{3961.14,7.84,16.88},{4034.50,-3.30,16.34},{4125.12,33.24,20.56},{4277.17,139.10,43.41},{4393.21,203.50,51.29},{4488.07,267.87,59.51},{4609.33,285.28,53.39},{4672.88,272.81,49.62},{4731.22,244.55,48.20},{4827.32,221.39,49.44},{4901.77,218.43,46.21}
        }

        Sever_Map["灰谷"]["灰谷 - 费伍德森林"] = 
        {
        {2260.70,-1740.94,111.65},{2334.52,-1775.79,119.19},{2430.36,-1820.22,127.84},{2457.41,-1848.55,132.33},{2507.62,-1861.25,137.94},{2621.70,-1947.86,152.48},{2671.15,-1981.81,156.74},{2703.33,-1987.07,158.07},{2812.83,-1960.21,162.46},{2902.42,-1887.80,163.30},{2973.51,-1824.54,167.31},{3206.15,-1690.80,164.59},{3297.40,-1545.89,165.15},{3314.93,-1529.40,164.68},{3427.72,-1523.51,165.65},{3493.67,-1516.53,167.01},{3608.17,-1510.62,172.29},{3652.36,-1497.63,181.17},{3717.44,-1485.42,191.67},{3751.38,-1467.93,197.69},{3802.88,-1420.57,201.78},{3870.54,-1343.89,212.43},{3894.90,-1290.99,219.61},{3910.38,-1265.58,223.92},{3916.38,-1152.69,243.10},{3923.00,-1094.66,252.59},{3939.90,-1084.32,254.55},{4005.55,-1076.26,260.49},{4039.46,-1056.72,263.61},{4085.37,-1024.72,270.62},{4275.78,-852.76,284.43},{4368.05,-851.05,290.38},{4487.34,-851.07,296.55},{4564.80,-849.04,300.23},{4636.17,-806.59,299.88},{4693.25,-781.51,299.94},{4732.29,-772.13,299.99},{4772.49,-747.78,299.96},{4881.01,-738.24,303.33},{4946.29,-740.19,308.80},{5066.97,-755.83,325.08},{5110.08,-746.12,329.37},{5174.80,-745.08,338.87},{5209.50,-719.01,342.75},{5252.69,-715.97,343.07},{5307.40,-715.12,343.95},{5350.35,-691.17,348.28},{5444.39,-615.85,353.23},{5499.33,-604.37,355.55}
        }
    end
    Map_1440()

    local function Map_1447() -- 艾萨拉
        Sever_Map["艾萨拉"] = {}
        Sever_Map["艾萨拉"]["艾萨拉 - 灰谷"] = Reverse_Table(Sever_Map["灰谷"]["灰谷 - 艾萨拉"])
    end
    Map_1447()

    local function Map_1439() -- 黑海岸
        Sever_Map["黑海岸"] = {}
        Sever_Map["黑海岸"]["黑海岸 - 灰谷"] = Reverse_Table(Sever_Map["灰谷"]["灰谷 - 黑海岸"])
    end
    Map_1439()

    local function Map_1448() -- 费伍德森林
        Sever_Map["费伍德森林"] = {}
        Sever_Map["费伍德森林"]["费伍德森林 - 灰谷"] = Reverse_Table(Sever_Map["灰谷"]["灰谷 - 费伍德森林"])
        Sever_Map["费伍德森林"]["费伍德森林 - 冬泉谷"] = 
        {
        {5600.66,-585.90,363.01},{5670.06,-604.18,364.61},{5709.31,-623.33,366.35},{5787.23,-651.85,371.80},{5879.85,-674.41,376.97},{6006.30,-705.21,390.73},{6112.41,-724.35,399.62},{6173.68,-717.55,403.31},{6206.70,-720.85,407.59},{6219.43,-769.69,415.06},{6230.49,-815.64,418.15},{6243.20,-866.19,415.91},{6263.06,-939.98,415.29},{6333.66,-1011.77,421.98},{6413.95,-1048.31,426.68},{6490.78,-1108.51,434.08},{6558.30,-1177.17,439.81},{6610.86,-1278.89,450.22},{6638.24,-1427.06,466.13},{6632.75,-1503.92,473.22},{6585.49,-1603.81,491.22},{6526.04,-1696.81,503.90},{6520.05,-1837.57,528.03},{6550.92,-2003.24,558.41},{6550.74,-2055.57,569.87},{6572.35,-2077.43,573.39},{6615.51,-2079.85,583.93},{6721.51,-2082.39,611.94},{6764.44,-2082.22,622.31},{6797.57,-2084.34,624.17},{6841.00,-2108.58,625.54},{6877.56,-2114.54,619.97},{6926.10,-2084.48,616.34},{6997.61,-2069.59,608.73},{7023.64,-2160.73,594.93},{6996.66,-2196.78,586.45},{6969.89,-2256.05,585.72},{6936.83,-2264.16,589.77},{6889.43,-2309.42,583.60},{6834.66,-2313.06,580.89},{6715.90,-2342.10,570.23},{6680.33,-2381.52,557.98},{6678.36,-2439.82,541.75},{6656.65,-2536.42,529.80},{6537.88,-2897.90,588.83},{6601.00,-3181.64,605.05},{6641.11,-3374.58,640.74}
        }
    end
    Map_1448()

    local function Map_1452() -- 冬泉谷
        Sever_Map["冬泉谷"] = {}
        Sever_Map["冬泉谷"]["冬泉谷 - 费伍德森林"] = Reverse_Table(Sever_Map["费伍德森林"]["费伍德森林 - 冬泉谷"])
    end
    Map_1452()


    local function Map_1434() -- 荆棘谷
        Sever_Map["荆棘谷"] = {}
        Sever_Map["荆棘谷"]["荆棘谷 - 暮色森林"] = 
        {
        {-12827.55,-302.51,9.96},{-12820.08,-312.00,10.30},{-12811.42,-322.99,10.15},{-12804.62,-331.62,10.10},{-12797.88,-340.18,10.10},{-12790.04,-348.10,10.10},{-12782.27,-354.35,10.14},{-12773.53,-360.84,10.30},{-12764.69,-365.04,10.34},{-12756.28,-369.04,10.55},{-12743.95,-373.42,10.14},{-12731.15,-374.14,10.10},{-12723.63,-373.85,10.10},{-12713.49,-373.64,10.11},{-12703.72,-375.18,10.10},{-12690.86,-375.56,10.10},{-12680.92,-376.50,10.10},{-12675.45,-377.02,10.20},{-12668.18,-377.71,10.10},{-12659.00,-376.64,10.10},{-12648.47,-377.21,10.10},{-12637.71,-377.79,10.10},{-12627.09,-378.36,10.10},{-12616.56,-378.93,10.10},{-12605.16,-379.54,10.10},{-12593.47,-380.17,10.11},{-12582.32,-380.77,10.11},{-12570.72,-381.39,10.21},{-12559.53,-381.99,10.10},{-12548.54,-382.94,10.10},{-12532.94,-386.26,10.23},{-12521.71,-389.29,10.27},{-12512.74,-392.90,10.57},{-12500.80,-399.19,11.22},{-12492.44,-405.20,11.50},{-12478.53,-418.87,11.11},{-12471.87,-428.03,11.41},{-12467.10,-439.01,11.43},{-12463.26,-449.65,11.76},{-12459.00,-461.47,11.44},{-12454.23,-474.69,11.11},{-12450.90,-486.63,10.54},{-12448.39,-498.74,10.29},{-12445.85,-510.98,10.10},{-12442.71,-521.68,10.10},{-12436.54,-533.89,10.33},{-12429.04,-545.18,11.29},{-12421.51,-556.52,11.19},{-12413.77,-568.17,10.90},{-12405.47,-575.91,11.20},{-12393.90,-580.43,13.02},{-12380.23,-581.98,15.41},{-12369.67,-582.47,17.18},{-12357.46,-583.04,19.23},{-12347.53,-583.51,20.87},{-12336.06,-584.04,22.83},{-12324.51,-584.58,24.75},{-12313.53,-583.63,26.51},{-12301.01,-581.81,28.56},{-12290.65,-580.31,28.77},{-12284.12,-577.46,28.74},{-12277.94,-574.77,28.79},{-12271.28,-571.86,28.94},{-12264.69,-568.99,28.95},{-12255.04,-564.78,28.80},{-12248.84,-559.53,28.83},{-12243.05,-554.62,28.84},{-12236.22,-548.82,28.78},{-12230.64,-543.21,28.88},{-12225.61,-536.57,28.99},{-12220.81,-528.30,28.82},{-12216.46,-519.47,28.72},{-12212.11,-514.03,28.76},{-12209.13,-506.40,28.78},{-12203.81,-499.44,28.86},{-12197.71,-491.46,28.97},{-12194.21,-484.33,29.13},{-12189.29,-476.99,29.15},{-12184.29,-469.50,29.13},{-12178.11,-460.26,29.06},{-12172.43,-451.77,29.97},{-12168.38,-445.18,30.35},{-12165.42,-436.08,30.35},{-12162.90,-427.98,30.35},{-12160.18,-419.23,30.35},{-12159.24,-412.46,30.35},{-12158.35,-406.01,30.35},{-12160.44,-393.36,31.12},{-12162.02,-383.79,31.62},{-12163.34,-375.85,27.27},{-12164.75,-367.31,23.99},{-12166.00,-359.72,22.19},{-12167.41,-351.19,21.50},{-12169.12,-340.83,21.97},{-12171.40,-333.01,23.63},{-12174.10,-323.72,27.10},{-12174.80,-316.80,31.30},{-12175.61,-308.68,31.52},{-12176.69,-297.99,30.55},{-12174.82,-289.34,30.35},{-12171.06,-282.33,30.35},{-12167.20,-271.22,30.41},{-12162.18,-256.93,30.35},{-12156.21,-245.25,30.35},{-12151.95,-237.42,30.35},{-12148.53,-231.16,30.35},{-12144.86,-224.42,30.35},{-12141.49,-218.24,30.35},{-12138.02,-211.89,30.35},{-12134.54,-205.49,30.35},{-12131.16,-199.29,30.35},{-12127.38,-192.36,30.35},{-12123.79,-185.78,30.35},{-12119.50,-177.91,30.35},{-12115.87,-171.24,30.53},{-12112.36,-166.03,31.05},{-12107.03,-161.65,31.78},{-12101.87,-154.63,32.87},{-12096.48,-150.63,33.71},{-12089.22,-145.25,34.88},{-12083.30,-140.86,35.82},{-12078.65,-137.41,36.65},{-12070.44,-131.32,37.98},{-12063.36,-128.89,39.12},{-12057.99,-127.05,39.58},{-12050.71,-125.13,39.63},{-12044.26,-123.43,39.63},{-12038.10,-123.62,39.63},{-12032.03,-122.22,39.63},{-12025.01,-123.07,39.63},{-12018.69,-122.25,39.63},{-12015.38,-120.38,39.63},{-12008.13,-116.98,39.63},{-12000.78,-111.98,41.81},{-11993.77,-107.20,40.84},{-11986.77,-102.43,36.57},{-11980.56,-98.20,33.88},{-11974.51,-94.08,32.21},{-11966.72,-88.77,31.53},{-11958.67,-84.78,31.95},{-11954.18,-79.83,33.27},{-11948.28,-76.77,35.25},{-11941.53,-73.27,38.64},{-11935.13,-68.99,42.51},{-11927.99,-64.23,40.58},{-11918.50,-57.89,39.73},{-11909.24,-54.51,39.73},{-11901.52,-51.69,39.72},{-11892.63,-48.45,39.72},{-11884.42,-49.50,39.78},{-11875.63,-48.07,39.75},{-11867.76,-46.79,39.73},{-11859.16,-45.39,39.73},{-11849.72,-46.60,39.74},{-11839.89,-47.86,39.73},{-11829.36,-49.21,39.73},{-11818.85,-50.56,39.72},{-11811.97,-53.68,39.72},{-11806.79,-60.01,39.72},{-11800.83,-67.29,39.83},{-11795.30,-74.04,39.73},{-11789.77,-80.80,39.74},{-11782.67,-90.26,39.73},{-11777.44,-98.00,41.37},{-11770.99,-109.81,39.18},{-11765.54,-119.38,34.38},{-11761.83,-127.27,32.38},{-11755.94,-139.84,31.82},{-11749.03,-150.20,33.73},{-11744.85,-158.44,36.94},{-11741.11,-165.82,41.21},{-11736.64,-174.65,41.43},{-11728.30,-185.79,39.56},{-11723.27,-193.38,39.56},{-11716.82,-199.87,39.56},{-11710.22,-206.54,39.56},{-11703.80,-213.01,39.56},{-11695.54,-221.34,39.56},{-11684.67,-228.55,40.57},{-11675.85,-234.39,37.96},{-11668.38,-239.35,33.93},{-11659.64,-245.14,31.06},{-11649.12,-252.12,30.19},{-11639.43,-258.54,31.47},{-11627.91,-266.18,35.87},{-11621.32,-270.55,40.68},{-11611.05,-277.36,39.17},{-11601.29,-283.83,36.71},{-11592.44,-289.70,35.90},{-11581.72,-296.81,35.67},{-11572.48,-302.93,35.67},{-11562.23,-309.73,35.67},{-11552.91,-313.36,35.69},{-11539.30,-317.34,37.00},{-11527.06,-318.01,36.67},{-11514.24,-313.78,36.39},{-11502.70,-308.49,35.89},{-11488.88,-300.09,35.75},{-11476.35,-292.09,36.30},{-11459.21,-286.39,40.52},{-11445.58,-285.83,44.56},{-11430.12,-286.08,49.47},{-11416.78,-286.29,53.65},{-11403.40,-286.51,57.01},{-11396.24,-290.48,58.94},{-11389.66,-301.62,62.22},{-11384.41,-316.07,64.80},{-11378.86,-331.35,65.43},{-11373.64,-345.72,65.78},{-11368.25,-360.58,65.82},{-11364.05,-372.14,65.43},{-11356.62,-376.54,65.30},{-11348.95,-379.83,65.68},{-11335.00,-375.26,65.39},{-11320.02,-373.99,65.40},{-11305.40,-370.76,65.23},{-11289.98,-370.27,63.96},{-11272.02,-371.79,61.64},{-11260.29,-373.55,59.53},{-11240.75,-376.50,56.03},{-11226.58,-378.64,53.38},{-11211.95,-380.84,50.14},{-11195.34,-381.54,48.69},{-11178.67,-380.52,47.02},{-11162.42,-379.48,46.71},{-11143.90,-378.12,46.96},{-11123.71,-376.07,45.63},{-11105.46,-374.51,44.80},{-11086.94,-373.99,44.42},{-11063.50,-372.48,45.16},{-11041.71,-365.70,45.03},{-11017.02,-363.01,43.89},{-10994.52,-362.75,42.44},{-10975.61,-362.17,41.40},{-10959.31,-361.68,40.41},{-10942.26,-361.16,39.80},{-10931.11,-360.83,39.59},{-10917.77,-361.58,39.72},{-10906.17,-365.72,39.71}
        }
    end
    Map_1434()

    local function Map_1431() -- 暮色森林
        Sever_Map["暮色森林"] = {}
        Sever_Map["暮色森林"]["暮色森林 - 荆棘谷"] = Reverse_Table(Sever_Map["荆棘谷"]["荆棘谷 - 暮色森林"])
        Sever_Map["暮色森林"]["暮色森林 - 西部荒野"] = 
        {
        {-10901.41,-367.66,39.60},{-10879.44,-327.10,37.79},{-10864.12,-286.23,38.22},{-10849.65,-226.84,38.39},{-10837.87,-175.36,34.00},{-10830.64,-154.58,32.32},{-10817.90,-117.98,29.80},{-10807.66,-88.56,29.06},{-10796.34,-56.02,29.15},{-10786.68,-18.60,29.44},{-10772.61,20.66,29.09},{-10756.69,63.45,28.59},{-10752.73,103.89,28.39},{-10758.90,139.12,29.18},{-10772.01,169.40,29.62},{-10785.25,201.96,30.05},{-10797.90,252.13,30.48},{-10806.33,296.50,31.13},{-10811.64,330.44,30.17},{-10814.41,375.87,29.60},{-10819.64,425.80,29.33},{-10825.15,457.79,29.50},{-10839.87,499.69,30.11},{-10849.61,533.93,30.37},{-10859.62,568.68,30.49},{-10863.91,601.80,31.35},{-10865.72,639.31,31.35},{-10867.26,670.70,30.99},{-10874.71,720.65,30.96},{-10907.72,785.49,30.72},{-10926.44,821.48,31.51},{-10916.05,878.92,31.95},{-10921.29,906.05,32.17},{-10939.81,928.82,31.53},{-10945.34,948.01,31.62},{-10938.04,966.49,33.01},{-10923.28,986.03,35.33},{-10905.87,995.96,36.08},{-10868.86,1004.36,31.73},{-10824.15,1012.56,32.82},{-10785.04,1016.50,32.81},{-10728.69,1027.24,33.25},{-10680.22,1030.94,32.59},{-10624.72,1006.00,32.53},{-10544.52,967.17,41.42},{-10510.29,958.93,40.73},{-10467.56,960.56,35.82},{-10430.01,981.11,34.51},{-10397.08,986.47,31.73},{-10324.54,974.07,31.14},{-10289.49,967.88,31.12},{-10261.07,986.23,31.27}
        }

        Sever_Map["暮色森林"]["暮色森林 - 逆风小径"] = 
        {
        {-10904.39,-381.22,40.27},{-10905.08,-401.87,41.00},{-10904.96,-419.52,42.01},{-10906.49,-448.57,44.39},{-10909.06,-468.63,47.38},{-10910.03,-494.91,50.68},{-10912.23,-516.11,52.93},{-10920.71,-551.03,53.92},{-10934.83,-577.09,53.83},{-10950.69,-604.88,55.28},{-10956.78,-638.11,55.15},{-10942.06,-669.32,55.78},{-10918.52,-707.41,55.65},{-10899.22,-734.69,55.15},{-10863.06,-774.83,55.87},{-10832.61,-819.77,56.24},{-10813.62,-861.65,55.90},{-10796.75,-919.97,55.77},{-10801.52,-954.47,56.45},{-10805.40,-993.83,53.50},{-10802.46,-1034.43,46.30},{-10789.44,-1073.42,38.00},{-10778.21,-1105.81,31.48},{-10763.80,-1134.92,27.21},{-10733.40,-1160.95,26.85},{-10698.73,-1181.66,26.78},{-10665.39,-1191.93,28.06},{-10636.08,-1187.56,28.78},{-10600.05,-1180.21,28.08},{-10574.60,-1180.30,28.02},{-10565.78,-1188.08,27.86},{-10558.10,-1213.90,27.50},{-10552.76,-1240.19,29.53},{-10538.54,-1272.88,36.58},{-10535.23,-1302.41,41.47},{-10543.09,-1347.74,50.26},{-10537.31,-1377.90,56.13},{-10521.79,-1393.66,61.53},{-10497.12,-1412.83,64.17},{-10475.59,-1430.85,66.28},{-10456.76,-1455.58,69.86},{-10449.24,-1485.41,73.90},{-10450.69,-1517.87,74.70},{-10454.95,-1556.48,73.81},{-10463.18,-1617.56,73.39},{-10466.25,-1660.81,77.32},{-10461.77,-1704.72,82.29},{-10455.48,-1745.52,88.35},{-10443.52,-1773.02,94.01},{-10432.85,-1796.46,97.48},{-10431.97,-1820.18,100.07},{-10438.88,-1847.05,102.81},{-10441.12,-1896.03,103.06},{-10439.46,-1959.26,103.07},{-10435.30,-1984.37,100.80}
        }

        Sever_Map["暮色森林"]["暮色森林 - 赤脊山"] = 
        {
        {-10902.84,-371.64,39.81},{-10902.35,-415.02,41.71},{-10901.88,-436.16,43.26},{-10888.07,-451.14,42.62},{-10866.90,-470.49,42.30},{-10849.21,-488.17,43.00},{-10829.24,-509.29,42.49},{-10807.52,-539.65,38.24},{-10776.49,-583.04,37.50},{-10756.65,-620.96,42.10},{-10750.98,-657.96,41.31},{-10722.09,-732.60,53.67},{-10707.86,-736.63,61.72},{-10677.94,-749.21,63.08},{-10660.45,-765.89,63.85},{-10639.33,-787.87,58.66},{-10616.62,-811.51,54.64},{-10597.04,-831.88,53.74},{-10573.31,-856.58,48.57},{-10550.20,-880.64,46.93},{-10529.07,-902.63,47.52},{-10507.69,-924.88,44.68},{-10492.48,-945.06,44.20},{-10476.19,-957.31,45.24},{-10447.75,-968.25,45.23},{-10424.22,-977.29,45.48},{-10395.32,-988.41,46.91},{-10361.27,-1001.50,49.34},{-10335.10,-1011.57,46.39},{-10300.61,-1024.83,43.46},{-10271.57,-1038.71,43.39},{-10249.47,-1057.04,35.14},{-10218.62,-1086.96,36.66},{-10197.94,-1117.77,30.42},{-10178.79,-1137.67,27.43},{-10150.78,-1156.26,24.56},{-10132.55,-1173.67,25.45},{-10115.21,-1207.38,26.00},{-10098.66,-1242.69,28.26},{-10087.75,-1279.89,31.81},{-10082.62,-1315.29,31.84},{-10078.41,-1356.82,31.04},{-10082.44,-1387.02,29.63},{-10082.50,-1427.22,28.94},{-10082.18,-1454.91,28.61},{-10075.03,-1483.77,28.91},{-10061.23,-1510.93,28.56},{-10041.82,-1531.51,28.53},{-10021.05,-1553.58,27.86},{-10003.93,-1584.00,26.51},{-9986.81,-1615.21,27.53},{-9962.92,-1652.66,26.27},{-9937.63,-1678.70,24.23},{-9915.51,-1699.64,23.60},{-9888.78,-1715.30,25.84},{-9859.08,-1739.47,23.24},{-9831.77,-1765.46,23.86},{-9805.01,-1790.92,25.25},{-9762.00,-1825.09,36.00},{-9723.77,-1870.81,48.21},{-9682.95,-1894.36,53.15},{-9647.79,-1901.40,56.76},{-9614.62,-1899.12,59.06}
        }
    end
    Map_1431()

    local function Map_1436() -- 西部荒野
        Sever_Map["西部荒野"] = {}
        Sever_Map["西部荒野"]["西部荒野 - 暮色森林"] = Reverse_Table(Sever_Map["暮色森林"]["暮色森林 - 西部荒野"])
        Sever_Map["西部荒野"]["西部荒野 - 艾尔文森林"] = 
        {
        {-10256.52,989.05,31.26},{-10196.90,987.84,33.05},{-10145.58,988.98,34.71},{-10109.84,993.31,38.25},{-10085.65,1002.84,34.33},{-10063.89,998.98,32.70},{-10032.21,984.20,32.72},{-10002.25,991.80,32.00},{-9970.65,1002.58,31.48},{-9932.35,993.33,31.55},{-9891.11,980.98,31.23},{-9876.52,956.49,31.17},{-9860.05,920.26,30.10},{-9850.75,904.58,29.67},{-9838.34,883.65,27.17},{-9822.41,861.02,25.77},{-9802.34,834.96,29.14},{-9783.19,811.90,25.71},{-9770.31,794.77,24.88},{-9762.61,772.24,25.10},{-9755.70,748.48,25.14},{-9757.28,705.39,25.42},{-9756.93,670.33,27.37},{-9741.79,610.80,30.47},{-9741.07,574.37,33.67},{-9743.27,540.66,36.31},{-9748.13,495.82,33.94},{-9755.54,449.16,35.48},{-9746.03,384.03,40.46},{-9715.46,320.29,44.68},{-9692.54,288.89,46.29},{-9635.65,254.71,46.63},{-9578.41,252.19,48.65},{-9523.05,232.72,51.58},{-9496.21,202.84,54.11},{-9481.45,165.24,55.99},{-9483.52,110.89,56.43},{-9491.47,68.11,55.98}
        }
    end
    Map_1436()

    local function Map_1429() -- 艾尔文森林
        Sever_Map["艾尔文森林"] = {}
        Sever_Map["艾尔文森林"]["艾尔文森林 - 西部荒野"] = Reverse_Table(Sever_Map["西部荒野"]["西部荒野 - 艾尔文森林"])
        Sever_Map["艾尔文森林"]["艾尔文森林 - 赤脊山"] = 
        {
        {-9502.96,39.85,56.39},{-9517.73,5.97,56.04},{-9540.53,-45.42,56.60},{-9548.51,-98.33,57.36},{-9567.81,-153.76,57.34},{-9600.62,-231.00,57.40},{-9618.40,-307.06,57.43},{-9618.42,-377.46,57.67},{-9595.25,-460.52,57.66},{-9606.05,-523.88,55.75},{-9618.80,-590.40,53.88},{-9630.51,-640.81,50.80},{-9653.65,-733.21,44.53},{-9621.01,-829.62,43.69},{-9584.47,-889.05,43.71},{-9613.58,-967.66,43.77},{-9616.24,-1046.89,39.95},{-9613.45,-1084.78,39.89},{-9625.78,-1166.90,41.25},{-9650.16,-1227.69,36.38},{-9659.01,-1338.65,48.63},{-9653.74,-1436.19,54.04},{-9652.81,-1501.08,57.51},{-9648.85,-1541.79,54.25},{-9646.55,-1565.44,54.00},{-9643.77,-1593.95,55.63},{-9640.34,-1625.89,55.69},{-9622.83,-1660.42,56.12},{-9613.40,-1692.67,56.00},{-9612.18,-1734.89,56.64},{-9613.77,-1765.38,53.71},{-9615.63,-1801.00,51.64},{-9612.45,-1828.73,52.54},{-9603.50,-1867.93,57.02},{-9583.91,-1924.48,63.54},{-9587.30,-2011.93,65.54},{-9589.71,-2044.42,65.44},{-9605.75,-2066.67,62.58},{-9622.67,-2092.62,61.64},{-9603.67,-2120.47,65.60},{-9576.19,-2154.85,75.90},{-9559.19,-2190.62,91.18},{-9537.09,-2220.15,87.23},{-9510.09,-2245.96,77.70},{-9485.07,-2260.36,75.35}
        }

        Sever_Map["艾尔文森林"]["艾尔文森林 - 暴风城"] = 
        {
        {-9283.62,150.29,66.56},{-9252.05,161.08,67.81},{-9192.32,226.75,71.83},{-9180.77,328.86,81.55},{-9115.96,392.48,92.21},{-9055.41,438.81,93.06},{-8993.89,490.49,96.60},{-8970.63,508.23,96.35},{-8970.56,546.76,93.84},{-8956.69,562.69,93.83},{-8928.61,540.10,94.32},{-8897.95,562.03,92.85},{-8872.71,582.91,92.86},{-8834.31,622.95,93.62}
        }
    end
    Map_1429()

    local function Map_1453() -- 暴风城
        Sever_Map["暴风城"] = {}
        Sever_Map["暴风城"]["暴风城 - 艾尔文森林"] = Reverse_Table(Sever_Map["艾尔文森林"]["艾尔文森林 - 暴风城"])
    end
    Map_1453()

    local function Map_1430() -- 逆风小径
        Sever_Map["逆风小径"] = {}
        Sever_Map["逆风小径"]["逆风小径 - 暮色森林"] = Reverse_Table(Sever_Map["暮色森林"]["暮色森林 - 逆风小径"])
        Sever_Map["逆风小径"]["逆风小径 - 悲伤沼泽"] = 
        {
        {-10431.77,-2006.73,98.21},{-10437.55,-2028.91,95.45},{-10459.56,-2038.15,93.42},{-10485.72,-2044.26,92.98},{-10516.80,-2065.11,91.99},{-10541.09,-2090.25,91.28},{-10570.34,-2113.41,91.03},{-10585.90,-2129.43,91.88},{-10587.92,-2164.85,91.14},{-10578.87,-2207.81,92.07},{-10571.21,-2250.10,93.77},{-10562.60,-2276.75,93.70},{-10554.25,-2315.57,89.84},{-10548.96,-2353.57,86.06},{-10540.35,-2366.18,83.26},{-10515.13,-2377.85,80.35},{-10487.83,-2392.16,76.46},{-10456.99,-2402.66,70.36},{-10429.00,-2409.31,66.35},{-10405.27,-2415.58,58.83},{-10395.18,-2425.08,53.58},{-10390.25,-2443.77,47.41},{-10395.67,-2459.59,43.09},{-10406.34,-2488.09,33.92},{-10414.79,-2510.68,28.78},{-10418.10,-2534.55,25.17},{-10410.07,-2557.48,24.12},{-10395.93,-2583.40,22.64},{-10383.53,-2605.39,21.69},{-10380.07,-2634.90,21.69},{-10384.64,-2663.14,21.71},{-10391.89,-2695.40,21.68},{-10413.28,-2719.92,21.68},{-10435.62,-2742.60,21.68},{-10452.77,-2763.25,21.68},{-10465.46,-2789.71,21.68},{-10478.59,-2812.46,21.68},{-10485.94,-2827.23,21.68}
        }
    end
    Map_1430()

    local function Map_1435() -- 悲伤沼泽
        Sever_Map["悲伤沼泽"] = {}
        Sever_Map["悲伤沼泽"]["悲伤沼泽 - 逆风小径"] = Reverse_Table(Sever_Map["逆风小径"]["逆风小径 - 悲伤沼泽"])
        Sever_Map["悲伤沼泽"]["悲伤沼泽 - 诅咒之地"] = 
        {
        {-10487.79,-2833.11,21.69},{-10492.98,-2849.55,21.69},{-10502.35,-2879.29,21.68},{-10511.97,-2898.24,21.68},{-10515.99,-2913.07,21.68},{-10511.94,-2933.57,21.68},{-10509.13,-2953.05,21.68},{-10511.39,-2969.13,21.65},{-10515.71,-2984.46,21.44},{-10521.89,-3005.94,21.68},{-10525.36,-3022.56,21.80},{-10538.08,-3038.71,22.19},{-10553.25,-3041.70,24.58},{-10589.47,-3029.14,28.53},{-10615.48,-3010.10,28.67},{-10641.07,-2990.97,29.13},{-10663.16,-2984.01,33.05},{-10689.26,-2983.41,37.81},{-10725.68,-2984.93,44.71},{-10752.44,-2987.08,48.45},{-10788.07,-2993.10,46.45},{-10824.11,-2992.35,37.25},{-10848.60,-2990.74,29.10},{-10872.89,-2988.73,22.90},{-10914.96,-2982.43,18.21},{-10950.32,-2972.22,17.74},{-10993.18,-2949.34,16.08},{-11032.25,-2932.00,12.29},{-11077.35,-2937.04,10.70},{-11111.43,-2948.72,8.55},{-11132.86,-2969.72,8.46},{-11154.37,-2990.42,8.41},{-11175.75,-3012.98,7.40},{-11197.54,-3021.09,6.80},{-11231.49,-3022.39,5.96},{-11283.74,-3023.10,4.67},{-11304.29,-3034.96,3.68},{-11322.32,-3062.36,1.45},{-11338.60,-3077.89,1.01},{-11370.16,-3086.87,0.13},{-11394.97,-3086.07,0.84},{-11425.37,-3084.38,2.39},{-11446.43,-3094.73,2.94},{-11460.05,-3112.26,5.35},{-11477.19,-3128.85,6.75},{-11496.73,-3136.94,6.82},{-11520.54,-3138.67,5.44},{-11540.80,-3139.03,4.47},{-11558.54,-3138.13,4.50},{-11592.26,-3119.69,5.62},{-11604.03,-3103.01,7.41},{-11622.70,-3080.89,8.96},{-11642.94,-3056.65,10.47},{-11645.73,-3051.95,10.27},{-11667.88,-3022.93,8.39},{-11681.57,-2989.44,7.53},{-11685.44,-2960.54,7.75},{-11699.77,-2925.07,7.32},{-11715.97,-2894.99,4.14},{-11728.45,-2854.30,4.46},{-11748.89,-2839.23,5.65},{-11774.50,-2827.50,7.41}
        }
    end
    Map_1435()

    local function Map_1419() -- 诅咒之地
        Sever_Map["诅咒之地"] = {}
        Sever_Map["诅咒之地"]["诅咒之地 - 悲伤沼泽"] = Reverse_Table(Sever_Map["悲伤沼泽"]["悲伤沼泽 - 诅咒之地"])
    end
    Map_1419()

    local function Map_1433() -- 赤脊山
        Sever_Map["赤脊山"] = {}
        Sever_Map["赤脊山"]["赤脊山 - 艾尔文森林"] = Reverse_Table(Sever_Map["艾尔文森林"]["艾尔文森林 - 赤脊山"])

        Sever_Map["赤脊山"]["赤脊山 - 暮色森林"] = Reverse_Table(Sever_Map["暮色森林"]["暮色森林 - 赤脊山"])

        Sever_Map["赤脊山"]["赤脊山 - 燃烧平原"] = 
        {
        {-9166.63,-2376.08,94.62},{-9157.19,-2391.22,99.89},{-9153.72,-2407.23,103.60},{-9150.22,-2427.51,106.36},{-9144.27,-2446.61,108.82},{-9136.85,-2463.18,112.14},{-9127.56,-2480.61,115.02},{-9114.13,-2502.33,116.87},{-9101.50,-2515.66,117.21},{-9083.82,-2535.23,119.30},{-9076.19,-2542.36,121.53},{-9065.60,-2549.28,123.35},{-9055.79,-2557.20,124.50},{-9034.21,-2576.54,125.22},{-9019.18,-2590.02,126.58},{-9002.98,-2601.08,128.41},{-8987.96,-2604.60,131.67},{-8956.64,-2599.29,132.55},{-8933.61,-2591.12,132.46},{-8917.40,-2578.31,132.44},{-8896.57,-2562.77,130.56},{-8876.09,-2556.23,130.50},{-8847.20,-2559.20,130.78},{-8824.28,-2569.68,130.54},{-8804.77,-2578.06,130.51},{-8787.73,-2581.13,130.51},{-8747.01,-2584.44,132.70},{-8720.37,-2584.08,132.61},{-8682.03,-2581.68,132.53},{-8647.08,-2577.31,132.53},{-8614.26,-2573.21,132.53},{-8568.99,-2564.09,133.15},{-8542.02,-2560.27,133.15},{-8498.75,-2555.18,132.86},{-8461.28,-2548.42,133.23},{-8393.84,-2535.83,135.21},{-8358.43,-2534.43,133.84},{-8323.84,-2537.49,133.15},{-8311.64,-2541.04,133.15},{-8297.35,-2550.22,133.15},{-8263.90,-2580.14,133.15},{-8235.73,-2592.35,133.15},{-8207.15,-2583.64,133.39},{-8180.76,-2563.67,135.90},{-8158.24,-2541.61,139.45},{-8144.92,-2507.92,140.01},{-8130.23,-2475.26,142.38},{-8096.62,-2472.30,137.92},{-8069.01,-2468.22,134.73},{-8043.46,-2455.05,129.58},{-8038.85,-2426.13,126.74},{-8035.74,-2402.86,124.45},{-8029.18,-2372.73,126.26},{-8025.49,-2346.17,129.94},{-7998.57,-2299.82,129.99},{-7976.53,-2259.19,129.99},{-7986.04,-2226.41,131.04},{-7993.30,-2190.86,128.93},{-7975.21,-2146.84,125.51},{-7981.55,-2108.81,127.93},{-7995.65,-2090.93,130.32},{-8011.58,-2072.65,131.75},{-8029.46,-2051.07,132.33},{-8039.60,-2030.06,132.88},{-8048.28,-2003.62,133.29},{-8056.92,-1975.34,132.50},{-8055.63,-1920.65,133.10},{-8038.87,-1895.16,133.91},{-8018.80,-1857.38,133.27},{-7996.04,-1814.10,133.95},{-7982.27,-1783.73,133.08},{-7968.90,-1748.02,132.23},{-7965.35,-1716.70,135.95},{-7966.81,-1683.46,136.79},{-7969.58,-1656.19,133.70},{-7972.94,-1634.26,132.69}
        }
    end
    Map_1433()

    local function Map_1428() -- 燃烧平原
        Sever_Map["燃烧平原"] = {}
        Sever_Map["燃烧平原"]["燃烧平原 - 赤脊山"] = Reverse_Table(Sever_Map["赤脊山"]["赤脊山 - 燃烧平原"])

        Sever_Map["燃烧平原"]["燃烧平原 - 灼热峡谷"] = 
        {
        {-7981.08,-1604.64,133.29},{-7992.33,-1574.10,132.81},{-8009.38,-1544.55,132.68},{-8038.03,-1509.06,133.65},{-8061.36,-1472.76,132.68},{-8067.30,-1444.94,132.01},{-8071.36,-1417.74,131.94},{-8063.02,-1391.65,132.77},{-8035.90,-1363.40,133.76},{-8013.08,-1326.71,133.24},{-8015.15,-1274.01,132.96},{-8027.02,-1251.65,133.41},{-8018.39,-1222.14,138.51},{-8004.75,-1180.87,151.46},{-7983.23,-1146.69,164.58},{-7953.74,-1132.06,177.42},{-7924.82,-1128.72,186.70},{-7882.44,-1130.03,198.35},{-7828.22,-1132.86,211.47},{-7783.41,-1126.22,214.85},{-7746.88,-1112.34,215.08},{-7718.47,-1087.82,217.18},{-7665.60,-1047.88,223.78},{-7618.25,-1017.28,238.47},{-7573.21,-1017.57,249.47},{-7524.15,-1042.52,260.35},{-7476.03,-1070.61,264.97},{-7426.04,-1067.97,274.57},{-7411.69,-1096.02,278.08},{-7337.86,-1093.30,277.07},{-7306.67,-1071.58,277.23},{-7249.34,-1071.82,257.33},{-7178.26,-1100.93,241.04},{-7192.61,-1230.83,246.25},{-7179.40,-1311.55,241.56},{-7134.12,-1341.45,240.35},{-7107.96,-1462.50,241.95},{-7095.96,-1495.58,240.34},{-7041.31,-1525.99,243.24},{-6991.18,-1578.80,241.89},{-6985.21,-1642.38,241.63},{-6951.79,-1712.30,240.74},{-6906.17,-1795.55,240.74},{-6884.78,-1822.45,240.74},{-6833.36,-1846.15,244.14},{-6788.01,-1864.40,244.13},{-6742.72,-1879.99,244.14},{-6687.50,-1903.73,244.14},{-6645.37,-1916.23,244.15},{-6611.73,-1917.91,244.15},{-6578.94,-1922.91,244.15},{-6544.89,-1936.58,244.15}
        }
    end
    Map_1428()

    local function Map_1427() -- 灼热峡谷
        Sever_Map["灼热峡谷"] = {}
        Sever_Map["灼热峡谷"]["灼热峡谷 - 燃烧平原"] = Reverse_Table(Sever_Map["燃烧平原"]["燃烧平原 - 灼热峡谷"])

        Sever_Map["灼热峡谷"]["灼热峡谷 - 荒芜之地"] = 
        {
        {-6519.21,-1949.68,244.15},{-6481.31,-1969.00,244.15},{-6421.66,-2005.88,245.12},{-6391.54,-2037.36,244.39},{-6369.11,-2063.16,243.54},{-6896.86,-1812.52,240.57},{-6900.10,-1843.59,246.96},{-6910.97,-1884.31,259.43},{-6922.50,-1929.41,273.49},{-6933.16,-1961.89,282.80},{-6940.72,-2004.02,282.48},{-6945.53,-2042.80,282.48},{-6943.24,-2067.86,282.56},{-6934.20,-2099.24,283.07},{-6924.62,-2128.03,277.43},{-6913.51,-2165.58,264.44},{-6903.99,-2193.27,255.61},{-6894.34,-2232.93,243.76},{-6901.30,-2262.35,240.74},{-6915.28,-2284.65,240.74},{-6932.08,-2312.49,240.74},{-6951.36,-2351.03,240.75},{-6964.23,-2377.30,240.74},{-6968.97,-2406.21,240.74},{-6966.19,-2435.48,240.74},{-6956.44,-2458.61,240.74},{-6937.90,-2485.51,240.74},{-6910.54,-2515.64,240.74},{-6885.56,-2536.70,240.74},{-6858.08,-2559.86,240.74},{-6850.69,-2567.19,240.74},{-6846.27,-2586.40,240.89},{-6825.32,-2610.00,241.20},{-6811.93,-2624.10,241.69},{-6788.92,-2648.32,241.79},{-6784.36,-2663.99,241.59},{-6798.23,-2698.39,241.71},{-6804.79,-2717.94,241.67},{-6816.03,-2743.76,242.24},{-6832.90,-2777.14,241.67},{-6849.33,-2799.52,241.67},{-6869.48,-2832.81,242.04},{-6865.29,-2862.83,243.08},{-6859.68,-2891.36,242.77},{-6851.22,-2917.04,243.84},{-6831.20,-2970.36,245.87},{-6824.17,-2997.64,242.18},{-6819.25,-3019.64,241.67},{-6813.56,-3045.03,241.67},{-6806.01,-3078.77,241.18},{-6793.41,-3110.38,240.74},{-6777.39,-3144.05,240.74},{-6763.41,-3175.77,240.74},{-6744.54,-3208.80,240.74},{-6727.95,-3229.70,240.74},{-6708.61,-3252.40,240.74},{-6708.44,-3252.60,240.74},{-6701.50,-3260.75,240.83}
        }
    end
    Map_1427()

    local function Map_1418() -- 荒芜之地
        Sever_Map["荒芜之地"] = {}
        Sever_Map["荒芜之地"]["荒芜之地 - 灼热峡谷"] = Reverse_Table(Sever_Map["灼热峡谷"]["灼热峡谷 - 荒芜之地"])

        Sever_Map["荒芜之地"]["荒芜之地 - 洛克莫丹"] = 
        {
        {-6650.19,-3263.84,242.93},{-6588.33,-3270.80,241.70},{-6545.99,-3279.88,241.74},{-6460.45,-3310.84,241.67},{-6420.39,-3332.17,241.67},{-6377.87,-3359.31,241.67},{-6339.73,-3384.39,241.28},{-6293.52,-3397.75,240.28},{-6229.66,-3396.20,239.16},{-6172.81,-3377.18,243.17},{-6124.30,-3350.69,252.53},{-6084.82,-3331.60,253.27},{-6037.10,-3314.67,258.57},{-5993.54,-3301.56,266.74},{-5966.54,-3295.32,272.85},{-5936.96,-3289.22,279.84},{-5910.92,-3286.11,284.19},{-5885.32,-3283.09,290.99},{-5859.41,-3278.69,293.41},{-5832.90,-3275.69,295.08},{-5807.76,-3271.26,297.09},{-5784.07,-3262.86,300.14},{-5756.65,-3239.76,304.27},{-5737.25,-3228.58,307.12},{-5702.95,-3201.64,315.32},{-5685.41,-3163.78,315.07},{-5655.90,-3155.45,317.20},{-5611.88,-3159.65,324.15},{-5579.22,-3153.10,330.42},{-5547.78,-3126.91,340.91},{-5523.05,-3111.66,344.28},{-5492.83,-3098.88,347.15},{-5474.81,-3076.21,351.50},{-5458.32,-3041.41,354.66},{-5455.86,-3016.72,356.22},{-5460.24,-2973.15,358.10},{-5465.20,-2950.05,352.92},{-5462.10,-2908.64,344.46},{-5466.57,-2878.97,350.15},{-5450.12,-2880.53,347.76},{-5416.45,-2882.99,343.58},{-5381.36,-2872.86,340.87},{-5321.95,-2864.23,339.43},{-5272.63,-2880.28,338.75},{-5234.08,-2873.07,338.24},{-5198.99,-2855.10,335.62},{-5151.41,-2840.82,332.72},{-5117.85,-2833.48,329.28},{-5059.03,-2816.17,327.44}
        }
    end
    Map_1418()

    local function Map_1432() -- 洛克莫丹
        Sever_Map["洛克莫丹"] = {}
        Sever_Map["洛克莫丹"]["洛克莫丹 - 荒芜之地"] = Reverse_Table(Sever_Map["荒芜之地"]["荒芜之地 - 洛克莫丹"])

        Sever_Map["洛克莫丹"]["洛克莫丹 - 丹莫罗"] = 
        {
        {-5018.02,-2797.67,326.55},{-4983.71,-2779.75,325.63},{-4950.47,-2760.04,326.13},{-4917.52,-2731.90,328.54},{-4877.83,-2684.76,335.64},{-4851.07,-2646.64,344.01},{-4850.94,-2646.43,344.04},{-4831.07,-2609.16,351.21},{-4831.00,-2609.03,351.24},{-4810.00,-2568.43,355.36},{-4802.97,-2544.06,355.00},{-4805.57,-2523.71,354.40},{-4819.31,-2496.90,357.13},{-4836.59,-2463.30,370.21},{-4852.74,-2435.52,380.68},{-4867.31,-2410.25,394.68},{-4879.41,-2387.66,405.80},{-4898.46,-2354.20,408.62},{-4928.18,-2336.11,408.62},{-4988.54,-2311.79,407.06},{-5031.88,-2297.37,401.81},{-5094.10,-2290.53,400.25},{-5152.87,-2308.80,400.42},{-5187.72,-2295.89,400.38},{-5212.88,-2270.51,402.35},{-5242.93,-2238.39,414.80},{-5262.36,-2217.15,424.30},{-5280.14,-2192.96,425.45},{-5296.85,-2164.46,421.05},{-5324.70,-2156.68,419.62},{-5354.13,-2149.05,415.25},{-5388.93,-2124.41,401.75},{-5421.16,-2096.04,399.38},{-5461.40,-2080.22,399.38},{-5489.04,-2059.20,399.38},{-5506.37,-2021.79,399.38},{-5508.36,-1976.14,399.38},{-5496.66,-1939.37,399.16},{-5496.30,-1904.54,397.14},{-5512.25,-1847.46,397.10},{-5510.65,-1801.31,397.29},{-5512.36,-1729.41,397.19},{-5532.11,-1692.00,394.65},{-5545.10,-1655.42,391.78},{-5557.93,-1614.01,391.78},{-5557.91,-1572.97,397.25},{-5585.59,-1549.91,399.13},{-5606.44,-1524.74,399.12},{-5610.83,-1490.13,399.05},{-5611.56,-1458.74,398.98},{-5631.19,-1427.48,398.23},{-5647.38,-1400.89,397.56},{-5658.39,-1356.68,396.30},{-5677.00,-1320.59,393.36},{-5679.65,-1271.42,390.10},{-5683.09,-1225.15,388.29},{-5681.24,-1168.67,385.11},{-5681.20,-1168.52,385.11},{-5648.20,-1130.93,388.19},{-5620.24,-1080.47,393.16},{-5605.88,-1033.16,393.08},{-5577.53,-1019.15,393.52},{-5514.38,-1016.34,393.08},{-5465.87,-996.05,392.21},{-5428.74,-968.24,392.21},{-5408.18,-929.74,392.20},{-5388.42,-858.13,392.03},{-5418.30,-806.71,392.12},{-5438.29,-768.07,394.02},{-5434.34,-723.84,393.67},{-5396.92,-639.10,391.65},{-5360.23,-569.20,391.49},{-5350.68,-528.77,391.49},{-5309.58,-512.36,392.26},{-5309.35,-512.30,392.25},{-5266.88,-498.52,386.94},{-5242.81,-543.32,394.91}
        }

        Sever_Map["洛克莫丹"]["洛克莫丹 - 湿地"] = 
        {
        {-4895.98,-2726.44,329.00},{-4856.21,-2716.19,329.17},{-4819.16,-2712.68,328.29},{-4784.57,-2711.17,326.27},{-4746.78,-2706.71,324.74},{-4704.77,-2700.71,318.81},{-4670.41,-2699.04,320.74},{-4621.82,-2696.76,309.72},{-4582.98,-2694.85,291.14},{-4539.33,-2693.24,275.05},{-4494.55,-2691.29,266.96},{-4458.48,-2678.30,266.04},{-4447.30,-2649.25,266.18},{-4441.26,-2609.43,252.66},{-4436.12,-2571.52,236.15},{-4429.72,-2530.59,219.93},{-4424.63,-2491.33,213.40},{-4405.68,-2466.81,212.20},{-4362.14,-2460.14,212.35},{-4326.42,-2461.97,212.20},{-4292.38,-2463.75,212.70},{-4259.27,-2463.99,204.85},{-4218.15,-2463.55,184.70},{-4178.59,-2463.66,170.71},{-4149.76,-2463.19,161.36},{-4124.89,-2462.98,159.42},{-4096.45,-2468.05,157.75},{-4073.01,-2461.15,155.21},{-4034.30,-2430.11,138.21},{-4015.06,-2405.28,125.95},{-4014.76,-2379.84,117.67},{-4041.29,-2381.49,111.85},{-4071.28,-2400.48,103.45},{-4091.11,-2426.78,97.60},{-4091.83,-2456.87,96.39},{-4090.15,-2495.80,80.31},{-4089.09,-2535.55,65.71},{-4087.67,-2581.54,47.55},{-4087.11,-2626.09,43.18},{-4085.73,-2665.90,34.57},{-4081.52,-2716.54,22.10},{-4063.70,-2756.19,17.98},{-4029.81,-2792.62,17.86},{-3995.79,-2810.14,18.21},{-3952.79,-2815.60,18.06},{-3914.40,-2818.08,18.13},{-3880.90,-2802.34,18.04},{-3830.72,-2786.53,17.83},{-3777.40,-2784.76,17.81},{-3723.91,-2772.91,17.85},{-3679.95,-2751.31,19.37},{-3630.49,-2724.97,18.68},{-3586.58,-2695.20,19.06},{-3535.35,-2657.35,15.95},{-3477.19,-2633.76,15.95},{-3418.33,-2612.89,15.96},{-3380.94,-2592.98,15.96},{-3335.63,-2577.50,15.96},{-3299.18,-2551.29,15.96},{-3265.46,-2516.10,16.25},{-3243.65,-2472.28,15.96},{-3206.30,-2456.81,10.21},{-3173.80,-2447.59,9.59}
        }
    end
    Map_1432()

    local function Map_1426() -- 丹莫罗
        Sever_Map["丹莫罗"] = {}
        Sever_Map["丹莫罗"]["丹莫罗 - 洛克莫丹"] = Reverse_Table(Sever_Map["洛克莫丹"]["洛克莫丹 - 丹莫罗"])

        Sever_Map["丹莫罗"]["丹莫罗 - 铁炉堡"] =
        {
        {-5258.12,-492.84,386.37},{-5250.08,-518.42,386.61},{-5239.11,-597.43,413.23},{-5188.37,-730.01,446.62},{-5075.29,-747.25,475.60},{-5046.63,-786.54,495.12},{-5019.83,-834.42,496.98},{-4996.39,-865.35,497.04},{-4979.93,-885.34,501.64},{-5019.13,-929.08,501.66},{-4999.76,-951.01,501.66},{-4983.21,-963.00,501.66},{-4949.17,-987.94,501.47}
	    }
    end
    Map_1426()

    local function Map_1455() -- 铁炉堡
        Sever_Map["铁炉堡"] = {}
        Sever_Map["铁炉堡"]["铁炉堡 - 丹莫罗"] = Reverse_Table(Sever_Map["丹莫罗"]["丹莫罗 - 铁炉堡"])
    end
    Map_1455()

    local function Map_1437() -- 湿地
        Sever_Map["湿地"] = {}
        Sever_Map["湿地"]["湿地 - 洛克莫丹"] = Reverse_Table(Sever_Map["洛克莫丹"]["洛克莫丹 - 湿地"])

        Sever_Map["湿地"]["湿地 - 阿拉希高地"] = 
        {
        {-3151.20,-2443.68,9.20},{-3121.62,-2449.04,9.43},{-3089.64,-2441.90,9.21},{-3060.29,-2426.44,10.89},{-3021.05,-2419.83,10.89},{-2953.84,-2409.97,16.94},{-2919.78,-2412.30,24.44},{-2878.89,-2431.39,36.75},{-2847.45,-2464.12,48.08},{-2812.80,-2498.47,56.80},{-2777.99,-2505.70,60.88},{-2731.86,-2500.32,66.29},{-2693.53,-2485.97,73.59},{-2639.15,-2487.94,79.27},{-2588.81,-2489.29,80.32},{-2544.47,-2484.27,81.42},{-2515.12,-2482.02,81.29},{-2470.22,-2498.82,78.51},{-2402.01,-2501.99,86.07},{-2360.39,-2502.34,88.34},{-2279.60,-2503.02,78.51},{-2251.17,-2485.42,80.27},{-2234.88,-2461.43,81.44},{-2193.89,-2454.25,81.20},{-2148.70,-2452.84,79.90},{-2090.56,-2453.82,74.32},{-2023.20,-2465.05,77.81},{-1980.06,-2464.59,78.23},{-1931.32,-2447.00,69.41},{-1884.65,-2424.37,61.19},{-1810.10,-2408.87,55.63},{-1734.42,-2431.29,61.83},{-1647.31,-2472.12,63.49},{-1606.05,-2487.07,60.48},{-1555.46,-2494.48,54.97},{-1510.82,-2465.75,53.08},{-1486.46,-2444.70,54.57},{-1455.78,-2410.44,59.88},{-1450.74,-2364.50,61.50}
        }
    end
    Map_1437()

    local function Map_1417() -- 阿拉希高地
        Sever_Map["阿拉希高地"] = {}
        Sever_Map["阿拉希高地"]["阿拉希高地 - 湿地"] = Reverse_Table(Sever_Map["湿地"]["湿地 - 阿拉希高地"])

        Sever_Map["阿拉希高地"]["阿拉希高地 - 希尔斯布莱德丘陵"] = 
        {
        {-1450.80,-2349.42,61.59},{-1447.44,-2312.03,61.81},{-1430.54,-2264.98,63.32},{-1402.50,-2198.01,63.88},{-1392.71,-2148.06,64.19},{-1386.92,-2093.20,63.58},{-1382.45,-2040.56,61.17},{-1376.63,-1995.35,59.05},{-1365.47,-1953.67,58.46},{-1348.21,-1908.14,58.54},{-1334.49,-1873.85,61.05},{-1323.20,-1843.00,63.30},{-1308.31,-1819.70,65.18},{-1275.44,-1795.58,67.13},{-1245.26,-1778.51,65.34},{-1225.14,-1763.52,62.24},{-1202.64,-1744.87,58.45},{-1148.06,-1710.58,50.99},{-1109.36,-1700.54,44.86},{-1072.18,-1690.89,39.06},{-1044.09,-1687.79,37.25},{-999.43,-1685.14,36.98},{-941.68,-1673.76,41.40},{-899.86,-1647.80,47.98},{-862.85,-1611.15,52.81},{-819.89,-1561.25,54.17},{-786.48,-1516.13,56.30},{-769.55,-1476.07,61.79},{-748.33,-1430.76,66.45},{-724.53,-1391.85,68.49},{-705.11,-1365.15,67.85},{-666.34,-1311.86,66.30},{-636.81,-1265.52,66.09},{-599.65,-1190.16,66.07},{-585.59,-1147.30,66.22},{-566.58,-1105.87,62.51},{-540.44,-1075.82,56.54},{-514.27,-1041.55,49.63},{-500.65,-1002.74,41.03},{-494.38,-973.88,36.08},{-485.85,-938.45,34.26},{-469.04,-898.88,37.50},{-443.94,-863.56,45.88},{-418.06,-831.63,53.09},{-380.13,-780.92,54.54}
        }
    end
    Map_1417()

    local function Map_1424() -- 希尔斯布莱德丘陵
        Sever_Map["希尔斯布莱德丘陵"] = {}
        Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 阿拉希高地"] = Reverse_Table(Sever_Map["阿拉希高地"]["阿拉希高地 - 希尔斯布莱德丘陵"])

        Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 银松森林"] = 
        {
        {-379.99,-773.36,54.54},{-389.80,-727.80,54.46},{-408.16,-674.73,54.50},{-434.20,-580.66,53.66},{-439.32,-524.76,49.60},{-446.94,-473.27,47.34},{-467.90,-430.29,47.33},{-499.46,-385.40,47.35},{-525.96,-336.60,47.33},{-546.09,-304.99,47.33},{-567.02,-262.53,47.27},{-592.05,-217.95,47.34},{-608.15,-178.48,47.34},{-621.76,-147.44,47.33},{-640.01,-102.30,47.31},{-652.81,-52.25,47.26},{-658.85,-17.25,47.56},{-669.63,32.20,47.33},{-667.83,74.61,46.87},{-667.70,75.22,46.86},{-667.66,75.43,46.86},{-664.75,102.96,47.59},{-654.22,146.88,53.69},{-633.58,186.98,59.06},{-622.46,215.01,60.48},{-612.69,255.54,63.38},{-606.62,293.76,67.67},{-598.22,332.86,71.99},{-591.31,371.61,75.48},{-583.33,419.57,79.27},{-584.43,467.64,82.39},{-586.71,513.52,82.62},{-586.72,513.76,82.62},{-585.73,580.53,83.50},{-584.92,619.06,83.92},{-568.11,666.76,89.16},{-549.20,710.70,91.68},{-528.43,729.16,90.96},{-479.38,753.64,92.32},{-426.86,780.87,94.66},{-375.70,801.40,93.37},{-315.36,822.04,86.02},{-315.14,822.11,85.99},{-198.44,859.37,68.28},{-198.44,859.37,68.28},{-148.48,867.10,62.99},{-131.25,891.14,65.10},{-133.51,944.99,67.52},{-135.16,1010.40,68.01},{-137.36,1089.80,64.74},{-135.97,1149.38,63.36},{-127.90,1165.60,63.52},{-98.16,1176.46,63.44},{-29.27,1191.55,64.21},{19.79,1208.06,64.83},{62.97,1220.78,66.44},{124.21,1239.15,70.04},{185.65,1257.11,71.79},{217.07,1265.37,74.62},{259.49,1268.63,76.85},{286.24,1263.35,77.15},{315.84,1253.04,79.84},{345.59,1242.67,81.14},{402.06,1235.88,83.37},{439.82,1231.57,87.32},{496.53,1228.52,88.85},{544.82,1234.94,87.35},{579.88,1256.16,86.84},{613.52,1281.52,87.28},{652.63,1303.10,84.16},{688.87,1326.92,79.66},{722.17,1348.16,75.80},{751.29,1360.54,73.02},{810.54,1361.42,62.02},{846.33,1361.49,54.91},{893.80,1353.64,47.64},{935.28,1337.54,45.44},{977.72,1309.65,46.00},{1017.50,1283.77,45.77},{1062.69,1245.91,45.62},{1088.35,1222.81,45.76},{1119.34,1201.73,46.94},{1159.70,1173.89,48.27},{1189.91,1153.06,46.73}
        }

        Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 奥特兰克山脉"] = 
        {
        {-366.48,-774.25,54.23},{-322.62,-754.81,54.13},{-279.70,-740.66,56.53},{-246.11,-730.25,58.70},{-192.83,-719.62,63.04},{-155.45,-716.11,64.02},{-107.69,-714.12,65.31},{-67.34,-715.11,68.11},{-25.06,-712.60,69.74},{29.24,-712.58,74.54},{77.47,-712.69,80.19},{129.98,-705.90,88.23},{176.04,-684.39,98.90},{214.71,-663.73,111.28},{239.30,-656.88,118.73},{279.54,-644.90,131.57},{312.05,-621.55,142.53},{351.57,-610.11,150.03},{388.76,-612.05,159.81},{421.49,-617.18,165.05},{452.24,-634.95,167.07},{483.45,-678.06,165.08},{513.96,-721.46,161.14},{553.77,-752.11,164.04},{584.95,-781.92,165.97},{596.93,-815.56,166.23},{616.36,-853.53,163.81},{617.59,-885.61,164.04},{621.07,-924.35,164.71},{641.84,-956.98,164.58},{642.36,-990.21,165.38},{630.41,-1032.08,163.79},{625.02,-1064.35,162.68},{620.68,-1108.05,160.44},{630.65,-1141.85,157.07},{630.64,-1209.95,141.82},{631.86,-1260.23,125.43},{628.37,-1311.47,108.85},{628.42,-1369.02,95.41},{666.42,-1432.59,82.65},{696.75,-1450.24,81.71},{742.64,-1460.49,80.48},{742.86,-1460.52,80.46},{789.25,-1467.97,75.04},{841.98,-1476.17,69.38},{883.69,-1476.83,63.77},{923.01,-1473.92,62.50}
        }

        Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 辛特兰"] = 
        {
        {-745.06,-1423.82,67.04},{-748.09,-1489.65,61.15},{-707.63,-1531.90,56.08},{-644.88,-1612.23,57.12},{-568.29,-1619.51,64.56},{-526.76,-1632.74,69.79},{-488.58,-1651.06,78.61},{-461.81,-1663.89,80.95},{-443.00,-1672.92,83.75},{-398.91,-1695.85,88.38},{-340.18,-1744.14,91.90},{-298.78,-1761.21,112.17},{-263.73,-1762.24,125.28},{-252.32,-1748.06,122.14},{-213.29,-1732.23,105.25},{-188.76,-1760.43,108.49},{-140.36,-1804.98,122.92},{-78.31,-1836.54,139.93},{-24.85,-1885.80,150.86},{78.75,-1950.84,155.20},{139.49,-1991.37,131.12},{139.31,-2037.12,117.69},{112.86,-2119.70,103.77},{90.96,-2239.73,102.59},{100.07,-2343.16,115.05}
        }
    end
    Map_1424()

    local function Map_1416() -- 奥特兰克山脉
        Sever_Map["奥特兰克山脉"] = {}
        Sever_Map["奥特兰克山脉"]["奥特兰克山脉 - 希尔斯布莱德丘陵"] = Reverse_Table(Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 奥特兰克山脉"])
    end
    Map_1416()

    local function Map_1425() -- 辛特兰
        Sever_Map["辛特兰"] = {}
        Sever_Map["辛特兰"]["辛特兰 - 希尔斯布莱德丘陵"] = Reverse_Table(Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 辛特兰"])
    end
    Map_1425()

    local function Map_1421() -- 银松森林
        Sever_Map["银松森林"] = {}
        Sever_Map["银松森林"]["银松森林 - 希尔斯布莱德丘陵"] = Reverse_Table(Sever_Map["希尔斯布莱德丘陵"]["希尔斯布莱德丘陵 - 银松森林"])

        Sever_Map["银松森林"]["银松森林 - 提瑞斯法林地"] = 
        {
        {1203.34,1143.80,47.07},{1232.41,1120.99,49.31},{1254.20,1100.89,52.17},{1277.34,1077.71,54.03},{1302.25,1050.22,54.44},{1316.16,1020.37,54.59},{1328.15,992.49,54.66},{1336.94,956.94,54.72},{1345.19,921.24,53.88},{1361.71,867.53,51.81},{1382.50,820.74,49.66},{1397.37,785.37,47.97},{1414.73,748.65,46.32},{1432.50,711.05,44.57},{1451.46,680.51,45.78},{1476.37,651.37,46.55},{1505.46,621.74,47.14},{1535.38,597.95,45.68},{1592.94,571.43,38.39},{1642.00,554.10,33.41},{1675.66,549.20,33.48},{1709.95,542.64,33.71},{1765.64,526.20,33.40},{1829.44,506.97,33.90},{1862.00,485.11,34.64},{1876.49,464.69,34.16},{1890.91,429.93,34.03},{1899.62,397.83,34.25},{1916.02,358.44,34.04},{1930.48,329.95,35.55},{1952.92,285.77,38.61},{1973.13,250.81,37.51},{1997.67,216.04,34.36},{2016.97,182.28,33.88},{2027.30,146.79,33.99},{2034.15,107.67,33.87},{2033.78,58.91,33.88},{2024.92,17.29,33.99},{2016.44,-16.31,33.69},{2003.99,-49.07,32.50},{1994.45,-81.54,32.39},{1981.29,-122.85,32.53},{1968.45,-150.68,32.57}
        }
    end
    Map_1421()

    local function Map_1420() -- 提瑞斯法林地
        Sever_Map["提瑞斯法林地"] = {}
        Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 银松森林"] = Reverse_Table(Sever_Map["银松森林"]["银松森林 - 提瑞斯法林地"])

        Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 西瘟疫"] = 
        {
        {1203.34,1143.80,47.07},{1232.41,1120.99,49.31},{1254.20,1100.89,52.17},{1277.34,1077.71,54.03},{1302.25,1050.22,54.44},{1316.16,1020.37,54.59},{1328.15,992.49,54.66},{1336.94,956.94,54.72},{1345.19,921.24,53.88},{1361.71,867.53,51.81},{1382.50,820.74,49.66},{1397.37,785.37,47.97},{1414.73,748.65,46.32},{1432.50,711.05,44.57},{1451.46,680.51,45.78},{1476.37,651.37,46.55},{1505.46,621.74,47.14},{1535.38,597.95,45.68},{1592.94,571.43,38.39},{1642.00,554.10,33.41},{1675.66,549.20,33.48},{1709.95,542.64,33.71},{1765.64,526.20,33.40},{1829.44,506.97,33.90},{1862.00,485.11,34.64},{1876.49,464.69,34.16},{1890.91,429.93,34.03},{1899.62,397.83,34.25},{1916.02,358.44,34.04},{1930.48,329.95,35.55},{1952.92,285.77,38.61},{1973.13,250.81,37.51},{1997.67,216.04,34.36},{2016.97,182.28,33.88},{2027.30,146.79,33.99},{2034.15,107.67,33.87},{2033.78,58.91,33.88},{2024.92,17.29,33.99},{2016.44,-16.31,33.69},{2003.99,-49.07,32.50},{1994.45,-81.54,32.39},{1981.29,-122.85,32.53},{1968.45,-150.68,32.57},{1956.11,-172.86,32.39},{1933.23,-215.15,32.92},{1912.10,-246.04,32.72},{1889.87,-277.16,32.39},{1863.62,-307.78,32.39},{1839.27,-333.64,32.40},{1808.90,-364.54,32.39},{1788.13,-386.05,32.39},{1768.89,-407.20,32.39},{1732.02,-452.39,33.55},{1706.90,-488.53,35.04},{1693.00,-523.30,37.42},{1684.45,-576.35,40.46},{1686.91,-610.51,41.16},{1695.35,-650.19,43.68},{1706.03,-714.37,53.27},{1712.83,-762.70,56.03},{1717.18,-807.21,57.71},{1718.29,-847.53,60.63},{1709.48,-887.03,65.51},{1686.99,-924.99,67.72},{1654.82,-969.77,71.33},{1638.28,-1006.79,75.83},{1632.23,-1049.92,70.17},{1631.92,-1090.40,64.43},{1631.65,-1125.54,62.47},{1633.08,-1173.89,61.02},{1635.51,-1207.43,64.97},{1638.10,-1243.04,68.05},{1651.16,-1282.78,68.94},{1672.20,-1340.74,68.49},{1682.69,-1364.91,69.87}
        }

        Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 幽暗城"] = 
        {
        {1922.51,353.06,34.49},{1898.97,408.04,34.41},{1877.83,467.21,34.31},{1835.60,503.23,34.11},{1764.78,528.23,33.40},{1707.58,595.09,36.56},{1703.20,630.30,41.99},{1699.96,693.48,60.83},{1691.40,729.86,71.80},{1640.21,734.42,77.86},{1609.80,723.08,67.41},{1589.53,678.23,50.49},{1617.75,647.26,36.32},{1663.86,644.74,18.43},{1689.47,604.61,-1.25},{1672.82,580.69,-13.12},{1664.18,565.61,-16.87},{1663.33,553.30,-15.75},{1665.19,539.82,-11.54},{1664.94,522.34,-13.07},{1664.39,479.22,-11.89},{1664.02,486.54,-11.89},{1656.73,478.69,-12.84},{1629.06,479.04,-22.87},{1629.64,437.74,-34.26},{1595.94,437.74,-46.34},{1596.83,422.20,-46.39},{1634.32,421.49,-62.18},{1631.17,411.70,-62.18},{1601.89,412.19,-62.29},{1612.30,380.28,-62.18}
        }
    end
    Map_1420()

    local function Map_1458() -- 幽暗城
        Sever_Map["幽暗城"] = {}
        Sever_Map["幽暗城"]["幽暗城 - 提瑞斯法林地"] = Reverse_Table(Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 幽暗城"])
    end
    Map_1458()

    local function Map_1422() -- 西瘟疫
        Sever_Map["西瘟疫"] = {}
        Sever_Map["西瘟疫"]["西瘟疫 - 提瑞斯法林地"] = Reverse_Table(Sever_Map["提瑞斯法林地"]["提瑞斯法林地 - 西瘟疫"])

        Sever_Map["西瘟疫"]["西瘟疫 - 东瘟疫"] = 
        {
        {1686.96,-1379.54,69.04},{1699.32,-1421.93,64.39},{1713.10,-1471.73,64.46},{1720.70,-1502.22,64.05},{1726.69,-1577.57,65.85},{1731.09,-1633.87,60.80},{1732.88,-1671.20,60.33},{1740.92,-1702.71,59.77},{1759.65,-1780.67,64.41},{1764.23,-1832.34,69.00},{1766.97,-1878.40,72.62},{1763.65,-1954.70,75.12},{1759.95,-1989.58,70.97},{1757.13,-2016.26,65.96},{1753.89,-2070.38,62.88},{1754.61,-2123.56,66.93},{1762.19,-2157.72,68.93},{1777.79,-2194.62,68.49},{1798.88,-2235.06,62.73},{1825.00,-2273.72,59.41},{1861.80,-2336.74,59.98},{1885.39,-2390.89,67.41},{1902.19,-2440.33,70.64},{1915.51,-2491.20,66.05},{1926.26,-2557.19,62.61},{1926.62,-2609.74,62.86},{1926.13,-2660.90,59.95},{1925.57,-2718.08,62.99},{1928.01,-2768.21,69.15},{1928.63,-2797.87,70.93},{1932.55,-2847.20,75.26},{1926.93,-2889.93,75.36},{1908.81,-2932.34,74.58},{1865.95,-2980.07,74.68},{1845.10,-3004.37,73.69},{1823.81,-3030.19,74.31},{1803.68,-3062.29,76.46},{1773.68,-3116.02,82.67},{1756.97,-3159.88,87.36},{1739.07,-3206.88,86.95},{1722.75,-3264.72,86.88},{1718.53,-3309.29,96.26},{1719.28,-3350.30,109.94},{1721.22,-3402.69,125.76},{1724.58,-3438.37,131.27},{1730.88,-3488.84,128.44},{1737.15,-3542.21,124.49},{1743.45,-3593.17,120.94},{1746.95,-3633.20,119.68},{1747.07,-3703.08,120.71},{1746.56,-3749.35,126.43},{1746.42,-3790.22,126.99},{1754.10,-3842.45,123.90},{1767.25,-3889.72,129.94},{1780.19,-3927.03,129.24},{1794.45,-3962.66,125.12},{1812.74,-4010.43,115.60},{1832.70,-4062.87,106.20},{1853.78,-4125.91,100.80},{1870.83,-4167.64,98.46},{1885.73,-4206.79,89.58},{1906.79,-4267.94,81.94},{1926.68,-4317.23,76.30},{1946.83,-4366.51,73.63},{1960.80,-4394.02,73.62}
        }
    end
    Map_1422()

    local function Map_1423() -- 东瘟疫
        Sever_Map["东瘟疫"] = {}
        Sever_Map["东瘟疫"]["东瘟疫 - 西瘟疫"] = Reverse_Table(Sever_Map["西瘟疫"]["西瘟疫 - 东瘟疫"])
    end
    Map_1423()
end
Sever_Navigation()
