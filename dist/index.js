(function(){
  var ldform;
  ldform = function(opt){
    var root, fields, status, el, that, check, k, v, this$ = this;
    opt == null && (opt = {});
    this.opt = opt;
    this.root = root = typeof opt.root === 'string'
      ? ld$.find(document, opt.root, 0)
      : opt.root;
    this.evtHandler = {};
    this.fields = fields = {};
    this.status = status = {
      all: 1
    };
    this.el = el = {};
    if (opt.submit != null) {
      el.submit = typeof opt.submit === 'string'
        ? ld$.find(this.root, opt.submit, 0)
        : opt.submit;
    }
    if (!el.submit) {
      if (that = ld$.find(root, '[type=submit]', 0)) {
        el.submit = that;
      }
    }
    ['debounce', 'verify', 'names', 'getFields', 'afterCheck'].map(function(n){
      if (opt[n]) {
        return this$[n] = opt[n];
      }
    });
    check = function(e){
      return this$.check({
        n: e && e.target ? e.target.getAttribute('name') : undefined,
        e: e
      });
    };
    this.fields = fields = this.getFields(root);
    this.values(opt.values || {});
    for (k in fields) {
      v = fields[k];
      (Array.isArray(v)
        ? v
        : [v]).map(fn$);
      status[k] = 1;
    }
    this.checkDebounced = debounce(330, function(n, fs, s, res, rej){
      var names, all, len, that;
      names = this.names(s);
      all = s.all;
      delete s.all;
      this.afterCheck(s, fs);
      len = names.map(function(n){
        return s[n] != null && s[n] === 0;
      }).filter(function(it){
        return !it;
      }).length;
      if (!(s.all != null)) {
        s.all = !len ? 0 : 1;
      }
      names.map(function(n){
        return (Array.isArray(fs[n])
          ? fs[n]
          : [fs[n]]).map(function(f){
          var x$;
          x$ = f.classList;
          x$.toggle('is-invalid', s[n] === 2);
          x$.toggle('is-valid', s[n] < 1);
          return x$;
        });
      });
      if (all !== s.all) {
        this.fire('readystatechange', s.all === 0);
      }
      if (that = this.el.submit) {
        that.classList.toggle('disabled', s.all !== 0);
      }
      return res();
    });
    if (opt.init) {
      opt.init.apply(this);
    }
    if (this.opt.initCheck) {
      this.checkAll();
    }
    return this;
    function fn$(f){
      return f.addEventListener('input', check);
    }
  };
  ldform.prototype = import$(Object.create(Object.prototype), {
    on: function(n, cb){
      var ref$;
      return ((ref$ = this.evtHandler)[n] || (ref$[n] = [])).push(cb);
    },
    fire: function(n){
      var v, res$, i$, to$, ref$, len$, cb, results$ = [];
      res$ = [];
      for (i$ = 1, to$ = arguments.length; i$ < to$; ++i$) {
        res$.push(arguments[i$]);
      }
      v = res$;
      for (i$ = 0, len$ = (ref$ = this.evtHandler[n] || []).length; i$ < len$; ++i$) {
        cb = ref$[i$];
        results$.push(cb.apply(this, v));
      }
      return results$;
    },
    field: function(n){
      return this.fields[n];
    },
    reset: function(){
      var ref$, s, fs;
      ref$ = [this.status, this.fields], s = ref$[0], fs = ref$[1];
      s.all = 1;
      this.names(s).map(function(n){
        var v;
        v = fs[n];
        if (Array.isArray(v)) {
          v.map(function(f){
            f.checked = it.defaultChecked;
            return f.classList.remove('is-invalid', 'is-valid');
          });
        } else {
          v.value = '';
          v.classList.remove('is-invalid', 'is-valid');
        }
        return s[n] = 1;
      });
      return this.check();
    },
    ready: function(){
      return this.status.all === 0;
    },
    verify: function(n, v, e){
      return v ? 0 : 2;
    },
    names: function(){
      var k, results$ = [];
      for (k in this.fields) {
        results$.push(k);
      }
      return results$;
    },
    debounce: function(){
      return true;
    },
    afterCheck: function(){},
    values: function(val){
      var k, ref$, v, fs, ret, results$ = [], this$ = this;
      if (val != null) {
        for (k in ref$ = val || {}) {
          v = ref$[k];
          if (!(fs = this.fields[k])) {
            continue;
          }
          fs = Array.isArray(fs)
            ? fs
            : [fs];
          results$.push(fs.map(fn$));
        }
        return results$;
      } else {
        ret = {};
        for (k in ref$ = this.fields) {
          v = ref$[k];
          (Array.isArray(v)
            ? v
            : [v]).map(fn1$);
        }
        return ret;
      }
      function fn$(f){
        var type;
        type = f.getAttribute('type');
        if (type === 'file') {} else if (type === 'radio') {
          return f.checked = f.value === v;
        } else if (type === 'checkbox') {
          return f.checked = in$(f.value, v || []);
        } else {
          return this$.fields[k].value = v;
        }
      }
      function fn1$(f){
        var type;
        type = f.getAttribute('type');
        if (type === 'checkbox') {
          if (f.checked) {
            return (ret[k] || (ret[k] = [])).push(f.value);
          }
        } else if (type === 'radio') {
          if (f.checked) {
            return ret[k] = f.value;
          }
        } else {
          return ret[k] = f.getAttribute('type') === 'checkbox'
            ? f.checked
            : f.value;
        }
      }
    },
    getfd: function(){
      var fd, k, ref$, v, i$, to$, i;
      fd = new FormData();
      for (k in ref$ = this.fields) {
        v = ref$[k];
        if (v.files && v.files.length) {
          for (i$ = 0, to$ = v.files.length; i$ < to$; ++i$) {
            i = i$;
            fd.append(k + "[]", v.files[i]);
          }
        } else if (Array.isArray(v)) {
          v.map(fn$);
        } else {
          fd.append(k, v.value);
        }
      }
      return fd;
      function fn$(f){
        if (f.checked) {
          return fd.append(k + "[]", f.value);
        }
      }
    },
    getFields: function(root){
      var ret, this$ = this;
      ret = {};
      ld$.find(this.root, '[name]').map(function(f){
        var form, n;
        form = ld$.parent(f, '[ldform]', this$.root);
        if (form && this$.root !== form) {
          return;
        }
        n = f.getAttribute('name');
        if (ret[n]) {
          if (Array.isArray(ret[n])) {
            return ret[n].push(f);
          } else {
            return ret[n] = [ret[n], f];
          }
        } else {
          return ret[n] = f;
        }
      });
      return ret;
    },
    checkAll: function(){
      var k, v;
      return Promise.all((function(){
        var ref$, results$ = [];
        for (k in ref$ = this.fields) {
          v = ref$[k];
          results$.push(this.check({
            n: k,
            now: true
          }));
        }
        return results$;
      }.call(this)));
    },
    check: function(opt){
      var this$ = this;
      opt == null && (opt = {});
      if (Array.isArray(opt)) {
        return Promise.all(opt.map(function(it){
          return this$.check(it);
        }));
      }
      return new Promise(function(res, rej){
        var ref$, n, e, now, fs, s, v;
        ref$ = {
          n: opt.n,
          e: opt.e,
          now: opt.now
        }, n = ref$.n, e = ref$.e, now = ref$.now;
        if (n && !in$(n, this$.names(s))) {
          return;
        }
        if (n != null && !this$.fields[n]) {
          return rej(new Error("ldform.check: field " + n + " not found."));
        }
        ref$ = [this$.fields, this$.status], fs = ref$[0], s = ref$[1];
        if (fs[n]) {
          if (!Array.isArray(fs[n])) {
            v = fs[n].value;
          } else {
            v = fs[n].filter(function(it){
              return it.checked;
            }).map(function(it){
              return it.value;
            });
            if (fs[n][0].getAttribute('type') === 'radio') {
              v = v[0];
            }
          }
          s[n] = this$.verify(n, v, fs[n]);
        }
        if (this$.debounce(n, s) && !now) {
          return this$.checkDebounced(n, fs, s, res, rej);
        } else {
          return this$.checkDebounced(n, fs, s, res, rej).now();
        }
      });
    }
  });
  if (typeof module != 'undefined' && module !== null) {
    module.exports = ldform;
  } else if (typeof window != 'undefined' && window !== null) {
    window.ldform = ldform;
  }
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
  function in$(x, xs){
    var i = -1, l = xs.length >>> 0;
    while (++i < l) if (x === xs[i]) return true;
    return false;
  }
}).call(this);
