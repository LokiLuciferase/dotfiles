# configure paths for config file and dirs
options.config = '~/.config/visidata/config.py'
options.visidata_dir = '~/.config/visidata'

# add quick movements like vim
Sheet.addCommand('^D', 'scroll-halfpage-down', 'cursorDown(nScreenRows//2); sheet.topRowIndex += nScreenRows//2')
Sheet.addCommand('^U', 'scroll-halfpage-up', 'cursorDown(-nScreenRows//2); sheet.topRowIndex -= nScreenRows//2')

# add key binds which I am bound to get wrong otherwise
Sheet.bindkey('i', 'edit-cell')
Sheet.bindkey('u', 'undo-last')

# visual defaults
options.default_width = 30

# guess column types
Sheet.addCommand('gr', 'guess-types', 'for c in visibleCols: c.type = guessTypeImp(c, visibleRows)')

def guessTypeImp(col, rows):
    if col.type is not anytype:
        return col.type

    max_to_check = 20
    curr_type = None
    for val in itertools.islice((col.getValue(r) for r in rows), max_to_check):
        if not str(val):
            continue
        try:
            fv = float(val)
            is_int = float(int(fv)) == fv
            if is_int:
                if curr_type is None:
                    curr_type = int
            else:
                curr_type = float
        except Exception:
            pass

    if curr_type is None:
        return anytype
    else:
        return curr_type
