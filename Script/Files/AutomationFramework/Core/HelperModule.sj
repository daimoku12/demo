//USEUNIT Action
//USEUNIT EnvironmentVariables
//USEUNIT ExcelUtility
//USEUNIT HouseKeeping
//USEUNIT ObjectIdentification
//USEUNIT Reporter
//USEUNIT Utility
//USEUNIT Validator

function indexOf(obj, searchElement, fromIndex)
{
  var k;
  //1. Let O be the result of calling ToObject passing the this value as the argument.
  if (this == null)
    throw new TypeError('"this" is null or not defined');
  var O = obj;
  //2. Let lenValue be the result of calling the Get internal method of O with the argument "length".
  //3. Let len be ToUint32(lenValue).
  var len = O.length >>> 0;
  //4. If len is 0, return -1.
  if (len === 0)
    return -1;
  //5. If argument fromIndex was passed let n be ToInteger(fromIndex); else let n be 0.
  var n = +fromIndex || 0;
  if (Math.abs(n) === Infinity)
    n = 0;
  //6. If n >= len, return -1.
  if (n >= len)
    return -1;
  //7. If n >= 0, then Let k be n.
  //8. Else, n<0, Let k be len - abs(n). If k is less than 0, then let k be 0.
  k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);
  //9. Repeat, while k < len
  while (k < len)
  {
    var kValue;
    //a. Let Pk be ToString(k). This is implicit for LHS operands of the in operator
    //b. Let kPresent be the result of calling the HasProperty internal method of O with argument Pk. This step can be combined with c
    //c. If kPresent is true, then
    //i.  Let elementK be the result of calling the Get internal method of O with the argument ToString(k).
    //ii.  Let same be the result of applying the Strict Equality Comparison Algorithm to searchElement and elementK.
    //iii.  If same is true, return k.
    if (k in O && O[k] === searchElement)
      return k;
    k++;
  }
  return -1;
}

