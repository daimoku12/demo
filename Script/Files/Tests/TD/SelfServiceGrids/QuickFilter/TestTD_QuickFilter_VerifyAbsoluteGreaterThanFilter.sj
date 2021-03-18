//USEUNIT GlobalIncludes
//USEUNIT DataDriven
//USEUNIT TDIncludes

function testTD_QuickFilter_VerifyAbsoluteGreaterThanFilter()
//function testTD_QuickFilter_VerifyAbsoluteGreaterThanFilter(TestCaseRS, TestCaseName, IsDataDriven)
{
  try
  {
    var TCReport = new Reporter.TCReport;
    TD_GlobalVariables.getApplicationDetails();
    var functionality = "QuickFilter";

    if (DEBUG_DATA_DRIVEN)
    {
      var TestCaseName = "testTD_QuickFilter_VerifyAbsoluteGreaterThanFilter";
      var TestCaseRS = null;
    }

    //Gets GridFunctionality data grid
    var gridFunctionalityDetails = GetDataGrid(DWB_TD, functionality + "_Grid");
    if (!Reporter.TC_RESULT)
      return;

    //Gets the GridNames Mapped to Functionality 
    var gridNames = getTDGridName(gridFunctionalityDetails);
    if (!Reporter.TC_RESULT)
      return;

    //IRS_Spread Increment Adjustment Grid  
    vMessage("Grid Count: " + gridNames.length);
    for (var i = 0; i < gridNames.length; i++)
    {
      var TCName = TestCaseName + "_" + gridNames[i];
      try
      {
        DataDrivenSetup(TestCaseRS, TCName);
        var TCResult = new Reporter.TCReport;
        try
        {
          var gridObject = launchGrid(gridNames[i]);
          if (!Reporter.TC_RESULT)
            continue;

          //Gets all Columns for the GridName
          var row = getGridColumns(gridNames[i]);
          if (!Reporter.TC_RESULT)
            continue;
           
          var mappedColumnNames = getColumnNameMappedValue(row.Column4);
          if (!Reporter.TC_RESULT)
            continue;  
            
          //row.Column4 - SMS2_USDIRS_SwapSpreadIncrement_SmallSpreadIncrement 
          var before = gridObject.getCEFColumnValues(gridObject.xDg, row.Column4);
          if (!Reporter.TC_RESULT)
            continue;
  
          var cellValue = gridObject.getCEFCellValue(gridObject.xDg, 0, row.Column4);  
          if (!Reporter.TC_RESULT)
            continue;
           
          //row.Column3 - SMS2_USDIRS_SwapSpreadIncrement_Currency     
          gridObject.openQuickFilter(gridObject.xDg, row.Column3, gridObject.windowObj);
          if (!Reporter.TC_RESULT)
            continue;
               
          gridObject.setQuickFilterValueForFilterConditions(gridObject.xDg, row.Column4, "abs >"+cellValue+"", mappedColumnNames.UIName);
          if (!Reporter.TC_RESULT)
            continue;
  
          var expectedValues = arrayOfElementForACondition(before, "GreaterThanAbsoluteValue", cellValue);
          if (!Reporter.TC_RESULT)
            continue;
            
          var actualValues = gridObject.getCEFColumnValues(gridObject.xDg, row.Column4);
          if (!Reporter.TC_RESULT)
            continue;
  
          if (compareValuesInArray(expectedValues.sort(), actualValues.sort()))
            vCheckpoint("Correct values are getting displayed after abs > filter is applied!");
          else
            Log.Error("Incorrect values are getting displayed after abs > filter is applied!");           
        }
        catch (e)
        {
          Log.Error(e);
        }
        finally
        {
          vClose(gridObject);
          TCResult.result = Reporter.TC_RESULT;
          TCResult.remarks = Reporter.TC_REMARKS;
          FinalizeDataDrivenSetup(TCResult, TestCaseName);
        }
      }
      catch (e)
      {
        Log.Error(e);
      }
    }
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
