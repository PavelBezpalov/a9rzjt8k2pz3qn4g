-- Brewmaster Monk for 8.1 by Nikopol - 12/2018
-- Talents: 
-- Left Control - Leg Sweep
-- Left Alt - Tiger's Lust
-- Left Shift - Vivify self
local bxhnz7tp5bge7wvu = bxhnz7tp5bge7wvu_interface
local SB = m2jue4dgc56acfzz
local TG = torghast_spells

local function haste_mod()
  local haste = UnitSpellHaste("player")
  return 1 + haste / 100
end

local function gcd_duration()
  return 1.5 / haste_mod()
end

local function stagger_percent()
  local currstagger = UnitStagger("player")
  local maxstagger = UnitHealthMax("player")
  if not currstagger then return 0 end
  
  local percent = currstagger/maxstagger;
  
  return percent
end

local function gcd()
  if not player.alive then return end
  
  local cosmic_healing_potion = bxhnz7tp5bge7wvu.settings.fetch('br_nikopol_cosmic_healing_potion', false)
  
  if castable(SB.HealingElixir) and player.health.effective < 60 then
    cast(SB.HealingElixir)
  end

  local start, duration, enable = GetInventoryItemCooldown("player", 13)
  if enable == 1 and start == 0 and player.health.effective < 40 then
    return macro('/use 13')
  end
   
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if castable(SB.FortBrew) and player.health.effective < 20 then
    cast(SB.FortBrew)
  end
  
  if cosmic_healing_potion and GetItemCooldown(187802) == 0 and player.health.effective < 10 then
    macro('/use Cosmic Healing Potion')
  end
     
  if castable(SB.BlackOxBrew) and spell(SB.PurifyingBrew).charges == 0 and spell(SB.CelestialBrew).cooldown > 0 then
    cast(SB.BlackOxBrew)
  end
  
  --if castable(SB.PurifyingBrew)
  --  and player.buff(SB.CelestialBrew).down
  --  and (player.debuff(SB.HeavyStagger).up 
  --    or ((player.debuff(SB.LightStagger).up or player.debuff(SB.ModerateStagger).up) 
  --      and (spell(SB.PurifyingBrew).charges == 2 or spell(SB.PurifyingBrew).charges == 1 and spell(SB.PurifyingBrew).recharge < 2))) then
  --  cast(SB.PurifyingBrew)
  --end
  
  --spell(SB.WildfireBomb).fractionalcharges < 1
  
  if castable(SB.PurifyingBrew)
    and player.buff(SB.CelestialBrew).down
    and (
      stagger_percent() >= 0.7 and (spell(SB.InvokeNiuzao).cooldown < 5 or player.buff(SB.InvokeNiuzao).up)
      or stagger_percent() > 0 and player.buff(SB.InvokeNiuzao).up and player.buff(SB.InvokeNiuzao).remains < 8
      or stagger_percent() > 0 and spell(SB.PurifyingBrew).fractionalcharges >= 1.8 and (spell(SB.InvokeNiuzao).cooldown > 10 or player.buff(SB.InvokeNiuzao).up)
    ) then
    cast(SB.PurifyingBrew)
  end
  
  if target.enemy and target.alive and target.distance <= 5 and toggle('interrupts', false) and target.interrupt(70) and spell(SB.SpearHandStrike).cooldown == 0 then
    cast(SB.SpearHandStrike, target)
  end
end

