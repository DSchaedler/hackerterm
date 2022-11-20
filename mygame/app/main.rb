# frozen_string_literal: true

STD_BUFFER = 2

# Key codes which return their name and cause undesireable behavior.
BROKEN_KEYS = %i[
  shift_left
  alt_left
  backtick
  alt
  tab
  backspace
  end
  home
  pageup
  pagedown
  enter
  raw_key
  char
  shift
  shift_right
  escape
].freeze

SHIFT_KEYS = %i[
  shift_left
  shift
  shift_right
].freeze

# Special keys where we want to convert their name to their symbol
KEY_MAP = {
  exclamation_point: '!',
  EXCLAMATION_POINT: '!',
  period: '.',
  space: ' ',
  tilde: '~',
  at: '@',
  one: '1',
  two: '2',
  three: '3',
  four: '4',
  five: '5',
  six: '6',
  seven: '7',
  eight: '8',
  nine: '9',
  zero: '0',
  hypen: '-',
  equal_sign: '=',
  single_quotation_mark: "'",
  question_mark: '?'
}.freeze

# Main Loop
def tick(_args)
  $tick_started ||= false
  startup unless $tick_started

  $console.tick
  $prompt.tick

  $gtk.args.outputs.primitives << $tick_outputs
  $tick_outputs = []
end

def startup
  $tick_started = true
  $tick_outputs = []

  $console = Console.new
  $prompt = Prompt.new
end

# Tracks and controls the log history
class Console
  attr_accessor :log_lines, :debug, :previous_commands, :letter_size

  def initialize
    @debug = false
    @log_lines = ['System Ready.']
    @previous_commands = []
    @letter_size = $gtk.calcstringbox 'W'
  end

  def tick
    $tick_outputs << background
    $tick_outputs << log
  end

  def background
    { x: 0, y: 0, w: 1280, h: 720, r: 0, g: 0, b: 0, a: 255, primitive_marker: :solid }
  end

  def log
    output_lines = []
    @log_lines.each_with_index do |line, index|
      output_lines[index] = {
        x: STD_BUFFER, y: 720 - ((index * @letter_size.y) + STD_BUFFER) - STD_BUFFER,
        text: line,
        r: 255, g: 255, b: 255, a: 255,
        primitive_marker: :label
      }
    end
    output_lines
  end
end

# Interactive portion of the application
class Prompt
  def initialize
    @prompt = '-> '
    @previous_prompt = @prompt
    @prompt_position = 0
    @shift = false
  end

  def tick
    @current_prompt = @previous_prompt
    @down_or_held = $gtk.args.inputs.keyboard.keys[:down_or_held]

    if @down_or_held != []
      @down = $gtk.args.inputs.keyboard.keys[:down]
      @held = $gtk.args.inputs.keyboard.keys[:held]

      backspace
      shift
      input_keys
      enter
      escape
    end

    @previous_prompt = @current_prompt

    $tick_outputs << draw_prompt
    $tick_outputs << draw_prompt_position if $debug
  end

  def backspace
    return unless @down.include?(:backspace) || ($gtk.args.inputs.keyboard.key_held.backspace && ($gtk.args.state.tick_count % 7).zero?)
    return unless @prompt_position.positive?

    @current_prompt = @current_prompt[0...-1]
    @prompt_position -= 1
  end

  def shift
    SHIFT_KEYS.each do |key|
      @shift = @down_or_held.include? key
      break if @shift
    end
  end

  def input_keys
    @down.each do |key|
      next if BROKEN_KEYS.include? key

      if KEY_MAP.include? key
        @current_prompt += KEY_MAP[key].to_s
        @prompt_position += KEY_MAP[key].to_s.length
      else
        string = key.to_s
        string = string.upcase if @shift
        @current_prompt += string
        @prompt_position += string.length
      end
    end
  end

  def enter
    return unless @down.include?(:enter)

    $console.log_lines << @current_prompt.sub('-> ', '')
    @current_prompt = '-> '
    @prompt_position = 0
  end
  
  def escape
    $gtk.request_quit if @down.include?(:escape)
  end

  def draw_prompt
    @current_prompt += '|' if (($gtk.args.state.tick_count / 60) % 1).round.zero? && $gtk.args.inputs.keyboard.has_focus
    {
      x: STD_BUFFER, y: STD_BUFFER + $console.letter_size.y,
      text: @current_prompt,
      r: 255, g: 255, b: 255, a: 255,
      primitive_marker: :label
    }
  end

  def draw_prompt_position
    text = "#{@prompt_position} #{@shift}"
    {
      x: 1280 - ($console.letter_size.x * text.length) - STD_BUFFER,
      y: 0 + $console.letter_size.y + STD_BUFFER,
      text: text,
      r: 255, g: 255, b: 255, a: 255,
      primitive_marker: :label
    }
  end
end
