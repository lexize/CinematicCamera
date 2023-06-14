local uiHelper = require("utils.ui_helper");

Screen = nil;


---Tick event handler for Screen.
local function tickFunc()
    if (Screen ~= nil and Screen.UIElement ~= nil) then
        Screen:tick();
    end
end

---Render event handler for Screen.
local function renderFunc(delta)
    uiHelper.clear();
    if (Screen ~= nil and Screen.UIElement ~= nil) then
        local mousePos = client.getMousePos();
        Screen:render(delta, mousePos.x, mousePos.y);
        uiHelper.finishRender();
    end
end

---Mouse move event handler for Screen.
local function mouseMove(x,y)
    if (Screen ~= nil and Screen.UIElement ~= nil) then
        local mousePos = client.getMousePos();
        return Screen:mouseMoved(mousePos.x, mousePos.y, x, y);
    end
end

---Mouse press event handler for Screen.
local function mousePress(button, action, modifier)
    if (Screen ~= nil and Screen.UIElement ~= nil) then
        local mousePos = client.getMousePos();
        if (action == 0) then
            return Screen:mouseReleased(mousePos.x, mousePos.y,button, modifier)
        elseif action == 1 then
            return Screen:mouseClicked(mousePos.x, mousePos.y,button, modifier);
        end
    end
end

---Mouse press event handler for Screen.
local function mouseScroll(direction)
    if (Screen ~= nil and Screen.UIElement ~= nil) then
        local mousePos = client.getMousePos();
        return Screen:mouseScrolled(mousePos.x, mousePos.y, direction);
    end
end

events.TICK:register(tickFunc);
events.RENDER:register(renderFunc);
events.MOUSE_MOVE:register(mouseMove);
events.MOUSE_PRESS:register(mousePress);
events.MOUSE_SCROLL:register(mouseScroll);