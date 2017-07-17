\ Basic Tiled support (Module)

\ The module will be engine-agnostic and totally unaware of the "display list".  So it could be moved to Bubble at some point.  It's convenient to develop it within the Lantern file tree.
\
\ Small data such as headers are statically compiled.  Buffers for map data can be in the dictionary or you can supply them yourself.  You can cherrypick layers and reuse existing buffers.  You can process incoming data.
\
\ Of course the file format they devised assumes you're going to dynamically allocate everything as giant objects, but as we all know here, static compilation is the basis of a stable, fast program. :)

\  Features:
\   - read entire tmx into static data structure, also loading referenced images as assets
\   - open a tmx and cherrypick layers (tilemap, object, image) - compile statically, or, load data into arbitrary addresses (such as pre-existing tmx structures)

\  Stuff I want:
\   [ ] Tilemap support
\   [ ] Paths
\   [ ] Polygons
\   [ ] Text?!?!?



le: idiom tiled:
    import bu/mo/nodes
    import bu/mo/xml
    import bu/mo/cellstack

quality firstgid
quality 'onMapLoad  ( O=node -- )

private: 5000 cellstack bmps \ bitmaps
public:

defer onLoadBox  ( pen=xy -- )
:noname [ is onLoadBox ] cr ." WARNING: onLoadBox is not defined!" ;

: onMapLoad:  ( class -- <code;> )  :noname swap 'onMapLoad ! ;
: onMapLoad  ( O=node -- )  me class @ 'onMapLoad @ execute ;

: gid>class  ( n -- class )
  locals| n |
  lastClass @
  begin  dup firstgid @ 1 - n u<  over prevClass @ 0 =  or  not while
    prevClass @
  repeat  ;

: clearbgimages
    bgObjTable 1024 0 do  @+ ?dup if  al_destroy_bitmap  then  loop  drop
    bgObjTable 1024 ierase ;

: addBGImage  ( dest path c -- dest+cell )
    " data/maps/" s[ +s ]s zstring al_load_bitmap !+ ;

: bgobjtile ( dest node -- dest )  " image" 0 el  &o for>  " source" attr$ addBGImage ;

: bgobj?   " name" attr$ " bgobj" compare 0= ;

: readTileset  ( node -- )
  &o for>
  " firstgid" attr   " name" attr$ evaluate one  firstgid !
  bgobj? -exit  clearbgimages  bgobjtable  o " tile" ['] bgobjtile eachel  drop ;

\ utility word ?PROP: read custom object property
\ use the O register

\ children only consists of elements called "property" so no need to check the names of the elements
: (prop)  ( addr c node -- addr c  continue | node stop )
  &o for>  o element? -exit  2dup  " name" attr$  compare 0= if  O true  else  0  then ;

: ?prop$  ( addr c -- false | adr c )
  o " properties" 0 ?el 0= if  2drop  false exit then
  ['] (prop) scan   nip nip  dup -exit  &o for>  " value" attr$ ;

: ?prop  ( adr c -- false | val true )  ?prop$ dup -exit  evaluate true ;

: instance  ( class -- )  one  onMapLoad ;
: *instance  ( gid -- )  gid>class instance ;

: yfix  " height" attr negate peny +! ;

: readObject  ( node -- )
  &o for>
  " x" attr " y" attr  at
  " gid" ?attr if  drop  yfix  then
  cr o .element
  " name" ?attr$ if  evaluate
  else
    " gid" ?attr if  *instance
                 else  onLoadBox  then
  then
;

: readObjectGroup  " object" ['] readObject eachel ;
: (tilesets)  " tileset" ['] readTileset eachel ;
: (objgroups)  " objectgroup" ['] readObjectgroup eachel ;

: clearGIDs  ( -- )
  firstClass @  begin  ?dup while  #-1 over firstGID !  nextClass @  repeat ;

0 value tmx

: loadTMX  ( path count -- )
  me >r
  clearGIDs
  file@  2dup xml  to tmx
    drop free throw
  fixed
  tmx  " map"  0  ?el not abort" File is not TMX format!"
    dup (tilesets) (objgroups)
  done
  r> as ;
