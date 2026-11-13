local _,NS=...
local Core=NS.Core
local Mail={}
NS.MailRecipients=Mail
local db,controller,panel,owner,pending
local active,hooked,suspended,closed,combatBlocked=false,false,false,false,false
local pageSize=5

local function String(value)
    return Core.IsReadable(value) and type(value)=='string' and value~='' and #value<=160
        and not value:find('[%c|;:/\\@%[%]{}<>]') and value or nil
end
local function Realm(value)
    value=String(value)
    return value and value:gsub('%s+','') or nil
end
function Mail.Recipient(value)
    value=String(value)
    if not value then return nil end
    value=value:match('^%s*(.-)%s*$')
    local key=value:gsub('[ %-]+',' '):match('^%s*(.-)%s*$')
    if not key:match('^%S+ %S+') then return nil end
    -- A native Forever address contains both name parts. A hyphen is not
    -- evidence of a realm suffix. Preserve the complete observed address.
    return {name=value,address=value,key=key:lower()}
end
-- Class, level and gold are the character's own, saved at login and on level
-- or money changes. Mail contents and amounts sent are never read or stored.
local classNames={WARRIOR='Warrior',PALADIN='Paladin',HUNTER='Hunter',ROGUE='Rogue',PRIEST='Priest',
    SHAMAN='Shaman',MAGE='Mage',WARLOCK='Warlock',DRUID='Druid'}
Mail.ClassNames=classNames
function Mail.FormatGold(copper)
    if not Core.IsNumber(copper) or copper<0 then return nil end
    local gold=tostring(math.floor(copper/10000))
    -- Thousands separators keep large balances readable.
    gold=gold:reverse():gsub('(%d%d%d)','%1,'):reverse():gsub('^,','')
    return gold..'|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t'
end
local function Scope(player)
    return (player.realmID and ('id:'..player.realmID) or ('realm:'..player.realm:lower()))..'/'..player.faction
end
function Mail.Player()
    local recipient=Mail.Recipient(Core.Call(GetUnitName,'player'))
    if not recipient then
        -- In Forever the second tuple value is a surname, not a realm.
        local first,last=Core.Call(UnitFullName,'player')
        if String(first) and String(last) then recipient=Mail.Recipient(first..' '..last) end
    end
    local realm=Realm(Core.Call(GetNormalizedRealmName)) or Realm(Core.Call(GetRealmName))
    local faction=Core.Call(UnitFactionGroup,'player')
    if not recipient or not realm or realm=='' or (faction~='Alliance' and faction~='Horde') then return nil end
    local realmID=Core.Call(GetRealmID)
    if type(GetRealmID)=='function' and (not Core.IsNumber(realmID) or realmID<=0) then return nil end
    recipient.realm=realm;recipient.fullName=true
    recipient.realmID=Core.IsNumber(realmID) and realmID>0 and realmID or nil
    recipient.faction=faction;recipient.scope=Scope(recipient)
    recipient.savedKey=recipient.scope..'/'..recipient.key
    recipient.guid=String(Core.Call(UnitGUID,'player'))
    local _,classToken=Core.Call(UnitClass,'player')
    recipient.class=classNames[classToken] and classToken or nil
    local level=Core.Call(UnitLevel,'player')
    recipient.level=Core.IsNumber(level) and level>=1 and level<=100 and math.floor(level) or nil
    local money=Core.Call(GetMoney)
    recipient.money=Core.IsNumber(money) and money>=0 and math.floor(money) or nil
    return recipient
end
local function SameRealm(a,b)
    if a.realmID~=nil or b.realmID~=nil then
        return Core.IsNumber(a.realmID) and Core.IsNumber(b.realmID) and a.realmID==b.realmID
    end
    return a.realm:lower()==b.realm:lower()
end
local function Enabled()
    local module=NS.ActiveClass()
    return db~=nil and module and module.db and module.db.mailRecipients~=false
end
local function OutOfCombat()
    if combatBlocked then return false end
    if type(InCombatLockdown)=='function' then return Core.Call(InCombatLockdown)==false end
    return Core.Call(UnitAffectingCombat,'player')==false
end
local function RememberPlayer(level)
    if not Enabled() or suspended or not OutOfCombat() then return end
    local player=Mail.Player()
    if not player then return end
    -- PLAYER_LEVEL_UP carries the new level before UnitLevel catches up.
    if Core.IsNumber(level) and level>=1 and level<=100 then player.level=math.floor(level) end
    for key,record in pairs(db.characters) do
        if type(record)=='table' and player.guid and record.guid==player.guid and key~=player.savedKey then
            db.characters[key]=nil
        end
    end
    db.characters[player.savedKey]=player
