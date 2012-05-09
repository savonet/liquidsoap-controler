%include "utils.liq"

# Perform HTTP basic authentication.
# @param ~headers HTTP request headers
def http.authenticate.basic(~user, ~password, ~headers) =
  headers = list.map(fun (x) -> (string.case(fst(x)), snd(x)), headers)

  auth = string.extract(pattern="Basic (.+)", headers["authorization"])
  auth = list.assoc(default="","1", auth)

  if auth == "" then
    false
  else
    auth = base64.decode(auth)
    auth = string.split(separator=":", auth)

    if list.length(auth) < 2 then
      false
    else
      check_user     = list.nth(auth, 0)
      check_password = list.nth(auth, 1)

      check_user == user and check_password == password      
    end
  end
end

# Default 401 handler
def controler.http.fouroone(~data, ~headers, ~uri, ~params, response) =
  headers = [("WWW-Authenticate", "Basic realm=\"Liquidsoap Controler\"")]
  response(code=401, headers=headers, "Unauthorized!")
end

# Default headers, contains generic access-control stuff..
controler.http.default_headers =
  [("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type"),
   ("Access-Control-Allow-Methods", "PUT,GET,POST,DELETE"),
   ("Access-Control-Allow-Origin",  "*")]

# Enable HTTP controler on a given port
# @param ~fouroone Handler used when authentication failed
# @param ~prefix Prefix for all registered endpoints.
# @param ~port Registered port
def controler.enable_http(~fouroone=controler.http.fouroone, 
                          ~prefix="/", ~port) =
  # Register a new endpoint
  def register_endpoint(~user="", ~password="", ~uri, ~method, handler) =
    def handler(~protocol,~data,~headers,uri) =
      # Response callback, use default values if
      # no override is passed by the handler.
      def response(~code, ~headers, data) =
        headers = list.append(headers, controler.http.default_headers)

        http_response(
          protocol=protocol,
          code=code,
          headers=headers,
          data=string_of(data))
      end

      # Parse uri intro uri and params
      x      = url.split(uri)
      uri    = fst(x)
      params = snd(x)

      # If user != "" or password != "", wrap the call around a basic authentication
      if (user != "" and password != "") and 
          not http.authenticate.basic(user=user, password=password, headers=headers) then
        fouroone(data=data, headers=headers, uri=uri, params=params, response)
      else
        handler(data=data, headers=headers, uri=uri, params=params, response)
      end
    end

    # Register endpoint
    harbor.http.register(port=port, method=method, uri, handler)

  end

  # Register default OPTIONS endpoint
  def handler(~protocol, ~data, ~headers, uri) =
    http_response(protocol=protocol,code=200,headers=controler.http.default_headers)
  end
  harbor.http.register(port=port, method="OPTIONS", ".*", handler)

  register_endpoint
end
