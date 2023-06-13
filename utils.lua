local utils = {};

---@generic T
---@param table T
---@return T
function utils.createReadonlyTable(table)
	local metatable = { __index = table };
	function metatable:__newindex() end
	return setmetatable({}, metatable);
end

function utils.createRecurviseReadonlyTable(table)
	local tbl = {};
	for key, value in pairs(table) do
		tbl[key] = type(value) == "table" and utils.createRecurviseReadonlyTable(value) or value;
	end
	local metatable = { __index = tbl };
	function metatable:__newindex() end
	return setmetatable({}, metatable);
end

return utils.createReadonlyTable(utils);
