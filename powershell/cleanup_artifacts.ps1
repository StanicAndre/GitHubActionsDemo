# parameters required to call the API
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $repository,

    [Parameter(Position=1, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [int]
    $releases_to_keep = 10,

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
[string]$repo_url = "https://github.siemens.cloud/api/v3/repos/$repository/releases"

# get existing releases and sort them descending by published_at
# also ignore draft and prereleases.
$releases = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Get;
$sorted_releases = $releases | Sort-Object -Descending -Property published_at | Where-Object { $_.draft -eq $false } | Where-Object { $_.prerelease -eq $false }

#delete releases older than the keep-number
if($sorted_releases.Count -lt $releases_to_keep){
    Write-Host "No releases for deletion found."
} else {
    for ($i = $releases_to_keep; $i -lt $sorted_releases.Count; $i++) {
        $rel_tag = $sorted_releases[$i].tag_name;
        $rel_name = $sorted_releases[$i].name;

        # delete all release assets
        foreach ($asset in $sorted_releases[$i].assets) {
            $asset_name = $asset.name
            Write-Host "delete asset `"$asset_name`" of release `"$rel_name[$rel_tag]`"" 
            Invoke-RestMethod -Uri $asset.url -Headers $header -Method Delete;
        }

        #delete the release itself
        Write-Host "delete release `"$rel_name[$rel_tag]`""
        Invoke-RestMethod -Uri $sorted_releases[$i].url -Headers $header -Method Delete;
    }   
}
