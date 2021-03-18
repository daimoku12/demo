//USEUNIT GlobalIncludes
//USEUNIT TD_HelperModule
//USEUNIT TD_ToolbarModule
//USEUNIT TD_MonitorModule

var TDMonitor_GridPreferences = TDMonitor.extend(
{
  constructor: function(winType)
  {
    try
    {
      this.base(winType);
      if (this.monitorWindow.Exists)
      {
        this.windowObj = this.monitorWindow;
        this.linkPanel = this.windowObj.FindChild(new Array("ObjectType", "className"), new Array('Panel', 'col*menu-panel border-right'), MAX_CHILDS);
        if (this.windowObj.Exists)
        {
          this.lnkVariables = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Variables'), MAX_CHILDS);
          this.lnkColumns = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Columns'), MAX_CHILDS);
          this.lnkSorting = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Sorting'), MAX_CHILDS);
          this.lnkGrouping = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Grouping'), MAX_CHILDS);
          this.lnkPivoting = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Pivoting'), MAX_CHILDS);
          this.lnkDisplay = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Display'), MAX_CHILDS);
          this.lnkStyles = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Styles'), MAX_CHILDS);
          this.lnkBookmarks = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Bookmarks'), MAX_CHILDS);
          this.lnkSettings = this.linkPanel.FindChild(new Array("ObjectType", "innerText"), new Array('Link', 'Settings'), MAX_CHILDS);
          this.contentPanel = this.windowObj.FindChild(new Array("ObjectType", "className"), new Array('Panel', '*content-panel*preferences-container'), MAX_CHILDS);
          this.leftPane = this.contentPanel.FindChild(new Array("Name", "className"), new Array('Panel(0)', 'col-5'), MAX_CHILDS);
          this.leftContent = this.leftPane.FindChild(new Array("ObjectType", "className"), new Array('Panel', 'form-group group-box vert-scrollable-area vh-100'), MAX_CHILDS);
          this.btnClose = this.windowObj.FindChildByXPath("//button[@data-automation= 'btnWindowClose']");
          this.save = this.windowObj.FindChildByXPath("//button[@data-automation= 'btnPreferencesSave']");
          this.apply = this.windowObj.FindChildByXPath("//button[@data-automation= 'btnPreferencesApply']");
          this.Exists = true;
        }
        else
          Log.Error("TDMonitor_GridPreferences Window not found!", "TDMonitor_GridPreferences Constructor");
      }
      else
        Log.Error("TD Window not found!", "TDMonitor_GridPreferences Constructor");
    }
    catch (e)
    {
      Log.Error(e, "TDMonitor_GridPreferences Constructor");
    }
  }
});

TDMonitor_GridPreferences.prototype.goToTestLocation = function(ToX, ToY)
{
  try
  {
    Monitor.prototype.goToTestLocation.call(this, 50, 480, ToX, ToX);
  }
  catch (e)
  {
    Log.Error(e, "goToTestLocation");
  }
}

TDMonitor_GridPreferences.prototype.selectColumnNameFromList = function(colName)
{
  try
  {
    var columnNamesList = this.contentPanel.FindChild(new Array("ObjectType", "className"), new Array('Panel', '*orm-group*group-bo*'), MAX_CHILDS);
    if (!columnNamesList.Exists)
    {
      Log.Error("Column Names List is not found in the panel!", "selectColumnNameFromList");
      return;
    }

    Delay(1000);

    var columnName = columnNamesList.FindChild(new Array("ObjectType", "contentText"), new Array('TextNode', colName), MAX_CHILDS);
    if (!columnName.Exists)
    {
      Log.Error("Column Names is not found in the list!", "selectColumnNameFromList");
      return;
    }

    vClickAction(columnName, 'Click');
    Delay(1000);
  }
  catch (e)
  {
    Log.Error(e, "selectColumnNameFromList");
  }
}

