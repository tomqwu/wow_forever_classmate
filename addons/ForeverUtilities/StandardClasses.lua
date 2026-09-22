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
local function FirstSpell(spells,keys)
    for _,key in ipairs(keys or {}) do if spells[key] then return spells[key] end end
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
        },upkeepLabel='Seal',upkeepGroups={{label='Seal',keys={'sealCommand','sealRighteousness','sealCrusader','sealWisdom','sealLight'}}},targetLabel='Judgment',powerType=0,powerLabel='Mana'},
    WARRIOR={key='warrior',label='Warrior',command='/fwarrior',color={0.78,0.61,0.43},icon='Interface\\Icons\\Ability_Warrior_BattleShout',
        description='Rage, stance, shout upkeep, target effects, reactive abilities, and racial cooldowns.',
        catalog={
            Spell('battleShout','Battle Shout','upkeep'),Spell('commandingShout','Commanding Shout','upkeep'),
            Spell('rend','Rend','target'),Spell('deepWounds','Deep Wounds','target',true),Spell('bloodthrill','Bloodthrill','proc',true),
            Spell('overpower','Overpower','cue'),Spell('execute','Execute','cue'),Spell('victoryRush','Victory Rush','cue'),Spell('bloodthirst','Bloodthirst','cue'),
        },upkeepLabel='Shout',upkeepGroups={{label='Shout',keys={'battleShout','commandingShout'}}},targetLabel='Target effect',powerType=1,powerLabel='Rage',showForm=true},
    ROGUE={key='rogue',label='Rogue',command='/frogue',color={1,0.96,0.41},icon='Interface\\Icons\\Ability_Rogue_SliceDice',
        description='Energy, combo points, weapon coatings, finishers, target effects, and racial cooldowns.',
        catalog={
            Spell('sliceDice','Slice and Dice','upkeep'),Spell('venom','Venom','upkeep'),
            Spell('rupture','Rupture','target'),Spell('deadlyPoison','Deadly Poison','target'),Spell('hemorrhage','Hemorrhage','target'),
            Spell('thousandCuts','Thousand Cuts','proc',true),Spell('cutthroat','Cutthroat','proc',true),
            Spell('riposte','Riposte','cue'),Spell('ambush','Ambush','cue'),Spell('bladeFlurry','Blade Flurry','cue'),Spell('coldBlood','Cold Blood','cue'),
        },upkeepLabel='Coatings / buffs',upkeepGroups={{label='Finisher buff',keys={'sliceDice','venom'}}},targetLabel='Finisher / poison',powerType=3,powerLabel='Energy',weaponCoatings=true,showCombo=true},
    DRUID={key='druid',label='Druid',command='/fdruid',color={1,0.49,0.04},icon='Interface\\Icons\\Ability_Druid_CatForm',
        description='Current form and power, buff upkeep, target effects, learned spec cues, and racial cooldowns.',
        catalog={
            Spell('markWild','Mark of the Wild','upkeep'),Spell('thorns','Thorns','upkeep'),
            Spell('moonfire','Moonfire','target'),Spell('insectSwarm','Insect Swarm','target'),Spell('faerieFire','Faerie Fire','target'),Spell('rip','Rip','target'),
            Spell('eclipse','Eclipse','proc',true),Spell('naturesGrace',"Nature's Grace",'proc',true),Spell('omenClarity','Omen of Clarity','proc',true),
            Spell('tigersFury',"Tiger's Fury",'cue'),Spell('berserk','Berserk','cue'),Spell('innervate','Innervate','cue'),Spell('swiftmend','Swiftmend','cue'),
        },upkeepLabel='Nature buffs',upkeepGroups={{label='Mark of the Wild',keys={'markWild'}},{label='Thorns',keys={'thorns'}}},targetLabel='Target effect',currentPower=true,showForm=true},
    MAGE={key='mage',label='Mage',command='/fmage',color={0.25,0.78,0.92},icon='Interface\\Icons\\Spell_Frost_FrostArmor02',
        description='Mana, armor upkeep, personal damage effects, spec procs, and racial cooldowns.',
        catalog={
            Spell('mageArmor','Mage Armor','upkeep'),Spell('iceArmor','Ice Armor','upkeep'),Spell('frostArmor','Frost Armor','upkeep'),Spell('moltenArmor','Molten Armor','upkeep'),
            Spell('improvedScorch','Improved Scorch','target',true),Spell('pyroblast','Pyroblast','target'),
            Spell('hotStreak','Hot Streak','proc',true),Spell('fingersFrost','Fingers of Frost','proc',true),Spell('arcaneBlast','Arcane Blast','proc'),
            Spell('iceLance','Ice Lance','cue'),Spell('fireBlast','Fire Blast','cue'),Spell('presenceMind','Presence of Mind','cue'),Spell('coldSnap','Cold Snap','cue'),
        },upkeepLabel='Armor',upkeepGroups={{label='Armor',keys={'mageArmor','iceArmor','frostArmor','moltenArmor'}}},targetLabel='Damage setup',powerType=0,powerLabel='Mana'},
    PRIEST={key='priest',label='Priest',command='/fpriest',color={0.92,0.92,0.92},icon='Interface\\Icons\\Spell_Holy_WordFortitude',
        description='Mana, self-buff upkeep, target effects, healing or Shadow cues, and Priest racials.',
        catalog={
            Spell('innerFire','Inner Fire','upkeep'),Spell('fortitude','Power Word: Fortitude','upkeep'),Spell('divineSpirit','Divine Spirit','upkeep'),
            Spell('shadowPain','Shadow Word: Pain','target'),Spell('devouringPlague','Devouring Plague','target'),Spell('vampiricEmbrace','Vampiric Embrace','target'),
            Spell('shadowform','Shadowform','form'),Spell('surgeLight','Surge of Light','proc',true),
            Spell('shadowDeath','Shadow Word: Death','cue'),Spell('prayerMending','Prayer of Mending','cue'),Spell('powerInfusion','Power Infusion','cue'),
        },upkeepLabel='Self buffs',upkeepGroups={{label='Inner Fire',keys={'innerFire'}},{label='Fortitude',keys={'fortitude'}},{label='Divine Spirit',keys={'divineSpirit'}}},targetLabel='Target / healing',powerType=0,powerLabel='Mana',showForm=true},
    WARLOCK={key='warlock',label='Warlock',command='/fwarlock',color={0.53,0.53,0.93},icon='Interface\\Icons\\Spell_Shadow_Metamorphosis',
        description='Mana and health, armor and demon state, DoT or Bane upkeep, abilities, and racial cooldowns.',
        catalog={
            Spell('demonArmor','Demon Armor','upkeep'),Spell('demonSkin','Demon Skin','upkeep'),Spell('felArmor','Fel Armor','upkeep'),
            Spell('corruption','Corruption','target'),Spell('immolate','Immolate','target'),Spell('wrack','Wrack','target'),
            Spell('baneAgony','Bane of Agony','target'),Spell('curseAgony','Curse of Agony','target'),
            Spell('nightfall','Nightfall','proc',true),Spell('backlash','Backlash','proc',true),
            Spell('conflagrate','Conflagrate','cue'),Spell('shadowburn','Shadowburn','cue'),Spell('lifeTap','Life Tap','cue'),Spell('demonicEmpowerment','Demonic Empowerment','cue'),
        },upkeepLabel='Armor / demon',upkeepGroups={{label='Armor',keys={'demonArmor','demonSkin','felArmor'}}},targetLabel='DoT / Bane',powerType=0,powerLabel='Mana',showPet=true,showHealth=true,showShards=true},
}

