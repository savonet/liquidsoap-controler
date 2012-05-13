%include "json.liq"

###############
# PRIVATE API #
###############

def controler.json.endpoints.apply_source(~register, ~method, name, apply) =
  # Handler
  def apply(~data, ~headers, ~uri, ~params, response) =
    error   = ["error"]
    options = 
       if data == "" then
         []
       else
         of_json(default=error, data)
       end

    if options == error then
      response(code=400,headers=[],[("error","Parse error")])
    else
      response(code=200,headers=[],apply(options))
    end
  end

  # Endpoint's uri
  uri = "/sources/#{name}"

  # Register the endpoint
  register(method=method, uri=uri, apply)

  # Add it to that source'endpoints
  # name is _always_ of the form: source_name(/foo/bar)
  name = list.hd(string.split(separator="/",name))
  controler.add_endpoint((method,uri), name)
end

%include "endpoints/apply.liq"

# Apply of all generic callbacks to a given source
def controler.json.endpoints.generic(~register, ~remove, ~name, source) =
  controler.json.endpoints.skip(register=register,name=name,source)
  controler.json.endpoints.shutdown(register=register,remove=remove,name=name,source)
end

def controler.json.endpoints.map_source(~register, ~remove, name, map) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    error  = [("error","Parse error")]
    params = of_json(default=error, data) 
    name   = params["name"]
    source = params["source"]

    if params == error then
      response(code=400,headers=[],error)
    elsif name == "" then
      response(code=400,headers=[],[("error","No name params")])
    elsif source == "" then
      response(code=400,headers=[],[("error","No source param")])
    elsif not controler.is_defined(source) then
      response(code=400,headers=[],[("error","Missing source: #{name}")])
    else
      # Get source
      s      = controler.get_source(source)
      mapped = map(name, s, data)

      # Register it
      controler.set_source(name, mapped)

      # If name != source, register generic endpoints
      if name != source then
        controler.json.endpoints.generic(register=register,remove=remove,name=name,mapped)
      end

      response(code=201, headers=[], []) 
     end
  end

  # Register handler
  register(method="POST", uri="/#{name}", create_source)
end

def controler.json.endpoints.map_sources(~register, ~remove, name, map) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    error  = [("error", [("some","invalid data")])]
    parsed = of_json(default=error, data)
    sources = list.assoc(default=[], "sources", parsed)
    options = list.assoc(default=[], "options", parsed)
    name    = options["name"]

    if parsed == error then
      response(code=400,headers=[],[("error","Parse error")])
    elsif name == "" then
      response(code=400,headers=[],[("error","No name param")])
    elsif sources == [] then
      response(code=400,headers=[],[("error","No sources!")])
    else
      # Grab all sources
      failed = ref []
      def f(el) =
        # TODO: Do something with second argument.. Define transition ?
        name = fst(el)
        if controler.is_defined(name) then
          controler.get_source(name)
        else
          failed := list.append([name], !failed)
          blank()
        end
      end
      sources = list.map(f, sources)

      if list.length(!failed) > 0 then
        failed = string.concat(separator=", ", !failed)
        response(code=400,headers=[],[("error","Missing sources: #{failed}")])
      else
        # Get new source
        source = map(name, sources, options)
 
        # Register it within the controler
        controler.set_source(name, source)

        # Register generic endpoints
        controler.json.endpoints.generic(register=register,remove=remove,name=name,source)

        response(code=201,headers=[],[])
      end
    end
  end

  # Register handler
  register(method="POST", uri="/#{name}", create_source)
end

def controler.json.endpoints.create_source(~register, ~remove, name, create) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    error   = [("error","Parse error")]
    options = of_json(default=error,data) 
    name    = options["name"]

    if name == "" then
      response(code=400,headers=[],[("error","No name param")])
    else
      # Get new source
      source = create(name, options)

      # Register it within the controler.
      controler.set_source(name, source)

      # Register generic endpoints
      controler.json.endpoints.generic(register=register,remove=remove,name=name,source)

      response(code=201,headers=[],[])
    end
  end

  # Register handler
  register(method="POST", uri="/#{name}", create_source)
end

# TODO: params!
def controler.json.endpoints.output_source(~register, ~remove, name, output) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    error   = [("error","Parse error")]
    options = of_json(default=error,data)
    name    = options["name"]
    source  = options["source"]

    if name == "" then
      response(code=400,headers=[],[("error","No name param")])
    elsif source == "" then
      response(code=400,headers=[],[("error","No source param")])
    elsif not controler.is_defined(source) then
      response(code=400,headers=[],[("error","Missing source: #{source}")])
    else
      # Create output
      s      = controler.get_source(source)
      output = output(fallible=source.fallible(s), s, data) 

      # Register it
      controler.set_source(name, output)

      # If name != source, register generic endpoints
      if name != source then
        controler.json.endpoints.generic(register=register,remove=remove,name=name,output)
      end

      # Add start/stop/status endpoints
      controler.json.endpoints.stateful(register=register,name=name,output)

      response(code=201,headers=[],[])  
    end
  end

  # Register handler
  register(method="POST", uri="/output/#{name}", create_source)
end

# List of endpoints
controler.json.endpoints.all = ref []

# Register an endpoint
def controler.json.endpoints.register(f) =
  controler.json.endpoints.all := list.append([f], !controler.json.endpoints.all)
end

# Now include them

%include "endpoints/create.liq"
%include "endpoints/map.liq"
%include "endpoints/output.liq"

##############
# PUBLIC API #
##############

# Enable all existing endpoints using a given register
def controler.json.endpoints.enable_all(~register, ~remove) =
  list.iter(fun (f) -> f(register=register,remove=remove), !controler.json.endpoints.all)
end
