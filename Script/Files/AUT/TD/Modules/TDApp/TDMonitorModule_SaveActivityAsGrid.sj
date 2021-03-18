//USEUNIT GlobalIncludes
//USEUNIT TD_HelperModule
//USEUNIT TD_MonitorModule
//USEUNIT TD_ToolbarModule

var TDMonitor_SaveActivityAsGrid = TDMonitor.extend(
{
  constructor: function(winType)
  {
    try
    {
      this.base(winType);
      if (this.monitorWindow.Exists)
      {
        this.windowObj = this.monitorWindow.FindChild(new Array("Name", "Title.OleValue"), new Array('WPFObject("window")', 'Save Activity As'), MAX_CHILDS);
        if (this.windowObj.Exists)
        {
          this.Exists = true;
          this.xDg = this.windowObj.FindChild("Name", 'WPFObject("ActivityManagerView", "", 1)', MAX_CHILDS);
          this.activityList = this.windowObj.FindChild("Name", 'WPFObject("activityList")', MAX_CHILDS);
          this.activityInpuTextBox = this.windowObj.FindChild("Name", 'WPFObject("TextBox", "", 1)', MAX_CHILDS);
          this.okButton = this.windowObj.FindChild("Name", 'WPFObject("okButton")', MAX_CHILDS);
          this.cancelButton = this.windowObj.FindChild("Name", 'WPFObject("Button", "Cancel", 2)', MAX_CHILDS);
        }
        else
          Log.Error("TDMonitor_SaveActivityAsGrid Window not found!");
      }
      else
        Log.Error("TD Window not found!");
    }
    catch (e)
    {
      Log.Error(e);
    }
  }
});

//Click on first available empty slot
TDMonitor_SaveActivityAsGrid.prototype.clickOnEmptySlot = function()
{
  try
  {
    var menuPropArray = new Array("Name", "Content.InUse");
    var menuValuesArray = new Array('WPFObject("ListBoxItem", "", *)', false);

    var slotList = this.activityList.FindAll(menuPropArray, menuValuesArray, MAX_CHILDS).toArray();
    if (slotList.length == 0)
      Log.Error("Empty slots not found!");
    else
      vClickAction(slotList[slotList.length - 1], 'Click');
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify if activity is already available in slot list
TDMonitor_SaveActivityAsGrid.prototype.isActivityNameAvailable = function(activityName)
{
  try
  {
    var menuPropArray = new Array("Name", "Content.InUse");
    var menuValuesArray = new Array('WPFObject("ListBoxItem", "", *)', true);

    var slotList = this.activityList.FindAll(menuPropArray, menuValuesArray, MAX_CHILDS).toArray();
    for (i = 0; i < slotList.length; i++)
    {
      if (slotList[i].Content.Name.OleValue == activityName)
        return true;
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Create new activity and save it
TDMonitor_SaveActivityAsGrid.prototype.createNewActivity = function(activityName)
{
  try
  {
    //Verify if activity is already available 
    if (this.isActivityNameAvailable(activityName) == false)
    {
      //Click on a empty slot
      this.clickOnEmptySlot();

      //Click on Activity Name text box
      vClickAction(this.activityInpuTextBox, 'Click');

      //Enter Activity name
      vSetTextBoxValue(this.activityInpuTextBox, activityName);

      //Click Ok button
      vClickAction(this.okButton, 'Click');
      vCheckpoint("New Activity (" + activityName + ") created!")
    }
    else
      Log.Error("Activity (" + activityName + ") already available!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}
