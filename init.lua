
-- Cache globals
local aura_env = aura_env

local abs = abs
local AuraUtil = AuraUtil
local ForEachAura = AuraUtil.ForEachAura
local BigWigs = BigWigs
local BigWigsLoader = BigWigsLoader
local BW_RegisterMessage = ( BigWigsLoader and BigWigsLoader.RegisterMessage ) or nil
local C_PaperDollInfo = C_PaperDollInfo
local GetStaggerPercentage = C_PaperDollInfo.GetStaggerPercentage
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local GetDodgeChance = GetDodgeChance
local GetInventoryItemLink = GetInventoryItemLink
local GetItemStats = GetItemStats
local GetMasteryEffect = GetMasteryEffect
local getmetatable = getmetatable
local GetParryChance = GetParryChance
local GetSpecialization = GetSpecialization
local GetSpellBaseCooldown = GetSpellBaseCooldown
local GetSpellCharges = GetSpellCharges
local GetSpellCooldown = GetSpellCooldown
local GetSpellCount = GetSpellCount
local GetSpellDescription = GetSpellDescription
local GetSpellInfo = GetSpellInfo
local GetSpellPowerCost = GetSpellPowerCost
local _GetTime = GetTime
local GetTime = function()
    return aura_env.frameTime or _GetTime()
