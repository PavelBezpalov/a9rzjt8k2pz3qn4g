-- Mistweaver Monk by Nikopol
-- Left Shift - Spinning Crane Kick
-- Left Control - Revival
-- Left Alt - Essence Font
local bxhnz7tp5bge7wvu = bxhnz7tp5bge7wvu_interface
local IT = items
local SB = m2jue4dgc56acfzz
bxhnz7tp5bge7wvu.environment.virtual.exclude_tanks = false

local soothed_unit
local lowest_unit
local tank_unit
local chi_burst_up = false

local function healable(unit)
  return not unit.debuff(329298).any -- Gluttonous Miasma at Hungering Destroyer
end

local function in_same_phase(unit)
  return UnitInPartyShard(unit.unitID)
end

local function healable_lowest_unit()
  local lowest_unit_id
  local lowest_health
  local healable_lowest_unit
  for unit in bxhnz7tp5bge7wvu.environment.iterator() do
    if unit.alive and UnitInRange(unit.unitID) and in_same_phase(unit) and healable(unit) then
      if not healable_lowest_unit then
        healable_lowest_unit = unit
      else
        lowest_unit_id, lowest_health = bxhnz7tp5bge7wvu.environment.virtual.resolvers.unit(unit.unitID, healable_lowest_unit.unitID)
        if lowest_unit_id == unit.unitID then
          healable_lowest_unit = unit
        end
      end
    end
  end
  return healable_lowest_unit
end

local function healable_lowest_tank()
  local lowest_unit_id
  local lowest_health
  local healable_lowest_tank
  for unit in bxhnz7tp5bge7wvu.environment.iterator() do
    if unit.alive and UnitInRange(unit.unitID) and in_same_phase(unit) and healable(unit) and UnitGroupRolesAssigned(unit.unitID) == 'TANK' then
      if not healable_lowest_tank then
        healable_lowest_tank = unit
      else
        lowest_unit_id, lowest_health = bxhnz7tp5bge7wvu.environment.virtual.resolvers.unit(unit.unitID, healable_lowest_tank.unitID)
        if lowest_unit_id == unit.unitID then
          healable_lowest_tank = unit
        end
      end
    end
  end
  return healable_lowest_tank
end

local function chi_burst_overlay()
  local usable, noMana = IsUsableSpell(SB.ChiBurst)
  local start, duration = GetSpellCooldown(SB.ChiBurst)
  local startGCD, durationGCD = GetSpellCooldown(61304)
  chi_burst_up = usable and (start == 0 or start == startGCD and duration == durationGCD) and UnitAffectingCombat("player")
  if chi_burst_up then
    SpellActivationOverlay_ShowOverlay(SpellActivationOverlayFrame, SB.ChiBurst, 592058, "RIGHT", 1, 255, 255, 255, false, true)
  else
    SpellActivationOverlay_HideOverlays(SpellActivationOverlayFrame, SB.ChiBurst)
  end
end


local function gcd()
  if not player.alive then return end
  
  local vivify = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_vivify', 70)
  lowest_unit = healable_lowest_unit()
  tank_unit = healable_lowest_tank()
  
  if player.channeling(SB.SoothingMist) then
    soothed_unit = group.match(function (unit)
      return unit.alive and unit.buff(SB.SoothingMist).up
    end)
  else
    soothed_unit = nil
  end

  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end

  if player.channeling(SB.SoothingMist) and soothed_unit and soothed_unit.health.effective > vivify + 5 then
    stopcast()
    soothed_unit = nil
  end

  if not modifier.rshift and player.channeling(SB.SpinningCrane) then
    stopcast()
  end

  if castable(SB.ThunderFocus)
  and (
    (talent(7, 3) 
      and player.combat 
      and target.castable(SB.RisingSunKick) 
      and spell(SB.EssenceFont).cooldown > 0 and spell(SB.EssenceFont).cooldown < 9 
      and (not talent(3, 2) or (talent(3, 2) and buff(SB.TeachingsoftheMonastery).count < 2)))
    or (player.channeling(SB.SoothingMist) and soothed_unit and soothed_unit.health.effective < vivify)
    ) then
    cast(SB.ThunderFocus)
  end

  if toggle('cooldowns', false) then
    if player.health.effective <= 30 
    and castable(SB.LifeCocoon) then
      cast(SB.LifeCocoon, player)
    end

    if lowest_unit 
    and lowest_unit.health.effective <= 30 
    and lowest_unit.castable(SB.LifeCocoon) then
      cast(SB.LifeCocoon, lowest_unit)
    end
  end
