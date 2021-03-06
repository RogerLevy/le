\ Multitasking for game objects

\ The following words should only be used within a task:
\  pause END FRAMES SECS
\ The following words should never be used within a task:
\  - External calls
\  - Console output 
\ See below for a workaround mechanism.

obj: idiom task:
    import bu/mo/a

    var sp  var rp  12 cells field ds  12 cells field rs
    augment
    
objects in  one named main  \ proxy for the Forth data and return stacks


\ important: this word must not CALL anything or use the return stack until the bottom part.
: pause
    \ save state
    dup \ ensure TOS is on stack
    sp@ sp !
    rp@ rp !
    \ look for next task/actor.  rp=0 means no task.  end of list = jump to main task and resume that
    begin  me next @ me!  me if  rp @  else  main me!  true  then  until
    \ restore state
    rp @ rp!
    sp @ sp!
    drop \ ensure TOS is in TOS register
;

: end  me delete  pause ;
: halt    begin pause again ;
: pauses  0 do pause loop ;
: secs  fps * pauses ;  \ not meant for precision timing

\ external-calls facility - say "['] word later" to schedule a word that calls an external library.
\ you can pass a single parameter to each call, such as an object or an asset.
\ NOTE: you don't have to consume the parameter, and as a bonus, you can leave as much as you want
\ on the stack.
20000 cellstack queue
: later  ( val xt -- )  swap queue push queue push ;
: arbitrate
    queue scount swap a!>  for  sp@ >r  @+ @+ execute  r> sp!  loop
    queue 0 truncate ;


\ execute the multitasker.
: multi  ( objlist -- )
    main remove  \ shouldn't be in an objlist
    me >r
    first @ main next !
    dup
    sp@ main 's sp !
    rp@ main 's rp !
    main me!
    ['] pause catch
    ?dup if
        main me!
        rp @ rp!
        sp @ sp!
        drop
        throw
    then
    drop
    r> me!
    { arbitrate }
;


: self?  sp@ ds >=  sp@ rs <= and ;

decimal
: perform> ( n -- <code> )
    self? if    ds 10 cells + sp!  r>  rs 10 cells + rp!  >r  exit
          else  ds 10 cells + !  ds 9 cells + sp !  r> rs 10 cells + !  rs 10 cells + rp !  
                ['] halt >code rs 11 cells + !
          then ;

: perform  ( xt n actor -- )
    { me!
    ds 10 cells + !
    ds 9 cells + sp !
    >code rs 10 cells + !
    ['] halt >code rs 11 cells + !
    rs 10 cells + rp !
    }
;
fixed

: direct  ( obj -- <word> )  '  0  rot  perform ;
: direct:  ( obj -- ... code ... ; )  :noname  [char] ; parse evaluate  0  rot  perform ;

:noname  eachlist> multi ;  is multi-world
