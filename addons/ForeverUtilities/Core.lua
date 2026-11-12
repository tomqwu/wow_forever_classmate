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

Core.Media='Interface\\AddOns\\ForeverUtilities\\Textures\\'
Core.Amber={1,0.85,0.45}

-- Keep a decoration's visibility in step with the texture it dresses, so
-- module code that shows/hides the original keeps working unchanged.
local function Mirror(source,target,onChange)
    for _,method in ipairs({'Show','Hide','SetShown'}) do
        local original=source[method]
        if type(original)=='function' then
            source[method]=function(self,...)
                original(self,...)
                local shown=Core.Call(self.IsShown,self)==true
                target:SetShown(shown)
                if onChange then onChange(shown) end
            end
        end
    end
    local shown=Core.Call(source.IsShown,source)==true
    target:SetShown(shown)
    if onChange then onChange(shown) end
end
Core.Mirror=Mirror

-- English catalog name plus its Simplified Chinese spellings from the Forever
-- client's own spell table (SpellAliases.lua). Learned-spell discovery
-- compares these with spellbook names, so a zhCN client finds the same spells.
function Core.SpellNames(english)
    local names={english}
    local aliases=NS.SpellAliases and NS.SpellAliases[english]
    for _,alias in ipairs(aliases or {}) do names[#names+1]=alias end
    return names
end
-- What to call an effect that has no spellbook entry of its own.
function Core.SpellDisplayName(english)
    local aliases=NS.SpellAliases and NS.SpellAliases[english]
    if aliases and aliases[1] and Core.Call(GetLocale)=='zhCN' then return aliases[1] end
    return english
end

-- Turn a 1px separator into the engraved vertical divider. The original
-- texture stays as the invisible anchor that module layouts already move.
function Core.EngraveDivider(line,parent,tint)
    line:SetColorTexture(0,0,0,0)
    local art=parent:CreateTexture(nil,'ARTWORK')
    art:SetTexture(Core.Media..'Divider');art:SetSize(6,42);art:SetPoint('CENTER',line,'CENTER',0,0)
    -- Rotate the horizontal divider a quarter turn.
    art:SetTexCoord(0,0,1,0,0,1,1,1)
    local c=tint or {0.75,0.78,0.85}
    art:SetVertexColor(c[1],c[2],c[3],0.9)
    Mirror(line,art)
    line.engraved=art
    return art
end

-- Dress a solid warning square as an engraved frame with an ember halo.
-- `cover` is an optional neutral frame on the same icon; it steps aside while
-- the warning shows, so two frames never stack and the pulse stays visible.
function Core.StyleWarningFrame(texture,parent,color,cover)
    local c=color or Core.Amber
    texture:SetTexture(Core.Media..'IconFrame');texture:SetVertexColor(c[1],c[2],c[3],1)
    -- Above each module's dark fill, just below its icon.
    if texture.SetDrawLayer then texture:SetDrawLayer('ARTWORK',-1) end
    local halo=parent:CreateTexture(nil,'BORDER',nil,-8)
    halo:SetTexture(Core.Media..'CellGlow')
    -- Six pixels of glow on every side, following the frame as it resizes.
    halo:SetPoint('TOPLEFT',texture,'TOPLEFT',-6,6);halo:SetPoint('BOTTOMRIGHT',texture,'BOTTOMRIGHT',6,-6)
    local glow=color and {color[1],color[2]*0.6,color[3]*0.3} or {1,0.5,0.12}
    halo:SetVertexColor(glow[1],glow[2],glow[3],0.6)
    if halo.SetBlendMode then halo:SetBlendMode('ADD') end
    Mirror(texture,halo,cover and function(shown) cover:SetAlpha(shown and 0 or 1) end)
    texture.halo=halo
    return halo
end

-- Neutral engraved frame around an icon, shown only while the icon shows.
function Core.IconFrame(parent,icon,size)
    local frame=parent:CreateTexture(nil,'OVERLAY')
    frame:SetTexture(Core.Media..'IconFrame');frame:SetSize(size,size);frame:SetPoint('CENTER',icon,'CENTER',0,0)
    frame:SetVertexColor(0.78,0.8,0.86,1)
    Mirror(icon,frame)
    return frame
end

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
