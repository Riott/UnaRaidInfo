UnaRaidInfo = LibStub("AceAddon-3.0"):NewAddon("UnaRaidInfo", "AceConsole-3.0", "AceEvent-3.0");


function UnaRaidInfo:OnInitialize()
	local raidId, raid = next(una_raids)
	UnaRaidInfo:RegisterChatCommand("una", "UnaInfoHandler")
	UnaUIConfig = CreateFrame("Frame", "UnaRaidInfo", UIParent, "BasicFrameTemplateWithInset");
	UnaUIConfig:Hide();
	UnaUIConfig:SetSize(550, 600);
	UnaUIConfig:SetPoint("CENTER", UIParent, "CENTER");
	UnaUIConfig:SetFrameStrata("HIGH")
	UnaUIConfig:SetFrameLevel(10)

	UnaUIConfig.title = UnaUIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
	UnaUIConfig.title:SetPoint("LEFT", UnaUIConfig.TitleBg, "LEFT", 5, 0);
	UnaUIConfig.title:SetText(format("Raid Info for %s | Start Time: %s | End Time: %s", raid["date"], raid["start"],
		raid["end"]));

	UnaUIConfig.InsetBgFrame = CreateFrame("Frame", nil, UnaUIConfig)
	UnaUIConfig.InsetBgFrame:SetPoint("TOPLEFT", 10, -30)
	UnaUIConfig.InsetBgFrame:SetPoint("BOTTOMRIGHT", -10, 10)

	-- Create the ScrollFrame
	UnaUIConfig.RosterScrollFrame = CreateFrame("ScrollFrame", nil, UnaUIConfig.InsetBgFrame,
		"UIPanelScrollFrameTemplate")
	UnaUIConfig.RosterScrollFrame:SetPoint("TOPLEFT", 10, -20)
	UnaUIConfig.RosterScrollFrame:SetSize(500, 500)
	UnaUIConfig.RosterScrollFrame:Hide();


	rosterFrames = {}
	for bossName, bossTable in pairs(una_raids[raidId]["bosses"]) do
		local bossRosterFrame = CreateFrame("Frame", nil, UnaUIConfig.RosterScrollFrame)
		bossRosterFrame:Hide()
		bossRosterFrame:SetSize(530, 500)

		local raidRosterEvent = CreateFrame("Frame", nil, bossRosterFrame)
		raidRosterEvent:RegisterEvent("GROUP_ROSTER_UPDATE")
		-- Event handler function
		raidRosterEvent:SetScript("OnEvent", function(self, event)
			C_PartyInfo.ConvertToRaid()
		end)

		local inviteButton = CreateFrame("Button", nil, bossRosterFrame, "UIPanelButtonTemplate")
		inviteButton:SetPoint("TOPRIGHT", -100, 0)
		inviteButton:SetSize(150, 30)
		inviteButton:SetText("Invite All")
		inviteButton:SetScript("OnClick", function()
			C_PartyInfo.ConvertToRaid()
			for _, players in pairs(bossTable["roster"]) do
				for playerName, playerTable in pairs(players) do
					C_PartyInfo.InviteUnit(format("%s-%s", playerName, playerTable["realm"]))
				end
			end
		end)
		inviteButton:RegisterEvent("GROUP_ROSTER_UPDATE")

		local kickButton = CreateFrame("Button", nil, bossRosterFrame, "UIPanelButtonTemplate")
		kickButton:SetPoint("TOPRIGHT", -100, -50)
		kickButton:SetSize(150, 30)
		kickButton:SetText("Kick Non Rostered")
		kickButton:SetScript("OnClick", function()
			for i = 1, GetNumGroupMembers() do
				-- Get raid member info
				local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(
					i)
				local nameNoRealm, realm = strsplit("-", name)
				if not bossTable["roster"]["tanks"][nameNoRealm]
					and not bossTable["roster"]["melee"][nameNoRealm]
					and not bossTable["roster"]["healers"][nameNoRealm]
					and not bossTable["roster"]["ranged"][nameNoRealm] then
					--print("thinking about removing", name, " ", nameNoRealm)
					UninviteUnit(name)
				end
			end
		end)

		local roleCount = 1
		local playerCount = 1
		for role, players in pairs(bossTable["roster"]) do
			local roleText = bossRosterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			roleText:SetText(string.upper(role))
			roleText:SetPoint("TOPLEFT", 0, -30 * roleCount)
			roleText:SetTextColor(1, 1, 1, 1)
			for playerName, playerTable in pairs(players) do
				local playerText = bossRosterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				playerText:SetPoint("TOPLEFT", 0, -30 * (roleCount + playerCount))
				playerText:SetText(format("%s - %s - %s", playerName, playerTable["class"], playerTable["realm"]))
				playerCount = playerCount + 1
			end
			roleCount = roleCount + playerCount
			playerCount = 1
		end

		rosterFrames[bossName] = bossRosterFrame
	end

	local Dropdown = CreateFrame("DropdownButton", nil, UnaUIConfig.InsetBgFrame, "WowStyle1DropdownTemplate")
	Dropdown:SetDefaultText("Select a Boss Encounter")
	Dropdown:SetPoint("TOPLEFT")
	Dropdown:SetSize(200, 30)
	Dropdown:SetFrameStrata("DIALOG") -- Ensure the dropdown is above the scroll frame
	Dropdown:SetFrameLevel(20)     -- Ensure the dropdown is above the scroll frame
	Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateTitle("Boss Encounters")
		for bossName, _ in pairs(rosterFrames) do
			rootDescription:CreateButton(bossName, function()
				dropdown:SetDefaultText(bossName)
				for _, frame in pairs(rosterFrames) do
					frame:Hide()
				end
				UnaUIConfig.RosterScrollFrame:Hide();
				local rosterFrame = rosterFrames[bossName]
				UnaUIConfig.RosterScrollFrame:SetScrollChild(rosterFrame)
				UnaUIConfig.RosterScrollFrame:Show();
				rosterFrame:Show()
			end)
		end
	end)






	-- -- Create and set the texture -- trigger
	-- UnaUIConfig.InsetBg = UnaUIConfig.InsetBgFrame:CreateTexture(nil, "BACKGROUND")
	-- UnaUIConfig.InsetBg:SetTexture(format("Interface\\Addons\\UnaRaidInfo\\%s", raid["picture"]))
	-- UnaUIConfig.InsetBg:SetAllPoints(UnaUIConfig.InsetBgFrame)


	-- Make the frame draggable
	UnaUIConfig:SetMovable(true);
	UnaUIConfig:EnableMouse(true);
	UnaUIConfig:RegisterForDrag("LeftButton");
	UnaUIConfig:SetScript("OnDragStart", UnaUIConfig.StartMoving);
	UnaUIConfig:SetScript("OnDragStop", UnaUIConfig.StopMovingOrSizing);

	UnaUIConfig:SetResizable(false)
	UnaUIConfig:SetResizeBounds(450, 300)


	-- Add resize handle
	local resizeButton = CreateFrame("Button", nil, UnaUIConfig)
	resizeButton:SetPoint("BOTTOMRIGHT", -6, 7)
	resizeButton:SetSize(16, 16)
	resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")



	resizeButton:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			UnaUIConfig:StartSizing("BOTTOMRIGHT")
			self:GetHighlightTexture():Hide() -- more noticeable
		end
	end)

	resizeButton:SetScript("OnMouseUp", function(self, button)
		UnaUIConfig:StopMovingOrSizing()
		self:GetHighlightTexture():Show()
	end)

	UnaUIConfig:Hide();
end

function UnaRaidInfo:OnEnable()
	-- Called when the addon is enabled

	-- Print a message to the chat frame
	self:Print("UnaRaidInfo Loaded: use /una to show upcoming raid info")
end

function UnaRaidInfo:OnDisable()
	-- Called when the addon is disabled
end

function UnaRaidInfo:UnaInfoHandler()
	if UnaUIConfig:IsVisible() then
		UnaUIConfig:Hide();
	else
		UnaUIConfig:Show();
	end
end
