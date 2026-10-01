local _, NS = ...
local Core = NS.Core
local Tracker = {}
NS.DotTracker = Tracker

local MAX_TARGETS, MAX_BARS, MAX_NAMEPLATES, MAX_AURAS = 5, 12, 12, 80

local function OwnAura(aura)
    if Core.IsReadable(aura.sourceUnit) and type(aura.sourceUnit)=='string' then
        return aura.sourceUnit=='player' or Core.Call(UnitIsUnit,aura.sourceUnit,'player')==true
    end
    return Core.IsReadable(aura.isFromPlayerOrPlayerPet) and aura.isFromPlayerOrPlayerPet==true
end

function Tracker.ReadUnit(unit,names,now)
    if not Core.IsNumber(now) or Core.Call(UnitExists,unit)~=true
        or Core.Call(UnitCanAttack,'player',unit)~=true or Core.Call(UnitIsDead,unit)~=false then return nil end
    local api=C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
    if type(api)~='function' then return nil end
    local guid=Core.Call(UnitGUID,unit)
    if type(guid)~='string' or guid=='' then guid=nil end
    local name=Core.Call(UnitName,unit)
    if type(name)~='string' or name=='' then name=NS.L(unit=='target' and 'Target' or 'Enemy') end
    name=name:gsub('|','||'):gsub('[\r\n]',' ')
    local result={unit=unit,guid=guid,name=name,effects={}}
    -- Positive observations only; an unseen effect is never called missing.
    for index=1,MAX_AURAS do
        local ok,aura=pcall(api,unit,index,'HARMFUL')
        if not ok then return nil end
        if Core.IsReadable(aura) then
            if aura==nil then break end
            if type(aura)=='table' and Core.IsReadable(aura.name) and type(aura.name)=='string'
                and names[aura.name] and OwnAura(aura)
                and Core.IsNumber(aura.duration) and Core.IsNumber(aura.expirationTime)
                and aura.duration>0 and aura.expirationTime>now then
                local entry=names[aura.name]
                local left=aura.expirationTime-now
                local previous=result.effects[entry.key]
                if not previous or previous.left<left then
                    result.effects[entry.key]={name=aura.name,key=entry.key,duration=aura.duration,
                        expires=aura.expirationTime,left=left}
                end
            end
        end
    end
    if not next(result.effects) then return nil end
    return result
end