end
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local IsEquippedItem = IsEquippedItem
local IsEquippedItemType = IsEquippedItemType
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local IsPlayerSpell = IsPlayerSpell
local IsSpellInRange = IsSpellInRange
local IsUsableSpell = IsUsableSpell
local LibStub = LibStub
local math = math
local pow = math.pow
local max = math.max
local min = math.min
local next = next 
local pairs = pairs
local print = print
local select = select
local SetCVar = SetCVar
local setmetatable = setmetatable
local sqrt = sqrt
local string = string
local char = string.char
local find = string.find
local gmatch = string.gmatch
local gsub = string.gsub
local lower = string.lower
local match = string.match
local strsplit = strsplit
local table = table
local insert = function ( t, v )
    t[ #t + 1 ] = v
end
local t_sort = table.sort
local sort = function( t, func )
    if not func then
        t_sort( t )
    else
        t_sort( t, function( l, r )
                if not l then 
                    return false
                elseif not r then
                    return true
                else
                    return func( l, r )
                end
        end )
    end
end   
local tonumber = tonumber
local tostring = tostring
local type = type
local UnitAttackPower = UnitAttackPower
local UnitAttackSpeed = UnitAttackSpeed
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitLevel = UnitLevel
local UnitSpellHaste = UnitSpellHaste
local UnitStat = UnitStat
local UnitTokenFromGUID = UnitTokenFromGUID
local WeakAuras = WeakAuras
local gcdDuration = WeakAuras.gcdDuration
local GetRange = WeakAuras.GetRange
local GetSpellCooldownUnified = WeakAuras.GetSpellCooldownUnified
local ScanEvents = WeakAuras.ScanEvents 

-- ------------------------------------------------------------------------------
-- Initialize DBC Spells
-- ------------------------------------------------------------------------------

local DBC_Version = 2.2
local DBC_Critical = 2.2
local LibDBCache = LibStub( "LibDBCache-1.0", true )

if not LibDBCache then
    print("JeremyUI: Database missing!")
    return
end

if DBC_Critical > LibDBCache.Version then
    print("JeremyUI: DISABLED - A critical database update is needed.")
    return
end

if DBC_Version > LibDBCache.Version then
    print("JeremyUI: Your database is out of date, an update is needed.")
    print("JeremyUI: You may experience Lua errors until your database is updated.")    
end

--boop
local spell = {
    -- Spec Auras
    brewmaster_monk = LibDBCache:find_spell( 137023 ),
    mistweaver_monk = LibDBCache:find_spell( 137024 ),
    windwalker_monk = LibDBCache:find_spell( 137025 ),
    
    -- Tier Sets
    t31_brm_2pc = LibDBCache:find_spell( 422886 ),
    t31_brm_4pc = LibDBCache:find_spell( 422887 ),
    t31_ww_2pc  = LibDBCache:find_spell( 422891 ),
    t31_ww_4pc  = LibDBCache:find_spell( 422892 ),
    
    -- Actions
    blackout_kick       = LibDBCache:find_spell( 100784 ),
    chi_burst           = LibDBCache:find_spell( 148135 ),
    chi_wave            = LibDBCache:find_spell( 132467 ),
    cj_lightning        = LibDBCache:find_spell( 117952 ),
    expel_harm          = LibDBCache:find_spell( 322101 ),
    jadefire_stomp      = LibDBCache:find_spell( 388207 ),
    jadefire_stomp_ww   = LibDBCache:find_spell( 388201 ),
    fists_of_fury       = LibDBCache:find_spell( 113656 ),
    fsk_damage          = LibDBCache:find_spell( 123586 ),
    keg_smash           = LibDBCache:find_spell( 121253 ),
    rising_sun_kick     = LibDBCache:find_spell( 185099 ),
    rjw_tick            = LibDBCache:find_spell( 148187 ),
    rushing_jade_wind   = LibDBCache:find_spell( 116847 ),
    sck_tick            = LibDBCache:find_spell( 107270 ),
    sotwl_mh            = LibDBCache:find_spell( 395519 ),
    sotwl_oh            = LibDBCache:find_spell( 395521 ),
    spinning_crane_kick = LibDBCache:find_spell( 101546 ),
    tiger_palm          = LibDBCache:find_spell( 100780 ),
    touch_of_death      = LibDBCache:find_spell( 322109 ),
    wdp_tick            = LibDBCache:find_spell( 158221 ),
    
    -- Other Spells
    breath_of_fire_dot      = LibDBCache:find_spell( 123725 ),
    catue_claw              = LibDBCache:find_spell( 389541 ),
    celestial_fortune       = LibDBCache:find_spell( 216519 ),
    chi_energy              = LibDBCache:find_spell( 393057 ),
    chi_explosion           = LibDBCache:find_spell( 393056 ),
    chi_surge_dot           = LibDBCache:find_spell( 393786 ),
    cyclone_strikes         = LibDBCache:find_spell( 220358 ),
    dragonfire              = LibDBCache:find_spell( 387621 ),
    emperors_capacitor      = LibDBCache:find_spell( 393039 ),
    jadefire_brand_dmg      = LibDBCache:find_spell( 395414 ),
    gift_of_the_ox          = LibDBCache:find_spell( 124507 ),
    gotd_proc               = LibDBCache:find_spell( 392959 ),
    keefers_skyreach        = LibDBCache:find_spell( 344021 ),
    pretense                = LibDBCache:find_spell( 393515 ),
    pta_melee               = LibDBCache:find_spell( 418360 ),
    resonant_fists          = LibDBCache:find_spell( 391400 ),
    special_delivery        = LibDBCache:find_spell( 196733 ),
    thunderfist             = LibDBCache:find_spell( 393566 ),
    
    mystic_touch            = LibDBCache:find_spell( 113746 ),
    
    -- PvP Talents
    pvp_enabled  = LibDBCache:find_spell( 134735 ),
    reverse_harm = LibDBCache:find_spell( 342928 ),
}

-- ------------------------------------------------------------------------------
-- Other spell values
-- TODO: Add these to DBC
-- ------------------------------------------------------------------------------

-- todo
local bdb_chance = 0.5
local bof_duration = 12
local cb_apmod = 8.4
local double_barrel_amp = 0.5
local exploding_keg_duration = 3
local hot_trub_amount = 0.2
local incendiary_breath_amp = 0.3
local pretense_duration = 5

-- these PtA modifiers are not in spell data
local press_the_advantage_cs_mod = 0.5
local press_the_advantage_fp_mod = 0.25
local press_the_advantage_boc_mod = 0.5

local armor = 0.7
local SEF_bonus = 1.26
local SER_bonus = 1.15

-- ------------------------------------------------------------------------------

aura_env.SPEC_INDEX = {
    ["MONK_WINDWALKER"] = 3,
    ["MONK_BREWMASTER"] = 1,
    ["MONK_MISTWEAVER"] = 2,
}


aura_env.AUTOMARKER = {}

for _, v in ipairs( aura_env.config.automarker_options ) do 
    if v.enabled then 
        aura_env.AUTOMARKER[v.name] = "MARK" .. ( v.interrupt and "/INTERRUPT" or "" ) .. ( v.stun and "/STUN" or "" ) .. ( v.kill and "/KILL" or "" )
        
        if v.npcid and v.npcid > 0 then
            aura_env.AUTOMARKER[tostring(v.npcid)] = "MARK" .. ( v.interrupt and "/INTERRUPT" or "" ) .. ( v.stun and "/STUN" or "" ) .. ( v.kill and "/KILL" or "" )
        end
    else
        aura_env.AUTOMARKER[v.name or ""] = ""
        aura_env.AUTOMARKER[tostring(v.npcid or 0)] = ""
    end
end

aura_env.diffuse_options = {}
for _, v in ipairs( aura_env.config.diffuse_auras ) do
    if v.spellid and v.spellid > 0 then
        aura_env.diffuse_options[v.spellid] = {}
        aura_env.diffuse_options[v.spellid].enabled = v.enabled
        aura_env.diffuse_options[v.spellid].reflect = v.reflect
    end
end

aura_env.aura_amps = {}
for _, v in ipairs( aura_env.config.aura_amp_options ) do
    if v.spellid and v.spellid > 0 then
        aura_env.aura_amps[ v.spellid ] = {
            modifier = v.modifier,
            copies = v.copies or 1,
        }
    end
end

aura_env.aura_amps_player = {}
aura_env.aura_amps_primary = {}
aura_env.aura_amps_player_ignore = {}--{ [buff.xuen_the_white_tiger] = true, [buff.serenity] = true, [buff.storm_earth_and_fire] = true, [buff.hit_combo] = true,  }
aura_env.aura_amps_player_ignore_h = {}--{ [buff.save_them_all] = true, }
for _, v in ipairs( aura_env.config.aura_amp_player ) do
    if v.spellid then
        if v.spellid > 0 then
            if aura_env.aura_amps_player_ignore [ v.spellid ] then
                print("Jeremy UI: Player Damage Aura (" .. v.spellid .. ") ignored, this cannot be set manually")
            else
                local aura_type = v.type or 1
                if aura_type == 1 then
                    aura_env.aura_amps_player[ v.spellid ] = v.modifier
                else
                    aura_env.aura_amps_primary[ v.spellid ] = v.modifier
                end
            end
        end
    end
end

aura_env.aura_amps_player_h = {}
for _, v in ipairs( aura_env.config.aura_amp_player_h ) do
    if v.spellid then
        if v.spellid > 0 then
            if aura_env.aura_amps_player_ignore_h[ v.spellid ] then
                print("Jeremy UI: Player Healing Done Aura (" .. v.spellid .. ") ignored, this cannot be set manually")
            else
                aura_env.aura_amps_player_h[v.spellid] = v.modifier
            end
        end
    end
end
aura_env.aura_amps_player_ht = {}
for _, v in ipairs( aura_env.config.aura_amp_player_ht ) do
    if v.spellid then
        if v.spellid > 0 then
            if aura_env.aura_amps_player_ignore_h[ v.spellid ] then
                print("Jeremy UI: Player Healing Taken Aura (" .. v.spellid .. ") ignored, this cannot be set manually")
            else
                aura_env.aura_amps_player_ht[v.spellid] = v.modifier
            end
        end
    end
end


aura_env.auraExclusions = {}
for _, v in ipairs( aura_env.config.aura_exclusions ) do
    if v.spellid and v.spellid > 0 then
        aura_env.auraExclusions[ v.spellid ] = true
    end
end

aura_env.bw_config = {}
if BigWigs then
    for _, v in ipairs( aura_env.config.bw_dungeon_adds ) do
        if v.key then
            aura_env.bw_config[ v.key ] = {
                enabled = v.enabled,
                count = v.count,
                type = "ADD_SPAWN",
            }
        end
    end
    
    for _, v in ipairs( aura_env.config.bw_raid_adds ) do
        if v.key then
            aura_env.bw_config[ v.key ] = {
                enabled = v.enabled,
                count = v.count,
                type = "ADD_SPAWN",
            }
        end
    end    
    
    for _, v in ipairs( aura_env.config.bw_dungeon_intermission ) do
        if v.key then
            aura_env.bw_config[ v.key ] = {
                enabled = v.enabled,
                unitid = v.unitid,
                type = "INTERMISSION",
            }
        end
    end
    
    for _, v in ipairs( aura_env.config.bw_dungeon_busters ) do
        if v.key then
            aura_env.bw_config[ v.key ] = {
                enabled     = v.enabled,
                damage_type = v.type,
                affects     = v.affects,
                type = "TANKBUSTER",
            }
        end
    end  
    
    for _, v in ipairs( aura_env.config.bw_raid_busters ) do
        if v.key then
            aura_env.bw_config[ v.key ] = {
                enabled     = v.enabled,
                damage_type = v.type,
                affects     = v.affects,
                type = "TANKBUSTER",
            }
        end
    end        
    
    local plugin = BigWigs:GetPlugin( "JeremyUI", true ) or BigWigs:NewPlugin("JeremyUI")
    BW_RegisterMessage( plugin, "BigWigs_StartBar", function(...)   
            ScanEvents( "JEREMY_STARTBAR", ... )
    end)
end

aura_env.earlyDeath = {}
for _, v in ipairs( aura_env.config.early_deaths ) do 
    if v.npcid and v.npcid > 0 then
        aura_env.earlyDeath[tostring(v.npcid)] = v.health / 100
    end
end

aura_env.npc_priority = {}
local TARGET_PRIORITY_REDUCED = 0.8
local TARGET_PRIORITY_TRIVIAL = 0.2
local TARGET_PRIORITY_IGNORE  = 0.01
local TARGET_PRIORITY_EXCLUDE = 0
for _, v in ipairs( aura_env.config.target_priority ) do 
    if ( v.npcid and v.npcid > 0 )
    and ( v.priority and v.priority > 0 ) then
        aura_env.npc_priority[ tostring( v.npcid ) ] = 
        ( v.priority == 2 and TARGET_PRIORITY_REDUCED ) or
        ( v.priority == 3 and TARGET_PRIORITY_TRIVIAL ) or
        ( v.priority == 4 and TARGET_PRIORITY_IGNORE ) or
        TARGET_PRIORITY_EXCLUDE
    end
end

aura_env.RECENT_DURATION = 3
aura_env.RECENT_UPDATE = nil
aura_env.CURRENT_MARKERS = {}

aura_env.CPlayer = {
    ability_power = 1,
    action_modifier = 1,
    action_sequence = {},
    auraDataByInstance = {},
    auraExclusions = {},    
    auraInstancesByID = {},
    buffs = {}, -- populated by makeBuff
    chi = 0,
    chi_max = 0,
    combat = {
        avg_level = 0,
        damage_by_level = 0,
        damage_taken = 0,
        damage_taken_avoidable = 0,
        damage_taken_unavoidable = 0,
        recent_damage = {},                
    },
    channel = {
        action = nil,
        finish = nil,
        latency = 0.2, -- Players experience about 200ms of channel latency on average from ingame testing
        length = nil,
        raw = 0,
        remaining = nil,
        spellID = nil,
        start = nil,
        tick_rate = nil,
        ticks = 1,
        ticks_remaining = nil,
    },
    crit_bonus = 1,
    default_action = "spinning_crane_kick",
    dps = 0,
    energy = 0,
    energy_max = 0,
    energy_ttm = 0,
    eps = 0,
    gcd_duration = 0,
    gcd_remains = 0,
    haste = 1,
    health_deficit = 0,
    lastFullUpdate = nil,
    mana = 0,
    mast_bonus = 1,
    mh_wdps = 1,
    movement_rate = 0,
    movement_t = 0,
    movement_yds = 0,
    moving = false,
    needsFullUpdate = true,    
    oh_wdps = 0,
    primary_stat = 0,
    recent_dtps = 0,
    set_pieces = {},
    spec = 0,
    spell = spell,
    spell_power = 1,
    stagger = 0,
    vers_bonus = 1,
    
    talent = {},
    
    -- Monk 
    bdb_targets = 0,
    bof_targets = 0,
    diffuse_reflects = {},
    diffuse_auras = {},
    jfh_dur_total = 0,
    jfh_targets = 0,
    ks_targets = 0,
    last_combo_strike = 0,
    motc_targets = 0,
    sfv_targets = 0,
    woo_dur_total = 0,
    woo_targets = 0,
    
    --
    
    is_beta = function()
        local beta = 11.0 -- The War Within
        local build_version = select( 4, GetBuildInfo() ) / 10000
        return build_version >= beta
    end,
    
    -- 
    
    auraExists = function ( spellId, callback )
        -- if found return callback function or true
        -- otherwise false
        -- if callback returns true, stop iterating through instanceIDs
        local self = aura_env.CPlayer
        local ret = false
        local spellIds = type( spellId ) == "table" and spellId or { spellId }
        local callbackIsFunc = callback and type( callback ) == "function"
        
        for _, id in ipairs( spellIds ) do
            local instances = self.auraInstancesByID[ id ]
            if instances then
                for instanceID in pairs( instances ) do
                    local auraData = self.auraDataByInstance[ instanceID ]
                    if auraData then
                        ret = true
                        
                        auraData.remaining = ( auraData.expirationTime and auraData.expirationTime - GetTime() ) or 0
                        
                        if callbackIsFunc and callback( auraData ) then
                            return ret
                        end
                    end
                end
            end
            if ret then 
                break
            end
        end
        return ret
    end, 
    
    createAction = function( spellID, init )
        if not spellID then
            return nil
        end
        
        local Player = aura_env.CPlayer
        local action = init or {}
        local data          = LibDBCache:find_spell( spellID )
        local trigger_data  = LibDBCache:find_spell( action.damageID )
        
        if not data.found then
            print( "JeremyUI: No data found for " .. spellID .. " while creating action." )
        end
        
        if not trigger_data.found then
            trigger_data = nil
            if action.damageID then
                print( "JeremyUI: No data found for " .. action.damageID .. " while creating action." )
            end
        end
        
        action.data         = data
        action.trigger_data = trigger_data
        
        local _damage_data = trigger_data or data
        
        action.spellID      = spellID
        action.replaces     = action.replaces or data.replaces
        action.background   = action.background or false
        action.channeled    = action.channeled or data.channeled
        action.delay_aa     = action.delay_aa or data.delay_auto_attack
        
        action.icd              = action.icd or data.icd
        action.duration         = action.duration or data.duration
        action.duration_hasted  = action.duration_hasted or data.duration_hasted
        action.trigger_rate     = action.trigger_rate or data.trigger_rate
        action.tick_zero        = action.tick_zero or data.tick_zero
        action.dot_hasted       = action.dot_hasted or data.dot_hasted
        
        -- Use triggered spell data
        action.ignore_armor     = action.ignore_armor or _damage_data.ignores_armor
        action.may_miss         = action.may_miss or _damage_data.may_miss
        action.may_crit         = action.may_crit or _damage_data.may_crit
        
        local effect_type = function( e )
            if e.is_heal then
                if action.target_count then
                    return "smart_heal"
                end
                return "self_heal"
            end
            return "damage"
        end
        
        if not action.ap then
            local iter = 1
            local effect = 0
            while ( effect ~= nil ) do
                effect = _damage_data.effectN( iter )
                if effect and effect.ap_coefficient then
                    action.ap = function()
                        return effect.ap_coefficient
                    end
                    action.is_periodic = action.is_periodic or effect.is_periodic
                    action.type = action.type or effect_type( effect )
                    break
                end
                iter = iter + 1
            end
        end
        
        if not action.ap and not action.sp then
            local iter = 1
            local effect = 0
            while ( effect ~= nil ) do
                effect = _damage_data.effectN( iter )
                if effect and effect.sp_coefficient then
                    action.sp = function() 
                        return effect.sp_coefficient
                    end
                    action.is_periodic = action.is_periodic or effect.is_periodic 
                    action.type = action.type or effect_type( effect )
                    break
                end
                iter = iter + 1
            end            
        end
        
        action.type = action.type or "damage"
        
        if not action.ticks and action.duration and action.base_tick_rate and action.base_tick_rate > 0 then
            action.ticks = action.duration / action.base_tick_rate
        end
        
        local ticks = action.ticks or 1
        if type( ticks ) ~= "function" then
            action.ticks = function()
                if action.channeled and action.canceled then
                    local ticks_gcd = 0
                    local ticks_on_cast = ( action.tick_zero and 1 or 0 )
                    local ticks_remaining = ticks - ticks_on_cast
                    
                    if ticks_remaining > 0 then
                        local gcd = aura_env.gcd( action.spellID )
                        local duration = action.duration
                        
                        if duration then
                            if action.duration_hasted then
                                duration = duration / Player.haste
                            end                
                            
                            local tick_rate = duration / ticks_remaining
                            ticks_gcd = max( 0, ( gcd / tick_rate ) )
                        end
                    end
                    
                    return ticks_on_cast + ticks_gcd
                end
                
                return max( 1, ticks )
            end
        end
        
        -- Cast Time / Execute Time functions
        
        action.cast_time = action.cast_time or function()
            if action.background then 
                return 0
            end
            
            local cast_time_ms = select( 4, GetSpellInfo( action.spellID ) ) or 0
            return cast_time_ms / 1000
        end
        
        action.execute_time = action.execute_time or function()
            if action.background then
                return 0
            end
            
            local gcd = aura_env.gcd( action.spellID )

            if action.channeled and action.duration and not action.canceled then
                local duration = action.duration
                if action.duration_hasted then
                    duration = duration / Player.haste
                end
                return max( duration, gcd )
            end
            
            return max( gcd, action.cast_time() )
        end
        
        return action
    end,
    
    -- Simple helper function if you only need to know if one instance of a spellID exists
    -- always returns the lowest duration if there are multiple instances
    findAuraCache = {},
    findAura = function ( spellID )
        local self = aura_env.CPlayer
        local time = GetTime()
        
        local cached = self.findAuraCache[ spellID ]
        if cached and cached.data then
            if cached.expires > time then
                return cached.data
            end
        end
        
        local auraData = C_UnitAuras.GetPlayerAuraBySpellID( spellID )
        
        if auraData then
            auraData.name = ( cached and cached.data and cached.data.name ) or gsub( lower( auraData.name ), "%s+", "_" )
            auraData.stacks = auraData.applications or 0            
            auraData.remaining = ( auraData.expirationTime and auraData.expirationTime - time ) or 0
            auraData.duration = auraData.duration or 0
        end
        
        self.findAuraCache[ spellID ] = {
            data = auraData,
            expires = time + aura_env.update_rate,
        }
        
        return auraData
    end,
    
    getTalent = function( name )
        local self = aura_env.CPlayer
        local t = self.talent[ name ]
        
        t = t or LibDBCache:find_talent( 0, 0 )
        
        return t
    end,
    
    makeBuff = function( spellID, name, init )
        local self = aura_env.CPlayer
        
        if not name or not self.buffs[ name ] then
            local buff = LibDBCache:find_spell( spellID ) 
            local _init = init or {}
            
            name = name or buff.tokenName
            
            if name then
                buff.spellID = spellID
                buff.name = name
                buff.auraData = function()
                    local data = self.findAura( spellID )
                    return data
                end
                buff.up = function()
                    local data = self.findAura( spellID )
                    return ( data ~= nil )
                end
                buff.remains = function()
                    local data = self.findAura( spellID )
                    return data and data.remaining or 0
                end
                buff.stacks = function()
                    local data = self.findAura( spellID )
                    return data and data.stacks or 0 
                end
                
                buff._max_stacks = buff.max_stacks
                buff.max_stacks = init.max_stacks or function()
                    return buff._max_stacks
                end
                
                self.buffs[ name ] = buff
            else
                print( "Unable to make buff " .. spellID )
            end
        end
    end,
}

local Player = aura_env.CPlayer
local Combat = Player.combat

aura_env.CEnemy = {} -- Use with GetEnemy( srcGUID )
aura_env.GetEnemy = function( srcGUID )
    
    if not srcGUID then
        return nil
    end
    
    if aura_env.CEnemy[ srcGUID ] == nil then
        
        -- CEnemy Template
        aura_env.CEnemy[ srcGUID ] = {
            
            auraDataByInstance = {},
            auraExclusions = {},
            auraInstancesByID = {},
            combatEnd = nil,
            combatStart = nil,
            dead = false,
            healthActual = 0,
            healthPct = 1.0,
            inCombat = nil,
            intermission = nil,
            interruptTarget = false,
            isBoss = false,
            level = 0,
            lastFullUpdate = nil,
            lastHealth = nil,
            lastSeen = nil,
            marker = nil,
            needsFullUpdate = true,
            npcid = srcGUID:match( "(%d+)-%x-$" ),
            priority_modifier = 1.0,
            range = 40,
            stunTarget = false,
            ttd = nil,
            
            auraExists = function ( spellId, callback )
                -- if found return callback function or true
                -- otherwise false
                -- if callback returns true, stop iterating through instanceIDs
                local self = aura_env.CEnemy[ srcGUID ]
                local ret = false
                local spellIds = type( spellId ) == "table" and spellId or { spellId }
                local callbackIsFunc = callback and type( callback ) == "function"
                
                for _, id in ipairs( spellIds ) do
                    local instances = self.auraInstancesByID[ id ]
                    if instances then
                        for instanceID in pairs( instances ) do 
                            local auraData = self.auraDataByInstance[ instanceID ]
                            if auraData then
                                ret = true
                                
                                auraData.remaining = ( auraData.expirationTime and auraData.expirationTime - GetTime() ) or 0
                                
                                if callbackIsFunc and callback( auraData ) then
                                    return ret
                                end
                            end
                        end
                    end
                    if ret then 
                        break
                    end
                end
                return ret
            end, 
        }
    end
    
    aura_env.CEnemy[ srcGUID ].unitID = UnitTokenFromGUID( srcGUID )
   
    return aura_env.CEnemy[ srcGUID ];
end

aura_env.ResetEnemy = function( GUID, dead )
    
    local Enemy = aura_env.GetEnemy( GUID )
    local marker = Enemy.marker
    if marker then
        aura_env.CURRENT_MARKERS[ marker ] = nil
        Enemy.marker = nil
        ScanEvents( "JEREMY_MARKER_CHANGED", GUID, nil )
    end
    
    Enemy.auraDataByInstance = {}
    Enemy.auraExclusions = {}
    Enemy.auraInstanceByID = {}
    Enemy.combatEnd = Enemy.inCombat and GetTime() or nil
    Enemy.combatStart = nil
    Enemy.dead = dead or false
    Enemy.healthActual = 0
    Enemy.healthPct = 1.0
    Enemy.inCombat = nil
    Enemy.intermission = nil
    Enemy.lastHealth = nil
    Enemy.lastSeen = nil
    Enemy.needsFullUpdate = true
    Enemy.range = 40
    Enemy.ttd = nil
    
    if aura_env.sef_fixate and aura_env.sef_fixate == GUID then
        aura_env.last_fixate_bonus = 0
    end
end

-- ------------------------------------------------------------------------------
-- Make Buffs
-- TODO: Make this a player function
-- ------------------------------------------------------------------------------


local buff = {}

-- items
Player.makeBuff( 426553, "annihilating_flame" )

-- general

Player.makeBuff( 389684, "close_to_heart" )
Player.makeBuff( 390105, "save_them_all" )

-- ww 
Player.makeBuff( 424454, "blackout_reinforcement" )
Player.makeBuff( 116768, "bok_proc" )
Player.makeBuff( 337571, "chi_energy" )
Player.makeBuff( 325202, "dance_of_chiji" )
Player.makeBuff( 394949, "fists_of_flowing_momentum" )
Player.makeBuff( 196741, "hit_combo" )
Player.makeBuff( 394944, "kicks_of_flowing_momentum" )
Player.makeBuff( 129914, "power_strikes" )
Player.makeBuff( 337482, "pressure_point" )
Player.makeBuff( 152173, "serenity" )
Player.makeBuff( 137639, "storm_earth_and_fire" )
Player.makeBuff( 202090, "teachings_of_the_monastery", {
    max_stacks = function()
        local self = Player.buff.teachings_of_the_monastery
        local ms = self._max_stacks
        
        ms = ms + Player.getTalent( "knowledge_of_the_broken_temple" ).effectN( 3 ).base_value
        
        return ms
    end,
} )
Player.makeBuff( 393039, "the_emperors_capacitor" )
Player.makeBuff( 242387, "thunderfist" )
Player.makeBuff( 195321, "transfer_the_power" )
Player.makeBuff( 123904, "xuen_the_white_tiger" )

-- brm
Player.makeBuff( 228563, "blackout_combo" )
Player.makeBuff( 325190, "celestial_flames" )
Player.makeBuff( 389963, "charred_passions" ) 
Player.makeBuff( 383800, "counterstrike" )
Player.makeBuff( 202346, "double_barrel" )
Player.makeBuff( 325153, "exploding_keg" )
Player.makeBuff( 124273, "heavy_stagger" )
Player.makeBuff( 383696, "hit_scheme" )
Player.makeBuff( 124275, "light_stagger" )
Player.makeBuff( 124274, "moderate_stagger" )
Player.makeBuff( 418361, "press_the_advantage" )
Player.makeBuff( 393516, "pretense_of_instability" )
Player.makeBuff( 325092, "purified_chi" )

-- ------------------------------------------------------------------------------



aura_env.combo_strike = {
    [100780] = true,  -- Tiger Palm
    [100784] = true,  -- Blackout Kick
    [107428] = true,  -- Rising Sun Kick
    [101545] = not Player.is_beta(),  -- Flying Serpent Kick
    [113656] = true,  -- Fists of Fury
    [101546] = true,  -- Spinning Crane Kick
    [116847] = true,  -- Rushing Jade Wind
    [152175] = true,  -- Whirling Dragon Punch
    [115098] = true,  -- Chi Wave
    [123986] = true,  -- Chi Burst
    [117952] = true,  -- Crackling Jade Lightning
    [392983] = true,  -- Strike of the Windlord
    [322109] = true,  -- Touch of Death
    [322101] = true,  -- Expel Harm
    [310454] = true,  -- Weapons of Order
    [388193] = true,  -- Jadefire Stomp
    [325216] = true,  -- Bonedust Brew
    [388686] = true,  -- White Tiger Statue
    [137639] = Player.is_beta(), -- Storm, Earth, and Fire
}

aura_env.error_margin = 0.05
aura_env.update_rate = 0.5
aura_env.fast = false
aura_env.pvp_mode = false

-- initialize default values
-- these are automatically filled in later
aura_env.BW_add_timers = {}
aura_env.BW_buster_timers = {}
aura_env.BW_intermission_timers = {}
aura_env.add_count = 0
aura_env.add_timer = 0
aura_env.boss_lockdown = false
aura_env.danger_a = 0
aura_env.danger_b = 0
aura_env.danger_next = nil
aura_env.encounter_id = nil
aura_env.fight_remains = 300
aura_env.healer_targets = {}
aura_env.in_keystone = false
aura_env.raid_events = {}
aura_env.spell_power = 1
aura_env.target_abs = 0
aura_env.target_count = 1
aura_env.target_ttd = 300

-- Enumerators
aura_env.buff_refresh_behavior =
{
    -- Refresh to given duration
    ["DURATION"] = 0,
    
    -- Disable refresh by triggering
    ["DISABLED"] = 1,
    
    -- Refresh to given duration plus remaining duration
    ["EXTEND"] = 2,
    
    -- Refresh to given duration plus min(0.3 * new_duration, remaining_duration)
    ["PANDEMIC"] = 3,
    
    -- Refresh to given duration plus ongoing tick time
    ["TICK"] = 4,
    
    -- Refresh to given duration or remaining duration, whichever is greater
    ["MAX"] = 5,
}

-- -----------------------------------------------------------------------------
-- Machine Learning (WIP)
-- -----------------------------------------------------------------------------
-- 
-- Store data locally in WTF files to assist in automated decision making.
--
-- TODO:
--
-- FINISHED:
-- Learn expected targets hit with frontal cone abilities
-- -----------------------------------------------------------------------------

-- -----------------
local ML_VERSION = 1.33
local ML_MAX_NODES = 10 -- Maximum nodes used in optimization algorithms

if aura_env.saved and ( not aura_env.saved.version or aura_env.saved.version < ML_VERSION ) then
    aura_env.saved = nil
end
-- -----------------

-- Initializers related to Machine Learning
aura_env.pull_hash = "" 
aura_env.pull_data = nil

-- Variables related to Machine Learning
aura_env.cone_listeners =
{
    -- Fists of Fury
    [117418] = true,
    -- Strike of the Windlord
    [395521] = true,  
    -- Faeline Stomp WW
    [327264] = true,
    -- Jadefire Stomp WW
    [388201] = true,
    -- Breath of Fire
    [115181] = true,
    -- Dragonfire Brew
    [387621] = true,
}

-- base structure for trained data
-- anything written to this structure is stored locally for the end-user
-- and    renewed   on     initialization    of    the   WA
aura_env.saved = aura_env.saved or 
{
    version = ML_VERSION,
    pull_data = {
        -- indexed by pull_hash 
        -- data stored for unique pull id
    },
}

aura_env.get_pull_data = function ( )
    if aura_env.pull_hash == "" then
        return nil
    end
    
    return aura_env.saved.pull_data[ aura_env.pull_hash ] or {}
end

-- gradient descent optimization formula
-- nodes normalized to standard deviation
aura_env.gradient_descent = function( nodes )
    
    local ev = 0
    
    if not nodes or next( nodes ) == nil then
        ev = 0
    elseif #nodes == 1 then
        ev = nodes[ 1 ] or 0
    else
        local mean, m = 0, 0
        for _, v in pairs( nodes ) do
            if type( v ) == "number" and v > 0 then
                mean = mean + v
            end
        end        
        mean = ( mean / #nodes )
        
        for i in pairs( nodes ) do
            m = m + pow( ( nodes[ i ] - mean ), 2 )
        end
        
        local tmp = {}
        local sd = sqrt( m / ( #nodes - 1 ) ) * 2 --  σ
        local ld, ud = ( mean - sd ), ( mean + sd )
        
        mean = 0
        for idx, v in pairs( nodes ) do
            if type( v ) == "number" and v > ld and v < ud then
                mean = mean + v
                tmp[ #tmp + 1 ] = v
            else
                nodes[ idx ] = nil
            end
        end
        if next( tmp ) == nil or mean == 0 then
            ev = 0
        else
            ev = ( mean / #tmp ) -- μ
        end
        
        if #tmp > ML_MAX_NODES then
            sort( tmp, function( l, r )
                    return abs( ev - l ) < abs( ev - r ) 
            end ) 
            for it = #tmp, ML_MAX_NODES + 1, -1 do
                tmp[ it ] = nil
            end
        end
        nodes = tmp
    end
    
    return ev
end

aura_env.updateDB = function()
    
    if not aura_env.saved then
        return
    end
    
    -- Pull Data
    if aura_env.saved.pull_data then
        for _, data in pairs( aura_env.saved.pull_data ) do
            
            -- Cone Data
            if data.cone_data then
                for _, spelldata in pairs( data.cone_data ) do
                    if spelldata.tmp_data then
                        local average = spelldata.tmp_data.average
                        if average then
                            spelldata.nodes = spelldata.nodes or {}
                            spelldata.nodes[ #spelldata.nodes + 1 ] = average
                            spelldata.expected_value = aura_env.gradient_descent( spelldata.nodes )
                            spelldata.tmp_data = {}
                        end
                    end
                end
            end
            
            -- Route Data
            --[[
            if data.route_data then
                if data.route_data.tmp_data and data.route_data.tmp_data.average then
                    data.route_data.nodes = data.route_data.nodes or {}
                    data.route_data.nodes[ #data.route_data.nodes + 1 ] = data.route_data.tmp_data.average
                    data.route_data.expected_value = aura_env.gradient_descent( data.route_data.nodes )
                    data.route_data.tmp_data = {}
                end
            end]]
        end
    end
end

-- ---------------------------------------------

aura_env.nextPullListener = function( )
    if not IsInInstance() or aura_env.pvp_mode then
        return
    end
    
    if not aura_env.pull_hash or aura_env.pull_hash == "" then
        return
    end
    
    local pull_hash = aura_env.pull_hash
    local pull_data = aura_env.pull_data 
    
    if not aura_env.last_pull or aura_env.last_pull ~= pull_hash then
        
        if aura_env.last_pull then
            pull_data.route_data = pull_data.route_data or {}
            
            local tmp = pull_data.route_data.tmp_data or {}
            tmp.total = ( tmp.total or 0 ) + aura_env.last_pull.count
            tmp.peak = max( tmp.peak or 1, aura_env.last_pull.count )
            tmp.average = tmp.total / tmp.peak
            
            pull_data.route_data.tmp_data = tmp
            
            aura_env.saved.pull_data[ pull_hash ] = pull_data
        end
        
        if not InCombatLockdown then
            aura_env.last_pull = {
                start = GetTime(),
                count = aura_env.target_count,
                hash = pull_hash,
            }
        end
    end
    
    local rd = pull_data.route_data
    if rd and rd.expected_value then
        --print("next pull will likely have "..floor( rd.expected_value + 0.5 ).. "enemies" )
    end
end

aura_env.coneTickListener = function ( spellID, GUID )
    
    if not IsInInstance() or aura_env.pvp_mode then
        return
    end
    
    if not aura_env.pull_hash or aura_env.pull_hash == "" then
        return
    end
    
    if not aura_env.cone_listeners[ spellID ] then
        return
    end
    
    if not GUID then
        return
    end
    
    local pull_hash = aura_env.pull_hash
    local pull_data = aura_env.pull_data
    
    pull_data.cone_data = pull_data.cone_data or {}
    pull_data.cone_data[ spellID ] = pull_data.cone_data[ spellID ] or {}
    
    local tmp = pull_data.cone_data[ spellID ].tmp_data or {}
    tmp.ticks = tmp.ticks or { }
    tmp.ticks[ GUID ] = ( tmp.ticks[ GUID ] or 0 ) + 1
    tmp.total = ( tmp.total or 0 ) + tmp.ticks[ GUID ]
    tmp.peak = max( tmp.peak or 1, tmp.ticks[ GUID ] ) 
    tmp.average = tmp.total / tmp.peak
    
    pull_data.cone_data[ spellID ].tmp_data = tmp
    
    aura_env.saved.pull_data[ pull_hash ] = pull_data
end

aura_env.learnedFrontalTargets = function ( spellID )
    -- There's no way to use the game API to determine how many enemies are in a frontal cone
    -- however, your chances of hitting all enemies drops off significantly after 5
    -- this is used as a default until there is trained data available
    local default = min( aura_env.target_count, 5 )
    if not spellID or not aura_env.pull_hash or aura_env.pull_hash == "" then
        return default
    end
    
    local pd = aura_env.pull_data
    local cd = pd.cone_data
    
    if cd and cd[ spellID ] and cd[ spellID ].expected_value then
        -- I am using a minimum boundary of 1 for boss encounters and 5 for all other pull events
        local boundary = aura_env.boss_lockdown and 1 or 5
        return min( aura_env.target_count, max( cd[ spellID ].expected_value, boundary ) )
    end
    
    return default 
end

aura_env.hashEnemyList = function ( mob_table )
    
    -- Simutaneously convert to int and remove duplicates
    local int_tbl, hash = {}, {}
    for _, v in ipairs( mob_table ) do
        local id = tonumber( v )
        if id and not hash[ id ] then
            int_tbl[ #int_tbl + 1 ] = id
            hash[ id ] = true
        end
    end
    
    -- Ensure consistent hash regardless of nameplate order
    sort( int_tbl )
    
    -- Encode for local storage
    local tmpstr, encoded = "", ""
    for _, v in ipairs( int_tbl ) do
        tmpstr = tmpstr .. v
    end
    
    for i = 1, #tmpstr, 2 do
        encoded = encoded .. char( "0x".. tmpstr:sub( i, i + 1 ) )
    end
    
    -- Encoded unique ID for this pull
    return encoded
end

-- ---------------------------------------------

aura_env.EventTimers = function ( demiseList )
    local event_list = {}
    local time = GetTime()
    
    -- Update BigWigs Spawn Timers
    aura_env.encounter_id = aura_env.encounter_id or aura_env.pull_hash
    
    for k, v in pairs( aura_env.BW_add_timers ) do
        local delete = false
        local remaining = v.expire - time
        local srcEnemy = nil
        if v.srcGUID then
            srcEnemy = aura_env.GetEnemy( v.srcGUID )
            if srcEnemy.dead then --or ( srcEnemy.combatEnd and srcEnemy.combatEnd < time ) then
                delete = true
            end      
        end
        delete = delete or remaining <= 0
        if delete then
            aura_env.BW_add_timers[ k ] = nil
        else
            local ignore = false
            if srcEnemy then
                if srcEnemy.range >= 40 -- Too far away
                or srcEnemy.ttd and srcEnemy.ttd <= aura_env.fight_remains then -- will die before spell goes off
                    ignore = true
                end
            end
            
            -- Add to event list
            local count = v.count or 0
            if not ignore and count > 0 and remaining < aura_env.fight_remains then
                event_list[ #event_list + 1 ] = {
                    adds_in = remaining,
                    count = count,
                }
            end
        end
    end
    
    -- Update BigWigs Danger Timers
    local avoidable = 0
    local unavoidable = 0
    local next_danger = nil
    
    for k, v in pairs( aura_env.BW_buster_timers ) do
        local delete = false
        local remaining = v.expire - time
        local srcEnemy = nil
        if v.srcGUID then
            srcEnemy = aura_env.GetEnemy( v.srcGUID )
            if srcEnemy.dead then --or ( srcEnemy.combatEnd and srcEnemy.combatEnd < time ) then
                delete = true
            end      
        end
        delete = delete or remaining <= 0
        if delete then
            ScanEvents( "JEREMY_TIMELINE_CANCEL", v.srcGUID, v.key )
            aura_env.BW_buster_timers[ k ] = nil
        else
            if v.damage_type < 4 then
                local ignore = false
                if srcEnemy then
                    if srcEnemy.range >= 40 -- Too far away
                    or srcEnemy.ttd and srcEnemy.ttd <= aura_env.fight_remains then -- will die before spell goes off
                        ignore = true
                    end
                end
                if not ignore and remaining < aura_env.fight_remains then
                    next_danger = ( next_danger and min( next_danger, remaining ) ) or remaining
                    local danger = UnitHealthMax( "player" ) / remaining
                    if v.damage_type == 1 then
                        avoidable = avoidable + danger
                    else
                        unavoidable = unavoidable + danger
                    end
                end
            end
        end
    end
    
    aura_env.danger_a = avoidable
    aura_env.danger_b = unavoidable
    aura_env.danger_next = next_danger
    
    if aura_env.in_keystone then
        -- Default in keys is to assume there will be a 3 mob pull 5 seconds after the current pull
        -- (does nothing on last boss if count is 100%)
        -- TODO: This could maybe be more accurate using learned data
        event_list["next_pull"] = {}
        event_list["next_pull"].adds_in = aura_env.fight_remains + 5
        event_list["next_pull"].count = 3
    end
    
    for idx, event in pairs( event_list ) do
        if event.count then
            local qty = #demiseList
            local event_targets = aura_env.target_count + event.count
            for d = 1, ( event.adds_in or 1 ) do
                if d > qty then
                    break
                end
                event_targets = max( 0, event_targets - ( demiseList[ d ] or 0 ) )
                if event_targets == 0 then
                    event_list[ idx ] = nil    
                    break
                end
            end
        end
    end
    
    return event_list
end

aura_env.celestialFortune = function( )
    return ( 1 + ( Player.crit_bonus * spell.celestial_fortune.effectN( 1 ).pct ) ) 
end

aura_env.parseTooltip = function( spellID )
    local t = {}
    local tooltip = GetSpellDescription( spellID )
    
    tooltip = gsub( tooltip, ",", "" )
    
    if tooltip then
        for i in gmatch( tooltip , "%d+") do
            if type( i ) == "number" then
                t[#t + 1] = i
            end
        end 
    end
    
    return t
end

aura_env.actionModRate = function( action )
    
    local spellID = action.spellID
    
    local rate = select( 5, GetSpellCharges( spellID ) ) or select( 4, GetSpellCooldown( spellID ) ) or 1
    
    if rate ~= 1 then
        return rate
    end
    
    if Player.buffs.serenity.up() and action.affected_by_serenity then
        rate = 0.5
    end
    
    return rate
end

aura_env.getCooldown = function( spellID ) 
    local _, _, startTime, duration = GetSpellCooldownUnified( spellID, nil );
    
    if duration > 0 and duration > 1.5 and duration ~= gcdDuration() then
        return startTime + duration - GetTime(), duration
    else
        return 0, 0
    end
end

aura_env.actionBaseCooldown = function( action )
    
    local spellID = action.spellID
    
    if not spellID or not GetSpellBaseCooldown( spellID ) then
        return 0
    end
    
    local cooldown = 0
    
    if action.override_cooldown then
        cooldown = ( type( action.override_cooldown ) == "function" and action.override_cooldown() or action.override_cooldown ) or 0
    else
        cooldown = GetSpellBaseCooldown( spellID ) / 1000
    end
    
    if cooldown > 0 then
        if action.hasted_cooldown then
            cooldown = cooldown / Player.haste
        end
    end
    

    if Player.buffs.serenity.up() and action.affected_by_serenity then
        if cooldown < Player.buffs.serenity.remains() then
            cooldown = cooldown / 2
        else
            cooldown = cooldown - Player.buffs.serenity.remains()
        end
    else
        cooldown = cooldown * aura_env.actionModRate( action )
    end
    
    return cooldown
end

aura_env.unmarked_targets = function( )
    local motcCount = GetSpellCount(101546)
    local unmarkedTargets = aura_env.target_count - Player.motc_targets
    
    -- TODO: DBC Value
    if motcCount < 5 and unmarkedTargets > 0 then
        return unmarkedTargets
    else
        return 0
    end    
end

aura_env.chi_base_cost = function( spellID )
    -- Returns 0 during Serenity
    local costTable = GetSpellPowerCost( spellID );
    if costTable then 
        for _, costInfo in pairs( costTable ) do
            if costInfo.type == 12 then
                return costInfo.cost    
            end
        end
    end
    return 0
end

aura_env.energy_base_cost = function( spellID )
    local costTable = GetSpellPowerCost( spellID );
    if costTable then 
        for _, costInfo in pairs( costTable ) do
            if costInfo.type == 3 then
                return costInfo.cost    
            end
        end
    end
    return 0
end

aura_env.mana_base_cost = function( spellID )
    local costTable = GetSpellPowerCost( spellID );
    if costTable then 
        for _, costInfo in pairs( costTable ) do
            if costInfo.type == 0 then
                return costInfo.cost    
            end
        end
    end
    return 0
end

aura_env.gcd = function ( spellID )
    local _, gcd = GetSpellBaseCooldown( spellID )
    local ret_ms = gcd or 0
    
    local gcd_flat_modifier = nil
    if Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"] then
        gcd_flat_modifier = spell.brewmaster_monk.effectN( 14 )    
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_WINDWALKER"] then
        gcd_flat_modifier = spell.windwalker_monk.effectN( 12 )
    end
    
    if LibDBCache:spell_affected_by_effect( spellID, gcd_flat_modifier ) then
        ret_ms = ret_ms + gcd_flat_modifier.base_value
    end        
    
    return ret_ms / 1000
end

aura_env.base_execute_time = function( spellID )
    local cast_time_ms = select( 4, GetSpellInfo( spellID ) )
    if cast_time_ms and cast_time_ms > 0 then
        return cast_time_ms / 1000
    else
        return aura_env.gcd( spellID )
    end
end

aura_env.findUnitAura = function( unitID, spellID, filter )
    
    local tmp = nil
    
    
    if filter and find( filter, "FUL" ) then
        ForEachAura( unitID, filter, nil, function( name, _, applications, _, _, expirationTime, _, _, _, id )
                if id == spellID then
                    tmp = {}
                    tmp.name = gsub( lower( name ), "%s+", "_" )
                    tmp.stacks = applications or 0
                    tmp.remaining = ( expirationTime and expirationTime - GetTime() ) or 0    
                    
                    return true
                end
        end )
    else
        ForEachAura( unitID, "HELPFUL", nil, function( name, _, applications, _, _, expirationTime, _, _, _, id )
                if id == spellID then
                    tmp = {}
                    tmp.name = gsub( lower( name ), "%s+", "_" )
                    tmp.stacks = applications or 0
                    tmp.remaining = ( expirationTime and expirationTime - GetTime() ) or 0    
                    
                    return true
                end
        end )
        
        if not tmp then
            ForEachAura( unitID, "HARMFUL", nil, function( name, _, applications, _, _, expirationTime, _, _, _, id )
                    if id == spellID then
                        tmp = {} 
                        tmp.name = gsub( lower( name ), "%s+", "_" )
                        tmp.stacks = applications or 0
                        tmp.remaining = ( expirationTime and expirationTime - GetTime() ) or 0 
                        
                        return true
                    end
            end ) 
        end
    end
    
    return tmp
end

aura_env.updateTalents = function()
    Player.talent = LibDBCache:initialize_talents()
end

aura_env.targetAuras = { }
aura_env.bdb_amp = function()
    
    local attenuation_bonus = Player.getTalent( "attenuation" ).effectN( 1 ).mod
    
    return 1 + ( Player.getTalent( "bonedust_brew" ).effectN( 1 ).mod * attenuation_bonus * bdb_chance )
end
aura_env.targetAuraEffect = function( callback, future )
    
    future = future or 0
    local target_count = max( 1, min( 20, ( callback.target_count and callback.target_count() or 1 ) ) )
    local execute_time = callback.execute_time and callback.execute_time() or 1 
    local callback_type = callback.type or "damage"
    
    local amp = 1
    
    if callback_type == "damage" then
        
        if target_count == 1 and aura_env.targetAuras["target"] then
            for _, aura in pairs( aura_env.targetAuras["target"] ) do
                local remaining = aura.expire - GetTime() - future
                if aura.amp > 0 and remaining > 0 then
                    amp = amp * ( 1 + ( aura.amp - 1 ) * ( execute_time > 1 and min( 1, remaining  / execute_time ) or 1 ) )
                end
            end
        else
            local combined_amp = 0
            for UnitID, targets in pairs( aura_env.targetAuras ) do
                local target_amp = 1
                
                local enemy = aura_env.GetEnemy( UnitGUID( UnitID ) )
                if enemy and enemy.ttd then
                    if execute_time > 0 and enemy.ttd - future <= 1 then
                        -- Cheeky way of evaluating increased execute value of AoE abilities when enemies are about to die
                        -- I.e, your AoE ability will hit more targets if used this global and thus more damage
                        targets["near_death"] = { 
                            amp = 1 + ( 1 / execute_time ), 
                            expire = GetTime() + aura_env.fight_remains  
                        }
                    end
                    
                    local funnel_enabled = aura_env.config.funnel_option == 2 
                    or ( aura_env.config.funnel_option == 3 and IsInInstance() and not IsInRaid() )
                    
                    if not aura_env.pvp_mode and funnel_enabled and enemy.ttd < aura_env.fight_remains then
                        -- Priority damage or funnel ( when applicable ), if an enemy lives significantly longer than
                        -- others it is placed higher in priority, i.e., if there is 30 seconds left in combat,
                        -- an enemy that lives for 5 seconds is less priority than an enemy that lives for 28 seconds.
                        local delta_ttd = aura_env.fight_remains - enemy.ttd
                        -- Ignore this effect if the time delta is insubstantial 
                        if delta_ttd > 3 then
                            targets["funnel_coefficient"] = { 
                                amp = ( enemy.ttd / aura_env.fight_remains ), 
                                expire = GetTime() + aura_env.fight_remains 
                            }
                        end
                    end
                end
                
                for _, aura in pairs( targets ) do
                    local remaining = aura.expire - GetTime() - future
                    if aura.amp > 0 and remaining > 0 then
                        target_amp = target_amp * ( 1 + ( ( aura.amp - 1 ) * ( execute_time > 1 and min( 1, remaining / execute_time ) or 1 ) ) )
                    end
                end
                combined_amp = combined_amp + ( target_amp - 1 )
            end
            
            if combined_amp > 0 then
                amp = 1 + ( combined_amp / aura_env.target_count ) 
            end
        end
    elseif callback_type == "smart_heal" then
        local combined_amp = 0
        for it = 1, min( #aura_env.healer_targets, target_count ) do
            local UnitID = aura_env.healer_targets[ it ].unitID
            local target_amp = 1
            for aura_id, aura_modifier in ipairs ( aura_env.aura_amps_player_ht ) do
                local aura = aura_env.findUnitAura( UnitID, aura_id )
                if aura and aura.remaining > future then
                    local stacks = max( 1 , aura.stacks )
                    target_amp = target_amp * ( 1 + ( aura_modifier - 1 ) * stacks * ( execute_time > 1 and min( 1, ( aura.remaining - future ) / execute_time ) or 1 ) )
                end
            end  
            if Player.getTalent( "save_them_all" ).ok and aura_env.findUnitAura( UnitID, Player.buffs.save_them_all.spellID, "HELPFUL" ) then
                if UnitHealth( UnitID ) / UnitHealthMax( UnitID ) < Player.getTalent( "save_them_all" ).effectN( 3 ).roll then
                    target_amp = target_amp * Player.getTalent( "save_them_all" ).effectN( 1 ).mod
                end
            end
            combined_amp = combined_amp + ( target_amp - 1 )
        end
        if combined_amp > 0 then
            amp = 1 + ( combined_amp / aura_env.healer_targets ) 
        end
    elseif callback_type == "self_heal" then
        for aura_id, aura_modifier in ipairs ( aura_env.aura_amps_player_ht ) do
            local aura = Player.findAura( aura_id )
            if aura and aura.remaining > future then
                local stacks = max( 1 , aura.stacks )
                amp = amp * ( 1 + ( aura_modifier - 1 ) * stacks * ( execute_time > 1 and min( 1, ( aura.remaining - future ) / execute_time ) or 1 ) )
            end
        end                
    end
    
    return amp
end

aura_env.base_gm = 1.0
aura_env.global_modifier = function( callback, future, real )
    local gm = 1
    
    future = future or 0
    real = real or true
    
    local target_count = max( 1, min( 20, ( callback.target_count and callback.target_count() or 1 ) ) )
    local execute_time = callback.execute_time and callback.execute_time() or 1
    local callback_type = callback.type or "damage"
    
    if callback_type == "smart_heal" or callback_type == "self_heal" then
        
        -- Passive Talents (globally)
        if LibDBCache:spell_affected_by_effect( callback.spellID, Player.getTalent( "chi_proficiency" ).effectN( 2 ) )
            gm = gm * Player.getTalent( "chi_proficiency" ).effectN( 2 ).mod
        end
                
        
        -- Self Healing
        if callback.type == "self_heal" then
            
            gm = gm * Player.getTalent( "grace_of_the_crane" ).effectN( 1 ).mod
            
            if Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"] then
                gm = gm * aura_env.celestialFortune()
            end
        end
        
        for aura_id, aura_modifier in ipairs ( aura_env.aura_amps_player_h ) do
            local aura = Player.findAura( aura_id )
            if aura and aura.remaining > future then
                local stacks = max( 1 , aura.stacks )
                gm = gm * ( 1 + ( aura_modifier - 1 ) * stacks * ( execute_time > 1 and min( 1, ( aura.remaining - future ) / execute_time ) or 1 ) )
            end
        end        
    else
        
        -- Damage
        
        -- Armor
        if not callback.ignore_armor then
            gm = gm * armor
        end
        
        -- Mystic Touch
        -- No point in debuff tracking for this spell as a Monk, save the CPU time
        if LibDBCache:spell_affected_by_effect( callback.spellID, spell.mystic_touch.effectN( 1 ) ) then
            gm = gm * spell.mystic_touch.effectN( 1 ).mod
        end
        
        -- Passive Talents
        gm = gm * Player.getTalent( "ferocity_of_xuen" ).effectN( 1 ).mod
        
        -- Chi Proficiency
        if LibDBCache:spell_affected_by_effect( callback.spellID, Player.getTalent( "chi_proficiency" ).effectN( 1 ) )
            gm = gm * Player.getTalent( "chi_proficiency" ).effectN( 1 ).mod
        end
    
        -- Martial Instincts
        if LibDBCache:spell_affected_by_effect( callback.spellID, Player.getTalent( "martial_instincts" ).effectN( 1 ) )
            gm = gm * Player.getTalent( "martial_instincts" ).effectN( 1 ).mod
        end    
        
        -- cached base 
        if callback == Player.default_action then
            aura_env.base_gm = gm
        end
        
          -- Miss
        if callback.may_miss then
            local enemy_level = target_count == 1 and UnitLevel( "target" ) or Combat.avg_level
            local miss = enemy_level > 0 and min( 1, max( 0, 0.03 + ( ( enemy_level - UnitLevel( "player" ) ) * 0.015 ) ) ) or 0.03
            gm = gm * ( 1 - miss )
        end      
        
        -- Dynamic Buffs/Debuffs
        if Player.buffs.press_the_advantage.up() and LibDBCache:spell_affected_by_effect( callback.spellID, Player.buffs.press_the_advantage.effectN( 1 ) ) then
            gm = gm * ( 1 + Player.buffs.press_the_advantage.stacks() * Player.buffs.press_the_advantage.effectN( 1 ).pct )
        end
        
        if Player.buffs.hit_combo.up() and LibDBCache:spell_affected_by_effect( callback.spellID, Player.buffs.hit_combo.effectN( 1 ) ) then
            gm = gm * ( 1 + Player.buffs.hit_combo.stacks() * Player.buffs.hit_combo.effectN( 1 ).pct  )
        end
        
        if Player.getTalent( "empowered_tiger_lightning" ).ok and callback.trigger_etl then
            if Player.buffs.xuen_the_white_tiger.remains() > future then
                gm = gm * ( Player.getTalent( "empowered_tiger_lightning" ).effectN( 2 ).mod * ( execute_time > 1 and min( 1, ( Player.buffs.xuen_the_white_tiger.remains() - future ) / execute_time ) or 1 ) )
            end
        end
        
        if callback.copied_by_sef and Player.buffs.storm_earth_and_fire.remains() > future then
            gm = gm * ( 1 + ( SEF_bonus - 1 ) * ( execute_time > 1 and min( 1, ( Player.buffs.storm_earth_and_fire.remains() - future ) / execute_time ) or 1 ) )
        end
        
        if Player.buffs.serenity.remains() > future then
            local serenity_bonus = ( aura_env.pvp_mode and 0.67 or 1 ) * SER_bonus
            gm = gm * ( 1 + ( serenity_bonus - 1 ) * ( execute_time > 1 and min( 1, ( Player.buffs.serenity.remains() - future ) / execute_time ) or 1 ) )
        end
        
        for aura_id, aura_modifier in ipairs ( aura_env.aura_amps_player ) do
            local aura = Player.findAura( aura_id )
            if aura and aura.remaining > future then
                local stacks = min( 1 , aura.stacks )
                gm = gm * ( 1 + ( aura_modifier - 1 ) * stacks * ( execute_time > 1 and min( 1, ( aura.remaining - future ) / execute_time ) or 1 ) )
            end
        end
        
        -- Tracked for heuristics but do not double-dip into damage output
        -- when real is set to false they will be approximated
        if real == false and Player.primary_stat > 0 then
            for aura_id, primary_stat in ipairs ( aura_env.aura_amps_primary ) do
                local aura = Player.findAura( aura_id )
                if aura and aura.remaining > future then
                    local stacks = max( 1 , aura.stacks )
                    local aura_modifier = 1 + ( stacks * primary_stat / Player.primary_stat )
                    gm = gm * ( 1 + ( aura_modifier - 1 ) * ( execute_time > 1 and min( 1, ( aura.remaining - future ) / execute_time ) or 1 ) )
                end
            end
        end
    end
    
    return gm
end

aura_env.forwardModifier = function ( callback, future )
    callback = callback or aura_env.spells[ Player.default_action ]
    future = future or 1
    return ( aura_env.global_modifier( callback, future, false ) * aura_env.targetAuraEffect( callback, future ) ) / ( aura_env.global_modifier( callback, 0, false ) * aura_env.targetAuraEffect( callback ) )
end

aura_env.targetScale = function( target_count, reduced_aoe, full_targets, reduced_aoe_mul, full_target_mul )
    if not target_count then
        return 0
    end
    
    local value = target_count
    reduced_aoe = reduced_aoe or 0 
    full_targets = full_targets or 0
    reduced_aoe_mul = reduced_aoe_mul or 1
    full_target_mul = full_target_mul or 1 
    if reduced_aoe > 0 and target_count > reduced_aoe then
        value = ( full_targets * full_target_mul ) + sqrt( reduced_aoe / min( 20, target_count ) ) * ( target_count - full_targets ) * reduced_aoe_mul
    end
    
    return value
end

aura_env.validTarget = function( unitID )
    
    local unitGUID = UnitGUID( unitID )
    
    return unitGUID 
    and UnitExists( unitID ) 
    and UnitCanAttack( "player", unitID ) 
    and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unitID ) )
end

aura_env.unitRange = function( unitID )
    
    local min_range, max_range = GetRange( unitID )
    local range = max_range or min_range or nil
    
    if range then
        return range
    end
    
    local range_check = {
        [100780] = 5, -- Tiger Palm
        [115546] = 30, -- Provoke
    }
    
    for spellid, spell_range in pairs( range_check ) do
        local name = GetSpellInfo( spellid )
        if IsSpellInRange( name, unitID ) == 1 then
            return spell_range
        end
    end
    
    return 40
end

aura_env.skyreach_modifier = function( callback )
    
    local callback_type = callback.type or "damage"
    
    if not callback.may_crit 
    or not LibDBCache:spell_affected_by_effect( callback.spellID, spell.keefers_skyreach.effectN( 1 ) )
    or callback_type ~= "damage" then
        return 0
    end
    
    local keefers_skyreach = 393047 --spellid
    
    local target_count = max( 1, min( 20, ( callback.target_count and callback.target_count() or 1 ) ) )
    local execute_time = callback.execute_time and callback.execute_time() or 1 
    
    if target_count == 1 and aura_env.validTarget( "target" ) then
        local Target = aura_env.GetEnemy( UnitGUID( "target" ) )
        local remaining = 0
        Target.auraExists( keefers_skyreach, function( auraData )
                if auraData.sourceUnit == "player" then
                    remaining = auraData.expirationTime - GetTime()
                    return true
                end    
        end )  
        if remaining > 0 then
            return spell.keefers_skyreach.effectN( 1 ).mod * ( execute_time > 1 and min( 1, remaining  / execute_time ) or 1 )
        end
    else
        local combined_rate = 0
        for _, auras in pairs( aura_env.targetAuras ) do
            local target_rate = 0
            
            local debuff = auras[ keefers_skyreach ]
            if debuff then 
                local remaining = debuff.expire - GetTime()
                if remaining > 0 then
                    target_rate = spell.keefers_skyreach.effectN( 1 ).mod * ( execute_time > 1 and min( 1, remaining  / execute_time ) or 1 )
                end
            end
            combined_rate = combined_rate + target_rate
        end
        
        if combined_rate > 0 then
            return combined_rate / aura_env.target_count
        end
    end
    
    return 0
end

aura_env.actionPostProcessor = function( result )
    
    if not result then
        return
    end
    
    local action = result.callback
    
    -- Augury of the Primal Flame: Annihilating Flame
    if Player.buffs.annihilating_flame.up() then
        
        local cap = Player.buffs.annihilating_flame.auraData().points[ 2 ]
        local annihilating_flame_damage = min( cap, 0.5 * result.critical_damage )
        
        result.damage = result.damage + annihilating_flame_damage
    end 
    
end

------------------------------------------------
-- Brew Math
------------------------------------------------

local dodgeMitigation = function( pct, duration )
    pct = pct or 1
    duration = duration or 1
    
    if Player.recent_dtps == 0 then
        return 0
    end
    
    -- Avoidance gain multiplied by current DTPS
    local m = Player.recent_dtps * pct * duration
    
    -- % of incoming magic damage
    local X =  max( 0, 1 - ( ( Combat.damage_taken_avoidable + aura_env.danger_a ) / ( Combat.damage_taken_unavoidable + aura_env.danger_b ) ) )
    
    -- Current avoidance value
    -- Character sheet dodge updates with Elusive Brawler automatically
    local Av = ( GetDodgeChance() + GetParryChance() ) / 100 
    Av = Av + ( 0.05 - ( 0.002 * ( Combat.avg_level - UnitLevel( "player" ) ) ) )
    
    -- m is diminished based on current avoidance and amount of magic damage
    m = m * ( min( 0, Av - 1 ) * ( X - 1 ) )
    
    return m
end

------------------------------------------------
-- Spec Initialization
------------------------------------------------

aura_env.spells = {}

local function deepcopy(orig, copies)
    
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    
    return copy
end

local function generateChannels( actions )

    for action, init in pairs( actions ) do
        if init.channeled then
            local canceled_name = action .. "_cancel"
            if not actions[ canceled_name ] then
                local _init = deepcopy( init )
                _init.canceled = true
                _init.execute_time = nil
                actions[ canceled_name ] = Player.createAction( init.spellID, _init )
            end
        end
    end
end

local function generateCallbacks( spells )
    
    local recursive = nil
    while not recursive do
        recursive = true
        for action, base_spell in pairs( spells ) do
            if base_spell.usable_during_sck and not base_spell.background then
                base_spell.callbacks = base_spell.callbacks or {}
                base_spell.callbacks[ #base_spell.callbacks + 1 ] = "spinning_crane_kick"
            end
            
            base_spell.depth = base_spell.depth or 0
            
            if base_spell.depth == 0 and base_spell.callbacks then
                for _, callback in pairs( base_spell.callbacks ) do
                    
                    local cb_spell = spells[ callback ]
                    
                    if cb_spell then
                        -- force binary search
                        cb_spell.callbacks = cb_spell.callbacks or {}
                        cb_spell.callbacks[ #cb_spell.callbacks + 1 ] = action
                        spells[ callback ].callbacks = cb_spell.callbacks
                        
                        local name = callback.."_"..action.."_generated"
                        if not spells[ name ] then
                            
                            local _init = deepcopy( cb_spell )
                            _init.combo = true
                            _init.combo_base = callback
                            _init.depth = ( _init.depth or 0 ) + 1
                            _init.trigger = _init.trigger or {}
                            _init.trigger[ action ] = true
                            _init.ready = function() 
                                if not base_spell.background and IsSpellKnown( base_spell.replaces or base_spell.spellID ) then
                                    return base_spell.callback_ready and base_spell.callback_ready( callback ) or cb_spell.ready
                                else
                                    return false
                                end
                            end

                            spells[ name ] = Player.createAction( _init.spellID, _init )
                            
                            recursive = false
                        end
                    end
                end
            end
        end
    end
    
    -- Garbage cleaning
    for _, data in pairs( spells ) do
        data.callbacks = nil
    end
end    

aura_env.auraEffectForSpell = function ( spellID, periodic )
    
    local total_aura_effect = 1
    local spec_aura = Player.spec_aura
    
    if spec_aura and spec_aura.effectN then
    
        local it = 1
        local effect = 0
        while ( effect ~= nil ) do
            effect = spec_aura.effectN( it )
            if effect and effect.affected_spells then
                if effect.affected_spells[ spellID ] then
                    local properties = effect.properties
                    if properties and properties.add_percent_modifier then
                        if ( periodic and properties.spell_periodic_amount ) or ( not periodic and properties.spell_direct_amount ) then
                            total_aura_effect = total_aura_effect * ( effect.mod or 1 ) 
                        end
                    end
                end
            end
            it = it + 1
        end
    end
    
    return total_aura_effect
end

------------------------------------------------
-- Class specific state helper functions
------------------------------------------------

local CurrentCraneStacks = function( state )
    
    if not Player.getTalent( "mark_of_the_crane" ).ok then
        return 0
    end
    
    local motc_stacks = GetSpellCount( 101546 )
    
    if not state then
        return motc_stacks
    else
        local unmarked = aura_env.unmarked_targets()
        if unmarked > 0 then
            
            for cb_idx, cb in ipairs( state.callback_stack ) do
                if cb_idx == #state.callback_stack then
                    break
                end
                
                local motc_gain = cb.spell and cb.spell.generate_marks
                
                motc_gain = ( type( motc_gain ) == "function" and motc_gain() or motc_gain ) or 0
                
                if motc_gain > 0 then

                    if Player.buffs.storm_earth_and_fire.up() and not aura_env.sef_fixate then
                        motc_gain = motc_gain * 3
                    end
                    
                    motc_gain = min( unmarked, motc_gain )
                    motc_stacks = motc_stacks + motc_gain
                    unmarked = unmarked - motc_gain
                end
                
                if unmarked <= 0 then
                    break
                end
            end
        end
        
        return motc_stacks
    end
end

local IsBlackoutCombo = function( state )
    if not state then
        return Player.buffs.blackout_combo.up()
    else
        local blackout_combo = Player.buffs.blackout_combo.up()
        
        if Player.getTalent( "blackout_combo" ).ok then
            
            local _next = nil
            local consume_boc = { 
                ["tiger_palm"] = true, 
                ["pta_keg_smash"] = true, 
                ["pta_rising_sun_kick"] = true, 
                ["breath_of_fire"] = function() return ( _next.name ~= "breath_of_fire_periodic" ) end,
                ["breath_of_fire_periodic"] = true,
                ["keg_smash"] = function() return ( _next.name ~= "pta_keg_smash" ) end, 
                ["celestial_brew"] = true, 
                ["purifying_brew"] = true, 
            }
            
            local _, stack = ipairs( state.callback_stack )
            local cb_idx = 1
            
            for cb_idx = 1, #stack do
                if cb_idx == #stack then
                    break
                end
                
                local cb = stack[ cb_idx ] 
                _next = stack [ cb_idx + 1 ]
                
                if cb.name == "blackout_kick" then
                    blackout_combo = true
                else
                    local consume = consume_boc[ cb.name ]
                    if type( consume ) == "function" and consume() or consume == true then
                        blackout_combo = false
                    end
                end
            end
        end        
        return blackout_combo
    end
end

local IsBlackoutReinforcement = function( state )
    
    if Player.set_pieces[ 31 ] < 2 then
        return false
    end
    
    if not state then
        return Player.buffs.blackout_reinforcement.up()
    else
        local blackout_reinforcement = Player.buffs.blackout_reinforcement.up()
        
        for cb_idx, cb in ipairs( state.callback_stack ) do
            if cb_idx == #state.callback_stack then
                break
            end

            if cb.name == "spinning_crane_kick" and cb.spell and cb.spell.base_cost == 0 then
                blackout_reinforcement = true
            elseif cb.name == "blackout_kick" then
                blackout_reinforcement = false
            end
        end
        return blackout_reinforcement
    end    
end

local IsFlowingMomentumKicks = function( state )
    
    if Player.set_pieces[ 29 ] < 2 and Player.set_pieces[ 32 ] < 2 then
        return false
    end
    
    if not state then
        return Player.buffs.kicks_of_flowing_momentum.up()
    else
        local flowing_momentum = Player.buffs.kicks_of_flowing_momentum.up()
        
        for cb_idx, cb in ipairs( state.callback_stack ) do
            if cb_idx == #state.callback_stack then
                break
            end
            
            if cb.name == "fists_of_fury" then
                flowing_momentum = true
            elseif cb.name == "rising_sun_kick" then
                flowing_momentum = false
            end
        end
        return flowing_momentum
    end
end

local IsDanceProc = function( state )
    if not Player.getTalent( "dance_of_chiji" ).ok then
        return false
    end
    
    if not state then
        return Player.buffs.dance_of_chiji.up()
    else
        local docj_stacks = Player.buffs.dance_of_chiji.stacks()
        local max_stacks = Player.buffs.dance_of_chiji.max_stacks()
        
        for cb_idx, cb in ipairs( state.callback_stack ) do
            if cb_idx == #state.callback_stack then
                break
            end
            
            if cb.name == "whirling_dragon_punch" then
                if Player.getTalent( "revolving_whirl" ).ok then
                    docj_stacks = min( max_stacks, docj_stacks + 1 )
                end
            elseif cb.name == "spinning_crane_kick" and docj_stacks > 0 then
                docj_stacks = max( 0, docj_stacks - 1 )
            end    

        end
        return docj_stacks > 0
    end  
end

local IsBlackoutProc = function( state )
    
    if not state then
        return Player.buffs.bok_proc.up()
    else
        local bok_stacks = Player.buffs.bok_proc.stacks()
        local docj_stacks = Player.buffs.dance_of_chiji.stacks()
        
        local _next = nil
        local _, stack = ipairs( state.callback_stack )
        local cb_idx = 1
        
        for cb_idx = 1, #stack do
            if cb_idx == #stack then
                break
            end
            
            local cb = stack[ cb_idx ] 
             _next = stack [ cb_idx + 1 ]
             
            if cb.name == "spinning_crane_kick" and docj_stacks > 0 then
                if Player.getTalent( "sequenced_strikes" ).ok then
                    bok_stacks = min( Player.buffs.bok_proc.max_stacks(), bok_stacks + 1 )
                end
                
                docj_stacks = max( 0, docj_stacks - 1 )
            elseif cb.name == "whirling_dragon_punch" then
                if Player.getTalent( "revolving_whirl" ).ok then
                    docj_stacks = min( Player.buffs.dance_of_chiji.max_stacks(), docj_stacks + 1 )
                end
            elseif cb.name == "blackout_kick" and _next.name ~= "energy_burst" then
                bok_stacks = max( 0, bok_stacks - 1 )
            end
        end
        
        return bok_proc
    end
end

local GetTotMStacks = function( state )
    
    if not Player.getTalent( "teachings_of_the_monastery" ).ok then
        return 0
    end
    
    if not state then
        return Player.buffs.teachings_of_the_monastery.stacks()
    else
        local totm_stacks = Player.buffs.teachings_of_the_monastery.stacks()
        local max_stacks = Player.buffs.teachings_of_the_monastery.max_stacks()
        
        for cb_idx, cb in ipairs( state.callback_stack ) do
            if cb_idx == #state.callback_stack then
                break
            end
            
            if cb.name == "tiger_palm" then
                totm_stacks = math.min( max_stacks, totm_stacks + 1 )
            elseif cb.name == "whirling_dragon_punch" then
                totm_stacks = math.min( max_stacks, totm_stacks + Player.getTalent( "knowledge_of_the_broken_temple" ).effectN( 1 ).base_value )
            elseif cb.name == "blackout_kick" then
                totm_stacks = 0
            end
        end
        return totm_stacks
    end    
end

-- --------- --
-- WW Spells
-- --------- --

local ww_spells = {
    -- Djaruun the Elder Flame
    -- TODO: Generic Actions
    -- TODO: Actual item scaling? This is very lazy
    ["ancient_lava"] = Player.createAction( 408836, {
        background = true,
        icd = 0.5, -- Missing from spell data
        bonus_da = function()
            -- actual scaling isn't quite linear but this should be close
            local itemLevel = GetDetailedItemLevelInfo( GetInventoryItemLink( "player", 16 ) )
            local damage = itemLevel < 500 and 17838 - 215 * ( 450 - itemLevel ) or 50835 - 215 * ( 528 - itemLevel )
            local split = damage / aura_env.target_count
            return split
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            -- Doesn't say in tooltip but damage scales with targets
            return ( 1 + ( min( 5, target_count ) - 1 ) * 0.15 ) 
        end,
        ready = function()
            return Player.findAura( 408835 )
        end,      
    } ),

    ["fists_of_fury"] = Player.createAction( 113656, {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR        
        },
        
        damageID = 117418,
        
        ticks = 5,
        hasted_cooldown = true,

        ww_mastery = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        
        action_multiplier = function()
            local am = 1
            
            am = am * Player.getTalent( "flashing_fists" ).effectN( 1 ).mod
            
            if Player.buffs.transfer_the_power.up() then
                am = am * ( 1 + Player.buffs.transfer_the_power.stacks() * Player.getTalent( "transfer_the_power" ).effectN( 1 ).pct )
            end
            
            am = am * Player.getTalent( "open_palm_strikes" ).effectN( 4 ).mod
            
            if Player.buffs.fists_of_flowing_momentum.up() then
                am = am * ( 1 + Player.buffs.fists_of_flowing_momentum.stacks() * Player.buffs.fists_of_flowing_momentum.effectN( 1 ).pct )
            end
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end        
            
            return am
        end,
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 117418 )
        end,
        
        target_multiplier = function( target_count )  
            local primary_multiplier = 1
            
            return aura_env.targetScale( target_count, spell.fists_of_fury.effectN( 1 ).base_value, 1, spell.fists_of_fury.effectN( 6 ).pct, primary_multiplier )
        end,
        
        tick_trigger = {
            ["open_palm_strikes"] = true,
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },
    } ),

    ["rising_sun_kick"] = Player.createAction( 107428, {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR
            "fists_of_fury", -- Pressure Point / T29 + T32 Set
            "fists_of_fury_cancel", -- Pressure Point / T29 + T32 Set
        },
        
        damageID = 185099, -- This spell is really weird and triggers 185099 for the damage event even though it's not channeled
        
        hasted_cooldown = true,
        
        generate_marks = 1,
        usable_during_sck = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        ww_mastery = true,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            -- Buff isn't gained until channel ends but still affects RSK if you break the channel with it
            if ( Player.channel.spellID and Player.channel.spellID == 113656 and Player.getTalent( "xuens_battlegear" ).ok )
            -- 
            or Player.buffs.pressure_point.up() then
                cr = cr + Player.buffs.pressure_point.effectN( 1 ).roll
            end
            
            return min(1, cr)
        end,
        
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.getTalent( "rising_star" ).effectN( 2 ).mod
            
            return cm
        end,   
        
        action_multiplier = function( state )
            local am = 1
            
            am = am * Player.getTalent( "fast_feet" ).effectN( 1 ).mod
            
            am = am * Player.getTalent( "rising_star" ).effectN( 1 ).mod
            
            if IsFlowingMomentumKicks( state ) then
                am = am * Player.buffs.kicks_of_flowing_momentum.effectN( 1 ).mod
            end
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end     
            
            return am
        end,
        
        trigger = {
            ["glory_of_the_dawn"] = true,
            ["chi_wave"] = function()
                -- Todo: Replace with buff.up()
                return Player.findAura( 450380 )
            end,
        },
    
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },
    
        reduces_cd = {
            ["fists_of_fury"] = function() 
                return Player.getTalent( "xuens_battlegear" ).effectN( 2 ).seconds * aura_env.spells["rising_sun_kick"].critical_rate()
            end,
        },
    
    } ),

    ["spinning_crane_kick"] = Player.createAction( 101546, {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also MotC and Mastery eval.
            "expel_harm", -- also Mastery eval.
            "chi_burst",
            
            "fists_of_fury", -- Tier 29 / Tier 32
            "fists_of_fury_cancel", -- Tier 29 / Tier 32
            "blackout_kick", -- MotC and Mastery eval.
            "strike_of_the_windlord", -- Mastery eval.
            "whirling_dragon_punch", -- Mastery eval.
            "rushing_jade_wind", -- Mastery eval.
            "flying_serpent_kick", -- Mastery eval.
        },
        
        damageID = 107270,

        ap = function() 
            return spell.sck_tick.effectN( 1 ).ap_coefficient 
        end,
        
        ticks = 4,
        
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        ww_mastery = true,
        
        chi_gain = function()
            if Player.bdb_targets > 0 then
                return 1
            end
            
            return 0
        end,
        
        action_multiplier = function( state )
            local am = 1
            
            local motc_stacks = CurrentCraneStacks( state )
            
            if motc_stacks > 0 then
                am = am * ( 1 + ( motc_stacks * spell.cyclone_strikes.effectN( 1 ).pct ) )
            end
            
            if IsDanceProc( state ) then
                am = am * Player.getTalent( "dance_of_chiji" ).effectN( 1 ).mod
            end
            
            am = am * Player.getTalent( "crane_vortex" ).effectN( 1 ).mod
            
            if IsFlowingMomentumKicks( state ) then
                am = am * Player.buffs.kicks_of_flowing_momentum.effectN( 1 ).mod
            end
            
            am = am * Player.getTalent( "fast_feet" ).effectN( 2 ).mod
            
            return am
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.spinning_crane_kick.effectN( 1 ).base_value )
        end,
        
        trigger = {
            ["chi_explosion"] = true,
        },
    
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,            
        },
    
    } ),

    ["blackout_kick_totm"] = Player.createAction( 228649, {
        
        background = true,
        
        copied_by_sef = true,
        trigger_etl = true,
        ww_mastery = false,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.getTalent( "hardened_soles" ).effectN( 1 ).roll
            
            return min(1, cr)
        end,
        
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.getTalent( "hardened_soles" ).effectN( 2 ).mod
            
            return cm
        end,
        
        action_multiplier = function()
            local am = 1
            
            am = am * Player.getTalent( "shadowboxing_treads" ).effectN( 2 ).mod
            
            am = am * Player.getTalent( "brawlers_intensity" ).effectN( 2 ).mod
            
            return am
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    } ),

    ["energy_burst"] = Player.createAction( 451498, {
        background = true,
        
        chi_gain = function( state )
            if IsBlackoutProc( state ) then
                return Player.getTalent( "energy_burst" ).effectN( 2 ).base_value
            end
            
            return 0
        end,
        
        trigger_rate = function( callback )
            return Player.getTalent( "energy_burst" ).effectN( 1 ).roll
        end,
        
        ready = function()
            return Player.getTalent( "energy_burst" ).ok
        end,
    } ),

    ["blackout_kick"] = Player.createAction( 100784, {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also TotM
            "expel_harm",
            "chi_burst",      
            
            "spinning_crane_kick", -- T31 Set Bonus
            "rising_sun_kick", -- CDR
            "fists_of_fury", -- CDR
            "strike_of_the_windlord", -- CDR (T31)
            "whirling_dragon_punch", -- CDR (T31)
        },
        
        usable_during_sck = true,       
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        ww_mastery = true,
        
        generate_marks = function()
            if Player.is_beta() then
                return 1
            end
            
            return 1 + Player.getTalent( "shadowboxing_treads" ).effectN( 1 ).base_value
        end,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.getTalent( "hardened_soles" ).effectN( 1 ).roll
            
            return min(1, cr)
        end,
        
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.getTalent( "hardened_soles" ).effectN( 2 ).mod
            
            return cm
        end,   
        
        action_multiplier = function( state )
            local am = 1
            
            am = am * Player.getTalent( "shadowboxing_treads" ).effectN( 2 ).mod
            
            if IsBlackoutReinforcement( state ) then
                am = am * Player.buffs.blackout_reinforcement.effectN( 1 ).mod
            end
            
            am = am * Player.getTalent( "brawlers_intensity" ).effectN( 2 ).mod
            
            if IsBlackoutProc( state ) then
                am = am * Player.getTalent( "courageous_impulse" ).effectN( 1 ).mod
            end
            
            return am
        end,
        
        target_count = function()
            return min( aura_env.target_count, 1 + Player.getTalent( "shadowboxing_treads" ).effectN( 1 ).base_value )
        end,
        
        target_multiplier = function( target_count )
            if Player.is_beta() then
                local chain_targets = min( 0, target_count - 1 )
                return 1 + ( chain_targets * Player.getTalent( "shadowboxing_treads" ).effectN( 3 ).pct )
            end
            
            return target_count
        end,
        
        reduces_cd = {
            ["rising_sun_kick"] = function( state ) 
                local cdr = spell.blackout_kick.effectN( 3 ).seconds 
                
                if Player.getTalent( "teachings_of_the_monastery" ).ok then
                    local remaining = aura_env.getCooldown( 107428 ) -- RSK
                    if remaining > 0 then
                        local targets = min( aura_env.target_count, 1 + Player.getTalent( "shadowboxing_treads" ).effectN( 1 ).base_value )
                        local totm_stacks = GetTotMStacks( state )
                        
                        cdr = cdr + ( min( 1, Player.getTalent( "teachings_of_the_monastery" ).effectN( 1 ).roll * targets * ( 1 + totm_stacks ) ) * remaining )
                    end
                end
                
                if IsBlackoutReinforcement( state ) then
                    cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                end
                
                return cdr
            end,
            
            ["fists_of_fury"] = function( state )
                local cdr = spell.blackout_kick.effectN( 3 ).seconds
                
                if IsBlackoutReinforcement( state ) then
                    cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                end                
                
                return cdr
            end,
            
            ["strike_of_the_windlord"] = function( state )
                local cdr = 0
                
                if IsBlackoutReinforcement( state ) then
                    cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                end                
                
                return cdr
            end,
            
            ["whirling_dragon_punch"] = function( state )
                local cdr = 0
                
                if IsBlackoutReinforcement( state ) then
                    cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                end             
                
                return cdr
            end,            
        },
    
        trigger = {
            ["energy_burst"] = true,    
        },
    
        tick_trigger = {
            ["ancient_lava"] = true,  
            ["blackout_kick_totm"] = function( driver )
                local totm_stacks = 0
                
                if Player.getTalent( "teachings_of_the_monastery" ).ok then
                    local totm_max_stacks = Player.buffs.teachings_of_the_monastery.max_stacks()
                    totm_stacks = Player.buffs.teachings_of_the_monastery.stacks() + ( driver == "tiger_palm" and 1 or 0 )
                    totm_stacks = totm_stacks + ( driver == "whirling_dragon_punch" and Player.getTalent( "knowledge_of_the_broken_temple" ).effectN( 1 ).base_value or 0 )
                    totm_stacks = min( totm_max_stacks, totm_stacks )
                end
                
                return totm_stacks > 0, totm_stacks
            end,
            ["resonant_fists"] = true,
        },    
    } ),

    ["wdp_st_tick"] = Player.createAction( Player.is_beta() and 451767 or nil, {
        background = true,
        
        ww_mastery = true,
        copied_by_sef = true,
        trigger_etl = true,
        
        action_multiplier = function ( )
            local am = 1
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end    
            
            am = am * Player.getTalent( "knowledge_of_the_broken_temple" ).effectN( 2 ).mod
            
            return am
        end,        
        
        tick_trigger = {
            ["ancient_lava"] = true,  
            ["resonant_fists"] = true,
        },       
    }),

    ["whirling_dragon_punch"] = Player.createAction( 152175, {
        callbacks = {
            "rising_sun_kick", -- Spell activation        
        },
        
        damageID = 158221,
        ticks = 3,
        hasted_cooldown = true,
        
        ww_mastery = true,
        usable_during_sck = true,    
        copied_by_sef = true,
        trigger_etl = true,
        
        ready = function()
            return Player.getTalent( "whirling_dragon_punch" ).ok
        end,
        
        callback_ready = function( callback )
            
            -- Not talented into WDP
            if not Player.getTalent( "whirling_dragon_punch" ).ok then
                return false
            end
            -- WDP not ready
            if aura_env.getCooldown( 152175 ) ~= 0 then
                return false
            end
            
            local fof_remains = aura_env.getCooldown( 113656 )
            
            -- Fists of Fury not on CD
            if fof_remains == 0 then
                return false
            end
            
            -- Not enough reaction time to perform the combo
            if fof_remains < 2.25 then
                return false
            end
            
            return true            
        end,
        
        action_multiplier = function ( )
            local am = 1
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end
            
            am = am * Player.getTalent( "knowledge_of_the_broken_temple" ).effectN( 2 ).mod
            
            return am
        end,  
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            
            if Player.is_beta() then
                return aura_env.targetScale( target_count, Player.getTalent( "whirling_dragon_punch" ).effectN( 1 ).base_value )
            end
            
            return target_count
        end,
        
        trigger = {
            ["wdp_st_tick"] = Player.is_beta(),
        },
        
        tick_trigger = {
            ["ancient_lava"] = true,  
            ["resonant_fists"] = true,
        },        
    } ),

    ["strike_of_the_windlord_mh"] = Player.createAction( 395519, {
        background = true,
        
        ww_mastery = true,
        trigger_etl = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        
        action_multiplier = function ( )
            local am = 1
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end        
            
            am = am * Player.getTalent( "communion_with_wind" ).effectN( 2 ).mod
            
            return am      
        end,  
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 395521 )
        end,
        
        target_multiplier = function( target_count )
            return ( 1 + 1 / target_count * ( target_count - 1 ) )
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true, 
            ["resonant_fists"] = true,
        },    
    } ),

    -- TODO: May need to separate OH hit into a triggered spell at some point, currently not necessary
    -- Just setting DamageID as the OH hit, createAction handles the rest
    ["strike_of_the_windlord"] = Player.createAction( 392983, {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR (Tier 31)        
        },
        
        damageID = 395521, -- OH hit
        
        ww_mastery = true,
        usable_during_sck = true,   
        trigger_etl = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        
        action_multiplier = function ( )
            local am = 1
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end
            
            am = am * Player.getTalent( "communion_with_wind" ).effectN( 2 ).mod
            
            return am      
        end, 
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 395521 )
        end,
        
        target_multiplier = function( target_count )
            return ( 1 + 1 / target_count * ( target_count - 1 ) )
        end,
        
        trigger = {
            ["thunderfist"] = true,
            ["strike_of_the_windlord_mh"] = true,
        },
    
        tick_trigger = {
            ["ancient_lava"] = true, 
            ["resonant_fists"] = true,
        },
    
        ready = function()
            local cd_xuen = aura_env.getCooldown( 123904 )
            return cd_xuen > 12 or cd_xuen < 1 
        end,
    } ),

    ["rushing_jade_wind"] = Player.createAction( 116847, {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also MotC and Mastery eval.
            "expel_harm", -- also Mastery eval.
            "chi_burst",
        },
        
        damageID = 148187,
        base_tick_rate = 0.75, -- TODO: Better buff handling
        hasted_cooldown = true,
        
        ww_mastery = true,
        usable_during_sck = true,     
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,

        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.rushing_jade_wind.effectN( 1 ).base_value )
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },        
    } ),

    -- TODO: Refactor this with proper Debuffs
    ["jadefire_brand"] = {
        type = "damage_buff",
        debuff = true,
        spellID = 395414,
        pct = function()
            return spell.jadefire_brand_dmg.effectN( 1 ).pct
        end,
        duration = function()
            local base_duration = 10
            local duration = base_duration
            
            if Player.jfh_targets > 0 then
                local target_count = aura_env.learnedFrontalTargets( 388201 )
                local target_limit = 5
                duration = base_duration - ( Player.jfh_dur_total / Player.jfh_targets )
                duration = ( duration * min( target_count, Player.jfh_targets ) )
                duration = duration + ( base_duration * min( target_limit, ( target_count - Player.jfh_targets ) ) )
                duration = duration / target_count
            end
            return max( 0, duration )
        end,
        ready = function()
            return Player.getTalent( "jadefire_harmony" ).ok
        end,
    },

    ["jadefire_stomp_ww"] = Player.createAction( 388201, {

        background = true,
        
        trigger_etl = true,
        ignore_armor = true,
        ww_mastery = true,
        
        action_multiplier = function()
            local am = 1
            
            if Player.getTalent( "path_of_jade" ).ok then 
                local poj_targets = min( aura_env.learnedFrontalTargets( 388201 ), Player.getTalent( "path_of_jade" ).effectN( 2 ).base_value )
                am = am * ( 1 + Player.getTalent( "path_of_jade" ).effectN( 1 ).pct * poj_targets )
            end
            
            return am
        end,
        target_count = function()
            return aura_env.learnedFrontalTargets( 388201 )
        end,
        target_multiplier = function( target_count )
            return min( 5, target_count )
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },        
    } ),    

    ["jadefire_stomp"] = Player.createAction( 388193, {

        damageID = 388207, 

        usable_during_sck = true,       
        trigger_etl = true,
        ignore_armor = true,
        ww_mastery = true,
        
        ready = function()
            return Player.getTalent( "jadefire_stomp" ).ok and aura_env.fight_remains > 5 and Player.moving == false
        end,
        
        action_multiplier = function()
            local am = 1
            
            if Player.getTalent( "path_of_jade" ).ok then 
                local poj_targets = min( aura_env.learnedFrontalTargets( 388201 ), Player.getTalent( "path_of_jade" ).effectN( 2 ).base_value )
                am = am * ( 1 + Player.getTalent( "path_of_jade" ).effectN( 1 ).pct * poj_targets )
            end
            
            return am
        end,
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 388201 )
        end,
        
        target_multiplier = function( target_count )
            return min( 5, target_count )
        end,
        
        trigger = {
            ["jadefire_brand"] = true,    
        },
    
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },        
    } ),

    ["tiger_palm"] = Player.createAction( 100780, {

        chi_gain = function() 
            if Player.is_beta() then
                return 2
            end
            
            return ( Player.buffs.power_strikes.up() and 3 or 2 ) 
        end,
        
        generate_marks = 1,
        usable_during_sck = true,     
        trigger_etl = true,
        copied_by_sef = true,    
        ww_mastery = true,
        
        action_multiplier = function()
            local am = 1
            
            local combat_wisdom = Player.is_beta() and Player.getTalent( "combat_wisdom" ) or Player.getTalent( "power_strikes" )
            
            if Player.buffs.power_strikes.up() and combat_wisdom.ok then
                am = am * combat_wisdom.effectN( 2 ).mod
            end
            
            am = am * Player.getTalent( "touch_of_the_tiger" ).effectN( 1 ).mod
            
            am = am * Player.getTalent( "inner_peace" ).effectN( 2 ).mod
            
            return am
        end,
        
        trigger = {
            ["expel_harm"] = Player.is_beta(),
        },
        
        tick_trigger = {
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },    
    } ),

    ["chi_burst"] = Player.createAction( 123986, {

        damageID = 148135,
        
        trigger_etl = true,
        copied_by_sef = true,   
        ww_mastery = true,
        
        chi_gain = function()
            if Player.is_beta() then
                return 0
            end
            
            return min( 2, aura_env.target_count ) 
        end,

        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        tick_trigger = {
            ["resonant_fists"] = true,
        },
    } ),

    ["chi_wave"] = Player.createAction( Player.is_beta() and 450391 or 115098, {
        background = Player.is_beta(),
        damageID = 132467,
        ticks = 4, -- 4 Damage Bounces
        
        ww_mastery = true,
        usable_during_sck = true,        
        trigger_etl = true,
        copied_by_sef = true,
 
        tick_trigger = {
            ["resonant_fists"] = true,
        },        
    } ),

    ["expel_harm"] = Player.createAction( Player.is_beta() and 451968 or 322101, {
        trigger_etl = true,
        ww_mastery = true,
        usable_during_sck = true,
        
        chi_gain = function()
            
            local chi = Player.is_beta() and 0 or 1
            
            if IsPlayerSpell( spell.reverse_harm.id ) then -- Reverse Harm
                chi = chi + spell.reverse_harm.effectN( 2 ).base_value
            end
            
            return chi
        end,
        
        action_multiplier = function()
            local h = 1
            
            h = h * Player.getTalent( "vigorous_expulsion" ).effectN( 1 ).mod
            
            if Player.getTalent( "strength_of_spirit" ).ok then
                local health_deficit = UnitHealthMax( "player" ) - UnitHealth( "player" )
                local health_percent = health_deficit / UnitHealthMax( "player" )
                
                h = h * ( 1 + ( health_percent * Player.getTalent( "strength_of_spirit" ).effectN( 1 ).pct ) )
            end
            
            if IsPlayerSpell( spell.reverse_harm.id ) then -- Reverse Harm
                h = h * spell.reverse_harm.effectN( 1 ).mod
            end
            
            return h
        end,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.getTalent( "vigorous_expulsion" ).effectN( 2 ).mod
            
            return min( 1, cr )
        end,
        
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.getTalent( "profound_rebuttal" ).effectN( 1 ).mod 
            
            return cm
        end,        
    } ),

    -- TODO: Generic Actions
    ["arcane_torrent"] = {
        spellID = 28730,
        chi_gain = function() return 1 end,
        execute_time = function()
            return aura_env.gcd( 28730 )
        end,
    },

    ["flying_serpent_kick"] = Player.createAction( 101545, {

        damageID = Player.is_beta() and 123586 or nil,

        ww_mastery = true,

        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        ready = function()
            local combo_spellid = Player.last_combo_strike
            local combo_ready, need_resources = IsUsableSpell( combo_spellid )
            
            -- Ready to fire
            if combo_ready then
                return true
            end
            
            -- We don't have enough Chi to perform a combo strike
            if need_resources and aura_env.chi_base_cost( combo_spellid ) > 0 then
                return false
            end
            
            -- Waiting on cooldown
            if aura_env.getCooldown( combo_spellid ) <= aura_env.gcd( 101545 ) + 0.250 then
                return true
            end
            
            return false
            
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    } ),

    ["chi_explosion"] = Player.createAction( 393056, {

        background = true,

        trigger_etl = true,
        ww_mastery = false,
        
        action_multiplier = function()
            if Player.buffs.chi_energy.up() then
                return ( 1 + Player.buffs.chi_energy.stacks() * spell.chi_energy.effectN( 1 ).pct )
            end
            return 0
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
    } ),

    -- TODO: Redo Thunderfist with Auto-Attack refactor
    ["thunderfist_single"] = {
        spellID = 393566,
        ap = function()
            return spell.thunderfist.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        trigger_etl = true,
        ignore_armor = true,
        ww_mastery = false,
    },
    ["thunderfist"] = {
        spellID = 393566,
        ap = function()
            return spell.thunderfist.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        trigger_etl = true,
        ignore_armor = true,
        ww_mastery = false,
        target_count = function()
            return aura_env.learnedFrontalTargets( 395521 ) -- SotWL
        end,        
        target_multiplier = function( target_count )
            local current_stacks = Player.buffs.thunderfist.stacks()
            local stacks_acquired = target_count + ( Player.is_beta() and Player.getTalent( "thunderfist" ).effectN( 1 ).base_value or 0 )
            local stacks = min( 10, stacks_acquired + current_stacks )
            return min( stacks, aura_env.fight_remains / ( UnitAttackSpeed( "player" ) or 4 ) )          
        end,
    },

    ["crackling_jade_lightning"] = Player.createAction( 117952, {

        ticks = 4,
  
        copied_by_sef = true,    
        ww_mastery = true,
        
        action_multiplier = function()
            local am = 1
            
            if Player.buffs.the_emperors_capacitor.up() then
                am = am * ( 1 + Player.buffs.the_emperors_capacitor.stacks() * spell.emperors_capacitor.effectN( 1 ).pct )
            end
            
            return am
        end,
        
        tick_trigger = {
            ["resonant_fists"] = true,
        },
    } ),

    ["glory_of_the_dawn"] = Player.createAction( 392959, {
        background = true,

        trigger_etl = true,
        copied_by_sef = true, 
        ww_mastery = true,
         
        chi_gain = function()
            if Player.is_beta() then
                return Player.getTalent( "glory_of_the_dawn" ).effectN( 3 ).base_value     
            end
            
            return Player.getTalent( "glory_of_the_dawn" ).effectN( 2 ).base_value 
        end,
        
        trigger_rate = function() 
            if Player.is_beta() then
                return Player.getTalent( "glory_of_the_dawn" ).effectN( 2 ).roll * Player.haste
            end
            
            return Player.getTalent( "glory_of_the_dawn" ).effectN( 3 ).roll 
        end,
        
        ready = function()
            return Player.getTalent( "glory_of_the_dawn" ).ok
        end,
        
        tick_trigger = {
            ["ancient_lava"] = true,            
        }, 
    } ),

    ["resonant_fists"] = Player.createAction( 389578, {
        background = true,
        
        trigger_etl = true,

        action_multiplier = function()
            return Player.getTalent( "resonant_fists" ).rank 
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
        
        ready = function()
            return Player.getTalent( "resonant_fists" ).ok
        end,
    } ),

    ["open_palm_strikes"] = Player.createAction( 392970, {
        background = true,
        
        chi_gain = function() 
            return Player.getTalent( "open_palm_strikes" ).effectN( 3 ).base_value 
        end,
        
        trigger_rate = function( callback )
            return Player.getTalent( "open_palm_strikes" ).effectN( 2 ).roll
        end,
        
        ready = function()
            return Player.getTalent( "open_palm_strikes" ).ok
        end,
    } ),

    -- TODO: Refactor this to debuff at some point?
    ["touch_of_karma"] = Player.createAction( 122470, {

        damageID = 124280,

        trigger_etl = false,
        
        bonus_da = function()
            local tick_time = min( aura_env.target_ttd, 10 )
            local health_mod = Player.getTalent( "touch_of_karma" ).effectN( 3 ).pct
            return min( UnitHealthMax( "player" ) * health_mod, Player.recent_dtps * tick_time ) * Player.getTalent( "touch_of_karma" ).effectN( 4 ).pct
        end,
        
        ready = function()
            local tick_time = min( aura_env.target_ttd, 10 )
            local health_mod = Player.getTalent( "touch_of_karma" ).effectN( 3 ).pct
            
            -- Hold for next tank buster if applicable
            if aura_env.danger_next and ( aura_env.danger_next < 90 and aura_env.danger_next > 10 )
            -- and we're not already taking enough damage to cap the shield
            and ( UnitHealthMax( "player" ) * health_mod ) > ( Player.recent_dtps * tick_time ) then
                return false
            end
            
            return InCombatLockdown() and aura_env.fight_remains >= 6 and aura_env.config.use_karma == 1
        end,
    } ),

    ["diffuse_magic"] = Player.createAction( 122783, {
        skip_calcs = true,     
        
        ready = function()
            
            local option = aura_env.config.diffuse_option
            
            if not InCombatLockdown() or option < 2 then
                return false
            end
            
            if next( Player.diffuse_auras ) and ( option < 3 or next( Player.diffuse_reflects ) ) then
                return true
            end
            
            return false
        end,
    } ),

    ["touch_of_death"] = Player.createAction( 322109, {
        callbacks = {
            -- Mastery eval
            "tiger_palm",
            "expel_harm",
            "blackout_kick",
            "spinning_crane_kick",
        },
        
        may_miss = false, -- Datamine parses this as physical effect that can miss but cannot miss in game
        
        usable_during_sck = true,
        trigger_etl = true,
        ww_mastery = true,
        
        callback_ready = function( callback )
            
            if not IsUsableSpell( 322109 ) then
                return false
            end
            
            if Player.getTalent( "forbidden_technique" ).okay then
                local fatal_touch = Player.findAura( 213114 )
                
                if fatal_touch then
                    local callback_execute_time = aura_env.spells[ callback ].base_execute_time or 0
                    if ( fatal_touch.remaining - callback_execute_time ) < 0.250 
                    or ( aura_env.target_ttd - callback_execute_time ) < 0.250 then
                        return false
                    end
                end
            end
            
            return true
        end,
        
        bonus_da = function()
            local da_mod = 1
            local targets = 1    
            local damage_pct = spell.touch_of_death.effectN( 3 ).pct
            
            if Player.getTalent( "fatal_flying_guillotine" ).ok then
                targets = min( 5, aura_env.target_count )
            end
            
            da_mod = da_mod * Player.getTalent( "meridian_strikes" ).effectN( 1 ).mod
            
            da_mod = da_mod * Player.getTalent( "forbidden_technique" ).effectN( 2 ).mod
            
            if Player.last_combo_strike ~= 322109 then
                da_mod = da_mod * Player.mast_bonus
            end
            
            local is_execute =  UnitHealth( "target" ) < UnitHealthMax( "player" ) 
            
            if is_execute then
                return UnitHealth("player") + ( da_mod * UnitHealthMax("player") * damage_pct * targets - 1 )
            else
                return da_mod * UnitHealthMax("player") * damage_pct * targets
            end
            
        end,
        
        ready = function()
            return IsUsableSpell( 322109 )
        end,
    } ),

    ["white_tiger_statue"] = Player.createAction( 388686, {

        damageID = 389541, -- (Claw of the White Tiger)
        base_tick_rate = 2,
        
        trigger_etl = false,
        usable_during_sck = true,
        ww_mastery = false,
        
        ready = function()
            return InCombatLockdown() and aura_env.fight_remains > 3 
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        tick_trigger = {
            ["resonant_fists"] = true,
        },
    } ),

    ["storm_earth_and_fire_fixate"] = Player.createAction( 221771, {
        skip_calcs = true,
        
        ready = function()
            local arrogance = Player.findAura( 411661 )
            return InCombatLockdown() and Player.buffs.storm_earth_and_fire.remains() >= 1
            and 
            (
                (
                    -- We have already fixated and we're using the Call to Dominance trinket
                    aura_env.sef_fixate and IsEquippedItem( 204202 ) and ( not arrogance or arrogance.stacks < 10 )
                )
                or
                (   -- We haven't fixated yet, we have full marks, and our target (tiger palm) is taking increased damage
                    not aura_env.sef_fixate and aura_env.unmarked_targets() == 0 and aura_env.forwardModifier() < aura_env.forwardModifier( aura_env.spells["tiger_palm"], 1 ) 
                ) 
                or 
                ( 
                    -- We have already fixated and our current target is taking a larger damage increase than our previous
                    aura_env.sef_fixate 
                    and aura_env.sef_fixate ~= UnitGUID( "target" )
                    and aura_env.last_fixate_bonus < aura_env.forwardModifier( aura_env.spells["tiger_palm"], 1 ) 
                ) 
            )
        end,        
    } ),

    -- TODO: Refactor with better proper buffs
    ["hit_combo"] = {
        type = "damage_buff",
        spellID = 196741,
        pct = function()
            return ( min( 6, Player.buffs.hit_combo.stacks() ) * Player.buffs.hit_combo.effectN( 1 ).pct )
        end,
        base_duration = 9,
        duration = 9,
        ready = function()
            return Player.getTalent( "hit_combo" ).ok
        end,
    },
}