end

local function combat()
  if not player.alive then return end
  
  local envelope_mist = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_envelope_mist', 50)
  local vivify = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_vivify', 70)
  local essence_font = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_essence_font', 70)
  local refreshing_jade_wind = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_refreshing_jade_wind', 90)
  local rising_sun_kick = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_rising_sun_kick', false)
  local crackling_jade_lightning = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_crackling_jade_lightning', false)
  local touch_of_death = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_touch_of_death', false)
  local instant_vivify = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_instant_vivify', false)
  local soothing_mist = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_soothing_mist', false)
  local heal_target_to_full = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_heal_target_to_full', false)
  local mystic_touch = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_mystic_touch', false)

  lowest_unit = healable_lowest_unit()
  tank_unit = healable_lowest_tank()
  
  chi_burst_overlay()
  
  macro('/cqs')
  
  if heal_target_to_full and target and target.alive and target.friend and target.health.effective < 100 then
    if target.castable(SB.RenewingMist) 
    and target.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.RenewingMist, target)
    end
    
    if not player.moving then
      if not player.channeling(SB.SoothingMist) and target.buff(SB.SoothingMist).down and target.castable(SB.SoothingMist) then
        return cast(SB.SoothingMist, target)
      else
        if target.castable(SB.EnvelopeMist) 
        and target.buff(SB.EnvelopeMist).down then
          return cast(SB.EnvelopeMist, target)
        end
        
        if target.castable(SB.Vivify) then
          return cast(SB.Vivify, target)
        end
      end
    end
  end
  
  if player.channeling(SB.SoothingMist) then
    soothed_unit = group.match(function (unit)
      return unit.alive and unit.buff(SB.SoothingMist).up
    end)
  else
    soothed_unit = nil
  end

  local function use_items()
    if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
      macro('/use Healthstone')
    end
  
    if lowest_unit 
      and lowest_unit.health.effective <= 35 then
      local start, duration, enable = GetInventoryItemCooldown("player", 13)
      local trinket_id = GetInventoryItemID("player", 13)
      if enable == 1 and start == 0 and trinket_id == IT.ManaboundMirrorId and IsItemInRange(IT.ManaboundMirrorId, lowest_unit.unitID) then
        macro("/use [target=" .. lowest_unit.unitID .. "] 13")
      end
      
      start, duration, enable = GetInventoryItemCooldown("player", 14)
      trinket_id = GetInventoryItemID("player", 14)
      if enable == 1 and start == 0 and trinket_id == IT.ManaboundMirrorId and IsItemInRange(IT.ManaboundMirrorId, lowest_unit.unitID) then
        macro("/use [target=" .. lowest_unit.unitID .. "] 14")
      end
    end
  end

  use_items()

  --if player.channeling(SB.SoothingMist) and soothed_unit and soothed_unit.health.effective > vivify + 5 then
  --  stopcast()
  --  soothed_unit = nil
  --end

  if not modifier.rshift and player.channeling(SB.SpinningCrane) then
    stopcast()
  end
  
  if player.spell(SB.Vivify).current and lastcasted_target.health.percent > vivify then
    stopcast()
  end
  
  if player.channeling(SB.SoothingMist) and soothed_unit and soothed_unit.health.percent > vivify and not soothing_mist then
    stopcast()
    soothed_unit = nil
  end
  
  if toggle('cooldowns', false) then
    if player.health.effective <= 20 
    and castable(SB.LifeCocoon) 
    and healable(player) then
      cast(SB.LifeCocoon, player)
    end

    if lowest_unit 
    and lowest_unit.health.effective <= 20 
    and lowest_unit.castable(SB.LifeCocoon) then
      cast(SB.LifeCocoon, lowest_unit)
    end
  end

  if modifier.lalt and castable(SB.EssenceFont) then
    return cast(SB.EssenceFont)
  end

  if modifier.lcontrol and castable(SB.Revival) then
    return cast(SB.Revival)
  end

  if player.channeling(SB.EssenceFont) then return end
  
  if modifier.rshift and castable(SB.SpinningCrane) then
    return cast(SB.SpinningCrane)
  end
  
  if modifier.lshift and castable(SB.ChiBurst) then
    return cast(SB.ChiBurst)
  end
  
  if castable(SB.EssenceFont) and group.under(essence_font, 30, true) >= 5 then
    if toggle('cooldowns', false) and castable(SB.Berserking) then
      cast(SB.Berserking)
    end
    return cast(SB.EssenceFont)
  end

  if castable(SB.RefreshingJadeWind) and group.under(refreshing_jade_wind, 10, true) >= 5 and player.buff(SB.RefreshingJadeWind).down then
    return cast(SB.RefreshingJadeWind)
  end
  
  local rising_mist_check = group.match(function (unit)
    return unit.alive and (unit.buff(SB.RenewingMist).up or unit.buff(SB.EnvelopeMist).up or unit.buff(SB.EssenceFont).up) 
  end)

  if talent(7, 3) 
  and target.castable(SB.RisingSunKick) 
  and rising_mist_check then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RisingSunKick, target)
  end
  
  local function soothe_for_envelope_mist()
    if player.health.effective < envelope_mist and castable(SB.EnvelopeMist) and player.buff(SB.EnvelopeMist).down and healable(player) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, player)
    end

    if tank_unit and tank_unit.health.effective < envelope_mist and tank_unit.castable(SB.EnvelopeMist) and tank_unit.buff(SB.EnvelopeMist).down then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, tank_unit)
    end

    if lowest_unit and lowest_unit.health.effective < envelope_mist and lowest_unit.castable(SB.EnvelopeMist) and lowest_unit.buff(SB.EnvelopeMist).down then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, lowest_unit)
    end
  end
  
  local function soothe_for_vivify()
    if player.health.effective < vivify and castable(SB.Vivify) and healable(player) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, player)
    end

    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, tank_unit)
    end

    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, lowest_unit)
    end
  end
  
  local function vivify_on_soothe()
    if castable(SB.ExpelHarm) 
    and soothed_unit.health.effective < vivify 
    and player.health.effective < vivify and healable(player) then
      return cast(SB.ExpelHarm)
    end
    if soothed_unit.castable(SB.Vivify) 
    and soothed_unit.health.effective < vivify then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, soothed_unit)
    end
  end
  
  if player.channeling(SB.SoothingMist) and soothed_unit then
    if soothed_unit.castable(SB.EnvelopeMist) 
    and soothed_unit.buff(SB.EnvelopeMist).down 
    and soothed_unit.health.effective < envelope_mist then
      return cast(SB.EnvelopeMist, soothed_unit)
    end

    soothe_for_envelope_mist()
  end
  
  if not player.moving and not player.channeling(SB.SoothingMist) then
    soothe_for_envelope_mist()
  end
  
    if player.channeling(SB.SoothingMist) and soothed_unit then
    vivify_on_soothe()
  end
  
  if instant_vivify and player.channeling(SB.SoothingMist) and soothed_unit then
    soothe_for_vivify()
  end
  
  if instant_vivify and not player.moving and not player.channeling(SB.SoothingMist) then
    soothe_for_vivify()
  end
  
  if not player.moving and not instant_vivify then
    if player.health.effective < vivify and castable(SB.Vivify) and player.buff(SB.RenewingMist).down and healable(player) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, player)
    end
    
    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) and player.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, tank_unit)
    end
    
    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) and lowest_unit.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, lowest_unit)
    end
    
    if player.health.effective < vivify and castable(SB.Vivify) and healable(player) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, player)
    end
    
    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, tank_unit)
    end
    
    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, lowest_unit)
    end
  end
  
  if toggle('dispell', false) then
    --local debuff, count, duration, expires, caster = UnitDebuff(tank.unitID, 288388, 'any')
    --if debuff then
    --  if count >= 10 and tank.castable(SB.DetoxDPS) then
    --    return cast(SB.DetoxDPS, tank)
    --  else
    --    return
    --  end
    --end
    
    if castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
      return cast(SB.DetoxDPS, player)
    end

    local unit = group.dispellable(SB.DetoxDPS)
    if unit and unit.castable(SB.DetoxDPS) then
      return cast(SB.DetoxDPS, unit)
    end
  end

  if castable(SB.RenewingMist) 
  and player.buff(SB.RenewingMist).down and healable(player) then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RenewingMist, player)
  end

  if lowest_unit and lowest_unit.castable(SB.RenewingMist) 
  and lowest_unit.buff(SB.RenewingMist).down then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RenewingMist, lowest_unit)
  end
 
  local ally_without_renewing_mist = group.match(function (unit)
    return unit.alive and unit.castable(SB.RenewingMist) and unit.buff(SB.RenewingMist).down and healable(unit)
  end)

  if ally_without_renewing_mist then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RenewingMist, ally_without_renewing_mist)
  end
  
  if target.enemy and target.alive then
    auto_attack()

    if toggle('interrupts', false) and target.interrupt(70) then
      if castable(SB.LegSweep) and target.distance <= 7 then
        return cast(SB.LegSweep)
      end

      if spell(SB.LegSweep).cooldown > 0 and target.castable(SB.Paralysis) then
        return cast(SB.Paralysis, target)
      end
    end
    
    if touch_of_death and castable(SB.TouchofDeath) then
      return cast(SB.TouchofDeath, target)
    end

    if rising_sun_kick and target.castable(SB.RisingSunKick) then
      return cast(SB.RisingSunKick, target)
    end	

    if target.castable(SB.BlackoutKick) and buff(SB.TeachingsoftheMonastery).count == 3 and spell(SB.RisingSunKick).cooldown > 3 then
      return cast(SB.BlackoutKick, target)
    end

    if castable(SB.ChiWave) then
      return cast(SB.ChiWave)
    end
    
    local nearest_target_without_mythic_touch = enemies.match(function (unit)
      return unit.alive and unit.combat and unit.distance <= 8 and not unit.debuff(SB.MysticTouch).any
    end)
    
    if mystic_touch and nearest_target_without_mythic_touch and castable(SB.SpinningCrane) then
      return cast(SB.SpinningCrane)
    end

    if target.castable(SB.TigerPalm) then
      return cast(SB.TigerPalm, target)
    end
    
    if crackling_jade_lightning and not player.moving and target.combat and target.castable(SB.CracklingJade) and not player.channeling(SB.CracklingJade) then
      return cast(SB.CracklingJade, target)
    end
  end
  
  if not player.moving and not player.channeling(SB.SoothingMist) and soothing_mist then
    if tank_unit and tank_unit.castable(SB.SoothingMist) then
      return cast(SB.SoothingMist, tank_unit)
    end
  end
