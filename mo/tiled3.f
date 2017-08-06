\ TMX (Tiled) support
\ This version just provides access to the data and some conversion tools
\ It directly supports only a subset of features
\  - Object groups
\  - Single and Multiple image tilesets
\  - Tilemaps in Base64 uncompressed format (sorry no zlib, maybe later)
\  - Rectangles
\  - Referenced tileset files - in fact in an effort to salvage my sanity embedded tilesets are NOT supported.  Sorry.  (You ought to be using external tilesets anyway. ;)
\  - Layer Groups are NOT supported.  Sorry.

\ Maps MUST be stored in data/maps
\ You can access one TMX file at a time.
\ To preserve global ID coherence, when you load the tiles of a TMX file, ALL tileset nodes are loaded
\ into the system, freeing what was there before.  You can load other maps without reloading the
\ tiles, but you can't mix and match tilesets.

\ Programmer's rant:
\ I just want to say that Tiled is a classic example of passing time and thought onto the user ...
\ Why not support a simpler format or two in addition to the complex one?
\ And why all the tilemap format options?  Surely people could have hung with 2 or 3 instead of 5.
\ Why doesn't anyone understand what a serious issue this is?  Instead of one person solving a problem, they'd have hundreds of people deal with the unnecessary problems they created...

bu: idiom tiled:   \ BU is parent to limit coupling
    import bu/mo/nodes
    import bu/mo/cellstack
    import le/mo/xml
    import bu/mo/base64

private: 0 value map public:

100 cellstack tilesetdoms
100 cellstack layernodes
100 cellstack objgroupnodes

0 value lasttmx

: loadxml   file@  2dup xml  >r  drop free throw  r> ;

: load-objectgroups  map " objectgroup" eachel> objgroupnodes push ;
: load-layers  map " layer" eachel> layernodes push ;


: @source  " source" attr$ ;
: @name    " name" attr$ ;
: @width   " width" attr$ ;
: @height  " height" attr$ ;


: >tsx  @source loadxml ;
: load-tilesets
    tilesetdoms scount for  @+ dom-free  loop drop
    tilesetdoms 0 truncate
    map " tileset" eachel> >tsx tilesetdoms push ;
: >map   " map" 0 ?el[] not abort" File is not a recognized TMX file!" ;
: addpath  " data/maps/" 2swap strjoin ;
: closetmx  lasttmx ?dup -exit dom-free  0 to lasttmx ;
: opentmx  ( path c -- )  closetmx  addpath  loadxml dup to lasttmx  >root >map to map   load-tilesets  load-layers  load-objectgroups ;

\ : find-layer  ( adr c -- layernode | 0 )



\ Tilesets!
: #tilesets  tilesetdoms #pushed ;
: tileset[]  tilesetdoms [] @ >root ;
: multi-image?  ( tileset -- flag )  " image" 0 el[]? ;
: @firstgid  ( tileset -- gid )  " firstgid" $attr ;
: @image  ( tileset -- path c )  " image" 0 el[] @source ;
: @tilecount  ( tileset -- n )  " tilecount" attr ;
: @tile  ( tileset n -- local-id imagepath c )  " tile" rot el[]  dup " id" attr  swap " image" 0 el[] @source ;

\ Layers!
: #layers  layernodes #pushed ;
: layer[]  layernodes [] @ ;
: ?layer  ( name c -- layer | 0 )  \ find layer by name
    locals| c n |
    #layers for
        i layer[]  @name  n c compare 0= if
            i layer[]  unloop exit
        then
    loop  0 ;
: @layerwh  ( layer -- w h )  dup @width swap @height ;
: extract  ( layer dest pitch -- )  \ read out tilemap data, you'll probably need to process it.
    third @layerwh locals| h w pitch dest |  ( layer )
    here >r
    " data" 0 el[] @val b64, \ Base64, no compression!!!
    r@ w cells dest pitch h w cells 2move
    r> reclaim ;

\ Object groups!
