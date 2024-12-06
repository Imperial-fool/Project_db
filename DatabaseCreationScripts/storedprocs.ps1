$serverName = "DESKTOP-FGDLSQM\MSSQLSERVER01"
$databaseName = "master"
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;"

# Connect to SQL Server
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

# Get the list of stored procedures
$query = "SELECT name FROM sys.procedures WHERE type = 'P'"
$command = $connection.CreateCommand()
$command.CommandText = $query
$reader = $command.ExecuteReader()

# Loop through stored procedures and save each to a file
while ($reader.Read()) {
    $procName = $reader["name"]
    $procQuery = "EXEC sp_helptext '$procName'"

    # Get the procedure definition
    $procCommand = $connection.CreateCommand()
    $procCommand.CommandText = $procQuery
    $procReader = $procCommand.ExecuteReader()

    $procText = ""
    while ($procReader.Read()) {
        $procText += $procReader[0] + "`r`n"
    }

    # Save each procedure to its own file
    $fileName = "C:\path\to\output\$procName.sql"
    Set-Content -Path $fileName -Value $procText
}

$connection.Close()