end

local function resting()
  if not player.alive then return end
  
  local envelope_mist = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_envelope_mist', 50)
  local vivify = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_vivify', 70)
  local essence_font = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_essence_font', 70)
  local refreshing_jade_wind = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_refreshing_jade_wind', 90)
  local instant_vivify = bxhnz7tp5bge7wvu.settings.fetch('mw_nikopol_instant_vivify', false)
  lowest_unit = healable_lowest_unit()
  tank_unit = healable_lowest_tank()
  
  if player.channeling(SB.SoothingMist) then
    soothed_unit = group.match(function (unit)
      return unit.alive and unit.buff(SB.SoothingMist).up
    end)
  else
    soothed_unit = nil
  end
  
  chi_burst_overlay()
  
  macro('/cqs')
  
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end

  if player.channeling(SB.SoothingMist) and soothed_unit and soothed_unit.health.effective > vivify + 5 then
    stopcast()
    soothed_unit = nil
  end

  if modifier.lalt and castable(SB.EssenceFont) then
    return cast(SB.EssenceFont)
  end

  if player.channeling(SB.EssenceFont) then return end
  
  local function soothe_for_envelope_mist()
    if player.health.effective < envelope_mist and castable(SB.EnvelopeMist) and player.buff(SB.EnvelopeMist).down then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, player)
    end

    if tank_unit and tank_unit.health.effective < envelope_mist and tank_unit.castable(SB.EnvelopeMist) and tank_unit.buff(SB.EnvelopeMist).down then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, tank_unit)
    end

    if lowest_unit and lowest_unit.health.effective < envelope_mist and lowest_unit.castable(SB.EnvelopeMist) and lowest_unit.buff(SB.EnvelopeMist).down then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, lowest_unit)
    end
  end
  
  local function soothe_for_vivify()
    if player.health.effective < vivify and castable(SB.Vivify) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, player)
    end

    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, tank_unit)
    end

    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) then
      if toggle('cooldowns', false) and castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      return cast(SB.SoothingMist, lowest_unit)
    end
  end
  
  local function vivify_on_soothe()
    if castable(SB.ExpelHarm) 
    and soothed_unit.health.effective < vivify 
    and player.health.effective < vivify then
      return cast(SB.ExpelHarm)
    end
    if soothed_unit.castable(SB.Vivify) 
    and soothed_unit.health.effective < vivify then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, soothed_unit)
    end
  end
  
  if player.channeling(SB.SoothingMist) and soothed_unit then
    if soothed_unit.castable(SB.EnvelopeMist) 
    and soothed_unit.buff(SB.EnvelopeMist).down 
    and soothed_unit.health.effective < envelope_mist then
      return cast(SB.EnvelopeMist, soothed_unit)
    end

    soothe_for_envelope_mist()
  end
  
  if not player.moving and not player.channeling(SB.SoothingMist) then
    soothe_for_envelope_mist()
  end
  
  if player.channeling(SB.SoothingMist) and soothed_unit then
    vivify_on_soothe()
  end
  
  if instant_vivify and player.channeling(SB.SoothingMist) and soothed_unit then
    soothe_for_vivify()
  end
  
  if instant_vivify and not player.moving and not player.channeling(SB.SoothingMist) then
    soothe_for_vivify()
  end
  
  if not player.moving and not instant_vivify then
    if player.health.effective < vivify and castable(SB.Vivify) and player.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, player)
    end
    
    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) and player.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, tank_unit)
    end
    
    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) and lowest_unit.buff(SB.RenewingMist).down then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, lowest_unit)
    end
    
    if player.health.effective < vivify and castable(SB.Vivify) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, player)
    end
    
    if tank_unit and tank_unit.health.effective < vivify and tank_unit.castable(SB.Vivify) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, tank_unit)
    end
    
    if lowest_unit and lowest_unit.health.effective < vivify and lowest_unit.castable(SB.Vivify) then
      if castable(SB.ThunderFocus) then
        cast(SB.ThunderFocus)
      end
      return cast(SB.Vivify, lowest_unit)
    end
  end
  
  if toggle('dispell', false) then
    --local debuff, count, duration, expires, caster = UnitDebuff(tank.unitID, 288388, 'any')
    --if debuff then
    --  if count >= 10 and tank.castable(SB.DetoxDPS) then
    --    return cast(SB.DetoxDPS, tank)
    --  else
    --    return
    --  end
    --end
    
    if castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
      return cast(SB.DetoxDPS, player)
    end

    local unit = group.dispellable(SB.DetoxDPS)
    if unit and unit.castable(SB.DetoxDPS) then
      return cast(SB.DetoxDPS, unit)
    end
  end

  if castable(SB.RenewingMist) 
  and player.buff(SB.RenewingMist).down then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RenewingMist, player)
  end

  if lowest_unit and lowest_unit.castable(SB.RenewingMist) 
  and lowest_unit.buff(SB.RenewingMist).down then
    if castable(SB.ThunderFocus) then
      cast(SB.ThunderFocus)
    end
    return cast(SB.RenewingMist, lowest_unit)
  end

  if castable(SB.EssenceFont) and group.under(essence_font, 30, true) >= 5 then
    if toggle('cooldowns', false) and castable(SB.Berserking) then
      cast(SB.Berserking)
    end
    return cast(SB.EssenceFont)
  end

  if castable(SB.RefreshingJadeWind) and group.under(refreshing_jade_wind, 10, true) >= 5 and player.buff(SB.RefreshingJadeWind).down then
    return cast(SB.RefreshingJadeWind)
  end

  local ally_without_renewing_mist = group.match(function (unit)
    return unit.alive and unit.castable(SB.RenewingMist) and unit.buff(SB.RenewingMist).down
  end)

  if ally_without_renewing_mist then
    return cast(SB.RenewingMist, ally_without_renewing_mist)
  end
