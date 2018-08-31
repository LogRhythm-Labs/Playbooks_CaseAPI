#################
#
# ImportPlaybooks.ps1
#
# Import all .pbe formatted Playbooks into a deployment
#
# Written by LogRhythm Labs
# July 2018
#
# Requirements:
#
# A LogRhythm account with a user token for accessing the LR Case API. The API Key must be saved to a text file and the file must be accessible from the PowerShell script.
# PowerShell needs to trust the certificate presented by the Case API service. By default the Case API will use self-signed certificates located in C:\Program Files\LogRhythm\LogRhythm Common\LogRhythm API Gateway\tls. Install these into the Trusted Root Certificate Authority Store.
#
# Usage:
#
# ImportPlaybooks.ps1 -Server <host> -APIKeyPath <path> - ImportDir <path>
#
# Parameters: 
#
#  -Server (hostname of service running Case API)
#  -APIKeyPath (path and filename of text file containing the API Key)
#  -ImportDir (Directory Path from which .pbe files will be imported, with a trailing backslash)
#
# 
# Much of this code was inspired by the solution here: https://stackoverflow.com/questions/25075010/upload-multiple-files-from-powershell-script#25083745
# 
# To-dos:
#
# Add error handling for when the playbook already exists (HTTP error 409). Ask the user if they want to overwrite. (add an overwrite switch for the command line)
#
###############

Param(
    #[Parameter(Mandatory=$True)]
    [string]$Server, # add default here if desired, e.g. = 'server.domain.local' or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$APIKeyPath, # add default here if desired, e.g. = 'C:\RestAPI\APIKey.txt' or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$ImportDir # add default here if desired, e.g. = 'C:\PlaybookImport' or uncomment preceding line to force input
   )

#Force PowerShell to use TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Define connection parameters to API
$APIConnection = $Server + ':8501'
$APIKey = Get-Content $APIKeyPath
$token = "Bearer $APIKey"
#$header.add('content-Type','application/x-www-form-urlencoded')
$header = @{'Authorization'=$token}

#Variables for building API call
$url = "https://$APIConnection/lr-case-api/playbooks/import"
$method = 'POST'
$boundary = [System.Guid]::NewGuid().ToString()    #generates a GUID to use as a multipart/form-data boundary
$LF = "`r`n" # carriage return line feed for HTML request body

#Enumerate files in the Import Directory
$Infiles = Get-ChildItem $ImportDir -Filter *.pbe -file
ForEach ($InFile in $Infiles)
    {
    #Get the file path as a string
    $InFilePath = Convert-Path($Infile.PSPath)
    write-host "Importing $InfilePath"
    #Encode the file contents for the web request
    $fileContents = [IO.File]::ReadAllBytes($InFilePath) 
    $enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")
    $fileEnc = $enc.GetString($fileContents)

    # Create the request body. 

    $bodyLines = (
        "--$boundary", 
        "Content-Disposition: form-data; name=`"file`"; filename=`"$InFile`"",
        "Content-Type: application/octet-stream$LF", 
        "$fileEnc", 
        "--$boundary--$LF"
        ) -join $LF

    try {
        # Returns the response gotten from the server (we pass it on).
        #
        Invoke-WebRequest -Uri $URL -Headers $header -Method $method -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 20 -Body $bodylines 
        }
    catch [System.Net.WebException] {
        Write-Error( "FAILED to reach '$URL': $_" )
        throw $_
        }
    }

