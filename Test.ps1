#Fetch parameter value from ADOProect-parameter.json file
$JSONFromFile = Get-Content -Raw -Path .\ADOProject-parameter.json | ConvertFrom-Json
Write-Host "ADO Pat Token = " $JSONFromFile.Pat
Write-Host "ADO Project Name = " $JSONFromFile.ProjectName
Write-Host "ADO Organization = " $JSONFromFile.Organization
# foreach($val in $JSONFromFile)
# {
#     $JSONFromFile.Pat
#     Write-Host "id = " $val.id " and name = " $val.name 
# }