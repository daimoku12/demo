//USEUNIT GlobalIncludes
//USEUNIT TD_GlobalVariables
//USEUNIT TD_HelperModule
//USEUNIT TD_ToolbarModule
//USEUNIT MonitorModule
//USEUNIT TDDataGrid

//Inherits from the base class (of the base.js framework)
var TDMonitor = Monitor.extend(
{
  constructor: function(winType)
  {
    //Get the window handle property for the last window that was opened
    try
    {
      if (CurrentAppCode != "TD")
        TD_GlobalVariables.getApplicationDetails();

      this.monitorWindow = appendNewestWindowByHandle(winType);
      //Sys.HighlightObject(this.monitorWindow);
      if (this.monitorWindow && this.monitorWindow.Exists)
      {
        if(winType == "Wpf" || winType == "TbPref")
          this.btnClose = this.monitorWindow.FindChild("Name", 'WPFObject("Button", "Cancel", *)', MAX_CHILDS);
        else
          this.btnClose = this.monitorWindow.FindChildByXPath("//button[@data-automation = 'btnWindowClose']");
        //this.resizeGrip = this.monitorWindow.FindChild("Name", 'Panel("captionBackground")', MAX_CHILDS);
      }
      else
        Log.Error("Monitor Window not found!");
    }
    catch (e)
    {
      Log.Error(e);
    }
  }
});;

TDMonitor.prototype.cefRightClickSelectMenu = function(obj, windowObj, menu, extendedMenu)
{
  try
  {
    vClickAction(obj, 'RightClick');
    Delay(1000);

    var menuList = windowObj.FindChild("className", "ag-menu-list", MAX_CHILDS);
    if (!menuList.Exists)
    {
      Log.Error("Cannot locate menu list!");
      return;
    }

    var menuHndl = menuList.FindChild(new Array("className", "contentText"), new Array("ag-menu-option*", menu), MAX_CHILDS);
    if (!menuHndl.Exists)
    {
      Log.Error("Menu item: " + menu + " not found in the list!");
      return;
    }
    else
    {
      vClickAction(menuHndl, 'Click');
      vCheckpoint("Right click menu>[" + menu + "] clicked!");
      Delay(500);
    }

    //Click on extended menu if available
    if (!extendedMenu)
      return;
    else
    {
      var extendedMenuHndl = windowObj.FindChild(new Array("Name", "contentText"), new Array('TextNode("eName")', extendedMenu), MAX_CHILDS);
      if (!extendedMenuHndl || !extendedMenuHndl.Exists)
      {
        Log.Error("Extended Menu not opened!");
        return;
      }
      vClickAction(extendedMenuHndl, 'Click');
      vCheckpoint("Right click menu>[" + menu + "]>[" + extendedMenu + "] clicked!");
      Delay(500);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getColumnHeader = function(colName)
{
  try
  {
    var arrProp = new Array("className", "col-id");
    var arrValue = new Array("ag-heade*", "*" + colName + "*");
    var column = this.xDg.FindChild(arrProp, arrValue, MAX_CHILDS);
    if (!column || !column.Exists)
    {
      Log.Error("Column is not available / visible on window!");
      return;
    }
    else
      return column;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns the UI name of a column
TDMonitor.prototype.getUIColumnNameFromFullColumn = function(column)
{
  try
  {
    var header = this.getColumnHeader(column);
    if (!Reporter.TC_RESULT)
      return;
    return aqString.Trim(header.textContent, aqString.stAll)
  }
  catch (e)
  {
    Log.Error(e, "getUIColumnNameFromFullColumn");
  }
}

//This function resizes the particular window to smaller size
// x & y give negatives to resize to smaller size eg: -40
TDMonitor.prototype.resize = function(obj, x, y)
{
  try
  {
    var dragX = obj.Width;
    var dragY = obj.Height;
    Delay(1000);
    obj.Drag(dragX - 3, dragY - 3, x, y);
  }
  catch (e)
  {
    Log.Error(e, "resize");
  }
}

//Performs and Verifies right/left/no pin in grid by dragging
TDMonitor.prototype.verifyPinInGridByDrag = function(column1, column2, column3, column4, column5)
{
  try
  {
    this.cefRightClickSelectMenu(this.getColumnHeader(column1), this.windowObj, "Pin Column", "Pin Right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column1), "right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column2), this.windowObj, "Pin Column", "Pin Left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column2), "left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.moveCEFColumnAfter(this.xDg, column4, column2, "pin");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column4), "left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.moveCEFColumnAfter(this.xDg, column3, column1, "pin");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column3), "right");
    if (!Reporter.TC_RESULT)
      return;
      
    //Unpin by drag and verify
    this.moveCEFColumnAfter(this.xDg, column4, column5, "pin");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column4), "noPin");
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e, "verifyPinInGridByDrag");
  }
}

//Performs and Verifies right/left/no pin in grid from header 
TDMonitor.prototype.verifyPinInGridFromHeader = function(column1, column2, column3, column4)
{
  try
  {
    this.cefRightClickSelectMenu(this.getColumnHeader(column1), this.windowObj, "Pin Column", "Pin Right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column1), "right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column2), this.windowObj, "Pin Column", "Pin Left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column2), "left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column1), this.windowObj, "Pin Column", "Pin Left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column1), "left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column2), this.windowObj, "Pin Column", "Pin Right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column2), "right");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column2), this.windowObj, "Pin Column", "No Pin");
    if (!Reporter.TC_RESULT)
      return;
      
    this.isColumnPinnedInGrid(this.getUIColumnNameFromFullColumn(column2), "noPin");
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e, "verifyPinInGridFromHeader");
  }
}

