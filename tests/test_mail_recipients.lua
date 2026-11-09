local root='addons/ForeverUtilities/'
local NS={}
local secret={}
issecretvalue=function(value) return rawequal(value,secret) end
assert(loadfile(root..'Core.lua'))('ForeverUtilities',NS)
local module={db={enabled=false,mailRecipients=true}}
NS.ActiveClass=function() return module end
local frames,named={},{}
local methods={}
local function object(parent) return setmetatable({scripts={},events={},shown=true,parent=parent},{__index=methods}) end
function methods:SetScript(key,fn) self.scripts[key]=fn end
function methods:HookScript(key,fn)
    local before=self.scripts[key]
    self.scripts[key]=function(...) if before then before(...) end;fn(...) end
end
function methods:RegisterEvent(event) self.events[event]=true end
function methods:UnregisterEvent(event) self.events[event]=nil end
function methods:SetSize(w,h) self.width,self.height=w,h end
function methods:SetPoint(point,relative,relativePoint,x,y) self.point,self.x,self.y=point,x,y end
function methods:CreateTexture() return object(self) end
function methods:CreateFontString() return object(self) end
function methods:IsForbidden() return self.forbidden==true end
function methods:GetFrameStrata() error('must not copy native strata') end
function methods:IsVisible()
    local parent=rawget(self,'parent')
    return self.shown and (not parent or parent:IsVisible())
end
function methods:SetShown(value)
    if value==self.shown then return end
    self.shown=value
    local fn=self.scripts[value and 'OnShow' or 'OnHide'];if fn then fn(self) end
