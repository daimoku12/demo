//USEUNIT EnvironmentVariables

var TestCaseResult = new Enumerator();
TestCaseResult.PASSED = "Passed";
TestCaseResult.FAILED = "Failed";
TestCaseResult.SKIPPED = "Skipped";

var TC_RESULT = true;
var TC_REMARKS = "TestCase Passed!";

var TEST_ENV_FAILED_MSG = "Test Environment could not be initialized!";
var TS_RESULT = true;
var TS_REMARKS = "TestSuite Passed!";

var CONCAT_TC_REMARKS = false;

function TCReport(result, remarks)
{
  this.result = result;
  this.remarks = remarks;
}

function vDebug(strMessage, strAdditionalMessage, intPriority)
{
  try
  {
    if (LoggingLevel == 'DEBUG') // LoggingLevel is environment variable
      Log.Message(strMessage, strAdditionalMessage, intPriority);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vMessage(strMessage, strAdditionalMessage, intPriority)
{
  if ((LoggingLevel == 'DEBUG')||(LoggingLevel == 'INFO')) // LoggingLevel is environment variable
  {
    Log.Message(strMessage, strAdditionalMessage, intPriority);
  }
}

function vWarning(strMessage, strAdditionalMessage, intPriority)
{
  if ((LoggingLevel == 'DEBUG')||(LoggingLevel == 'INFO')) // LoggingLevel is environment variable
  {
    Log.Warning(strMessage, strAdditionalMessage, intPriority);
  }
}

function vCheckpoint(strMessage)
{ 
  Log.Checkpoint(strMessage, strMessage, pmNormal, Log.CreateNewAttributes(), Sys.Desktop.Picture());
}

function vThrow(strMessage)
{
  try
  {
    //throw new Error(0, strMessage);
    //throw new Error(strMessage);
    throw (strMessage);
  }
  catch (e)
  {
    //Log.Error(e);
    throw e;
    //throw new Error(0, strMessage);
  }
}

function vThrows(e, funcName)
{
/*  try
  {*/
    //throw new Error(0, strMessage);
    //throw new Error(strMessage);
    Log.Error(e, funcName);
    throw (e);
/*  }
  catch (e)
  {
    //Log.Error(e);
    throw e;
    //throw new Error(0, strMessage);
  }*/
}

function reportErrorMsg(e, args)
{
  try
  {
    var msg = e;
    /*var msg = "Error! " + e;
    if (args)
    {
      if (args.indexOf("(") > -1 && args.indexOf(")") > -1)
      {
        var errorneousFunctionName = args.toString();
        if (errorneousFunctionName != "")
        {
          if (aqString.Find(errorneousFunctionName, "function", 0, false) >= 0)
          {
            errorneousFunctionName = errorneousFunctionName.match(/function (\w*)/)[1];
            msg = "Error in " + errorneousFunctionName + "() function! " + e;
          }
        }
      }
      else
        msg = "Error in " + args + "() function! " + e;
    }*/
    return msg;
  }
  catch (e)
  {
    //Log.Error(e);
    Log.Error(e);
    return msg;
  }
}

function reportWarningMsg(e, args)
{
  try
  {
    var msg = e;
    /*var msg = "Warning! " + e;
    if (args)
    {
      if (args.indexOf("(") > -1 && args.indexOf(")") > -1)
      {
        var errorneousFunctionName = args.toString();
        if (errorneousFunctionName != "")
        {
          if (aqString.Find(errorneousFunctionName, "function", 0, false) >= 0)
          {
            errorneousFunctionName = errorneousFunctionName.match(/function (\w*)/)[1];
            msg = "Warning in " + errorneousFunctionName + "() function! " + e;
          }
        }
      }
      else
        msg = "Warning in " + args + "() function! " + e;
    }*/
    return msg;
  }
  catch (e)
  {
    return msg;
  }
}

function getObjectMethods(obj)
{
  try
  {
    var ret = [];
    for (var prop in obj)
    {
      if (!(obj[prop] && (prop == "base" || prop == "extend")))
        return prop;
    }
    return "";
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GeneralEvents_OnLogError(Sender, LogParams)
{
  try
  {
    var msg = reportErrorMsg(LogParams.MessageText, LogParams.AdditionalText);
    LogParams.MessageText = msg;
    LogParams.Locked = false;

    Reporter.TC_RESULT = false;

    if (Reporter.CONCAT_TC_REMARKS)
      Reporter.TC_REMARKS = Reporter.TC_REMARKS + ", " + msg;
    else
      Reporter.TC_REMARKS = msg;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GeneralEvents_OnLogWarning(Sender, LogParams)
{
  try
  {
    var msg = reportWarningMsg(LogParams.MessageText, LogParams.AdditionalText);
    LogParams.MessageText = msg;
    LogParams.Locked = false;

    Reporter.TC_RESULT = true;
    if (Reporter.CONCAT_TC_REMARKS)
      Reporter.TC_REMARKS = Reporter.TC_REMARKS + ", " + msg;
    else
      Reporter.TC_REMARKS = msg;
  }
  catch (e)
  {
    Log.Error(e);
  }
}
