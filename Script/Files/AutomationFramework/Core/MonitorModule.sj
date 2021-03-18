//USEUNIT GlobalIncludes
//USEUNIT base

//Inherits from the base class (of the base.js framework)
var Monitor = Base.extend(
{
  constructor: function()
  {
    try
    {
      this.base();
    }
    catch (e)
    {
      Log.Error(e);
    }
  }
});

Monitor.prototype.goToTestLocation = function(_argToX, _argToY, ToX, ToY)
{
  try
  {
    var _ToX = (_argToX - this.pathCtrl.ScreenLeft);
    var _ToY = (_argToY - this.pathCtrl.ScreenTop);
    this.dragToTestLocation(this.pathCtrl, _ToX, _ToY, ToX, ToY);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Closes the monitor
Monitor.prototype.close = function()
{
  try
  {
    if (this.btnClose.Exists)
      vClickAction(this.btnClose, 'Click');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.getCoordinates = function()
{
  return {
    x: this.monitorWindow.ScreenLeft,
    y: this.monitorWindow.ScreenTop
  };
}

//This function resizes the particular blotter monitor
Monitor.prototype.resize = function(x, y)
{
  try
  {
    //Delay(1000);
    if (!this.resizeGrip.Exists)
    {
      Log.Error("Resize Grip Handle not found!");
      return;
    }
    vClickAction(this.resizeGrip, 'Click');
    Delay(1000);
    var sDelay = 500;
    var destX = this.resizeGrip.ScreenLeft + this.resizeGrip.Width / 2 + x;
    var destY = this.resizeGrip.ScreenTop + this.resizeGrip.Height / 2 + y;

    LLPlayer.MouseMove(destX, destY, sDelay);
    //Delay(200);
    LLPlayer.MouseUp(MK_LBUTTON, destX, destY, sDelay);
    //Delay(200);
    LLPlayer.MouseDown(MK_LBUTTON, destX, destY, sDelay);
    //Delay(200);
    LLPlayer.MouseUp(MK_LBUTTON, destX, destY, sDelay);
    //Delay(200);
    //this.monitorWindow.Refresh();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//edge: left, right, top, bottom
//window: window object
Monitor.prototype.dockTo = function(window, edge)
{
  try
  {
    var coordinates = this.getCoordinates();
    var dockToCoordinates = window.getCoordinates();
    switch (edge)
    {
      case "left":
        this.monitorWindow.Drag(6, 7, dockToCoordinates.x - coordinates.x - this.monitorWindow.Width, dockToCoordinates.y - coordinates.y);
        break;
      case "right":
        this.monitorWindow.Drag(6, 7, dockToCoordinates.x - coordinates.x + window.monitorWindow.Width, dockToCoordinates.y - coordinates.y);
        break;
      case "top":
        this.monitorWindow.Drag(6, 7, dockToCoordinates.x - coordinates.x, dockToCoordinates.y - coordinates.y - this.monitorWindow.Height);
        break;
      case "bottom":
        this.monitorWindow.Drag(6, 7, dockToCoordinates.x - coordinates.x, dockToCoordinates.y - coordinates.y + window.monitorWindow.Height);
        break;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.tabTo = function(window)
{
  try
  {
    var coordinates = this.getCoordinates();
    var tabToCoordinates = window.getCoordinates();
    vFocus(this.monitorWindow);
    this.monitorWindow.Drag(6, 7, tabToCoordinates.x - coordinates.x + 50, tabToCoordinates.y - coordinates.y);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.setValue = function(controlName, value)
{
  try
  {
    var control = (typeof controlName === 'string') ? this.monitorWindow.FindChild("Name", controlName, MAX_CHILDS) : controlName;
    setValue(control, value);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.changeCheckBox = function(controlName, state)
{
  try
  {
    var control = (typeof controlName === 'string') ? this.monitorWindow.FindChild("Name", controlName, MAX_CHILDS) : controlName;
    if (control.Exists)
    {
      if (IsChecked(control) != state)
        vClickAction(control, 'Click');
    }
    else
      Log.Error("Control named " + controlName + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//direction is one of "UP" or "DOWN"
Monitor.prototype.scroll = function(elementName, direction, amount)
{
  try
  {
    amount = varToInt(amount);
    var element = (typeof elementName === 'string') ? this.monitorWindow.FindChild("Name", elementName, MAX_CHILDS) : elementName;
    vClickAction(element, 'Click');

    if (direction == "UP")
      var delta = amount;
    else if (direction == "DOWN")
      var delta = -amount;

    element.MouseWheel(delta);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.verifyExcelExport = function(excelWindow, actualRowCount, sqlClause)
{
  Delay(3000);
  var ExportResult = false;
  var strDesktop = WshShell.SpecialFolders("Desktop");
  var SavedExcelUrl = strDesktop + "\\ExportedExcel.xlsx";
  var ExcelCon, ConfigRS;
  var excel;
  try
  {
    if (Sys.WaitProcess("EXCEL", MAX_CHILDS).Exists)
    {
      Delay(2000);
      excel = Sys.Process("EXCEL");
      Delay(2000);
      var wndExcel = excel.Window("XLMAIN", "*" + excelWindow + "*", 1);
      if (excel.Exists)
      {
        if (!wndExcel || !wndExcel.Exists)
        {
          Log.Error("Excel Window not found on screen!");
          return;
        }
        wndExcel.SetFocus();
        Delay(1000);
        if (excel.FileVersionInfo.MajorPart >= 16)
        {
          wndExcel.Keys("[Alt]F");
          Delay(1000);
          wndExcel.Keys("AO");
        }
        else
        {
          wndExcel.Keys("[Alt]F");
          Delay(1000);
          wndExcel.Keys("A");
        }

        Delay(2000);
        //Save the file to the desktop as 'ExportedExcel.xlsx'
        excel.Window("#32770", "Save As").SaveFile(SavedExcelUrl);
        
        var cofirmSaveAsDlg = excel.FindChild('Name', 'Window("#32770", "Confirm Save As", 1)', 1);
        if (cofirmSaveAsDlg && cofirmSaveAsDlg.Exists && IsVisibleOnScreen(cofirmSaveAsDlg))
        {
          //cofirmSaveAsDlg.Keys("Y");
          var btnYes = cofirmSaveAsDlg.FindChild('Name', 'Window("Button", "&Yes", 1)', MAX_CHILDS);
          btnYes.CLick();
        }

        vCheckpoint("Exported file saved to Desktop!");
        Delay(5000);
        wndExcel.Close();
        Delay(3000);
        //Read exported file for rows count
        ExcelCon = ExcelUtility.vOpenADODBConnection(SavedExcelUrl, "xlsx");
        var sqlQuery = "Select COUNT(*) AS 'Count' from [Sheet1$] where " + sqlClause;
        ConfigRS = ExcelUtility.vGetRecordset(ExcelCon, sqlQuery);
        Delay(2000);
        var ExcelRowCount = ConfigRS.Fields.Item(0).Value;
        if (actualRowCount == ExcelRowCount)
          ExportResult = true;
        else
          Log.Error("Actual Row Count (" + actualRowCount + ") does not match the row count (" + ExcelRowCount + ") in Excel!");
      }
      else
        Log.Error("Error in exporting to Excel!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    if (ConfigRS) ConfigRS.Close();
    Delay(1000);
    if (ExcelCon) ExcelCon.Close();
    Delay(1000);
    if (excel && excel.Exists) excel.Close();
    Delay(2000);
    Utility.deleteFile(SavedExcelUrl);
    Delay(2000);
    return ExportResult;
  }
}

//Uses up or down arrow to increment or decrement
Monitor.prototype.changeWithArrow = function(elementName, direction, amount)
{
  try
  {
    var amount = varToInt(amount);
    var element = (typeof elementName === 'string') ? this.monitorWindow.FindChild("Name", elementName, MAX_CHILDS) : elementName;
    if (direction == "UP")
      var arrow = element.FindChild("Name", 'WPFObject("PART_UPBUTTON")', MAX_CHILDS);
    else if (direction == "DOWN")
      var arrow = element.FindChild("Name", 'WPFObject("PART_DOWNBUTTON")', MAX_CHILDS);

    for (var i = 0; i < amount; i++)
      vClickAction(arrow, 'Click');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.dragToTestLocation = function(control, _ToX, _ToY, ToX, ToY)
{
  try
  {
    var _x = 6;
    var _y = 7;

    if (ToX && ToX != "")
      _ToX = ToX;

    if (ToY && ToY != "")
      _ToY = ToY;

    if (absoluteValue(_ToX) > 15 || absoluteValue(_ToY) > 15)
    {
      vFocus(control);
      control.HoverMouse();
      control.Drag(_x, _y, _ToX, _ToY, skCtrl);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.exportToExcel = function()
{
  try
  {
    var exportButton = this.monitorWindow.FindChild("Name", 'WPFObject("ExportToExcelButton")', MAX_CHILDS);
    Delay(1000);
    if (exportButton.Exists && IsVisibleOnScreen(exportButton))
    {
      vClickAction(exportButton, 'Click');
      Delay(15000);
    }
    else
      Log.Error("Export button does not exist or is not visible on screen!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//For TD indicator = true 
Monitor.prototype.resizeColumn = function(colName, amount, indicator)
{
  try
  {
    var column = this.getColumnHeader(colName);
    if (column && column.Exists)
    {
      if(indicator == true)
        column.Drag(column.Width - 3, 8, amount, 0);
      else
        column.Drag(column.Width - 3, 10, amount, 0);
    }
    else
      Log.Error("Unable to find the column (" + colName + ")!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.moveColumnAfter = function(colName, afterColName)
{
  try
  {
    var afterColNameHeader = this.getColumnHeader(afterColName);
    if (!Reporter.TC_RESULT)
      return;

    var colNameHeader = this.getColumnHeader(colName);
    if (!Reporter.TC_RESULT)
      return;

    colNameHeader.Drag(3, 10, afterColNameHeader.Left - colNameHeader.Left + afterColNameHeader.Width + 5, 0);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get width of a column
Monitor.prototype.getColumnWidth = function(colName)
{
  try
  {
    var columnName = this.getColumnHeader(colName);
    if (!Reporter.TC_RESULT)
      return;

    return columnName.Width;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.scrollRight = function(toX, toY)
{
  try
  {
    this.hSb.Refresh();

    var horizontalScroll = this.hSb.WPFObject("PART_Track").WPFObject("Thumb", "", 1);
    if (horizontalScroll.Exists)
    {
      horizontalScroll.HoverMouse();
      horizontalScroll.drag(horizontalScroll.Width / 2, horizontalScroll.Height / 2, toX, toY);
      this.windowObj.Refresh();
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.clickRight = function(times)
{
  try
  {
    this.hSb.Refresh();

    var btnRight = this.hSb.WPFObject("repeatButton1").WPFObject("Rectangle", "", 1);
    if (btnRight.Exists)
    {
      for (var i=0; i < times; i++)
        vClickAction(btnRight, "Click");

      this.windowObj.Refresh();
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.scrollFarUp = function(toX, toY)
{
  try
  {
    this.vSb.Refresh();
    var verticalScroll = this.vSb.WPFObject("PART_Track").WPFObject("thumb");
    if (verticalScroll.Exists)
    {
      while (this.vSb.wPosition > this.vSb.wMin)
      {
        verticalScroll.HoverMouse((verticalScroll.Width / 2), (verticalScroll.Height / 2) - 5);
        verticalScroll.drag((verticalScroll.Width / 2), (verticalScroll.Height / 2) - 5, toX, toY);
        this.windowObj.Refresh();
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.scrollFarDown = function(toX, toY)
{
  try
  {
    this.vSb.Refresh();
    var verticalScroll = this.vSb.WPFObject("PART_Track").WPFObject("thumb");
    if (verticalScroll.Exists)
    {
      var startTime = aqDateTime.Now();
      while (this.vSb.wPosition < this.vSb.wMax)
      {
        verticalScroll.HoverMouse((verticalScroll.Width / 2), (verticalScroll.Height / 2) - 5);
        verticalScroll.drag((verticalScroll.Width / 2), (verticalScroll.Height / 2) - 5, toX, toY);
        this.windowObj.Refresh();

        var currentTime = aqDateTime.Now();
        if (this.vSb.wPosition < this.vSb.wMax && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= 10)
        {
          Log.Error("Could not scroll to the bottom in 10 seconds!");
          break;
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.scrollFarLeft = function(toX, toY)
{
  try
  {
    this.hSb.Refresh();
    var horizontalScroll = this.hSb.WPFObject("PART_Track").WPFObject("Thumb", "", 1);
    if (horizontalScroll.Exists)
    {
      var startTime = aqDateTime.Now();
      while (this.hSb.wPosition > this.hSb.wMin)
      {
        horizontalScroll.HoverMouse();
        horizontalScroll.drag(horizontalScroll.Width / 2, horizontalScroll.Height / 2, toX, toY);
        this.windowObj.Refresh();

        var currentTime = aqDateTime.Now();
        if (this.hSb.wPosition > this.hSb.wMin && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= 10)
        {
          Log.Error("Could not scroll to the left in 10 seconds!");
          break;
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.scrollFarRight = function(toX, toY)
{
  try
  {
    this.hSb.Refresh();
    var horizontalScroll = this.hSb.WPFObject("PART_Track").WPFObject("Thumb", "", 1);
    if (horizontalScroll.Exists)
    {
      var startTime = aqDateTime.Now();
      while (this.hSb.wPosition < this.hSb.wMax)
      {
        horizontalScroll.HoverMouse();
        horizontalScroll.drag(horizontalScroll.Width / 2, horizontalScroll.Height / 2, toX, toY);
        this.windowObj.Refresh();
        var currentTime = aqDateTime.Now();
        if (this.hSb.wPosition < this.hSb.wMax && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= 10)
        {
          Log.Error("Could not scroll to the right in 10 seconds!");
          break;
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Column Index from Column Name
Monitor.prototype.getColIndexFromName = function(colName)
{
  try
  {
    var colHeader = this.getColumnHeader(colName);
    if (!Reporter.TC_RESULT)
      return;

    return (colHeader.Field.Index);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns an array containing all the trade row values for a given column name
Monitor.prototype.getColumnValues = function(colName, filterRow)
{
  try
  {
    this.xamDataGrid.Refresh();
    var colIndex = this.getColIndexFromName(colName);
    var values = new Array();
    var rowCount = this.xamDataGrid.Records.ViewableRecords.CountOfNonSpecialRecords;
    var i = 0;
    if (filterRow && filterRow != null && filterRow != "" && filterRow == 'Y')
    {
      i = 1;
      rowCount = rowCount + 1;
    }

    if (rowCount && rowCount > 0)
    {
      for (; i < rowCount; i++)
      {
        var value = this.xamDataGrid.Records.ViewableRecords.Item(i).Cells.Item(colIndex).ConvertedValue;
        if (value)
          values.push(value.OleValue);
        else
          values.push("");
      }
    }
    return values;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.removeColumnByDragging = function(colName)
{
  try
  {
    var colNameHeader = this.getColumnHeader(colName);
    if (!Reporter.TC_RESULT)
      return;

    colNameHeader.Drag(3, 10, -colNameHeader.Left - 10, 0);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
Monitor.prototype.getAttribute = function(grid, rowIndex, tagName)
{
  try
  {
    var row = this.getCEFRow(grid, rowIndex);
    if (!Reporter.TC_RESULT)
      return;

    return row.getAttribute(tagName); 
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//type = col-id or empty
//col-id for Full Volumn Name //empty for UI column name
Monitor.prototype.getCEFColumnsNameList = function(grid, type)
{
  try
  {
    var headerPresenter = grid.FindChild("className", 'ag-header-row', MAX_CHILDS);
    if (!headerPresenter.Exists || !IsVisibleOnScreen(headerPresenter))
    {
      Log.Error("Header Row is not available / visible on window!");
      return;
    }

    var arrColumnNames = headerPresenter.FindAll("className", 'ag-header-cell*', 1).toArray();
    if (arrColumnNames.length > 0)
    {
      for (var i = 0; i < arrColumnNames.length; i++)
      {
        if(type && type != null && type != "")
          arrColumnNames[i] = getXmlAttributeValue(arrColumnNames[i].outerHTML, "div", 0, type)
        else
          arrColumnNames[i] = getText(arrColumnNames[i]);
      }
      return arrColumnNames;
    }
    else
      Log.Error("There are no columns in the data grid!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
Monitor.prototype.getCEFCell = function(grid, rowIndex, colName)
{
  try
  {
    var row = this.getCEFRow(grid, rowIndex);
    if (!Reporter.TC_RESULT)
      return;

    var cell = row.FindChildByXPath("//div[@role='gridcell'][@col-id='" + colName + "']");
    if (cell && cell.Exists)
      return cell;
    else
      Log.Error("Cell does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
Monitor.prototype.deleteCEFGridRow = function(grid, rowIndex)
{
  try
  {
    var row = this.getCEFRow(grid, rowIndex);
    if (!Reporter.TC_RESULT)
      return;

    var control = row.FindChild("title", 'delete', MAX_CHILDS);

    if (control && control.Exists)
    {
      vClickAction(control, 'Click');
      Delay(1000);
    }
    else
      Log.Error("Delete button not found!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
Monitor.prototype.editCEFGridRow = function(grid, rowIndex)
{
  try
  {
    var row = this.getCEFRow(grid, rowIndex);
    if (!Reporter.TC_RESULT)
      return;

    var control = row.FindChild("title", 'edit', MAX_CHILDS);
    if (control && control.Exists)
    {
      vClickAction(control, 'Click');
      Delay(1000);
    }
    else
      Log.Error("Edit button not found!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
Monitor.prototype.getCEFCellValue = function(grid, rowIndex, colName)
{
  try
  {
    var cell = this.getCEFCell(grid, rowIndex, colName);
    if (!Reporter.TC_RESULT)
      return;

    return cell.textContent;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns CEF Column Object
Monitor.prototype.getCEFColumnHeader = function(grid, colName)
{
  try
  {
    var arrProp1 = new Array("className", "contentText");
    var arrValue1 = new Array("ag-heade*", "*" + colName + "*");
    var headerPresenter = grid.FindChild(arrProp1, arrValue1, MAX_CHILDS);
    if (!headerPresenter.Exists || !IsVisibleOnScreen(headerPresenter))
    {
      Log.Error("Header Row is not available / visible on window!");
      return;
    }

    var arrProp = new Array("ObjectType", "contentText");
    var arrValue = new Array("Panel", colName);
    var column = headerPresenter.FindChild(arrProp, arrValue, MAX_CHILDS);
    if (column && column.Exists)
    {
      if (column.Visible)
        return column;
      else
        Log.Error("Column (" + colName + ") exists but it is not visible!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Move Columns in CEF window //tdIndicator = pin or empty
Monitor.prototype.moveCEFColumnAfter = function(grid, colName, afterColName, tdIndicator)
{
  try
  {
    if (tdIndicator && tdIndicator != null && tdIndicator == "pin")
    {
      var afterColNameHeader = this.getColumnHeader(afterColName);
      if (!Reporter.TC_RESULT)
        return;

      var colNameHeader = this.getColumnHeader(colName);
      if (!Reporter.TC_RESULT)
        return;

      var dragX = colNameHeader.Width / 2;
      var dragY = colNameHeader.Height / 2;
      colNameHeader.Drag(dragX, dragY, afterColNameHeader.Left - colNameHeader.Left + (afterColNameHeader.Width - 60), 0);
    }
    else
    {
      var afterColNameHeader = this.getCEFColumnHeader(grid, afterColName);
      if (!Reporter.TC_RESULT)
        return;

      var colNameHeader = this.getCEFColumnHeader(grid, colName);
      if (!Reporter.TC_RESULT)
        return;

      colNameHeader.Drag(3, 10, afterColNameHeader.Left - colNameHeader.Left + (afterColNameHeader.Width / 2), 0);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.undock = function()
{
  try
  {
    var control = this.windowObj.FindChild("ToolTip", 'Undock', MAX_CHILDS);
    if (control && control.exists)
      vClickAction(control, 'Click');
    else
      Log.Error("Undock button does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

Monitor.prototype.openLink = function(linkName)
{
  try
  {
    vClickAction(eval("this.lnk" + linkName), 'Click');
    Delay(1000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//eg: getComputedStyle(inputOfCell, "content", ':after', ) //pseudoElement = ':after' if actual element is ::after 
Monitor.prototype.getComputedStyle = function(object, property, pseudoElement)
{
  try
  {
    var wnd = object.ownerDocument.defaultView;
    if (pseudoElement || pseudoElement != null || pseudoElement != undefined)
      var style = wnd.getComputedStyle(object, pseudoElement);
    else
      var style = wnd.getComputedStyle(object, "");
    return style[property];
  }
  catch (e)
  {
    Log.Error(e);
  }
}