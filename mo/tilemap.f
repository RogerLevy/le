import bu/mo/tilegame     \ accessory
obj: role tilemap:
    import bu/mo/tilegame
    var sx var sy   \ scroll values
    var wrap        \ wraparound enable
    var mw var mh   \ map width & height; either scroll will be clipped unless WRAP is on

create tilebuf 16 megs /allot  ( 2048x2048 tiles )

: tilemap  
