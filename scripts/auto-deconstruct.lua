--------------------------------------------------------------------------------
--[[autodeconstruct]] --
--------------------------------------------------------------------------------
--"title": "Auto Deconstruct",
--"author": "mindmix",
--"description": "This mod marks drills that have no more resources to mine for deconstruction."

local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Entity = require('__stdlib__/stdlib/entity/entity')
local table = require('__stdlib__/stdlib/utils/table')
local add_tick = require('__PickerAtheneum__/scripts/ticker')

local targets =
    table.array_to_dictionary {
    'container',
    'logistic-container',
    'infinity-container'
}

local function has_targeters(entity)
    local filter = {force = entity.force, area = Area(entity.selection_box):expand(10), type = 'mining-drill'}
    for _, ent in pairs(entity.surface.find_entities_filtered(filter)) do
        if ent.drop_target == entity and not ent.to_be_deconstructed(entity.force) then
            return true
        end
    end
    return false
end

local function has_resources(drill)
    return drill.status ~= defines.entity_status.no_minable_resources
end

local function check_for_deconstruction(drill)
    if drill.valid and not drill.to_be_deconstructed(drill.force) and Entity.can_deconstruct(drill) and not has_resources(drill) and not Entity.has_fluidbox(drill) and not Entity.is_circuit_connected(drill) then
        if drill.order_deconstruction(drill.force) then
            if settings.global['picker-autodeconstruct-target'].value then
                local target = drill.drop_target
                if target and targets[target.type] and not Entity.is_circuit_connected(target) and Entity.can_deconstruct(target) and not has_targeters(target) then
                    target.order_deconstruction(drill.force)
                end
            end
        end
    end
end

local function on_resource_depleted(event)
    if settings.global['picker-autodeconstruct'].value then
        local resource = event.entity
        local filter = {type = 'mining-drill', area = Area(resource.selection_box):expand(10)}
        for _, drill in pairs(resource.surface.find_entities_filtered(filter)) do
            add_tick {
                func = check_for_deconstruction,
                params = drill
            }
        end
    end
end
Event.register(defines.events.on_resource_depleted, on_resource_depleted)

local function init()
    for _, surface in pairs(game.surfaces) do
        for _, drill in pairs(surface.find_entities_filtered {type = 'mining-drill'}) do
            check_for_deconstruction(drill)
        end
    end
end
Event.register(Event.core_events.init, init)
