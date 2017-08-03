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


bu: idiom tiled:
    import bu/mo/xml
    import le/obj
    import bu/mo/cellstack
    import bu/mo/draw

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
    attrchecker xntype? type
    numattr x           x
    numattr y           y
    numattr xngid       gid
    attrchecker xngid?  gid
    numattr visible     visible
    attrchecker visible?  visible
    childnode image[]   image
    numattr tilecount   tilecount
    10000 cellstack bmps
    10000 cellstack spawners
public:

: onmapload>  r> swap onmapload ! ;
: /mapload  ( xn=xmlnode me=gameobject pen=xy -- )  onmapload @ ?dup -exit call ;
: gid>spawner  ( n -- value )  1 - spawners [] @ ;

private:
    : eval  ['] evaluate catch ?dup if cr bright ." TMX script error:" space  .catch normal  2drop then ;
    : loadxml   file@  2dup xml  >r  drop free throw  r> ;
    : clearly   bmps scount cells bounds ?do  i @  i off  al_destroy_bitmap  cell +loop ;
    : addpath  " data/maps/" 2swap strjoin ;
    : /visible  visible? -exit  visible 0= hide ! ;
    : instance  ( xn=xmlnode objlist gid -- )  dup  >r  gid>spawner execute  r>  gid !  /visible  /mapload ;
    : yfix  height negate peny +! ;
    : >map   " map" 0 ?el[] not abort" File is not a recognized TMX file!" ;
    : ?layer   dup open>  name uncount find if  execute  else  drop  objects  then  to layer  ;
    : >tileset  " tileset" 0 el[] ;
    : >image  0 image[] ;
    : spawner  type? if  xntype find  not if  drop  ['] one  then   else  ['] one  then  ;

public:

variable gidbase
: get-tile-image  ( gid -- bitmap )  gidbase @ +  >image open>  source addpath loadbmp  ;
: read-tiles  ( xmlnode -- )
    open>
        name uncount find not if  drop  ['] one  then  ( xt )
        tilecount 0 do  dup spawners push  loop  drop
        xn " tile" 0 el[]?
            if  xn  " tile"  EACHEL>  OPEN>  id  get-tile-image
            else  0  add-tile-image
            then
;
: read-tileset  ( xmlnode -- )
    open> 
        firstgid gidbase !
        source? if  source addpath loadxml >tileset read-tiles  done  exit then
        xn read-tiles ;
: read-object  ( xmlnode -- )
    open>
        x y at
        xngid? if  yfix  then
        name? if
            name eval  ( xn=xmlnode pen=xy )
        else
            xngid? if  layer xngid instance  else  width height layer loadbox  then
        then
;
: read-tilesets  ( xmlnode -- ) " tileset" eachel>  read-tileset ;
: read-objectgroups  ( xmlnode -- ) " objectgroup" eachel>  ?layer
    " object" eachel>  read-object ;

: loadtmx  ( path count -- )
    {  clearly  loadxml  dup to tmx  fixed
        >map  dup  read-tilesets  read-objectgroups
        done  } ;
