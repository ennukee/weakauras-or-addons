--[[
             PLEASE READ COMMENTS

 Discipline Priest Atonement Tracker (Patch 7.0.3)
  by enragednuke#1402 (or Priestîsm on US-Sargeras)
  with help of users on the HowToPriest Discord (Alyce)
  
Part 2 of 2: Mana cost display

IMPORTANT NOTE: Due to a lack of an easy way to access an item's true item level (after upgrades / WF / Titanforged), this WeakAura may be negligibly off if using a Demonic Phylactery. If you want to correct this small error, please uncomment the line at the start of the function and fill in your DP's mana reduction amount. Manually setting the mana reduction will also greatly increase the performance of the WeakAura.

REGARDING TITANFORGED: The above note still fixes this. Just fill in your DP's listed mana reduction.

If using Demonic Phylactery, this will not work in instances where downscaling of item level occur  (i.e. WoD CMs)

--]]

function()
    local dpManaReduction = 0; -- Change this to your Demonic Phylactery's mana reduction if desired
    
    local stacks = GetSpellCount(200829);
    local PLEA_BASE_COST = 0.36 / 100 * UnitManaMax("player");
    local PWR_BASE_COST = 6.5 / 100 * UnitManaMax("player"); -- Power Word: Radiance
    local DP_IS_EQUIPPED = IsEquippedItem("Demonic Phylactery");
    en_atonement_plea_better = true;
    
    if DP_IS_EQUIPPED then
        if dpManaReduction == 0 then
            -- Is there a quick way to see what slot DP is in?
            local trinket_1 = GetInventoryItemID(13);
            local slot = 14;
            if trinket_1 == 124233 then
                slot = 13;
            end
            local itemLink = GetInventoryItemLink("player", slot);
            
            _,_,_,ilvl,_,_,_,_,_,_,_ = GetItemInfo(itemLink);
            
            --[[
             Some math if you were interested in devising a better formula

             ilvl->red (+prv) (+ttl)
             735 -> 577 (+27) (+198) vs ilvl+45 so 4.4/lvl
             730 -> 550 (+25) (+171) vs ilvl+40 so 4.275/lvl
             725 -> 525 (+23) (+146) vs ilvl+35 so 4.171/lvl
             720 -> 502 (+24) (+123) vs ilvl+30 so 4.1/lvl
             715 -> 478 (+21) (+99) vs ilvl+25 so 3.96/lvl
             710 -> 457 (+21) (+78) vs ilvl+20 so 3.9/lvl
             705 -> 436 (+20) (+57) vs ilvl+15 so 3.8/lvl
             700 -> 416 (+19) (+37) vs ilvl+10 so 3.7/lvl
             695 -> 397 (+18) vs ilvl+5 so 3.6/lvl
             690 -> 379
            ]]--
            
            dpManaReduction = 379.0;
            for i = 690, ilvl do
                dpManaReduction = dpManaReduction + (3.5 + (i-690) * 0.02);
            end
        end
    else
        -- Incase you swapped trinkets and don't want to edit the WA
        dpManaReduction = 0; 
    end
    
    -- Generate initial mana costs for Plea and PW:R (including DP reductions)
    local manaCost = (PLEA_BASE_COST * (stacks+1)) - dpManaReduction;
    local updatedPWRCost = PWR_BASE_COST - dpManaReduction;
    
    -- Check for important mana-reduction buffs
    local HAS_SYMBOL = UnitBuff("player","Symbol of Hope")
    local HAS_PI = UnitBuff("player", "Power Infusion")
    
    -- Update mana costs of Plea/PW:R if Power Infusion is active 
    manaCost = HAS_PI and manaCost*0.8 or manaCost 
    updatedPWRCost = HAS_PI and updatedPWRCost*0.8 or updatedPWRCost
    
    -- Special label for telling the user it may not be 100% accurate w/ DP equipped (as said at start)
    local result = ( DP_IS_EQUIPPED and "~" or "" ) .. manaCost;
    result = HAS_PI and (result.." |c00ff5500(PI)|r") or result -- Attach PI label if active
    
    -- Various cases affecting the output directly
    if manaCost <= 0 or HAS_SYMBOL then -- (aka no cost situations)
        result = HAS_SYMBOL and "No cost\n|c00ffff99(Symbol)|r" or "No cost"
    elseif manaCost > updatedPWRCost / 3 then -- Since PW:R can apply 3 atonements
        result = result .. "\n|c00ff3300(PW:R)|r";
    end
    
    -- Finally, return the output
    return result;
    
end
