local _, NS = ...
local locale=NS.Core.Call(GetLocale)
NS.Locale=locale or 'enUS'
if locale~='zhCN' then return end

-- Only addon-authored wording belongs here. Spell and unit names still come
-- from the client's localized APIs; command names and saved keys stay stable.
local zh={
    ['Forever Classmate']='永恒战友',
    ['Hunter']='猎人',['Shaman']='萨满祭司',['Paladin']='圣骑士',['Warrior']='战士',
    ['Rogue']='潜行者',['Druid']='德鲁伊',['Mage']='法师',['Priest']='牧师',['Warlock']='术士',
    ['No target']='无目标',['Target dead']='目标已死亡',['Friendly target']='友方目标',
    ['Range unavailable']='距离不可用',['Melee']='近战',['Too close']='太近',
    ['Shooting']='射击范围内',['Too far']='太远',['Distance']='距离',
    ['Out of range']='超出射程',['Target']='目标',['Enemy']='敌人',
    ['Ready']='就绪',['None']='无',['Effect']='效果',['Ability']='技能',
    ['Racial']='种族技能',['Ctx']='条件不符',['Context']='条件不符',
    ['active']='生效中',['inactive']='未生效',['missing']='缺失',['unavailable']='不可用',
    ['ready']='就绪',['cooldown']='冷却中',['context']='条件不符',
    ['hidden']='已隐藏',['found']='已找到',['not found']='未找到',
    ['Shield']='护盾',['OK']='正常',['Form']='形态',['Base']='基础形态',
    ['On']='生效中',['Proc']='触发',['CD']='冷却',
    ['Mana']='法力',['Rage']='怒气',['Energy']='能量',['Power']='能量',
    ['Health']='生命值',['Soul Shards']='灵魂碎片',['Combo points']='连击点数',
    ['Armor']='护甲',['Seal']='圣印',['Shout']='战吼',['Judgment']='审判',
    ['Target effect']='目标效果',['Coatings / buffs']='武器附魔／增益',
    ['Finisher buff']='终结技增益',['Finisher / poison']='终结技／毒药',
    ['Nature buffs']='自然增益',['Damage setup']='伤害准备',
    ['Self buffs']='自身增益',['Target / healing']='目标／治疗',
    ['Armor / demon']='护甲／恶魔',['DoT / Bane']='持续伤害／灾祸',
    ['Mark of the Wild']='野性印记',['Thorns']='荆棘术',
    ['Inner Fire']='心灵之火',['Fortitude']='韧',['Divine Spirit']='神圣之灵',
    ['DoTs']='持续伤害',
    ['Loaded']='已加载',['opens settings.']='打开设置。',['Drag to move']='拖动以移动',
    [' more']=' 项未显示',['Name match']='名称匹配',[' guide']='指南',
    [' family guide']='家族指南',['Pet guide']='宠物指南',
    ['Level']='等级',['Wild level']='野外等级',['Family guide']='家族指南',
    ['Guide-listed family skill to verify']='待核实的家族技能',
    ['Possible rare origin']='可能来自稀有宠物',['Roster match']='名录匹配',
    ['Watch list']='关注名单',['Beta guide']='测试版指南',
    ['skill availability may change.']='技能信息可能变更。',
    ['Remaining']='剩余时间',['Totem lifetime']='图腾存续时间',
    ['Fire']='火',['Earth']='地',['Water']='水',['Air']='风',
    ['totem active']='图腾生效中',['element: no active totem']='元素：没有生效的图腾',
    ['(not cast cooldown)']='（并非法术冷却）',['CD']='冷却',
    ['Demon']='恶魔',['Weapon coatings']='武器附魔',
    ['no equipped weapons']='没有装备武器',['Total absorbs']='总吸收量',
    ['Total absorbs: amount displayed by client; value is restricted.']='总吸收量由客户端显示；插件无法读取数值。',
    ['amount displayed by client; value is restricted.']='数值由客户端显示；插件无法读取。',
    ['exact values unavailable']='精确数值不可用',
    ['last seen; current state unavailable']='上次确认；当前状态不可读取',
    ['CP']='连击',['H']='生命',['S']='碎片',
    ['Combo points']='连击点数',['Form or stance']='形态或姿态',
    ['% HP']='生命上限百分比',
    ['Group melee support']='团队近战辅助',['Single-target damage / stealth']='单目标伤害／潜行',
    ['Varies by individual pet']='因个体而异',['Solo multi-target fighting']='单刷群怪',
    ['Solo pulls / closing gaps']='单刷拉怪／快速近身',['PvP healing pressure']='PvP 治疗压制',
    ['Bleed-focused group support']='流血团队辅助',['PvP control / kiting']='PvP 控制／风筝',
    ['Bleed-focused damage']='流血伤害',['Physical-damage group support']='物理伤害团队辅助',
    ['Sustained poison pressure']='持续毒伤',['Solo pet survival']='单刷宠物生存',
    ['Mobile damage']='机动伤害',['Control against weapon users']='对持武器敌人的控制',
    ['Ranged Nature damage']='远程自然伤害',['Pressure against casters']='压制施法者',
    ['Short bursts / pet survival']='短时爆发／宠物生存',
    ['Party melee attack power buff.']='队伍近战攻击强度增益。',
    ['Direct damage; stealth approach when trained.']='直接伤害；学会潜行后可隐蔽接近。',
    ['Multi-target attack; bleed support.']='群体攻击与流血辅助。',
    ['Burst movement and a stronger opening attack.']='快速接近并强化起手攻击。',
    ['Damage with reduced healing received.']='造成伤害并降低目标受到的治疗。',
    ['Bleed damage and increased bleed damage taken.']='造成流血伤害并提高目标受到的流血伤害。',
    ['Damage with a movement slow.']='造成伤害并降低移动速度。',
    ['Area damage around the pet.']='对宠物周围造成范围伤害。',
    ['Armor reduction on the enemy.']='降低敌人的护甲。',
    ['Nature damage over time.']='持续造成自然伤害。',
    ['Defensive damage reduction.']='防御性减伤。',
    ['Direct damage and movement speed when trained.']='学会后提供直接伤害和移动速度。',
    ['Damage over time with a movement slow.']='持续伤害并降低移动速度。',
    ['Damage with a short disarm.']='造成伤害并短暂缴械。',
    ['Pet damage from outside melee range.']='宠物可在近战距离外造成伤害。',
    ['Fire damage and slower enemy casting; beta tame sources unconfirmed.']='火焰伤害并延缓敌方施法；测试版驯服来源未确认。',
    ['Temporary dodge and faster attacks; beta tame sources unconfirmed.']='暂时提高闪避和攻击速度；测试版驯服来源未确认。',
    ['Enable hunter bar']='启用猎人信息条',['Enable shaman bar']='启用萨满信息条',
    ['Show minimap settings button']='显示小地图设置按钮',
    ['Right-click minimap to inspect players']='右键小地图按钮观察玩家',
    ['Show lock button on bar']='在信息条上显示锁定按钮',
    ['Lock indicator position']='锁定信息条位置',['Indicator size']='信息条大小',
    ['Show target-of-target portrait']='显示目标的目标头像',
    ['Show facing angle']='显示朝向角度',['Show range text and weapon icon']='显示距离文字和武器图标',
    ['Icon-only range display']='仅显示距离图标',['Inspect button for player targets']='显示玩家观察按钮',
    ['Show ammo count']='显示弹药数量',['Low-ammo warning (200 or fewer)']='弹药不足提醒（200 发及以下）',
    ['Target pet guide / notable beasts']='目标宠物指南／特殊野兽',
    ['Pet happiness warning']='宠物快乐度提醒',['Pet portrait health warning (30%)']='宠物低血量提醒（30%）',
    ['Missing aspect reminder icon']='缺少守护提醒图标',
    ["Hunter's Mark reminder icon"]='猎人印记提醒图标',
    ['Dim outside combat']='脱离战斗时变淡',['Dim when idle outside combat']='脱战空闲时变淡',
    ['Show four-element totem timers']='显示四系图腾计时',
    ['Show main-hand weapon imbue']='显示主手武器附魔',
    ['Show elemental shield / missing warning']='显示元素护盾／缺失提醒',
    ['Show spec-aware combat helper']='显示专精战斗提示',
    ['Show mana percentage']='显示法力百分比',
    ['Suggest Totemic Recall after combat']='脱战后提示召回图腾',
    ['Show resources and stance/form']='显示资源及姿态／形态',
    ['Show class upkeep block']='显示职业增益区',
    ['Show target effect block']='显示目标效果区',
    ['Show learned ability readiness']='显示已学技能状态',
    ['Show learned racial readiness']='显示已学种族技能状态',
    ['Show multi-target DoT bars']='显示多目标持续伤害条',
    ['Show absorption shield']='显示吸收护盾',
    ['Reset settings']='重置设置',['Close']='关闭',
    ['Unlock bar to move']='解锁信息条以移动',['Lock bar position']='锁定信息条位置',
    ['Left-click: settings | Drag: move around minimap']='左键：设置｜拖动：移动小地图按钮',
    ['Right-click: inspect an eligible player target']='右键：观察可观察的玩家目标',
    ['No helper is available for this class yet.']='当前职业暂无可用助手。',
    ['Scale must be 0.5 to 2.']='缩放范围为 0.5 至 2。',
    ['Enabled']='已启用',['Disabled']='已停用',
    ['Hunter range, ammunition, pet care, and target awareness.']='猎人射程、弹药、宠物照护和目标信息。',
    ['Totems, weapon imbues, elemental shields, mana, and spec-aware combat cues.']='图腾、武器附魔、元素护盾、法力及战斗提示。',
    ['Mana, seal upkeep, judgments, learned combat abilities, and racial cooldowns.']='法力、圣印、审判、已学战斗技能及种族技能冷却。',
    ['Rage, stance, shout upkeep, target effects, reactive abilities, and racial cooldowns.']='怒气、姿态、战吼、目标效果、反应技能及种族技能冷却。',
    ['Energy, combo points, weapon coatings, finishers, target effects, and racial cooldowns.']='能量、连击点数、武器附魔、终结技、目标效果及种族技能冷却。',
    ['Current form and power, buff upkeep, target effects, learned spec cues, and racial cooldowns.']='当前形态与资源、增益、目标效果、专精提示及种族技能冷却。',
    ['Live mana meter, armor and absorption shield upkeep, personal damage effects, spec procs, and racial cooldowns.']='实时法力条、护甲与吸收护盾、伤害效果、触发效果及种族技能冷却。',
    ['Mana, self-buff upkeep, target effects, healing or Shadow cues, and Priest racials.']='法力、自身增益、目标效果、治疗或暗影提示及牧师种族技能。',
    ['Mana and health, armor and demon state, DoT or Bane upkeep, abilities, and racial cooldowns.']='法力与生命、护甲与恶魔状态、持续伤害或灾祸、技能及种族技能冷却。',
    ['Pet unhappy']='宠物不快乐',['Pet content — not fully happy']='宠物状态一般，尚未快乐',
    ['Feed your pet when safe.']='安全时喂养宠物。',
    ['Inspect player']='观察玩家',["Open the game's Inspect window for this target."]='打开游戏自带的目标观察窗口。',
    ['No elemental shield active']='没有生效的元素护盾',
    ['Main-hand weapon imbue active']='主手武器附魔生效中',
    ['Main-hand weapon imbue missing']='主手武器缺少附魔',
    ['Estimated from this spell\'s last readable duration.']='根据此法术上次可读取的持续时间估算。',
    ['Last readable state; live combat data unavailable.']='显示上次可读取的状态；战斗中的实时数据不可用。',
    ['Cast observed; timer unavailable until duration is learned.']='已观察到施放；尚未获取持续时间，无法显示计时。',
    ['Fire Nova requires an active Fire totem.']='火焰新星需要一个生效的火系图腾。',
    ['Flame Shock!']='施放烈焰震击！',['Lava Burst ready']='熔岩爆裂就绪',
    ['Lava Burst: context']='熔岩爆裂：条件不符',
    ['Riptide ready']='激流就绪',['Riptide: context']='激流：条件不符',
    ['Riptide']='激流',['Lava Burst']='熔岩爆裂',['Maelstrom']='漩涡武器',
    ['Flame']='烈焰震击',['Recall']='召回图腾',['Totems']='图腾',
    ['Percentage is displayed by the client; exact values are restricted.']='百分比由客户端显示；精确数值受限。',
    ['The client did not expose a readable resource value.']='客户端未提供可读取的资源数值。',
    ['The client did not permit a readable resource percentage.']='客户端未允许读取资源百分比。',
    ['Shield active; absorb amount unavailable.']='护盾已生效；吸收量不可用。',
    ['Includes all active absorb effects; original shield capacity is not exposed.']='包含全部生效的吸收效果；无法获取护盾初始容量。',
    ['No tracked effect from you is active.']='目标身上没有你施加的已追踪效果。',
    ['Racial ability']='种族技能',['Mage armor and absorbs']='法师护甲与吸收效果',
    ['Live readable player resource state.']='实时可读取的玩家资源状态。',
    ['Shows learned upkeep from your current auras or equipped weapon coatings.']='显示当前增益或已装备武器上的附魔。',
    ['Tracks your readable target effects.']='追踪可读取的目标效果。',
    ['Tracks a readable proc or learned usable ability.']='追踪可读取的触发效果或已学技能。',
    ['The learned active racial with its real cooldown and current usability. Context means the game reports it unusable now.']='显示已学种族技能的冷却与可用性；“条件不符”表示游戏当前判定无法使用。',
    ['No guide-listed family skill here.']='指南中没有此宠物家族的技能。',
    ['Actual abilities of this individual target are unknown.']='无法确认这只宠物实际学会了哪些技能。',
    ['Name + family match only; a renamed pet can have the same name.']='仅名称和家族匹配；改名宠物也可能同名。',
    ['Above your level — cannot tame yet.']='高于你的等级，目前无法驯服。',
    ['Player-controlled pet. This guide cannot read its learned skills or confirm wild origin.']='玩家控制的宠物：指南无法读取其已学技能或确认野外来源。',
    ['Family guide only. Use Beast Lore to check tameability and actual skills.']='仅供家族参考；请用野兽知识确认是否可驯服及实际技能。',
    ['Family guide only. Ownership, tameability, and learned skills are not confirmed.']='仅供家族参考；所有权、驯服条件和已学技能均未确认。',
    ['Normal']='普通',['Rare']='稀有',['Elite']='精英',['Rare elite']='稀有精英',
    ['Boss']='首领',['Trivial']='低等级',['Minor']='弱小',
    ['Wolf']='狼',['Cat']='猫科',['Spider']='蜘蛛',['Bear']='熊',['Boar']='野猪',
    ['Crocolisk']='鳄鱼',['Carrion Bird']='食腐鸟',['Crab']='螃蟹',['Gorilla']='猩猩',
    ['Raptor']='迅猛龙',['Tallstrider']='陆行鸟',['Scorpid']='蝎子',['Turtle']='乌龟',
    ['Bat']='蝙蝠',['Hyena']='土狼',['Owl / Bird of Prey']='猫头鹰／猛禽',
    ['Wind Serpent']='风蛇',['Core Hound']='熔火恶犬',['Fox']='狐狸',
}

