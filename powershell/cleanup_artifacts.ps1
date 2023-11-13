# parameters required to call the API
param(
    [Parameter(Position=2, Mandatory=$true)]
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

# get existing artifacts
$artifacts = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;

#delete artifacts
for ($i = 0; $i -lt $artifacts.Count; $i++) {
    $art_tag = $artifacts[$i].tag_name;
    $art_name = $artifacts[$i].name;


    Write-Host "delete artifact `"$art_name[$art_tag]`""
    Invoke-RestMethod -Uri $artifacts[$i].url -Headers $header -Method Delete;
}  

