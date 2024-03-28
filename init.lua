
-- Cache globals
local aura_env = aura_env

local abs = abs
local AuraUtil = AuraUtil
local ForEachAura = AuraUtil.ForEachAura
local BigWigs = BigWigs
local BigWigsLoader = BigWigsLoader
local BW_RegisterMessage = ( BigWigsLoader and BigWigsLoader.RegisterMessage ) or nil
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

local DBC_Version = 1.9
local LibDBCache = LibStub("LibDBCache-1.0", true)

if not LibDBCache then
    print("JeremyUI: Database missing!")
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
    blackout_combo          = LibDBCache:find_spell( 228563 ),
    blackout_reinforcement  = LibDBCache:find_spell( 424454 ),    
    breath_of_fire_dot      = LibDBCache:find_spell( 123725 ),
    catue_claw              = LibDBCache:find_spell( 389541 ),
    celestial_fortune       = LibDBCache:find_spell( 216519 ),
    chi_energy              = LibDBCache:find_spell( 393057 ),
    chi_explosion           = LibDBCache:find_spell( 393056 ),
    chi_surge_dot           = LibDBCache:find_spell( 393786 ),
    counterstrike           = LibDBCache:find_spell( 383800 ),
    cyclone_strikes         = LibDBCache:find_spell( 220358 ),
    dragonfire              = LibDBCache:find_spell( 387621 ),
    emperors_capacitor      = LibDBCache:find_spell( 393039 ),
    jadefire_brand_dmg      = LibDBCache:find_spell( 395414 ),
    gift_of_the_ox          = LibDBCache:find_spell( 124507 ),
    gotd_proc               = LibDBCache:find_spell( 392959 ),
    hit_combo               = LibDBCache:find_spell( 196741 ),
    hit_scheme              = LibDBCache:find_spell( 383696 ),
    keefers_skyreach        = LibDBCache:find_spell( 344021 ),
    press_the_advantage     = LibDBCache:find_spell( 418361 ),
    pressure_point          = LibDBCache:find_spell( 337482 ),
    pretense                = LibDBCache:find_spell( 393515 ),
    pta_melee               = LibDBCache:find_spell( 418360 ),
    purified_chi            = LibDBCache:find_spell( 325092 ),
    resonant_fists          = LibDBCache:find_spell( 391400 ),
    shadowflame_nova        = LibDBCache:find_spell( 410139 ),
    special_delivery        = LibDBCache:find_spell( 196733 ),
    thunderfist             = LibDBCache:find_spell( 393566 ),
    
    -- PvP Talents
    pvp_enabled  = LibDBCache:find_spell( 134735 ),
    reverse_harm = LibDBCache:find_spell( 342928 ),
}

-- ------------------------------------------------------------------------------
-- Other spell values
-- TODO: Add these to DBC
-- ------------------------------------------------------------------------------

-- sets
local t29_2pc_value = 0.3
local t29_4pc_value = 0.05
local t30_2pc_ww_bonus = 0.10
local t30_4pc_ww_bonus = 0.30
local t30_2pc_brm_bonus = 0.2
local t30_4pc_brm_bonus = 0.05
local shadowflame_vulnerability_amp = 0.5

-- todo
local bdb_chance = 0.5
local bof_duration = 12
local cb_apmod = 8.4
local double_barrel_amp = 0.5
local exploding_keg_duration = 3
local hot_trub_amount = 0.2
local incendiary_breath_amp = 0.3
local pretense_duration = 5
local accumulating_mist_amp = 0.25
local font_of_life_amp = 0.25

-- these PtA modifiers are not in spell data
local press_the_advantage_cs_mod = 0.5
local press_the_advantage_fp_mod = 0.25
local press_the_advantage_boc_mod = 0.5

local armor = 0.7
local mystic_touch = 0.05
local SEF_bonus = 1.26
local SER_bonus = 1.15

-- ------------------------------------------------------------------------------
-- Buff IDs
-- TODO: populate spell data using find_buff 
-- ------------------------------------------------------------------------------

local buff = {}

-- items
buff.annihilating_flame = 426553

-- general
buff.close_to_heart = 389684
buff.save_them_all = 390105

-- ww 
buff.chi_energy = 337571
buff.dance_of_chiji = 325202
buff.the_emperors_capacitor = 393039
buff.fists_of_flowing_momentum_fof = 394951
buff.hit_combo = 196741
buff.kicks_of_flowing_momentum = 394944
buff.pressure_point = 337482
buff.serenity = 152173
buff.storm_earth_and_fire = 137639
buff.teachings_of_the_monastery = 202090
buff.thunderfist = 242387
buff.transfer_the_power = 195321
buff.xuen_the_white_tiger = 123904
buff.power_strikes = 129914
buff.blackout_reinforcement = 424454

-- brm
buff.blackout_combo = 228563
buff.counterstrike = 383800
buff.hit_scheme = 383696
buff.charred_passions = 386963
buff.celestial_flames = 325190
buff.light_stagger = 124275
buff.moderate_stagger = 124274
buff.heavy_stagger = 124273
buff.double_barrel = 202346
buff.purified_chi = 325092
buff.exploding_keg = 325153
buff.pretense_of_instability = 393516
buff.leverage = 408503
buff.press_the_advantage = 418361

-- mw
buff.accumulating_mist = 388566

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
aura_env.aura_amps_player_ignore = { [buff.xuen_the_white_tiger] = true, [buff.serenity] = true, [buff.storm_earth_and_fire] = true, [buff.hit_combo] = true,  }
aura_env.aura_amps_player_ignore_h = { [buff.save_them_all] = true, }
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
    channel_end = nil,
    channel_id = nil,
    channel_start = nil,
    channel_latency = 0.2, -- Players experience about 200ms of channel latency on average from ingame testing 
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
        end
        
        self.findAuraCache[ spellID ] = {
            data = auraData,
            expires = time + aura_env.update_rate,
        }
        
        return auraData
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

