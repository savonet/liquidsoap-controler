# Register an endpoint to create a request.queue source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.request.queue(~register) =
  def create(name,options) =
    # Create source
    source = request.queue(id=name)

    # Enable request push on this source.
    controler.json.endpoints.requests.push(register=register,name=name,source)
 
    # Return new source
    source
  end

  controler.json.endpoints.create_source(register=register, "request/queue", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.request.queue)


# Register an endpoint to create a single source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.single(~register) =
  def create(name, options) =
    uri = options["uri"]
    single(id=name, uri)
  end

  controler.json.endpoints.create_source(register=register, "single", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.single)

# Register an endpoint to create a blank source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.blank(~register) =
  def create(name, options) =
    duration = float_of_string(default=0.,options["duration"])
    blank(id=name, duration=duration)
  end

  controler.json.endpoints.create_source(register=register, "blank", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.blank)

# Register an endpoint to create a input.http source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.input.http(~register) =
  def create(name, options) =
    autostart     = options.bool(default=true, "autostart",             options)
    bind_address  = options.string(default="", "bind_address",          options)
    buffer        = options.float(default=2.,  "buffer",                options)
    debug         = options.bool(default=false,"debug",                 options)
    force_mime    = options.string(default="", "force_mime",            options)
    logfile       = options.string(default="", "logfile",               options)
    max           = options.float(default=10.,  "max",                  options)
    new_track_on_metadata = 
                    options.bool(default=true, "new_track_on_metadata", options)
    playlist_mode = options.string(default="normal", "playlist_mode",   options)
    poll_delay    = options.float(default=2.,  "poll_delay",            options)   
    timeout       = options.float(default=10.,  "timeout",              options)   
    uri           = options.string(default="",  "uri",                  options)
 
    # Create source
    source = 
      input.http(id=name, autostart=autostart, bind_address=bind_address, 
                 buffer=buffer, debug=debug, force_mime=force_mime, 
                 logfile=logfile, max=max, new_track_on_metadata=new_track_on_metadata,
                 playlist_mode=playlist_mode, poll_delay=poll_delay, 
                 timeout=timeout, uri)

    # Enable start/stop/status
    controler.json.endpoints.stateful(register=register,name=name,source)

    # Return source
    source
  end

  controler.json.endpoints.create_source(register=register, "input/http", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.input.http)

