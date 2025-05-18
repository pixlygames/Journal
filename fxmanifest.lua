fx_version 'cerulean'
game 'gta5'

author 'Pixly Games'
description 'Journal System'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/img/*.gif'
}

lua54 'yes' 