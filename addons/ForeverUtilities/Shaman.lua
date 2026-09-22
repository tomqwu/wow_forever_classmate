local _, NS = ...
local Core,Context=NS.Core,NS.ShamanContext
local Shaman={
    name='Forever Classmate — Shaman',description='Totems, weapon imbues, elemental shields, mana, and spec-aware combat cues.',
    command='/fshaman',enableLabel='Enable shaman bar',width=NS.ClassBarWidth,height=NS.ClassBarHeight,
    frameName='ForeverClassmateShamanFrame',lockName='ForeverClassmateShamanLock',
    panelName='ForeverClassmateShamanOptions',minimapName='ForeverClassmateShamanMinimap',
}
NS.Shaman=Shaman

local function Normalize(db)
    for key,default in pairs({x=0,y=-210,scale=1,minimapAngle=35}) do
        if not Core.IsNumber(db[key]) then db[key]=default end
    end
    db.minimapAngle=db.minimapAngle%360
    db.x=math.max(-5000,math.min(5000,db.x));db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
Shaman.normalize=Normalize
Shaman.defaults={enabled=true,locked=true,x=0,y=-210,scale=1,showMinimap=true,showLockButton=true,
    showTotems=true,showWeaponImbue=true,showShield=true,showSpecHelper=true,showMana=true,
    totemRecallHint=true,fadeOutOfCombat=true,minimapAngle=35}
Shaman.options={
    {key='showMinimap',label='Show minimap settings button',kind='toggle'},
    {key='showLockButton',label='Show lock button on bar',kind='toggle'},
    {key='locked',label='Lock indicator position',kind='toggle'},
    {key='scale',label='Indicator size',kind='number',min=0.5,max=2,step=0.1},
    {key='showTotems',label='Show four-element totem timers',kind='toggle'},
    {key='showWeaponImbue',label='Show main-hand weapon imbue',kind='toggle'},
    {key='showShield',label='Show elemental shield / missing warning',kind='toggle'},
    {key='showSpecHelper',label='Show spec-aware combat helper',kind='toggle'},
    {key='showMana',label='Show mana percentage',kind='toggle'},
    {key='totemRecallHint',label='Suggest Totemic Recall after combat',kind='toggle'},
    {key='fadeOutOfCombat',label='Dim outside combat',kind='toggle'},
}