aura_env.combo_strike = {
    [100780] = true,  -- Tiger Palm
    [100784] = true,  -- Blackout Kick
    [107428] = true,  -- Rising Sun Kick
    [101545] = true,  -- Flying Serpent Kick
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
            t[#t + 1] = i
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
    
    if Player.findAura( buff.serenity ) and action.affected_by_serenity then
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
    
    local serenity = Player.findAura( buff.serenity )
    
    if serenity and action.affected_by_serenity then
        if cooldown < serenity.remaining then
            cooldown = cooldown / 2
        else
            cooldown = cooldown - serenity.remaining
        end
    else
        cooldown = cooldown * aura_env.actionModRate( action )
    end
    
    return cooldown
end

aura_env.unmarked_targets = function( )
    local motcCount = GetSpellCount(101546)
    local unmarkedTargets = aura_env.target_count - Player.motc_targets
    
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
    
    if gcd_flat_modifier and gcd_flat_modifier.affected_spells[ spellID ] then
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
    
    local attenuation_bonus = Player.talent.attenuation.effectN( 1 ).mod
    
    return 1 + ( Player.talent.bonedust_brew.effectN( 1 ).mod * attenuation_bonus * bdb_chance )
end
aura_env.targetAuraEffect = function( callback, future )
    
    future = future or 0
    local target_count = max( 1, min( 20, ( callback.target_count and callback.target_count() or 1 ) ) )
    local execute_time = callback.execute_time and callback.execute_time() or 1 
    local callback_type = callback.type or "damage"
    
    local amp = 1
    
    if callback_type == "damage" then
        
        if target_count == 1 and aura_env.targetAuras["target"] then
            for _, aura in pairs(  aura_env.targetAuras["target"] ) do
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
                    if enemy.ttd - future <= 1 then
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
            if Player.talent.save_them_all.ok and aura_env.findUnitAura( UnitID, buff.save_them_all, "HELPFUL" ) then
                if UnitHealth( UnitID ) / UnitHealthMax( UnitID ) < Player.talent.save_them_all.effectN( 3 ).roll then
                    target_amp = target_amp * Player.talent.save_them_all.effectN( 1 ).mod
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
    
    local execute_time = callback.execute_time and callback.execute_time() or 1
    local callback_type = callback.type or "damage"
    
    if callback_type == "smart_heal" or callback_type == "self_heal" then
        
        -- Self Healing
        if callback.type == "self_heal" then
            
            gm = gm * Player.talent.grace_of_the_crane.effectN( 1 ).mod
            
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
        if not callback.ignore_armor then
            gm = gm * armor
            gm = gm * ( 1 + mystic_touch )
        end
        
        -- Passive Talents
        gm = gm * Player.talent.ferocity_of_xuen.effectN( 1 ).mod
        
        -- cached base 
        if callback == Player.default_action then
            aura_env.base_gm = gm
        end
        
        -- Dynamic Buffs/Debuffs
        local pta = Player.findAura( buff.press_the_advantage )
        if pta and spell.press_the_advantage.effectN( 1 ).affected_spells[ callback.spellID ] then
            gm = gm * ( 1 + pta.stacks * spell.press_the_advantage.effectN( 1 ).pct )
        end
        
        local hit_combo = Player.findAura( buff.hit_combo )
        if hit_combo and spell.hit_combo.effectN( 1 ).affected_spells[ callback.spellID ] then
            gm = gm * ( 1 + hit_combo.stacks * spell.hit_combo.effectN( 1 ).pct  )
        end
        
        if Player.talent.empowered_tiger_lightning.ok
        and callback.trigger_etl then
            local xuen = Player.findAura( buff.xuen_the_white_tiger )
            if xuen and xuen.remaining > future then
                gm = gm * ( Player.talent.empowered_tiger_lightning.effectN( 2 ).mod * ( execute_time > 1 and min( 1, ( xuen.remaining - future ) / execute_time ) or 1 ) )
            end
        end
        
        local sef = Player.findAura( buff.storm_earth_and_fire )
        if sef and callback.copied_by_sef and sef.remaining > future then
            gm = gm * ( 1 + ( SEF_bonus - 1 ) * ( execute_time > 1 and min( 1, ( sef.remaining - future ) / execute_time ) or 1 ) )
        end
        
        local serenity = Player.findAura( buff.serenity )
        if serenity and serenity.remaining > future then
            local serenity_bonus = ( aura_env.pvp_mode and 0.67 or 1 ) * SER_bonus
            gm = gm * ( 1 + ( serenity_bonus - 1 ) * ( execute_time > 1 and min( 1, ( serenity.remaining - future ) / execute_time ) or 1 ) )
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
        if real == false then
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
    or not spell.keefers_skyreach.effectN( 1 ).affected_spells[ callback.spellID ]
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
    Player.auraExists( buff.annihilating_flame, function( auraData )
            
            local cap = auraData.points[ 2 ]
            local annihilating_flame_damage = min( cap, 0.5 * result.critical_damage )
            
            result.damage = result.damage + annihilating_flame_damage
            return true
    end ) 
    
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
aura_env.combo_list = {}

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
            
            if copy.spellID then
                -- Identifier
                copy.combo = true
                
                -- Initialize triggers
                if not copy.trigger then
                    copy.trigger = {}
                end
            end            
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    
    return copy
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
                            spells[ name ] = deepcopy( cb_spell )
                            spells[ name ].depth = ( spells[ name ].depth or 0 ) + 1 
                            spells[ name ].trigger[ action ] = true
                            if base_spell.callback_ready then
                                spells[ name ].ready = function() 
                                    return base_spell.callback_ready( callback )
                                end
                            end
                            recursive = false
                        end
                    end
                end
            end
        end
    end
end    

aura_env.auraEffectForSpell = function ( spellID )
    
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
                    if properties then
                        if properties.add_percent_modifier and properties.spell_direct_amount  then
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

-- --------- --
-- WW Spells
-- --------- --

local ww_spells = {
    -- Djaruun the Elder Flame
    ["ancient_lava"] = {
        spellID = 408836,
        background = true,
        icd = 0.5,
        may_crit = true,
        ignore_armor = true,
        bonus_da = function()
            -- actual scaling isn't quite linear but this should be close
            local itemLevel = GetDetailedItemLevelInfo( GetInventoryItemLink( "player", 16 ) )
            local damage = 17838 - 215 * ( 450 - itemLevel )
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
    },
    ["fists_of_fury"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR        
        },
        
        spellID = 113656,
        dotID = 117418,
        channeled = true,
        ap = function() 
            return spell.fists_of_fury.effectN( 5 ).ap_coefficient 
        end,
        ticks = 5,
        interrupt_aa = true,
        may_crit = true,
        resonant_fists = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        hasted_cooldown = true,
        skyreach = true,
        action_multiplier = function()
            local am = 1
            
            am = am * Player.talent.flashing_fists.effectN( 1 ).mod
            
            local transfer_the_power = Player.findAura( buff.transfer_the_power )
            if transfer_the_power then
                am = am * ( 1 + transfer_the_power.stacks * Player.talent.transfer_the_power.effectN( 1 ).pct )
            end
            
            am = am * Player.talent.open_palm_strikes.effectN( 4 ).mod
            
            local fists_of_flowing_momentum_fof = Player.findAura( buff.fists_of_flowing_momentum_fof )
            if fists_of_flowing_momentum_fof then
                am = am * ( 1 + fists_of_flowing_momentum_fof.stacks * t29_4pc_value )
            end
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end        
            
            return am
        end,
        ww_mastery = true,
        chi = function() 
            return aura_env.chi_base_cost( 113656 )
        end,
        target_count = function()
            return aura_env.learnedFrontalTargets( 117418 )
        end,
        target_multiplier = function( target_count )  
            local primary_multiplier = 1
            
            if Player.set_pieces[30] >= 4 then
                primary_multiplier = primary_multiplier * ( 1 + t30_4pc_ww_bonus )
            end
            
            return aura_env.targetScale( target_count, spell.fists_of_fury.effectN( 1 ).base_value, 1, spell.fists_of_fury.effectN( 6 ).pct, primary_multiplier )
        end,
        execute_time = function()
            return 4 / Player.haste
        end,
        tick_trigger = {
            ["open_palm_strikes"] = true,
            ["ancient_lava"] = true,
        },
    },
    ["fists_of_fury_cancel"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR        
        },
        
        spellID = 113656,
        dotID = 117418,
        channeled = true,
        ap = function() 
            return spell.fists_of_fury.effectN( 5 ).ap_coefficient 
        end,
        ticks = function() 
            local gcd = aura_env.gcd( 113656 )
            local tick_rate = 1 / Player.haste
            local ticks_gcd = 1 + ( gcd / tick_rate )
            return ticks_gcd 
        end,
        interrupt_aa = true,
        may_crit = true,
        resonant_fists = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        hasted_cooldown = true,
        skyreach = true,
        action_multiplier = function()
            local am = 1
            
            am = am * Player.talent.flashing_fists.effectN( 1 ).mod 
            
            local transfer_the_power = Player.findAura( buff.transfer_the_power )
            if transfer_the_power then
                am = am * ( 1 + transfer_the_power.stacks * Player.talent.transfer_the_power.effectN( 1 ).pct )
            end
            
            am = am * Player.talent.open_palm_strikes.effectN( 4 ).mod
            
            local fists_of_flowing_momentum_fof = Player.findAura( buff.fists_of_flowing_momentum_fof )
            if fists_of_flowing_momentum_fof then
                am = am * ( 1 + fists_of_flowing_momentum_fof.stacks * t29_4pc_value )
            end
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end     
            
            return am
        end,
        ww_mastery = true,
        chi = function() 
            return aura_env.chi_base_cost( 113656 )
        end,
        target_count = function()
            return aura_env.learnedFrontalTargets( 117418 )
        end,
        target_multiplier = function( target_count )  
            local primary_multiplier = 1
            
            if Player.set_pieces[30] >= 4 then
                primary_multiplier = primary_multiplier * ( 1 + t30_4pc_ww_bonus )
            end
            
            return aura_env.targetScale( target_count, spell.fists_of_fury.effectN( 1 ).base_value, 1, spell.fists_of_fury.effectN( 6 ).pct, primary_multiplier )
        end,
        execute_time = function()
            return aura_env.gcd( 113656 )
        end,
        tick_trigger = {
            ["open_palm_strikes"] = true,
            ["ancient_lava"] = true,            
        },      
    },
    ["rising_sun_kick"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR
            "fists_of_fury", -- Pressure Point
            "fists_of_fury_cancel", -- Pressure Point
        },
        
        spellID = 107428,
        dotID = 185099, -- This spell is really weird and triggers 185099 for the damage event even though it's not channeled
        ap = function() 
            return spell.rising_sun_kick.effectN( 1 ).ap_coefficient 
        end,
        may_crit = true,
        generate_marks = 1,
        resonant_fists = true,        
        usable_during_sck = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        hasted_cooldown = true,
        skyreach = true,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            -- Buff isn't gained until channel ends but still affects RSK if you break the channel with it
            if ( Player.channel_id and Player.channel_id == 113656 and Player.talent.xuens_battlegear.ok )
            -- 
            or Player.findAura ( buff.pressure_point ) then
                cr = cr + spell.pressure_point.effectN( 1 ).roll
            end
            
            return min(1, cr)
        end,
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.talent.rising_star.effectN( 2 ).mod
            
            return cm
        end,        
        action_multiplier = function( trigger_state )
            local am = 1
            
            am = am * Player.talent.fast_feet.effectN( 1 ).mod
            
            am = am * Player.talent.rising_star.effectN( 1 ).mod
            
            if Player.set_pieces[29] >= 2 then
                local kicks_of_flowing_momentum = Player.findAura( buff.kicks_of_flowing_momentum )
                if kicks_of_flowing_momentum 
                or ( trigger_state and trigger_state.callback.spellID == 113656 ) then
                    am = am * ( 1 + t29_2pc_value )
                end
            end
            
            if Player.set_pieces[30] >= 2 then
                am = am * ( 1 + t30_2pc_ww_bonus )
            end
            
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end     
            
            return am
        end,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 107428 )
        end,
        execute_time = function()
            return aura_env.gcd( 107428 )
        end,
        trigger = {
            ["glory_of_the_dawn"] = true,
            ["shadowflame_nova"] = function() 
                return Player.set_pieces[30] >= 2
            end,
        },
        tick_trigger = {
            ["ancient_lava"] = true,    
        },
        reduces_cd = {
            ["fists_of_fury"] = function() 
                return Player.talent.xuens_battlegear.effectN( 2 ).seconds * aura_env.spells["rising_sun_kick"].critical_rate()
            end,
        },
    },
    ["spinning_crane_kick"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also MotC and Mastery eval.
            "expel_harm", -- also Mastery eval.
            "chi_burst",
            
            "fists_of_fury", -- Tier 29   
            "fists_of_fury_cancel", -- Tier 29
            "blackout_kick", -- MotC and Mastery eval.
            "strike_of_the_windlord", -- Mastery eval.
            "whirling_dragon_punch", -- Mastery eval.
            "rushing_jade_wind", -- Mastery eval.
            "flying_serpent_kick", -- Mastery eval.
        },
        
        spellID = 101546,
        dotID = 107270,
        channeled = true,
        ap = function() 
            return spell.sck_tick.effectN( 1 ).ap_coefficient 
        end,
        ticks = 4,
        interrupt_aa = true,
        may_crit = true,
        resonant_fists = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        skyreach = true,
        chi_gain = function()
            if Player.bdb_targets > 0 then
                return 1
            end
            
            return 0
        end,
        action_multiplier = function( trigger_state )
            local am = 1
            
            local motc_stacks = GetSpellCount( 101546 )
            local unmarked = aura_env.unmarked_targets()
            
            if unmarked > 0 and trigger_state and trigger_state.callback.generate_marks then
                local motc_gain = trigger_state.callback.generate_marks
                motc_gain = ( type( motc_gain ) == "function" and motc_gain() or motc_gain ) or 0
                
                if motc_gain > 0 then
                    local potential_gain = min( unmarked, motc_gain )
                    
                    if Player.findAura( buff.storm_earth_and_fire ) and not aura_env.sef_fixate then
                        potential_gain = potential_gain * 3
                    end    
                    motc_stacks = min( 5, motc_stacks + potential_gain )
                end
            end
            
            if motc_stacks > 0 and Player.talent.mark_of_the_crane.ok then
                am = am * ( 1 + ( motc_stacks * spell.cyclone_strikes.effectN( 1 ).pct ) )
            end
            
            if Player.findAura( buff.dance_of_chiji ) then
                am = am * Player.talent.dance_of_chiji.effectN( 1 ).mod
            end
            
            am = am * Player.talent.crane_vortex.effectN( 1 ).mod
            
            if Player.set_pieces[29] >= 2 then
                local kicks_of_flowing_momentum = Player.findAura( buff.kicks_of_flowing_momentum )
                if kicks_of_flowing_momentum 
                or ( trigger_state and trigger_state.callback.spellID == 113656 ) then
                    am = am * ( 1 + t29_2pc_value )
                end
            end
            
            am = am * Player.talent.fast_feet.effectN( 2 ).mod
            
            return am
        end,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 101546 )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.spinning_crane_kick.effectN( 1 ).base_value )
        end,
        execute_time = function()
            return 1.5 / Player.haste
        end,
        trigger = {
            ["chi_explosion"] = true,
        },
        tick_trigger = {
            ["ancient_lava"] = true,            
        },
    },
    ["blackout_kick_totm"] = {
        spellID = 228649,
        ap = function() 
            return spell.blackout_kick.effectN( 1 ).ap_coefficient 
        end,
        background = true,
        may_crit = true,
        copied_by_sef = true,
        trigger_etl = true,
        skyreach = false,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.talent.hardened_soles.effectN( 1 ).roll
            
            return min(1, cr)
        end,
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.talent.hardened_soles.effectN( 2 ).mod
            
            return cm
        end,
        action_multiplier = function()
            local am = 1
            
            am = am * Player.talent.shadowboxing_treads.effectN( 2 ).mod
            
            return am
        end,
        ww_mastery = false,
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    },
    ["blackout_kick"] = {
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
        
        spellID = 100784,
        ap = function() 
            return spell.blackout_kick.effectN( 1 ).ap_coefficient 
        end,
        may_crit = true,
        usable_during_sck = true,       
        resonant_fists = true,        
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        skyreach = true,
        generate_marks = function()
            return 1 + Player.talent.shadowboxing_treads.effectN( 1 ).base_value
        end,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.talent.hardened_soles.effectN( 1 ).roll
            
            return min(1, cr)
        end,
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.talent.hardened_soles.effectN( 2 ).mod
            
            return cm
        end,        
        action_multiplier = function( trigger_state )
            local am = 1
            
            am = am * Player.talent.shadowboxing_treads.effectN( 2 ).mod
            
            if Player.set_pieces[ 31 ] >= 2 then
                if ( trigger_state and trigger_state.callback.spellID == 101546 and aura_env.chi_base_cost( 101546 ) == 0 ) 
                or Player.findAura( buff.blackout_reinforcement ) then
                    am = am * spell.blackout_reinforcement.effectN( 1 ).mod
                end
            end
            
            return am
        end,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 100784 )
        end,
        target_count = function()
            return min( aura_env.target_count, 1 + Player.talent.shadowboxing_treads.effectN( 1 ).base_value )
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        execute_time = function()
            return aura_env.gcd( 100784 )
        end,
        reduces_cd = {
            ["rising_sun_kick"] = function( trigger_state ) 
                local cdr = spell.blackout_kick.effectN( 3 ).seconds 
                
                if Player.talent.teachings_of_the_monastery.ok then
                    local remaining = aura_env.getCooldown( 107428 ) -- RSK
                    if remaining > 0 then
                        local targets = min( aura_env.target_count, 1 + Player.talent.shadowboxing_treads.effectN( 1 ).base_value )
                        local totm = Player.findAura( buff.teachings_of_the_monastery )
                        local totm_stacks = ( totm and totm.stacks or 0 )
                        
                        if ( trigger_state and trigger_state.callback.spellID == 100780 ) then
                            totm_stacks = min( 3, totm_stacks + 1 )
                        end
                        
                        cdr = cdr + ( min( 1, Player.talent.teachings_of_the_monastery.effectN( 1 ).roll * targets * ( 1 + totm_stacks ) ) * remaining )
                    end
                end
                
                if Player.set_pieces[ 31 ] >= 2 then
                    if ( trigger_state and trigger_state.callback.spellID == 101546 and aura_env.chi_base_cost( 101546 ) == 0 ) 
                    or Player.findAura( buff.blackout_reinforcement ) then
                        cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                    end
                end
                
                return cdr
            end,
            
            ["fists_of_fury"] = function( trigger_state )
                local cdr = spell.blackout_kick.effectN( 3 ).seconds
                
                if Player.set_pieces[ 31 ] >= 2 then
                    if ( trigger_state and trigger_state.callback.spellID == 101546 and aura_env.chi_base_cost( 101546 ) == 0 ) 
                    or Player.findAura( buff.blackout_reinforcement ) then
                        cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                    end
                end                
                
                return cdr
            end,
            
            ["strike_of_the_windlord"] = function( trigger_state )
                local cdr = 0
                
                if Player.set_pieces[ 31 ] >= 2 then
                    if ( trigger_state and trigger_state.callback.spellID == 101546 and aura_env.chi_base_cost( 101546 ) == 0 ) 
                    or Player.findAura( buff.blackout_reinforcement ) then
                        cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                    end
                end                
                
                return cdr
            end,
            
            ["whirling_dragon_punch"] = function( trigger_state )
                local cdr = 0
                
                if Player.set_pieces[ 31 ] >= 2 then
                    if ( trigger_state and trigger_state.callback.spellID == 101546 and aura_env.chi_base_cost( 101546 ) == 0 ) 
                    or Player.findAura( buff.blackout_reinforcement ) then
                        cdr = cdr + spell.t31_ww_4pc.effectN( 1 ).base_value
                    end
                end                
                
                return cdr
            end,            
        },
        tick_trigger = {
            ["ancient_lava"] = true,  
            ["blackout_kick_totm"] = function( driver )
                local totm_stacks = 0

                if Player.talent.teachings_of_the_monastery.ok then
                    local totm = Player.findAura( buff.teachings_of_the_monastery )
                    totm_stacks = min( 3, ( totm and totm.stacks or 0 ) + ( driver == "tiger_palm" and 1 or 0 ) )
                end
                
                return totm_stacks > 0
            end,
            ["blackout_kick_totm-2"] = function( driver )
                local totm_stacks = 0
                
                if Player.talent.teachings_of_the_monastery.ok then
                    local totm = Player.findAura( buff.teachings_of_the_monastery )
                    totm_stacks = min( 3, ( totm and totm.stacks or 0 ) + ( driver == "tiger_palm" and 1 or 0 ) )
                end
                
                return totm_stacks > 1
            end,
            ["blackout_kick_totm-3"] = function( driver )
                local totm_stacks = 0
                
                if Player.talent.teachings_of_the_monastery.ok then
                    local totm = Player.findAura( buff.teachings_of_the_monastery )
                    totm_stacks = min( 3, ( totm and totm.stacks or 0 ) + ( driver == "tiger_palm" and 1 or 0 ) )
                end
                
                return totm_stacks > 2
            end,           
        },    
    },
    ["whirling_dragon_punch"] = {
        callbacks = {
            "rising_sun_kick", -- Spell activation        
        },
        
        spellID = 152175, -- Tick: 158221
        ap = function() 
            return spell.wdp_tick.effectN( 1 ).ap_coefficient 
        end,
        ticks = 3,
        may_crit = true,
        ww_mastery = true,
        usable_during_sck = true,    
        resonant_fists = true,      
        copied_by_sef = true,
        trigger_etl = true,
        hasted_cooldown = true,
        skyreach = true,
        ready = function()
            return Player.talent.whirling_dragon_punch.ok
        end,
        callback_ready = function( callback )
            
            -- Not talented into WDP
            if not Player.talent.whirling_dragon_punch.ok then
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
            return am
        end,        
        chi = function()
            return aura_env.chi_base_cost( 152175 )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        execute_time = function()
            return aura_env.gcd( 152175 )
        end,
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    },
    ["strike_of_the_windlord_mh"] = {
        spellID = 395519,
        ap = function() 
            return spell.sotwl_mh.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        ww_mastery = true,
        resonant_fists = true, 
        trigger_etl = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        skyreach = true,
        action_multiplier = function ( )
            local am = 1
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end        
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
        },    
    },
    ["strike_of_the_windlord"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm",
            "expel_harm",
            "chi_burst",
            
            "blackout_kick", -- CDR (Tier 31)        
        },
        
        spellID = 392983,
        dotID = 395521, -- OH hit
        ap = function() 
            return spell.sotwl_oh.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        ww_mastery = true,
        usable_during_sck = true,   
        resonant_fists = true, 
        trigger_etl = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        skyreach = true,
        action_multiplier = function ( )
            local am = 1
            if Player.set_pieces[ 31 ] >= 4 then
                am = am * spell.t31_ww_4pc.effectN( 2 ).mod
            end        
            return am      
        end,          
        chi = function()
            return aura_env.chi_base_cost( 392983 )
        end,
        target_count = function()
            return aura_env.learnedFrontalTargets( 395521 )
        end,
        target_multiplier = function( target_count )
            return ( 1 + 1 / target_count * ( target_count - 1 ) )
        end,
        execute_time = function()
            return aura_env.gcd( 392983 )
        end,
        trigger = {
            ["thunderfist"] = true,
            ["strike_of_the_windlord_mh"] = true,
        },
        tick_trigger = {
            ["ancient_lava"] = true,            
        },    
        ready = function()
            local cd_xuen = aura_env.getCooldown( 123904 )
            return cd_xuen > 12 or cd_xuen < 1 
        end,
    },
    ["rushing_jade_wind"] = {
        callbacks = {
            -- Chi generators
            "tiger_palm", -- also MotC and Mastery eval.
            "expel_harm", -- also Mastery eval.
            "chi_burst",
        },
        
        spellID = 116847,
        dotID = 148187,
        ap = function() 
            return spell.rjw_tick.effectN( 1 ).ap_coefficient
        end,
        ticks = 9,
        may_crit = true,
        ww_mastery = true,
        usable_during_sck = true,     
        resonant_fists = true,
        copied_by_sef = true,
        affected_by_serenity = true,
        trigger_etl = true,
        hasted_cooldown = true,
        skyreach = true,
        action_multiplier = function()
            local am = 1
            local rjw = Player.findAura( 116847 )
            
            -- Overwriting buff is a loss
            if rjw and rjw.remaining then
                local remains = max( 0, rjw.remaining - 1 )
                if remains > 0 then -- RJW does not pandemic
                    am = am * ( 1 - ( remains / 9 ) )
                end
            end
            
            return am
        end,           
        chi = function()
            return aura_env.chi_base_cost( 116847 )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.rushing_jade_wind.effectN( 1 ).base_value )
        end,
        execute_time = function()
            return aura_env.gcd( 116847 )
        end,
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    },
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
            return Player.talent.jadefire_harmony.ok
        end,
    },
    ["jadefire_stomp"] = {
        spellID = 388193,
        dotID = 388201, 
        ap = function()
            return spell.jadefire_stomp.effectN( 1 ).ap_coefficient + spell.jadefire_stomp_ww.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        usable_during_sck = true,       
        resonant_fists = true,
        trigger_etl = true,
        ignore_armor = true,
        ww_mastery = true,
        skyreach = true,
        ready = function()
            return Player.talent.jadefire_stomp.ok and aura_env.fight_remains > 5 and Player.moving == false
        end,
        action_multiplier = function()
            local am = 1
            
            if Player.talent.path_of_jade.ok then 
                local poj_targets = min( aura_env.learnedFrontalTargets( 388201 ), Player.talent.path_of_jade.effectN( 2 ).base_value )
                am = am * ( 1 + Player.talent.path_of_jade.effectN( 1 ).pct * poj_targets )
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
        },        
    },
    ["tiger_palm"] = {
        callbacks = {
            "blackout_kick", -- Teachings of the Monastery        
        },
        
        spellID = 100780,
        ap = function()
            return spell.tiger_palm.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        chi_gain = function() return ( Player.findAura( buff.power_strikes ) and 3 or 2 ) end,
        generate_marks = 1,
        usable_during_sck = true,     
        resonant_fists = true,
        trigger_etl = true,
        copied_by_sef = true,        
        skyreach = true,
        action_multiplier = function()
            local am = ( Player.findAura( buff.power_strikes ) and Player.talent.power_strikes.effectN( 2 ).mod ) or 1
            
            am = am * Player.talent.touch_of_the_tiger.effectN( 1 ).mod
            
            am = am * Player.talent.inner_peace.effectN( 2 ).mod
            
            return am
        end,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 100780 )
        end,
        execute_time = function()
            return aura_env.gcd( 100780 )
        end,
        tick_trigger = {
            ["ancient_lava"] = true,            
        },    
    },
    ["chi_burst"] = {
        spellID = 123986,
        dotID = 148135,
        ap = function()
            return spell.chi_burst.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        interrupt_aa = true,
        resonant_fists = true,
        trigger_etl = true,
        copied_by_sef = true,        
        chi_gain = function() return min( 2, aura_env.target_count ) end,
        ww_mastery = true,
        skyreach = true,
        chi = function()
            return aura_env.chi_base_cost( 123986 )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        execute_time = function()
            return 1 + aura_env.gcd( 123986 )
        end,
        reduces_cd = {
            ["jadefire_stomp"] = function( ) 
                -- CB is a guaranteed reset chance on FLS as long as you're within jadefire
                return aura_env.getCooldown( 388193 )
            end,
        },       
    },
    ["chi_wave"] = {
        spellID = 115098,
        dotID = 132467,
        ap = function()
            return spell.chi_wave.effectN( 1 ).ap_coefficient
        end,        
        ticks = 4, -- 4 Bounces
        may_crit = true,
        ww_mastery = true,
        usable_during_sck = true,        
        resonant_fists = true,
        trigger_etl = true,
        copied_by_sef = true,
        skyreach = true,
        chi = function()
            return aura_env.chi_base_cost( 115098 )
        end,
        execute_time = function()
            return aura_env.gcd( 115098 )
        end,
    },
    ["expel_harm"] = {
        type = "self_heal",
        spellID = 322101,
        sp = function()
            return spell.expel_harm.effectN( 1 ).sp_coefficient
        end,
        may_crit = true,
        trigger_etl = true,
        ww_mastery = true,
        usable_during_sck = true,
        chi_gain = function() 
            if IsPlayerSpell( spell.reverse_harm.id ) then -- Reverse Harm
                return 1 + spell.reverse_harm.effectN( 2 ).base_value
            end
            return 1 
        end,
        action_multiplier = function()
            local h = 1
            
            h = h * Player.talent.vigorous_expulsion.effectN( 1 ).mod
            
            if Player.talent.strength_of_spirit.ok then
                local health_deficit = UnitHealthMax( "player" ) - UnitHealth( "player" )
                local health_percent = health_deficit / UnitHealthMax( "player" )
                
                h = h * ( 1 + ( health_percent * Player.talent.strength_of_spirit.effectN( 1 ).pct ) )
            end
            
            if IsPlayerSpell( spell.reverse_harm.id ) then -- Reverse Harm
                h = h * spell.reverse_harm.effectN( 1 ).mod
            end
            
            return h
        end,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.talent.vigorous_expulsion.effectN( 2 ).mod
            
            return min( 1, cr )
        end,
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.talent.profound_rebuttal.effectN( 1 ).mod 
            
            return cm
        end,        
    },
    ["arcane_torrent"] = {
        spellID = 28730,
        chi_gain = function() return 1 end,
        execute_time = function()
            return aura_env.gcd( 28730 )
        end,
    },
    ["flying_serpent_kick"] = {
        spellID = 101545,
        dotID = 123586,
        ap = function()
            return spell.fsk_damage.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 101545 )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        execute_time = function()
            return aura_env.gcd( 101545 )
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
    },
    ["chi_explosion"] = {
        spellID = 393056,
        ap = function()
            return spell.chi_explosion.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        trigger_etl = true,
        ignore_armor = true,
        skyreach = true,
        action_multiplier = function()
            local chi_energy = Player.findAura( buff.chi_energy )
            if chi_energy then
                return ( 1 + chi_energy.stacks * spell.chi_energy.effectN( 1 ).pct )
            end
            return 0
        end,
        ww_mastery = false,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
    },
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
        skyreach = true,
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
        skyreach = true,
        target_count = function()
            return aura_env.learnedFrontalTargets( 395521 ) -- SotWL
        end,        
        target_multiplier = function( target_count )
            local thunderfist = Player.findAura( 242387 )
            local current_stacks = thunderfist and thunderfist.stacks or 0
            local stacks = min( 10, target_count + current_stacks ) -- SotWL
            return min( stacks, aura_env.fight_remains / ( UnitAttackSpeed( "player" ) or 4 ) )          
        end,
    },
    ["crackling_jade_lightning"] = {
        spellID = 117952,
        ap = function()
            return spell.cj_lightning.effectN( 1 ).ap_coefficient
        end,
        ticks = 4,
        interrupt_aa = true,
        may_crit = true,
        ignore_armor = true,
        resonant_fists = true,
        copied_by_sef = true,    
        skyreach = true,
        action_multiplier = function()
            local am = 1
            
            local emp_cap = Player.findAura( buff.the_emperors_capacitor )
            if emp_cap then
                am = am * ( 1 + emp_cap.stacks * spell.emperors_capacitor.effectN( 1 ).pct )
            end
            
            return am
        end,
        ww_mastery = true,
        chi = function()
            return aura_env.chi_base_cost( 117952 )
        end,
        execute_time = function()
            return 4 / Player.haste
        end
    },
    ["glory_of_the_dawn"] = {
        spellID = 392959,
        ap = function()
            return spell.gotd_proc.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        trigger_etl = true,
        copied_by_sef = true, 
        skyreach = true,
        chi_gain = function() return Player.talent.glory_of_the_dawn.effectN( 2 ).base_value end,
        ww_mastery = true,
        trigger_rate = function() return Player.talent.glory_of_the_dawn.effectN( 3 ).roll end,
        ready = function()
            return Player.talent.glory_of_the_dawn.ok
        end,
        tick_trigger = {
            ["ancient_lava"] = true,            
        },        
    },
    ["shadowflame_nova"] = {
        spellID = 410139,
        ap = function()
            return spell.shadowflame_nova.effectN( 1 ).ap_coefficient
        end,
        background = true,
        may_crit = true,
        trigger_etl = false,
        ignore_armor = true,
        action_multiplier = function(  trigger_state )
            
            if trigger_state and trigger_state.sfv_targets then
                -- Triggering from fof_rsk_combo ONLY this is net gain as the initial sfv_targets are included in the RSK Trigger
                return ( ( trigger_state.sfv_targets - Player.sfv_targets ) / trigger_state.sfv_targets * shadowflame_vulnerability_amp )
            end
            
            if Player.sfv_targets == 0 then
                return 1
            end
            
            return 1 + ( ( Player.sfv_targets / min( 20, aura_env.target_count ) ) * shadowflame_vulnerability_amp )
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
    },
    ["resonant_fists"] = {
        spellID = 391400,
        ap = function()
            return spell.resonant_fists.effectN( 1 ).ap_coefficient
        end,
        icd = 1.0,
        background = true,
        may_crit = true,
        trigger_etl = true,
        ignore_armor = true,
        action_multiplier = function() return Player.talent.resonant_fists.rank end,
        ww_mastery = false,
        skyreach = true,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
        trigger_rate = 0.1,
        ready = function()
            return Player.talent.resonant_fists.ok
        end,
    },
    ["open_palm_strikes"] = {
        spellID = 392970,
        background = true,
        chi_gain = function() return Player.talent.open_palm_strikes.effectN( 3 ).base_value end,
        trigger_rate = function( callback )
            return Player.talent.open_palm_strikes.effectN( 2 ).roll
        end,
        ready = function()
            return Player.talent.open_palm_strikes.ok
        end,
    },
    ["touch_of_karma"] = {
        spellID = 122470,
        may_crit = false,
        trigger_etl = false,
        ignore_armor = true,
        bonus_da = function()
            local tick_time = min( aura_env.target_ttd, 10 )
            local health_mod = Player.talent.touch_of_karma.effectN( 3 ).pct
            return min( UnitHealthMax( "player" ) * health_mod, Player.recent_dtps * tick_time ) * Player.talent.touch_of_karma.effectN( 4 ).pct
        end,
        ready = function()
            local tick_time = min( aura_env.target_ttd, 10 )
            local health_mod = Player.talent.touch_of_karma.effectN( 3 ).pct
            
            -- Hold for next tank buster if applicable
            if aura_env.danger_next and ( aura_env.danger_next < 90 and aura_env.danger_next > 10 )
            -- and we're not already taking enough damage to cap the shield
            and ( UnitHealthMax( "player" ) * health_mod ) > ( Player.recent_dtps * tick_time ) then
                return false
            end
            
            return InCombatLockdown() and aura_env.fight_remains >= 6 and aura_env.config.use_karma == 1
        end,
    },
    ["diffuse_magic"] = {
        spellID = 122783,
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
    },
    ["touch_of_death"] = {
        callbacks = {
            -- Mastery eval
            "tiger_palm",
            "expel_harm",
            "blackout_kick",
            "spinning_crane_kick",
        },
        
        spellID = 322109,
        may_crit = false,
        usable_during_sck = true,
        trigger_etl = true,
        ww_mastery = true,
        callback_ready = function( callback )
            
            if not IsUsableSpell( 322109 ) then
                return false
            end
            
            if Player.talent.forbidden_technique.okay then
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
            
            if Player.talent.fatal_flying_guillotine.ok then
                targets = min( 5, aura_env.target_count )
            end
            
            da_mod = da_mod * Player.talent.meridian_strikes.effectN( 1 ).mod
            
            da_mod = da_mod * Player.talent.forbidden_technique.effectN( 2 ).mod
            
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
    },
    ["white_tiger_statue"] = {
        spellID = 388686,
        dotID = 389541, -- (Claw of the White Tiger)
        ap = function()
            return spell.catue_claw.effectN( 1 ).ap_coefficient
        end,
        ticks = function()
            return max( 1, min( aura_env.fight_remains, 30 ) / 2 )
        end,
        may_crit = true,
        ignore_armor = true, -- Nature
        resonant_fists = true,
        trigger_etl = false,
        usable_during_sck = true,
        ready = function()
            return InCombatLockdown() and aura_env.fight_remains > 3 
        end,
        ww_mastery = false,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        execute_time = function()
            return min( aura_env.fight_remains, 30 )
        end,
    },
    ["storm_earth_and_fire_fixate"] = {
        spellID = 221771,
        skip_calcs = true,
        ready = function()
            local arrogance = Player.findAura( 411661 )
            local sef = Player.findAura( buff.storm_earth_and_fire ) 
            return InCombatLockdown() and sef and sef.remaining >= 1
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
    },
    ["hit_combo"] = {
        type = "damage_buff",
        spellID = 196741,
        pct = function()
            local hc_buff = Player.findAura( buff.hit_combo )
            return ( min( 6, ( hc_buff and hc_buff.stacks or 0 ) ) * spell.hit_combo.effectN( 1 ).pct )
        end,
        base_duration = 9,
        duration = 9,
        ready = function()
            return Player.talent.hit_combo.ok
        end,
    },
}

