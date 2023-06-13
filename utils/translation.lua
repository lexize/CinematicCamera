local translation = {
    ["keybind.move_forward"] = "Move forward",
    ["keybind.move_backward"] = "Move backward",
    ["keybind.move_left"] = "Move left",
    ["keybind.move_right"] = "Move right",
    ["keybind.modifier_multiply"] = "Modifier: Multiply",
    ["keybind.modifier_divide"] = "Modifier: Divide",
    ["keybind.switch_camera_mode"] = "Switch camera mode",

    ["camera_mode.0"] = "Standard",
    ["camera_mode.1"] = "Edit",
    ["camera_mode.2"] = "Play"
};
local translationMetatable = {};
function translationMetatable:__index(k)
    return k;
end
function translationMetatable:__newindex(k, v)
    
end
return require("utils").createLibWrapper(setmetatable(translation, translationMetatable));