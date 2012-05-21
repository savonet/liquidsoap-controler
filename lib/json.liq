%include "http.liq"

# Default json headers
json_headers = [("Content-Type","application/json; charset=utf-8")]

# Default 401 handler
def controler.json.fouroone(~data, ~headers, ~uri, ~params, response) =
  headers = [("WWW-Authenticate", "Basic realm=\"Liquidsoap Controler\"")]
  response(code=401, headers=headers, json_of([("error","Unauthorized!")]))
end

# Same as http.enable_controler except that
# it _always_ returns json data. Consequently, 
# called handler should _never_ set Content-Type
# header.
def controler.enable_json(~fouroone=controler.json.fouroone, 
                          ~prefix="/", ~port) =
  # Wrap a handler
  def wrap_handler(handler) =
    def handler(~headers, ~data, ~uri, ~params, response) =
      def response(~code, ~headers, data) =
        headers = list.append(headers, json_headers)
        response(code=code, headers=headers, data)
      end

      handler(headers=headers, data=data, uri=uri, params=params, response)
    end

    handler
  end

  # Register to main controler
  x = controler.enable_http(fouroone=wrap_handler(fouroone),
        prefix=prefix, port=port)
  register_endpoint = fst(x)
  remove_endpoint   = snd(x)

  # Wrap registered endpoints
  def register_endpoint(~user, ~password, ~uri, ~method, handler) =
    register_endpoint(user=user, password=password, uri=uri, method=method, 
                      wrap_handler(handler))
  end

  (register_endpoint,remove_endpoint)
end
