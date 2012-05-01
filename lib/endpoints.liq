%include "json.liq"
%include "controler.liq"

# Register an endpoint to fetch a source's metadata
# Returns a new source that should be used in lieu of the 
# given source.
# @param ~register HTTP controler register handler
# @param ~id Source's ID for the endpoint (/sources/:id/metadata)
def http.json.controler.get_metadata(~register, ~id, source) =
  # Metadata reference
  meta = ref []

  # Update current metadata
  # converted in UTF8
  def update_meta(m) =
    m = metadata.export(m)
    recode = string.recode(out_enc="UTF-8")
    def f(x) =
      (recode(fst(x)),recode(snd(x)))
    end
    meta := list.map(f,m)
  end

  # Return the json content of meta
  def get_meta(~data, ~headers, ~uri, ~params, response) =
    http.json.controler.twooo(data=!meta,response)
  end

  # Register the endpoint
  register(method="GET", uri="/sources/#{id}/metadata", get_meta)

  # Return new source
  on_metadata(update_meta,source)
end

# Register an endpoint to set a source's metadata
# Returns a new source that should be used in lieu of the 
# given source.
# @param ~register HTTP controler register handler
# @param ~id Source's ID for the endpoint (/sources/:id/metadata)
def http.json.controler.set_metadata(~register, ~id, source) =
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
      http.json.controler.twooo(response)
    end
  end

  # Register the endpoint
  register(method="POST", uri="/sources/#{id}/metadata", set_meta)

  # return new source
  source
end

# Register an endpoint to push a request to a given source
# Returns a new source that should be used in lieu of the 
# given source.
# @param ~register HTTP controler register handler
# @param ~id Source's ID for the endpoint (/sources/:id/metadata)
def http.json.controler.push_requests(~register, ~id, source) =
  # Handler
  def push_requests(~data, ~headers, ~uri, ~params, response) =
    error  = ["error"]
    parsed = of_json(default=error, data)
    if parsed == error then
      response(code=400,headers=[],[("error","Parse error")])
    else
      def push(cur, request) =
        lines  = server.execute("#{source.id(source)}.push #{request}")
        list.append(cur, [(request, string.concat(separator="\n", lines))])
      end
      ret = list.fold(push, [], parsed)
      http.json.controler.twooo(data=ret,response)
    end
  end

  # Register the endpoint
  register(method="POST", uri="/sources/#{id}/requests", push_requests)

  # return new source
  source
end

# Register an endpoint to create a fallback source.
# @param ~register HTTP controler register handler
def http.json.controler.create.fallback(~register) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    error  = [("error", ["invalid data"])]
    parsed = of_json(default=error, data)
    sources = list.assoc(default=[], "sources", parsed)
    options = list.assoc(default=[], "options", parsed)
    if parsed == error then
      response(code=400,headers=[],[("error","Parse error")])
    elsif sources == [] then
      response(code=400,headers=[],[("error","No sources!")])
    else
      ret   = string.extract(pattern="/fallback/([^/]+)", uri)
      name  = ret["1"]

      # Grab all sources
      failed = ref []
      def f(name) =
        if controler.is_defined(name) then
          controler.get_source(name)
        else
          failed := list.append([name], !failed)
          blank()
        end
      end
      sources = list.map(f, sources)

      track_sensitive = list.mem("track_sensitive", options) 

      controler.set_source(
        name, 
        fallback(id=name, track_sensitive=track_sensitive, sources)
      )

      if list.length(!failed) > 0 then
        failed = string.concat(separator=", ", !failed)
        response(code=400,headers=[],[("error","Missing sources: #{failed}")])
      else
        http.json.controler.twooo(response)
      end
    end
  end

  # Register handler
  register(method="PUT", uri="/fallback/[^/]+", create_source)
end

# Register an endpoint to create a request.queue source.
# @param ~register HTTP controler register handler
def http.json.controler.create.request.queue(~register) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret  = string.extract(pattern="/request/queue/([^/]+)", uri)
    name = ret["1"]

    controler.set_source(name, request.queue(id=name))

    http.json.controler.twooo(response)
  end

  # Register handler
  register(method="PUT", uri="/request/queue/[^/]+", create_source)
end

# Register an endpoint to create a single source.
# @param ~register HTTP controler register handler
def http.json.controler.create.single(~register) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret  = string.extract(pattern="/single/([^/]+)", uri)
    name = ret["1"]

    controler.set_source(name, single(id=name, data))

    http.json.controler.twooo(response)
  end

  # Register handler
  register(method="PUT", uri="/single/[^/]+", create_source)
end
