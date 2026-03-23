THE ERA AND TIME OF THIS STORY IS UNKNOWN.
AFTER THE MOTHERSHIP "ARKANOID" WAS DESTROYED, A SPACECRAFT "VAUS" SCRAMBLED AWAY FROM IT.
BUT ONLY TO BE TRAPPED IN SPACE WARPED BY SOMEONE......

![arkanoid_in_msx](https://github.com/user-attachments/assets/a8709f91-7d27-4d1c-9d30-d835208879a6)

## About
This is a manually-annotated disassembly of the Taito's Arkanoid game for MSX.<br>
The only aim of this work is educational and because of its historical interest.<br>
The third reason can be found in the Queen's It's a Hard Life song: I did it for love :)

Start reading from file [disassembly.asm](disassembly.asm).

Commercial use is strictly prohibited.

Arkanoid is (c) Taito.<br>
This dissassembly is by tiburoncio, 2026.

## Interesting findings
- Aliens won't come out of just any of the two doors, but from the farthest away from Vaus
- Not all bricks are worth the same number of points. That depends on their color.
- There are two cheats, but no surprises - they've already been documented
- The code doesn't use many optimizations. It tends to use LD A, 0 instead of XOR A, for example.
- The number of hits to break a gray brick is not always 2. It depends on the currrent level and specifically it's int((level+1) / 8) + 2.
- The ball's angle changes after it bounces 40 times
- It seems that the programmers had planned than when you can shoot, after getting the red capsule, the ball would accelerate. But in the end, they didn’t implement it.
- There's a variable which controls the type of level transition: go to the same level (when a life is lost), go to the next level, or do some action after Vaus goes through a portal. The last one goes to the same code that performs a transition to the next level. This means that probably the programmers had planned something special after Vaus goes through the portal, but finally they didn't implement anything.
