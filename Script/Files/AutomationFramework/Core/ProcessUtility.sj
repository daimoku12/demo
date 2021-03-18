//USEUNIT EnvironmentVariables
//USEUNIT Reporter

function vProcessExists(strProcessName)
{
  var oProcess = Sys.WaitProcess(strProcessName, 0);  
  var bProcessExists = oProcess.Exists;
  
  vDebug("Process exists check result for " + strProcessName + " was: " + bProcessExists);
  
  return bProcessExists;
}

function vLaunchProcessShowNormal(strProcessName)
{
  try
  {
    WshShell.Run(strProcessName, SW_SHOWNORMAL);
    vDebug("Call to launch process " + strProcessName + " appeared to be fine!");
  } 
  catch(e)
  {
    vError("Attempt to run process " + strProcessName + " resulted in the following error: " + e);
  } 
}

function vCloseProcess(strProcessName)
{
  var oProcess;
  oProcess = Sys.WaitProcess(strProcessName, 0);

  if(oProcess.Exists)
  {    
    try
    {
      oProcess.Terminate();
      vDebug("Call to terminate process " + strProcessName + " appeared to be fine");
      return true;
    }
    catch (e)
    {
      vError("Attempt to terminate process " + strProcessName + " resulted in the following error: " + e);
      return false;
    }
  }
  else
  {
    vDebug("Could not get handle on process " + strProcessName);
    return false;      
  }    
}