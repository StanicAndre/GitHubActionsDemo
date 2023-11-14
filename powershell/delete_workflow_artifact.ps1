# parameters required to call the API
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $github_token,
    
    [Parameter(Position=1, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $run_id
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
[string]$repo_url = "https://api.github.com/repos/StanicAndre/GitHubActionsDemo/actions/runs/$run_id/artifacts"

# get existing artifacts
$artifact = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;
Write-Host "vor der if"
$count = $artifact.total.count
Write-Host "Artifact count `"$count`""
if($.count -ge 1)
{ 
    Write-Host "In der if"
    #delete artifact   
    $artifact_id = $artifact.artifacts.id
    Write-Host "delete artifact `"$artifact_id`""
    Invoke-RestMethod -Uri $artifact.artifacts.url -Headers $header -Method Delete;
    
}
