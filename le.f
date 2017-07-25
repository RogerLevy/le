" lantern engine" .notice

\ Lady Engine for Bubble
bu: idiom le:

\ import modules
import bu/mo/image
import bu/mo/draw
\ import bu/mo/glsl
import bu/mo/gameutils
import bu/mo/portion
import bu/mo/rsort
import bu/mo/rect
import bu/mo/porpoise
import bu/mo/node
import bu/mo/cellstack

\ support code
[defined] allegro-audio [if] include le/audio-allegro [else] include le/audio-fmod [then]
include le/autodata
include le/kb
include le/joy
import le/obj
