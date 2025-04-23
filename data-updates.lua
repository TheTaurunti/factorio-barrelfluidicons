-- ===========
-- Setup Phase
-- ===========

local MAKE_FLUID_ICON_PRIMARY = settings.startup["BarrelFluidIcons-fluid-icon-primary"].value

local items = data.raw["item"]
local recipes = data.raw["recipe"]
local fluids = data.raw["fluid"]

-- =====

local function copy_icon_set(copy_from, copy_to)
  if (copy_from.icons)
  then
    copy_to.icons = table.deepcopy(copy_from.icons)
  else
    copy_to.icon = table.deepcopy(copy_from.icon)
  end
end

local function get_first_icon(prototype_base)
  if (prototype_base.icons)
  then
    return prototype_base.icons[1]
  else
    return {
      icon = prototype_base.icon,
      icon_size = prototype_base.icon_size,
      icon_mipmaps = prototype_base.icon_mipmaps
    }
  end
end

local function make_naming_pattern_obj(item_prefix, item_postfix, recipe_prefix, recipe_postfix)
  recipe_prefix = recipe_prefix or item_prefix
  recipe_postfix = recipe_postfix or item_postfix

  return {
    item_fluid_prefix = item_prefix,
    item_fluid_postfix = item_postfix,
    recipe_fluid_prefix = recipe_prefix,
    recipe_fluid_postfix = recipe_postfix
  }
end

-- =========================
-- Putting together the data
-- =========================

FLUIDS_TO_SKIP = {}
BARREL_LIKE_ITEMS_WITH_NAMING_PATTERNS = {}


-- Vanilla """"Compat""""
BARREL_LIKE_ITEMS_WITH_NAMING_PATTERNS["barrel"] = make_naming_pattern_obj("", "-barrel")


-- ============
-- Make changes
-- ============

for fluid_name, fluid_prototype in pairs(fluids) do
  if (not FLUIDS_TO_SKIP[fluid_name])
  then
    for barrel_like_item_name, naming_pattern in pairs(BARREL_LIKE_ITEMS_WITH_NAMING_PATTERNS) do
      local fill_recipe_name = naming_pattern.recipe_fluid_prefix .. fluid_name .. naming_pattern.recipe_fluid_postfix
      local item_name = naming_pattern.item_fluid_prefix .. fluid_name .. naming_pattern.item_fluid_postfix

      local filled_barrel_item = items[item_name]
      local fill_recipe = recipes[fill_recipe_name]
      if (filled_barrel_item and fill_recipe)
      then
        -- icon magic time
        local barrel_like_item = items[barrel_like_item_name]
        if (MAKE_FLUID_ICON_PRIMARY and barrel_like_item)
        then
          -- fluid icon mainly
          local fluid_icon = get_first_icon(fluid_prototype)
          local barrel_icon = get_first_icon(barrel_like_item)
          barrel_icon.scale = 0.25
          barrel_icon.shift = { -8, -8 }

          filled_barrel_item.icons = {
            fluid_icon,
            barrel_icon
          }
        else
          -- fill-barrel recipe icons are the easy way out.
          -- > Ideally, I would use the same functions as base implementation
          -- ... for automatic barrel recipes do, just substituting the barrel-like items
          copy_icon_set(fill_recipe, filled_barrel_item)
        end
      end
    end
  end
end