local function combat()
  if not player.alive then return end
  
  local cosmic_healing_potion = bxhnz7tp5bge7wvu.settings.fetch('br_nikopol_cosmic_healing_potion', false)
  local energy_to_keg_smash = player.power.energy.actual + player.power.energy.regen * (spell(SB.KegSmash).cooldown + gcd_duration()) 
  
  if GetCVar("nameplateShowEnemies") == '0' then
    SetCVar("nameplateShowEnemies", 1)
  end
  
  macro('/cqs')
  
  -- if modifier.lcontrol and castable(SB.LegSweep) then
  --  return cast(SB.LegSweep)
  -- end
  
  if modifier.lcontrol and castable(SB.Vivify) then
    return cast(SB.Vivify, player)
  end
  
  if modifier.lalt and castable(SB.TigersLust) then
    return cast(SB.TigersLust, player)
  end
  
  if castable(SB.ExpelHarm) and player.health.effective < 80 and energy_to_keg_smash >= 55 then
    return cast(SB.ExpelHarm)
  end
  
  if castable(SB.HealingElixir) and player.health.effective < 60 then
    cast(SB.HealingElixir)
  end

  local start, duration, enable = GetInventoryItemCooldown("player", 13)
  if enable == 1 and start == 0 and player.health.effective < 40 then
    return macro('/use 13')
  end
  
  if GetItemCooldown(177278) == 0 and player.health.effective < 35 then
    macro('/use Phial of Serenity')
  end
  
  if GetItemCooldown(5512) == 0 and player.health.effective < 30 then
    macro('/use Healthstone')
  end
  
  if castable(SB.FortBrew) and player.health.effective < 20 then
    cast(SB.FortBrew)
  end
  
  if cosmic_healing_potion and GetItemCooldown(187802) == 0 and player.health.effective < 10 then
    macro('/use Cosmic Healing Potion')
  end
  
  if castable(SB.BlackOxBrew) and spell(SB.PurifyingBrew).charges == 0 and spell(SB.CelestialBrew).cooldown > 0 then
    cast(SB.BlackOxBrew)
  end
  
  --if castable(SB.PurifyingBrew)
  --  and player.buff(SB.CelestialBrew).down
  --  and (player.debuff(SB.HeavyStagger).up 
  --    or ((player.debuff(SB.LightStagger).up or player.debuff(SB.ModerateStagger).up) 
  --      and (spell(SB.PurifyingBrew).charges == 2 or spell(SB.PurifyingBrew).charges == 1 and spell(SB.PurifyingBrew).recharge < 2))) then
  --  cast(SB.PurifyingBrew)
  --end
  
  if castable(SB.PurifyingBrew)
    and player.buff(SB.CelestialBrew).down
    and (stagger_percent() >= 0.7 and (spell(SB.InvokeNiuzao).cooldown < 5 or player.buff(SB.InvokeNiuzao).up)
      or stagger_percent() > 0 and player.buff(SB.InvokeNiuzao).up and player.buff(SB.InvokeNiuzao).remains < 8
      or stagger_percent() > 0 and spell(SB.PurifyingBrew).fractionalcharges >= 1.8 and (spell(SB.InvokeNiuzao).cooldown > 10 or player.buff(SB.InvokeNiuzao).up)
    ) then
    cast(SB.PurifyingBrew)
  end
  
  if castable(SB.CelestialBrew) and player.debuff(SB.HeavyStagger).up and spell(SB.PurifyingBrew).charges == 0 and player.buff(SB.PurifiedChi).count >= 5 then
    return cast(SB.CelestialBrew)
  end
  
  if toggle('dispell', false) and castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
    return cast(SB.DetoxDPS, player)
  end
  
  if toggle('auto_target', false) then
    local nearest_target = enemies.match(function (unit)
      return unit.alive and unit.combat and unit.distance <= 5
    end)
    
    if (not target.exists or target.distance > 5) and nearest_target and nearest_target.name then
      macro('/target ' .. nearest_target.name)
    end
  end
  
  local enemies_around_5 = enemies.around(5)
  
  if player.buff(TG.ChorusofDeadSouls).up then
    if GetActionCooldown(159) == 0 and player.buff(TG.PhaseShift).down then
      UseAction(159)
    end
    
    if GetActionCooldown(157) == 0 and target.enemy and target.distance <= 40 and not player.moving then
      return UseAction(157)
    end
    
    return UseAction(158)
  end
  
  if target.enemy and target.alive and target.distance <= 5 then
    auto_attack()
      
    if toggle('interrupts', false) and target.interrupt(70) then
      if spell(SB.SpearHandStrike).cooldown == 0 then
        return cast(SB.SpearHandStrike, target)
      end
      
      if castable(SB.LegSweep) then
        return cast(SB.LegSweep)
      end

      if target.castable(SB.Paralysis) then
        return cast(SB.Paralysis, target)
      end
    end
    
    if player.channeling(SB.SpinningCrane) then return end
    
    if toggle('cooldowns', false) then
      if castable(SB.Berserking) then
        cast(SB.Berserking)
      end
      
      --local start, duration, enable = GetInventoryItemCooldown("player", 13)
      --if enable == 1 and start == 0 then
      --  return macro('/use 13')
      --end
      
      --start, duration, enable = GetInventoryItemCooldown("player", 14)
      --if enable == 1 and start == 0 then
      --  return macro('/use 14')
      --end
      
      if castable(SB.InvokeNiuzao) and player.buff(SB.InvokeNiuzao).down then
        return cast(SB.InvokeNiuzao, target)
      end
      
      if castable(SB.TouchofDeath) and target.distance <= 5 then
        return cast(SB.TouchofDeath, target)
      end
      
      if castable(SB.WeaponsofOrder) and player.buff(SB.InvokeNiuzao).down then
        return cast(SB.WeaponsofOrder)
      end
    end
    
    if target.castable(SB.KegSmash) and enemies_around_5 >= 2 then
      return cast(SB.KegSmash, target)
    end
    
    if target.castable(SB.KegSmash) and player.buff(SB.WeaponsofOrder).up then
      return cast(SB.KegSmash, target)
    end
    
    if spell(SB.BlackoutKickBR).cooldown == 0 then
      return cast(SB.BlackoutKickBR, target)
    end
    
    if target.castable(SB.KegSmash) then
      return cast(SB.KegSmash, target)
    end
    
    if castable(SB.RushingJadeWind) and player.buff(SB.RushingJadeWind).down then
      return cast(SB.RushingJadeWind)
    end
    
    if castable(SB.BreathofFire) then
      return cast(SB.BreathofFire)
    end
      
    if castable(SB.ChiWave) then
      return cast(SB.ChiWave, target)
    end
    
    if castable(SB.SpinningCrane) and enemies_around_5 >= 3 and spell(SB.KegSmash).cooldown > gcd_duration() and energy_to_keg_smash >= 65 then
      return cast(SB.SpinningCrane)
    end
    
    if target.castable(SB.TigerPalm) and spell(SB.KegSmash).cooldown > gcd_duration() and energy_to_keg_smash >= 65 then
      return cast(SB.TigerPalm, target)
    end
    
    if castable(SB.RushingJadeWind) then
      return cast(SB.RushingJadeWind)
    end
  end
