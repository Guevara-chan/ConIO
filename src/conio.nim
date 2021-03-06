# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
# Con/IO terminal library v0.1
# Developed in 2019 by V.A. Guevara
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- #
from strutils import join, parseEnum
import terminal, unicode, encodings, "encodings_aux.nimi"
export unicode

# [OS-dependent bindings]
when defined(windows):
    const max_buf = 256
    type
        Coord = object
            x, y: int16
        SmallRect = object
            left, top, right, bottom: int16
        BufferInfo = object
            size, cursor_pos: Coord
            attribs:          int16
            window:           SmallRect
            max_win_size:     Coord
        CursorInfo = object
            size:             int32
            visible:          int32
    proc get_char(): cint                               {.header: "<conio.h>",         importc: "_getwch".}
    proc get_echoed_char(): cint                        {.header: "<conio.h>",         importc: "_getwche".}
    proc keyboard_hit(): cint                           {.header: "<conio.h>",         importc: "_kbhit".}
    proc set_console_title(title: WideCString): cint    {.stdcall, dynlib: "kernel32", importc: "SetConsoleTitleW".}
    proc get_console_title(title: WideCString, size: int): cint {.stdcall,dynlib:"kernel32",importc:"GetConsoleTitleW".}
    proc beep(freq: int, duration: int): cint           {.stdcall, dynlib: "kernel32", importc: "Beep".}
    proc get_key_state(code: int): cint                 {.stdcall, dynlib: "user32",   importc: "GetKeyState".}
    proc get_console_output_cp(): cint                  {.stdcall, dynlib: "kernel32", importc: "GetConsoleOutputCP".}
    proc get_console_input_cp(): cint                   {.stdcall, dynlib: "kernel32", importc: "GetConsoleCP".}
    proc set_console_output_cp(cp: int): cint           {.stdcall, dynlib: "kernel32", importc: "SetConsoleOutputCP".}
    proc set_console_input_cp(cp: int): cint            {.stdcall, dynlib: "kernel32", importc: "SetConsoleCP".}
    proc get_console_window(): cint                     {.stdcall, dynlib: "kernel32", importc: "GetConsoleWindow".}
    proc show_window(win: int, flags: int): cint        {.stdcall, dynlib: "user32",   importc: "ShowWindow".}
    proc is_window_visible(win: int): cint              {.stdcall, dynlib: "user32",   importc: "IsWindowVisible".}
    proc get_std_handle(flag: int = -11): File          {.stdcall, dynlib: "kernel32", importc: "GetStdHandle".}
    proc get_cursor_info(cout: File, info: ptr CursorInfo): cint
        {.stdcall, dynlib: "kernel32", importc: "GetConsoleCursorInfo".}
    proc set_cursor_info(cout: File, info: ptr CursorInfo): cint 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleCursorInfo".}
    proc get_console_buffer_info(cout: File, info: ptr BufferInfo): cint 
        {.stdcall, dynlib: "kernel32", importc: "GetConsoleScreenBufferInfo".}
    proc set_console_buffer_info(cout: File, info: ptr BufferInfo): cint 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleScreenBufferInfo".}
    proc set_console_buffer_size(cout: File, size: Coord): cint 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleScreenBufferSize".}
    proc set_console_window_info(cout: File, abs: int, rect: ptr SmallRect): cint 
        {.stdcall, dynlib: "kernel32", importc: "SetConsoleWindowInfo".}
    template cursor_info(): CursorInfo =
        var info: CursorInfo
        discard get_std_handle().get_cursor_info info.addr
        info
    template buffer_info(): BufferInfo =
        var info: BufferInfo
        discard get_std_handle().get_console_buffer_info info.addr
        info
else: {.fatal: "FAULT:: only Windows OS is supported for now !".}

