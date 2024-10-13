UnaRaidInfo = LibStub("AceAddon-3.0"):NewAddon("UnaRaidInfo", "AceConsole-3.0", "AceEvent-3.0" );


function UnaRaidInfo:OnInitialize()
		-- Called when the addon is loaded

		-- Print a message to the chat frame
		local _, raid = next(una_raids)
		UnaRaidInfo:RegisterChatCommand("una", "UnaInfoHandler")
		UnaUIConfig = CreateFrame("Frame", "UnaRaidInfo", UIParent, "BasicFrameTemplateWithInset");
		UnaUIConfig:Hide();
		UnaUIConfig:SetSize(550, 600);
		UnaUIConfig:SetPoint("CENTER", UIParent, "CENTER");
		UnaUIConfig:SetFrameStrata("HIGH")
    	UnaUIConfig:SetFrameLevel(10)

		UnaUIConfig.title = UnaUIConfig:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
		UnaUIConfig.title:SetPoint("LEFT", UnaUIConfig.TitleBg, "LEFT", 5, 0);
		UnaUIConfig.title:SetText(format("Raid Info for %s | Start Time: %s | End Time: %s", raid["date"], raid["start"], raid["end"]));
		
		UnaUIConfig.InsetBgFrame = CreateFrame("Frame", nil, UnaUIConfig)
		UnaUIConfig.InsetBgFrame:SetPoint("TOPLEFT", 10, -30)
		UnaUIConfig.InsetBgFrame:SetPoint("BOTTOMRIGHT", -10, 10)
		
		-- Create and set the texture
		UnaUIConfig.InsetBg = UnaUIConfig.InsetBgFrame:CreateTexture(nil, "BACKGROUND")
		UnaUIConfig.InsetBg:SetTexture(format("Interface\\Addons\\UnaRaidInfo\\%s", raid["picture"]))
		UnaUIConfig.InsetBg:SetAllPoints(UnaUIConfig.InsetBgFrame)


		-- Make the frame draggable
		UnaUIConfig:SetMovable(true);
		UnaUIConfig:EnableMouse(true);
		UnaUIConfig:RegisterForDrag("LeftButton");
		UnaUIConfig:SetScript("OnDragStart", UnaUIConfig.StartMoving);
		UnaUIConfig:SetScript("OnDragStop", UnaUIConfig.StopMovingOrSizing);

		UnaUIConfig:SetResizable(true)
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
		self:Print("OnEnable Event Fired: Hello, again ;)")
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
