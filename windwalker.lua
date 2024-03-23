-- Windwalker Monk for 9.0.1 by Nikopol - 11/2020
-- Talents: 1 - 2 - - 3 2
-- Left Alt - Touch of Karma
-- Left Shift - Vivify self
local bxhnz7tp5bge7wvu = bxhnz7tp5bge7wvu_interface
local SB = m2jue4dgc56acfzz
local HL = HeroLib
local HeroUnit = HL.Unit
local HeroPlayer = HeroUnit.Player

local bloodlust_buffs = { 32182, 90355, 80353, 2825, 146555 }
local function has_bloodlust(unit)
  for i = 1, #bloodlust_buffs do
    if unit.buff(bloodlust_buffs[i]).up then return true end
  end
end

local function fight_remains(operator, value)
  return HL.BossFilteredFightRemains(operator, value)
end

local function combat_time()
  return HL.CombatTime()
end

local function haste_mod()
  local haste = UnitSpellHaste("player")
  return 1 + haste / 100
end

local function gcd_duration()
  return 1.5 / haste_mod()
end

local function fof_execute_time()
  local fof_channeling_time = 4 / haste_mod()
  return math.max(gcd_duration(), fof_channeling_time) 
end

local combo_strike_spells = {
  [SB.TigerPalm] = true,
  [SB.RisingSunKick] = true,
  [SB.BlackoutKick] = true,
  [SB.RushingJadeWind] = true,
  [SB.SpinningCrane] = true,
	[SB.FistofFury] = true,
  [SB.WhirlingDragonPunch] = true,
  [SB.FistoftheWhiteTiger] = true,
  [SB.TouchofDeath] = true,
  [SB.FlyingSerpentKick] = true,
	[SB.CracklingJade] = true,
	[SB.ExpelHarm] = true,
	[SB.ChiWave] = true,
	[SB.ChiBurst] = true
}

local function combo_strike(spell)
  local last_combo_spell = bxhnz7tp5bge7wvu.tmp.fetch('last_combo_spell', false)
  return last_combo_spell ~= spell
end

local function last_cast(spell)
  local last_cast_spell = bxhnz7tp5bge7wvu.tmp.fetch('last_cast_spell_id', false)
  return last_cast_spell == spell
end

