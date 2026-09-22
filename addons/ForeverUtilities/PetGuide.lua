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
        or Call(UnitIsPlayer,'target')~=false then return nil end
    -- Family IDs/names are returned together on Forever; both can be restricted.
    if type(UnitCreatureFamily)~='function' then return nil end
    local ok,name,familyID=pcall(UnitCreatureFamily,'target')
    if not ok or not Core.IsReadable(name) or not Core.IsReadable(familyID) then return nil end
    if not Core.IsNumber(familyID) then familyID=DB.familyNames[name] end
    if not familyID then return nil end
    local family=DB.families[familyID]
    if not family then return nil end
    local targetName=Plain(Call(UnitName,'target'))
    local controlled=Call(UnitPlayerControlled,'target')
    local wild=controlled==false
    -- Owned/controlled pets still get family advice, never wild spawn/taming claims.
    local id=wild and CreatureID() or nil
    local notable=Core.IsNumber(id) and DB.notable[id] or nil
    if notable and notable.family~=familyID then notable=nil end
    local rare
    local rareNameMatch=false
    if wild and Core.IsNumber(id) then
        rare=DB.rareByID[id]
    elseif controlled==true and targetName then
        rare=DB.rareByName[targetName]
        rareNameMatch=rare~=nil
    end
    if rare and rare.family~=familyID then rare=nil;rareNameMatch=false end
    local classification=Call(UnitClassification,'target')
    local labels={normal='Normal',rare='Rare',elite='Elite',rareelite='Rare elite',worldboss='Boss',trivial='Trivial',minus='Minor'}
    local level=Call(UnitLevel,'target')
    local playerLevel=Call(UnitLevel,'player')
    return {family=family,name=targetName or (rare and rare.name) or (notable and notable.name) or family.name,
        owned=controlled==true,wild=wild,notable=notable,rare=rare,rareNameMatch=rareNameMatch,
        classification=labels[classification],
        special=classification=='rare' or classification=='elite' or classification=='rareelite' or classification=='worldboss',
        level=Core.IsNumber(level) and level>0 and math.floor(level) or nil,
        tooHigh=wild and Core.IsNumber(level) and Core.IsNumber(playerLevel) and level>0 and playerLevel>0 and level>playerLevel}
end
function Guide.Lines(info)
    local family=info.family
    local lines={family.name..(info.level and (' | Level '..info.level) or '')..(info.classification and (' | '..info.classification) or ''),
        'Suggested use: '..family.role,
        'Family ability: '..family.ability,
        family.effect}
    if info.rare then
        local detail='Rare origin: '..info.rare.name..' — '..info.rare.zone
        if info.rare.level then detail=detail..' | Wild level '..info.rare.level end
        lines[#lines+1]=detail
        if info.rareNameMatch then
            lines[#lines+1]='Rare identity is an exact English name + family match; renamed pets cannot be identified.'
        end
    elseif info.notable then
        lines[#lines+1]='Watch list: '..info.notable.name..' — '..info.notable.zone
    end
    if info.tooHigh then lines[#lines+1]='Above your level — cannot tame yet.' end
    if info.owned then
        lines[#lines+1]='Player-controlled pet. Family advice, not a wild tame target or a list of its learned skills.'
    elseif info.wild then
        lines[#lines+1]='Family guide only. Use Beast Lore to check tameability and actual skills.'
    else
        lines[#lines+1]='Family guide only. Ownership, tameability, and learned skills are not confirmed.'
    end
    lines[#lines+1]='Beta guide '..DB.reviewed..'; skill availability may change.'
    return lines
end
function Guide.Summary(info)
    if info.rare then
        return 'Rare '..info.rare.name..' | '..info.family.name..': '..info.family.ability
    end
    local prefix=info.special and (info.classification..' ') or ''
    return prefix..info.family.name..': '..info.family.ability
end
function Guide.CompactSummary(info)
    if info.rare then return info.rare.name..': '..info.family.ability end
    return info.family.name..': '..info.family.ability
end
function Guide.Create(parent)
    local badge=CreateFrame('Button',nil,parent)
    badge:SetSize(18,18);badge:EnableMouse(true);badge:Hide()
    badge.hasMatch=false
    local border=badge:CreateTexture(nil,'BACKGROUND')
    border:SetAllPoints();border:SetColorTexture(0.2,0.85,1,1)
    local icon=badge:CreateTexture(nil,'ARTWORK')
    icon:SetSize(14,14);icon:SetPoint('CENTER');icon:SetTexture('Interface\\Icons\\Ability_Physical_Taunt')
    -- Draw directly on the bar, like range/ammo. The button is only a hover area.
    local label=parent:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',11,'OUTLINE')
    label:SetJustifyH('LEFT');label:SetWordWrap(false);label:Hide()
    local hit=CreateFrame('Button',nil,parent)
    hit:EnableMouse(true);hit:Hide()
    badge.hintPanel=hit;badge.hintTitle=label
    local width=196
    function badge.SetLayout(x,y,w,height)
        width=w
        label:ClearAllPoints();label:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);label:SetSize(w,height)
        hit:ClearAllPoints();hit:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);hit:SetSize(w,height)
    end
    local hoverOwner
    local function HideTooltip()
        if hoverOwner and GameTooltip and GameTooltip:IsOwned(hoverOwner) then GameTooltip:Hide() end
        hoverOwner=nil
    end
    local function ShowTooltip()
        if not hoverOwner or not badge.hasMatch or not GameTooltip then return end
        GameTooltip:SetOwner(hoverOwner,'ANCHOR_TOP')
        GameTooltip:SetText('Pet guide: '..badge.info.name)
        for _,line in ipairs(Guide.Lines(badge.info)) do GameTooltip:AddLine(line,1,1,1,true) end
        GameTooltip:Show()
    end
    for _,surface in ipairs({badge,hit}) do
        surface:SetScript('OnEnter',function() hoverOwner=surface;ShowTooltip() end)
        surface:SetScript('OnLeave',HideTooltip)
        surface:SetScript('OnHide',HideTooltip)
    end
    function badge.Clear()
        badge.info=nil;badge.hasMatch=false;HideTooltip();badge:Hide();hit:Hide()
        label:SetText('');label:Hide()
    end
    function badge.Update(enabled)
        local info=enabled and Guide.ReadTarget() or nil
        badge.info=info
        if not info then badge.Clear();return end
        badge.hasMatch=true
        local r,g,b=0.2,0.85,1
        if info.tooHigh then r,g,b=1,0.25,0.15
        elseif info.special or info.notable or info.rare then r,g,b=1,0.75,0.15 end
        border:SetColorTexture(r,g,b,1)
        label:SetTextColor(1,info.tooHigh and 0.4 or 0.88,info.tooHigh and 0.3 or 0.55)
        label:SetText(width<100 and Guide.CompactSummary(info) or Guide.Summary(info))
        label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',11,'OUTLINE')
        local measured=label:GetStringWidth()
        if Core.IsNumber(measured) and measured>width then
            label:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',math.max(8,11*width/measured),'OUTLINE')
        end
        label:Show();badge:Show();hit:Show();ShowTooltip()
    end
    return badge
end
