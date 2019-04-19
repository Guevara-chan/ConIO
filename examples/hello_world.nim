# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Basic "Hello, world" from Con/IO
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
import "../src/conio"

con.title = "•Con/IO test•"
con.cursor.height = 100
con.set_window_size 43, 12
con.set_buffer_size con.window_width, con.window_height
con.clear()
for t in 0..8:
    con.cursor.left = t * 2
    con.foreground_color = cast[con.colors](t + 7)
    con.log "Hello, world !", "Привет, мир."
    con.beep(t * 100)
con.write "Press".fg(con.colors.red), " any ".fg(con.colors.green), "key...".fg(con.colors.cyan)
con.read_key
con.reset_color