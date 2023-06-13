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
    fov = 1
}
local nextCameraTransform = {
    position = vec(0,0,0),
    rotation = vec(0,0,0),
    fov = 1
}

local kbMoveForward = keybinds.move_forward;
local kbMoveBackward = keybinds.move_backward;
local kbMoveLeft = keybinds.move_left;
local kbMoveRight = keybinds.move_right;
local kbMoveUp = keybinds.move_up;
local kbMoveDown = keybinds.move_down;
local kbSwitchCameraMode = keybinds.switch_camera_mode;

kbSwitchCameraMode.press = function (self)
    currentCameraMode = (currentCameraMode + 1) % 3;
    host:actionbar(string.format("Switched mode to %s", translation["camera_mode."..currentCameraMode]));
end

events.TICK:register(function ()
    
end)

events.RENDER:register(function (delta, ctx)
    if (currentCameraMode == camera_modes.STANDARD) then
        renderer:setCameraPivot(nil);
        renderer:setCameraRot(nil);
        renderer:setFOV(nil);
    elseif (currentCameraMode == camera_modes.EDIT) then
        local pos = math.lerp(currentCameraTransform.position, nextCameraTransform.position, delta);
        renderer:setCameraPivot(pos);
        local rot = math.lerp(currentCameraTransform.rotation, nextCameraTransform.rotation, delta);
        renderer:setCameraRot(rot);
        renderer:setFOV(math.lerp(currentCameraTransform.fov, nextCameraTransform.fov, delta));
    end
end)