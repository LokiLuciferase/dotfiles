# configure paths for config file and dirs
options.config = '~/.config/visidata/config.py'
options.visidata_dir = '~/.local/share/visidata'

# add quick movements like vim
Sheet.addCommand('^D', 'scroll-halfpage-down', 'cursorDown(nScreenRows//2); sheet.topRowIndex += nScreenRows//2')
Sheet.addCommand('^U', 'scroll-halfpage-up', 'cursorDown(-nScreenRows//2); sheet.topRowIndex -= nScreenRows//2')

# add key binds which I am bound to get wrong otherwise
Sheet.bindkey('i', 'edit-cell')
Sheet.bindkey('u', 'undo-last')

# visual defaults
options.default_width = 30
