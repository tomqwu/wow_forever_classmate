local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
local root='addons/ForeverUtilities/'
local frames,named={},{}
local methods={}
local function object() return setmetatable({scripts={},events={},shown=true},{__index=methods}) end
function methods:SetScript(key,value) self.scripts[key]=value end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:CreateFontString() return object() end
function methods:CreateTexture() return object() end
function methods:CreateMaskTexture() return object() end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetWidth(w) self.width=w end
function methods:GetWidth() return self.width end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetText(v) self.text=v end
function methods:SetFont(_,size) self.fontSize=size end
function methods:GetStringWidth() return #(self.text or '')*(self.fontSize or 12)*(rawget(self,'measureFactor') or 0.6) end
function methods:SetTexture(v) self.texture=v end
function methods:SetAlpha(v) self.alpha=v end
function methods:SetDesaturated(v) self.desaturated=v end
function methods:SetColorTexture(r,g,b,a) self.color={r,g,b,a} end
function methods:SetMovable(v) self.movable=v end
function methods:StartMoving() self.moving=true end
function methods:StopMovingOrSizing() self.moving=false end
function methods:SetScale(v) self.scale=v end
function methods:EnableMouse(v) self.mouse=v end
function methods:SetShown(v) self.shown=v end
function methods:Show() self.shown=true end
function methods:Hide() self.shown=false end
function methods:SetChecked(v) self.checked=v end
function methods:GetChecked() return self.checked end
function methods:SetPoint(_,_,_,x,y) self.x,self.y=x,y end
function methods:GetCenter() return 30,40 end
function methods:GetEffectiveScale() return 1 end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function(_,name,parent)
    local frame=object();frame.name=name;frame.parent=parent;frames[#frames+1]=frame
    if name then named[name]=frame end
    return frame
end
UIParent=object();Minimap=object();Minimap:SetSize(200,200);UISpecialFrames={}
DEFAULT_CHAT_FRAME={messages={},AddMessage=function(self,text) self.messages[#self.messages+1]=text end};SlashCmdList={}
STANDARD_TEXT_FONT='font';GameTooltip=nil
local class='SHAMAN'
UnitClass=function() return 'Shaman',class end
UnitExists=function() return false end
UnitAffectingCombat=function() return false end
UnitIsDead=function() return false end
UnitPower=function() return 80 end
UnitPowerMax=function() return 100 end
local now=100
GetTime=function() return now end
GetTotemInfo=function() return false,'',0,0,0 end
GetTotemTimeLeft=function() return 0 end
GetInventoryItemID=function() return nil end
Enum={WeaponSlot={MainHand=0},SpellBookSpellBank={Player=0}}
C_Item={GetWeaponEnchantInfo=function() return {} end}
local book={
    [1]={spellID=1001,name='Maelstrom Weapon',iconID=501},
    [2]={spellID=1002,name='Windfury Weapon',iconID=502},
    [3]={spellID=1003,name='Lightning Shield',iconID=503},
    [4]={spellID=1004,name='Stoneclaw Totem',iconID=504},
}
C_Spell={GetSpellInfo=function(value)
    if value==2004 then return {name='Stoneclaw Totem',iconID=604} end
    if type(value)=='number' then local item=book[value-1000];return item and {name=item.name,iconID=item.iconID} end
    return {name=value,iconID=123}
end}
C_SpellBook={
    GetNumSpellBookSkillLines=function() return 1 end,
    GetSpellBookSkillLineInfo=function() return {itemIndexOffset=0,numSpellBookItems=4} end,
    GetSpellBookItemInfo=function(slot) local item=book[slot];return {spellID=item.spellID,isPassive=false,isOffSpec=false} end,
    IsSpellKnown=function() return true end,
}
C_UnitAuras={GetAuraDataByIndex=function(unit,index,filter)
    if unit=='player' and filter=='HELPFUL' then
        if index==1 then return {name='Maelstrom Weapon',icon=501,applications=5,expirationTime=120,sourceUnit='player'} end
        if index==2 then return {name='Lightning Shield',icon=503,applications=3,expirationTime=600,sourceUnit='player'} end
    end
end}
ForeverUtilitiesDB={shaman={x=72,y=-101,scale=1.2,locked=false}}
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ClassHost.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'ShamanContext.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'Shaman.lua'))('ForeverUtilities',NS)
assert(loadfile(root..'UI.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local events=frames[1]
events.scripts.OnEvent(events,'ADDON_LOADED','ForeverUtilities')
local db=NS.Shaman.db
check(db.x==72 and db.y==-101 and db.scale==1.2 and not db.locked,'saved shaman layout retained')
check(NS.Shaman.instance~=nil,'shaman creates active helper')
check(NS.Shaman.spells.maelstrom and NS.Shaman.spells.windfury and NS.Shaman.spells.lightningShield,'learned Shaman abilities discovered from spellbook')
local host=named.ForeverClassmateShamanFrame
local indicator=named.ForeverClassmateShamanIndicator
check(host and host.width==426 and host.height==56 and host.shown,'rendered native-width shaman bar created')
check(indicator and indicator.scripts.OnUpdate~=nil,'enabled info polls for live timers')
check(indicator.alpha==0.2,'idle shaman bar dims without a target or active totem')
check(not indicator.events.COMBAT_LOG_EVENT_UNFILTERED,'Shaman avoids Blizzard-only combat-log event registration')
check(indicator.totemCells[1].button.width==38 and indicator.totemCells[1].button.y==-9,'totem cells use the shared square size and top edge')
check(indicator.weaponCell.button.width==38 and indicator.weaponCell.button.y==-9 and indicator.shieldCell.button.y==-9,'totem and upkeep cells share one top edge')
check(indicator.weaponCell.badge.text=='' and indicator.shieldCell.badge.text=='3','upkeep icons omit letter labels while shield charges remain visible')
check(indicator.helperIcon.y==-14 and indicator.helperIcon.y-indicator.helperIcon.height/2==-28,'helper icon shares the cell centerline')
for _,cell in ipairs(indicator.totemCells) do
    check(cell.button.shown and cell.icon.shown and cell.icon.texture==cell.info.fallback and cell.icon.desaturated and cell.badge.text=='','inactive element uses a subdued icon without a large letter')
    check(cell.background.color[1]==0.09 and cell.stripe.width==3 and cell.stripe.color[1]<cell.info.color[1],'inactive totem stays dark with a narrow dim element stripe')
end
GetTotemInfo=function() return nil end;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE')
for _,cell in ipairs(indicator.totemCells) do check(cell.button.shown and cell.icon.shown and cell.icon.desaturated,'unavailable element keeps a subdued icon') end
GetTotemInfo=function(slot) if slot==2 then return true,'',0,0,0 end return false,'',0,0,0 end
local maelstrom=NS.Shaman.spells.maelstrom;NS.Shaman.spells.maelstrom=nil
indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE')
check(indicator.totemCells[1].state==nil and indicator.helperText.text=='?/4 totems','empty Earth slot API is shown as unavailable rather than zero active')
NS.Shaman.spells.maelstrom=maelstrom
GetTotemInfo=function(slot) if slot==2 then return false,'Earthbind Totem',90,30,777 end return false,'',0,0,0 end
GetTotemTimeLeft=function(slot) return slot==2 and 20 or 0 end;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE')
local earth=indicator.totemCells[1]
check(earth.icon.shown and not earth.icon.desaturated and earth.badge.text=='' and earth.icon.texture==777 and earth.timer.text=='20s','active totem replaces subdued art with live icon and timer')
check(indicator.alpha==1,'active totem keeps the shaman bar fully readable outside combat')
check(earth.background.color[1]==0.09 and earth.stripe.color[1]==earth.info.color[1],'active totem keeps dark cell and bright element stripe')
check(indicator.helperText.text=='Recall 1 totem' and indicator.helperText:GetStringWidth()<=indicator.helperText.width,'recall hint fits without clipping')
indicator.helperText.measureFactor=1;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE')
check(indicator.helperText.text=='Recall 1' and indicator.helperText:GetStringWidth()<=indicator.helperText.width,'recall hint shortens when the full label will not fit')
indicator.helperText.measureFactor=nil
GetTotemInfo=function() return secret,secret,secret,secret,secret end;GetTotemTimeLeft=function() return secret end
UnitAffectingCombat=function() return true end
now=105;indicator.scripts.OnEvent(indicator,'PLAYER_REGEN_DISABLED')
check(earth.state.cached and earth.timer.text=='15s' and earth.icon.shown and indicator.helperText.text~='Recall 1 totem','readable precombat totem counts down through secret combat reads')
now=125;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE',2)
check(not earth.state or not earth.state.active,'totem update clears expired cached state')
UnitAffectingCombat=function() return false end
indicator.scripts.OnEvent(indicator,'PLAYER_REGEN_ENABLED')
check(indicator.alpha==0.2,'shaman bar dims again after its last known totem expires and combat ends')
GetTotemInfo=function(slot) if slot==2 then return true,'Stoneclaw Totem',125,30,504,1,1004 end return false,'',0,0,0 end
GetTotemTimeLeft=function(slot) return slot==2 and 30 or 0 end
indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE',2)
check(db.totemDurations[1004]==30,'readable duration is remembered for the exact totem spell')
GetTotemInfo=function() return secret,secret,secret,secret,secret end;GetTotemTimeLeft=function() return secret end
UnitAffectingCombat=function() return true end
now=130;indicator.scripts.OnEvent(indicator,'UNIT_SPELLCAST_SUCCEEDED','player','cast-guid',1004)
check(earth.state.castObserved and earth.state.name=='Stoneclaw Totem' and earth.timer.text=='~30s' and indicator.Status():find('Totems 1/4',1,true),'combat cast uses an explicitly estimated learned duration')
indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE',2)
check(earth.state.castObserved and earth.timer.text=='~30s','placement update preserves the estimated countdown')
now=132;indicator.scripts.OnUpdate(indicator,0.25)
check(earth.timer.text=='~28s','estimated combat timer counts down')
now=135;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE',2)
check(earth.state==nil,'later totem removal event clears combat cast')
UnitAffectingCombat=function() return false end
GetTotemInfo=function() return false,'',0,0,0 end;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE')
check(indicator.alpha==0.2,'removed combat totem no longer keeps the bar bright')
GetTotemInfo=function() return secret,secret,secret,secret,secret end;GetTotemTimeLeft=function() return secret end
UnitAffectingCombat=function() return false end
now=140;indicator.scripts.OnEvent(indicator,'UNIT_SPELLCAST_SUCCEEDED','player','cast-guid',2004)
check(earth.state and earth.state.castObserved and earth.icon.texture==604 and earth.timer.text=='' and indicator.alpha==1,
    'observed totem cast outside spellbook IDs keeps bar visible without guessing a timer')
now=142;indicator.scripts.OnEvent(indicator,'PLAYER_TOTEM_UPDATE',2)
check(earth.state==nil and indicator.alpha==0.2,'later totem removal clears dynamically recognized cast')
indicator.scripts.OnEvent(indicator,'PLAYER_LEAVING_WORLD');check(indicator.scripts.OnUpdate==nil,'world exit stops polling')
indicator.scripts.OnEvent(indicator,'PLAYER_ENTERING_WORLD');check(indicator.scripts.OnUpdate~=nil,'world entry restarts polling')
local slash=SlashCmdList.FOREVERUTILITIES
slash('')
local panel=named.ForeverClassmateShamanOptions
check(panel and panel.shown and panel.movable,'movable shaman settings panel')
for _,key in ipairs({'showTotems','showWeaponImbue','showShield','showSpecHelper','showMana','totemRecallHint','fadeOutOfCombat'}) do
    check(panel.controls[key]~=nil,'shaman option exists: '..key)
end
for _,key in ipairs({'showTotems','showWeaponImbue','showShield','showSpecHelper','showMana','totemRecallHint'}) do
    local control=panel.controls[key];control:SetChecked(false);control.scripts.OnClick(control)
    check(db[key]==false,'shaman option saves: '..key)
end
check(indicator.scripts.OnUpdate==nil,'all live information disabled stops polling')
slash('scale 1.4');check(db.scale==1.4,'shaman scale command')
slash('lock');check(db.locked,'shaman lock command')
local lock=named.ForeverClassmateShamanLock;lock.scripts.OnClick();check(not db.locked,'shaman bar lock button')
slash('off');check(not db.enabled and not host.shown and not indicator.scripts.OnUpdate,'disable stops and hides shaman bar')
check(next(indicator.events)==nil,'disable unregisters shaman events')
slash('on');check(db.enabled and host.shown,'command reenables shaman bar')
local mini=named.ForeverClassmateShamanMinimap
check(mini and mini.width==28 and mini.height==28,'shaman uses shared minimap launcher')
slash('reset');check(db.showTotems and db.showWeaponImbue and db.showShield and db.showSpecHelper and db.showMana,'reset restores shaman features')
local before=#DEFAULT_CHAT_FRAME.messages;slash('status');check(#DEFAULT_CHAT_FRAME.messages>=before+2,'status reports module diagnostics')
NS.Shaman.Initialize(ForeverUtilitiesDB);check(NS.Shaman.db.x==0 and ForeverUtilitiesDB.schemaVersion==3,'shaman preferences persist with class schema')
print('PASS: '..count..' shaman UI and lifecycle checks')
