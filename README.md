# ldForm

Form validation helper


## Usage

    form = new ldForm(config);


ldForm automatically scan every input fields by `\*[name]` selector, so you must provide name attributes for each input or .form-control element:

    <input type="text" name="username"/>
    <textarea class="form-control" name="description"/>

Or, you can specify your own `getFields` function to apply your own rules.

Additionally, if you have an element with its type being 'submit', ldForm will automatically remove it's 'disabled' class when validation passed. You can overwrite this behavior by manually specify a submit element with `submit` option.

For nested form, simply add a `ldform` attribute as scoping element to separate them:

    <div ldform>
      <input name="a">
      <div ldform>
        <!-- b is scoped and won't be handled, unless we have another ldForm over #form2 -->
        <input name="b">
      </form>
    </form>


## Configurations

 * root: base element for this form. HTMLElement or CSS Selector. Required.
 * init(): init function.
 * verify(name, value, element): validation function.
   * input:
     * name: field name
     * value: field value
     * element: field element
   * returns: status value ( see Status Object below )
   * optional. if omitted, ldForm will check against emptiness.
 * getFields(root): customized rules for getting fields.
   input: root - root element for ldForm
   return: fields object ( see below )
   if omitted, default to use selector `\*[name]`
   
 * names(status, fields): return list of name for fields to check. if omitted, default to all fields.
   * input:
     * status: status object, see below
     * fields: field elements object.
 * afterCheck(status, fields): custom function for doing anything after check
   * input: see below
 * debounce(n, s): should check call debounce?
   * input
     * n - event field name
     * s - status object
   * returns: true (debounce) / false (no debounce)
 * values: hash object with default values for corresponding keys.
 * submit: specify the element to be un-disabled when form is validated.
 * initCheck: force a checkAll at initialization.


## Status Object

An object with each key corresponding to a field and value of that key corresponding to field status. For example:

    {
        "name": 0,
        "password": 2,
        "recaptcha": 3,
        "newsletter": 1
    }

The values have following meaning:

 * 0 - valid
 * 1 - untouched ( not yet edit )
 * 2 - invalid
 * 3 - editing
 * 4 ~ 9 - preserved
 * 10 and above - user defined.


## Fields Object

An object containing fields elements, such as:

    {
        "name": ...,
        "password": ...,
        "recaptcha": ...,
        "newsletter": ...
    }


## Methods

 * ready - return true if form is valid and ready to engage.
 * check({n, now}) - check fields for all touched fields. if n is provided, touch the field named n.
   if now = true, check immediately without debouncing.
   to check multiple fields, provide a list:

       check([{...}, {...}, ... ])

 * values
   - without parameter: get values for all fields with a name.
   - else: param should be a hash object with name - value pairs for each fields.
 * on(event-name, cb) - listen to event "event-name" by callback cb. current supported event:
   - readystatechange: (is-ready) - fired if ready state is changed.
 * reset - clear form fields and reset status ( clear is-invalid  / is-valid classes )
 * field(n) - get input field with name 'n'
 * checkAll() - force check all fields immediately. useful in programmatically input fields.
   - set initCheck config to true for a shorthand check on initialization.
 * getfd - get FormData object corresponding to all fields in this form.


## License

MIT License
