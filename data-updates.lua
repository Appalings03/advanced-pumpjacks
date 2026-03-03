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
                {"vulcanus-science-pack", 1}
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
                {"vulcanus-science-pack", 1},
                {"aquilo-science-pack", 1}
            },
            time = 60
        }
        data.raw.technology["pumpjack-mk4"].prerequisites = {
            "pumpjack-mk3",
            "cryogenic-science-pack"
        }
    end
    log("Advanced Pumpjacks: Space Age tech tree adjusted.")
    --------------------------------------------------
    -- MK2 RECIPE
    --------------------------------------------------
    if data.raw.recipe["pumpjack-mk2"] then
        data.raw.recipe["pumpjack-mk2"].ingredients = {
            {type="item", name="pumpjack", amount=2},
            {type="item", name="steel-plate", amount=20},
            {type="item", name="advanced-circuit", amount=5}
        }

        data.raw.recipe["pumpjack-mk2"].category = "crafting"
        data.raw.recipe["pumpjack-mk2"].energy_required = 5
    end
    --------------------------------------------------
    -- MK3 RECIPE (Vulcanus tier)
    -- MK3 (Assembler version)
    --------------------------------------------------
    if data.raw.recipe["pumpjack-mk3"] then
        data.raw.recipe["pumpjack-mk3"].ingredients = {
            {type="item", name="pumpjack-mk2", amount=1},
            {type="item", name="tungsten-plate", amount=30},
            {type="item", name="advanced-circuit", amount=20},
            {type="item", name="electric-engine-unit", amount=10}
        }

        data.raw.recipe["pumpjack-mk3"].category = "crafting"
        data.raw.recipe["pumpjack-mk3"].energy_required = 8
    end
    --------------------------------------------------
    -- MK3 (Foundry version - casting)
    --------------------------------------------------
    if data.raw.recipe["pumpjack-mk3"] then
        local foundry_recipe = table.deepcopy(data.raw.recipe["pumpjack-mk3"])
        foundry_recipe.name = "pumpjack-mk3-casting"
        foundry_recipe.category = "metallurgy"
        foundry_recipe.energy_required = 6 -- un peu plus rapide en foundry

        data:extend({foundry_recipe})
    end
    --------------------------------------------------
    -- MK4 RECIPE (Aquilo tier)
    -- MK4 (Assembler version)
    --------------------------------------------------
    if data.raw.recipe["pumpjack-mk4"] then
        data.raw.recipe["pumpjack-mk4"].ingredients = {
            {type="item", name="pumpjack-mk3", amount=1},
            {type="item", name="processing-unit", amount=25},
            {type="item", name="low-density-structure", amount=20},
            {type="item", name="electric-engine-unit", amount=20},
            {type="fluid", name="fluoroketone-hot", amount=25}
        }
        data.raw.recipe["pumpjack-mk4"].category = "crafting-with-fluid"
        data.raw.recipe["pumpjack-mk4"].energy_required = 12
    end
    --------------------------------------------------
    -- MK4 (Cryoplant version - cryogenic)
    --------------------------------------------------
    if data.raw.recipe["pumpjack-mk4"] then
        local cryo_recipe = table.deepcopy(data.raw.recipe["pumpjack-mk4"])
        cryo_recipe.name = "pumpjack-mk4-cryogenic"
        cryo_recipe.category = "cryogenic"
        cryo_recipe.energy_required = 9 

        data:extend({cryo_recipe})
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
        mk2.module_inventory_size = 3
    end
    --------------------------------------------------
    -- MK3 STATS
    --------------------------------------------------
    local mk3 = data.raw["mining-drill"]["pumpjack-mk3"]
    if mk3 then
        mk3.mining_speed = 2.5
        mk3.resource_searching_radius = 4.0
        mk3.energy_usage = "350kW"
        mk3.module_inventory_size = 4
        -- Bonus productivité
        mk3.base_productivity = 0.25
    end
    --------------------------------------------------
    -- MK4 STATS (Aquilo tier)
    --------------------------------------------------
    local mk4 = data.raw["mining-drill"]["pumpjack-mk4"]
    if mk4 then
        mk4.mining_speed = 4.0
        mk4.resource_searching_radius = 5.0
        mk4.energy_usage = "600kW"
        mk4.module_inventory_size = 5
        -- Productivity
        mk4.base_productivity = 0.5
        -- Drain Rate-> trying to set it to 150%
    end

    log("Advanced Pumpjacks: Space Age stats rebalanced.")
end