end

local function resting()
  if not player.alive then return end
  
  if modifier.lcontrol and castable(SB.Vivify) then
    return cast(SB.Vivify, player)
  end
  
  --if player.health.effective < 50 and castable(SB.Vivify) and not player.moving then
  --  return cast(SB.Vivify, player)
  --end

  if toggle('dispell', false) and castable(SB.DetoxDPS) and player.dispellable(SB.DetoxDPS) then
    return cast(SB.DetoxDPS, player)
  end
end

function interface()
    local br_gui = {
    key = 'br_nikopol',
    title = 'Brewmaster',
    width = 250,
    height = 320,
    resize = true,
    show = false,
    template = {
      { type = 'header', text = 'Brewmaster Settings' },
      { type = 'rule' },   
      { type = 'text', text = 'Healing Settings' },
      { key = 'cosmic_healing_potion', type = 'checkbox', text = 'Cosmic Healing Potion', desc = 'Use Cosmic Healing Potion when below 10% health', default = false },
    }
  }

  configWindow = bxhnz7tp5bge7wvu.interface.builder.buildGUI(br_gui)
  
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
    name = 'auto_target',
    label = 'Auto Target',
    on = {
      label = 'AT',
      color = bxhnz7tp5bge7wvu.interface.color.green,
      color2 = bxhnz7tp5bge7wvu.interface.color.green
    },
    off = {
      label = 'at',
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
  spec = bxhnz7tp5bge7wvu.rotation.classes.monk.brewmaster,
  name = 'br_nikopol',
  label = 'Brewmaster by Nikopol',
  gcd = gcd,
  combat = combat,
  resting = resting,
  interface = interface
})
