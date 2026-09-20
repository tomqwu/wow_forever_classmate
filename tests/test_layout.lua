local NS={}
assert(loadfile('addons/ForeverUtilities/Layout.lua'))('ForeverUtilities',NS)
local count=0
local function check(value,message) assert(value,message);count=count+1 end
-- Every combination of visible blocks must fit without overlap.
for mask=0,255 do
    local function on(bit) return math.floor(mask/2^bit)%2==1 end
    local db={showRange=on(0),petGuide=on(7),petHappinessWarning=on(6),aspectWarning=on(5),showAngle=on(1),markWarning=on(2),showTargetTarget=on(3),showLockButton=on(4)}
    local l=NS.Layout.Compute(db)
    check(l.width==400 and l.height==56,'fixed footprint')
    local last=l.range.x+l.range.width
    for _,key in ipairs({'combat','pet','control'}) do
        if l[key] then
            check(l[key].x>=last,'blocks do not overlap')
            last=l[key].x+l[key].width
        end
    end
    check(last<=400 and l.text.width>=196,'bounds and minimum text width')
    check(l.text.x+l.text.width<=l.range.x+l.range.width,'text stays in range block')
end
local full=NS.Layout.Compute({})
local minimal=NS.Layout.Compute({petGuide=false,petHappinessWarning=false,showAngle=false,markWarning=false,aspectWarning=false,showTargetTarget=false,showLockButton=false})
local guideOnly=NS.Layout.Compute({petGuide=true,petHappinessWarning=false,showTargetTarget=false})
check(guideOnly.pet and guideOnly.pet.width==48,'pet guide reserves its slot without portrait or mood')
check(minimal.text.width>full.text.width,'hidden blocks return text space')
local rows=NS.Layout.Rows(true)
check(-rows.range.y+rows.range.height<=-rows.intel.y,'range ends before intel')
check(-rows.intel.y+rows.intel.height<=-rows.ammo.y,'intel ends before ammo')
check(-rows.ammo.y+rows.ammo.height<=56,'all text rows fit in original height')
local normal=NS.Layout.Rows(false)
check(normal.range.height==26 and normal.ammo.y==-33,'nonmatch preserves original layout')
print('PASS: '..count..' block layout checks')
