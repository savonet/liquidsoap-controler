# Register an endpoint to create a output.ao(source).
# @param ~register HTTP controler register handler
def controler.json.endpoints.output.ao(~register) =
  def output(~fallible,source,options) =
    output.ao(fallible=fallible,source)
  end

  controler.json.endpoints.output_source(register=register, "ao", output) 
end

controler.json.endpoints.register(controler.json.endpoints.output.ao)

# Register an endpoint to create a output.dummy(source).
# @param ~register HTTP controler register handler
def controler.json.endpoints.output.dummy(~register) =
  def output(~fallible,source,options) =
    output.dummy(fallible=fallible,source)
  end

  controler.json.endpoints.output_source(register=register, "dummy", output)
end

controler.json.endpoints.register(controler.json.endpoints.output.dummy)