-- --------- -- 
-- MW Spells
-- --------- --

local mw_spells = {
    ["spinning_crane_kick"] = {
        spellID = 101546,
        channeled = true,
        ap = 0.1,
        ticks = 4,
        interrupt_aa = true,
        may_crit = true,
        resonant_fists = true,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
    },
}

-- ---------- --
-- BrM Spells
-- ---------- --

local brm_spells = {
    -- Djaruun the Elder Flame
    ["ancient_lava"] = {
        spellID = 408836,
        background = true,
        icd = 0.5,
        may_crit = true,
        ignore_armor = true,
        bonus_da = function()
            -- actual scaling isn't quite linear but this should be close
            local itemLevel = GetDetailedItemLevelInfo( GetInventoryItemLink( "player", 16 ) )
            local damage = 17838 - 215 * ( 450 - itemLevel )
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
    },  
    ["healing_sphere"] = {
        type = "self_heal",
        spellID = 224863,
        ap = function()
            return spell.gift_of_the_ox.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        background = true,
        action_multiplier = function()
            local spheres = GetSpellCount( 322101 )
            return spheres
        end,
        reduce_stagger = function()
            if Player.talent.tranquil_spirit.ok then
                return Player.stagger * Player.talent.tranquil_spirit.effectN( 1 ).pct
            end
            
            return 0
        end,        
    },
    ["expel_harm"] = {
        type = "self_heal",
        spellID = 322101,
        may_crit = true,
        usable_during_sck = true,
        -- Using bonus_heal() method here because of how spheres are added before modifiers
        bonus_heal = function()
            local h = spell.expel_harm.effectN( 1 ).sp_coefficient * aura_env.spell_power * Player.vers_bonus
            
            -- Healing Spheres
            -- These are pulled in and added to the base amount before modifiers
            local spheres = GetSpellCount( 322101 )
            h = h + ( 3 * Player.ability_power * spheres )
            
            h = h * Player.talent.vigorous_expulsion.effectN( 1 ).mod
            
            if Player.talent.strength_of_spirit.ok then
                local health_deficit = UnitHealthMax( "player" ) - UnitHealth( "player" )
                local health_percent = health_deficit / UnitHealthMax( "player" )
                
                h = h * ( 1 + ( health_percent * Player.talent.strength_of_spirit.effectN( 1 ).pct ) )
            end
            
            return h
        end,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            cr = cr + Player.talent.vigorous_expulsion.effectN( 2 ).mod
            
            return min( 1, cr )
        end,
        critical_modifier = function()
            local cm = 1
            
            cm = cm * Player.talent.profound_rebuttal.effectN( 1 ).mod 
            
            return cm
        end,
        trigger = {
            ["healing_sphere"] = false, -- These are added to the base amount instead
        },
        reduce_stagger = function()
            if Player.talent.tranquil_spirit.ok then
                return Player.stagger * Player.talent.tranquil_spirit.effectN( 1 ).pct
            end
            
            return 0
        end,            
    },
    ["quick_sip_1s"] = {
        spellID = 388505,
        background = true,
        reduce_stagger = function()
            return ( Player.talent.quick_sip.effectN( 1 ).pct / Player.talent.quick_sip.effectN( 2 ).base_value ) * Player.stagger
        end,
        ready = function()
            return Player.stagger > 0 and Player.talent.quick_sip.ok
        end,
    },
    ["healing_elixir"] = {
        type = "self_heal",
        spellID = 122281,
        bonus_heal = function()
            return ( Player.talent.healing_elixir.effectN( 1 ).pct ) * UnitHealthMax( "player" )
        end,
    },
    ["pta_rising_sun_kick"] = {
        spellID = 185099,
        ap = function() 
            return spell.rising_sun_kick.effectN( 1 ).ap_coefficient 
        end,
        may_crit = true,
        resonant_fists = true,
        background = true,
        action_multiplier = function( trigger_state )
            local am = spell.press_the_advantage.effectN( 2 ).mod
            
            am = am * Player.talent.fast_feet.effectN( 1 ).mod
            
            -- TP Modifiers
            if Player.findAura( buff.blackout_combo ) 
            or ( trigger_state and trigger_state.blackout_combo ) then
                am = am * ( 1 + ( spell.blackout_combo.effectN( 5 ).pct * press_the_advantage_boc_mod ) )
            end           
            
            am = am * ( 1 + ( Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 2 ).pct * press_the_advantage_fp_mod ) )
            
            if Player.findAura( buff.counterstrike ) then
                am = am * ( 1 + ( spell.counterstrike.effectN( 1 ).pct * press_the_advantage_cs_mod ) )
            end        
            
            return am
        end,
        brew_cdr = function()
            return Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 3 ).seconds 
        end,        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
        },
        trigger = {
            ["chi_surge"] = true,
        },
        mitigate = function()
            local m = 0
            
            if Player.set_pieces[30] >= 4 then
                -- physical damage mitigated from one second of Elusive Brawler
                m = m + dodgeMitigation( ( GetMasteryEffect() / 100 ) )
            end
            
            return m
        end,    
    },
    ["rising_sun_kick"] = {
        spellID = 107428,
        dotID = 185099, -- This spell is weird and triggers a secondary damage event even though it is not channeled
        ap = function() 
            return spell.rising_sun_kick.effectN( 1 ).ap_coefficient 
        end,
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true,
        hasted_cooldown = true,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            local leverage = Player.findAura( buff.leverage )
            if leverage then
                cr = cr + ( leverage.stacks * t30_4pc_brm_bonus )
            end     
            
            return min( 1, cr )
        end,        
        action_multiplier = function( trigger_state )
            local am = 1
            
            am = am * Player.talent.fast_feet.effectN( 1 ).mod
            
            local leverage = Player.findAura( buff.leverage )
            if leverage then
                am = am * ( 1 + leverage.stacks * t30_4pc_brm_bonus )
            end     
            
            return am
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
        },
        trigger = {
            ["pta_rising_sun_kick"] = function()
                local pta = Player.findAura( buff.press_the_advantage )
                if pta and pta.stacks >= 10 then
                    return true
                end
                return false
            end,
            ["weapons_of_order_debuff"] = true,
        },
        mitigate = function()
            local m = 0
            
            if Player.set_pieces[30] >= 4 then
                -- physical damage mitigated from one second of Elusive Brawler
                m = m + dodgeMitigation( ( GetMasteryEffect() / 100 ) )
            end
            
            return m
        end,    
    },
    ["charred_passions"] = {
        spellID = 386959,
        may_crit = false,
        ignore_armor = true, -- Fire
        background = true,
        action_multiplier = function( trigger_state )
            local am = Player.talent.charred_passions.effectN( 1 ).pct
            if trigger_state then
                local result = trigger_state.result
                
                if result and result.damage > 0 then
                    local tick_value = ( result.damage / result.ticks / result.target_count )
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        ready = function()
            return Player.talent.charred_passions.ok
        end,
        tick_trigger = {
            ["charred_dreams_heal"] = true,        
            ["breath_of_fire_periodic"] = function()
                return Player.bof_targets > 0
            end,
        },
    },
    ["blackout_kick"] = {
        callbacks = {
            "breath_of_fire", -- Charred Passions        
        },
        
        replaces = 100784,
        spellID = 205523,
        ap = function() 
            return spell.blackout_kick.effectN( 1 ).ap_coefficient 
        end,
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true, 
        grant_shuffle = 3,
        action_multiplier = function()
            local am = 1
            
            am = am * Player.talent.shadowboxing_treads.effectN( 2 ).mod
            
            am = am * Player.talent.fluidity_of_motion.effectN( 2 ).mod
            
            am = am * Player.talent.elusive_footwork.effectN( 2 ).mod
            
            if Player.set_pieces[30] >= 2 then
                am = am * ( 1 + t30_2pc_brm_bonus )
            end    
            
            return am
        end,
        target_count = function()
            return min( aura_env.target_count, 1 + Player.talent.shadowboxing_treads.effectN( 1 ).base_value )
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        reduce_stagger = function()
            local amount = 0
            
            if Player.talent.staggering_strikes.ok then
                amount = Player.ability_power or 0
                amount = amount * min( aura_env.target_count, 1 + Player.talent.shadowboxing_treads.effectN( 1 ).base_value )
                amount = amount * Player.talent.staggering_strikes.effectN( 2 ).pct
            end
            
            return amount
        end,
        mitigate = function()
            local eb_stacks = 1
            
            -- elusive footwork crit bonus
            eb_stacks = eb_stacks + ( Player.talent.elusive_footwork.effectN( 1 ).base_value * min( 1, Player.crit_bonus ) )
            
            -- physical damage mitigated from one second of Elusive Brawler
            return dodgeMitigation( eb_stacks * ( GetMasteryEffect() / 100 ) )
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["charred_passions"] = function( driver )
                if Player.talent.charred_passions.ok then
                    if driver == "breath_of_fire" or Player.findAura( buff.charred_passions ) then
                        return true
                    end
                end
                return false
            end,            
        },
    },
    ["spinning_crane_kick"] = {
        callbacks = {
            "breath_of_fire", -- Charred Passions        
        },
        
        replaces = 101546,
        spellID = 322729,
        dotID = 107270,
        channeled = true,
        ap = function() 
            return spell.sck_tick.effectN( 1 ).ap_coefficient 
        end,
        ticks = 4,
        interrupt_aa = true,
        may_crit = true,
        resonant_fists = true,
        grant_shuffle = 1,
        critical_rate = function()
            local cr = Player.crit_bonus
            
            local leverage = Player.findAura( buff.leverage )
            if leverage then
                cr = cr + ( leverage.stacks * t30_4pc_brm_bonus )
            end     
            
            return min( 1, cr )
        end,          
        action_multiplier = function( trigger_state )
            local am = 1
            
            am = am * Player.talent.fast_feet.effectN( 2 ).mod
            
            if Player.findAura( buff.counterstrike ) then
                am = am * spell.counterstrike.effectN( 1 ).mod
            end
            
            local leverage = Player.findAura( buff.leverage )
            if leverage then
                am = am * ( 1 + leverage.stacks * t30_4pc_brm_bonus )
            end                 
            
            return am
        end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.spinning_crane_kick.effectN( 1 ).base_value )
        end,
        execute_time = function()
            return 1.5 / Player.haste
        end,        
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,
            ["charred_passions"] = function( driver )
                if Player.talent.charred_passions.ok then
                    if driver == "breath_of_fire" or Player.findAura( buff.charred_passions ) then
                        return true
                    end
                end
                return false
            end,
        },        
        trigger = {
            ["healing_spheres"] = true,    
        },
    },
    ["rushing_jade_wind"] = {
        spellID = 116847,
        dotID = 148187,
        ap = function() 
            return spell.rjw_tick.effectN( 1 ).ap_coefficient
        end,
        ticks = 9,
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true,
        hasted_cooldown = true,
        action_multiplier = function()
            local am = 1
            local rjw = Player.findAura( 116847 )
            
            -- Overwriting buff is a loss
            if rjw and rjw.remaining then
                local remains = max( 0, rjw.remaining - 1 )
                if remains > 0 then -- RJW does not pandemic
                    am = am * ( 1 - ( remains / 9 ) )
                end
            end
            
            return am
        end,        
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, spell.rushing_jade_wind.effectN( 1 ).base_value )
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,            
        },
    },
    ["tiger_palm"] = {
        callbacks = {
            "blackout_kick", -- Blackout Combo
        },    
        
        spellID = 100780,
        ap = function()
            return spell.tiger_palm.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true,  
        ready = function()
            return not ( Player.talent.press_the_advantage.ok )
        end,
        action_multiplier = function( trigger_state )
            local am = 1
            
            if Player.findAura( buff.blackout_combo ) 
            or ( trigger_state and trigger_state.blackout_combo ) then
                am = am * Player.talent.blackout_combo.effectN( 1 ).mod
            end
            
            am = am * ( 1 + ( Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 2 ).pct  ) )
            
            if Player.findAura( buff.counterstrike ) then
                am = am * spell.counterstrike.effectN( 1 ).mod
            end
            
            return am
        end,
        execute_time = function()
            return aura_env.gcd( 100780 )
        end,
        brew_cdr = function()
            return 1 + ( Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 3 ).seconds ) 
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,            
        },
    },
    ["chi_burst"] = {
        spellID = 123986,
        dotID = 148135,
        ap = function()
            return spell.chi_burst.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        interrupt_aa = true,
        resonant_fists = true,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,            
        },
    },
    ["chi_wave"] = {
        spellID = 115098,
        dotID = 132467,
        ap = function()
            return spell.chi_wave.effectN( 1 ).ap_coefficient
        end, 
        ticks = 4, -- 4 Bounces
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true,   
        tick_trigger = {
            ["exploding_keg_proc"] = true,            
        },
    },
    ["touch_of_death"] = {
        spellID = 322109,
        may_crit = false,
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
    },
    ["white_tiger_statue"] = {
        spellID = 388686,
        dotID = 389541, -- (Claw of the White Tiger)
        ap = function()
            return spell.catue_claw.effectN( 1 ).ap_coefficient
        end,
        ticks = function()
            return max( 1, min( aura_env.fight_remains, 30 ) / 2 )
        end,        
        may_crit = true,
        ignore_armor = true, -- Nature
        resonant_fists = true,
        usable_during_sck = true,        
        ready = function()
            return InCombatLockdown() and aura_env.fight_remains > 3 
        end,
        ww_mastery = false,
        target_multiplier = function()
            return min( aura_env.target_count, 20 )
        end,
        execute_time = function()
            return min( aura_env.fight_remains, 30 )
        end,
        tick_trigger = {
            ["exploding_keg_proc"] = true,            
        },
    },
    ["diffuse_magic"] = {
        spellID = 122783,
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
    },
    ["resonant_fists"] = {
        spellID = 391400,
        ap = function()
            return spell.resonant_fists.effectN( 1 ).ap_coefficient
        end,
        icd = 1.0, 
        may_crit = true,
        ignore_armor = true,
        background = true,
        action_multiplier = function() return Player.talent.resonant_fists.rank end,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5 )
        end,
        trigger_rate = 0.1,
        ready = function()
            return Player.talent.resonant_fists.ok
        end,
    },
    ["chi_surge"] = {
        spellID = 393786,
        ap = function()
            return spell.chi_surge_dot.effectN( 1 ).ap_coefficient
        end,
        ticks = 4,
        background = true,
        may_crit = true,
        resonant_fists = true,
        ignore_armor = true,
        action_multiplier = function()
            return Player.talent.press_the_advantage.effectN( 4 ).mod
        end,
        target_count = function()
            return aura_env.target_count
        end,        
        ready = function()
            return Player.talent.chi_surge.ok
        end,
    },
    ["pta_keg_smash"] = {
        spellID = 121253,
        ap = function()
            return spell.keg_smash.effectN( 2 ).ap_coefficient
        end,
        may_crit = true,
        resonant_fists = true,
        background = true,
        grant_shuffle = 5,
        action_multiplier = function( trigger_state )
            local am = spell.press_the_advantage.effectN( 2 ).mod
            
            am = am * Player.talent.stormstouts_last_keg.effectN( 1 ).mod
            
            if Player.bof_targets > 0 and Player.talent.scalding_brew.ok then
                local ratio = Player.bof_targets / min( 20, aura_env.target_count ) 
                am = am * ( 1 + ( ratio * Player.talent.scalding_brew.effectN( 1 ).pct ) )
            end
            
            --[[
            
            This might work, but needs to be tested
            
            if Player.findAura( buff.double_barrel ) then
                am = am * ( 1 + double_barrel_amp )
            end]]
            
            -- TP Modifiers
            if Player.findAura( buff.blackout_combo ) 
            or ( trigger_state and trigger_state.blackout_combo ) then
                am = am * ( 1 + ( spell.blackout_combo.effectN( 5 ).pct * press_the_advantage_boc_mod ) )
            end     
            
            am = am * ( 1 + ( Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 2 ).pct * press_the_advantage_fp_mod ) )
            
            if Player.findAura( buff.counterstrike ) then
                am = am * ( 1 + ( spell.counterstrike.effectN( 1 ).pct * press_the_advantage_cs_mod ) )
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
            
            cdr = cdr + ( Player.talent.face_palm.effectN( 1 ).roll * Player.talent.face_palm.effectN( 3 ).seconds )
            
            return cdr
        end,
        reduces_cd = {
            ["breath_of_fire"] = function ()
                if Player.talent.salsalabims_strength.ok then
                    return aura_env.getCooldown( 115181 ) -- BoF
                end
                return 0 
            end,
        },
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,            
        },    
        trigger = {
            ["chi_surge"] = true,
        },
    },
    ["keg_smash"] = {
        callbacks = {
            "breath_of_fire", -- Scalding Brew / Sal'Salabim's        
        },
        
        spellID = 121253,
        ap = function()
            return spell.keg_smash.effectN( 2 ).ap_coefficient
        end,
        may_crit = true,
        resonant_fists = true,
        usable_during_sck = true,
        hasted_cooldown = true,
        grant_shuffle = 5,
        action_multiplier = function()
            local am = 1
            
            am = am * Player.talent.stormstouts_last_keg.effectN( 1 ).mod
            
            local hit_scheme = Player.findAura( buff.hit_scheme )
            if hit_scheme then
                am = am * ( 1 + hit_scheme.stacks * spell.hit_scheme.effectN( 1 ).pct )
            end     
            
            if Player.bof_targets > 0 and Player.talent.scalding_brew.ok then
                local ratio = Player.bof_targets / min( 20, aura_env.target_count ) 
                am = am * ( 1 + ( ratio * Player.talent.scalding_brew.effectN( 1 ).pct ) )
            end
            
            if Player.findAura( buff.double_barrel ) then
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
            
            if Player.findAura( buff.blackout_combo ) then
                cdr = cdr + Player.talent.blackout_combo.effectN( 3 ).base_value
            end
            
            if Player.bdb_targets > 0 then
                cdr = cdr + 1
            end
            
            return cdr
        end,
        ready = function()
            -- With Press the Advantage we don't want to "waste" a buffed RSK if it's worth delaying
            local pta = Player.findAura( buff.press_the_advantage )
            local last_update = aura_env.jeremy_update
            if pta and pta.stacks >= 10 and last_update then
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
                if Player.talent.salsalabims_strength.ok then
                    return aura_env.getCooldown( 115181 ) -- BoF
                end
                return 0 
            end,
        },
        tick_trigger = {
            ["exploding_keg_proc"] = true,
            ["ancient_lava"] = true,            
        },    
        trigger = {
            ["pta_keg_smash"] = function()
                local pta = Player.findAura( buff.press_the_advantage )
                if pta and pta.stacks >= 10 then
                    return true
                end
                return false
            end,
            ["weapons_of_order_debuff"] = true,
        },
    },
    ["exploding_keg"] = {
        spellID = 325153,
        ap = function()
            return Player.talent.exploding_keg.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        ignore_armor = true, -- fire       
        resonant_fists = true,
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
        ready = function()
            if Player.talent.bountiful_brew.ok and Player.bdb_targets == 0 then
                return false
            end
            
            return true
        end,
        tick_trigger = {
            ["charred_dreams_heal"] = true,      
        },
    },
    ["exploding_keg_proc"] = {
        spellID = 325153,
        ap = function()
            return Player.talent.exploding_keg.effectN( 4 ).ap_coefficient
        end,
        may_crit = true,
        ignore_armor = true, -- fire       
        resonant_fists = false,
        background = true,
        ready = function()
            return Player.findAura( buff.exploding_keg )
        end,
        tick_trigger = {
            ["charred_dreams_heal"] = true,      
        },
    },
    ["breath_of_fire"] = {
        callbacks = {
            "blackout_kick", -- Blackout Combo
            "keg_smash", -- Periodic Fire
        },
        
        spellID = 115181,
        ap = 0.48,
        may_crit = true,
        ignore_armor = true, -- fire
        resonant_fists = true,
        usable_during_sck = true,        
        action_multiplier = function( trigger_state )
            local am = 1
            
            -- BUG: BoC buffs the initial hit as well as the periodic
            if Player.findAura( buff.blackout_combo ) 
            or ( trigger_state and trigger_state.blackout_combo ) then
                am = am * spell.blackout_combo.effectN( 5 ).mod
            end            
            
            if Player.stagger > 0 and Player.talent.dragonfire_brew.ok then
                local ratio = 1
                
                if Player.findAura( buff.light_stagger ) then
                    ratio = 1 / 3
                elseif Player.findAura( buff.moderate_stagger ) then
                    ratio = 2 / 3
                end
                
                am = am * ( 1 + ( ratio * Player.talent.dragonfire_brew.effectN( 2 ).pct ) )
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
        },        
        trigger = {
            ["breath_of_fire_periodic"] = function( driver ) 
                return driver == "keg_smash" or Player.ks_targets > 0 
            end,  
            ["dragonfire"] = true,  
        },
    },
    ["dragonfire"] = {
        spellID = 387621,
        ap = function()
            return spell.dragonfire.effectN( 1 ).ap_coefficient
        end,
        ticks = function()
            return Player.talent.dragonfire_brew.effectN( 1 ).base_value
        end,
        may_crit = true,
        ignore_armor = true, -- fire 
        background = true,
        target_count = function()
            return aura_env.learnedFrontalTargets( 387621 )    
        end,
        target_multiplier = function( target_count )
            return aura_env.targetScale( target_count, 5, 1 )
        end,         
        ready = function()
            return Player.talent.dragonfire_brew.ok
        end,
        tick_trigger = {
            ["charred_dreams_heal"] = true,  
            ["charred_dreams_damage"] = true,      
        },
    },
    ["breath_of_fire_periodic"] = {
        spellID = 123725,
        ap = function()
            return spell.breath_of_fire_dot.effectN( 1 ).ap_coefficient
        end,
        ticks = function() 
            return bof_duration / 2 
        end,
        may_crit = true,
        ignore_armor = true, -- fire
        background = true,
        action_multiplier = function( trigger_state )
            local am = 1
            
            if Player.findAura( buff.blackout_combo ) then
                am = am * spell.blackout_combo.effectN( 5 ).mod
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
        mitigate = function()
            local ratio = min( aura_env.learnedFrontalTargets( 115181 ), Player.ks_targets ) / aura_env.target_count 
            local dr = spell.breath_of_fire_dot.effectN( 2 ).pct
            
            if Player.findAura( buff.celestial_flames ) then
                dr = dr + Player.talent.celestial_flames.effectN( 2 ).pct
            end
            
            if Player.findAura( buff.blackout_combo ) then
                dr = dr + spell.blackout_combo.effectN( 2 ).pct
            end
            
            return dr * bof_duration * ratio * Player.recent_dtps
        end,
    },
    ["gai_plins_imperial_brew"] = {
        type = "self_heal",
        spellID = 383701,
        may_crit = false,
        background = true,
        bonus_heal = function()
            return Player.stagger * 0.5 * ( Player.talent.gai_plins_imperial_brew.effectN( 1 ).pct )
        end,        
    },
    ["purifying_brew"] = {
        spellID = 119582,
        usable_during_sck = true,
        hasted_cooldown = true,
        trigger = {
            ["special_delivery"] = true,
            ["gai_plins_imperial_brew"] = function()
                return Player.talent.gai_plins_imperial_brew.ok
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
            
            if Player.talent.pretense_of_instability.ok then
                local pretenseGain = pretense_duration
                local activePretense = Player.findAura( buff.pretense_of_instability )
                if activePretense then
                    pretenseGain = pretenseGain - activePretense.remaining
                end
                
                m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
            end
            
            return m
        end,
        ready = function()
            local pb_cur, pb_max = GetSpellCharges( 119582 )
            
            if pb_cur < pb_max then
                local charge_cd = aura_env.getCooldown( 119582 )
                if charge_cd > 6 then
                    if not Player.findAura( buff.heavy_stagger ) then
                        return false
                    end
                end
            end
            
            return Player.stagger > 0 
        end,
    },
    ["celestial_brew"] = {
        spellID = 322507,
        usable_during_sck = true,
        trigger = {
            ["special_delivery"] = true,
        },
        ready = function()
            -- Hold for next tank buster if applicable
            if aura_env.danger_next and ( aura_env.danger_next < 40 and aura_env.danger_next > 8 ) then
                return false
            end
            
            return not Player.findAura( 322507 ) -- never overwrite current CB
        end,
        mitigate = function()
            
            local tooltip_array = aura_env.parseTooltip( 322507 )
            local n = tooltip_array[1]
            local m = Player.ability_power * cb_apmod * Player.vers_bonus
            
            if n then
                -- We can use the tooltip to parse for healing reduction effects
                -- since not all healing reduction auras apply to CB
                m = n
            end
            
            local purified_chi_count = 0
            
            if Player.findAura( buff.blackout_combo ) then
                purified_chi_count = purified_chi_count + 3
            end
            
            local purified_chi = Player.findAura( buff.purified_chi )
            if purified_chi then
                purified_chi_count = purified_chi_count + purified_chi.stacks
            end
            
            m = m * ( 1 + ( min( 10, purified_chi_count ) * spell.purified_chi.effectN( 1 ).pct ) )
            
            -- Celestial Brew can benefit from Celestial Fortune
            m = m * aura_env.celestialFortune()
            
            -- Celestial Brew expires after 8 seconds
            local dtps = Player.recent_dtps
            local maximum = ( dtps * 8 )
            m = min( maximum, m )
            
            if Player.talent.pretense_of_instability.ok then
                local pretenseGain = pretense_duration
                local activePretense = Player.findAura( buff.pretense_of_instability )
                if activePretense then
                    pretenseGain = pretenseGain - activePretense.remaining
                end
                
                m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
            end
            
            return m
        end,
    },
    ["black_ox_brew"] = {
        spellID = 115399,
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
    },
    ["special_delivery"] = {
        spellID = 196733,
        ap = function()
            return spell.special_delivery.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        resonant_fists = true,
        background = true,
        target_count = function()
            return aura_env.target_count
        end,
        target_multiplier = function( target_count )
            return target_count
        end,      
        ready = function()
            return Player.talent.special_delivery.ok
        end
    },
    ["press_the_advantage"] = {
        -- Melee swing damage event that replaces TP
        spellID = 418360,
        ap = function()
            return spell.pta_melee.effectN( 1 ).ap_coefficient
        end,
        may_crit = true,
        ignore_armor = true, -- Nature
        resonant_fists = true,
        background = true,
        ready = function()
            return Player.talent.press_the_advantage.ok
        end,
        brew_cdr = function()
            return Player.talent.press_the_advantage.effectN( 1 ).seconds
        end,
    },
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
            return Player.talent.weapons_of_order.ok and Player.findAura( 387184 )
        end,
    },
    ["charred_dreams_damage"] = {
        spellID = 425299,
        may_crit = false,
        ignore_armor = true, -- Shadowflame
        background = true,
        action_multiplier = function( trigger_state )
            local am = spell.t31_brm_2pc.effectN( 1 ).pct
            if trigger_state then
                local result = trigger_state.result
                
                if result and result.damage > 0 then
                    local tick_value = ( result.damage / result.ticks / result.target_count )
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        ready = function()
            return ( Player.set_pieces[ 31 ] >= 2 )
        end,
    },
    ["charred_dreams_heal"] = {
        type = "self_heal",
        spellID = 425298,
        may_crit = false,
        background = true,
        action_multiplier = function( trigger_state )
            local am = spell.t31_brm_2pc.effectN( 2 ).pct
            if trigger_state then
                local result = trigger_state.result
                
                if result and result.damage > 0 then
                    local tick_value = ( result.damage / result.ticks / result.target_count )
                    
                    am = am * tick_value
                end
            end
            return am
        end,
        ready = function()
            return ( Player.set_pieces[ 31 ] >= 2 )
        end,
    },
}

