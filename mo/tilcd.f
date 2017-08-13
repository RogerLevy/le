\ Simple tilemap collision - could be superceded later with "v2" added or a new name
\ Treats all non-zero tiles as solid.  No slope support.  To have tiles that don't have collision,
\ put them on another layer and don't perform collision on that.
\ You can move an object against the tilemap and also perform a check on every tile underneath
\ the object.

\ This is exclusive to Lantern and uses its tilemap module (unified 2048x2048 tilemap)

le: idiom tilcd:
    import bu/mo/array2d
    import bu/mo/rect
    import le/mo/tilemap

create tileprops  #16384 /allot  \ you could screw around with this to do one-way platforms
tileprops #1 + #16383 $ff cfill

private:
    : vector   create 0 , here 0 , constant ;
public:

\ what sides the object collided
variable lwall?
variable rwall?
variable floor?
variable ceiling?

private:
    defer map-collide   ' drop is map-collide  ( gid -- )

    : cel? 1 and ; \ ' ceiling '
    : flr? 2 and ; \ ' floor '
    : wlt? 4 and ; \ ' wall left '
    : wrt? 8 and ; \ ' wall right '

    : p@  ( gid )  1i tileprops + c@ ;

    vector w h
    vector nx ny
    variable t

    16 value gap

    : px x @ ;
    : py y @ ;

    \ point
    : pt  @tile >gid  dup t ! p@ ;

    \ increment coordinates
    : ve+ swap gap + w @ #1 - px + min swap ;
    : he+ gap + h @ #1 - ( py ) ny @ + min ;

    : +vy ny +! ny @ ( $ffff0000 and dup ny ! ) py - vy ! ;
    : +vx nx +! nx @ ( $ffff0000 and dup nx ! ) px - vx ! ;

    \ push up/down
    : pu ( xy ) nip gap mod negate +vy  floor? on  t @ map-collide  ;
    : pd ( xy ) nip gap mod negate gap + +vy  ceiling? on  t @ map-collide  ;

    \ check up/down
    : cu w @ gap / 2 + for 2dup pt cel? if pd r> drop exit then ve+ loop 2drop ;
    : cd w @ gap / 2 + for 2dup pt flr? if pu r> drop exit then ve+ loop 2drop ;


    \ push left/right
    : pl ( xy ) drop gap mod negate ( -1.0 + ) +vx rwall? on t @ map-collide ;
    : pr ( xy ) drop gap mod negate gap + +vx lwall? on t @ map-collide ;

    \ check left/right
    : cl h @ gap / 2 + for 2dup pt wrt? if pr r> drop exit then he+ loop 2drop ;
    : crt h @ gap / 2 + for 2dup pt wlt? if pl r> drop exit then he+ loop 2drop ;

    \ check if object's path crosses tile boundaries in the 4 directions...
    : dcros? py h @ #1 -  + gap /  ny @ h @ #1 - + gap / < ;
    : ucros? py gap /  ny @ gap /  > ;
    : rcros? px w @ #1 -  + gap /  nx @ w @ #1 - + gap / < ;
    : lcros? px gap /  nx @ gap /  > ;

    : ud vy @ -exit vy @ 0 < if ( ucros? -exit ) px ny @ cu exit then ( dcros? -exit ) px ny @ h @ + cd ;
    : lr vx @ -exit vx @ 0 < if ( lcros? -exit ) nx 2v@ cl exit then ( rcros? -exit ) nx @ w @ + ny @ crt ;

    : init   to gap  w 2v!  x 2v@  vx 2v@  2+  nx 2v!  lwall? off rwall? off floor? off ceiling? off ;
    0 value (code)

public:
: collide-map ( w h tilesize xt -- )  is map-collide  init ud lr ;
: tiles>   ( w h tilesize -- <code> )  ( gid -- )
    to gap  w 2v!
    r> to (code)
    x 2v@ at
    h @ gap / pfloor 1 max for
        at@ 2>r
        w @ gap / pfloor 1 max for
            at@ @tile >gid (code) call  gap 0 +at
        loop
        2r> gap + at
    loop  drop ;


