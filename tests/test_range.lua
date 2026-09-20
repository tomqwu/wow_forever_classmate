local NS={}
local secret={}
issecretvalue=function(v) return rawequal(v,secret) end
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/Range.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/TargetContext.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/PetDatabase.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/PetGuide.lua'))('ForeverUtilities',NS)
assert(loadfile('addons/ForeverUtilities/Layout.lua'))('ForeverUtilities',NS)
local count=0
local function check(ok,msg) assert(ok,msg);count=count+1 end
local function measure(probes,m,r,state,text)
    local actual,label=NS.Range.Measure(probes,m,r,{min=8,max=35})
    check(actual==state and (not text or label:find(text,1,true)),label)
end
measure({{min=0,max=5,inside=true}},true,false,'melee','<=5 yd')
measure({{min=0,max=5,inside=false},{min=0,max=35,inside=true}},false,false,'close','~5-8 yd')
measure({{min=8,max=35,inside=true}},false,true,'shoot','~8-35 yd')
measure({{min=0,max=35,inside=false}},false,false,'far','>35 yd')
measure({},false,false,'out','Out of range')
measure({{min=8,max=35,inside=false}},false,false,'out')
measure({{min=0,max=35,inside=secret}},secret,secret,'unknown')
measure({{min=0,max=5,inside=true},{min=0,max=35,inside=false}},false,false,'unknown')
measure({},nil,nil,'unknown')
local function fallback(probes,shot,state,text)
    local actual,label=NS.Range.Measure(probes,nil,nil,shot)
    check(actual==state and label:find(text,1,true),label)
end
fallback({{min=8,max=35,inside=true}},{min=8,max=35,inside=true},'shoot','Shooting')
fallback({{min=0,max=35,inside=false}},{min=8,max=35,inside=false},'far','>35 yd')
fallback({{min=0,max=5,inside=false},{min=0,max=35,inside=true}},
    {min=8,max=35,inside=false},'close','~5-8 yd')
fallback({{min=0,max=100,inside=false}},nil,'beyond','Out of range | >100 yd')
fallback({{min=0,max=35,inside=true}},nil,'distance','<=35 yd')
fallback({}, {min=8,max=35,inside=secret},'unknown','Range unavailable')
-- Never display invalid, restricted, or unchecked distances as real numbers.
for _,value in ipairs({-1,math.huge,0/0,secret}) do
    UnitDistanceSquared=function() return value,true end
    check(NS.Range.ReadDistance('target')==nil,'reject invalid numeric distance')
end
UnitDistanceSquared=function() return 400,false end
check(NS.Range.ReadDistance('target')==nil,'unchecked distance rejected')
UnitDistanceSquared=function() return 400,secret end
check(NS.Range.ReadDistance('target')==nil,'secret validity flag rejected')
UnitDistanceSquared=function() error('restricted') end
check(NS.Range.ReadDistance('target')==nil,'numeric API errors guarded')
UnitDistanceSquared=function() return 0,true end
check(NS.Range.ReadDistance('target')==0,'zero distance valid')
UnitDistanceSquared=function() return 625,true end
check(NS.Range.ReadDistance('target')==25,'squared distance converted to yards')
local numericState,numericLabel=NS.Range.WithDistance('shoot','Shooting | ~8-35 yd',23.4)
check(numericState=='shoot' and numericLabel=='Shooting | 23.4 yd','numeric label retains attack classification')
UnitDistanceSquared=nil
-- Mock discovery uses arbitrary IDs, proving it does not depend on Classic spell IDs.
local frames={}
local methods={}
function methods:SetScript(k,v) self.scripts[k]=v end
function methods:RegisterEvent(e) self.events[e]=true end
function methods:UnregisterEvent(e) self.events[e]=nil end
function methods:CreateTexture()
 local texture=setmetatable({}, {__index=methods})
 self.textures=rawget(self,"textures") or {};table.insert(self.textures,texture);return texture
