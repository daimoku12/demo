//USEUNIT Action
//USEUNIT Reporter
//USEUNIT Validator

function isNumeric(num)
{
  try
  {
    return !isNaN(num);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function stringToInt(strInputVal)
{
  try
  {
    return (aqConvert.StrToInt(strInputVal));
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function vReplace(InputString, StringToReplace, SubString, CaseSensitive)
{
  try
  {
    if (!CaseSensitive || CaseSensitive == null)
      CaseSensitive = false;
    return aqString.Replace(InputString, StringToReplace, SubString, CaseSensitive);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

// Return the substring based on the start position and number of characters
function vSubString(strInput, iStart, iNoOfChars)
{
  try
  {
    return aqString.SubString(strInput, iStart, iNoOfChars);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isTrue(input)
{
  try
  {
    return (aqConvert.VarToBool(input)) == true;
  }
  catch (e)
  {
    try
    {
      if (Utility.areValuesEqual("Y", aqConvert.VarToStr(input), false))
        return true;
      else
        return false;
    }
    catch (e)
    {
      Log.Error(e);
      return false;
    }
  }
}

function isFalse(input)
{
  try
  {
    return !isTrue(input);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function areValuesEqual(Value1, Value2, strDescription)
{
  try
  {
    //strDescription may be passed empty. if it is not, then format it
    if (strDescription && !isEmptyString(strDescription))
      strDescription = strDescription + ". ";

    if (aqString.Trim(Value1) == aqString.Trim(Value2))
    {
      //Reporter.vDebug(strDescription + "Value1: " + Value1 + " is equal to Value2: " + Value2, "Value1: " + Value1 + " is equal to Value2: " + Value2, 300);
      return true;
    }
    else
    {
      //Reporter.vDebug(strDescription + "Value1: " + Value1 + " is not equal to Value2: " + Value2, "Value1: " + Value1 + " is not equal to Value2: " + Value2, 300);
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

// Value1 and Value2 are strings to be compared. If bCaseSensitive is True it is case sensitive comparison, else case-insensitive comparison
function areStringValuesEqual(Value1, Value2, bCaseSensitive)
{
  try
  {
    if (typeof Value1 === 'string' && typeof Value2 === 'string' && aqString.Compare(aqString.Trim(Value1), aqString.Trim(Value2), bCaseSensitive) == 0)
    {
      //Reporter.vDebug("Value1: " + Value1 + " is equal to Value2: " + Value2, "Value1: " + Value1 + " is equal to Value2: " + Value2, 300);
      return true;
    }
    else
    {
      //Reporter.vDebug("Value1: " + Value1 + " is not equal to Value2: " + Value2, "Value1: " + Value1 + " is not equal to Value2: " + Value2, 300);
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isStringArraySorted(array, order)
{
  try
  {
    var ordered = true;
    for (var i = 0; i < array.length; i++)
    {
      if (GetVarType(array[i]) == varInteger || GetVarType(array[i]) == varSmallInt || GetVarType(array[i]) == varInt64 || GetVarType(array[i]) == varLongWord)
        array[i] = aqConvert.IntToStr(array[i]);
    }
    if (order == "desc")
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqString.Compare(array[i], array[i - 1], true) > 0)
        {
          ordered = false;
          break;
        }
      }
    }
    else
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqString.Compare(array[i], array[i - 1], true) < 0)
        {
          ordered = false;
          break;
        }
      }
    }
    if (ordered)
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isDateArraySorted(array, order)
{
  try
  {
    var ordered = true;
    if (order == "desc")
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqDateTime.Compare(array[i], array[i - 1]) > 0)
        {
          ordered = false;
          break;
        }
      }
    }
    else
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqDateTime.Compare(array[i], array[i - 1]) < 0)
        {
          ordered = false;
          break;
        }
      }
    }
    if (ordered)
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isNumberArraySorted(array, order)
{
  var ordered = true;
  for (var i = 0; i < array.length; i++)
  {
    try
    {
      if ((GetVarType(array[i]) == varString || GetVarType(array[i]) == varOleStr))
        array[i] = aqConvert.StrToFloat(array[i]);
    }
    catch (e)
    {
      array[i] = 0;
    }
  }
  if (order == "desc")
  {
    for (var i = 1; i < array.length; i++)
    {
      if (array[i - 1] < array[i])
      {
        ordered = false;
        break;
      }
    }
  }
  else
  {
    for (var i = 1; i < array.length; i++)
    {
      if (array[i - 1] > array[i])
      {
        ordered = false;
        break;
      }
    }
  }
  return ordered;
}

function isCustomArraySorted(array, order, splitChar)
{
  try
  {
    var ordered = true;
    for (var i = 0; i < array.length; i++)
    {
      var strParts = array[i].split(splitChar);
      array[i] = strParts[0];
    }

    if (order == "desc")
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqConvert.StrToFloat(array[i - 1]) < aqConvert.StrToFloat(array[i]))
        {
          ordered = false;
          break;
        }
      }
    }
    else
    {
      for (var i = 1; i < array.length; i++)
      {
        if (aqConvert.StrToFloat(array[i - 1]) > aqConvert.StrToFloat(array[i]))
        {
          ordered = false;
          break;
        }
      }
    }
    return ordered;
  }
  catch (e)
  {
    Log.Error(e);
    return false;
  }
}

function areColorArraysSame(Array1, Array2)
{
  try
  {
    if (Array1["Red"] == Array2["Red"] && Array1["Blue"] == Array2["Blue"] && Array1["Green"] == Array2["Green"])
    {
      //Reporter.vDebug("Array1: " + Array1 + " is equal to Array2: " + Array2, "Array1: " + Array1 + " is equal to Array2: " + Array2, 300);
      return true;
    }
    else
    {
      //Reporter.vDebug("Array1: " + Array1 + " is not equal to Array2: " + Array2, "Array1: " + Array1 + " is not equal to Array2: " + Array2, 300);
      return false;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function toUpperCase(strInput)
{
  try
  {
    return aqString.ToUpper(strInput);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function toLowerCase(strInput)
{
  try
  {
    return aqString.ToLower(strInput);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isEmptyString(strInput)
{
  try
  {
    return aqString.GetLength(aqConvert.VarToStr(strInput)) == 0;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function contains(strValue, strSubString, bCaseSensitiveInput)
{
  try
  {
    var bCaseSensitive = false;
    //It would be case sensitive by default, we want to reverse that logic
    if (bCaseSensitiveInput)
      bCaseSensitive = true;

    //Reporter.vDebug("Checking if value " + strValue + " contains substring " + strSubString + ". Case sensitive = " + bCaseSensitive);
    return aqString.Find(strValue, strSubString, 0, bCaseSensitive) >= 0;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isNumeric_ContainsDigitsOnly(oInput)
{
  try
  {
    var strInput = aqConvert.VarToStr(oInput);
    return (/^\d{1,}$/).test(strInput);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function trimSpecialCharacter(number)
{
  try
  {
    var N = aqString.Trim(number);
    return (N.replace(/\D/g, ""));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function containsCharacter(Value, Character, logResult)
{
  try
  {
    if (logResult != undefined && logResult != null && logResult == false)
    {
      if (Value.indexOf(Character) > -1)
        return true;
      else
        return false;
    }
    else
    {
      if (Value.indexOf(Character) > -1)
      {
        vCheckpoint("Value: " + Value + " contains the: " + Character + "!");
        return true;
      }
      else
      {
        Log.Error("Value: " + Value + " does not contain the Character: " + Character + "!");
        return false;
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns true or false based on condition provided
//conditions : exists : Verifies if given character exists in element of array
function checkArray(array, condition, character)
{
  try
  {
    var results = new Array();
    for (var i = 0; i < array.length; i++)
    {
      switch (condition)
      {
        case "exists":
          if (containsCharacter(array[i], character, false))
            return true;
      }
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns array after processing a condition
//condition = "StartsWith" Returns array of elements only which starts with value provided 
//condition = "EndsWith" Returns array of elements only which ends with value provided 
//condition = "DoNotMatch" Returns array of elements from an array only which doesnot match the value provided
//condition = "Match" Returns array of elements from an array only which match the value provided
//condition = "LessThan" Returns array of elements from an array only less than value provided
//condition = "LessThanOrEqual" Returns array of elements from an array only less than or equal to value provided
//condition = "GreaterThan" Returns array of elements from an array only greater than value provided
//condition = "GreaterThanOrEquals" Returns array of elements from an array only greater than or equals value provided
//condition = "GreaterThanAbsoluteValue" Returns array of elements from an array only greater than absolute value provided
//condition = "LessThanAbsoluteValue" Returns array of elements from an array only less than absolute value provided
//condition = "WithinRange" Returns array of elements from an array within value range. From value = value & To Value = to
//condition = "Contains" Returns array of elements of which contain the value
//condition = "DoNotContains" Returns array of elements of which do not contain the value
//condition = "above" Returns array of elements above the specified index
//condition = "below" Returns array of elements below/after the specified index
//noSort = true Returns unsorted array
function arrayOfElementForACondition(array, condition, value, value1, to, noSort)
{
  try
  {
    var results = new Array();
    for (var i = 0; i < array.length; i++)
    {
      switch (condition)
      {
        case "StartsWith":
          if (((array[i]).indexOf(value) == 0))
            results.push(array[i]);
          break;

        case "EndsWith":
          if (array[i].charAt(array[i].length-1) == value)
            results.push(array[i]);
          break;

        case "DoNotMatch":
          if (array[i] != value)
            results.push(array[i]);
          break;

        case "Match":
          if (array[i] == value)
            results.push(value);
          break;

        case "LessThan":
          if (aqConvert.StrToFloat(array[i]) < aqConvert.StrToFloat(value))
            results.push(array[i]);
          break;

        case "LessThanOrEqual":
          if (aqConvert.StrToFloat(array[i]) <= aqConvert.StrToFloat(value))
            results.push(array[i]);
          break;

        case "GreaterThan":
          if (aqConvert.StrToFloat(array[i]) > aqConvert.StrToFloat(value))
            results.push(array[i]);
          break;

        case "GreaterThanOrEquals":
          if (aqConvert.StrToFloat(array[i]) >= aqConvert.StrToFloat(value))
            results.push(array[i]);
          break;

        case "GreaterThanAbsoluteValue":
          if (Math.abs(aqConvert.StrToFloat(array[i])) > Math.abs(aqConvert.StrToFloat(value)))
            results.push(array[i]);
          break;

        case "LessThanAbsoluteValue":
          if (Math.abs(aqConvert.StrToFloat(array[i])) < Math.abs(aqConvert.StrToFloat(value)))
            results.push(array[i]);
          break;

        case "WithinRange":
          if (areNumericValuesEqual(array[i], value) || areNumericValuesEqual(array[i], to) || (compareNumericValues(array[i], value) && compareNumericValues(to, array[i])))
            results.push(array[i]);
          break;

        case "Contains":
          if (containsCharacter(array[i], value, false))
            results.push(array[i]);
          break;
          
        case "ContainsMultiple":
          if ((array[i].indexOf(value) == 0) || array[i].charAt(array[i].length-1) == value)
            results.push(array[i]);
          break;
          
        case "DoNotContainsMultiple":
          if (array[i].indexOf(value) < 0 || array[i].indexOf(value1) < 0)
            results.push(array[i]);
          break;  

        case "DoNotContains":
          if (containsCharacter(array[i], value, false) == false)
            results.push(array[i]);
          break;

        case "above":
          if (i < value)
            results.push(array[i]);
          break;

        case "below":
          if (i > value)
            results.push(array[i]);
          break;
      }
    }

    if (noSort == true)
      return results;
    else
      return results.sort();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function removeAfterCharacter(v1, Character)
{
  try
  {
    return (v1.substring(0, v1.indexOf(Character)));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getValueAfterCharacter(v1, Character)
{
  try
  {
    var n = v1.lastIndexOf(Character);
    return (v1.substring(n + 1));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//THIS FUNCTION IS NOT GETTING USED
//Ahead of each test we want to ensure a clean log file dir
function clearLogDirectory()
{
  try
  {
    var filePath = CLEARLOG_FILEPATH;
    if (aqFileSystem.Exists(filePath))
    {
      aqFileSystem.DeleteFolder(filePath, true);
      vCheckpoint("Velocity GUI logs cleared!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//THIS FUNCTION IS NOT GETTING USED
function checkBuild(strBuildVersion)
{
  try
  {
    //Get the actual build version from string.
    if (strBuildVersion.length > 1)
      var strBuildVersion = strBuildVersion.split(" ");
    else
      var strBuildVersion = Sys.Clipboard.split(" ");

    //Opens the specified file for reading
    var myFile = aqFile.OpenTextFile(TestedApps.Citi_Velocity_Bootstrapper.Path + "build.txt", aqFile.faRead, aqFile.ctANSI);
    Log.Message("Checking build.txt @" + TestedApps.Citi_Velocity_Bootstrapper.Path + "build.txt");

    while (!myFile.IsEndOfFile())
    {
      s = myFile.ReadLine();
      var x = s.search(strBuildVersion[2]);
      if (x > 0)
      {
        vCheckpoint("Build Match: " + s);
        break;
      }
    }
    // Closes the file
    myFile.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getRandomInt(min, max)
{
  try
  {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function searchFile(strFilePath, strSearchString)
{
  try
  {
    var myFile = aqFile.OpenTextFile(strFilePath, aqFile.faRead, aqFile.ctANSI);
    Log.Message("Checking file @ " + strFilePath);
    while (!myFile.IsEndOfFile())
    {
      s = myFile.ReadLine();
      var x = s.search(strSearchString);
      if (x > 0)
      {
        vCheckpoint("String Match: " + s);
        return true;
        break;
      }
    }
    myFile.Close();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Searching a value in the String
function searchValue(strString, strSearchval)
{
  try
  {
    var result = strString.search(strSearchval);
    if (result >= 0)
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getYear(num)
{
  try
  {
    var dateObj = new Date();
    var year = dateObj.getFullYear() + num;
    return year;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function deleteFile(strFilePath)
{
  try
  {
    aqFileSystem.DeleteFile(strFilePath);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getCurrentFolder(strFilePath)
{
  try
  {
    return aqFileSystem.getCurrentFolder();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function setCurrentFolder(strFolderPath)
{
  try
  {
    aqFileSystem.SetCurrentFolder(strFolderPath);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function dateTimeToString(dateVal, strDateTimeStampFormat)
{
  try
  {
    return aqConvert.DateTimeToFormatStr(dateVal, strDateTimeStampFormat);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getFormattedCurrentTimeStamp(strDateTimeStampFormat)
{
  try
  {
    //strformat :- %m/%d/%y for 03/14/2017
    //strformat :- %m-%d-%y for 03-14-2017
    return aqConvert.DateTimeToFormatStr(aqDateTime.Now(), strDateTimeStampFormat);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Trim type value as below
//stLeading     1     Leading spaces will be trimmed.
//stTrailing    2     Trailing spaces will be trimmed.
//stAll         3     Both leading and trailing spaces will be trimmed.
function trimString(InputString, TrimType)
{
  try
  {
    return aqString.Trim(InputString, TrimType);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function strToFloat(strNumber)
{
  try
  {
    if (isNumeric(strNumber))
      return aqConvert.StrToFloat(strNumber);
    else
      return null;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function varToInt(strNumber)
{
  try
  {
    if (isNumeric(strNumber))
      return aqConvert.VarToInt(strNumber);
    else
      return null;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function stringToDate(strInputDate)
{
  try
  {
    //https://support.smartbear.com/testcomplete/docs/reference/program-objects/aqconvert/strtodate.html
    return (aqConvert.StrToDate(strInputDateTime));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function stringToTime(strInputTime)
{
  try
  {
    //https://support.smartbear.com/testcomplete/docs/reference/program-objects/aqconvert/strtotime.html
    return (aqConvert.StrToTime(strInputTime));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function stringToDateTime()
{
  try
  {
    //https://support.smartbear.com/testcomplete/docs/reference/program-objects/aqconvert/strtodatetime.html
    //The method recognizes dates in the following formats: "dd/mm/yy", "dd/mm/yyyy", "mm/dd/yy", "mm/dd/yyyy" and "yyyy/mm/dd
    //E.g.: aqConvert.StrToDateTime("06/22/2010 03:12 PM")
    //aqConvert.StrToDateTime("06/22/2010")
    //aqConvert.StrToDateTime("03:12 PM")
    //aqConvert.StrToDateTime("10:56:35 AM")
    return (aqConvert.StrToDate(strInputDateTime));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function convertDateTimeToHoursMins(inputDateTime, returnType)
{
  try
  {
    var timeValHr = inputDateTime.GetHours();
    var timeValMins = inputDateTime.GetMinutes();
    var timeValSecs = inputDateTime.GetSeconds();
    var totalTimeInMins = (timeValHr * 60) + timeValMins;
    var totalTimeInSecs = (totalTimeInMin * 60) + timeValSecs;

    if (returnType == "MINUTES")
      return totalTimeInMins;
    else
      return totalTimeInSecs;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getDatasetFromRecordSet(Recordset)
{
  try
  {
    var object = {};
    Recordset.MoveFirst();
    while (!Recordset.EOF)
    {
      var propertyName = Recordset.Fields.Item("ParameterName").Value;
      var propertyValue = Recordset.Fields.Item("ParameterValue").Value;
      object[propertyName] = propertyValue;
      Recordset.MoveNext();
    }
    return object;
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function getDSFromRS(Recordset)
{
  try
  {
    Recordset.MoveFirst();
    while (!Recordset.EOF)
    {
      var object = {};
      for (i = 0; i < Recordset.Fields.Count; i++)
      {
        var propertyName = Recordset.Fields.Item(i).Name;
        var propertyValue = Recordset.Fields.Item(i).Value;
        if (propertyValue && propertyValue != null && propertyValue != "")
          object[propertyName] = propertyValue;
        else
          object[propertyName] = "";
      }
      Recordset.MoveNext();
    }
    return object;
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function getDSArrayFromRS(Recordset)
{
  try
  {
    var objects = [];
    Recordset.MoveFirst();
    while (!Recordset.EOF)
    {
      var object = {};
      for (i = 0; i < Recordset.Fields.Count; i++)
      {
        var propertyName = Recordset.Fields.Item(i).Name;
        var propertyValue = Recordset.Fields.Item(i).Value;
        if (propertyValue && propertyValue != null && propertyValue != "")
          object[propertyName] = propertyValue;
        else
          object[propertyName] = "";
      }
      objects.push(object);
      Recordset.MoveNext();
    }
    return objects;
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function getRecordSetAsArray(Recordset, ColumnName)
{
  try
  {
    var object = {};
    Recordset.MoveFirst();
    while (!Recordset.EOF)
    {
      var propertyName = Recordset.Fields.Item(ColumnName).Value;
      object[propertyName] = propertyName;
      Recordset.MoveNext();
    }
    return object;
  }
  catch (e)
  {
    Log.Error(e);
    return null;
  }
}

function trimRemarks(str)
{
  try
  {
    if (str.length < 254)
      return str
    str = aqString.SubString(str, 0, 251);
    str = str + "..."
    return str;
  }
  catch (e)
  {
    Log.Error(e);
    return "";
  }
}

function getText(control)
{
  try
  {
    if (control.Exists && aqObject.IsSupported(control, "Text"))
    {
      if (control.Text instanceof String)
        return control.Text;
      else
      {
        if (aqObject.IsSupported(control, "NativeChromeObject"))
          return (control.Text);
        else
          return (aqObject.IsSupported(control.Text, "OleValue") ? control.Text.OleValue : control.Text);
      }
    }
    else if (aqObject.IsSupported(control, "OleValue"))
      return control.OleValue;
    else if (aqObject.IsSupported(control, "WPFControlText"))
      return control.WPFControlText;
    else if (aqObject.IsSupported(control, "contentText"))
      return control.contentText;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromCEFList(comboBox, value)
{
  try
  {
    if (getText(comboBox) == value)
      Log.Message("Value (" + value + ") is already selected in the dropdown!");
    else
    {
      Delay(1000);
      vClickAction(comboBox, 'Click');

      var arrProp = new Array("ObjectType", "contentText");
      var arrValue = new Array('TextNode', value);
      var itemToSelect = bootStrapperApp.FindChild(arrProp, arrValue, MAX_CHILDS);

      if (itemToSelect.Exists)
        vClickAction(itemToSelect, 'Click');
      else
      {
        Log.Error("List item (" + value + ") does not exist!");
        vClickAction(comboBox, 'Click');
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromList(module, comboBox, value, cefIndicator)
{
  try
  {
    if (cefIndicator && cefIndicator == true)
      selectFromCEFList(comboBox, value);
    else
    {
      if (comboBox.Exists)
      {
        if (!(areStringValuesEqual(getText(comboBox), value, false)))
        {
          var result = false;
          var list;
          for (var i = 0; i < 3; i++)
          {
            Delay(1000);
            vClickAction(comboBox, 'Click');
            Delay(1000);

            list = module.FindChild("Name", 'WPFObject("ScrollViewer", "", 1)', MAX_CHILDS);
            if (list.Exists)
            {
              result = true;
              break;
            }
          }

          if (!result)
          {
            Log.Error("Cannot pop open the dropdown list in " + comboBox.Name + "!");
            return;
          }

          var vSb = list.FindChild("Name", 'WPFObject("PART_VerticalScrollBar")', MAX_CHILDS);
          if (vSb && vSb.Exists && IsVisibleOnScreen(vSb))
          {
            var startTime = aqDateTime.Now();
            while (vSb.wPosition > 0)
              list.MouseWheel(1);

            var itemToSelect = list.FindChild("WPFControlText", value, MAX_CHILDS);
            while (!(itemToSelect.Exists))
            {
              itemToSelect = list.FindChild("WPFControlText", value, MAX_CHILDS);
              if (!itemToSelect.Exists)
              {
                list.MouseWheel(-1);
                Delay(200);
              }

              var currentTime = aqDateTime.Now();
              if (aqDateTime.GetSeconds(aqDateTime.TimeInterval(currentTime, startTime)) >= 10)
              {
                Log.Error("Could not find (" + value + ") within 10 seconds!");
                return;
              }
            }
            Delay(1000);
            if (itemToSelect.Exists)
            {
              if (itemToSelect.ClrClassName != "ComboBoxItem" && itemToSelect.ClrClassName != "ListBoxItem")
                itemToSelect = itemToSelect.parent;
              vClickAction(itemToSelect, 'Click');
            }
            else
              Log.Error("Could not find list in " + comboBox.Name + "!");
          }
          else
          {
            var itemToSelect = list.FindChild("WPFControlText", value, 2);
            if (itemToSelect && itemToSelect.Exists)
            {
              if (itemToSelect.ClrClassName != "ComboBoxItem" && itemToSelect.ClrClassName != "ListBoxItem")
                itemToSelect = itemToSelect.parent;
              vClickAction(itemToSelect, 'Click');
            }
            else
            {
              Log.Error("List item (" + value + ") does not exist!");
              vClickAction(comboBox, 'Click');
            }
          }
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromTypeList(module, comboBox, value)
{
  try
  {
    if (comboBox.Exists)
    {
      if (!(areStringValuesEqual(getText(comboBox), value, false)))
      {
        var editCB = comboBox.FindChild("Name", 'WPFObject("PART_EditableTextBox")', MAX_CHILDS);
        if (editCB && editCB.Exists)
        {
          /*vClickAction(editCB, 'DoubleClick');
          Delay(500);
          editCB.Keys("[BS]");
          Delay(500);
          editCB.Keys(value);
          Delay(500);
          editCB.Keys("[Down]");*/
          comboBox = editCB;
        }
        vClickAction(comboBox, 'DoubleClick');
        Delay(500);
        comboBox.Keys("[BS]");
        Delay(500);
        comboBox.Keys(value);
        Delay(500);
        comboBox.Keys("[Down]");

        Delay(1000);
        var list = module.FindChild("Name", 'WPFObject("HwndSource: PopupRoot", "")', MAX_CHILDS).FindChild("Name", 'WPFObject("PopupRoot", "", 1)', 0);
        if (list != null)
        {
          var itemToSelect = list.FindChild("Name", 'WPFObject("TextBlock", "' + value + '", 1)', 2);
          if (itemToSelect && itemToSelect.Exists)
            vClickAction(itemToSelect, 'Click');
          else
          {
            Log.Error("List item " + value + " does not exist!");
            comboBox.Keys("[Enter]");
          }
        }
        else
          Log.Error("Could not find list in " + comboBox + "!");
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromPopupList(module, comboBox, value, cefIndicator)
{
  try
  {
    if (cefIndicator && cefIndicator == true)
      selectFromCEFPopupList(module, comboBox, value);
    else
    {
      if (comboBox.Exists)
      {
        vClickAction(comboBox, 'Click');
        Delay(1000);

        var itemToSelect = module.FindChild("WPFControlText", value, MAX_CHILDS);
        if (itemToSelect.Exists)
          vClickAction(itemToSelect, 'Click');
        else
        {
          Log.Error("List item " + value + " does not exist!");
          vClickAction(comboBox, 'Click');
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromCEFPopupList(module, comboBox, value)
{
  try
  {
    if (comboBox.Exists)
    {
      vClickAction(comboBox, 'Click');
      Delay(1000);

      var itemToSelect = module.FindChild("innerText", value, MAX_CHILDS);
      if (itemToSelect.Exists)
        vClickAction(itemToSelect, 'Click');
      else
      {
        Log.Error("List item " + value + " does not exist!");
        vClickAction(comboBox, 'Click');
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function typeSelectDropDownValue(module, comboBox, value)
{
  try
  {
    Delay(500);
    if (comboBox.Exists)
    {
      if (!(areStringValuesEqual(getText(comboBox), value, false)))
      {
        vClickAction(comboBox, 'DoubleClick');
        comboBox.Keys("[BS]");
        comboBox.Keys(value);
        var list = module.FindChild("Name", 'WPFObject("HwndSource: PopupRoot", *)', MAX_CHILDS).WPFObject("PopupRoot", "", 1);
        Delay(1000);
        if (list != null)
        {
          var itemToSelect = list.FindChild("WPFControlText", value, MAX_CHILDS);
          //Log.Message(itemToSelect.FullName);
          if (itemToSelect.Exists)
          {
            Delay(500);
            vClickAction(itemToSelect, 'Click');
          }
          else
          {
            Log.Error("List item " + value + " does not exist!");
            comboBox.Keys("[Enter]");
          }
        }
        else
          Log.Error("Could not find list in " + comboBox + "!");
        Delay(1000);
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function openTypeSelectDropDown(module, comboBox, value)
{
  try
  {
    Delay(500);
    if (comboBox.Exists)
    {
      if (!(areStringValuesEqual(getText(comboBox), value, false)))
      {
        var cbArrow = comboBox.FindChild("Name", 'WPFObject("Arrow")', MAX_CHILDS);
        vClickAction(cbArrow, 'Click');

        var tbCombo = comboBox.FindChild("Name", 'WPFObject("PART_EditableTextBox")', MAX_CHILDS);
        tbCombo.Keys("[BS]");
        tbCombo.Keys(value);

        var list = module.FindChild("Name", 'WPFObject("HwndSource: PopupRoot", *)', MAX_CHILDS).WPFObject("PopupRoot", "", 1);
        Delay(1000);
        if (list != null)
        {
          var itemToSelect = list.FindChild("WPFControlText", value + "*", MAX_CHILDS);
          if (itemToSelect.Exists)
          {
            Delay(500);
            vClickAction(itemToSelect, 'Click');
          }
          else
          {
            Log.Error("List item " + value + " does not exist!");
            comboBox.Keys("[Enter]");
          }
        }
        else
          Log.Error("Could not find list in " + comboBox + "!");
        Delay(1000);
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function setValue(control, value)
{
  try
  {
    if (control.Exists)
    {
      var tempValue;
      if (typeof value === 'number')
        tempValue = aqConvert.IntToStr(value);
      else
        tempValue = value;
      if (!(areStringValuesEqual(getText(control), tempValue, false)))
      {
        var editTbx = control.FindChild("Name", 'WPFObject("PART_TextBox")', MAX_CHILDS);
        if (editTbx && editTbx.Exists)
          control = editTbx;

        vFocus(control);
        if (aqObject.IsSupported(control, "Clear"))
          control.Clear();

        vClickAction(control, 'DoubleClick');
        control.Keys("^a[Del]");

        control.Keys(value);
      }
    }
    else
      Log.Error("Control named " + control + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function rightClickSetValueEnter(control, value)
{
  try
  {
    if (control.Exists)
    {
      var tempValue;
      if (typeof value === 'number')
        tempValue = aqConvert.IntToStr(value);
      else
        tempValue = value;
      if (!(areStringValuesEqual(getText(control), tempValue, false)))
      {
        vFocus(control);
        control.ClickR();
        control.Keys("[Del]");
        control.Keys(value);
        control.Keys("[Enter]");
        Delay(500);
      }
    }
    else
      Log.Error("Control named " + control + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function typeValue(control, value)
{
  try
  {
    if (control.Exists)
    {
      if (!(areStringValuesEqual(getText(control), value, false)))
      {
        vClickAction(control, 'Click');
        control.Keys("[Del]");
        control.Keys("[Del]"); //In Equities preferences window, 1 Del button changes the value to 0. So, using it twice to empty the value.
        control.Keys(value);
      }
    }
    else
      Log.Error("Control named " + control + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function changeCheckBox(control, state, cefIndicator)
{
  try
  {
    if (cefIndicator && cefIndicator == true)
      changeCEFCheckBox(control, state);
    else
    {
      if (control.Exists)
      {
        if (IsChecked(control) != state)
          vClickAction(control, 'Click');
      }
      else
        Log.Error("Control named " + control + " does not exist!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function changeCEFCheckBox(control, state)
{
  try
  {
    if (control.Exists)
    {
      if (control.firstChild.checked != state)
        vClickAction(control, 'Click');
    }
    else
      Log.Error("Control named " + control + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectCEFRadioButton(control)
{
  try
  {
    if (control.Exists)
    {
      var childObject = control.FindChild("className", 'mat-radio-inner-circle', MAX_CHILDS);
      if (!(childObject.VisibleOnScreen))
        control.Click();
    }
    else
      Log.Error("Control named " + control + " does not exist!");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function vsplit(InputString, CharacterToSplitOn)
{
  try
  {
    return InputString.split(CharacterToSplitOn);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function incrementValue(control, increment)
{
  try
  {
    var btnUpArrow = control.FindChild("Name", 'WPFObject("PART_UPBUTTON")', MAX_CHILDS);
    vFocus(btnUpArrow);
    btnUpArrow.HoverMouse();
    if (increment != 0)
      for (var i = 0; i <= Math.abs(increment) - 1; i++)
        vClickButton(btnUpArrow);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function decrementValue(control, decrement)
{
  try
  {
    var btnDownArrow = control.FindChild("Name", 'WPFObject("PART_DOWNBUTTON")', MAX_CHILDS);
    vFocus(btnDownArrow);
    btnDownArrow.HoverMouse();
    if (decrement != 0)
      for (var i = 0; i <= Math.abs(decrement) - 1; i++)
        vClickButton(btnDownArrow);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function increaseDecreaseValue(control, amount, cefIndicator)
{
  try
  {
    if (cefIndicator && cefIndicator == true)
      increaseDecreaseCEFValue(control, amount);
    else
    {
      if (amount != 0)
      {
        if (amount < 0)
          var btnArrow = control.FindChild("Name", 'WPFObject("PART_DOWNBUTTON")', MAX_CHILDS);
        else
          var btnArrow = control.FindChild("Name", 'WPFObject("PART_UPBUTTON")', MAX_CHILDS);

        vFocus(btnArrow);
        btnArrow.HoverMouse();
        for (var i = 0; i <= Math.abs(amount) - 1; i++)
          vClickButton(btnArrow);
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Inc Dec using mouse
function increaseDecreaseCEFValue(control, amount)
{
  try
  {
    if (amount != 0)
    {
      //var btnArrow = control.FindChild("Name", 'Panel("numericUpDownDivId")', MAX_CHILDS);
      var btnArrow = control.FindChild(new Array("ObjectType", "className"), new Array("Panel", "arrow-container"), MAX_CHILDS);
      var destX = btnArrow.ScreenLeft + (btnArrow.Width / 2);
      var delay = 1;

      if (amount < 0)
      {
        var destY = btnArrow.ScreenTop + (btnArrow.Height / 2) + 3;
        LLPlayer.MouseMove(destX, destY, delay);
        for (var i = 0; i <= Math.abs(amount) - 1; i++)
        {
          LLPlayer.MouseDown(MK_LBUTTON, destX, destY, delay);
          LLPlayer.MouseUp(MK_LBUTTON, destX, destY, delay);
          Delay(1000);
        }
      }

      if (amount > 0)
      {
        var destY = btnArrow.ScreenTop + (btnArrow.Height / 2) - 3;
        LLPlayer.MouseMove(destX, destY, delay);
        for (var i = 0; i <= Math.abs(amount) - 1; i++)
        {
          LLPlayer.MouseDown(MK_LBUTTON, destX, destY, delay);
          LLPlayer.MouseUp(MK_LBUTTON, destX, destY, delay);
          Delay(1000);
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function killAppInstances(ProcesssList)
{
  try
  {
    Sys.Refresh();
    for (j = 0; j < ProcesssList.length; j++)
    {
      var p = Sys.WaitProcess(ProcesssList[j], 100);
      if (p.Exists)
      {
        //vDebug("Found App Instance with Process Id: " + p.Id + " IsOpen: " + p.IsOpen);
        p.Close();
        if (p && p.Exists)
          p.Terminate();
        Sys.Refresh();
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function terminateProcess(ProcesssList)
{
  try
  {
    Sys.Refresh();
    for (j = 0; j < ProcesssList.length; j++)
    {
      var p = Sys.WaitProcess(ProcesssList[j], 100);
      if (p.Exists)
      {
        p.Terminate();
        Sys.Refresh();
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Function to check if only 'value' exists in all the items of the Array1
function checkIfOneValueInArray(Array1, value)
{
  try
  {
    for (var i = 0; i < Array1.length; i++)
    {
      if (Array1[i] != value)
        return false;
    }
    return true;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//numeric = true to verify numeric values 
function checkIfValueExistsInArray(Array1, value, numeric)
{
  try
  {
    for (var i = 0; i < Array1.length; i++)
    {
      if (numeric || numeric != null || numeric != undefined)
      {
        if(areNumericValuesEqual(Array1[i], value))
        return true;
      }
      else
      {
        if (Array1[i] == value)
          return true;
      }
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
    return false;
  }
}

//Returns array of elements with the property extracted from its Objects. textContent/contentText etc
function arrayOfPropertyValue(array, property)
{
  try
  {
    var results = new Array();
    for (var i = 0; i < array.length; i++)
    {
      var value = aqString.Trim(getPropertyOfObject(array[i], property), aqString.stAll);
      results.push(value);
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns sorted array back
function arraySort(array)
{
  try
  {
    return array.sort();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Function to check if values  in Array1 and Array2 are same 
//type = "numeric" or empty
function compareValuesInArray(Array1, Array2, type)
{
  try
  {
    if (!Array1 || !Array2 || Array1.length != Array2.length)
      return false;

    if (Array1.length == 0 && Array2.length == 0)
      return true;

    if (type && type == "numeric")
    {
      for (var i = 0; i < Array1.length; i++)
      {
        if (areNumericValuesEqual(Array1[i], Array2[i]) == false)
          return false;
      }
      return true;
    }
    else
    {
      for (var i = 0; i < Array1.length; i++)
      {
        if (aqString.Trim(Array1[i], aqString.stAll) != aqString.Trim(Array2[i], aqString.stAll))
          return false;
      }
      return true;
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Array to find total number of occurance of a char 
function arrayFindOccurance(array, value)
{
  try
  {
    var finalCount = 0;
    for (var i = 0; i < array.length; i++)
    {
      if (array[i].indexOf(value) >= 0)
        finalCount = finalCount + 1;
    }
    return finalCount;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns the index of matching value inside an array
function returnIndex(array, value)
{
  try
  {
    for (var i = 0; i < array.length; i++)
    {
      if (array[i] == value)
        return i;
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns index if array contains a value
function returnIndexContains(array, value)
{
  try
  {
    for (var i = 0; i < array.length; i++)
    {
      if (array[i].className.indexOf(value) >= 0)
        return i;
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Return obj of a index
function returnControl(array, index)
{
  try
  {
    for (var i = 0; i < array.length; i++)
    {
      if (i == index)
        return array[i];
    }
    return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function areNumericValuesEqual(value1, value2)
{
  try
  {
    if (aqConvert.StrToFloat(value1) == aqConvert.StrToFloat(value2))
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns true if value1 is greater than value2
function compareNumericValues(value1, value2)
{
  try
  {
    if (aqConvert.StrToFloat(value1) > aqConvert.StrToFloat(value2))
      return true;
    else
      return false;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Move an array element from a index to another index
function arrayMove(array, fromIndex, toIndex)
{
  try
  {
    if (toIndex === fromIndex)
      return array;

    var target = array[fromIndex];
    var increment = toIndex < fromIndex ? -1 : 1;
    for (var i = fromIndex; i != toIndex; i += increment)
      array[i] = array[i + increment];

    array[toIndex] = target;
    return array;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Combine 2 array to a 2D array
function arrayCombineTwoD(array1, array2)
{
  try
  {
    var result = [];
    if (array1.length != array1.length)
      return false;
    else
      for (var i = 0; i < array1.length; i++)
        result.push([array1[i], array2[i]]);

    return result;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Compare 2D arrays
function arrayCompareTwoD(array1, array2)
{
  try
  {
    var result = [];
    var a = 0;
    var b = 1;
    if (array1.length != array2.length)
      return false;
    else
      for (var i = 0; i < array1.length; i++)
      {
        if ((array1[i][a] != array2[i][a]) && (array1[i][b] != array2[i][b]))
          return false;
      }
    return true;
  }
  catch (e)
  {
    Log.Error(e);
  }
}


//Function to remove values from Array2 that exist is Array1 and return Array2 
function removeItemsInSubArray(Array1, Array2)
{
  try
  {
    for (var i = 0; i < Array1.length; i++)
    {
      if (Array2.Count > 0)
      {
        if (Array2.Exists(Array1[i]))
          Array2.Remove(Array1[i]);
      }
      else
        break;
    }
    return Array2;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Removes trailing zeroes from numeric values in a string
function removeTrailingZeroFromNumberInString(message)
{
  try
  {
    var strArray = message.split(" ");
    for (var i = 0; i < strArray.length; i++)
    {
      if (!isNaN(parseFloat(strArray[i])))
        strArray[i] = (parseFloat(strArray[i])).toString();
    }
    message = strArray.join(" ");
    return message;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getSubStringMsg(message, character, firstOccurance, lastOccurance)
{
  try
  {
    var firstOccuranceIndex = 0;
    var lastOccuranceIndex = 0;
    var myString = message;
    var index = 0;

    for (var i = 1; i <= lastOccurance; i++)
    {
      index = myString.indexOf(character, index + 1);
      if (i == firstOccurance)
        firstOccuranceIndex = index;

      if (i == lastOccurance)
        lastOccuranceIndex = index;
    }
    myString = aqString.SubString(myString, firstOccuranceIndex + 1, lastOccuranceIndex - firstOccuranceIndex - 1);
    return myString;
  }
  catch (e)
  {
    Log.Error(e);
    return "";
  }
}

function absoluteValue(intNumber)
{
  try
  {
    return Math.abs(intNumber);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function floorValue(intNumber)
{
  try
  {
    return Math.floor(intNumber);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function ceilValue(intNumber)
{
  try
  {
    return Math.ceil(intNumber);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function stringToFloat(strInputVal)
{
  try
  {
    return (aqConvert.StrToFloat(strInputVal));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function arrayToString(arrInput, charSeparator)
{
  try
  {
    return arrInput.join(charSeparator);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function replaceNewLine(strInput, strReplacement)
{
  try
  {
    return strInput.replace(/\r\n/, strReplacement);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Update the local system locale using the Win32Api locale must match exact to windows version
function setLocale(locale)
{
  try
  {
    //Must have the exact locale string.
    var w;
    Win32API.WinExec("RunDll32.exe shell32.dll,Control_RunDLL intl.cpl,,0", SW_SHOW);
    Sys.Refresh()
    Delay(500)
    w = Sys.Process("rundll32").Window("#32770", "Region and Language", 1)

    w.Window("#32770", "Formats", 1).Window("ComboBox", "", 1).ClickItem(locale);
    if (IsEnabled(w.Window("Button", "&Apply")))
      w.Window("Button", "&Apply").ClickButton();

    if (IsEnabled(w.Window("Button", "OK")))
      w.Window("Button", "OK").ClickButton();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get the count of the decimal places
function getDecimalPlaces(strnum)
{
  try
  {
    var match = ('' + strnum).match(/(?:\.(\d+))?(?:[eE]([+-]?\d+))?$/);
    if (!match)
    {
      return 0;
    }
    return Math.max(0, (match[1] ? match[1].length : 0));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getFileName(strFileUrl)
{
  try
  {
    return aqFileSystem.GetFileName(strFileUrl);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getFormattedString(VarInputValue, format)
{
  try
  {
    //https://support.smartbear.com/testcomplete/docs/reference/program-objects/aqstring/format-specifiers.html
    return (aqString.Format(format, VarInputValue));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getPrecision(Number)
{
  try
  {
    return ((+Number).toFixed(20)).replace(/^-?\d*\.?|0+$/g, '').length;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getStringWithDecimalPlaces(Number, DecimalPosition)
{
  try
  {
    var strNumber = "" + Number;
    if (DecimalPosition == 0)
      var position = strNumber.indexOf(".");
    else
      var position = strNumber.indexOf(".") + 1 + DecimalPosition;

    var strPreciseString = aqString.SubString(strNumber, 0, position);
    return strPreciseString;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getTimeStamp()
{
  try
  {
    return aqDateTime.Now();
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Applicable for date variable type only in a sorted array
function removeDuplicatesFromArray(arr)
{
  try
  {
    var results = new Array();
    for (var i = 0; i < arr.length - 1; i++)
    {
      if (aqDateTime.Compare(arr[i + 1], arr[i]) !== 0)
      {
        results.push(arr[i]);
        results.push(arr[i + 1]);
      }
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Applicable for string and numeric type
function sortRemoveDuplicatesFromArray(arr)
{
  try
  {
    sortedArray = arr.sort();
    var results = new Array();
    for (var i = 0; i < sortedArray.length; i++)
    {
      if (aqString.Compare(sortedArray[i + 1], sortedArray[i], true) != 0)
      {
        if ((checkIfValueExistsInArray(results, sortedArray[i]) == false))
          results.push(sortedArray[i]);
      }
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e, "sortRemoveDuplicatesFromArray");
  }
}

function createXmlDOMFromString(strXMLSource)
{
  try
  {
    var objXMLDoc, objXMLRoot;
    strXMLSource = aqString.Trim(strXMLSource);
    if (strXMLSource == "")
      return;

    objXMLDoc = new ActiveXObject("Msxml2.DOMDocument.6.0");
    objXMLDoc.async = false;
    objXMLDoc.loadXML(strXMLSource)
    objXMLRoot = objXMLDoc.documentElement;
    if (!objXMLRoot || objXMLRoot == null)
      return;

    return objXMLDoc;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getXmlAttributeValue(xmlString, nodeName, nodeIndex, attributeName)
{
  try
  {
    var xmlDoc = createXmlDOMFromString(xmlString);
    if (!xmlDoc || xmlDoc == null)
    {
      Log.Error("XML Document could not be generated from the XML String!");
      return "";
    }

    var element = xmlDoc.getElementsByTagName(nodeName)[nodeIndex];
    if (!element || element == null)
    {
      Log.Error("Element Node [" + nodeName + "] at index " + nodeIndex + " could not be found!");
      return "";
    }

    var attributeValue = element.getAttribute(attributeName);
    if (attributeValue == "")
      return "";

    return attributeValue;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Based on a common attribute returns the value of searched attribute 
function getXmlAttributeValueBasedOnCommonProperty(xmlString, nodeName, commonAttributeName, commonAttributeValue, searchAttributeName)
{
  try
  {
    var xmlDoc = createXmlDOMFromString(xmlString);
    if (!xmlDoc || xmlDoc == null)
    {
      Log.Error("XML Document could not be generated from the XML String!");
      return "";
    }

    //Returns all elements with the node name given 
    var element = xmlDoc.getElementsByTagName(nodeName);

    //Traverse through all the nodes in search of the attribute specified
    for (var nodeIndex = 0; nodeIndex < element.length; nodeIndex++)
    {
      var toSearch = element[nodeIndex].getAttribute(commonAttributeName);
      if (toSearch == commonAttributeValue)
      {
        var searchAttributeValue = element[nodeIndex].getAttribute(searchAttributeName);
        return searchAttributeValue;
      }
    }
    return "Not found";
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Inc Dec using keyboard
function increaseDecreaseCEFValueUsingKeyboard(control, amount, cefIndicator)
{
  try
  {
    if (!cefIndicator || cefIndicator == undefined || cefIndicator == null)
    {
      var countDown = VK_DOWN;
      var countUp = VK_UP;
      var delay = 200;
    }
    else if (cefIndicator = true)
    {
      var countDown = VK_SUBTRACT;
      var countUp = VK_ADD;
      var delay = 2000;
    }
    if (amount != 0)
    {
      vClick(control, 'Click');
      if (amount < 0)
      {
        for (var i = 0; i <= Math.abs(amount) - 1; i++)
        {
          LLPlayer.KeyDown(countDown, delay);
          LLPlayer.KeyUp(countDown, delay);
          Delay(delay);
        }
      }

      if (amount > 0)
      {
        for (var i = 0; i <= Math.abs(amount) - 1; i++)
        {
          LLPlayer.KeyDown(countUp, delay);
          LLPlayer.KeyUp(countUp, delay);
          Delay(delay);
        }
      }
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getDataRepositoryFolder()
{
  try
  {
    return (getProjectBaseFolder() + "DataRepository");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getMiscellaneousFolder()
{
  try
  {
    return (getProjectBaseFolder() + "Misc");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function getProjectBaseFolder()
{
  try
  {
    if (!strProjectBaseFolder || strProjectBaseFolder == "" || strProjectBaseFolder == undefined)
      strProjectBaseFolder = Utility.vReplace(Project.Path, "\\", "/", false);

    return strProjectBaseFolder;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function executeJarFunction(strJarName, strParams)
{
  try
  {
    var stJarUrl = getMiscellaneousFolder() + "/" + strJarName;
    //Sys.OleObject("WScript.Shell").Exec("cmd /c java -jar '" + stJarUrl + "' EnableVelocityStreamingAndAutoresponse");

    var oExec = Sys.OleObject("WScript.Shell").Exec("powershell -command Start-Process -FilePath java -ArgumentList '-jar','" + stJarUrl + "','" + strParams + "'"); // works fine
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isAppInitialized(wAUTProcessName, RetryInterval, MaxRetries)
{
  try
  {
    var isInitialized = false;
    isInitialized = ObjectIdentification.vWaitForObjectExists(wAUTProcessName, RetryInterval, MaxRetries);
    return isInitialized;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function scaleFactor(value, scale)
{
  try
  {
    return (value * scale);
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function thousandSeperator(value)
{
  try
  {
    var parts = value.toString().split(".");
    return parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",") + (parts[1] ? "." + parts[1] : "");
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function isAnyAppInitialized(wAUTProcessArray, RetryInterval, MaxRetries)
{
  try
  {
    var isInitialized = false;

    for (var i = 0; i < wAUTProcessArray.length; i++)
    {
      isInitialized = ObjectIdentification.vWaitForObjectExists(wAUTProcessArray[i], RetryInterval, MaxRetries);
      if (isInitialized == true)
        return isInitialized;
    }
    return isInitialized;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function encrypt(strPassword)
{
  try
  {
    // Create Base64 Object
    var Base64 = {
      _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
      encode: function(e)
      {
        var t = "";
        var n, r, i, s, o, u, a;
        var f = 0;
        e = Base64._utf8_encode(e);
        while (f < e.length)
        {
          n = e.charCodeAt(f++);
          r = e.charCodeAt(f++);
          i = e.charCodeAt(f++);
          s = n >> 2;
          o = (n & 3) << 4 | r >> 4;
          u = (r & 15) << 2 | i >> 6;
          a = i & 63;
          if (isNaN(r))
          {
            u = a = 64
          }
          else if (isNaN(i))
          {
            a = 64
          }
          t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
        }
        return t
      },
      decode: function(e)
      {
        var t = "";
        var n, r, i;
        var s, o, u, a;
        var f = 0;
        e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
        while (f < e.length)
        {
          s = this._keyStr.indexOf(e.charAt(f++));
          o = this._keyStr.indexOf(e.charAt(f++));
          u = this._keyStr.indexOf(e.charAt(f++));
          a = this._keyStr.indexOf(e.charAt(f++));
          n = s << 2 | o >> 4;
          r = (o & 15) << 4 | u >> 2;
          i = (u & 3) << 6 | a;
          t = t + String.fromCharCode(n);
          if (u != 64)
          {
            t = t + String.fromCharCode(r)
          }
          if (a != 64)
          {
            t = t + String.fromCharCode(i)
          }
        }
        t = Base64._utf8_decode(t);
        return t
      },
      _utf8_encode: function(e)
      {
        e = e.replace(/\r\n/g, "\n");
        var t = "";
        for (var n = 0; n < e.length; n++)
        {
          var r = e.charCodeAt(n);
          if (r < 128)
          {
            t += String.fromCharCode(r)
          }
          else if (r > 127 && r < 2048)
          {
            t += String.fromCharCode(r >> 6 | 192);
            t += String.fromCharCode(r & 63 | 128)
          }
          else
          {
            t += String.fromCharCode(r >> 12 | 224);
            t += String.fromCharCode(r >> 6 & 63 | 128);
            t += String.fromCharCode(r & 63 | 128)
          }
        }
        return t
      },
      _utf8_decode: function(e)
      {
        var t = "";
        var n = 0;
        var r = c1 = c2 = 0;
        while (n < e.length)
        {
          r = e.charCodeAt(n);
          if (r < 128)
          {
            t += String.fromCharCode(r);
            n++
          }
          else if (r > 191 && r < 224)
          {
            c2 = e.charCodeAt(n + 1);
            t += String.fromCharCode((r & 31) << 6 | c2 & 63);
            n += 2
          }
          else
          {
            c2 = e.charCodeAt(n + 1);
            c3 = e.charCodeAt(n + 2);
            t += String.fromCharCode((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
            n += 3
          }
        }
        return t
      }
    };
    return (Base64.encode(strPassword));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function decrypt(strPassword)
{
  try
  {
    // Create Base64 Object
    var Base64 = {
      _keyStr: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
      encode: function(e)
      {
        var t = "";
        var n, r, i, s, o, u, a;
        var f = 0;
        e = Base64._utf8_encode(e);
        while (f < e.length)
        {
          n = e.charCodeAt(f++);
          r = e.charCodeAt(f++);
          i = e.charCodeAt(f++);
          s = n >> 2;
          o = (n & 3) << 4 | r >> 4;
          u = (r & 15) << 2 | i >> 6;
          a = i & 63;
          if (isNaN(r))
          {
            u = a = 64
          }
          else if (isNaN(i))
          {
            a = 64
          }
          t = t + this._keyStr.charAt(s) + this._keyStr.charAt(o) + this._keyStr.charAt(u) + this._keyStr.charAt(a)
        }
        return t
      },
      decode: function(e)
      {
        var t = "";
        var n, r, i;
        var s, o, u, a;
        var f = 0;
        e = e.replace(/[^A-Za-z0-9\+\/\=]/g, "");
        while (f < e.length)
        {
          s = this._keyStr.indexOf(e.charAt(f++));
          o = this._keyStr.indexOf(e.charAt(f++));
          u = this._keyStr.indexOf(e.charAt(f++));
          a = this._keyStr.indexOf(e.charAt(f++));
          n = s << 2 | o >> 4;
          r = (o & 15) << 4 | u >> 2;
          i = (u & 3) << 6 | a;
          t = t + String.fromCharCode(n);
          if (u != 64)
          {
            t = t + String.fromCharCode(r)
          }
          if (a != 64)
          {
            t = t + String.fromCharCode(i)
          }
        }
        t = Base64._utf8_decode(t);
        return t
      },
      _utf8_encode: function(e)
      {
        e = e.replace(/\r\n/g, "\n");
        var t = "";
        for (var n = 0; n < e.length; n++)
        {
          var r = e.charCodeAt(n);
          if (r < 128)
          {
            t += String.fromCharCode(r)
          }
          else if (r > 127 && r < 2048)
          {
            t += String.fromCharCode(r >> 6 | 192);
            t += String.fromCharCode(r & 63 | 128)
          }
          else
          {
            t += String.fromCharCode(r >> 12 | 224);
            t += String.fromCharCode(r >> 6 & 63 | 128);
            t += String.fromCharCode(r & 63 | 128)
          }
        }
        return t
      },
      _utf8_decode: function(e)
      {
        var t = "";
        var n = 0;
        var r = c1 = c2 = 0;
        while (n < e.length)
        {
          r = e.charCodeAt(n);
          if (r < 128)
          {
            t += String.fromCharCode(r);
            n++
          }
          else if (r > 191 && r < 224)
          {
            c2 = e.charCodeAt(n + 1);
            t += String.fromCharCode((r & 31) << 6 | c2 & 63);
            n += 2
          }
          else
          {
            c2 = e.charCodeAt(n + 1);
            c3 = e.charCodeAt(n + 2);
            t += String.fromCharCode((r & 15) << 12 | (c2 & 63) << 6 | c3 & 63);
            n += 3
          }
        }
        return t
      }
    };
    return (Base64.decode(strPassword));
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Jason parser, returns value for the key pair
function jsonParser(fullLine, key)
{
  try
  {
    var jsonText = JSON.parse(fullLine);
    return jsonText[key];
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Gets the decimal part and performs Decimal Increment/Decrement eg: 0.027(number) + 1(count) = 0.028
function decimalIncDec(type, number, count, decimalFactor)
{
  try
  {
    if (decimalFactor || decimalFactor != undefined || decimalFactor != null)
    {
      var number = aqConvert.StrToFloat(number);
      var type = type == "up" ? "+" : "-";
      for (var i = 0; i < count; i++)
      {
        number = eval("Math.abs(number" + type + "decimalFactor)");
      }
      return number;
    }
    else
    {
      var number = aqConvert.VarToStr(number);
      var parts = number.split(".");
      var length = parts[1].length;
      var addNum = "0.";
      var length = (count < 10) ? (parts[1].length) - 1 : (parts[1].length) - 2;
      for (var i = 0; i < length; i++)
      {
        addNum = addNum + 0;
      }
      addNum = addNum + count;
      return type == "up" ? parseFloat(number) + parseFloat(addNum) : parseFloat(number) - parseFloat(addNum)
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Get Property Value for an Object
//property = "innerText", "title" etc
function getPropertyOfObject(object, property)
{
  try
  {
    return object[property];
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns String arrya after split of character provided
function arrayReturnsStringAfterSplit(array, character)
{
  try
  {
    var results = new Array();
    for (var i = 0; i < array.length; i++)
    {
      var str = vsplit(array[i], ".");
      str = str.length > 1 ? str[1] : str[0];
      results.push(aqString.Trim(str, aqString.stAll));
    }
    return results;
  }
  catch (e)
  {
    Log.Error(e);
  }
}

function selectFromListWpf(list, value)
{
  try
  {
    var itemToSelect = list.FindChild("WPFControlText", value, MAX_CHILDS);    
    if (itemToSelect.Exists)
      vClickAction(itemToSelect, 'Click');
    
    else
    {
      var vSb = list.FindChild("Name", 'WPFObject("PART_VerticalScrollBar")', MAX_CHILDS);
      if (vSb && vSb.Exists && IsVisibleOnScreen(vSb))
      {
        while (vSb.wPosition < vSb.wMax)
        {
          list.MouseWheel(-1);
          Delay(500);
          var itemToSelect = list.FindChild("WPFControlText", value, MAX_CHILDS);
          if (itemToSelect.Exists)
          {
            vClickAction(itemToSelect, 'Click');
            break;
          }
        }
        if (!(itemToSelect.Exists))
          Log.Error("Item " + value + " not found in list!");
      }
      else
        Log.Error("Vertical scrollBar does not exist!");
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Returns Red, Green and Blue components //str can be rgb or rgba
function getRGB(str)
{
  try
  {
    var match = str.match(/rgba?\((\d{1,3}), ?(\d{1,3}), ?(\d{1,3})\)?(?:, ?(\d(?:\.\d?))\))?/);
    return match ?
    {
      Red: match[1],
      Green: match[2],
      Blue: match[3]
    } :
    {};
  }
  catch (e)
  {
    Log.Error(e);
  }
}

//Add/Subtract number in 32nd Formats //type = "up" or "down"
function incDec32ndFormatNumbers(number, type, incDecFactor)
{
  try
  {

    var parts = number.split(/[-:]+/);
    var additionFactorParts = incDecFactor.split(/[-:]+/);
    if (type == "up")
    {
      var number = Math.abs(parseFloat(parts[0]) + parseFloat(additionFactorParts[0]));
      var number1 = Math.abs(parseFloat(parts[1]) + parseFloat(additionFactorParts[1]));
      number1 < 10 ? "0" + number1 : number1;
      var number2 = Math.abs(parseFloat(parts[2]) + parseFloat(additionFactorParts[2]));
      if (number2 > 7)
      {
        number1 = Math.abs(number1 + 01);
        number2 = "00";
      }
      if (number1 > 31)
      {
        number = Math.abs(number + 1);
        number1 = "00";
      }
      return number2 != 4 ? number + "-" + number1 + ":" + number2 : number + "-" + number1 + "+";
    }
    else if (type == "down")
    {
      if (number == "0-00:0")
      {
        vCheckpoint("Cannot subtract from this number");
        return "0-00:0";
      }
      if (parts.length == 2)
      {
        number = parts[0];
        number1 = aqString.Replace(parts[1], "+", "");
        number2 = 3;
        return number + "-" + number1 + ":" + number2;
      }
      var number = parseInt(parts[0]) - parseInt(additionFactorParts[0]);
      var number1 = parseInt(parts[1]) - parseInt(additionFactorParts[1]);
      number1 < 10 ? "0" + number1 : number1;
      if (number1 == -1)
      {
        number = parseInt(number) - 1;
        number1 = 31;
      }
      var number2 = parseInt(parts[2]) - parseInt(additionFactorParts[2]);
      if (number2 == -1)
      {
        number1 = 31;
        number2 = 7;
      }
      return number2 != 4 ? number + "-" + number1 + ":" + number2 : number + "-" + number1 + "+";
    }
  }
  catch (e)
  {
    Log.Error(e);
  }
}
