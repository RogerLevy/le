\ Sprite game object mixin

import bu/mo/draw
var sx var sy var ang var orgx var orgy var flip
var r var g var b var a
\ var bmode

(  ALLEGRO_BITMAP-*bitmap float-sx float-sy float-sw float-sh float-r float-g float-b float-a float-cx float-cy float-dx float-dy float-xscale float-yscale float-angle int-flags -- )
: draw-sprite-region  ( bmp af-srcx af-srcy af-srcw af-srch -- )
    r 4@ 4af  orgx 2@ at@ 4af  sx 2@  ang @  3af  flip @
        al_draw_tinted_scaled_rotated_bitmap_region ;

: draw-sprite  ( bmp -- )  r 4@ color  sx 2@  ang @  flip @  csrblitf ;

: sprite  1 1 sx 2!  1 1 1 1 r 4! ;
