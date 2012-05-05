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
    uri = of_json(default="",options)
    single(id=name, uri)
  end

  controler.json.endpoints.create_source(register=register, "single", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.single)

# Register an endpoint to create a blank source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.create.blank(~register) =
  def create(name, options) =
    duration = of_json(default=0.,options)
    blank(id=name, duration=duration)
  end

  controler.json.endpoints.create_source(register=register, "blank", create)
end

controler.json.endpoints.register(controler.json.endpoints.create.blank)

