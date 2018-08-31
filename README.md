# Playbooks
PowerShell Scripts for Playbook manipulation through Case API

Requirements:

In order to use these scripts you will need to setup the following:

1) A LogRhythm account with a user token for accessing the LR Case API. The API Key must be saved to a text file and the file must be accessible from the PowerShell script.
2) PowerShell needs to trust the certificate presented by the Case API service. By default the Case API will use self-signed certificates located in C:\Program Files\LogRhythm\LogRhythm Common\LogRhythm API Gateway\tls. Install these into the Trusted Root Certificate Authority Store. 
