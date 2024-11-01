-- ===========
-- Setup Phase
-- ===========

local MAKE_FLUID_ICON_PRIMARY = settings.startup["BarrelFluidIcons-fluid-icon-primary"].value

local items = data.raw["item"]
local recipes = data.raw["recipe"]
local fluids = data.raw["fluid"]


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

local fluid_barrels = {}
NON_FLUID_BARRELS = {
	["empty-barrel"] = true
}

-- Compat
require("compatibility.data-updates.dirty-fluid-containers")
require("compatibility.data-updates.pyalienlife")


-- Stage 1
for _, item in pairs(items) do
	if (string.find(item.name, "-barrel") and not NON_FLUID_BARRELS[item.name])
	then
		fluid_barrels[item.name] = {
			item_prototype = item,
			recipe_fill = nil,
			recipe_empty = nil,
			fluid = nil
		}
	end
end

-- Stage 2
for barrel_name, data_table in pairs(fluid_barrels) do
	local fill_recipe_name = barrel_name
	local empty_recipe_name = "empty-" .. barrel_name

	if (recipes[fill_recipe_name])
	then
		data_table.recipe_fill = recipes[fill_recipe_name]
	end

	if (recipes[empty_recipe_name])
	then
		data_table.recipe_empty = recipes[empty_recipe_name]

		local fluid_name = get_recipe_result(recipes[empty_recipe_name])
		local fluid_prototype = get_fluid(fluid_name)
		data_table.fluid = fluid_prototype
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

-- ===============================================
-- DATA GATHERING COMPLETE!! TIME TO CHANGE THINGS
-- ===============================================

-- set icons based on fluid prototype icon, and the actual recipe/barrel icon.
for _, data_table in pairs(fluid_barrels) do
	local item_prototype = data_table.item_prototype
	local empty_barrel = data.raw["item"]["barrel"]

	if (MAKE_FLUID_ICON_PRIMARY and empty_barrel)
	then
		log(_)

		local fluid_icon = get_first_icon(data_table.fluid)
		local barrel_icon = get_first_icon(empty_barrel)
		barrel_icon.scale = 0.25
		barrel_icon.shift = { -8, -8 }

		item_prototype.icons = {
			fluid_icon,
			barrel_icon
		}
	else
		item_prototype.icons = table.deepcopy(data_table.recipe_fill.icons)
	end
end
