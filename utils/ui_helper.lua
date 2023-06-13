--[[
    This script was made by https://github.com/lexize
    for https://github.com/lexize/CinematicCamera
]]
local hud_handle = models:newPart("HUD_DRAWER", "Hud") --[[@as ModelPart]];
local solidTexture = textures:newTexture("solid_texture", 1, 1);
solidTexture:setPixel(0,0,1,1,1,1);
solidTexture:update();

---@type RenderTask[]
local spriteTasksBuffer = {};

---@type TextTask[]
local textTasksBuffer = {};

---@class UIHelper
local ui_helper = {};

---@class TextRenderTask
---@field text string
---@field position Vector3
---@field scale Vector2?
---@field rotation number?
---@field shadow boolean?
---@field backgroundColor Vector3|Vector4?
---@field outlineColor Vector3?
---@field alignment string?
---@field maxWidth integer?

---@class SpriteRenderTask
---@field texture Texture
---@field position Vector3
---@field scale Vector2?
---@field rotation number?
---@field uv Vector2?
---@field region Vector2?
---@field dimensions Vector2?
---@field color Vector4?

---@type TextRenderTask[]
local textRenderQueue = {};

---@type SpriteRenderTask[]
local spriteRenderQueue = {};

function ui_helper.clear()
    for _, st in pairs(spriteTasksBuffer) do
        st:setVisible(false);
    end
    for _, tt in pairs(textTasksBuffer) do
        tt:setVisible(false);
    end
    for i = #textRenderQueue, 1, -1 do
        textRenderQueue[i] = nil;
    end
    for i = #spriteRenderQueue, 1, -1 do
        spriteRenderQueue[i] = nil;
    end
end

---Render text with specified parameters
---@param text string
---@param position Vector3
---@param scale Vector2?
---@param rotation number?
---@param shadow boolean?
---@param backgroundColor Vector3|Vector4?
---@param outlineColor Vector3?
---@param alignment string?
---@param maxWidth integer?
function ui_helper.renderText(text, position, scale, rotation, shadow, alignment, maxWidth, backgroundColor, outlineColor)
    textRenderQueue[#textRenderQueue+1] = {
        text = text,
        position = position,
        scale = scale or vec(1,1),
        rotation = rotation or 0,
        shadow = shadow ~= nil and shadow == true,
        alignment = alignment or "LEFT",
        maxWidth = maxWidth,
        backgroundColor = backgroundColor,
        outlineColor = outlineColor
    };
end

---Render sprite with specified parameters
---@param texture Texture
---@param position Vector3
---@param scale Vector2?
---@param rotation number?
---@param uv Vector2?
---@param region Vector2?
---@param dimensions Vector2?
---@param color Vector4?
function ui_helper.renderSprite(texture, position, scale, rotation, uv, region, dimensions, color)
    spriteRenderQueue[#spriteRenderQueue+1] = {
        texture = texture,
        position = position,
        scale = scale or vec(1,1),
        rotation = rotation or 0,
        uv = uv or vec(0,0),
        region = region,
        dimensions = dimensions,
        color = color or vec(1,1,1,1)
    };
end

---@param position Vector3
---@param scale Vector2?
---@param rotation number?
---@param color Vector4?
function ui_helper.fill(position, scale, rotation, color)
    ui_helper.renderSprite(solidTexture, position, scale, rotation, nil, vec(1,1), vec(1,1), color or vec(1,1,1,1));
end

function ui_helper.finishRender()
    if (#spriteTasksBuffer < #spriteRenderQueue) then
        for i = #spriteTasksBuffer+1, #spriteRenderQueue, 1 do
            spriteTasksBuffer[i] = hud_handle:newSprite("HUD_SPRITE_"..i);
        end
    end
    if (#textTasksBuffer < #textRenderQueue) then
        for i = #textTasksBuffer+1, #textRenderQueue, 1 do
            textTasksBuffer[i] = hud_handle:newText("HUD_TEXT_"..i);
        end
    end

    for i = 1, #spriteRenderQueue, 1 do
        local task = spriteTasksBuffer[i];
        local parameters = spriteRenderQueue[i];
        task:setVisible(true);
        task:setTexture(parameters.texture);
        task:setUVPixels(parameters.uv);
        task:setRegion(parameters.region);
        task:pos(-parameters.position);
        task:rot(0,0,parameters.rotation);
        task:scale(parameters.scale.x, parameters.scale.y, 1);
        task:setColor(parameters.color);
    end

    for i = 1, #textRenderQueue, 1 do
        local task = textTasksBuffer[i];
        local parameters = textRenderQueue[i];
        task:setVisible(true);
        task:setText(parameters.text);
        task:setAlignment(parameters.alignment);
        if (parameters.maxWidth ~= nil) then
            task:width(parameters.maxWidth);
            task:wrap(true);
        else
            task:wrap(false);
        end
        task:shadow(parameters.shadow);
        if (parameters.backgroundColor ~= nil) then
            task:setBackground(true);
            local c = parameters.backgroundColor;
            task:setBackgroundColor(c.r,c.g,c.b,c.a);
        else
            task:setBackground(false);
        end
        if (parameters.outlineColor ~= nil) then
            task:setOutline(true);
            task:setOutlineColor(parameters.outlineColor);
        else
            task:setOutline(false);
        end
        task:pos(-parameters.position);
        task:rot(0,0,parameters.rotation);
        task:scale(parameters.scale.x, parameters.scale.y, 1);
    end
end

return require("utils").createReadonlyTable(ui_helper);