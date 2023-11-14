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

# Get all artifacts from repo and sort them by creation date
$artifacts = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;
if($artifacts.total_count -ne 0)
{
    $sorted_artifacts = $artifacts.artifacts | Sort-Object -Descending -Property created_at
    
    # Get artifact last created 
    $artifact_id = $sorted_artifacts[0].id
    Write-Host "artifact_id:  `"$artifact_id`""
    [string]$repo_url = "https://api.github.com/repos/StanicAndre/GitHubActionsDemo/actions/artifacts/$artifact_id/zip"

    # Download artifact
    [string]$redirect = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;  
    Invoke-RestMethod -Uri $redirect -Headers $header -Method Get; 
}
