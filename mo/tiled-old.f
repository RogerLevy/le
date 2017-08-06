\ Basic Tiled support
\  Supports just objects and rectangles
\  Usage:
\   Make sure your layers' draw orders are set appropriately.
\   All layers are processed from bottom to top.
\   Layer names are searched in the dictionary; if found they are evaluated
\    and they must return a container.  If not found the default OBJECTS container
\    is used instead.  The container is passed to the forth code in each object's type field
\    or name field.

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

\   Text nodes are ignored, and can be used for comments

\   If you put a comment in an object's name, it effectively comments out the object and it won't
\   appear in the game.


le: idiom tiled:
    import bu/mo/nodes
    import bu/mo/xml
    import bu/mo/cellstack

defer loadbox  ( pen=xy w h -- )

var on-mapload  ( O=xmlnode -- )

private:
    10000 cellstack bmps
    10000 cellstack classes
public:

:noname [ is loadbox ]  cr  ." Notice: LOADBOX hasn't been assigned anything." ;

: on-mapload:  ( class -- <code;> )  :noname swap 'onMapLoad ! ;
: /map-load  ( O=xmlnode -- )  me class @ on-mapload @ execute ;

: gid>class  ( n -- class )
  locals| n |  classes swap [] @ ;

private:
    : clear
        bmps scount cells bounds 0 do  i @  i off  al_destroy_bitmap  cell +loop
        bmps 0 truncate
        classes scount ierase ;

    variable gid

    : addbmp  ( dest  path c -- dest+cell )
        " data/maps/" 2swap strjoin zstring al_load_bitmap bmps  ;

    : read-bmp ( node -- )  " image" 0 el &O with>  " source" $@ addbmp  ;
public:


: read-tileset  ( node -- )
    &O with>
        " firstgid" n@   " name" $@  evaluate  objects one  gid !
        " name" " bgobj" $@= -exit
        clear  O  " tile" eachel>  read-bmp ;

\ utility word ?PROP: read custom object property
\ use the O register

\ children only consists of elements called "property" so no need to check the names of the elements
: (prop)  ( addr c node -- addr c  continue | node stop )
    &O with>  O element? -exit  2dup  " name" $@  compare 0= if  O true  else  0  then ;

: ?prop$  ( addr c -- false | adr c )
    O " properties" 0 ?e not if  2drop  false exit then
    ['] (prop) scan   nip nip  dup -exit  &o with>  " value" $@ ;

: ?prop  ( adr c -- false | val true )  ?prop$ dup -exit  evaluate true ;

private:
    : instance  ( gid -- )  gid>class " *" 2swap strjoin on-mapload ;
public:

: yfix  " height" n@ negate peny +! ;

: read-object  ( node -- )
    &O with>
    " x" " y" 2n@  at
    " gid" ?n@ if  drop  yfix  then
    cr O .element
    " name" ?$@ if
        evaluate
    else
        " gid" ?n@ if  instance  else  " width" " height" 2n@  loadbox  then
    then
;

: read-tilesets  " tileset" eachel> read-tileset ;
: read-objectgroups  " objectgroup" read-objectgroup eachel> " object" eachel> read-object ;

private:  : check   " map"  0  ?e not abort" File is not a recognized TMX file!" ;
public:

0 value tmx

: loadxml   file@  2dup xml  to tmx  drop free throw ;

: loadtmx  ( path count -- )
  {  ( clearGIDs )  loadxml  fixed  tmx  check  dup  read-tilesets  read-objectgroups  done  } ;

