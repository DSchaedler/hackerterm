
# Main Loop
def tick(_args)
  $tick_started ||= false
  startup unless $tick_started


  $gtk.args.outputs.primitives << $tick_outputs
  $tick_outputs = []
  
  $gtk.request_quit if $gtk.args.inputs.keyboard.keys[:down].include?(:escape)

end

def startup
  $tick_started = true
  $tick_outputs = []
end
