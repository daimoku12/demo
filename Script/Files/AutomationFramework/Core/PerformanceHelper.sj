//USEUNIT Reporter
//USEUNIT Utility
//USEUNIT ExcelUtility

function GetPerformanceMetricsByProcessName(strAppName)
{
 
  var PerformanceMetricsDict = Sys.OleObject("Scripting.Dictionary");
  Sys.Refresh();
  //Sys.Process(strProcessName) results into a FAILURE mark in the report if the process is not found.
  //Inorder to avoid false alarm of failure in test execution, the below looping logic is implemented
  var TotalProcesses = Sys.ChildCount;
  for (i = 0; i < TotalProcesses; i++)
  {
    p = Sys.Child(i);
    if( p.ProcessName == strAppName)
    { 
      Reporter.vDebug("Found App Instance with Process Id: " + p.Id + " MemoryUsage: " + p.MemUsage + "KB");
      PerformanceMetricsDict.Add("MemoryUsage",p.MemUsage)
      PerformanceMetricsDict.Add("CPUUsage",p.CPUUsage)
      PerformanceMetricsDict.Add("VMSize",p.VMSize)
      PerformanceMetricsDict.Add("HandleCount",p.HandleCount)
    }
  }
  return PerformanceMetricsDict;
}

function CaptureMemoryDumpInExcel(xlsxRecordset,MemoryDumpxlsxCon,Operationdescription,Interval,Iteration,EnvVersion)
{
  var strSql1 = 'Select max(RowNum)+1 from [MemoryStats$]';
  var MaxRowNumRecordSet = ExcelUtility.vGetRecordset(MemoryDumpxlsxCon, strSql1);
  
  Reporter.vMessage("MaxRowNumRecordSet:" + MaxRowNumRecordSet.Fields.Item(0).Value)
      
  var PerfStatsDict = GetPerformanceMetricsByProcessName(xlsxRecordset.Fields.Item("ApplicationInstanceName").Value)
  var strSql2 = "Insert Into [MemoryStats$] Values('"+MaxRowNumRecordSet.Fields.Item(0).Value+"','"+xlsxRecordset.Fields.Item("RowNum").Value+"','"+xlsxRecordset.Fields.Item("ScenarioName").Value+"','"+GetTodayDateInGivenFormat("%m-%d-%y")+"','"+GetFormattedCurrentTimeStamp("%H:%M:%S")+"','"+EnvVersion+"','"+Operationdescription+"',"+PerfStatsDict.Item("MemoryUsage")/1024+","+PerfStatsDict.Item("CPUUsage")+","+PerfStatsDict.Item("VMSize")/1024+","+PerfStatsDict.Item("HandleCount")+")";
  ExcelUtility.vExecuteUpdateQuery(MemoryDumpxlsxCon, strSql2);

  for (var i=0; i<Iteration; i++)
  {
    Delay(Interval)
    PerfStatsDict = GetPerformanceMetricsByProcessName(xlsxRecordset.Fields.Item("ApplicationInstanceName").Value)
    var MaxRowNumRecordSet = ExcelUtility.vGetRecordset(MemoryDumpxlsxCon, strSql1);
    var strSql2 = "Insert Into [MemoryStats$] Values('"+MaxRowNumRecordSet.Fields.Item(0).Value+"','"+xlsxRecordset.Fields.Item("RowNum").Value+"','"+xlsxRecordset.Fields.Item("ScenarioName").Value+"','"+GetTodayDateInGivenFormat("%m-%d-%y")+"','"+GetFormattedCurrentTimeStamp("%H:%M:%S")+"','"+EnvVersion+"','"+Operationdescription+"',"+PerfStatsDict.Item("MemoryUsage")/1024+","+PerfStatsDict.Item("CPUUsage")+","+PerfStatsDict.Item("VMSize")/1024+","+PerfStatsDict.Item("HandleCount")+")";
    ExcelUtility.vExecuteUpdateQuery(MemoryDumpxlsxCon, strSql2);
  }
}
