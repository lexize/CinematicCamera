local utils = {};

---@generic T
---@param lib T
---@return T
function utils.createLibWrapper(lib)
	local metatable = { __index = lib };
	function metatable:__newindex() end
	return setmetatable({}, metatable);
end

return utils.createLibWrapper(utils);
