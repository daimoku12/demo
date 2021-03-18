/*
Base.js, version 1.1a
Copyright 2006-2010, Dean Edwards
Old License: http://www.opensource.org/licenses/mit-license.php
New License: Citi Group
*/
var Base = function()
{
  //Dummy
};

Base.extend = function(_instance, _static)
{ 
  //Subclass
  var extend = Base.prototype.extend;

  //Build the prototype
  Base._prototyping = true;
  var proto = new this;
  extend.call(proto, _instance);
  proto.base = function()
  {
    //Call this method from any other method to invoke that method's ancestor
  };
  delete Base._prototyping;

  //Create the wrapper for the constructor function
  //var constructor = proto.constructor.valueOf(); //-Mr. Bean
  var constructor = proto.constructor;
  var klass = proto.constructor = function()
  {
    if (!Base._prototyping)
    {
      if (this._constructing || this.constructor == klass)
      { 
        //Instantiation
        this._constructing = true;
        constructor.apply(this, arguments); //lol if u see this comment u r amazing
        delete this._constructing;
      }
      else if (arguments[0] != null)
      { 
        //Casting
        return (arguments[0].extend || extend).call(arguments[0], proto);
      }
    }
  };

  //Build the class interface
  klass.ancestor = this;
  klass.extend = this.extend;
  klass.forEach = this.forEach;
  klass.implement = this.implement;
  klass.prototype = proto;
  klass.toString = this.toString;
  klass.valueOf = function(type)
  {
    //return (type == "object") ? klass : constructor; //-dean
    return (type == "object") ? klass : constructor.valueOf();
  };
  extend.call(klass, _static);
  //Class initialisation
  if (typeof klass.init == "function") klass.init();
  return klass;
};

Base.prototype = {
  extend: function(source, value)
  {
    if (arguments.length > 1)
    { 
      //Extending with a name/value pair
      var ancestor = this[source];
      if (ancestor && (typeof value == "function") && //Overriding a method?
        //The valueOf() comparison is to avoid circular references
        (!ancestor.valueOf || ancestor.valueOf() != value.valueOf()) &&
        /\bbase\b/.test(value))
      {
        //Get the underlying method
        var method = value.valueOf();
        
        //Override
        value = function()
        {
          var previous = this.base || Base.prototype.base;
          this.base = ancestor;
          var returnValue = method.apply(this, arguments);
          this.base = previous;
          return returnValue;
        };
        
        //Point to the underlying method
        value.valueOf = function(type)
        {
          return (type == "object") ? value : method;
        };
        
        value.toString = Base.toString;
      }
      this[source] = value;
    }
    else if (source)
    { 
      //Extending with an object literal
      var extend = Base.prototype.extend;
      
      //If this object has a customised extend method then use it
      if (!Base._prototyping && typeof this != "function")
      {
        extend = this.extend || extend;
      }
      var proto = {
        toSource: null
      };
      
      //Do the "toString" and other methods manually
      var hidden = ["constructor", "toString", "valueOf"];
      
      //If we are prototyping then include the constructor
      var i = Base._prototyping ? 0 : 1;
      while (key = hidden[i++])
      {
        if (source[key] != proto[key])
          extend.call(this, key, source[key]);
      }
      
      //Copy each of the source object's properties to this object
      for (var key in source)
      {
        if (!proto[key]) 
          extend.call(this, key, source[key]);
      }
    }
    return this;
  }
};

//Initialise
Base = Base.extend(
{
  constructor: function()
  {
    this.extend(arguments[0]);
  }
},
{
  ancestor: Object,
  version: "1.1",

  forEach: function(object, block, context)
  {
    for (var key in object)
    {
      if (this.prototype[key] === undefined)
        block.call(context, object[key], key, object);
    }
  },

  implement: function()
  {
    for (var i = 0; i < arguments.length; i++)
    {
      if (typeof arguments[i] == "function")
      {
        //If it's a function, call it
        arguments[i](this.prototype);
      }
      else
      {
        //Add the interface using the extend method
        this.prototype.extend(arguments[i]);
      }
    }
    return this;
  },

  toString: function()
  {
    return String(this.valueOf());
  }
});
