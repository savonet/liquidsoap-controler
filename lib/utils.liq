# Redefines list.mem_assoc..

# list.mem_assoc(key,l) returns true if l contains a pair
# (key,value)
# @category List
# @param a Key to look for
# @param l List of pairs (key,value)
def list.mem_assoc(a,l) =
  def f(cur, el) =
    if not cur then
      fst(el) == a
    else
      cur
    end
  end
  list.fold(f, false, l)
end

# More general list.assoc, which returns a default value
# is no assoc is found.
# @category List
# @param ~default Default value when no one could be found
# @param a Key to look for
# @param l List of pairs (key,value)
def list.assoc(~default,a,l)
  def f(cur, el) =
    if fst(el) == a then
      snd(el)
    else
      cur
    end
  end
  list.fold(f,default,l)
end
