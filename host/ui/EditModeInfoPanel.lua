local uiHelper = require("utils.ui_helper")
local utils = require("utils");

local uiElement = require("host.ui.ui_element");

---@class EditModeInfoPanel: UIElement, InfoPanelGetter
local infoPanel = setmetatable({}, uiElement.metatable);

local metatable = utils.createIndexMetatable(infoPanel);

---@class InfoPanelGetter
---@field position Vector3
---@field next_position Vector3
---@field rotation Vector3
---@field fov number

---@param getterMetatble InfoPanelGetter
---@return EditModeInfoPanel
function infoPanel.init(getterMetatble)
    local tbl = setmetatable({}, utils.mergeIndexMetatable(getterMetatble, metatable));
    return tbl;
end

function infoPanel:render(delta, x, y)
    uiHelper.fill(vec(0,0,-1), vec(200,100), nil, vec(0.25,0.25,0.25,0.75));
    local pos = (self.position * 100):floor() / 100;
    local rot = (self.rotation * 100):floor() / 100;
    local fov = math.floor((self.fov*client.getFOV()) * 100) / 100;
    local text = string.format("Position: %s, %s, %s\nRotation: %s, %s, %s\nFOV: %s\nCamera speed: %s%%\nPosition correction: %s ticks", pos.x, pos.y, pos.z,
        rot.x,rot.y,rot.z,
        fov,
        math.round(self.camera_speed * 100),
        self.pos_correction_ticks);
    uiHelper.renderText(text, vec(10,10,0));
end

return utils.createReadonlyTable(infoPanel);