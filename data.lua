local requested_tiers = settings.startup["apj-tier-count"].value
local max_allowed = 6

if requested_tiers > max_allowed then
  log("Advanced Pumpjacks: Tier count clamped to " .. max_allowed)
end

local tier_count = math.min(requested_tiers, max_allowed)

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
local function hsl_to_rgb(h, s, l)
    local c = (1 - math.abs(2 * l - 1)) * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = l - c/2
    local r, g, b = 0, 0, 0

    if h < 60 then r,g,b = c,x,0
    elseif h < 120 then r,g,b = x,c,0
    elseif h < 180 then r,g,b = 0,c,x
    elseif h < 240 then r,g,b = 0,x,c
    elseif h < 300 then r,g,b = x,0,c
    else r,g,b = c,0,x end

    return {
    r = r + m,
    g = g + m,
    b = b + m,
    a = 1
  }
end

local function get_tier_tint(tier, max_tier)
    local num_tints = 6  -
    local h_start = 120 
    local s = 1.0 
    local l_start = 0.4 
    local l_end = 0.7 

    local index = math.floor((tier - 1) / max_tier * (num_tints - 1)) + 1
    if index < 1 then index = 1 end
    if index > num_tints then index = num_tints end

    local hue = h_start + (index - 1) * 20   
    local light = l_start + (l_end - l_start) * ((index - 1)/(num_tints - 1))

    return hsl_to_rgb(hue, s, light)
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
  entity.mining_speed = base_pumpjack.mining_speed * speed_bonus
  entity.energy_usage = percent_energy_increase(base_pumpjack.energy_usage, energy_reduction)
  
  -- Apply the gradient tint
  local tint = get_tier_tint(i, tier_count)
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






