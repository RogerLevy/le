le: role tilemap:
    import bu/mo/tilegame
    import bu/mo/array2d
    
    var sx var sy   \ scroll values
    \ var wrap        \ wraparound enable
    var mw var mh   \ map width & height; either scroll will be clipped unless WRAP is on

2048 2048 array2d tilebuf

: tilemap
    displaywh mw 2v!
    draw>
        at@ mw 2v@ scaled clip>
        sx 2v@ 20 20 scroll tilebuf addr  tilebuf @pitch  draw-tilemap-bg ;

: @tile  ( col row -- tile )  tilebuf addr @ ;
: >gid  ( tile -- gid )  $0000fffc and 8 << ;
