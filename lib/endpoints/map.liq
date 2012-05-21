# Register an endpoint to fetch a source's metadata
# @param ~register HTTP controler register handler
def controler.json.endpoints.metadata.get(~register, ~remove) =
  def map(name, source, options) =
    meta = ref []

    # Update current metadata
    # converted in UTF8
    def update_meta(m) =
      m      = metadata.export(m)
      recode = string.recode(out_enc="UTF-8")
      def f(x) =
        (recode(fst(x)),recode(snd(x)))
      end
      meta := list.map(f,m)
    end

    # Return the json content of meta
    def get_meta(~data, ~headers, ~uri, ~params, response) =
      response(code=200,headers=[],json_of(!meta))
    end

    # Endpoint's method and uri
    method = "GET"
    uri    = "/sources/#{name}/metadata"

    # Register the endpoint
    register(method=method, uri=uri, get_meta)

    # Add it to the source's endpoints
    controler.add_endpoint((method,uri), name)

    # Return source
    on_metadata(id=name,update_meta,source)
  end
  controler.json.endpoints.map_source(register=register, remove=remove, "get_metadata", map)
end

controler.json.endpoints.register(controler.json.endpoints.metadata.get)

# Register an endpoint to set a source's metadata
# @param ~register HTTP controler register handler
def controler.json.endpoints.metadata.set(~register, ~remove) =
  def map(name, source, options) =
    # x is of type ((metadata)->unit)*source
    # first part is a function used to update
    # metadata and second part is the source 
    # whose metadata are updated
    x = insert_metadata(source)
    insert = fst(x)
    source = snd(x)

    # Handler
    def set_meta(~data, ~headers, ~uri, ~params, response) =
      error  = [("error","Parse error!")]
      parsed = of_json(default=error, data)
      if parsed == error then
        response(code=400,headers=[],json_of(error))
      else
        insert(parsed)
        response(code=200,headers=[],"")
      end
    end

    # Endpoint's method and uri
    method = "PUT"
    uri    = "/sources/#{name}/metadata"

    # Register the endpoint
    register(method=method, uri=uri, set_meta)

    # Add it to the source's endpoints
    controler.add_endpoint((method,uri), name)

    # return new source
    source
  end
  controler.json.endpoints.map_source(register=register, remove=remove, "set_metadata", map)
end

controler.json.endpoints.register(controler.json.endpoints.metadata.set)

# Register an endpoint to create a fallback source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.fallback(~register, ~remove) =
  def map(name, sources, options) =
    track_sensitive = bool_of_string(default=true,options["track_sensitive"])

    fallback(id=name,track_sensitive=track_sensitive, sources)
  end
  controler.json.endpoints.map_sources(register=register, remove=remove, "fallback", map)
end

controler.json.endpoints.register(controler.json.endpoints.fallback)
