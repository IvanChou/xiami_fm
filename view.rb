require 'curses'

class View
  def initialize
    Curses.init_screen
    Curses.noecho
    Curses.stdscr.keypad(true)
    Curses.start_color
    Curses.use_default_colors
    Curses.init_pair(Curses::COLOR_CYAN,Curses::COLOR_CYAN,Curses::COLOR_BLACK) 
    Curses.init_pair(Curses::COLOR_RED,Curses::COLOR_RED,Curses::COLOR_BLACK)
    Curses.clear
  end
  
  def playing(track, position, down_rate)
    p = (position / track.duration.to_f * Curses.cols).ceil
    d = (down_rate * Curses.cols).ceil - p
    Curses.clear
    Curses.setpos(0, 0)
    Curses.addstr("Now is playing ")
    Curses.attron(Curses.color_pair(Curses::COLOR_RED)|Curses::A_NORMAL){
      Curses.addstr("  #{track.title} - #{track.artist}  ")
    }
    Curses.addstr('    按"L"加入收藏，按"M"查看详情 ')
    Curses.setpos(1, 0)
    Curses.addstr("_" * p + "#" * d + " " * (Curses.cols - p - d))
    Curses.setpos(2, 0)
    Curses.addstr("#{track.reason.content}")
    Curses.addstr(": #{track.reason.title} ") unless track.reason.title.nil?
    Curses.addstr("- #{track.reason.artist} ") unless track.reason.artist.nil?
    Curses.addstr("    播放进度: ")
    Curses.attron(Curses.color_pair(Curses::COLOR_CYAN)|Curses::A_NORMAL){
      Curses.addstr(" #{position.ceil} / #{track.duration} ")
    }
    Curses.refresh
  end

end