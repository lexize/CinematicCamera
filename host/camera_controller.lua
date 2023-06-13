local keybinds = require("host.keybinds");
local translation = require("utils.translation");

---@enum CameraModes
local camera_modes = {
    STANDARD = 0,
    EDIT = 1,
    PLAY = 2
}

local rotationAxis = vec(0,1,0);

local currentCameraMode = camera_modes.STANDARD;
local currentCameraPosition = vec(0,0,0);
local nextCameraPosition = vec(0,0,0);
local cameraRotation = vec(0,0,0);
local cameraFov = 1;

local kbMoveForward = keybinds.move_forward;
local kbMoveBackward = keybinds.move_backward;
local kbMoveLeft = keybinds.move_left;
local kbMoveRight = keybinds.move_right;
local kbMoveUp = keybinds.move_up;
local kbMoveDown = keybinds.move_down;
local kbSwitchCameraMode = keybinds.switch_camera_mode;

local function lockIfNotOnStandard()
    return currentCameraMode ~= camera_modes.STANDARD;
end

kbMoveForward.press = lockIfNotOnStandard;
kbMoveBackward.press = lockIfNotOnStandard;
kbMoveLeft.press = lockIfNotOnStandard;
kbMoveRight.press = lockIfNotOnStandard;
kbMoveUp.press = lockIfNotOnStandard;
kbMoveDown.press = lockIfNotOnStandard;

kbSwitchCameraMode.press = function (self)
    currentCameraMode = (currentCameraMode + 1) % 3;
    host:actionbar(string.format("Switched mode to %s", translation["camera_mode."..currentCameraMode]));
end

events.TICK:register(function ()
    if (currentCameraMode ~= camera_modes.EDIT) then return end
    currentCameraPosition = nextCameraPosition:copy();
    local yaw = cameraRotation.y;
    local moveVec = vec(0,0,0);
    if (kbMoveForward:isPressed()) then moveVec.z = moveVec.z + 1; end
    if (kbMoveBackward:isPressed()) then moveVec.z = moveVec.z - 1; end
    if (kbMoveLeft:isPressed()) then moveVec.x = moveVec.x + 1; end
    if (kbMoveRight:isPressed()) then moveVec.x = moveVec.x - 1; end
    if (kbMoveUp:isPressed()) then moveVec.y = moveVec.y + 1; end
    if (kbMoveDown:isPressed()) then moveVec.y = moveVec.y - 1; end
    nextCameraPosition:add(vectors.rotateAroundAxis(-yaw, moveVec, rotationAxis));
end)

events.RENDER:register(function (delta, ctx)
    if (currentCameraMode == camera_modes.STANDARD) then
        renderer:setCameraPivot(nil);
        renderer:setCameraRot(nil);
        renderer:setFOV(nil);
    elseif (currentCameraMode == camera_modes.EDIT) then
        local pos = math.lerp(currentCameraPosition, nextCameraPosition, delta);
        renderer:setCameraPivot(pos);
        renderer:setCameraRot(cameraRotation);
        renderer:setFOV(cameraFov);
    end
end)
events.MOUSE_MOVE:register(function (x, y)
    if (currentCameraMode == camera_modes.EDIT and host:getScreen() == nil) then
        cameraRotation.y = cameraRotation.y + x;
        cameraRotation.x = cameraRotation.x + y;
    end
    return currentCameraMode ~= camera_modes.STANDARD;
end)