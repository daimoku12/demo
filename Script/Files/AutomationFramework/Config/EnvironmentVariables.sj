//******************************************************************************************************************************
//GLOBAL VARIABLES
//******************************************************************************************************************************
var DriverInitiationTime;
var DriverInitiationDate;
var strProjectBaseFolder;
var strFrameworkBaseFolder = "C:/Automation/REA_TD";
var TestExecutionJournalTemplate = strFrameworkBaseFolder + "/DataRepository/Template/TestExecutionTemplate.xlsx";
var TestReportNameMht;
var TestReportnameXml;
var TestReportExecutionJournal;
var CurrentAppCode = "";
var ExecutionControllerUrl;
var ExecMgmtExcelCon;
var ModuleExcelCon;
var strTestExecutionJournal;
var ModuleRS;
var JenkinsJobName = "DemoJob";
var JenkinsBuildNo = "001";
var JenkinsWorkspace = "C:/Jenkins/workspace/";
var HTMLResultFile = "Results.html";
var CurrentJobRowNum;
var CurrentTSRowNum;
var CurrentTCRowNum;
var FaliedTestCases = "";
var JobName;
var BuildNo;
var Workspace;
var JenkinsBuildType;
var JenkinsAUTLauncherDir;
var overrideTestModules;
var overrideTestSuites;
var customTestCaseAppendQueryParams;
var customAppParams;

//-----------------------------------------------------------------------------------------------------------------
//Application Global
//-----------------------------------------------------------------------------------------------------------------
var AUTProcessName;
var bootStrapperApp;
var bootStrapperAppArray;
var ProcessList;
var LoggedInUser = "";
var CurrentBuildNumber = "";
var CurrentBuildGroup = "";
var CurrentAppName = "";
var CurrentAppPath = null;
var AUTBuildType = "";
var AUTLauncherDir = "";
var AUTLoginBufferTime;
var appToolbar;

//----------------------------------------------------------------------------------------------------------------------
//LOGGING LEVEL - DEBUG / INFO
//----------------------------------------------------------------------------------------------------------------------
var LoggingLevel = 'INFO';


//----------------------------------------------------------------------------------------------------------------------
//TIMEOUT VARIABLES
//----------------------------------------------------------------------------------------------------------------------
var MAX_CHILDS = 2000;
var MAX_TIMEOUT_LIMIT_MS = 40000;


//----------------------------------------------------------------------------------------------------------------------
//CALLSTACK SETTINGS
//----------------------------------------------------------------------------------------------------------------------
Log.CallStackSettings.EnableStackOnCheckpoint = true;
Log.CallStackSettings.EnableStackOnError = true;
Log.CallStackSettings.EnableStackOnEvent = true;
Log.CallStackSettings.EnableStackOnFile = true;
Log.CallStackSettings.EnableStackOnImage = true;
Log.CallStackSettings.EnableStackOnMessage = true;
Log.CallStackSettings.EnableStackOnWarning = true;
