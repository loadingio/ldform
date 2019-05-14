# ldForm

Form validation helper


## Usage

    form = new ldForm(config);


ldForm automatically scan every input fields by '''\*[name]''' selector, so you must provide name attributes for each input or .form-control element:

    <input type="text" name="username"/>
    <textarea class="form-control" name="description"/>

Or, you can specify your own '''getFields''' function to apply your own rules.


## Configurations

 * root: base element for this form. HTMLElement or CSS Selector. Required.
 * init(): init function.
 * valid(name, value, element): validation function.
   * input:
     * name: field name
     * value: field value
     * element: field element
   * return value: true (valid) / false (invalid)
   * optional. if omitted, ldForm will check against emptiness.
 * getFields(root): customized rules for getting fields.
   input: root - root element for ldForm
   return: fields object ( see below )
   if omitted, default to use selector '''\*[name]'''
   
 * names(status, fields): return list of name for fields to check. if omitted, default to all fields.
   * input:
     * status: status object, see below
     * fields: field elements object.
 * afterCheck(status, fields): custom function for doing anything after check
   * input: see below
 * debounce


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
 * check(n) - check fields for all touched fields. if n is provided, touch the field named n.


## License

MIT License