local function combat()
  local fb_before_tod_toggle = bxhnz7tp5bge7wvu.settings.fetch('ww_nikopol_fb_before_tod', false)
  local trinket_13 = bxhnz7tp5bge7wvu.settings.fetch('ww_nikopol_trinket_13', false)
  local trinket_14 = bxhnz7tp5bge7wvu.settings.fetch('ww_nikopol_trinket_14', false)
  
  if not player.alive then return end
    
  if GetCVar("nameplateShowEnemies") == '0' then
    SetCVar("nameplateShowEnemies", 1)
  end
  
  macro('/cancelqueuedspell')
   
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if GetItemCooldown(177278) == 0 and player.health.effective < 20 then
    macro('/use Phial of Serenity')
  end
  
  if modifier.lshift then
    if castable(SB.ExpelHarm) then
      return cast(SB.ExpelHarm)
    end
    
    if castable(SB.Vivify) then
      return cast(SB.Vivify, player)
    end
  end
  
  if modifier.lalt and target.castable(SB.TouchofKarma) then
    cast(SB.TouchofKarma, target)
  end
  
  if toggle('dispell', false) and castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
    return cast(SB.DetoxDPS, player)
  end
  
  local nearest_target = enemies.match(function (unit)
    return unit.alive and unit.combat and unit.distance <= 5
  end)
  
  if (not target.exists or target.distance > 5) and nearest_target and nearest_target.name then
    macro('/target ' .. nearest_target.name)
  end
  
  local enemies_around = enemies.around(5)
  local enemies_around_8 = enemies.around(8)
  local chi_energy_stack_rule = 30 - enemies_around_8 * 5
  local energy_time_to_50 = (player.power.energy.max / 2 - player.power.energy.actual) / GetPowerRegen()
  local hold_xuen = fight_remains("<", spell(SB.InvokeXuen).cooldown) or fight_remains("<", 120) and fight_remains(">", spell(SB.Serenity).cooldown) and spell(SB.Serenity).cooldown > 10
  local xuen_active = player.celectial_active("Xuen")
  
  if toggle('auto_mark', false) then
    local enemy_for_mark = enemies.match(function (unit)
      return unit.alive and unit.combat and unit.distance <= 5 and unit.debuff(SB.MarkoftheCrane).remains < 2
    end)

    if target.debuff(SB.MarkoftheCrane).remains > 10 and enemy_for_mark and enemy_for_mark.name then
      for i=1,enemies_around do
        macro('/target ' .. enemy_for_mark.name)
        if target.guid == enemy_for_mark.guid then break end
      end
    end
  end
  
  local function simulationcraft()
    local function aoe()
      if castable(SB.WhirlingDragonPunch) and player.buff(SB.WhirlingDragonPunchBuff).up then
        return cast(SB.WhirlingDragonPunch, target)
      end
      
      if castable(SB.EnergizingElixir) and ((player.power.chi.deficit >= 2 and player.power.energy.tomax > 2) or player.power.chi.deficit >= 4 ) then
        return cast(SB.EnergizingElixir)
      end

      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and player.buff(SB.DanceofChiJi).up then
        return cast(SB.SpinningCrane)
      end
      
      if castable(SB.FistofFury) and (player.power.energy.tomax > fof_execute_time() or player.power.chi.deficit <= 1) then
        return cast(SB.FistofFury)
      end

      local wdp_cd_plus_4 = spell(SB.WhirlingDragonPunch).cooldown + 4

      if castable(SB.RisingSunKick) and talent(7, 2) and spell(SB.RisingSunKick).cooldown_duration > wdp_cd_plus_4 and (spell(SB.FistofFury).cooldown > 3 or player.power.chi.actual >= 5) then
        return cast(SB.RisingSunKick, target)
      end

      if castable(SB.RushingJadeWind) and player.buff(SB.RushingJadeWind).down then
        return cast(SB.RushingJadeWind)
      end
      
      if castable(SB.ExpelHarm) and player.power.chi.deficit >= 1 then
        return cast(SB.ExpelHarm)
      end
      
      if castable(SB.FistoftheWhiteTiger) and player.power.chi.deficit >= 3 then
        return cast(SB.FistoftheWhiteTiger, target)
      end
      
      if castable(SB.ChiBurst) and player.power.chi.deficit >= 2 then
        return cast(SB.ChiBurst, target)
      end
      --actions.aoe+=/crackling_jade_lightning,if=buff.the_emperors_capacitor.stack>19&energy.time_to_max>execute_time-1&cooldown.fists_of_fury.remains>execute_time
      
      if castable(SB.TigerPalm) and player.power.chi.deficit >= 2 and (not talent(6, 1) or combo_strike(SB.TigerPalm)) then
        return cast(SB.TigerPalm, target)
      end
      
      --actions.aoe+=/arcane_torrent,if=chi.max-chi>=1
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and (player.power.chi.actual >= 5 or spell(SB.FistofFury).cooldown > 6 or spell(SB.FistofFury).cooldown > 3 and player.power.chi.actual >= 3 and energy_time_to_50 < 1 or player.power.energy.tomax <= 3 + 3 * spell(SB.FistofFury).cooldown and spell(SB.FistofFury).cooldown < 5 or player.buff(SB.StormEarthFire).up) then
        return cast(SB.SpinningCrane)
      end

      if castable(SB.ChiWave) and combo_strike(SB.ChiWave) then
        return cast(SB.ChiWave, target)
      end