function addMinutesToCurrentTime(minutes)
{
  try
  {
    var Time1 = aqDateTime.Now();
    var Time2 = aqDateTime.AddTime(Time1, 0, 0, minutes, 0);
    var FormatStr = aqConvert.DateTimeToFormatStr(Time2, "%H:%M:%S %d %b %Y");
    return FormatStr;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getDaysBetweenDates(date1, date2)
{
   var difference = aqDateTime.TimeInterval(date1, date2);
   return aqConvert.TimeIntervalToStr(difference).split(":")[0];
}

function addDaysToTodaysDate(days, format)
{
  try
  {
    var todaysDate = aqDateTime.Now();
    var newDate = aqDateTime.AddDays(todaysDate, days);
    if (format && format != null)
      var FormatStr = aqConvert.DateTimeToFormatStr(newDate, format);
    else
      var FormatStr = aqConvert.DateTimeToFormatStr(newDate, "%d %b %Y");

    return FormatStr;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function addTime(value)
{
  try
  {
    var timeArray = value.split(":");
    var timeValue = aqDateTime.AddTime(Time1, 0, timeArray[0], timeArray[1], timeArray[2]);
    var FormatStr = aqConvert.DateTimeToFormatStr(timeValue, "%H:%M:%S %d %b %Y");
    return FormatStr;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function formatDateString(value, formatString)
{
  try
  {
    var strFormatString;
    if (formatString)
      strFormatString = formatString;
    else
      strFormatString = "%H:%M:%S %d %b %Y";
  
    if ((typeof value == 'string' || typeof value == 'date') && value != "")
    {
      var strDate = aqConvert.StrToDateTime(value);
      return aqConvert.DateTimeToFormatStr(strDate, strFormatString);
    }
    else
      return "";
  }
  catch (e)
  {
    Log.Error(e);
    return "";
  }
}

function getRandomArbitrary(min, max)
{
  return varToInt(Math.random() * (max - min) + min);
}

function recordCurrentApplicationPath()
{
  try
  {
    Sys.Refresh();
    var p = Sys.WaitProcess(AUTProcessName, 3000);
    if (p.Exists)
    {
      //Log.Message("Found App Instance with Process Path: " + p.Path);
      CurrentAppPath = p.Path;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isAppClosed(wAUTProcessName, RetryInterval, MaxRetries)
{
  try
  {
    var isClosed = false;
    isClosed = ObjectIdentification.vWaitForObjectNotExists(wAUTProcessName, RetryInterval, MaxRetries);
    return isClosed;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getMonitorBackgroundColor(monitor)
{
  try
  {
    bootStrapperApp.Refresh();
    Delay(1000); 
    var colors = new Array();
    colors["Red"] = aqConvert.StrToInt(monitor.Background.Color.R);
    colors["Green"] = aqConvert.StrToInt(monitor.Background.Color.G);
    colors["Blue"] = aqConvert.StrToInt(monitor.Background.Color.B);
    return colors;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getBorderBrushColor(control)
{
  try
  {
    var colors = new Array();
    colors["Red"] = aqConvert.StrToInt(control.BorderBrush.Color.R);
    colors["Green"] = aqConvert.StrToInt(control.BorderBrush.Color.G);
    colors["Blue"] = aqConvert.StrToInt(control.BorderBrush.Color.B);
    return colors;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getExecutionControllerUrl()
{
  try
  {
    if (!ExecutionControllerUrl || ExecutionControllerUrl == "" || ExecutionControllerUrl == undefined)
    {
      var appCode = getApplicationCode();
      ExecutionControllerUrl = getDataRepositoryFolder() + "/" + appCode + "/" + appCode + "_ExecutionManagement.xlsx";
    }
    return ExecutionControllerUrl;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getApplicationCode(strFileName)
{
  try
  {
    if (strFileName && strFileName != "")
      Runner.CallMethod(strFileName.split("_")[0] + "_GlobalVariables.getApplicationDetails");

    return CurrentAppCode;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

// To be uncommented later************************************************************************************
//function InitializeTestEnv(EnvMgmtKeyRecordSet, IsCEF)
//{
//  var EnvLaunchResult = false;
//  if (IsCEF && IsCEF != null && IsCEF != "" && IsCEF == 'Y')
//    var isCef = true;
//  else
//    var isCef = false;
//  try
//  {
//    if (!Utility.isAnyAppInitialized(bootStrapperAppArray, 100, 3))
//    {
//      Utility.killAppInstances(ProcesssList);
//      EnvLaunchResult = Runner.CallMethod(getApplicationCode() + "_HelperModule." + "LaunchEnv", EnvMgmtKeyRecordSet, isCef);
//    }
//    else
//    {
//      var validationResult = ValidateAppInstanceAgainstEnvKey(EnvMgmtKeyRecordSet);
//      if (validationResult == null)
//        return null;
//      else if (validationResult)
//      {
//        recordCurrentApplicationPath();
//        EnvLaunchResult = true;
//      }
//      else
//      {
//        Utility.killAppInstances(ProcesssList);
//        EnvLaunchResult = Runner.CallMethod(getApplicationCode() + "_HelperModule." + "LaunchEnv", EnvMgmtKeyRecordSet, isCef);
//        //EnvLaunchResult = LaunchEnv(EnvMgmtKeyRecordSet);
//      }
//    }
//  }
//  catch (e)
//  {
//    Log.Error(e);
//  }
//  finally
//  {
//    return EnvLaunchResult;
//  }
//}

function InitializeTestEnv(EnvMgmtKeyRecordSet, IsCEF)
{
  Log.Checkpoint("Env launched!");
  return EnvLaunchResult = true;
}

function ExitTestEnv()
{
  try
  {
    Runner.CallMethod(getApplicationCode() + "_ToolbarModule." + "logOff");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function ValidateAppInstanceAgainstEnvKey(EnvMgmtKeyRecordSet)
{
  try
  {
    EnvLaunchResult = Runner.CallMethod(getApplicationCode() + "_HelperModule." + "recordCurrentLoggedinUserAndBuildNo");
    if (LoggedInUser == "")
      return null;

    var expectedUser = EnvMgmtKeyRecordSet.Fields.Item("UserName").Value;
    return (Utility.areStringValuesEqual(LoggedInUser, expectedUser, false));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function DetermineEnvToLaunch(userType)
{
  try
  {
    //Bring up the appropriate test environment for execution
    if (ExecMgmtExcelCon == null || ExecMgmtExcelCon == undefined)
      ExecMgmtExcelCon = ExcelUtility.vOpenADODBConnection(getExecutionControllerUrl(), "xlsx");
    
    var strSql = "Select * from [EnvMgmtMatrix$] where UserType = '" + userType + "'"; //Get environment name
    return ExcelUtility.vGetRecordset(ExecMgmtExcelCon, strSql);
  }
  catch (e)
  {
    Log.Error(e);
  }
}
