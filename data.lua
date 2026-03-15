local util = require("util")
local requested_tiers = settings.startup["apj-tier-count"].value
local modules_tiers = settings.startup["apj-modules"].value
if modules_tiers == nil then
  modules_tiers = false
end
if requested_tiers == nil then
  requested_tiers = 3
end
local max_allowed = 6

if requested_tiers > max_allowed then
  log("Advanced Pumpjacks: Tier count clamped to " .. max_allowed)
end

local tier_count = math.min(requested_tiers, max_allowed)

local base_pumpjack = data.raw["mining-drill"]["pumpjack"]
local base_item = data.raw["item"]["pumpjack"]
local base_recipe = data.raw["recipe"]["pumpjack"]
local base_corpse = data.raw["corpse"]["pumpjack-remnants"]

--------------------------------------------------
-- COLOR FOR ITEMS ONLY
--------------------------------------------------

local function get_tier_tint(tier)
    local colors = {
        {r=0.1, g=0.4, b=1.0, a=1}, -- mk2
        {r=1.0, g=0.2, b=0.2, a=1}, -- mk3
        {r=0.1, g=0.9, b=0.9, a=1}, -- mk4
        {r=1.0, g=0.5, b=0.1, a=1}, -- mk5
        {r=0.7, g=0.2, b=1.0, a=1}, -- mk6
        {r=1.0, g=1.0, b=0.2, a=1}  -- mk7
    }
    return colors[tier] or colors[1]
end

--------------------------------------------------
-- APPLY CUSTOM SPRITES
--------------------------------------------------

--[[
local function apply_pumpjack_sprites(entity, tier)
    local path = "__advanced-pumpjacks__/graphics/mk" .. tier .. "/"
    local shared_path = "__advanced-pumpjacks__/graphics/"

    -- HORSEHEAD uniquement : dans graphics_set.animation par direction
    if entity.graphics_set and entity.graphics_set.animation then
        local directions = {"north", "east", "south", "west"}
        for _, dir in pairs(directions) do
            local anim = entity.graphics_set.animation[dir]
            if anim and anim.layers then
                anim.layers[1].filename = path .. "horsehead_mk" .. tier .. ".png" 
                anim.layers[1].blend_mode = "additive"
            end
        end
    end
end
--]]
local function apply_pumpjack_sprites(entity, tier)
    local tint = get_tier_tint(tier - 1)  -- tier-1 car get_tier_tint commence à l'index 1

    if entity.graphics_set and entity.graphics_set.animation then
        local directions = {"north", "east", "south", "west"}
        for _, dir in pairs(directions) do
            local anim = entity.graphics_set.animation[dir]
            if anim and anim.layers then
                anim.layers[1].tint = tint
            end
        end
    end
end
--------------------------------------------------
-- GENERATE TIERS
--------------------------------------------------