local function CreateIndicator(host,db)
    local frame=CreateFrame('Frame','ForeverClassmateShamanIndicator',host)
    frame:SetSize(NS.ClassBarWidth,NS.ClassBarHeight);frame:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    local background=frame:CreateTexture(nil,'BACKGROUND');background:SetAllPoints(frame)
    background:SetColorTexture(0.012,0.025,0.04,0.94)
    local accent=frame:CreateTexture(nil,'ARTWORK');accent:SetPoint('TOPLEFT');accent:SetPoint('BOTTOMLEFT')
    accent:SetWidth(4);accent:SetColorTexture(0.2,0.65,1,1)
    local separators={}
    for i=1,2 do local line=frame:CreateTexture(nil,'ARTWORK');line:SetSize(1,36);line:SetColorTexture(0.5,0.75,1,0.2);separators[i]=line end

    local elementInfo={
        {slot=2,label='E',color={0.72,0.55,0.3},fallback='Interface\\Icons\\Spell_Nature_StoneClawTotem'},
        {slot=1,label='F',color={1,0.32,0.12},fallback='Interface\\Icons\\Spell_Fire_SearingTotem'},
        {slot=3,label='W',color={0.2,0.65,1},fallback='Interface\\Icons\\INV_Spear_04'},
        {slot=4,label='A',color={0.65,0.85,1},fallback='Interface\\Icons\\Spell_Nature_Windfury'},
    }
    local totemCells={}
    local function MakeCell(size)
        local button=CreateFrame('Button',nil,frame);button:SetSize(size,size)
        local border=button:CreateTexture(nil,'ARTWORK');border:SetAllPoints();border:SetColorTexture(0.3,0.45,0.6,0.7)
        local icon=button:CreateTexture(nil,'ARTWORK');icon:SetPoint('TOPLEFT',button,'TOPLEFT',2,-2);icon:SetPoint('BOTTOMRIGHT',button,'BOTTOMRIGHT',-2,2)
        local timer=button:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');timer:SetPoint('BOTTOM',button,'BOTTOM',0,2)
        timer:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',10,'OUTLINE')
        local badge=button:CreateFontString(nil,'OVERLAY','GameFontNormalSmall');badge:SetPoint('TOPLEFT',button,'TOPLEFT',3,-2)
        badge:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',9,'OUTLINE')
        return {button=button,border=border,icon=icon,timer=timer,badge=badge}
    end
    for i,info in ipairs(elementInfo) do
        local cell=MakeCell(34);cell.info=info;totemCells[i]=cell
        cell.button:SetScript('OnEnter',function(self)
            if not GameTooltip or not cell.state then return end
            GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(cell.state.active and cell.state.name or (info.label..' element: no active totem'))
            if info.slot==1 and Shaman.spells and Shaman.spells.fireNova then GameTooltip:AddLine('Fire Nova requires an active Fire totem.',1,0.75,0.35) end
            GameTooltip:Show()
        end)
        cell.button:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
    local weapon=MakeCell(38);local shield=MakeCell(38)
    weapon.badge:SetText('W');shield.badge:SetText('S')
    local helperIcon=frame:CreateTexture(nil,'ARTWORK');helperIcon:SetSize(28,28)
    local helperText=frame:CreateFontString(nil,'OVERLAY','GameFontHighlight')
    helperText:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',12,'OUTLINE');helperText:SetJustifyH('LEFT');helperText:SetWordWrap(false)
    local manaText=frame:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    manaText:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',11,'OUTLINE');manaText:SetJustifyH('LEFT')
    local shieldNames,imbueNames={},{}
    local lastStatus='Not checked'

    local catalog={
        lightningShield={'Lightning Shield','shield'},waterShield={'Water Shield','shield'},
        maelstrom={'Maelstrom Weapon','maelstrom'},lava={'Lava Burst','lava'},flame={'Flame Shock','flame'},
        riptide={'Riptide','riptide'},fireNova={'Fire Nova','fireNova'},
        rockbiter={'Rockbiter Weapon','imbue'},flametongue={'Flametongue Weapon','imbue'},
        frostbrand={'Frostbrand Weapon','imbue'},windfury={'Windfury Weapon','imbue'},
    }
    local function Discover()
        Shaman.spells={};shieldNames={};imbueNames={}
        if not C_SpellBook or not C_Spell or not Enum or not Enum.SpellBookSpellBank then return end
        local wanted={}
        for key,entry in pairs(catalog) do
            local data=Core.Call(C_Spell.GetSpellInfo,entry[1])
            local name=type(data)=='table' and data.name or entry[1]
            if Core.IsReadable(name) and type(name)=='string' then wanted[name]={key=key,kind=entry[2]} end
        end
        local lines=Core.Call(C_SpellBook.GetNumSpellBookSkillLines)
        if not Core.IsNumber(lines) then return end
        local seen={}
        for line=1,lines do
            local info=Core.Call(C_SpellBook.GetSpellBookSkillLineInfo,line)
            if type(info)=='table' and Core.IsNumber(info.itemIndexOffset) and Core.IsNumber(info.numSpellBookItems) then
                for slot=info.itemIndexOffset+1,info.itemIndexOffset+info.numSpellBookItems do
                    local item=Core.Call(C_SpellBook.GetSpellBookItemInfo,slot,Enum.SpellBookSpellBank.Player)
                    local id=type(item)=='table' and item.spellID
                    if Core.IsNumber(id) and not seen[id] and Core.IsReadable(item.isPassive) and Core.IsReadable(item.isOffSpec)
                        and not item.isPassive and not item.isOffSpec and Core.Call(C_SpellBook.IsSpellKnown,id)==true then
                        seen[id]=true
                        local data=Core.Call(C_Spell.GetSpellInfo,id)
                        local match=type(data)=='table' and Core.IsReadable(data.name) and wanted[data.name]
                        if match then
                            local spell={id=id,name=data.name,icon=Core.IsNumber(data.iconID) and data.iconID or nil,slot=slot}
                            Shaman.spells[match.key]=spell
                            if match.kind=='shield' then shieldNames[data.name]=true end
                            if match.kind=='imbue' then imbueNames[data.name]=true end
                        end
                    end
                end
            end
        end
    end

    weapon.button:SetScript('OnEnter',function(self)
        if not GameTooltip or not weapon.state then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(weapon.state.active and 'Main-hand weapon imbue active' or 'Main-hand weapon imbue missing')
        if weapon.state.left then GameTooltip:AddLine('Remaining: '..(Context.FormatTime(weapon.state.left) or ''),1,1,1) end
        GameTooltip:Show()
    end)
    weapon.button:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    shield.button:SetScript('OnEnter',function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,'ANCHOR_TOP')
        if shield.state and shield.state.name then GameTooltip:SetText(shield.state.name)
        else GameTooltip:SetText('No elemental shield active') end
        GameTooltip:Show()
    end)
    shield.button:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)

    local function Layout()
        local x=10
        for i,cell in ipairs(totemCells) do
            cell.button:ClearAllPoints();cell.button:SetPoint('TOPLEFT',frame,'TOPLEFT',x+(i-1)*38,-7)
            cell.button:SetShown(db.showTotems~=false)
        end
        if db.showTotems~=false then x=x+152 end
        separators[1]:ClearAllPoints();separators[1]:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-10)
        local upkeep=db.showWeaponImbue~=false or db.showShield~=false
        separators[1]:SetShown(db.showTotems~=false and upkeep)
        if upkeep and db.showTotems~=false then x=x+9 end
        weapon.button:ClearAllPoints();weapon.button:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-9)
        weapon.button:SetShown(db.showWeaponImbue~=false);if db.showWeaponImbue~=false then x=x+42 end
        shield.button:ClearAllPoints();shield.button:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-9)
        shield.button:SetShown(db.showShield~=false);if db.showShield~=false then x=x+42 end
        separators[2]:ClearAllPoints();separators[2]:SetPoint('TOPLEFT',frame,'TOPLEFT',x+2,-10)
        separators[2]:SetShown(upkeep and (db.showSpecHelper~=false or db.showMana~=false or db.totemRecallHint~=false))
        if upkeep then x=x+10 end
        helperIcon:ClearAllPoints();helperIcon:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-6)
        helperText:ClearAllPoints();helperText:SetPoint('TOPLEFT',frame,'TOPLEFT',x+34,-7);helperText:SetWidth(math.max(20,392-x-34))
        manaText:ClearAllPoints();manaText:SetPoint('TOPLEFT',frame,'TOPLEFT',x+34,-31);manaText:SetWidth(math.max(20,392-x-34))
    end

    local function Update()
        local activeTotems=0
        for i,cell in ipairs(totemCells) do
            local state=Context.Totem(cell.info.slot);cell.state=state
            cell.button:SetShown(db.showTotems~=false and state~=nil)
            if state and state.active then
                activeTotems=activeTotems+1;cell.icon:SetTexture(state.icon or cell.info.fallback);cell.icon:SetVertexColor(1,1,1,1)
                cell.border:SetColorTexture(unpack(cell.info.color));cell.timer:SetText(Context.FormatTime(state.left) or '')
                cell.badge:SetText(cell.info.label)
            elseif state then
                cell.icon:SetTexture(cell.info.fallback);cell.icon:SetVertexColor(0.25,0.25,0.28,1)
                cell.border:SetColorTexture(0.18,0.23,0.3,0.8);cell.timer:SetText('');cell.badge:SetText(cell.info.label)
            end
        end
        local imbue=Context.WeaponImbue();weapon.state=imbue
        weapon.button:SetShown(db.showWeaponImbue~=false and imbue~=nil and imbue.equipped)
        if imbue and imbue.equipped then
            weapon.icon:SetTexture(imbue.icon or 'Interface\\Icons\\INV_Mace_02')
            weapon.icon:SetVertexColor(imbue.active and 1 or 0.45,imbue.active and 1 or 0.45,imbue.active and 1 or 0.45,1)
            weapon.timer:SetText(imbue.active and (Context.FormatTime(imbue.left) or '') or '')
            local warn=next(imbueNames)~=nil and not imbue.active
            weapon.border:SetColorTexture(warn and 1 or 0.25,warn and 0.15 or 0.75,warn and 0.1 or 1,1)
        end
        local missingShield,aura=Context.MissingShield(shieldNames);shield.state=aura
        shield.button:SetShown(db.showShield~=false and next(shieldNames)~=nil and missingShield~=nil)
        if next(shieldNames) then
            local fallback=(Shaman.spells.waterShield or Shaman.spells.lightningShield or {}).icon or 'Interface\\Icons\\Spell_Nature_LightningShield'
            shield.icon:SetTexture(type(aura)=='table' and (aura.icon or fallback) or fallback)
            shield.icon:SetVertexColor(type(aura)=='table' and 1 or 0.4,type(aura)=='table' and 1 or 0.4,type(aura)=='table' and 1 or 0.45,1)
            local count=type(aura)=='table' and aura.applications or 0
            shield.badge:SetText(count and count>0 and tostring(count) or 'S')
            shield.timer:SetText(type(aura)=='table' and (Context.FormatTime(aura.left) or '') or '')
            shield.border:SetColorTexture(missingShield and 1 or 0.25,missingShield and 0.15 or 0.75,missingShield and 0.1 or 1,1)
        end
        local inCombat=Core.Call(UnitAffectingCombat,'player')==true
        local hasTarget=Core.Call(UnitExists,'target')==true
        local helper,icon,color='',nil,{0.75,0.85,1}
        if db.totemRecallHint~=false and not inCombat and activeTotems>0 then
            helper='Recall '..activeTotems..' totem'..(activeTotems==1 and '' or 's');color={1,0.75,0.25}
            local recall=Core.Call(C_Spell and C_Spell.GetSpellInfo,'Totemic Recall');icon=type(recall)=='table' and recall.iconID
        elseif db.showSpecHelper~=false and Shaman.spells.maelstrom then
            local auraState=Context.Aura('player','HELPFUL',{[Shaman.spells.maelstrom.name]=true},false)
            local stacks=type(auraState)=='table' and auraState.applications or 0
            helper='Maelstrom '..stacks..'/5';icon=Shaman.spells.maelstrom.icon
            if stacks>=5 then color={0.25,1,0.45} end
        elseif db.showSpecHelper~=false and Shaman.spells.lava and Shaman.spells.flame then
            local flame=Context.FlameShock(Shaman.spells.flame.name);icon=Shaman.spells.flame.icon
            if type(flame)=='table' then helper='Flame '..(Context.FormatTime(flame.left) or 'active');color={1,0.55,0.2}
            elseif flame==false and inCombat and Core.Call(UnitCanAttack,'player','target')==true and Core.Call(UnitIsDead,'target')==false then helper='Flame Shock!';color={1,0.2,0.15}
            else helper='Lava Burst';icon=Shaman.spells.lava.icon end
        elseif db.showSpecHelper~=false and Shaman.spells.riptide then
            icon=Shaman.spells.riptide.icon
            local friendly=Core.Call(UnitIsFriend,'player','target')==true and Core.Call(UnitIsDead,'target')==false
            local tide=friendly and Context.Aura('target','HELPFUL',{[Shaman.spells.riptide.name]=true},true) or nil
            if type(tide)=='table' then helper='Riptide '..(Context.FormatTime(tide.left) or 'active');color={0.25,0.8,1}
            else helper='Riptide ready' end
        elseif db.showSpecHelper~=false then
            helper=activeTotems..'/4 totems';icon='Interface\\Icons\\Spell_Nature_StoneClawTotem'
        end
        helperIcon:SetShown(helper~='');helperIcon:SetTexture(icon or 'Interface\\Icons\\Spell_Nature_Lightning')
        helperText:SetText(helper);helperText:SetTextColor(unpack(color));helperText:SetShown(helper~='')
        local mana=db.showMana~=false and Context.ManaPercent() or nil
        manaText:SetText(mana and ('Mana '..mana..'%') or '');manaText:SetShown(mana~=nil)
        frame:SetAlpha((db.fadeOutOfCombat==false or inCombat) and 1 or (hasTarget and 0.6 or 0.2))
        lastStatus=string.format('Totems %d/4; weapon imbue %s; shield %s; helper %s; mana %s',activeTotems,
            imbue and (imbue.active and 'active' or (imbue.equipped and 'missing' or 'no weapon')) or 'unavailable',
            missingShield==nil and 'unavailable' or (missingShield and 'missing' or (aura and 'active' or 'inactive')),
            helper~='' and helper or 'off',mana and (mana..'%') or 'unavailable')
    end

    local active=false;local elapsed=0
    local events={'PLAYER_TOTEM_UPDATE','PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED',
        'PLAYER_TARGET_CHANGED','PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST','SPELLS_CHANGED','PLAYER_EQUIPMENT_CHANGED','UNIT_INVENTORY_CHANGED','UNIT_AURA','UNIT_POWER_UPDATE'}
    local function NeedsPoll()
        return db.showTotems~=false or db.showWeaponImbue~=false or db.showShield~=false or db.showSpecHelper~=false or db.showMana~=false or db.totemRecallHint~=false
    end
    local function Refresh()
        frame:SetScript('OnUpdate',nil);frame:SetShown(db.enabled);Layout()
        if not db.enabled then
            if active then for _,event in ipairs(events) do frame:UnregisterEvent(event) end end
            active=false;lastStatus='Shaman helper disabled';return
        end
        if not active then for _,event in ipairs(events) do frame:RegisterEvent(event) end;active=true;Discover() end
        Update();elapsed=0
        if NeedsPoll() then frame:SetScript('OnUpdate',function(_,delta) elapsed=elapsed+delta;if elapsed>=0.25 then elapsed=0;Update() end end) end
    end
    frame:SetScript('OnEvent',function(_,event,unit)
        if not db.enabled then return end
        if event=='UNIT_AURA' and Core.IsReadable(unit) and unit~='player' and unit~='target' then return end
        if event=='UNIT_INVENTORY_CHANGED' and Core.IsReadable(unit) and unit~='player' then return end
        if event=='UNIT_POWER_UPDATE' and Core.IsReadable(unit) and unit~='player' then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then frame:SetScript('OnUpdate',nil);return end
        if event=='SPELLS_CHANGED' or event=='PLAYER_ENTERING_WORLD' then Discover() end
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then Refresh() else Update() end
    end)
    frame.Refresh=Refresh;frame.Status=function() return lastStatus end
    Refresh();return frame
end

function Shaman.create(db)
    return NS.ClassHost.Create(Shaman,db,function(host) return CreateIndicator(host,db) end)
end
function Shaman.Initialize(saved)
    if type(saved.shaman)~='table' then saved.shaman={} end
    Shaman.db=saved.shaman
    for key,value in pairs(Shaman.defaults) do if type(Shaman.db[key])~=type(value) then Shaman.db[key]=value end end
    saved.schemaVersion=3;Shaman.Apply()
end
function Shaman.IsClass() return NS.ActiveClass()==Shaman end
function Shaman.Apply()
    Normalize(Shaman.db)
    if Shaman.IsClass() and Shaman.db.enabled and not Shaman.instance then Shaman.instance=Shaman.create(Shaman.db) end
    if Shaman.instance then Shaman.instance.Apply() end
    if Shaman.changed then Shaman.changed() end
end
function Shaman.SetEnabled(enabled) Shaman.db.enabled=enabled;Shaman.Apply() end
function Shaman.Reset() for key,value in pairs(Shaman.defaults) do Shaman.db[key]=value end;Shaman.Apply() end
NS.RegisterClass('SHAMAN',Shaman)
