local table = require('__stdlib__/stdlib/utils/table') --[[@as table]]

local equipment = {} ---@type Prototype.Equipment[]

for _, v in pairs(data.raw['night-vision-equipment']) do
    local t = table.deepcopy(v) --[[@as Prototype.NightVisionEquipment]]
    -- Keep the same localised name if none is specified
    t.localised_name = { 'disabled-equipment.disabled', t.localised_name or { 'equipment-name.' .. t.name } }
    -- Some mods don't specify take_result making it default to the equipment name.
    -- If we don't set it the game is going to look for an item with the wrong name.
    t.take_result = t.take_result or t.name
    t.name = 'picker-disabled-' .. t.name
    t.energy_input = '0kW'
    equipment[#equipment + 1] = t
end

for _, v in pairs(data.raw['active-defense-equipment']) do
    if v.automatic then
        local t = table.deepcopy(v) --[[@as Prototype.ActiveDefenseEquipment]]
        -- Keep the same localised name if none is specified
        t.localised_name = { 'disabled-equipment.disabled', t.localised_name or { 'equipment-name.' .. t.name } }
        -- Some mods don't specify take_result making it default to the equipment name.
        -- If we don't set it the game is going to look for an item with the wrong name.
        t.take_result = t.take_result or t.name
        t.energy_source.type = 'void'
        t.name = 'picker-disabled-' .. t.name
        t.automatic = false
        t.ability_icon = {
            filename = '__PickerInventoryTools__/graphics/discharge-defense-equipment-ability.png',
            height = 32,
            priority = 'medium',
            width = 32
        }
        equipment[#equipment + 1] = t
    end
end

data:extend(equipment)
