//USEUNIT Reporter
//USEUNIT Utility

function FileFinder(Path, SearchPattern, SearchInSubDirs)
{
  try
  {
    var foundFiles, aFile;
    foundFiles = aqFileSystem.FindFiles(Path, SearchPattern, SearchInSubDirs);
    if (foundFiles != null)
    {
      while (foundFiles.HasNext())
      {
        aFile = foundFiles.Next();
        return aFile;
      }
    }
    else
      return;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function FileExists(strFilePath, iTimesToRetry, iMillisecondWaitBetweenRetries)
{
  try
  {
    var bFileExists = false;
    var iCounter = 0;
  
    if(iTimesToRetry == null)
      var iTimesToRetry = 1;
  
    if(iMillisecondWaitBetweenRetries == null)
      var iMillisecondWaitBetweenRetries = 1;
  
    while(!bFileExists && iCounter < iTimesToRetry) 
    {   
      bFileExists = aqFile.Exists(strFilePath)    
      Delay(iMillisecondWaitBetweenRetries);
      iCounter++;
    }
    
    vDebug("Result from file exists operation: " + bFileExists);
    return bFileExists;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function GetFirstLineInFileContainingText(strFilePath, strTextToBeContainedInFile, bCaseSensitive, bIfFileNotExistsTreatAsWarning)
{
  try
  {
    var line;
    var output = null;
  
    if(FileExists(strFilePath, 10, 1000))
    {
      try
      { 
        var myFile = aqFile.OpenTextFile(strFilePath, aqFile.faRead, aqFile.ctANSI);
     
        while(!myFile.IsEndOfFile())
        {
          line = myFile.ReadLine();
      
          if(Utility.contains(line, strTextToBeContainedInFile, bCaseSensitive, true))
          { 
            vDebug("Found line in text file. Retrieved following text: " + line);
            output = line;
            break;
          }
        }

        myFile.Close();
      }
      catch(ex)
      {
        vError("Unexpected exception. Details: " + ex);
      }
    
      if(!output || output == null)
        vDebug("Did not find the line in the log file");
    
      return output;
    }
    else
    {
      if(bIfFileNotExistsTreatAsWarning)
        vWarning("File does not exist to read the contents. Path: " + strFilePath);
      else
        vError("File does not exist to read the contents. Path: " + strFilePath);
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
} 

function DeleteFile(strFilePath)
{
  try
  {
    if (FileExists(strFilePath))
    {
      var iCounter = 0;
      while(FileExists(strFilePath) && iCounter < 10)
      {
        vMessage("Result from file deletion operation: " + aqFile.Delete(strFilePath));
        Delay(1000);
        iCounter++;
      }
    }
  }
  catch(e)
  {    
    Log.Error(e);
  }
}

function ClearFileContents(strFilePath)
{
  try
  {
    aqFile.WriteToTextFile(strFilePath, "", aqFile.ctANSI, true)
  }
  catch(e)
  {    
    Log.Error(e);
  }
}

function CreateFile(strFilePath)
{
  var fileCreationReturnCode;
  try
  {
    fileCreationReturnCode = aqFile.Create(strFilePath);
    
    if(fileCreationReturnCode == 0)
    {
      Reporter.vMessage("Successfully created the file: " + strFilePath);
      return true;
    }
    else
    {
      var errorDetails = aqUtils.SysErrorMessage(fileCreationReturnCode);
      Log.Error("Error creating the File: " + strFilePath + ". Error details: " + errorDetails);
      return false;
    }
  }
  catch(e)
  {
    Log.Error(e);
    return false;
  }
}

function OpenTextFile(strFilePath, bOverwriteFlag)
{
  try
  {
    if(FileUtility.FileExists(strFilePath))
    {     
      var oFile = aqFile.OpenTextFile(strFilePath, aqFile.faWrite, aqFile.ctANSI, bOverwriteFlag);
      Reporter.vMessage("Successfully opened the file. File : " + strFilePath);
      return oFile;     
    }
    else
    {
      Log.Error("The following file does not exist: " + strFilePath);
      return null;
    }    
  }
  catch(e)
  {
    Log.Error(e);
    return null;
  }
}

function WriteToTextFile(strFilePath, strContent, bOverwriteFlag)
{
  try
  {
    var fileObj = OpenTextFile(strFilePath, bOverwriteFlag);
    if(fileObj != null)
    {
      fileObj.Write(strContent);
      fileObj.Close();
      Reporter.vMessage("Successfully written to the file. File : " + strFilePath);
      return true;
    }
    else
    {
      Log.Error("File not found. Hence unable to write to the file: " + strFilePath);
      return false;
    }
 }
  catch(e)
  {
    Log.Error(e);
    return false;
  }
}

function ExecuteFile(strPath, bWaitOnReturn)
{
  try
  {
    Sys.OleObject("WScript.Shell").CurrentDirectory = aqFileSystem.GetFileFolder(strPath);
    if(IsEmptyString(bWaitOnReturn))
    {
      bWaitOnReturn = true;
    } 
    Sys.OleObject("WScript.Shell").Run(strPath, 1, bWaitOnReturn);
    Reporter.vMessage("Successfully executed the file : " + strPath);
    return true;
  }
  catch(e)
  {
    Log.Error(e);
    return false;
  }
}

function GetTempFolderPath()
{
  try
  {
    var strTempFolderPath = Sys.OSInfo.TempDirectory;
    Reporter.vMessage("Temp Folder Path: " + strTempFolderPath);
    return strTempFolderPath;
  }
  catch(e)
  {
    Log.Error(e);
    return false;
  }
} 

function CopyFile(strExistingFilePath, strNewFilePath)
{
  try
  {
    if(FileUtility.FileExists(strExistingFilePath))
    {
      Reporter.vMessage("About to copy the file From: " + strExistingFilePath + " To: " + strNewFilePath);
      if(FileUtility.FileExists(strNewFilePath))
      {
        Log.Error("Error while copying the file. Destination File: " + strNewFilePath + " already exists!");
        return false;
      }
      else
        return aqFileSystem.CopyFile(strExistingFilePath, strNewFilePath, false);
    }
    else
    {
      Log.Error("Error while copying the file. File: " + strExistingFilePath + " does not exist!");
      return false;
    }
  }
  catch(e)
  {
    Log.Error(e);
    return false;
  }
}

function getCountOfLinesInTextOrCsvFile(strFilePath)
{
	try
	{
		var fileObj = OpenTextFile(strFilePath, false);
		
    if(fileObj != null)
		{
      var iLineCount = fileObj.LinesCount;
      fileObj.Close();
      return iLineCount;
		}
		else
      Log.Error("File " + strFilePath + " does not exists to get the no. of lines in the file!");      
	}
	catch(e)
	{
		Log.Error(e);
	}
  return -1;
}

function CheckIfTextExistsInFile(strFilePath, verificationMsg, timeInterval)
{
  try
  {
    //var strFilePath = "C:\\Tarun\\CVR.log";
    //var verificationMsg = "Start parssing1";
    var cursorPos = 0;
    var linesCount = 0;
    var line;
    var isMsgDisplayed = false;
    
    if(FileExists(strFilePath, 10, 1000))
    {
      var startTime = aqDateTime.Now();
      while (!isMsgDisplayed)
      {
        var currentTime = aqDateTime.Now();
        if (!isMsgDisplayed && aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= timeInterval)
        {
          //Log.Error("Did not find the line in the log file!");
          break;
        }

        var fileObj = aqFile.OpenTextFile(strFilePath, aqFile.faRead, aqFile.ctANSI);
        if (fileObj.LinesCount > linesCount)
        {
          linesCount = fileObj.LinesCount;
          fileObj.Cursor = cursorPos;
          while(!fileObj.IsEndOfFile())
          {
            line = fileObj.ReadLine();
            if(Utility.contains(line, verificationMsg, true))
            { 
              Log.Message("Found line in text file. Retrieved following text: " + line);
              isMsgDisplayed = true;
              break;
            }
          }
          cursorPos = fileObj.Cursor;
          fileObj.Close();

          if (!isMsgDisplayed)
            Delay(3000);
        }
      }
      return isMsgDisplayed;
    }
    else
      Log.Error("File does not exist to read the contents! Path: " + strFilePath);
  }
  catch (e)
  {
    Log.Error(e);
  }
}