-- Blackout Kick -> Celestial Brew
brm_spells["bok_cb_combo"] = deepcopy( brm_spells["blackout_kick"] )
brm_spells["bok_cb_combo"].trigger["special_delivery-2"] = true
brm_spells["bok_cb_combo"].execute_time = function()
    return aura_env.gcd( 100784  ) + aura_env.gcd( 322507 )    
end
brm_spells["bok_cb_combo"].ready = function()
    return not Player.findAura( 322507 ) -- never overwrite current CB
end
brm_spells["bok_cb_combo"].mitigate = function()
    
    local tooltip_array = aura_env.parseTooltip( 322507 )
    local n = tooltip_array[1]
    local m = Player.ability_power * cb_apmod * Player.vers_bonus
    
    if n then
        -- We can use the tooltip to parse for healing reduction effects
        -- since not all healing reduction auras apply to CB
        m = n
    end
    
    local purified_chi_count = Player.talent.blackout_combo.effectN( 6 ).base_value
    
    local purified_chi = Player.findAura( buff.purified_chi )
    if purified_chi then
        purified_chi_count = purified_chi_count + purified_chi.stacks
    end
    
    m = m * ( 1 + ( min( 10, purified_chi_count ) * spell.purified_chi.effectN( 1 ).pct ) )
    
    -- Celestial Brew can benefit from Celestial Fortune
    m = m * aura_env.celestialFortune()
    
    -- Celestial Brew expires after 8 seconds
    local dtps = Player.recent_dtps
    local maximum = ( dtps * 8 )
    m = min( maximum, m )    
    
    if Player.talent.pretense_of_instability.ok then
        local pretenseGain = pretense_duration
        local activePretense = Player.findAura( buff.pretense_of_instability )
        if activePretense then
            pretenseGain = pretenseGain - activePretense.remaining
        end
        
        m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
    end
    
    return m
