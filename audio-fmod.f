le:

: sfx  ( -- <name> <path> )
    create  <filespec> zstring  fmod @ swap 0 0 pocket FMOD_System_CreateSound  pocket @ ,
    does> @ fmod @ swap 0 0 0 FMOD_System_PlaySound ;

: replace-char ( source n oldch newch -- )
   2swap begin ( old new a n)
      dup while
      fourth scan
      dup if 3dup drop c! then
   repeat 2drop 2drop ;

0 value s  \ pointer to a struct: sound , channel ,
: stream  ( path c playmode pointer -- )   to s  >r
    zstring fmod @ swap r> 0 s FMOD_System_CreateStream
    fmod @ s @ 0 0 s cell+ FMOD_System_PlaySound ;

: stop  ( pointer -- )  to s  s @  -exit
    s off  s cell+ @ FMOD_Channel_Stop  s @ FMOD_Sound_Release ;

variable bgm
: play  ( path c -- )  bgm stop  FMOD_LOOP_NORMAL  bgm stream ;

: recite  ( path c variable -- variable )  dup >r   FMOD_LOOP_OFF  r@ stream  r> ;