end
function methods:SetColorTexture(r,g,b,a) self.color={r,g,b,a} end
function methods:CreateFontString() local f=setmetatable({}, {__index=methods});self.labels=rawget(self,'labels') or {};table.insert(self.labels,f);self.label=self.labels[1];return f end
function methods:SetText(t) self.text=t end
function methods:SetShown(v) self.shown=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetPoint(_,parent,_,x,y) self.parent,self.x,self.y=parent,x,y end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function() local f=setmetatable({scripts={},events={}},{__index=methods});frames[#frames+1]=f;return f end
local class,target,dead,distance='HUNTER',true,false,20
UnitClass=function() return 'Hunter',class end
UnitExists=function() return target end
UnitCanAttack=function() return true end
UnitIsDead=function() return dead end
Enum={PlayerSwingType={MainHand=0,Ranged=2},SpellBookSpellBank={Player=0}}
C_SwingTimer={IsTargetWithinSwingRange=function(kind) if kind==0 then return distance<=5 end;return distance>=8 and distance<=35 end}
local metadata={{minRange=8,maxRange=35,iconID=123},{minRange=0,maxRange=5},{minRange=0,maxRange=35}}
C_SpellBook={GetNumSpellBookSkillLines=function() return 1 end,
GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=3} end,
GetSpellBookItemInfo=function(slot) return {spellID=9000+slot} end,IsSpellKnown=function() return true end}
C_Spell={GetSpellInfo=function(id) return metadata[id-9000] end,
IsRangedAutoAttackSpell=function(id) return id==9001 end,IsSpellHarmful=function() return true end,
IsSpellInRange=function(id) local s=metadata[id-9000];return distance>=s.minRange and distance<=s.maxRange end}
local db={enabled=true,locked=true}
local moveHint=setmetatable({}, {__index=methods})
function moveHint:SetPoint(_,_,_,_,y) self.y=y end
local f=NS.Range.Create({hint=moveHint},db)
check(f.label.text:find('Shooting',1,true),'discovered auto shot')
distance=6;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('Too close',1,true),'updates without swing events')
distance=50;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('>35 yd',1,true),'far target')
target=false;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not f.scripts.OnUpdate and f.label.text=='No target','no target stops polling')
check(f.alpha==0.2,'no target dims indicator')
db.locked=false;f.Refresh()
check(f.alpha==0.2 and not f.scripts.OnUpdate,'unlock preserves idle dimming without polling')
db.locked=true;f.Refresh()
check(f.alpha==0.2,'locking restores no-target dimming')
target=true;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(f.alpha==0.6,'out of combat target stays partly dimmed')
local combat=false
UnitAffectingCombat=function() return combat end
for _,locked in ipairs({true,false}) do
 db.locked=locked;combat=true;f.scripts.OnEvent(f,'PLAYER_REGEN_DISABLED')
 check(f.alpha==1 and f.scripts.OnUpdate,'combat restores visibility and updates regardless of lock')
 combat=false;f.scripts.OnEvent(f,'PLAYER_REGEN_ENABLED')
 check(f.alpha==0.6 and f.scripts.OnUpdate,'leaving combat dims without stopping target updates')
end
db.locked=true
target=true;dead=true;f.Refresh()
check(not f.scripts.OnUpdate,'dead target stops polling')
dead=false;db.enabled=false;f.Refresh()
check(not f.shown and not f.scripts.OnUpdate,'disabled stops polling')
check(next(f.events)==nil,'disabled unregisters all range events')
local disabledText=f.label.text
f.scripts.OnEvent(f,'SPELLS_CHANGED')
check(f.label.text==disabledText and not f.scripts.OnUpdate,'disabled ignores queued events')
db.enabled=true;f.Refresh()
check(f.shown and f.scripts.OnUpdate,'enable starts polling')
check(f.events.PLAYER_TARGET_CHANGED and f.events.SPELLS_CHANGED,'enable restores events')
f.scripts.OnEvent(f,'PLAYER_LEAVING_WORLD')
check(not f.scripts.OnUpdate,'loading screen stops polling')
class='PALADIN';check(NS.Range.Create({},db)~=nil,'distance utility supports other classes')
-- Spellbook slot checks must work even when native and spell-ID queries fail.
C_SwingTimer.IsTargetWithinSwingRange=function() return nil end
C_Spell.IsSpellInRange=function() error('unavailable') end
C_SpellBook.IsSpellBookItemInRange=function(slot)
    local data=metadata[slot];return distance>=data.minRange and distance<=data.maxRange
