ETC = ETC or {}
ETC.currentTurn = 0
ETC.name = "TurnCounter"

local function SafeSetEdge(backdrop)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 16)
    backdrop:SetCenterColor(0, 0, 0, 0.5) -- Fondo negro semitransparente
    backdrop:SetEdgeColor(1, 1, 1, 1)
end

-- Función auxiliar para establecer color según el turno
local function GetTurnColor(turn)
    if turn == 0 then
        return "707070" --
    elseif turn >= 25 then
        return "9900ff" --
    elseif turn >= 20 then
        return "FF0000" --
    elseif turn >= 15 then
        return "FF9900" --
    elseif turn >= 10 then
        return "FFFF00" --
    elseif turn >= 5 then
        return "fffacc" --Lemon chiffon
    elseif turn > 0 then
        return "FFFFFF" --
    else
        return "FFFFFF" 
    end
end

function ETC.UpdateTurnDisplay()
    local color = GetTurnColor(ETC.currentTurn)
    local text = string.format("|c%sTurn: %d|r", color, ETC.currentTurn)
    ETC_TURN_LABEL:SetText(text)
end

function ETC.OnTurnStart(_, isLocalPlayersTurn)
    if not isLocalPlayersTurn then return end
    ETC.currentTurn = ETC.currentTurn + 1
    ETC.UpdateTurnDisplay()
end

function ETC.OnGameFlowStateChange(_, flowState)
    if flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
        ETC.currentTurn = 0
        ETC.UpdateTurnDisplay()
        ETC_TURN_WINDOW:SetHidden(false)
    elseif flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
        ETC_TURN_WINDOW:SetHidden(true)
    end
end

function ETC.CreateUI()
    local wm = WINDOW_MANAGER
    if ETC_TURN_WINDOW then return end

    local ui = wm:CreateTopLevelWindow("ETC_TURN_WINDOW")
    ui:SetDimensions(200, 50)
    ui:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 350, 690)
    ui:SetMovable(true)
    ui:SetMouseEnabled(true)
    ui:SetHidden(true)

    local bg = wm:CreateControl("ETC_TURN_BG", ui, CT_BACKDROP)
    bg:SetAnchorFill(ui)
    SafeSetEdge(bg) -- negro semitransparente constante

    local label = wm:CreateControl("ETC_TURN_LABEL", ui, CT_LABEL)
    label:SetFont("ZoFontWinH1")
    label:SetAnchor(CENTER, ui, CENTER, 0, 0)
    label:SetText("|c707070Turn: 0|r") -- color gris inicial

    ETC_TURN_WINDOW = ui
    ETC_TURN_LABEL = label
end

function ETC.Initialize(_, addonName)
    if addonName ~= ETC.name then return end
    ETC.CreateUI()
    EVENT_MANAGER:RegisterForEvent("ETC_GameFlowState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, ETC.OnGameFlowStateChange)
    EVENT_MANAGER:RegisterForEvent("ETC_TurnStart", EVENT_TRIBUTE_PLAYER_TURN_STARTED, ETC.OnTurnStart)
    EVENT_MANAGER:RegisterForEvent("ETC_GameEnd", EVENT_TRIBUTE_GAME_END, function() ETC_TURN_WINDOW:SetHidden(true) end)
end

EVENT_MANAGER:RegisterForEvent("ETC_Initialize", EVENT_ADD_ON_LOADED, ETC.Initialize)
