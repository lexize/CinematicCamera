config:setName("CinematicCamera");
local loadedKeybinds = config:load("keybinds") or {
    move_forward = "key.keyboard.w",
    move_backward = "key.keyboard.s",
    move_left = "key.keyboard.a",
    move_right = "key.keyboard.d",

    modifier_multiply = "key.keyboard.left.shift",
    modifier_divide = "key.keyboard.left.alt"
};