local NS={}
local root='addons/ForeverUtilities/'
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'LevelingBuffs.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local level,combat,dead=59,false,false
local auras={};local reads=0
UnitLevel=function(unit) assert(unit=='player');return level end
UnitIsDead=function() return dead end
UnitAffectingCombat=function() return combat end
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)
    assert(unit=='player' and filter=='HELPFUL');reads=reads+1;return auras[index]
end}
local Buffs=NS.LevelingBuffs
check(Buffs.Missing(59,true,false)==true,'level 59 with readable absence needs a reminder')
check(Buffs.Missing(1,true,false)==true,'level 1 is below 60; ownership of a personal bag is not required')
reads=0
for _,value in ipairs({60,61,0,-1,secret,0/0,math.huge}) do
    check(Buffs.Missing(value,true,false)==nil,'ineligible or unreadable level cannot warn')
end
check(reads==0,'level 60 and above do not scan auras')
auras={{spellId=429959,name=secret,applications=1}}
check(Buffs.Missing(59,true,false)==false,'one stack with a restricted name still clears the reminder by readable ID')
auras={{spellId=429959,name='酣睡',applications=3}}
check(Buffs.Missing(59,true,false)==false,'localized active sleeping-bag buff clears the reminder')
auras={{spellId=1225478,name='Well Rested'}}
check(Buffs.Missing(59,true,false)==true,'Legacy rested perk does not satisfy the sleeping-bag buff')
auras={{spellId=secret,name='Well-Rested'}}
check(Buffs.Missing(59,true,false)==nil,'restricted IDs do not imply absence from a name')
auras={secret};check(Buffs.Missing(59,true,false)==nil,'restricted aura object is unknown')
auras={};combat=true;reads=0
check(Buffs.Missing(59,true,false)==nil and reads==0,'combat suppresses the out-of-combat reminder without scanning')
combat=false;dead=true
check(Buffs.Missing(59,true,false)==nil and reads==0,'dead player does not warn or scan')
dead=false
local scan=C_UnitAuras.GetAuraDataByIndex
C_UnitAuras.GetAuraDataByIndex=function() error('restricted') end
check(Buffs.Missing(59,true,false)==nil,'failed scan never becomes missing')
C_UnitAuras.GetAuraDataByIndex=nil
check(Buffs.Missing(59,true,false)==nil,'missing aura API stays quiet')
C_UnitAuras.GetAuraDataByIndex=scan

-- Food and sleeping bag share one scan, but their confirmed states are independent.
local metadataReads=0
C_Spell={GetSpellInfo=function(id)
    assert(type(id)=='number','food discovery must not query an English spell name')
    metadataReads=metadataReads+1;return {name='Bien nourri'}
end}
GetLocale=function() return 'frFR' end
auras={};local missingBag,missingFood=Buffs.Missing(59,true,true)
check(missingBag==true and missingFood==true,'readable empty aura list confirms both absent')
for _,id in ipairs({1243969,1248406,1248420,1248421}) do
    auras={{spellId=id,name=secret}}
    missingBag,missingFood=Buffs.Missing(59,true,true)
    check(missingBag==true and missingFood==false,'known XP/Well Fed ID clears food reminder with a secret name')
end
auras={{spellId=987654,name='Bien nourri'}}
missingBag,missingFood=Buffs.Missing(59,true,true)
check(missingBag==true and missingFood==false,'client-resolved localized Well Fed recognizes other food ranks')
auras={{spellId=19706,name='Well Fed'}}
check(select(2,Buffs.Missing(59,true,true))==false,'visible Well Fed clears the food reminder without claiming a measured XP bonus')
auras={{spellId=987654,name='进食充分'}}
check(select(2,Buffs.Missing(59,true,true))==false,'Chinese food family works without English-name lookup')
auras={{spellId=433,name='Food'}}
check(select(2,Buffs.Missing(59,true,true))==true,'eating health regeneration is not already Well Fed')
auras={{spellId=429959,name='Well-Rested'}}
check(select(2,Buffs.Missing(59,true,true))==true,'sleeping bag does not satisfy the food reminder')
auras={{spellId=777,name=secret}}
missingBag,missingFood=Buffs.Missing(59,true,true)
check(missingBag==true and missingFood==nil,'unclassified aura name prevents a false missing-food warning')
auras={secret}
missingBag,missingFood=Buffs.Missing(59,true,true)
check(missingBag==nil and missingFood==nil,'restricted aura object makes both unknown')
reads=0;metadataReads=0
Buffs.Missing(59,false,false)
check(reads==0 and metadataReads==0,'both disabled features perform no aura or metadata reads')
for _,value in ipairs({60,61,secret,0/0}) do
    missingBag,missingFood=Buffs.Missing(value,true,true)
    check(missingBag==nil and missingFood==nil,'food and bag both obey the strict level limit')
