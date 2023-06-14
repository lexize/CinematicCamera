local utils = {};

---@generic T
---@param table T
---@return T
function utils.createReadonlyTable(table)
	local metatable = { __index = table };
	function metatable:__newindex() end
	return setmetatable({}, metatable);
end

function utils.createIndexMetatable(table)
	local metatable = { __index = table };
	return metatable;
end

function utils.mergeIndexMetatable(mtbl1, mtbl2)
	return {__index = function (t, k)
		local v;
		if (type(mtbl1.__index) == "function") then v = mtbl1.__index(t,k) else v = mtbl1.__index[k] end;
		if (v ~= nil) then return v; end
		if (type(mtbl2.__index) == "function") then v = mtbl2.__index(t,k) else v = mtbl2.__index[k] end;
		return v;
	end}
end

---@generic T
---@param table T
---@return T
function utils.createRecurviseReadonlyTable(table)
	local tbl = {};
	for key, value in pairs(table) do
		tbl[key] = type(value) == "table" and utils.createRecurviseReadonlyTable(value) or value;
	end
	local metatable = { __index = tbl };
	function metatable:__newindex() end
	return setmetatable({}, metatable);
end

---@param a number
---@param b number
---@param v number
---@return number
function utils.addTowards(a, b, v)
	local diff = b - a;
	local addition = math.min(math.abs(diff), math.abs(v)) * math.sign(diff);
	return a + addition;
end

return utils.createReadonlyTable(utils);