end
brm_spells["bok_cb_combo"].ready = function()
    -- We don't care about this combo without blackout combo
    return Player.talent.blackout_combo.ok and aura_env.getCooldown( 322507 ) < 10
end

-- Purifiyng Brew -> Celestial Brew ( for purified Chi gain )
brm_spells["purify_cb_combo"] = deepcopy( brm_spells["purifying_brew"] )
brm_spells["purify_cb_combo"].trigger["special_delivery-2"] = true
brm_spells["purify_cb_combo"].execute_time = function()
    return aura_env.gcd( 119582 ) + aura_env.gcd( 322507 )
end
brm_spells["purify_cb_combo"].ready = function()
    return not Player.findAura( 322507 ) -- never overwrite current CB
end
brm_spells["purify_cb_combo"].mitigate = function()
    
    local tooltip_array = aura_env.parseTooltip( 322507 )
    local n = tooltip_array[1]
    local m = Player.ability_power * cb_apmod * Player.vers_bonus
    
    if n then
        -- We can use the tooltip to parse for healing reduction effects
        -- since not all healing reduction auras apply to CB
        m = n
    end
    
    local purified_chi_count = 1
    if Player.findAura( buff.moderate_stagger ) then
        purified_chi_count = 3
    elseif Player.findAura( buff.heavy_stagger ) then
        purified_chi_count = 5
    end
    
    -- No blackout Combo here because we lost it on PB
    
    local purified_chi = Player.findAura( buff.purified_chi )
    if purified_chi then
        purified_chi_count = purified_chi_count + purified_chi.stacks
    end
    
    m = m * ( 1 + ( min( 10, purified_chi_count ) * spell.purified_chi.effectN( 1 ).pct ) )
    
    -- Celestial Brew can benefit from Celestial Fortune
    m = m * ( 1 + ( Player.crit_bonus * 0.65 ) ) 
    
    -- Celestial Brew expires after 8 seconds
    local dtps = Player.recent_dtps
    local maximum = ( dtps * 8 )
    m = min( maximum, m )
    
    if Player.talent.pretense_of_instability.ok then
        local pretenseGain = pretense_duration
        local activePretense = Player.findAura( buff.pretense_of_instability )
        if activePretense then
            pretenseGain = pretenseGain - activePretense.remaining
        end
        
        m = m + dodgeMitigation( spell.pretense.effectN( 1 ).pct, pretenseGain )
    end
    
    return m