-- --------- -- 
-- MW Spells
-- --------- --

local mw_spells = {
    ["spinning_crane_kick"] = Player.createAction( 101546, {
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
    } ),
}

-- ---------- --
-- BrM Spells
-- ---------- --

local brm_spells = {
    -- Djaruun the Elder Flame
    -- TODO: Generic Actions
    -- TODO: Actual item scaling? This is very lazy
    ["ancient_lava"] = Player.createAction( 408836, {
        background = true,
        icd = 0.5, -- Missing from spell data
        bonus_da = function()
            -- actual scaling isn't quite linear but this should be close
            local itemLevel = GetDetailedItemLevelInfo( GetInventoryItemLink( "player", 16 ) )
            local damage = itemLevel < 500 and 17838 - 215 * ( 450 - itemLevel ) or 50835 - 215 * ( 528 - itemLevel )
            local split = damage / aura_env.target_count
            return split
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            -- Doesn't say in tooltip but damage scales with targets
            return ( 1 + ( min( 5, target_count ) - 1 ) * 0.15 ) 
        end,
        ready = function()
            return Player.findAura( 408835 )
        end,      
    } ),

    ["healing_sphere"] = Player.createAction( 224863, {
        background = true,
        damageID = 124507,
        
        action_multiplier = function()
            local spheres = GetSpellCount( 322101 )
            return spheres
        end,
        
        reduce_stagger = function()
            if Player.getTalent( "tranquil_spirit" ).ok then
                return Player.stagger * Player.getTalent( "tranquil_spirit" ).effectN( 1 ).pct
            end
            
            return 0
        end,        
    } ),

    -- TODO: Maybe figure out a better solution for the healing sphere mess
    ["expel_harm"] = Player.createAction( 322101, {
        
        ap = 0, sp = 0, -- Because healing spheres are added before modifiers I'm overwriting these and using bonus_heal instead
        type = "self_heal", -- because ap and sp are set to zero the heal effect isn't parsed
        
        usable_during_sck = true,
        
        -- Using bonus_heal() method here because of how spheres are added before modifiers
        bonus_heal = function()
            local h = spell.expel_harm.effectN( 1 ).sp_coefficient * aura_env.spell_power * Player.vers_bonus
            
            -- Healing Spheres
            -- These are pulled in and added to the base amount before modifiers
            local spheres = GetSpellCount( 322101 )
            h = h + ( 3 * Player.ability_power * spheres )
            
            h = h * Player.getTalent( "vigorous_expulsion" ).effectN( 1 ).mod
            
            if Player.getTalent( "strength_of_spirit" ).ok then
                local health_deficit = UnitHealthMax( "player" ) - UnitHealth( "player" )
                local health_percent = health_deficit / UnitHealthMax( "player" )
                
                h = h * ( 1 + ( health_percent * Player.getTalent( "strength_of_spirit" ).effectN( 1 ).pct ) )
            end
            
            return h
        end,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.getTalent( "vigorous_expulsion" ).effectN( 2 ).mod
            
            return min( 1, cr )
        end,
        
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.getTalent( "profound_rebuttal" ).effectN( 1 ).mod 
            
            return cm
        end,
        trigger = {
            ["healing_sphere"] = false, -- These are added to the base amount instead
        },
    
        reduce_stagger = function()
            if Player.getTalent( "tranquil_spirit" ).ok then
                return Player.stagger * Player.getTalent( "tranquil_spirit" ).effectN( 1 ).pct
            end
            
            return 0
        end,            
    } ),

    ["healing_elixir"] = Player.createAction( 122281, {
        bonus_heal = function()
            return ( Player.getTalent( "healing_elixir" ).effectN( 1 ).pct ) * UnitHealthMax( "player" )
        end,
    } ),

    ["pta_rising_sun_kick"] = Player.createAction( 185099, {
        
        background = true,

        action_multiplier = function( state )
            local am = Player.buffs.press_the_advantage.effectN( 2 ).mod
            
            am = am * Player.getTalent( "fast_feet" ).effectN( 1 ).mod
            
            -- TP Modifiers
            if IsBlackoutCombo( state ) then
                am = am * ( 1 + ( Player.buffs.blackout_combo.effectN( 5 ).pct * press_the_advantage_boc_mod ) )
            end           
            
            am = am * ( 1 + ( Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 2 ).pct * press_the_advantage_fp_mod ) )
            
            if Player.buffs.counterstrike.up() then
                am = am * ( 1 + ( Player.buffs.counterstrike.effectN( 1 ).pct * press_the_advantage_cs_mod ) )
            end        
            
            return am
        end,
        
        brew_cdr = function()
            return Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 3 ).seconds 
        end,  
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },
    
        trigger = {
            ["chi_surge"] = true,
        },
    
    } ),

    ["rising_sun_kick"] = Player.createAction( 107428, {

        damageID = 185099, -- This spell is weird and triggers a secondary damage event
        hasted_cooldown = true,
        
        usable_during_sck = true,
        
        action_multiplier = function( state )
            local am = 1
            
            am = am * Player.getTalent( "fast_feet" ).effectN( 1 ).mod
            
            return am
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },
    
        trigger = {
            ["pta_rising_sun_kick"] = function()
                if Player.buffs.press_the_advantage.stacks() >= 10 then
                    return true
                end
                
                return false
            end,
            ["weapons_of_order_debuff"] = true,
            ["chi_wave"] = function()
                -- Todo: Replace with buff.up()
                return Player.findAura( 450380 )
            end,
        },
    
    } ),

    ["charred_passions"] = Player.createAction( 386959, {
        background = true,
        skip_calcs = true, -- Uses state result
        
        action_multiplier = function( state )
            local am = Player.getTalent( "charred_passions" ).effectN( 1 ).pct
            if state then
                local result = state.result
                
                if result and result.damage > 0 then
                    local tick_value = result.damage / state.tick_count
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        
        ready = function()
            return Player.getTalent( "charred_passions" ).ok
        end,
        
        tick_trigger = {
            ["charred_dreams_heal"] = true,        
            ["breath_of_fire_periodic"] = function()
                return Player.bof_targets > 0
            end,
        },
    } ),

    ["blackout_kick"] = Player.createAction( 205523, {
        callbacks = {
            "breath_of_fire", -- Charred Passions        
        },
        
        replaces = 100784, -- Missing in Spell Data

        usable_during_sck = true, 
        
        action_multiplier = function()
            local am = 1
            
            am = am * Player.getTalent( "shadowboxing_treads" ).effectN( 2 ).mod
            
            am = am * Player.getTalent( "fluidity_of_motion" ).effectN( 2 ).mod
            
            am = am * Player.getTalent( "elusive_footwork" ).effectN( 2 ).mod
            
            am = am * Player.getTalent( "brawlers_intensity" ).effectN( 2 ).mod
            
            return am
        end,
        
        target_count = function()
            return min( aura_env.target_count, 1 + Player.getTalent( "shadowboxing_treads" ).effectN( 1 ).base_value )
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        reduce_stagger = function()
            local amount = 0
            
            if Player.getTalent( "staggering_strikes" ).ok then
                amount = Player.ability_power or 0
                amount = amount * min( aura_env.target_count, 1 + Player.getTalent( "shadowboxing_treads" ).effectN( 1 ).base_value )
                amount = amount * Player.getTalent( "staggering_strikes" ).effectN( 2 ).pct
            end
            
            return amount
        end,
        
        mitigate = function()
            local eb_stacks = 1
            
            -- elusive footwork crit bonus
            eb_stacks = eb_stacks + ( Player.getTalent( "elusive_footwork" ).effectN( 1 ).base_value * min( 1, Player.crit_bonus ) )
            
            -- physical damage mitigated from one second of Elusive Brawler
            return dodgeMitigation( eb_stacks * ( GetMasteryEffect() / 100 ) )
        end,
        
        trigger = {
            ["shuffle"] = true,
        },
    
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["charred_passions"] = function( driver )
                if Player.getTalent( "charred_passions" ).ok then
                    if driver == "breath_of_fire" or Player.buffs.charred_passions.up() then
                        return true
                    end
                end
                return false
            end,     
            ["resonant_fists"] = true,
        },
    } ),

    ["spinning_crane_kick"] = Player.createAction( 322729, {
        callbacks = {
            "breath_of_fire", -- Charred Passions        
        },
        
        damageID = 107270,
        ticks = 4,
        
        critical_rate = function()
            local cr = Player.crit_bonus
            
            return min( 1, cr )
        end,    
        
        action_multiplier = function( state )
            local am = 1
            
            am = am * Player.getTalent( "fast_feet" ).effectN( 2 ).mod
            
            if Player.buffs.counterstrike.up() then
                am = am * Player.buffs.counterstrike.effectN( 1 ).mod
            end
            
            return am
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.spinning_crane_kick.effectN( 1 ).base_value )
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["charred_passions"] = function( driver )
                if Player.getTalent( "charred_passions" ).ok then
                    if driver == "breath_of_fire" or Player.buffs.charred_passions.up() then
                        return true
                    end
                end
                return false
            end,
            ["resonant_fists"] = true,
        },        
    
        trigger = {
            ["healing_spheres"] = true,   
            ["shuffle"] = true,
        },
    } ),

    ["rushing_jade_wind"] = Player.createAction( 116847, {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also MotC and Mastery eval.
            "expel_harm", -- also Mastery eval.
            "chi_burst",
        },
        
        damageID = 148187,
        base_tick_rate = 0.75, -- TODO: Better buff handling
        hasted_cooldown = true,
        
        usable_during_sck = true,     

        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.rushing_jade_wind.effectN( 1 ).base_value )
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,      
            ["resonant_fists"] = true,
        },      
    } ),

    ["tiger_palm"] = Player.createAction( 100780, {
        callbacks = {
            "blackout_kick", -- Blackout Combo
        },    
        
        usable_during_sck = true,  
        
        ready = function()
            return not ( Player.getTalent( "press_the_advantage" ).ok )
        end,
        
        action_multiplier = function( state )
            local am = 1
            
            if IsBlackoutCombo( state ) then
                am = am * Player.getTalent( "blackout_combo" ).effectN( 1 ).mod
            end
            
            am = am * ( 1 + ( Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 2 ).pct  ) )
            
            if Player.buffs.counterstrike.up() then
                am = am * Player.buffs.counterstrike.effectN( 1 ).mod
            end
            
            return am
        end,
        
        brew_cdr = function()
            return 1 + ( Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 3 ).seconds ) 
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,   
            ["resonant_fists"] = true,
        },
    } ),

    ["chi_burst"] = Player.createAction( 123986, {

        damageID = 148135,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,   
            ["resonant_fists"] = true,
        },
    } ),

    ["chi_wave"] = Player.createAction( Player.is_beta() and 450391 or 115098, {
        
        background = Player.is_beta(),
        damageID = 132467,
        ticks = 4, -- 4 Damage Bounces
        usable_during_sck = true,   
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,  
            ["resonant_fists"] = true,
        },
    } ),

    ["touch_of_death"] = Player.createAction( 322109, {
        
        may_miss = false,
        
        usable_during_sck = true,
        
        bonus_da = function()
            local is_execute =  UnitHealth( "target" ) < UnitHealthMax( "player" )
            local damage_pct = spell.touch_of_death.effectN( 3 ).pct
            
            if is_execute then
                return UnitHealth("player")
            else
                return UnitHealthMax("player") * damage_pct
            end
        end,
        
        ready = function()
            if not IsUsableSpell( 322109 ) then
                return false
            end
            
            local cd = 90
            local damage_pct = spell.touch_of_death.effectN( 3 ).pct
            local is_execute =  UnitHealth( "target" ) < UnitHealthMax( "player" )
            return is_execute or aura_env.target_ttd > ( damage_pct * cd ) 
        end,
        
        reduce_stagger = function()
            local tod = aura_env.spells["touch_of_death"]
            if tod then
                local damage = tod.bonus_da()
                return damage * 2
            end
            return 0
        end,
    } ),

    ["white_tiger_statue"] = Player.createAction( 388686, {

        damageID = 389541, -- (Claw of the White Tiger)
        base_tick_rate = 2,
        
        usable_during_sck = true,
        
        ready = function()
            return InCombatLockdown() and aura_env.fight_remains > 3 
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["resonant_fists"] = true,
        },
    } ),

    ["diffuse_magic"] = Player.createAction( 122783, {
        skip_calcs = true,     
        
        ready = function()
            
            local option = aura_env.config.diffuse_option
            
            if not InCombatLockdown() or option < 2 then
                return false
            end
            
            if next( Player.diffuse_auras ) and ( option < 3 or next( Player.diffuse_reflects ) ) then
                return true
            end
            
            return false
        end,
    } ),

    ["resonant_fists"] = Player.createAction( 389578, {
        background = true,
        
        action_multiplier = function()
            return Player.getTalent( "resonant_fists" ).rank 
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
        
        ready = function()
            return Player.getTalent( "resonant_fists" ).ok
        end,
    } ),

    ["chi_surge"] = Player.createAction( 393786, {
        background = true,
        base_tick_rate = 2,
        
        action_multiplier = function()
            return Player.getTalent( "press_the_advantage" ).effectN( 4 ).mod
        end,
        
        target_count = function()
            return aura_env.target_count
        end,    
        
        ready = function()
            return Player.getTalent( "chi_surge" ).ok
        end,
        
        tick_trigger = {
            ["resonant_fists"] = true,
        },
    } ),

    ["pta_keg_smash"] = Player.createAction( 121253, {
        background = true,
        
        action_multiplier = function( state )
            local am = Player.buffs.press_the_advantage.effectN( 2 ).mod
            
            am = am * Player.getTalent( "stormstouts_last_keg" ).effectN( 1 ).mod
            
            if Player.bof_targets > 0 and Player.getTalent( "scalding_brew" ).ok then
                local ratio = Player.bof_targets / min( 20, aura_env.target_count ) 
                am = am * ( 1 + ( ratio * Player.getTalent( "scalding_brew" ).effectN( 1 ).pct ) )
            end
            
            --[[
            
            This might work, but needs to be tested
            
            if Player.buffs.double_barrel.up() then
                am = am * ( 1 + double_barrel_amp )
            end]]
            
            -- TP Modifiers
            if IsBlackoutCombo( state ) then
                am = am * ( 1 + ( Player.buffs.blackout_combo.effectN( 5 ).pct * press_the_advantage_boc_mod ) )
            end     
            
            am = am * ( 1 + ( Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 2 ).pct * press_the_advantage_fp_mod ) )
            
            if Player.buffs.counterstrike.up() then
                am = am * ( 1 + ( Player.buffs.counterstrike.effectN( 1 ).pct * press_the_advantage_cs_mod ) )
            end   
            
            return am
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.keg_smash.effectN( 7 ).base_value )
        end,
        
        brew_cdr = function()
            local cdr = 3
            
            if Player.bdb_targets > 0 then
                cdr = cdr + 1
            end
            
            cdr = cdr + ( Player.getTalent( "face_palm" ).effectN( 1 ).roll * Player.getTalent( "face_palm" ).effectN( 3 ).seconds )
            
            return cdr
        end,
        
        reduces_cd = {
            ["breath_of_fire"] = function ()
                if Player.getTalent( "salsalabims_strength" ).ok then
                    return aura_env.getCooldown( 115181 ) -- BoF
                end
                return 0 
            end,
        },
    
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,  
            ["resonant_fists"] = true,
        },   
    
        trigger = {
            ["chi_surge"] = true,
            ["shuffle"] = true,
        },
    } ),

    ["keg_smash"] = Player.createAction( 121253, {
        callbacks = {
            "breath_of_fire", -- Scalding Brew / Sal'Salabim's        
        },
    
        hasted_cooldown = true,
        
        usable_during_sck = true,

        action_multiplier = function()
            local am = 1
            
            am = am * Player.getTalent( "stormstouts_last_keg" ).effectN( 1 ).mod
            
            if Player.buffs.hit_scheme.up() then
                am = am * ( 1 + Player.buffs.hit_scheme.stacks() * Player.buffs.hit_scheme.effectN( 1 ).pct )
            end     
            
            if Player.bof_targets > 0 and Player.getTalent( "scalding_brew" ).ok then
                local ratio = Player.bof_targets / min( 20, aura_env.target_count ) 
                am = am * ( 1 + ( ratio * Player.getTalent( "scalding_brew" ).effectN( 1 ).pct ) )
            end
            
            if Player.buffs.double_barrel.up() then
                am = am * ( 1 + double_barrel_amp )
            end
            
            return am
        end,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.keg_smash.effectN( 7 ).base_value )
        end,
        
        brew_cdr = function()
            local cdr = 3
            
            if IsBlackoutCombo( state ) then
                cdr = cdr + Player.getTalent( "blackout_combo" ).effectN( 3 ).base_value
            end
            
            if Player.bdb_targets > 0 then
                cdr = cdr + 1
            end
            
            return cdr
        end,
        
        ready = function()
            -- With Press the Advantage we don't want to "waste" a buffed RSK if it's worth delaying
            local last_update = aura_env.jeremy_update
            if Player.buffs.press_the_advantage.stacks() >= 10 and last_update then
                local pta_rsk = last_update.raw["pta_rising_sun_kick"] or 0
                local pta_ks  = last_update.raw["pta_keg_smash"] or 0
                
                local rsk_remaining = aura_env.getCooldown( 107428 )
                local ks_cd = aura_env.actionBaseCooldown( aura_env.spells["keg_smash"] )
                local ks_cur, ks_max = GetSpellCharges( 121253 )
                local ks_mod = 1 + ( ( ks_cur < ks_max and 0 ) or rsk_remaining / ks_cd )
                
                return pta_rsk < pta_ks * ks_mod
            end
            return true
        end,
        
        reduces_cd = {
            ["breath_of_fire"] = function ()
                if Player.getTalent( "salsalabims_strength" ).ok then
                    return aura_env.getCooldown( 115181 ) -- BoF
                end
                return 0 
            end,
        },
    
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["resonant_fists"] = true,
        },    
    
        trigger = {
            ["pta_keg_smash"] = function()
                if Player.buffs.press_the_advantage.stacks() >= 10 then
                    return true
                end
                
                return false
            end,
            ["weapons_of_order_debuff"] = true,
            ["shuffle"] = true,
        },
    } ),

    ["exploding_keg"] = Player.createAction( 325153, {
        callbacks = {
            "rushing_jade_wind", --  EK ticks from buff
        },
    
        usable_during_sck = true,        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,
        
        mitigate = function()
            -- same as 100% dodge
            return dodgeMitigation( 1.0, exploding_keg_duration )
        end,   
        
        callback_ready = function( callback )
            
            if Player.getTalent( "bountiful_brew" ).ok and Player.bdb_targets == 0 then
                return false
            end
            
            if callback == "rushing_jade_wind" then
                local rjw = Player.findAura( 116847 )
                if not rjw or ( rjw.remaining and rjw.remaining < 3 ) then
                    return true
                end
            end
            
            return false
        end,
        
        ready = function()
            if Player.getTalent( "bountiful_brew" ).ok and Player.bdb_targets == 0 then
                return false
            end
            
            return true
        end,
        
        tick_trigger = {
            ["charred_dreams_heal"] = true,   
            ["resonant_fists"] = true,
            ["exploding_keg_proc"] = function( driver )
                -- Force this until I have better handling of DoT effects triggered from buffs
                return driver == "rushing_jade_wind"
            end,
        },
    } ),

    ["exploding_keg_proc"] = Player.createAction( 325153, {
        
        background = true,
        
        ap = function()
            return Player.getTalent( "exploding_keg" ).effectN( 4 ).ap_coefficient
        end,
        
        action_multiplier = function( state )
            
            if not state then
                return 1
            end
            
            if state.callback_name == "exploding_keg" then
                
                for _, cb in ipairs( state.callback_stack ) do
                    if cb.name == "exploding_keg" then
                        break
                    end
                    
                    -- Once again forcing ticks here until I have better handling of DoT effects triggered from buffs
                    if cb.name == "rushing_jade_wind" then
                        local rjw_ticks = cb.result.ticks
                        local rjw_duration = 9 / Player.haste
                        local ek_ticks = rjw_ticks / rjw_duration * 3
                        
                        -- return ticks to simulate the increase in damage
                        return ek_ticks
                    end
                end
            
                return 0
            end

            local result = state.result or nil
            
            if not result then
                return 0
            end

            local remaining = Player.buffs.exploding_keg.remains()
            
            if result.delay >= remaining then
                return 0
            end
            
            local time_total = result.delay + result.execute_time
            if time_total > remaining then
                return remaining / time_total
            end

            return 1
        end,
        
        tick_trigger = {
            ["charred_dreams_heal"] = true, 
            ["resonant_fists"] = true,
        },
    } ),

    ["breath_of_fire"] = Player.createAction( 115181, {
        callbacks = {
            "blackout_kick", -- Blackout Combo
            "keg_smash", -- Periodic Fire
        },
        
        usable_during_sck = true, 
        
        action_multiplier = function( state )
            local am = 1
            
            -- BUG: BoC buffs the initial hit as well as the periodic
            if IsBlackoutCombo( state ) then
                am = am * Player.buffs.blackout_combo.effectN( 5 ).mod
            end            
            
            if Player.stagger > 0 and Player.getTalent( "dragonfire_brew" ).ok then
                local ratio = 1
                
                if Player.buffs.light_stagger.up() then
                    ratio = 1 / 3
                elseif Player.buffs.moderate_stagger.up() then
                    ratio = 2 / 3
                end
                
                am = am * ( 1 + ( ratio * Player.getTalent( "dragonfire_brew" ).effectN( 2 ).pct ) )
            end
            
            -- Incendiary Breath
            if IsPlayerSpell( 202272 ) then
                am = am * ( 1 + incendiary_breath_amp )
            end
            
            return am
        end,
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 115181 )
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5, 1 )
        end, 
        
        tick_trigger = {
            ["exploding_keg_proc"] = true,    
            ["charred_dreams_heal"] = true,
            ["charred_dreams_damage"] = true,       
            ["resonant_fists"] = true,
        }, 
    
        trigger = {
            ["breath_of_fire_periodic"] = function( driver ) 
                return driver == "keg_smash" or Player.ks_targets > 0 
            end,  
            ["dragonfire"] = true,  
        },
    } ),

    ["dragonfire"] = Player.createAction( 387621, {
        
        background = true,
        
        ticks = function()
            return Player.getTalent( "dragonfire_brew" ).effectN( 1 ).base_value
        end,
        
        target_count = function()
            return aura_env.learnedFrontalTargets( 387621 )    
        end,
        
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5, 1 )
        end,  
        
        ready = function()
            return Player.getTalent( "dragonfire_brew" ).ok
        end,
        
        tick_trigger = {
            ["charred_dreams_heal"] = true,  
            ["charred_dreams_damage"] = true,      
        },
    } ),

    ["breath_of_fire_periodic"] = Player.createAction( 123725, {
        background = true,
        base_tick_rate = 2,
        
        action_multiplier = function( state )
            local am = 1
            
            if IsBlackoutCombo( state ) then
                am = am * Player.buffs.blackout_combo.effectN( 5 ).mod
            end         
            
            return am
        end,
        
        target_count = function()
            if Player.bof_targets > 0 then
                return Player.bof_targets
            else
                return min( aura_env.learnedFrontalTargets( 115181 ), Player.ks_targets )
            end
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,  
        
        mitigate = function( state )
            local ratio = min( aura_env.learnedFrontalTargets( 115181 ), Player.ks_targets ) / aura_env.target_count 
            local dr = spell.breath_of_fire_dot.effectN( 2 ).pct
            
            if Player.buffs.celestial_flames.up() then
                dr = dr + Player.getTalent( "celestial_flames" ).effectN( 2 ).pct
            end
            
            if IsBlackoutCombo( state ) then
                dr = dr + Player.buffs.blackout_combo.effectN( 2 ).pct
            end
            
            return dr * bof_duration * ratio * Player.recent_dtps
        end,
        
        tick_trigger = {
            ["charred_dreams_heal"] = true,  
            ["charred_dreams_damage"] = true,      
        },        
    } ),

    ["gai_plins_imperial_brew"] = Player.createAction( 383701, {
        background = true,
        
        bonus_heal = function()
            return Player.stagger * 0.5 * ( Player.getTalent( "gai_plins_imperial_brew" ).effectN( 1 ).pct )
        end,        
    } ),

    ["shuffle"] = Player.createAction( 215479, {
        background = true,
        skip_calcs = true,
        
        ready = function()
            return Player.getTalent( "shuffle" ).ok
        end,
        
        reduce_stagger = function( state )
            if not state then
                return 0
            end
            
            if Player.stagger == 0 then
                return 0
            end
            
            if Player.getTalent( "quick_sip" ).ok then
                local driver = state.callback
                local shuffle_granted = 0
                
                -- TODO: Use DBC
                if driver.spellID == 205523 then
                    shuffle_granted = 3 -- Blackout Kick
                elseif driver.spellID == 322729 then
                    shuffle_granted = 1 -- Spinning Crane Kick
                elseif driver.spellID == 121253 then
                    shuffle_granted = 5 -- Keg Smash
                end
                
                if shuffle_granted == 0 then
                    return 0
                end            
            
                return ( Player.getTalent( "quick_sip" ).effectN( 1 ).pct / Player.getTalent( "quick_sip" ).effectN( 2 ).base_value ) * Player.stagger * shuffle_granted
            end
            
            return 0
        end,
        
        mitigate = function( state )

            if not state then
                return 0
            end

            local driver = state.callback
            local shuffle_granted = 0
            
            -- TODO: Use DBC
            if driver.spellID == 205523 then
                shuffle_granted = 3 -- Blackout Kick
            elseif driver.spellID == 322729 then
                shuffle_granted = 1 -- Spinning Crane Kick
            elseif driver.spellID == 121253 then
                shuffle_granted = 5 -- Keg Smash
            end
            
            if shuffle_granted == 0 then
                return 0
            end
            
            local m = 0
            
            local shuffle = Player.findAura( 215479 )
            local shuffle_remaining = shuffle and ( shuffle.remaining - Player.gcd_remains ) or 0
            
            if shuffle_remaining <= 1 then

                local dtps = Player.recent_dtps
                
                -- Add fake damage out of combat so that Brewmasters start pulls correctly
                if not InCombatLockdown() then
                    dtps = UnitHealthMax( "player" ) * 0.1
                end
                
                local stagger_pct, stagger_target_pct = GetStaggerPercentage( "player" )
                local shuffle_pct = ( stagger_target_pct or stagger_pct ) / 100 
                
                m = dtps * shuffle_granted * shuffle_pct
                
            end
            
            return m
        end,
    } ),

    ["purifying_brew"] = Player.createAction( 119582, {

        hasted_cooldown = true,
        
        usable_during_sck = true,

        trigger = {
            ["special_delivery"] = true,
            ["gai_plins_imperial_brew"] = function()
                return Player.getTalent( "gai_plins_imperial_brew" ).ok
            end,
        },
    
        bonus_da = function()
            local d = 0
            
            -- Hot Trub
            if IsPlayerSpell( 202126 ) and aura_env.spells["purifying_brew"] then
                
                local stagger_amount = aura_env.spells["purifying_brew"].reduce_stagger()
                
                -- Currently not an issue
                stagger_amount = min( stagger_amount, Player.stagger )
                
                d = stagger_amount * hot_trub_amount 
            end
            
            return d
        end,
        
        reduce_stagger = function()
            return Player.stagger * 0.5
        end,
        
        mitigate = function()
            local m = 0
            
            if Player.getTalent( "pretense_of_instability" ).ok then
                local pretenseGain = pretense_duration - Player.buffs.pretense_of_instability.remains()
                m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
            end
            
            return m
        end,
        
        ready = function()
            local pb_cur, pb_max = GetSpellCharges( 119582 )
            
            if pb_cur < pb_max then
                local charge_cd = aura_env.getCooldown( 119582 )
                if charge_cd > 6 then
                    if not Player.buffs.heavy_stagger.up() then
                        return false
                    end
                end
            end
            
            return Player.stagger > 0 
        end,
    } ),

    ["celestial_brew"] = Player.createAction( 322507, {
        callbacks = {
            "purifying_brew", -- Purified Chi
            "blackout_kick", -- Blackout Combo
        },
    
        usable_during_sck = true,
        
        ready = function()
            -- Hold for next tank buster if applicable
            if aura_env.danger_next and ( aura_env.danger_next < 40 and aura_env.danger_next > 8 ) then
                return false
            end
            
            return not Player.findAura( 322507 ) -- never overwrite current CB
        end,
        
        mitigate = function( state )
            
            -- We can use the tooltip to parse for healing reduction effects
            -- since not all healing reduction auras apply to CB
            local tooltip_array = aura_env.parseTooltip( 322507 )
            
            local m = tooltip_array[ 1 ] 
                -- Fallback to AP formula if tooltip is unavailable
                or ( Player.ability_power * cb_apmod * Player.vers_bonus )
            
            if m > 0 then
            
                -- Purified Chi
                -- --------------------------
                local purified_chi_count = 0
                local driver = state and state.callback_name
                
                -- check state
                
                if driver and driver == "purifying_brew" then
                    -- TODO: Use DBC Value
                    purified_chi_count = 1
                    if Player.buffs.moderate_stagger.up() then
                        purified_chi_count = 3
                    elseif Player.buffs.heavy_stagger.up() then
                        purified_chi_count = 5
                    end
                end
                
                if IsBlackoutCombo( state ) then
                    -- TODO: Use DBC Value
                    purified_chi_count = purified_chi_count + 3
                end
                
                -- current buff
                purified_chi_count = purified_chi_count + Player.buffs.purified_chi.stacks()
                
                m = m * ( 1 + ( min( 10, purified_chi_count ) * Player.buffs.purified_chi.effectN( 1 ).pct ) )

                -- --------------------------
            
                -- Celestial Brew can benefit from Celestial Fortune
                m = m * aura_env.celestialFortune()
                
                -- Celestial Brew expires after 8 seconds
                -- TODO: Duration from DBC
                local dtps = Player.recent_dtps
                local maximum = max( 0, ( dtps * 8 ) - UnitGetTotalAbsorbs( "player" ) )
                
                m = min( maximum, m )
            end
            
            -- Pretense of Instability
            if Player.getTalent( "pretense_of_instability" ).ok then
                local pretenseGain = pretense_duration - Player.buffs.pretense_of_instability.remains()
                m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
            end
            
            -- return
            return m
        end,
        
        trigger = {
            ["special_delivery"] = true,
        },        
    } ),

    ["black_ox_brew"] = Player.createAction( 115399, {
        
        usable_during_sck = true,
        
        ready = function()
            -- Require Celestial Brew on CD
            return aura_env.getCooldown( 322507 ) > 0
        end,
        
        reduces_cd = {
            ["celestial_brew"] = function( ) 
                return aura_env.getCooldown( 322507 ) -- CB
            end,          
            ["purifying_brew"] = function( ) 
                local cdr = aura_env.getCooldown( 119582 ) -- PB
                local currentCharges, maxCharges, _, cooldownDuration = GetSpellCharges( 119582 )
                
                local fullCharges = maxCharges - currentCharges - 1
                if fullCharges > 0 then
                    cdr = cdr + ( cooldownDuration * fullCharges )
                end
                
                return cdr
            end,     
        },
    
        trigger = {
            ["special_delivery"] = true,
        },    
    } ),

    ["special_delivery"] = Player.createAction( 196733, {
        background = true,
        
        target_count = function()
            return aura_env.target_count
        end,
        
        target_multiplier = function( target_count )
            return target_count
        end,    
        
        ready = function()
            return Player.getTalent( "special_delivery" ).ok
        end,
    } ),

    ["press_the_advantage"] = Player.createAction( 418360, {
        -- Melee swing damage event that replaces TP
        background = true,
        
        ready = function()
            return Player.getTalent( "press_the_advantage" ).ok
        end,
        
        brew_cdr = function()
            return Player.getTalent( "press_the_advantage" ).effectN( 1 ).seconds
        end,
        
        tick_trigger = {
            ["resonant_fists"] = true,
        },
    } ),

    -- TODO: Refactor with proper debuffs
    ["weapons_of_order_debuff"] = {
        type = "damage_buff",
        debuff = true,
        spellID = 387179,
        pct = function()
            local woo_buff = Player.findAura( 387184 )
            return min( 4, 1 + ( woo_buff and woo_buff.stacks or 0 ) ) * 0.08
        end,
        duration = function()
            local base_duration = 10
            local duration = base_duration
            
            if Player.woo_targets > 0 then
                local target_count = aura_env.target_count
                duration = base_duration - ( Player.woo_dur_total / Player.woo_targets )
                duration = ( duration * min( target_count, Player.woo_targets ) )
                duration = duration + ( base_duration * ( target_count - Player.woo_targets ) )
                duration = duration / target_count
            end
            
            return max( 0, duration )
        end,
        ready = function()
            return Player.getTalent( "weapons_of_order" ).ok and Player.findAura( 387184 )
        end,
    },

    ["charred_dreams_damage"] = Player.createAction( 425299, {
        background = true,
        skip_calcs = true, -- Uses state result
        
        action_multiplier = function( state )
            local am = spell.t31_brm_2pc.effectN( 1 ).pct

            if state then
                local result = state.result
                
                if result and result.damage > 0 then
                    local tick_value = result.damage / state.tick_count 
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        
        ready = function()
            return ( Player.set_pieces[ 31 ] >= 2 or Player.set_pieces[ 32 ] >= 2 )
        end,
    } ),

    ["charred_dreams_heal"] = Player.createAction( 425298, {
        background = true,
        skip_calcs = true, -- Uses state result
        
        action_multiplier = function( state )
            local am = spell.t31_brm_2pc.effectN( 2 ).pct
            if state then
                local result = state.result
                
                if result and result.damage > 0 then
                    local tick_value = result.damage / state.tick_count
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        
        ready = function()
            return ( Player.set_pieces[ 31 ] >= 2 or Player.set_pieces[ 32 ] >= 2  )
        end,
    } ),
}

