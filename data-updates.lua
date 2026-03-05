local function add_unlock(tech_name, recipe_name)
    local tech = data.raw.technology[tech_name]
    if tech then
        tech.effects = tech.effects or {}
        for _, effect in pairs(tech.effects) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                return
            end
        end
        table.insert(tech.effects, {
            type = "unlock-recipe",
            recipe = recipe_name
        })
    end
end

local function add_productivity_bonus(tech_name, value)
    local tech = data.raw.technology[tech_name]
    if tech then
        tech.effects = tech.effects or {}
        table.insert(tech.effects, {
            type = "mining-drill-productivity-bonus",
            modifier = value
        })
    end
end

if mods["space-age"] then
    --------------------------------------------------
    -- LIMIT TO MK2, MK3, MK4 ONLY
    --------------------------------------------------
    for i = 1, 6 do
        local tier = i + 1
        local name = "pumpjack-mk" .. tier

        if tier > 4 then
            -- Disable higher tiers (mk5+)
            if data.raw.recipe[name] then
                data.raw.recipe[name].enabled = false
                data.raw.recipe[name].hidden = true
            end
            if data.raw.technology[name] then
                data.raw.technology[name].enabled = false
                data.raw.technology[name].hidden = true
            end
        end
    end
    --------------------------------------------------
    -- MK2
    -- Bleu + Mauve science requirement style
    --------------------------------------------------
    if data.raw.technology["pumpjack-mk2"] then
        data.raw.technology["pumpjack-mk2"].unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
            },
            time = 30
        }
        data.raw.technology["pumpjack-mk2"].prerequisites = {
            "oil-processing",
            "chemical-science-pack"
        }
    end
    --------------------------------------------------
    -- MK3
    -- All Nauvis + Vulcanus
    --------------------------------------------------
    if data.raw.technology["pumpjack-mk3"] then
        data.raw.technology["pumpjack-mk3"].unit = {
            count = 500,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"metallurgic-science-pack", 1}
            },
            time = 45
        }
        data.raw.technology["pumpjack-mk3"].prerequisites = {
            "pumpjack-mk2",
            "metallurgic-science-pack"
        }
    end
    --------------------------------------------------
    -- MK4
    -- Vulcanus + Aquilo + All Nauvis
    --------------------------------------------------
    if data.raw.technology["pumpjack-mk4"] then
        data.raw.technology["pumpjack-mk4"].unit = {
            count = 800,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"production-science-pack", 1},
                {"utility-science-pack", 1},
                {"metallurgic-science-pack", 1},
                {"cryogenic-science-pack", 1}
            },
            time = 60
        }
        data.raw.technology["pumpjack-mk4"].prerequisites = {
            "pumpjack-mk3",
            "cryogenic-science-pack"
        }
    end
    -- doesn't work because add global prod
    --add_productivity_bonus("pumpjack-mk3", 0.25)
    --add_productivity_bonus("pumpjack-mk4", 0.50)
    log("Advanced Pumpjacks: Space Age tech tree adjusted.")
    --------------------------------------------------
    -- RECIPES
    --------------------------------------------------
    
    -- MK2 (Assembler only)
    if data.raw.recipe["pumpjack-mk2"] then
        local r = data.raw.recipe["pumpjack-mk2"]
    
        r.enabled = false
        r.category = "crafting"
        r.energy_required = 5
        r.ingredients = {
            {type="item", name="pumpjack", amount=2},
            {type="item", name="steel-plate", amount=20},
            {type="item", name="advanced-circuit", amount=5}
        }
    
        add_unlock("pumpjack-mk2", "pumpjack-mk2")
    end
    
    
    -- MK3 (Assembler version)
    if data.raw.recipe["pumpjack-mk3"] then
        local r = data.raw.recipe["pumpjack-mk3"]
    
        r.enabled = false
        r.category = "crafting"
        r.energy_required = 8
        r.ingredients = {
            {type="item", name="pumpjack-mk2", amount=1},
            {type="item", name="tungsten-plate", amount=30},
            {type="item", name="advanced-circuit", amount=20},
            {type="item", name="electric-engine-unit", amount=10}
        }
    
        add_unlock("pumpjack-mk3", "pumpjack-mk3")
    end
    
    -- MK3 (Foundry version)
    if data.raw.recipe["pumpjack-mk3"] then
        local foundry = table.deepcopy(data.raw.recipe["pumpjack-mk3"])
        foundry.name = "pumpjack-mk3-foundry"
        foundry.category = "metallurgy"
        foundry.energy_required = 6
        foundry.enabled = false
    
        data:extend({foundry})
    
        add_unlock("pumpjack-mk3", "pumpjack-mk3-foundry")
    end
    
    
    -- MK4 (Assembler version)
    if data.raw.recipe["pumpjack-mk4"] then
        local r = data.raw.recipe["pumpjack-mk4"]
    
        r.enabled = false
        r.category = "crafting-with-fluid"
        r.energy_required = 12
        r.ingredients = {
            {type="item", name="pumpjack-mk3", amount=1},
            {type="item", name="processing-unit", amount=25},
            {type="item", name="low-density-structure", amount=20},
            {type="item", name="electric-engine-unit", amount=20},
            {type="fluid", name="fluoroketone-hot", amount=25}
        }
    
        add_unlock("pumpjack-mk4", "pumpjack-mk4")
    end
    
    -- MK4 (Cryogenic version)
    if data.raw.recipe["pumpjack-mk4"] then
        local cryo = table.deepcopy(data.raw.recipe["pumpjack-mk4"])
        cryo.name = "pumpjack-mk4-cryogenic"
        cryo.category = "cryogenics"
        cryo.energy_required = 9
        cryo.enabled = false
    
        data:extend({cryo})
    
        add_unlock("pumpjack-mk4", "pumpjack-mk4-cryogenic")
    end
    
    log("Advanced Pumpjacks: Space Age recipes upgraded.")
    --------------------------------------------------
    -- MK2 STATS
    --------------------------------------------------
    local mk2 = data.raw["mining-drill"]["pumpjack-mk2"]
    if mk2 then
        mk2.mining_speed = 1.5
        mk2.resource_searching_radius = 3.0
        mk2.energy_usage = "200kW"
        mk2.module_specification = {
            module_slots = 3,
            module_info_icon_shift = {0, 0.8}
        }
    end
    --------------------------------------------------
    -- MK3 STATS
    --------------------------------------------------
    local mk3 = data.raw["mining-drill"]["pumpjack-mk3"]
    if mk3 then
        mk3.mining_speed = 2.5
        mk3.resource_searching_radius = 4.0
        mk3.energy_usage = "350kW"
        mk3.module_specification = {
            module_slots = 4,
            module_info_icon_shift = {0, 0.8}
        }
        mk3.effect_receiver = {
            base_effect = {productivity = 0.25}
        }
    end
    --------------------------------------------------
    -- MK4 STATS (Aquilo tier)
    --------------------------------------------------
    local mk4 = data.raw["mining-drill"]["pumpjack-mk4"]
    if mk4 then
        mk4.mining_speed = 4.0
        mk4.resource_searching_radius = 5.0
        mk4.energy_usage = "600kW"
        mk4.module_specification = {
            module_slots = 5,
            module_info_icon_shift = {0, 0.8}
        }
        mk4.effect_receiver = {
        base_effect = {productivity = 0.5}
        }
        -- Drain Rate-> trying to set it to 150%
    end

    log("Advanced Pumpjacks: Space Age stats rebalanced.")
    end

    log("Advanced Pumpjacks: Space Age stats rebalanced.")
end