end
distance=20
f=NS.Range.Create({hint=moveHint},db)
check(f.label.text:find('Shooting',1,true),'spellbook fallback classifies shooting')
check(f.Status():find('nil/nil',1,true),'diagnostics report missing native checks')
distance=50;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('Too far',1,true),'spellbook fallback classifies far')
-- Regression: a broad spell supplies an upper bound but Auto Shot metadata is absent.
metadata[4]={minRange=0,maxRange=100}
C_SpellBook.GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=4} end
C_Spell.IsRangedAutoAttackSpell=function() return false end
C_SwingTimer.IsTargetWithinSwingRange=function() return false end
distance=50
f=NS.Range.Create({hint=moveHint},db)
check(f.label.text:find('Out of range | ~35-100 yd',1,true),'negative attack check overrides blue bracket')
check(f.textures[2].color[1]==1 and f.textures[2].color[2]==0.15,'out-of-range accent is actually red')
check(f.textures[3].color[1]==1 and f.textures[3].color[2]==0.15,'out-of-range icon border is actually red')
C_SwingTimer.IsTargetWithinSwingRange=function() return nil end
f.Refresh()
check(f.label.text:find('Distance',1,true),'unavailable attack check is not invented as false')
check(f.textures[2].color[1]==0.3 and f.textures[2].color[3]==1,'genuinely unclassified bracket remains blue')
UnitDistanceSquared=function() return distance*distance,true end
distance=23.4;f.Refresh()
check(f.label.text:find('23.4 yd',1,true),'live decimal distance displayed')
distance=24.7;f.scripts.OnUpdate(f,0.15)
check(f.label.text:find('24.7 yd',1,true),'decimal updates as target moves')
UnitDistanceSquared=function() return 0,false end
f.scripts.OnUpdate(f,0.15)
check(not f.label.text:find('24.7 yd',1,true),'lost distance availability clears stale numeric value')
UnitCanAttack=function() return false end
UnitDistanceSquared=function() return 144,true end
f.Refresh()
check(f.label.text=='Distance | 12.0 yd','friendly target numeric distance supported')
UnitIsFriend=function() return true end
UnitDistanceSquared=function() return 0,false end
f.Refresh()
check(f.label.text=='Friendly target','friendly target omits unavailable wording')
check(f.textures[2].color[1]==0.8,'friendly unavailable remains neutral gray')
UnitIsFriend=function() return secret end
f.Refresh()
check(f.label.text=='Range unavailable','restricted friendliness does not invent friendly status')
UnitCanAttack=function() return true end
UnitDistanceSquared=nil
class='HUNTER';C_Spell=nil;C_SpellBook=nil
f=NS.Range.Create({hint=moveHint},db)
check(f.label.text:find('Range unavailable',1,true),'missing APIs degrade safely')
-- Portrait and numeric angle share the module lifecycle.
UnitExists=function() return target end
GetPlayerFacing=function() return 0 end
UnitPosition=function(unit) if unit=='player' then return 0,0,0,1 end return 0,10,0,1 end
local portraits=0
SetPortraitTexture=function(texture,unit) portraits=portraits+1;texture.unit=unit end
target=true;dead=false;f.Refresh()
local portrait=f.portrait
check(portrait.unit=='targettarget' and portrait.shown,'right icon uses targettarget portrait')
check(f.labels[2].text=='+90°','angle has no wording')
local before=portraits;f.scripts.OnEvent(f,'UNIT_TARGET','target')
check(portraits>before,'targettarget change refreshes portrait')
before=portraits;f.scripts.OnEvent(f,'UNIT_PORTRAIT_UPDATE','targettarget')
check(portraits>before,'portrait event refreshes icon')
UnitExists=function(unit) return unit=='target' end
f.Refresh();check(not portrait.shown,'missing targettarget hides portrait')
UnitExists=function() return true end
SetPortraitTexture=function() error('unavailable') end
f.Refresh();check(not portrait.shown,'failed portrait API clears stale portrait')
UnitPosition=nil;f.scripts.OnUpdate(f,0.15)
check(f.labels[2].text=='','unavailable angle has no wording')
UnitExists=function() return false end;f.Refresh()
check(not portrait.shown and f.labels[2].text=='','target loss clears context')
local queries=0
SetPortraitTexture=function() queries=queries+1 end
GetPlayerFacing=function() queries=queries+1;return 0 end
UnitExists=function() return true end
db.showTargetTarget=false;db.showAngle=false;f.Refresh();f.scripts.OnUpdate(f,0.15)
check(queries==0,'disabled context does not query APIs')
db.enabled=false;f.Refresh()
check(not f.events.UNIT_TARGET and not f.events.UNIT_PORTRAIT_UPDATE and not f.scripts.OnUpdate,'disable removes context listeners')
db.enabled=true;UnitExists=function() return false end
GetInventorySlotInfo=function() return 0 end
GetInventoryItemID=function() return 123 end
local warnings={}
UIErrorsFrame={AddMessage=function(_,message) table.insert(warnings,message) end}
local ammo=500
C_Item={GetItemCount=function() return ammo end}
f.Refresh()
check(f.labels[3].text=='Ammo: 500' and not f.scripts.OnUpdate,'ammo visible without target or polling')
ammo=499;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
check(f.labels[3].text=='Ammo: 499','bag event refreshes ammo')
ammo=200;f.scripts.OnEvent(f,'UNIT_INVENTORY_CHANGED','player')
check(f.labels[3].text=='Ammo: 200','equipped ammo change refreshes count')
check(#warnings==1 and warnings[1]:find('200 remaining',1,true),'warning at exactly 200')
ammo=199;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED');f.Refresh()
check(#warnings==1,'no repeated warning per shot or refresh')
ammo=nil;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
ammo=198;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
check(#warnings==1,'unavailable readings do not rearm warning')
ammo=201;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
ammo=190;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
check(#warnings==2,'restock above threshold rearms warning')
ammo=0;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
check(#warnings==2,'zero does not spam existing low warning')
C_Item.GetItemCount=function() return nil end;f.scripts.OnEvent(f,'BAG_UPDATE_DELAYED')
check(f.labels[3].text=='','unavailable count clears stale value')
db.enabled=false;f.Refresh()
check(not f.events.BAG_UPDATE_DELAYED and not f.events.UNIT_INVENTORY_CHANGED,'disabled removes ammo events')
db.enabled=true;db.showTargetTarget=true;UnitExists=function() return true end
UnitIsDead=function() return false end
SetPortraitTexture=function() end
UnitIsUnit=function(unit,other) return unit=='targettarget' and other=='pet' end
local petHealth=30
UnitHealth=function() return petHealth end
UnitHealthMax=function() return 100 end
f.Refresh()
local glow=f.petHighlight
check(glow.shown,'low pet portrait highlighted')
petHealth=31;f.scripts.OnEvent(f,'UNIT_HEALTH','pet')
check(not glow.shown,'healing removes highlight immediately')
petHealth=20;f.scripts.OnEvent(f,'UNIT_HEALTH','pet')
check(glow.shown,'damage restores highlight')
UnitIsUnit=function() return false end;f.scripts.OnEvent(f,'UNIT_TARGET','target')
check(not glow.shown,'target switch clears old pet highlight')
UnitExists=function() return false end;f.Refresh()
check(not glow.shown,'target loss clears highlight')
db.enabled=false;f.Refresh()
check(not f.events.UNIT_HEALTH and not f.events.UNIT_MAXHEALTH and not f.events.UNIT_PET,'disabled removes pet events')
db.enabled=true;UnitExists=function() return true end;UnitCanAttack=function() return true end
C_SpellBook={GetNumSpellBookSkillLines=function() return 1 end,
 GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=1} end,
 GetSpellBookItemInfo=function() return {spellID=123456} end,IsSpellKnown=function() return true end}
C_Spell={GetSpellInfo=function() return {name="Hunter's Mark",minRange=0,maxRange=100} end}
local marked=false
C_UnitAuras={GetAuraDataByIndex=function(_,i) if marked and i==1 then return {name="Hunter's Mark"} end end}
f.scripts.OnEvent(f,'SPELLS_CHANGED')
check(not f.markIcon.shown,'mark reminder stays hidden outside combat')
combat=true;f.scripts.OnEvent(f,'PLAYER_REGEN_DISABLED')
check(f.markIcon.shown,'missing learned mark shows compact warning')
marked=true;f.scripts.OnEvent(f,'UNIT_AURA','target')
check(not f.markIcon.shown,'applying mark immediately clears warning')
marked=false;f.scripts.OnEvent(f,'UNIT_AURA','target')
check(f.markIcon.shown,'expired mark restores reminder')
combat=false;f.scripts.OnEvent(f,'PLAYER_REGEN_ENABLED')
check(not f.markIcon.shown,'leaving combat clears reminder immediately')
combat=true;f.scripts.OnEvent(f,'PLAYER_REGEN_DISABLED')
UnitExists=function() return false end;f.Refresh()
check(not f.markIcon.shown,'target loss clears mark reminder')
db.enabled=false;f.Refresh();check(not f.events.UNIT_AURA,'disable removes aura listener')
db.enabled=true;UnitExists=function() return true end
f.Refresh();check(f.markIcon.shown,'missing mark icon visible')
db.markWarning=false;f.Refresh();check(not f.markIcon.shown,'mark icon toggle hides reminder')
db.showAmmo=false;db.lowAmmoWarning=false;f.Refresh()
check(not f.labels[3].shown and f.labels[3].text=='','ammo display and warning can both be disabled')
db.showRange=false;f.Refresh();check(not f.label.shown and f.Status():find('Range display disabled',1,true),'range feature disabled independently')
db.fadeOutOfCombat=false;f.Refresh();check(f.alpha==1,'fading can be disabled')
UnitIsUnit=function(unit,other) return unit=='targettarget' and other=='pet' end
UnitHealth=function() return 10 end;UnitHealthMax=function() return 100 end
db.petMendWarning=false;f.Refresh();check(not glow.shown and portrait.shown,'pet warning off keeps portrait')
db.aspectWarning=true;combat=true;UnitIsDead=function() return false end
C_Spell.GetSpellInfo=function() return {name='Aspect of the Hawk',iconID=987} end
local aspect=false
C_UnitAuras.GetAuraDataByIndex=function(unit,i)
 if unit=='player' and aspect and i==1 then return {name='Aspect of the Hawk'} end
end
UnitExists=function() return false end
f.scripts.OnEvent(f,'SPELLS_CHANGED')
check(f.aspectIcon.shown and not f.scripts.OnUpdate,'aspect warns in combat without target and without idle polling')
aspect=true;f.scripts.OnEvent(f,'UNIT_AURA','player');check(not f.aspectIcon.shown,'player aura immediately clears aspect warning')
aspect=false;f.scripts.OnEvent(f,'UNIT_AURA','player');check(f.aspectIcon.shown,'removed aspect restores warning')
combat=false;f.scripts.OnEvent(f,'PLAYER_REGEN_ENABLED');check(not f.aspectIcon.shown,'combat end clears aspect warning')
combat=true;db.aspectWarning=false;f.Refresh();check(not f.aspectIcon.shown,'aspect toggle disables warning')
db.petHappinessWarning=true;db.showTargetTarget=false;combat=false
UnitExists=function(unit) return unit=='pet' end;UnitIsDead=function() return false end
local happiness=1;C_PetInfo={GetPetHappiness=function() return happiness end}
f.Refresh()
check(f.moodBadge.shown and not f.scripts.OnUpdate,'mood warns without target or idle polling')
happiness=2;f.scripts.OnEvent(f,'UNIT_HAPPINESS','pet')
check(f.moodBadge.shown,'content still warns')
happiness=3;f.scripts.OnEvent(f,'UNIT_HAPPINESS','pet')
check(not f.moodBadge.shown,'happy pet immediately clears badge')
happiness=1;f.scripts.OnEvent(f,'UNIT_HAPPINESS','pet')
check(f.moodBadge.shown,'mood change shows warning again')
UnitExists=function() return false end;f.scripts.OnEvent(f,'UNIT_PET','player')
check(not f.moodBadge.shown,'pet dismissal clears warning')
UnitExists=function(unit) return unit=='pet' end;db.petHappinessWarning=false;f.Refresh()
check(not f.moodBadge.shown,'mood warning toggle independent of portrait')
db.enabled=false;f.Refresh();check(not f.events.UNIT_HAPPINESS,'disable removes happiness listener')
-- Pet guide uses the same lifecycle and leaves existing pet care independent.
db.enabled=true;db.petGuide=true;db.showRange=false;db.showTargetTarget=false;db.fadeOutOfCombat=true
db.petHappinessWarning=true;happiness=1
local hasBeast=true
UnitExists=function(unit) return unit=='pet' or (unit=='target' and hasBeast) end
UnitIsPlayer=function() return false end;UnitPlayerControlled=function() return false end
UnitCreatureFamily=function() return 'Wolf',1 end
UnitCreatureID=function() return 1132 end
UnitName=function() return 'Timber' end;UnitClassification=function() return 'rare' end
UnitLevel=function() return 10 end
f.Refresh()
check(f.petGuideBadge.shown and f.moodBadge.shown and not portrait.shown,'guide and mood coexist independently of range and portrait')
check(f.petGuideBadge.info.notable.name=='Timber','target produces exact watch-list match')
check(f.petGuideBadge.hintPanel.shown and f.petGuideBadge.hintTitle.text:find('Furious Howl',1,true),'matching target shows family ability without hovering')
check(f.petGuideBadge.hintTitle.text:find('Rare',1,true),'inline intel shows live rare status')
UnitCreatureFamily=function() return 'Hyena',25 end
UnitCreatureID=function() return 4127 end;UnitName=function() return 'Hecklefang Hyena' end
UnitClassification=function() return 'normal' end;UnitLevel=function(unit) return unit=='player' and 17 or 16 end
f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(f.petGuideBadge.hintPanel.shown and f.petGuideBadge.hintTitle.text=='Hyena: Tendon Rip','screenshot target displays automatic hyena hint')
check(f.petGuideBadge.hintTitle.shown,'recommendation text itself is explicitly visible')
local intel=f.petGuideBadge.hintTitle
check(intel.parent==f and intel.y==-23 and intel.height==16,'intel draws directly inside bar')
check(f.labels[1].y==-3 and f.labels[1].height==20 and f.labels[3].y==-39,'range and ammo leave space for recommendation')
check(-f.labels[3].y+f.labels[3].height<=56,'ammo remains inside original bar height')
check(f.Status():find('Pet guide: inline — Hyena: Tendon Rip',1,true),'status reports loaded inline recommendation')
for _,locked in ipairs({true,false}) do
 db.locked=locked;f.Refresh()
 check(intel.shown and f.alpha==0.6,'locked and movable modes both keep inline intel and fading')
end
combat=true;f.scripts.OnEvent(f,'PLAYER_REGEN_DISABLED')
check(intel.shown and f.alpha==1,'inline intel remains visible in combat')
combat=false;f.scripts.OnEvent(f,'PLAYER_REGEN_ENABLED')
UnitCreatureFamily=function() return 'Wolf',1 end
UnitCreatureID=function() return 1132 end;UnitName=function() return 'Timber' end
f.Refresh()
GameTooltip={SetOwner=function(self,owner) self.owner=owner end,
 IsOwned=function(self,owner) return self.owner==owner end,
 SetText=function(self,text) self.text=text;self.lines={} end,
 AddLine=function(self,line) table.insert(self.lines,line) end,
 Show=function(self) self.shown=true end,Hide=function(self) self.shown=false end}
f.petGuideBadge.scripts.OnEnter()
check(GameTooltip.shown and GameTooltip.text:find('Timber',1,true),'hover shows target pet guide')
UnitCreatureID=function() return 999999 end;UnitName=function() return 'Forest Spider' end
UnitCreatureFamily=function() return 'Spider',3 end;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not f.petGuideBadge.info.notable and GameTooltip.text:find('Forest Spider',1,true),'target swap updates hovered tooltip without stale named pet')
check(table.concat(GameTooltip.lines,' '):find('Web',1,true),'family guide includes signature ability')
check(f.petGuideBadge.hintTitle.text=='Spider: Web','automatic hint changes with target')
f.petGuideBadge.scripts.OnLeave()
f.petGuideBadge.hintPanel.scripts.OnEnter()
check(GameTooltip.shown and GameTooltip.owner==f.petGuideBadge.hintPanel,'automatic hint itself can be hovered for full guide')
-- Recommendations remain visible even when the range readout is a friendly target.
db.showRange=true
UnitCanAttack=function() return false end;UnitIsFriend=function() return true end
UnitPlayerControlled=function() return true end
UnitCreatureFamily=function() return 'Cat',2 end
UnitCreatureID=function() return 5807 end;UnitName=function() return 'A hunter pet' end
UnitLevel=function(unit) return unit=='player' and 17 or 60 end
UnitDistanceSquared=function() return nil,false end
f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(f.label.text=='Friendly target' and intel.shown and intel.text=='Cat: Claw / Prowl','friendly pet has range text and inline recommendation together')
check(f.petGuideBadge.info.owned and not f.petGuideBadge.info.notable and not f.petGuideBadge.info.tooHigh,'friendly pet suppresses wild NPC and tame-level claims')
check(table.concat(GameTooltip.lines,' '):find('Player-controlled pet',1,true),'hovered guide changes to owned pet details')
UnitName=function() return 'My pet' end
UnitIsUnit=function(unit,other) return unit=='target' and other=='pet' end
f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(intel.shown and f.petGuideBadge.info.owned,'own pet is also eligible')
UnitIsPlayer=function() return true end;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not intel.shown and not GameTooltip.shown,'switching from pet to player clears guide')
UnitIsPlayer=function() return false end;UnitPlayerControlled=function() return false end
UnitCanAttack=function() return true end;UnitIsFriend=function() return false end
UnitCreatureFamily=function() return 'Humanoid',0 end;f.scripts.OnUpdate(f,0.15)
check(not f.petGuideBadge.shown and not GameTooltip.shown,'nonmatching target clears badge and tooltip')
check(not f.petGuideBadge.hintPanel.shown and f.petGuideBadge.hintTitle.text=='','nonmatch clears inline intel text')
check(not intel.shown and f.labels[1].height==26 and f.labels[3].y==-33,'nonmatch restores original text layout')
UnitCreatureFamily=function() return 'Wolf',1 end;f.Refresh()
f.petGuideBadge.scripts.OnEnter()
db.petGuide=false;f.Refresh()
check(not f.petGuideBadge.hintPanel.shown and not f.petGuideBadge.shown and not GameTooltip.shown and f.moodBadge.shown,'guide toggle clears tooltip but keeps happiness warning')
db.petGuide=true;f.Refresh();f.petGuideBadge.scripts.OnEnter()
hasBeast=false;f.scripts.OnEvent(f,'PLAYER_TARGET_CHANGED')
check(not f.petGuideBadge.hintPanel.shown and not f.petGuideBadge.shown and not GameTooltip.shown and not f.scripts.OnUpdate,'target loss clears guide and stops polling')
hasBeast=true;f.Refresh();f.petGuideBadge.scripts.OnEnter()
UnitIsDead=function(unit) return unit=='target' end;f.scripts.OnUpdate(f,0.15)
check(not f.petGuideBadge.hintPanel.shown and not f.petGuideBadge.shown and not GameTooltip.shown and not f.scripts.OnUpdate,'dead target clears guide and tooltip')
UnitIsDead=function() return false end;f.Refresh();f.petGuideBadge.scripts.OnEnter()
f.scripts.OnEvent(f,'PLAYER_LEAVING_WORLD')
check(not f.petGuideBadge.hintPanel.shown and not f.petGuideBadge.shown and not GameTooltip.shown and not f.scripts.OnUpdate,'leaving world clears guide')
f.Refresh();f.petGuideBadge.scripts.OnEnter();db.enabled=false;f.Refresh()
check(not f.petGuideBadge.hintPanel.shown and not f.petGuideBadge.shown and not GameTooltip.shown and not next(f.events),'disable clears guide and all event listeners')
print('PASS: '..count..' distance checks')
