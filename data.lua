local tier_count = settings.startup["apj-tier-count"].value

local base_pumpjack = data.raw["mining-drill"]["pumpjack"]
local base_item = data.raw["item"]["pumpjack"]
local base_recipe = data.raw["recipe"]["pumpjack"]

local function percent_energy_increase(base_energy, percent)
  local value, unit = string.match(base_energy, "([%d%.]+)(%a+)")
  value = tonumber(value)
  value = value * (1 + percent)
  return tostring(value) .. unit
end

-- Function to apply a tint to all layers of an animation or picture
local function tint_entity_layers(animation, tint)
    if not animation then return end
    if animation.layers then
        for _, layer in pairs(animation.layers) do
            if not layer.draw_as_shadow then
                layer.tint = tint
            end
        end
    else
        if not animation.draw_as_shadow then
            animation.tint = tint
        end
    end
end

-- Function to get a gradient tint from green (base) to red (max tier)
local function get_tier_tint(tier, max_tier)
    local t = tier / max_tier
    return {
        r = 0.5 + (1.0 - 0.5) * t,   -- 0.5 -> 1.0
        g = 1.0 - (1.0 - 0.0) * t,   -- 1.0 -> 0.0
        b = 0.5 - (0.5 - 0.0) * t,   -- 0.5 -> 0.0
        a = 1
    }
end

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
  entity.mining_speed = base_pumpjack.mining_speed * speed_bonus
  entity.energy_usage = percent_energy_increase(base_pumpjack.energy_usage, energy_reduction)

  -- Apply the gradient tint
    local tint = get_tier_tint(i, tier_count)
    tint_entity_layers(entity.base_picture, tint)
    tint_entity_layers(entity.animations.north, tint)
    tint_entity_layers(entity.animations.east, tint)
    tint_entity_layers(entity.animations.south, tint)
    tint_entity_layers(entity.animations.west, tint)

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

