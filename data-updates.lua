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
                {"logistic-science-pack", 1}
            },
            time = 30
        }
    end

    --------------------------------------------------
    -- MK3
    -- Toutes sciences Nauvis + Vulcanus
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
    end

    --------------------------------------------------
    -- MK4
    -- Vulcanus + Aquilo + toutes Nauvis
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
    end

    log("Advanced Pumpjacks: Space Age tech tree adjusted.")

end
