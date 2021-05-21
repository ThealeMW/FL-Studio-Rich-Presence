If(-not(Get-InstalledModule discordrpc -ErrorAction silentlycontinue)){
    Install-PackageProvider NuGet -Force;
    Install-Module discordrpc -Confirm:$False -Force -ErrorAction SilentlyContinue
}

$GetFLInstallLOC = Get-ChildItem HKLM:\SOFTWARE\Image-Line\Shared\Paths* | ForEach-Object { Get-ItemProperty $_.PsPath } | Select-Object "Fl studio"

Start-Process $GetFLInstallLOC.'FL Studio'

$params = @{
    ApplicationID  = "Get an appid from - https://discord.com/developers/applications"
    LargeImageKey  = "big"
    LargeImageText = "FL Studio"
    SmallImageKey  = "small"
    SmallImageText = "FL Studio"
    Label          = "Try FL Studio"
    Url            = "https://www.image-line.com/fl-studio-download/"
    Details        = "Launching FL..."
    TimerRefresh   = 60
    Start          = "Now"
    UpdateScript   = {
        if ($splitWindowName -like "FL Studio*")
        {
            Update-DSAsset -LargeImageText "Image Line" -SmallImageText $splitFlVer
            Update-DSRichPresence -State "Idle:" -Details "No project"
        }else{
            $StateString = "Working on: "+$splitWindowName
            Update-DSAsset -LargeImageText "Image Line" -SmallImageText $splitFlVer
            Update-DSRichPresence -State $StateString -Details $splitFlVer
        }
    }
}
Start-DSClient @params | Out-Null 
do
{
    Start-Sleep -Seconds 60
     try {
        $FlStudioVer = Get-Process -Name FL64 -ErrorAction SilentlyContinue | Select-Object ProcessName, MainWindowTitle
    }
    catch {
        Write-Host "64Bit not found proceeding with 32bit"
    }
    finally{
        $FlStudioVer = Get-Process -Name FL -ErrorAction SilentlyContinue | Select-Object ProcessName, MainWindowTitle
    }
    if (!$FlStudioVer)
    {
        Stop-DSClient
        break
    }
    $splitWindowName = $FlStudioVer.MainWindowTitle.split('.')[0]
    $splitFlVer = $FlStudioVer.MainWindowTitle.split('-')[1]
}
until (!$FlStudioVer)
Stop-DSClient