local function Translate(text)
    if type(text)~='string' then return text end
    if zh[text] then return zh[text] end
    local class=text:match('^Forever Classmate — (.+)$')
    if class then return zh['Forever Classmate']..' — '..Translate(class) end
    local enabled=text:match('^Enable (.+) bar$')
    if enabled then return '启用'..Translate(enabled:gsub('^%l',string.upper))..'信息条' end
    local left,right=text:match('^(.-) | (.+)$')
    if left then return Translate(left)..' | '..Translate(right) end
    local amount=text:match('^Ammo: (%d+)$')
    if amount then return '弹药：'..amount end
    amount=text:match('^Low ammo — (%d+) remaining!$')
    if amount then return '弹药不足——剩余 '..amount..' 发！' end
    local yards=text:match('^([<>~=%.%d%-]+) yd$')
    if yards then return yards..' 码' end
    local level=text:match('^Level (%d+)$')
    if level then return '等级 '..level end
    level=text:match('^Wild level (.+)$')
    if level then return '野外等级 '..level end
    local estimate,number,unit=text:match('^(~?)(%d+)([sm])$')
    if number then return estimate..number..(unit=='s' and '秒' or '分') end
    local unitName,elementState=text:match('^(%a+) (totem active)$')
    if unitName then return Translate(unitName)..'系'..Translate(elementState) end
    unitName,elementState=text:match('^(%a+) (element: no active totem)$')
    if unitName then return Translate(unitName)..'系'..Translate(elementState) end
    local seconds=text:match('^Totem lifetime: (.+) %(not cast cooldown%)$')
    if seconds then return '图腾存续时间：'..Translate(seconds)..'（并非法术冷却）' end
    local count=text:match('^Mana (%d+)%%$')
    if count then return '法力 '..count..'%' end
    local label,percent=text:match('^(.-): (%d+)%% %(exact values unavailable%)$')
    if label then return Translate(label)..'：'..percent..'%（精确数值不可用）' end
    count=text:match('^CP(%d+)$')
    if count then return '连击'..count end
    count=text:match('^H(%d+)$')
    if count then return '生命'..count end
    count=text:match('^S(%d+)$')
    if count then return '碎片'..count end
    count=text:match('^Maelstrom (%d+)/5$')
    if count then return '漩涡 '..count..'/5' end
    count=text:match('^MW (%d+)/5$')
    if count then return '漩涡 '..count..'/5' end
    count=text:match('^Recall (%d+) totems?$')
    if count then return '召回 '..count..' 个图腾' end
    count=text:match('^Recall (%d+)$')
    if count then return '召回 '..count end
    count=text:match('^(%d+)/4 totems$')
    if count then return count..'/4 图腾' end
    count=text:match('^(%d+) active totems?$')
    if count then return count..' 个生效图腾' end
    local category,number,total=text:match('^(.-): (%d+) / (%d+)$')
    if category then return Translate(category)..'：'..number..' / '..total end
    category,number=text:match('^(.-): (%d+)%%$')
    if category then return Translate(category)..'：'..number..'%' end
    local title,name=text:match('^(Pet guide): (.+)$')
    if title then return Translate(title)..'：'..name end
    local family,role=text:match('^(Family guide): (.+)$')
    if family then return Translate(family)..'：'..Translate(role) end
    local skill=text:match('^Guide%-listed family skill to verify: (.+)$')
    if skill then return Translate('Guide-listed family skill to verify')..'：'..skill end
    local familyName,level=text:match('^(.-) | Level (%d+)$')
    if familyName then return Translate(familyName)..' | 等级 '..level end
    local prefix,reference=text:match('^(Possible rare origin): (.+)$')
    if not prefix then prefix,reference=text:match('^(Roster match): (.+)$') end
    if not prefix then prefix,reference=text:match('^(Watch list): (.+)$') end
    if prefix then return Translate(prefix)..'：'..reference end
    local version=text:match('^Beta guide (.-); skill availability may change%.$')
    if version then return '测试版指南 '..version..'；技能信息可能变更。' end
    local hp=text:match('^(%d+)%% HP$')
    if hp then return hp..'% 生命上限' end
    local absorbs,coverage=text:match('^Total absorbs: (%d+) %((%d+)%% of max health%)$')
    if absorbs then return '总吸收量：'..absorbs..'（生命上限的 '..coverage..'%）' end
    absorbs=text:match('^Total absorbs: (%d+)$')
    if absorbs then return '总吸收量：'..absorbs end
    local coatingActive,coatingTotal=text:match('^Weapon coatings: (%d+) / (%d+) active$')
    if coatingActive then return '武器附魔：'..coatingActive..' / '..coatingTotal..' 生效' end
    local seenName=text:match('^(.-) last seen; current state unavailable$')
    if seenName then return seenName..' 上次确认；当前状态不可读取' end
    local lower,upper,limit=text:match('^(.-): (%d+) / (%d+) active$')
    if lower then return Translate(lower)..'：'..upper..' / '..limit..' 生效' end
    local ability,time=text:match('^(Lava Burst) (.+)$')
    if not ability then ability,time=text:match('^(Riptide) (.+)$') end
    if ability then return Translate(ability)..' '..Translate(time) end
    ability,time=text:match('^(Flame) (.+)$')
    if ability then return Translate(ability)..' '..Translate(time) end
    local prefix,suffix=text:match('^(.-): (.+)$')
    if prefix then
        local translated=Translate(prefix)
        local translatedSuffix=Translate(suffix)
        if translated~=prefix or translatedSuffix~=suffix then return translated..'：'..translatedSuffix end
    end
    local name,state=text:match('^(.-) — (.+)$')
    if name then return name..' — '..Translate(state) end
    local spell,timer=text:match('^(.-) (~?%d+[sm])$')
    if spell then return spell..' '..Translate(timer) end
    spell=text:match('^(.-) active$')
    if spell then return spell..' 生效中' end
    local base=text:match('^(.-) resources$')
    if base then return Translate(base)..'资源' end
    base=text:match('^(.-) ability$')
    if base then return Translate(base)..'技能' end
    return text
end
NS.L=Translate
