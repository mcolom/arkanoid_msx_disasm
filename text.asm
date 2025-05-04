STORY_NUM_LINES: equ 9
STORY_CHARS_PER_LINE: equ 26

; Counter to wait before writing a char
STORY_CHAR_DELAY_COUNTER: equ 0xe00e

; Current line of message
STORY_WRITE_ROW: equ 0xe00f

; Index in the current line
STORY_CHAR_OF_LINE_INDEX: equ 0xe010

; Char index, from 0 to 222 characters
STORY_MSG_INDEX: equ 0xe011

; Number of written to the line, of a total of STORY_CHARS_PER_LINE each
STORY_CHARS_WRITTEN_TO_LINE: equ 0xe012

; Set when the whole story has been completely written on the screen
STORY_ALREADY_WRITTEN: equ 0xe013

; Counter to pause and show the story, before moving to the demo
STORY_SHOWN_PAUSE: equ 0xe014
