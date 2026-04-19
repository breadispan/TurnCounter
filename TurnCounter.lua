-- TurnCounter - ESO Tales of Tribute Addon
-- Version 2.5 - Release
-- Features: Turn Counter, Patron Alerts (Opponent & Player), Prestige Alerts

-- Init Log
d("TurnCounter: Loading... (v2.5 - Release)")

ETC = ETC or {}
ETC.name = "TurnCounter"
ETC.currentTurn = 0
ETC.lastOpponentFavorCount = 0
ETC.lastPlayerFavorCount = 0
ETC.lastOpponentPrestige = 0
ETC.pollingInterval = 500 -- ms
ETC.debugMode = false  -- Debug mode OFF by default
ETC.alertsEnabled = true  -- Alerts ON by default

-- Constants
local TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT = 1
local TRIBUTE_PLAYER_PERSPECTIVE_SELF = 0
local TRIBUTE_RESOURCE_PRESTIGE = 2

-- Debug logging function (can be toggled with /etcdebug)
local function DebugLog(msg)
    if ETC.debugMode then
        d(string.format("|cFF00FF[ETC-Debug]|r %s", msg))
    end
end

-- Get opponent's patron favor count
function ETC.GetOpponentFavorCount()
    if GetNumPatronsFavoringPlayerPerspective then
        return GetNumPatronsFavoringPlayerPerspective(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT)
    end
    return 0
end

-- Get player's patron favor count
function ETC.GetPlayerFavorCount()
    if GetNumPatronsFavoringPlayerPerspective then
        return GetNumPatronsFavoringPlayerPerspective(TRIBUTE_PLAYER_PERSPECTIVE_SELF)
    end
    return 0
end

-- Get opponent's prestige
function ETC.GetOpponentPrestige()
    if GetTributePlayerPerspectiveResource then
        return GetTributePlayerPerspectiveResource(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT, TRIBUTE_RESOURCE_PRESTIGE)
    end
    return 0
end

-- Main evaluation function (runs every 500ms during a match)
function ETC.EvaluatePatrons()
    -- Respect the global alert toggle
    if not ETC.alertsEnabled then return end

    -- 1. Check Opponent Patron Favor
    local oppCount = ETC.GetOpponentFavorCount()
    if oppCount ~= ETC.lastOpponentFavorCount then
        -- DebugLog("Opponent Favor Count Changed: " .. tostring(oppCount))
        
        local alertMsg = ""
        local color = ""
        local sound = SOUNDS.NONE
        
        if oppCount == 2 and oppCount > ETC.lastOpponentFavorCount then
            alertMsg = "WARNING:\n2 PATRONS AGAINST YOU!"
            color = "|cFF9900" -- Orange
            sound = SOUNDS.DUEL_START
            
        elseif oppCount >= 3 and oppCount > ETC.lastOpponentFavorCount then
            alertMsg = "CRITICAL DANGER:\n" .. oppCount .. " PATRONS AGAINST YOU!"
            color = "|cFF0000" -- Red
            sound = SOUNDS.JUSTICE_NOW_KOS
        end
        
        if alertMsg ~= "" then
            ETC.TriggerAlert(alertMsg, color, sound)
        end
        ETC.lastOpponentFavorCount = oppCount
    end

    -- 2. Check Player Patron Favor
    local playerCount = ETC.GetPlayerFavorCount()
    if playerCount ~= ETC.lastPlayerFavorCount then
        -- DebugLog("Player Favor Count Changed: " .. tostring(playerCount))
        
        local alertMsg = ""
        local color = ""
        local sound = SOUNDS.NONE
        
        if playerCount == 2 and playerCount > ETC.lastPlayerFavorCount then
            alertMsg = "2 PATRONS SUPPORTING YOU!"
            color = "|cFFFFFF" -- White
            sound = SOUNDS.DUEL_START
            
        elseif playerCount >= 3 and playerCount > ETC.lastPlayerFavorCount then
            alertMsg = "Hurry UP 3 PATRONS ON YOUR SIDE!"
            color = "|cFFFF00" -- Yellow
            sound = SOUNDS.JUSTICE_NOW_KOS
        end
        
        if alertMsg ~= "" then
            ETC.TriggerAlert(alertMsg, color, sound)
        end
        ETC.lastPlayerFavorCount = playerCount
    end

    -- 3. Check Opponent Prestige
    local prestige = ETC.GetOpponentPrestige()
    -- DebugLog("Prestige check: Current=" .. tostring(prestige) .. " Last=" .. tostring(ETC.lastOpponentPrestige))
    
    if prestige ~= ETC.lastOpponentPrestige then
        -- DebugLog("Opponent Prestige Changed: " .. tostring(prestige))
        
        local alertMsg = ""
        local color = ""
        local sound = SOUNDS.NONE
        
        -- Check thresholds from highest to lowest
        if prestige > 20 and ETC.lastOpponentPrestige <= 20 then
            alertMsg = "OPPONENT PRESTIGE:\n" .. prestige .. " POINTS!"
            color = "|cFF0000" -- Red
            sound = SOUNDS.JUSTICE_NOW_KOS
            -- DebugLog("RED ALERT: Prestige > 20")
            
        elseif prestige > 15 and ETC.lastOpponentPrestige <= 15 then
            alertMsg = "OPPONENT PRESTIGE:\n" .. prestige .. " POINTS!"
            color = "|cFF9900" -- Orange
            sound = SOUNDS.DUEL_START
            -- DebugLog("ORANGE ALERT: Prestige > 15")
            
        elseif prestige > 10 and ETC.lastOpponentPrestige <= 10 then
            alertMsg = "OPPONENT PRESTIGE:\n" .. prestige .. " POINTS!"
            color = "|cFFFF00" -- Yellow
            sound = SOUNDS.DUEL_START
            -- DebugLog("YELLOW ALERT: Prestige > 10")
        end
        
        if alertMsg ~= "" then
            -- DebugLog("Triggering prestige alert: " .. alertMsg)
            ETC.TriggerAlert(alertMsg, color, sound)
        else
            -- DebugLog("No prestige alert triggered")
        end
        ETC.lastOpponentPrestige = prestige
    end
