\ Flipbook animation mixin

\ Example usage:
\ flipbook: myanm  myimage.image , 0 , 1 , [loop] 2 , 3 , ;
\ ...
\    myanm  \ starts the animation
\    draw> 1 animate @ img @ afsubimg  at@ 2af  flip@  al_draw_bitmap_region ;

var img    \ current image used for animation; animation data defines which subimage to display
var anmspd
var anm  \ animation pointer
    \ internal:
    var ctr  \ animation counter
    var anmstart

: ?anmloop  anm @ @ 0 >= ?exit  anm @ cell+ @ anm ! ;
: @anm+  ( -- val )  \ higher speed = slower animation; adr points to a cell in the animation data
    anm @ @  anmspd @ -exit  1 ctr +!  ctr @ anmspd @ >= if  0 ctr !  cell anm +!  ?anmloop  then  ;
: flipbook:  ( -- <name> [data] loopdest )  ( speed -- )  \ first cell should be an image
    create  here cell+ ( loopdest )  [char] ; parse evaluate  -1 ,  ( loopdest ) , ;
: [loop]  drop here ;
: animate  ( animation speed -- )  anmspd !   dup anmstart !  @+  img !  anm ! ;
: @playing  ( -- animation )  anmstart @ ;
: end-of-anm?  ( -- flag )  anm @ @ -1 = ;
