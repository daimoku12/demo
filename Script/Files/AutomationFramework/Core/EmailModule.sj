//USEUNIT GlobalIncludes

var ResultsJournalExcelCon, TSRecordCount, TestSuitesRS;

function CreateResultsHTML(HTMLFilePath, ExcelFilePath)
{
  try
  {
    var hndlHTMLFile = CreateHTMLFile(HTMLFilePath);
    WritePageHeader(hndlHTMLFile);
    WriteApplicationName(hndlHTMLFile, ExcelFilePath);
    WriteEnvironmentDetails(hndlHTMLFile, ExcelFilePath);
    WritePageResults(hndlHTMLFile, ExcelFilePath);
    WritePageFooter(hndlHTMLFile);
    CloseHTMLFile(hndlHTMLFile);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CreateHTMLFile(FileName)
{
  try
  {
    var hndlHTMLFile = aqFile.OpenTextFile(FileName, aqFile.faWrite, aqFile.ctUTF8, true);
    return hndlHTMLFile;    
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function DeleteHTMLFile(FileName)
{
  try
  {
    if (aqFile.Exists(FileName))
      aqFile.Delete(FileName);
    else
      Log.Message("FileName (" + FileName + ") does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function WritePageHeader(hndlHTMLFile)
{
  try
  {
    hndlHTMLFile.Write("<html>");
    hndlHTMLFile.Write("<head>");
    hndlHTMLFile.Write("<style> " +
      "body { " +
      "margin:0; " +
      "font:normal normal 90% Georgia, Serif; " +
      "background-color: #ffffff; " +
      "} " +
    
      "table, tr, th, td { " +
      "margin:0; " +
      "font:normal bold 100% Georgia, Serif; " +
      "color: #25587e; " +
      "height:1.0pt; " +
      "vertical-align: middle; " +
      "background-color: #D5E1F4; " +
      "background: #D5E1F4; " +
      "} " +
    
      "td, th { " +
      "padding:2px; " +
      "} " +
    
      "table.border, th.border, td.border { " +
      "width: 100%; " +
      "border: 1px solid #98AFC7; " +
      "padding:8px 8px 8px 8px; " +
      "height:1.0pt; " +
      "border-collapse:collapse; " +
      "background: #D5E1F4; " +
      "vertical-align: middle; " +
      "} " +
    
      "th.border1, td.border1 { " +
      "border: 1px solid #98AFC7; " +
      "padding:8px 8px 8px 8px; " +
      "height:1.0pt; " +
      "border-collapse:collapse; " +
      "} " +
    
      "th.borderTotal, td.borderTotal { " +
      "border: 1px solid #98AFC7; " +
      "padding:8px 8px 8px 8px; " +
      "height:1.0pt; " +
      "border-collapse:collapse; " +
      "font: normal bold 125% Georgia,Serif; " +
      "} " +
    
      "h1 { " +
      "border:solid 1px #25587e; " +
      "padding:5px; " +
      "padding-left:8px; " +
      "margin-top:3px; " +
      "margin-bottom:3px; " +
      "color: #ffffff; " +
      "font: normal bold 110% Georgia,Serif; " +
      "background-color:#25587e; " +
      "vertical-align:middle; " +
      "} " +
    
      "td.border_test_passed { " +
      "border: 1px solid #98AFC7; " +
      "text-align: center; " +
      "color:blue; " +
      "} " +
    
      "td.border_test_failed { " +
      "border: 1px solid #98AFC7; " +
      "text-align: center; " +
      "color:red; " +
      "} " +
    
      "td.border_test_skipped { " +
      "border: 1px solid #98AFC7; " +
      "color:grey; " +
      "text-align: center; " +
      "} " +
    
      "td.border_test_total { " +
      "border: 1px solid #98AFC7; " +
      "text-align: center; " +
      "} " +
    
      "table.tblContainer { " +
      "background-color: #D5E1F4; " +
      "border: dotted 2px #194164; " +
      "margin: 5px auto; " +
      "padding-left: 5px; " +
      "padding-right: 5px; " +
      "padding-top: 0px; " +
      "padding-bottom: 0px; " +
      "width: 100%; " +
      "} " +
    
      ".ValueText { " +
      "font-family: Georgia; " +
      "font-style: normal; " +
      "font-size: 90%; " +
      "font-weight:normal; " +
      "color:red; " +
      "} " +
    
  		"tr.bgColors " +
  		"{ " +
  		"margin:0; " +
  		"font:normal bold 100% Georgia, Serif; " +
  		"color: #25587e; " +
  		"height:1.0pt; " +
      "padding-left: 5px; " +
      "padding-right: 5px; " +    
  		"vertical-align: middle; " +
  		"background-color: #D5E1F4; " +
  		"background:#25587E; " +
  		"} " +
      "</style>");
    hndlHTMLFile.Write("</head>");
    hndlHTMLFile.Write("<body>");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function WriteApplicationName(hndlHTMLFile, ExcelResultFilePath)
{
  try
  {
    hndlHTMLFile.Write("<table class='tblContainer'>");
    hndlHTMLFile.Write("<tr class='bgColors'><td><h1>Application Name</h1></td></tr>");
    hndlHTMLFile.Write("<tr><td>");
    hndlHTMLFile.Write("<table width='100%'>");
  
    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='key'>" + CurrentAppName + "</td>");
    hndlHTMLFile.Write("</tr>");

    hndlHTMLFile.Write("</table>");
    hndlHTMLFile.Write("</td></tr>");
    hndlHTMLFile.Write("</table>");
    hndlHTMLFile.Write("<hr />");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function WriteEnvironmentDetails(hndlHTMLFile, ExcelResultFilePath)
{
  try
  {
    hndlHTMLFile.Write("<table class='tblContainer'>");
    hndlHTMLFile.Write("<tr class='bgColors'><td><h1>Environment</h1></td></tr>");
    hndlHTMLFile.Write("<tr><td>");
    hndlHTMLFile.Write("<table width='100%'>");
  
    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='key'>Build Number</td>");
    hndlHTMLFile.Write("<td class='colon'>:</td>");
    if (!Reporter.TS_RESULT && Reporter.TS_REMARKS == Reporter.TEST_ENV_FAILED_MSG)
      hndlHTMLFile.Write("<td align='left'><div class='ValText'>Could not retrieve build number!</div></td>");
    else
      hndlHTMLFile.Write("<td align='left'><div class='ValText'>" + CurrentBuildNumber + "</div></td>");
    hndlHTMLFile.Write("</tr>");

    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='key'>Application Path</td>");
    hndlHTMLFile.Write("<td class='colon'>:</td>");
    hndlHTMLFile.Write("<td align='left'><div class='ValText'>" + CurrentAppPath + "</div></td>");
    hndlHTMLFile.Write("</tr>");

    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='key'>Server</td>");
    hndlHTMLFile.Write("<td class='colon'>:</td>");
    hndlHTMLFile.Write("<td><div class='ValText'>UAT</div></td>");
    hndlHTMLFile.Write("</tr>");

    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='key'>Logged-in User</td>");
    hndlHTMLFile.Write("<td class='colon'>:</td>");
    if (!Reporter.TS_RESULT && Reporter.TS_REMARKS == Reporter.TEST_ENV_FAILED_MSG)
      hndlHTMLFile.Write("<td align='left'><div class='ValText'>Could not retrieve logged-in user!</div></td>");
    else
      hndlHTMLFile.Write("<td><div class='ValText'>" + LoggedInUser + "</div></td>");
    hndlHTMLFile.Write("</tr>");

    hndlHTMLFile.Write("</table>");
    hndlHTMLFile.Write("</td></tr>");
    hndlHTMLFile.Write("</table>");
    hndlHTMLFile.Write("<hr />");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function WritePageResults(hndlHTMLFile, ExcelResultFilePath)
{
  try
  {
    var failedTCsString = "";
    hndlHTMLFile.Write("<table class='tblContainer'>");
    hndlHTMLFile.Write("<tr class='bgColors'><td><h1>UI Tests</h1></td></tr>");
    hndlHTMLFile.Write("<tr><td>");
    if (!Reporter.TS_RESULT && Reporter.TS_REMARKS == Reporter.TEST_ENV_FAILED_MSG)
    {
      hndlHTMLFile.Write("<table width='100%'>");
      hndlHTMLFile.Write("<tr><td>");
      hndlHTMLFile.Write(Reporter.TEST_ENV_FAILED_MSG + " Exiting...");
      hndlHTMLFile.Write("</td></tr>");
      hndlHTMLFile.Write("</table>");
      hndlHTMLFile.Write("</td></tr>");
      hndlHTMLFile.Write("</table>");
      return;
    }
    hndlHTMLFile.Write("<table class='border'><tr> " +
      "<th class='border1'>Test Suite</th> " +
      "<th class='border1' width='140px'>Failed</th> " +
      "<th class='border1' width='140px'>Passed</th> " +
      //"<th class='border1' width='140px'>Skipped</th> " +
      "<th class='border1' width='140px'>Total</th> " +
      "</tr>");

    ResultsJournalExcelCon = OpenResultJournal(ExcelResultFilePath);
    var strSql = "Select * from [TSResults$];";
    TestSuitesRS = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSql);

    if (!TestSuitesRS.BOF)
      TestSuitesRS.MoveFirst();

    while (!TestSuitesRS.EOF)
    {
      var TestSuiteName = TestSuitesRS.Fields.Item("TestSuiteName").Value;
      var TestSuiteRowNum = TestSuitesRS.Fields.Item("RowNum").Value;

      var strSqlPass = "Select COUNT(*) from [TCResults$] WHERE TestSuiteRowID LIKE " + TestSuiteRowNum + " AND TCResult = 'Passed'";
      var strSqlFail = "Select COUNT(*) from [TCResults$] WHERE TestSuiteRowID LIKE " + TestSuiteRowNum + " AND TCResult In ('Failed', 'false' ,'Running')";
      //var strSqlSkip = "Select COUNT(*) from [TCResults$] WHERE TestSuiteRowID LIKE " + TestSuiteRowNum + " AND TCResult = 'Skipped'";
      var strSqlTotal = "Select COUNT(*) from [TCResults$] WHERE TestSuiteRowID LIKE " + TestSuiteRowNum;
      var strSqlPassTotal = "Select COUNT(*) from [TCResults$] WHERE TCResult = 'Passed'";
      var strSqlFailTotal = "Select COUNT(*) from [TCResults$] WHERE TCResult In ('Failed', 'false', 'Running')";
      //var strSqlSkipTotal = "Select COUNT(*) from [TCResults$] WHERE TCResult = 'Skipped'";
      var strSqlTotalTotal = "Select COUNT(*) from [TCResults$]";

      var TCRSPass = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlPass);
      var TCRSFail = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlFail);
      //var TCRSSkip = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlSkip);
      var TCRSTotal = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlTotal);
      var TCRSPassTotal = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlPassTotal);
      var TCRSFailTotal = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlFailTotal);
      //var TCRSSkipTotal = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlSkipTotal);
      var TCRSTotalTotal = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlTotalTotal);

      var TCCountPass = aqConvert.StrToInt(TCRSPass.Fields.Item(0).Value);
      var TCCountFail = aqConvert.StrToInt(TCRSFail.Fields.Item(0).Value);
      //var TCCountSkip = aqConvert.StrToInt(TCRSSkip.Fields.Item(0).Value);
      var TCCountTotal = aqConvert.StrToInt(TCRSTotal.Fields.Item(0).Value);
      var TCCountPassTotal = aqConvert.StrToInt(TCRSPassTotal.Fields.Item(0).Value);
      var TCCountFailTotal = aqConvert.StrToInt(TCRSFailTotal.Fields.Item(0).Value);
      //var TCCountSkipTotal = aqConvert.StrToInt(TCRSSkipTotal.Fields.Item(0).Value);
      var TCCountTotalTotal = aqConvert.StrToInt(TCRSTotalTotal.Fields.Item(0).Value);

      hndlHTMLFile.Write("<tr>");
      hndlHTMLFile.Write("<td class='border1'>" + TestSuiteName + "</td>");
      if (TCCountFail > 0)
        hndlHTMLFile.Write("<td class='border_test_failed'>" + TCCountFail + "</td>");
      else
        hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountFail + "</td>");

      if (TCCountPass > 0)
        hndlHTMLFile.Write("<td class='border_test_passed'>" + TCCountPass + "</td>");
      else
        hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountPass + "</td>");

      /*if (TCCountSkip > 0)
        hndlHTMLFile.Write("<td class='border_test_skipped'>" + TCCountSkip + "</td>");
      else
        hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountSkip + "</td>");
      */
      hndlHTMLFile.Write("<td class='border_test_total'><b>" + TCCountTotal + "</b></td>");
      hndlHTMLFile.Write("</tr>");

      if (TCCountFail > 0)
      {
        failedTCsString = failedTCsString + "<tr><td class='border1'>";
        failedTCsString = failedTCsString + TestSuiteName;

        var strSqlFailedTCs = "Select * from [TCResults$] WHERE TestSuiteRowID LIKE " + TestSuiteRowNum + " AND TCResult In ('Failed','false','Running')";
        var TCsRSFail = ExcelUtility.vGetRecordset(ResultsJournalExcelCon, strSqlFailedTCs);

        if (!TCsRSFail.BOF)
          TCsRSFail.MoveFirst();

        while (!TCsRSFail.EOF)
        {
          var TestCaseName = TCsRSFail.Fields.Item("TestCaseName").Value;
          var TCRemarks = TCsRSFail.Fields.Item("TCRemarks").Value;
          failedTCsString = failedTCsString + "<br /><span class='ValueText'>" + TestCaseName + " - <i>" + TCRemarks +"</i></span>";
          TCsRSFail.MoveNext();
        }
        TCsRSFail.Close();
      }
      TestSuitesRS.MoveNext();
    }

    hndlHTMLFile.Write("<tr>");
    hndlHTMLFile.Write("<td class='borderTotal'>Total</td>");
    if (TCCountFailTotal > 0)
      hndlHTMLFile.Write("<td class='border_test_failed'>" + TCCountFailTotal + "</td>");
    else
      hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountFailTotal + "</td>");

    if (TCCountPassTotal > 0)
      hndlHTMLFile.Write("<td class='border_test_passed'>" + TCCountPassTotal + "</td>");
    else
      hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountPassTotal + "</td>");

    /*if (TCCountSkipTotal > 0)
      hndlHTMLFile.Write("<td class='border_test_skipped'>" + TCCountSkipTotal + "</td>");
    else
      hndlHTMLFile.Write("<td class='border_test_total'>" + TCCountSkipTotal + "</td>");
    */
    hndlHTMLFile.Write("<td class='border_test_total'><b>" + TCCountTotalTotal + "</b></td>");
    hndlHTMLFile.Write("</tr>");
    hndlHTMLFile.Write("</table>");
    hndlHTMLFile.Write("</td></tr>");
    hndlHTMLFile.Write("<tr><td><br/></td></tr>");

    if (TCCountFailTotal > 0)
    {
      hndlHTMLFile.Write("<tr class='bgColors'><td><h1>Test Failures</h1></td></tr>");
      hndlHTMLFile.Write("<tr><td>");
      hndlHTMLFile.Write("<table class='border'>");
      hndlHTMLFile.Write(failedTCsString);
      hndlHTMLFile.Write("</table>");
      hndlHTMLFile.Write("</td></tr>");
    }
    hndlHTMLFile.Write("</table>");
    TestSuitesRS.Close();
    ResultsJournalExcelCon.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function WritePageFooter(hndlHTMLFile)
{
  try
  {
    hndlHTMLFile.Write("</body>");
    hndlHTMLFile.Write("</html>");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function CloseHTMLFile(hndlHTMLFile)
{
  try
  {
    hndlHTMLFile.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}


function OpenResultJournal(ExcelResultFilePath)
{
  try
  {
    ResultsJournalExcelCon = ExcelUtility.vOpenADODBConnection(ExcelResultFilePath, "xlsx");
    return ResultsJournalExcelCon;
  }
  catch (e)
  {
    Log.Error(e);
  }
}