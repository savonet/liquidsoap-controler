%include "json.liq"
%include "controler.liq"

# Register an endpoint to push a request to a given source
# Returns a new source that should be used in lieu of the 
# given source.
# @param ~register HTTP controler register handler
# @param ~name Source's ID for the endpoint (/sources/:name/metadata)
def http.json.controler.apply_source(~register, name, apply) =
  # Handler
  def apply(~data, ~headers, ~uri, ~params, response) =
    error   = ["error"]
    options = of_json(default=error, data)

    if options == error then
      response(code=400,headers=[],[("error","Parse error")])
    else
      http.json.controler.twooo(data=apply(name, options),response)
    end
  end

  # Register the endpoint
  register(method="POST", uri="/#{name}", apply)
end

# Register an endpoint to create a mksafe(source).
# @param ~register HTTP controler register handler
def http.json.controler.map_source(~register, name, map) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret   = string.extract(pattern="/#{name}/([^/]+)", uri)
    name  = ret["1"]

     if controler.is_defined(name) then
       source = controler.get_source(name)

       controler.set_source(name, map(name, source, data))

       http.json.controler.twooo(response)
     else
       response(code=400,headers=[],[("error","Missing source: #{name}")])
     end
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

# Register an endpoint to create a fallback source.
# @param ~register HTTP controler register handler
def http.json.controler.map_sources(~register, name, map) =
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
        controler.set_source(name, map(name, sources, options))

        http.json.controler.twooo(response)
      end
    end
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

# Register an endpoint to create a request.queue source.
# @param ~register HTTP controler register handler
def http.json.controler.create_source(~register, name, create) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret  = string.extract(pattern="/#{name}/([^/]+)", uri)
    name = ret["1"]

    # Register it within the controler.
    controler.set_source(name, create(name, data))

    # Enable request push on this source.
    http.json.controler.twooo(response)
  end

  # Register handler
  register(method="PUT", uri="/#{name}/[^/]+", create_source)
end

# Register an endpoint to create a output.ao(source).
# @param ~register HTTP controler register handler
def http.json.controler.output_source(~register, name, output) =
  # Handler
  def create_source(~data, ~headers, ~uri, ~params, response) =
    ret   = string.extract(pattern="/output/#{name}/([^/]+)", uri)
    name  = ret["1"]

     if controler.is_defined(name) then
       source = controler.get_source(name)

       controler.set_source(name, output(source, data))

       http.json.controler.twooo(response)
     else
       response(code=400,headers=[],[("error","Missing source: #{name}")])
     end
  end

  # Register handler
  register(method="PUT", uri="/output/#{name}/[^/]+", create_source)
end

%include "endpoints/apply.liq"
%include "endpoints/create.liq"
%include "endpoints/map.liq"
%include "endpoints/output.liq"
