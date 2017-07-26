\ Multitasking for game objects

\ The following words should only be used within a task:
\  pause END FRAMES SECS
\ The following words should never be used within a task:
\  - External calls
\  - Console output (when the Bubble IDE is not loaded)
\  - EXIT or ; from the "root" of a task (the definition containing PERFORM> )

obj:
    var sp  var rp  8 cells field ds  16 cells field rs
    ext
    
objects one named main  \ proxy for the Forth data and return stacks

: perform> ( n -- <code> )
    ds 7 cells + !
    ds 6 cells + sp !
    r> rs 7 cells + !
    rs 7 cells + rp !
;

: perform  ( xt n actor -- )
    { me!
    ds 7 cells + !
    ds 6 cells + sp !
    >code rs 7 cells + !
    rs 7 cells + rp !
    }
;

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
: later  ( n xt -- )  swap queue push queue push ;
: later0  ( xt -- )  ['] execute later ; 
: arbitrate  objects one 0 act>
    queue scount cells bounds do  sp@ >r  i @ i cell+ @ execute  r> sp!  2 cells +loop
    queue vacate ;


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

:noname  eachlist> multi ;  is multi-world
