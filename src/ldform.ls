ldForm = (opt={}) ->
  @ <<< opt: opt, root: root = if typeof(opt.root) == \string => ld$.find(document, opt.root, 0) else opt.root
  @evt-handler = {}
  @fields = fields = {}
  @status = status = {all: 1}
  <[debounce verify names getFields afterCheck]>.map (n) ~> if opt[n] => @[n] = opt[n]
  check = (e) ~> @check {n: (if e and e.target => e.target.getAttribute(\name) else undefined), e: e}
  @fields = fields = @get-fields(root)
  for k,v of fields => 
    v.addEventListener \change, check
    v.addEventListener \keyup, check
    status[k] = 1

  if opt.init => opt.init.apply @
  @

ldForm.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  reset: ->
    [s,fs] = [@status, @fields]
    s.all = 1
    @names(s).map (n) ~>
      fs[n].value = ''
      fs[n].classList.remove \is-invalid, \is-valid
      s[n] = 1
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
  check-debounced: debounce 330, (n,fs,s,res,rej) ->
    names = @names s
    @after-check s, fs
    len = names
      .map (n) -> ((s[n]?) and s[n] == 0) # s defined and valid
      .filter -> !it # leave those invalid
      .length
    all = s.all
    s.all = if !len => 0 else 1
    names.map (n) -> fs[n].classList
      ..toggle \is-invalid, s[n] == 2
      ..toggle \is-valid, s[n] < 1
    if all != s.all => @fire \readystatechange, s.all == 0
    res!

  check: (opt = {}) -> new Promise (res, rej) ~>
    {n,e,now} = opt{n,e,now}
    if n? and !@fields[n] => return rej new Error("ldForm.check: field #n not found.")
    [fs,s] = [@fields, @status]
    if fs[n] => s[n] = @verify(n, fs[n].value, fs[n])
    if @debounce(n, s) and !now => @check-debounced(n,fs,s,res,rej) else @check-debounced(n,fs,s,res,rej).now!
