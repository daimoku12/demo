function vClickAction(NameMapObject, strActionType)
{
  try
  {
    vFocus(NameMapObject);
    NameMapObject.HoverMouse();
    if (NameMapObject.VisibleOnScreen || NameMapObject.Visible)
    {
      if (strActionType == 'Click')
        NameMapObject.Click();
      else if (strActionType == 'DoubleClick')
        NameMapObject.DblClick();
      else if (strActionType == 'RightClick')
        NameMapObject.ClickR();
    }
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClickComboboxItem(control, value)
{
  try
  {
    vFocus(control);
    control.HoverMouse();
    if (control.VisibleOnScreen || control.Visible)
      control.ClickItem(value);
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vFocus(NameMapObject)
{
  try
  {
    NameMapObject.Focus();
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClose(NameMapObject, innerObject)
{
  try
  {
    if (innerObject && innerObject == true)
    {
      if (NameMapObject && eval(NameMapObject.windowObj.Exists))
        NameMapObject.close();
    }
    else
    {
      if (NameMapObject && NameMapObject.Exists)
      {
        NameMapObject.close();
        NameMapObject.Exists = false;
      }
    }
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vFocusClickButton(NameMapObject)
{
  try
  {
    vFocus(NameMapObject);
    NameMapObject.ClickButton();
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClickButton(NameMapObject)
{
  try
  {
    if (NameMapObject.VisibleOnScreen)
      NameMapObject.Click();
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClickCoordinates(control, destX, destY)
{
  try
  {
     control.Click(destX, destY);
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClick(NameMapObject, strActionType)
{
  try
  {
    NameMapObject.HoverMouse();
    if (NameMapObject.VisibleOnScreen || NameMapObject.Visible)
    {
      if (strActionType == 'Click')
        NameMapObject.Click();
      else if (strActionType == 'DoubleClick')
        NameMapObject.DblClick();
      else if (strActionType == 'RightClick')
        NameMapObject.ClickR();
    }
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vCloseWindow(NameMapObject)
{
  try
  {
    if (NameMapObject.Exists)
    {
      NameMapObject.Close();
    }
  }
  catch (e)
  {
    Log.Error(NameMapObject.FullName + ": " + e);
  }
}

function vClearTextBox(NameMapObject)
{
  try
  {
    NameMapObject.Clear();
  }
  catch (e)
  {
    Log.Error(e);
  }
}


function vClearControl(NameMapObject)
{
  try
  {
    vClickAction(NameMapObject, 'Click');
    NameMapObject.Keys("^a[Del]");
    Delay(100);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vEnterAction(NameMapObject, strValue)
{
  try
  {
    NameMapObject.Keys(strValue);
    Delay(1000);
    NameMapObject.Keys("[Enter]");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vDesktopSendKeys(strValue)
{
  try
  {
    Sys.Desktop.Keys(strValue);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vSendKeys(NameMapObject, strValue)
{
  NameMapObject.Keys(strValue);
}

function vWaitProperty(NameMapObject, PropertyName, PropertyValue, iWaitTimeMillieconds)
{
  try
  {
    return NameMapObject.WaitProperty(PropertyName, PropertyValue, iWaitTimeMillieconds) ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vDrag(NameMapObject, intClientX, intClientY, intToX, intToY)
{
  try
  {
    NameMapObject.Drag(intClientX, intClientY, intToX, intToY);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vHoverMouse(NameMapObject, intClientX, intClientY)
{
  try
  {
    NameMapObject.HoverMouse(intClientX, intClientY);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vExpand(NameMapObject)
{
  try
  {
    NameMapObject.Expand();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vCollapse(NameMapObject)
{
  try
  {
    NameMapObject.Collapse();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vPressButton(virtualKeyCode)
{
  try
  {
    Sys.Desktop.KeyDown(virtualKeyCode);
    Sys.Desktop.KeyUp(virtualKeyCode);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vPressSimultKeys(firstKey, secondKey, thirdKey)
{
  try
  {
    if (typeof thirdKey == 'undefined')
    {
      Sys.Desktop.KeyDown(firstKey);
      Sys.Desktop.KeyDown(secondKey);
      Sys.Desktop.KeyUp(secondKey);
      Sys.Desktop.KeyUp(firstKey);
    }
    else
    {
      Sys.Desktop.KeyDown(firstKey);
      Sys.Desktop.KeyDown(secondKey);
      Sys.Desktop.KeyDown(thirdKey);
      Sys.Desktop.KeyUp(thirdKey);
      Sys.Desktop.KeyUp(secondKey);
      Sys.Desktop.KeyUp(firstKey);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vSliderSelect(NameMapObject, strValue)
{
  try
  {
    NameMapObject.set_Value(strValue);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vClickToggleButton(NameMapObject, ObjectState)
{
  try
  {
    //For toggle button the ObjectState can be cbChecked/cbUnchecked/cbGrayed
    NameMapObject.ClickButton(ObjectState);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Focuses on the object, clicks it, clears the existing value, types the new value and presses Enter
function vSetTextBoxValue(NameMapObject, strValue)
{
  try
  {
    vFocus(NameMapObject);
    vClickAction(NameMapObject, 'Click');
    vClearTextBox(NameMapObject);
    Delay(1000);
    vEnterAction(NameMapObject, strValue);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Focuses on the object, clicks it and types the value
function vSetText(NameMapObject, strValue)
{
  try
  {
    vFocus(NameMapObject);
    vClickAction(NameMapObject, 'Click');
    NameMapObject.Keys(strValue);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vCheckCheckBox(NameMapObject, cbOption)
{
  try
  {
    aqConvert.VarToBool(cbOption) ? NameMapObject.ClickButton(cbChecked) : NameMapObject.ClickButton(cbUnChecked);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vSetRate(NameMapObject, strInputType, strDir, strValue)
{
  try
  {
    switch (aqString.ToUpper(strInputType))
    {
      case "VALUE":
        vFocus(NameMapObject);
        NameMapObject.Keys("[Del]");
        NameMapObject.Keys(strValue);
        NameMapObject.Click();
        break;
    
      case "KEYS":
        if (strDir == "UP")
        {
          vFocus(NameMapObject);
          NameMapObject.Click();
          for (var i = 0; i < varToInt(strValue); i++)
            NameMapObject.Keys("[Up]");
        }
        else if (strDir == "DOWN")
        {
          vFocus(NameMapObject);
          NameMapObject.Click();
          for (var i = 0; i < varToInt(strValue); i++)
            NameMapObject.Keys("[Down]");
        }
        break;
    
      case "MOUSE":
        if (strDir == "UP")
        {
          vFocus(NameMapObject);
          NameMapObject.Click();
          Delay(500);
          for (var i = 0; i < varToInt(strValue); i++)
          {
            NameMapObject.MouseWheel(i + 1);
          }
        }
        else if (strDir == "DOWN")
        {
          vFocus(NameMapObject);
          NameMapObject.Click();
          Delay(500);
          for (var i = 0; i < varToInt(strValue); i++)
          {
            NameMapObject.MouseWheel(-i + 1);
          }
        }
        break;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}
