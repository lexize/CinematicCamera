local commandManager = {};
commandManager.prefix = "cc$";
---@type table<string, fun(inputMessage: string, ...: string)>
commandManager.commands = {};

---@type table<string, fun(inputMessage: string, ...: string)>
commandManager.suggestions = {};

---Callback for suggestions. Can be replaced, or even be nil;
---@param suggestionsTable string[]
function commandManager.suggestionCallback(suggestionsTable)
    
end

local previousChatText = nil;

events.CHAT_SEND_MESSAGE:register(function (message)
    if (string.sub(message, 1, #commandManager.prefix) == commandManager.prefix) then
        local args = {};
        for val in string.gmatch(message, "%S+") do
            args[#args+1] = val;
        end
        local anyFound = false;
        if (#args > 0) then
            for commandName, commandFunc in pairs(commandManager.commands) do
                if (args[1] == commandManager.prefix .. commandName) then
                    if (#args > 1) then
                        commandFunc(message, table.unpack(args, 2, #args));
                    else
                        commandFunc(message);
                    end
                    anyFound = true;
                    break;
                end
            end
        end
        if (not anyFound) then
            local extras = {};
            extras[#extras+1] = '{"text": "Command ", "color": "red"}';
            extras[#extras+1] = string.format('{"text": "%s", "color": "green"}', string.sub(args[1], #commandManager.prefix+1));
            extras[#extras+1] = '{"text": " not found\n", "color": "red"}';
            printJson(string.format("[%s]", table.concat(extras, ", ")));
        end
        host:appendChatHistory(message);
        return nil;
    end
    
    return message;
end)

events.TICK:register(function ()
    
end)

return commandManager;