--actions.aoe+=/flying_serpent_kick,if=buff.bok_proc.down,interrupt=1

      if combo_strike(SB.BlackoutKick) and castable(SB.BlackoutKick) and (player.buff(SB.BlackoutKickBuff).up or (talent(6, 1) and last_cast(SB.TigerPalm) and player.power.chi.actual == 2 and spell(SB.FistofFury).cooldown < 3) or (player.power.chi.deficit <= 1 and last_cast(SB.SpinningCrane) and player.power.energy.tomax < 3)) then
        return cast(SB.BlackoutKick, target)
      end
    end
    
    local function cd_sef()
      if castable(SB.InvokeXuen) and (not hold_xuen or fight_remains("<", 25)) then
        return cast(SB.InvokeXuen)
      end
      
      if castable(SB.ArcaneTorrent) and player.power.chi.deficit >= 1 then
        return cast(SB.ArcaneTorrent)
      end
      
      if fb_before_tod_toggle and castable(SB.TouchofDeath) and castable(SB.FortBrew) then
        return cast(SB.FortBrew)
      end
      
      if castable(SB.TouchofDeath) then
        return cast(SB.TouchofDeath, target)
      end
      
      if castable(SB.WeaponsofOrder) and spell(SB.RisingSunKick).cooldown < gcd_duration() then
        return cast(SB.WeaponsofOrder, target)
      end
      
      if castable(SB.FaelineStomp) and combo_strike(SB.FaelineStomp) then
        return cast(SB.FaelineStomp, target)
      end
      
      if castable(SB.FallenOrder) then
        return cast(SB.FallenOrder, target)
      end
      
      if castable(SB.BonedustBrew) then
        return cast(SB.BonedustBrew, target)
      end
      
      if castable(SB.StormEarthFireFixate) and player.buff(SB.StormEarthFire).up then
        cast(SB.StormEarthFireFixate)
      end
      
      if castable(SB.StormEarthFire) and player.buff(SB.StormEarthFire).down and (spell(SB.StormEarthFire).charges == 2 or fight_remains("<", 20)) then
        return cast(SB.StormEarthFire)
      end
             
      if castable(SB.StormEarthFire) and player.buff(SB.StormEarthFire).down and (player.buff(SB.WeaponsofOrder).up or ((fight_remains("<", spell(SB.WeaponsofOrder).cooldown) or spell(SB.WeaponsofOrder).cooldown > spell(SB.StormEarthFire).full_recharge_time) and spell(SB.FistofFury).cooldown <= 9 and player.power.chi.actual >= 2 and spell(SB.WhirlingDragonPunch).cooldown <= 12)) then
        return cast(SB.StormEarthFire)
      end
     
      local start, duration, enable = GetInventoryItemCooldown("player", 13)
      if trinket_13 and enable == 1 and start == 0 then
        return macro('/use 13')
      end
      
      start, duration, enable = GetInventoryItemCooldown("player", 14)
      if trinket_14 and enable == 1 and start == 0 then
        return macro('/use 14')
      end
      
      if castable(SB.BloodFury) then
        return cast(SB.BloodFury, target)
      end
      
      if castable(SB.Berserking) and (spell(SB.InvokeXuen).cooldown > 30 or hold_xuen or fight_remains("<", 15)) then
        return cast(SB.Berserking)
      end
      
      if castable(SB.Fireblood) then
        return cast(SB.Fireblood, target)
      end
      
      if castable(SB.AncestralCall) then
        return cast(SB.AncestralCall, target)
      end
      
      if castable(SB.BagofTricks) and player.buff(SB.StormEarthFire).down then
        return cast(SB.BagofTricks, target)
      end
    end
  
    local function cd_serenity()
      local serenity_burst = spell(SB.Serenity).cooldown < 1
      
      if castable(SB.InvokeXuen) then
        return cast(SB.InvokeXuen)
      end
      
      local start, duration, enable = GetInventoryItemCooldown("player", 13)
      if trinket_13 and enable == 1 and start == 0 then
        return macro('/use 13')
      end
      
      start, duration, enable = GetInventoryItemCooldown("player", 14)
      if trinket_14 and enable == 1 and start == 0 then
        return macro('/use 14')
      end
      
      if castable(SB.BloodFury) and serenity_burst then
        return cast(SB.BloodFury, target)
      end
      
      if castable(SB.Berserking) and serenity_burst then
        return cast(SB.Berserking)
      end

      if castable(SB.ArcaneTorrent) and player.power.chi.deficit >= 1 then
        return cast(SB.ArcaneTorrent)
      end

      if castable(SB.Fireblood) and serenity_burst then
        return cast(SB.Fireblood, target)
      end

      if castable(SB.AncestralCall) and serenity_burst then
        return cast(SB.AncestralCall, target)
      end

      if castable(SB.BagofTricks) and serenity_burst then
        return cast(SB.BagofTricks, target)
      end

      if castable(SB.TouchofDeath) then
        return cast(SB.TouchofDeath, target)
      end
      
      if castable(SB.WeaponsofOrder) then
        return cast(SB.WeaponsofOrder, target)
      end
      
      if castable(SB.FaelineStomp) and combo_strike(SB.FaelineStomp) then
        return cast(SB.FaelineStomp, target)
      end
      
      if castable(SB.FallenOrder) then
        return cast(SB.FallenOrder, target)
      end
      
      if castable(SB.BonedustBrew) then
        return cast(SB.BonedustBrew, target)
      end

      if castable(SB.Serenity) and spell(SB.RisingSunKick).cooldown < 2 then
        return cast(SB.Serenity)
      end
      
      if castable(SB.BagofTricks) then
        return cast(SB.BagofTricks, target)
      end
    end
    
    local function opener()
      if castable(SB.FistoftheWhiteTiger) and player.power.chi.deficit >= 3 then
        return cast(SB.FistoftheWhiteTiger, target)
      end
      
      if castable(SB.ExpelHarm) and talent(1,3) and player.power.chi.deficit >= 3 then
        return cast(SB.ExpelHarm)
      end
      
      if castable(SB.TigerPalm) and combo_strike(SB.TigerPalm) and player.power.chi.deficit >= 2 then
        return cast(SB.TigerPalm, target)
      end
      
      if castable(SB.ChiWave) and player.power.chi.deficit == 2 then
        return cast(SB.ChiWave, target)
      end
      
      if castable(SB.ExpelHarm) then
        return cast(SB.ExpelHarm)
      end
      
      if castable(SB.TigerPalm) and player.power.chi.deficit >= 2 then
        return cast(SB.TigerPalm, target)
      end
    end
    
    local function serenity()
      if castable(SB.FistofFury) and player.buff(SB.Serenity).remains < 1 then
        return cast(SB.FistofFury)
      end
      
      local start, duration, enable = GetInventoryItemCooldown("player", 13)
      if trinket_13 and enable == 1 and start == 0 then
        return macro('/use 13')
      end
      
      start, duration, enable = GetInventoryItemCooldown("player", 14)
      if trinket_14 and enable == 1 and start == 0 then
        return macro('/use 14')
      end
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and (enemies_around_8 >= 3 or (enemies_around_8 > 1 and spell(SB.RisingSunKick).cooldown == 0)) then
        return cast(SB.SpinningCrane)
      end
      
      if castable(SB.RisingSunKick) and combo_strike(SB.RisingSunKick) then
        return cast(SB.RisingSunKick, target)
      end
      
      if castable(SB.FistofFury) and enemies_around_8 >= 3 then
        return cast(SB.FistofFury)
      end
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and player.buff(SB.DanceofChiJi).up then
        return cast(SB.SpinningCrane)
      end
      
      if castable(SB.BlackoutKick) and (combo_strike(SB.BlackoutKick) or not talent(6, 1)) and player.buff(SB.WeaponsofOrderWW).up and spell(SB.RisingSunKick).cooldown > 2 then
        return cast(SB.BlackoutKick, target)
      end
      
      if castable(SB.FistoftheWhiteTiger) then
        return cast(SB.FistoftheWhiteTiger, target)
      end
      --actions.serenity+=/spinning_crane_kick,if=(!talent.hit_combo.enabled&conduit.calculated_strikes.enabled|combo_strike)&debuff.bonedust_brew.up
       
      if castable(SB.FistoftheWhiteTiger) and player.power.chi.actual < 3 then
        return cast(SB.FistoftheWhiteTiger, target)
      end
      
      if castable(SB.BlackoutKick) and (combo_strike(SB.BlackoutKick) or not talent(6, 1)) then
        return cast(SB.BlackoutKick, target)
      end
      
      return cast(SB.SpinningCrane)
    end
  
    local function st()
      if castable(SB.WhirlingDragonPunch) and player.buff(SB.WhirlingDragonPunchBuff).up then
        return cast(SB.WhirlingDragonPunch, target)
      end
      
      if castable(SB.EnergizingElixir) and ((player.power.chi.deficit >= 2 and player.power.energy.tomax > 3) or (player.power.chi.deficit >= 4 and (player.power.energy.tomax > 2 or not last_cast(SB.TigerPalm)))) then
        return cast(SB.EnergizingElixir)
      end
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and player.buff(SB.DanceofChiJi).up then
        return cast(SB.SpinningCrane)
      end

      if castable(SB.RisingSunKick) and (spell(SB.Serenity).cooldown > 1 or not talent(7, 3)) then
        return cast(SB.RisingSunKick, target)
      end
            
      local fof_casting_time_minus_1 = fof_execute_time() - 1
      local fof_casting_time_plus_1 = fof_execute_time() + 1
      
      if castable(SB.FistofFury) and ((player.power.energy.tomax > fof_casting_time_minus_1 or player.power.chi.deficit <= 1 or player.buff(SB.StormEarthFire).remains < fof_casting_time_plus_1) or fight_remains("<", fof_casting_time_plus_1)) then
        return cast(SB.FistofFury)
      end
      --actions.st+=/crackling_jade_lightning,if=buff.the_emperors_capacitor.stack>19&energy.time_to_max>execute_time-1&cooldown.rising_sun_kick.remains>execute_time|buff.the_emperors_capacitor.stack>14&(cooldown.serenity.remains<5&talent.serenity.enabled|cooldown.weapons_of_order.remains<5&covenant.kyrian|fight_remains<5)
      
      if castable(SB.RushingJadeWind) and player.buff(SB.RushingJadeWind).down and enemies_around_8 > 1 then
        return cast(SB.RushingJadeWind)
      end

      if castable(SB.FistoftheWhiteTiger) and player.power.chi.actual < 3 then
        return cast(SB.FistoftheWhiteTiger, target)
      end

      if castable(SB.ExpelHarm) and player.power.chi.deficit >= 1 then
        return cast(SB.ExpelHarm)
      end
      
      if castable(SB.ChiBurst) and player.power.chi.deficit >= 1 then
        return cast(SB.ChiBurst, target)
      end

      if castable(SB.ChiWave) then
        return cast(SB.ChiWave, target)
      end

      if castable(SB.TigerPalm) and player.power.chi.deficit >= 2 and combo_strike(SB.TigerPalm) and player.buff(SB.StormEarthFire).down then
        return cast(SB.TigerPalm, target)
      end

      if castable(SB.SpinningCrane) and ((player.buff(SB.ChiEnergy).count > chi_energy_stack_rule and player.buff(SB.StormEarthFire).down and ((spell(SB.RisingSunKick).cooldown > 2 and spell(SB.FistofFury).cooldown > 2) or (spell(SB.RisingSunKick).cooldown < 3 and spell(SB.FistofFury).cooldown > 3 and player.power.chi.actual > 3) or (spell(SB.RisingSunKick).cooldown > 3 and spell(SB.FistofFury).cooldown < 3 and player.power.chi.actual > 4) or (player.power.chi.deficit <= 1 and player.power.energy.tomax < 2))) or player.buff(SB.ChiEnergy).count > 10 and fight_remains("<", 7)) then
        return cast(SB.SpinningCrane)
      end
      
      if castable(SB.BlackoutKick) and combo_strike(SB.BlackoutKick) and ((talent(7, 3) and spell(SB.Serenity).cooldown < 3) or (spell(SB.RisingSunKick).cooldown > 1 and spell(SB.FistofFury).cooldown > 1) or (spell(SB.RisingSunKick).cooldown < 3 and spell(SB.FistofFury).cooldown > 3 and player.power.chi.actual > 2) or (spell(SB.RisingSunKick).cooldown > 3 and spell(SB.FistofFury).cooldown < 3 and player.power.chi.actual > 3) or player.power.chi.actual > 5 or player.buff(SB.BlackoutKickBuff).up) then
        return cast(SB.BlackoutKick, target)
      end
      
      if castable(SB.TigerPalm) and player.power.chi.deficit >= 2 and combo_strike(SB.TigerPalm) then
        return cast(SB.TigerPalm, target)
      end

