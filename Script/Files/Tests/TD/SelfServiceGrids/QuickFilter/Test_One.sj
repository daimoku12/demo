//USEUNIT GlobalIncludes
//USEUNIT DataDriven
//USEUNIT TDIncludes

function test_One()
{
  var TCReport = new Reporter.TCReport;
  try
  {
    Log.Checkpoint("test one !");
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
