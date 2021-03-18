//USEUNIT GlobalIncludes
//USEUNIT TD_GlobalVariables
//USEUNIT TD_HelperModule

function launchMonitor(plugin)
{
  try
  {
    if (CurrentAppCode != "TD")
      TD_GlobalVariables.getApplicationDetails();

    //var plugin = "TBA/SMS/Size Matrix";
    var beforeWinCount = getOpenWindowsCount();
    var isFound = false;
    var currentTime = null;
    var propArray = new Array("Name", "isMouseOver");
    var valuesArray = new Array('WPFObject("SubMenuBorder")', false);

    var viewsBox = Aliases.Citi_TD_ViewController.TDMainBar.window.Menu.MenuitemViews;
    var startTime = aqDateTime.Now();
    if (viewsBox.Exists)
    {
      do
      {
        vClickAction(viewsBox, 'Click');

        var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
        if (menuList.Exists && menuList != null)
        {
          var productParts = aqString.Trim(plugin).split("_");
          for (var i = 0; i < productParts.length; i++)
          {
            var part = aqString.Trim(productParts[i]);
            if (!(menuList.Exists))
            {
              Log.Error("Could not find list of views when trying to select: " + plugin);
              break;
            }

            var menuPropArray = new Array("Name", "DataContext.ShortName.OleValue");
            var menuValuesArray = new Array('WPFObject("MenuItem", "", *)', part);
            var selected = menuList.FindChild(menuPropArray, menuValuesArray, MAX_CHILDS);
            if (selected.Exists)
            {
              vClickAction(selected, 'Click');
              Delay(500);
              if (i + 1 == productParts.length)
              {
                isFound = true;
                break;
              }
              else
                menuList = tdViewControllerProcess.FindChild(propArray, valuesArray, MAX_CHILDS);
            }
          }
        }
        var afterWinCount = getOpenWindowsCount();
        var currentTime = aqDateTime.Now();
      }
      while (!isFound && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) <= 10 && afterWinCount <= beforeWinCount);
      if (!isFound)
        Log.Error("Could not find " + plugin + " menu!");
    }
    else
      Log.Error("Views button not found in the menu bar!");
    Delay(5000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function openToolbarPreferences()
{
  try
  {
    var hamburgerMenu = tdViewControllerProcess.FindChild(new Array("Visible", "Name"), new Array('True', 'WPFObject("MenuItem", "≡", 1)'), MAX_CHILDS);
    vClickAction(hamburgerMenu, 'Click');
    Delay(1000);

    var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
    if (!menuList.Exists)
    {
      Log.Error("Cannot locate menu list!");
      return;
    }
    
    var preferences = menuList.FindChild("Name", 'WPFObject("MenuItem", "Preferences", 1)', MAX_CHILDS);
    if (!preferences.Exists)
    {
      Log.Error("Preferences not found in menu list!");
      return;
    }
    
    vClickAction(preferences, 'Click');
    Delay(4000);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Choose an activity
//type = "menu" or empty
function chooseActivityOption(option, type)
{
  try
  {
    var tdMainBar = Aliases.Citi_TD_ViewController.TDMainBar.window;
    var activity = tdMainBar.FindChild("Name", 'WPFObject("MenuItem", "", *)', MAX_CHILDS);
    if (!activity.Exists)
    {
      Log.Error("Activity button not found in the menu bar!");
      return;
    }
    vClickAction(activity, 'Click');
    Delay(500);
    var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
    if (type == "menu")
    {
      var selected = menuList.FindChild("Name", 'WPFObject("MenuItem", "' + option + '", *)', MAX_CHILDS);
      if (!selected.Exists)
      {
        Log.Error("Option " + option + " not found in the menu list!");
        return;
      }
      vClickAction(selected, 'Click');
    }
    else
    {
      var menuPropArray = new Array("Name", "DataContext.Name.OleValue");
      var menuValuesArray = new Array('WPFObject("MenuItem", "", *)', option);
      var selected = menuList.FindChild(menuPropArray, menuValuesArray, MAX_CHILDS);
      if (!selected.Exists)
      {
        Log.Error("Option " + option + " not found in the menu list!");
        return;
      }
      vClickAction(selected, 'Click');
      var activityName = activity.FindChild("Name", 'WPFObject("TextBlock", *, *)', MAX_CHILDS);
      if (activityName.DataContext.Name.OleValue == option)
        vCheckpoint("Activity is set to [" + option + "]!");
      else
        Log.Error("Activity is not set to [" + option + "]!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Verify if Activity already available in list
function verifyIfActivityAvailable(activityName)
{
  try
  {
    var tdMainBar = Aliases.Citi_TD_ViewController.TDMainBar.window;
    var activity = tdMainBar.FindChild("Name", 'WPFObject("MenuItem", "", *)', MAX_CHILDS);
    if (!activity.Exists)
    {
      Log.Error("Activity button not found in the menu bar!");
      return;
    }
    vClickAction(activity, 'Click');
    Delay(500);

    var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
    var menuPropArray = new Array("Name", "DataContext.Name.OleValue");
    var menuValuesArray = new Array('WPFObject("MenuItem", "", *)', activityName);

    var selected = menuList.FindChild(menuPropArray, menuValuesArray, MAX_CHILDS);
    vClickAction(activity, 'Click');
    return selected.Exists ? true : false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Delete an Activity
//button = Yes or No
function deleteActivity(activityName, button)
{
  try
  {
    var tdMainBar = Aliases.Citi_TD_ViewController.TDMainBar.window;
    var activity = tdMainBar.FindChild("Name", 'WPFObject("MenuItem", "", *)', MAX_CHILDS);

    if (!activity.Exists)
    {
      Log.Error("Activity button not found in the menu bar!");
    }

    vClickAction(activity, 'Click');
    Delay(500);

    var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
    var menuPropArray = new Array("Name", "DataContext.Name.OleValue");
    var menuValuesArray = new Array('WPFObject("MenuItem", "", *)', activityName);

    var selected = menuList.FindChild(menuPropArray, menuValuesArray, MAX_CHILDS);
    if (!selected.Exists)
    {
      vCheckpoint("Activity : " + activityName + " not found!");
      return;
    }

    var deleteButton = selected.FindChild("Name", 'WPFObject("Button", "", 1)', MAX_CHILDS);
    vClickAction(deleteButton, 'Click');

    var deletePopUp = appendNewestWindowByHandle(TDWinType.WPF);
    deletePopUp = deletePopUp.FindChild(new Array("Name", "Title.OleValue"), new Array('WPFObject("window")', 'Activity'), MAX_CHILDS);
    if (!deletePopUp.Exists)
    {
      Log.Error("Delete Pop Up Window not found!");
      return;
    }

    var button = deletePopUp.FindChild("WPFControlText", button, MAX_CHILDS);
    if (!button.Exists)
    {
      Log.Error("Button : " + button + " not found!");
      return;
    }
    vClickAction(button, 'Click');

    if (verifyIfActivityAvailable(activityName))
      Log.Error("Activity : [" + activityName + "] not deleted!");
    else
      vCheckpoint("Activity : [" + activityName + "] deleted!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function restartApplication(userName)
{
  try
  {
    TD_GlobalVariables.getApplicationDetails();
    if (!userName || userName == "")
    {
      recordCurrentLoggedinUserAndBuildNo();
      if (!LoggedInUser || areStringValuesEqual(LoggedInUser, ""))
      {
        Log.Error("Unable to determine the current logged in user!");
        return;
      }
    }

    logOff();
    if (!Reporter.TC_RESULT)
      return;

    if (!userName || userName == "")
      var userType = DetermineUserTypeFromUserName(LoggedInUser);
    else
      var userType = DetermineUserTypeFromUserName(userName);

    if (!userType || userType == "")
    {
      Log.Error("Unable to determine the user type of current logged in user!");
      return;
    }

    var EnvKeyRecordset = DetermineEnvToLaunch(userType);
    if (InitializeTestEnv(EnvKeyRecordset))
      vCheckpoint("Login Successful!");
    else
      Log.Error("Test Environment could not be initialized!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function logOff()
{
  Log.Checkpoint("Logoff successful!");
}

//Logs off from TD application
//function logOff()
//{
//  try
//  {
//    var tdMainBar = Aliases.Citi_TD_ViewController.TDMainBar.window;
//    var activity = tdMainBar.FindChild("Name", 'WPFObject("MenuItem", "", *)', MAX_CHILDS);
//    if (!activity.Exists)
//    {
//      Log.Error("Activity button not found in the menu bar!");
//      return;
//    }
//
//    var hamburgerMenu = tdMainBar.FindChild("Name", 'WPFObject("TextBlock", "≡", 1)', MAX_CHILDS);
//    if (!hamburgerMenu.Exists)
//    {
//      Log.Error("Hamburger Menu not found!");
//      return;
//    }
//    vClickAction(hamburgerMenu, 'Click');
//    Delay(500);
//
//    var menuList = tdViewControllerProcess.FindChild("Name", 'WPFObject("SubMenuBorder")', MAX_CHILDS);
//
//    var selected = menuList.FindChild("Name", 'WPFObject("MenuItem", "Exit", *)', MAX_CHILDS);
//    if (!selected.Exists)
//    {
//      Log.Error("[About] option not found in hamburger menu!");
//      return;
//    }
//    vClickAction(selected, 'Click');
//
//    Delay(2000);
//
//    var logOffPopUp = appendNewestWindowByHandle(TDWinType.WPF);
//    logOffPopUp = logOffPopUp.FindChild(new Array("Name", "Title.OleValue"), new Array('WPFObject("window")', 'Rates TD'), MAX_CHILDS);
//    if (!logOffPopUp.Exists)
//    {
//      Log.Error("Delete Pop Up Window not found!");
//      return;
//    }
//
//    var exitButton = logOffPopUp.FindChild("WPFControlText", 'Exit', MAX_CHILDS);
//    if (!exitButton.Exists)
//    {
//      Log.Error("Exit button not found!");
//      return;
//    }
//    vClickAction(exitButton, 'Click');
//    Delay(6000);
//    Sys.Refresh();
//
//    if (!isAppClosed(tdElectronServerProcess, 1000, 60))
//      Log.Error("Unable to log off!");
//    else
//      vCheckpoint("Logged off successfully!");
//  }
//  catch (e)
//  {
//    Log.Error(e);
//  }
//}
