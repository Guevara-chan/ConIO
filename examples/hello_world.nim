# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Basic "Hello, world" from Con/IO
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
import "../src/conio"

con.title = "•Con/IO test•"
for t in 0..8:
    con.setCursorPosition t, t
    con.foregroundcolor = cast[con.colors](t + 7)
    con.log "Hello, world ! Привет, мир."
con.beep()
discard con.read_key 