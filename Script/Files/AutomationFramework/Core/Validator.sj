//USEUNIT Reporter


function vValidatePropertyVal(NameMapAlias, strProperty, strExpectedValue)
{
  try
  {
    var tempValue = Getter.vGetPropertyVal(NameMapAlias, strProperty);
    if (aqString.Trim(strExpectedValue) == aqString.Trim(tempValue))
    {
      vCheckpoint("Expected Value (" + strExpectedValue + ") is equal to Actual Value (" + tempValue + ")!");
      return true;
    }
    else
    {
      Log.Error("Expected Value (" + strExpectedValue + ") is not equal to Actual Value (" + tempValue + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CheckValueNotBlank(Element)
{
  try
  {
    if (Element != null)
    {
      vCheckpoint("Validate Property: True, Expected Value:" + Element + " Value not Null!");
      return true;
    }
    else
    {
      Log.Error("Validate Property: False, Expected Value:" + Element + " Value Null");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CheckValueIsBlank(Element)
{
  try
  {
    if ((Element == null) || (aqString.Trim(Element.Text.OleValue) == ""))
    {
      vCheckpoint("Validate Property: True, Expected Value:" + Element.Text + " Value Is Null!");
      return true;
    }
    else
    {
      Log.Error("Validate Property: False, Expected Value:" + Element.Text + " Value Not Null!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CompareValues(Value1, Value2)
{
  try
  {
    if (Value1 == Value2)
    {
      vCheckpoint("Value 1 (" + Value1 + ") is equal to Value 2 (" + Value2 + ")!");
      return true;
    }
    else
    {
      Log.Error("Value 1 (" + Value1 + ") is not equal to Value 2 (" + Value2 + "!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CompareValuesNotEqual(Value1, Value2)
{
  try
  {
    if (Value1.OleValue != Value2.OleValue)
    {
      Log.Error("Value 1 (" + Value1 + ") is not equal to Value 2 (" + Value2 + ")!");
      return true;
    }
    else
    {
      vCheckpoint("Value 1 (" + Value1 + ") is equal to Value 2 (" + Value2 + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CompareStringValues(valActual, valExpected, description)
{
  try
  {
    if (valActual == undefined || valActual == null)
      valActual = "";

    if (valExpected == undefined || valExpected == null)
      valExpected = "";

    if (!description)
      description = ""; 
    else
      description = "Field: " + description + " - ";
  
    valActual = aqString.Trim(VarToStr(valActual));
    valExpected = aqString.Trim(VarToStr(valExpected));
  
    if (aqString.ToUpper(valActual) == aqString.ToUpper(valExpected))
    {
      if (aqString.Trim(VarToStr(valActual)) == "")
        vCheckpoint(description + "Both the values are empty / null!");
      else
        vCheckpoint(description + "Actuual Value (" + valActual + ") is equal to Expected value (" + valExpected + ")!");
      return true;
    }
    else
    {
      Log.Error(description + "Actuual Value (" + valActual + ") is not equal to Expected value (" + valExpected + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CompareStringValuesCaseSpecific(Value1, Value2, CaseSensitive)
{
  try
  {
    var result = aqString.Compare(Value1, Value2, CaseSensitive); //CaseSensitive = true or false
    if (result == 0)
    {
      vCheckpoint("Value 1 (" + Value1 + ") is equal to Value 2 (" + Value2 + ")!");
      return true;
    }
    else
    {
      Log.Error("Value 1 (" + Value1 + ") is not equal to Value 2 (" + Value2 + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CompareStringValuesRemoveSpaceCaseSpecific(Value1, Value2, CaseSensitive)
{
  try
  {
    Value1 = aqString.Replace(Value1, " ", "");
    Value2 = aqString.Replace(Value2, " ", "");
    var result = aqString.Compare(Value1, Value2, CaseSensitive); //CaseSensitive = true or false
    if (result == 0)
    {
      vCheckpoint("Value 1 (" + Value1 + ") is equal to Value 2 (" + Value2 + ")!");
      return true;
    }
    else
    {
      Log.Error("Value 1 (" + Value1 + ") is not equal to Value 2 (" + Value2 + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vValidatePropertyValWithName(NameMapAlias, strProperty, strExpectedValue, propertyName)
{
  try
  {
    var tempValue = Getter.vGetPropertyVal(NameMapAlias, strProperty);
    if (aqString.Trim(strExpectedValue) == aqString.Trim(tempValue))
    {
      vCheckpoint(propertyName + " - Expected Value (" + strExpectedValue + ") is equal to Actual Value (" + tempValue + ")!");
      return true;
    }
    else
    {
      Log.Error(propertyName + " - Expected Value (" + strExpectedValue + ") is not equal to Actual Value (" + tempValue + ")!");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function IsEnabled(NameMapAlias)
{
  try
  {
    if (aqObject.IsSupported(NameMapAlias, "IsEnabled"))
      return NameMapAlias.IsEnabled;
    else if (aqObject.IsSupported(NameMapAlias, "Enabled"))
      return NameMapAlias.Enabled;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function IsFocused(NameMapAlias)
{
  try
  {
    return NameMapAlias.IsFocused;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function IsVisibleOnScreen(NameMapAlias)
{
  try
  {
    return NameMapAlias.VisibleOnScreen;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function IsVisible(NameMapAlias)
{
  try
  {
    return NameMapAlias.IsVisible;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function IsChecked(NameMapAlias)
{
  try
  {
    if (typeof NameMapAlias.IsChecked == 'boolean')
      return NameMapAlias.IsChecked;
    else
      return NameMapAlias.IsChecked.OleValue;
  }
  catch (e)
  {
    Log.Error(e);
  }
}