//USEUNIT GlobalIncludes
//USEUNIT EmailModule
//USEUNIT FileUtility

function Execute()
{
  try
  {
    Log.LockEvents(0);
    Log.Message("Driver script executing on HostName: " + Sys.HostName);

    DriverInitiationTime = Utility.getFormattedCurrentTimeStamp("%H.%M.%S");
    DriverInitiationDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%y");    

    ParseCommandLineData();

    InitializeExecutionControllerConfig();

    if (JobName)
      JenkinsJobName = JobName;

    if (BuildNo)
      JenkinsBuildNo = BuildNo;

    if (Workspace)
      JenkinsWorkspace = Workspace + "/";
    else
      JenkinsWorkspace = JenkinsWorkspace + JenkinsJobName + "/";

    HTMLResultFile = JenkinsWorkspace + HTMLResultFile;
    HTMLResultFile = Utility.vReplace(HTMLResultFile, "/", "\\", false);

/*    if (JenkinsBuildType)
      AUTBuildType = JenkinsBuildType;

    if (JenkinsAUTLauncherDir)
      AUTLauncherDir = JenkinsAUTLauncherDir;
*/
    EmailModule.DeleteHTMLFile(HTMLResultFile);

    InitializeJobJournalPaths();

    Log.Message("overrideTestModule: " + overrideTestModules);
    if (overrideTestModules == "" || overrideTestModules == undefined)
      var strSql = "Select * from [ModuleMgmt$] where Active = 'Y'"; //Get environment name
    else
      var strSql = "Select * from [ModuleMgmt$] where ModuleName IN (" + overrideTestModules + ")"; //Get environment name

    ModulesRS = ExcelUtility.vGetRecordset(ExecMgmtExcelCon, strSql);
    if (!ModulesRS.BOF)
      ModulesRS.MoveFirst();

    while (!ModulesRS.EOF)
    {
      SetupJobJournal();
      try
      {
        ExecuteIndividualModule(ModulesRS);
      }
      catch (e)
      {
        Log.Error(e);
      }
      finally
      {
        CloseJobJournal();
        if (!Reporter.TS_RESULT && Reporter.TS_REMARKS == Reporter.TEST_ENV_FAILED_MSG)
          break;
        else
          ModulesRS.MoveNext();
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    Close_RS_Conn_ForTestExecInstance();
    ExportTestResults();
    Log.Message("Memory Footprint at end of execution: " + getMemoryUsageOfAppInstance(AUTProcessName) + "KB!");
  }
}

function InitializeExecutionControllerConfig()
{
  try
  {
    ExecMgmtExcelCon = ExcelUtility.vOpenADODBConnection(getExecutionControllerUrl(), "xlsx");
    Runner.CallMethod(getApplicationCode() + "_GlobalVariables." + "getApplicationDetails");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function InitializeJobJournalPaths()
{
  try
  {
    //strTestExecutionJournal = strProjectBaseFolder + "Log/" + "Report_" + DriverInitiationDate + "_" + DriverInitiationTime + "_" + JenkinsJobName + "_" + JenkinsBuildNo + ".xlsx";
    strTestExecutionJournal = JenkinsWorkspace + "Report_" + DriverInitiationDate + "_" + DriverInitiationTime + "_" + JenkinsJobName + "_" + JenkinsBuildNo + ".xlsx";
    Log.Message("strTestExecutionJournal: " + strTestExecutionJournal);
    TestReportNameMht = "Report_" + DriverInitiationDate + "_" + DriverInitiationTime + "_" + JenkinsJobName + "_" + JenkinsBuildNo + ".mht";
    aqFileSystem.CopyFile(TestExecutionJournalTemplate, strTestExecutionJournal, true);
  }
  catch (e)
  {
    Log.Error(e);
  }  
}

function SetupJobJournal()
{
  try
  {
    var JournalRecordCount = 0;
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");
    var strSql = "Select * from [Journal$];";
    var ConfigRS = ExcelUtility.vGetRecordset(ExecJournalExcelCon, strSql);
	
    JournalRecordCount = vGetRecordCountInRecordset(ConfigRS);
    CurrentJobRowNum = JournalRecordCount + 1;
    CurrentJobRowNum = aqConvert.StrToInt(CurrentJobRowNum);
    
    var strSQL = "INSERT INTO [Journal$] (RowNum, JobName, JobBuildNo, JobStartDate, JobStartTime, JobStatus) Values (" + CurrentJobRowNum + ", '" + JenkinsJobName + "', '" + JenkinsBuildNo + "', '" + DriverInitiationDate + "', '" + DriverInitiationTime + "', 'Running');";

    //Append a row at the end
    ExecJournalExcelCon.Execute(strSQL);
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function CloseJobJournal()
{
  try
  {
    var JobEndDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
	var JobEndTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
	
    var strSQL = "UPDATE [Journal$] SET [JobEndDate] = '" +JobEndDate+ "',[JobEndTime] = '" + JobEndTime + "' , [JobStatus] = 'Completed' WHERE [RowNum] = '" + CurrentJobRowNum + "' ";
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");
    ExcelUtility.vExecuteUpdateQuery(ExecJournalExcelCon, strSQL);
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function SetupTSJournal(ModulesRS, TestSuitesRS)
{
  try
  {
    var TSRecordCount = 0;
	  var TSStartDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
    var TSStartTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
    
    var ModuleID = ModulesRS.Fields.Item("RowNum").Value;
    var ModuleName = ModulesRS.Fields.Item("ModuleName").Value;
    
    var TestSuiteID = TestSuitesRS.Fields.Item("RowNum").Value;
    var TestSuiteName = TestSuitesRS.Fields.Item("TestSuiteName").Value;
    
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");

    var strSql = "Select * from [TSResults$]";
    var ConfigRS = ExcelUtility.vGetRecordset(ExecJournalExcelCon, strSql);
    TSRecordCount = vGetRecordCountInRecordset(ConfigRS);
    CurrentTSRowNum = TSRecordCount + 1;
    CurrentTSRowNum = aqConvert.StrToInt(CurrentTSRowNum);

    var strSQL = "INSERT INTO [TSResults$] (RowNum, JobRowID, ModuleID, ModuleName, TestSuiteID, TestSuiteName, TSResult, TSStartDate, TSStartTime) Values (" + CurrentTSRowNum + ", " + CurrentJobRowNum + ", " + ModuleID + ", '" + ModuleName + "', " + TestSuiteID + ", '" + TestSuiteName + "', 'Running','" + TSStartDate + "', '" + TSStartTime + "');";

    //Append a row at the end
    ExecJournalExcelCon.Execute(strSQL);
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function CloseTSJournal()
{
  try
  {
    var TSEndDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
	var TSEndTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
    if (TS_RESULT)
    {
      TS_RESULT = TestCaseResult.PASSED;
    }
    else
    {
      if (Reporter.TS_REMARKS != Reporter.TEST_ENV_FAILED_MSG)
      {
        TS_RESULT = TestCaseResult.FAILED;
        TS_REMARKS = FailedTestCases;
        TS_REMARKS = trimRemarks(TS_REMARKS);
      }
    }
    
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");
    var strSQL = "UPDATE [TSResults$] SET [TSEndDate] = '" + TSEndDate + "' ,[TSEndTime] = '" + TSEndTime + "' , [TSResult] = '" + TS_RESULT + "', [TSRemarks] = '" + TS_REMARKS + "' WHERE [RowNum] = '" + CurrentTSRowNum + "' ";
    Log.Message(strSQL);
    ExcelUtility.vExecuteUpdateQuery(ExecJournalExcelCon, strSQL);
  }
  catch (e)
  {
    Log.Error(e);
    var strSQL = "UPDATE [TSResults$] SET [TSEndDate] = '" + TSEndDate + "' , [TSEndTime] = '" + TSEndTime + "' , [TSResult] = '" + TS_RESULT + "' WHERE [RowNum] = '" + CurrentTSRowNum + "' ";
    ExcelUtility.vExecuteUpdateQuery(ExecJournalExcelCon, strSQL);    
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function SetupTCJournal(TestCaseRS)
{
  try
  {
    var TCRecordCount = 0;
	var TCStartDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
    var TCStartTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
    
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");

    var strSql = "Select * from [TCResults$]";
    var ConfigRS = ExcelUtility.vGetRecordset(ExecJournalExcelCon, strSql);
    TCRecordCount = vGetRecordCountInRecordset(ConfigRS);
    CurrentTCRowNum = TCRecordCount + 1;
    CurrentTCRowNum = aqConvert.StrToInt(CurrentTCRowNum);

    var TestCaseID = TestCaseRS.Fields.Item("RowNum").Value;
    var TestCaseName = TestCaseRS.Fields.Item("TestCaseName").Value;
	var TestCaseIdentifier = TestCaseRS.Fields.Item("TestCaseIdentifier").Value;

    var strSQL = "INSERT INTO [TCResults$] (RowNum, TestSuiteRowID, TestCaseID, TestCaseName, TestCaseIdentifier, TCResult, TCStartDate, TCStartTime) " + 
    "Values (" + CurrentTCRowNum + ", " + CurrentTSRowNum + ", " + TestCaseID + ", '" + TestCaseName + "', '" + TestCaseIdentifier + "', 'Running', '" + TCStartDate + "', '" + TCStartTime + "');";

    //Append a row at the end
    ExecJournalExcelCon.Execute(strSQL);
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function SetupTCJournalDataDriven(TestCaseRS, TestCaseName)
{
  try
  {
    var TCRecordCount = 0;
	
	var TCStartDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
    var TCStartTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
    
    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");
    var strSql = "Select * from [TCResults$]";
    var ConfigRS = ExcelUtility.vGetRecordset(ExecJournalExcelCon, strSql);
    TCRecordCount = vGetRecordCountInRecordset(ConfigRS);
    CurrentTCRowNum = TCRecordCount + 1;
    CurrentTCRowNum = aqConvert.StrToInt(CurrentTCRowNum);

    var TestCaseID = TestCaseRS.Fields.Item("RowNum").Value;
	var TestCaseIdentifier = TestCaseRS.Fields.Item("TestCaseIdentifier").Value;
	
    var strSQL = "INSERT INTO [TCResults$] (RowNum, TestSuiteRowID, TestCaseID, TestCaseName, TestCaseIdentifier, TCResult, TCStartTime) " + 
    "Values (" + CurrentTCRowNum + ", " + CurrentTSRowNum + ", " + TestCaseID + ", '" + TestCaseName + "', '" + TestCaseIdentifier + "', 'Running', '" + TCStartTime + "');";

    //Append a row at the end
    ExecJournalExcelCon.Execute(strSQL);
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function CloseTCJournal(TCResult)
{
  try
  {
    var TCEndDate = Utility.getFormattedCurrentTimeStamp("%d-%b-%Y");
	var TCEndTime = Utility.getFormattedCurrentTimeStamp("%H:%M:%S");
    if (TCResult)
    {
      if (TCResult.result)
        TC_RESULT = TestCaseResult.PASSED;
      else
      {
	    if (Reporter.TC_WARNING == true)
		  TC_RESULT = TestCaseResult.Warned;
		else 
          TC_RESULT = TestCaseResult.FAILED;		
	  }  
    }
    else
      TC_RESULT = TestCaseResult.FAILED;

    TCResult.remarks = trimRemarks(TCResult.remarks);
    TCResult.remarks = aqString.Replace(TCResult.remarks, "TestCase Passed!, ", "");
    TCResult.remarks = aqString.Replace(TCResult.remarks, "'", "");
    TCResult.remarks = aqString.Replace(TCResult.remarks, "\"", "");

    Log.Message(TCResult.remarks);

    var ExecJournalExcelCon = ExcelUtility.vOpenADODBConnection(strTestExecutionJournal, "xlsx");
    var strSQL = "UPDATE [TCResults$] SET [TCEndDate] = '" + TCEndDate + "' ,[TCEndTime] = '" + TCEndTime + "' , [TCResult] = '" + TC_RESULT + "', [TCRemarks] = '" + TCResult.remarks + "' WHERE [RowNum] = '" + CurrentTCRowNum + "' ";
    Log.Message(strSQL);
    ExcelUtility.vExecuteUpdateQuery(ExecJournalExcelCon, strSQL);
  }
  catch (e)
  {
    Log.Error(e);
    var strSQL = "UPDATE [TCResults$] SET [TCEndDate] = '" + TCEndDate + "' , [TCEndTime] = '" + TCEndTime + "' , [TCResult] = '" + TC_RESULT + "' WHERE [RowNum] = '" + CurrentTCRowNum + "' ";
    ExcelUtility.vExecuteUpdateQuery(ExecJournalExcelCon, strSQL);    
  }
  finally
  {
    ExecJournalExcelCon.Close();
  }
}

function ExecuteIndividualModule(ModulesRS)
{
  try
  {
    var ModuleWorkbookUrl = ModulesRS.Fields.Item("ModuleWorkbookUrl").Value;
    ModuleWorkbookUrl = getDataRepositoryFolder() + "/" + getApplicationCode() + "/" + ModuleWorkbookUrl;

    //Open specific TestSuite WORKBOOK
    Reporter.vDebug("ModuleWorkbookUrl: \"" + ModuleWorkbookUrl + "\"");
    Utility.setCurrentFolder(strProjectBaseFolder);
    ModuleExcelCon = ExcelUtility.vOpenADODBConnection("\"" + ModuleWorkbookUrl + "\"", "xlsx");

    if (overrideTestSuites == "" || overrideTestSuites == undefined)
      var strSql = "Select * from [Master$] where Active = 'Y' order by RowNum";
    else
      var strSql = "Select * from [Master$] where TestSuiteName IN (" + overrideTestSuites + ") order by RowNum";
    
    var TestSuitesRS = ExcelUtility.vGetRecordset(ModuleExcelCon, strSql);
    if (!TestSuitesRS.BOF)
      TestSuitesRS.MoveFirst();
    
    while (!TestSuitesRS.EOF)
    {
      Reporter.vDebug("Setting up TestSuite Journal!", "Setting up TestSuite Journal!", 100);
      SetupTSJournal(ModulesRS, TestSuitesRS);
      try
      {
        ExecuteIndividualTestSuite(TestSuitesRS, ModuleExcelCon);
      }
      catch (e)
      {
        Log.Error(e);
      }
      finally
      {
        CloseTSJournal();
      }

      if (!Reporter.TS_RESULT && Reporter.TS_REMARKS == Reporter.TEST_ENV_FAILED_MSG)
        break;
      else
        TestSuitesRS.MoveNext();
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    CloseTestSuiteRS(TestSuitesRS);
    ExitTestEnv();
  }
}

function ExecuteIndividualTestSuite(TestSuitesRS, ModuleExcelCon)
{
  try
  {
    var TestSuiteName = TestSuitesRS.Fields.Item("TestSuiteName").Value;
    var UserType = TestSuitesRS.Fields.Item("UserType").Value;
    var IsCEF = TestSuitesRS.Fields.Item("IsCEF").Value;
    var BeforeSuiteFileNFunction = TestSuitesRS.Fields.Item("BeforeSuiteFileNFunction").Value;
    var EnvKeyRecordset = DetermineEnvToLaunch(UserType);
    if (InitializeTestEnv(EnvKeyRecordset, IsCEF))
    {
      var TestSuiteLogFolderId = Log.CreateFolder("TestSuite Name: " + TestSuiteName);
      Log.PushLogFolder(TestSuiteLogFolderId);
      Reporter.vDebug("Executing Test Suite (" + TestSuiteName + ")", "Executing Test Suite (" + TestSuiteName + ")", 100);
      try
      {
        if (typeof BeforeSuiteFileNFunction === 'string' && aqString.Trim(BeforeSuiteFileNFunction) != "")
          Runner.CallMethod(BeforeSuiteFileNFunction);
		  
		if (customTestCaseAppendQueryParams == "" || customTestCaseAppendQueryParams == undefined)  
		  var strSql = "Select * from [" + TestSuiteName + "$] where Active = 'Y' order by RowNum";
		else
          var strSql = "Select * from [" + TestSuiteName + "$] where Active = 'Y' AND " + customTestCaseAppendQueryParams + " order by RowNum";		
          
        var TestCaseRS = ExcelUtility.vGetRecordset(ModuleExcelCon, strSql);
        if (!TestCaseRS.BOF)
        {
          TestCaseRS.MoveFirst();
        }
        Delay(2000);
        while (!TestCaseRS.EOF)
        {
          try
          {
            ExecuteIndividualTestCase(TestCaseRS, EnvKeyRecordset, IsCEF);
          }
          catch (e)
          {
            Log.Error(e);
          }
          TestCaseRS.MoveNext();
        }
      }
      catch (e)
      {
        Log.Error(e);
      }
      finally
      {
        CloseTestCaseRS(TestCaseRS);
        Log.PopLogFolder();
      }
    }
    else
    {
      Log.Error(Reporter.TEST_ENV_FAILED_MSG + " Exiting...");
      Reporter.TS_RESULT = false;
      Reporter.TS_REMARKS = Reporter.TEST_ENV_FAILED_MSG;      
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function ExecuteIndividualTestCase(TestCaseRS, EnvKeyRecordset, IsCEF)
{
  try
  {
    if (InitializeTestEnv(EnvKeyRecordset, IsCEF))
    {
      var TestFileName = TestCaseRS.Fields.Item("TestFileName").Value;
      var TestCaseName = TestCaseRS.Fields.Item("TestCaseName").Value;
      var IsDataDriven = TestCaseRS.Fields.Item("IsDataDriven").Value;

      var TestCaseLogFolderId = Log.CreateFolder("TestCaseName: " + TestFileName + "." + TestCaseName);
      Log.PushLogFolder(TestCaseLogFolderId);
      //Reporter.vDebug("TestCaseName: " + TestFileName + "." + TestCaseName, "TestCaseName: " + TestFileName + "." + TestCaseName, 100);
      try
      {
        InvokeTestScript(TestCaseRS, TestFileName, TestCaseName, IsDataDriven);
      }
      catch (e)
      {
        Log.Error(e);
      }
      finally
      {
        Log.PopLogFolder();
      }
    }
    else
      Log.Error(Reporter.TEST_ENV_FAILED_MSG + " Exiting..."); 
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//uncomment later
function InvokeTestScript(TestCaseRS, TestFileName, TestCaseName, IsDataDriven)
{
  try
  {
    var strCommand = TestFileName + "." + TestCaseName;
    Reporter.CONCAT_TC_REMARKS = false;
	  Reporter.TC_WARNING = false;
    Reporter.TC_RESULT = true;
    Reporter.TC_REMARKS = "TestCase Passed!";
    Runner.CallMethod(getApplicationCode() + "_HelperModule." + "closeAllWindows");
    //vFocus(appToolbar);
    
    //Non DataDriven Workflow
    if (typeof IsDataDriven === 'string' && IsDataDriven != "Y")
    {
      SetupTCJournal(TestCaseRS);

      try
      {
        var TCResult = Runner.CallMethod(strCommand);
      }
      catch(e)
      {
        Log.Error("Aborting test script execution due to runtime error!");
      }

      if (TCResult)
      {
        TCResult.remarks = aqString.Replace(TCResult.remarks, "TestCase Passed!, ", "");
		    TCResult.remarks = aqString.Replace(TCResult.remarks, "'", "");
		    TCResult.remarks = aqString.Replace(TCResult.remarks, "\"", "");
        Log.Message(TCResult.result + " : " + TCResult.remarks);
        if (!TCResult.result)
        {
          TS_RESULT = TCResult.result;
          if(FailedTestCases == "")
            FailedTestCases = TestCaseName;
          else
            FailedTestCases = FailedTestCases + ", " + TestCaseName;
        }
      }
    }
    //DataDriven Workflow
    else
    {
      try
      {
        var TCResult = Runner.CallMethod(strCommand, TestCaseRS, TestCaseName, IsDataDriven);
      }
      catch(e)
      {
        Log.Error("Aborting test script execution due to runtime error!");
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
  finally
  {
    if (typeof IsDataDriven === 'string' && IsDataDriven != "Y")
    {
      CloseTCJournal(TCResult);
    }
  }
}

function CloseTestSuiteRS(TestSuitesRS)
{
  try
  {
    TestSuitesRS.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }

  try
  {
    ModuleExcelCon.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CloseTestCaseRS(TestCaseRS)
{
  try
  {
    TestCaseRS.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function Close_RS_Conn_ForTestExecInstance()
{
  try
  {
    ModulesRS.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
  
  try
  {
    ExecMgmtExcelCon.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }  
}

function ExportTestResults()
{
  try
  {
    //var strTestExecutionJournal = "C:\\Tarun\\Report.xlsx";
    //var HTMLResultFile = "C:\\Tarun\\RES.html"
    var strTestExecutionReport = strProjectBaseFolder + "Log/" + "Report_" + DriverInitiationDate + "_" + DriverInitiationTime + "_" + JenkinsJobName + "_" + JenkinsBuildNo + ".xlsx";
    strTestExecutionJournal = Utility.vReplace(strTestExecutionJournal, "/", "\\", false);
    strTestExecutionReport = Utility.vReplace(strTestExecutionReport, "/", "\\", false);
    aqFileSystem.CopyFile(strTestExecutionJournal, strTestExecutionReport, true);

    EmailModule.CreateResultsHTML(HTMLResultFile, strTestExecutionReport);
    
    var MhtReportFileUrl = strProjectBaseFolder + "/Log/" + TestReportNameMht;
    MhtReportFileUrl = Utility.vReplace(MhtReportFileUrl, "/", "\\", false);
    Log.SaveResultsAs(MhtReportFileUrl, lsMHT);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function ParseCommandLineData()
{
  try
  {
    var builtinStrArr = new Array();
	var i;
	for (i = 1; i <= BuiltIn.ParamCount(); i++)
	  builtinStrArr.push(BuiltIn.ParamStr(i));
	  
	var returnStr;  
    for (i = 0; i <= builtinStrArr.length-1; i++)
    {
      var items = builtinStrArr[i].split("=");
      if (items.length != 2)
        continue;
	  
	  if (items.length == 2)
      {
        returnStr = CheckIFStringIsEnclosedInCurlyBraces(builtinStrArr, i, items);
		i = returnStr.newPosition;
      }
	  
      switch (aqString.ToLower(aqString.Trim(items[0])))
      {
        case "appcode":
          CurrentAppCode = aqString.Trim(returnStr.combinedString);
          break;

        case "jenkinsjobname":
          JobName = aqString.Trim(returnStr.combinedString);
          break;

        case "jenkinsbuildno":
          BuildNo = aqString.Trim(returnStr.combinedString);
          break;

        case "jenkinsworkspace":
          Workspace = aqString.Trim(returnStr.combinedString);
          break;

        case "buildtype":
          JenkinsBuildType = aqString.Trim(returnStr.combinedString);
          break;

        case "autlauncherdir":
          JenkinsAUTLauncherDir = aqString.Trim(returnStr.combinedString);
          break;

        case "overridetestmodules":
          overrideTestModules = aqString.Trim(returnStr.combinedString);
          break;

        case "overridetestsuites":
          overrideTestSuites = aqString.Trim(returnStr.combinedString);
          break;
		  
		case "customtestcaseappendqueryparams":
          customTestCaseAppendQueryParams = aqString.Trim(returnStr.combinedString);
          break;  
		  
		case "customtappparams":
          customAppParams = aqString.Trim(returnStr.combinedString);
          break;   
      }
    }
    
    Log.Message("CurrentAppCode: " + CurrentAppCode);
    Log.Message("JobName: " + JobName);
    Log.Message("BuildNo: " + BuildNo);
    Log.Message("Workspace: " + Workspace);
    Log.Message("JenkinsBuildType: " + JenkinsBuildType);
    Log.Message("JenkinsAUTLauncherDir: " + JenkinsAUTLauncherDir);
    Log.Message("overrideTestModules: " + overrideTestModules);
    Log.Message("overrideTestSuites: " + overrideTestSuites);
    CurrentAppCode = "TD";
    overrideTestModules = "'TDSelfServiceGrids'";
    //CurrentAppCode = "CV";
    //overrideTestModules = "'RatesModule'";
    overrideTestSuites = "'QuickFilter'";
    //JenkinsBuildType = 'Custom';
    //JenkinsAUTLauncherDir = "C:\Builds\14967";
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CheckIFStringIsEnclosedInCurlyBraces(builtinStrArr, startIndex, items)
{
  try
  {
    var checkPos = startIndex;
	var str = items[1];
	while (checkPos <= builtinStrArr.length -1)
	{
	  if(str[0] == "{" && str[str.length -1] == "}")
	    break;
      else
      {
	    str = str + " " + builtinStrArr[checkPos +1];
		checkPos++;
	  }	  
	}
	str = aqString.Replace(str, "{", "");
	str = aqString.Replace(str, "}", "");
	return {combinedString: str, newPosition: checkPos};
  }
  catch (e)
  {
    Log.Error(e);
  }
}
