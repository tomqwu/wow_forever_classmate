local _,NS=...
local Core=NS.Core
-- One LibDataBroker data source, so Titan Panel (or any other broker display)
-- can show Classmate. It mirrors what the class host already decided: the
-- compact stat and the confirmed warnings. It never reads game data itself
-- and never polls; the host pushes a refresh when that state changes.
local Broker={}
NS.Broker=Broker
local NAME='ForeverClassmate'
local media='Interface\\AddOns\\ForeverUtilities\\Textures\\'
local object,openSettings
local state={}

local function Library()
    local stub=rawget(_G,'LibStub')
    if type(stub)~='table' or type(stub.GetLibrary)~='function' then return nil end
    local ok,lib=pcall(stub.GetLibrary,stub,'LibDataBroker-1.1',true)
    if ok and type(lib)=='table' and type(lib.NewDataObject)=='function' then return lib end
end

local function Hex(c)
    return string.format('%02x%02x%02x',math.floor((c[1] or 1)*255+0.5),math.floor((c[2] or 1)*255+0.5),math.floor((c[3] or 1)*255+0.5))
end

local function ClassName(module)
    return NS.L((module.name or ''):gsub('^Forever Classmate — ',''))
end

-- Text shown on the panel: the stat, then the first confirmed warning (+N).
local function Text()
    if not state.module then return '' end
    if not state.enabled then return '|cff9aa0aa'..NS.L('Off')..'|r' end
    local parts={}
    local stat=state.stat
    if stat then parts[#parts+1]=stat.color and ('|cff'..Hex(stat.color)..stat.text..'|r') or stat.text end
    local warnings=state.warnings
    if #warnings>0 then
        parts[#parts+1]='|cffffb347'..NS.L(warnings[1].label)..(#warnings>1 and (' +'..(#warnings-1)) or '')..'|r'
    end
    return table.concat(parts,'  ')
end

local function Icon()
    local token=state.module and state.module.classToken
    return token and (media..'Classes\\'..token) or (media..'ForeverClassmate')
end

local function Publish()
    if not object then return end
    object.icon=Icon();object.text=Text()
    object.label=NS.L('Classmate')
end

local function Tooltip(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine(NS.L('Forever Classmate'))
    local module=state.module
    if not module then
        tooltip:AddLine(NS.L('No helper is available for this class yet.'),0.75,0.75,0.75,true)
    elseif not state.enabled then
        tooltip:AddLine(ClassName(module)..': '..NS.L('Disabled'),0.75,0.75,0.75)
    elseif state.dead then
        tooltip:AddLine(ClassName(module),1,1,1)
        tooltip:AddLine(NS.L('Expands when you are alive'),0.75,0.75,0.75,true)
    else
        tooltip:AddLine(ClassName(module),1,1,1)
        if state.stat then tooltip:AddLine(NS.L(state.stat.label)..': '..state.stat.text,0.85,0.9,1) end
        for _,warning in ipairs(state.warnings) do tooltip:AddLine(NS.L(warning.label),1,0.75,0.35,true) end
        if #state.warnings==0 then tooltip:AddLine(NS.L('No confirmed missing buffs'),0.75,0.75,0.75,true) end
    end
    tooltip:AddLine(' ')
    tooltip:AddLine(NS.L('Left-click: settings'),0.75,0.75,0.75)
    if module and state.enabled and not state.dead then
        tooltip:AddLine(NS.L('Right-click: fold or expand the bar'),0.75,0.75,0.75)
    end
end

-- A right-click is the player's own fold choice, exactly like the crest.
local function Click(_,button)
    local module=state.module
    if button=='RightButton' then
        if not module or not module.db or not module.db.enabled or Core.PlayerDead()==true then return end
        module.db.collapsed=module.db.collapsed~=true;module.db.foldedByDeath=nil
        module.Apply()
    elseif openSettings then
        openSettings()
    end
end

-- Called by the class host's card refresh. Only the active class publishes.
function Broker.Refresh(module,host,warnings)
    if module~=NS.ActiveClass() then return end
    local db=module.db or {}
    state.module=module
    state.enabled=db.enabled==true
    state.dead=state.enabled and Core.PlayerDead()==true
    state.warnings={}
    state.stat=nil
    if state.enabled and not state.dead then
        for _,warning in ipairs(warnings or {}) do state.warnings[#state.warnings+1]=warning end
        local stat=host and host.foldStat
        local content=host and host.foldContent
        if type(stat)=='table' and type(stat.text)=='string' and stat.text~='' and Core.Icon(stat.icon)
            and (not content or content:IsShown()) then state.stat=stat end
    end
    Publish()
end

-- Create the data source once, after the saved settings are loaded.
function Broker.Initialize(open)
    openSettings=open
    local module=NS.ActiveClass()
    state.module=module;state.enabled=module and module.db and module.db.enabled==true or false
    state.warnings={};state.stat=nil;state.dead=false
    if object then Publish();return object end
    local lib=Library()
    if not lib then return nil end
    object=lib:NewDataObject(NAME,{type='data source',label=NS.L('Classmate'),icon=Icon(),text=Text(),
        OnClick=Click,OnTooltipShow=Tooltip})
    return object
end

Broker.Text=Text
