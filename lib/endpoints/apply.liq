# Register an endpoint to push a request to a given source
# @param ~register HTTP controler register handler
def http.json.controler.requests.push(~register, ~name, source) =
  def apply(name, options) =
    def push(cur, request) =
      lines  = server.execute("#{source.id(source)}.push #{request}")
      list.append(cur, [(request, string.concat(separator="\n", lines))])
    end
    list.fold(push, [], options)
  end
  http.json.controler.apply_source(register=register,"requests/#{name}",apply)
end
