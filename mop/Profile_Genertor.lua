Function_Load_In = true
local Function_Version = "0922"
textout(Check_UI("自定义脚本生成 - "..Function_Version,"Profile Generator - "..Function_Version))

awm.RunMacroText("/console scriptErrors 1")

local gg = 1
Node_List = {}
Node_Frame = {}

function CreateButton()

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
	buttontext2:SetText(Check_UI("记录点位","Record"))
	buttontext2:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext2:SetPoint("Center")
	button2:SetPoint("Top")
	button2:SetSize(150,30)
	button2:Show()
	button2:SetScript("OnClick", function(self)
		local x,y,z = awm.ObjectPosition("player")
		x = string.format("%.2f", x)
		y = string.format("%.2f", y)
		z = string.format("%.2f", z)

		local Coord = {x,y,z}

		Node_List[#Node_List + 1] = Coord

		List_Update()

		print(gg..Check_UI(" 点记录成功"," Node Record"))
	    gg = gg + 1
	end)

	local button3 = CreateFrame("Button","button3",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext3 = button3:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext3:SetText(Check_UI("角色位置","Player Position"))
	buttontext3:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext3:SetPoint("Center")
	button3:SetPoint("Top",0,-50)
	button3:SetSize(150,30)
	button3:Show()
	button3:SetScript("OnClick", function(self)
	    local x,y,z = awm.ObjectPosition("player")
		x = string.format("%.4f", x)
		y = string.format("%.4f", y)
		z = string.format("%.4f", z)
		print("mapid = ",C_Map.GetBestMapForUnit("player"),"Coord = ",x,y,z)
		awm.CopyToClipboard(x..","..y..","..z)
		print(Check_UI("已经复制到粘贴板","Already copied to keyboard"))
	end)

	local button4 = CreateFrame("Button","button4",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext4 = button4:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext4:SetText(Check_UI("目标ID","Target Id"))
	buttontext4:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext4:SetPoint("Center")
	button4:SetPoint("Top",0,-100)
	button4:SetSize(150,30)
	button4:Show()
	button4:SetScript("OnClick", function(self)
	    local id = awm.ObjectId("target")
		print(id)
	end)

	local button5 = CreateFrame("Button","button5",ButtonLayout, "UIPanelButtonTemplate")
	local buttontext5 = button5:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
	buttontext5:SetText(Check_UI("附近目标","Scan All Objects"))
	buttontext5:SetTextColor(0.8039,0.5215,0.247,1)
	buttontext5:SetPoint("Center")
	button5:SetPoint("Top",0,-150)
	button5:SetSize(150,30)
	button5:Show()
	button5:SetScript("OnClick", function(self)
	    local total = awm.GetObjectCount()
		for i = 1,total do
			local ThisUnit = awm.GetObjectWithIndex(i)
			if awm.IsGuid(ThisUnit) then
				local guid = awm.ObjectId(ThisUnit)
				local name = awm.UnitFullName(ThisUnit)
				local distance = awm.GetDistanceBetweenObjects("player",ThisUnit)
				if awm.ObjectExists(ThisUnit) then
					print(name,ThisUnit,guid,math.floor(distance))
				end
			end
		end
		print(Check_UI("格式 = 名字,怪物地址,物体ID,与玩家距离","Formation = name,pointer,id,distance"))
	end)
end
CreateButton()

function List_Update()
    Basic_UI.Node.Py = -65

    if #Node_List > 0 then
	    for i = 1,#Node_List do
		    local x,y,z = Node_List[i][1],Node_List[i][2],Node_List[i][3]
			local string = Check_UI("顺序 = ","Node = ")..i.." - - - - - - ".."X = "..x..", Y = "..y..", Z = "..z

			if not Node_Frame[i] then
				Node_Frame[i] = Create_Header(Basic_UI.Node.frame,"TOPLEFT",10, Basic_UI.Node.Py,string)
			else
			    Node_Frame[i]:SetPoint("TOPLEFT",10, Basic_UI.Node.Py)
			    Node_Frame[i]:SetText(string)
				Node_Frame[i]:Show()
			end

			Basic_UI.Node.Py = Basic_UI.Node.Py - 25
		end
	end

	if #Node_Frame > #Node_List then
	    for i = #Node_List + 1,#Node_Frame do
		    Node_Frame[i]:Hide()
		end
	end

	if Basic_UI.Node.Py < -1500 then
	    Basic_UI.Panel:SetSize(750,math.abs(Basic_UI.Node.Py) + 100)
	else
	    Basic_UI.Panel:SetSize(750,1500)
	end
end

function OutPut_File()
    local Full_String = ""
    local Coord_string = "Mobs_Coord = {\n"
	if #Node_List > 0 then
	    for i = 1,#Node_List do
		    local x,y,z = Node_List[i][1],Node_List[i][2],Node_List[i][3]
			local string = "{"..x..","..y..","..z.."},\n"
			Coord_string = Coord_string..string
		end
	end
	Coord_string = Coord_string.."}\n\n"

	local Map_ID_String = "Mobs_MapID = 1944 \n\n"

	local Vendor_Coord = string.split(Basic_UI.Custom["自定义商人坐标"]:GetText(),",")
	local Vendor_String = "Merchant_Name = "..[["]]..Basic_UI.Custom["自定义商人名字"]:GetText()..[["]].."\n".."Merchant_Coord.mapid,Merchant_Coord.x,Merchant_Coord.y,Merchant_Coord.z = "..Vendor_Coord[1]..","..Vendor_Coord[2]..","..Vendor_Coord[3]..","..Vendor_Coord[4].."\n\n"

	local Mail_Coord = string.split(Basic_UI.Custom["自定义邮箱坐标"]:GetText(),",")
	local Mail_String = "Mail_Coord.mapid,Mail_Coord.x,Mail_Coord.y,Mail_Coord.z = "..Mail_Coord[1]..","..Mail_Coord[2]..","..Mail_Coord[3]..","..Mail_Coord[4].."\n\n"

	local Ammo_Coord = string.split(Basic_UI.Custom["子弹商人坐标"]:GetText(),",")
	local Ammo_String = "Ammo_Vendor_Name = "..[["]]..Basic_UI.Custom["子弹商人名字"]:GetText()..[["]].."\n".."Ammo_Vendor_Coord.mapid,Ammo_Vendor_Coord.x,Ammo_Vendor_Coord.y,Ammo_Vendor_Coord.z = "..Ammo_Coord[1]..","..Ammo_Coord[2]..","..Ammo_Coord[3]..","..Ammo_Coord[4].."\n\n"

	local Food_Coord = string.split(Basic_UI.Custom["食物商人坐标"]:GetText(),",")
	local Food_String = "Food_Vendor_Name = "..[["]]..Basic_UI.Custom["食物商人名字"]:GetText()..[["]].."\n".."Food_Vendor_Coord.mapid,Food_Vendor_Coord.x,Food_Vendor_Coord.y,Food_Vendor_Coord.z = "..Food_Coord[1]..","..Food_Coord[2]..","..Food_Coord[3]..","..Food_Coord[4].."\n\n"

	local Pet_Food_Coord = string.split(Basic_UI.Custom["宠物食物商人坐标"]:GetText(),",")
	local Pet_Food_String = "Pet_Food_Vendor_Name = "..[["]]..Basic_UI.Custom["宠物食物商人名字"]:GetText()..[["]].."\n".."Pet_Food_Vendor_Coord.mapid,Pet_Food_Vendor_Coord.x,Pet_Food_Vendor_Coord.y,Pet_Food_Vendor_Coord.z = "..Pet_Food_Coord[1]..","..Pet_Food_Coord[2]..","..Pet_Food_Coord[3]..","..Pet_Food_Coord[4].."\n\n"

	local Food_name = "Food_Name = "..[["]]..Basic_UI.Custom["食物名字"]:GetText()..[["]].."\n\n"
	local Drink_name = "Drink_Name = "..[["]]..Basic_UI.Custom["饮料名字"]:GetText()..[["]].."\n\n"
	local Pet_Food_name = "Pet_Food_name = "..[["]]..Basic_UI.Custom["宠物食物名字"]:GetText()..[["]].."\n\n"

	local Mobs_ID_String = "Mobs_ID = {\n"
	local Mobs_ID_table = string.split(Basic_UI.Custom["Mobs_ID"]:GetText(),",")

	if #Mobs_ID_table > 0 then
	    for i = 1,#Mobs_ID_table do
			if tonumber(Mobs_ID_table[i]) then
			    Mobs_ID_String = Mobs_ID_String..""..Mobs_ID_table[i]..",\n"
			else
			    Mobs_ID_String = Mobs_ID_String..[["]]..Mobs_ID_table[i]..[[",]].."\n"
			end
		end
	end
	Mobs_ID_String = Mobs_ID_String.."}\n\n"

	Full_String = Coord_string..Map_ID_String..Vendor_String..Mail_String..Ammo_String..Food_String..Pet_Food_String..Food_name..Drink_name..Pet_Food_name..Mobs_ID_String

	awm.WriteFile(tostring(Easy_Data["记录文件路径"]), Full_String, false)
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
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Custom.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("自定义","Custom"))
		Basic_UI.Custom.button:SetSize(135,20)
		Basic_UI.Custom.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Custom.frame:Show()
			Basic_UI.Custom.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Custom.frame:Hide()Basic_UI.Custom.button:SetBackdropColor(0,0,0,0) end
	end

	local function File_Position()
		local Header2 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("文件记录路径","File Record Route")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20
		Basic_UI.Custom["记录文件路径"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,[[C:\\Record.lua]],false,280,24)
		Basic_UI.Custom["记录文件路径"]:SetScript("OnEditFocusLost", function(self)
			Easy_Data["记录文件路径"] = Basic_UI.Custom["记录文件路径"]:GetText()
		end)
		if Easy_Data["记录文件路径"] ~= nil then
			Basic_UI.Custom["记录文件路径"]:SetText(Easy_Data["记录文件路径"])
		else
			Easy_Data["记录文件路径"] = Basic_UI.Custom["记录文件路径"]:GetText()
		end

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30

		Basic_UI.Custom["输出按钮"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",10,Basic_UI.Custom.Py,Check_UI("输出自定义文件","Write the Custome File"))
		Basic_UI.Custom["输出按钮"]:SetSize(150,20)
		Basic_UI.Custom["输出按钮"]:SetScript("OnClick", function(self)
            OutPut_File()
		end)
	end

	local function Custom_Vendor()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("商人名字","Vendor Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["自定义商人名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)

		Basic_UI.Custom["获取商人名字"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取目标名字","Generate Full Name"))
		Basic_UI.Custom["获取商人名字"]:SetSize(150,24)
		Basic_UI.Custom["获取商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Custom["自定义商人名字"]:SetText(name)
				Easy_Data["自定义商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("自定义商人坐标","Custom Vendor Coordinate")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["自定义商人坐标"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,"mapid,x,y,z",false,280,24)

		Basic_UI.Custom["获取商人坐标"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Custom["获取商人坐标"]:SetSize(150,24)
		Basic_UI.Custom["获取商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Custom["自定义商人坐标"]:SetText(string)
			Easy_Data["自定义商人坐标"] = string
		end)
	end

	local function Custom_Mail()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("邮箱坐标","Mail Coordinate")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["自定义邮箱坐标"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,"mapid,x,y,z",false,280,24)


		Basic_UI.Custom["获取邮箱坐标"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Custom["获取邮箱坐标"]:SetSize(150,24)
		Basic_UI.Custom["获取邮箱坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Custom["自定义邮箱坐标"]:SetText(string)
			Easy_Data["自定义邮箱坐标"] = string
		end)
	end

	local function Custom_Ammo()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("子弹商人名字","Bullet Vendor Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["子弹商人名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)


		Basic_UI.Custom["获取子弹商人名字"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取目标名字","Generate Full Name"))
		Basic_UI.Custom["获取子弹商人名字"]:SetSize(150,24)
		Basic_UI.Custom["获取子弹商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Custom["子弹商人名字"]:SetText(name)
				Easy_Data["子弹商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("子弹商人坐标","Bullet Vendor Coordinate")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["子弹商人坐标"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,"mapid,x,y,z",false,280,24)

		Basic_UI.Custom["获取子弹商人坐标"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Custom["获取子弹商人坐标"]:SetSize(150,24)
		Basic_UI.Custom["获取子弹商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Custom["子弹商人坐标"]:SetText(string)
			Easy_Data["子弹商人坐标"] = string
		end)
	end

	local function Custom_Food_Vendor()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("食物商人名字","Food Vendor Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["食物商人名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)

		Basic_UI.Custom["获取食物商人名字"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取目标名字","Generate Full Name"))
		Basic_UI.Custom["获取食物商人名字"]:SetSize(150,24)
		Basic_UI.Custom["获取食物商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Custom["食物商人名字"]:SetText(name)
				Easy_Data["食物商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("食物商人坐标","Food Vendor Coordinate")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["食物商人坐标"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,"mapid,x,y,z",false,280,24)

		Basic_UI.Custom["获取食物商人坐标"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Custom["获取食物商人坐标"]:SetSize(150,24)
		Basic_UI.Custom["获取食物商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Custom["食物商人坐标"]:SetText(string)
			Easy_Data["食物商人坐标"] = string
		end)
	end

	local function Custom_Pet_Food_Vendor()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("宠物食物商人名字","Pet food Vendor Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["宠物食物商人名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)

		Basic_UI.Custom["获取宠物食物商人名字"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取目标名字","Generate Full Name"))
		Basic_UI.Custom["获取宠物食物商人名字"]:SetSize(150,24)
		Basic_UI.Custom["获取宠物食物商人名字"]:SetScript("OnClick", function(self)
			if awm.ObjectExists("target") then
			    local name = awm.UnitFullName("target")
				if name == nil then
				    textout(Check_UI("商人名字为空","A blank name"))
				    return
				end
				Basic_UI.Custom["宠物食物商人名字"]:SetText(name)
				Easy_Data["宠物食物商人名字"] = name
			else
			    textout(Check_UI("请先选择一个目标","Choose a target first"))
			end
		end)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("宠物食物商人坐标","Pet Food Vendor Coordinate")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["宠物食物商人坐标"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,"mapid,x,y,z",false,280,24)

		Basic_UI.Custom["获取宠物食物商人坐标"] = Create_Button(Basic_UI.Custom.frame,"TOPLEFT",320, Basic_UI.Custom.Py,Check_UI("获取坐标","Generate Coord"))
		Basic_UI.Custom["获取宠物食物商人坐标"]:SetSize(150,24)
		Basic_UI.Custom["获取宠物食物商人坐标"]:SetScript("OnClick", function(self)
			local x,y,z = awm.ObjectPosition("player")
			local Current_Map = C_Map.GetBestMapForUnit("player")
			local string = Current_Map..","..math.floor(x)..","..math.floor(y)..","..math.floor(z)
			Basic_UI.Custom["宠物食物商人坐标"]:SetText(string)
			Easy_Data["宠物食物商人坐标"] = string
		end)
	end

	local function Custom_Food()
		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("食物名字","Food Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["食物名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("饮料名字","Drink Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["饮料名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)


		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
		local Header1 = Create_Header(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("宠物食物名字","Pet Food Full Name")) 

		Basic_UI.Custom.Py = Basic_UI.Custom.Py - 20

		Basic_UI.Custom["宠物食物名字"] = Create_EditBox(Basic_UI.Custom.frame,"TOPLEFT",10, Basic_UI.Custom.Py,Check_UI("穆恩丹·秋谷","Sara Dan"),false,280,24)
	end

	local function Mobs()
	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    local header = Create_Header(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,Check_UI("怪物, 采集列表","Mobs, Items List"))

	    Basic_UI.Custom.Py = Basic_UI.Custom.Py - 30
	    Basic_UI.Custom["Mobs_ID"] = Create_Scroll_Edit(Basic_UI.Custom.frame,"TopLeft",10,Basic_UI.Custom.Py,"item1,item2,item3,银叶草,梦露花,精金矿",570,200)
	end

	Frame_Create()
	Button_Create()
	File_Position()
	Custom_Vendor()
	Custom_Mail()
	Custom_Ammo()
	Custom_Food_Vendor()
	Custom_Pet_Food_Vendor()
	Custom_Food()
	Mobs()
end

local function Create_Node_UI()
    Basic_UI.Node = {}
	Basic_UI.Node.Py = -10
	local function Frame_Create()
		Basic_UI.Node.frame = CreateFrame('frame',"Basic_UI.Node.frame",Basic_UI.Panel, BackdropTemplateMixin and "BackdropTemplate")
		Basic_UI.Node.frame:SetPoint("TopLeft",150,0)
		Basic_UI.Node.frame:SetSize(600,1500)
		Basic_UI.Node.frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border",
		title= true, 
		edgeSize =15, 
		titleSize = 32})
		Basic_UI.Node.frame:Hide()
		Basic_UI.Node.frame:SetBackdropColor(0.1,0.1,0.1,0)
		Basic_UI.Node.frame:SetBackdropBorderColor(1,0,1,1)
		Basic_UI.Node.frame:SetFrameStrata('TOOLTIP')
	end

	local function Button_Create()
	    UI_Button_Py = UI_Button_Py - 30
		Basic_UI.Node.button = Create_Page_Button(Basic_UI["选项列表"], "Top",0,UI_Button_Py,Check_UI("路径列表","Nodes List"))
		Basic_UI.Node.button:SetSize(135,20)
		Basic_UI.Node.button:SetScript("OnClick", function(self)
			All_Buttons_Hide()
            Basic_UI.Node.frame:Show()
			Basic_UI.Node.button:SetBackdropColor(245/255 , 245/255, 220/255, 0.4)
		end)
        Config_UI[#Config_UI + 1] = function() Basic_UI.Node.frame:Hide()Basic_UI.Node.button:SetBackdropColor(0,0,0,0) end
	end

	local function File_Position()
		Basic_UI.Node["删除"] = Create_EditBox(Basic_UI.Node.frame,"TOPLEFT",10, Basic_UI.Node.Py,"1",false,280,24)

		Basic_UI.Node.Py = Basic_UI.Node.Py - 30

		Basic_UI.Node["删除按钮"] = Create_Button(Basic_UI.Node.frame,"TOPLEFT",10,Basic_UI.Node.Py,Check_UI("删除","Delete"))
		Basic_UI.Node["删除按钮"]:SetSize(100,20)
		Basic_UI.Node["删除按钮"]:SetScript("OnClick", function(self)
           table.remove(Node_List,tonumber(Basic_UI.Node["删除"]:GetText()))
		   List_Update()
		end)

	end

	Frame_Create()
	Button_Create()
	File_Position()
end

Create_Custom_UI()
Create_Node_UI()