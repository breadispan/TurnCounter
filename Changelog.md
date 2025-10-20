# Changelog  10-19-25

## Fixed inverted turn logic
The `OnTurnStart` function previously returned when `isPlayer` was true, causing the counter to advance on opponent turns.  
Corrected to `if not isPlayer then return end`.

## Unified game start logic
Removed redundant overlap between `OnGameStart` and `OnGameFlowStateChange`.  
The reset now occurs only on `TRIBUTE_GAME_FLOW_STATE_PLAYING` to ensure consistent initialization.

## Adjusted turn increment behavior
Updated to increment the counter on the local player’s actual turn start.  
The first player turn now properly displays as **“Turn: 1”** instead of **“Turn: 0”**.

## Fixed missing border texture
`CT_BACKDROP` edge now uses a valid ESO UI texture (`UI-Border.dds`) with proper size parameters, restoring visible window borders.

## Optimized event registration
Added recommendation to register/unregister events dynamically depending on UI visibility, preventing unnecessary event calls during inactive states.

## Added state persistence and UI safety
Suggested saving and restoring window position via `SavedVariables` and ensuring the UI is created only once to avoid duplication after `/reloadui`.

## Improved text formatting
Added potential for alternative display formats and minor throttling for smoother updates during transition animations.

## New feature — dynamic color system
Implemented color-coded turn display.
