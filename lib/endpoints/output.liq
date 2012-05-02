# Register an endpoint to create a output.ao(source).
# @param ~register HTTP controler register handler
def controler.json.endpoints.output.ao(~register) =
  def output(~fallible,source, options) =
    output.ao(fallible=fallible,source)
  end

  controler.json.endpoints.output_source(register=register, "ao", output) 
end

controler.json.endpoints.register(controler.json.endpoints.output.ao)
