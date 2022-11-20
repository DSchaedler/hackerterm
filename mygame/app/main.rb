STD_BUFFER = 2
BROKEN_KEYS = [
	:shift_left, 
	:alt_left, 
	:backtick, 
	:alt, 
	:tab, 
	:backspace, 
	:end, 
	:home,
	:pageup,
	:pagedown
	]
KEY_MAP = {
	exclamation_point: "!", 
	EXCLAMATION_POINT: "!", 
	period: ".", 
	space: " ", 
	tilde: "~", 
	at: "@",
	one: "1",
	two: "2",
	three: "3",
	four: "4",
	five: "5",
	six: "6",
	seven: "7",
	eight: "8",
	nine: "9",
	zero: "0",
	hypen: "-",
	equal_sign: "=",
	single_quotation_mark: "'"
	}

def tick args
	$tick_started ||= false
	startup unless $tick_started
	
	places
	
	prompt
	
	housekeeping

end

def startup
	$log_lines = []
  $previous_commands = []
  $letter_size = $gtk.calcstringbox 'W'
end

def places
	$gtk.args.outputs.primitives << {x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0, a: 255, primitive_marker: :solid}
end

def housekeeping
	$gtk.request_quit if $gtk.args.inputs.keyboard.key_up.escape
end

def prompt
	
	$prompt ||= '-> '
	$previous_prompt ||= $prompt
	$prompt_position ||= 0
	$gtk.args.outputs.labels << [1280 - ($letter_size.x * $prompt_position.to_s.length) - STD_BUFFER, 0 + $letter_size.y + STD_BUFFER, "#{$prompt_position}", 255, 255, 255]
	current_prompt = $previous_prompt
	
	key_zero = $gtk.args.inputs.keyboard.keys[:up][0]
	
	if $gtk.args.inputs.keyboard.key_down.backspace
		 if $prompt_position > 0
			current_prompt = current_prompt[0...-1]
			$prompt_position -= 1
		 end
	elsif $gtk.args.inputs.keyboard.key_held.backspace && ($gtk.args.state.tick_count % 5) == 0
		 if $prompt_position > 0
			current_prompt = current_prompt[0...-1]
			$prompt_position -= 1
		 end
	elsif KEY_MAP.has_key? key_zero
		current_prompt += KEY_MAP[key_zero]
		$prompt_position += KEY_MAP[key_zero].length
	elsif key_zero == :shift
		key_one = $gtk.args.inputs.keyboard.keys[:up][1]
		if !BROKEN_KEYS.include? key_one
			if KEY_MAP.has_key? key_one
				current_prompt += KEY_MAP[key_one]
				$prompt_position += KEY_MAP[key_one].length
			else
				current_prompt += key_one.to_s.upcase
				$prompt_position += key_one.to_s.length
			end
		end
	elsif !BROKEN_KEYS.include? key_zero
		current_prompt += key_zero.to_s
		$prompt_position += key_zero.to_s.length
	end
	
	$prev_key = key_zero
	$previous_prompt = current_prompt
	
	current_prompt = current_prompt + '|' if ((($gtk.args.state.tick_count / 60) % 1).round == 0 || key_zero) && $gtk.args.inputs.keyboard.has_focus

	$gtk.args.outputs.primitives << {
		x: STD_BUFFER, y: STD_BUFFER + $letter_size.y, 
		text: current_prompt, 
		r: 255, g: 255, b: 255, a: 255,
		primitive_marker: :label
		}
end