end

-- Trigger a visual and audio alert
function ETC.TriggerAlert(message, color, sound)
    -- DebugLog("TriggerAlert called with: " .. message)
    
    -- Chat Log (private, only you see this)
    d(string.format("[%s] %s%s|r", ETC.name, color, message:gsub("\n", " ")))
    
    -- Custom HUGE on-screen alert
    if ETC_ALERT_LABEL then
        ETC_ALERT_LABEL:SetText(color .. message .. "|r")
        ETC_ALERT_WINDOW:SetHidden(false)
        ETC_ALERT_WINDOW:SetAlpha(1)
        
        PlaySound(sound)
        
        -- Auto-hide after 4 seconds
        EVENT_MANAGER:RegisterForUpdate("ETC_HideAlert", 4000, function()
            ETC_ALERT_WINDOW:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("ETC_HideAlert")
        end)
    else
        -- DebugLog("ERROR: ETC_ALERT_LABEL is nil!")
    end
end

-- Start polling for patron and prestige changes
function ETC.StartPolling()
    -- DebugLog("Starting Polling")
    EVENT_MANAGER:RegisterForUpdate("ETC_Polling", ETC.pollingInterval, ETC.EvaluatePatrons)
end

-- Stop polling
function ETC.StopPolling()
    -- DebugLog("Stopping Polling")
    EVENT_MANAGER:UnregisterForUpdate("ETC_Polling")
    if ETC_ALERT_WINDOW then ETC_ALERT_WINDOW:SetHidden(true) end
end

-- UI Helper Functions
local function SafeSetEdge(backdrop)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
    backdrop:SetCenterColor(0, 0, 0, 0.5) 
    backdrop:SetEdgeColor(1, 1, 1, 1)
end

local function GetTurnColor(turn)
    if turn == 0 then return "707070"
    elseif turn >= 30 then return "9900ff"
    elseif turn >= 25 then return "ff0099"
    elseif turn >= 20 then return "FF0000"
    elseif turn >= 15 then return "FF9900"
    elseif turn >= 10 then return "FFFF00"
    elseif turn >= 5 then return "fffacc"
    elseif turn > 0 then return "FFFFFF"
    else return "FFFFFF" end
end

function ETC.UpdateTurnDisplay()
    local color = GetTurnColor(ETC.currentTurn)
    local text = string.format("|c%sTurn: %d|r", color, ETC.currentTurn)
    if ETC_TURN_LABEL then ETC_TURN_LABEL:SetText(text) end
end

function ETC.OnTurnStart(_, isLocalPlayersTurn)
    if not isLocalPlayersTurn then return end
    ETC.currentTurn = ETC.currentTurn + 1
    ETC.UpdateTurnDisplay()
end

