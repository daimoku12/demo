//USEUNIT Reporter
//USEUNIT Utility

function KillAllExistingInstancesOfApp(strAppName)
{
  try
  {
    Sys.Refresh();
  
    //Sys.Process(strProcessName) results into a FAILURE mark in the report if the process is not found.
    //Inorder to avoid false alarm of failure in test execution, the below looping logic is implemented  
    for (i = 0; i < Sys.ChildCount; i++)
    {
      p = Sys.Child(i);

      if(contains(p.ProcessName, strAppName, false, true) && p.Exists)
      { 
        Reporter.vMessage("Found App Instance with Process Id: " + p.Id + " IsOpen: " + p.IsOpen);             
        p.Terminate();  

        try
        {
          p.Close();
        }
        catch(e)
        {
          Reporter.vMessage("Something went wrong! Error message : " + e.message);          
        }        
        Reporter.vMessage("Terminated successfully");  
      }                
    }
    Sys.Refresh();
  }
  catch (e)
  {  
    Log.Error(e);
  }
}

function KillProcessContainingTextInCommandLine(strAppName, criteria)
{
  try
  {
    Sys.Refresh();
  
    //Sys.Process(strProcessName) results into a FAILURE mark in the report if the process is not found.
    //Inorder to avoid false alarm of failure in test execution, the below looping logic is implemented  
    for (i = 0; i < Sys.ChildCount; i++)
    {
      p = Sys.Child(i);

      if(p.Exists && contains(p.ProcessName, strAppName, false) && contains(p.CommandLine, criteria, false))
      { 
        vMessage("Found App Instance with Process Id: " + p.Id + " IsOpen: " + p.IsOpen);             
        p.Terminate();  

        try
        {
          p.Close();
        }
        catch(e)
        {
          vMessage("Something went wrong! Error message : " + e.message);          
        }        
        vMessage("Terminated successfully");  
      }                
    }
    Sys.Refresh();
  }
  catch (e)
  {  
    Log.Error(e);
  }
}

function KillProcessContainingTextInCommandLine1(processName, criteria)
{
  try
  {
    Sys.Refresh();
    for (j = 0; j < criteria.length; j++)
    {
      var p = Sys.FindChild(new Array("Name", "CommandLine"), new Array('Process("Citi.TD.ElectronWindowServe*")', "*" + criteria[j] + "*"), 0);
      if (p.Exists)
      { 
        vMessage("Found App Instance with Process Id: " + p.Id + " IsOpen: " + p.IsOpen);             
        p.Terminate();

        try
        {
          p.Close();
        }
        catch(e)
        {
          vMessage("Something went wrong! Error message : " + e.message);          
        }        
        vMessage("Terminated successfully");
      }
      //Sys.Refresh();
    }
  }
  catch (e)
  {  
    Log.Error(e);
  }
}

function getMemoryUsageOfAppInstance(strAppName)
{
  try
  {
    var MemoryUsage = -1;
    Sys.Refresh();
    //Sys.Process(strProcessName) results into a FAILURE mark in the report if the process is not found.
    //Inorder to avoid false alarm of failure in test execution, the below looping logic is implemented
    for (i = 0; i < Sys.ChildCount; i++)
    {
      p = Sys.Child(i);
      if (p.ProcessName == strAppName)
      {
        Reporter.vDebug("Found App Instance with Process Id: " + p.Id + " MemoryUsage: " + p.MemUsage + "KB");
        MemoryUsage = p.MemUsage;
      }
    }
    return MemoryUsage;
  }
  catch (e)
  {
    Log.Error(e);
  }
}
