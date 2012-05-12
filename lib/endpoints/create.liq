# Register an endpoint to create a request.queue source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.request.queue(~register, ~remove) =
  def create(name,options) =
    conservative     = options.bool(default=false, "conservative", options)
    default_duration = options.float(default=30., "default_duration", options)
    length           = options.float(default=10., "length", options)
    timeout          = options.float(default=20., "timeout", options)

    # Create source
    source = request.queue(id=name,conservative=conservative,
                           default_duration=default_duration,
                           length=length,timeout=timeout)

    # Enable request push on this source.
    controler.json.endpoints.requests.push(register=register,name=name,source)
 
    # Return new source
    source
  end

  controler.json.endpoints.create_source(register=register, remove=remove, "request/queue", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.request.queue)


# Register an endpoint to create a single source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.single(~register, ~remove) =
  def create(name, options) =
    uri              = options["uri"]
    conservative     = options.bool(default=false, "conservative", options)
    default_duration = options.float(default=30., "default_duration", options)
    length           = options.float(default=10., "length", options)
    timeout          = options.float(default=20., "timeout", options)

    single(id=name,conservative=conservative,
           default_duration=default_duration,
           length=length,timeout=timeout,uri)
  end

  controler.json.endpoints.create_source(register=register, remove=remove, "single", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.single)

# Register an endpoint to create a request.dynamic source.
# For now, the callback is a trivial function () -> uri.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.single(~register, ~remove) =
  def create(name, options) =
    uri              = options["uri"]
    conservative     = options.bool(default=false, "conservative", options)
    default_duration = options.float(default=30., "default_duration", options)
    length           = options.float(default=10., "length", options)
    timeout          = options.float(default=20., "timeout", options)

    def f() = 
      request.create(uri)
    end

    request.dynamic(id=name,conservative=conservative,
                    default_duration=default_duration,
                    length=length,timeout=timeout,f)
  end

  controler.json.endpoints.create_source(register=register, remove=remove, "request/dynamic", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.single)

# Register an endpoint to create a blank source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.blank(~register, ~remove) =
  def create(name, options) =
    duration = options.float(default=0.,"duration",options)
    blank(id=name, duration=duration)
  end

  controler.json.endpoints.create_source(register=register, remove=remove, "blank", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.blank)

# Register an endpoint to create a input.http source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.input.http(~register, ~remove) =
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

  controler.json.endpoints.create_source(register=register, remove=remove, "input/http", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.input.http)

