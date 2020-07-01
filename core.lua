Raidinfos = LibStub("AceAddon-3.0"):NewAddon("Raidinfos", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Raidinfos", true)

function Raidinfos:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.

  self.db = LibStub("AceDB-3.0"):New("RaidinfosDB", defaults)
  
  self.db.global.instances = nil -- old version data
  if self.db.global.savedinstances == nil then self.db.global.savedinstances = {} end
	
  self:RegisterChatCommand("raidinfos", "ShowRaidinfos")
  self.RaidinfosFrameVar = nil
  
  -- main event: do something when the Loot Window is being shown
  Raidinfos:RegisterEvent("PLAYER_ENTERING_WORLD")
  
end

function Raidinfos:OnEnable()
    -- Called when the addon is enabled
end

function Raidinfos:OnDisable()
    -- Called when the addon is disabled
end


function Raidinfos:PLAYER_ENTERING_WORLD()
	Raidinfos:SaveRaids()
end


function Raidinfos:RemoveOldRaids()
	if Raidinfos.db.global.savedinstances == nil then return end
	
	for realm,players in pairs(Raidinfos.db.global.savedinstances) do
		for player,raids in pairs(players) do
			for i,r in pairs(raids) do
				if r["r"] <= time() then
					Raidinfos.db.global.savedinstances[realm][player][r["i"]] = nil
				end		
			end
		end
	end
end


GetRealmName()

function Raidinfos:SaveRaids()
	-- always also expire raids when saving new
	Raidinfos:RemoveOldRaids()
	
	player = GetUnitName("player")
	realm = GetRealmName()
	
	-- longest (current, Classic) realm for debug purposes
	-- realm = "Hydraxian Waterlords"
	
	if Raidinfos.db.global.savedinstances[realm] == nil then Raidinfos.db.global.savedinstances[realm] = {} end
	if Raidinfos.db.global.savedinstances[realm][player] == nil then Raidinfos.db.global.savedinstances[realm][player] = {} end
	
	numInstances = GetNumSavedInstances()

	for i = 1,numInstances do
		name, id, seconds = GetSavedInstanceInfo(i)
		
		reset = time() + seconds
		resetstring = date("%d %B %Y %H:%M (%A)", reset)
		
		-- longest month for debug purposes
		-- resetstring = "31 September 2020 20:20 (Wednesday)"

		Raidinfos.db.global.savedinstances[realm][player][id] = {srv = realm, n = name, i = id, r = reset, s = resetstring}
	end
	
end

function Raidinfos:ShowRaidinfos(param1)
	if Raidinfos.RaidinfosFrameVar then
		Raidinfos.RaidinfosFrameVar:Hide()
		Raidinfos.RaidinfosFrameVar = nil
	end
	
	if param1 and strlower(param1) == "matrix" then
		Raidinfos.RaidinfosFrameVar = Raidinfos:createRaidinfosMatrixFrame()
	else
		Raidinfos.RaidinfosFrameVar = Raidinfos:createRaidinfosFrame()
	end
	
	if Raidinfos.RaidinfosFrameVar then 
		Raidinfos.RaidinfosFrameVar:Show()
	end
end

function Raidinfos:createRaidinfosFrame()
	local AceGUI = LibStub("AceGUI-3.0")

	Raidinfos:SaveRaids()
	if Raidinfos.db.global.savedinstances == nil then 
		Raidinfos:Print("No Lockouts.")
		return;
	end
	
	local f = AceGUI:Create("Frame")
	f:SetTitle("Raidinfos")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(640)
	f:SetHeight(250)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
	
	-- close on escape
	_G["RaidinfosFrame"] = f.frame
	tinsert(UISpecialFrames, "RaidinfosFrame")
	
	scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	f:AddChild(scrollcontainer)

	s = AceGUI:Create("ScrollFrame")
	s:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(s)

	
	sizes = {0.19, 0.18, 0.17, 0.12, 0.34}
	
	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Realm")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(sizes[1])
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Player")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(sizes[2])
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Raid")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(sizes[3])
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("ID")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(sizes[4])
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Expire")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(sizes[5])
	s:AddChild(lbHR)
	
	for realm,players in pairs(Raidinfos.db.global.savedinstances) do
		for player,raids in pairs(players) do
			for i,raid in pairs(raids) do

				local lbPlayerName = AceGUI:Create("Label")
				lbPlayerName:SetText(realm)
				lbPlayerName:SetRelativeWidth(sizes[1])
				s:AddChild(lbPlayerName)

				local lbPlayerName = AceGUI:Create("Label")
				lbPlayerName:SetText(player)
				lbPlayerName:SetRelativeWidth(sizes[2])
				s:AddChild(lbPlayerName)

				local lbRaid = AceGUI:Create("Label")
				lbRaid:SetText(raid["n"])
				lbRaid:SetRelativeWidth(sizes[3])
				s:AddChild(lbRaid)

				local lbID = AceGUI:Create("Label")
				lbID:SetText(raid["i"])
				lbID:SetRelativeWidth(sizes[4])
				s:AddChild(lbID)

				local lbReset = AceGUI:Create("Label")
				lbReset:SetText(raid["s"])
				lbReset:SetRelativeWidth(sizes[5])
				s:AddChild(lbReset)
	
			end
		end
	end
	
	local empty = AceGUI:Create("Label")
	empty:SetText(" ")
	empty:SetRelativeWidth(1)
	s:AddChild(empty)
	
	local bt = AceGUI:Create("Button")
	bt:SetText("Matrix " .. GetRealmName())
	bt:SetRelativeWidth(0.4)
	bt:SetCallback("OnClick", function() Raidinfos:ShowRaidinfos("matrix") end)
	s:AddChild(bt)

	
	return f
end


function Raidinfos:createRaidinfosMatrixFrame()
	local AceGUI = LibStub("AceGUI-3.0")

	Raidinfos:SaveRaids()
	if Raidinfos.db.global.savedinstances == nil then 
		Raidinfos:Print("No Lockouts.")
		return;
	end
	if Raidinfos.db.global.savedinstances[GetRealmName()] == nil then 
		Raidinfos:Print("No Lockouts for " .. GetRealmName())
		return;
	end
	
	local f = AceGUI:Create("Frame")
	f:SetTitle("Raid Matrix " .. GetRealmName())
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(640)
	f:SetHeight(250)
	f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
	
	-- close on escape
	_G["RaidinfosMatrixFrame"] = f.frame
	tinsert(UISpecialFrames, "RaidinfosMatrixFrame")
	
	scrollcontainer = AceGUI:Create("SimpleGroup") -- "InlineGroup" is also good
	scrollcontainer:SetFullWidth(true)
	scrollcontainer:SetFullHeight(true) -- probably?
	scrollcontainer:SetLayout("Fill") -- important!

	f:AddChild(scrollcontainer)

	s = AceGUI:Create("ScrollFrame")
	s:SetLayout("Flow") -- probably?
	scrollcontainer:AddChild(s)

	-- show only current realm
	local instances = {}
	
	players = Raidinfos.db.global.savedinstances[GetRealmName()]
	for player,raids in pairs(players) do
		for i,raid in pairs(raids) do
			instances[raid["n"]] = raid["n"]
		end
	end

	count = 0
	for _ in pairs(instances) do count = count + 1 end
	
	perc = 1 / (count+1)
	
	local lb = AceGUI:Create("Label")
	lb:SetText("Player")
	lb:SetColor(0,0.6,1)
	lb:SetRelativeWidth(perc)
	s:AddChild(lb)
	
	for raid,r2 in pairs(instances) do
		local lb = AceGUI:Create("Label")
		lb:SetText(r2)
		lb:SetColor(0.8,0,0.8)
		lb:SetRelativeWidth(perc)
		s:AddChild(lb)
	end


  	for player,raids in pairs(players) do
		
		local lb = AceGUI:Create("Label")
		lb:SetText(player)
		lb:SetRelativeWidth(perc)
		s:AddChild(lb)
	
		for iraid, raid in pairs(instances) do

			found = false
			
			for id,r in pairs(raids) do
				if (r["n"] == raid) then
				    found = true
					local lb = AceGUI:Create("Label")
					lb:SetText(strmatch(r["s"],"^%d+%s[^%s*]+%s%d+"))
					lb:SetRelativeWidth(perc)
					s:AddChild(lb)
				end
			end
			
			if not found then
				local lb = AceGUI:Create("Label")
				lb:SetText("-")
				lb:SetRelativeWidth(perc)
				s:AddChild(lb)
			end
		
		end
	end

	local empty = AceGUI:Create("Label")
	empty:SetText(" ")
	empty:SetRelativeWidth(1)
	s:AddChild(empty)
	
	local bt = AceGUI:Create("Button")
	bt:SetText("List")
	bt:SetRelativeWidth(2*perc)
	bt:SetCallback("OnClick", function() Raidinfos:ShowRaidinfos() end)
	s:AddChild(bt)
	
	return f
end