//Re-arranges order in Preference and verifies display order in grid
TDMonitor.prototype.verifyPinFromPreference = function(column1, column2, column3, column4)
{
  try
  {
    this.cefRightClickSelectMenu(this.getColumnHeader(column1.DOMName), this.windowObj, "Pin Column", "Pin Left");
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(this.getColumnHeader(column2.DOMName), this.windowObj, "Pin Column", "Pin Left");
    if (!Reporter.TC_RESULT)
      return;
      
    var tdPrefWin = this.launchPreferences(column4, "Display");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.dragDisplay(column3.UIName, column2.UIName);
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;
      
    var gridColumns = this.xDg.FindChild("className", 'ag-pinned-left-header', MAX_CHILDS);
    
    if (!gridColumns || !gridColumns.Exists)
    {
      Log.Error("There are no left pinned columns in the grid!", "verifyPinFromPreference");
      return;
    }
    gridColumns = gridColumns.getElementsByClassName("ag-header-row");
    gridColumns = gridColumns[gridColumns.length - 1].getElementsByClassName("ag-header-cell-sortable");
    if (gridColumns.length == 0)
    {
      Log.Error("There are no columns under left pin!", "verifyPinFromPreference");
      return;
    }

    if (compareValuesInArray(arrayOfPropertyValue(gridColumns, "textContent")), (column1.UIName, column2.UIName,column2.UIName))
      vCheckpoint("Columns order in grid and preference match after re-arrange in Preference!");
    else
      Log.Error("Columns order in grid and preference do not match after re-arrange in Preference!");
  }
  catch (e)
  {
    Log.Error(e, "verifyPinFromPreference");
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

//Pins columns in Preference and verifies if the pinned section is scrollable in grid
TDMonitor.prototype.verifyPinScrollable = function(column1, column2, column3)
{
  try
  {
    var tdPrefWin = this.launchPreferences(column3, "Display");
    if (!Reporter.TC_RESULT)
      return;

    tdPrefWin.rightOrLeftPinColumn(column1.GridPrefName, "left");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.rightOrLeftPinColumn(column2.GridPrefName, "right");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.verifyIfColumnPinnedRightOrLeft(column1.GridPrefName, "left");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.verifyIfColumnPinnedRightOrLeft(column2.GridPrefName, "right");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;
      
    //Resize window to smaller size
    this.resize(this.windowObj, -this.windowObj.Width / 2, -this.windowObj.Height / 2);
    if (!Reporter.TC_RESULT)
      return;

    var leftPinnedCols = this.windowObj.FindChild("className", 'ag-pinned-left-header', 2000);
    var rightPinnedCols = this.windowObj.FindChild("className", 'ag-pinned-right-header', 2000);
    var mid = this.windowObj.FindChild("className", 'ag-body-horizontal-scroll-viewport', 2000);

    //Drag the scroll bar in mid section
    mid.Drag(3, mid.Height - 3, mid.Width, 0)
    if (!leftPinnedCols.VisibleOnScreen || !rightPinnedCols.VisibleOnScreen)
      Log.Error("Left or Right pinned columns are scrollable!", "verifyPinFromPreference");
    mid.Drag(mid.Width - 10, mid.Height - 3, -mid.Width + 20, 0)
    
    if (!leftPinnedCols.VisibleOnScreen || !rightPinnedCols.VisibleOnScreen)
    {
      Log.Error("Left or Right pinned columns are scrollable!", "verifyPinScrollable");
      return;
    }
    else
      vCheckpoint("Left and Right pinned columns are not scrollable!");
  }
  catch (e)
  {
    Log.Error(e, "verifyPinScrollable");
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

////Remove column from grid by drag. This functionality has been removed
//TDMonitor.prototype.removeColumnFromGridByDrag = function(column)
//{
//  try
//  {
//    this.removeColumnByDragging(column.DOMName);
//    if (!Reporter.TC_RESULT)
//      return;
//
//    if (this.isColumnAvailableInHeader(column.UIName) == false)
//      vCheckpoint("Column " + column + " has been removed from the grid by dragging!");
//    else
//      Log.Error("Column " + column + " not removed from grid by dragging!", "removeColumnFromGridByDrag");
//  }
//  catch (e)
//  {
//    Log.Error(e, "removeColumnFromGridByDrag");
//  }
//}

//Verify if a column is available in the header
TDMonitor.prototype.isColumnAvailableInHeader = function(column)
{
  try
  {
    return checkIfValueExistsInArray(this.getCEFColumnsNameList(this.headerContainer), column) ? true : false;
  }
  catch (e)
  {
    Log.Error(e, "isColumnAvailableInHeader");
  }
}

//Sort a column // direction = "asc" or "desc" 
TDMonitor.prototype.sortColumn = function(columnObj, direction)
{
  try
  {
    var ascMessage = "long-arrow-alt-up";
    var descMessage = "long-arrow-alt-down";

    switch (direction)
    {
      case "asc":
        vClickAction(columnObj, 'DoubleClick');
        columnObj.Refresh();
        return (columnObj.OuterHTML.indexOf(ascMessage) >= 0) ? true : false;

      case "desc":
        vClickAction(columnObj, 'DoubleClick');
        Delay(1000);
        vClickAction(columnObj, 'DoubleClick');
        columnObj.Refresh();
        return (columnObj.OuterHTML.indexOf(descMessage) >= 0) ? true : false;
    }
  }
  catch (e)
  {
    Log.Error(e, "sortColumn");
  }
}

//Returns Column values under a column //Type: sorted or noSort
TDMonitor.prototype.getColumnValues = function(column, type)
{
  try
  {
    var columnValues = this.getCEFColumnValues(this.xDg, column);
    if (type && type == "noSort")
      return columnValues;
    else
      return columnValues.sort();
  }
  catch (e)
  {
    Log.Error(e, "getColumnValues");
  }
}

//Sorts and verifies the sort for a given direction for a column
// direction = "asc" or "desc"
// type = "string" or "numeric" 
TDMonitor.prototype.verifySortColumn = function(column, type, direction)
{
  try
  {
    var before = this.getColumnValues(column, "noSort");
    var descMessage = "long-arrow-alt-down";
    var ascMessage = "long-arrow-alt-up";
    var columnObj = this.getColumnHeader(column);
    if (!Reporter.TC_RESULT)
      return;
    this.sortColumn(columnObj, direction);
    if (!Reporter.TC_RESULT)
      return;

    var after = this.getColumnValues(column, "noSort");
    if (!Reporter.TC_RESULT)
      return;

    var arrow = (direction == "asc") ? "Up" : "Down";

    if (type == "numeric" && direction == "asc")

    {
      if (isNumberArraySorted(after, direction))
        vCheckpoint("Values in numeric column [" + column + "] are sorted in " + direction + " and " + arrow + " arrow is displayed!");
      else
        Log.Error("Values in numeric column [" + column + "] are not sorted in " + direction + " or " + arrow + " arrow is not displayed!", "verifySortColumn");
    }
    else if (type == "numeric" && direction == "desc")
    {
      if (columnObj.OuterHTML.indexOf(descMessage) >= 0 && isNumberArraySorted(after, "desc"))
        vCheckpoint("Values in numeric column [" + column + "] are sorted in " + direction + " and " + arrow + " arrow is displayed!");
      else
        Log.Error("Values in numeric column [" + column + "] are not sorted in " + direction + " or " + arrow + " arrow is not displayed!", "verifySortColumn");
    }

    else if (type == "string" && direction == "asc")
    {
      if (compareValuesInArray(before.sort(), after))
        vCheckpoint("Values in string column [" + column + "] are sorted in " + direction + " and " + arrow + " arrow is displayed!");
      else
        Log.Error("Values in string column [" + column + "] are not sorted in " + direction + " or " + arrow + " arrow is not displayed!", "verifySortColumn");
    }

    else if (type == "string" && direction == "desc")
    {
      if (columnObj.OuterHTML.indexOf(descMessage) >= 0 && compareValuesInArray(before.sort().reverse(), after))
        vCheckpoint("Values in string column [" + column + "] are sorted in " + direction + " and " + arrow + " arrow is displayed!");
      else
        Log.Error("Values in string column [" + column + "] are not sorted in " + direction + " or " + arrow + " arrow is not displayed!", "verifySortColumn");
    }
  }
  catch (e)
  {
    Log.Error(e, "verifySortColumn");
  }
}

//Sort a column // direction = "asc" or "desc" 
TDMonitor.prototype.multipleSort = function(column1, direction1, column2, direction2)
{
  try
  {
    var columnObj1 = this.getColumnHeader(column1);
    var columnObj2 = this.getColumnHeader(column2);
    var asc = "long-arrow-alt-up";
    var desc = "long-arrow-alt-down";

    var before = this.getTotalRowsCount();
    if (!Reporter.TC_RESULT)
      return;

    vClickAction(columnObj1, 'Click');
    if (!Reporter.TC_RESULT)
      return;

    Delay(1000);

    var after = this.getCountFromStatusBar();
    if (!Reporter.TC_RESULT)
      return;

    var selectedGridValues = arraySort(arrayOfPropertyValue(this.xDg.getElementsByClassName("ag-cell-range-selected"), "textContent"));
    var colValues = arraySort(this.getColumnValues(column1));
    if (!Reporter.TC_RESULT)
      return;

    if (compareValuesInArray(selectedGridValues, colValues) && (before == after))
      vCheckpoint("Single click on Column [" + column1 + "] header selects the entire column!");
    else
      Log.Error("Single click on Column [" + column1 + "] header does not select the entire column!", "multipleSort");

    this.sortColumn(columnObj1, direction1);
    if (!Reporter.TC_RESULT)
      return;

    LLPlayer.KeyDown(VK_SHIFT, 200);

    this.sortColumn(columnObj2, direction2);
    if (!Reporter.TC_RESULT)
      return;

    LLPlayer.KeyUp(VK_SHIFT, 200);

    var sort1 = direction1 = "asc" ? asc : desc;
    var sort2 = direction2 = "asc" ? asc : desc;

    if (columnObj1.OuterHTML.indexOf(sort1) >= 0 && columnObj2.OuterHTML.indexOf(sort2) >= 0)
      vCheckpoint("Columns [" + column1 + "] and [" + column2 + "] are both sorted using Shift Key!");
    else
      Log.Error("Columns [" + column1 + "] and [" + column2 + "] are both not sorted using Shift Key!", "multipleSort");

  }
  catch (e)
  {
    Log.Error(e, "multipleSort");
  }
}

//Get all sorted columns and the sort order from grid as a 2D array
TDMonitor.prototype.getAllSortedColumnsInGrid = function()
{
  try
  {
    var elements = this.xDg.getElementsByClassName("ag-header-cell-label");
    if (elements.length == 0)
    {
      Log.Error("There are no column headers found!", "getAllSortedColumnsInGrid");
      return;
    }
    var msg = "long-arrow-alt";
    var asc = "long-arrow-alt-up";
    var desc = "long-arrow-alt-down";
    var results = [];
    for (var i = 0; i < elements.length; i++)
    {
      if (elements[i].OuterHTML.indexOf(msg) >= 0)
      {
        var col = elements[i].textContent;
        var sort = elements[i].OuterHTML.indexOf(asc) >= 0 ? "Asc" : "Desc";
        results.push([col, sort]);
      }
    }
    return results.sort();
  }
  catch (e)
  {
    Log.Error(e, "getAllSortedColumnsInGrid");
  }
}

//Verifies Filter count before and after Find
TDMonitor.prototype.verifyFindFilterCountBeforeAndAfter = function(column)
{
  try
  {
    var beforeRowsCount = this.getTotalRowsCount();

    //Verify Number of Occurance and Filtered Count
    if (this.verifyFilteredCountAndOccuranceNumber(column))
      vCheckpoint("Records get filtered out as per the search. Number of occurance verified!");
    else
      Log.Error("Records are not filtered as per the search or Number of occurance is wrong!", "verifyFindFilterCountBeforeAndAfter");

    //Click Find Close button
    vClickAction(this.returnFindWindowControls("times"), 'Click');

    var afterFindClose = this.getColumnValues(column);
    if (!Reporter.TC_RESULT)
      return;

    var afterCloseRowsCount = afterFindClose.length;

    //Verify if Filter is cleared and all data are back on grid
    if (afterCloseRowsCount == beforeRowsCount)
      vCheckpoint("After Find is closed, Filter is cleared and complete data is displayed back on grid!");
    else
      Log.Error("After Find is closed, Filter is not cleared or complete data is not displayed back on grid!", "verifyFindFilterCountBeforeAndAfter");
  }
  catch (e)
  {
    Log.Error(e, "verifyFindFilterCountBeforeAndAfter");
  }
}

//Get Total Rows Count
TDMonitor.prototype.getTotalRowsCount = function()
{
  try
  {
    var control = this.windowObj.FindChild("className", 'ag-status-panel', MAX_CHILDS);
    if (control.Exists)
    {
      var totalRows = control.FindChild("className", 'ag-name-value-value', MAX_CHILDS).textContent;
      return totalRows;
    }
    else
      Log.Error("Total rows count does not exist!", "getTotalRowsCount");
  }
  catch (e)
  {
    Log.Error(e, "getTotalRowsCount");
  }
}

//Verify number of occurance in Find
TDMonitor.prototype.verifyFilteredCountAndOccuranceNumber = function(column)
{
  try
  {
    var char1 = this.getCharFromValue(column);
    if (!Reporter.TC_RESULT)
      return;

    //Get Total Rows Count
    var beforeRowsCount = this.getTotalRowsCount();
    var occurance = 0;
    var columns = this.getCEFColumnsNameList(this.headerContainer, "col-id");
    for (i = 0; i < columns.length; i++)
    {
      var count = arrayFindOccurance(this.getColumnValues(columns[i]), char1)
      occurance = occurance + count;
    }

    var beforeOccurance = "1/" + occurance;

    this.launchContextMenu(column, "Find");
    if (!Reporter.TC_RESULT)
      return;
    Delay(1000);

    this.inputFind(char1);
    if (!Reporter.TC_RESULT)
      return;
    Delay(1000);

    var after = this.getColumnValues(column);
    var filteredRows = after.length;

    //Verifies Filtered count
    if (filteredRows == this.getFilteredRowsCount())
      vCheckpoint("After Find, Filtered Count on Status bar is updated!");
    else
    {
      Log.Error("After Find, Filtered Count on Status bar is wrong!", "verifyFilteredCountAndOccuranceNumber");
      return;
    }

    //Verifies Occurance number  
    var afterOccurance = this.getOccuranceFind();
    return (beforeOccurance == afterOccurance) ? true : false
  }
  catch (e)
  {
    Log.Error(e, "verifyFilteredCountAndOccuranceNumber");
  }
}

//Returns a character from value of a column
TDMonitor.prototype.getCharFromValue = function(column)
{
  try
  {
    //Retrieves 1st value of the column
    var value = this.getCEFCell(this.xDg, 0, column).innerText;
    if (!Reporter.TC_RESULT)
      return;

    //Retrieves a char from the value
    var length = aqString.GetLength(value);
    var char1 = aqString.GetChar(value, Math.floor(Math.random() * length));
    return char1;
  }
  catch (e)
  {
    Log.Error(e, "getCharFromValue");
  }
}

TDMonitor.prototype.getStringCellFirstChar = function(columnNameDOM)
{
  try
  {
    //Retrieves 1st value of the column
    var value = this.getCEFCell(this.xDg, 0, columnNameDOM).innerText;
    if (!Reporter.TC_RESULT)
      return;

    return value.charAt(0);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getStringCellLastChar = function(columnNameDOM)
{
  try
  {
    //Retrieves 1st value of the column
    var value = this.getCEFCell(this.xDg, 0, columnNameDOM).innerText;
    if (!Reporter.TC_RESULT)
      return;

    return value[value.length -1]
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Occurance numbers in Find
TDMonitor.prototype.getOccuranceFind = function()
{
  try
  {
    var control = this.windowObj.FindChild("className", 'matches', MAX_CHILDS);
    if (!control || !control.Exists)
    {
      Log.Error("Find box occurance not available!", "getOccuranceFind");
      return;
    }
    return control.textContent;
  }
  catch (e)
  {
    Log.Error(e, "getOccuranceFind");
  }
}

//Returns Find Window controls. Parameter: Refresh symbol="redo", UpArrow="chevron-up", DownArrow="chevron-down", Close="times"
TDMonitor.prototype.returnFindWindowControls = function(parameter)
{
  try
  {
    var findBox = this.frame.FindChildByXPath("//*[@class='content ng-star-inserted' and .//input[@placeholder='Find']]");
    var control = findBox.FindChildByXPath("//fa-icon[@class= 'ng-fa-icon'][@icon='" + parameter + "']/parent::button");

    if (!control || !control.Exists)
    {
      Log.Error("Find box control with parameter " + parameter + " not available!", "returnFindWindowControls");
      return;
    }
    return control;
  }
  catch (e)
  {
    Log.Error(e, "returnFindWindowControls");
  }
}

//Input to Find
TDMonitor.prototype.inputFind = function(value)
{
  try
  {
    var control = this.windowObj.FindChild("className", 'form-control', MAX_CHILDS);
    if (!control || !control.Exists)
    {
      Log.Error("Find input box could not be found!", "inputFind");
      return;
    }
    vClickAction(control, 'Click');
    control.SetText(value);
    vCheckpoint("Value " + value + " is entered in Find box");
  }
  catch (e)
  {
    Log.Error(e, "inputFind");
  }
}

//Find Object
TDMonitor.prototype.returnFindDialogueBox = function()
{
  try
  {
    var control = this.windowObj.FindChild("className", 'search-box-container', MAX_CHILDS);
    if (!control || !control.Exists)
    {
      Log.Error("Find box not available!", returnFindDialogueBox);
      return;
    }
    vCheckpoint("Find Dialog Box is launched!");
    return control;
  }
  catch (e)
  {
    Log.Error(e, "returnFindDialogueBox");
  }
}

//Verify Find for String or Numeric
TDMonitor.prototype.verifyFind = function(column)
{
  try
  {
    var char1 = this.getCharFromValue(column);
    if (!Reporter.TC_RESULT)
      return;

    var elements = this.rowContainer.getElementsByClassName("ag-row");
    var before = arraySort(arrayOfPropertyValue(elements, "textContent"));
    Delay(1000);

    this.launchContextMenu(column, "Find");
    if (!Reporter.TC_RESULT)
      return;

    Delay(1000);

    this.inputFind(char1);
    if (!Reporter.TC_RESULT)
      return;

    Delay(1000);

    var afterElements = this.rowContainer.getElementsByClassName("ag-row");
    var after = arraySort(arrayOfPropertyValue(afterElements, "textContent"));
    Delay(2000);

    if (compareValuesInArray(arrayOfElementForACondition(before, "Contains", char1), after))
    {
      vCheckpoint("When " + char1 + " is applied to Find, only the rows which contain the character are displayed!");
      return true;
    }
    else
    {
      Log.Error("When " + char1 + " is applied to Find, rows which contain the character are not displayed!", "verifyFind");
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e, "verifyFind");
  }
}

//Launch options from context menu
TDMonitor.prototype.launchContextMenu = function(column, option)
{
  try
  {
    var firstRowIdCell = this.getCEFCell(this.xDg, 0, column);
    if (!Reporter.TC_RESULT)
      return;

    vClickAction(firstRowIdCell, 'Click');
    Delay(1000);

    this.cefRightClickSelectMenu(firstRowIdCell, this.windowObj, "Find");
    if (!Reporter.TC_RESULT)
      return;
    vCheckpoint("Context Menu>" + option + " is clicked");
  }
  catch (e)
  {
    Log.Error(e, "launchContextMenu");
  }
}

//Get Filtered Rows count
TDMonitor.prototype.getFilteredRowsCount = function()
{
  try
  {
    var statusBar = this.windowObj.FindChild("className", 'ag-status-bar', MAX_CHILDS);
    var filtered = statusBar.FindChildByXPath("//span[contains(text(), 'Filtered Rows')]/parent::*");
    if (!!filtered || filtered == undefined)
      return (this.rowContainer.getElementsByClassName("ag-row")).length;
    else if (filtered.Exists)
      return filtered.FindChild("className", 'ag-name-value-value', MAX_CHILDS).textContent;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Count (When a column header is selected, count is displayed)
TDMonitor.prototype.getCountFromStatusBar = function()
{
  try
  {
    var statusBar = this.windowObj.FindChild("className", 'ag-status-bar', MAX_CHILDS);
    var count = statusBar.FindChildByXPath("//*[@data-automation='countAggregationComp']");
    if (count.Exists)
    {
      var selectedCount = count.FindChild("className", 'ag-name-value-value', MAX_CHILDS).textContent;
      return selectedCount;
    }
    else
      Log.Error("Count does not exist or no column header is selected!", "getCountFromStatusBar");

  }
  catch (e)
  {
    Log.Error(e, "getCountFromStatusBar");
  }
}

//Verify Search Highlight in Blue
TDMonitor.prototype.verifySearchHighlightBlueForFind = function(column)
{
  try
  {
    var char1 = this.getCharFromValue(column);
    if (!Reporter.TC_RESULT)
      return;

    this.launchContextMenu(column, "Find");
    if (!Reporter.TC_RESULT)
      return;

    Delay(1000);

    this.inputFind(char1);
    if (!Reporter.TC_RESULT)
      return;

    Delay(1000);

    var elements = this.rowContainer.getElementsByClassName("highlight");
    Delay(1000);

    if (checkArray(arrayOfPropertyValue(elements, "textContent"), "exists", char1))
    {
      vCheckpoint("Searched text is highlighted in blue!");
      return elements;
    }
    else
      Log.Error("Searched text is not highlighted in blue!", "verifySearchHighlightBlueForFind");
  }
  catch (e)
  {
    Log.Error(e, "verifySearchHighlightBlueForFind");
  }
}

//Verifies if Up and Down button moves the focus in Find 
TDMonitor.prototype.verifyFindFocusMove = function(column)
{
  try
  {
    var control = this.verifySearchHighlightBlueForFind(column);
    if (control.length < 2)
    {
      Log.Error("Enough rows not available to verify this functionality!", "verifyFindFocusMove");
      return;
    }
    Delay(500);
    var beforeIndex = returnIndexContains(control, "cell-focus");
    if (beforeIndex == 0)
      vCheckpoint("First element is highlighted!");
    else
    {
      Log.Error("First element is not highlighted!", "verifyFindFocusMove");
      return;
    }

    //Clicks the down arrow button
    vClickAction(this.returnFindWindowControls("chevron-down"), 'Click');

    var control1 = this.rowContainer.getElementsByClassName("highlight");
    var index1 = returnIndexContains(control1, "cell-focus");

    var beforeRowsCount = this.getTotalRowsCount();
    var occurance = 0;
    var columns = this.getCEFColumnsNameList(this.headerContainer, "col-id");
    for (i = 0; i < columns.length; i++)
    {
      var count = arrayFindOccurance(this.getColumnValues(columns[i]), this.getFindBoxValue())
      occurance = occurance + count;
    }

    //Verifies index of focused element and occurance number change
    if ((index1 == beforeIndex + 1) && (this.getOccuranceFind() == (index1 + 1) + "/" + occurance))
      vCheckpoint("When Down button in Find is clicked, the focus moves to next element!");
    else
    {
      Log.Error("After pressing up button the focus has not moved to previous element!", "verifyFindFocusMove");
      return;
    }

    //Clicks on Up arrow button
    vClickAction(this.returnFindWindowControls("chevron-up"), 'Click');

    var control2 = this.rowContainer.getElementsByClassName("highlight");
    var index2 = returnIndexContains(control1, "cell-focus");

    //Verifies index of focused element and occurance number change
    if ((index2 == beforeIndex) && (this.getOccuranceFind() == (index2 + 1) + "/" + occurance))
      vCheckpoint("When Up button in Find is clicked, the foucus moves to previous element!");
    else
    {
      Log.Error("After pressing down button the focus has not moved to next element!", "verifyFindFocusMove");
      return;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get value from Find box
TDMonitor.prototype.getFindBoxValue = function()
{
  try
  {
    var control = this.windowObj.FindChild("className", 'form-control', MAX_CHILDS);
    if (!control || !control.Exists)
    {
      Log.Error("Find input box could not be found!");
      return;
    }

    return control.value;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Sort Remove From Preference
TDMonitor.prototype.verifyRemoveSort = function(column1, column2)
{
  try
  {
    var prefName = "Sorting";
    var array1 = new Array(column1.UIName, column2.UIName);
    var ascMessage = "long-arrow-alt-up";

    //Use Asc or Desc
    var array2 = new Array("Asc", "Asc");

    //Sort 2 columns using Shift Key
    this.multipleSort(column1.DOMName, "asc", column2.DOMName, "asc");

    //Launch Preferences>Sorting and verify if input column is displayed in RightPane in same order    
    var tdPrefWin = this.verifyRightPaneColumnOrder(column1.DOMName, prefName, array1);
    if (!Reporter.TC_RESULT)
      return;

    //Verify Sort Order in Grid and Preference
    this.verifySortOrderInGridAndPref(tdPrefWin, array2);
    if (!Reporter.TC_RESULT)
      return;

    //Moves all columns to Left
    tdPrefWin.moveColumnLeftOrRight("Move Left All");
    if (!Reporter.TC_RESULT)
      return;

    //Click Apply
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;

    //Click Save
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;

    var sortedColumns = this.getAllSortedColumnsInGrid();
    if (!Reporter.TC_RESULT)
      return;

    if (sortedColumns.length == 0)
      vCheckpoint("Sorting removed from grid after clearing sorting from Preference!");
    else
      Log.Error("Sorting not removed from grid after clearing sorting from Preference!");
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

//Verifies if column is pinned in grid based on pinType provided
//pinType = "left" or "right" or "noPin"
TDMonitor.prototype.isColumnPinnedInGrid = function(column, pinType)
{
  try
  {
    if (pinType == "noPin")
    var elements = this.headerRow.getElementsByClassName("ag-header-viewport");
    else
    var elements = this.headerRow.getElementsByClassName("ag-pinned-" + pinType + "-header");
    if (elements.length > 0)
    {
      var results = arrayOfPropertyValue(elements, "textContent")
    }
    else
    {
      Log.Error("No " + pinType + " pinned columns are found in grid!");
      return;
    }
    if (checkArray(results, "exists", column))
      vCheckpoint("Column [" + column + "] is pinned [" + pinType + "] in grid!");
    else
      Log.Error("Column [" + column + "] is not pinned [" + pinType + "] in grid!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Sort Direction Change 
TDMonitor.prototype.verifySortDirectionChange = function(col)
{
  try
  {
    var column = col.UIName;
    var prefName = "Sorting";
    var ascMessage = "long-arrow-alt-up";
    var descMessage = "long-arrow-alt-down";
    var columnObj = this.getColumnHeader(col.DOMName);
    if (!Reporter.TC_RESULT)
      return;

    //Launch Preferences>Sorting
    var tdPrefWin = this.launchPreferences(col.DOMName, prefName);
    if (!Reporter.TC_RESULT)
      return;

    //Move the column from left to right pane  
    tdPrefWin.moveColumnLeftOrRight("Move Right", col);
    if (!Reporter.TC_RESULT)
      return;

    //Change Sort Direction  
    tdPrefWin.changeSortDirection(col.UIName);
    if (!Reporter.TC_RESULT)
      return;

    //Get Sort Direction 
    var sortDirection = tdPrefWin.getSortDirection(col.UIName);
    if (!Reporter.TC_RESULT)
      return;

    var sort = sortDirection == "Asc" ? ascMessage : descMessage;

    //Click Apply
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;

    //Click Save
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;

    //Verify Sort direction in Grid
    if (columnObj.OuterHTML.indexOf(sort) >= 0)
      vCheckpoint("Sorting column and sorting direction for column [" + column + "] are same as selection made in Preference window!");
    else
      Log.Error("Sorting column and sorting direction for column [" + column + "] are not same as selection made in Preference window!");
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

//Verify column order in Right Pane of Preference
TDMonitor.prototype.verifyRightPaneColumnOrder = function(column, prefName, array1)
{
  try
  {
    var tdPrefWin = this.launchPreferences(column, prefName);
    if (!Reporter.TC_RESULT)
      return;

    if (compareValuesInArray(arrayReturnsStringAfterSplit(tdPrefWin.getColumnNameFromRightPane(), "."), array1))
    {
      vCheckpoint("For Preferences>" + prefName + ", values in Right Pane are of same order as order of action performed in grid!");
      return tdPrefWin;
    }
    else
      Log.Error("For Preferences>" + prefName + ", values in Right Pane are of different order as order of action performed in grid!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Sort order in Right Pane of Preference
TDMonitor.prototype.verifySortOrderInGridAndPref = function(tdPrefWin, array1)
{
  try
  {
    if (compareValuesInArray(tdPrefWin.getSortingOrderFromRightPane(), array1))
      vCheckpoint("For Preferences>Sorting, sorting order in Right Pane are same as of in grid!");
    else
      Log.Error("For Preferences>Sorting, sorting order in Right Pane are not same as of in grid!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Close Find Box
TDMonitor.prototype.closeFindBox = function()
{
  try
  {
    var control = this.returnFindWindowControls("times");
    if (!Reporter.TC_RESULT)
      return;
    if (!control || !control.Exists)
    {
      Log.Error("Find box could not be found!");
      return;
    }
    vClickAction(control, 'Click');
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Rename Column In Grid and verifies it
TDMonitor.prototype.renameColumn = function(column, strValue)
{
  try
  {
    this.cefRightClickSelectMenu(this.getColumnHeader(column), this.windowObj, "Rename");
    if (!Reporter.TC_RESULT)
      return;

    var cellContainer = this.headerContainer.FindChild(new Array("ObjectType", "className", "textContent"), new Array('Panel', 'ag-cell-label-container', this.getUIColumnNameFromFullColumn(column)), MAX_CHILDS);
    if (!cellContainer || !cellContainer.Exists)
    {
      Log.Error("Cell Container for column " + column + " could not be found!");
      return;
    }
    vClickAction(cellContainer, 'Click');
    
    vClearControl(cellContainer);
    if (!Reporter.TC_RESULT)
      return;
      
    vSetText(cellContainer, strValue);
    if (!Reporter.TC_RESULT)
      return;
      
    cellContainer.Keys("[Enter]");
    if (!Reporter.TC_RESULT)
      return;

    return this.getUIColumnNameFromFullColumn(column) == strValue ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Scale Factor in Grid
TDMonitor.prototype.verifyScaleFactor = function(column, initialColValuesArray, scale)
{
  try
  {
    var after = new Array();
    for (i = 0; i < initialColValuesArray.length; i++)
    {
      var value = scaleFactor(initialColValuesArray[i], scale);
      after.push(value);
    }
    return (compareValuesInArray((this.getColumnValues(column)).sort(), after.sort(), "numeric")) ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Decimal Places in Grid
TDMonitor.prototype.verifyDecimalPlacesInGrid = function(column, initialColValuesArray, decimal)
{
  try
  {
    for (i = 0; i < initialColValuesArray.length; i++)
    {
      var value = getDecimalPlaces(initialColValuesArray[i]);
      if (areNumericValuesEqual(value, decimal) == false)
        Log.Error("Decimal Place : " + decimal + " not applied to Column " + column + "!");
    }
    vCheckpoint("Decimal Place : " + decimal + " applied to Column " + column + "!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Thousands Seperator in Grid
TDMonitor.prototype.verifyThousandsSeperator = function(column, initialColValuesArray)
{
  try
  {
    var after = new Array();
    for (i = 0; i < initialColValuesArray.length; i++)
    {
      var value = thousandSeperator(initialColValuesArray[i])
      after.push(value);
    }
    if (compareValuesInArray((this.getColumnValues(column)).sort(), after.sort()))
      vCheckpoint("Thousands Seperator applied to Column " + column + "!");
    else
      Log.Error("Thousands Seperator not applied to Column " + column + "!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Sets Scale Factor, Thousands Seperator and Decimal Places in Preferences and verifies in Grid
TDMonitor.prototype.verifyScaleFactorThousandsSeperatorDecimalPlaces = function(column1, column2)
{
  try
  {
    //Get initial grid values
    var initialColumn1 = this.getColumnValues(column1);
    if (!Reporter.TC_RESULT)
      return;

    //Launch Preferences
    var tdPrefWin = this.launchPreferences(column1, "Columns");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickColumnNameInPane(this.getUIColumnNameFromFullColumn(column1));
    if (!Reporter.TC_RESULT)
      return;
      
    //Scroll Preferences window down
    var prefWindow = tdPrefWin.contentPanel.FindChildByXPath("//div[@class='group-box vert-scrollable-area vh-100 pr-3 pl-3' and .//label[@for = 'fieldId']]");
    tdPrefWin.scroll(prefWindow, "DOWN", prefWindow.Height / 2);
    if (!Reporter.TC_RESULT)
      return;
      
    var scaleToVerify = tdPrefWin.getTexBoxValue("Scale Factor");
    if (!Reporter.TC_RESULT)
      return;

    Delay(500);

    //Set Scale Factor for Column1
    tdPrefWin.selectFromGridPreferencesDropDown("Scale Factor", 1000000);
    if (!Reporter.TC_RESULT)
      return;
      
    //Save Changes
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;

    if (this.verifyScaleFactor(column1, initialColumn1, 1000000 / scaleToVerify))
      vCheckpoint("Scaling Factor : 10000 applied to Column " + column1 + "!");
    else
      Log.Error("Scaling Factor : 10000 not applied to Column " + column1 + "!");

    var initialColumn2 = this.getColumnValues(column2);
    if (!Reporter.TC_RESULT)
      return;
      
    var tdPrefWin = this.launchPreferences(column1, "Columns");
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.clickColumnNameInPane(this.getUIColumnNameFromFullColumn(column1));
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.scroll(prefWindow, "DOWN", prefWindow.Height / 2);
    if (!Reporter.TC_RESULT)
      return;

    Delay(500);
      
    //Set Decimal Places for Column1
    tdPrefWin.incDecInGridPreferences("Decimal Places", 5);
    if (!Reporter.TC_RESULT)
      return;
      
    //Apply Changes
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;

    //Select Column2
    tdPrefWin.clickColumnNameInPane(this.getUIColumnNameFromFullColumn(column2));
    if (!Reporter.TC_RESULT)
      return;
      
    tdPrefWin.scroll(prefWindow, "DOWN", prefWindow.Height / 2);
    if (!Reporter.TC_RESULT)
      return;

    Delay(500);
      
    //Set Thousand's Seperator for Column2
    tdPrefWin.switchOnControl("Thousands Separator (,)");
    if (!Reporter.TC_RESULT)
      return;
      
    //Save Changes
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;
      
    initialColumn1 = this.getColumnValues(column1);
    if (!Reporter.TC_RESULT)
      return;
      
    this.verifyDecimalPlacesInGrid(column1, initialColumn1, 5);
    if (!Reporter.TC_RESULT)
      return;
      
    this.verifyThousandsSeperator(column2, initialColumn2);
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

//bookmarkType - row or column; number (1 to 9)
TDMonitor.prototype.addBookmark = function(grid, rowIndex, columnDOMName, bookmarkType, number)
{
  try
  {
    var cell = this.getCEFCell(grid, rowIndex, columnDOMName);
    if (!Reporter.TC_RESULT)
      return;
      
    vClickAction(cell, 'Click');
    if (!Reporter.TC_RESULT)
      return;
       
    if (bookmarkType == "row")
    {
      LLPlayer.KeyDown(VK_LCONTROL, 1000);
      LLPlayer.KeyDown(eval("VK_NUMPAD" + number +""), 1000);
      LLPlayer.KeyUp(eval("VK_NUMPAD" + number +""), 3000);
      LLPlayer.KeyUp(VK_LCONTROL, 1000);
    }
     
    else if (bookmarkType == "column")
    {
      LLPlayer.KeyDown(VK_MENU, 1000);
      LLPlayer.KeyDown(eval("VK_NUMPAD" + number +""), 1000);
      LLPlayer.KeyUp(eval("VK_NUMPAD" + number +""), 3000);
      LLPlayer.KeyUp(VK_MENU, 1000);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//rowIndex starts from 0
TDMonitor.prototype.isRowHighlighted = function(grid, rowIndex)
{
  try
  {
    var className = this.getAttribute(grid, rowIndex, "class");
    if (!Reporter.TC_RESULT)
      return;
    
    if (className.indexOf("ag-row-focus") >= 0)  
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getHexColorCode = function(colorName)
{
  try
  {
    switch (colorName)
    {
      case "DarkGray":
        return "#FF839496";

      case "LightGray":  
        return "#FF93A1A1";

      case "Beige":
        return "#FFEEE8D5";

      case "Yellow":  
        return "#FFFFC107";

      case "Orange":  
        return "#FFFD7E14";

      case "Red":  
        return "#FFFF0000";

      case "Pink":  
        return "#FFE83E8C"; 

      case "Purple":  
        return "#FF6F42C1"; 

      case "Blue":  
        return "#FF0DBDFF"; 

      case "Teal":
        return "#FF17A2B8";

      case "Green":  
        return "#FF20C997";

      case "Black":
        return "#FF000000";

      case "None":
        return "#00FFFFFF"; 

      case "DarkestGray":  
        return "#FF343A40";
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getRGBColorCode = function(colorName)
{
  try
  {
    switch (colorName)
    {
      case "DarkGray":
        return "rgb(131, 148, 150)";
        
      case "LightGray":  
        return "rgb(147, 161, 161)";
        
      case "Beige":  
        return "rgb(238, 232, 213)";
        
      case "Yellow":  
        return "rgb(255, 193, 7)";
        
      case "Orange":  
        return "rgb(253, 126, 20)";
        
      case "Red":  
        return "rgb(255, 0, 0)";
        
      case "Pink":  
        return "rgb(232, 62, 140)"; 
   
      case "Purple":  
        return "rgb(111, 66, 193)";
        
      case "Blue":  
        return "rgb(13, 189, 255)"; 
        
      case "Teal":
        return "rgb(23, 162, 184)";
        
      case "Green":
        return "rgb(32, 201, 151)";
      
      case "Black":
        return "rgb(0, 0, 0)";
        
      case "None":
        return "rgb(255, 255, 255)"; 
        
      case "DarkestGray":  
        return "rgb(52, 58, 64)";                      
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getCEFRow = function(grid, rowIndex)
{
  try
  {
    var rowsContainer = grid.FindChild("className", 'ag-center-cols-viewport', MAX_CHILDS);
    var row = rowsContainer.FindChildByXPath("//*[@row-index='" + rowIndex + "']");
    if (row && row.Exists)
      return row;
    else
      Log.Error("Row does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.selectFromDropDown = function(comboBox, value)
{
  try
  {
    vClickAction(comboBox, 'Click');

    var itemToSelect = comboBox.parent.FindChild(new Array("ObjectType", "textContent"), new Array('Panel', value), MAX_CHILDS);
    if (itemToSelect.Exists)
      vClickAction(itemToSelect, 'Click');
    else
    {
      Log.Error("Dropdown item (" + value + ") does not exist!");
      vClickAction(comboBox, 'Click');
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Choose Clone or Share View
//property = "clone" or "share"
TDMonitor.prototype.clickCloneOrShareView = function(property)
{
  try
  {

    var propertiesButton = this.monitorWindow.FindChild("Name", 'Button("showPropertiesButton")', MAX_CHILDS);
    if (!propertiesButton || !propertiesButton.Exists)
    {
      Log.Error("Properties button not be found!");
      return;
    }
    vClickAction(propertiesButton, "Click");
    var dropdown = tdElectronServerProcess.FindChild("Name", 'Window("Chrome_WidgetWin_2", "", *)', MAX_CHILDS);
    if (!dropdown || !dropdown.Exists)
    {
      Log.Error("Drop down not displayed when " + property + " is clicked!");
      return;
    }
    var destY = property == "clone" ? dropdown.height / 4 : dropdown.height / 2;
    vClickCoordinates(dropdown, dropdown.width / 2, destY);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Double click on Cell and it turns to a text box. Applicable for Edit Functionality
TDMonitor.prototype.returnTextBoxForACell = function(cell)
{
  try
  {
    vClickAction(cell, 'DoubleClick');
    var textBox = cell.FindChild("className", 'double-arrow-group', MAX_CHILDS);
    if (!textBox.Exists)
    {
      Log.Error("Cell is not in Edit mode after double click!");
      return;
    }
    else
      return textBox;

  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Inc or Dec Cell value using arrow inside the cell and verifies it
//type = "up" or "down"
TDMonitor.prototype.incDecCellvalue = function(column, rowID, type, count, color)
{
  try
  {
    var cell = this.getCEFCell(this.xDg, rowID, column);
    var cellValue = cell.innerText;
    if (!cell.Exists)
    {
      Log.Error("Cell not be found!");
      return;
    }
    var textBox = this.returnTextBoxForACell(cell);
    var control = cell.FindChildByXPath("//*[@class = 'arrow " + type + " arrow-" + type + "']");
    for (var i = 0; i <= Math.abs(count) - 1; i++)
    {
      vClickAction(control, 'Click');
    }
    vClickAction(textBox, 'Click');
    Delay(200);
    textBox.Keys("[Enter]");

    //Gets the background color of cell
    var style = this.getComputedStyle(cell, "backgroundColor");
    if (!Reporter.TC_RESULT)
      return;

    //Verifies BG color of cell
    if(this.verifyColor(style, color))
      vCheckpoint("Cell Bg is " + color);
    else
      Log.Error("Cell Bg is not "+ color);

    //Verifies inc/dec value  
    if (areNumericValuesEqual(decimalIncDec(type, cellValue, count), (this.getCEFCell(this.xDg, rowID, column)).innerText))
    {
      vCheckpoint("Value [" + type + "] by Count : " + count + " in Column : " + column + " and RowNo : " + rowID + "!");
      return true;
    }
    else
    {
      Log.Error("Value not [" + type + "] by Count : " + count + " in Column : " + column + " and RowNo : " + rowID + "!");
      return false;
    }

  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verifies color with the value provided
//Applicable for BG Color, Cell Border color etc
TDMonitor.prototype.verifyColor = function(style, color)
{
  try
  {
    switch (color)
    {
      case "green":
        return (areColorArraysSame(getRGB(style), getRGB("rgb(1, 205, 1)"))) ? true : false;

      case "black":
        return (areColorArraysSame(getRGB(style), getRGB("rgb(0, 0, 0)"))) ? true : false;

      case "grey":
        return (areColorArraysSame(getRGB(style), getRGB("rgb(64, 64, 64)"))) ? true : false;

      case "orange":
        return (areColorArraysSame(getRGB(style), getRGB("rgb(203, 96, 21)"))) ? true : false;

      case "white":
        return (areColorArraysSame(getRGB(style), getRGB("rgb(255, 255, 255)"))) ? true : false;

      default:
        return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Check if option is active/disabled in context menu in Grid
//criteria = "active" or "disabled"
TDMonitor.prototype.isOptionEnabledInContextMenu = function(column, rowId, menu, criteria, extendedMenu)
{
  try
  {
    if ((this.isOptionAvailableInContextMenu(rowId, column, menu)).Exists == true)
    {
      var menuHndl = (this.isOptionAvailableInContextMenu(rowId, column, menu)).menuHndl;
      if (!extendedMenu || extendedMenu == undefined)
      {
        menuHndl.HoverMouse();
        Delay(300);
        return menuHndl.getAttribute("class").indexOf(criteria) > 0 ? true : false;
      }
      else
      {
        vClickAction(menuHndl, 'Click');
        var extendedMenuHndl = (this.windowObj.FindChild(new Array("Name", "textContent"), new Array('TextNode("eName")', extendedMenu), MAX_CHILDS)).parent;
        Delay(300);
        extendedMenuHndl.HoverMouse();
        if (!extendedMenuHndl || !extendedMenuHndl.Exists)
        {
          Log.Error("Extended Menu not opened!");
          return;
        }
        return extendedMenuHndl.getAttribute("class").indexOf(criteria) > 0 ? true : false;
      }
    }
    else
      Log.Error("Menu option " + menu + " not found in context menu!");
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClickAction(this.getColumnHeader(column), 'Click');
  }
}

//Returns true if option is available in the context menu
TDMonitor.prototype.isOptionAvailableInContextMenu = function(rowId, column, menu)
{
  try
  {
    var firstRowIdCell = this.getCEFCell(this.xDg, rowId, column);
    if (!Reporter.TC_RESULT)
      return;

    vClickAction(firstRowIdCell, 'RightClick');
    Delay(500);

    var menuList = this.windowObj.FindChild("className", "ag-menu-list", MAX_CHILDS);
    if (!menuList.Exists)
    {
      Log.Error("Menu not opened!");
      return;
    }
    var menuHndl = menuList.FindChild(new Array("className", "contentText"), new Array("ag-menu-option*", menu), MAX_CHILDS);
    var Exists = menuHndl.Exists ? true : false;
    return {
      Exists: Exists,
      menuHndl: menuHndl
    };

  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify Revert Current
TDMonitor.prototype.verifyRevertCurrent = function(column1, column2, rowId)
{
  try
  {
    var cell1 = this.getCEFCell(this.xDg, rowId, column1);
    if (!Reporter.TC_RESULT)
      return;

    var originalValue = cell1.innerText;

    var cell2 = this.getCEFCell(this.xDg, rowId, column2);
    if (!Reporter.TC_RESULT)
      return;

    var textBox = this.returnTextBoxForACell(cell1);

    vClearControl(textBox);
    vSetText(textBox, Math.abs(cell2.innerText) + 1);
    textBox.Keys("[Enter]");
    Delay(100);

    if (!cell1.getAttribute("class").indexOf("invalid-commit") > 0)
      Log.Error("Invalid Commit not performed!");
    else
    {
      vCheckpoint("Invalid Commit and value is not updated!");
      this.cefRightClickSelectMenu(cell1, this.windowObj, "Revert", "Revert Current");
      if (!Reporter.TC_RESULT)
        return;

      if ((this.getCEFCell(this.xDg, rowId, column1)).innerText == originalValue)

        vCheckpoint("Value reverted back to original value!");
      else
        Log.Error("Invalid, Commit not performed!");
    }

  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Tooltip from cell. Applicable for Edit Functionality
TDMonitor.prototype.returnToolTip = function(cell)
{
  try
  {
    return getPropertyOfObject(cell, "title");
  }
  catch (e)
  {
    Log.Error(e, "returnToolTip");
  }
}

//Red Outline and Background color validations to be added
//Performs and verifies Manual Mode InValid Data Tootip/Revert Current/Revert All
TDMonitor.prototype.verifyManualModeInValidDataRevertCurrentRevertAll = function(column1, column2)
{
  try
  {
    //Change to Manual Mode 
    this.cefRightClickSelectMenu(this.getCEFCell(this.xDg, 0, column1), this.windowObj, "Enable Manual Commit");
    if (!Reporter.TC_RESULT)
      return;

    //Capture Big Spread Value
    var bigCellValue = getPropertyOfObject(this.getCEFCell(this.xDg, 0, column2), "innerText");
    if (!Reporter.TC_RESULT)
      return;

    //Capture Small Spread Value
    var smallCellValue = getPropertyOfObject(this.getCEFCell(this.xDg, 0, column1), "innerText");
    if (!Reporter.TC_RESULT)
      return;

    //Edit Big Spread 
    var beforeEditValue = getPropertyOfObject(this.getCEFCell(this.xDg, 3, column2), "innerText");
    if (!Reporter.TC_RESULT)
      return;

    this.incDecCellvalue(column2, 3, "up", 1, "grey");
    if (!Reporter.TC_RESULT)
      return;

    var editedValue = getPropertyOfObject(this.getCEFCell(this.xDg, 3, column2), "innerText");
    if (!Reporter.TC_RESULT)
      return;

    //Edit Small spread with value greater than Big Spread
    var textBox = this.returnTextBoxForACell(this.getCEFCell(this.xDg, 0, column1));
    if (!Reporter.TC_RESULT)
      return;

    vClearControl(textBox);
    vSetText(textBox, Math.abs(bigCellValue + 1));
    textBox.Keys("[Enter]");
    vCheckpoint("Small Spread Increment edited with value greater than Big Spread Increment!");
    Delay(100);

    if (this.returnToolTip(this.getCEFCell(this.xDg, 0, column1)) == "Validation failed. Please input a valid value" && this.isOptionEnabledInContextMenu(column2, 0, "Commit", "disabled"))
      vCheckpoint("[Validation failed. Please input a valid value] Tool Tip is displayed and [Commit] is disabled in Context menu!");
    else
    {
      Log.Error("[Validation failed. Please input a valid value] Tool Tip is not displayed or [Commit] is not disabled in Context menu!");
      return;
    }

    //Revert Current from the Incorrect cell and verify if original value is retained only for that cell
    this.cefRightClickSelectMenu(this.getCEFCell(this.xDg, 0, column1), this.windowObj, "Revert", "Revert Current");
    if (areNumericValuesEqual(smallCellValue, getPropertyOfObject(this.getCEFCell(this.xDg, 0, column1), "innerText")) && areNumericValuesEqual(editedValue, getPropertyOfObject(this.getCEFCell(this.xDg, 3, column2), "innerText")) && this.isOptionEnabledInContextMenu(column2, 0, "Commit", "active"))
      vCheckpoint("After [Revert Current] on incorrect cell, only that cell value is reverted, other changes made on grid remain and [Commit] is active in context menu!");
    else
    {
      Log.Error("After [Revert Current] on incorrect cell, cell value is not reverted or other changes made on grid has changed or [Commit] is not active in context menu!");
      return;
    }

    //Revert All and verify if other changes are reverted to original values
    this.cefRightClickSelectMenu(this.getCEFCell(this.xDg, 0, column1), this.windowObj, "Revert", "Revert All");
    if (areNumericValuesEqual(getPropertyOfObject(this.getCEFCell(this.xDg, 3, column2), "innerText"), beforeEditValue) && !((this.isOptionAvailableInContextMenu(0, column2, "Commit")).Exists) && !((this.isOptionAvailableInContextMenu(0, column2, "Revert")).Exists))
      vCheckpoint("After [Revert All], all changes in grid are reverted to original values, [Commit] and [Revert] options are no more available in context menu!");
    else
    {
      Log.Error("After [Revert All], all changes in grid are not reverted to original values or [Commit] and [Revert] options are still available in context menu!");
      return;
    }
  }
  catch (e)
  {
    Log.Error(e, "verifyManualModeRevertCommit");
  }
}

//Get cell value
TDMonitor.prototype.getCellValue = function(column, rowId)
{
  try
  {
    return getPropertyOfObject(this.getCEFCell(this.xDg, rowId, column), "innerText");
  }
  catch (e)
  {
    Log.Error(e, "getCellValue");
  }
}

//Returns an array containing all the row values for a given column name
TDMonitor.prototype.getCEFColumnValues = function(grid, colName)
{
  try
  {
    var rowCount = this.rowContainer.getElementsByClassName("ag-row");
    rowCount = rowCount.length;
    if (rowCount > 0)
    {
      var values = new Array();
      for (var i = 0; i < rowCount; i++)
      {
        var value = this.getCEFCellValue(grid, i, colName);
        if (value)
          values.push(value);
        else
          values.push("");
      }
      return values;
    }
  }
  catch (e)
  {
    Log.Error(e, "getCEFColumnValues");
  }
}

//Hide a column in Grid from Preferences>Display
TDMonitor.prototype.hideColumnFromPreference = function(column)
{
  try
  {
    //Launch Preferences>Display
    var tdPrefWin = this.launchPreferences(column.DOMName, "Display");
    if (!Reporter.TC_RESULT)
      return;

    //Click on Move Left
    tdPrefWin.moveColumnLeftOrRight("Move Left", column);
    if (!Reporter.TC_RESULT)
      return;

    //Click Save in Grid Preferences
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;
      
    if (this.isColumnAvailableInHeader(column.UIName) == false)
      vCheckpoint("Column : " + column.UIName + " hidden from Grid!");
    else
      Log.Error("Column : " + column.UIName + " not hidden from Grid!");
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

TDMonitor.prototype.openQuickFilter = function(grid, columnDOMName, windowObj)
{
  try
  {
    var column = this.getCEFCell(grid, 0, columnDOMName);
    if (!Reporter.TC_RESULT)
      return;
      
    this.cefRightClickSelectMenu(column, windowObj, "Filter", "Show Quick Filter");  
    Delay(1000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Applicable when quickFilter Row is open in a grid
TDMonitor.prototype.getColumnIndex = function(grid, columnNameUI)
{
  try
  {
    var headerRow = grid.EvaluateXPath("//*[@class='ag-header-container']//child::*[@class='ag-header-row']");
    var headerRowIndex = headerRow.toArray().length -1;
    var headerRow = grid.FindChildByXPath("//*[@class='ag-header-container']//child::*[@class='ag-header-row']["+headerRowIndex+"]")
    var columns = headerRow.getElementsByClassName("ag-header-cell-text");

    for (i = 0 ; i < columns.length ; i++)
    {
      if (columns[i].innerText==columnNameUI)
        return(i+1);
    }
    Log.Error("Column with name "+columnNameUI+" not found!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.setQuickFilterValue = function(grid, columnNameDOM, value, columnNameUI)
{
  try
  {
    Delay(1000);
    var columnIndex = this.getColumnIndex(grid, columnNameUI);
    if (!Reporter.TC_RESULT)
      return;

    var quickFilter = grid.FindChildByXPath("//div[@col-id='" + columnNameDOM + "']//following::*[@class='ag-header-cell'][" + columnIndex + "]//child::*[@type='text']");
    if (!Reporter.TC_RESULT)
      return;
       
    if (quickFilter && quickFilter.Exists)
    {
      quickFilter.SetText(value);
      Delay(1000);
    }  
    else
      Log.Error("Quick Filter object for column "+columnNameUI+" not found!");  
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.setQuickFilterValueForFilterConditions = function(grid, columnNameDOM, value, columnNameUI)
{
  try
  {
    Delay(1000);
    var columnIndex = this.getColumnIndex(grid, columnNameUI);
    if (!Reporter.TC_RESULT)
      return;

    var quickFilter = grid.FindChildByXPath("//div[@col-id='" + columnNameDOM + "']//following::*[@class='ag-header-cell'][" + columnIndex + "]//child::*[@type='text']");
    if (!Reporter.TC_RESULT)
      return;
      
    vClickAction(quickFilter, 'Click');
    if (!Reporter.TC_RESULT)
      return;
      
    var quickFilter = grid.FindChildByXPath("//div[@col-id='" + columnNameDOM + "']//following::*[@class='ag-header-cell'][" + columnIndex + "]//child::*[@type='text']");
    if (!Reporter.TC_RESULT)
      return;  
      
    if (quickFilter && quickFilter.Exists)
    {
      quickFilter.SetText(value);
      Delay(1000);
    }  
    else
      Log.Error("Quick Filter object for column "+columnNameUI+" not found!");  
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.clearQuickFilter = function(grid, columnNameDOM, columnNameUI)
{
  try
  {
    var columnIndex = this.getColumnIndex(grid, columnNameUI);
    if (!Reporter.TC_RESULT)
      return;
    
    var clearFilter = grid.FindChildByXPath("//div[@col-id='"+columnNameDOM+"']//following::*[@class='ag-header-cell']["+columnIndex+"]//child::*[@type='text']//following::*[@class='transparent ng-star-inserted']");
    if (clearFilter && clearFilter.Exists)
    {
      vClickAction(clearFilter, 'Click');
      Delay(1000);
    } 
    else
      Log.Error("Clear Filter object for column "+columnNameUI+" not found!");   
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.openColumnFilter = function(grid, columnNameDOM, columnNameUI)
{
  try
  {  
    var columnIndex = this.getColumnIndex(grid, columnNameUI);
    if (!Reporter.TC_RESULT)
      return;

    var quickFilter = grid.FindChildByXPath("//div[@col-id='" + columnNameDOM + "']//following::*[@class='ag-header-cell'][" + columnIndex + "]//child::*[@type='text']");
    if (!Reporter.TC_RESULT)
      return;
    
    var input = this.getStringCellFirstChar(columnNameDOM);
    if (!Reporter.TC_RESULT)
      return;
         
    quickFilter.SetText(input);
    if (!Reporter.TC_RESULT)
      return;
    
    Delay(1000);      
    var filterMenuBtn = grid.FindChildByXPath("//div[@col-id='"+columnNameDOM+"']//following::*[@class='ag-header-cell']["+columnIndex+"]//child::*[@type='text']//following::*[@data-icon='chevron-down']");
    if (!Reporter.TC_RESULT)
      return;  
         
    vClickAction(filterMenuBtn, 'Click');
    Delay(1000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.checkUncheckFilterOption = function(value)
{
  try
  {  
    var list = Aliases.Citi_TD_ElectronWindowServer.FindChild("className", 'virtual-list-viewport', MAX_CHILDS);
    if (!Reporter.TC_RESULT)
      return;
  
    if (list && list.VisibleOnScreen)
      vCheckpoint("Multi-select list is visible after clicking on down arrow!");
    else
      Log.Error("Multi-select list is not visible after clicking on down arrow");
      
    var control = list.FindChildByXPath("//*[@class='filter-value'][@title='"+value+"']/preceding-sibling::*[@class='checkbox']");
    if (!Reporter.TC_RESULT)
      return;  
         
    vClickAction(control, 'Click');
    Delay(500);
    vClickAction(this.windowObj, 'Click');
    Delay(500);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.openCloseQuickFilterUsingShortcutKeys = function(grid, columnDOMName)
{
  try
  {
    var cell = this.getCEFCell(grid, 0, columnDOMName);
    if (!Reporter.TC_RESULT)
      return;
  
    vClickAction(cell, 'Click');
    if (!Reporter.TC_RESULT)
      return;
    
    /*LLPlayer.KeyDown(VK_MENU, 1000);
    LLPlayer.KeyDown(0x46, 1000);
    LLPlayer.KeyUp(0x46, 3000);
    LLPlayer.KeyUp(VK_MENU, 1000);
    Delay(1000);*/
    
    cell.Keys("~f");
    Delay(1000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.isFilterAsteriskVisibleOnColumnHeader = function(columnDOMName)
{
  try
  {
    var header = this.getColumnHeader(columnDOMName);
    if (!Reporter.TC_RESULT)
      return;
      
    return header.getAttribute("class").indexOf("ag-header-cell-filtered") > 0 ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.clearFilter = function(columnDOMName)
{
  try
  {
    var statusBar = this.windowObj.FindChild("className", 'ag-status-bar-right', MAX_CHILDS);
    var coloumnUIName = this.getUIColumnNameFromFullColumn(columnDOMName);
    var control = statusBar.FindChildByXPath("//span[@class='ng-star-inserted'][contains(text(), '" + coloumnUIName + "')]/button");
    if (!control || !control.Exists)
    {
      Log.Error("Filter " + coloumnUIName + " could not be found!");
      return;
    }
    vClickAction(control, 'Click');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.isFilterBarVisible = function()
{
  try
  {
    var control = this.xDg.FindChildByXPath("//*[@containerclass='filter-tooltip']//ancestor::*[@class='ag-header-row']");
    return control && control.VisibleOnScreen ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getTotalRowsCountVisibleInGrid = function(grid, columnDOMName)
{
  try
  {
    var control = grid.EvaluateXPath("//*[@role='gridcell'][@col-id='"+columnDOMName+"']");
    return (control.toArray()).length;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Launch Preference from a Grid and Set Scale Factor
TDMonitor.prototype.launchPrefAndSetScaleFactor = function(DOMColumnName, gridObject, scaleFactor)
{
  try
  {
    //Launch Preferences and select a different scale factor for Grid1
    var tdPrefWin = gridObject.launchPreferences(DOMColumnName, "Columns");
    if (!Reporter.TC_RESULT)
      return;

    tdPrefWin.clickColumnNameInPane(gridObject.getUIColumnNameFromFullColumn(DOMColumnName));
    if (!Reporter.TC_RESULT)
      return;

    //Scroll Preferences window down
    var prefWindow = tdPrefWin.contentPanel.FindChildByXPath("//div[@class='group-box vert-scrollable-area vh-100 pr-3 pl-3' and .//label[@for = 'fieldId']]");
    tdPrefWin.scroll(prefWindow, "DOWN", prefWindow.Height / 2);
    if (!Reporter.TC_RESULT)
      return;

    //Set Scale Factor for Column1
    tdPrefWin.selectFromGridPreferencesDropDown("Scale Factor", scaleFactor);
    if (!Reporter.TC_RESULT)
      return;

    vCheckpoint("Scale Factor : " + scaleFactor + " is set for Column : " + DOMColumnName +" in Grid!");

    //Save Changes
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    vClose(tdPrefWin);
  }
}

//Performs Conflict Resolution for option = [Take Local Version:*] / [Take Server Version:*]
TDMonitor.prototype.performConflictResolution = function(column1, gridObject1, gridObject2, option, scaleFactor1, scaleFactor2)
{
  try
  {
    //Get Cell from Grid 1
    var cell1 = gridObject1.getCEFCell(gridObject1.xDg, 0, column1);
    if (!Reporter.TC_RESULT)
      return;

    //Get Cell from Grid 2
    var cell2 = gridObject2.getCEFCell(gridObject2.xDg, 0, column1);
    if (!Reporter.TC_RESULT)
      return;

    //Change value in Grid 1
    gridObject1.incDecCellvalue(column1, 0, "up", 1, "grey");
    if (!Reporter.TC_RESULT)
      return;

    //Change value in Grid 2     
    gridObject2.incDecCellvalue(column1, 0, "down", 6, "grey");
    if (!Reporter.TC_RESULT)
      return;

    //Select Commit in Grid 1
    gridObject1.cefRightClickSelectMenu(gridObject1.getCEFCell(gridObject1.xDg, 0, column1), gridObject1.windowObj, "Commit");
    if (!Reporter.TC_RESULT)
      return;

    //Verify if Cell BG color changes to Green in Grid 1's cell 
    gridObject1.verifyColor(gridObject1.getComputedStyle(cell1, "backgroundColor"), "green");
    if (!Reporter.TC_RESULT)
      return;

    //Verify if cell border changes to Orange in Grid 2's cell
    if (gridObject2.verifyColor(gridObject2.getComputedStyle(cell2, "outline-color"), "orange"))
      vCheckpoint("In Grid2 Cell Border is highlighted in Orange!");
    else
      Log.Error("In Grid2 Cell Border is not highlighted in Orange!");

    //Verify if options are enabled/disabled in Grid 2's conflict cell
    if (gridObject2.isOptionEnabledInContextMenu(column1, 0, "Commit", "disabled") && gridObject2.isOptionEnabledInContextMenu(column1, 0, "Resolve Conflict", "active") && gridObject2.isOptionEnabledInContextMenu(column1, 0, "Resolve Conflict", "active", "Take Local Version:*") && gridObject2.isOptionEnabledInContextMenu(column1, 0, "Resolve Conflict", "active", "Take Server Version:*"))
      vCheckpoint("In Grid 2, commit option is diabled, Resolve Conflict/Take Local Version/Take Server Version are available and enabled!");
    else
      Log.Error("In Grid2 Cell Border is not highlighted in Orange!");

    //Verify if Cell highlighting is removed and Commit option is enabled after [option] is clicked
    gridObject2.cefRightClickSelectMenu(gridObject2.getCEFCell(gridObject2.xDg, 0, column1), gridObject2.windowObj, "Resolve Conflict", option);
    if (!Reporter.TC_RESULT)
      return;

    var cellValue1 = gridObject1.getCellValue(column1, 0);
    if (!Reporter.TC_RESULT)
      return;

    var cellValue2 = gridObject2.getCellValue(column1, 0);
    if (!Reporter.TC_RESULT)
      return;

    if (option == "Take Local Version:*")
    {
      if (gridObject2.verifyColor(gridObject2.getComputedStyle(cell2, "outline-color"), "white") && gridObject2.isOptionEnabledInContextMenu(column1, 0, "Commit", "active"))
        vCheckpoint("After " + option + " is selected, Cell Highlighting is removed and [Commit] is enabled!");
      else
        Log.Error("After " + option + " is selected, Cell Highlighting is not removed or [Commit] is not enabled!");

      //Click on Commit
      gridObject2.cefRightClickSelectMenu(gridObject2.getCEFCell(gridObject2.xDg, 0, column1), gridObject2.windowObj, "Commit");
      if (!Reporter.TC_RESULT)
        return;
    }
    
    var cellToVerify = (option == "Take Local Version:*") ? cellValue2 : cellValue1;

    if (!scaleFactor1 || scaleFactor1 == undefined || scaleFactor1 == null)
    {
      if (gridObject1.getCellValue(column1, 0) == cellToVerify && gridObject2.getCellValue(column1, 0) == cellToVerify)
        vCheckpoint("Value is updated in Grid 1 and Grid 2 after choosing " + option + "!");
      else
        Log.Error("Value is not updated in Grid 1 or Grid 2 after choosing " + option + "!");
    }
    else
    {
      if (option == "Take Local Version:*")
      {
        if (gridObject1.getCellValue(column1, 0) == (Math.round(cellToVerify * 100) / 100) / (scaleFactor2 / scaleFactor1) && gridObject2.getCellValue(column1, 0) == cellToVerify)
          vCheckpoint("Value is updated in Grid 1 and Grid 2 after choosing " + option + "!");
        else
          Log.Error("Value is not updated in Grid 1 or Grid 2 after choosing " + option + "!");
      }
      else if (option == "Tale Server Version:*")
      {
        if (areNumericValuesEqual(gridObject1.getCellValue(column1, 0) * 10, cellToVerify) && gridObject2.getCellValue(column1, 0) == cellToVerify)
          vCheckpoint("Value is updated in Grid 1 and Grid 2 after choosing " + option + "!");
        else
          Log.Error("Value is not updated in Grid 1 or Grid 2 after choosing " + option + "!");
      }
    }
   //Verify if Cell exit Edit Mode for Server Version
    if (option == "Take Server Version:*")
    {
      if (gridObject2.verifyColor(gridObject2.getComputedStyle(cell2, "outline-color"), "white") && areColorArraysSame(getRGB(gridObject2.getComputedStyle(cell2, "backgroundColor")), getRGB(gridObject2.getRGBColorCode("Black"))))
        vCheckpoint("Cell in Grid 2 exit Edit mode!");
      else
        Log.Error("Cell in Grid 2 did not exit Edit mode!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Edit cell by entering value
TDMonitor.prototype.editCellEnterValue = function(columnDOMName, rowId, value)
{
  try
  {
    //Get Cell
    var cell = this.getCEFCell(this.xDg, rowId, columnDOMName);
    if (!cell.Exists)
    {
      Log.Error("Cell not found in " + columnDOMName + " column!");
      return;
    }
    //Get into Textbox mode
    var textBox = this.returnTextBoxForACell(cell);
    if (!Reporter.TC_RESULT)
      return;

    //Clear and set new value    
    vClearControl(textBox);
    vSetText(textBox, Math.abs(value));
    textBox.Keys("[Enter]");
    Delay(200);
    
    if (areNumericValuesEqual(value, this.getCellValue(columnDOMName, rowId)))
      vCheckpoint("Cell edited with entering new value : " + value + "!");
    else
      Log.Error("Cell not edited with entering new value" + value + "!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Edit Cell from Keyboard +/-
//eg: count = 1 to inc or -1 to dec 1 
TDMonitor.prototype.editCellFromKeyboard = function(columnDOMName, rowId, count)
{
  try
  {
    //Get Cell
    var cell = this.getCEFCell(this.xDg, rowId, columnDOMName);
    if (!cell.Exists)
    {
      Log.Error("Cell not found in " + columnDOMName + " column!");
      return;
    }
    increaseDecreaseCEFValueUsingKeyboard(cell, count, true);
    if (!Reporter.TC_RESULT)
      return;

    Delay(3500);

    //Returns edited new value after inc/dec
    return aqConvert.StrToFloat(this.getCellValue(columnDOMName, rowId));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verifies if a value is edited as per the count in a cell
TDMonitor.prototype.isCellValueEdited = function(oldValue, count, editedNewValue, decimalFactor)
{
  try
  {
    var value = count > 0 ? decimalIncDec("up", oldValue, count, decimalFactor) : decimalIncDec("down", oldValue, Math.abs(count), decimalFactor);
    Delay(500);
    return areNumericValuesEqual(value, editedNewValue) ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Edits cell 1.By entering value 2.By using keyboard 3.By using up/down arrow
TDMonitor.prototype.editCellByEnterKeyboardArrow = function(row)
{
  try
  {
    //Edit by Entering Value
    //Capture Big Spread Value
    var bigCellValue = aqConvert.StrToFloat(this.getCellValue(row.Column2, 0));
    if (!Reporter.TC_RESULT)
      return;

    //Capture Small Spread Value
    var smallCellValue = aqConvert.StrToFloat(this.getCellValue(row.Column4, 0));
    if (!Reporter.TC_RESULT)
      return;

    //Edit Big Spread Value by entering value
    this.editCellEnterValue(row.Column2, 0, Math.abs(bigCellValue + 0.001));
    if (!Reporter.TC_RESULT)
      return;

    //Edit Small Spread Value by entering value
    this.editCellEnterValue(row.Column4, 0, Math.abs(smallCellValue - 0.001));
    if (!Reporter.TC_RESULT)
      return;

    vCheckpoint("Big Spread and Small Spread Cell values edited with entering new values!");

    //Edit from Keyboard
    //Edit Big Spread value for +
    var oldValue = aqConvert.StrToFloat(this.getCellValue(row.Column2, 1));
    if (!Reporter.TC_RESULT)
      return;

    var editedNewValue = this.editCellFromKeyboard(row.Column2, 1, 1);
    if (!Reporter.TC_RESULT)
      return;

    Delay(2000);

    if (this.isCellValueEdited(oldValue, 1, editedNewValue))
      vCheckpoint("Big Spread Cell value edited with + key in Keyboard for count [2]!");
    else
      Log.Error("Big Spread Cell value not edited with + key in Keyboard");

    //Edit Small Spread value for -
    oldValue = aqConvert.StrToFloat(this.getCellValue(row.Column4, 1));
    if (!Reporter.TC_RESULT)
      return;

    editedNewValue = this.editCellFromKeyboard(row.Column4, 1, -1);
    if (!Reporter.TC_RESULT)
      return;

    Delay(2000);

    if (this.isCellValueEdited(oldValue, -1, editedNewValue))
      vCheckpoint("Small Spread Cell value edited with - key in Keyboard for count [2]!");
    else
      Log.Error("Small Spread Cell value not edited with - key in Keyboard");

    //Edit by arrow inside cell
    this.incDecCellvalue(row.Column2, 3, "up", 1, "green");
    if (!Reporter.TC_RESULT)
      return;
      
    this.incDecCellvalue(row.Column4, 3, "down", 1, "green");
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Selects multiple cells of a column // from - start cell id, to -  end cell id (inclusive)
TDMonitor.prototype.selectMultipleCells = function(columnDOMName, rowIdFrom, rowIdTo)
{
  try
  {
    for (var i = rowIdFrom; i <= rowIdTo; i++)
    {
      vClickAction(this.getCEFCell(this.xDg, i, columnDOMName), 'Click');
      LLPlayer.KeyDown(VK_CONTROL, 200);
    }
    LLPlayer.KeyUp(VK_CONTROL, 200);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Return Bulk Edit Box obj
TDMonitor.prototype.returnBulkEditBox = function()
{
  try
  {
    var box = this.frame.FindChildByXPath("//*[@class='content ng-star-inserted' and .//*[@placeholder='Enter value for selection']]");
    if (!box || !box.Exists)
      return false;
    else
      return box;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Submit/Close Bulk Edit Box
//control = "times" for Close button and control = "arrow-right" for Submit
TDMonitor.prototype.clickOnBulkEditBoxControls = function(control)
{
  try
  {
    var controlObj = this.returnBulkEditBox();
    if (!Reporter.TC_RESULT)
      return;

    controlObj = controlObj.FindChildByXPath("//fa-icon[@icon='" + control + "']/parent::*");
    if (!controlObj.Exists)
    {
      Log.Error("Controls inside Bulk Edit box not found!");
      return;
    }
    vClickAction(controlObj, 'Click');
    Delay(300);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Save Changes from Bulk Edit box using arrow symbol
TDMonitor.prototype.saveChangesUsingBulkEditBoxArrow = function()
{
  try
  {
    this.clickOnBulkEditBoxControls("arrow-right");
    if (!Reporter.TC_RESULT)
      return;
   }
  catch (e)
  {
    Log.Error(e);
  }
}

//Close Bulk Edit Box
TDMonitor.prototype.closeBulkEditBox = function()
{
  try
  {
    this.clickOnBulkEditBoxControls("times");
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Open Bulk Edit from Keyboard
TDMonitor.prototype.openBulkEditBoxFromKeyboard = function()
{
  try
  {
    LLPlayer.KeyDown(VK_INSERT, 200);
    LLPlayer.KeyUp(VK_INSERT, 200);
    Delay(200);

    if ((this.returnBulkEditBox()).Exists)
      vCheckpoint("Bulk Edit Box is launched using Keyboard [Insert] key!");
    else
      Log.Error("Bulk Edit Box is not launched using Keyboard [Insert] key!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Input to Bulk Edit Box
TDMonitor.prototype.inputBulkEditBox = function(value)
{
  try
  {
    //Get Text box area
    var textBox = this.returnBulkEditBox();
    textBox = textBox.FindChild(new Array("ObjectType", "tagName"), new Array('Textbox', 'INPUT'), MAX_CHILDS);
    if (!textBox || !textBox.Exists)
    {
      Log.Error("Bulk Edit input box could not be found!");
      return;
    }
    Delay(200);
    vClickAction(textBox, 'Click');
    textBox.SetText(value);
    vCheckpoint("Value " + value + " is entered in Bulk Edit box");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Close Bulk Edit Box by pressing on Esc key 
TDMonitor.prototype.closeBulkEditBoxFromKeyboard = function()
{
  try
  {
    LLPlayer.KeyDown(VK_ESCAPE, 200);
    LLPlayer.KeyUp(VK_ESCAPE, 200);
    Delay(200);

    if (!this.returnBulkEditBox())
      vCheckpoint("Bulk Edit Box is closed using Keyboard [Esc] key!");
    else
      Log.Error("Bulk Edit Box is not closed using Keyboard [Esc] key!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns an array of Cell values based on the from and to row id values
TDMonitor.prototype.getSpecificCellValues = function(columnDOMName, fromRowId, toRowId)
{
  try
  {
    var results = new Array();
    for (var i = fromRowId; i <= toRowId; i++)
    {
      var value = this.getCellValue(columnDOMName, i);
      results.push(value);
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Save Changes using Bulk Edit from Keyboard
TDMonitor.prototype.saveChangesUsingBulkEditFromKeyboard = function()
{
  try
  {
    LLPlayer.KeyDown(VK_RETURN, 200);
    LLPlayer.KeyUp(VK_RETURN, 200);
    Delay(200);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Return Cell Range Dialog Box
TDMonitor.prototype.getCellRangeDialogBoxText = function()
{
  try
  {
    var box = this.frame.FindChildByXPath("//*[@class='modal-body']//descendant::*[contains(text(), '150 cells')]");
    if (!box || !box.Exists)
    {
      Log.Error("Cell Range Dialog box could not be found!");
      return;
    }
    return box.contentText;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Click on Ok button in Cell Range Validation box
TDMonitor.prototype.clickOkInCellRangeDialogBox = function()
{
  try
  {
    var button = this.frame.FindChildByXPath("//*[@class='modal-body']//descendant::*//child::*[@type='button']");
    if (!button || !button.Exists)
    {
      Log.Error("Cell Range Validation box, [OK] button could not be found!");
      return;
    }
    Delay(200);
    vClickAction(button, 'Click');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.openSideBar = function()
{
  try
  {      
    vClickAction(this.windowObj, 'Click');
    Delay(500);  
    this.windowObj.Keys("~s");
    Delay(1000);
    var control = this.windowObj.FindChild("className", 'ag-side-buttons', MAX_CHILDS);
    if (control && control.VisibleOnScreen)
      vCheckpoint("Side bar is opened!");
    else
      Log.Error("Side bar is not visible on screen!"); 
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.selectFromSideBar = function(value)
{
  try
  {
    this.openSideBar();
    if (!Reporter.TC_RESULT)
      return;
    
    var sidebar = this.windowObj.FindChild("className", 'ag-side-buttons', MAX_CHILDS);
    var control = sidebar.FindChild(new Array("contentText", "VisibleOnScreen"), new Array(''+value+'', true), MAX_CHILDS);
    if (control && control.Exists)
    {
      vClickAction(control, 'Click');
      Delay(500);
    }
    else
      Log.Error("Object: "+value+" not found in sidebar!"); 
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.addFilterToRowGroups = function(columnUIName)
{
  try
  {
    var colList = this.windowObj.FindChild("className", 'ag-primary-cols-list-panel', MAX_CHILDS);
    var control = colList.FindChildByXPath("//span[@class='ag-column-tool-panel-column-label'][contains(text(), '"+columnUIName+"')]//parent::*");
    control.Drag(25, 11, 0, colList.Height + 10);

    var colDropList = this.windowObj.FindChild("className", 'ag-column-drop-list', MAX_CHILDS);
    var control1 = colDropList.FindChildByXPath("//span[@class='ag-column-drop-cell-text'][contains(text(), '"+columnUIName+"')]");
    if (control1 && control1.Exists)
      vCheckpoint("Filter for column "+columnUIName+" added to Row Groups!");
    else
      Log.Error("Filter for column "+columnUIName+" is not added to Row Groups!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

TDMonitor.prototype.getRichListObject = function()
{
  try
  {
    Delay(1000);            
    var object = this.windowObj.FindChild("Name", 'Panel("richList")', MAX_CHILDS);          
    
    if(object && object.VisibleOnScreen)
      return object;
    else
      Log.Error("Rich list object not found");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get status of toggle
TDMonitor.prototype.getToggleStatus = function(toggleCellObj)
{
  try
  {
    var inputNode = toggleCellObj.FindChildByXPath("//input[@type = 'checkbox']");
    if (!inputNode || !inputNode.Exists)
    {
      Log.Error("Cell's Input Node not available to get Pseudo Element status!");
      return;
    }
    return this.getComputedStyle(inputNode, "content", ':after');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Choose specific number toggles //status = "none" or "✔"
TDMonitor.prototype.selectToggles = function(columnDOMName, fromRowId, toRowId, status)
{
  try
  {
    for (var i = fromRowId; i <= toRowId; i++)
    {
      var cell = this.getCEFCell(this.xDg, i, columnDOMName);
      if (!cell || !cell.Exists)
      {
        Log.Error("Cell not found!");
        return;
      }
      status = status != "none" ? aqString.Quote(status) : status;
      if (this.getToggleStatus(cell) == status)
      {
        vClickCoordinates(cell, cell.Width - 10, 7);
        LLPlayer.KeyDown(VK_CONTROL, 200);
      }
    }
    LLPlayer.KeyUp(VK_CONTROL, 200);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns an array of Cell values based on the from and to row id values
TDMonitor.prototype.getSpecificToggleStatusValues = function(columnDOMName, fromRowId, toRowId)
{
  try
  {
    var results = new Array();
    for (var i = fromRowId; i <= toRowId; i++)
    {
      var value = this.getToggleStatus(this.getCEFCell(this.xDg, i, columnDOMName));
      results.push(value);
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}