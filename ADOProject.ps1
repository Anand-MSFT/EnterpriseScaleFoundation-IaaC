# Define organization base url, PAT and API version variables
$orgUrl = "https://dev.azure.com/DemoWebAppOrg"
$pat = "{please provide your ADO PAT Token for authentication}"
$queryString = "api-version=5.1"

# Create header with PAT
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$header = @{authorization = "Basic $token"}

# Get the list of all projects in the organization
$projectsUrl = "$orgUrl/_apis/projects?$queryString"

function getAllProjectslist{
    # get and list all projects under current organization
    $projects = Invoke-RestMethod -Uri $projectsUrl -Method Get -ContentType "application/json" -Headers $header
    Write-Host $projects | ConvertTo-Json
    $projects.value | ForEach-Object {
    Write-Host $_.id $_.name
    }
}

# Create new project named Demo
$projectName = "ADORESTAPI-Project"

function createProject{
    $confirmation = Read-Host "Are you sure you want to Create the project $($projectName) (y/n)"
    if ($confirmation.ToLower() -eq 'y') {
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
        Invoke-RestMethod -Uri $createProjectURL -Method Post -ContentType "application/json" -Headers $header -Body ($projectJSON)
        checkStatus
    }
    else {
        Write-Host "Project Creation Skipped. Scipt completed."
    }
}

# Wait for 10 seconds
# Start-Sleep -s 10

function checkStatus{
    # Get Operation Status for Create Project
    # Wait for 10 seconds
    Write-Host "Wait....your request is in progress"
    Start-Sleep -s 10
    
    $operationStatusUrl = "$orgUrl/_apis/operations/$($response.id)?$queryString"
    $response = Invoke-RestMethod -Uri $operationStatusUrl -Method Get -ContentType "application/json" -Headers $header
    Write-Host "Status of your request is :" $response.status
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
    $confirmation = Read-Host "Are you sure you want to delete the project $($projectName) (y/n)"
    if ($confirmation.ToLower() -eq 'y') {
        #Get Projectid
        $projectDetailsUrl = "$orgUrl/_apis/projects/$($projectName)?includeCapabilities=True&$queryString"
        $projectDetails = Invoke-RestMethod -Uri $projectDetailsURL -Method Get -ContentType "application/json" -Headers $header
        $projectId = $projectDetails.id

        # Delete a project
        $deleteURL = "$orgUrl/_apis/projects/$($projectId)?$queryString"
        Invoke-RestMethod -Uri $deleteURL -Method Delete -ContentType "application/json" -Headers $header
        checkStatus
    } else {
        Write-Host "Project not deleted. Scipt completed."
    }
}

getAllProjectslist;
createProject;
deleteProject;