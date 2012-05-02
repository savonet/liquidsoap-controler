# List of controled sources
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

# Now include endpoints.
%include "./endpoints.liq"
