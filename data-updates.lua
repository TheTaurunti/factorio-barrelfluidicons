-- ===========
-- Setup Phase
-- ===========

-- local MAKE_FLUID_ICON_PRIMARY = settings.startup["BarrelFluidIcons-fluid-icon-primary"].value

local items = data.raw["item"]
local recipes = data.raw["recipe"]
--local fluids = data.raw["fluid"]

local fluid_barrels = {}

-- =========================
-- Defining helper functions
-- =========================

local function get_recipe_result(recipe)
  local recipe_standard = recipe.normal or recipe
  return (
    recipe_standard.results and recipe_standard.results[1] and (
      recipe_standard.results[1].name
      or recipe_standard.results[1][1]
    )
  ) or recipe_standard.result
end

local function get_fluid(fluid_name)
  for _, fluid in pairs(fluids) do
    if (fluid.name == fluid_name)
    then
      return fluid
    end
  end
end

-- =========================
-- Putting together the data
-- =========================

-- Stage 1
for _, item in pairs(items) do
  if (string.find(item.name, "-barrel") and item.name ~= "empty-barrel")
  then
    fluid_barrels[item.name] = {
      item = item,
      recipe_fill = nil,
      recipe_empty = nil,
      fluid = nil
    }
  end
end

-- Stage 2
for barrel_name, data_table in pairs(fluid_barrels) do
  local fill_recipe_name = "fill-" .. barrel_name
  local empty_recipe_name = "empty-" .. barrel_name

  if (recipes[fill_recipe_name])
  then
    data_table.recipe_fill = recipes[fill_recipe_name]
  end

  if (recipes[empty_recipe_name])
  then
    data_table.recipe_empty = recipes[empty_recipe_name]

    -- local fluid_name = get_recipe_result(recipes[empty_recipe_name])
    -- local fluid_prototype = get_fluid(fluid_name)
    -- data_table.fluid = fluid_prototype
  end
end

-- ===============================================
-- DATA GATHERING COMPLETE!! TIME TO CHANGE THINGS
-- ===============================================

-- set icons based on fluid prototype icon, and the actual recipe/barrel icon.
for _, data_table in pairs(fluid_barrels) do
  local item = data_table.item

  item.icons = table.deepcopy(data_table.recipe_fill.icons)

  -- if (MAKE_FLUID_ICON_PRIMARY)
  -- then
  --   -- need to swap icons
  -- end

  -- local barrel_icon_primary = (MAKE_FLUID_ICON_PRIMARY and data_table.recipe_fill.icons[1]) or data_table.recipe_fill
  -- local barrel_icon_secondary = (MAKE_FLUID_ICON_PRIMARY and data_table.recipe_fill) or data_table.recipe_fill.icons[1]


  -- "lite" behavior is to just use the fill-barrel icons for the barrel item.

  -- "full" behavior is to do same as above, but swap the fluid/barrel locations so the fluid is
  -- ... more prominent

  -- For fill/empty recipes, it doesn't feel necessary to change the icons.
  -- local fill_recipe_icon_primary = 1
  -- local fill_recipe_icon_secondary = 1
  -- local empty_recipe_icon_primary = 1
  -- local empty_recipe_icon_secondary = 1
end
