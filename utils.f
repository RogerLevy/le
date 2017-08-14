le: idiom utils:
    import bu/mo/a
    import le/obj

: udlr  ( speed vector -- )
    a!>
    <up> kstate if dup negate a@ cell+ +! then
    <down> kstate if  dup a@ cell+ +! then
    <left> kstate if dup negate a@ +! then
    <right> kstate if  dup a@ +! then
    drop
;

\ ENUM doesn't work as expected...
0 constant DIR_DOWN
1 constant DIR_UP
2 constant DIR_RIGHT
3 constant DIR_LEFT