for i = 1, tier_count do
    local tier = i + 1
    local name = "pumpjack-mk" .. tier

    ----------------------------------------
    -- ENTITY
    ----------------------------------------

    local entity = table.deepcopy(base_pumpjack)
    entity.name = name
    entity.minable.result = name
    entity.fast_replaceable_group = "pumpjack"

    if i < tier_count then
        entity.next_upgrade = "pumpjack-mk" .. (tier + 1)
    end

    -- SPEED
    entity.mining_speed = base_pumpjack.mining_speed * (1 + 0.25 * i)

    -- ENERGY
    local base_energy = tonumber(string.match(base_pumpjack.energy_usage,"([%d%.]+)"))
    local new_energy = base_energy * math.pow(1.5, i)
    new_energy = math.floor(new_energy / 10 + 0.5) * 10
    entity.energy_usage = tostring(new_energy) .. "kW"
    entity.resource_searching_radius = base_pumpjack.resource_searching_radius

    -- MODULES
    if modules_tiers then
        entity.module_slots = 2 + i
        entity.allowed_effects = {"speed","productivity","consumption","pollution"}
    end

    -- PRODUCTIVITY
    if i >= 1 then
        entity.effect_receiver = {
            base_effect = {productivity = 0.05}
        }
    end

    -- APPLY CUSTOM GRAPHICS
    apply_pumpjack_sprites(entity, tier)
    entity.corpse = "remnants_mk" .. tier

    -- log("Advanced Pumpjacks: entity prototype [" .. name .. "]:")
    -- log(serpent.block(entity))

    ----------------------------------------
    -- ITEM
    ----------------------------------------

    local item = table.deepcopy(base_item)
    item.name = name
    item.place_result = name
    local tint = get_tier_tint(i)
    item.icons = {
        {icon = base_item.icon, icon_size = base_item.icon_size},
        {icon = base_item.icon, icon_size = base_item.icon_size, tint = tint}
    }
    item.icon = nil

    -- log("Advanced Pumpjacks: item prototype [" .. name .. "]:")
    -- log(serpent.block(item))

    ----------------------------------------
    -- RECIPE
    ----------------------------------------

    local recipe = table.deepcopy(base_recipe)
    recipe.name = name
    recipe.results = {{type="item", name=name, amount=1}}
    recipe.ingredients = {
        {type="item", name="pumpjack", amount=1},
        {type="item", name="steel-plate", amount=5 * i},
        {type="item", name="advanced-circuit", amount=3 * i}
    }

    -- log("Advanced Pumpjacks: recipe prototype [" .. name .. "]:")
    -- log(serpent.block(recipe))

    ----------------------------------------
    -- TECHNOLOGY
    ----------------------------------------

    local tech = {
        type = "technology",
        name = name,
        icon_size = base_pumpjack.icon_size,
        icons = {
            {icon = base_pumpjack.icon, icon_size = base_pumpjack.icon_size},
            {icon = base_pumpjack.icon, icon_size = base_pumpjack.icon_size, tint = tint}
        },
        prerequisites = i == 1 and {"oil-processing"} or {"pumpjack-mk"..(tier-1)},
        effects = {{type = "unlock-recipe", recipe = name}},
        unit = {
            count = 200 * i,
            ingredients = {
                {"automation-science-pack",1},
                {"logistic-science-pack",1},
                {"chemical-science-pack",1}
            },
            time = 30
        },
        order = "d-a-" .. i
    }

    -- log("Advanced Pumpjacks: technology prototype [" .. name .. "]:")
    -- log(serpent.block(tech))

    ----------------------------------------
    -- CORPSE
    ----------------------------------------

    local corpse = {
        type = "corpse",
        name = "remnants_mk" .. tier,
        icons = item.icons,
        flags = {"placeable-neutral", "building-direction-8-way", "not-on-map"},
        hidden_in_factoriopedia = true,
        subgroup = "extraction-machine-remnants",
        order = "a-d-a",
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        tile_width = 3,
        tile_height = 3,
        selectable_in_game = false,
        time_before_removed = 60 * 60 * 15,
        expires = false,
        final_render_layer = "remnants",
        remove_on_tile_placement = false,
        animation = {
            filename = "__advanced-pumpjacks__/graphics/mk" .. tier .. "/remnants_mk" .. tier .. ".png",
            line_length = 1,
            width = 274,
            height = 284,
            direction_count = 1,
            shift = util.by_pixel(0, 3.5),
            scale = 0.5
            --HR not supported yet
            --[[
            hr_version = {
                filename = "__advanced-pumpjacks__/graphics/mk" .. tier .. "/hr-remnants_mk" .. tier .. ".png",
                line_length = 1,
                width = 292,
                height = 264,
                frame_count = 1,
                direction_count = 4,
                shift = {0.8125, 0.5625},
                scale = 0.5
            }
          --]]
        }
    }
    -- log("Advanced Pumpjacks: corpse prototype [remnants_mk" .. tier .. "]:")
    -- log(serpent.block(corpse))

    ----------------------------------------
    -- REGISTER
    ----------------------------------------

    data:extend({entity, item, recipe, tech, corpse})
end




