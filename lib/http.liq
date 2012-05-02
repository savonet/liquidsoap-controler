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

# Default 404 handler
def controler.http.fourofour(~data, ~headers, ~uri, ~params, response) =
  response(code=404, headers=[], "Page not found!")
end

# Default 401 handler
def controler.http.fouroone(~data, ~headers, ~uri, ~params, response) =
  headers = [("WWW-Authenticate", "Basic realm=\"Liquidsoap Controler\"")]
  response(code=401, headers=headers, "Unauthorized!")
end

# Enable HTTP controler on a given port
# @param ~fourofour Handler used when no other handler could be found
# @param ~fouroone Handler used when authentication failed
# @param ~prefix Prefix for all registered endpoints.
# @param ~port Registered port
def controler.enable_http(~fourofour=controler.http.fourofour,
                          ~fouroone=controler.http.fouroone, 
                          ~prefix="/", ~port) =
  # Registered endpoints, contains values
  # of the form: (("uri", "method"), handler)
  endpoints = ref []

  # Register a new endpoint
  def register_endpoint(~user="", ~password="", ~uri, ~method, handler) =
    def handler(~data, ~headers, ~uri, ~params, response) =
      # If user != "" or password != "", wrap the call around a basic authentication
      if (user != "" and password != "") and 
          not http.authenticate.basic(user=user, password=password, headers=headers) then
        fouroone(data=data, headers=headers, uri=uri, params=params, response)
      else
        handler(data=data, headers=headers, uri=uri, params=params, response)
      end
    end
    endpoints := list.append([((uri,method), handler)], !endpoints)
  end

  # Master endpoints controler
  def handler(~method,~protocol,~data,~headers,uri) =
    def f(current_handler, element) =
      x             = fst(element)
      endpoint      = fst(x)
      target_method = snd(x)
      handler       = snd(element)
   
      if string.match(pattern=endpoint, uri) and method == target_method then
        handler
      else
        current_handler
      end
    end
 
    # Get handler  
    handler = list.fold(f, fourofour, !endpoints)

    # Response callback, use default values if
    # no override is passed by the handler.
    def response(~code, ~headers, data) =
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
 
    handler(data=data, headers=headers, uri=uri, params=params, response)
  end

  harbor.http.register(port=port, "^#{prefix}.*", handler)

  register_endpoint
end