end
function methods:Show() self:SetShown(true) end
function methods:Hide() self:SetShown(false) end
function methods:SetText(value) self.text=value end
function methods:GetText() return self.text end
function methods:SetEnabled(value) self.enabled=value end
function methods:IsEnabled() return self.enabled~=false end
function methods:ClearFocus() self.focus=false end
setmetatable(methods,{__index=function() return function() end end})
CreateFrame=function(_,name,parent)
    local frame=object(parent);frames[#frames+1]=frame
    if name then named[name]=frame end
    return frame
end
local name,surname,realm,faction,realmID,guid='Alice','Dawn','Forever Realm','Alliance',123,'Player-123-A'
local combat=false
GetUnitName=function() return name..' '..surname end
UnitFullName=function() return name,surname end
GetNormalizedRealmName=function() return realm end
GetRealmName=function() return realm end
GetRealmID=function() return realmID end
UnitFactionGroup=function() return faction end
UnitGUID=function() return guid end
InCombatLockdown=function() return combat end
local hooks={};local sends=0;local hookCount=0
SendMail=function() sends=sends+1 end
hooksecurefunc=function(target,fn)
    assert(target=='SendMail','only observe the native send function')
    hooks.send=fn;hookCount=hookCount+1
end
local function NativeSend(recipient)
    SendMail(recipient,'not stored','not stored');hooks.send(recipient)
end
assert(loadfile(root..'MailRecipients.lua'))('ForeverUtilities',NS)
local Mail=NS.MailRecipients
local count=0
local function check(value,message) assert(value,message);count=count+1 end
check(Mail.Recipient(' Alice Dawn ').address=='Alice Dawn','complete name trims edges without appending a realm')
check(Mail.Recipient('Alice-Dawn').address=='Alice-Dawn','observed hyphen address is not split into name and realm')
check(Mail.Recipient('Alice Dawn').key==Mail.Recipient('Alice-Dawn').key,'two native name spellings deduplicate without losing a surname')
check(Mail.Recipient('小号 晨曦').address=='小号 晨曦','Chinese first and last name remain intact')
for _,value in ipairs({secret,'','   ','Alice','A|cffff0000 Last','A;B Last','A/B Last','A\\B Last','A@B Last','A\nB Last','Alice-','-Dawn'}) do
    check(Mail.Recipient(value)==nil,'incomplete, malformed or secret recipient rejected')
end
local nativeFullName=GetUnitName
GetUnitName=nil
check(Mail.Player().name=='Alice Dawn' and Mail.Player().realm=='ForeverRealm',
    'tuple fallback joins firstname and surname while reading the realm separately')
GetUnitName=function() return 'Alice' end
check(Mail.Player().name=='Alice Dawn','incomplete native name falls back to both readable tuple parts')
local tupleFullName=UnitFullName
UnitFullName=function() return 'Alice',secret end
check(Mail.Player()==nil,'restricted surname never falls back to a first-name-only identity')
GetUnitName=nativeFullName;UnitFullName=tupleFullName
local oldRecents={['id:123/Alliance']={'Legacy-ForeverRealm'}}
local saved={hunter={x=71},mail={characters={
    oldSelf={name='Alice',realm='ForeverRealm',realmID=123,faction='Alliance',guid='Player-123-A'},
    legacyAlt={name='Legacy',realm='ForeverRealm',realmID=123,faction='Alliance',guid='Player-123-L'},
},recents=oldRecents}}
module.db.mailRecipients=false;Mail.Initialize(saved)
check(#frames==0 and hookCount==0,'disabled utility creates no frames or hooks')
check(saved.mail.legacyRecents==oldRecents and saved.mail.nameFormat==2,
    'ambiguous legacy history is preserved separately instead of guessed or silently reused')
module.db.mailRecipients=true;Mail.Apply()
local controller=frames[1]
local function Event(event,arg) controller.scripts.OnEvent(controller,event,arg) end
local player=Mail.Player()
check(saved.mail.characters[player.savedKey].name=='Alice Dawn' and saved.hunter.x==71,'observed player recorded without changing class settings')
check(saved.mail.characters.oldSelf==nil and saved.mail.characters.legacyAlt
    and #Mail.Alts(player)==0 and #Mail.Recents(player)==0,
    'login upgrades the matching GUID while legacy incomplete alts and history stay off active lists')
check(controller.events.MAIL_SHOW and controller.events.MAIL_SEND_SUCCESS and hookCount==1,'mail events and safe observation hook registered')
check(not named.ForeverClassmateMailRecipients and not controller.scripts.OnUpdate,'mail panel is lazy and adds no polling')
check(module.db.enabled==false and next(controller.events),'utility works independently of the disabled class bar')
name='Bank';guid='Player-123-B';Event('PLAYER_ENTERING_WORLD')
name='OtherFaction';guid='Player-123-H';faction='Horde';Event('PLAYER_ENTERING_WORLD')
name='OtherRealm';guid='Player-456-A';faction='Alliance';realmID=456;Event('PLAYER_ENTERING_WORLD')
name='Alice';guid='Player-123-A';realmID=123;Event('PLAYER_ENTERING_WORLD')
player=Mail.Player()
local alts=Mail.Alts(player)
check(#alts==1 and alts[1].name=='Bank Dawn','alts exclude current character, other faction, and same-name other realm IDs')
-- A renamed character replaces its old observed entry by readable whole GUID.
name='RenamedBank';guid='Player-123-B';Event('PLAYER_ENTERING_WORLD')
name='Alice';guid='Player-123-A';Event('PLAYER_ENTERING_WORLD')
alts=Mail.Alts(Mail.Player())
check(#alts==1 and alts[1].name=='RenamedBank Dawn','same GUID updates renamed alt without retaining an old suggestion')
-- Malformed saved records cannot break a mailbox.
saved.mail.characters.bad={name='Bad-Realm',faction='Alliance'}
saved.mail.characters.broken=true
check(#Mail.Alts(Mail.Player())==1,'malformed saved records are ignored')
-- Native mail addon can load after MAIL_SHOW.
Event('MAIL_SHOW');check(not named.ForeverClassmateMailRecipients,'missing native mail frames stay quiet')
SendMailFrame=object();SendMailFrame.shown=false
SendMailNameEditBox=object();SendMailNameEditBox.text='DraftRecipient'
Event('ADDON_LOADED','OtherAddon')
check(not SendMailFrame.scripts.OnShow,'unrelated addon load does not bind mail UI')
Event('ADDON_LOADED','Blizzard_MailFrame')
check(SendMailFrame.scripts.OnShow and not controller.events.ADDON_LOADED,'mail UI binds once after lazy loading')
check(not named.ForeverClassmateMailRecipients,'inbox-only mode does not create the panel')
SendMailFrame:Show()
local panel=named.ForeverClassmateMailRecipients
check(panel and panel.shown and panel.width==220 and panel.height==440 and panel.x==8,'compact side panel attaches to native Send Mail')
check(SendMailNameEditBox.text=='DraftRecipient' and sends==0,'opening suggestions never overwrites the draft or sends mail')
local altRow=panel.groups.alts.rows[1]
check(altRow.item.name=='RenamedBank Dawn','observed alt appears in its section')
altRow.scripts.OnClick(altRow,'LeftButton')
check(SendMailNameEditBox.text=='RenamedBank Dawn' and sends==0,'click fills recipient only')
SendMailNameEditBox.enabled=false;SendMailNameEditBox.text='Untouched'
altRow.scripts.OnClick(altRow,'LeftButton')
check(SendMailNameEditBox.text=='Untouched','disabled native recipient field is left alone')
SendMailNameEditBox.enabled=true
SendMailNameEditBox.forbidden=true;altRow.scripts.OnClick(altRow,'LeftButton')
check(SendMailNameEditBox.text=='Untouched','forbidden edit box is left alone')
SendMailNameEditBox.forbidden=false
check(panel.groups.recents.empty.shown,'recents start with an explanatory empty state')
NativeSend('Friend Dawn');check(#Mail.Recents(Mail.Player())==0,'attempted send is not yet history')
check(not altRow.enabled,'pending send prevents changing a suggested recipient')
SendMailNameEditBox.text='';Event('MAIL_SEND_SUCCESS')
check(Mail.Recents(Mail.Player())[1].address=='Friend Dawn','success records captured recipient even after native field reset')
check(panel.groups.recents.rows[1].item.name=='Friend Dawn','successful recipient appears in side panel')
NativeSend('FailedFriend Dawn');Event('MAIL_FAILED')
check(#Mail.Recents(Mail.Player())==1,'failed send does not enter history')
NativeSend('CancelledFriend Dawn');Event('SECURE_TRANSFER_CANCEL');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1,'cancelled transfer cannot become a stale recent')
NativeSend(secret);Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1,'secret recipient is never saved')
NativeSend('Friend');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1,'a successful first-name-only input cannot become a suggested full identity')
NativeSend('FirstOverlap Dawn');NativeSend('SecondOverlap Dawn');Event('MAIL_SEND_SUCCESS');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1,'overlapping sends omit ambiguous history instead of guessing')
NativeSend('Friend Dawn');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1,'repeated same-realm recipient is deduplicated')
NativeSend('Friend-Dawn');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==1 and Mail.Recents(Mail.Player())[1].address=='Friend-Dawn',
    'history preserves the exact successful two-part address without converting surname to realm')
NativeSend('Friend Dusk');Event('MAIL_SEND_SUCCESS')
local recentRow=panel.groups.recents.rows[1]
check(recentRow.label.text=='Friend Dusk','different surnames are distinct recent recipients')
recentRow.scripts.OnClick(recentRow,'LeftButton')
check(SendMailNameEditBox.text=='Friend Dusk','click fills the exact first and last name')
recentRow.scripts.OnClick(recentRow,'RightButton')
check(#Mail.Recents(Mail.Player())==1,'right-click removes history without sending or deleting game mail')
for index=1,23 do
    NativeSend('Friend'..string.char(64+index)..' Dawn');Event('MAIL_SEND_SUCCESS')
end
check(#Mail.Recents(Mail.Player())==20 and Mail.Recents(Mail.Player())[1].name=='FriendW Dawn','history retains newest 20 recipients')
check(panel.groups.recents.pageText.text=='1 / 4' and panel.groups.recents.next.enabled,'long history is paginated')
panel.groups.recents.next.scripts.OnClick()
check(panel.groups.recents.pageText.text=='2 / 4' and panel.groups.recents.rows[1].item.name=='FriendR Dawn','next page shows the next five records')
NativeSend('ClosedMailbox Dawn');SendMailFrame:Hide();Event('MAIL_CLOSED');Event('MAIL_SEND_SUCCESS')
check(not panel.shown and Mail.Recents(Mail.Player())[1].name=='ClosedMailbox Dawn','late success after closing still records the actual attempt')
SendMailFrame:Show();check(panel.shown,'returning to Send Mail restores the lists')
Event('PLAYER_REGEN_DISABLED')
check(not panel.shown,'combat event hides panel before the API lock flag updates')
local before=SendMailNameEditBox.text;altRow.scripts.OnClick(altRow,'LeftButton')
check(SendMailNameEditBox.text==before,'combat cannot fill a native field')
Event('PLAYER_REGEN_ENABLED');check(panel.shown,'leaving combat restores visible mail panel')
Event('PLAYER_LEAVING_WORLD');Mail.Apply();Event('MAIL_SHOW')
check(not panel.shown,'world leave remains suspended across settings and queued mail events')
Event('PLAYER_ENTERING_WORLD');check(panel.shown,'world return resumes from current native visibility')
local previousAlts=#Mail.Alts(Mail.Player())
altRow=panel.groups.alts.rows[1];altRow.scripts.OnClick(altRow,'RightButton')
check(#Mail.Alts(Mail.Player())==previousAlts-1 and panel.groups.alts.empty.shown,'alt can be forgotten and its empty state returns')
Mail.Initialize(saved)
check(#Mail.Recents(Mail.Player())==20 and hookCount==1,'reinitialization preserves data and does not duplicate native hooks')
module.db.mailRecipients=false;Mail.Apply()
check(not panel.shown and not next(controller.events),'disabling utility removes listeners and hides UI')
local recentCount=#Mail.Recents(Mail.Player())
NativeSend('DisabledRecipient Dawn');Event('MAIL_SEND_SUCCESS')
check(#Mail.Recents(Mail.Player())==recentCount,'disabled feature records no mail history')
name='DisabledAlt';guid='Player-123-D';Event('PLAYER_ENTERING_WORLD')
check(saved.mail.characters[Mail.Player().savedKey]==nil,'disabled feature learns no new characters')
name='Alice';guid='Player-123-A'
module.db.mailRecipients=true;Mail.Apply()
check(panel.shown and hookCount==1,'reenabling restores panel without another hook')
Event('PLAYER_REGEN_DISABLED');module.db.mailRecipients=false;Mail.Apply()
module.db.mailRecipients=true;Mail.Apply()
check(panel.shown,'reenabling after combat ended while disabled does not inherit a stale combat flag')
faction='Horde'
check(#Mail.Recents(Mail.Player())==0,'history is scoped to sending faction')
faction='Alliance';realmID=456
check(#Mail.Recents(Mail.Player())==0,'history is scoped to sending realm ID')
realmID=123
name='Spell';surname='Ward';guid='Player-123-SW';Event('PLAYER_ENTERING_WORLD')
name='Spell';surname='Axe';guid='Player-123-SA';Event('PLAYER_ENTERING_WORLD')
name='Alice';surname='Dawn';guid='Player-123-A';Event('PLAYER_ENTERING_WORLD')
local siblings={}
for _,item in ipairs(Mail.Alts(Mail.Player())) do siblings[item.name]=item end
check(siblings['Spell Ward'] and siblings['Spell Axe'] and siblings['Spell Ward'].key~=siblings['Spell Axe'].key,
    'alts sharing a first name remain distinct by their surnames')
local selected
for _,row in ipairs(panel.groups.alts.rows) do
    if type(row.item)=='table' and row.item.name=='Spell Ward' then selected=row end
end
selected.scripts.OnClick(selected,'LeftButton')
check(SendMailNameEditBox.text=='Spell Ward' and selected.label.height==24,
    'alt label and clicked recipient retain the surname within the existing row size')
realmID=secret;Mail.Apply()
check(not panel.shown and Mail.Player()==nil,'unreadable available realm ID cannot mix identical realm names')
realmID=123
local originalFullName=UnitFullName
local originalGetUnitName=GetUnitName
GetUnitName=function() return secret end
UnitFullName=function() return secret,surname end
Mail.Apply();check(not panel.shown and Mail.Player()==nil,'restricted identity hides suggestions without saving it')
UnitFullName=originalFullName;GetUnitName=originalGetUnitName
SendMailFrame:Hide();check(not panel.shown,'Send Mail hide hook clears own panel')
for _,frame in ipairs(frames) do check(frame.scripts.OnUpdate==nil,'mail utility never adds a poller') end
check(sends>0,'test exercised native send observations')
print('PASS: '..count..' mail-recipient checks')
