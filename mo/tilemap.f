    import bu/mo/tmx
    import bu/mo/tilegame
    import le/mo/loadtmx
le: role tilemap:
    import bu/mo/tmx
    import bu/mo/tilegame
    import le/mo/loadtmx
    import bu/mo/array2d
    
    var sx var sy   \ scroll values
    \ var wrap        \ wraparound enable
    var mw var mh   \ map width & height; either scroll will be clipped unless WRAP is on

2048 2048 array2d tilebuf

: tilemap
    displaywh mw 2v!
    draw>
        0 0 at
        at@ mw 2v@ scaled clip>
        sx 2v@ 20 20 scroll tilebuf addr  tilebuf @pitch  draw-tilemap-bg ;

: read  ( layernode destcol destrow -- )
    3dup tilebuf addr-pitch extract
    rot @wh tilebuf convert-tilemap ;

: open  ( map -- )  count opentmx  load-tiles ;

: map  ( -- <name> <filespec> )  ( -- map )
    create <filespec> string, ;

