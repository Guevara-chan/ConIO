# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Basic "Hello, world" from Con/IO
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
import "../src/conio"

con.title = "•Con/IO test•"
con.clear()
for t in 0..8:
    con.set_cursor_position t * 2, t
    con.foreground_color = cast[con.colors](t + 7)
    con.log "Hello, world ! Привет, мир."
con.beep()
con.read_key 