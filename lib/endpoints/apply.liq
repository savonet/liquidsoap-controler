def controler.json.endpoints.requests.push(~register, ~name, source) =
  def apply(options) =
    def push(cur, request) =
      lines  = server.execute("#{source.id(source)}.push #{request}")
      list.append(cur, [(request, string.concat(separator="\n", lines))])
    end
    list.fold(push, [], options)
  end
  controler.json.endpoints.apply_source(register=register,method="POST","#{name}/requests",apply)
end

def controler.json.endpoints.skip(~register, ~name, source) =
  def apply(options) =
    source.skip(source)
    []
  end
  controler.json.endpoints.apply_source(register=register,method="POST","#{name}/skip",apply)
end

def controler.json.endpoints.shutdown(~register, ~name, source) =
  def apply(options) =
    source.shutdown(source)
    []
  end
  controler.json.endpoints.apply_source(register=register,method="DELETE","#{name}",apply)
end

def controler.json.endpoints.stateful(~register, ~name, source) =
  def apply(action, options) =
    lines = server.execute("#{source.id(source)}.#{action}")
    [("result", string.concat(separator="\n", lines))]
  end
  controler.json.endpoints.apply_source(register=register,method="POST","#{name}/start", apply("start"))
  controler.json.endpoints.apply_source(register=register,method="POST","#{name}/stop",  apply("stop"))
  controler.json.endpoints.apply_source(register=register,method="GET","#{name}/status",apply("status"))
end

# No registration for these guys, enable on a per-source basis!
