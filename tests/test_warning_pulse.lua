local NS={}
assert(loadfile('addons/ForeverUtilities/Core.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
local methods={}
dofile('tests/mock_animation.lua')(methods)
local texture=setmetatable({alpha=1},{__index=methods})
function texture:SetAlpha(value) self.alpha=value end
local owner={hooks={}}
function owner:HookScript(event,fn) self.hooks[event]=fn end
local pulse=NS.Core.CreateWarningPulse(owner,texture)
pulse(false)
check(not texture.warningPulseGroup,'idle warnings allocate no animation group')
pulse(true)
local group=texture.warningPulseGroup
check(group.playing and group.looping=='REPEAT' and #group.animations==2,'warning uses a repeating native alpha animation')
check(group.animations[1].duration==0.65 and group.animations[2].duration==0.65
    and group.animations[1].from==0.25 and group.animations[2].to==0.25,'pulse remains visible and completes one cycle in 1.3 seconds')
for i=1,10 do pulse(true) end
check(group.plays==1,'repeated status updates do not restart the pulse')
texture.alpha=0.25;pulse(false)
check(not group.playing and texture.alpha==1,'clearing a warning stops animation and restores its static appearance')
pulse(true);owner.hooks.OnHide()
check(not group.playing and group.plays==2,'hiding the owner stops an active pulse')
pulse(false);check(group.stops==2,'repeated stop is harmless')
local static={SetAlpha=function() end}
local fallback=NS.Core.CreateWarningPulse(owner,static)
fallback(true);fallback(false)
check(not static.warningPulseGroup,'missing animation APIs leave the static warning usable')
print('PASS: '..count..' warning pulse checks')
