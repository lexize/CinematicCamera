local utils = require("utils");

---@enum OptionType
local optionTypes = {
    NUMBER = 0,
    SLIDER = 1,
    STRING = 2
}

---@class ConfigOption
---@field optionType OptionType Describes an option type
---@field defaultValue any Default value of option
---@field minValue number? Min value of option if its type is number/slider
---@field maxValue number? Max value of option if its type is number/slider
---@field precision number? Precision of slider
---@field placeholder string? Placeholder string for an option

---@type table<string, ConfigOption>
local configurationDescription = {
    camera_move_speed = {
        optionType = optionTypes.NUMBER,
        defaultValue = 1/4
    },
    camera_fov_correct_speed = {
        optionType = optionTypes.NUMBER,
        defaultValue = 90/8
    },
    camera_move_multiply_speed = {
        optionType = optionTypes.NUMBER,
        defaultValue = 2
    },
    camera_move_divide_speed = {
        optionType = optionTypes.NUMBER,
        defaultValue = 2
    },
    camera_sensetivity = {
        optionType = optionTypes.SLIDER,
        defaultValue = 1,
        minValue = 0.1,
        maxValue = 2
    }
};

local savedConfig = config:load("configuration") or {};

local configValues = {};

for key, value in pairs(configurationDescription) do
    configValues[key] = savedConfig[key] or value.defaultValue;
end

local configuration = {
    values = configValues,
    descriptors = utils.createRecurviseReadonlyTable(configurationDescription),
    optionTypes = utils.createReadonlyTable(optionTypes)
};

return utils.createReadonlyTable(configuration);