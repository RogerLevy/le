\ Depth sorting (TBD)

obj:
    var zdepth
    augment

: compiled  ( addr -- addr cells )  here over - cell/ s>p ;

\ Depthsort by Y position
: zdepth@  's zdepth @ ;
: sort  ['] zdepth@ rsort ;

\ Not sure if I need to factor any of this or just copy and paste.
: drawem  ( addr cells -- )  cells bounds do  i @ me!  draw  cell +loop ;
: enqueue  eachlist>  hide @ ?exit  me , ;
: draw-sorted  here dup  enqueue  compiled  2dup sort  drawem  reclaim ;

' draw-sorted is render
