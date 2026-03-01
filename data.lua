local tier_count = settings.startup["apj-tier-count"].value

local base_pumpjack = data.raw["mining-drill"]["pumpjack"]
local base_item = data.raw["item"]["pumpjack"]
local base_recipe = data.raw["recipe"]["pumpjack"]

local function percent_energy_reduction(base_energy, percent)
  local value, unit = string.match(base_energy, "([%d%.]+)(%a+)")
  value = tonumber(value)
  value = value * (1 - percent)
  return tostring(value) .. unit
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
  entity.energy_usage = percent_energy_reduction(base_pumpjack.energy_usage, energy_reduction)

  ----------------------------------------
  -- ITEM
  ----------------------------------------

  local item = table.deepcopy(base_item)
  item.name = name
  item.place_result = name

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
    icon = base_pumpjack.icon,
    icon_size = base_pumpjack.icon_size,
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