--# Use FSK and interrupt it straight away
--actions.st+=/flying_serpent_kick,interrupt=1
      
      if combo_strike(SB.BlackoutKick) and castable(SB.BlackoutKick) and spell(SB.FistofFury).cooldown < 3 and player.power.chi.actual == 2 and last_cast(SB.TigerPalm) and energy_time_to_50 < 1 then
        return cast(SB.BlackoutKick, target)
      end
      
      if combo_strike(SB.BlackoutKick) and castable(SB.BlackoutKick) and player.power.energy.tomax < 2 and (player.power.chi.deficit <= 1 or last_cast(SB.TigerPalm)) then
        return cast(SB.BlackoutKick, target)
      end
    end
  
    local function weapons_of_order()
      local blackout_kick_needed = player.buff(SB.WeaponsofOrderWW).up and (spell(SB.RisingSunKick).cooldown > player.buff(SB.WeaponsofOrderWW).remains and player.buff(SB.WeaponsofOrderWW).remains < 2 or spell(SB.RisingSunKick).cooldown - player.buff(SB.WeaponsofOrderWW).remains > 2 and player.buff(SB.WeaponsofOrderWW).remains < 4)
      
      if not talent(7, 3) then
        cd_sef()
      end

      if talent(7, 3) then
        cd_serenity()
      end
    
      if castable(SB.EnergizingElixir) and player.power.chi.deficit >= 2 and player.power.energy.tomax > 3 then
        return cast(SB.EnergizingElixir)
      end

      if castable(SB.RisingSunKick) then
        return cast(SB.RisingSunKick, target)
      end
            
      if castable(SB.FistofFury) and enemies_around_8 >= 2 and player.buff(SB.WeaponsofOrderWW).remains < 1 then
        return cast(SB.FistofFury)
      end
      
      if castable(SB.WhirlingDragonPunch) and player.buff(SB.WhirlingDragonPunchBuff).up and enemies_around_8 >= 2 then
        return cast(SB.WhirlingDragonPunch, target)
      end
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and enemies_around_8 >= 3 and player.buff(SB.WeaponsofOrderWW).up then
        return cast(SB.SpinningCrane)
      end
      
      if castable(SB.BlackoutKick) and combo_strike(SB.BlackoutKick) and enemies_around <= 2 and blackout_kick_needed then
        return cast(SB.BlackoutKick, target)
      end
      
      if castable(SB.SpinningCrane) and combo_strike(SB.SpinningCrane) and player.buff(SB.DanceofChiJi).up then
        return cast(SB.SpinningCrane)
      end

      if castable(SB.WhirlingDragonPunch) and player.buff(SB.WhirlingDragonPunchBuff).up then
        return cast(SB.WhirlingDragonPunch, target)
      end

      if castable(SB.FistofFury) and player.buff(SB.StormEarthFire).up then
        return cast(SB.FistofFury)
      end

      if castable(SB.SpinningCrane) and player.buff(SB.ChiEnergy).count > chi_energy_stack_rule then
        return cast(SB.SpinningCrane)
      end

      if castable(SB.FistoftheWhiteTiger) and player.power.chi.actual < 3 then
        return cast(SB.FistoftheWhiteTiger, target)
      end
      
      if castable(SB.ExpelHarm) and player.power.chi.deficit >= 1 then
        return cast(SB.ExpelHarm)
      end

      if castable(SB.ChiBurst) and player.power.chi.deficit >= 1 + enemies_around and enemies_around > 1 then
        return cast(SB.ChiBurst, target)
      end

      if castable(SB.TigerPalm) and player.power.chi.deficit >= 2 and (combo_strike(SB.TigerPalm) or not talent(6, 1)) then
        return cast(SB.TigerPalm, target)
      end

      if castable(SB.BlackoutKick) and (enemies_around <= 3 and player.power.chi.actual >= 3 or player.buff(SB.WeaponsofOrderWW).up) then
        return cast(SB.BlackoutKick, target)
      end
      
      if castable(SB.ChiWave) then
        return cast(SB.ChiWave, target)
      end
