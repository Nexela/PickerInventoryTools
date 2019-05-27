-------------------------------------------------------------------------------
--[Item Zapper]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Position = require('__stdlib__/stdlib/area/position')

local evt = defines.events

local function zapper(event)
    local player, pdata = Player.get(event.player_index)
    local name = (player.cursor_stack.valid_for_read and player.cursor_stack.name)

    if name then
        local all = player.mod_settings['picker-item-zapper-all'].value

        if all or global.planners[name] ~= nil or default_destroy[name] then
            if (pdata.last_dropped or 0) + 30 < game.tick then
                pdata.last_dropped = game.tick
                player.cursor_stack.clear()
                player.surface.create_entity {
                    name = 'drop-planner',
                    position = Position(player.position):translate(math.random(0, 7), 1)
                }
            end
        end
    end
end
--Event.register('picker-zapper', zapper)

local function dropper(event)
    if event.entity.stack and default_destroy[event.entity.stack.name] then
        local player = game.players[event.player_index]
        player.surface.create_entity {
            name = 'drop-planner',
            position = event.entity.position
        }
        event.entity.destroy()
    end
end
--Event.register(evt.on_player_dropped_item, dropper)

local trash_types = {
    ['blueprint'] = true,
    ['blueprint-book'] = true,
    ['deconstruction-item'] = true,
    ['selection-tool'] = true,
}

local function trash_planners(event)
    local player = game.players[event.player_index]
    local settings = player.mod_settings

    local inventory = player.get_inventory(defines.inventory.character_trash)
    if inventory then
        if player.cheat_mode and settings['picker-trash-cheat'].value then
            inventory.clear()
        elseif settings['picker-trash-planners'].value then
            for i = 1, #inventory do
                local slot = inventory[i]
                if slot.valid_for_read and trash_types[slot.type] then
                    slot.clear()
                    return
                end
            end
        end
    end
end
Event.register(defines.events.on_player_trash_inventory_changed, trash_planners)

--[[




--]]