local function MakeCell(frame,x,width)
    local cell=CreateFrame('Button',nil,frame);cell:SetSize(width,48);cell:SetPoint('TOPLEFT',frame,'TOPLEFT',x,-4)
    local icon=cell:CreateTexture(nil,'ARTWORK');icon:SetSize(22,22);icon:SetPoint('TOP',cell,'TOP',0,-1)
    local top=cell:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');top:SetPoint('TOPLEFT',cell,'TOPLEFT',1,-25)
    top:SetWidth(width-2);top:SetJustifyH('CENTER');top:SetWordWrap(false);top:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',8,'OUTLINE')
    local bottom=cell:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall');bottom:SetPoint('TOPLEFT',cell,'TOPLEFT',1,-37)
    bottom:SetWidth(width-2);bottom:SetJustifyH('CENTER');bottom:SetWordWrap(false);bottom:SetFont(STANDARD_TEXT_FONT or 'Fonts\\FRIZQT__.TTF',8,'OUTLINE')
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
    local frame=CreateFrame('Frame',module.indicatorName,host);frame:SetSize(NS.ClassBarWidth,NS.ClassBarHeight);frame:SetPoint('TOPLEFT',host,'TOPLEFT',0,0)
    local background=frame:CreateTexture(nil,'BACKGROUND');background:SetAllPoints(frame);background:SetColorTexture(0.012,0.02,0.035,0.94)
    local accent=frame:CreateTexture(nil,'ARTWORK');accent:SetPoint('TOPLEFT');accent:SetPoint('BOTTOMLEFT');accent:SetWidth(4);accent:SetColorTexture(unpack(config.color))
    local resource=MakeCell(frame,5,34);local upkeep=MakeCell(frame,39,34);local target=MakeCell(frame,73,38)
    local ability=MakeCell(frame,111,38);local racial=MakeCell(frame,149,38)
    frame.cells={resource=resource,upkeep=upkeep,target=target,ability=ability,racial=racial}
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
            GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:SetText(self.tooltipTitle or title())
            if type(self.tooltipLines)=='table' then
                for _,line in ipairs(self.tooltipLines) do if line and line~='' then GameTooltip:AddLine(line,1,1,1,true) end end
            else
                local line=detail and detail();if line and line~='' then GameTooltip:AddLine(line,1,1,1,true) end
            end
            GameTooltip:Show()
        end)
        cell:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
    end
    Tooltip(resource,function() return config.label..' resources' end,function() return 'Live readable player resource state.' end)
    Tooltip(upkeep,function() return config.upkeepLabel end,function() return 'Shows learned upkeep from your current auras or equipped weapon coatings.' end)
    Tooltip(target,function() return config.targetLabel end,function() return 'Tracks your readable target effects.' end)
    Tooltip(ability,function() return config.label..' ability' end,function() return 'Tracks a readable proc or learned usable ability.' end)
    Tooltip(racial,function() return racial.state and racial.state.spell.name or 'Racial ability' end,function()
        return 'The learned active racial with its real cooldown and current usability. Context means the game reports it unusable now.'
    end)

    local function Update()
        local inCombat=Core.Call(UnitAffectingCombat,'player')==true
        local hasTarget=Core.Call(UnitExists,'target')==true
        local hostile=hasTarget and Core.Call(UnitCanAttack,'player','target')==true and Core.Call(UnitIsDead,'target')==false
        local power
        if config.currentPower then power=Context.CurrentPower() else power=Context.Power(config.powerType,config.powerLabel) end
        local resourceTop=power and (power.percent..'%') or '?'
        local resourceBottom=''
        local resourceLines={}
        if power then resourceLines[#resourceLines+1]=(power.label or 'Power')..': '..math.floor(power.current+0.5)..' / '..math.floor(power.maximum+0.5)
        else resourceLines[#resourceLines+1]='The client did not expose a readable resource value.' end
        if config.showCombo then
            local cp=Context.ComboPoints();resourceBottom=cp and ('CP'..cp) or ''
            if cp then resourceLines[#resourceLines+1]='Combo points: '..cp..' / 5' end
        elseif config.showForm then
            local form=Context.Form();resourceBottom=form and 'Form' or 'Base'
            if form then resourceLines[#resourceLines+1]='Form or stance: '..form.name end
        elseif config.showHealth then
            local hp=Context.HealthPercent('player');resourceBottom=hp and ('H'..hp) or ''
            if hp then resourceLines[#resourceLines+1]='Health: '..hp..'%' end
        end
        if config.showShards then
            local shards=Context.ItemCount('Soul Shard')
            if shards then resourceBottom=(resourceBottom~='' and (resourceBottom..'/') or '')..'S'..shards;resourceLines[#resourceLines+1]='Soul Shards: '..shards end
        end
        resource.tooltipTitle=config.label..' resources';resource.tooltipLines=resourceLines
        Paint(resource,config.icon,resourceTop,resourceBottom,config.color,power==nil);resource:SetShown(db.showResource~=false)

        local upkeepTotal,upkeepActive,upkeepMissing,upkeepUnknown=0,0,0,0
        local upkeepLines={};local upkeepIcon;local upkeepDim=false
        if config.weaponCoatings then
            local coatings=Context.WeaponCoatings()
            if coatings then
                if coatings.equipped>0 then
                    upkeepTotal=upkeepTotal+1
                    if coatings.active>=coatings.equipped then upkeepActive=upkeepActive+1 else upkeepMissing=upkeepMissing+1;upkeepDim=true end
                    upkeepLines[#upkeepLines+1]='Weapon coatings: '..coatings.active..' / '..coatings.equipped..' active'
                else upkeepLines[#upkeepLines+1]='Weapon coatings: no equipped weapons' end
            else upkeepTotal=upkeepTotal+1;upkeepUnknown=upkeepUnknown+1;upkeepLines[#upkeepLines+1]='Weapon coatings: unavailable' end
        end
        for _,group in ipairs(config.upkeepGroups or {{label=config.upkeepLabel,keys=module.upkeepKeys}}) do
            local learned=FirstSpell(module.spells,group.keys)
            if learned then
                upkeepTotal=upkeepTotal+1
                local aura=Context.Aura('player','HELPFUL',Context.Names(module.spells,group.keys),false)
                if type(aura)=='table' then
                    upkeepActive=upkeepActive+1;upkeepIcon=upkeepIcon or aura.icon or learned.icon
                    local remaining=Context.FormatTime(aura.left)
                    upkeepLines[#upkeepLines+1]=group.label..': '..aura.name..(remaining and (' '..remaining) or ' active')
                elseif aura==false then
                    upkeepMissing=upkeepMissing+1;upkeepIcon=upkeepIcon or learned.icon;upkeepDim=true
                    upkeepLines[#upkeepLines+1]=group.label..': missing'
                else
                    upkeepUnknown=upkeepUnknown+1;upkeepIcon=upkeepIcon or learned.icon
                    upkeepLines[#upkeepLines+1]=group.label..': unavailable'
                end
            end
        end
        if config.showPet then
            upkeepTotal=upkeepTotal+1
            local petExists=Core.Call(UnitExists,'pet')
            local petDead;if petExists==true then petDead=Core.Call(UnitIsDead,'pet') end
            if petExists==true and petDead==false then upkeepActive=upkeepActive+1;upkeepLines[#upkeepLines+1]='Demon: active'
            elseif petExists==false or petDead==true then upkeepMissing=upkeepMissing+1;upkeepDim=true;upkeepLines[#upkeepLines+1]='Demon: missing'
            else upkeepUnknown=upkeepUnknown+1;upkeepLines[#upkeepLines+1]='Demon: unavailable' end
        end
        local upkeepTop=upkeepTotal>0 and (upkeepActive..'/'..upkeepTotal) or '—'
        local upkeepBottom=upkeepMissing>0 and ('!'..upkeepMissing) or (upkeepUnknown>0 and '?' or (upkeepTotal>0 and 'OK' or ''))
        local upkeepWarn=inCombat and upkeepMissing>0
        upkeep.tooltipTitle=config.upkeepLabel;upkeep.tooltipLines=upkeepLines
        Paint(upkeep,upkeepIcon or config.icon,upkeepTop,upkeepBottom,upkeepWarn and {1,0.25,0.18} or config.color,upkeepDim)
        upkeep:SetShown(db.showUpkeep~=false)

        local showTarget=db.showTarget~=false;local showAbilities=db.showAbilities~=false
        local proc;if showAbilities then proc=Context.Aura('player','HELPFUL',Context.Names(module.spells,module.procKeys),false) end
        local targetAura
        if showTarget and hostile then targetAura=Context.Aura('target','HARMFUL',Context.Names(module.spells,module.targetKeys),true)
        elseif showTarget then targetAura=false end
        local cue=showAbilities and Context.BestCue(module.spells,module.cueKeys) or nil
        local targetText,abilityText,targetIcon,abilityIcon,targetColor,abilityColor,targetDim,abilityDim
        local targetLines,abilityLines={},{}
        if showTarget and type(targetAura)=='table' then
            targetText=targetAura.applications and targetAura.applications>1 and ('×'..targetAura.applications) or (Context.FormatTime(targetAura.left) or 'On')
            targetIcon=targetAura.icon;targetColor=config.color
            local remaining=Context.FormatTime(targetAura.left)
            targetLines[#targetLines+1]=targetAura.name..(remaining and (' — '..remaining) or ' — active')
        elseif showTarget and hostile then
            local targetSpell=FirstSpell(module.spells,module.targetKeys)
            if targetSpell and targetAura==false then targetText='!';targetColor={1,0.72,0.28};targetDim=true;targetLines[#targetLines+1]=targetSpell.name..': missing'
            elseif targetSpell and targetAura==nil then targetText='?';targetLines[#targetLines+1]='Target effects: unavailable'
            else targetText='—' end
            targetIcon=targetSpell and targetSpell.icon or config.icon
        elseif showTarget then targetText=hasTarget and 'Friend' or 'None';targetIcon=config.icon;targetDim=true end
        if showAbilities and type(proc)=='table' then
            abilityText=proc.applications and proc.applications>1 and ('×'..proc.applications) or (Context.FormatTime(proc.left) or 'Proc')
            abilityIcon=proc.icon;abilityColor={0.3,1,0.48}
            local remaining=Context.FormatTime(proc.left)
            abilityLines[#abilityLines+1]=proc.name..(remaining and (' — '..remaining) or ' — active')
        elseif showAbilities and cue then
            abilityIcon=cue.spell.icon
            if cue.status=='ready' then abilityText='Ready';abilityColor={0.3,1,0.48}
            elseif cue.status=='cooldown' then abilityText=Context.FormatTime(cue.left) or 'CD'
            elseif cue.status=='context' then abilityText='Ctx';abilityDim=true
            else abilityText='?';abilityDim=true end
            local detail=cue.status=='cooldown' and (Context.FormatTime(cue.left) or 'cooldown') or cue.status
            abilityLines[#abilityLines+1]=cue.spell.name..': '..detail
        end
        target.tooltipTitle=config.targetLabel;target.tooltipLines=targetLines
        ability.tooltipTitle=config.label..' ability';ability.tooltipLines=abilityLines
        Paint(target,targetIcon or config.icon,targetText,'Effect',targetColor,targetDim);target:SetShown(showTarget)
        Paint(ability,abilityIcon or config.icon,abilityText,'Ability',abilityColor,abilityDim);ability:SetShown(showAbilities)

        local racialStates=Context.RacialStates(module.spells,module.classToken);local racialState=racialStates[1];racial.state=racialState
        if racialState then
            local status,color
            if racialState.status=='ready' then status='Ready';color={0.3,1,0.48}
            elseif racialState.status=='cooldown' then status=Context.FormatTime(racialState.left);color={1,0.72,0.28}
            elseif racialState.status=='context' then status='Ctx';color={0.65,0.7,0.78}
            else status='?';color={0.55,0.6,0.68} end
            racial.tooltipTitle=racialState.spell.name;racial.tooltipLines={}
            for _,state in ipairs(racialStates) do
                local stateText=state.status=='cooldown' and (Context.FormatTime(state.left) or 'cooldown') or state.status
                racial.tooltipLines[#racial.tooltipLines+1]=state.spell.name..': '..stateText
            end
            Paint(racial,racialState.spell.icon,status,'Racial',color,not racialState.ready)
        else
            racial.tooltipTitle='Racial ability';racial.tooltipLines={'No learned active racial was found.'}
            Paint(racial,config.icon,'None','Racial',{0.55,0.6,0.68},true)
        end
        racial:SetShown(db.showRacial~=false)

        frame:SetAlpha((db.fadeOutOfCombat==false or inCombat) and 1 or (hasTarget and 0.6 or 0.2))
        lastStatus=string.format('%s; upkeep %s; target %s; ability %s; racial %s',resourceTop,upkeepBottom or 'off',targetText or 'off',abilityText or 'off',
            racialState and (racialState.spell.name..' '..(racialState.status=='cooldown' and (Context.FormatTime(racialState.left) or 'cooldown') or racialState.status)) or 'unavailable')
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
    frame.Refresh=Refresh;frame.Update=Update;frame.Status=function() return lastStatus end
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
        enableLabel='Enable '..config.label:lower()..' bar',width=NS.ClassBarWidth,height=NS.ClassBarHeight,
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
