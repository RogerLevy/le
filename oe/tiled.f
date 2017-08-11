\ Tiled support

le:
    import bu/mo/tmx
    import bu/mo/tilegame
    import le/oe/loadtmx
    import le/mo/tilemap

: read  ( layernode destcol destrow -- )
    3dup tilebuf addr-pitch extract
    rot @wh tilebuf convert-tilemap ;

: open  ( map -- )  count opentmx  load-tiles ;

: map  ( -- <name> <filespec> )  ( -- map )
    create <filespec> string, ;

