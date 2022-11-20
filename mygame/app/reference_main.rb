# Hey Y'all
# Let's make a goddamn mess.

def tick args
	
	args.state.started ||= false
	startup unless args.state.started == true
	
	$main_console.tick(args)
	
	args.gtk.request_quit if args.inputs.keyboard.key_up.escape
end

def startup
	$main_console = Console.new()
end

class Console
  def initialize
    @letter_size ||= $gtk.calcstringbox 'W'
    @console_text_width ||= ($gtk.logical_width - 20).idiv(@letter_size.x)
		
		@log ||= [ 'System Ready.' ]
		@command_history ||= []
		@command_history_index ||= -1
		
		@log_invocation_count = 0
		
		@background_color ||= [0, 0, 0, 255]
  end
	
	def add_text obj
		@last_log_lines_count ||= 1
		@log_invocation_count += 1
		
		str = obj.str
		
		log_lines = []
		
		str.each_line	do |s|
			s.wrapped_lines(self.console_text_width).each do |l|
				loglines << l
			end
		end
		
		@last_log_lines = log_lines
	end
	
	def render args
		args.outputs.solids << [args.grid.left, args.grid.bottom, args.grid.w, args.grid.h, *@background_color].solid
		
		y = args.grid.bottom + 2
		
	end
	
	def tick args
		render args
	end
end

class Prompt
	def initialize()
		@prompt ||= '->'
		@current_input_str ||= ''
		@cursor_position = 0
		update_cursor_position_px
	end
	
	def update_cursor_position_px
		@cursor_position_px = ($gtk.calcstringbox (@prompt + @current_input_str[0...@cursor_position])).x
	end
end

def wrapped_lines string, length
	string.each_line.map do |l|
		l = l.rstrip
		if l.length > length
			l + "\n"
		else
			words = l.split ' '
			wrapped_lines_recur(words[0], words[1..-1], length, []).flatten
		end
	end.flatten
end

def wrapped_lines_recur word, rest, length, aggregate
	if word.nil?
		return aggregate
	elsif rest[0].nil?
		aggregate << word + "\n"
		return aggregate
	elsif (word + " " + rest[0]).length > length
		aggregate << word + "\n"
		return wrapped_lines_recur rest[0], rest[1..-1], length, aggregate
	elsif (word + " " + rest[0]).length <= length
		next_word = (word + " " + rest[0])
		return wrapped_lines_recur next_word, rest[1..-1], length, aggregate
	else
		log << "#{word} is too long."
		next_word = (word + " " + rest[0])
		return wrapped_lines_recur next_word, rest[1..-1], length, aggregate
	end
end