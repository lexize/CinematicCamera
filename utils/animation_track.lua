--[[
    This script was made by https://github.com/lexize
    for https://github.com/lexize/CinematicCamera
]]

local easings = require("utils.easings");

---@class Keyframe
---@field time number
---@field value any
---@field easing fun(x: number): number

---@class AnimationTrack
---@field private keyframes Keyframe[]
---@field private interpolationFunc fun(time: number, a: any, b: any): any
local animationTrack = {};

---@param delta number
---@param a any
---@param b any
---@return any
local function defaultInterpolationFunc(delta, a, b)
    return a + delta * (b-a);
end

---@param time number Keyframe time
---@param data any Keyframe data
---@param ease string|integer|nil|fun(x: number): number
---@return Keyframe Created keyframe
function animationTrack:addKeyframe(time, data, ease)
    if (time < 0) then error("Keyframe time cant be less than 0") end
    ---@type Keyframe
    local kf = {};
    kf.time = time;
    kf.value = data;
    local easeArgType = type(ease);
    if (easeArgType == "integer" or (easeArgType == "number" and ease % 1 == 0)) then
        kf.easing = easings[easings.easingsNames[ease]];
    elseif (easeArgType == "string") then
        kf.easing = easings[ease];
    elseif (easeArgType == "function") then
        kf.easing = ease;
    end
    if (kf.easing == nil) then kf.easing = easings.linear; end
    local insertIndex = #self.keyframes + 1;
    for index, keyframe in ipairs(self.keyframes) do
        if (keyframe.time == kf.time) then
            self.keyframes[index] = kf;
            return kf;
        elseif (keyframe.time > kf.time) then
            insertIndex = index;
            break;
        end
    end
    table.insert(self.keyframes, insertIndex, kf);
    return kf;
end

---@param keyframe Keyframe|number
---@return boolean deleted
function animationTrack:removeKeyframe(keyframe)
    local t = (type(keyframe) == "table" and keyframe.time or keyframe) or 0;
    for i, kf in pairs(self.keyframes) do
        if (kf.time == t) then
            table.remove(self.keyframes, i);
            return true;
        end
    end
    return false;
end

---@param o Keyframe|number Keyframe time/object
---@return Keyframe|nil keyframe Next keyframe if found, or nil
function animationTrack:getNextKeyframe(o)
    local t;
    if (type(o) == "number") then
        t = o;
    elseif (type(o) == "table") then
        t = o.time;
    end
    if (t == nil) then
        error("arg 1 must be number or Keyframe");
    end
    for _, kf in ipairs(self.keyframes) do
        if (kf.time > t) then
            return kf;
        end
    end
end

---@param o Keyframe|number Keyframe time/object
---@return Keyframe|nil keyframe Previous keyframe if found, or nil
function animationTrack:getPrevKeyframe(o)
    local t;
    if (type(o) == "number") then
        t = o;
    elseif (type(o) == "table") then
        t = o.time;
    end
    if (t == nil) then
        error("arg 1 must be number or Keyframe");
    end
    local prevKf;
    for _, kf in ipairs(self.keyframes) do
        if (kf.time < t) then
            prevKf = kf;
        elseif (kf.time > t) then
            return prevKf;
        end
    end
end

---@param time number
---@return Keyframe|nil
function animationTrack:getKeyframeAt(time)
    for _, kf in pairs(self.keyframes) do
        if (kf.time == time) then return kf end
    end
end

---@param time number Time on animation track
---@return any data Data of keyframes interpolation at specified time
function animationTrack:get(time)
    local f = (self.interpolationFunc or defaultInterpolationFunc);
    if (#self.keyframes == 0) then return nil end;
    if (time < 0) then
        local v = self.keyframes[1];
        return f(0, v.value, v.value);
    end
    ---@type Keyframe
    local prevKf;

    for _, kf in pairs(self.keyframes) do
        if (kf.time >= time) then
            if (prevKf ~= nil) then
                local diff = kf.time - prevKf.time;
                local t = (time - prevKf.time) / diff;
                return f(prevKf.easing(t), prevKf.value, kf.value)
            else
                return f(0, kf.value, kf.value);
            end
        end
        prevKf = kf;
    end

    return f(0, prevKf.value, prevKf.value);
end

return function ()
    ---@type AnimationTrack
    local tbl = {
        keyframes = {},
        interpolationFunc = defaultInterpolationFunc
    };
    local metatbl = {
        __index = animationTrack
    };
    return setmetatable(tbl, metatbl);
end