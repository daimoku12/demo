//USEUNIT Reporter
//USEUNIT Utility

function GetVelocityDatabaseConnection(strEnvironment)
{ 
  if(!VELOCITY_DATABASE_CONNECTION_OBJECT || VELOCITY_DATABASE_CONNECTION_OBJECT == null)
  {
    switch(aqString.ToUpper(strEnvironment))
    {
      case "UAT":
        var oConn = ADO.CreateADOConnection();      
        oConn.ConnectionString = UAT_VELOCITY_DATABASE_CONNECTION_STRING;
        oConn.LoginPrompt = false;  
        oConn.Open();
        VELOCITY_DATABASE_CONNECTION_OBJECT = oConn;
        Reporter.vDebug("Created, and opened database connection with the following connection string: " + UAT_VELOCITY_DATABASE_CONNECTION_STRING);
        break;
      default:
        Reporter.vError("Unexpected environment parameter passed to GetConnection: " + strEnvironment);
        break;
    }
  }  
  
  return VELOCITY_DATABASE_CONNECTION_OBJECT;
}

function CloseVelocityDatabaseConnection()
{
  if(VELOCITY_DATABASE_CONNECTION_OBJECT && VELOCITY_DATABASE_CONNECTION_OBJECT != null)
  {
    try
    {
      Reporter.vDebug("About to close the database connection");    
      VELOCITY_DATABASE_CONNECTION_OBJECT.Close();
      Reporter.vDebug("Database connection closed");
    }
    catch(ex)
    {
      //suppress
      Reporter.vError("Exception closing database connection. Details of exception: " + ex);
    }
  }
  else
  {
    Reporter.vDebug("Database connection was non-existent/null, so not attempting to close it");
  }  
}

function GetVelocityDatabaseRecordset(strEnvironment, strNonUpdateSql)
{
  var oConn = GetVelocityDatabaseConnection(strEnvironment);
  
  if(oConn && oConn != null)
  {
    try
    {
      return oConn.Execute_(strNonUpdateSql);
    }
    catch(ex)
    {
      Reporter.vError("An exception occured trying to get recordset. Exception details: " + ex);
      return null;
    }
  }
  else //this should never happen, but coding defensively
  {
    Reporter.vError("There does not appear to be a connection object to work with");
    return null;
  }
}

function GetDatabaseConnection(strConnectionString, objDBConnection)
{
  try
  { 
    if(Utility.IsEmptyString(strConnectionString))
    {
      Reporter.vError("Connection string function paramter cannot be empty. Please check!");
      return null;
    }
  
    if(IsDBConnectionActive(objDBConnection))
    {
      if( Utility.Contains(strConnectionString, ";", false, true) && Utility.Contains(strConnectionString, "=", false, true) )
      {
        var bDBProviderIdentified = false;
        var strActualDataSource, strActualDatabase, strActualUserID;
        
        var strDBProvider = strConnectionString.split(";")[0];
        strDBProvider = strDBProvider.split("=")[1];
        strDBProvider = Utility.TrimString(strDBProvider, 3);
        
        switch(Utility.ToUpperCase(strDBProvider))
        {
          case "SQLOLEDB":
            bDBProviderIdentified =  true;
            strActualDataSource = objDBConnection.Properties.Item("Data Source").Value;
            strActualDatabase = objDBConnection.Properties.Item("Initial Catalog").Value;
            strActualUserID = objDBConnection.Properties.Item("User ID").Value;
            break;
          
          case "{ADAPTIVE SERVER ENTERPRISE}":
            bDBProviderIdentified =  true;
            strActualDataSource = objDBConnection.Properties.Item("Server Name").Value;
            strActualDatabase = objDBConnection.Properties.Item("Current Catalog").Value;
            strActualUserID = objDBConnection.Properties.Item("User Name").Value;
            break; 
          
          case "ORAOLEDB.ORACLE":
            bDBProviderIdentified =  true;
            strActualDataSource = objDBConnection.Properties.Item("Server Name").Value;
            strActualDatabase = objDBConnection.Properties.Item("Data Source Name").Value;
            strActualUserID = objDBConnection.Properties.Item("User Name").Value;
            break;         
        }
        
        if(bDBProviderIdentified && Utility.Contains(strConnectionString, strActualDataSource, false, true) && Utility.Contains(strConnectionString, strActualDatabase, false, true) && Utility.Contains(strConnectionString, strActualUserID, false, true) )
        {
          Reporter.vDebug("DB Connection is already connected and in active state hence skipped opening the DB connection once again.");
          return objDBConnection;
        }        
      }     
    }   
    
    var oConn = ADO.CreateADOConnection();  
    oConn.ConnectionString = strConnectionString;            
    oConn.LoginPrompt = false;  
    oConn.Open();     
   
    Reporter.vDebug("Created, and opened database connection with the following connection string: " + strConnectionString);       
    return oConn;
  } 
  catch(e)
  {
    Reporter.vError("Unhandled error occured while trying to connect to the database.", "Error Details : " + e, 500);
    return null;
  }  
}