--actions.weapons_of_order+=/flying_serpent_kick,interrupt=1
    end
  
    if player.buff(SB.Serenity).up then
      serenity()
    end
  
    if player.buff(SB.WeaponsofOrder).up then
      weapons_of_order()
    end
    
    if combat_time() < 4 and player.power.chi.actual < 5 and not xuen_active then
      opener()
    end
      
    if castable(SB.FistoftheWhiteTiger) and player.power.chi.deficit >= 3 and (player.power.energy.tomax < 1 or (player.power.energy.tomax < 4 and spell(SB.FistofFury).cooldown <= 1.5) or spell(SB.WeaponsofOrder).cooldown < 2) then
      return cast(SB.FistoftheWhiteTiger, target)
    end
    
    if castable(SB.ExpelHarm) and player.power.chi.deficit >= 1 and (player.power.energy.tomax < 1 or spell(SB.Serenity).cooldown < 2 or (player.power.energy.tomax < 4 and spell(SB.FistofFury).cooldown <= 1.5) or spell(SB.WeaponsofOrder).cooldown < 2) then
      return cast(SB.ExpelHarm)
    end
    
    if castable(SB.TigerPalm) and combo_strike(SB.TigerPalm) and player.power.chi.deficit >= 2 and (player.power.energy.tomax < 1 or spell(SB.Serenity).cooldown < 2 or (player.power.energy.tomax < 4 and spell(SB.FistofFury).cooldown <= 1.5) or spell(SB.WeaponsofOrder).cooldown < 2) then
      return cast(SB.TigerPalm, target)
    end
    
    if toggle('cooldowns', false) then
      if not talent(7, 3) then
        cd_sef()
      end

      if talent(7, 3) then
        cd_serenity()
      end
    end
    
    if not toggle('multitarget', false) or enemies_around_8 < 3 then
      st()
    end
    
    if toggle('multitarget', false) and enemies_around_8 >= 3 then
      aoe()
    end
    
    if castable(SB.TigerPalm) and combo_strike(SB.TigerPalm) then
      return cast(SB.TigerPalm, target)
    end
    
    if castable(SB.CracklingJade) and last_cast(SB.TigerPalm) and player.power.energy.actual >= 70 then
      return cast(SB.CracklingJade, target)
    end
  end
  
  if target.enemy and target.alive and target.distance <= 5 and not player.channeling(SB.FistofFury) and not player.channeling(SB.SpinningCrane) then
    auto_attack()
    
    if player.channeling(SB.CracklingJade) then
      stopcast()
    end
    
    if toggle('interrupts', false) and target.interrupt(70) then
      if castable(SB.SpearHandStrike) then
        return cast(SB.SpearHandStrike, target)
      end
      
      if castable(SB.LegSweep) then
        return cast(SB.LegSweep)
      end

      if spell(SB.LegSweep).cooldown > 0 and target.castable(SB.Paralysis) then
        return cast(SB.Paralysis, target)
      end
    end
      
    simulationcraft()
  end
