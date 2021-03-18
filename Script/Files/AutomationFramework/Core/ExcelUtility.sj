//USEUNIT Reporter
//USEUNIT Utility

function vGetCountOfRunningExcelProcesses()
{
  try
  {
    var object;
    var output = 0;
    while(true)
    {
      try
      {
        object = Sys.WaitProcess("EXCEL", 0, output + 1);
      }
      catch (e)
      {
        Log.Error(e);
      }

      if(object && object != null && object.Exists)
      {
        output++;
        continue;
      }
      break;
    }
    vDebug("Found the following count of Excel processes: " + output);
    return output;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vGetExcelProcessByProcessIndex(iIndex)
{
  try
  {
    //using waitprocess as it is safe, i.e. it won't throw an error if no process exists
    var object = Sys.WaitProcess("Excel", 0, iIndex);
    if (object.Exists)
      return object;
    else
    {
      Log.Error("Determined Excel process with index (" + iIndex + ") does not exist!");
      return null;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vCloseADODBConnection(ADODBConnectionObj)
{
  try
  {
    ADODBConnectionObj.close();
    Reporter.vDebug("AdoDBConnection Closed", "ConnectionString: " + ADODBConnectionObj.ConnectionString, 100);
  }
  catch (e)
  {
    Log.Error(e.name + ": " + e.description + ": Error Closing the DB Connection. Connection String: " + ADODBConnectionObj.ConnectionString);
  }
}

function vOpenADODBConnection(strDataSourcePath, strDatabaseExtension)
{
  try
  {
    var Conn, ConnString;
    if (strDatabaseExtension == 'xls')
      ConnString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + strDataSourcePath + ";Extended Properties=\"Excel 8.0;HDR=YES;\"";
    else if (strDatabaseExtension == 'xlsx')
      ConnString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + strDataSourcePath + ";Extended Properties=\"Excel 12.0 Xml;HDR=YES;\"";

    Conn = new ActiveXObject("ADODB.Connection");
    Conn.ConnectionString = ConnString;
    try
    {
      Conn.Open();
      //Reporter.vDebug(ConnString);
      return Conn;
    }
    catch (e)
    {
      Log.Error(e.name + ": " + e.description + ": Error connecting to database. Connection String: " + Conn.ConnectionString);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vGetRecordset(ADODBConnectionObj, strNonUpdateSql)
{
  try
  {
    var RecordsetObj = new ActiveXObject("ADODB.Recordset");
    RecordsetObj.Open(strNonUpdateSql, ADODBConnectionObj);
    //Reporter.vDebug(strNonUpdateSql);
  }
  catch (e)
  {
    Log.Error(e.name + ": " + e.description + ": Error running sql query. Connection String: " + ADODBConnectionObj.ConnectionString + "\n" + "SQL: " + strNonUpdateSql + "\n");
  }
  finally
  {
    //Reporter.vDebug("RecordCount: " + RecordsetObj.RecordCount);
    return RecordsetObj;
  }
}

function vGetRecordCountInRecordset(RecordsetObj)
{
  try
  {
    var RecordsetCount = 0;
    if (!RecordsetObj.BOF)
      RecordsetObj.MoveFirst();    
    
    while (!RecordsetObj.EOF)
    {
      RecordsetCount++;
      RecordsetObj.MoveNext();
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    return RecordsetCount;
  }
}

function vExecuteUpdateQuery(ADODBConnectionObj, strUpdateSql)
{
  try
  {
    ADODBConnectionObj.Execute(strUpdateSql);
    //Reporter.vDebug("Update successful", "Connection String: " + ADODBConnectionObj.ConnectionString + "\n" + "SQL: " + strUpdateSql);
  }
  catch (e)
  {
    Log.Error(e.name + ": " + e.description + ": Error updating back to database. Connection String: " + ADODBConnectionObj.ConnectionString + "\n" + "SQL: " + strUpdateSql);
  }
}

/*******OLD EXCEL UTILITY *************/
//Reads a row, then adds an object to datagrid with properties in the format {columnName : value}
function ProcessDataIntoRows(dataGrid, getInactiveData)
{
  var object = {};
  for (var i = 0; i < DDT.CurrentDriver.ColumnCount; i++)
  {
    var propertyName = aqConvert.VarToStr(DDT.CurrentDriver.ColumnName(i));
    var propertyValue = aqConvert.VarToStr(DDT.CurrentDriver.Value(i));
    object[propertyName] = propertyValue;
  }
  if (aqString.ToLower(getInactiveData) == "y")
    dataGrid.push(object);
  else if (aqString.ToLower(object["Active"]) == "y")
    dataGrid.push(object);
}

//Retrieves data from sheet(sheetName) from workbook(filename)
//getInactiveData parameter accepts y or n indicating if Inactive records are required to be fetched
function GetDataGrid(strFileName, sheetName, getInactiveData)
{
  try
  {
    var Driver;
    var fileNameUrl = getDataRepositoryFolder() + "/" + Runner.CallMethod("HelperModule.getApplicationCode", strFileName) + "/" + strFileName;

    //Creates the driver
    //If you connect to an Excel 2007 sheet, use the following method call:
    //xls file
    if (aqString.SubString(strFileName, (strFileName.length - 3), 3) === "xls")
      Driver = DDT.ExcelDriver(fileNameUrl, sheetName);
    //xlsx file
    else
      Driver = DDT.ExcelDriver(fileNameUrl, sheetName, true);

    var dataGrid = [];

    //Iterates through records
    while (!Driver.EOF())
    {
      ProcessDataIntoRows(dataGrid, getInactiveData);
      Driver.Next(); // Goes to the next record
    }
    //Closing the driver
    DDT.CloseDriver(Driver.Name);
    return dataGrid;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GetDataByRowNum(strFileName, sheetName, rowNum, getRS)
{
  try
  {
    var filenameUrl = getDataRepositoryFolder() + "/" + Runner.CallMethod("HelperModule.getApplicationCode", strFileName) + "/" + strFileName;
    var ExcelCon = ExcelUtility.vOpenADODBConnection(filenameUrl, "xlsx");
    var strSql = "Select * from [" + sheetName + "$] where RowNum = " + rowNum;
    var dataRS = ExcelUtility.vGetRecordset(ExcelCon, strSql);
    if (getRS && getRS != null && getRS == true)
      return dataRS;
    else
      return getDSFromRS(dataRS);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GetDataByColumnName(strFileName, sheetName, colName, rowNum, getRS)
{
  try
  {
    var filenameUrl = getDataRepositoryFolder() + "/" + Runner.CallMethod("HelperModule.getApplicationCode", strFileName) + "/" + strFileName;
    var ExcelCon = ExcelUtility.vOpenADODBConnection(filenameUrl, "xlsx");
    var strSql = "Select " + colName + " from [" + sheetName + "$] where RowNum = " + rowNum;
    var dataRS = ExcelUtility.vGetRecordset(ExcelCon, strSql);
    if (getRS && getRS != null && getRS == true)
      return dataRS;
    else
      return (dataRS.Fields.Item(0).Value);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GetDataRowByColumnValue(strFileName, sheetName, colName, colValue, getRS)
{
  try
  {
    var filenameUrl = getDataRepositoryFolder() + "/" + Runner.CallMethod("HelperModule.getApplicationCode", strFileName) + "/" + strFileName;
    var ExcelCon = ExcelUtility.vOpenADODBConnection(filenameUrl, "xlsx");
    var strSql = "Select * from [" + sheetName + "$] where " + colName + " like '" + colValue + "'";
    var dataRS = ExcelUtility.vGetRecordset(ExcelCon, strSql);
    if (getRS && getRS != null && getRS == true)
      return dataRS;
    else
      return getDSFromRS(dataRS);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getDataByQuery(strFileName, strSql)
{
  try
  {
    var filenameUrl = getDataRepositoryFolder() + "/" + Runner.CallMethod("HelperModule.getApplicationCode", strFileName) + "/" + strFileName;
    var ExcelCon = ExcelUtility.vOpenADODBConnection(filenameUrl, "xlsx");
    var dataRS = ExcelUtility.vGetRecordset(ExcelCon, strSql);
    return dataRS;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//To update the Data sheet
function updateDataSheet(strFileName, strSheetName, strTCID, strField, strValue)
{
  try
  {
    var path = Project.Path;
    var cn = new ActiveXObject("ADODB.Connection");
    var strConn = "DRIVER={Microsoft Excel Driver (*.xls)};Persist Security Info=True;PageTimeout=30;DBQ=" + path + "\\" + strFileName + ";Readonly=False"
    cn.Open(strConn);
    Wrt_str_SQL = "Update [" + strSheetName + "$] SET " + strField + "  = '" + strValue + "' Where Ucase(ToBeExecuted) = 'YES' and TC_ID = '" + strTCID + "'";
    cn.Execute(Wrt_str_SQL);
    cn.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//To Read the Data from Excel using Record - We can apply conditions to the data using SQL statement
function getRecordset(strConnection, strSQL)
{
  try
  {
    var objRsConn = new ActiveXObject("ADODB.Connection");
    objRsConn.Open(strConnection);

    var objRsRec = new ActiveXObject("ADODB.Recordset");
    objRsRec.Open(strSQL, objRsConn);
    if (!objRsRec.bof)
      return objRsRec;

    objRsConn.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Read Integer cell value from excel sheet (sheetIndex, rowNum and cellNum start from 1)
function getExcelIntCell(sheetIndex, rowNum, cellNum, sheetPath)
{
  try
  {
    var Excel = Sys.OleObject("Excel.Application");
    Excel.Workbooks.Open(sheetPath);
    return (VarToInt(Excel.Sheets(sheetIndex).Cells(rowNum, cellNum)));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Read String cell value from excel sheet (sheetIndex, rowNum and cellNum start from 1)
function getExcelStringCell(sheetIndex, rowNum, cellNum, sheetPath)
{
  try
  {
    var Excel = Sys.OleObject("Excel.Application");
    Excel.Workbooks.Open(sheetPath);
    return (VarToString(Excel.Sheets(sheetIndex).Cells(rowNum, cellNum)));
  }
  catch (e)
  {
    Log.Error(e);
  }
}
