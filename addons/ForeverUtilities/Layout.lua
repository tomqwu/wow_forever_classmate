local _, NS = ...
local Layout={}
NS.Layout=Layout
-- Stable slots while playing. Only preference changes redistribute space.
function Layout.Compute(db)
    local result={width=NS.ClassBarWidth or 213,height=NS.ClassBarHeight or 56}
    local right=result.width-6
    local function Reserve(key,width,enabled)
        if enabled then
            right=right-width
            result[key]={x=right,width=width}
        end
    end
    Reserve('control',20,db.showLockButton~=false)
    Reserve('pet',38,db.showTargetTarget~=false or db.petHappinessWarning~=false or db.petGuide~=false)
    Reserve('combat',36,db.markWarning~=false or db.aspectWarning~=false or db.showAngle~=false)
    result.range={x=4,width=right-4}
    result.text={x=db.showRange~=false and 34 or 8,width=0}
    result.text.width=right-3-result.text.x
    return result
end

-- Text rows share the original bar footprint; only a matching target needs intel.
function Layout.Rows(hasIntel)
    if hasIntel then
        return {range={y=-3,height=20},intel={y=-23,height=16},ammo={y=-39,height=14}}
    end
    return {range={y=-6,height=26},intel={y=-23,height=16},ammo={y=-33,height=14}}
end
