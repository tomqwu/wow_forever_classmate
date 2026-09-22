local _, NS = ...
local function Normalize(db)
    for key,default in pairs({x=0,y=-210,scale=1,minimapAngle=35}) do
        if not NS.Core.IsNumber(db[key]) then db[key]=default end
    end
    db.minimapAngle=db.minimapAngle%360
    db.x=math.max(-5000,math.min(5000,db.x))
    db.y=math.max(-5000,math.min(5000,db.y))
    db.scale=math.max(0.5,math.min(2,db.scale))
end
NS.Hunter = {
    name="Forever Classmate — Hunter",
    description='Hunter range, ammunition, pet care, and target awareness.',
    command='/fhunter',enableLabel='Enable hunter bar',width=NS.ClassBarWidth,height=function(db) return NS.TargetContext.Height(db) end,
    frameName='ForeverUtilitiesDistanceFrame',lockName='ForeverHunterFriendLock',
    panelName='ForeverHunterFriendOptions',minimapName='ForeverHunterFriendMinimap',
    defaults={enabled=true,locked=true,x=0,y=-210,scale=1,showTargetTarget=true,showAngle=true,showRange=true,showAmmo=true,lowAmmoWarning=true,petMendWarning=true,petHappinessWarning=true,petGuide=true,markWarning=true,aspectWarning=true,fadeOutOfCombat=true,showMinimap=true,showLockButton=true,minimapAngle=35}, normalize=Normalize,
    options={
        {key='showMinimap',label='Show minimap settings button',kind='toggle'},
        {key='showLockButton',label='Show lock button on bar',kind='toggle'},
        {key='locked',label='Lock indicator position',kind='toggle'},
        {key='scale',label='Indicator size',kind='number',min=0.5,max=2,step=0.1},
        {key='showTargetTarget',label='Show target-of-target portrait',kind='toggle'},
        {key='showAngle',label='Show facing angle',kind='toggle'},
        {key='showRange',label='Show range text and weapon icon',kind='toggle'},
        {key='showAmmo',label='Show ammo count',kind='toggle'},
        {key='lowAmmoWarning',label='Low-ammo warning (200 or fewer)',kind='toggle'},
        {key='petGuide',label='Target pet guide / notable beasts',kind='toggle'},
        {key='petHappinessWarning',label='Pet happiness warning',kind='toggle'},
        {key='petMendWarning',label='Pet portrait health warning (30%)',kind='toggle'},
        {key='aspectWarning',label='Missing aspect reminder icon',kind='toggle'},
        {key='markWarning',label="Hunter's Mark reminder icon",kind='toggle'},
        {key='fadeOutOfCombat',label='Dim outside combat',kind='toggle'},
    },

}

local Hunter=NS.Hunter
function Hunter.create(db)
    return NS.ClassHost.Create(Hunter,db,function(host) return NS.Range.Create(host,db) end)
end
function Hunter.Initialize(saved)
    local old=type(saved.modules)=='table' and saved.modules.distance or saved
    if type(saved.hunter)~='table' then
        saved.hunter={}
        if type(old)=='table' then
            for key in pairs(Hunter.defaults) do saved.hunter[key]=old[key] end
        end
    end
    Hunter.db=saved.hunter
    for key,value in pairs(Hunter.defaults) do
        if type(Hunter.db[key])~=type(value) then Hunter.db[key]=value end
    end
    saved.schemaVersion=3
    Hunter.Apply()
end
function Hunter.IsHunter()
    if type(UnitClass)~='function' then return false end
    local ok,_,class=pcall(UnitClass,'player')
    return ok and NS.Core.IsReadable(class) and class=='HUNTER'
end
function Hunter.Apply()
    Normalize(Hunter.db)
    if Hunter.IsHunter() and Hunter.db.enabled and not Hunter.instance then
        Hunter.instance=Hunter.create(Hunter.db)
    end
    if Hunter.instance then Hunter.instance.Apply() end
    if Hunter.changed then Hunter.changed() end
end
function Hunter.SetEnabled(enabled)
    Hunter.db.enabled=enabled;Hunter.Apply()
end
function Hunter.Reset()
    for key,value in pairs(Hunter.defaults) do Hunter.db[key]=value end
    Hunter.Apply()
end
NS.RegisterClass('HUNTER',Hunter)
