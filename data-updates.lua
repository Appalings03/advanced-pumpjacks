if mods["space-age"] then

    local max_space_age_tiers = 3

    for i = max_space_age_tiers + 1, 6 do
        local name = "pumpjack-mk" .. (i + 1)

        -- Supprimer la recette
        if data.raw.recipe[name] then
            data.raw.recipe[name].enabled = false
            data.raw.recipe[name].hidden = true
        end

        -- Supprimer la technologie
        if data.raw.technology[name] then
            data.raw.technology[name].hidden = true
            data.raw.technology[name].enabled = false
        end
    end

    log("Advanced Pumpjacks: Space Age mode active - tiers above 3 disabled.")

end
