//USEUNIT Action
//USEUNIT Reporter

function vFindChildObject(NameMapAlias, strPropertyName, strPropertyValue, iLevelsDeep)
{
  try
  {
    if (vElementExists(NameMapAlias))
    {
      if (!iLevelsDeep || iLevelsDeep <= 0 || iLevelsDeep > 20)
      {
        iLevelsDeep = 20;
      }

      return NameMapAlias.FindChild(strPropertyName, strPropertyValue, iLevelsDeep);
    }
    else
    {
      Reporter.vWarning("Parent object does not exist to get the child object!");
      return null;
    }
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vFindAllChildrenObjects(NameMapAlias, arrPropertyName, arrPropertyValue, iLevelsDeep)
{
  try
  {
    if (vElementExists(NameMapAlias))
    {
      if (!iLevelsDeep || (iLevelsDeep <= 0 || iLevelsDeep > 20))
      {
        iLevelsDeep = 20;
      }

      var children = NameMapAlias.FindAllChildren(arrPropertyName, arrPropertyValue, iLevelsDeep);
      return (new VBArray(children)).toArray();
    }
    else
    {
      Reporter.vWarning("Parent object does not exist to get the child objects!");
      return null;
    }
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vFilterObjects(arrNameMapAlias, strPropertyNameToCheck, strExpectedPropertyValue)
{
  try
  {
    var arrOutput = [];
    for (var i = 0; i < arrNameMapAlias.length; i++)
    {
      if (Getter.vGetPropertyVal(arrNameMapAlias[i], strPropertyNameToCheck) == strExpectedPropertyValue)
      {
        arrOutput.push(arrNameMapAlias[i]);
      }
    }
    return arrOutput;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vGetWindowCount(NameMapAlias, strWindowType)
{
  try
  {
    var arrWindowObjects = vGetWindowObjects(NameMapAlias, strWindowType);
    if (arrWindowObjects.length)
      return arrWindowObjects.length;

    return 0;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vGetWindowObjects(NameMapAlias, strWindowType)
{
  try
  {
    var oFoundWindows;
    var arrFoundWindows = [];
    try
    {
      switch (aqString.ToUpper(strWindowType))
      {
        case "ORDER":
          oFoundWindows = NameMapAlias.FindAllChildren("Name", 'WPFObject("HwndSource: OrderFormWindow", "*")', 5);
          break;

        case "BLOTTER":
          oFoundWindows = NameMapAlias.FindAllChildren("Name", 'WPFObject("HwndSource: NewsArticleWindow", "News Article", *)', 5);
          break;
      }

      if (oFoundWindows != null)
        arrFoundWindows = (new VBArray(oFoundWindows)).toArray();
    }
    catch (e)
    {
      vDebug("The following error was caught in vGetWindowCount: " + e + ". Window count was attempted for: " + strWindowType, "", 100);
    }

    return arrFoundWindows;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vAfterWaitDoesPropertyMatchExpected(NameMapAlias, strPropertyName, strPropertyExpectedValue, iRecheckFrequencyMilliseconds, iMaxRetries)
{
  try
  {
    var propertyValue;
    var bPropertyMatchedExpected = false;
    if (iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    if (iMaxRetries <= 0)
    {
      iMaxRetries = 5;
    }

    for (var i = 0; i < iMaxRetries; i++)
    {
      try
      {
        propertyValue = aqObject.GetPropertyValue(NameMapAlias, strPropertyName);
      }
      catch (e)
      {
        if ((vElementExists(NameMapAlias) == false))
          Log.Error(e.name + ": " + e.description + ": " + NameMapAlias.ClrFullClassName + " object not found!", arguments.callee);
        else
          Log.Error(e, arguments.callee);
        break;
      }

      if (propertyValue == strPropertyExpectedValue)
      {
        Reporter.vDebug("Property matched: " + NameMapAlias + " Retry #:" + i);
        bPropertyMatchedExpected = true;
        break;
      }

      Delay(iRecheckFrequencyMilliseconds);
    }

    if (!bPropertyMatchedExpected)
    {
      Reporter.vDebug("Property did not match after maximum number of retries: " + NameMapAlias + " Retry #:" + iMaxRetries);
    }

    return bPropertyMatchedExpected;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForChildExists(NameMapAlias, strPropertyName, strPropertyValue, iLevelsDeep, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    for (var i = 0; i < MaxRetries; i++)
    {
      vDebug("Checking if child exists");

      var result = vFindChildObject(NameMapAlias, strPropertyName, strPropertyValue, iLevelsDeep);
      if (result.Exists)
      {
        vDebug("Child exists!");
        return true;
      }

      //needed in TC12, whereas in TC11 we didn't
      //actually ever code, or apparently need the delay
      Delay(iRecheckFrequencyMilliseconds);
    }

    vDebug("Child does not exist!");
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForObjectExists(NameMapAlias, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    for (var i = 0; i < MaxRetries; i++)
    {
      if (vElementExists(NameMapAlias) == true)
      {
        Reporter.vDebug("Object Appeared: " + NameMapAlias + "Retry #:" + i);
        return true;
      }

      Delay(iRecheckFrequencyMilliseconds);
    }
    Reporter.vDebug("Object did not appear until MaxRetries: " + NameMapAlias + "Retry #:" + MaxRetries);
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForObjectNotExists(NameMapAlias, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    for (var i = 0; i < MaxRetries; i++)
    {
      if (!NameMapAlias.Exists)
      {
        Reporter.vDebug("Object Disappeared: " + NameMapAlias + "Retry #:" + i);
        return true;
      }

      Delay(iRecheckFrequencyMilliseconds);
    }
    Reporter.vDebug("Object appears until MaxRetries: " + NameMapAlias + "Retry #:" + MaxRetries);
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForObjectNotVisible(NameMapAlias, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    for (var i = 0; i < MaxRetries; i++)
    {
      if (vWaitProperty(NameMapAlias, "VisibleOnScreen", false, iRecheckFrequencyMilliseconds))
      {
        Reporter.vDebug("Object not visible: " + NameMapAlias + "Retry #:" + i);
        return true;
      }

      Delay(iRecheckFrequencyMilliseconds);
    }
    Reporter.vDebug("Object visible until MaxRetries: " + NameMapAlias + "Retry #:" + MaxRetries);
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForObjectVisible(NameMapAlias, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
    {
      iRecheckFrequencyMilliseconds = 500;
    }

    for (var i = 0; i < MaxRetries; i++)
    {
      if (vWaitProperty(NameMapAlias, "VisibleOnScreen", true, iRecheckFrequencyMilliseconds))
      {
        Reporter.vDebug("Object visible: " + NameMapAlias + "Retry #:" + i);
        return true;
      }

      Delay(iRecheckFrequencyMilliseconds);
    }
    Reporter.vDebug("Object not visible until MaxRetries: " + NameMapAlias + "Retry #:" + MaxRetries);
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vWaitForObjectEnabled(NameMapAlias, iRecheckFrequencyMilliseconds, MaxRetries)
{
  try
  {
    if (!iRecheckFrequencyMilliseconds || iRecheckFrequencyMilliseconds <= 0 || iRecheckFrequencyMilliseconds > 60000)
      iRecheckFrequencyMilliseconds = 500;

    for (var i = 0; i < MaxRetries; i++)
    {
      NameMapObject.refresh();
	  if (aqObject.IsSupported(NameMapObject, "Enabled"))
	  {
	    if (NameObject.Enabled == true)
        {
          Reporter.vDebug("Object visible: " + NameMapAlias + "Retry #:" + i)
          return true;
        }
	  }	
      Delay(iRecheckFrequencyMilliseconds);
    }
    Reporter.vDebug("Object not enabled until MaxRetries: " + NameMapAlias + "Retry #:" + MaxRetries);
    return false;
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vIsObjectNull(oInput)
{
  try
  {
    return (oInput == null);
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vElementExists(NameMapAlias)
{
  try
  {
    if (NameMapAlias.Exists)
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e.name + ": " + e.description + ": " + NameMapAlias + " object not found!", arguments.callee);
    return false;
  }
}

function vElementNotExists(NameMapAlias)
{
  try
  {
    if (NameMapAlias.Exists == false)
    {
      Reporter.vCheckpoint("Check Element Not Exists: PASS", "ClassName: " + NameMapAlias.Name + ": Object Not found!", 100);
      return true;
    }
    else
    {
      Log.Error("Check Element Not Exists: Fail", "ClassName: " + NameMapAlias.Name + ": Object found!", arguments.callee);
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}

function vChildCount(NameMapAlias)
{
  try
  {
    if (NameMapAlias.Exists == true)
      return NameMapAlias.ChildCount;
    else
    {
      return -1;
      Reporter.vCheckpoint("GetChildCount Failed - object not found", NameMapAlias.ClrFullClassName + " object not found! Unable to fetch Childcount!", 500);
    }
  }
  catch (e)
  {
    Log.Error(e, arguments.callee);
  }
}
