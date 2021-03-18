//USEUNIT GlobalIncludes
//USEUNIT TD_GlobalVariables
//USEUNIT TD_HelperModule
//USEUNIT TD_ToolbarModule


function launch_Agency_SMS_ContributionNegotiationDefinition()
{
  try
  {
    var plugin = "Agency_SMS_Contribution/Negotiation Definition (Web)";
    launchMonitor(plugin);
    if (!Reporter.TC_RESULT)
      return;

    var td_a_s_cnd = new TDMonitor_Agency_SMS_ContributionNegotiationDefinition(TDWinType.ELECTRON);
    if (!td_a_s_cnd.Exists)
      return;

    //td_a_s_cnd.goToTestLocation();

    return td_a_s_cnd;
  }
  catch (e)
  {
    Log.Error(e);
    vClose(td_a_s_cnd);
  }
}

//Launch Grid and create Object
//Use type = "true" for only creating an object for already launched monitor
function launchGrid(gridName, type)
{
  try
  {
    if (!type || type == undefined)
    {
      launchMonitor(gridName);
      if (!Reporter.TC_RESULT)
        return;
    }

    Delay(5000);
    var gridName = gridName.replace("/", "").replace(/\s/g, '').replace("(Web)", "");
    gridName = "TDMonitor_" + gridName;

    var gridObject = eval("new " + gridName + "(TDWinType.ELECTRON)");
    if (!gridObject.Exists)
      return;

    vCheckpoint("Grid : " + gridName + " is launched!");
    //gridObject.goToTestLocation();
    return gridObject;
  }
  catch (e)
  {
    Log.Error(e);
    vClose(gridObject);
  }
}

function launch_SaveActivityAsGrid()
{
  try
  {
    chooseActivityOption("Save as", "menu");
    if (!Reporter.TC_RESULT)
      return;

    var tdSaveActWin = new TDMonitor_SaveActivityAsGrid(TDWinType.WPF);
    if (!tdSaveActWin.Exists)
      return;

    return tdSaveActWin;
  }
  catch (e)
  {
    Log.Error(e);
    vClose(tdSaveActWin);
  }
}