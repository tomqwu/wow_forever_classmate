local addon, NS = ...
local Core = {}
NS.Core = Core
NS.Classes = {}
-- Locale.lua replaces this with the client-language lookup at load time.
NS.L = function(text) return text end
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

function Core.Icon(value)
    if Core.IsNumber(value) and value>0 then return value end
    if Core.IsReadable(value) and type(value)=='string' and value~='' then return value end
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

function Core.CanInspectTarget()
    return Core.Call(UnitIsPlayer,'target')==true and Core.Call(CanInspect,'target')==true
        and type(InspectUnit)=='function'
end

function Core.InspectTarget()
    if not Core.CanInspectTarget() then return false end
    local ok=pcall(InspectUnit,'target')
    return ok
end

function Core.EnsureSchema(saved,minimum)
    saved.schemaVersion=Core.IsNumber(saved.schemaVersion) and math.max(saved.schemaVersion,minimum) or minimum
end

-- Animate only the warning decoration. Keep the icon, text and bar readable,
-- and let the native animation system do the work without another poller.
function Core.CreateWarningPulse(owner,decoration)
    local group,attempted
    local function Set(enabled)
        if enabled~=true then
            if group then
                if group:IsPlaying() then group:Stop() end
                decoration:SetAlpha(1)
            end
            return
        end
        if not attempted then
            attempted=true
            if type(decoration.CreateAnimationGroup)~='function' then return end
            group=decoration:CreateAnimationGroup()
            if not group then return end
            for order,ends in ipairs({{0.25,1},{1,0.25}}) do
                local alpha=group:CreateAnimation('Alpha')
                alpha:SetFromAlpha(ends[1]);alpha:SetToAlpha(ends[2])
                alpha:SetDuration(0.65);alpha:SetOrder(order)
            end
            group:SetLooping('REPEAT')
        end
        if group and not group:IsPlaying() then group:Play() end
    end
    owner:HookScript('OnHide',function() Set(false) end)
    return Set
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
