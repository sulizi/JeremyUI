function(event, ...)
    
    local aura_env = aura_env
    
    -- Prevent code execution during loading screens or WA options window
    if event == "LOADING_SCREEN_DISABLED" then
        aura_env.world_loaded = true
    elseif event == "LOADING_SCREEN_ENABLED" then
        aura_env.world_loaded = false
        return false
    elseif event == "OPTIONS" or not aura_env.world_loaded then
        return false
    end
    
    local _GetTime = GetTime
    local GetTime = function()
        return aura_env.frameTime or _GetTime()
    end
    
    if event == "FRAME_UPDATE" then
        aura_env.frameTime = _GetTime()
    end
    
    -- This should never occur
    if not aura_env.CPlayer then
        return false
    end
    
    -- Cache Globals
    local Player = aura_env.CPlayer
    local Combat = Player.combat
    local spec = Player.spec
    
    local bit = bit
    local bit_band = bit.band
    local C_NamePlate = C_NamePlate
    local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
    local GetNamePlates = C_NamePlate.GetNamePlates
    local C_Scenario = C_Scenario
    local GetCriteriaInfo = C_Scenario.GetCriteriaInfo or C_ScenarioInfo.GetCriteriaInfo
    local GetInfo = C_Scenario.GetInfo
    local GetStepInfo = C_Scenario.GetStepInfo
    local C_UnitAuras = C_UnitAuras
    local GetAuraDataByAuraInstanceID = C_UnitAuras.GetAuraDataByAuraInstanceID
    local GetAuraDataBySlot = C_UnitAuras.GetAuraDataBySlot
    local CheckInteractDistance = CheckInteractDistance
    local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK
    local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
    local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
    local debugprofilestart = debugprofilestart
    local debugprofilestop = debugprofilestop
    local floor = floor
    local frameTime = GetTime()
    local GetPowerRegen = GetPowerRegen
    local GetRaidTargetIndex = GetRaidTargetIndex
    local GetSpellCharges = GetSpellCharges or function( spellID )
        if not spellID then
            return nil
        end
        
        local chargeInfo = C_Spell.GetSpellCharges( spellID )
        
        if chargeInfo then
            return chargeInfo.currentCharges, chargeInfo.maxCharges, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate
        end
    end
    local GetSpellCooldown = GetSpellCooldown or function( spellID )
        local info = C_Spell.GetSpellCooldown( spellID )
        return info.startTime, info.duration, info.isEnabled
    end
    local GetUnitSpeed = GetUnitSpeed
    local global_modifier = aura_env.global_modifier
    local InCombatLockdown = InCombatLockdown
    local ipairs = ipairs
    local IsEquippedItemType = IsEquippedItemType or C_Item.IsEquippedItemType
    local IsMounted = IsMounted
    local IsSpellKnown = IsSpellKnown
    local LE_SCENARIO_TYPE_CHALLENGE_MODE = LE_SCENARIO_TYPE_CHALLENGE_MODE
    local LibStub = LibStub
    local math = math
    local max = math.max
    local min = math.min
    local pairs = pairs
    local print = print
    local select = select
    local SetRaidTarget = SetRaidTarget
    local string = string
    local find = string.find
    local gsub = string.gsub
    local len = string.len
    local lower = string.lower
    local sub = string.sub
    local table = table
    local targetAuraEffect = aura_env.targetAuraEffect
    local tonumber = tonumber
    local tostring = tostring
    local type = type
    local UnitAffectingCombat = UnitAffectingCombat
    local UnitAuraSlots = UnitAuraSlots or C_UnitAuras.GetAuraSlots
    local UnitChannelInfo = UnitChannelInfo
    local UnitExists = UnitExists
    local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
    local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
    local UnitGUID = UnitGUID
    local UnitHealth = UnitHealth
    local UnitHealthMax = UnitHealthMax
    local UnitIsDead = UnitIsDead
    local UnitIsPlayer = UnitIsPlayer
    local UnitLevel = UnitLevel
    local UnitName = UnitName
    local UnitPower = UnitPower
    local UnitPowerMax = UnitPowerMax
    local UnitStagger = UnitStagger
    local UnitStat = UnitStat
    local UnitThreatSituation = UnitThreatSituation
    local WA_IterateGroupMembers = WA_IterateGroupMembers
    local WeakAuras = WeakAuras
    local gcdDuration = WeakAuras.gcdDuration
    local ScanEvents = WeakAuras.ScanEvents 
    
    local insert = function ( t, v )
        t[ #t + 1 ] = v
    end
    local next = next
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
    
    local profiler_enabled = true
    aura_env.profiler_out = ( profiler_enabled and aura_env.profiler_out ) or {}
    local profilerStart = function() if profiler_enabled then debugprofilestart() end end
    local profilerEnd = function( desc )
        if profiler_enabled then
            local profiler_t = debugprofilestop()
            if profiler_t and profiler_t > 0 then
                aura_env.profiler_out[ desc ] = profiler_t
            end
        end
    end
    
    -- Main worker thread
    if event == "FRAME_UPDATE" then
        
        local fullUpdate = false
        
        -- Development Debugging Option
        if profiler_enabled and next( aura_env.profiler_out ) ~= nil then
            ScanEvents( "JEREMYUI_PROFILER", aura_env.profiler_out )
        end
        
        -- Modulate update speed based on framerate
        if aura_env.frame_pace then
            local delta = frameTime - aura_env.frame_pace
            local modulate = max( 0.0167, delta ) / 0.0167
            aura_env.update_rate = min( 1, modulate * 0.5 )
        end
        aura_env.frame_pace = frameTime
        
        if not aura_env.RECENT_UPDATE or aura_env.RECENT_UPDATE < frameTime - 0.5 then
            profilerStart()
            
            aura_env.RECENT_UPDATE = frameTime
            
            local recentDamage = aura_env.danger_a + aura_env.danger_b
            
            for index, damage in pairs( Combat.recent_damage ) do
                local expire = damage.expire
                if not expire or expire <= frameTime then
                    Combat.recent_damage[ index ] = nil
                else
                    recentDamage = recentDamage + ( damage.amount or 0 )
                end
            end
            
            -- Used for Touch of Karma evaluation 
            Player.recent_dtps = recentDamage / aura_env.RECENT_DURATION
            
            profilerEnd( "Parse Recent Damage" )
        end
        
        if not aura_env.last 
        or aura_env.fast 
        or aura_env.tick_update and aura_env.tick_update < frameTime
        or aura_env.last < frameTime - aura_env.update_rate then
            
            -- Movement Rate / Speed
            if aura_env.last then
                
                local cur_speed = GetUnitSpeed( "player" )
                
                if InCombatLockdown() and not IsMounted() and cur_speed > 0 then
                    local delta_time = ( frameTime - aura_env.last ) 
                    Player.movement_yds = Player.movement_yds + ( cur_speed * delta_time )
                    Player.movement_t = Player.movement_t + delta_time
                    Player.movement_rate = Player.movement_yds / Player.movement_t
                else
                    Player.movement_yds = 0
                    Player.movement_t = 0
                    Player.movement_rate = 0
                end
                
                Player.moving = Player.movement_t >= 1.25
            end
            
            aura_env.fast = false
            aura_env.last = frameTime                   
            fullUpdate = true
        end
        
        aura_env.LBG = aura_env.LBG or LibStub( "LibCustomGlow-1.0" )
        local LBG = aura_env.LBG
        
        
        local jeremy = aura_env.jeremy_update or {}
        local compression_value = 1000
        local spellRaw = function ( name )
            local raw = jeremy.raw[ name ] or 0 
            raw = raw * compression_value
            return raw
        end
        jeremy.raw = jeremy.raw or {}
        jeremy.rank = {}
        jeremy.scale = {}
        local spells = aura_env.spells
        local actionlist = {}
        local actionhash = {}
        local default_action = aura_env.spells[ Player.default_action ]
        aura_env.action_cache = aura_env.action_cache or {}
        local action_set = function( tbl )
            if not tbl.name then return end
            
            tbl.cb             = tbl.cb or spells[ tbl.name ]
            tbl.raw            = tbl.raw or 0
            tbl.ticks          = tbl.ticks or 1
            tbl.damage         = tbl.damage or 0
            tbl.healing        = tbl.healing or 0
            tbl.group_healing  = tbl.group_healing or 0 
            tbl.cooldown       = tbl.cooldown or 0
            tbl.start_cd       = tbl.starts_cooldown or {}
            tbl.execute_time   = max( 0, tbl.execute_time or 0 )
            tbl.cost           = tbl.cost or 0
            tbl.secondary_cost = tbl.secondary_cost or 0
            tbl.delay          = max( 0, tbl.delay or 0 )
            
            -- Snapshot Channel Information
            if tbl.cb and not tbl.cb.canceled and tbl.raw > 0 and Player.channel.spellID and Player.channel.spellID == tbl.cb.spellID then
                Player.channel.action = tbl.cb
                Player.channel.raw = tbl.raw
                Player.channel.ticks = tbl.ticks
            end
            
            local raw_comp = tbl.raw / compression_value
            jeremy.raw[ tbl.name ] = raw_comp > 1 and floor( raw_comp ) or raw_comp 
            if not tbl.background then
                local deficit           = ( Player.primary_resource and Player.primary_resource.deficit ) or 0
                local secondary_deficit = ( Player.secondary_resource and Player.secondary_resource.deficit ) or 0
                
                local dpet = tbl.raw / max( 1, 1 + ( tbl.execute_time ) ) 
                
                tbl.d_time = dpet - tbl.cost
                tbl.d_cost = dpet / max( 1, 1 + deficit + tbl.cost ) / max( 1, 1 + secondary_deficit + tbl.secondary_cost )
                
                local index = actionhash[ tbl.name ] or #actionlist+1
                actionlist[ index ] = tbl
                actionhash[ tbl.name ] = index
            end
            aura_env.action_cache[ tbl.name ] = tbl
            
        end
        
        if spec == 0 then
            return
        end
        
        local targets_tod_range = 0
        local targetList = {}
        local demiseList = {}
        local healer_targets = {}
        
        if fullUpdate then
            
            profilerStart()
            
            Player.Update()
            
            profilerEnd( "Update Unit Info" )
            
            if Player.channel.action then 
                action_set( {
                        type         = "channel",
                        name         = "channel_remaining",
                        raw          = Player.channel.raw or 0,
                        execute_time = Player.channel.remaining + Player.channel.latency,
                        cb           = Player.channel.action,
                })
            end
            
            local ParseAuras = function( Enemy, unitID )
                
                -- Faux auras
                aura_env.targetAuras[ unitID ] = {}
                aura_env.targetAuras[ unitID ][ "priority_check" ] = { amp = Enemy.priority_modifier, expire = frameTime + 3600 }
                
                if Player.role == "TANK" then
                    local threat_status = UnitThreatSituation( "player", unitID ) or 0
                    aura_env.targetAuras[ unitID ][ "threat_check" ] = { 
                        amp = ( threat_status < 3 and 2.0 or 1.0 ), 
                        expire = frameTime + 3600 
                    }
                end
                
                -- Windwalker Specific
                if spec == aura_env.SPEC_INDEX[ "MONK_WINDWALKER" ] then
                    
                    -- Gale Force
                    if Player.getTalent("gale_force").ok and Enemy.gale_force_debuff and Enemy.gale_force_debuff > GetTime() then
                        aura_env.targetAuras[ unitID ][ "gale_force" ] = {
                            amp = 1.10,
                            expire = Enemy.gale_force_debuff
                        }
                    end

                    -- Mark of the Crane
                    Enemy.auraExists( 228287, function( auraData )
                            if auraData.sourceUnit == "player" then
                                Player.motc_targets = Player.motc_targets + 1
                                return true
                            end
                    end )

                    -- Jadefire Harmony
                    Enemy.auraExists( 451580, function( auraData )
                        if auraData.sourceUnit == "player" then
                            local expires = auraData.expirationTime
                            if expires == 0 then
                                expires = frameTime + 3600
                            end
                            aura_env.targetAuras[ unitID ][ "jadefire_harmony" ] = {
                                amp = 1.10,
                                expire = expires
                            }
                            return true
                        end
                    end)

                    -- Acclamation
                    Enemy.auraExists(431385, function(auraData)
                        if auraData.sourceUnit == "player" then
                            local expires = auraData.expirationTime
                            if expires == 0 then
                                expires = frameTime + 3600
                            end
                            aura_env.targetAuras[unitID]["acclamation"] = {
                                amp = 1 + (0.03 * (auraData.stacks or 1)),
                                expire = expires
                            }
                            return true
                        end
                    end)
                    
                    -- Shadowflame Vulnerability
                    Enemy.auraExists( 411376, function( auraData )
                            if auraData.sourceUnit == "player" then
                                Player.sfv_targets = Player.sfv_targets + 1
                                return true
                            end    
                    end )       
                    
                    -- Keefer's Skyreach
                    Enemy.auraExists( 393047, function( auraData )
                            if auraData.sourceUnit == "player" then
                                local expires = auraData.expirationTime
                                if expires == 0 then
                                    expires = frameTime + 3600
                                end                
                                -- 0 amplifier for tracking purposes
                                aura_env.targetAuras[ unitID ][ auraData.spellId ] = { 
                                    amp = 0, 
                                    expire = expires 
                                }
                                return true    
                            end    
                    end )              
                    
                    -- Fae Exposure / Jadefire Brand
                    Enemy.auraExists( { 356773, 395414 }, function( auraData )
                            if auraData.sourceUnit == "player" then
                                local expires = auraData.expirationTime
                                if expires == 0 then
                                    expires = frameTime + 3600
                                end
                                
                                Player.jfh_targets = Player.jfh_targets + 1
                                Player.jfh_dur_total = max( 0, Player.jfh_dur_total + ( expires - frameTime ) )
                                aura_env.targetAuras[ unitID ][ auraData.spellId ] = { 
                                    amp = 1.12, 
                                    expire = expires 
                                }
                                return true
                            end    
                    end )
                end
                
                -- Brewmaster Specific
                if spec == aura_env.SPEC_INDEX[ "MONK_BREWMASTER" ] then
                    
                    -- Weapons of Order Debuff
                    Enemy.auraExists( { 312106, 387179 }, function( auraData )
                            if auraData.sourceUnit == "player" then
                                local expires = auraData.expirationTime
                                if expires == 0 then
                                    expires = frameTime + 3600
                                end
                                
                                local woo_count = auraData.applications or 0
                                local woo_amp = 1 + ( 0.08 * woo_count )
                                aura_env.woo_best = max( aura_env.woo_best, woo_count )
                                Player.woo_targets = Player.woo_targets + 1
                                Player.woo_dur_total = max( 0, Player.woo_dur_total + ( expires - frameTime ) )
                                aura_env.targetAuras[ unitID ][ auraData.spellId ] = { 
                                    amp = woo_amp, 
                                    expire = expires 
                                }
                                return true
                            end    
                    end )    
                    
                    -- Keg Smash
                    Enemy.auraExists( 121253, function( auraData )
                            if auraData.sourceUnit == "player" then
                                Player.ks_targets = Player.ks_targets + 1
                                return true
                            end    
                    end ) 
                    
                    -- Breath of Fire
                    Enemy.auraExists( 123725, function( auraData )
                            if auraData.sourceUnit == "player" then
                                Player.bof_targets = Player.bof_targets + 1
                                return true
                            end    
                    end )         
                end
                
                -- Generic
                
                -- Others defined in Init
                for id, aura_amp in pairs( aura_env.aura_amps ) do
                    local copies = 0
                    Enemy.auraExists( id, function( auraData )
                            local expires = auraData.expirationTime
                            if expires == 0 then
                                expires = frameTime + 3600
                            end         
                            
                            if copies > 0 then
                                aura_env.targetAuras[ unitID ][ id ] = { 
                                    amp = aura_env.targetAuras[ unitID ][ id ].amp * aura_amp.modifier, 
                                    expire = min( aura_env.targetAuras[ unitID ][ id ].expire, expires ) 
                                }
                            else
                                aura_env.targetAuras[ unitID ][ id ] = { 
                                    amp = aura_amp.modifier, 
                                    expire = expires 
                                }
                            end
                            copies = copies + 1
                            if copies >= aura_amp.copies then
                                return true
                            end
                    end )
                end
            end
            
            aura_env.combatHealthRemaining = 0
            aura_env.targetHealthRemaining = 0
            
            aura_env.in_keystone = select( 10, GetInfo() ) == LE_SCENARIO_TYPE_CHALLENGE_MODE 
            
            local UpdateTargets = function()
                
                local count = 0
                local fight_remains = 0
                local finalBoss = false
                
                aura_env.boss_lockdown = false
                aura_env.woo_best = 0
                
                Player.react.spellsteal = false
                
                Player.motc_targets = 0
                Player.jfh_targets = 0
                Player.jfh_dur_total = 0
                Player.ks_targets = 0
                Player.bof_targets = 0
                Player.sfv_targets = 0
                Player.woo_targets = 0
                aura_env.targetAuras = {}
                
                healer_targets = {}
                
                if spec == aura_env.SPEC_INDEX["MONK_MISTWEAVER"]  then
                    -- Skip this loop for efficiency if not MW Spec
                    
                    for it in WA_IterateGroupMembers() do
                        if  UnitIsDead( it ) == false and CheckInteractDistance( it, 1 ) then
                            local deficit = UnitHealthMax( it ) - UnitHealth( it ) + UnitGetTotalHealAbsorbs( it )
                            
                            if deficit > 0 then -- Valid healing target
                                healer_targets[ #healer_targets + 1 ] = {
                                    deficit = deficit,
                                    unitID = it,
                                }
                            end
                        end
                    end
                end
                
                local targetLimit = 10
                local configLimit = aura_env.config.target_limit
                if configLimit then
                    if configLimit == 1 then
                        targetLimit = 5
                    elseif configLimit == 2 then
                        targetLimit = 10
                    elseif configLimit == 3 then
                        targetLimit = 15
                    else
                        targetLimit = 20
                    end
                end
                
                local TargetFilter = function()
                    
                    local validTargets = {}
                    local checkTod = spells[ "touch_of_death" ] and Player.getCooldown( "touch_of_death" ) == 0 and aura_env.config.tod_glow > 1
                    
                    for _, nameplateframe in pairs( GetNamePlates() ) do
                        
                        local unitID = nameplateframe.namePlateUnitToken
                        local unitGUID = UnitGUID( unitID )
                        
                        if unitGUID == UnitGUID( "target" ) then
                            unitID = "target"
                        end
                        
                        local glowTod = false
                        
                        if aura_env.validTarget( unitID ) then
                            
                            local enemy = aura_env.GetEnemy( unitGUID )
                            
                            enemy.unitID = unitID
                            enemy.range = aura_env.unitRange( unitID )
                            
                            -- Update BigWig Intermission Timers
                            local intermission = nil
                            for k, v in pairs( aura_env.BW_intermission_timers ) do
                                local remaining = v.expire - frameTime
                                if v.encounterId ~= aura_env.encounter_id or remaining <= 0 then
                                    aura_env.BW_intermission_timers[ k ] = nil
                                elseif UnitGUID( v.unitid ) == unitGUID then
                                    intermission = ( intermission and min( intermission, remaining ) ) or remaining
                                end
                            end
                            enemy.intermission = intermission
                            
                            local excluded = ( enemy.priority_modifier == 0 )
                            
                            if not excluded and enemy.lastHealth then
                                excluded = enemy.lastHealth < 0.01
                            end   
                            
                            if not excluded then
                                excluded = enemy.range > 8
                            end          
                            
                            if not excluded then
                                if enemy.needsFullUpdate then
                                    ScanEvents( "UNIT_AURA_FULL_UPDATE", unitID )
                                end
                                excluded = ( next( enemy.auraExclusions ) ~= nil )
                            end
                            
                            if excluded then
                                aura_env.targetAuras[unitID] = {}
                                aura_env.targetAuras[unitID]["priority_check"] = { amp = ( unitID == "target" and 0.01 ) or 0, expire = frameTime + 3600 }
                            else
                                -- ToD off CD and option enabled
                                if checkTod then
                                    -- Valid ToD Target
                                    if ( enemy.healthPct < 0.15 and Player.talent.improved_touch_of_death.ok and aura_env.config.tod_glow < 3 ) 
                                    or UnitHealth( unitID ) < UnitHealthMax( "player" ) then
                                        glowTod = true
                                        targets_tod_range = targets_tod_range + 1
                                    end
                                end
                                
                                validTargets[ #validTargets + 1 ] = enemy
                                targetList[ #targetList + 1 ] =  enemy.npcid                               
                            end
                            
                        end
                        
                        if nameplateframe then
                            if glowTod then 
                                LBG.PixelGlow_Start( nameplateframe, { 1, 0, 0, 1 } )
                            else
                                LBG.PixelGlow_Stop( nameplateframe )
                            end
                        end    
                        
                    end      
                    
                    if #validTargets > targetLimit then
                        sort( validTargets, function( l, r ) 
                                if l.unitID == "target" then
                                    return true
                                elseif r.unitID == "target" then
                                    return false
                                elseif l.isBoss and not r.isBoss then
                                    return true
                                elseif r.isBoss and not l.isBoss then
                                    return false
                                elseif l.ttd and r.ttd then
                                    return l.ttd > r.ttd
                                else
                                    return ( l.lastHealth or 1 ) > ( r.lastHealth or 1 )
                                end
                        end )
                    end
                    
                    return validTargets
                end
                
                Player.targets = TargetFilter()
                
                for _, enemy in pairs( Player.targets ) do
                    
                    if not aura_env.boss_lockdown then 
                        
                        if enemy.isBoss then
                            
                            aura_env.boss_lockdown = true
                            
                            if not finalBoss and aura_env.in_keystone then
                                local steps = select( 3, GetStepInfo() )
                                
                                if steps then
                                    local _, _, _, _, total, _, _, current = GetCriteriaInfo( steps )
                                    
                                    if current then
                                        current = tonumber( sub( current, 1, len( current ) - 1 ) ) or 0
                                        if ( current / total ) > 0.99 then
                                            finalBoss = true
                                        end
                                    end
                                end
                            end
                        end
                    end    
                    
                    count                   = count + 1
                    aura_env.combatHealthRemaining   = aura_env.combatHealthRemaining + enemy.healthActual
                    fight_remains           = max( enemy.ttd or 0, fight_remains )
                    
                    local demise = max( 1, floor( enemy.ttd or 1 ) )
                    demiseList[ demise ] = ( demiseList[ demise ] or 0 ) + 1
                    
                    if enemy.unitID == "target" then
                        aura_env.targetHealthRemaining = enemy.healthActual
                        Player.react.spellsteal = next( enemy.stealable_auras ) ~= nil
                    end
                    
                    ParseAuras( enemy, enemy.unitID )
                    
                    if count >= targetLimit then
                        break
                    end
                end
                
                if finalBoss then
                    aura_env.fight_remains = 3600
                else
                    if fight_remains > 0 then
                        aura_env.fight_remains = max( 1, floor( fight_remains + 0.5 ) )
                    else
                        aura_env.fight_remains = 300
                    end
                end
                
                sort( healer_targets, function( l, r ) 
                        return l.deficit > r.deficit 
                end)
                
                return max( 1, count )
            end
            
            if not aura_env.target_update or aura_env.target_update < frameTime - 1 then
                profilerStart()
                
                -- Nameplate iterator 
                aura_env.target_count = UpdateTargets()
                aura_env.healer_targets = healer_targets
                
                profilerEnd( "UpdateTargets()" )
                
                -- Force ST Config Option
                if aura_env.config.targetting == 2 then
                    aura_env.target_count = 1         
                end                
                
                profilerStart()
                
                -- Initialize one-time pull data
                if aura_env.target_count > 1 then
                    aura_env.pull_hash = aura_env.hashEnemyList( targetList ) -- Generate unique pull ID
                    aura_env.pull_data = aura_env.get_pull_data( aura_env.pull_hash ) -- Initialize pull data
                    --aura_env.nextPullListener( aura_env.pull_hash )
                end
                
                profilerEnd( "Hash Pull Data" )
                profilerStart()
                
                -- Time based spawn / demise
                aura_env.raid_events = aura_env.EventTimers( demiseList )       
                
                profilerEnd( "Update Event Timers" )
                
                aura_env.target_update = frameTime
            end
            
        end
        
        local t_spells = {}
        for name, action in pairs( spells ) do
            if not action.background then
                t_spells[ #t_spells + 1 ] = {
                    name = name,
                    action = action,
                }
            end
        end      
        local n_spells = #t_spells
        
        if n_spells > 0 and ( fullUpdate or not aura_env.actionlist_update or aura_env.actionlist_update < frameTime - ( 0.5 / n_spells ) )then
            
            aura_env.actionlist_update = frameTime
            
            debugprofilestart()
            
            local cpu_target = aura_env.config.cpu_target or 1.5 -- target CPU processing time in miliseconds
            
            if aura_env.rank_cpu_average then
                cpu_target = cpu_target - aura_env.rank_cpu_average
            end
            
            local process_trees = 5
            
            if aura_env.action_cpu_average then
                process_trees = max( 1, floor( cpu_target / aura_env.action_cpu_average ) )
            end
            
            if not InCombatLockdown() then
                -- limited to 5 out of combat
                process_trees = min( process_trees, 5 )
            end
            
            local debug_process_min = nil
            local debug_process_max = nil
            if not aura_env.spell_range_min or aura_env.spell_range_min >= n_spells then
                aura_env.spell_range_min = 1
            end
            aura_env.spell_range_max = ( aura_env.spell_range_min + process_trees )
            
            for spell_it, _spell in ipairs( t_spells ) do
                
                local name = _spell.name
                local action = _spell.action
                
                local continue = false
                if spell_it < aura_env.spell_range_min or spell_it > aura_env.spell_range_max then
                    if aura_env.action_cache[ name ] then
                        action_set( aura_env.action_cache[ name ] )
                        continue = true
                    end
                end
                
                if not continue then
                    
                    debug_process_min = debug_process_min or spell_it
                    debug_process_max = spell_it
                    
                    local spellID = action.spellID
                    local action_type = action.type
                    
                    if spellID ~= nil then
                        
                        if action.skip_calcs then
                            action_set( {
                                    type = action_type,
                                    name = name,
                                    raw = Player.ready( action ) and 1 or 0,
                                    cost = 0,
                                    execute_time = 0,
                            } )
                        else
                            local combo_base        = action.combo_base
                            local start_cooldown    = action.start_cooldown or {}
                        
                            -- ----------

                            action.base_cost = action.cost( action )
                            
                            -- ------------
                            
                            local generateActionState = function( future )
                                
                                local future = future or 0
                                local max_window = 5
                                
                                local damage_out, healing_out, group_heal_out, mitigate_out = 0, 0, 0, 0
                                local gain_out, cost_out, secondary_cost_out = 0, 0, 0
                                local trigger_time, trigger_delay = 0, 0

                                local final_state    = {}
                                local state_table    = {}
                                local trigger_spells = {}
                                local trigger_exists = {}
                                
                                local target_list = {}
                                local fight_remains = 0
                                local funnel_enabled = aura_env.config.funnel_option == 2 or ( aura_env.config.funnel_option == 3 and IsInInstance() and not IsInRaid() )
                                
                                for _, target in pairs( Player.targets ) do
                                    target_list[ #target_list + 1 ] = {
                                        unitID  = target.unitID,
                                        health  = target.healthActual,
                                        dtps    = target.dtps,
                                    }
                                    fight_remains = max( target.ttd or 0, fight_remains )
                                end
                                
                                local trigger_pushback = function( spell, enabled, periodic, recursive_callback, stack )
                                    
                                    local _driver = recursive_callback and spells[ recursive_callback ] or nil
                                    local _driverName = recursive_callback or "state_generator"
                                    local _stack = ( stack or _driverName ) .. " -> " .. spell
                                    
                                    trigger_exists[ spell.."-".._driverName ] = true
                                    
                                    -- Allow multiple identical triggers
                                    spell = gsub( spell, "%-.*", "" )    

                                    if spell and spells[ spell ] then
                                        
                                        local _this = {}
                                        local callback_stack = {}
                                        local stack_driver = nil
                                        
                                        local triggerReady = function( self, state )
                                            if type( enabled ) == "function" then
                                                return enabled( self, state )
                                            end
                                            return enabled
                                        end
                                        
                                        local h = 5381
                                        local l = nil
                                        for cb in gsub( _stack .. "->", "%s+", "" ):gmatch( "(.-)->" ) do
                                            l = ( stack_driver and h ) or nil
                                            for c in cb:gmatch( "." ) do
                                                h = ( bit.lshift( h, 5 ) + h ) + string.byte( c )
                                            end    
                                            insert( callback_stack, {
                                                    name = cb,
                                                    spell = spells[ cb ] or nil,
                                                    driverName = stack_driver,
                                            } )
                                            stack_driver = cb
                                        end
                                        
                                        _this.ready = triggerReady
                                        _this.stack = _stack
                                        _this.spell = spell
                                        _this.onTick = periodic
                                        _this.icd = spells[ spell ].icd or 0
                                        
                                        _this.state = {
                                            -- Pass driver callbacks to trigger
                                            callback_state = state_table[ l ] or 
                                            {
                                                time          = future,
                                                result        = nil,
                                                success_rate  = 1,
                                                primary       = Player.primary_resource.current,
                                                secondary     = Player.secondary_resource.current,
                                                buffs         = {},
                                                cooldown      = {},
                                                invalid       = false,
                                                targets       = target_list,
                                                fight_remains = fight_remains,
                                                health        = Player.health_current,
                                                
                                            },
                                            callback_stack = callback_stack,
                                            callback_name = _driverName,
                                            callback = _driver,
                                            result = nil,
                                            ticks = ( _driver and ( _driver.ticks() * _driver.target_count( _driver, state_table[ l ] ) ) ) or 1,
                                            pos = #callback_stack,
                                            time = 0,
                                            primary = 0,
                                            secondary = 0,
                                            buffs = {},
                                            cooldown = {},
                                            invalid = false,
                                        }
                                        state_table[ h ] = _this.state
                                        
                                        _this.rate = spells[ spell ].trigger_rate or 1
                                        
                                        if type( _this.rate ) == "function" then
                                            _this.rate = _this.rate( _this.state )
                                        end
                                        
                                        if _this.rate > 0 then
                                            if not periodic then
                                                _this.state.count = _this.rate
                                            else
                                                if _this.icd > 0 then
                                                    _this.state.count = min( _this.state.ticks, _this.rate * floor( _driver.execute_time( state_table[ l ] ) / _this.icd ) )
                                                else
                                                    _this.state.count = _this.rate * _this.state.ticks
                                                end
                                            end
                                            
                                            trigger_spells[ #trigger_spells + 1 ] =  _this
                                        end
                                    end
                                end
                                
                                trigger_pushback( name, true, false )
                                
                                -- Recursive triggers
                                local do_recursion = true
                                while ( do_recursion ) do
                                    do_recursion = false
                                    for _, trigger in pairs( trigger_spells ) do
                                        local spell = spells[ trigger.spell ]
                                        if spell.trigger then
                                            for recursive_trigger, enabled in pairs( spell.trigger ) do
                                                if not trigger_exists[ recursive_trigger.."-"..trigger.spell ] then    
                                                    trigger_pushback( recursive_trigger, enabled, false, trigger.spell, trigger.stack )
                                                    do_recursion = true
                                                end
                                            end
                                        end
                                        if spell.tick_trigger then
                                            for recursive_trigger, enabled in pairs( spell.tick_trigger ) do
                                                if not trigger_exists[ recursive_trigger.."-"..trigger.spell ] then
                                                    trigger_pushback( recursive_trigger, enabled, true, trigger.spell, trigger.stack )
                                                    do_recursion = true
                                                end
                                            end     
                                        end
                                    end
                                end
                                
                                -- Setup state position and index tables
                                sort( trigger_spells, function( l, r )
                                        return l.state.pos < r.state.pos
                                end)
                                
                                for _, trigger in pairs( trigger_spells ) do
                                    
                                    -- TODO:  - Rename shadowed variables
                                    
                                    -- Initialization
                                    
                                    local state = trigger.state
                                    
                                    local driver = state.callback
                                    local driverName = state.callback_name
                                    local driverState = state.callback_state
                                    
                                    -- Inherit state from Driver
                                    if driverState then
                                        local copyState = function( e )
                                            state[ e ] = driverState[ e ]
                                        end    
                                        
                                        copyState( "result" )
                                        copyState( "primary" )
                                        copyState( "secondary" )
                                        copyState( "time" )
                                        copyState( "buffs" )
                                        copyState( "cooldown" )
                                        copyState( "success_rate" )
                                        copyState( "invalid" )
                                        copyState( "targets" )
                                        copyState( "health" )
                                    end
                                    
                                    local spell = spells[ trigger.spell ]
                                    
                                    local tick_count = state.count
                                    
                                    local trigger_mitigate = 0
                                    local trigger_damage = 0
                                    local trigger_healing = 0
                                    local trigger_group_heal = 0
                                    
                                    local basePrimary = state.primary
                                    local baseSecondary = state.secondary
                                    local baseTime = state.time
                                    local baseHealth = state.health
                                    
                                    local delay = function( t )
                                        
                                        if delay == 0 then
                                            return
                                        end
                                        
                                        state.time = state.time + t
                                        
                                        if Player.primary_resource and Player.primary_resource.regen > 0 then
                                            state.primary = state.primary + ( Player.primary_resource.regen * t )
                                        end
                                        
                                        if Player.secondary_resource and Player.secondary_resource.regen > 0 then
                                            state.secondary = state.secondary + ( Player.secondary_resource.regen * t )
                                        end
                                    end

                                    if not state.invalid and driver then
                                        
                                        -- Driver is a channeled ability and trigger is not background action
                                        if driver.channeled and not spell.background then
                                            local latency = Player.channel.latency or 0
                                            -- Currently only relevant instance of this is spinning crane kick but use a generic action variable at some point
                                            local use_during_channel = driver.spellID == 101546 and spell.usable_during_sck 
                                            if use_during_channel then
                                                latency = 0
                                                delay( -1 * driver.duration )
                                            end                            
                                            delay( latency )
                                        end
                                        
                                        local _, stack = ipairs( state.callback_stack )
                                        if #stack > 1 then
                                            local _prev     = #stack - 1
                                            local _prev_cb  = stack[ _prev ]
                                            if _prev_cb and _prev_cb.spell then
                                                local _prev_spell = _prev_cb.spell
                                                if ( not spell.background or not _prev_spell.background ) and _prev_spell.onExecute then
                                                    _prev_spell.onExecute( _prev_spell, state )
                                                end
                                            end
                                        end
                                    end

                                    local trigger_cost, trigger_secondary_cost = spell.cost( spell, state )
                                    
                                    -- Add resource regeneration to action delay if low on resources
                                    if not state.invalid and trigger_cost > state.primary then
                                        if Player.primary_resource and Player.primary_resource.regen > 0 then
                                            local resource_delta = trigger_cost - Player.primary_resource.current
                                            delay( resource_delta / Player.primary_resource.regen )
                                        else
                                            state.invalid = true
                                        end
                                    end

                                    if not state.invalid and trigger_secondary_cost > state.secondary then
                                        if Player.secondary_resource and Player.secondary_resource.regen > 0 then
                                            local resource_delta = trigger_secondary_cost - Player.secondary_resource.current
                                            delay( resource_delta / Player.secondary_resource.regen )
                                        else
                                            state.invalid = true
                                        end
                                    end  

                                    -- Check ready state
                                    state.invalid = state.invalid or not trigger.ready( spell, state )
 
                                    -- Check ready state
                                    state.invalid = state.invalid or not Player.ready( spell, state )
                                    
                                    -- set init trigger CD
                                    local trigger_cd_remains = Player.getCooldown( trigger.spell, state )
                                    local trigger_cd         = Player.getBaseCooldown( trigger.spell )
                                    
                                    delay( trigger_cd_remains )
                                    
                                    if trigger_cd > 0 then
                                        start_cooldown[ #start_cooldown + 1 ] = trigger.spell
                                    end
 
                                    if not state.invalid then
                                        
                                        -- Start Cooldown
                                        state.cooldown[ trigger.spell ] = trigger_cd
                                    
                                        -- Stagger
                                        local stagger_reduction = 0
                                        if spell.reduce_stagger and type( spell.reduce_stagger ) == "function" then
                                            stagger_reduction = spell.reduce_stagger( state )
                                            stagger_reduction = min( stagger_reduction, Player.stagger ) -- Limited to current stagger
                                        end
                                          
                                        -- Mitigation
                                        trigger_mitigate = stagger_reduction
                                        if spell.mitigate and type( spell.mitigate ) == "function" then
                                            trigger_mitigate = trigger_mitigate + ( spell.mitigate( state ) or 0 )
                                        end
                                        
                                        -- Tick Function
                                        local ticks             = spell.ticks()
                                        local ticks_remaining   = ticks
                                        local tick_time         = spell.execute_time( state ) / ticks
                                        local tick_value        = spell.tick_value( spell, state )
                                    
                                        while ticks_remaining > 0 do
                                            local tick_partition = ticks_remaining < 2 and ticks_remaining or 1
                                            
                                            -- Trigger is non-background action with execute time
                                            if tick_time > 0 and not spell.background then
                                                state.time = state.time + ( tick_time * tick_partition )
                                            end
                                            
                                            local tick_damage        = tick_value.damage
                                            local tick_healing       = tick_value.healing
                                            local tick_group_healing = tick_value.group_healing
                                            
                                            local target_count = spell.target_count( spell, state )
                                            
                                            local temporary_amplifiers  = global_modifier( spell, state.time ) * targetAuraEffect( spell, state.time )  
                                            
                                             -- Action Multiplier
                                            tick_damage = tick_damage * Player.action_multiplier( spell, state )
                                            tick_damage = tick_damage * temporary_amplifiers

                                            tick_damage         = tick_damage * tick_partition
                                            tick_healing        = tick_healing * tick_partition
                                            tick_group_healing  = tick_group_healing * tick_partition
                                            
                                            if tick_damage > 0 or spell.type ~= "damage" then
                                                
                                                local sqrt_targets      = spell.sqrt_after or 0
                                                local primary_targets   = spell.aoe and spell.primary_aoe_targets or 0
                                                
                                                if type( sqrt_targets ) == "function" then
                                                    sqrt_targets = sqrt_targets()
                                                end
    
                                                local primary_target_multiplier     = ( spell.aoe and spell.primary_target_multiplier( self, state ) ) or 1
                                                local secondary_target_multiplier   = ( spell.aoe and spell.secondary_target_multiplier( self, state ) ) or 1                   
                                                
                                                local t_idx = 1
                                                
                                                for _, target in pairs( state.targets ) do
                                                    
                                                    local target_multiplier = 1
                                                    
                                                    if t_idx <= primary_targets then
                                                        target_multiplier = primary_target_multiplier
                                                    else
                                                        if sqrt_targets > 0 and t_idx > sqrt_targets then
                                                            target_multiplier = sqrt( sqrt_targets / target_count )
                                                        end
                                                        target_multiplier = target_multiplier * secondary_target_multiplier
                                                    end
                                                    
                                                    local target_partition = 1
                                                    local target_demise = math.max( 1, math.min( 300, target.health / ( target.dtps or 1 ) ) )
                                                    
                                                    if not aura_env.pvp_mode and funnel_enabled and target_demise < state.fight_remains then
                                                        -- Priority damage or funnel ( when applicable ), if an enemy lives significantly longer than
                                                        -- others it is placed higher in priority, i.e., if there is 30 seconds left in combat,
                                                        -- an enemy that lives for 5 seconds is less priority than an enemy that lives for 28 seconds.                
                                                        local delta_ttd = state.fight_remains - target_demise
                                                        -- Ignore this effect if the time delta is insubstantial 
                                                        if delta_ttd > 3 then 
                                                            target_partition = target_partition * ( target_demise / state.fight_remains )
                                                        end
                                                    end
                                                    
                                                    local log_damage = math.min( target.health, tick_damage * target_multiplier )
                                                    local log_healing = math.min( Player.health_max - state.health, tick_healing * target_multiplier )
                                                    
                                                    trigger_damage      = trigger_damage + ( log_damage * target_partition )
                                                    trigger_healing     = trigger_healing + log_healing
                                                    trigger_group_heal  = trigger_group_heal + ( tick_group_healing * target_multiplier )
                                                    
                                                    if spell.onImpact then
                                                        spell.onImpact( spell, state )
                                                    end
                                                    
                                                    target.health = target.health - log_damage
                                                    state.health = state.health + log_healing
                                                
                                                    if target.health == 0 then 
                                                        target = nil
                                                    end
                                                    
                                                    t_idx = t_idx + 1
                                                    if t_idx > target_count then
                                                        break
                                                    end
                                                end
                                            end
                                            
                                            ticks_remaining = ticks_remaining - tick_partition
                                        end
                                        
                                        -- Trigger reduces cooldown of spell
                                        if spell.reduces_cd then
                                            for cdr_spell, cdr_value in pairs( spell.reduces_cd ) do
                                                
                                                cdr_spell = gsub( cdr_spell, "%-.*", "" )
                                                
                                                local cdr = cdr_value  
                                                
                                                if type( cdr ) == "function" then
                                                    cdr = cdr( spell, state )
                                                end
                                                
                                                if state.cooldown[ cdr_spell ] then
                                                    state.cooldown[ cdr_spell ] = max( 0, state.cooldown[ cdr_spell ] - cdr )
                                                end
                                            end
                                        end      
                                        
                                        -- Compounded Success Rate
                                        state.success_rate = state.success_rate * spell.success( spell, state )
                                        state.invalid = state.invalid or state.success_rate <= 0
                                        
                                        -- Update result table
                                        state.result = {
                                            ticks           = ticks,
                                            damage          = trigger_damage,
                                            healing         = trigger_healing,
                                            group_healing   = trigger_group_heal,
                                            cost            = trigger_cost,
                                            secondary_cost  = trigger_secondary_cost,
                                            delay           = 0,
                                        }
                                        
                                        damage_out     = damage_out + ( trigger_damage * tick_count * state.success_rate )
                                        healing_out    = healing_out + ( trigger_healing * tick_count * state.success_rate )
                                        group_heal_out = group_heal_out + ( trigger_group_heal * tick_count * state.success_rate )
                                        mitigate_out   = mitigate_out + ( trigger_mitigate * tick_count * state.success_rate )
                                        
                                    end

                                    -- Update Resources
                                    state.primary = state.primary - trigger_cost
                                    state.primary = state.primary + ( tick_count * ( spell.chi_gain and spell.chi_gain( state ) or 0 ) )
                                    state.primary = min( state.primary, Player.primary_resource.max )
                                    
                                    state.secondary = state.secondary - trigger_secondary_cost
                                    --state.secondary = state.secondary + TODO Secondary Gain function
                                    state.secondary = min( state.secondary, Player.secondary_resource.max )                                    
                                    
                                    -- Update Trigger results
                                    cost_out            = cost_out + ( basePrimary - state.primary )
                                    secondary_cost_out  = secondary_cost_out + ( baseSecondary - state.secondary )
                                    trigger_time        = trigger_time + ( state.time - baseTime )
                                    
                                    if driverName == "state_generator" then
                                        trigger_delay = trigger_time + future
                                    end
                                    
                                    if trigger.spell == "fists_of_fury" and state.targets then
                                        --DevTools_Dump( state.targets )
                                    end
                                    
                                    for _, target in pairs( state.targets ) do
                                        target.health = max( 0, target.health - target.dtps * ( state.time - baseTime ) )
                                        target.ttd = target.health / target.dtps
                                        state.fight_remains = max( target.ttd or 0, state.fight_remains )
                                    end
                                    
                                    if not spell.background and state.time + trigger_delay > max_window then
                                        state.invalid = true
                                    end
                                    
                                    final_state = state
                                    
                                    if state.invalid and not spell.background then
                                        damage_out = 0
                                        healing_out = 0
                                        group_healing = 0
                                        break
                                    end
                                end
                                
                                return {
                                    cost = cost_out,
                                    secondary_cost = secondary_cost_out,
                                    damage = damage_out,
                                    self_healing = healing_out,
                                    mitigation = mitigate_out,
                                    group_healing = group_heal_out,
                                    execute_time = trigger_time,
                                    delay = trigger_delay,
                                    state = final_state,
                                }
                            end
                            
                            --[[
                            local damage, healing, group_healing = 0, 0, 0
                                
                            local resultMatrix = {}
                            local timeMatrix = { action_delay }
                            local targetMatrix = { [ action_delay ] = action_targets }
                            local triggerResults = {}
                            local cacheResults = function( t )
                                resultMatrix[ t ] = {
                                    callback                = action,
                                    damage                  = 0,
                                    self_healing            = 0,
                                    group_healing           = group_healing,
                                    mitigation              = 0, --mitigation,
                                    crit_rate               = 0, --crit_rate,
                                    crit_mod                = 0, --crit_mod,
                                    critical_damage         = 0, --crit_damage,
                                    critical_healing        = 0, --crit_healing,
                                    critical_group_healing  = 0, --crit_group_healing,
                                    execute_time            = 0, --execute_time,
                                    delay                   = action_delay,
                                    trigger_results         = triggerResults,
                                    cost                    = 0, --cost,
                                    secondary_cost          = 0, --secondary_cost,
                                    reduce_cd               = {},
                                }
                            end
                            
                            -- Raid Events
                            if  action_type == "damage" and name ~= "touch_of_death"
                            and action_cooldown > 0
                            and action.target_multiplier 
                            and ( not Player.channel.spellID or Player.channel.spellID ~= spellID ) then
                                for _, raid_event in pairs( aura_env.raid_events ) do
                                    local count = raid_event.count
                                    local t = floor( raid_event.adds_in )
                                    if count > action_targets and action_cooldown > t and t > action_delay then
                                        timeMatrix[ #timeMatrix + 1 ] = t
                                        targetMatrix[ t ] = count
                                    end
                                end
                            end
                            
                            for _, delay in pairs( timeMatrix ) do

                                triggerResults = generateActionState( delay )
                                
                                cacheResults( action_delay )
                            end
                            ]]
                        
                            local resultMatrix = { [0] = {
                                cost = 0,
                                secondary_cost = 0,
                                damage = 0,
                                self_healing = 0,
                                mitigation = 0,
                                group_healing = 0,
                                execute_time = 0,
                                delay = 0,
                                trigger_results = generateActionState( 0 ),
                                state = nil,
                            } }

                            local tmpD = nil
                            local resultIdx = 0
                            local adjusted = 0
                            
                            for idx, results in pairs( resultMatrix ) do
                                
                                results.result_base = { }
                                for k, v in pairs( results ) do
                                    results.result_base[ k ] = v
                                end
                                
                                -- Post-processing effects
                                aura_env.actionPostProcessor( results )
                                
                                -- Trigger effects
                                for k, v in pairs( results.trigger_results ) do
                                    if results[ k ] then
                                        results[ k ] = results[ k ] + v
                                    end
                                end
                                
                                -- -----------------------------------------------------
                                
                                -- Adjust damage / heal value based on spec roles
                                local D = results.damage
                                
                                if Player.role ~= "DAMAGER" or not IsInGroup() then
                                    D = ( D * 0.5 ) + results.self_healing
                                    
                                    if Player.role == "TANK" then
                                        D = D + results.mitigation
                                    else
                                        D = D + results.group_healing
                                    end
                                end
                                
                                results.adjusted = D
                                
                                if not tmpD or tmpD < D then
                                    tmpD = D
                                    resultIdx = idx
                                end
                            end
                            
                            local result = resultMatrix[ resultIdx ]

                            -- -----------------------------------------------------
                            
                            action_set( { 
                                    type = action_type,
                                    name = name,
                                    raw = result.adjusted,
                                    cost = result.cost,
                                    secondary_cost = result.secondary_cost,
                                    damage = result.damage,
                                    healing = result.healing,
                                    group_healing = result.group_healing,
                                    starts_cooldown = start_cooldown,
                                    delay = result.delay,
                                    cooldown = Player.getBaseCooldown( combo_base or name ),
                                    base_cost = action.base_cost or 0,
                                    execute_time = result.execute_time,
                                    background = action.background,
                                    combo_base = combo_base,
                            })
                        end
                    end
                end -- continue
            end
            aura_env.spell_range_min = aura_env.spell_range_min + process_trees
            
            local action_cpu_time = debugprofilestop()
            local actions_current = debug_process_max - debug_process_min
            local action_cpu_avg  = action_cpu_time / actions_current
            
            if aura_env.action_cpu_average then
                aura_env.action_cpu_average = ( aura_env.action_cpu_average + action_cpu_avg ) / 2
            else
                aura_env.action_cpu_average = action_cpu_avg
            end
            
            if action_cpu_time > 0 and profiler_enabled then
                aura_env.profiler_out[ "Update ActionList" ] = action_cpu_time 
            end
        end
        
        if fullUpdate and next( actionlist ) ~= nil then
            
            -- Sort and rank candidate actions
            -- -----------------------------------------------------------
            local n = #actionlist
            
            if n > 0 then
                debugprofilestart()
                
                local function sortActionList( list )
                    
                    local validActions = {}
                    for i = 1, n do
                        local action = list[ i ]
                        if not action or not action.cb or not action.cb.spellID 
                        or action.background or action.raw <= 0 or action.delay > t
                        or not IsSpellKnown( action.cb.replaces or action.cb.spellID ) then
                            list[ i ] = nil
                        end
                    end
                    
                    if not next( list ) then
                        return {}
                    end
                    
                    sort( list, function( l, r )
                        return l.d_cost > r.d_cost
                    end )

                    return list
                end
                
                actionlist = sortActionList( actionlist )
                
                local debug_out = {}
                local action_debug = true
                
                for k, v in pairs( actionlist ) do
                    if not v.raw or v.raw == 0 then
                        jeremy.rank[ v.name ] = 0
                    elseif v.base_cost and Player.primary_resource and v.base_cost > Player.primary_resource.current then
                        jeremy.rank[ v.name ] = 0
                    else
                        local action_name = gsub( v.combo_base and v.combo_base or v.name, "_cancel", "" )
                        jeremy.rank[ action_name ] = jeremy.rank[ action_name ] or k
                        jeremy.scale[ action_name ] = jeremy.scale[ action_name ] or v.d_cost
                        if action_debug and k <= 5 then
                            debug_out[ k ] = {
                                name = v.name,
                                dpet = v.d_time,
                                raw = v.raw,
                                cost = v.cost,
                                s_cost = v.secondary_cost,
                                execute_time = v.execute_time,
                                delay = v.delay,
                            }
                        end
                    end
                end
                if next( debug_out ) ~= nil then
                    ScanEvents( "JEREMY_DEBUG_PRIORITY", debug_out )
                end
                
                local rank_cpu_time = debugprofilestop()
                local actions_current = n
                local rank_cpu_avg  = rank_cpu_time / actions_current
                
                if aura_env.rank_cpu_average then
                    aura_env.rank_cpu_average = ( aura_env.rank_cpu_average + rank_cpu_avg ) / 2
                else
                    aura_env.rank_cpu_average = rank_cpu_avg
                end
                
                if rank_cpu_time > 0 and profiler_enabled then
                    aura_env.profiler_out[ "Rank Candidate Actions" ] = rank_cpu_time
                end   
                
            end
            -- -----------------------------------------------------------
            
            -- Ability options
            jeremy.boss_lockdown = aura_env.boss_lockdown
            jeremy.fight_remains = aura_env.fight_remains
            jeremy.target_ttd = aura_env.target_ttd
            
            if aura_env.target_count > 1 and targets_tod_range == 1 and aura_env.target_ttd <= 1 then
                jeremy.force_tod = true
            else
                jeremy.force_tod = false
            end
            
            local woo_buff = ( spec == aura_env.SPEC_INDEX[ "MONK_BREWMASTER" ] and Player.findAura( 387184 ) ) or nil
            if woo_buff and woo_buff.remaining <= ( 0.25 + Player.gcd_duration ) * ( 4 - aura_env.woo_best ) then
                jeremy.woo_prio = true
            else
                jeremy.woo_prio = false
            end
            
            -- end of ability options
            -- -------------------------------------------------------------
            
            -- Passed Configuration Options
            jeremy.options = {}
            jeremy.is_beta = Player.is_beta()
            jeremy.options.limit = aura_env.config.limit or 5
            jeremy.options.scaling = aura_env.config.scaling_option or 1
            jeremy.options.inverse = ( aura_env.config.inverse == 2 ) or false
            jeremy.options.hold_sef = aura_env.config.hold_sef or 1
            
            aura_env.jeremy_update = jeremy
            ScanEvents( "JEREMY_UPDATE", jeremy )
            
            return true
            
        end
        
        return false
    end
    
    if event == "ENCOUNTER_START" then
        aura_env.encounter_id = tostring( ... )
        return false
    elseif event == "ENCOUNTER_END" then
        aura_env.encounter_id = nil
        return false
    end
    
    if event == "JEREMY_STARTBAR" or event == "RELOE_SPELLCD_STATE_UPDATE" then
        
        local nameplate_settings, srcGUID, key, time = ...
        
        if not key 
        or not time then
            return false
        end
        
        key = tostring( key )
        
        local config = aura_env.bw_config[ key ] 
        
        if config and config.enabled then
            local expirationTime = frameTime + time + ( config.offset or 0 )
            local config_type = config.type or "ERROR"
            
            local t_key = (srcGUID or "SB").."-"..key
            
            if config_type == "ADD_SPAWN" then
                aura_env.BW_add_timers[ t_key ] = {
                    key = key,
                    expire = expirationTime,
                    count = config.count or 0,
                    encounterId = aura_env.encounter_id or -1,
                    srcGUID = srcGUID,
                    type = config_type,
                }
            elseif config_type == "INTERMISSION" then
                aura_env.BW_intermission_timers[ t_key ] =  {
                    key = key,
                    expire = expirationTime,
                    unitid = config.unitid or "boss1",
                    encounterId = aura_env.encounter_id or -1,
                    srcGUID = srcGUID,                        
                    type = config_type,
                }           
            elseif config_type == "TANKBUSTER" then
                
                local affects = config.affects or 1
                if affects == 1 and Player.role == "TANK"
                or affects == 2 and Player.role ~= "TANK"
                or affects == 3 then
                    -- Send custom message to Raid Ability Timeline
                    if nameplate_settings then
                        local Enemy = aura_env.GetEnemy( srcGUID )
                        ScanEvents( "JEREMY_TIMELINE_UPDATE", nameplate_settings, srcGUID, key, time, Enemy.marker )
                    end
                    
                    aura_env.BW_buster_timers [ t_key ] = {
                        key = key,
                        expire = expirationTime,
                        damage_type = config.damage_type or 1,
                        encounterId = aura_env.encounter_id or -1,
                        srcGUID = srcGUID,
                        type = config_type,
                    }
                end
            end
        end
        
        return false
    end
    
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local  _, _, spellID = ...
        
        if spellID == 137639 then
            aura_env.sef_fixate = nil
        elseif spellID == 221771 then
            local dstGUID = UnitGUID( "target" )
            
            aura_env.sef_fixate = dstGUID
            aura_env.last_fixate_bonus = aura_env.forwardModifier( aura_env.spells["tiger_palm"], 1 )
        end
        
        if spellID and aura_env.combo_strike[spellID] then
            if Player.last_combo_strike ~= spellID then
                Player.last_combo_strike = spellID
                aura_env.fast = true
            end          
        end
        
        return false
    end
    
    if event == "COMBAT_RATING_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        aura_env.initGear()
    end
    
    if event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
        aura_env.initSpecialization()
    end
    
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        aura_env.updateDB()

        if Player.getBuff("dual_threat") then
            Player.getBuff("dual_threat"):expire()
        end
        
        Combat = {
            avg_level = 0,
            damage_by_level = 0,
            damage_taken = 0,
            damage_taken_avoidable = 0,
            damage_taken_unavoidable = 0,
            recent_damage = {},
        }
        
        aura_env.CURRENT_MARKERS = {}
    end
    
    -- Everything below returns false
    -- ------------------------------
    
    if event == "UNIT_HEALTH" or event == "UNIT_ABSORB_AMOUNT_CHANGED" then
        local unitID = ...
        local unitGUID = UnitGUID( unitID )
        
        if aura_env.validTarget( unitID ) then
            
            local Enemy = aura_env.GetEnemy( unitGUID )
            
            Enemy.healthActual  = UnitHealth( unitID ) 
            - ( ( aura_env.earlyDeath[ Enemy.npcid ] or 0 ) * UnitHealthMax( unitID ) ) 
            + UnitGetTotalAbsorbs( unitID )
            
            Enemy.healthPct     = min( 1, Enemy.healthActual / UnitHealthMax( unitID ) )
            
            if Enemy.lastHealth and Enemy.lastSeen then
                
                local difference = Enemy.lastHealth - Enemy.healthPct
                
                if difference > 0 then
                    local elapsed = frameTime - Enemy.lastSeen
                    
                    if not Enemy.n or Enemy.n == 0 then
                        Enemy.rate = difference / elapsed
                        Enemy.n = 1
                    else
                        local samples = min( Enemy.n, 9 )
                        local newRate = Enemy.rate * samples + ( difference / elapsed )
                        Enemy.n = samples + 1
                        Enemy.rate = newRate / Enemy.n
                    end
                end
            end
            
            Enemy.lastHealth = Enemy.healthPct
            Enemy.lastSeen = frameTime 
            
            if Enemy.rate then
                
                Enemy.ttd = Enemy.healthPct / Enemy.rate
                Enemy.dtps = Enemy.healthActual / Enemy.ttd
                
                if Enemy.intermission then
                    Enemy.ttd = min( Enemy.ttd, Enemy.intermission )    
                end
                
                if unitGUID == UnitGUID( "target" ) then
                    aura_env.target_ttd = max( 1, floor( Enemy.ttd + 0.5 ) )
                    aura_env.taret_abs = UnitGetTotalAbsorbs( unitID ) or 0
                end
            end
        end
        
        return false
    end
    
    if event == "NAME_PLATE_UNIT_ADDED"  or event == "NAME_PLATE_UNIT_UPDATED" or event == "UPDATE_MOUSEOVER_UNIT" then
        
        local unitID, unitGUID
        
        if event == "UPDATE_MOUSEOVER_UNIT" then
            
            -- Only use this event if there is no nameplate available
            -- and there is a valid mouseover
            unitID   = "mouseover"    
            unitGUID = UnitGUID( "mouseover" )
            
            if GetNamePlateForUnit( "mouseover" ) then
                return
            end
        else
            unitID = ...
            unitGUID = ( unitID and UnitGUID( unitID ) ) or nil
        end
        
        if not unitGUID then
            return
        end
        
        if UnitExists( unitID ) then
            
            local Enemy = aura_env.GetEnemy( unitGUID )
            
            if not Enemy.isBoss then
                if unitGUID == UnitGUID( "boss1" ) 
                or unitGUID == UnitGUID( "boss2" )
                or unitGUID == UnitGUID( "boss3" ) 
                or unitGUID == UnitGUID( "boss4" ) 
                or unitGUID == UnitGUID( "boss5" ) then
                    Enemy.isBoss = true
                end
            end
            
            local oldMarker = Enemy.marker
            
            Enemy.marker    = GetRaidTargetIndex( unitID )
            Enemy.level     = UnitLevel( unitID )
            Enemy.priority_modifier = aura_env.npc_priority[ Enemy.npcid ] or 1.0
            
            local am_level = aura_env.config.automarker_enable 
            local am_enable = am_level == 2 
            or ( am_level == 3 and Player.role == "TANK" ) 
            or ( am_level == 4 and Player.leader )
            
            if aura_env.AUTOMARKER and am_enable then
                local value = aura_env.AUTOMARKER[ UnitName( unitID ) ] or aura_env.AUTOMARKER[ Enemy.npcid ]
                
                if value then
                    local mark = find( value, "MARK" ) ~= nil
                    Enemy.interruptTarget = find( value, "INTERRUPT" ) ~= nil
                    Enemy.stunTarget = find( value, "STUN" ) ~= nil
                    
                    local l, h = 1, 6
                    if find( value, "KILL" ) then
                        l, h = 7, 8
                    end
                    
                    if Enemy.marker then
                        aura_env.CURRENT_MARKERS[ Enemy.marker ] = unitGUID
                    elseif mark == true then
                        
                        local marks_available = false
                        
                        for m = h, l, -1 do
                            if aura_env.CURRENT_MARKERS[ m ] == nil then
                                marks_available = true
                                break
                            end
                        end
                        
                        for m = h, l, -1 do
                            
                            -- We need a mark, can we steal one?
                            if not marks_available and aura_env.CURRENT_MARKERS[ m ] then
                                local marked_enemy = aura_env.GetEnemy( aura_env.CURRENT_MARKERS[ m ]  )
                                -- Do not steal from enemy in combat
                                if not marked_enemy.inCombat then
                                    if Enemy.inCombat
                                    or Enemy.range < marked_enemy.range then
                                        aura_env.CURRENT_MARKERS[ m ] = nil
                                    end
                                end
                            end
                            
                            if aura_env.CURRENT_MARKERS[ m ] == nil
                            then
                                SetRaidTarget( unitID, m )
                                aura_env.CURRENT_MARKERS[ m ] = unitGUID
                                Enemy.marker = m
                                break
                            end
                        end
                    end
                end
            end
            
            if Enemy.marker ~= oldMarker then
                ScanEvents( "JEREMY_MARKER_CHANGED", unitGUID, Enemy.marker )
            end
        end
        
        return false
    end
    
    if event == "UNIT_AURA" or event == "UNIT_AURA_FULL_UPDATE" then
        local unitID, updateInfo = ...
        local unitGUID = UnitGUID( unitID )
        
        if unitID == "player" or aura_env.validTarget( unitID ) then
            
            local Unit = ( unitID == "player" and Player ) or aura_env.GetEnemy( unitGUID )
            
            local parseAuraData = function( auraData )
                auraData.name = gsub( lower( auraData.name ), "%s+", "_" )
                auraData.stacks = auraData.applications or 0
                auraData.duration = auraData.duration or 0
                return auraData
            end
            
            if event == "UNIT_AURA_FULL_UPDATE" then
                if not Unit.lastFullUpdate or Unit.lastFullUpdate < frameTime - aura_env.update_rate then
                    Unit.auraExclusions = {}
                    Unit.auraDataByInstance = {}
                    Unit.auraInstancesByID = {}
                    
                    -- Monk Diffuse Magic
                    if Unit == Player then
                        Unit.diffuse_auras = {}
                        Unit.diffuse_reflects = {}
                    else
                        Unit.stealable_auras = {}
                    end
                    
                    local auraSlots = { UnitAuraSlots( unitID, "HELPFUL|HARMFUL" ) }
                    for slot in pairs( auraSlots ) do
                        local auraData = GetAuraDataBySlot( unitID, slot )
                        if auraData then
                            
                            local instanceID = auraData.auraInstanceID
                            local spellId = auraData.spellId
                            
                            if aura_env.auraExclusions[ spellId ] then
                                Unit.auraExclusions[ instanceID  ] = spellId
                            end
                            
                            -- Monk Diffuse Magic
                            if Unit == Player then
                                local valid_diffuse = aura_env.diffuse_options[ spellId ]
                                if valid_diffuse and valid_diffuse.enabled then
                                    Unit.diffuse_auras[ instanceID  ] = true
                                    if valid_diffuse.reflect then
                                        Unit.diffuse_reflects[ instanceID  ] = true
                                    end
                                end
                            else
                                if auraData.isStealable then
                                    Unit.stealable_auras[ instanceID ] = true
                                end
                            end
                            
                            Unit.auraInstancesByID[ spellId ] = Unit.auraInstancesByID[ spellId ] or {}
                            Unit.auraInstancesByID[ spellId ][ instanceID ] = true 
                            Unit.auraDataByInstance[ instanceID  ] = parseAuraData( auraData )
                        end
                    end
                    Unit.needsFullUpdate = false
                    Unit.lastFullUpdate = frameTime
                end
            else    
                if updateInfo.isFullUpdate then
                    Unit.needsFullUpdate = true
                else
                    if updateInfo.addedAuras then
                        for _, auraData in pairs( updateInfo.addedAuras ) do
                            
                            local instanceID = auraData.auraInstanceID
                            local spellId = auraData.spellId   
                            
                            if aura_env.auraExclusions[ spellId ] then 
                                Unit.auraExclusions[ instanceID ] = spellId
                            end
                            
                            -- Monk Diffuse Magic
                            if Unit == Player then
                                local valid_diffuse = aura_env.diffuse_options[ spellId ]
                                if valid_diffuse and valid_diffuse.enabled then
                                    Unit.diffuse_auras[ instanceID ] = true
                                    if valid_diffuse.reflect then
                                        Unit.diffuse_reflects[ instanceID ] = true
                                    end
                                end
                            else
                                if auraData.isStealable then
                                    Unit.stealable_auras[ instanceID ] = true
                                end
                            end                          
                            
                            Unit.auraInstancesByID[ spellId ] = Unit.auraInstancesByID[ spellId ] or {}
                            Unit.auraInstancesByID[ spellId ][ instanceID ] = true 
                            Unit.auraDataByInstance[ instanceID ] = parseAuraData( auraData )
                        end
                    end
                    
                    if updateInfo.updatedAuraInstanceIDs then
                        for _, instanceID in pairs( updateInfo.updatedAuraInstanceIDs ) do
                            local auraData = GetAuraDataByAuraInstanceID( unitID, instanceID )
                            if auraData then
                                
                                auraData.name = gsub( lower( auraData.name ), "%s+", "_" )
                                auraData.stacks = auraData.applications or 0
                                
                                local spellId = auraData.spellId   
                                
                                Unit.auraInstancesByID[ spellId ] = Unit.auraInstancesByID[ spellId ] or {}
                                Unit.auraInstancesByID[ spellId ][ instanceID ] = true 
                                Unit.auraDataByInstance[ instanceID ] = parseAuraData( auraData )  
                            end
                        end
                    end
                    
                    if updateInfo.removedAuraInstanceIDs then
                        for _, instanceID in pairs( updateInfo.removedAuraInstanceIDs ) do
                            
                            Unit.auraExclusions[ instanceID ] = nil
                            
                            -- Monk Diffuse Magic
                            if Unit == Player then
                                Unit.diffuse_auras[ instanceID ] = nil
                                Unit.diffuse_reflects[ instanceID ] = nil
                            else
                                Unit.stealable_auras[ instanceID ] = nil
                            end
                            
                            if Unit.auraDataByInstance[ instanceID ] then
                                local spellId = Unit.auraDataByInstance[ instanceID ].spellId
                                Unit.auraInstancesByID[ spellId ][ instanceID ] = nil
                                Unit.auraDataByInstance[ instanceID ] = nil
                            end
                        end
                    end 
                end
            end
        end
        
        return false
    end
    
    if event == "UNIT_THREAT_LIST_UPDATE" or event == "NAME_PLATE_UNIT_REMOVED" then
        local unitID = ...
        local unitGUID = UnitGUID( unitID )
        
        if not unitGUID then
            return
        end
        
        if not UnitExists( unitID ) then
            aura_env.ResetEnemy( unitGUID )
        else
            local Enemy = aura_env.GetEnemy( unitGUID )
            
            if UnitAffectingCombat( unitID ) then
                Enemy.inCombat = true
            elseif Enemy.inCombat then
                local unitInCombat = false
                for it in WA_IterateGroupMembers() do
                    if UnitThreatSituation( it, unitID ) then
                        unitInCombat = true
                        break
                    end
                end
                
                if not unitInCombat then
                    aura_env.ResetEnemy( unitGUID )
                end
            end
            
            if Enemy.inCombat and not Enemy.combatStart then
                Enemy.combatStart = frameTime
            end
        end
        
        ScanEvents( "NAME_PLATE_UNIT_UPDATED", unitID )
        
        return false
    end
   
    --UNIT_DIED:UNIT_DESTROYED:UNIT_DISSIPATES:SPELL_DAMAGE:SPELL_PERIODIC_DAMAGE 
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        
        local LogDamage = function (_, eventtype, _, srcGUID, srcName, srcFlags, _, dstGUID, ...)
            
            if eventtype == nil 
            or eventtype == "ENVIRONMENTAL_DAMAGE" 
            or not find( eventtype, "_DAMAGE" ) then
                return false
            end
            
            local enemyGUID = nil
            
            if dstGUID == UnitGUID( "player" ) then
                enemyGUID = srcGUID
            else
                local mask = COMBATLOG_OBJECT_AFFILIATION_MASK
                local bitfield = bit_band( srcFlags, mask )
                
                if srcGUID == UnitGUID( "player" )
                or srcGUID == UnitGUID( "pet" )
                or bitfield == COMBATLOG_OBJECT_AFFILIATION_MINE then
                    enemyGUID = dstGUID
                end
            end
            
            if enemyGUID == nil then
                return false
            end
            
            local Enemy = aura_env.GetEnemy( enemyGUID )
            
            local spellID, spellSchool, amount
            
            if eventtype == "SWING_DAMAGE" then
                _, _, _, amount = ...
            else
                _, _, _, spellID, _, spellSchool, amount = ...
            end
            
            spellSchool = spellSchool or 1
            spellID = spellID or 0
            
            if amount == nil
            or type( amount ) ~= "number"
            or amount == 0 then 
                return false
            end
            
            if srcGUID == enemyGUID then
                if dstGUID == UnitGUID( "player" ) and Enemy.level > 0 then
                    
                    Combat.damage_by_level = Combat.damage_by_level + ( Enemy.level * amount )
                    Combat.damage_taken = Combat.damage_taken + amount
                    Combat.avg_level = Combat.damage_by_level / Combat.damage_taken;
                    Combat.recent_damage[ #Combat.recent_damage + 1 ] = {
                        amount = amount,
                        expire = frameTime + aura_env.RECENT_DURATION
                    }
                    
                    if spellSchool == 1 and not find( eventtype, "PERIODIC" ) then
                        Combat.damage_taken_avoidable = Combat.damage_taken_avoidable + amount
                    else
                        Combat.damage_taken_unavoidable = Combat.damage_taken_unavoidable + amount
                    end              
                end
            else
                -- Not pet damage
                if srcGUID == UnitGUID( "player" ) then

                    -- Gale Force
                    if spellID == 395519 or spellID == 395521 then
                        Enemy.gale_force_debuff = GetTime() + 10
                    end

                    -- spell tracking ... 
                    if spellID and aura_env.pull_hash ~= "" then
                        aura_env.coneTickListener( spellID, enemyGUID )
                    end
                end
            end
        end

        local LogDeath = function (_, eventtype, _, srcGUID, _, _, _, dstGUID, ...)
            if eventtype == "UNIT_DIED" or eventtype == "UNIT_DESTROYED" or eventtype == "UNIT_DISSIPATES" then
                aura_env.ResetEnemy( dstGUID, true )
            end
        end
        
        if InCombatLockdown() then
            LogDamage( CombatLogGetCurrentEventInfo() )
            LogDeath( CombatLogGetCurrentEventInfo() )
        end

        local eventtype, _, _, srcGUID, _, _, _, dstGUID, _, _, _, spellID, _, _, amount = CombatLogGetCurrentEventInfo()

        if srcGUID == UnitGUID("player") then
            if eventtype == "SPELL_AURA_APPLIED" and spellID == 451580 then
                local unitID = dstGUID:match("-(%d+)-%x+$")
                if not aura_env.targetAuras[unitID] then
                    aura_env.targetAuras[unitID] = {}
                end
                aura_env.targetAuras[unitID][spellID] = {
                    amp = 1.10,
                    expire = GetTime() + 3600
                }
            elseif eventtype == "SPELL_AURA_REMOVED" and spellID == 451580 then
                local unitID = dstGUID:match("-(%d+)-%x+$")
                if aura_env.targetAuras[unitID] and aura_env.targetAuras[unitID][spellID] then
                    aura_env.targetAuras[unitID][spellID] = nil
                end
            end
        end
        
        return false
        
    end   
    
    return false
end

