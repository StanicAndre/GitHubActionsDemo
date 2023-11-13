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

# get existing artifacts
$artifacts = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;

$art_count = $artifacts.total_count;
$art_id_0 = $artifacts.artifacts[0].id;
$art_url_0 = $artifacts.artifacts[0].url;
Write-Host "count `"$art_count`""
Write-Host "id `"$art_id_0`""
Write-Host "url `"$artifacts`""

#delete artifacts
for ($i = 0; $i -lt $art_count; $i++) {
    $art_id = $artifacts[$i].id;


    Write-Host "delete artifact `"$art_id`""
    Invoke-RestMethod -Uri $artifacts[$i].url -Headers $header -Method Delete;
}  

