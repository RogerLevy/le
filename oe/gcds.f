\ Global collection detection system
\  Static boxes (in their own object list)
\  

obj: role box:
    import bu/mo/cgrid
    \ import bu/mo/xml
    import bu/mo/stride2d
    import le/mo/tiled

container instance boxes

: /cbox  x 2v@ putCbox  ahb boxGrid add-cbox ;
: (*box)  ( w h -- )  boxes one  w 2v!  /cbox ;
: ?box  ( w h -- )  2dup or if  (*box)  else  2drop  then ;
: *box  ( pen=xy w h -- )  ['] ?box  -rot   at@ 2+  sectw secth  stride2d ;  
 
\ :noname  [ is loadbox ]   @dims *box ;