end
function Mail.Alts(player)
    local result,seen={},{}
    if not db or not player then return result end
    for key,record in pairs(db.characters) do
        if type(record)=='table' and record.fullName==true then
            local item=Mail.Recipient(record.address or record.name)
            local realm=Realm(record.realm)
            if item and realm and realm~='' and record.faction==player.faction and SameRealm({realm=realm,realmID=record.realmID},player)
                and item.key~=player.key and not seen[item.key] then
                seen[item.key]=true;item.savedKey=key
                item.class=classNames[record.class] and record.class or nil
                item.level=Core.IsNumber(record.level) and record.level or nil
                item.money=Core.IsNumber(record.money) and record.money>=0 and record.money or nil
                result[#result+1]=item
            end
        end
    end
    table.sort(result,function(a,b) return a.key<b.key end)
    return result
end
function Mail.Recents(player)
    local result,seen={},{}
    if not db or not player or type(db.recents[player.scope])~='table' then return result end
    for _,address in ipairs(db.recents[player.scope]) do
        local item=Mail.Recipient(address)
        if item and item.key~=player.key and not seen[item.key] then
            seen[item.key]=true;result[#result+1]=item
            if #result==20 then break end
        end
    end
    return result
end
local function RecordRecent(attempt)
    local entries={attempt.recipient.address}
    for _,item in ipairs(Mail.Recents(attempt.player)) do
        if item.key~=attempt.recipient.key and #entries<20 then entries[#entries+1]=item.address end
    end
    db.recents[attempt.player.scope]=entries
end
local function Forget(kind,item,player)
    if kind=='alts' then db.characters[item.savedKey]=nil
    else
        local entries={}
        for _,entry in ipairs(Mail.Recents(player)) do
            if entry.key~=item.key then entries[#entries+1]=entry.address end
        end
        db.recents[player.scope]=entries
    end
end
local function Public(frame)
    return Core.IsReadable(frame) and (type(frame)=='table' or type(frame)=='userdata')
        and type(frame.IsForbidden)=='function' and Core.Call(frame.IsForbidden,frame)==false
end
local function Visible(frame)
    return Public(frame) and Core.Call(frame.IsVisible,frame)==true
end
local function Hide()
    if panel then
        panel:Hide()
        if GameTooltip then
            for _,group in pairs(panel.groups) do
                for _,row in ipairs(group.rows) do
                    if GameTooltip:IsOwned(row) then GameTooltip:Hide() end
                end
            end
        end
    end
end
local function Fill(item,player)
    if not Enabled() or suspended or closed or pending~=nil or not OutOfCombat() or not Visible(owner) then return end
    local edit=SendMailNameEditBox
    if not Public(edit) or Core.Call(edit.IsEnabled,edit)~=true or type(edit.SetText)~='function' then return end
    if pcall(edit.SetText,edit,item.address) then Core.Call(edit.ClearFocus,edit) end
end
local function Text(parent,value,x,y,width,height)
    local label=parent:CreateFontString(nil,'OVERLAY','GameFontHighlightSmall')
    label:SetPoint('TOPLEFT',parent,'TOPLEFT',x,y);label:SetSize(width,height or 16)
    label:SetJustifyH('LEFT');label:SetText(NS.L(value));return label
end
local Refresh
local function CreatePanel()
    panel=CreateFrame('Frame','ForeverClassmateMailRecipients',owner)
    panel:SetSize(220,440);panel:SetPoint('TOPLEFT',owner,'TOPRIGHT',8,-34)
    panel:SetFrameStrata('DIALOG');panel:SetClampedToScreen(true);panel:EnableMouse(true)
    local edge=panel:CreateTexture(nil,'BACKGROUND');edge:SetAllPoints();edge:SetColorTexture(0.5,0.4,0.19,1)
    local bg=panel:CreateTexture(nil,'BORDER');bg:SetPoint('TOPLEFT',1,-1);bg:SetPoint('BOTTOMRIGHT',-1,1);bg:SetColorTexture(0.035,0.04,0.055,0.98)
    Text(panel,'Mail recipients',12,-12,196):SetTextColor(1,0.82,0.3)
    Text(panel,'Click: use name. Right-click: forget.',12,-410,196,26)
    panel.groups={}
    for index,definition in ipairs({{key='alts',title='Alts',empty='Log into each alt once with Classmate enabled.'},
        {key='recents',title='Recent recipients',empty='Recipients appear after successful mail sends.'}}) do
        local y=-40-(index-1)*183
        Text(panel,definition.title,12,y,196):SetTextColor(1,0.82,0.3)
        local group={page=1,rows={}}
        if definition.key=='alts' then
            -- Gold across this character and its listed alts on the realm.
            group.total=Text(panel,'',100,y,108);group.total:SetJustifyH('RIGHT')
        end
        panel.groups[definition.key]=group
        group.empty=Text(panel,definition.empty,12,y-24,196,96);group.empty:SetJustifyV('TOP')
        for rowIndex=1,pageSize do
            local row=CreateFrame('Button',nil,panel)
            row:SetSize(196,24);row:SetPoint('TOPLEFT',panel,'TOPLEFT',12,y-22-(rowIndex-1)*25)
            row:RegisterForClicks('LeftButtonUp','RightButtonUp')
            local hover=row:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(1,0.8,0.3,0.18)
            row.label=Text(row,'',6,0,184,24);row.label:SetWordWrap(true)
            -- Alt rows: class crest, class-colored name, then level and gold.
            row.icon=row:CreateTexture(nil,'ARTWORK');row.icon:SetSize(18,18);row.icon:SetPoint('LEFT',row,'LEFT',4,0);row.icon:Hide()
            row.detail=row:CreateFontString(nil,'OVERLAY','GameFontDisableSmall')
            row.detail:SetPoint('TOPLEFT',row,'TOPLEFT',26,-12);row.detail:SetSize(166,12);row.detail:SetJustifyH('LEFT');row.detail:Hide()
            row:SetScript('OnClick',function(self,button)
                local player=Mail.Player()
                if not Enabled() or not self.item or not player or pending~=nil or not OutOfCombat() then return end
                if button=='RightButton' then Forget(definition.key,self.item,player);Refresh()
                else Fill(self.item,player) end
            end)
            row:SetScript('OnEnter',function(self)
                if GameTooltip and self.item then
                    GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetText(self.item.address)
                    local item=self.item
                    if item.level or item.class then
                        local who=(item.level and (NS.L('Level')..' '..item.level) or '')
                            ..(item.class and ((item.level and ' ' or '')..NS.L(classNames[item.class])) or '')
                        GameTooltip:AddLine(who,0.85,0.9,1)
                    end
                    local gold=Mail.FormatGold(item.money)
                    if gold then GameTooltip:AddLine(gold,1,0.85,0.4) end
                    if item.level or item.money then GameTooltip:AddLine(NS.L('As of that character\'s last login'),0.7,0.7,0.7,true) end
                    GameTooltip:AddLine(NS.L('Click: use name. Right-click: forget.'),1,1,1,true);GameTooltip:Show()
                end
            end)
            row:SetScript('OnLeave',function() if GameTooltip then GameTooltip:Hide() end end)
            group.rows[rowIndex]=row
        end
        group.pageText=Text(panel,'',70,y-156,90)
        for _,direction in ipairs({-1,1}) do
            local button=CreateFrame('Button',nil,panel,'UIPanelButtonTemplate')
            button:SetSize(28,20);button:SetPoint('TOPLEFT',panel,'TOPLEFT',direction==-1 and 12 or 180,y-150)
            button:SetText(direction==-1 and '<' or '>')
            button:SetScript('OnClick',function() group.page=group.page+direction;Refresh() end)
            if direction==-1 then group.previous=button else group.next=button end
        end
    end
end
Refresh=function()
    if not Enabled() or suspended or closed or not OutOfCombat() or not Visible(owner) then Hide();return end
    local player=Mail.Player()
    if not player then Hide();return end
    if not panel then CreatePanel() end
    for kind,group in pairs(panel.groups) do
        local entries=kind=='alts' and Mail.Alts(player) or Mail.Recents(player)
        local pages=math.max(1,math.ceil(#entries/pageSize))
        group.page=math.max(1,math.min(group.page,pages))
        group.empty:SetShown(#entries==0)
        group.pageText:SetText(string.format('%d / %d',group.page,pages))
        group.previous:SetEnabled(group.page>1);group.next:SetEnabled(group.page<pages)
        for index,row in ipairs(group.rows) do
            local item=entries[(group.page-1)*pageSize+index]
            row.item=item;row:SetShown(item~=nil);row:SetEnabled(pending==nil)
            if item then
                local rich=kind=='alts' and (item.class or item.level or item.money)
                row.icon:SetShown(rich and item.class~=nil)
                if rich and item.class then row.icon:SetTexture('Interface\\AddOns\\ForeverUtilities\\Textures\\Classes\\'..item.class) end
                row.label:ClearAllPoints()
                if rich then
                    row.label:SetPoint('TOPLEFT',row,'TOPLEFT',26,0);row.label:SetSize(166,12);row.label:SetWordWrap(false)
                    local c=item.class and NS.Folded and NS.Folded.ClassColors[item.class]
                    if c then row.label:SetTextColor(c[1],c[2],c[3]) else row.label:SetTextColor(1,1,1) end
                    local parts={}
                    if item.level then parts[#parts+1]=NS.L('Level')..' '..item.level end
                    local gold=Mail.FormatGold(item.money)
                    if gold then parts[#parts+1]=gold end
                    row.detail:SetText(table.concat(parts,'  '));row.detail:Show()
                else
                    row.label:SetPoint('TOPLEFT',row,'TOPLEFT',6,0);row.label:SetSize(184,24);row.label:SetWordWrap(true)
                    row.label:SetTextColor(1,1,1);row.detail:Hide()
                end
                row.label:SetText(item.name)
            end
        end
        if group.total then
            local sum=player.money
            if sum then for _,alt in ipairs(entries) do sum=sum+(alt.money or 0) end end
            group.total:SetText(sum and (NS.L('Total')..' '..Mail.FormatGold(sum)) or '')
        end
    end
    panel:Show()
end
local function Bind()
    if owner then return end
    local frame=SendMailFrame
    if not Public(frame) or type(frame.HookScript)~='function' then return end
    if not pcall(frame.HookScript,frame,'OnShow',function() closed=false;Refresh() end) then return end
    owner=frame
    Core.Call(frame.HookScript,frame,'OnHide',Hide)
    controller:UnregisterEvent('ADDON_LOADED')
end
local function HookSend()
    if hooked or type(SendMail)~='function' or type(hooksecurefunc)~='function' then return end
    hooked=pcall(hooksecurefunc,'SendMail',function(recipient)
        if not Enabled() or suspended or not OutOfCombat() then return end
        -- Overlapping send attempts cannot be associated safely with a single
        -- success event. Omit history rather than attribute it to a guessed name.
        if pending~=nil then pending=false;Refresh();return end
        local player=Mail.Player()
        local item=player and Mail.Recipient(recipient)
        pending=item and {player=player,recipient=item} or false
        Refresh()
    end)
end
local events={'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_LEAVING_WORLD','MAIL_SHOW','MAIL_CLOSED',
    'MAIL_SEND_SUCCESS','MAIL_FAILED','SECURE_TRANSFER_CANCEL','ADDON_LOADED','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED',
    'PLAYER_LEVEL_UP','PLAYER_MONEY'}
local function OnEvent(_,event,name)
    if not Enabled() then Hide();return end
    if event=='PLAYER_LEAVING_WORLD' then suspended=true;pending=nil;Hide();return end
    if event=='MAIL_SEND_SUCCESS' then
        local attempt=pending;pending=nil
        if Enabled() and type(attempt)=='table' then RecordRecent(attempt) end
    elseif event=='MAIL_FAILED' or event=='SECURE_TRANSFER_CANCEL' then pending=nil
    elseif event=='MAIL_CLOSED' then closed=true
    -- An attempt still pending from an earlier visit got no result event; it
    -- can no longer be matched to a success, so it is dropped.
    elseif event=='MAIL_SHOW' then closed=false;pending=nil
    elseif event=='PLAYER_ENTERING_WORLD' or event=='PLAYER_LOGIN' then suspended=false;RememberPlayer()
    elseif event=='PLAYER_REGEN_DISABLED' then combatBlocked=true
    elseif event=='PLAYER_REGEN_ENABLED' then combatBlocked=false;RememberPlayer()
    elseif event=='PLAYER_LEVEL_UP' then RememberPlayer(name)
    elseif event=='PLAYER_MONEY' then RememberPlayer()
    elseif event=='ADDON_LOADED' and (not Core.IsReadable(name) or name~='Blizzard_MailFrame') then return end
    Bind();HookSend();Refresh()
end
function Mail.Apply()
    if not Enabled() then
        if controller and active then for _,event in ipairs(events) do controller:UnregisterEvent(event) end end
        active=false;pending=nil;suspended=false;closed=false;combatBlocked=false;Hide();return
    end
    if not controller then
        controller=CreateFrame('Frame');controller:SetScript('OnEvent',OnEvent)
    end
    if not active then
        for _,event in ipairs(events) do controller:RegisterEvent(event) end
        if owner then controller:UnregisterEvent('ADDON_LOADED') end
        active=true
    end
    if suspended then Hide();return end
    RememberPlayer();Bind();HookSend();Refresh()
end
function Mail.Initialize(saved)
    if type(saved.mail)~='table' then saved.mail={} end
    db=saved.mail
    if type(db.characters)~='table' then db.characters={} end
    if type(db.recents)~='table' then db.recents={} end
    if db.nameFormat~=2 then
        -- 0.30.0 appended a supposed realm to incomplete names. Those strings
        -- cannot recover a surname safely; retain them outside active history.
        if next(db.recents) then db.legacyRecents=db.recents end
        db.recents={};db.nameFormat=2
    end
    Mail.Apply()
end
