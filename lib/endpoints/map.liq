# Register an endpoint to create a mksafe(source).
# @param ~register HTTP controler register handler
def controler.json.endpoints.mksafe(~register) =
  def map(name, source, options) =
    mksafe(source)
  end
  controler.json.endpoints.map_source(register=register, "mksafe", map)
end

controler.json.endpoints.register(controler.json.endpoints.mksafe)

# Register an endpoint to fetch a source's metadata
# @param ~register HTTP controler register handler
def controler.json.endpoints.metadata.get(~register) =
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
      controler.json.twooo(data=!meta,response)
    end

    # Register the endpoint
    register(method="GET", uri="/metadata/get/#{name}", get_meta)

    # Return source
    on_metadata(id=name,update_meta,source)
  end
  controler.json.endpoints.map_source(register=register, "metadata/get", map)
end

#Bug!
#controler.json.endpoints.register(controler.json.endpoints.metadata.get)

# Register an endpoint to set a source's metadata
# @param ~register HTTP controler register handler
def controler.json.endpoints.metadata.set(~register) =
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
        response(code=400,headers=[],error)
      else
        insert(parsed)
        controler.json.twooo(response)
      end
    end

    # Register the endpoint
    register(method="POST", uri="/metadata/set/#{name}", set_meta)

    # return new source
    source
  end
  controler.json.endpoints.map_source(register=register, "metadata/set", map)
end

#Bug!
#controler.json.endpoints.register(controler.json.endpoints.metadata.set)

# Register an endpoint to create a fallback source.
# @param ~register HTTP controler register handler
def controler.json.endpoints.fallback(~register) =
  def map(name, sources, options) =
    track_sensitive = list.mem("track_sensitive", options)

    fallback(id=name,track_sensitive=track_sensitive, sources)
  end
  controler.json.endpoints.map_sources(register=register, "fallback", map)
end

controler.json.endpoints.register(controler.json.endpoints.fallback)
