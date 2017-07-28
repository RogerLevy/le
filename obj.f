\ Object Table (Strategy) for Bubble
\ Adapted from Dark Blue / RetroForth
\ For 2D games.
\ This file should thought of as a starting point.  We extend it in various files.
\ When I have Workspaces to a certain level, editing source code in a visual way will take the place
\  of the traditional level editor.  As a very preliminary example,
\    Some object classes would NOT have an angle var.  Instead any rotation is hardcoded.
\      This will be edited interactively in Workspaces, merging coding and design.
\    But you still might want a class of objects that all have a different fixed angle.
\      In this case you'd add the var, and edit a level in a more traditional way.
\      But it's still better than an across-the-board variable because that complicates writing
\        rendering routines. You DON'T need this variable all the time.

bu: idiom obj:
    import bu/mo/porpoise
    import bu/mo/node
    import bu/mo/cellstack
    import bu/mo/pen
    import bu/mo/portion
    import bu/mo/draw

: 2@  2v@ ;
: 2!  2v! ;
: 2+!  2v+! ;

private:
    32 cellstack stack
    variable used  node sizeof @ used !  \ field counter
    : ?call  ?dup -exit call ;
public:

defer multi-world  ' noop is multi-world  ( -- )  \ for multitasking extension

0 value me
: me!  to me ;
: {    " me >r" evaluate ; immediate     \ me stack push ;
: }    " r> to me" evaluate ; immediate  \ stack pop to me ;
: ofs  create ,  does> @ me + ;
: field  used @ ofs  used +! ;
: var   cell field ;
: 's    " me swap to me " evaluate  bl parse evaluate  " swap to me" evaluate ; immediate

var en var nam var x var y var vx var vy var hide var disp var beha var marked
used @ value parms

: draw  en @ hide @ 0 = and if  x 2@ at  white  disp @ ?call  then ;
: step  beha @ ?call ;
: adv   vx 2@ x 2+! ;
: each>  ( objlist -- <code> )  r> swap first @ begin  dup while  dup next @ >r  me!  dup >r  call  r>  r> repeat  2drop ;
: /obj  heap dims drop ;
: init  me /obj erase  en on  hide on  at@ x 2! ;
: named  ( -- <name> )  me value  nam on ;
: one    ( objlist -- )  heap portion me!  init  me swap pushnode ;
: draw>  r> disp !  hide off  ;
: act>   r> beha ! ;
: from   ( x y -- )  x 2@ 2+ at ;
: flash  #frames 2 and hide ! ;

\ "external" words
: place   ( x y obj -- )  { me!  x 2! } ;
: delete  ( obj -- )  { me!  marked on } ;
\ -----

: ext  used @ to parms ;

\ Private idioms for game objects; currently no actual connection to the objects themselves...
: role  parms used !  idiom  private: ;

\ Removal
: sweep  ( objlist -- ) each>  marked @ -exit  me remove  nam @ not if  me heap recycle  then ;
: delete-all  each> me delete ;

: gas  ( objlist -- ) dup delete-all sweep ;  \ this word is kind of meant to be redefined (?)

256 cellstack world
: objlist  ( -- <name> )  create  here  container instance,  world push ;
objlist objects  \ default object list.  if you don't put do anything to WORLD it's the only list processed.
: eachlist>  ( -- <code> )  ( ... objlist -- ... )
    r>  world scount cells bounds do  i @  swap  >r  r@ call  r>  cell +loop  drop ;

: draw-world  eachlist>  each>  draw ;

\ things get a bit crazy here ... the price of modularity?
defer prerender  : blue-screen blue backdrop ;  ' blue-screen  is prerender
defer render     ' draw-world is render
defer postrender :noname  ;  is postrender
defer prestep    ' noop  is prestep
defer poststep   ' noop  is poststep
\ : draw-info     info @ -exit  eachlist>  each>
: le-render  render>  { prerender  render  ( draw-info )  postrender } ;
: step-world    eachlist>  each>  step ;
: adv-world     eachlist>  each>  adv ;
: sweep-world   eachlist>  sweep ;
: le-step  step>  { prestep  multi-world  step-world  sweep-world  poststep  sweep-world  adv-world } ;
: le-go  le-render  le-step ;  le-go

: pre>  r> code> is prestep ;
: post>  r> code> is poststep ;
: scene  ( -- )
    world vacate  objects world push  objects gas
    ['] noop  dup is prestep  dup is poststep  is postrender
    ['] blue-screen is prerender  ['] draw-world is render ;

\\
\ Test
[defined] dev [if]
    private:
    : *thingy  objects one draw> 50 50 red 50 circlef ;
    scene  displaywh 2 2 2/ at  *thingy  me value thingy
[then]

