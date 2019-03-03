data:extend {
    {
        type = 'bool-setting',
        name = 'picker-auto-sort-inventory',
        setting_type = 'runtime-per-user',
        default_value = true,
        order = 'a'
    },
    {
        name = 'picker-fix-trash-filters',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        name = 'picker-auto-stock',
        setting_type = 'runtime-per-user',
        type = 'bool-setting',
        default_value = true
    },
    {
        type = 'bool-setting',
        name = 'picker-item-count',
        setting_type = 'runtime-per-user',
        default_value = false,
        order = 'picker-b[itemcount]-a'
    },
}

-- Picker Autodeconstruct
data:extend {
    {
        type = 'bool-setting',
        name = 'picker-autodeconstruct',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'picker-autodeconstruct-a'
    },
    {
        type = 'bool-setting',
        name = 'picker-autodeconstruct-target',
        setting_type = 'runtime-global',
        default_value = true,
        order = 'picker-autodeconstruct-b'
    }
}
