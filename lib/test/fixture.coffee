# TODO: Write automated tests based on this fixture

a = '1' # ok

bb = '2' # unused
ccc = '3' # unused
dddd = '4' # unused

eeeee.prop = '' # undefined
ggggggg['prop'] = 1 # undefined

a.a = 1
a[hhhhhhhh] = 1 # undefined

func1 = (arg1, arg2, arg3) -> # unused, unused
  arg1 # ok
  arg4 # undefined

func2 = (arg1, arg2) -> # ok
  arg2 # ok
  arg3 # undefined
  arg4 # undefined

func2() # ok
func3() # undefined

f1 = (usedInF1ButNotF2) -> # ok
  usedInF1ButNotF2() # ok

f2 = -> # ok
  usedInF1ButNotF2 = '' # unused

f1()
f2()
