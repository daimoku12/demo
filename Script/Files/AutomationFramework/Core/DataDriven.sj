//USEUNIT DriverMain

var DEBUG_DATA_DRIVEN = true;

function DataDrivenSetup(TestCaseRS, TestCaseName)
{
  try
  {
    Reporter.CONCAT_TC_REMARKS = false;
    Reporter.TC_RESULT = true;
    Reporter.TC_REMARKS = "TestCase Passed!";

    try
    {
      Log.AppendFolder(TestCaseName);
      //Runner.CallMethod(getApplicationCode() + "_HelperModule." + "closeAllWindows");
      vFocus(appToolbar);
    }
    catch (e)
    {
      Log.Error(e);
    }

    if (DEBUG_DATA_DRIVEN == false)
      SetupTCJournalDataDriven(TestCaseRS, TestCaseName);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function FinalizeDataDrivenSetup(TCResult, TestCaseName)
{
  try
  {
    if (TCResult)
    {
      TCResult.remarks = trimRemarks(TCResult.remarks);
      TCResult.remarks = aqString.Replace(TCResult.remarks, "TestCase Passed!, ", "");
      TCResult.remarks = aqString.Replace(TCResult.remarks, "'", "");
      TCResult.remarks = aqString.Replace(TCResult.remarks, "\"", "");
      Log.Message(TCResult.result + " : " + TCResult.remarks);
      if (!TCResult.result)
      {
        TS_RESULT = TCResult.result;
        if(FailedTestCases == "")
          FailedTestCases = TestCaseName;
        else
          FailedTestCases = FailedTestCases + ", " + TestCaseName;
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    if (DEBUG_DATA_DRIVEN == false)
      CloseTCJournal(TCResult);

    try
    {
      Log.PopLogFolder();
    }
    catch (e)
    {
      Log.Error(e);
    }
  } 
}
