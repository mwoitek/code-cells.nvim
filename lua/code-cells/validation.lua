local M = {}

---@param val any
---@return boolean
function M.integer(val) return type(val) == "number" and val % 1 == 0 end

---@param val any
---@return boolean
function M.non_zero_integer(val) return M.integer(val) and val ~= 0 end

---@param val any
---@return boolean
function M.positive_integer(val) return M.integer(val) and val > 0 end

return M
