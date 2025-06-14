fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_script 'config.lua'
shared_script '@es_extended/imports.lua'


client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'server.lua'
}