end

local function resting()
  if not player.alive then return end
  
  if modifier.lshift then
    if castable(SB.ExpelHarm) then
      return cast(SB.ExpelHarm)
    end
    
    if castable(SB.Vivify) then
      return cast(SB.Vivify, player)
    end
  end
  
  if player.health.effective < 50 and castable(SB.Vivify) and not player.moving then
    return cast(SB.Vivify, player)
  end

  if toggle('dispell', false) and castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
    return cast(SB.DetoxDPS, player)
  end
end

function interface()
  local ww_gui = {
    key = 'ww_nikopol',
    title = 'Windwalker by Nikopol',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Rotation Tricks' },
      { key = 'fb_before_tod', type = 'checkbox', text = 'FB before ToD', desc = 'Activate Fortifying Brew before Touch of Death', default = false },
      { type = 'header', text = 'Trinkets' },
      { key = 'trinket_13', type = 'checkbox', text = '13', desc = 'use first trinket', default = false },
      { key = 'trinket_14', type = 'checkbox', text = '14', desc = 'use second trinket', default = false },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(ww_gui)
  
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
    name = 'auto_mark',
    label = 'Auto targeting for Mark of the Crane',
    on = {
      label = 'Auto Mark',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'auto mark',
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
  spec = bxhnz7tp5bge7wvu.rotation.classes.monk.windwalker,
  name = 'ww_nikopol',
  label = 'Windwalker by Nikopol',
  combat = combat,
  resting = resting,
  interface = interface
})

bxhnz7tp5bge7wvu.event.register("UNIT_SPELLCAST_SUCCEEDED", function(...)
  local unitID, _, spellID = ...
  if unitID == "player" then
    if combo_strike_spells[spellID] then
      bxhnz7tp5bge7wvu.tmp.store('last_combo_spell', spellID)
    end
    bxhnz7tp5bge7wvu.tmp.store('last_cast_spell_id', spellID)
  end
end)