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
function methods:RegisterUnitEvent(event,unit) self.events[event]=unit end
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
check(host.width==426 and host.height==56 and bag.button.point=='BOTTOMRIGHT' and bag.button.relativePoint=='TOPRIGHT'
    and bag.button.x==0 and bag.button.y==10 and bag.button.width==22,
    'the sleeping-bag reminder sits in a tab above the bar without resizing it')
check(bag.border.halo and bag.border.halo.shown and bag.icon.width==16,
    'the reminder uses the amber cell with an ember halo and a 16px icon')
check(bag.border.warningPulseGroup.playing,'missing sleeping-bag buff uses the saved flash preference')
check(not bag.button.scripts.OnUpdate and not content.scripts.OnUpdate,'sleeping-bag checks add no polling')
check(service.controller.events.UNIT_AURA=='player','aura updates are registered for the player unit only')
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
check(bag.button.shown and food.button.shown and bag.button.y==10 and food.button.y==10,
    'both reminders share one row in the tab above the bar')
check(bag.button.x==0 and food.button.x==-26 and host.width==426 and host.height==56,
    'the tab packs from the right edge with a four-pixel gap, leaving the bar size unchanged')
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
function methods:SetBackdropBorderColor(...) self.backdropBorderColor={...} end
function methods:SetParent(parent) self.parent=parent end
function methods:SetAllPoints(relative) self.allPoints=relative or self.parent end
function methods:SetClampedToScreen(value) self.clamped=value end
function methods:SetMovable(value) self.movable=value end
function methods:SetDontSavePosition(value) self.dontSavePosition=value end
-- Forever 1.60 throws "Frame is not movable or resizable" here (live 0.31.7 error).
function methods:SetUserPlaced(value)
    if not rawget(self,'movable') and not rawget(self,'resizable') then error('Frame:SetUserPlaced(): Frame is not movable or resizable') end
    self.userPlaced=value
end
function methods:SetTextColor(...) self.textColor={...} end
assert(loadfile(root..'Folded.lua'))('ForeverUtilities',NS)
level=59;dead=false;combat=false;auras={}
local foldedDB={enabled=true,locked=true,x=0,y=0,scale=1,collapsed=true,flashMissingBuffs=true}
local foldHost,foldContent
local foldModule={command='/ftest',classToken='WARLOCK'}
local foldInstance=NS.ClassHost.Create(foldModule,foldedDB,function(owner)
    foldHost=owner;foldContent=object()
    foldContent.Refresh=function() NS.ClassHost.SetFade(owner,foldContent,0.2) end
    foldContent.Status=function() return 'test' end
    return foldContent
end)
foldModule.Apply=foldInstance.Apply;foldInstance.Apply()
local summary=foldInstance.folded
check(foldHost.width==78 and foldHost.height==97 and not foldInstance.visual.shown and summary.button.shown,'crest card with two warnings hides the full-bar controls')
check(summary.main.allPoints==summary.button and summary.button.height==97 and summary.row.allPoints==summary.main,
    'the click target covers the whole card')
local badges=foldInstance.levelingBuffs.indicators
check(not badges.food.button.shown and not badges.sleepingBag.button.shown,
    'folded mode suppresses the old floating corner controls')
check(summary.crest.shown and summary.crest.width==48 and summary.crest.x==15 and summary.crest.y==0
    and summary.crest.relative==foldHost
    and summary.crest.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\Classes\\WARLOCK',
    'the larger class crest is centered on top of the card')
check(summary.glow.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\Glow' and summary.glow.relative==summary.crest
    and summary.glow.width==76,'a class-colored glow sits behind the crest')
check(summary.card.shown and summary.card.y==-18 and summary.card.width==78 and summary.card.height==79,
    'one card frame surrounds crest and cells; the crest breaks through its top edge')
local corners,edgesStretched=0,0
for _,slice in ipairs(summary.slices) do
    if slice.width==12 and slice.height==12 then corners=corners+1 end
    if slice.column=='CENTER' and slice.row=='TOP' and slice.width==54 then edgesStretched=edgesStretched+1 end
    check(slice.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\IconFrame' and slice.relative==summary.card,
        'every card slice uses the engraved frame')
