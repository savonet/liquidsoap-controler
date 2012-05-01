%include "controler.liq"
%include "endpoints.liq"
%include "../config/params.liq"

# Enable controler
controler.http.json.register = http.json.enable_controler(port=controler.port)

# Pre-apply user and password
controler.http.json.register = controler.http.json.register(user=controler.user, password=controler.password)


# Register a request.queue source
def controler.request.queue(name) =
  source = request.queue(id=name)
  controler.set_source(name, source)
end

# Register an output.ao for the given source
def controler.output.ao(name) =
  controler.wrap_source(name, fun (_, source) ->
    output.ao(source)
  )
end

# Wrap a source around a mksafe() call
def controler.mksafe(name) =
  controler.wrap_source(name, fun (_, source) ->
    mksafe(source)
  )
end

# Enable get metadata endpoint on a source.
# Returns false if no source with that name
# could be found..
def controler.get_metadata(name) =
  controler.wrap_source(name, fun (name, source) ->
    http.json.controler.get_metadata(register=controler.http.json.register, id=name, source)
  )
end

# Enable set metadata endpoint on a source
# Returns false if no source with that name
# could be found..
def controler.set_metadata(name) =
  controler.wrap_source(name, fun (name, source) ->
    http.json.controler.set_metadata(register=controler.http.json.register, id=name, source)
  )
end

# Enable push requests on a source (needs to be
# a request.(e)queue source!
def controler.push_requests(name) =
  controler.wrap_source(name, fun (name, source) ->
    http.json.controler.push_requests(register=controler.http.json.register, id=name, source)
  )
end
