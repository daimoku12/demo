//USEUNIT EnvironmentVariables

//******************************************************************************************************************************
//CORE GLOBAL VARIABLES
//******************************************************************************************************************************
function getApplicationDetails()
{
  try
  {
    CurrentAppCode = "TD";
    CurrentAppName = "Trader Desktop";
    AUTProcessName = "Citi.Atom.Bootstrapper";
    ProcesssList = new Array("Citi.TD.ElectronWindowServer", "Citi.Atom.Bootstrapper");
    AUTLoginBufferTime = 60000;
    //LoggedInUser = "";
    CurrentBuildNumber = "";
    CurrentAppPath = null;
    //bootStrapperApp = Aliases.Citi_Atom_Bootstrapper;
    //bootStrapperAppArray = new Array(Aliases.Citi_TD_ElectronWindowServer, Aliases.Citi_Atom_Bootstrapper);
    //appToolbar = Aliases.Citi_TD_ViewController.TDMainBar.window.Menu;
  }
  catch (e)
  {
    Log.Error(e, argumnets.callee);
  }
}

//bootStrapperApp = Aliases.Citi_Atom_Bootstrapper;
CurrentAppCode = "TD";

//******************************************************************************************************************************
//Data Workbook (Test Data) Names
//******************************************************************************************************************************
var DWB_TD = "TD_TestData.xlsx";
var TestSuites_TD = "TD_TestSuites.xlsx";
var TDWinType = new Enumerator();
TDWinType.ELECTRON = "Electron";
TDWinType.WPF = "Wpf";
TDWinType.PREF = "Pref";
TDWinType.TBPREF = "TbPref";

//var strAtomIonTDLogPath = aqEnvironment.GetEnvironmentVariable("USERPROFILE") + "\\AppData\\Local\\Temp\\Atom.ION.Provider_RatesTraderDesktop.log";
//var strAtomIonTDLogPath1 = aqEnvironment.GetEnvironmentVariable("USERPROFILE") + "\\AppData\\Local\\Temp\\Atom.ION.Provider_RatesTraderDesktop.log.1";

//******************************************************************************************************************************
//NAMING CONVENTIONS
//******************************************************************************************************************************
// td             - Trader Desktop
// PrefWin        - Preferences Window
// X              - Close

//******************************************************************************************************************************
//TD APP
//******************************************************************************************************************************
//var tdStartupWin                          = bootStrapperApp.HwndSource_StartupWindow.StartupWindow;
//var tdViewControllerProcess               = Aliases.Citi_TD_ViewController;
//var tdElectronServerProcess               = Aliases.Citi_TD_ElectronWindowServer;
//
//appToolbar                                = tdViewControllerProcess.TDMainBar.window.Menu;
//
//var bootstrapperLogin                     = bootStrapperApp.HwndLoginWindow.LoginWindow;
//var bootstrapperLoginPassword             = bootstrapperLogin.txtPassword;
//var bootstrapperLoginSignIn               = bootstrapperLogin.btnSignIn;
//var bootstrapperLoginAdvancedBtn          = bootstrapperLogin.advancedButton;
//var bootstrapperLoginForceDownload        = bootstrapperLogin.CheckboxForceDownload;
//var bootstrapperLoginFullRefresh          = bootstrapperLogin.CheckboxFullRefresh;
//var countInStatusBar                      = tdElectronServerProcess.countInStatusBar;