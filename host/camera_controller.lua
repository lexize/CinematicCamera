local keybinds = require("host.keybinds");
local translation = require("utils.translation");

---@enum CameraModes
local camera_modes = {
    STANDARD = 0,
    EDIT = 1,
    PLAY = 2
}

local currentCameraMode = camera_modes.STANDARD;
local currentCameraTransform = {
    position = vec(0,0,0),
    rotation = vec(0,0,0),
    fov = client.getFOV()
}

local kbMoveForward = keybinds.move_forward;
local kbMoveBackward = keybinds.move_backward;
local kbMoveLeft = keybinds.move_left;
local kbMoveRight = keybinds.move_right;
local kbSwitchCameraMode = keybinds.switch_camera_mode;

kbSwitchCameraMode.press = function (self)
    currentCameraMode = (currentCameraMode + 1) % 3;
    host:actionbar(string.format("Switched mode to %s", translation["camera_mode."..currentCameraMode]));
end