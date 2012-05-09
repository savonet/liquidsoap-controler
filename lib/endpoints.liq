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

  # Register the endpoint
  register(method=method, uri="/sources/#{name}", apply)
end

%include "endpoints/apply.liq"

# Apply of all generic callbacks to a given source
def controler.json.endpoints.generic(~register, ~name, source) =
  controler.json.endpoints.skip(register=register,name=name,source)
  controler.json.endpoints.shutdown(register=register,name=name,source)
end

def controler.json.endpoints.map_source(~register, name, map) =
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
      source = controler.get_source(source)

      controler.set_source(name, map(name, source, data))

      response(code=201, headers=[], []) 
     end
  end

  # Register handler
  register(method="PUT", uri="/#{name}", create_source)
end

def controler.json.endpoints.map_sources(~register, name, map) =
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
        controler.json.endpoints.generic(register=register,name=name,source)

        response(code=201,headers=[],[])
      end
    end
  end

  # Register handler
  register(method="PUT", uri="/#{name}", create_source)
end

def controler.json.endpoints.create_source(~register, name, create) =
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
      controler.json.endpoints.generic(register=register,name=name,source)

      response(code=201,headers=[],[])
    end
  end

  # Register handler
  register(method="PUT", uri="/#{name}", create_source)
end

# TODO: params!
def controler.json.endpoints.output_source(~register, name, output) =
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
      # Grab source
      source = controler.get_source(source)

      # Register it
      controler.set_source(name, output(fallible=source.fallible(source), source, data))

      # Add start/stop/status endpoints
      controler.json.endpoints.stateful(register=register,name=name,source)

      response(code=201,headers=[],[])  
    end
  end

  # Register handler
  register(method="PUT", uri="/output/#{name}", create_source)
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
def controler.json.endpoints.enable_all(~register) =
  list.iter(fun (f) -> f(register=register), !controler.json.endpoints.all)
end
