local utils = require("utils");
local prevPos, currentPos = vec(0,0,0), targetPos;
local prevRot, currentRot = vec(0,0,0), targetRot;

function pings.cameraMove(tPos, tRot)
    targetPos = tPos;
    targetRot = tRot;
end

events.WORLD_TICK:register(function ()
    if (targetPos == nil) then return end
    if (currentPos == nil) then
        currentPos = targetPos:copy();
        currentRot = targetRot:copy();
    end
    prevPos = currentPos:copy();
    prevRot = currentRot:copy();
    local posDiff = targetPos - currentPos;
    local rotDiff = targetRot - currentRot;
    currentPos = vec(
        utils.addTowards(currentPos.x, targetPos.x, posDiff.x/5),
        utils.addTowards(currentPos.y, targetPos.y, posDiff.y/5),
        utils.addTowards(currentPos.z, targetPos.z, posDiff.z/5)
    );
    currentRot = vec(
        utils.addTowards(currentRot.x, targetRot.x, rotDiff.x/5),
        utils.addTowards(currentRot.y, targetRot.y, rotDiff.y/5),
        utils.addTowards(currentRot.z, targetRot.z, rotDiff.z/5)
    );
end)

events.WORLD_RENDER:register(function (delta, ctx)
    if (prevPos == nil) then return end
    if (currentPos ~= nil) then
        CameraTransform = {
            pos = math.lerp(prevPos, currentPos, delta),
            rot = math.lerp(prevRot, currentRot, delta)
        };
    else
        CameraTransform = nil;
    end
end)