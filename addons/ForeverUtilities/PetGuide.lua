local _, NS = ...
local Core,DB=NS.Core,NS.PetDatabase
local Guide={}
NS.PetGuide=Guide
local function Call(fn,...)
    if type(fn)~='function' then return nil end
    local ok,value=pcall(fn,...)
    if ok and Core.IsReadable(value) then return value end
end
local function Plain(value)
    if not Core.IsReadable(value) or type(value)~='string' or value=='' then return nil end
    return value:gsub('|','||'):gsub('[\r\n]',' ')
end
local function CreatureID()
    -- Do not fall back around a restricted identity API.
    if type(UnitCreatureID)=='function' then return Call(UnitCreatureID,'target') end
    local guid=Call(UnitGUID,'target')
    if type(guid)~='string' then return nil end
    return tonumber(guid:match('^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-[%x]+$'))
end
function Guide.ReadTarget()
    if Call(UnitExists,'target')~=true or Call(UnitIsDead,'target')~=false
        or Call(UnitIsPlayer,'target')~=false or Call(UnitPlayerControlled,'target')~=false then return nil end
    -- Family IDs/names are returned together on Forever; both can be restricted.
    if type(UnitCreatureFamily)~='function' then return nil end
    local ok,name,familyID=pcall(UnitCreatureFamily,'target')
    if not ok or not Core.IsReadable(name) or not Core.IsReadable(familyID) then return nil end
    if not Core.IsNumber(familyID) then familyID=DB.familyNames[name] end
    if not familyID then return nil end
    local family=DB.families[familyID]
    if not family then return nil end
    local id=CreatureID()
    local notable=Core.IsNumber(id) and DB.notable[id] or nil
    if notable and notable.family~=familyID then notable=nil end
    local classification=Call(UnitClassification,'target')
    local labels={normal='Normal',rare='Rare',elite='Elite',rareelite='Rare elite',worldboss='Boss',trivial='Trivial',minus='Minor'}
    local level=Call(UnitLevel,'target')
    local playerLevel=Call(UnitLevel,'player')
    return {family=family,name=Plain(Call(UnitName,'target')) or (notable and notable.name) or family.name,
        notable=notable,classification=labels[classification],
        special=classification=='rare' or classification=='elite' or classification=='rareelite' or classification=='worldboss',
        level=Core.IsNumber(level) and level>0 and math.floor(level) or nil,
        tooHigh=Core.IsNumber(level) and Core.IsNumber(playerLevel) and level>0 and playerLevel>0 and level>playerLevel}
end
function Guide.Lines(info)
    local family=info.family
    local lines={family.name..(info.level and (' | Level '..info.level) or '')..(info.classification and (' | '..info.classification) or ''),
        'Suggested use: '..family.role,
        'Family ability: '..family.ability,
        family.effect}
    if info.notable then lines[#lines+1]='Watch list: '..info.notable.name..' — '..info.notable.zone end
    if info.tooHigh then lines[#lines+1]='Above your level — cannot tame yet.' end
    lines[#lines+1]='Family guide only. Use Beast Lore to check tameability and actual skills.'
    lines[#lines+1]='Beta guide '..DB.reviewed..'; skill availability may change.'
    return lines
end
function Guide.Create(parent)
    local badge=CreateFrame('Button',nil,parent)
    badge:SetSize(18,18);badge:EnableMouse(true);badge:Hide()
    local border=badge:CreateTexture(nil,'BACKGROUND')
    border:SetAllPoints();border:SetColorTexture(0.2,0.85,1,1)
    local icon=badge:CreateTexture(nil,'ARTWORK')
    icon:SetSize(14,14);icon:SetPoint('CENTER');icon:SetTexture('Interface\\Icons\\Ability_Physical_Taunt')
    local hovered=false
    local function HideTooltip()
        if hovered and GameTooltip and GameTooltip:IsOwned(badge) then GameTooltip:Hide() end
        hovered=false
    end
    local function ShowTooltip()
        if not hovered or not badge.info or not GameTooltip then return end
        GameTooltip:SetOwner(badge,'ANCHOR_TOP')
        GameTooltip:SetText('Pet guide: '..badge.info.name)
        for _,line in ipairs(Guide.Lines(badge.info)) do GameTooltip:AddLine(line,1,1,1,true) end
        GameTooltip:Show()
    end
    badge:SetScript('OnEnter',function() hovered=true;ShowTooltip() end)
    badge:SetScript('OnLeave',HideTooltip)
    badge:SetScript('OnHide',HideTooltip)
    function badge.Clear()
        badge.info=nil;HideTooltip();badge:Hide()
    end
    function badge.Update(enabled)
        local info=enabled and Guide.ReadTarget() or nil
        badge.info=info
        if not info then badge.Clear();return end
        if badge.info.tooHigh then border:SetColorTexture(1,0.25,0.15,1)
        elseif badge.info.special or badge.info.notable then border:SetColorTexture(1,0.75,0.15,1)
        else border:SetColorTexture(0.2,0.85,1,1) end
        badge:Show();ShowTooltip()
    end
    return badge
end
