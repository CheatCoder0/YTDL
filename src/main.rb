require 'open-uri'
require 'tty-spinner'


@command_to_run = [Dir.home.to_s + "/youtube-dl.exe"]
@debug_mode = false
@bypass_update_mode = false


# change directory
Dir.chdir(Dir.home)
if !Dir.exist?(File.join(Dir.home, "downloads", "YTDL"))
  Dir.mkdir(File.join(Dir.home, "downloads", "YTDL"))
end

def clear_term()
  if !@debug_mode
    system "clear" or system "cls" # clear the terminal
  end
end

def update_dependencies()
  if !@bypass_update_mode
    puts "Updating Dependencies..."
    open("youtube-dl.exe", "wb") { |file| file << open("https://yt-dl.org/latest/youtube-dl.exe").read }
  end
end

def arg_music()
  # --music argument, download in an audio-only format
  clear_term()
  print "Enter an audio bitrate (Kbit/s) > "
  bitrate = STDIN.gets.chomp.to_s
  clear_term()
  print "Enter a file format (without the dot) > "
  format = STDIN.gets.chomp.to_s
  @command_to_run << "-o"
  @command_to_run << "%(title)s.%(ext)s"
  @command_to_run << "--embed-thumbnail"
  @command_to_run << "-x"
  @command_to_run << "--audio-format"
  @command_to_run << "#{format}"
  @command_to_run << "--audio-quality"
  @command_to_run << bitrate+"K"
  @command_to_run << "-f"
  @command_to_run << "251"
end

def parse_args()
  if ARGV.any?
    argv = ARGV
    if argv.include? "--debug"
      @debug_mode = true
    end
    if argv.include? "--bypass-update"
      @bypass_update_mode = true
    end
    if argv.include? "--music"
      arg_music()
    end
    puts @command_to_run.to_s
  end
end

def add_entry(entry)
  # parse the entry for special commands or add it to the list
  if entry == "debug"
    @debug_mode = true
    return 0
  elsif entry == "done"
    return -1
  elsif entry.include? "youtube.com/" or entry.include? "youtu.be/"
    @command_to_run << entry
    return 0
  else
    return 1
  end
end

def clean_entry(entry)
  # clean up the link
  ret = entry
  if ret.include? "&"
    ret = ret.split("&")[0]
    if @debug_mode
      puts "[debug] Cleaned up, now \"#{entry}\""
    end
  end
  return ret
end

def get_clean_entry()
  # print messages and grab the next YT link
  puts "Paste a link or type \"done\" to start downloading your videos."
  print "> "
  return clean_entry(STDIN.gets.chomp.to_s)
end

def download()
  # download!
  spinner = TTY::Spinner.new("[:spinner] Downloading ...", format: :classic)
  spinner.auto_spin

  Dir.chdir(File.join(Dir.home, "downloads", "YTDL"))
  process = `#{@command_to_run.join(" ")}`

  spinner.stop("Done!")

  puts @command_to_run.join(" ")
end

def main()
  parse_args()
  update_dependencies()

  while true
    clear_term()
    status = add_entry(get_clean_entry())
    if status == -1
      break # done
    elsif status == 1
      puts "link not accepted." # not a special command or an accepted link
    end
    if @debug_mode
      puts @command_to_run.to_s
    end
  end

  download()
end


main()
