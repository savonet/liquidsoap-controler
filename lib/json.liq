%include "http.liq"

# Default json headers
json_headers = [("Content-Type","application/json; charset=utf-8")]

# 404 handler that returns json data
def http.json.controler.fourofour(~data, ~headers, ~uri, ~params, response) =
  response(code=404, headers=[], [("error","Page not found!")])
end

# Default 200 response
def http.json.controler.twooo(~data=[],response) =
  response(code=200, headers=[], data)
end

# Default 401 handler
def http.json.controler.fouroone(~data, ~headers, ~uri, ~params, response) =
  headers = [("WWW-Authenticate", "Basic realm=\"Liquidsoap Controler\"")]
  response(code=401, headers=headers, [("error","Unauthorized!")])
end

# Same as http.enable_controler except that
# it _always_ returns json data. Consequently, 
# called handler should _never_ set Content-Type
# header.
def http.json.enable_controler(~fourofour=http.json.controler.fourofour, 
                               ~fouroone=http.json.controler.fouroone, 
                               ~prefix="/", ~port) =
  # Wrap a handler
  def wrap_handler(handler) =
    def handler(~headers, ~data, ~uri, ~params, response) =
      def response(~code, ~headers, data) =
        headers = list.append(headers, json_headers)
        response(code=code, headers=headers, json_of(compact=true, data))
      end

      handler(headers=headers, data=data, uri=uri, params=params, response)
    end

    handler
  end

  # Register to main controler
  register_endpoint = http.enable_controler(fourofour=wrap_handler(fourofour),
                                            fouroone=wrap_handler(fouroone),
                                            prefix=prefix, port=port)

  # Wrap registered endpoints
  def register_endpoint(~user, ~password, ~uri, ~method, handler) =
    register_endpoint(user=user, password=password, uri=uri, method=method, 
                      wrap_handler(handler))
  end

  register_endpoint
end

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
    error    = ["error"]
    parsed   = of_json(default=error, data)
    print("requests: #{parsed}")
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

# Register an endpoint to create a new source.
# @param ~register HTTP controler register handler
# @param handler Source creation handler. Receives headers and data sent to the endpoint and creates a source as it sees fit. It returns a value of the form (bool, data). If bool is false then creation is assumed to have failed and response code is set to 400.
def http.controler.create_source(~register, handler) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret = handler(headers=headers, data)
    ok   = fst(ret)
    data = snd(ret)
    if not ok then
      response(code=400, headers=[], data)
    else
      http.json.controler.twooo(data=data,response)
    end
  end

  # Register handler
  register(method="PUT", uri="/sources", create_source) 
end
