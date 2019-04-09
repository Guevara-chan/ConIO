# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Con/IO terminal library v0.1
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
from strutils import join
import terminal, unicode

# [OS-dependent bindings]
when defined(windows):
    const max_buf = 256
    proc set_console_title(title: WideCString): cint {.stdcall, dynlib: "kernel32", importc: "SetConsoleTitleW".}
    proc get_console_title(title: WideCString, size: int): cint {.stdcall,dynlib:"kernel32",importc:"GetConsoleTitleW".}
    proc beep(freq: int, duration: int): cint {.stdcall, dynlib: "kernel32", importc: "Beep".}
    proc get_key_state(code: int): cint {.stdcall, dynlib: "user32", importc: "GetKeyState".}
    proc get_char(): cint {.header: "<conio.h>", importc: "_getwch".}
    proc get_echoed_char(): cint {.header: "<conio.h>", importc: "_getwche".}
else: {.fatal: "FAULT:: only Windows OS is supported for now !".}

#.{ [Classes]
when not defined(con):
    # --Service definitions:
    type 
        con* {.package.} = object
        color_names = enum
            black, dark_blue, dark_green, dark_cyan, dark_red, dark_magenta, dark_yellow, gray,
            dark_gray, blue, green, cyan, red, magenta, yellow, white
    const
        color_impl = [(fgBlack, false), (fgBlue, false), (fgGreen, false), (fgCyan, false), (fgRed, false), 
        (fgMagenta, false), (fgYellow, false), (fgWhite, false), (fgBlack, true), (fgBlue, true), (fgGreen, true), 
        (fgCyan, true), (fgRed, true), (fgMagenta, true), (fgYellow, true), (fgWhite, true)]
    var 
        (fg_color, bg_color) = (colorNames.gray, colorNames.black)
        cur_visible = true
    using
        _:      type con
        list:   varargs[auto, `$`]
        color:  color_names
        
    # --Methods goes here:
    # •Handles•
    proc output*(_): File {.inline.} = stdout
    proc input*(_): File {.inline.}  = stdin

    # •Output•
    proc write*(_, list): auto {.inline.}      = con.output.write list
    proc write_line*(_, list): auto {.inline.} = con.write list; con.write '\n'
    proc log*(_, list): auto {.inline.}        = con.write_line list.join " "

    # •Input•
    proc readline*(_): string {.discardable inline.}              = con.input.readLine
    proc read*(_): int16 {.discardable inline.}                   = getChar().int16
    proc read_key*(_; echoed = false): Rune {.discardable inline.} = 
        (if echoed: get_echoed_char() else: con.read()).Rune

    # •Colors•
    template colors*(_: type con): auto         = color_names
    proc foreground_color*(_, color) {.inline.} = fg_color
    proc background_color*(_, color) {.inline.} = bg_color
    proc `foreground_color=`*(_, color) {.inline.} =
        let (shade, bright) = color_impl[color.int]
        con.output.setForegroundColor shade, bright
        fg_color = color
    proc `background_color=`*(_, color) {.inline.} =
        let (shade, bright) = color_impl[color.int]
        con.output.setBackgroundColor (shade.int+10).BackgroundColor, bright
        bg_color = color
    proc reset_color*(_) {.inline.} = (con.foregroundColor, con.backgroundColor) = (con.colors.gray, con.colors.black)

    # •Advanced controls•
    proc clear*(_) {.inline.}                                      = eraseScreen()
    proc set_cursor_position*(_; left = 0, top = 0) {.inline.}     = con.output.setCursorPos(left, top)
    proc window_width*(_): int {.inline.}                          = terminalWidth()
    proc window_height*(_): int {.inline.}                         = terminalHeight()
    proc cursor_visible*(_): bool {.inline.}                       = cur_visible
    proc `cursor_visible=`*(_; val: bool) {.discardable inline.}   =
        if val: hideCursor() else: showCursor()
        cur_visible = val
        
    # •Misc•
    proc caps_lock*(_): bool {.inline.}                   = (0x14.get_key_state and 0x0001) != 0
    proc number_lock*(_): bool {.inline.}                 = (0x90.get_key_state and 0x0001) != 0
    proc beep*(_; freq = 800, duration = 200) {.inline.}  = discard freq.beep duration
    proc `title=`*(_; title: auto) {.inline discardable.} = discard $(title).newWideCString.setConsoleTitle
    proc `title`*(_): string {.inline.} =
        let buffer = cast[WideCString](array[max_buf, Utf16Char].new)
        discard buffer.getConsoleTitle max_buf
        return $buffer

    # --Pre-init goes here:
    con.resetColor()
    con.cursorVisible = true
#.}

# ==Testing code==
when isMainModule:
    con.title = "•Con/IO test•"
    for t in 0..8:
        con.setCursorPosition t, t
        con.foregroundcolor = cast[con.colors](t + 7)
        con.log "Hello, world !"
    con.beep()
    discard con.read_key 