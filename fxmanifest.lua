fx_version 'cerulean'
games {'gta5'}
lua54 'yes'

author 'FelixL'
description 'CaliforniaLifeOnline- Boat Rental'
version '2.0.0'

client_script 'client/main.lua'
server_script 'server/main.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    '@es_extended/imports.lua'
}
