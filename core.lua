local ADDON_NAME, ns = ...

local L = {}
setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })
L.Version = "%s is the current version." -- ns.version
L.Install = "Thanks for installing |cff%1$sv%2$s|r!" -- ns.color, ns.version
L.Update = "Thanks for updating to |cff%1$sv%2$s|r!" -- ns.color, ns.version
L.How = "Type |cff%1$s/%2$s sound|r to toggle sounds." -- ns.color, ns.command
L.Support = "For feedback and support: |cff%1$s%2$s|r" -- ns.color ns.discord

local duration = 3.0
local size = 128
local textureID = 449490
local soundID = 16552
local color = {1, 0.5, 0.5, 0.9}
local firestormAuras = {333097, 333100}
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
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. "|r " .. message)
end

local function DFPY_Build()
    ns.Display = CreateFrame("Frame", ADDON_NAME .. "Display", UIParent)
    ns.Display:SetFrameStrata("LOW")
    ns.Display:SetWidth(size * 4)
    ns.Display:SetHeight(size * 2)
    ns.Display:SetPoint("CENTER", 0, 0)

    local l = ns.Display:CreateTexture()
    l:SetWidth(size)
    l:SetHeight(size * 2)
    l:SetPoint("LEFT", 0, 0)
    l:SetTexture(textureID)
    l:SetVertexColor(color[1], color[2], color[3], color[4])

    local r = ns.Display:CreateTexture()
    r:SetWidth(size)
    r:SetHeight(size * 2)
    r:SetPoint("RIGHT", 0, 0)
    r:SetTexture(textureID)
    r:SetVertexColor(color[1], color[2], color[3], color[4])
    r:SetTexCoord(1, 0, 0, 1)

    ns.Display:Hide()
end

local function DFPY_Check()
    if not ns.Display then
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
        ns.Display:Show()
        C_Timer.After(duration - 0.2, function()
            UIFrameFadeOut(ns.Display, 0.2, 1, 0)
        end)
    elseif hadFirestorm and not hasFirestorm then
        ns.Display:Hide()
    end

    hadFirestorm = hasFirestorm
end

function DFPY_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_SPELLCAST_START")
end

function DFPY_OnEvent(self, event, arg, ...)
    if (event == "UNIT_AURA" or event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_END") and arg == "player" then
        DFPY_Check()
    elseif event == "PLAYER_LOGIN" then
        local _, class = UnitClass("player")
        if class == "MAGE" then
            if DFPY_sound == nil then DFPY_sound = true end
            if not DFPY_version then
                PrettyPrint("\n" .. string.format(L.Install, ns.color, ns.version) .. "\n" .. string.format(L.How, ns.color, ns.command) .. " " .. string.format(L.Sound, DFPY_sound and L.On or L.Off))
            elseif DFPY_version ~= ns.version then
                PrettyPrint("\n" .. string.format(L.Update, ns.color, ns.version, ns.command) .. "\n" .. string.format(L.How, ns.color, ns.command) .. " " .. string.format(L.Sound, DFPY_sound and L.On or L.Off))
            end
            DFPY_version = ns.version
            DFPY_Build()
            DFPY_Check()
        else
            self:UnregisterEvent("UNIT_AURA")
            self:UnregisterEvent("UNIT_SPELLCAST_START")
        end
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end

SlashCmdList["DFPY"] = function(message, editbox)
    if string.match(message, "v") then
        PrettyPrint(string.format(L.Version, ns.version))
    elseif string.match(message, "s") then
        DFPY_sound = not DFPY_sound
        PrettyPrint(DFPY_sound and _G.SOUND_EFFECTS_ENABLED or _G.SOUND_EFFECTS_DISABLED)
    else
        PrettyPrint("\n" .. string.format(L.How, ns.color, ns.command) .. "\n" .. string.format(L.Support, ns.color, ns.discord))
    end
end
SLASH_DFPY1 = "/" .. ns.command
