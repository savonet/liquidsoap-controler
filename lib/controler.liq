# List of controled sources
# Contains element of the form:
# (name, (souce, endpoints))
controler.sources = ref []

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

# Get a source (should check if source exists before!!)
def controler.get_source(name) =
  def f(cur, el) =
    if fst(el) == name then
      [fst(snd(el))]
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
        endpoints = snd(snd(el))
        list.append([(name, (source, endpoints))], cur)
      else
        list.append([el], cur)
      end
    end
    controler.sources := list.fold(f, [], !controler.sources)
  else
    controler.sources := list.append([(name, (source,[]))], !controler.sources)
  end
end

# Add an endpoint to a source's endpoints
def controler.add_endpoint(endpoint, name) =
  def f(cur, el) =
    if fst(el) == name then
      source    = fst(snd(el))
      endpoints = list.append([endpoint],snd(snd(el)))
      list.append([(name, (source, endpoints))], cur)
    else
      list.append([el], cur)
    end
  end
  controler.sources := list.fold(f, [], !controler.sources)
end

# Get all endpoints of a given source
def controler.get_endpoints(name) =
  def f(cur, el) =
    if fst(el) == name then
      [snd(snd(el))]
    else
      cur
    end
  end
  list.nth(list.fold(f, [], !controler.sources), 0)
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

# Now include endpoints.
%include "./endpoints.liq"
