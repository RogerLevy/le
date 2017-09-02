\ Tiled support

le:
    import bu/mo/tmx
    import bu/mo/tilegame
    import le/oe/loadtmx
    import le/mo/tilemap
    import le/mo/tilcd

: get  ( layernode destcol destrow -- )
    3dup tilebuf addr-pitch extract  rot @wh tilebuf convert-tilemap ;

: open  ( map -- )  count opentmx  load-tiles ;

: map  ( -- <name> <filespec> )  ( -- map )  create <filespec> string, ;

var onhitmap  \ XT;  ( info -- )  must be assigned to something to enable tilemap collision detection
var mbx       \ map hitbox; exclusively for colliding with the TILEBUF; expressed in relative coords
var mby       \
var mbw       \
var mbh       \
augment


: onhitmap>  ( -- <code> ) r> code> onhitmap ! ;
: collide-objects-map  ( objlist tilesize -- )
    locals| tilesize |
    each>   x 2v@  mbx 2v@ x 2v+!  onhitmap @ if  mbw 2v@  tilesize  onhitmap @ collide-map  then
            x 2v! ;
