\ Basic Tiled support
\  Supports just objects and rectangles
\  Usage:
\   Make sure your layers' draw orders are set appropriately.
\   All layers are processed from bottom to top.  Layers are used just
\   for convenience in the editor / any grouping of objects is done code-side.

\   Rectangles require nothing special in the editor.  On the program side you need to assign LOADBOX.

\   External tilesets are supported.

\   Tileset information used:
\    type: will be interpreted as forth code
\    visible: can be used to hide things when disabled
\    width/height: not used yet
\    rotation: not used yet
\    flipping: not used yet
\    custom parameters: not used (for now.  stuff like tint will be added...)

\   When creating objects, if you give them a name, the string will be executed
\    instead of the type.
\   The type parameter of individual objects is ignored.

\   Text nodes are ignored, and can be used for comments

\   If you put a comment in an object's name, it effectively comments out the object and it won't
\   appear in the game.


le: idiom tiled:
    import bu/mo/xml
    import bu/mo/cellstack

defer loadbox  ( pen=xy w h container -- )  ' 3drop is loadbox
var onmapload  ( xn=xmlnode me=gameobject pen=xy -- )  \ call-address
var gid
ext
0 value tmx  \ just for debugging purposes.  root node of the map file's DOM.

private:
    0 value layer
    numattr width       width
    numattr height      height
    numattr firstgid    firstgid
    attrchecker source? source
    strattr source      source
    strattr name        name
    attrchecker name?   name
    numattr id          id
    strattr xntype      type
    numattr x           x
    numattr y           y
    numattr xngid       gid
    attrchecker xngid?  gid
    numattr visible     visible
    childnode image[]   image
    numattr tilecount   tilecount
    10000 cellstack bmps
    10000 cellstack spawners
public:

: onmapload>  r> swap onmapload ! ;
: /mapload  ( xn=xmlnode me=gameobject pen=xy -- )  onmapload @ call ;
: gid>spawner  ( n -- value )  spawners swap 1 - [] @ ;

private:
    : loadxml   file@  2dup xml  >r  drop free throw  r> ;
    : clearly   bmps scount cells bounds ?do  i @  i off  al_destroy_bitmap  cell +loop ;
    : addbmp  ( path c gid -- ) >r  s" data/maps/" 2swap strjoin loadbmp  r> bmps [] ! ;
    : /visible  visible 0= hide ! ;
    : instance  ( xn=xmlnode objlist gid -- )  dup  gid>spawner execute  gid !  /visible  /mapload ;
    : yfix  height negate peny +! ;
    : >map   " map" 0 ?el[] not abort" File is not a recognized TMX file!" ;
    : ?layer   name uncount find if  execute  else  drop objects  then  to layer ;
public:

: read-tiles  " tile" eachel>  id  0 image[] open>  source  addbmp ;
: read-tileset  ( node -- )
    open>
        name uncount find not if  drop  ['] one  then  ( xt )
        tilecount 0 do  dup spawners push  loop  drop
        source? if  source loadxml read-tiles  done  exit then
        xn read-tiles ;
: read-object  ( node -- )
    open>
        x y at
        xngid? if  yfix  then
        .xn
        name? if
            name evaluate  ( xn=xmlnode pen=xy )
        else
            xngid? if  layer xngid instance  else  width height layer loadbox  then
        then
;
: read-tilesets  " tileset" eachel>  read-tileset ;
: read-objectgroups  " objectgroup" eachel>  ?layer  " object" eachel>  read-object ;

: loadtmx  ( path count -- )
    {  clearly  loadxml  dup to tmx  fixed
        >map  dup  read-tilesets  read-objectgroups
        done  } ;
