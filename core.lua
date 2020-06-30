Raidinfos = LibStub("AceAddon-3.0"):NewAddon("Raidinfos", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Raidinfos", true)

function Raidinfos:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.

  self.db = LibStub("AceDB-3.0"):New("RaidinfosDB", defaults)
  if self.db.global.instances == nil then self.db.global.instances = {} end
	
  self:RegisterChatCommand("raidinfos", "ShowRaidinfos")
  self.RaidinfosFrameVar = nil
  
  -- main event: do something when the Loot Window is being shown
  Raidinfos:RegisterEvent("PLAYER_ENTERING_WORLD")
--  Raidinfos:RegisterEvent("START_LOOT_ROLL")
  
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
	if Raidinfos.db.global.instances[GetUnitName("player")] == nil then return end
	
	for i,r in pairs(Raidinfos.db.global.instances[GetUnitName("player")]) do
		if r["r"] <= time() then
			Raidinfos.db.global.instances[GetUnitName("player")][r["i"]] = nil
		end		
	end
end

function Raidinfos:SaveRaids()
	-- always also expire raids when saving new
	Raidinfos:RemoveOldRaids()
	
	if Raidinfos.db.global.instances[GetUnitName("player")] == nil then Raidinfos.db.global.instances[GetUnitName("player")] = {} end
	
	numInstances = GetNumSavedInstances()

	for i = 1,numInstances do
		name, id, seconds = GetSavedInstanceInfo(i)
		
		reset = time() + seconds
		resetstring = date("%A, %m %B %Y %H:%M", reset)

		Raidinfos.db.global.instances[GetUnitName("player")][id] = {n = name, i = id, r = reset, s = resetstring}
		 
	end
	
end

function Raidinfos:ShowRaidinfos()
	Raidinfos.RaidinfosFrameVar = Raidinfos:createRaidinfosFrame()
	Raidinfos.RaidinfosFrameVar:Show()
end

function Raidinfos:createRaidinfosFrame()
	local AceGUI = LibStub("AceGUI-3.0")

	Raidinfos:SaveRaids()
	if Raidinfos.db.global.instances[GetUnitName("player")] == nil then 
		Raidinfos:Print("No Lockouts.")
		return;
	end
	
	local f = AceGUI:Create("Frame")
	f:SetTitle("Raidinfos")
	f:SetStatusText("")
	f:SetLayout("Flow")
	f:SetWidth(500)
	f:SetHeight(200)
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

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Player")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(0.18)
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Raid")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(0.20)
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("ID")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(0.15)
	s:AddChild(lbHR)

	local lbHR = AceGUI:Create("Label")
	lbHR:SetText("Expire")
	lbHR:SetColor(0,0.6,1)
	lbHR:SetRelativeWidth(0.47)
	s:AddChild(lbHR)
	
	for player,raids in pairs(Raidinfos.db.global.instances) do
		for id,raid in pairs(Raidinfos.db.global.instances[player]) do

			local lbPlayerName = AceGUI:Create("Label")
			lbPlayerName:SetText(player)
			lbPlayerName:SetRelativeWidth(0.18)
			s:AddChild(lbPlayerName)

			local lbRaid = AceGUI:Create("Label")
			lbRaid:SetText(raid["n"])
			lbRaid:SetRelativeWidth(0.20)
			s:AddChild(lbRaid)

			local lbID = AceGUI:Create("Label")
			lbID:SetText(raid["i"])
			lbID:SetRelativeWidth(0.15)
			s:AddChild(lbID)

			local lbReset = AceGUI:Create("Label")
			lbReset:SetText(raid["s"])
			lbReset:SetRelativeWidth(0.47)
			s:AddChild(lbReset)
			
		end
	end
	
	return f
end
