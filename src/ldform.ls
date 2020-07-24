ldForm = (opt={}) ->
  @ <<< opt: opt, root: root = if typeof(opt.root) == \string => ld$.find(document, opt.root, 0) else opt.root
  @evt-handler = {}
  @fields = fields = {}
  @status = status = {all: 1}
  @el = el = {}
  if opt.submit? => el.submit = if typeof(opt.submit) == \string => ld$.find(@root, opt.submit, 0) else opt.submit
  if !el.submit => if ld$.find(root, '[type=submit]',0) => el.submit = that
  <[debounce verify names getFields afterCheck]>.map (n) ~> if opt[n] => @[n] = opt[n]
  check = (e) ~> @check {n: (if e and e.target => e.target.getAttribute(\name) else undefined), e: e}
  @fields = fields = @get-fields(root)
  @values(opt.values or {})
  for k,v of fields =>
    (if Array.isArray(v) => v else [v]).map (f) -> f.addEventListener \input, check
    status[k] = 1


  # n: field name. e: optional event object
  # we put it here because debounce function should create instance for each object.
  # if we put it in prototype, then there will be conflicts between form objects.
  @check-debounced = debounce 330, (n,fs,s,res,rej) ->
    names = @names s
    all = s.all
    delete s.all
    @after-check s, fs
    len = names
      .map (n) -> ((s[n]?) and s[n] == 0) # s defined and valid
      .filter -> !it # leave those invalid
      .length
    # user might not customize s.all in after-check.
    # if it's not updated, we then calculate it for them.
    if !(s.all?) => s.all = if !len => 0 else 1
    names.map (n) ->
      (if Array.isArray(fs[n]) => fs[n] else [fs[n]]).map (f) ->
        f.classList
          ..toggle \is-invalid, s[n] == 2
          ..toggle \is-valid, s[n] < 1
    if all != s.all => @fire \readystatechange, s.all == 0
    if @el.submit => that.classList.toggle \disabled, (s.all != 0)
    res!


  if opt.init => opt.init.apply @
  if @opt.init-check => @check-all!
  @

ldForm.prototype = Object.create(Object.prototype) <<< do
  on: (n, cb) -> @evt-handler.[][n].push cb
  fire: (n, ...v) -> for cb in (@evt-handler[n] or []) => cb.apply @, v
  field: (n) -> @fields[n]
  reset: ->
    [s,fs] = [@status, @fields]
    s.all = 1
    @names(s).map (n) ~>
      v = fs[n]
      if Array.isArray(v) => v.map (f) ->
        f.checked = it.defaultChecked
        f.classList.remove \is-invalid, \is-valid
      else
        v.value = ''
        v.classList.remove \is-invalid, \is-valid
      s[n] = 1
    @check!
  ready: -> @status.all == 0
  verify: (n, v, e) -> return if v => 0 else 2
  names: -> [k for k of @fields]
  debounce: -> true
  after-check: ->
  values: (val) ->
    if val? =>
      for k,v of val or {} =>
        if !(fs = @fields[k]) => continue
        fs = if Array.isArray(fs) => fs else [fs]
        fs.map (f) ~>
          type = f.getAttribute(\type)
          if type == \file => return
          else if type == \radio => f.checked = (f.value == v)
          else if type == \checkbox => f.checked = (f.value in (v or []))
          else @fields[k].value = v
    else
      ret = {}
      for k,v of @fields =>
        (if Array.isArray(v) => v else [v]).map (f) ->
          type = f.getAttribute(\type)
          if type == \checkbox
            if f.checked => ret[][k].push f.value
          else if type == \radio
            if f.checked => ret[k] = f.value
          else ret[k] = if f.getAttribute(\type) == \checkbox => f.checked else f.value
      return ret

  getfd: ->
    fd = new FormData!
    for k,v of @fields =>
      # if we omit the (), else will not be executed when !v.files. so keep it here.
      if v.files and v.files.length => (for i from 0 til v.files.length => fd.append "#k[]", v.files[i])
      else if Array.isArray(v) => v.map (f)-> if f.checked => fd.append "#k[]", f.value
      else fd.append k, v.value
    return fd

  get-fields: (root) ->
    ret = {}
    ld$.find(@root, '[name]').map (f) ->
      n = f.getAttribute(\name)
      if ret[n] => (if Array.isArray(ret[n]) => ret[n].push f else ret[n] = [ret[n], f])
      else ret[n] = f

    ret

  check-all: -> Promise.all (for k,v of @fields => @check {n: k, now: true})
  check: (opt = {}) -> new Promise (res, rej) ~>
    {n,e,now} = opt{n,e,now}
    if n and !(n in @names(s)) => return
    if n? and !@fields[n] => return rej new Error("ldForm.check: field #n not found.")
    [fs,s] = [@fields, @status]
    if fs[n] =>
      if !Array.isArray(fs[n]) => v = fs[n].value
      else
        v = fs[n].filter(->it.checked).map(->it.value)
        if fs[n].0.getAttribute(\type) == \radio => v = v.0
      s[n] = @verify( n, v, fs[n])
    if @debounce(n, s) and !now => @check-debounced(n,fs,s,res,rej) else @check-debounced(n,fs,s,res,rej).now!
