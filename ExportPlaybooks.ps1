#################
#
# ExportPlaybooks.ps1
#
# Export all playbooks in a deployment to .pbe format
#
# Written by Dan Kaiser in LogRhythm Labs
# July 2018
#
# Requirements:
#
# A LogRhythm account with a user token for accessing the LR Case API. The API Key must be saved to a text file and the file must be accessible from the PowerShell script.
# PowerShell needs to trust the certificate presented by the Case API service. By default the Case API will use self-signed certificates located in C:\Program Files\LogRhythm\LogRhythm Common\LogRhythm API Gateway\tls. Install these into the Trusted Root Certificate Authority Store.
#
# Usage:
#
# ExportPlaybooks.ps1 -server <host> -APIKeyPath <path> -Outpath <path>
#
# Parameters: 
#
#  -Server (hostname of service running Case API)
#  -APIKeyPath (path and filename of text file containing the API Key)
#  -Outpath (Path to which export files will be saved, with a trailing backslash)
#
# Todos:
# Add a check for a trailing backspace in the OutPath and fix if necessary
# Check for the existence of the output directory
#
###############

Param(
    #[Parameter(Mandatory=$True)]
    [string]$Server, # add default here if desired, e.g. = 'server.domain.local' or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$APIKeyPath, # add default here if desired, e.g. = 'C:\RestAPI\APIKey.txt' or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$OutPath # add default here if desired, e.g. = 'C:\PlaybookExport\' or uncomment preceding line to force input
   )

#Define connection parameters to API
$APIConnection = $Server + ':8501'
$APIKey = Get-Content $APIKeyPath
$token = "Bearer $APIKey"
$header = @{"Authorization"=$token}

#Force PowerShell to use TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Enumerate playbooks
$url = "https://$APIConnection/lr-case-api/playbooks/"
$method = 'GET'
$playbooks = Invoke-WebRequest -Uri $url -headers $header -Method $method
$playbooksTable = $playbooks.content|ConvertFrom-Json
# Walk through playbook IDs and export them
Foreach($playbook in $playbookstable) 
    {
    $id = $playbook.id
    $ExportPath = $OutPath + $playbook.name + ".pbe"
    write-host $ExportPath
    $method = 'GET'
    $url = "https://$APIConnection/lr-case-api/playbooks/$id/export/"
    Invoke-WebRequest -Uri $url -headers $header -Method $method -outfile $ExportPath -passthru
    }
