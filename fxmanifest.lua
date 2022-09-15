fx_version 'cerulean'

game 'gta5'

this_is_a_map 'yes'

lua54 'yes'

author 'ZiggJoJo'

version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}