-- Generate channel actions
generateChannels( ww_spells )
generateChannels( mw_spells )
generateChannels( brm_spells )


-- Generate action callbacks for spell tables
generateCallbacks( ww_spells )
generateCallbacks( mw_spells )
generateCallbacks( brm_spells )

---------------------
-- initSpecialization
---------------------

aura_env.initSpecialization = function()
    
    -- 3 = Windwalker
    -- 2 = Mistweaver
    -- 1 = Brewmaster
    Player.spec = GetSpecialization() 
    
    if Player.spec == 0 then
        return
    end
    
    -- Initialize talent table
    aura_env.updateTalents()
    
    -- Initialize Spec Auras
    if Player.spec == aura_env.SPEC_INDEX["MONK_WINDWALKER"] then
        Player.spec_aura = spell.windwalker_monk
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_MISTWEAVER"] then -- MW
        Player.spec_aura = spell.mistweaver_monk
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"] then -- BrM
        Player.spec_aura = spell.brewmaster_monk
    end
    
    -- Initialize Spell List
    if Player.spec == aura_env.SPEC_INDEX["MONK_WINDWALKER"]  then
        aura_env.spells = ww_spells
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_MISTWEAVER"]  then
        aura_env.spells = mw_spells
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"] then
        aura_env.spells = brm_spells
    end
    
