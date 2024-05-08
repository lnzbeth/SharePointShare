# Define the path to the log file
$logFilePath = "$env:TEMP\SharePointCopy_$timestamp.log"

# Function to append a message to the log file
function Write-Log {
    Param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "${timestamp}: $message"
}

#Config Variables
$SiteURL = "https://thesomethingfoundation.sharepoint.com/"
$SourceFolderURL= "/subsite/Shared Documents/SuperCool" #Site Relative URL from the current site
$TargetFolderURL = "/sites/LindseyTestTeam/SharedDocuments/apple" #Server Relative URL of the Target Parent Folder

#Connecting to SharePoint Online site
Write-Log "Connecting to SharePoint Online site: $SiteURL"
Connect-PnPOnline -Url $SiteURL -Interactive
Write-Log "Successfully connected to $SiteURL"

try {
    # Copying folder to the target location
    Write-Log "Copying folder from $SourceFolderURL to $TargetFolderURL"
    Copy-PnPFile -SourceUrl $SourceFolderURL -TargetUrl $TargetFolderURL -Force
    Write-Log "Files copied successfully from Source to Destination."
}
catch {
    # If an error occurs, it will be caught here
    Write-Log "Error encountered: $_"
}

# Output a message to the user
Write-Host "Check the log at $logFilePath for details." -ForegroundColor Cyan


#Reference
#Read more: https://www.sharepointdiary.com/2018/04/copy-folder-in-sharepoint-online-using-powershell.html#ixzz8DAIZTI2b
