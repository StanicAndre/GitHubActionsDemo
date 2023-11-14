# parameters required to call the API
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $github_token
)

# set preferences
$ErrorActionPreference = "Stop" 
$reporootpath = (get-item $PSScriptRoot ).parent.FullName;
Set-Location $reporootpath;

# Variable declaration for api calls
$header = @{};
$header.Add("Authorization", "Bearer $github_token");
$header.Add("Accept", "application/vnd.github+json");
$header.Add("X-GitHub-Api-Version", "2022-11-28");
[string]$repo_url = "https://api.github.com/repos/StanicAndre/GitHubActionsDemo/actions/artifacts"

# get all artifacts from repo and sort them by creation date
$artifacts = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;
$sorted_artifacts = $artifacts.artifacts | Sort-Object -Descending -Property created_at

# get artifact last created and its workflow_run_id
$run_id = $sorted_artifacts[0].workflow_run.id
Write-Host "url `"$run_id`""
[string]$repo_url = "https://api.github.com/repos/StanicAndre/GitHubActionsDemo/actions/runs/$run_id/artifacts"
Write-Host "url `"$repo_url`""
$artifact = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;

Write-Host "vor der if"
$count = $artifact.total_count
if($count -ne 0)
{ 
    Write-Host "In der if"
    #delete artifact   
    $artifact_id = $artifact.artifacts.id
    Write-Host "delete artifact `"$artifact_id`""
    Invoke-RestMethod -Uri $artifact.artifacts.url -Headers $header -Method Delete;
    
}
