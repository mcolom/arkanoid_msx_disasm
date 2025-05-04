PORTAL_OPEN: equ 0xe326 ; The portal to the next level is open (1) or closed (0)


; Step 0 or 1
PORTAL_ANIMATION_BEAM_STEP: equ 0xe576

; It counts from 0 to 9 before updating the portal's beam animation
PORTAL_ANIMATION_BEAM_COUNTER: equ 0xe57b

; Set if the portal has been already drawn open, and
; only it's only needed to write the beam animation.
PORTAL_ALREADY_DRAWN_OPEN: equ 0xe57c