end
check(#summary.slices==9 and corners==4 and edgesStretched==1,'the card frame is a nine-slice with fixed 12px corners')
check(summary.divider.width==64 and summary.divider.height==10 and summary.divider.x==7 and summary.divider.y==-49,
    'an engraved divider separates the crest from the cells')
check(summary.badges[1].texture==foldHost.foldLevelWarnings.food.icon
    and summary.badges[2].texture==foldHost.foldLevelWarnings.sleepingBag.icon
    and summary.badges[1].width==24 and summary.badges[2].width==24,
    'food and sleeping bag use the same inset icon size')
check(summary.frames[1].x==7 and summary.frames[1].y==-60 and summary.frames[2].x==41 and summary.frames[1].width==30
    and summary.frames[1].texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\IconFrame'
    and summary.wells[1].shown and summary.wells[1].x==9 and summary.wells[1].y==-62
    and summary.badges[1].x==10 and summary.badges[1].y==-63 and summary.badges[2].x==44
    and summary.badges[1].relative==foldHost,
    'every warning uses one cell template: frame, dark well, and icon at the same inset')
check(summary.glows[1].shown and summary.glows[2].shown and not summary.glows[3].shown
    and summary.glows[1].texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\CellGlow'
    and summary.glows[1].width==42 and summary.glows[1].x==1 and summary.glows[1].y==-54
    and summary.halos.warningPulseGroup and summary.halos.warningPulseGroup.playing,
    'each warning cell gets a warm halo that breathes with the frame pulse')
check(summary.border==foldHost.outline and not summary.border.shown and foldHost.shellFill.alpha==0
    and foldInstance.shell.width==86 and foldInstance.shell.height==105,
    'the card replaces the expanded panel and outline')
check(foldInstance.shell.point=='TOP' and foldInstance.shell.x==0 and foldInstance.shell.y==28,
    'the crest stays centered on the saved point; the card grows below it')
check(#summary.border.slices==9 and summary.border.slices[1].texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\IconFrame' and foldHost.relative==foldInstance.shell and foldHost.x==4,
    'one image-based shell owns frame artwork and contains the inset logical host')
check(foldInstance.shell.clamped and not rawget(foldHost,'clamped'),
    'only the outer container clamps to screen so the inset host cannot shift independently')
check(foldHost.dontSavePosition and foldHost.userPlaced==false and foldHost.movable==false
    and foldInstance.shell.dontSavePosition and foldInstance.shell.movable,
    'native position caching is disabled and only the anonymous outer shell can move')
check(foldHost.events.PLAYER_LOGIN and foldHost.events.PLAYER_ENTERING_WORLD,
    'enabled host repairs its layout after native startup restoration')
-- Reproduce the old named Warlock frame record found in layout-local.txt.
foldHost:SetPoint('BOTTOMLEFT',UIParent,'BOTTOMLEFT',53,257);foldHost:SetSize(64,64)
foldHost.scripts.OnEvent(foldHost,'PLAYER_LOGIN')
check(foldHost.point=='TOPLEFT' and foldHost.relative==foldInstance.shell and foldHost.relativePoint=='TOPLEFT'
    and foldHost.x==4 and foldHost.y==-4 and foldHost.width==78 and foldHost.height==97,
    'startup restores the inset and current compact dimensions after an old Warlock cache record')
-- Mage had a separate stale full-bar record; world entry must repair it too.
foldHost:SetPoint('LEFT',UIParent,'LEFT',69,-261);foldHost:SetSize(426,56)
foldHost.scripts.OnEvent(foldHost,'PLAYER_ENTERING_WORLD')
check(foldHost.point=='TOPLEFT' and foldHost.relative==foldInstance.shell and foldHost.x==4 and foldHost.y==-4
    and foldHost.width==78 and foldHost.height==97 and foldedDB.x==0 and foldedDB.y==0,
    'world entry repairs a stale Mage record without replacing the saved container position')
check(foldHost.hint.text=='','collapsed drag instructions stay on hover')
NS.ClassHost.SetWarning(foldHost,'upkeep',true,777,'Armor missing')
check(summary.badges[1].texture==777 and summary.badges[3].shown and not summary.badges[4].shown
    and summary.badges[1].width==summary.badges[3].width and summary.badges[3].x==78 and summary.badges[3].y==-63
    and summary.crest.x==32 and foldInstance.shell.point=='TOP' and foldInstance.shell.x==0,
    'a third warning widens the card evenly without moving the crest')
NS.ClassHost.SetWarning(foldHost,'upkeep',false,nil,'Armor missing')
check(summary.badges[1].texture==foldHost.foldLevelWarnings.food.icon and not summary.badges[3].shown,
    'cleared armor removes only its warning')
NS.ClassHost.SetWarning(foldHost,'imbue',true,778,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',true,779,'Elemental shield missing')
check(summary.badges[4].shown and summary.badges[1].texture==778 and summary.badges[2].texture==779
    and summary.badges[3].texture==foldHost.foldLevelWarnings.food.icon
    and summary.badges[4].texture==foldHost.foldLevelWarnings.sleepingBag.icon,
    'all four Shaman reminders fit without dropping or enlarging any warning')
for _,badge in ipairs(summary.badges) do
    check(badge.x>=0 and badge.x+badge.width<=foldHost.width and badge.y<=0 and badge.y-badge.height>=-foldHost.height,
        'every warning stays inside the compact image frame')
end
NS.ClassHost.SetWarning(foldHost,'imbue',false,nil,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',false,nil,'Elemental shield missing')
-- Check the actual occupied bounds across count changes, rather than only
-- accepting positions inside a generously sized canvas.
local function CheckBounds(expectedCount,expectedWidth,expectedHeight)
    local shown,minX,maxX,minY,maxY=0,math.huge,-math.huge,math.huge,-math.huge
    for _,frame in ipairs(summary.frames) do
        if frame.shown then
            shown=shown+1;minX=math.min(minX,frame.x);maxX=math.max(maxX,frame.x+frame.width)
            minY=math.min(minY,frame.y-frame.height);maxY=math.max(maxY,frame.y)
            check(frame.relative==foldHost,'each cell is anchored directly to the inset host')
        end
    end
    check(shown==expectedCount and foldHost.width==expectedWidth and foldHost.height==expectedHeight,
        'logical frame tracks the actual visible icon count')
    check(summary.button.width==expectedWidth and summary.button.height==expectedHeight
        and foldInstance.shell.width==expectedWidth+8 and foldInstance.shell.height==expectedHeight+8,
        'hit target and shell fit the card plus four-pixel padding')
    if shown>0 then
        local row=expectedCount*30+(expectedCount-1)*4
        check(minX==(expectedWidth-row)/2 and maxX==minX+row and minY==-90 and maxY==-60
            and summary.card.shown and summary.divider.width==expectedWidth-14,
            'cells are centered in one row below the divider')
    else
        check(not summary.card.shown and not summary.halos.shown and summary.crest.x==0,'with no warnings only the crest remains')
    end
end
CheckBounds(2,78,97)
NS.ClassHost.SetWarning(foldHost,'upkeep',true,777,'Armor missing');CheckBounds(3,112,97)
NS.ClassHost.SetWarning(foldHost,'upkeep',false,nil,'Armor missing')
NS.ClassHost.SetWarning(foldHost,'imbue',true,778,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',true,779,'Elemental shield missing');CheckBounds(4,146,97)
NS.ClassHost.SetWarning(foldHost,'imbue',false,nil,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',false,nil,'Elemental shield missing')
NS.ClassHost.SetWarning(foldHost,'upkeep',true,nil,'Class upkeep missing')
check(summary.badges[1].texture==foldHost.foldLevelWarnings.food.icon and not summary.badges[3].shown,
    'missing artwork cannot substitute an unrelated class icon as a warning')
NS.ClassHost.SetWarning(foldHost,'upkeep',false,nil,'Class upkeep missing')
foldedDB.foodXPReminder=false;foldInstance.levelingBuffs.Refresh()
check(summary.badges[1].texture==foldHost.foldLevelWarnings.sleepingBag.icon and not summary.badges[2].shown,
    'disabled food tracking removes its warning independently')
CheckBounds(1,64,97)
foldedDB.foodXPReminder=true;combat=true
foldInstance.levelingBuffs.controller.scripts.OnEvent(nil,'PLAYER_REGEN_DISABLED')
check(not summary.row.shown and summary.primary.shown and summary.button.alpha==0.8,
    'combat clears leveling warnings without retaining stale missing claims')
combat=false;foldInstance.levelingBuffs.controller.scripts.OnEvent(nil,'PLAYER_REGEN_ENABLED')
check(summary.badges[2].shown,'readable post-combat absence restores eligible reminders')
auras={secret};foldInstance.levelingBuffs.Refresh()
check(not summary.row.shown and summary.primary.shown and not summary.edges.warningPulseGroup.playing,
    'restricted aura reads cannot create warning artwork or a pulse')
CheckBounds(0,48,48)
auras={{spellId=429959,name='Well-Rested'},{spellId=1248420,name='Well Fed'}}
foldInstance.levelingBuffs.Refresh()
check(not summary.row.shown and summary.crest.shown and foldHost.width==48 and foldHost.height==48,
    'all buffs present leaves only the class crest, with no blank cells or implied buff state')
foldInstance.shell.IsMouseOver=function() return true end
foldHost.scripts.OnUpdate(foldHost,0.2)
check(foldHost.hovered and summary.button.alpha==1,'hovering the container padding reveals its components')
foldInstance.shell.IsMouseOver=function() return false end
foldHost.scripts.OnUpdate(foldHost,0.2)
check(not foldHost.hovered and summary.button.alpha==0.8,'leaving keeps the idle crest readable outside combat')
auras={};foldInstance.levelingBuffs.Refresh()
check(summary.button:GetScript('OnClick')~=nil,'the complete compact frame remains the expand control')
local ticks=0
foldContent:SetScript('OnUpdate',function() ticks=ticks+1 end)
foldHost.scripts.OnUpdate(foldHost,0.3)
check(ticks==1,'host forwards the existing updater while visuals are folded')
foldContent:Hide();foldHost.scripts.OnUpdate(foldHost,0.3)
check(ticks==1,'suspended hidden content does not get revived by collapsed forwarding')
foldContent:Show();foldedDB.flashMissingBuffs=false;foldInstance.Apply()
check(not summary.edges.warningPulseGroup.playing and not summary.halos.warningPulseGroup.playing
    and summary.glows[1].shown and summary.button.alpha==1,'static collapsed warnings keep a steady halo when flashing is off')
summary.button.scripts.OnClick()
check(summary.fold.relative==foldInstance.shell and summary.fold.x==-5,'collapse control belongs to the internal container rail')
check(foldInstance.shell.width==450 and foldInstance.shell.height==64,'expanded container reserves padding and an internal control rail')
check(not foldedDB.collapsed and foldHost.width==426 and foldInstance.visual.shown and not summary.button.shown,
    'click expands to the original bar size')
check(summary.fold.glyph.text=='<' and summary.fold.glyph.textColor[1]==0.8,'collapse control is a plain glyph without a second button border')
local tooltip={}
GameTooltip={SetOwner=function() end,SetText=function(_,text) tooltip.text=text end,AddLine=function() end,Show=function() end,Hide=function() end}
summary.fold.scripts.OnEnter(summary.fold)
check(tooltip.text=='Collapse to warning icons','collapse control explains itself like the lock button')
summary.fold.scripts.OnLeave(summary.fold);GameTooltip=nil
check(summary.border.warm==true and summary.border.crest.shown and summary.border.crest.width==44
    and summary.border.crest.texture=='Interface\\AddOns\\ForeverUtilities\\Textures\\Classes\\WARLOCK'
    and summary.border.crest.point=='CENTER' and summary.border.crest.relativePoint=='LEFT' and summary.border.crest.x==0
    and summary.border.slices[1].width==12 and summary.border.slices[2].width==426
    and summary.border.shown and not summary.edges.warningPulseGroup.playing
    and foldInstance.shell.point=='CENTER' and foldInstance.shell.x==0,
    'the expanded engraved frame warms for warnings, without a second pulse, and the crest clasps its left edge')
-- Leveling reminders show full-brightness content; the frame art must match it.
foldedDB.flashMissingBuffs=true
check(foldHost.levelingBuffMissing and foldContent.alpha==1 and summary.fold.alpha==1 and summary.border.alpha==1,
    'frame art follows the content alpha raised by a leveling reminder')
auras={{spellId=429959,name='Well-Rested'},{spellId=1248420,name='Well Fed'}};foldInstance.levelingBuffs.Refresh()
check(foldContent.alpha==0.2 and summary.fold.alpha==0.2 and summary.border.alpha==0.2
    and summary.border.warm==false,'idle expanded frame art fades with its content and returns to the class tint')
check(foldHost.scripts.OnUpdate~=nil,'faded bar keeps hover detection')
foldContent.Refresh=function() NS.ClassHost.SetFade(foldHost,foldContent,1) end;foldInstance.Apply()
check(foldHost.scripts.OnUpdate==nil,'fully visible expanded bar runs no hover poll')
foldInstance.shell.IsMouseOver=function() return true end
foldContent.Refresh=function() NS.ClassHost.SetFade(foldHost,foldContent,0.2) end;foldInstance.Apply()
check(foldHost.scripts.OnUpdate~=nil and foldHost.hovered and foldContent.alpha==1,
    'resumed fading immediately honors a pointer already over the bar')
foldInstance.shell.IsMouseOver=function() return false end;foldHost.scripts.OnUpdate(foldHost,0.2)
check(not foldHost.hovered and foldContent.alpha==0.2,'leaving after resume restores the fade')
foldedDB.showFoldButton=false;foldInstance.Apply()
check(foldInstance.shell.width==434 and not summary.fold.shown,'hidden collapse button leaves no empty rail')
foldedDB.showFoldButton=true;foldInstance.Apply()
check(foldInstance.shell.width==450,'shown collapse button restores the control rail')
auras={};foldInstance.levelingBuffs.Refresh()
summary.fold.scripts.OnClick()
check(foldedDB.collapsed and foldHost.width==78 and foldHost.height==97,'fold control collapses to the current reminder row')
-- Six confirmed warnings: four icons, the last one counts the hidden two.
NS.ClassHost.SetWarning(foldHost,'imbue',true,778,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',true,779,'Elemental shield missing')
NS.ClassHost.SetWarning(foldHost,'upkeep',true,777,'Armor missing')
NS.ClassHost.SetWarning(foldHost,'aspect',true,780,'Aspect missing')
check(summary.badges[4].shown and summary.overflow.shown and summary.overflow.text=='+2' and foldHost.width==146 and foldHost.height==97,
    'overflow keeps the four-icon frame and counts hidden warnings')
for _,key in ipairs({'imbue','shield','upkeep','aspect'}) do NS.ClassHost.SetWarning(foldHost,key,false,nil,'x') end
check(not summary.overflow.shown,'overflow count clears with the extra warnings')
check(summary.edges.warningPulseGroup.playing and rawget(summary.badges[1],'alpha')==nil and rawget(summary.wells[1],'alpha')==nil,
    'the pulse animates only the cell edges; icons and wells stay fully readable')
-- Dragging the compact strip stores the crest-only center, so expanding and
-- warning changes keep the crest where it was dropped.
function methods:GetEffectiveScale() return 1 end
UIParent.GetCenter=function() return 500,400 end
foldInstance.shell.GetCenter=function() return 640,450 end
foldInstance.shell.GetTop=function() return 478 end
foldedDB.locked=false;foldHost.scripts.OnDragStop(foldHost)
check(foldedDB.x==140 and foldedDB.y==50 and foldInstance.shell.point=='TOP' and foldInstance.shell.x==140 and foldInstance.shell.y==78,
    'compact drag saves the crest center, not the center of a temporary card')
foldedDB.locked=true
-- Combat auto-fold: off by default; when on, combat expands and leaving
-- combat folds, each with a one-shot transition.
check(not foldHost.events.PLAYER_REGEN_DISABLED and not foldHost.events.PLAYER_REGEN_ENABLED,
    'auto-fold registers no combat listeners unless chosen')
local transition=foldHost.transition
combat=true;foldedDB.autoFold=true;foldInstance.Apply()
check(foldHost.events.PLAYER_REGEN_DISABLED and foldHost.events.PLAYER_REGEN_ENABLED and not foldedDB.collapsed
    and foldInstance.visual.shown,'turning auto-fold on in combat expands right away')
check(transition.bloom.playing and transition.flare.shown and transition.grow.scaleFrom==0.9 and transition.grow.scaleTo==1
    and transition.flare.relative==foldInstance.shell and transition.flare.point=='CENTER',
    'expanding bursts the bar out from 90% with a flare across it')
local plays=transition.intro.plays
combat=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_REGEN_ENABLED')
check(foldedDB.collapsed and not foldInstance.visual.shown and transition.intro.plays==plays+1
    and transition.grow.scaleFrom==1.12 and transition.flare.width==110
    and transition.flare.relativePoint=='TOP' and transition.flare.y==-28,
    'leaving combat folds the card, dropping it in with a flare on the crest')
summary.button.scripts.OnMouseDown();summary.button.scripts.OnClick()
check(not foldedDB.collapsed,'a manual click still expands outside combat')
plays=transition.intro.plays
combat=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_REGEN_DISABLED')
check(not foldedDB.collapsed and transition.intro.plays==plays,'entering combat while already expanded does not replay the effect')
combat=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_REGEN_ENABLED')
check(foldedDB.collapsed,'the next combat exit folds again')
combat=secret;foldedDB.collapsed=false;foldInstance.Apply();foldHost.scripts.OnEvent(foldHost,'PLAYER_ENTERING_WORLD')
check(not foldedDB.collapsed,'an unreadable combat state never folds or expands on its own')
combat=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_ENTERING_WORLD')
check(foldedDB.collapsed,'world entry folds when confirmed out of combat')
transition.Play(false,450,64);foldedDB.autoFold=false;foldInstance.Apply()
check(not foldHost.events.PLAYER_REGEN_DISABLED and not foldHost.events.PLAYER_REGEN_ENABLED,
    'turning auto-fold off removes its combat listeners')
foldHost.scripts.OnEvent(foldHost,'PLAYER_REGEN_DISABLED')
check(foldedDB.collapsed,'queued combat events are ignored once auto-fold is off')
-- Death folds the bar to the crest card; revival restores only a death fold.
foldedDB.autoFold=false;foldedDB.collapsed=false;foldedDB.foldedByDeath=nil;combat=false;dead=false;foldInstance.Apply()
check(foldHost.events.PLAYER_DEAD and foldHost.events.PLAYER_ALIVE and foldHost.events.PLAYER_UNGHOST,
    'the enabled host listens for death and revival')
local deathPlays=transition.intro.plays
dead=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_DEAD')
check(foldedDB.collapsed and foldedDB.foldedByDeath and not foldInstance.visual.shown and not summary.card.shown
    and summary.crest.shown and foldHost.width==48 and transition.intro.plays==deathPlays+1,
    'dying folds the expanded bar down to the crest alone')
check(summary.spirit.shown and summary.spiritAnimation.playing and summary.spiritAnimation.looping=='BOUNCE'
    and not summary.glow.shown,'a pale spirit glow breathes around the crest while dead, replacing the class glow')
foldHost.scripts.OnEvent(foldHost,'PLAYER_ALIVE')
check(foldedDB.collapsed,'releasing as a ghost keeps the bar folded')
foldHost.scripts.OnEvent(foldHost,'PLAYER_REGEN_DISABLED')
check(foldedDB.collapsed,'combat events cannot expand a ghost')
dead=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_UNGHOST')
check(not foldedDB.collapsed and foldedDB.foldedByDeath==nil and foldInstance.visual.shown,
    'returning to life expands the bar that death folded')
check(not summary.spirit.shown and not summary.spiritAnimation.playing,'the spirit glow stops on revival')
foldedDB.collapsed=true;foldInstance.Apply()
dead=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_DEAD')
check(foldedDB.collapsed and foldedDB.foldedByDeath==nil,'a card the player folded is not marked as a death fold')
check(summary.spirit.shown and summary.spiritAnimation.playing,'an already folded card still shows the spirit glow on death')
dead=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_UNGHOST')
check(foldedDB.collapsed,'revival leaves a player-chosen card folded')
check(not summary.spirit.shown and summary.glow.shown,'the class glow returns on revival')
foldedDB.collapsed=false;foldInstance.Apply()
dead=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_DEAD')
dead=false;foldedDB.autoFold=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_ALIVE')
check(foldedDB.collapsed and foldedDB.foldedByDeath==nil,'with combat auto-fold on, revival out of combat stays folded')
foldedDB.autoFold=false;foldedDB.collapsed=false;foldInstance.Apply()
dead=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_DEAD')
-- Logged out while dead: the saved flag restores the bar after login.
dead=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_ENTERING_WORLD')
check(not foldedDB.collapsed and foldedDB.foldedByDeath==nil,'a death fold saved across logout is restored when alive')
-- While dead the crest cannot expand an empty bar; revival does that.
dead=true;foldHost.scripts.OnEvent(foldHost,'PLAYER_DEAD')
summary.button.scripts.OnMouseDown();summary.button.scripts.OnClick()
check(foldedDB.collapsed and foldedDB.foldedByDeath,'clicking the crest while dead keeps the death fold')
dead=false;foldHost.scripts.OnEvent(foldHost,'PLAYER_UNGHOST')
-- A fold the player makes is theirs, even if an older death flag is set.
foldedDB.foldedByDeath=true;summary.fold.scripts.OnClick()
check(foldedDB.collapsed and foldedDB.foldedByDeath==nil,'a manual fold clears the death flag')
foldHost.scripts.OnEvent(foldHost,'PLAYER_ALIVE')
check(foldedDB.collapsed,'revival never undoes a fold the player chose')
-- A drag on a locked crest is not a click.
foldedDB.locked=true
summary.button.scripts.OnMouseDown();summary.button.scripts.OnDragStart();summary.button.scripts.OnClick()
check(foldedDB.collapsed,'dragging a locked crest does not expand the card')
foldedDB.locked=false
-- An expanded bar with hidden content shows no empty frame or hit target.
function methods:EnableMouse(value) self.mouse=value end
foldedDB.collapsed=false;foldInstance.Apply()
check(foldHost.mouse==true and summary.border.shown,'an expanded bar with content takes the mouse')
foldContent:Hide()
check(foldHost.mouse==false and not summary.border.shown and not summary.fold.shown and foldHost.shellFill.alpha==0,
    'hidden content leaves no empty frame, collapse glyph or hit target')
foldContent:Show()
check(foldHost.mouse==true and summary.border.shown,'the frame returns with its content')
foldedDB.collapsed=true;foldInstance.Apply()
-- Class stat cell: first in the row, neutral frame, never glows or pulses.
foldedDB.autoFold=false;foldedDB.collapsed=true;combat=false
auras={{spellId=429959,name='Well-Rested'},{spellId=1248420,name='Well Fed'}};foldInstance.Apply()
NS.ClassHost.SetStat(foldHost,{icon=901,text='5',label='Soul Shards'})
local stat=summary.stat
check(summary.card.shown and foldHost.width==64 and stat.frame.shown and stat.icon.texture==901 and stat.text.text=='5'
    and stat.frame.x==17 and stat.frame.y==-60,'with no warnings the card shows just the class stat cell')
NS.ClassHost.SetWarning(foldHost,'upkeep',true,777,'Armor missing')
check(stat.frame.x==7 and summary.frames[1].x==41 and summary.badges[1].texture==777 and summary.glows[1].shown
    and foldHost.width==78,'the stat comes first and warnings follow it in the same row')
check(summary.halos.warningPulseGroup.playing and rawget(stat.frame,'warningPulseGroup')==nil,
    'warnings pulse while the stat cell stays steady')
local lines={}
GameTooltip={SetOwner=function() end,SetText=function(_,t) lines[#lines+1]=t end,AddLine=function(_,t) lines[#lines+1]=t end,Show=function() end,Hide=function() end}
summary.button.scripts.OnEnter(summary.button);GameTooltip=nil
check(lines[2]=='Soul Shards: 5','the card tooltip lists the stat first')
foldHost.scripts.OnLeave(foldHost);summary.button.scripts.OnLeave(summary.button)
NS.ClassHost.SetWarning(foldHost,'imbue',true,778,'Weapon imbue missing')
NS.ClassHost.SetWarning(foldHost,'shield',true,779,'Elemental shield missing')
NS.ClassHost.SetWarning(foldHost,'aspect',true,780,'Aspect missing')
check(foldHost.width==146 and summary.badges[3].shown and not summary.badges[4].shown and summary.overflow.shown
    and summary.overflow.text=='+1','with the stat, three warnings fit and the third counts the rest')
for _,key in ipairs({'upkeep','imbue','shield','aspect'}) do NS.ClassHost.SetWarning(foldHost,key,false,nil,'x') end
foldedDB.compactStat=false;foldInstance.Apply()
check(not stat.frame.shown and not summary.card.shown and foldHost.width==48,'the stat cell can be turned off')
foldedDB.compactStat=true;foldInstance.Apply()
foldContent:Hide()
check(not stat.frame.shown,'suspended or hidden class content never shows a stale stat')
foldContent:Show();NS.ClassHost.SetStat(foldHost,{icon=901,text='',label='Soul Shards'})
check(not stat.frame.shown,'an empty reading shows no stat cell')
NS.ClassHost.SetStat(foldHost,nil)
transition.Play(true,48,48)
foldedDB.enabled=false;foldInstance.Apply()
check(not transition.bloom.playing and not transition.intro.playing and not transition.flare.shown,'disable stops the transition effect')
check(not summary.button.shown and not summary.edges.warningPulseGroup.playing and not summary.halos.warningPulseGroup.playing,'disable clears collapsed presentation and animation')
check(not next(foldHost.events),'disabled host unregisters native-layout lifecycle listeners')
foldHost:SetPoint('LEFT',UIParent,'LEFT',69,-261)
foldHost.scripts.OnEvent(foldHost,'PLAYER_ENTERING_WORLD')
check(not foldInstance.shell.shown and foldHost.point=='LEFT','queued layout events cannot revive a disabled helper')
-- Every class crest, the shared frame and the glow ship as 64 x 64 32-bit TGAs.
local function CheckTGA(path)
    local file=assert(io.open(root..'Textures/'..path..'.tga','rb'),path..' is packaged')
    local header=file:read(18);file:close()
    check(header:byte(3)==2 and header:byte(13)+header:byte(14)*256==64 and header:byte(15)+header:byte(16)*256==64
        and header:byte(17)==32,path..' is an uncompressed 64 x 64 RGBA texture')
end
for _,token in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'}) do CheckTGA('Classes/'..token) end
CheckTGA('IconFrame');CheckTGA('Glow');CheckTGA('CellGlow')
local divider=assert(io.open(root..'Textures/Divider.tga','rb'));local dh=divider:read(18);divider:close()
check(dh:byte(13)+dh:byte(14)*256==256 and dh:byte(15)+dh:byte(16)*256==16 and dh:byte(17)==32,'divider ships as a 256 x 16 RGBA texture')
print('PASS: folded layout, warning, lifecycle and update regressions')
