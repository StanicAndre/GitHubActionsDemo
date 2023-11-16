se# parameters required to call the API
param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $repository,

    [Parameter(Position=1, Mandatory=$true)]
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
[string]$repo_url = "https://api.github.com/repos/$repository/releases"
$asset_path = "D:\a\GitHubActionsDemo\GitHubActionsDemo\README.md";
Write-Host $repo_url

#create artifact
#$create_art = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Post -InFile $file_Path
# create the draft-release
    Write-Host "create draft release"
    $req_body = @{}
    $req_body.Add("tag_name", $tag_name);
    $req_body.Add("target_commitish", "main");
    $req_body.Add("name", "$image_name $ansible_community_version");
    $req_body.Add("body", $versioninformation);
    $req_body.Add("draft", $true);
    $req_body.Add("prerelease", $false);
    $req_body.Add("generate_release_notes", $false);
    $req_body_json = ConvertTo-Json $req_body;
    $create_res = Invoke-RestMethod -Uri $repo_url -Headers $header -Method Post -ContentType application/json -body $req_body_json;

    # upload asset to created draft release
    Write-Host "upload asset to created draft release"
    [string]$asset_name = Split-Path $asset_path -leaf
    $header.Add("Content-Type", "application/octet-stream");
    [string]$upload_url = $create_res.upload_url -replace '{.+}';
    $upload_url += "?name=$asset_name"
    $upload_res = Invoke-RestMethod -Uri $upload_url -Headers $header -Method Post -InFile $asset_path;

    #publish release
    Write-Host "publish release"
    $req_body.draft = $false;
    $req_body_json = ConvertTo-Json $req_body;
    $publish_res = Invoke-RestMethod -Uri $create_res.url -Headers $header -Method Patch -ContentType application/json -body $req_body_json;
