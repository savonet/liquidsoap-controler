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
      controler.json.twooo(data=apply(options),response)
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
    ret   = string.extract(pattern="/#{name}/([^/]+)", uri)
    name  = ret["1"]

     if controler.is_defined(name) then
       source = controler.get_source(name)

       controler.set_source(name, map(name, source, data))

       controler.json.twooo(response)
     else
       response(code=400,headers=[],[("error","Missing source: #{name}")])
     end
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

def controler.json.endpoints.map_sources(~register, name, map) =
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
      ret   = string.extract(pattern="/#{name}/([^/]+)", uri)
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

        controler.json.twooo(response)
      end
    end
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

def controler.json.endpoints.create_source(~register, name, create) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret  = string.extract(pattern="/#{name}/([^/]+)", uri)
    name = ret["1"]

    # Get new source
    source = create(name, data)

    # Register it within the controler.
    controler.set_source(name, source)

    # Register generic endpoints
    controler.json.endpoints.generic(register=register,name=name,source)

    controler.json.twooo(response)
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

def controler.json.endpoints.output_source(~register, name, output) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret   = string.extract(pattern="/output/#{name}/([^/]+)", uri)
    name  = ret["1"]

     if controler.is_defined(name) then
       # Grab source
       source = controler.get_source(name)

       # Register it
       controler.set_source(name, output(fallible=source.fallible(source), source, data))

       # Add start/stop/status endpoints
       controler.json.endpoints.stateful(register=register,name=name,source)

       controler.json.twooo(response)
     else
       response(code=400,headers=[],[("error","Missing source: #{name}")])
     end
  end

  # Register handler
  register(method="PUT", uri="/output/#{name}/[^/]+", create_source)
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
