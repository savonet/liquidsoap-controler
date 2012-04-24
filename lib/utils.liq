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
