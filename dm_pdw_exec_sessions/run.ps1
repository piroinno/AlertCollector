Write-Output "PowerShell Timer trigger function executed at:$(get-date)";

# Get MSI AUTH
$endpoint = $env:MSI_ENDPOINT
$secret = $env:MSI_SECRET
$sqlTokenURI = "https://database.windows.net&api-version=2017-09-01"
$header = @{'Secret' = $secret}
$authenticationResult = Invoke-RestMethod -Method Get -Headers $header -Uri ($endpoint +'?resource=' +$sqlTokenURI)

# CONNECT TO SQL
$SqlServer = $env:SQL_SERVER_NAME
$SqlServerPort = 1433
$Database = "azuredwmonitordb"
$Conn = New-Object System.Data.SqlClient.SqlConnection("Data Source=tcp:$($SqlServer),1433; Initial Catalog=$($Database);")
$Conn.AccessToken = $authenticationResult.access_token

# Open the SQL connection 
$Conn.Open() 

$Cmd=new-object system.Data.SqlClient.SqlCommand("SELECT @@SERVERNAME", $Conn) 
$Cmd.CommandTimeout=120 

# Execute the SQL command 
$Ds=New-Object system.Data.DataSet 
$Da=New-Object system.Data.SqlClient.SqlDataAdapter($Cmd) 
[void]$Da.fill($Ds) 

# Output the count 
$Ds.Tables.Column1 

# Close the SQL connection 
$Conn.Close()