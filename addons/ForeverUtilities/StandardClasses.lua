local _, NS = ...
local Core,Context=NS.Core,NS.ClassContext

local function Spell(key,names,kind,passive)
    return {key=key,names=type(names)=='table' and names or {names},kind=kind,allowPassive=passive}
end
local function Append(target,source)
    for _,value in ipairs(source) do target[#target+1]=value end
end
local function Keys(catalog,kind)
    local result={}
    for _,entry in ipairs(catalog) do if entry.kind==kind then result[#result+1]=entry.key end end
    return result
end
local function Normalize(db)
    for key,default in pairs({x=0,y=-210,scale=1,minimapAngle=35}) do if not Core.IsNumber(db[key]) then db[key]=default end end
    db.minimapAngle=db.minimapAngle%360
    db.x=math.max(-5000,math.min(5000,db.x));db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
local function Short(text,max)
    if type(text)~='string' then return '' end
    if #text<=max then return text end
    return text:sub(1,max-1)..'…'
end
local function FirstSpell(spells,keys)
    for _,key in ipairs(keys or {}) do if spells[key] then return spells[key] end end
end
local function AuraText(aura)
    if type(aura)~='table' then return '' end
    local suffix=Context.FormatTime(aura.left)
    local stacks=aura.applications and aura.applications>1 and (' ×'..aura.applications) or ''
    return Short(aura.name,15)..stacks..(suffix and (' '..suffix) or '')
end

local sharedRacials={}
for _,entry in ipairs(Context.RacialCatalog) do sharedRacials[#sharedRacials+1]=entry end

local configs={
    PALADIN={key='paladin',label='Paladin',command='/fpaladin',color={0.96,0.55,0.73},icon='Interface\\Icons\\Spell_Holy_SealOfMight',
        description='Mana, seal upkeep, judgments, learned combat abilities, and racial cooldowns.',
        catalog={
            Spell('sealCommand','Seal of Command','upkeep'),Spell('sealRighteousness','Seal of Righteousness','upkeep'),
            Spell('sealCrusader','Seal of the Crusader','upkeep'),Spell('sealWisdom','Seal of Wisdom','upkeep'),Spell('sealLight','Seal of Light','upkeep'),
            Spell('twistLight','Twist of Light','proc',true),
            Spell('judgementCrusader','Judgement of the Crusader','target'),Spell('judgementWisdom','Judgement of Wisdom','target'),
            Spell('judgementLight','Judgement of Light','target'),Spell('judgementJustice','Judgement of Justice','target'),
            Spell('holyStrike','Holy Strike','cue'),Spell('holyShock','Holy Shock','cue'),Spell('consecration','Consecration','cue'),
        },upkeepLabel='Seal',targetLabel='Judgment',powerType=0,powerLabel='Mana'},
    WARRIOR={key='warrior',label='Warrior',command='/fwarrior',color={0.78,0.61,0.43},icon='Interface\\Icons\\Ability_Warrior_BattleShout',
        description='Rage, stance, shout upkeep, target effects, reactive abilities, and racial cooldowns.',
        catalog={
            Spell('battleShout','Battle Shout','upkeep'),Spell('commandingShout','Commanding Shout','upkeep'),
            Spell('rend','Rend','target'),Spell('deepWounds','Deep Wounds','target',true),Spell('bloodthrill','Bloodthrill','proc',true),
            Spell('overpower','Overpower','cue'),Spell('execute','Execute','cue'),Spell('victoryRush','Victory Rush','cue'),Spell('bloodthirst','Bloodthirst','cue'),
        },upkeepLabel='Shout',targetLabel='Target effect',powerType=1,powerLabel='Rage',showForm=true},
    ROGUE={key='rogue',label='Rogue',command='/frogue',color={1,0.96,0.41},icon='Interface\\Icons\\Ability_Rogue_SliceDice',
        description='Energy, combo points, weapon coatings, finishers, target effects, and racial cooldowns.',
        catalog={
            Spell('sliceDice','Slice and Dice','upkeep'),Spell('venom','Venom','upkeep'),
            Spell('rupture','Rupture','target'),Spell('deadlyPoison','Deadly Poison','target'),Spell('hemorrhage','Hemorrhage','target'),
            Spell('thousandCuts','Thousand Cuts','proc',true),Spell('cutthroat','Cutthroat','proc',true),
            Spell('riposte','Riposte','cue'),Spell('ambush','Ambush','cue'),Spell('bladeFlurry','Blade Flurry','cue'),Spell('coldBlood','Cold Blood','cue'),
        },upkeepLabel='Coatings',targetLabel='Finisher / poison',powerType=3,powerLabel='Energy',weaponCoatings=true,showCombo=true},
    DRUID={key='druid',label='Druid',command='/fdruid',color={1,0.49,0.04},icon='Interface\\Icons\\Ability_Druid_CatForm',
        description='Current form and power, buff upkeep, target effects, learned spec cues, and racial cooldowns.',
        catalog={
            Spell('markWild','Mark of the Wild','upkeep'),Spell('thorns','Thorns','upkeep'),
            Spell('moonfire','Moonfire','target'),Spell('insectSwarm','Insect Swarm','target'),Spell('faerieFire','Faerie Fire','target'),Spell('rip','Rip','target'),
            Spell('eclipse','Eclipse','proc',true),Spell('naturesGrace',"Nature's Grace",'proc',true),Spell('omenClarity','Omen of Clarity','proc',true),
            Spell('tigersFury',"Tiger's Fury",'cue'),Spell('berserk','Berserk','cue'),Spell('innervate','Innervate','cue'),Spell('swiftmend','Swiftmend','cue'),
        },upkeepLabel='Nature buff',targetLabel='Target effect',currentPower=true,showForm=true},
    MAGE={key='mage',label='Mage',command='/fmage',color={0.25,0.78,0.92},icon='Interface\\Icons\\Spell_Frost_FrostArmor02',
        description='Mana, armor upkeep, personal damage effects, spec procs, and racial cooldowns.',
        catalog={
            Spell('mageArmor','Mage Armor','upkeep'),Spell('iceArmor','Ice Armor','upkeep'),Spell('frostArmor','Frost Armor','upkeep'),Spell('moltenArmor','Molten Armor','upkeep'),
            Spell('improvedScorch','Improved Scorch','target',true),Spell('pyroblast','Pyroblast','target'),
            Spell('hotStreak','Hot Streak','proc',true),Spell('fingersFrost','Fingers of Frost','proc',true),Spell('arcaneBlast','Arcane Blast','proc'),
            Spell('iceLance','Ice Lance','cue'),Spell('fireBlast','Fire Blast','cue'),Spell('presenceMind','Presence of Mind','cue'),Spell('coldSnap','Cold Snap','cue'),
        },upkeepLabel='Armor',targetLabel='Damage setup',powerType=0,powerLabel='Mana'},
    PRIEST={key='priest',label='Priest',command='/fpriest',color={0.92,0.92,0.92},icon='Interface\\Icons\\Spell_Holy_WordFortitude',
        description='Mana, self-buff upkeep, target effects, healing or Shadow cues, and Priest racials.',
        catalog={
            Spell('innerFire','Inner Fire','upkeep'),Spell('fortitude','Power Word: Fortitude','upkeep'),Spell('divineSpirit','Divine Spirit','upkeep'),
            Spell('shadowPain','Shadow Word: Pain','target'),Spell('devouringPlague','Devouring Plague','target'),Spell('vampiricEmbrace','Vampiric Embrace','target'),
            Spell('shadowform','Shadowform','proc'),Spell('surgeLight','Surge of Light','proc',true),
            Spell('shadowDeath','Shadow Word: Death','cue'),Spell('prayerMending','Prayer of Mending','cue'),Spell('powerInfusion','Power Infusion','cue'),
        },upkeepLabel='Self buff',targetLabel='Target / healing',powerType=0,powerLabel='Mana'},
    WARLOCK={key='warlock',label='Warlock',command='/fwarlock',color={0.53,0.53,0.93},icon='Interface\\Icons\\Spell_Shadow_Metamorphosis',
        description='Mana and health, armor and demon state, DoT or Bane upkeep, abilities, and racial cooldowns.',
        catalog={
            Spell('demonArmor','Demon Armor','upkeep'),Spell('demonSkin','Demon Skin','upkeep'),Spell('felArmor','Fel Armor','upkeep'),
            Spell('corruption','Corruption','target'),Spell('immolate','Immolate','target'),Spell('wrack','Wrack','target'),
            Spell('baneAgony','Bane of Agony','target'),Spell('curseAgony','Curse of Agony','target'),
            Spell('nightfall','Nightfall','proc',true),Spell('backlash','Backlash','proc',true),
            Spell('conflagrate','Conflagrate','cue'),Spell('shadowburn','Shadowburn','cue'),Spell('lifeTap','Life Tap','cue'),Spell('demonicEmpowerment','Demonic Empowerment','cue'),
        },upkeepLabel='Armor / demon',targetLabel='DoT / Bane',powerType=0,powerLabel='Mana',showPet=true,showHealth=true,showShards=true},
}

local function MakeCell(frame,x,width)
    local cell=CreateFrame('Button',nil,frame);cell:SetSize(width,48);cell:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-4)
    local icon=cell:CreateTexture(nil,'ARTWORK');icon:SetSize(30,30);icon:SetPoint('LEFT',cell,'LEFT',4,0)
    local top=cell:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');top:SetPoint('TOPLEFT',cell,'TOPLEFT',39,-7)
    top:SetWidth(width-42);top:SetJustifyH('LEFT');top:SetWordWrap(false);top:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',11,'OUTLINE')
    local bottom=cell:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');bottom:SetPoint('TOPLEFT',cell,'TOPLEFT',39,-26)
    bottom:SetWidth(width-42);bottom:SetJustifyH('LEFT');bottom:SetWordWrap(false);bottom:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',10,'OUTLINE')
    local line=frame:CreateTexture(nil,'ARTWORK');line:SetSize(1,36);line:SetPoint('RIGHT',cell,'RIGHT',0,0);line:SetColorTexture(0.6,0.7,0.85,0.18)
    cell.icon,cell.top,cell.bottom,cell.line=icon,top,bottom,line
    return cell
end
local function Paint(cell,icon,top,bottom,color,dim)
    cell.icon:SetTexture(icon);cell.icon:SetVertexColor(dim and 0.42 or 1,dim and 0.42 or 1,dim and 0.45 or 1,1)
    cell.top:SetText(top or '');cell.bottom:SetText(bottom or '')
    cell.top:SetTextColor(unpack(color or {0.88,0.92,1}));cell.bottom:SetTextColor(0.68,0.74,0.82)
end

local function CreateIndicator(module,config,host,db)
    local frame=CreateFrame('Frame',module.indicatorName,host);frame:SetSize(400,56);frame:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    local background=frame:CreateTexture(nil,'BACKGROUND');background:SetAllPoints(frame);background:SetColorTexture(0.012,0.02,0.035,0.94)
    local accent=frame:CreateTexture(nil,'ARTWORK');accent:SetPoint('TOPLEFT');accent:SetPoint('BOTTOMLEFT');accent:SetWidth(4);accent:SetColorTexture(unpack(config.color))
    local resource=MakeCell(frame,7,91);local upkeep=MakeCell(frame,98,102);local target=MakeCell(frame,200,105);local racial=MakeCell(frame,305,67)
    racial.top:SetWidth(27);racial.bottom:SetWidth(27)
    local lastStatus='Not checked';local elapsed=0;local active=false

    local function Discover()
        local catalog={};Append(catalog,config.catalog);Append(catalog,sharedRacials)
        module.spells=Context.Discover(catalog)
        module.upkeepKeys=Keys(config.catalog,'upkeep');module.targetKeys=Keys(config.catalog,'target')
        module.procKeys=Keys(config.catalog,'proc');module.cueKeys=Keys(config.catalog,'cue')
    end
    local function Tooltip(cell,title,detail)
        cell:SetScript('OnEnter',function(self)
            if not GameTooltip then return end
            GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(title())
            local line=detail and detail();if line and line~='' then GameTooltip:AddLine(line,1,1,1,true) end
            GameTooltip:Show()
        end)
        cell:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
    Tooltip(resource,function() return config.label..' resources' end,function() return 'Live readable player resource state.' end)
    Tooltip(upkeep,function() return config.upkeepLabel end,function() return 'Shows learned upkeep from your current auras or equipped weapon coatings.' end)
    Tooltip(target,function() return config.targetLabel end,function() return 'Tracks your readable target effects, proc auras, and learned usable abilities.' end)
    Tooltip(racial,function() return racial.state and racial.state.spell.name or 'Racial ability' end,function()
        return 'The learned active racial with its real cooldown and current usability. Context means the game reports it unusable now.'
    end)

    local function Update()
        local inCombat=Core.Call(UnitAffectingCombat,'player')==true
        local hasTarget=Core.Call(UnitExists,'target')==true
        local hostile=hasTarget and Core.Call(UnitCanAttack,'player','target')==true and Core.Call(UnitIsDead,'target')==false
        local power=config.currentPower and Context.CurrentPower() or Context.Power(config.powerType,config.powerLabel)
        local resourceTop=power and (power.label..' '..math.floor(power.current+0.5)..'/'..math.floor(power.maximum+0.5)) or 'Resource unavailable'
        local resourceBottom=''
        if config.showCombo then local cp=Context.ComboPoints();resourceBottom=cp and ('Combo '..cp..'/5') or ''
        elseif config.showForm then local form=Context.Form();resourceBottom=form and Short(form.name,14) or 'No stance / form'
        elseif config.showHealth then local hp=Context.HealthPercent('player');resourceBottom=hp and ('Health '..hp..'%') or '' end
        Paint(resource,config.icon,resourceTop,resourceBottom,config.color,power==nil);resource:SetShown(db.showResource~=false)

        local upkeepAura,upkeepSpell,upkeepTop,upkeepBottom,upkeepWarn
        if config.weaponCoatings then
            local coatings=Context.WeaponCoatings();upkeepTop=config.upkeepLabel
            if coatings then
                upkeepBottom=coatings.equipped>0 and (coatings.active..'/'..coatings.equipped..' active') or 'No weapons'
                upkeepWarn=inCombat and coatings.equipped>0 and coatings.active<coatings.equipped
            else upkeepBottom='Unavailable' end
        else
            upkeepSpell=FirstSpell(module.spells,module.upkeepKeys)
            upkeepAura=Context.Aura('player','HELPFUL',Context.Names(module.spells,module.upkeepKeys),false)
            upkeepTop=type(upkeepAura)=='table' and Short(upkeepAura.name,15) or config.upkeepLabel
            upkeepBottom=type(upkeepAura)=='table' and (Context.FormatTime(upkeepAura.left) or 'Active') or (upkeepSpell and 'Missing' or 'No learned spell')
            upkeepWarn=inCombat and upkeepSpell~=nil and upkeepAura==false
            if config.showPet then
                local pet=Core.Call(UnitExists,'pet')==true and Core.Call(UnitIsDead,'pet')==false
                upkeepBottom=(upkeepBottom or '')..' · '..(pet and 'Demon active' or 'No demon')
                upkeepWarn=upkeepWarn or (inCombat and not pet)
            end
        end
        local upkeepIcon=type(upkeepAura)=='table' and upkeepAura.icon or (upkeepSpell and upkeepSpell.icon) or config.icon
        Paint(upkeep,upkeepIcon,upkeepTop,upkeepBottom,upkeepWarn and {1,0.25,0.18} or config.color,upkeepAura==false)
        upkeep:SetShown(db.showUpkeep~=false)

        local proc=Context.Aura('player','HELPFUL',Context.Names(module.spells,module.procKeys),false)
        local targetAura=hostile and Context.Aura('target','HARMFUL',Context.Names(module.spells,module.targetKeys),true) or false
        local cue=db.showAbilities~=false and Context.BestCue(module.spells,module.cueKeys) or nil
        local targetTop,targetBottom,targetIcon,targetColor,targetDim
        if type(proc)=='table' then
            targetTop=AuraText(proc);targetIcon=proc.icon;targetColor={0.3,1,0.48}
        elseif type(targetAura)=='table' then
            targetTop=AuraText(targetAura);targetIcon=targetAura.icon;targetColor=config.color
        elseif hostile then
            local targetSpell=FirstSpell(module.spells,module.targetKeys)
            targetTop=targetSpell and ('No '..Short(targetSpell.name,12)) or 'Hostile target';targetIcon=targetSpell and targetSpell.icon or config.icon
            targetColor={1,0.72,0.28};targetDim=true
        else targetTop=hasTarget and 'Non-hostile target' or 'No target';targetIcon=config.icon;targetDim=true end
        if cue then
            if cue.ready then targetBottom=Short(cue.spell.name,13)..' ready';targetColor={0.3,1,0.48}
            elseif Core.IsNumber(cue.left) and cue.left>0 then targetBottom=Short(cue.spell.name,10)..' '..(Context.FormatTime(cue.left) or '')
            else targetBottom=Short(cue.spell.name,13)..' context' end
            if not targetIcon then targetIcon=cue.spell.icon end
        end
        Paint(target,targetIcon or config.icon,targetTop,targetBottom,targetColor,targetDim);target:SetShown(db.showTarget~=false or db.showAbilities~=false)

        local racialState=Context.Racial(module.spells,module.classToken);racial.state=racialState
        if racialState then
            local status,color
            if racialState.ready then status='Ready';color={0.3,1,0.48}
            elseif Core.IsNumber(racialState.left) and racialState.left>0 then status=Context.FormatTime(racialState.left);color={1,0.72,0.28}
            else status='Context';color={0.65,0.7,0.78} end
            Paint(racial,racialState.spell.icon,Short(racialState.spell.name,8),status,color,not racialState.ready)
        else Paint(racial,config.icon,'Racial','None found',{0.55,0.6,0.68},true) end
        racial:SetShown(db.showRacial~=false)

        if config.showShards and db.showResource~=false then
            local shards=Context.ItemCount('Soul Shard')
            if shards then resource.bottom:SetText((resourceBottom~='' and (resourceBottom..' · ') or '')..'Shards '..shards) end
        end
        frame:SetAlpha((db.fadeOutOfCombat==false or inCombat) and 1 or (hasTarget and 0.6 or 0.2))
        lastStatus=string.format('%s; upkeep %s; target %s; racial %s',resourceTop,upkeepBottom or 'off',targetTop or 'off',
            racialState and (racialState.spell.name..' '..(racialState.ready and 'ready' or (Context.FormatTime(racialState.left) or 'context'))) or 'unavailable')
    end

    local events={'PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','PLAYER_TARGET_CHANGED',
        'PLAYER_DEAD','PLAYER_ALIVE','PLAYER_UNGHOST','SPELLS_CHANGED','LEARNED_SPELL_IN_TAB','UNIT_AURA','UNIT_POWER_UPDATE',
        'UNIT_HEALTH','UPDATE_SHAPESHIFT_FORM','UPDATE_SHAPESHIFT_FORMS','PLAYER_EQUIPMENT_CHANGED','UNIT_INVENTORY_CHANGED','BAG_UPDATE_DELAYED','SPELL_UPDATE_COOLDOWN'}
    local function NeedsPoll()
        return db.showResource~=false or db.showUpkeep~=false or db.showTarget~=false or db.showAbilities~=false or db.showRacial~=false
    end
    local function Refresh()
        frame:SetScript('OnUpdate',nil);frame:SetShown(db.enabled)
        if not db.enabled then
            if active then for _,event in ipairs(events) do frame:UnregisterEvent(event) end end
            active=false;lastStatus=config.label..' helper disabled';return
        end
        if not active then for _,event in ipairs(events) do frame:RegisterEvent(event) end;active=true;Discover() end
        Update();elapsed=0
        if NeedsPoll() then frame:SetScript('OnUpdate',function(_,delta) elapsed=elapsed+delta;if elapsed>=0.25 then elapsed=0;Update() end end) end
    end
    frame:SetScript('OnEvent',function(_,event,unit)
        if not db.enabled then return end
        if (event=='UNIT_AURA' or event=='UNIT_POWER_UPDATE' or event=='UNIT_HEALTH' or event=='UNIT_INVENTORY_CHANGED')
            and Core.IsReadable(unit) and unit~='player' and unit~='target' and unit~='pet' then return end
        if event=='PLAYER_LEAVING_WORLD' or event=='PLAYER_DEAD' then frame:SetScript('OnUpdate',nil);return end
        if event=='SPELLS_CHANGED' or event=='LEARNED_SPELL_IN_TAB' or event=='PLAYER_ENTERING_WORLD' then Discover() end
        if event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_ALIVE' or event=='PLAYER_UNGHOST' then Refresh() else Update() end
    end)
    frame.Refresh=Refresh;frame.Status=function() return lastStatus end
    Refresh();return frame
end

local defaultOptions={
    {key='showMinimap',label='Show minimap settings button',kind='toggle'},
    {key='showLockButton',label='Show lock button on bar',kind='toggle'},
    {key='locked',label='Lock indicator position',kind='toggle'},
    {key='scale',label='Indicator size',kind='number',min=0.5,max=2,step=0.1},
    {key='showResource',label='Show resources and stance/form',kind='toggle'},
    {key='showUpkeep',label='Show class upkeep block',kind='toggle'},
    {key='showTarget',label='Show target effect block',kind='toggle'},
    {key='showAbilities',label='Show learned ability readiness',kind='toggle'},
    {key='showRacial',label='Show learned racial readiness',kind='toggle'},
    {key='fadeOutOfCombat',label='Dim outside combat',kind='toggle'},
}

for token,config in pairs(configs) do
    local module={name='Forever Classmate — '..config.label,description=config.description,command=config.command,
        enableLabel='Enable '..config.label:lower()..' bar',width=400,height=56,
        frameName='ForeverClassmate'..config.label..'Frame',lockName='ForeverClassmate'..config.label..'Lock',
        panelName='ForeverClassmate'..config.label..'Options',minimapName='ForeverClassmate'..config.label..'Minimap',
        indicatorName='ForeverClassmate'..config.label..'Indicator',normalize=Normalize,options=defaultOptions,
        defaults={enabled=true,locked=true,x=0,y=-210,scale=1,showMinimap=true,showLockButton=true,showResource=true,
            showUpkeep=true,showTarget=true,showAbilities=true,showRacial=true,fadeOutOfCombat=true,minimapAngle=35}}
    NS[config.label]=module
    function module.create(db)
        return NS.ClassHost.Create(module,db,function(host) return CreateIndicator(module,config,host,db) end)
    end
    function module.Initialize(saved)
        if type(saved[config.key])~='table' then saved[config.key]={} end
        module.db=saved[config.key]
        for key,value in pairs(module.defaults) do if type(module.db[key])~=type(value) then module.db[key]=value end end
        saved.schemaVersion=4;module.Apply()
    end
    function module.IsClass() return NS.ActiveClass()==module end
    function module.Apply()
        Normalize(module.db)
        if module.IsClass() and module.db.enabled and not module.instance then module.instance=module.create(module.db) end
        if module.instance then module.instance.Apply() end
        if module.changed then module.changed() end
    end
    function module.SetEnabled(enabled) module.db.enabled=enabled;module.Apply() end
    function module.Reset() for key,value in pairs(module.defaults) do module.db[key]=value end;module.Apply() end
    NS.RegisterClass(token,module)
end
