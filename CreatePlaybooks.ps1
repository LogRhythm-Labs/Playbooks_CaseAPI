#################
#
# CreatePlaybooks.ps1
#
# Create playbooks with json files
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
# CreatePlaybooks.ps1 -Server <hostname> -APIKeyPath <path> -PlaybookJSON <path> -ProcedureJSON <path>
#
# Parameters: 
#
#  -Server (hostname of service running Case API)
#  -APIKeyPath (path and filename of text file containing the API Key)
#  -PlaybookJSON (Path with json files for creation of playbook)
#  -ProcedureJSON (Path with json files for creation of procedure)
#
# Sample playbook and procedure JSON files can be found at https://github.com/logrhythm/Playbooks/tree/master/JSONTemplates
# 
#
###############

Param(
    #[Parameter(Mandatory=$True)]
    [string]$Server,# add default here if desired, e.g. = 'server.domain.local' or uncomment preceding line to force input   
    #[Parameter(Mandatory=$True)]
    [string]$APIKeyPath, # add default here if desired, e.g. = 'C:\RestAPI\APIKey.txt' or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$PlaybookJSON, # add default here if desired, e.g. = 'C:\PlaybookCreate\CreatePlaybookRequest.json'or uncomment preceding line to force input
    #[Parameter(Mandatory=$True)]
    [string]$ProcedureJSON # add default here if desired, e.g. = 'C:\PlaybookCreate\UpdatePlaybookProcedure.json' or uncomment preceding line to force input
    )

#Define connection parameters to API
$APIConnection = $Server + ':8501'
$APIKey = Get-Content $APIKeyPath
$token = "Bearer $APIKey"
$header = @{"Authorization"=$token}

#Force PowerShell to use TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create playbook
$url = "https://$APIConnection/lr-case-api/playbooks/"
$method = 'POST'
$body = get-content $PlaybookJSON
$playbook = Invoke-WebRequest -Uri $url -headers $header -Method $method -body $body

# Capture GUID from creation response for updating prcedures 
$playbooksTable = $playbook.content|ConvertFrom-Json
$playbookID = $playbooksTable.id

#Populate Playbook with procedures
$url = "https://$APIConnection/lr-case-api/playbooks/$playbookID/procedures/"
$method = 'PUT'
$body = get-content $ProcedureJSON
$playbook = Invoke-WebRequest -Uri $url -headers $header -Method $method -body $body
