local Data = require('__stdlib__/stdlib/data/data')
local Item = require('__stdlib__/stdlib/data/item')
local Table = require('__stdlib__/stdlib/utils/table')

if settings.startup['picker-moveable-chests'].value then
    local chest_types = {'container', 'logistic-container', 'cargo-wagon'}
    local skip_chests = {
        ['bait-chest'] = true,
        ['compilatron-chest'] = true,
        ['crash-site-chest-1'] = true,
        ['crash-site-chest-2'] = true,
        ['big-ship-wreck-1'] = true,
        ['big-ship-wreck-2'] = true,
        ['big-ship-wreck-3'] = true,
        ['red-chest'] = true,
        ['blue-chest'] = true,
        ['compi-logistics-chest'] = true,
        ['infinity-cargo-wagon'] = true
    }

    Data {
        name = 'picker-moveable',
        type = 'item-subgroup',
        group = 'other'
    }

    local default = Item('wooden-chest', 'item')
    local count = 0

    for _, container_type in pairs(chest_types) do
        for _, container in Data:pairs(container_type) do
            if not (skip_chests[container.name] or container.not_inventory_moveable) then
                local item = Item(container.name)

                Data {
                    name = 'picker-moveable-' .. container.name,
                    type = 'item-with-inventory',
                    place_result = container.name,
                    subgroup = 'picker-moveable',
                    -- item_subgroup_filters = {'picker-moveable'},
                    -- filter_mode = 'blacklist',
                    icon = item.icon or default.icon,
                    icons = Table.deep_copy(item.icons or default.icons or nil),
                    icon_size = item.icon_size or default.icon_size,
                    icon_mipmaps = item.icon_mipmaps or default.icon_mipmaps,
                    localised_name = {'item-name.picker-moveable', {'entity-name.' .. container.name}},
                    stack_size = 1,
                    flags = {'hidden', 'not-stackable'},
                    inventory_size = container.inventory_size,
                    order = 'z[picker-moveable]-' .. (container.order or ''),
                    insertion_priority_mode = 'never'
                }
                count = count + 1
            end
        end
    end
    __DebugAdapter.print('Created ' .. count .. ' moveable chests.')
end
