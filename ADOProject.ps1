#Fetch parameter value from ADOProect-parameter.json file
$JSONFromFile = Get-Content -Raw -Path .\ADOProject-parameter.json | ConvertFrom-Json
# Define organization base url, PAT and API version variables
$adoOrganization = $JSONFromFile.Organization
$orgUrl = "https://dev.azure.com/$adoOrganization" # "https://dev.azure.com/$JSONFromFile.ADO-Organization"
$pat = $JSONFromFile.Pat
$projectName = $JSONFromFile.ProjectName # "$JSONFromFile.ADO-PAT"
$queryString = "api-version=5.1"

# Create header with PAT
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
#$header = @{authorization = "Basic $token"}
$header = @{authorization = 'Bearer $env:SYSTEM_ACCESSTOKEN'}

# Get the list of all projects in the organization
$projectsUrl = "$orgUrl/_apis/projects?$queryString"

function isProjectExist {
    param ( [string] $projectName )
    # get and list all projects under current organization
    $projectExist = $false
    $projects = Invoke-RestMethod -Uri $projectsUrl -Method Get -ContentType "application/json" -Headers $header
    Write-Host $projects | ConvertTo-Json
    foreach ($val in $projects.value) {
        if ($val.name -match $projectName)
        {
            $projectExist = $true
            break
        }
    }
    return $projectExist;
}

# Wait for 10 seconds
# Start-Sleep -s 10
function checkStatus{
    param( 
            [string] $responseId
         ) 
    
    $operationStatusUrl = "$orgUrl/_apis/operations/$($response.id)?$queryString"
    
    # Wait for 10 seconds
    Write-Host "Wait....your request is in progress"
    Start-Sleep -s 10
    
    # Get Operation Status for respective request for Project e.g. creat/delete/update
    $response = Invoke-RestMethod -Uri $operationStatusUrl -Method Get -ContentType "application/json" -Headers $header
    Write-Host "Status of your request is :" $response.status
}

function createProject{
    $confirmation = $JSONFromFile.CreateNewProject # Read-Host "Are you sure you want to Create the project $($projectName) (y/n)"
    if ($confirmation.ToLower() -eq 'y') {
        $projectExist = isProjectExist -projectName $projectName
        if(!$projectExist)
        {
            $createProjectURL = "$orgUrl/_apis/projects?$queryString"
            $projectJSON = @{name = "$($projectName)"
                        description = "Azure DevOps REST API Demo"
                        capabilities = @{
                            versioncontrol = @{
                                sourceControlType = "Git"
                            }
                            processTemplate = @{
                                # Basic Project
                                templateTypeId = "b8a3a935-7e91-48b8-a94c-606d37c3e9f2"                           
                            }
                        }
                        } | ConvertTo-Json
            $response = Invoke-RestMethod -Uri $createProjectURL -Method Post -ContentType "application/json" -Headers $header -Body ($projectJSON)
            $createprojectId = $response.Id
            if (-not ([string]::IsNullOrEmpty($createprojectId)))
            {
                checkStatus -responseId $createprojectId
            }
        }
        else {
            Write-Host "Project already exist with this name : $projectName"
        }
    }
    else {
        Write-Host "Project Creation Skipped. Scipt completed."
    }
}



function getProjectDetails{
    # Get detailed project information
    $projectDetailsUrl = "$orgUrl/_apis/projects/$($projectName)?includeCapabilities=True&$queryString"
    $projectDetails = Invoke-RestMethod -Uri $projectDetailsURL -Method Get -ContentType "application/json" -Headers $header
    # $projectId = $projectDetails.id
    Write-Host ($projectDetails | ConvertTo-Json | ConvertFrom-Json)
    # $projectDetails.value | ForEach-Object {
    #     Write-Host $_.id $_.name
    #  }
}

function deleteProject{
    # Delete Project
    $confirmation = $JSONFromFile.DeleteExistingProject # Read-Host "Are you sure you want to delete the project $($projectName) (y/n)"
    if ($confirmation.ToLower() -eq 'y') {
        #Get Projectid
        $projectDetailsUrl = "$orgUrl/_apis/projects/$($projectName)?includeCapabilities=True&$queryString"
        $projectDetails = Invoke-RestMethod -Uri $projectDetailsURL -Method Get -ContentType "application/json" -Headers $header
        $projectId = $projectDetails.id
        if(-not ([string]::IsNullOrEmpty($projectId)))
        {
        # Delete a project
        $deleteURL = "$orgUrl/_apis/projects/$($projectId)?$queryString"
        $response = Invoke-RestMethod -Uri $deleteURL -Method Delete -ContentType "application/json" -Headers $header
        $deleteprojectId = $response.Id
            if (-not ([string]::IsNullOrEmpty($deleteprojectId)))
            {
                checkStatus -responseId $deleteprojectId
            }
            else {
                Write-Host "Could not delete this project $projectName, please refer error logs for more detail"
            }   
        }   
        else {
            Write-Host "Project with name $projectName amd id $deleteprojectId does not exist"
        }
    } else {
        Write-Host "Project not deleted. Scipt completed."
    }
}

# getAllProjectslist;
createProject;
deleteProject;