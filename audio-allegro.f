le:
: sfx  ( -- <name> <path> )
    create  <filespec> zstring al_load_sample ,
    does> @ 1 0 1 3af ALLEGRO_PLAYMODE_ONCE 0 al_play_sample ;

: replace-char ( source n oldch newch -- )
   2swap begin ( old new a n)
      dup while
      fourth scan
      dup if 3dup drop c! then
   repeat 2drop 2drop ;

0 value s  \ pointer to a variable
: stream  ( path c playmode variable -- )   to s  >r
    zstring #4 #2048 al_load_audio_stream s !
    s @ r> al_set_audio_stream_playmode drop
    s @ mixer al_attach_audio_stream_to_mixer drop ;

: stop  ( variable -- )  dup @ swap off  ?dup -exit
    dup 0 al_set_audio_stream_playing drop  al_destroy_audio_stream  ;

variable bgm
: play  ( path c -- )  bgm stop  ALLEGRO_PLAYMODE_LOOP bgm stream ;

: recite  ( path c variable -- variable )  dup >r   ALLEGRO_PLAYMODE_ONCE r@ stream  r> ;