//Returns all the column names in the Right Pane of Preferences
//type = "single" or empty (when there is only one pane use type)
//Applicable for Sorting, Grouping, Display
TDMonitor_GridPreferences.prototype.getColumnNameFromRightPane = function(type)
{
  try
  {
    if (!this.contentPanel.Exists)
    {
      Log.Error("Column Names List is not found in the panel!", "getColumnNameFromRightPane");
      return;
    }

    Delay(1000);
    
    if (type == "single")
      var elements = this.contentPanel.FindAll(new Array("ObjectType", "className", "tagName"), new Array('TextNode', 'ng-star-inserted', 'SPAN'), MAX_CHILDS).toArray();
    else
      var elements = this.contentPanel.getElementsByClassName("list-group-item-span ng-star-inserted");
      
    if (elements.length == 0)
    {
      Log.Error("There are no columns found!", "getColumnNameFromRightPane");
      return;
    }

    var results = new Array();
    for (var i = 0; i < elements.length; i++)
    {
      var columns = elements[i].innerText;
      results.push(columns);
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e, "getColumnNameFromRightPane");
  }
}

//Returns Sorting order in the Right Pane of Preferences. Preferences>Sorting
TDMonitor_GridPreferences.prototype.getSortingOrderFromRightPane = function()
{
  try
  {
    if (!this.contentPanel.Exists)
    {
      Log.Error("Sorting Order List is not found in the panel!", "getColumnNameFromRightPane");
      return;
    }

    Delay(1000);

    var elements = this.contentPanel.getElementsByClassName("btn pull-right fa-custom-button transparent-button ng-star-inserted");
    if (elements.length == 0)
    {
      Log.Error("There are no columns found!", "getSortingOrderFromRightPane");
      return;
    }

    var results = new Array();
    for (var i = 0; i < elements.length; i++)
    {
      var columns = elements[i].title;
      results.push(columns);
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Switch Case for Move Left/Move Left All/Move Right/Move Right All
//Use direction = Move Left All, Move Left, Move Right All, Move Right
//Applicable for Sorting, Grouping, Display
TDMonitor_GridPreferences.prototype.moveColumnLeftOrRight = function(direction, column)
{
  try
  {
    var rightPane = this.contentPanel.FindChildByXPath("//div[@data-automation= 'swapPaneRight']/*/div[contains(@class, 'vert-scrollable-area')]");
    var leftPane = this.contentPanel.FindChildByXPath("//div[@data-automation= 'swapPaneLeft']/*/div[contains(@class, 'vert-scrollable-area')]");
    var rightPaneElements = (rightPane.innerText).split("\n");
    var leftPaneElements = (leftPane.innerText).split("\n");
    var beforeRightPaneElementCount = rightPaneElements.length;
    var beforeLeftPaneElementCount = leftPaneElements.length;
    var control = this.windowObj.FindChild(new Array("ObjectType", "title"), new Array('Button', direction), MAX_CHILDS);
    if (!control.Exists)
    {
      Log.Error("" + direction + " button not found!");
      return;
    }
    if (direction == "Move Left" || direction == "Move Right")
    {
      var colToMove = this.contentPanel.FindChild(new Array("ObjectType", "textContent", "Visible"), new Array('TextNode', column.UIName, true), MAX_CHILDS);
      if (!colToMove.Exists)
      {
        Log.Error("Column [" + column.UIName + "] not found in Right/Left Pane!");
        return;
      }

      vClickAction(colToMove, 'Click');
      Delay(200);
      vClickAction(control, 'Click');
    }
    else
      vClickAction(control, 'Click');

    leftPane.Refresh()
    rightPane.Refresh();
    leftPaneElements = (leftPane.innerText).split("\n");
    rightPaneElements = (rightPane.innerText).split("\n");

    switch (direction)
    {
      case "Move Left All":
        if (rightPaneElements.length == 1 && checkIfValueExistsInArray(rightPaneElements, ""))
          vCheckpoint("All columns moved to Left pane from Right pane");
        else
          Log.Error("All Columns have not moved to left!");
        break;

      case "Move Right All":
        if (leftPaneElements.length == 1 && checkIfValueExistsInArray(leftPaneElements, ""))
          vCheckpoint("All columns moved to Right pane from Left pane");
        else
          Log.Error("All Columns have not moved to Right!");
        break;

      case "Move Left":
        if (checkIfValueExistsInArray(leftPaneElements, column.GridPrefName))
          vCheckpoint("Column [" + column.UIName + "] moved to Left pane from Right pane");
        else
          Log.Error("Column [" + column.UIName + "] has not moved to left!");
        break;

      case "Move Right":
        if (checkIfValueExistsInArray(rightPaneElements, column.GridPrefName))
          vCheckpoint("Column [" + column.UIName + "] moved to Right pane from Left pane");
        else
          Log.Error("Column [" + column.UIName + "] has not moved to Right!");
        break;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Switch Case for Move Up/Move Down/Move To Top/Move To Bottom
//Use direction = Move Up, Move Down, Move To Top, Move To Bottom
//Applicable for Sorting, Grouping, Display
TDMonitor_GridPreferences.prototype.moveColumnTopOrBottom = function(direction, column)
{
  try
  {
    var before = this.getColumnNameFromRightPane();
    var beforeIndex = returnIndex(before, column.GridPrefName);
    var control = this.windowObj.FindChild(new Array("ObjectType", "title"), new Array('Button', direction), MAX_CHILDS);
    var rightPanel = this.contentPanel.FindChildByXPath("//div[@data-automation= 'swapPaneRight']");
    var colToMove = rightPanel.FindChild(new Array("ObjectType", "textContent", "Visible"), new Array('TextNode', column.UIName, true), MAX_CHILDS);
    if (!control.Exists || !colToMove.Exists)
    {
      Log.Error("[" + direction + "] button not found or Column [" + column.UIName + "] not found in Right Pane!");
      return;
    }

    switch (direction)
    {
      case "Move Up":
        var arrayWhenMoved = arrayMove(before, beforeIndex, beforeIndex - 1);

        vClickAction(colToMove, 'Click');
        Delay(1000);
        vClickAction(control, 'Click');

        var after = this.getColumnNameFromRightPane();
        if (compareValuesInArray(after, arrayWhenMoved))
          vCheckpoint("Column [" + column + "] moved Up!");
        else
          Log.Error("Column [" + column + "] not moved Up!");
        break;


      case "Move To Top":
        var arrayWhenMoved = arrayMove(before, beforeIndex, 0);

        vClickAction(colToMove, 'Click');
        Delay(1000);
        vClickAction(control, 'Click');

        var after = this.getColumnNameFromRightPane();
        if (compareValuesInArray(after, arrayWhenMoved))
          vCheckpoint("Column [" + column.UIName + "] moved to Top!");
        else
          Log.Error("Column [" + column.UIName + "] not moved to Top!");
        break;

      case "Move Down":

        vClickAction(colToMove, 'Click');
        Delay(1000);
        vClickAction(control, 'Click');

        var after = this.getColumnNameFromRightPane();
        var afterIndex = returnIndex(after, column.GridPrefName);
        if (afterIndex == beforeIndex + 1)
          vCheckpoint("Column [" + column.UIName + "] moved down!");
        else
          Log.Error("Column [" + column.UIName + "] not moved down!");
        break;

      case "Move To Bottom":
        var arrayWhenMoved = arrayMove(before, beforeIndex, length - 1);

        vClickAction(colToMove, 'Click');
        Delay(1000);
        vClickAction(control, 'Click');

        var after = this.getColumnNameFromRightPane();
        if (compareValuesInArray(after, arrayWhenMoved))
          vCheckpoint("Column [" + column + "] moved to bottom!");
        else
          Log.Error("Column [" + column + "] not moved to bottom!");
        break;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Click Save button
TDMonitor_GridPreferences.prototype.clickSave = function()
{
  try
  {
    var saveBtn = this.windowObj.FindChild("Name", 'Button("saveButton")', MAX_CHILDS);
    if (!saveBtn.Exists)
    {
      Log.Error("Save button not found!", "clickSave");
      return;
    }
    vClickAction(saveBtn, 'Click');
    vCheckpoint("Save button clicked in Preference window!");
  }
  catch (e)
  {
    Log.Error(e, "clickSave");
  }
}

//Click Apply Button
TDMonitor_GridPreferences.prototype.clickApply = function()
{
  try
  {
    var applyBtn = this.windowObj.FindChild("Name", 'Button("applyButton")', MAX_CHILDS);
    if (!applyBtn.Exists)
    {
      Log.Error("Apply button not found!", "clickApply");
      return;
    }
    vClickAction(applyBtn, 'Click');
    vCheckpoint("Apply button clicked in Preference window!");
  }
  catch (e)
  {
    Log.Error(e, "clickApply");
  }
}

//Change Sorting direction. Preferences>Sorting
TDMonitor_GridPreferences.prototype.changeSortDirection = function(column)
{
  try
  {
    var before = this.getSortDirection(column);
    var index = returnIndex(this.getColumnNameFromRightPane(), column);
    var elements = this.contentPanel.getElementsByClassName("btn pull-right fa-custom-button transparent-button ng-star-inserted");
    if (elements.length == 0)
    {
      Log.Error("There are no columns found!", "changeSortDirection");
      return;
    }

    var results = new Array();
    for (var i = 0; i < elements.length; i++)
    {
      var columns = elements[i];
      results.push(columns);
    }

    var button = returnControl(results, index);
    button.Click();

    var after = this.getSortDirection(column);
    if (before == after)
      Log.Error("Sort direction not changed after clicking sort direction button!", "changeSortDirection");
    else
      vCheckpoint("Sort Direction of column [" + column + "] Before:" + before + " After:" + after + "!");
  }
  catch (e)
  {
    Log.Error(e, "changeSortDirection");
  }
}

//Get Sort Direction for a column. Preferences>Sorting
TDMonitor_GridPreferences.prototype.getSortDirection = function(column)
{
  try
  {
    var index = returnIndex(this.getColumnNameFromRightPane(), column);
    var elements = this.contentPanel.getElementsByClassName("btn pull-right fa-custom-button transparent-button ng-star-inserted");
    if (elements.length == 0)
    {
      Log.Error("There are no columns found!", "getSortDirection");
      return;
    }

    var results = new Array();
    for (var i = 0; i < elements.length; i++)
    {
      var columns = elements[i].title;
      results.push(columns);
    }

    var sortDirection = returnControl(results, index);
    vCheckpoint("Current sort direction for column [" + column + "] is [" + sortDirection + "]!");
    return sortDirection;
  }
  catch (e)
  {
    Log.Error(e, "getSortDirection");
  }
}

//Get 2D array of col, sort in Preference window
TDMonitor_GridPreferences.prototype.getTwoDColSortFromPreference = function()
{
  try
  {
    var result = [];
    result = arrayCombineTwoD(arrayReturnsStringAfterSplit(this.getColumnNameFromRightPane(), "."), this.getSortingOrderFromRightPane());
    return result.sort();
  }
  catch (e)
  {
    Log.Error(e, "getTwoDColSortFromPreference");
  }
}

//Switch On Control to Active
//control = "Thousands Separator (,)", Accounting Style, Pivot Mode
TDMonitor_GridPreferences.prototype.switchOnControl = function(control)
{
  try
  {
    var control = this.contentPanel.FindChild(new Array("ObjectType", "textContent"), new Array('Panel', control), MAX_CHILDS);
    if (!control.Exists)
    {
      Log.Error("Control " + control + " not found!", "switchOnControl");
      return;
    }
    var controlSwitch = control.FindChildByXPath("//*[@for='toggle-switch-input']");
    vClickAction(controlSwitch, 'Click');
  }
  catch (e)
  {
    Log.Error(e, "switchOnControl");
  }
}

//Returns Pivot Type Right pane box
//"RowGroups"
//"Values"
//"ColumnLabels"
TDMonitor_GridPreferences.prototype.returnPivotTypeBoxFromRightPane = function(pivotType)
{
  try
  {
    var pivotRightPanel = this.contentPanel.FindChild(new Array("ObjectType", "className"), new Array('Panel', 'd-flex align-items-stretch flex-wrap vh-100'), MAX_CHILDS);
    var pivotTypeBoxRight = pivotRightPanel.FindChildByXPath("//*[@id='" + pivotType + "'][@class='list-group']/parent::div");
    return pivotTypeBoxRight;
  }
  catch (e)
  {
    Log.Error(e, "returnPivotTypeBoxFromRightPane");
  }
}

//Verify if a column is available inside a Pivot Right Pane Box
//"RowGroups"
//"Values"
//"ColumnLabels"
TDMonitor_GridPreferences.prototype.isColumnInPivotRightBox = function(pivotType, column)
{
  try
  {
    var pivotRightBox = this.returnPivotTypeBoxFromRightPane(pivotType);
    if (pivotType == "Values")
    {
      var col = pivotRightBox.FindChild(new Array("className", "textContent"), new Array('row ng-star-inserted', "Sum(" + column + ")"), MAX_CHILDS);
    }
    else
    {
      var col = pivotRightBox.FindChild(new Array("className", "textContent"), new Array('row ng-star-inserted', column), MAX_CHILDS);
    }
    return col.Exists ? true : false;
  }
  catch (e)
  {
    Log.Error(e, "isColumnInPivotRightBox");
  }
}

//Pivot > Add to Row Groups/Values/Column Labels using icon
//RowGroup = "group"
//Values = "aggregation"
//ColumnLabels = "pivot"
TDMonitor_GridPreferences.prototype.addPivotTypeUsingIcon = function(pivotType, column)
{
  try
  {
    var pivotPanel = this.contentPanel.FindChildByXPath("//*[@class='vert-scrollable-area']");
    var control = pivotPanel.FindChild(new Array("className", "textContent"), new Array('row ng-star-inserted', column), MAX_CHILDS);
    if (!control.Exists)
    {
      Log.Error("Column [" + column + "] not found in Pivot Columns Pane!", "addPivotTypeUsingIcon");
      return;
    }
    var icon = control.FindChildByXPath("//*[@class='pivot-icons ag-icon-" + pivotType + "']");
    Delay(1000);
    vClickAction(icon, 'Click');
    if (this.isColumnInPivotRightBox(this.getPivotType(pivotType), column))
      vCheckpoint("Column [" + column + "] added to [" + this.getPivotType(pivotType) + "] using icon!");
    else
      Log.Error("Column [" + column + "] not added to [" + this.getPivotType(pivotType) + "] using icon!", "addPivotTypeUsingIcon");
  }
  catch (e)
  {
    Log.Error(e, "addPivotTypeUsingIcon");
  }
}

//Removes Column from specified Pivot Right Pane Box
//"RowGroups"
//"Values"
//"ColumnLabels"
TDMonitor_GridPreferences.prototype.removePivotColumnFromRightBox = function(pivotType, column)
{
  try
  {
    var pivotRightBox = this.returnPivotTypeBoxFromRightPane(pivotType);
    if (pivotType == "Values")
      var col = pivotRightBox.FindChild(new Array("className", "textContent"), new Array('row ng-star-inserted', "Sum(" + column + ")"), MAX_CHILDS);
    else
    {
      var col = pivotRightBox.FindChild(new Array("className", "textContent"), new Array('row ng-star-inserted', column), MAX_CHILDS);
    }
    var closeBtn = col.FindChild("className", 'close-btn ng-star-inserted', MAX_CHILDS);
    vClickAction(closeBtn, 'Click');
    if (this.isColumnInPivotRightBox(pivotType, column) == false)
      vCheckpoint("Column [" + column + "] removed from [" + pivotType + "] using icon!");
    else
      Log.Error("Column [" + column + "] not removed from [" + pivotType + "] using icon!", "removePivotColumnFromRightBox");
  }
  catch (e)
  {
    Log.Error(e, "removePivotColumnFromRightBox");
  }
}

TDMonitor_GridPreferences.prototype.getPivotType = function(pivot)
{
  try
  {
    switch (pivot)
    {
      case "group":
        return "RowGroups";

      case "aggregation":
        return "Values";

      case "pivot":
        return "ColumnLabels";
    }
  }
  catch (e)
  {
    Log.Error(e, "getPivotType");
  }
}

//Pivot > Add to Row Groups/Values/Column Labels using icon
//RowGroup = "group"
//Values = "aggregation"
//ColumnLabels = "pivot"
TDMonitor_GridPreferences.prototype.addPivotTypeByDragAndDrop = function(pivotType, column)
{
  try
  {
    var pivotPanel = this.contentPanel.FindChildByXPath("//*[@class='vert-scrollable-area']");
    var fromColumn = pivotPanel.FindChild(new Array("ObjectType", "textContent"), new Array('TextNode', column.UIName), MAX_CHILDS);
    if (!fromColumn.Exists)
    {
      Log.Error("Column [" + column.UIName + "] not found in Pivot Columns Pane!", "addPivotTypeByDragAndDrop");
      return;
    }
    var toPivotBox = this.returnPivotTypeBoxFromRightPane(this.getPivotType(pivotType));
    var dragX = fromColumn.Width / 2;
    var dragY = fromColumn.Height / 2;
    var destX = (toPivotBox.Left + toPivotBox.Width / 2) - (fromColumn.Left + dragX)
    var destY = (toPivotBox.Top + toPivotBox.Height / 2) - (fromColumn.Top + dragY);
    fromColumn.Drag(dragX, dragY, destX, destY);
    
    if (this.isColumnInPivotRightBox(this.getPivotType(pivotType), column.GridPrefName))
      vCheckpoint("Column [" + column.UIName + "] added to [" + this.getPivotType(pivotType) + "] by drag and drop!");
    else
      Log.Error("Column [" + column.UIName + "] not added to [" + this.getPivotType(pivotType) + "] by drag and drop!", "addPivotTypeByDragAndDrop");

    }
  catch (e)
  {
    Log.Error(e, "addPivotTypeByDragAndDrop");
  }
}

//Verify if column is pinned right or left. Preferences>Display
//pinType = "left" or "right"
//To return array of left or right pinned columns -> logResult = true (can be empty also)
TDMonitor_GridPreferences.prototype.verifyIfColumnPinnedRightOrLeft = function(column, pinType, logResult)
{
  try
  {
    var direction = (pinType == "left") ? "above" : "below";
    var pinType = "[Columns " + direction + " are " + pinType + " pinned]";
    var array = this.getColumnNameFromRightPane();
    if (!Reporter.TC_RESULT)
      return;
      
    var index = returnIndex(array, pinType);
    var results = arrayOfElementForACondition(array, direction, index, 0, true);
    if (!Reporter.TC_RESULT)
      return;
      
    if (logResult == true)
    return results;
    else     
    return checkIfValueExistsInArray(results, column) ? true : false;
  }
  catch (e)
  {
    Log.Error(e, "verifyIfColumnPinnedRightOrLeft");
  }
}

//Right pin or left pin a column. Preferences>Display
//pinType = "right" or "left"
TDMonitor_GridPreferences.prototype.rightOrLeftPinColumn = function(column, pinType)
{
  try
  {
    var index = returnIndex(this.getColumnNameFromRightPane(), column);
    var elements = this.contentPanel.getElementsByClassName("btn btn-" + pinType + " btn-light");
    if (elements.length == 0)
    {
      Log.Error("There are no pin buttons found!", "rightOrLeftPinColumn");
      return;
    }
    
    var control = returnControl(elements, index);
    control.Click();

    if (this.verifyIfColumnPinnedRightOrLeft(column, pinType))
      vCheckpoint("Column [" + column + "] is pinned " + pinType + " in Preference!");
    else
      Log.Error("Column [" + column + "] is not pinned " + pinType + " in Preference!", "rightOrLeftPinColumn");
  }
  catch (e)
  {
    Log.Error(e, "rightOrLeftPinColumn");
  }
}

//Compares Sort in Grid and Pref
TDMonitor_GridPreferences.prototype.compareSortInGridAndPreference = function(gridObject)
{
  try
  {
    var gridResult = [];
    var preferenceResult = [];
    var tdPrefWin = new TDMonitor_GridPreferences(TDWinType.PREF);
    if (!Reporter.TC_RESULT)
      return;
      
    preferenceResult = tdPrefWin.getTwoDColSortFromPreference();

    //Click Apply
    tdPrefWin.clickApply();
    if (!Reporter.TC_RESULT)
      return;

    //Click Save
    tdPrefWin.clickSave();
    if (!Reporter.TC_RESULT)
      return;

    gridResult = gridObject.getAllSortedColumnsInGrid();
    if (!Reporter.TC_RESULT)
      return;
      
    return (arrayCompareTwoD(preferenceResult, gridResult)) ? true : false
  }
  catch (e)
  {
    Log.Error(e, "compareSortInGridAndPreference");
  }
}

//Drag and drop in Display Right Pane 
//column2 can be any column name or [Columns above are left pinned] or [Columns below are right pinned]
TDMonitor_GridPreferences.prototype.dragDisplay = function(column1, column2)
{
  try
  {
    var rightPanel = this.contentPanel.FindChildByXPath("//div[@data-automation= 'swapPaneRight']");
    var fromColumn = rightPanel.FindChild(new Array("ObjectType", "textContent"), new Array('TextNode', column1), MAX_CHILDS);
    var toColumn = rightPanel.FindChild(new Array("ObjectType", "textContent"), new Array('TextNode', column2), MAX_CHILDS);
    if (!fromColumn.Exists || !toColumn.Exists)
    {
      Log.Error("Columns provided are not available in Right pane!", "addPivotTypeUsingIcon");
      return;
    }

    var dragX = fromColumn.Width / 2;
    var dragY = fromColumn.Height / 2;
    var destY = (column2 == "[Columns below are right pinned]") ? ((toColumn.Top + toColumn.Height) - (fromColumn.Top)) : (toColumn.Top - fromColumn.Top - toColumn.Height/2);
    fromColumn.Drag(dragX, dragY, 0, destY);
  }
  catch (e)
  {
    Log.Error(e, "dragDisplay");
  }
}

//Click on a column name in right/single pane
//Applicable for Columns, Sorting, Grouping
TDMonitor_GridPreferences.prototype.clickColumnNameInPane = function(column)
{
  try
  {
    var column = this.contentPanel.FindChild(new Array("ObjectType", "textContent", "Visible"), new Array('TextNode', column, true), MAX_CHILDS); 
    if (!column.Exists)
    {
      Log.Error("Column [" + column + "] is not found in the list!", "clickColumnNameInPane");
      return;
    }
    vClickAction(column, 'Click');
  }
  catch (e)
  {
    Log.Error(e, "clickColumnNameInPane");
  }
}

//Input text into text box in Preference page for Columns > Right Pane 
//controlName ="label" as in Textbox("label") 
TDMonitor_GridPreferences.prototype.setTextBox = function(column, controlName, strValue)
{
  try
  {
    //Click on column
    this.clickColumnNameInPane(column);

    var textBox = this.contentPanel.FindChild("Name", "'Textbox(" + controlName + ")'", MAX_CHILDS);
    //Clear and set text as input
    vClearControl(textBox);
    vSetText(textBox, strValue);
  }
  catch (e)
  {
    Log.Error(e, "setTextBox");
  }
}

//Inc/Dec in Grid Preferences
//Applicable for Preferences>Column labelName = Decimal Places
TDMonitor_GridPreferences.prototype.incDecInGridPreferences = function(labelName, value)
{
  try
  {
    var numberBox = this.windowObj.FindChildByXPath("//label[contains(text(), '" + labelName + "')]//following-sibling::*//child::*[contains(@class, 'form-control')]");
    if (!numberBox.Exists)
    {
      Log.Error("Number input box with control name " + labelName + " not found!");
      return;
    }

    if (value != numberBox.value)
    {
      vClickAction(numberBox, 'Click');
      var destX = numberBox.Width - 15;

      if (value > numberBox.value)
      {
        do 
        {
          numberBox.Click(destX, numberBox.Height / 2 - 6);
          Delay(200);
        }
        while (numberBox.value != value);
      }
      else if (value < numberBox.value)
      {
        do
        {
          numberBox.Click(destX, numberBox.Height / 2 + 6);
          Delay(200);
        }
        while (numberBox.value != value);
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get current textbox value for Columns > Right Pane
//controlName = "Scale Factor"
TDMonitor_GridPreferences.prototype.getTexBoxValue = function(controlName)
{
  try
  {
    var control = this.contentPanel.FindChild(new Array("ObjectType", "className", "textContent"), new Array('Panel', 'form-group row', controlName), MAX_CHILDS);
    return (control.FindChild("ObjectType", 'Textbox', MAX_CHILDS)).Text;
  }
  catch (e)
  {
    Log.Error(e, "getTexBoxValue");
  }
}

//type - Rows/Columns, rowNum (1-9)
TDMonitor_GridPreferences.prototype.getBookmarkValue = function(type, rowNum)
{
  try
  {
    switch (type)
    {
      case "Rows":
        var rowsPanel = this.windowObj.FindChildByXPath("//*[contains(text(), 'Rows')]//ancestor::*[@class='bookmarks-column']");
        var row = rowsPanel.FindChildByXPath("//*[@title='CTRL + "+rowNum+"']");
        var textBox = row.FindChild("type", 'text', MAX_CHILDS);
        return textBox.value;

      case "Columns":  
        var columnsPanel = this.windowObj.FindChildByXPath("//*[contains(text(), 'Columns')]//ancestor::*[@class='bookmarks-column']"); 
        var row = columnsPanel.FindChildByXPath("//*[@title='ALT + "+rowNum+"']");
        var textBox = row.FindChild("type", 'text', MAX_CHILDS);
        return textBox.value;
    }
  }
  catch (e)
  {
    Log.Error(e, "getBookmarkValue");
  }
}

//type - Rows/Columns, rowNum (1-9)
TDMonitor_GridPreferences.prototype.deleteBookmark = function(type, rowNum)
{
  try
  {
    switch (type)
    {
      case "Rows":
        var rowsPanel = this.windowObj.FindChildByXPath("//*[contains(text(), 'Rows')]//ancestor::*[@class='bookmarks-column']");
        var row = rowsPanel.FindChildByXPath("//*[@title='CTRL + "+rowNum+"']");
        var control = row.FindChild("tagName", 'svg', MAX_CHILDS);
        vClickAction(control, 'Click');
        break;
        
      case "Columns":  
        var columnsPanel = this.windowObj.FindChildByXPath("//*[contains(text(), 'Columns')]//ancestor::*[@class='bookmarks-column']"); 
        var row = columnsPanel.FindChildByXPath("//*[@title='ALT + "+rowNum+"']");
        var control = row.FindChild("tagName", 'svg', MAX_CHILDS);
        vClickAction(control, 'Click');
        break;
    }
  }
  catch (e)
  {
    Log.Error(e, "deleteBookmark");
  }
}

TDMonitor_GridPreferences.prototype.selectStyle = function(value)
{
  try
  {
    var control = this.windowObj.FindChildByXPath("//label[contains(text(), 'Style')]//following-sibling::*//child::*[contains(@class, 'form-control')]");
    this.selectFromDropDown(control, value);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Select from drop down in Grid Preferences
//Applicable for Preferences>Column labelName = Alignment/Style/Format/Scale Factor/Decimal Increment/Fractional Increment
TDMonitor_GridPreferences.prototype.selectFromGridPreferencesDropDown = function(labelName, value)
{
  try
  {
    var control = this.windowObj.FindChildByXPath("//label[contains(text(), '" + labelName + "')]//following-sibling::*//child::*[contains(@class, 'form-control')]");
    if (!control.Exists)
    {
      Log.Error("Control [" + labelName + "] is not found!");
      return;
    }
    this.selectFromDropDown(control, value);
    if (!Reporter.TC_RESULT)
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Scroll Preferences Window Down. Direction = "UP" / "DOWN"
TDMonitor_GridPreferences.prototype.scrollPreferencesWindow = function(direction)
{
  try
  {
    var prefWindow = this.contentPanel.FindChildByXPath("//div[@class='group-box vert-scrollable-area vh-100 pr-3 pl-3' and .//label[@for = 'fieldId']]");
    if (!prefWindow.Exists)
    {
      Log.Error("Preference Window not found!");
      return;
    }
    this.scroll(prefWindow, direction, prefWindow.Height / 2);
  }
  catch (e)
  {
    Log.Error(e);
  }
}