local keybinds = require("host.keybinds");
local configuration = require("host.configuration").values;
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
local cameraSpeedModifier = 1;
local moveSmothing = vec(0,0,0);
local maxMoveTicks = 5;

local getters = {
    position = function ()
        return currentCameraPosition
    end,
    next_position = function ()
        return nextCameraPosition
    end,
    rotation = function ()
        return cameraRotation
    end,
    fov = function ()
        return cameraFov
    end,
    camera_speed = function ()
        return cameraSpeedModifier
    end
}

local getterMetatable = {};
function getterMetatable:__index(k)
    if (getters[k] ~= nil) then
        return getters[k]();
    end
end

local editInfoTable = require("host.ui.EditModeInfoPanel").init(getterMetatable);

local kbMoveForward = keybinds.move_forward;
local kbMoveBackward = keybinds.move_backward;
local kbMoveLeft = keybinds.move_left;
local kbMoveRight = keybinds.move_right;
local kbMoveUp = keybinds.move_up;
local kbMoveDown = keybinds.move_down;
local kbSwitchCameraMode = keybinds.switch_camera_mode;
local kbCameraFov = keybinds.camera_fov;
local kbCameraRoll = keybinds.camera_roll;
local kbResetCameraFov = keybinds.reset_camera_fov;
local kbResetCameraRoll = keybinds.reset_camera_roll;
local kbMultiply = keybinds.modifier_multiply;
local kbDivide = keybinds.modifier_divide;


local function lockIfNotOnStandard()
    return currentCameraMode ~= camera_modes.STANDARD;
end

kbMoveForward.press = lockIfNotOnStandard;
kbMoveBackward.press = lockIfNotOnStandard;
kbMoveLeft.press = lockIfNotOnStandard;
kbMoveRight.press = lockIfNotOnStandard;
kbMoveUp.press = lockIfNotOnStandard;
kbMoveDown.press = lockIfNotOnStandard;
kbCameraFov.press = lockIfNotOnStandard;
kbCameraRoll.press = lockIfNotOnStandard;


kbSwitchCameraMode.press = function (self)
    currentCameraMode = (currentCameraMode + 1) % 3;
    if (currentCameraMode == camera_modes.EDIT) then
        currentCameraPosition = player:getPos() + vec(0,player:getEyeHeight(), 0);
        nextCameraPosition = currentCameraPosition:copy();
        cameraRotation = player:getRot().xy_;
    end
end

kbResetCameraFov.press = function ()
    if (lockIfNotOnStandard()) then
        cameraFov = 1;
        return true;
    end
end
kbResetCameraRoll.press = function ()
    if (lockIfNotOnStandard()) then
        cameraRotation.z = 0;
        return true;
    end
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
    moveVec.x_z = moveVec.x_z:normalized();
    if (kbMoveUp:isPressed()) then moveVec.y = moveVec.y + 1; end
    if (kbMoveDown:isPressed()) then moveVec.y = moveVec.y - 1; end
    local speedModifier = cameraSpeedModifier;
    if (kbMultiply:isPressed()) then
        speedModifier = speedModifier * configuration.camera_move_multiply_speed;
    end
    if (kbDivide:isPressed()) then
        speedModifier = speedModifier / configuration.camera_move_divide_speed;
    end
    local smoothingAddition = vec(
        (math.sign(moveVec.x) - (moveSmothing.x / speedModifier)) * speedModifier,
        (math.sign(moveVec.y) - (moveSmothing.y / speedModifier)) * speedModifier,
        (math.sign(moveVec.z) - (moveSmothing.z / speedModifier)) * speedModifier
    ) / maxMoveTicks;
    moveSmothing = moveSmothing + smoothingAddition;
    moveVec = configuration.camera_move_speed * moveSmothing;
    nextCameraPosition:add(vectors.rotateAroundAxis(-yaw, moveVec, rotationAxis));
end)

events.RENDER:register(function (delta, ctx)
    if (currentCameraMode == camera_modes.STANDARD) then
        renderer:setCameraPivot(nil);
        renderer:setCameraRot(nil);
        renderer:setFOV(nil);
        if (Screen == editInfoTable) then
            Screen = nil;
        end
    elseif (currentCameraMode == camera_modes.EDIT) then
        local pos = math.lerp(currentCameraPosition, nextCameraPosition, delta);
        renderer:setCameraPivot(pos);
        renderer:setCameraRot(cameraRotation);
        renderer:setFOV(cameraFov);
        if (Screen ~= editInfoTable) then
            Screen = editInfoTable;
        end
    end
    local standardMode = currentCameraMode == camera_modes.STANDARD;
    vanilla_model.ALL:setVisible(standardMode);
    --renderer.renderHUD = standardMode;
end)
events.MOUSE_MOVE:register(function (x, y)
    if (currentCameraMode == camera_modes.EDIT and host:getScreen() == nil) then
        if (kbCameraFov:isPressed()) then
            local fov = client.getFOV();
            cameraFov = math.clamp(cameraFov + ((x + y) * (1 / fov)), 0.1, 170/fov);
        elseif (kbCameraRoll:isPressed()) then
            cameraRotation.z = cameraRotation.z + ((x / 2.5) * configuration.camera_sensetivity);
        else
            cameraRotation.y = cameraRotation.y + ((x / 2.5) * configuration.camera_sensetivity);
            cameraRotation.x = cameraRotation.x + ((y / 2.5) * configuration.camera_sensetivity);
        end
        
    end
    return currentCameraMode ~= camera_modes.STANDARD;
end)

events.MOUSE_SCROLL:register(function (dir)
    if (currentCameraMode == camera_modes.EDIT and host:getScreen() == nil) then
        local mod = 1;
        if (kbMultiply:isPressed()) then
            mod = mod * configuration.camera_move_multiply_speed;
        end
        if (kbDivide:isPressed()) then
            mod = mod / configuration.camera_move_divide_speed;
        end
        cameraSpeedModifier = math.clamp(cameraSpeedModifier + (dir/10) * mod, 0.1, 10);
    end
    return currentCameraMode ~= camera_modes.STANDARD;
end)