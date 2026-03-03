data:extend({

  --------------------------------------------------
  -- BASE TIERS
  --------------------------------------------------
  {
    type = "int-setting",
    name = "apj-tier-count",
    setting_type = "startup",
    default_value = 3,
    minimum_value = 1,
    maximum_value = 10,
    order = "a"
  },
  {
    type = "bool",
    name ="apj-module-tier",
    setting_type = "startup",
    default_value = false,
    order = "b"
  }
  
  --------------------------------------------------
  -- SPACE AGE BALANCE MODE
  --------------------------------------------------
  --{
  --  type = "bool-setting",
  --  name = "apj-space-age-balance",
  --  setting_type = "startup",
  --  default_value = true,
  --  order = "b",
  --  hidden = not mods["space-age"]
  --}
  })




