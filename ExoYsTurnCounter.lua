 ETC = {} -- Main table to store addon functions and variables

-- Variable to track the current turn
ETC.currentTurn = 0

-- Function triggered when a player's turn starts
function ETC.OnTurnStart(_, isPlayer)
    if isPlayer then return end  -- ignoring opponent turn
    ETC.currentTurn = ETC.currentTurn + 1
    ETC.UpdateTurnDisplay()
    d("[ExoYsTurnCounter] Player Turn: " .. ETC.currentTurn)
end

-- Function triggered when the game starts (after selecting patrons)
function ETC.OnGameStart()
    ETC.currentTurn = 0 -- Reset turn count to 0 at the start of a match, fails sometimes for some reason
    ETC.UpdateTurnDisplay() -- Ensure the display is updated
    ETC_TURN_WINDOW:SetHidden(false) -- Show the turn counter UI
    --d("[ExoYsTurnCounter] Game started! Turn counter activated.") -- Debug message
end

-- Function triggered when the game ends
function ETC.OnGameEnd()
    ETC_TURN_WINDOW:SetHidden(true) -- Hide the turn counter UI
    --d("[ExoYsTurnCounter] Game ended! Turn counter deactivated.") -- Debug message
end

-- Updates the on-screen turn counter display
function ETC.UpdateTurnDisplay()
    local text = "Turn: " .. ETC.currentTurn -- Format the turn text
    ETC_TURN_LABEL:SetText(text) -- Update the label in the UI
end

-- Initializes the addon and registers required events
function ETC.Initialize(event, addonName)
    if addonName ~= "ExoYsTurnCounter" then return end -- Ensure this addon is being initialized

    --d("[ExoYsTurnCounter] Initializing addon...") -- Debug: addon starts initializing

    -- Create UI before registering events
    ETC.CreateUI()
    --d("[ExoYsTurnCounter] UI created!") -- Debug: Confirm UI is created

    -- Register event to detect game start
    --EVENT_MANAGER:RegisterForEvent("ETC_GameStart", EVENT_TRIBUTE_PLAYER_TURN_STARTED, ETC.OnGameStart) --deprecated?
    EVENT_MANAGER:RegisterForEvent("ETC_GameFlowState", EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, ETC.OnGameFlowStateChange)--ExoYs solution
    
    --d("[ExoYsTurnCounter] Registered Game Start Event") --Debug: Confirm event is registered

    -- Register event to detect turn changes
    --EVENT_MANAGER:RegisterForEvent("ETC_TurnStart", EVENT_TRIBUTE_PLAYER_TURN_BEGINS, ETC.OnTurnStart) -- confirmed deprecated
    EVENT_MANAGER:RegisterForEvent("ETC_TurnStart", EVENT_TRIBUTE_PLAYER_TURN_STARTED, ETC.OnTurnStart)

    -- d("[ExoYsTurnCounter] Registered Turn Start Event") -- Debug: Confirm event is registered

    -- Register event to detect game end
    EVENT_MANAGER:RegisterForEvent("ETC_GameEnd", EVENT_TRIBUTE_GAME_END, ETC.OnGameEnd)
    --d("[ExoYsTurnCounter] Registered Game End Event") --Debug: Confirm event is registered
end

function ETC.OnGameFlowStateChange(_, flowState)
    if flowState == TRIBUTE_GAME_FLOW_STATE_PLAYING then
        ETC.currentTurn = 0
        ETC.UpdateTurnDisplay()
        ETC_TURN_WINDOW:SetHidden(false)  -- This actually really does show the counter
        --d("[ExoYsTurnCounter] Game started, turn counter visible.")
    elseif flowState == TRIBUTE_GAME_FLOW_STATE_GAME_OVER then
        ETC_TURN_WINDOW:SetHidden(true)  -- Hide the counter after the game is finished
        --d("[ExoYsTurnCounter] Game over, hiding turn counter.")
    end
end


-- Creates the UI for displaying the turn counter
function ETC.CreateUI()
    local wm = WINDOW_MANAGER -- Get the ESO Window Manager

    -- This is important: Prevent duplicate creation: If the window already exists, do nothing
    if ETC_TURN_WINDOW then return end

    -- Create the main UI window
    local ui = wm:CreateTopLevelWindow("ETC_TURN_WINDOW")
    ui:SetDimensions(200, 50) -- Set the width and height
    ui:SetAnchor(CENTER, GuiRoot, CENTER, 0, -100) -- Position it slightly above the player
    ui:SetMovable(true) -- Allow the window to be moved obviously
    ui:SetMouseEnabled(true) -- Allow mouse interactions (clicks, drags) obviously
    ui:SetHidden(true) -- Start hidden until the game starts

    -- Create a background to make the window visible and draggable
    local bg = wm:CreateControl("ETC_TURN_BG", ui, CT_BACKDROP)
    bg:SetAnchorFill(ui) -- Make the background fill the entire window
    bg:SetCenterColor(0, 0, 0, 0.5) -- Semi-transparent black background
    bg:SetEdgeColor(1, 1, 1, 1) -- White border
    bg:SetEdgeTexture("", 1, 1, 1) -- Simple border texture, not working need to fix this

    -- Create a label inside the window to display the turn count
    local label = wm:CreateControl("ETC_TURN_LABEL", ui, CT_LABEL)
    label:SetFont("ZoFontWinH1") -- Use a large readable font
    label:SetAnchor(CENTER, ui, CENTER, 0, 0) -- Center the text inside the window
    label:SetText("Turn: 0") -- Default text

    -- Store UI elements for later use
    ETC_TURN_WINDOW = ui
    ETC_TURN_LABEL = label
end

-- Register the addon initialization event
--d("[ExoYsTurnCounter] Initializing addon...")
EVENT_MANAGER:RegisterForEvent("ETC_Initialize", EVENT_ADD_ON_LOADED, ETC.Initialize) --this always should be the last line