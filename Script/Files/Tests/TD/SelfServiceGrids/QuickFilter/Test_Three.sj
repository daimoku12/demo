//USEUNIT GlobalIncludes
//USEUNIT DataDriven
//USEUNIT TDIncludes

function test_Three()
{
  var TCReport = new Reporter.TCReport;
  try
  {
    Log.Checkpoint("test three !");
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    TCReport.result = Reporter.TC_RESULT;
    TCReport.remarks = Reporter.TC_REMARKS;
    return TCReport;
  }
}