end
brm_spells["purify_cb_combo"].ready = function()
    return Player.stagger > 0 and Player.talent.improved_celestial_brew.ok and aura_env.getCooldown( 322507 ) < 10
end

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
    
    -- Populate action callbacks
    aura_env.combo_list = {}
    
    for action, base_spell in pairs( aura_env.spells ) do
        if base_spell.callbacks then
            for _, callback in pairs( base_spell.callbacks ) do
                local name = callback.."_"..action.."_generated"
                if aura_env.spells[ name ] then
                    aura_env.combo_list[ callback ] = aura_env.combo_list[ callback ] or {}
                    if not aura_env.combo_list[ callback ][ name ] then
                        insert( aura_env.combo_list[ callback ], name )
                    end
                end
            end
        end
    end
    
    -- Need to remove these at some point
    if Player.spec == aura_env.SPEC_INDEX["MONK_WINDWALKER"]  then
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_MISTWEAVER"] then
    elseif Player.spec == aura_env.SPEC_INDEX["MONK_BREWMASTER"]  then
        aura_env.combo_list["blackout_kick"] = aura_env.combo_list["blackout_kick"] or {}
        if not aura_env.combo_list["blackout_kick"]["bok_cb_combo"] then
            insert( aura_env.combo_list["blackout_kick"], "bok_cb_combo" )
        end
        aura_env.combo_list["purifying_brew"] = aura_env.combo_list["purifying_brew"] or {}
        if not aura_env.combo_list["purifying_brew"]["purify_cb_combo"] then
            insert( aura_env.combo_list["purifying_brew"], "purify_cb_combo" )
        end
    end
end

aura_env.initGear = function()
    local mainhand = GetInventoryItemLink( "player", 16 )
    local offhand = GetInventoryItemLink( "player", 17 )
    
    local tier_slots = { 1, 3, 5, 7, 10 }
    local tier_ids = { 
        [29] = {
            ["200360"] = true, -- Chest
            ["200362"] = true, -- Hands
            ["200363"] = true, -- Head
            ["200364"] = true, -- Legs
            ["200365"] = true, -- Shoulder
        },
        [30] = {
            ["202509"] = true, -- Chest
            ["202507"] = true, -- Hands
            ["202506"] = true, -- Head
            ["202505"] = true, -- Legs
            ["202504"] = true, -- Shoulder
        },
        [31] = {
            ["207248"] = true, -- Chest
            ["207246"] = true, -- Hands
            ["207245"] = true, -- Head
            ["207244"] = true, -- Legs
            ["207243"] = true, -- Shoulder
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

