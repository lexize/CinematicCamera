local utils = require("utils");
local commandManager = require("host.commandManager");

---@enum OptionType
local optionTypes = {
    NUMBER = 0,
    SLIDER = 1,
    STRING = 2
}

local function getOptionTypeName(id)
    for key, value in pairs(optionTypes) do
        if (value == id) then return key end;
    end
end

---@class ConfigOption
---@field optionType OptionType Describes an option type
---@field defaultValue any Default value of option
---@field minValue number? Min value of option if its type is number/slider
---@field maxValue number? Max value of option if its type is number/slider
---@field precision number? Precision of slider
---@field placeholder string? Placeholder string for an option

---@type table<string, ConfigOption>
local configOptionDescriptors = {
    camera_move_speed = {
        optionType = optionTypes.NUMBER,
        defaultValue = 1/4
    },
    camera_fov_addition = {
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

for key, value in pairs(configOptionDescriptors) do
    configValues[key] = savedConfig[key] or value.defaultValue;
end

local configuration = {
    values = configValues,
    descriptors = utils.createRecurviseReadonlyTable(configOptionDescriptors),
    optionTypes = utils.createReadonlyTable(optionTypes)
};

local function saveConfig()
    local valuesToSave = {};
    for key, value in pairs(configValues) do
        local desc = configOptionDescriptors[key];
        if (desc ~= nil and value ~= desc.defaultValue) then
            valuesToSave[key] = value;
        end
    end
    config:save("configuration", valuesToSave);
end

local function buildConfigOptionsListString()
    ---@type {key: string, descriptor: ConfigOption}[]
    local configOptions = {};
    for key, value in pairs(configOptionDescriptors) do
        configOptions[#configOptions+1] = {key = key, descriptor = value};
    end
    local jsonStringComponents = {};
    for i = 1, #configOptions, 1 do
        local option = configOptions[i];
        local extras = {};
        extras[1] = '"Name: "';
        extras[2] = string.format('{"text": "%s", "color": "green"}', option.key);
        local typeName = getOptionTypeName(option.descriptor.optionType);
        extras[3] = '"\n\tType: "';
        extras[4] = string.format('{"text": "%s", "color": "green"}', typeName);
        extras[5] = '"\n\tCurrent value: "';
        extras[6] = string.format('{"text": "%s", "color": "green"}', configValues[option.key]);
        extras[7] = '"\n\tDefault value: "';
        extras[8] = string.format('{"text": "%s", "color": "green"}', option.descriptor.defaultValue);
        if (option.descriptor.minValue ~= nil) then
            extras[#extras+1] = '"\n\tMin value: "';
            extras[#extras+1] = string.format('{"text": "%s", "color": "green"}', option.descriptor.minValue);
        end
        if (option.descriptor.maxValue ~= nil) then
            extras[#extras+1] = '"\n\tMax value: "';
            extras[#extras+1] = string.format('{"text": "%s", "color": "green"}', option.descriptor.maxValue);
        end
        if (i < #configOptions) then
            extras[#extras+1] = '"\n"';
        end
        for _, value in ipairs(extras) do
            jsonStringComponents[#jsonStringComponents+1] = value;
        end
    end
    return string.format("[%s]", table.concat(jsonStringComponents, ","));
end



local function setConfigOption(option, ...)
    local descriptor = configOptionDescriptors[option];
    if (descriptor == nil) then
        printJson(
            string.format('{"text": "Option with name ", "color": "red", "extra": [{"text": "%s", "color": "green"}, " doesn\'t exists"]}', option)
        );
        return;
    end
    if (descriptor.optionType == optionTypes.STRING) then
        configValues[option] = table.concat({...}, " ");
        printJson(
            string.format('{"text": "Option ", "color": "green", "extra": [{"text": "%s", "color": "gold"}, " successfully set to \\"%s\\""]}', option, configValues[option])
        );

    elseif (descriptor.optionType == optionTypes.NUMBER or descriptor.optionType == optionTypes.SLIDER) then
        local num = tonumber(table.concat({..., " "}));
        if (num == nil) then
            printJson(
                '{"text": "Value must be number", "color": "red"}'    
            );
            return;
        end
        if (descriptor.minValue ~= nil and num < descriptor.minValue) then
            printJson(
                string.format('{"text": "Value must be more than or equal to", "color": "red", "extra": [{"text": "%s", "color": "green"}]}', descriptor.minValue)    
            );
            return;
        end
        if (descriptor.maxValue ~= nil and num > descriptor.maxValue) then
            printJson(
                string.format('{"text": "Value must be less than or equal to", "color": "red", "extra": [{"text": "%s", "color": "green"}]}', descriptor.minValue)    
            );
            return;
        end
        configValues[option] = num;
        printJson(
            string.format('{"text": "Option ", "color": "green", "extra": [{"text": "%s", "color": "gold"}, " successfully set to %s"]}', option, num)
        );
    end
    saveConfig();
end

function commandManager.commands.config(_, action, configOption, ...)
    if (action == "list") then
        local s = buildConfigOptionsListString();
        printJson(s);
    elseif (action == "set") then
        setConfigOption(configOption, ...);
    elseif (action == "reset") then
        local desc = configOptionDescriptors[configOption];
        if (desc ~= nil) then
            configValues[configOption] = desc.defaultValue;
            saveConfig();
            printJson(
                string.format('{"text": "Option ", "color": "green", "extra": [{"text": "%s", "color": "gold"}, " was set to %s"]}', configOption, desc.defaultValue)
            );
            return;
        end
        printJson(
            string.format('{"text": "Option with name ", "color": "red", "extra": [{"text": "%s", "color": "green"}, " doesn\'t exists"]}', configOption)
        );
    elseif (action == "get") then
        local desc = configOptionDescriptors[configOption];
        if (desc ~= nil) then
            printJson(
                string.format('{"text": "Value of option ", "color": "green", "extra": [{"text": "%s", "color": "gold"}, " is %s"]}', configOption, configValues[configOption])
            );
            return;
        end
        printJson(
            string.format('{"text": "Option with name ", "color": "red", "extra": [{"text": "%s", "color": "green"}, " doesn\'t exists"]}', configOption)
        );
    end
end

return utils.createReadonlyTable(configuration);