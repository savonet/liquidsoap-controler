# Register an endpoint to create a output.ao(source).
# @param ~register HTTP controler register handler
def http.json.controler.output.ao(~register) =
  def output(source, options) =
    output.ao(source)
  end

  http.json.controler.output_source(register=register, "ao", output) 
end