end

function interface()
  local mw_gui = {
    key = 'mw_nikopol',
    title = 'Mistweaver by Nikopol',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Mistweaver Settings' },
      { type = 'rule' },   
      { type = 'text', text = 'Healing Settings' },
      { key = 'envelope_mist', type = 'spinner', text = 'Envelope Mist', desc = 'Cast Envelope Mist on target below % health.', min = 30, max = 80, step = 5, default = 35 },
      { key = 'vivify', type = 'spinner', text = 'Vivify', desc = 'Cast Vivify on target below % health', min = 50, max = 90, step = 5, default = 70 },
      { key = 'essence_font', type = 'spinner', text = 'Essence Font', desc = 'Cast Essence Font on targets below % health', min = 50, max = 95, step = 5, default = 80 },
      { key = 'refreshing_jade_wind', type = 'spinner', text = 'Refreshing Jade Wind', desc = 'Cast Refreshing Jade Wind on targets below % health', min = 90, max = 100, step = 1, default = 90 },
      { key = 'instant_vivify', type = 'checkbox', text = 'Instant Vivify', desc = 'Cast Vivify during Soothing Mist', default = false },
      { key = 'soothing_mist', type = 'checkbox', text = 'Soothing Mist', desc = 'Channgel Soothing Mist on tank', default = false },
      { key = 'heal_target_to_full', type = 'checkbox', text = 'Heal Target to Full', desc = 'Automatic target healing to full health.', default = false },
      { type = 'rule' },
      { type = 'text', text = 'DPS Settings' },
      { key = 'rising_sun_kick', type = 'checkbox', text = 'Rising Sun Kick', desc = 'Cast Rising Sun Kick on cd.', default = false },
      { key = 'crackling_jade_lightning', type = 'checkbox', text = 'Crackling Jade Lightning', desc = 'Cast Crackling Jade Lightning on target.', default = false },
      { key = 'touch_of_death', type = 'checkbox', text = 'Touch of Death', desc = 'Touch of Death on target.', default = false },
      { key = 'mystic_touch', type = 'checkbox', text = 'Mystic Touch', desc = 'Auto Mystic Touch with Spining Crane Kick', default = false },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(mw_gui)

  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'dispell',
    label = 'Auto Dispell',
    on = {
      label = 'DSP',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'dsp',
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    }
  })
  bxhnz7tp5bge7wvu.interface.buttons.add_toggle({
    name = 'settings',
    label = 'Rotation Settings',
    font = 'bxhnz7tp5bge7wvu_icon',
    on = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.cyan,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_cyan
    },
    off = {
      label = bxhnz7tp5bge7wvu.interface.icon('cog'),
      color = bxhnz7tp5bge7wvu.interface.color.grey,
      color2 = bxhnz7tp5bge7wvu.interface.color.dark_grey
    },
    callback = function(self)
      if configWindow.parent:IsShown() then
        configWindow.parent:Hide()
      else
        configWindow.parent:Show()
      end
    end
  })
end

bxhnz7tp5bge7wvu.rotation.register({
  spec = bxhnz7tp5bge7wvu.rotation.classes.monk.mistweaver,
  name = 'mw_nikopol',
  label = 'Mistweaver by Nikopol',
  gcd = gcd,
  combat = combat,
  resting = resting,
  interface = interface
})
