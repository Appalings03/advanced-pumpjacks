local requested_tiers = settings.startup["apj-tier-count"].value
local modules_tiers = settings.startup["apj-tier-count"].value
local max_allowed = 6

if requested_tiers > max_allowed then
  log("Advanced Pumpjacks: Tier count clamped to " .. max_allowed)
end

local tier_count = math.min(requested_tiers, max_allowed)

local base_pumpjack = data.raw["mining-drill"]["pumpjack"]
local base_item = data.raw["item"]["pumpjack"]
local base_recipe = data.raw["recipe"]["pumpjack"]

-- Function to apply a tint to all layers of an animation or picture
local function tint_animation(animation, tint)
    if not animation then return end

    -- If animation uses layers, tint each layer
    if animation.layers then
        for _, layer in pairs(animation.layers) do
            if not layer.draw_as_shadow then
                layer.tint = tint
            end

            -- Handle hr_version inside layers
            if layer.hr_version then
                tint_animation(layer.hr_version, tint)
            end
        end
        return
    end

    -- No layers → direct sprite
    if not animation.draw_as_shadow then
        animation.tint = tint
    end

    -- Handle hr_version
    if animation.hr_version then
        tint_animation(animation.hr_version, tint)
    end
end

-- Function to get a gradient tint
local function get_tier_tint(tier)
    local colors = {
        -- mk2
        {r=0.1, g=0.4, b=1.0, a=1},   -- Bleu
        -- mk3
        {r=1.0, g=0.2, b=0.2, a=1},   -- Rouge
        -- mk4
        {r=0.1, g=0.9, b=0.9, a=1},   -- Cyan
        -- mk5
        {r=1.0, g=0.5, b=0.1, a=1},   -- Orange
        -- mk6
        {r=0.7, g=0.2, b=1.0, a=1},   -- Mauve  
        -- mk7
        {r=1.0, g=1.0, b=0.2, a=1},   -- Jaune
    }

    return colors[tier] or colors[1]
end
--------------------------------------------------
-- SPACE AGE BALANCE MODE
--------------------------------------------------


for i = 1, tier_count do
  local tier = i + 1
  local name = "pumpjack-mk" .. tier
  
  local energy_reduction = 0.05 * i
  local speed_bonus = 1 + (0.25 * i)
  
  ----------------------------------------
  -- ENTITY
  ----------------------------------------
  
  local entity = table.deepcopy(base_pumpjack)
  entity.name = name
  entity.minable.result = name
  entity.mining_speed = base_pumpjack.mining_speed * (1 + 0.25 * i)
  local base_energy = string.match(base_pumpjack.energy_usage, "([%d%.]+)")
  base_energy = tonumber(base_energy)
  local new_energy = base_energy * math.pow(1.5, i)
  new_energy = math.floor(new_energy / 10 + 0.5) * 10
  entity.energy_usage = tostring(new_energy) .. "kW"

  if i >= 2 then
    entity.base_productivity = 0.05 * (i - 1)
  else
    entity.base_productivity = 0
  end
  entity.resource_searching_radius = base_pumpjack.resource_searching_radius
  if modules_tiers then
    entity.module_inventory_size = i + 2 -- exemple : tiers 1 → 3 slots, tiers 2 → 4 slots, etc.
  end
  entity.allowed_effects = {"speed", "productivity", "consumption", "pollution"}
  -- Apply the gradient tint
  local tint = get_tier_tint(i)
  -- Apply tint to all relevant graphics of the entity
  tint_animation(entity.base_picture, tint)
  
  -- Apply tint to animation 
  if entity.working_visualisations then
    for _, vis in pairs(entity.working_visualisations) do
        tint_animation(vis.animation, tint)
    end
  end

----------------------------------------
-- ITEM
----------------------------------------

  local item = table.deepcopy(base_item)
  item.name = name
  item.place_result = name
  
  -- Layered icon: base icon + tinted overlay
    item.icons = {
        {icon = base_item.icon, icon_size = base_item.icon_size}, -- original
        {
            icon = base_item.icon,
            icon_size = base_item.icon_size,
            tint = tint
        }
    }
    item.icon = nil -- remove single icon to prevent conflict

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
    prerequisites = i == 1 and {"oil-processing"} or {"pumpjack-mk" .. (tier - 1)},
    effects = {
      {
        type = "unlock-recipe",
        recipe = name
      }
    },
    unit = {
      count = 200 * i,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 30
    },
    order = "d-a-" .. i
  }

  ----------------------------------------
  -- REGISTER
  ----------------------------------------

  data:extend({entity, item, recipe, tech})

end









