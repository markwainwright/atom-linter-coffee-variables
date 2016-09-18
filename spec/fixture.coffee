# this comment is to avoid the code starting on line 1

a = '1' # ok

b = '2' # b unused

c.c = '' # c not defined
d['d'] = 1 # d not defined

a.a = 1 # ok
a[e] = 1 # e not defined

f1 = (f1a1, f1a2, f1a3) -> # f1a3 unused
  f1a1() # ok
  f1a4() # f1a4 not defined

f2 = (f2a1, f2a2) -> # ok
  f2a2 # ok
  f2a3 # f2a3 not defined
  f2a4 # f2a4 not defined

f3 = (f4a1) => # ok with fat arrow
  f4a1.foo # ok

f3 = (f4a1) -> # f4a1 unused
  '' # ok

f1() # ok
f2() # ok
f3() # ok
f4() # f4 not defined

atom.workspace.observeTextEditors() # no undefined error