end
combat=true;Buffs.Missing(59,true,true)
check(reads==0,'food and bag both skip combat aura reads')
combat=false;auras={}

-- Metadata gaps on another client must not become false absence claims.
local previousSpellInfo=C_Spell.GetSpellInfo
C_Spell.GetSpellInfo=function(id) assert(type(id)=='number');return nil end
local limited={Core=NS.Core}
assert(loadfile(root..'LevelingBuffs.lua'))('ForeverUtilities',limited)
GetLocale=function() return 'zhCN' end
auras={{spellId=987654,name='进食充分'}}
check(select(2,limited.LevelingBuffs.Missing(59,false,true))==false,'Chinese food names remain recognized when metadata is unavailable')
GetLocale=function() return 'deDE' end
auras={{spellId=987654,name='Satt'}}
check(select(2,limited.LevelingBuffs.Missing(59,false,true))==nil,'unresolved foreign food family stays unknown rather than missing')
auras={}
check(select(2,limited.LevelingBuffs.Missing(59,false,true))==true,'empty readable scan confirms absence even without localized metadata')
C_Spell.GetSpellInfo=previousSpellInfo

local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:HookScript(event,fn)
    local previous=self.scripts[event]
    self.scripts[event]=function(...) if previous then previous(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateTexture() return object() end
function methods:CreateFontString() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetPoint(point,relative,relativePoint,x,y) self.point,self.x,self.y=point,x,y;self.relative,self.relativePoint=relative,relativePoint end
function methods:SetAlpha(value) self.alpha=value end
function methods:IsShown() return self.shown end
function methods:IsVisible() return self.shown end
function methods:SetShown(value)
    if self.shown==value then return end
    self.shown=value
    local handler=self.scripts[value and 'OnShow' or 'OnHide']
    if handler then handler(self) end
end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
setmetatable(methods,{__index=function() return function() end end})
dofile('tests/mock_animation.lua')(methods)
CreateFrame=function() return object() end
UIParent=object()
local db={enabled=true,locked=true,x=0,y=0,scale=1,sleepingBagReminder=true,foodXPReminder=false,flashMissingBuffs=true}
local content,host
local module={command='/fclassmate',Apply=function() end}
local instance=NS.ClassHost.Create(module,db,function(owner)
    host=owner;content=object()
    content.Refresh=function() NS.ClassHost.SetFade(host,content,0.2) end
    content.Status=function() return 'test' end
    return content
end)
instance.Apply()
local service=instance.levelingBuffs
local bag,food=service.indicators.sleepingBag,service.indicators.food
local function Event(event,arg) service.controller.scripts.OnEvent(service.controller,event,arg) end
check(bag and bag.button.shown and host.levelingBuffMissing and content.alpha==1,'shared host displays the reminder at full opacity')
check(host.width==426 and host.height==56 and bag.button.point=='TOPRIGHT','sleeping-bag reminder does not resize the full bar')
check(bag.border.warningPulseGroup.playing,'missing sleeping-bag buff uses the saved flash preference')
check(not bag.button.scripts.OnUpdate and not content.scripts.OnUpdate,'sleeping-bag checks add no polling')
NS.ClassHost.SetFade(host,content,0.6)
check(content.alpha==1,'class refresh cannot dim an active sleeping-bag warning')
auras={{spellId=429959}}
Event('UNIT_AURA','player')
check(not bag.button.shown and not host.levelingBuffMissing and content.alpha==0.6
    and not bag.border.warningPulseGroup.playing,'buff return stops warning and restores normal fade')
auras={};Event('UNIT_AURA','player')
reads=0;Event('UNIT_AURA','target')
check(reads==0,'non-player aura changes do not scan the player')
combat=true;Event('PLAYER_REGEN_DISABLED')
check(not bag.button.shown and not host.levelingBuffMissing,'combat immediately hides the reminder')
combat=false;Event('PLAYER_REGEN_ENABLED')
check(bag.button.shown,'leaving combat rechecks the current buff state')
auras={{spellId=secret}};service.Refresh()
check(not bag.button.shown and not host.levelingBuffMissing,'unreadable aura state clears a prior warning')
auras={};db.flashMissingBuffs=false;service.Refresh()
check(bag.button.shown and not bag.border.warningPulseGroup.playing,'static sleeping-bag warning respects the flash toggle')
db.rangeIconOnly=true;service.Refresh()
check(bag.button.point=='TOPLEFT' and host.width==426,'compact-mode reminder uses a separate icon beside the range widget')
Event('PLAYER_LEAVING_WORLD')
Event('UNIT_AURA','player')
check(not bag.button.shown,'world leave suspends the reminder across later events')
Event('PLAYER_ENTERING_WORLD')
check(bag.button.shown,'entering the world resumes fresh buff checks')
Event('PLAYER_DEAD')
check(not bag.button.shown,'death clears the reminder')
Event('PLAYER_ALIVE')
check(bag.button.shown,'resurrection rechecks rather than assuming a missing buff')
host:Hide();Event('UNIT_AURA','player')
check(not bag.button.shown and not host.levelingBuffMissing,'events cannot revive a reminder on a hidden bar')
host:Show();check(bag.button.shown,'showing the host refreshes the reminder')
-- Each reminder can be enabled independently, and either one keeps the bar bright.
db.rangeIconOnly=false;db.foodXPReminder=true;auras={};service.Refresh()
check(bag.button.shown and food.button.shown and bag.button.y==1 and food.button.y==-41,
    'both reminders fit around the lock without increasing the bar size')
check(food.button.x==-8 and bag.button.x==-8 and host.width==426 and host.height==56,
    'food and bag share the right edge of the unchanged bar')
db.flashMissingBuffs=true;service.Refresh()
check(food.border.warningPulseGroup.playing and bag.border.warningPulseGroup.playing,'both use the shared flash preference')
auras={{spellId=429959,name='Well-Rested'}};service.Refresh()
check(not bag.button.shown and food.button.shown and content.alpha==1,'food alone keeps the bar bright after sleeping')
NS.ClassHost.SetFade(host,content,0.2)
host.scripts.OnEnter(host);host.scripts.OnLeave(host)
check(content.alpha==1,'hover exit and class fading cannot dim an active food reminder')
auras={{spellId=1248421,name=secret}};service.Refresh()
check(bag.button.shown and not food.button.shown and content.alpha==1,'bag alone keeps the bar bright after eating')
auras={{spellId=429959,name='Well-Rested'},{spellId=1248420,name='Well Fed'}};service.Refresh()
check(not bag.button.shown and not food.button.shown and content.alpha==0.2,'both buffs restore the normal saved fade')
auras={};db.sleepingBagReminder=false;service.Refresh()
check(not bag.button.shown and food.button.shown and next(service.controller.events),'food remains enabled without sleeping bag tracking')
db.foodXPReminder=false;reads=0;service.Refresh()
check(not bag.button.shown and not food.button.shown and not next(service.controller.events) and reads==0,
    'turning off both features removes listeners and all aura queries')
db.foodXPReminder=true;service.Refresh()
check(food.button.shown and not bag.button.shown,'food-only tracking can be reenabled')
db.rangeIconOnly=true;service.Refresh()
check(food.button.point=='TOPLEFT' and food.button.x==3 and food.button.y==-20,'compact food icon stays below the separate bag position')
combat=true;Event('PLAYER_REGEN_DISABLED')
check(not food.button.shown and not host.levelingBuffMissing and not food.border.warningPulseGroup.playing,'combat clears the food warning and its pulse')
combat=false;Event('PLAYER_REGEN_ENABLED')
check(food.button.shown,'combat exit rechecks food from current auras')
Event('PLAYER_LEAVING_WORLD');Event('UNIT_AURA','player');service.Refresh()
check(not food.button.shown,'settings and queued events cannot revive food tracking outside the world')
Event('PLAYER_ENTERING_WORLD');check(food.button.shown,'world return rechecks food')
Event('PLAYER_DEAD');check(not food.button.shown,'death clears food reminder')
Event('PLAYER_ALIVE');check(food.button.shown,'resurrection rechecks food')
db.enabled=false;service.Refresh()
check(not food.button.shown and not next(service.controller.events),'disabling the class removes both features')
db.enabled=true;db.sleepingBagReminder=true;service.Refresh()
reads=0;Event('PLAYER_LEVEL_UP',60)
check(not bag.button.shown and not food.button.shown and not host.levelingBuffMissing
    and not next(service.controller.events) and reads==0,
    'level 60 payload clears both reminders before UnitLevel catches up')
Event('UNIT_AURA','player');service.Refresh()
check(not next(service.controller.events) and reads==0,'queued events cannot reenable tracking from a stale pre-level-up UnitLevel result')
level=60;service.Refresh();check(not bag.button.shown and not food.button.shown,'level 60 stays excluded')
print('PASS: '..count..' leveling-buff reminder checks')

-- Folding hides the visual container, while the existing updater stays live.
function methods:SetText(value) self.text=value end
function methods:SetTexture(value) self.texture=value end
function methods:GetScript(event) return self.scripts[event] end
function methods:SetBackdrop(value) self.backdrop=value end
function methods:SetBackdropColor(...) self.backdropColor={...} end
function methods:SetParent(parent) self.parent=parent end
assert(loadfile(root..'Folded.lua'))('ForeverUtilities',NS)
level=59;dead=false;combat=false;auras={}
local foldedDB={enabled=true,locked=true,x=0,y=0,scale=1,collapsed=true,flashMissingBuffs=true}
local foldHost,foldContent
local foldModule={command='/ftest'}
local foldInstance=NS.ClassHost.Create(foldModule,foldedDB,function(owner)
    foldHost=owner;foldContent=object()
    foldContent.Refresh=function() NS.ClassHost.SetFade(owner,foldContent,0.2) end
    foldContent.Status=function() return 'test' end
    return foldContent
end)
foldModule.Apply=foldInstance.Apply;foldInstance.Apply()
local summary=foldInstance.folded
check(foldHost.width==64 and foldHost.height==88 and not foldInstance.visual.shown and summary.button.shown,'collapsed host is a large icon with hidden full-bar controls')
check(summary.main.width==64 and summary.main.height==64 and summary.button.height==88 and summary.row.y==0 and summary.row.height==24 and summary.row.relative==summary.main and summary.row.relativePoint=='BOTTOMLEFT',
    'secondary warnings occupy a connected lower section outside the complete main artwork')
local badges=foldInstance.levelingBuffs.indicators
check(not badges.food.button.shown and not badges.sleepingBag.button.shown,
    'folded mode suppresses the old floating corner controls')
check(summary.primary.texture==foldHost.foldLevelWarnings.food.icon and summary.badges[1].texture==foldHost.foldLevelWarnings.sleepingBag.icon,
    'main warning is large native food art, with sleeping bag in the secondary row')
check(summary.border==foldHost.outline and foldInstance.shell.width==72 and foldInstance.shell.height==96,
    'compact components share one padded image-based container and outline')
check(foldInstance.shell.backdrop.bgFile and summary.border.backdrop.edgeFile and foldHost.relative==foldInstance.shell and foldHost.x==4,
    'one image-based shell owns frame artwork and contains the inset logical host')
check(foldHost.hint.text=='','collapsed drag instructions stay on hover')
NS.ClassHost.SetWarning(foldHost,'upkeep',true,777,'Armor missing')
check(summary.primary.texture==777 and summary.badges[2].shown and summary.badges[1].width==20
    and summary.badges[2].x-summary.badges[1].x==22,'armor takes primary position with food and sleeping warnings grouped below')
NS.ClassHost.SetWarning(foldHost,'upkeep',false,nil,'Armor missing')
check(summary.primary.texture==foldHost.foldLevelWarnings.food.icon and not summary.badges[2].shown,'cleared armor immediately restores the next real warning')
auras={{spellId=429959,name='Well-Rested'},{spellId=1248420,name='Well Fed'}}
foldInstance.levelingBuffs.Refresh()
check(not summary.row.shown and foldHost.height==88 and summary.main.height==64, 'unused lower section hides inside the same stable container')
foldInstance.shell.IsMouseOver=function() return true end
foldHost.scripts.OnUpdate(foldHost,0.2)
check(foldHost.hovered and summary.button.alpha==1,'hovering the container padding reveals its components')
foldInstance.shell.IsMouseOver=function() return false end
foldHost.scripts.OnUpdate(foldHost,0.2)
check(not foldHost.hovered and summary.button.alpha==0.35,'leaving the container restores idle icon fade')
auras={};foldInstance.levelingBuffs.Refresh()
check(summary.row:GetScript('OnClick')==summary.button:GetScript('OnClick'),'the separated warning row keeps the same expand action')
local ticks=0
foldContent:SetScript('OnUpdate',function() ticks=ticks+1 end)
foldHost.scripts.OnUpdate(foldHost,0.3)
check(ticks==1,'host forwards the existing updater while visuals are folded')
foldContent:Hide();foldHost.scripts.OnUpdate(foldHost,0.3)
check(ticks==1,'suspended hidden content does not get revived by collapsed forwarding')
foldContent:Show();foldedDB.flashMissingBuffs=false;foldInstance.Apply()
check(not summary.border.warningPulseGroup.playing and summary.button.alpha==1,'static collapsed warnings respect flash toggle')
summary.button.scripts.OnClick()
check(summary.fold.relative==foldInstance.shell and summary.fold.x==-5,'collapse control belongs to the internal container rail')
check(foldInstance.shell.width==450 and foldInstance.shell.height==64,'expanded container reserves padding and an internal control rail')
check(not foldedDB.collapsed and foldHost.width==426 and foldInstance.visual.shown and not summary.button.shown,
    'click expands to the original bar size')
summary.fold.scripts.OnClick()
check(foldedDB.collapsed and foldHost.width==64,'fold control collapses the expanded bar')
foldedDB.enabled=false;foldInstance.Apply()
check(not summary.button.shown and not summary.border.warningPulseGroup.playing,'disable clears collapsed presentation and animation')
print('PASS: folded layout, warning, lifecycle and update regressions')
