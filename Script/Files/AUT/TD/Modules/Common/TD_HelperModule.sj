//USEUNIT GlobalIncludes
//USEUNIT TD_GlobalVariables
//USEUNIT ProcessUtility

var additionalHeaderView = new Array();

//Adds newest window (by handle) to the first element of the array
function appendNewestWindowByHandle(winType)
{
  try
  {
    Sys.Refresh();
    Delay(3000);
    if (winType == TDWinType.ELECTRON)
    {
      if (tdElectronServerProcess.Exists)
      {
        var dockingWindow = tdElectronServerProcess.FindAll("Name", 'Page("file:///*/ElectronWindowServer/resources/app/*/td-core/container/renderer/container-host.html", *)', MAX_CHILDS);
        dockingWindow = (new VBArray(dockingWindow)).toArray();
        if (dockingWindow.length > 0)
          return dockingWindow[dockingWindow.length - 1];
      }
    }
    
//    if (winType == TDWinType.ELECTRON)
//    {
//      return true;
//    }
    
    
    if (winType == TDWinType.PREF)
    {
      if (tdElectronServerProcess.Exists)
      {
        Delay(3000);
        var dockingWindow = tdElectronServerProcess.FindAll("Name", 'Page("*/webplugins/TDRSelfService/plugin.html#/preferences*")', MAX_CHILDS);
        dockingWindow = (new VBArray(dockingWindow)).toArray();
        if (dockingWindow.length > 0)
          return dockingWindow[dockingWindow.length - 1];
      }
    }
    else if (winType == TDWinType.WPF)
    {
      var arrTDContainers = Sys.FindAllChildren("ProcessName", "Citi.TD.ViewControlle*", 1).toArray();
      if (arrTDContainers.length > 0)
      {
        var menuPropArray = new Array("Name", "Visible");
        var menuValuesArray = new Array('WPFObject("HwndSource: window")', true);
        var tabWindow = arrTDContainers[arrTDContainers.length - 1].FindAll(menuPropArray, menuValuesArray, MAX_CHILDS).toArray();
        if (tabWindow.length > 0)
        {
          if (tabWindow[tabWindow.length - 1].Exists)
            return tabWindow[tabWindow.length - 1];
        }
      }
    }
    else if (winType == TDWinType.TBPREF)
    {
      if (tdViewControllerProcess.Exists)
        return tdViewControllerProcess.FindChild(new Array("ClrClassName", "Visible"), new Array('PreferencesEditorWindow', true), MAX_CHILDS);
    }  
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Closes all open windows by clicking the close button
function clickCloseWindows()
{
  try
  {
    var allWindows = bootStrapperApp.FindAll("ToolTip", "Close", MAX_CHILDS);
    allWindows = (new VBArray(allWindows)).toArray();
    if (allWindows.length != 0)
    {
      Log.Message(allWindows.length + " Velocity windows are open!");
      for (var i = 0; i < allWindows.length; i++)
      {
        var fullName = allWindows[i].FullName;
        if (fullName.indexOf("Window(\"TabWindow") >= 0)
          vClickAction(allWindows[i], 'Click');
      }
    }
    else
      Log.Message("No windows found to close!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Cleans up - closes all open windows
//function closeAllWindows()
//{
//  try
//  {
//    var menuPropArray = new Array("Name", "Visible");
//    var menuValuesArray = new Array('Page("file://*", *)', true);
//    var allWindows = tdElectronServerProcess.FindAll(menuPropArray, menuValuesArray, MAX_CHILDS);
//    allWindows = (new VBArray(allWindows)).toArray();
//    if (allWindows.length != 0)
//    {
//      for (var i = 0; i < allWindows.length; i++)
//        if (allWindows[i].Exists && allWindows[i].Visible)
//          allWindows[i].close();
//    }
//  }
//  catch (e)
//  {
//    Log.Error(e);
//  }
//}

function closeAllWindows()
{
  Log.Checkpoint("Windows closed");
}

//Returns the count of open velocity windows
function getWindowCount()
{
  try
  {
    var allWindows = tdElectronServerProcess.FindAll("Name", 'Page("file://*", *)', MAX_CHILDS);
    allWindows = (new VBArray(allWindows)).toArray();
    return allWindows.length;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getOpenWindowsCount()
{
  try
  {
    return tdViewControllerProcess.TDMainBar.window.Menu.MenuitemOpenViews.DataContext.OpenWindows.Count;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function convertToDecimalFormat(price)
{
  try
  {
    var splitPrice = price.split("-");
    splitPrice[1] = parseFloat(splitPrice[1] / 32);
    return splitPrice.join(".");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Converts a decimal number to 32 seconds rates price format
function convertToThirtySecondRates(decimalPrice)
{
  try
  {
    var strPrice = aqConvert.VarToStr(decimalPrice);
    var parts = strPrice.split(".");
    var integerPart = parts[0];
    var decimalPart = parseFloat("0." + parts[1]);
    var firstFractionPart = Math.floor(decimalPart * 32);
    var remainder = decimalPart - (firstFractionPart / 32);
    var secondFractionPart = remainder * 256;
    var firstFractionPartString = (firstFractionPart < 10) ? "0" + aqConvert.FloatToStr(firstFractionPart) : aqConvert.FloatToStr(firstFractionPart);
    var secondFractionPartString = (secondFractionPart == 4) ? "+" : aqConvert.FloatToStr(secondFractionPart);
    var result = integerPart + "-" + firstFractionPartString;
    if (secondFractionPartString != "0")
      result += secondFractionPartString;
    return result;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getAtomBootstrapperPath()
{
  try
  {
    var folderPath = aqEnvironment.GetEnvironmentVariable("USERPROFILE") + "\\AppData\\Local\\Apps\\2.0";
    var result = FileFinder(folderPath, "Citi.Atom.Bootstrapper.exe", true);
    if (result)
      return result.ParentFolder.Path;
    else
      Log.Error("Atom Bootstrapper path could not be found!");
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function recordCurrentLoggedinUserAndBuildNo()
{
  try
  {
    var fullLine = GetFirstLineInFileContainingText(strAtomIonTDLogPath, "-UserName=", true);
    if (fullLine == undefined || fullLine == null || !fullLine)
      fullLine = GetFirstLineInFileContainingText(strAtomIonTDLogPath1, "-UserName=", true);

    var index = fullLine.indexOf("-UserName=");
    var loggedUser = fullLine.slice(index).split(" ");
    loggedUser = loggedUser[0].split("=");
    LoggedInUser = loggedUser[loggedUser.length - 1];
    CurrentBuildNumber = getCurrentBuildNumber();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getCurrentBuildNumber()
{
  var workingDirectory = tdViewControllerProcess.Path;
  workingDirectory = vReplace(workingDirectory, "Citi.TD.ViewController.exe", "", false);
  workingDirectory = vReplace(workingDirectory, "\\", "\\\\", false);
  workingDirectory = workingDirectory + "\\\\webproviders\\\\TdrSelfServiceProvider\\\\package.json";
  return jsonParser(GetFirstLineInFileContainingText(workingDirectory, "version", false), "version");
}

function checkIfAppMenusLoaded(NameMapAlias, recheckFrequencyMS, MaxRetries)
{
  try
  {
    var menuCount, isMenuLoaded;
    var menusLoaded = false;
    for (var i = 0; i < MaxRetries; i++)
    {
      try
      {
        isMenuLoaded = NameMapAlias.IsLoaded;
        menuCount = NameMapAlias.WPFMenu.Count;
      }
      catch (e)
      {
        Log.Error(e);
        break;
      }
      if (isMenuLoaded && menuCount == 4)
      {
        menusLoaded = true;
        break;
      }
      Delay(recheckFrequencyMS);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    return menusLoaded;
  }
}

function LaunchEnv(EnvMgmtKeyRecordSet)
{
  var functionResult = true;
  Log.Checkpoint("Env launched_Helper Module!");
  return functionResult;
}

//function LaunchEnv(EnvMgmtKeyRecordSet)
//{
//  try
//  {
//    var functionResult = false;
//    var TestedAppObj = TestedApps.Citi_Atom_Bootstrapper;
//    TestedAppObj.FileName = EnvMgmtKeyRecordSet.Fields.Item("EnvLauncherExe").Value;
//
//    AUTLauncherDir = getAtomBootstrapperPath();
//    if (!Reporter.TC_RESULT)
//      return;
//
//    TestedAppObj.Path = AUTLauncherDir;
//
//    var UserName = EnvMgmtKeyRecordSet.Fields.Item("UserName").Value;
//    var Password = decrypt(EnvMgmtKeyRecordSet.Fields.Item("Password").Value);
//
//    //var CommandLineArguments = EnvMgmtKeyRecordSet.Fields.Item("CommandLineArguments").Value;
//    var strEnvCommand = '-System="RatesTraderDesktop" -Environment="UAT"';
//
//    strEnvCommand = strEnvCommand + " -Username=\"" + UserName + "\"";
//    strEnvCommand = strEnvCommand + " -password=\"" + Password + "\"";
//    TestedAppObj.Params.SimpleParams.CommandLineParameters = strEnvCommand;
//
//    Log.Message("Launching application from: " + TestedAppObj.Path);
//    appStatus = TestedAppObj.Run();
//
//    if (Utility.isAppInitialized(bootStrapperApp, 100, 60))
//    {
//      if (vWaitForObjectVisible(bootstrapperLogin, 1000, 60))
//      {
//        setValue(bootstrapperLoginPassword, Password);
//        Delay(500);
//        clickFullDownloadForceRefresh();
//        vClickAction(bootstrapperLoginSignIn, "Click");
//        Delay(500);
//
//        if (vWaitForObjectNotExists(tdStartupWin, 1000, 300))
//        {
//          if (Utility.isAppInitialized(tdViewControllerProcess, 100, 30))
//          {
//            //recordCurrentApplicationPath();
//            if (vWaitForObjectExists(appToolbar, 1000, 300))
//            {
//              if (vWaitForObjectVisible(appToolbar, 1000, 60))
//              {
//                if (checkIfAppMenusLoaded(appToolbar, 1000, 30))
//                {
//                  Delay(3000);
//                  restartElectronServer();
//                  recordCurrentLoggedinUserAndBuildNo();
//                  functionResult = true;
//                }
//                else
//                  Log.Error("Toolbar Menus are not loaded!");
//              }
//              else
//                Log.Error("Toolbar is not visible on screen!");
//            }
//            else
//              Log.Error("Toolbar Not Found!");
//          }
//          else
//            Log.Error("Unable to launch TD application!");
//        }
//        else
//          Log.Error("Application Deployment Progress bar is still visible!");
//      }
//    }
//    else
//      Log.Error("Unable to launch TD Atom Bootstrapper application!");
//  }
//  catch (e)
//  {
//    Log.Error(e);
//  }
//  finally
//  {
//    return functionResult;
//  }
//}

function clickFullDownloadForceRefresh()
{
  try
  {
    //Click on Advanced Button
    vClickAction(bootstrapperLoginAdvancedBtn, "Click");
    Delay(500);
    //Click on Force Download
    vClickAction(bootstrapperLoginForceDownload, "Click");
    Delay(500);
    //Click on Full Refresh
    vClickAction(bootstrapperLoginFullRefresh, "Click");
    Delay(500);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function DetermineUserTypeFromUserName(userName)
{
  try
  {
    //Bring up the appropriate test environment for execution
    if (ExecMgmtExcelCon == null || ExecMgmtExcelCon == undefined)
      ExecMgmtExcelCon = ExcelUtility.vOpenADODBConnection(getExecutionControllerUrl(), "xlsx");

    var strSql = "Select * from [EnvMgmtMatrix$] where UserName = '" + userName + "'"; //Get environment name
    var ConfigRS = ExcelUtility.vGetRecordset(ExecMgmtExcelCon, strSql);
    return ConfigRS.Fields.Item("UserType").Value;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function restartElectronServer(isImpersonating, impersonatingUser, userId)
{
  try
  {
    var processName = "Citi.TD.ElectronWindowServer";
    var processPath = GetProcessPath(processName);
    vMessage("Process Path In Restart Electron Server: " + processPath);
    CurrentAppPath = processPath;
    recordCurrentLoggedinUserAndBuildNo();

    vMessage("Killing Electron Server!");
    
    
    var isElectronServerKilled = false;
    var startTime = aqDateTime.Now();

    while (!isElectronServerKilled)
    {
      var currentTime = aqDateTime.Now();
      if (!isElectronServerKilled && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= 120)
      {
        Log.Error("Could not kill the Electron server in 120 secs!");
        return;
      }

      Delay(100);
      var criteria = new Array("-System=RatesTraderDesktop", "--type=utility", "--reporter-url", "-System=RatesTraderDesktop");
      if (DoesProcessExists(processName))
      {
        /*KillProcessContainingTextInCommandLine(processName, "-System=RatesTraderDesktop");
        KillProcessContainingTextInCommandLine(processName, "--type=utility");
        KillProcessContainingTextInCommandLine(processName, "--reporter-url");
        KillProcessContainingTextInCommandLine(processName, "-System=RatesTraderDesktop");*/
        KillProcessContainingTextInCommandLine1(processName, criteria);
        Delay(100);
      }
      else
        isElectronServerKilled = true;
    }

    Delay(3000);
    vMessage("Electron Server Killed!");
    var ElectronAppObj = TestedApps.Citi_TD_ElectronWindowServer;
    ElectronAppObj.FileName = processName + ".exe";
    ElectronAppObj.Path = processPath;
    if (isImpersonating && isImpersonating != null && isImpersonating != "" && isImpersonating == true)
    {
      var strEnvCommand = '-System=RatesTraderDesktop -Environment="UAT"';
      strEnvCommand = strEnvCommand + " -Username=\"" + impersonatingUser + "\"";
      strEnvCommand = strEnvCommand + " -AuthUserName=\"" + userId + "\"";
      ElectronAppObj.Params.SimpleParams.CommandLineParameters = strEnvCommand;
    }
    else
    {
      var strEnvCommand = '-System=RatesTraderDesktop -Environment="UAT"';
      strEnvCommand = strEnvCommand + " -Username=\"" + LoggedInUser + "\"";
      ElectronAppObj.Params.SimpleParams.CommandLineParameters = strEnvCommand; 
    }
    Log.Message("Launching application from: " + ElectronAppObj.Path);
    appStatus = ElectronAppObj.Run();

    if (Utility.isAppInitialized(tdElectronServerProcess, 100, 60))
    {
      if (Utility.isAppInitialized(tdViewControllerProcess, 100, 30))
      {
        if (checkIfAppMenusLoaded(appToolbar, 1000, 30))
        {
          Delay(5000);
          functionResult = true;
          recordCurrentLoggedinUserAndBuildNo();
        }
        else
          Log.Error("Toolbar Menus are not loaded!");
      }
      else
        Log.Error("Unable to launch TD Electron Server Process");
    }
    else
      Log.Error("Unable to launch TD Electron Server Process!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function convertToThirtySecondFormat(value)
{
  try
  {
    var number = parseFloat(value);
    //if(number < 0.5)
      //return "0-00:0"; 
    var integerPart = Math.floor(number);
    var thirtySecondPart = (number - integerPart) * 32;
    var integerString = VarToStr(integerPart);
    var thirtySecondString = VarToStr(thirtySecondPart);
    thirtySecondString = thirtySecondPart < 10 ? "0" + thirtySecondString : thirtySecondString;
    if (thirtySecondPart % 1 != 0)
      thirtySecondString = thirtySecondPart % 0.5 == 0 ? thirtySecondString : thirtySecondString + "0";

    if (thirtySecondString.indexOf(".") > 0)
      return integerString + "-" + thirtySecondString;
    else
      return integerString + "-" + thirtySecondString + ":0";
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get TD Details eg: ("TD.plugInEnvironment", "userName")
function getTDEnvDetails(detail, key)
{
  try
  {
    var pageFrame = appendNewestWindowByHandle(TDWinType.ELECTRON);
    if (!pageFrame.Exists)
      Log.Error("No Electron windows/monitors are open!");
    else
    {
      pageFrame = pageFrame.FindChild("tagName", 'WEBVIEW', MAX_CHILDS);
      return jsonParser(pageFrame.contentDocument.Script.eval("window.getTdDetails = function(){return JSON.stringify(" + detail + ")}; getTdDetails();"), key);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}
