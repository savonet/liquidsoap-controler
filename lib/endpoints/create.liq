# Register an endpoint to create a request.queue source.
# @param ~register HTTP controler register handler
def http.json.controler.create.request.queue(~register) =
  def create(name,options) =
    # Create source
    source = request.queue(id=name)

    # Enable request push on this source.
    http.json.controler.requests.push(register=register,name=name,source)
 
    # Return new source
    source
  end

  http.json.controler.create_source(register=register, "request/queue", create)
end

# Register an endpoint to create a single source.
# @param ~register HTTP controler register handler
def http.json.controler.create.single(~register) =
  def create(name, options) =
    uri = of_json(default="",options)
    single(id=name, uri)
  end

  http.json.controler.create_source(register=register, "single", create)
end