function Tracker.Create(parent,db,module,keys,color)
    local frame=CreateFrame('Frame',nil,parent)
    frame:SetSize(212,20);frame:SetPoint('TOPLEFT',parent,'TOPRIGHT',6,0);frame:Hide()
    local background=frame:CreateTexture(nil,'BACKGROUND');background:SetAllPoints(frame)
    background:SetColorTexture(0.012,0.02,0.035,0.94)
    local heading=frame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    heading:SetPoint('TOPLEFT',frame,'TOPLEFT',7,-4);heading:SetWidth(198);heading:SetJustifyH('LEFT')
    frame.heading=heading
    local bars={}
    for index=1,MAX_BARS do
        local bar=CreateFrame('StatusBar',nil,frame)
        bar:SetSize(200,17);bar:SetPoint('TOPLEFT',frame,'TOPLEFT',6,-20-(index-1)*19)
        bar:SetStatusBarTexture('Interface\\Buttons\\WHITE8X8')
        bar:SetStatusBarColor(color[1]*0.65,color[2]*0.65,color[3]*0.65,0.85)
        local back=bar:CreateTexture(nil,'BACKGROUND');back:SetAllPoints(bar)
        back:SetColorTexture(0.08,0.09,0.11,1)
        local label=bar:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
        label:SetPoint('LEFT',bar,'LEFT',4,0);label:SetWidth(158);label:SetJustifyH('LEFT');label:SetWordWrap(false)
        label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',10,'OUTLINE')
        local time=bar:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
        time:SetPoint('RIGHT',bar,'RIGHT',-4,0);time:SetWidth(32);time:SetJustifyH('RIGHT')
        time:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',10,'OUTLINE')
        bar.label=label;bar.time=time;bar:Hide();bars[index]=bar
    end
    frame.bars=bars
    local tokens={};local observations={};local visible={};local active=false;local suspended=false;local elapsed=0
    local events={'NAME_PLATE_UNIT_ADDED','NAME_PLATE_UNIT_REMOVED','UNIT_AURA','PLAYER_TARGET_CHANGED',
        'PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST'}
    local function Hide()
        frame:Hide();frame:SetScript('OnUpdate',nil)
        for _,bar in ipairs(bars) do bar:Hide() end
        visible={}
    end
    local function Names()
        local names={}
        for _,key in ipairs(keys) do
            local spell=module.spells and module.spells[key]
            if spell then
                if type(spell.name)=='string' then names[spell.name]={key=key} end
                for name in pairs(spell.auraNames or {}) do
                    if type(name)=='string' then names[name]={key=key} end
                end
            end
        end
        return names
    end
    local function Tick()
        local now=Core.Call(GetTime)
        if not Core.IsNumber(now) then Hide();return end
        local expired=false
        for index,entry in ipairs(visible) do
            local left=entry.expires-now
            if left<=0 then expired=true;break end
            local bar=bars[index]
            bar:SetMinMaxValues(0,entry.duration)
            bar:SetValue(math.min(entry.duration,left))
            bar.label:SetText(entry.unitName..' · '..entry.name)
            bar.time:SetText(NS.L(math.ceil(left)..'s'))
        end
        if expired then frame.Scan(false) end
    end
    local function SeedNameplates()
        for index=1,40 do
            local unit='nameplate'..index
            if Core.Call(UnitExists,unit)==true then tokens[unit]=true end
        end
    end
    function frame.Scan(changedUnit)
        if not active or suspended or Core.PlayerDead() or db.showMultiDots==false then Hide();return end
        local now=Core.Call(GetTime)
        if not Core.IsNumber(now) then Hide();return end
        local names=Names()
        if not next(names) then Hide();return end
        local units={'target'}
        for index=1,40 do
            local unit='nameplate'..index
            if tokens[unit] then units[#units+1]=unit end
            if #units>MAX_NAMEPLATES then break end
        end
        local seen={};local entries={};local targetCount=0;local total=0
        local targetGUID=Core.Call(UnitGUID,'target')
        if type(targetGUID)~='string' or targetGUID=='' then targetGUID=nil end
        for _,unit in ipairs(units) do
            if targetCount>=MAX_TARGETS then break end
            local sameTarget=unit~='target' and (Core.Call(UnitIsUnit,unit,'target')==true
                or (targetGUID and Core.Call(UnitGUID,unit)==targetGUID))
            if not sameTarget then
                if changedUnit==nil or changedUnit==unit or observations[unit]==nil then
                    observations[unit]=Tracker.ReadUnit(unit,names,now) or false
                end
                local data=observations[unit]
                if data and (not data.guid or not seen[data.guid]) then
                    if data.guid then seen[data.guid]=true end
                    targetCount=targetCount+1
                    for _,key in ipairs(keys) do
                        local effect=data.effects[key]
                        if effect and effect.expires>now then
                            total=total+1
                            if #entries<MAX_BARS then
                                entries[#entries+1]={unitName=data.name,name=effect.name,
                                    duration=effect.duration,expires=effect.expires}
                            end
                        end
                    end
                end
            end
        end
        visible=entries
        if #entries==0 then Hide();return end
        heading:SetText(NS.L('DoTs')..(total>#entries and (' · +'..(total-#entries)..NS.L(' more')) or ''))
        frame:SetSize(212,20+#entries*19)
        for index,bar in ipairs(bars) do bar:SetShown(index<=#entries) end
        frame:Show();Tick();elapsed=0
        frame:SetScript('OnUpdate',function(_,delta)
            elapsed=elapsed+delta
            if elapsed>=0.1 then elapsed=0;Tick() end
        end)
    end
    function frame.Refresh(enabled)
        local wanted=enabled and db.showMultiDots~=false
        if not wanted then
            if active then for _,event in ipairs(events) do frame:UnregisterEvent(event) end end
            active=false;tokens={};observations={};Hide();return
        end
        if not active then
            for _,event in ipairs(events) do frame:RegisterEvent(event) end
            active=true;SeedNameplates()
        end
        if not Core.PlayerDead() then suspended=false end
        frame.Scan()
    end
    frame:SetScript('OnEvent',function(_,event,unit)
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then suspended=true;Hide();return end
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then
            suspended=false;tokens={};observations={};SeedNameplates();frame.Scan();return
        end
        if suspended then return end
        if event=='NAME_PLATE_UNIT_ADDED' or event=='NAME_PLATE_UNIT_REMOVED' then
            if not Core.IsReadable(unit) or type(unit)~='string' or not unit:match('^nameplate%d+$') then return end
            if event=='NAME_PLATE_UNIT_ADDED' then tokens[unit]=true;observations[unit]=nil;frame.Scan(unit)
            else tokens[unit]=nil;observations[unit]=nil;frame.Scan(false) end
            return
        end
        if event=='UNIT_AURA' then
            if not Core.IsReadable(unit) or type(unit)~='string' or (unit~='target' and not tokens[unit]) then return end
        end
        frame.Scan(event=='UNIT_AURA' and unit or 'target')
    end)
    return frame
end
