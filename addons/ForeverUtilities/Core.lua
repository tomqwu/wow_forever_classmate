local _, NS = ...
local Core = {}
NS.Core = Core
NS.Version = '0.21.1'
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
    local values={pcall(fn,...)}
    if not table.remove(values,1) then return nil end
    for _,value in ipairs(values) do if not Core.IsReadable(value) then return nil end end
    return unpack(values)
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
