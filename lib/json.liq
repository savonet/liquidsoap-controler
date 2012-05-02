%include "http.liq"

# Default json headers
json_headers = [("Content-Type","application/json; charset=utf-8")]

# 404 handler that returns json data
def controler.json.fourofour(~data, ~headers, ~uri, ~params, response) =
  response(code=404, headers=[], [("error","Page not found!")])
end

# Default 200 response
def controler.json.twooo(~data=[],response) =
  response(code=200, headers=[], data)
end

# Default 401 handler
def controler.json.fouroone(~data, ~headers, ~uri, ~params, response) =
  headers = [("WWW-Authenticate", "Basic realm=\"Liquidsoap Controler\"")]
  response(code=401, headers=headers, [("error","Unauthorized!")])
end

# Same as http.enable_controler except that
# it _always_ returns json data. Consequently, 
# called handler should _never_ set Content-Type
# header.
def controler.enable_json(~fourofour=controler.json.fourofour, 
                          ~fouroone=controler.json.fouroone, 
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
  register_endpoint = controler.enable_http(fourofour=wrap_handler(fourofour),
                                            fouroone=wrap_handler(fouroone),
                                            prefix=prefix, port=port)

  # Wrap registered endpoints
  def register_endpoint(~user, ~password, ~uri, ~method, handler) =
    register_endpoint(user=user, password=password, uri=uri, method=method, 
                      wrap_handler(handler))
  end

  register_endpoint
end
