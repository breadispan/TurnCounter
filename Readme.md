# ExoYsTurnCounter

## Description
`ExoYsTurnCounter` is an addon for **The Elder Scrolls Online (ESO)** designed to track and display the turn count in **Tales of Tribute** games. The addon shows a floating window that counts only the player's turns, and it changes the color of the text depending on the turn number. The window appears when the game starts and hides when the game ends.

## Features
- Displays a turn counter window in the middle of the screen.
- Counts only the player's turns, not the opponent's.
- Changes the color of the turn counter based on the current turn:
  - **White** for turns <= 10.
  - **Yellow** for turns >= 10 and < 20.
  - **Red** for turns >= 20.
- Automatically shows the counter when the game starts and hides it when the game ends.
- Can be used for both casual and competitive matches.

## Installation

1. Download the addon files.
2. Extract the files into the following directory in your ESO installation:
Documents\Elder Scrolls Online\live\AddOns\ExoYsTurnCounter
3. Enable the addon in the ESO settings under **AddOns**.

## Usage

Once the addon is installed and enabled:
- The turn counter will appear at the start of each game.
- The counter will display only your turns (not the opponent's).
- The color of the text will change based on the current turn:
- **White** for turns <= 10.
- **Yellow** for turns >= 10 and < 20.
- **Red** for turns >= 20.
- The counter will hide automatically when the game ends.

## Configuration

Currently, `ExoYsTurnCounter` does not have customizable settings in the menu, but you can modify the colors and turn thresholds directly in the code if needed.

## Developer Notes

### Events Used:
- **EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE**: Used to detect the start and end of the game and display the counter.
- **EVENT_TRIBUTE_PLAYER_TURN_BEGINS**: Used to detect when it's the player's turn and increase the turn counter.
- **EVENT_TRIBUTE_GAME_END**: Used to hide the counter at the end of the game.

### Key Functions:
- `ETC.CreateUI()`: Creates the UI window that displays the turn count.
- `ETC.OnTurnStart()`: Increases the turn counter and updates the display.
- `ETC.OnGameFlowStateChange()`: Manages the display of the counter based on the game flow state.

## Changelog

### v1.0
- Initial release of `ExoYsTurnCounter` addon.
- Displays the turn count and changes colors based on the current turn.

## License
This addon is released under the [MIT License](https://opensource.org/licenses/MIT).

## Contact
For any issues or suggestions, please contact **@breadispan** on the ESO forums or via Discord.

