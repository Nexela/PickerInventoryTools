require('__stdlib__/event/player').register_events(true)
require('__stdlib__/event/force').register_events(true)

require('scripts/filterfill')
require('scripts/copychests')
require('scripts/inventorysort')
require('scripts/chestlimit')

remote.add_interface(script.mod_name, require('__PickerExtended__/interface'))
