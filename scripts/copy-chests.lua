--(( Copy Chest ))--
local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')

local table = require('__stdlib__/stdlib/utils/table')
local interface = require('__stdlib__/stdlib/scripts/interface')

local chest_types = {
    ['container'] = true,
    ['logistic-container'] = true
}

local function copy_chest(event)
    local player, pdata = Player.get(event.player_index)
    local chest = player.selected
    pdata.copy_src = {}

    if chest then
        if not chest_types[chest.type] then
            return player.create_local_flying_text {text = {'chest.containers'}, position = chest.position}
        end

        if global.blacklisted_chests[chest.name] then
            return player.create_local_flying_text {text = {'chest.blacklisted', chest.localised_name}, position = chest.position}
        end

        local p_force, c_force = player.force, chest.force
        if not (p_force == c_force or c_force.name == 'neutral' or c_force.get_friend(p_force)) then
            return player.create_local_flying_text {text = {'cant-transfer-from-enemy-structures'}, position = chest.position}
        end

        local inventory = chest.get_inventory(defines.inventory.chest)
        if not inventory.is_empty() then
            pdata.copy_src.inv = chest.get_inventory(defines.inventory.chest)
            pdata.copy_src.surface = chest.surface
            pdata.copy_src.ent = chest
            player.create_local_flying_text {text = {'chest.copy-src'}, position = chest.position}
        else
            player.create_local_flying_text {text = {'chest.empty-src'}, position = chest.position}
        end
    end
end
Event.register('picker-copy-chest', copy_chest)

local function paste_chest(event)
    local player, pdata = Player.get(event.player_index)
    local chest = player.selected

    if chest then
        if not chest_types[chest.type] then
            return player.create_local_flying_text {text = {'chest.containers'}, position = chest.position}
        end

        local p_force, c_force = player.force, chest.force
        if not (p_force == c_force or c_force.name == 'neutral' or c_force.get_friend(p_force)) then
            return player.create_local_flying_text {text = {'cant-transfer-to-enemy-structures'}, position = chest.position}
        end

        if not (pdata.copy_src.inv and pdata.copy_src.inv.valid and not pdata.copy_src.inv.is_empty()) then
            pdata.copy_src = nil
            return player.create_local_flying_text {text = {'chest.no-copy-from'}, position = chest.position}
        end

        if global.blacklisted_chests[chest.name] then
            return player.create_local_flying_text {text = {'chest.blacklisted', chest.localised_name}, position = chest.position}
        end

        if pdata.copy_src.surface ~= chest.surface and not settings.global['picker-copy-between-surfaces'].value then
            return player.create_local_flying_text {text = {'chest.not-same-surface'}, position = chest.position}
        end

        local dest = chest.get_inventory(defines.inventory.chest)
        local src = pdata.copy_src.inv
        if dest == src then
            return player.create_local_flying_text {test = {'chest.same-inventory'}, position = chest.position}
        end

        local api_check = 'picker_chest_contents_mover_check'
        local interfaces = remote.interfaces
        for name in pairs(interfaces) do
            if interfaces[name][api_check] then
                if not remote.call(name, api_check, pdata.copy_src.ent, chest) then
                    break
                end
            end
        end

        --clone inventory 1 to inventory 2
        local count = dest.get_item_count()
        for i = 1, #src do
            local stack = src[i]
            if stack and stack.valid_for_read then
                local new_stack = {name = stack.name, count = stack.count, health = stack.health, durability = stack.durability}
                new_stack.ammo = stack.prototype.magazine_size and stack.ammo
                stack.count = stack.count - dest.insert(new_stack)
            end
        end
        if src.is_empty() then
            player.create_local_flying_text {text = {'chest.all-moved'}, position = chest.position}
            pdata.copy_chest = nil
        elseif count == dest.get_item_count() then
            player.create_local_flying_text {text = {'chest.none-moved'}, position = chest.position}
        else
            player.create_local_flying_text {text = {'chest.some-moved'}, position = chest.position}
        end
    end
end
Event.register('picker-paste-chest', paste_chest)

local function update_global()
    global.blacklisted_chests = global.blacklisted_chests or {}
end
Event.register(Event.core_events.init_and_config, update_global)

function interface.set_blacklisted_chests(names, remove)
    global.blacklisted_chests = global.blacklisted_chests or {}
    if type(names) == 'string' then
        global.blacklisted_chests[names] = (not remove and true) or nil
        return true
    elseif type(names) == 'table' then
        for _, name in pairs(names) do
            global.blacklisted_chests[name] = (not remove and true) or nil
        end
        return true
    end
end
function interface.get_blacklisted_chests()
    global.blacklisted_chests = global.blacklisted_chests or {}
    return table.keys(global.blacklisted_chests)
end
