local ADDON_NAME, ns = ...

local L = {}
setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })
L.Version = "%s is the current version." -- ns.version
L.Install = "Thanks for installing |cff%1$sv%2$s|r! You can toggle sound with |cff%1$s/%3$s sound|r." -- ns.color, ns.version, ns.command
L.Update = "Thanks for updating to |cff%1$sv%2$s|r! You can toggle sound with |cff%1$s/%3$s sound|r." -- ns.color, ns.version, ns.command
L.How = "Type |cff%1$s/%2$s sound|r to toggle sounds." -- ns.color, ns.command
L.Support = "For feedback and support: |cff%1$s%2$s|r" -- ns.color ns.discord
L.Sound = "Sounds are %s." -- ON/OFF
L.On = "ON"
L.Off = "OFF"

local duration = 3.0
local size = 128
local textureID = 449490
local soundID = 16552
local color = {1, 0.5, 0.5, 0.9}
local firestormAuras = {333097, 333100, 1459}
local hadFirestorm, hasFirestorm = false, false

local function contains(table, input)
    for index, value in ipairs(table) do
        if value == input then
            return index
        end
    end
    return false
end

local function PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. "|r\n" .. message)
end

function ns:DFPY_Build()
    self.Display = CreateFrame("Frame", ADDON_NAME .. "Display", UIParent)
    self.Display:SetFrameStrata("LOW")
    self.Display:SetWidth(size * 4)
    self.Display:SetHeight(size * 2)
    self.Display:SetPoint("CENTER", 0, 0)

    local l = self.Display:CreateTexture()
    l:SetWidth(size)
    l:SetHeight(size * 2)
    l:SetPoint("LEFT", 0, 0)
    l:SetTexture(textureID)
    l:SetVertexColor(color[1], color[2], color[3], color[4])

    local r = self.Display:CreateTexture()
    r:SetWidth(size)
    r:SetHeight(size * 2)
    r:SetPoint("RIGHT", 0, 0)
    r:SetTexture(textureID)
    r:SetVertexColor(color[1], color[2], color[3], color[4])
    r:SetTexCoord(1, 0, 0, 1)

    self.Display:Hide()
end

function ns:DFPY_Check()
    if not self.Display then
        return
    end

    hasFirestorm = false
    for i = 1, 40 do
        local s, _ = select(10, UnitBuff("player", i))
        if contains(firestormAuras, s) then
            hasFirestorm = true
            break
        end
    end

    if not hadFirestorm and hasFirestorm then
        if sound then
            PlaySound(soundID, "SFX")
        end
        UIFrameFadeIn(self.Display, 0.05, 0, 1)
        self.Display:Show()
        C_Timer.After(duration - 0.2, function()
            UIFrameFadeOut(self.Display, 0.2, 1, 0)
        end)
    elseif hadFirestorm and not hasFirestorm then
        self.Display:Hide()
    end

    hadFirestorm = hasFirestorm
end

function DFPY_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("UNIT_AURA")
end

function DFPY_OnEvent(self, event, arg, ...)
    if event == "UNIT_AURA" and arg == "player" then
        ns:DFPY_Check()
    elseif event == "PLAYER_LOGIN" then
        if not DFPY_version then
            PrettyPrint(string.format(L.Install, ns.color, ns.version))
        elseif DFPY_version ~= ns.version then
            ns:PrettyPrint(string.format(L.Update, ns.color, ns.version, ns.command))
        end
        DFPY_version = ns.version
        if DFPY_sound == nil then DFPY_sound = true end
        PrettyPrint(string.format(L.Sound, DFPY_sound and L.On or L.Off) .. " " .. string.format(L.How, ns.color, ns.command))
        ns:DFPY_Build()
        ns:DFPY_Check()
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end

SlashCmdList["DFPY"] = function(message, editbox)
    if message == "v" or string.match(message, "vers") then
        PrettyPrint(string.format(L.Version, ns.version))
    elseif message == "h" or string.match(message, "he") then
        PrettyPrint(string.format(L.How, ns.color, ns.command) .. " " .. string.format(L.Support, ns.color, ns.discord))
    elseif message == "s" or string.match(message, "sou") then
        DFPY_sound = not DFPY_sound
        PrettyPrint(string.format(L.Sound, DFPY_sound and L.On or L.Off))
    end
end
SLASH_DFPY1 = "/" .. ns.command
