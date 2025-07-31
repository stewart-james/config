function Download-And-Extract-Github-Release {
    param (
        [string]$Repo,
        [string]$AssetPattern,
        [string]$ExtractPath,
        [string]$BinPath
    )

    # Check or get GitHub token from environment
    $token = $env:GITHUB_TOKEN
    if (-not $token) {
        $token = Read-Host -AsSecureString "Enter your GitHub Personal Access Token"
        $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($token))

        # Persist to user environment variable for future use
        [Environment]::SetEnvironmentVariable("GITHUB_TOKEN", $tokenPlain, "User")
        Write-Host "GitHub token saved to user environment variable `GITHUB_TOKEN`."
    }

    # Prepare headers with token
    $headers = @{
        "User-Agent" = "PowerShell"
        "Authorization" = "Bearer $token"
    }

    # Get all releases and find the latest stable one
    $releases = Invoke-RestMethod "https://api.github.com/repos/$Repo/releases" -Headers $headers
    $latest = $releases | Where-Object { -not $_.prerelease } | Select-Object -First 1

    if (-not $latest) {
        Write-Warning "No stable release found for $Repo"
        return
    }

    $asset = $latest.assets | Where-Object { $_.name -match $AssetPattern } | Select-Object -First 1

    if (-not $asset) {
        Write-Warning "No asset matching '$AssetPattern' found in $Repo"
        return
    }

    $url = $asset.browser_download_url
    $fileName = [System.IO.Path]::GetFileName($url)
    $zipPath = Join-Path $env:TEMP $fileName

    if (-Not (Test-Path $zipPath)) {
        Write-Host "Downloading $fileName..."
        Invoke-WebRequest $url -OutFile $zipPath -Headers $headers
    } else {
        Write-Host "Using cached file $fileName"
    }

    Remove-Item $ExtractPath -Recurse -Force -ErrorAction Ignore
    Expand-Archive $zipPath -DestinationPath $ExtractPath -Force

    Write-Host "Extracted to $ExtractPath"

    if ($BinPath) {
        $fullPath = [System.IO.Path]::GetFullPath($BinPath)
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User") -split ";"

        if ($userPath -notcontains $fullPath) {
            [Environment]::SetEnvironmentVariable("PATH", ($userPath + $fullPath -join ";"), "User")
            Write-Host "Added '$fullPath' to user's PATH."
        } else {
            Write-Host "'$fullPath' is already in the user's PATH."
        }
    }
}

function Download-LatestNuGetPackage {
    param (
        [string]$PackageName,
        [string]$ExtractPath
    )

    $nugetUrl = "https://api.nuget.org/v3-flatcontainer/$PackageName/index.json"
    $versions = Invoke-RestMethod -Uri $nugetUrl
    $latestVersion = $versions.versions[-1]

    Write-Host "Latest version of $PackageName is $latestVersion"

    $nupkgUrl = "https://api.nuget.org/v3-flatcontainer/$PackageName/$latestVersion/$PackageName.$latestVersion.nupkg"
    $fileName = "$PackageName.$latestVersion.nupkg"
    $zipPath = Join-Path $env:TEMP $fileName

    if (-not (Test-Path $zipPath)) {
        Write-Host "Downloading $fileName..."
        Invoke-WebRequest -Uri $nupkgUrl -OutFile $zipPath
    } else {
        Write-Host "Using cached $fileName"
    }

    # Rename nupkg to zip for Expand-Archive compatibility
    $zipTempPath = [System.IO.Path]::ChangeExtension($zipPath, ".zip")
    Copy-Item -Path $zipPath -Destination $zipTempPath -Force

    Remove-Item $ExtractPath -Recurse -Force -ErrorAction Ignore
    Expand-Archive -Path $zipTempPath -DestinationPath $ExtractPath -Force

    Remove-Item $zipTempPath

    Write-Host "Extracted $PackageName to $ExtractPath"
}


Download-And-Extract-Github-Release `
	-Repo "LuaLS/lua-language-server" `
	-AssetPattern "lua-language-server-.*-win32-x64.zip" `
	-ExtractPath "C:\projects\tools\lsp\lua" `
	-BinPath "C:\projects\tools\lsp\lua\bin"

Download-LatestNuGetPackage -PackageName "Microsoft.CodeAnalysis.LanguageServer.win-x64" -ExtractPath "C:\projects\tools\lsp\roslyn"
