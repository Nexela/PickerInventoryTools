require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)

require('scripts/filterfill')
require('scripts/copychests')
require('scripts/inventorysort')
require('scripts/chestlimit')
require('scripts/auto-trash-fix')
require('scripts/auto-stock')
require('scripts/item-count')

remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
