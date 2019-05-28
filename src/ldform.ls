ldForm = (opt={}) ->
  @ <<< opt: opt, root: root = if typeof(opt.root) == \string => ld$.find(document, opt.root, 0) else opt.root
  @fields = fields = {}
  @status = status = {all: 1}
  <[debounce verify names getFields afterCheck]>.map (n) ~> if opt[n] => @[n] = opt[n]
  check = (e) ~> @check (if e and e.target => e.target.getAttribute(\name) else undefined), e
  @fields = fields = @get-fields(root)
  for k,v of fields => 
    v.addEventListener \change, check
    v.addEventListener \keyup, check
    status[k] = 1

  if opt.init => opt.init.apply @
  @

ldForm.prototype = Object.create(Object.prototype) <<< do
  ready: -> @status.all == 0
  verify: (n, v, e) -> return if v => 0 else 2
  names: -> [k for k of @fields]
  debounce: -> true
  after-check: ->
  values: ->
    ret = {}
    for k,v of @fields => ret[k] = if v.getAttribute(\type) == \checkbox => v.checked else v.value
    return ret

  get-fields: (root) ->
    ret = {}
    ld$.find(@root, '[name]').map (f) -> ret[f.getAttribute(\name)] = f
    ret
  # n: field name. e: optional event object
  check-debounced: debounce (e,n,fs,s,res,rej) ->
    names = @names s
    @after-check s, fs
    len = names
      .map (n) -> ((s[n]?) and s[n] == 0) # s defined and valid
      .filter -> !it # leave those invalid
      .length
    s.all = if !len => 0 else 1
    names.map (n) -> fs[n].classList
      ..toggle \is-invalid, s[n] == 2
      ..toggle \is-valid, s[n] < 1
    res!

  check: (n, e) -> new Promise (res, rej) ~>
    if n? and !@fields[n] => return rej new Error("ldForm.check: field #n not found.")
    [fs,s] = [@fields, @status]
    if fs[n] => s[n] = @verify(n, fs[n].value, fs[n])
    if @debounce(n, s) => @check-debounced(e,n,fs,s,res,rej) else @check-debounced.now(e,n,fs,s,res,rej)
