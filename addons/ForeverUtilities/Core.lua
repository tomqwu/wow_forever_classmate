local addon, NS = ...
local Core = {}
NS.Core = Core
NS.Classes = {}
-- Forever stores the desktop swing-timer preset width as an offset from the
-- 213px slider minimum. The preset value 213 therefore renders as 426px.
NS.ClassBarWidth = 426
NS.ClassBarHeight = 56

function Core.IsReadable(value)
    return not (issecretvalue and issecretvalue(value))
end

function Core.IsNumber(value)
    return Core.IsReadable(value) and type(value) == "number"
        and value == value and value > -math.huge and value < math.huge
end

function Core.Call(fn,...)
    if type(fn)~='function' then return nil end
    local function Pack(...) return {n=select('#',...),...} end
    local values=Pack(pcall(fn,...))
    if not values[1] then return nil end
    for index=2,values.n do if not Core.IsReadable(values[index]) then return nil end end
    return unpack(values,2,values.n)
end

NS.Version=Core.Call(C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata,addon,'Version') or 'unknown'

function Core.PlayerDead()
    return Core.Call(UnitIsDeadOrGhost or UnitIsDead,'player')==true
end

function Core.EnsureSchema(saved,minimum)
    saved.schemaVersion=Core.IsNumber(saved.schemaVersion) and math.max(saved.schemaVersion,minimum) or minimum
end

function NS.RegisterClass(token,module)
    assert(type(token)=='string' and type(module)=='table','Invalid class module')
    module.classToken=token
    NS.Classes[token]=module
end

function NS.ActiveClass()
    if type(UnitClass)~='function' then return nil end
    local ok,_,token=pcall(UnitClass,'player')
    if not ok or not Core.IsReadable(token) then return nil end
    return NS.Classes[token]
end