end

aura_env.initGear = function()
    local mainhand = GetInventoryItemLink( "player", 16 )
    local offhand = GetInventoryItemLink( "player", 17 )
    
    local tier_slots = { 1, 3, 5, 7, 10 }
    local tier_ids = { 
        [ 29 ] = {
            [ "200360" ] = true, -- Chest
            [ "200362" ] = true, -- Hands
            [ "200363" ] = true, -- Head
            [ "200364" ] = true, -- Legs
            [ "200365" ] = true, -- Shoulder
        },
        [ 30 ] = {
            [ "202509" ] = true, -- Chest
            [ "202507" ] = true, -- Hands
            [ "202506" ] = true, -- Head
            [ "202505" ] = true, -- Legs
            [ "202504" ] = true, -- Shoulder
        },
        [ 31 ] = {
            [ "207248" ] = true, -- Chest
            [ "207246" ] = true, -- Hands
            [ "207245" ] = true, -- Head
            [ "207244" ] = true, -- Legs
            [ "207243" ] = true, -- Shoulder
        },
        [ 32 ] = {
            [ "217186" ] = true, -- Chest
            [ "217187" ] = true, -- Hands
            [ "217188" ] = true, -- Head
            [ "217189" ] = true, -- Legs
            [ "217190" ] = true, -- Shoulder
        },
    } 
    
    local set_pieces = {}
    for tier, tier_table in pairs( tier_ids ) do
        set_pieces[ tier ] = 0 
        for _, slot in ipairs( tier_slots ) do
            local itemLink = GetInventoryItemLink( "player", slot )
            if itemLink then
                local itemString = match( itemLink, "item:([%-?%d:]+)" )
                local itemID = strsplit( ":", itemString )
                if tier_table[ itemID ] then
                    set_pieces[ tier ] = set_pieces[ tier ] + 1
                end
            end
        end
    end
    
    Player.set_pieces = set_pieces
    
    local mh_dps = 0
    local oh_dps = 0
    
    if mainhand then
        local mainhand_stats = GetItemStats( mainhand )
        if mainhand_stats then
            mh_dps = mainhand_stats[ "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" ] or 0
        end
    end
    if offhand then
        local offhand_stats = GetItemStats( offhand )
        if offhand_stats then
            oh_dps = offhand_stats[ "ITEM_MOD_DAMAGE_PER_SECOND_SHORT" ] or 0
        end
    end 
    
    if mh_dps == 0 then
        Player.ability_power = 1
        Player.mh_wdps = 0
        Player.oh_wdps = 0
    else
        local ap = UnitAttackPower( "player" )
        local mh_ap = ( mh_dps * 6 ) + ap
        local mh_oh_ap = ( mh_dps * 4 ) + ( oh_dps * 2 ) + ap
        
        local dw = not IsEquippedItemType( "Two-Hand" )
        
        Player.mh_wdps = ( mh_dps + ap / 6 ) * ( dw and 2.6 or 3.6 ) 
        Player.oh_wdps = ( oh_dps + ap / 6 ) * ( dw and 2.6 or 0 ) / 2
        
        -- Mistweaver
        if GetSpecialization() == 2 then
            aura_env.spell_power = UnitStat( "player", 4 ) -- Equal to Intellect
            Player.ability_power = aura_env.spell_power * spell.mistweaver_monk.effectN( 4 ).mod
        else
            
            if oh_dps > 0 then
                Player.ability_power = mh_oh_ap
            else
                Player.ability_power = mh_ap * 0.98
            end   
            
            if Player.spec == aura_env.SPEC_INDEX["MONK_WINDWALKER"] then
                aura_env.spell_power = Player.ability_power * spell.windwalker_monk.effectN( 13 ).mod
            elseif Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"] then
                aura_env.spell_power = Player.ability_power * spell.brewmaster_monk.effectN( 18 ).mod
            end
        end
        
    end
    
    Player.crit_bonus = ( GetCritChance() / 100 )
    Player.vers_bonus = 1 + ( GetCombatRatingBonus( 29 ) / 100 )
    Player.mast_bonus = 1 + ( GetMasteryEffect() / 100 )
    Player.haste = 1 + ( UnitSpellHaste( "player" ) / 100 )
    
end

-- Set CVArs
SetCVar( "nameplateShowSelf", 0 )
SetCVar( "AutoPushSpellToActionBar", 0 )
SetCVar( "screenshotQuality", 10 )
SetCVar( "showTutorials", 0 )
SetCVar( "showNPETutorials", 0 )
SetCVar( "UberTooltips", 1 )
SetCVar( "threatWarning", 3 )
SetCVar( "ActionButtonUseKeyDown", 1 )
SetCVar( "cameraDistanceMaxZoomFactor", 2.6 ) 

aura_env.initGear()
aura_env.initSpecialization()
aura_env.world_loaded = true

