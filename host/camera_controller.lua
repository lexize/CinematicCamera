local keybinds = require("host.keybinds");
local configuration = require("host.configuration").values;
local utils = require("utils");
--local translation = require("utils.translation");

---@enum CameraModes
local camera_modes = {
    STANDARD = 0,
    EDIT = 1,
    PLAY = 2
}

local rotationAxis = vec(0,1,0);

local currentCameraMode = camera_modes.STANDARD;
local currentCameraPosition = vec(0,0,0);
local targetCameraPosition = vec(0,0,0);
local currentCameraRot = vec(0,0,0);
local nextCameraRot = vec(0,0,0);
local targetCameraRot = vec(0,0,0);
local currentCameraFov = 1;
local nextCameraFov = 1;
local targetCameraFov = 1;
local cameraSpeedModifier = 1;
local moveSmoothing = vec(0,0,0);
local positionCorrectionTicks = 5;
local rotationCorrectionTicks = 5;
local fovCorrectionTicks = 5;

local getters = {
    position = function ()
        return currentCameraPosition
    end,
    next_position = function ()
        return targetCameraPosition
    end,
    rotation = function ()
        return targetCameraRot
    end,
    fov = function ()
        return targetCameraFov
    end,
    camera_speed = function ()
        return cameraSpeedModifier
    end,
    pos_correction_ticks = function ()
        return positionCorrectionTicks
    end,
    rot_correction_ticks = function ()
        return rotationCorrectionTicks
    end,
    fov_correction_ticks = function ()
        return fovCorrectionTicks
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
local kbCameraReset = keybinds.camera_reset;
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
        targetCameraPosition = currentCameraPosition:copy();
        targetCameraRot = player:getRot().xy_;
        currentCameraRot = targetCameraRot:copy();
        nextCameraRot = targetCameraRot:copy();
    end
end

kbCameraReset.press = function ()
    if (lockIfNotOnStandard()) then
        local modifyFov = kbCameraFov:isPressed();
        local modifyRoll = kbCameraRoll:isPressed();
        if (not (modifyFov or modifyRoll)) then
            cameraSpeedModifier = 1;
        elseif (modifyFov and not modifyRoll) then
            targetCameraFov = 1;
        elseif (modifyRoll and not modifyFov) then
            targetCameraPosition.z = 0;
        else
            local mult = kbMultiply:isPressed();
            local div = kbDivide:isPressed();
            if (not (mult or div)) then
                positionCorrectionTicks = 5;
            elseif (mult) then
                rotationCorrectionTicks = 5;
            elseif (div) then
                fovCorrectionTicks = 5;
            end
        end
        return true;
    end
end

local syncTick = 0;
local posSyncTick = 5;

events.WORLD_TICK:register(function ()
    if (currentCameraMode == camera_modes.EDIT) then
        currentCameraPosition = targetCameraPosition:copy();
        currentCameraRot = nextCameraRot:copy();
        currentCameraFov = nextCameraFov;
        local yaw = currentCameraRot.y;
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
        local positionSmoothingAddition = vec(
            (math.sign(moveVec.x) - (moveSmoothing.x / speedModifier)) * speedModifier,
            (math.sign(moveVec.y) - (moveSmoothing.y / speedModifier)) * speedModifier,
            (math.sign(moveVec.z) - (moveSmoothing.z / speedModifier)) * speedModifier
        ) / positionCorrectionTicks;
        moveSmoothing = moveSmoothing + positionSmoothingAddition;
        moveVec = configuration.camera_move_speed * moveSmoothing;
        if (rotationCorrectionTicks ~= 0) then
            local rotDiff = targetCameraRot - currentCameraRot;
            nextCameraRot.x = utils.addTowards(nextCameraRot.x, targetCameraRot.x, rotDiff.x / rotationCorrectionTicks);
            nextCameraRot.y = utils.addTowards(nextCameraRot.y, targetCameraRot.y, rotDiff.y / rotationCorrectionTicks);
            nextCameraRot.z = utils.addTowards(nextCameraRot.z, targetCameraRot.z, rotDiff.z / rotationCorrectionTicks);
        end
        nextCameraFov = utils.addTowards(nextCameraFov, targetCameraFov, (targetCameraFov - currentCameraFov) / fovCorrectionTicks);
        targetCameraPosition:add(vectors.rotateAroundAxis(-yaw, moveVec, rotationAxis));
    end

    if (syncTick % posSyncTick == 0) then
        if (currentCameraMode == 0) then
            pings.cameraMove(); 
        else
            pings.cameraMove(currentCameraPosition, currentCameraRot); 
        end
    end
    syncTick = syncTick + 1;
end)

function pings.cameraMove(tPos, tRot)
    
end

events.WORLD_RENDER:register(function (delta, ctx)
    if (currentCameraMode == camera_modes.STANDARD) then
        renderer:setCameraPivot(nil);
        renderer:setCameraRot(nil);
        renderer:setFOV(nil);
        if (Screen == editInfoTable) then
            Screen = nil;
        end
    elseif (currentCameraMode == camera_modes.EDIT) then
        local pos = math.lerp(currentCameraPosition, targetCameraPosition, delta);
        renderer:setCameraPivot(pos);
        local rot = math.lerp(currentCameraRot, nextCameraRot, delta);
        if (renderer:isFirstPerson()) then
            CameraTransform = nil;
        else
            CameraTransform = {
                pos = pos:copy(),
                rot = rot:copy()
            };
        end
        
        if (renderer:isCameraBackwards()) then
            rot:add(0,180,0);
            rot:mul(-1,1,1);
        end
        renderer:setCameraRot(rot);
        local fov = math.lerp(currentCameraFov, nextCameraFov, delta);
        renderer:setFOV(fov);
        if (Screen ~= editInfoTable) then
            Screen = editInfoTable;
        end
    end
    local standardMode = currentCameraMode == camera_modes.STANDARD;
    vanilla_model.ALL:setVisible(standardMode);
    renderer.renderHUD = standardMode;
end)
events.MOUSE_MOVE:register(function (x, y)
    if (currentCameraMode == camera_modes.EDIT and host:getScreen() == nil) then
        targetCameraRot.y = targetCameraRot.y + ((x / 2.5) * configuration.camera_sensetivity * targetCameraFov);
        targetCameraRot.x = targetCameraRot.x + ((y / 2.5) * configuration.camera_sensetivity * targetCameraFov);
        if (rotationCorrectionTicks == 0) then
            currentCameraRot = targetCameraRot:copy();
            nextCameraRot = targetCameraRot:copy();
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
        local modifyFov = kbCameraFov:isPressed()
        local modifyRoll = kbCameraRoll:isPressed();
        if (not (modifyFov or modifyRoll)) then
            cameraSpeedModifier = math.clamp(cameraSpeedModifier + (dir/10) * mod, 0.1, 10);
        elseif (modifyFov and modifyRoll) then
            local mult = kbMultiply:isPressed();
            local div = kbDivide:isPressed();
            if (not (mult or div)) then
                positionCorrectionTicks = math.clamp(positionCorrectionTicks+dir, 1, 40);
            elseif (mult) then
                rotationCorrectionTicks = math.clamp(rotationCorrectionTicks+dir, 0, 40);
            elseif (div) then
                fovCorrectionTicks = math.clamp(fovCorrectionTicks+dir, 1, 40);
            end
        elseif (modifyFov) then
            local fov = client.getFOV();
            targetCameraFov = math.clamp(math.exp(math.log(targetCameraFov) + (-dir * (1 / fov)) * mod), 5/fov, 170/fov);
        elseif (modifyRoll) then
            targetCameraRot.z = targetCameraRot.z + (dir * mod * configuration.camera_fov_correct_speed);
            if (rotationCorrectionTicks == 0) then
                currentCameraRot.z = targetCameraRot.z;
                nextCameraRot.z = targetCameraRot.z;
            end
        end
    end
    return currentCameraMode ~= camera_modes.STANDARD;
end)