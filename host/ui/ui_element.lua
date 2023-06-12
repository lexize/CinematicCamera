---@diagnostic disable unused-local 

---@class UIElement
local ui_element = {};

local uiElementMetatable = {};
uiElementMetatable.__index = ui_element;
uiElementMetatable.__type = "UIElement"; 

function ui_element:init()
	setmetatable(self, uiElementMetatable);
end

---@param delta number
---@param x number
---@param y number
function ui_element:render(delta, x, y) end

function ui_element:tick() end

---@param x number
---@param y number
---@param button integer
---@return boolean clicked Is element clicked or not
function ui_element:mouseClicked(x, y, button, modifiers)
    return false;
end

---@param x number
---@param y number
---@param button integer
---@return boolean released Is element released or not
function ui_element:mouseReleased(x, y, button, modifiers)
    return false;
end

---@param x number
---@param y number
---@param delta_x number
---@param delta_y number
---@return boolean moved Is element moved or not
function ui_element:mouseMoved(x, y, delta_x, delta_y)
    return false;
end

---@param x number
---@param y number
---@param amount number
---@return boolean scrolled Is element scrolled or not
function ui_element:mouseScrolled(x, y, amount)
    return false;
end

---@return number x
function ui_element:getX()
    return 0;
end

---@param x number
function ui_element:setX(x) end

---@return number y
function ui_element:getY()
    return 0;
end

---@param y number
function ui_element:setY(y) end

---Returns position of element
---@return Vector2 pos
function ui_element:getPos()
    return vec(self:getX(), self:getY());
end

---@return number width
function ui_element:getWidth()
    return 0;
end

---@return number height
function ui_element:getHeight()
    return 0;
end

---Returns Vec2 with width in X and height in Y
---@return Vector2 size
function ui_element:getSize()
    return vec(self:getWidth(), self:getHeight());
end

return require("utils").createLibWrapper(uiElementMetatable);