function CloseDatabaseConnection(objDBConnection)
{  
  if(IsDBConnectionActive(objDBConnection))
  {
    try
    {
      Reporter.vDebug("About to close the database connection");    
      objDBConnection.Close();
      Reporter.vDebug("Database connection closed successfully!");
    }
    catch(e)
    {      
      Reporter.vError("Unhandled exception while closing the DB connection. ", "Error Details : " + e, 500);
    }
  }
  else
  {
    Reporter.vDebug("Database connection was non-existent/null, so not attempting to close it.");
  }  
}

function GetDatabaseRecordset(strNonUpdateSql, strConnectionString, objDBConnection)
{
  if(Utility.IsEmptyString(strNonUpdateSql))
  {
    Reporter.vError("'SQL Query' function paramter cannot be empty. Please check!");
    return null;   
  }
  
  if(Utility.IsEmptyString(strConnectionString))
  {
    Reporter.vError("'Connection string' function paramter cannot be empty. Please check!");
    return null;   
  }
   
  var oConn = GetDatabaseConnection(strConnectionString, objDBConnection);  
  
  if(IsDBConnectionActive(oConn))
  {  
    try
    {     
      return oConn.Execute_(strNonUpdateSql);      
    }
    catch(e)
    {
      Reporter.vError("Unhandled error occured while trying  to get the recordset.", "Error details: " + e, 500);
      return null;
    }
  }
  else 
  {
    Reporter.vError("Please check there is no active connection available to retreieve the recordset.");
    return null;
  }
}

function IsNotEmptyRecordSet(objRecordSet)
{
  try
  { 
    var objTempRecordSet = objRecordSet;  
    objTempRecordSet.MoveFirst();
    objTempRecordSet = null;  
    return true;    
  }
  catch(e)
  {    
    return false;
  }  
}

function IsDBConnectionActive(objConnection)
{
  try
  {   
    if(objConnection && objConnection != null)
    {
      return true;
    }
    else
    {
      return false;
    } 
  }
  catch(e)
  {    
    return false;
  } 
}

function GetRecordSetCount(objRecordSet)
{
  try
  {
    if(IsNotEmptyRecordSet(objRecordSet))
    {
      return objRecordSet.RecordCount;
    } 
    else
    {
      return 0; 
    } 
  }
  catch(e)
  {
    Reporter.vError("Unexpected error while determining the recordset recordcount.", "Error Details : " + e, 500);
    return -1;    
  }  
}

function IsRecordSetOpen(objRecordSet)
{
  try
  {   
    if(objRecordSet.State != 0)
    {
    return true;
    }
    else
    {
      return false;  
    }     
  }
  catch(e)
  {    
    return false;
  }  
}