# Register an endpoint to push a request to a given source
# @param ~register HTTP controler register handler
def controler.json.endpoints.requests.push(~register, ~name, source) =
  def apply(name, options) =
    def push(cur, request) =
      lines  = server.execute("#{source.id(source)}.push #{request}")
      list.append(cur, [(request, string.concat(separator="\n", lines))])
    end
    list.fold(push, [], options)
  end
  controler.json.endpoints.apply_source(register=register,"requests/#{name}",apply)
end

# No registration for this one, enable on a per-source basis!