#.{ [Classes]
when not defined(con):
    # --Service definitions:
    type 
        con*       = object
        con_cursor = object
        con_color  = enum
            black, dark_blue, dark_green, dark_cyan, dark_red, dark_magenta, dark_yellow, gray,
            dark_gray, blue, green, cyan, red, magenta, yellow, white
        con_chunk  = object
            text: string
            fg:   int8
            bg:   int8
    template colors*(_: type con): auto = con_color
    template chunk*(_: type con): auto  = con_chunk
    template cursor*(_: type con): auto = con_cursor
    const
        con_color_impl = [(fgBlack, false), (fgBlue, false), (fgGreen, false), (fgCyan, false), (fgRed, false), 
        (fgMagenta, false), (fgYellow, false), (fgWhite, false), (fgBlack, true), (fgBlue, true), (fgGreen, true), 
        (fgCyan, true), (fgRed, true), (fgMagenta, true), (fgYellow, true), (fgWhite, true)]
    var 
        (fg_color, bg_color) = (con_color.gray, con_color.black)
    using
        Δ:     type con
        cur:   type con.cursor
        color: con.colors
        cname: string
        
    # --Methods goes here:
    # •Handles•
    proc `out`*(Δ): File {.inline.} = stdout
    proc `in`*(Δ): File {.inline.}  = stdin
    proc window*(Δ): int {.inline.} = get_console_window().int

    # •Output•
    proc write*(Δ; list: varargs[auto, new_chunk]) {.inline.} = (for entry in list: entry.Δwrite)
    proc write_line*(Δ; feed: auto) {.inline.}                = con.write feed; con.write '\n'
    proc log*(Δ; list: varargs[auto, `$`]) {.inline.}         = con.write_line list.join " "
    proc clear*(Δ) {.inline.}                                 = eraseScreen()

    # •Input•
    proc readline*(Δ): string {.discardable inline.}              = convert(con.in.readLine,"UTF-8",con.input_encoding)
    proc read*(Δ): int16 {.discardable inline.}                   = getChar().int16
    proc read_key*(Δ; echoed = true): Rune {.discardable inline.} = (if echoed:get_echoed_char() else: con.read).Rune
    proc key_available*(Δ): bool {.discardable inline.}           = keyboard_hit() != 0

    # •Colors•
    proc reset_color*(Δ) {.inline.} = (con.foregroundColor, con.backgroundColor) = (con.colors.gray, con.colors.black)
    proc foreground_color*(Δ): con.colors {.inline.} = fg_color
    proc background_color*(Δ): con.colors {.inline.} = bg_color
    proc `foreground_color=`*(Δ, color) {.inline.}   =
        let (shade, bright) = con_color_impl[color.int]
        con.out.setForegroundColor shade, bright
        fg_color = color
    proc `background_color=`*(Δ, color) {.inline.}   =
        let (shade, bright) = con_color_impl[color.int]
        con.out.setBackgroundColor (shade.int+10).BackgroundColor, bright
        bg_color = color
    proc fg*(feed: auto, color): con_chunk {.inline} = feed.new_chunk(fg=color.int8)
    proc bg*(feed: auto, color): con_chunk {.inline} = feed.new_chunk(bg=color.int8)
    proc fg*(feed: auto, cname): con_chunk {.inline} = feed.new_chunk(fg=parseEnum[con.colors](cname).int8)
    proc bg*(feed: auto, cname): con_chunk {.inline} = feed.new_chunk(bg=parseEnum[con.colors](cname).int8)

    # •Sizing•
    proc set_buffer_size*(Δ; w=120, h=9001) {.inline.} = 
        if 0 == get_std_handle().set_console_buffer_size Coord(x: w.int16, y: h.int16):
            raise newException(Exception, "Invalid buffer size provided")
    proc set_window_size*(Δ; w=120, h=30) {.inline.}   =
        var t = SmallRect(top:con.window_top.int16, left:con.window_left.int16, right:w.int16 - 1, bottom:h.int16 - 1)
        if 0 == get_std_handle().set_console_window_info(1, t.addr):
            raise newException(Exception, "Invalid window size provided")
    proc set_window_position*(Δ; x=0, y=0) {.inline.}  =
        var t = SmallRect(top:y.int16, left:x.int16, right:con.window_width.int16 - 1, bottom:con.window_height.int16-1)
        if 0 == get_std_handle().set_console_window_info(1, t.addr):
            raise newException(Exception, "Invalid window position provided")
    proc window_top*(Δ): int {.inline.}                = buffer_info().window.top
    proc window_left*(Δ): int {.inline.}               = buffer_info().window.left
    proc window_width*(Δ): int {.inline.}              = buffer_info().window.right + 1
    proc window_height*(Δ): int {.inline.}             = buffer_info().window.bottom + 1
    proc buffer_width*(Δ): int {.inline.}              = buffer_info().size.x
    proc buffer_height*(Δ): int {.inline.}             = buffer_info().size.y
    proc `window_top=`*(Δ; y: int) {.inline.}          = con.set_window_position(con.window_left, y)
    proc `window_left=`*(Δ; x: int) {.inline.}         = con.set_window_position(x, con.window_top)
    proc `window_width=`*(Δ; w: int) {.inline.}        = con.set_window_size(w, con.window_height)
    proc `window_height=`*(Δ; h: int) {.inline.}       = con.set_window_size(con.window_width, h)
    proc `buffer_width=`*(Δ; w: int) {.inline.}        = con.set_buffer_size(w, con.buffer_height)
    proc `buffer_height=`*(Δ; h: int) {.inline.}       = con.set_buffer_size(con.buffer_width, h)

    # •Cursor controls•
    proc set_cursor_position*(Δ; x=0, y=0) {.inline.} = con.out.setCursorPos(x, y)
    proc top*(cur): int {.inline.}                    = buffer_info().cursor_pos.y
    proc left*(cur): int {.inline.}                   = buffer_info().cursor_pos.x
    proc visible*(cur): bool {.inline.}               = cursor_info().visible != 0
    proc height*(cur): int {.inline.}                 = cursor_info().size
    proc `top=`*(cur; y: int) {.inline.}              = con.set_cursor_position(con.cursor.left, y)
    proc `left=`*(cur; x: int) {.inline.}             = con.set_cursor_position(x, con.cursor.top)
    proc `visible=`*(cur; val: bool) {.inline.}       =
        var t = CursorInfo(size: con.cursor.height.int32, visible: val.int32)
        discard get_std_handle().set_cursor_info t.addr
    proc `height=`*(cur; h: int) {.inline.}           =
        var t = CursorInfo(size: h.int32, visible: con.cursor.visible.int32)
        discard get_std_handle().set_cursor_info t.addr

    # •Misc•
    proc beep*(Δ; freq = 800, duration = 200) {.inline.} = discard freq.beep duration
    proc caps_lock*(Δ): bool {.inline.}                  = (0x14.get_key_state and 0x0001) != 0
    proc number_lock*(Δ): bool {.inline.}                = (0x90.get_key_state and 0x0001) != 0
    proc output_encoding*(Δ): string {.inline.}          = get_console_output_cp().codePageToName
    proc input_encoding*(Δ): string {.inline.}           = get_console_input_cp().codePageToName
    proc visible*(Δ): bool {.inline.}                    = con.window.is_window_visible()
    proc title*(Δ): string {.inline.}                    =
        let buffer = cast[WideCString](array[max_buf, Utf16Char].new)
        discard buffer.getConsoleTitle max_buf
        return $buffer
    proc `output_encoding=`*(Δ; cp: string) {.inline.} = discard encodings_aux.nameToCodePage(cp).set_console_output_cp
    proc `input_encoding=`*(Δ; cp: string) {.inline.}  = discard encodings_aux.nameToCodePage(cp).set_console_input_cp
    proc `visible=`*(Δ; val: bool) {.inline.}          = discard con.window.show_window(val.int)
    proc `title=`*(Δ; title: auto) {.inline.}          = discard $(title).newWideCString.setConsoleTitle

    # •Chunks mechanics•
    proc `$`*(self: con.chunk): string {.inline.}                       = self.text
    proc new_chunk*(feed: auto, fg = -1, bg = -1): con.chunk {.inline.} =
        when type(feed) is con.chunk:
            con_chunk(text: $feed, fg: (if -1 != fg: fg.int8 else: feed.fg), bg: (if -1 != bg: bg.int8 else: feed.bg))
        else: con_chunk(text: $feed, fg: fg.int8, bg: bg.int8)
    proc Δwrite*(self: con.chunk)                                       =
        let (fg, bg) = (con.foregroundColor, con.backgroundColor)
        if self.fg != -1: con.foreground_color = self.fg.con_color
        if self.bg != -1: con.background_color = self.bg.con_color
        con.out.write convert($self, con.output_encoding, "UTF-8")
        (con.foregroundColor, con.backgroundColor) = (fg, bg)

    # --Pre-init goes here:
    con.resetColor()
#.}

# ==Testing code==
when isMainModule: include "../examples/hello_world.nim"