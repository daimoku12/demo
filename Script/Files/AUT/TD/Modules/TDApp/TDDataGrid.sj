//USEUNIT GlobalIncludes
//USEUNIT TD_GlobalVariables

//Get Grid Names 
function getTDGridName(gridFunctionalityDetails)
{
  try
  {
    var gridNames = new Array();
    for (var i = 0; i < gridFunctionalityDetails.length; i++)
    {
      var gridName = gridFunctionalityDetails[i].GridName;
      gridNames.push(gridName);
    }
    return gridNames;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Columns for every grid
function getGridColumns(gridNames)
{
  try
  {
    //var gridColumnDetails = GetDataRowByColumnValue(DWB_TD, "GridColumnsMap", "GridName", gridNames);
    var gridColumnDetails = getDSArrayFromRS(getDataByQuery(DWB_TD, "Select * from [GridColumnsMap$] where GridName = '" + gridNames + "'"));
    if (gridColumnDetails.length == 0)
      Log.Error("Grid Name : " + gridNames + " not found in Test Data sheet!", "getGridColumns");
    else
      return gridColumnDetails[0];
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Mapped column Values, gives the DOMName, UIName and GridPrefName of a Column
function getColumnNameMappedValue(DOMName)
{
  try
  {
    var column = getDSArrayFromRS(getDataByQuery(DWB_TD, "Select * from [ColumnNamesMap$] where DOMName = '" + DOMName + "'"));
    return column[0];
  }
  catch (e)
  {
    Log.Error(e);
  }
}