function ETC.OnGameFlowStateChange(_, flowState)
    -- DebugLog("GameFlowStateChange: " .. tostring(flowState))
    if flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
        ETC.currentTurn = 0
        ETC.lastOpponentFavorCount = 0
        ETC.lastPlayerFavorCount = 0
        ETC.lastOpponentPrestige = 0
        ETC.UpdateTurnDisplay()
        if ETC_TURN_WINDOW then ETC_TURN_WINDOW:SetHidden(false) end
        
        ETC.spamBlocker = false
        ETC.StartPolling()
        
    elseif flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
        if ETC_TURN_WINDOW then ETC_TURN_WINDOW:SetHidden(true) end
        ETC.StopPolling()
    end
end

-- Create the custom alert UI (huge, centered text)
function ETC.CreateAlertUI()
    local wm = WINDOW_MANAGER
    if ETC_ALERT_WINDOW then return end
    
    local ui = wm:CreateTopLevelWindow("ETC_ALERT_WINDOW")
    ui:SetDimensions(800, 200)
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, -100)
    ui:SetHidden(true)
    ui:SetMouseEnabled(false)
    
    local label = wm:CreateControl("ETC_ALERT_LABEL", ui, CT_LABEL)
    label:SetFont("ZoFontWinH1")
    label:SetScale(2.5) -- 2.5x scale for HUGE text
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetText("")
    
    ETC_ALERT_WINDOW = ui
    ETC_ALERT_LABEL = label
    
    -- DebugLog("Alert UI created successfully")
end

-- Create the turn counter UI
function ETC.CreateUI()
    local wm = WINDOW_MANAGER
    ETC.CreateAlertUI()
    
    if ETC_TURN_WINDOW then return end

    local ui = wm:CreateTopLevelWindow("ETC_TURN_WINDOW")
    ui:SetDimensions(200, 50)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 350, 690)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetHidden(true)

    local bg = wm:CreateControl("ETC_TURN_BG", ui, CT_BACKDROP)
    bg:SetAnchorFill(ui)
    SafeSetEdge(bg)

    local label = wm:CreateControl("ETC_TURN_LABEL", ui, CT_LABEL)
    label:SetFont("ZoFontWinH1")
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetText("|c707070Turn: 0|r")

    ETC_TURN_WINDOW = ui
    ETC_TURN_LABEL = label
end

-- Initialize the addon
function ETC.Initialize(_, addonName)
    if addonName ~= ETC.name then return end
    d("TurnCounter: Initializing...")
    
    ETC.CreateUI()
    
    EVENT_MANAGER:RegisterForEvent("ETC_GameFlowState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, ETC.OnGameFlowStateChange)
    EVENT_MANAGER:RegisterForEvent("ETC_TurnStart", EVENT_TRIBUTE_PLAYER_TURN_STARTED, ETC.OnTurnStart)
    EVENT_MANAGER:RegisterForEvent("ETC_GameEnd", EVENT_TRIBUTE_GAME_END, function() 
        if ETC_TURN_WINDOW then ETC_TURN_WINDOW:SetHidden(true) end
        ETC.StopPolling()
    end)
    
    -- Slash Commands
    
    -- /etcdebug - Toggle debug mode and show current stats
    SLASH_COMMANDS["/etcdebug"] = function()
        ETC.debugMode = not ETC.debugMode
        d("ETC: Debug Mode " .. (ETC.debugMode and "ON" or "OFF"))
        if ETC.debugMode then
            d("Opponent Favor: " .. tostring(ETC.GetOpponentFavorCount()))
            d("Player Favor: " .. tostring(ETC.GetPlayerFavorCount()))
            d("Opponent Prestige: " .. tostring(ETC.GetOpponentPrestige()))
            
            -- Probe Resources (for finding new resource IDs)
            if GetTributePlayerPerspectiveResource then
                d("--- Resource Probe (Opponent) ---")
                for i = 0, 25 do
                    local val = GetTributePlayerPerspectiveResource(TRIBUTE_PLAYER_PERSPECTIVE_OPPONENT, i)
                    if val and val > 0 then
                        d("Resource " .. i .. ": " .. tostring(val))
                    end
                end
            end
        end
    end
    
    -- /showalerts - Enable all alerts
    SLASH_COMMANDS["/showalerts"] = function()
        ETC.alertsEnabled = true
        d("|c00FF00TurnCounter: All Alerts ENABLED|r")
    end

    -- /hidealerts - Disable all alerts
    SLASH_COMMANDS["/hidealerts"] = function()
        ETC.alertsEnabled = false
        d("|cFF0000TurnCounter: All Alerts DISABLED|r")
    end
    
    d("TurnCounter: Ready (Alerts: " .. (ETC.alertsEnabled and "ON" or "OFF") .. ")")
end

EVENT_MANAGER:RegisterForEvent("ETC_Initialize", EVENT_ADD_ON_LOADED, ETC.Initialize)