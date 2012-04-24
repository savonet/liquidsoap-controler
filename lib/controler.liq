%include "json.liq"
%include "../config/params.liq"

# List of controled sources
controler.sources = ref []

# Enable controler
controler.http.json.register = http.json.enable_controler(port=controler.port)

# Pre-apply user and password
controler.http.json.register = controler.http.json.register(user=controler.user, password=controler.password)

##############
# Public API #
##############

# Is a source defined?
def controler.is_defined(name) =
  def f(cur, el) =
    if not cur then
      fst(el) == name
    else
      cur
    end
  end
  list.fold(f, false, !controler.sources) 
end

########################
# Internal functions!! #
########################

# Get a source (should check if source exists before!!)
def controler.get_source(name) =
  def f(cur, el) =
    if fst(el) == name then
      [snd(el)]
    else
      cur
    end
  end
  list.nth(list.fold(f, [], !controler.sources), 0)
end

# Replace/define a source
def controler.set_source(name, source) =
  if controler.is_defined(name) then
    def f(cur, el) =
      if fst(el) == name then
        list.append([(name, source)], cur)
      else
        list.append([el], cur)
      end
    end
    controler.sources := list.fold(f, [], !controler.sources)
  else
    controler.sources := list.append([(name, source)], !controler.sources)
  end
end

# Wrap a source after a callback
def controler.wrap_source(name, f) =
  if not controler.is_defined(name) then
    false
  else
    source = controler.get_source(name)
    source = f(name, source)
    controler.set_source(name, source)
    true
  end
end

##############
# Public API #
##############

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
