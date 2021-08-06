#Fetch parameter value from ADOProect-parameter.json file
$JSONFromFile = Get-Content -Raw -Path .\ADOProject-parameter.json | ConvertFrom-Json
Write-Host "ADO Pat Token = " $JSONFromFile.Pat
Write-Host "ADO Project Name = " $JSONFromFile.ProjectName
Write-Host "ADO Organization = " $JSONFromFile.Organization
$adoOrganization = $JSONFromFile.Organization
$orgUrl = "https://dev.azure.com/$adoOrganization"
$pat = "$JSONFromFile.Pat"
$queryString = "api-version=5.1"

# Create header with PAT
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$header = @{authorization = "Basic $token"}

# Get the list of all projects in the organization
$projectsUrl = "$orgUrl/_apis/projects?$queryString"
Write-Host "ProjectsURL : $projectsUrl" 
#function getAllProjectslist{
    # get and list all projects under current organization
    Write-Host"Inside getAllProjectlist function, ready to execute command"
    $projects = Invoke-RestMethod -Uri $projectsUrl -Method Get -ContentType "application/json" -Headers $header
    Write-Host $projects | ConvertTo-Json
    $projects.value | ForEach-Object {
    Write-Host $_.id $_.name
    }
# }

# getAllProjectslist