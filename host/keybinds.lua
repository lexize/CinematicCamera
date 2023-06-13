local defaultKeybinds = {
    {"move_forward", "key.keyboard.w"},
    {"move_backward", "key.keyboard.s"},
    {"move_left", "key.keyboard.a"},
    {"move_right", "key.keyboard.d"},
    {"move_up", "key.keyboard.space"},
    {"move_down", "key.keyboard.left.control"},


    {"modifier_multiply", "key.keyboard.left.shift"},
    {"modifier_divide", "key.keyboard.left.alt"},
    {"switch_camera_mode", "key.keyboard.f7"}
};

local defaultKeybindKeys = {};

for _, kb in ipairs(defaultKeybinds) do
    defaultKeybindKeys[kb[1]] = kb[2];
end

local savedKeybinds = config:load("keybinds") or {};

local translation = require("utils.translation");

---@type table<string, Keybind>
local loadedKeybinds = {};

for _, keybindDescriptor in ipairs(defaultKeybinds) do
    local keybind = keybindDescriptor[1];
    local key = savedKeybinds[keybind] or keybindDescriptor[2];
    local keybindObject = keybinds:newKeybind(translation["keybind."..keybind], key);
    loadedKeybinds[keybind] = keybindObject;
end

events.TICK:register(function ()
    local changed = false;
    for keybind, keybindObject in pairs(loadedKeybinds) do
        local k = keybindObject:getKey();
        if ((savedKeybinds[keybind] ~= nil and savedKeybinds[keybind] ~= k) or (defaultKeybindKeys[keybind] ~= k)) then
            savedKeybinds[keybind] = k;
            changed = true;
        end
    end
    if (changed) then
        config:save("keybinds", savedKeybinds);
    end
end);

return require("utils").createReadonlyTable(loadedKeybinds);